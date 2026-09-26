-- Auto-generate sketch.yaml for Arduino sketches so arduino-language-server
-- knows which board (FQBN) to use.
local M = {}

local asked = {} -- sketch dirs already handled this session

local function json(str)
  local ok, data = pcall(vim.json.decode, str)
  return ok and data or nil
end

local ns = vim.api.nvim_create_namespace("arduino_preflight")
local running = {} -- dir -> true while a preflight compile is in flight

local function sketch_fqbn(dir)
  local f = dir .. "/sketch.yaml"
  if vim.fn.filereadable(f) == 0 then
    return nil
  end
  for _, l in ipairs(vim.fn.readfile(f)) do
    local v = l:match("^default_fqbn:%s*(%S+)")
    if v then
      return v
    end
  end
end

-- arduino-cli writes its compilation database against the copies it makes in
-- the build folder, so clangd never matches the real .cpp files in the sketch.
-- Point those entries back at the sources; entries for the core and the
-- libraries are left as they are.  Car.ino.cpp has no counterpart in the
-- sketch and is skipped, which keeps clangd off the .ino that
-- arduino-language-server owns.
local function write_compile_commands(dir, build)
  local f = build .. "/compile_commands.json"
  if vim.fn.filereadable(f) == 0 then
    return
  end
  local db = json(table.concat(vim.fn.readfile(f), "\n"))
  if type(db) ~= "table" then
    return
  end
  for _, e in ipairs(db) do
    local file = e.file or ""
    local src = dir .. "/" .. vim.fs.basename(file)
    if vim.startswith(file, build) and vim.fn.filereadable(src) == 1 then
      for i, a in ipairs(e.arguments or {}) do
        if a == file then
          e.arguments[i] = src
        end
      end
      e.file = src
    end
  end
  vim.fn.writefile({ vim.json.encode(db) }, dir .. "/compile_commands.json")
end

-- arduino-language-server needs `arduino-cli compile` to succeed to start clangd.
-- Run it ourselves first and surface missing libraries as diagnostics instead.
function M.preflight(dir)
  local fqbn = sketch_fqbn(dir)
  if not fqbn or running[dir] or vim.fn.executable("arduino-cli") == 0 then
    return
  end
  running[dir] = true
  -- Kept inside the sketch rather than in a temp dir: the compilation
  -- database has to outlive the compile for clangd to read it, and the build
  -- cache makes the next preflight much quicker.  arduino-cli ignores
  -- dot-directories, so this does not end up in the firmware.
  local build = dir .. "/.build"
  vim.system(
    { "arduino-cli", "compile", "--fqbn", fqbn, "--only-compilation-database", "--build-path", build, dir },
    { text = true },
    function(res)
      vim.schedule(function()
        running[dir] = nil
        local by_buf, missing = {}, {}
        for line in ((res.stderr or "") .. "\n" .. (res.stdout or "")):gmatch("[^\n]+") do
          local file, lnum, col, hdr = line:match("^(.-):(%d+):(%d+): fatal error: (.-): No such file")
          if file then
            local b = vim.fn.bufnr(file)
            by_buf[b] = by_buf[b] or {}
            table.insert(by_buf[b], {
              lnum = tonumber(lnum) - 1,
              col = tonumber(col) - 1,
              severity = vim.diagnostic.severity.ERROR,
              source = "arduino-cli",
              message = ("Library missing: %s (try `arduino-cli lib search %s`)"):format(
                hdr,
                (hdr:gsub("%.h[p]*$", ""))
              ),
            })
            table.insert(missing, hdr)
          end
        end
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(b) and vim.fs.dirname(vim.api.nvim_buf_get_name(b)) == dir then
            vim.diagnostic.set(ns, b, by_buf[b] or {})
          end
        end
        if #missing > 0 then
          vim.notify("Arduino LSP can't start, missing: " .. table.concat(missing, ", "), vim.log.levels.WARN)
        elseif res.code == 0 then
          write_compile_commands(dir, build)
          -- compile works now; make sure the server is running.  Only the .ino
          -- wants arduino-language-server, so a preflight triggered from one of
          -- the sketch's .cpp buffers must not drag it in - those belong to
          -- clangd, which picks the database up on its own.
          local has_ino = false
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if
              vim.api.nvim_buf_is_loaded(b)
              and vim.bo[b].filetype == "arduino"
              and vim.fs.dirname(vim.api.nvim_buf_get_name(b)) == dir
            then
              has_ino = true
              break
            end
          end
          if has_ino and #vim.lsp.get_clients({ name = "arduino-language-server" }) == 0 then
            pcall(vim.cmd, "LspStart arduino-language-server")
          end
        end
      end)
    end
  )
end

local function write_sketch_yaml(dir, fqbn, port)
  local lines = { "default_fqbn: " .. fqbn }
  if port then
    table.insert(lines, "default_port: " .. port)
  end
  vim.fn.writefile(lines, dir .. "/sketch.yaml")
  vim.notify("Created " .. dir .. "/sketch.yaml (" .. fqbn .. ")", vim.log.levels.INFO)
  -- Restart the language server so it picks up the new board
  vim.schedule(function()
    vim.cmd("LspRestart arduino-language-server")
    M.preflight(dir)
  end)
end

-- The port lives in two places: sketch.yaml (used by arduino-cli run from a
-- terminal) and the sketch's .arduino_config.lua (used by Arduino-Nvim's
-- InoUpload/InoMonitor).  Keep both in step, plus the plugin's live value.
function M.set_port(dir, port)
  local yaml = dir .. "/sketch.yaml"
  local lines = vim.fn.filereadable(yaml) == 1 and vim.fn.readfile(yaml) or {}
  local found = false
  for i, l in ipairs(lines) do
    if l:match("^default_port:") then
      lines[i] = "default_port: " .. port
      found = true
    end
  end
  if not found then
    table.insert(lines, "default_port: " .. port)
  end
  vim.fn.writefile(lines, yaml)

  local cfg_file = dir .. "/.arduino_config.lua"
  local ok, cfg = pcall(dofile, cfg_file)
  cfg = ok and type(cfg) == "table" and cfg or {}
  cfg.board = cfg.board or sketch_fqbn(dir) or "arduino:avr:uno"
  cfg.baudrate = cfg.baudrate or "115200"
  cfg.port = port
  vim.fn.writefile({
    "return {",
    ("  board = %q,"):format(cfg.board),
    ("  port = %q,"):format(cfg.port),
    ("  baudrate = %q,"):format(tostring(cfg.baudrate)),
    "}",
  }, cfg_file)

  if _ArduinoConfigValues then
    _ArduinoConfigValues.port = port
  end
  vim.notify("Arduino port: " .. port, vim.log.levels.INFO)
end

-- Serial devices present right now, whether or not arduino-cli recognises them
local function serial_ports()
  local ports = vim.fn.glob("/dev/tty{ACM,USB}*", false, true)
  vim.list_extend(ports, vim.fn.glob("/dev/serial/by-id/*", false, true))
  return ports
end

-- Returns { {name=, fqbn=, port=}, ... } for connected boards
local function detected_boards(out)
  local data = json(out) or {}
  local ports = data.detected_ports or data -- new CLI wraps in detected_ports
  local boards = {}
  for _, p in ipairs(ports) do
    for _, b in ipairs(p.matching_boards or {}) do
      table.insert(boards, { name = b.name, fqbn = b.fqbn, port = p.port and p.port.address })
    end
  end
  return boards
end

local function pick_from_all(dir)
  vim.system({ "arduino-cli", "board", "listall", "--format", "json" }, { text = true }, function(res)
    vim.schedule(function()
      local boards = (json(res.stdout or "") or {}).boards or {}
      if #boards == 0 then
        return vim.notify("No boards found. Run `arduino-cli core install <core>`", vim.log.levels.WARN)
      end
      vim.ui.select(boards, {
        prompt = "Board for sketch.yaml:",
        format_item = function(b)
          return b.name .. "  (" .. b.fqbn .. ")"
        end,
      }, function(choice)
        if choice then
          write_sketch_yaml(dir, choice.fqbn)
        end
      end)
    end)
  end)
end

function M.ensure(bufnr)
  if vim.fn.executable("arduino-cli") == 0 then
    return
  end
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    return
  end
  local dir = vim.fs.dirname(file)
  if vim.uv.fs_stat(dir .. "/sketch.yaml") then
    if not asked[dir] then
      asked[dir] = true
      M.preflight(dir)
    end
    return
  end
  if asked[dir] then
    return
  end
  asked[dir] = true

  vim.system({ "arduino-cli", "board", "list", "--format", "json" }, { text = true }, function(res)
    vim.schedule(function()
      local boards = detected_boards(res.stdout or "")
      if #boards == 1 then
        write_sketch_yaml(dir, boards[1].fqbn, boards[1].port)
      elseif #boards > 1 then
        vim.ui.select(boards, {
          prompt = "Detected boards:",
          format_item = function(b)
            return ("%s  (%s @ %s)"):format(b.name, b.fqbn, b.port or "?")
          end,
        }, function(choice)
          if choice then
            write_sketch_yaml(dir, choice.fqbn, choice.port)
          end
        end)
      else
        pick_from_all(dir) -- nothing plugged in: choose manually
      end
    end)
  end)
end

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("arduino_sketch_yaml", { clear = true }),
    pattern = "arduino",
    callback = function(ev)
      M.ensure(ev.buf)
    end,
  })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("arduino_preflight", { clear = true }),
    pattern = { "*.ino", "*.h", "*.cpp", "*.c" },
    callback = function(ev)
      -- A split-out .h/.cpp has filetype "cpp", not "arduino", so the presence
      -- of sketch.yaml is what marks it as part of a sketch.
      local dir = vim.fs.dirname(ev.file)
      if vim.bo[ev.buf].filetype == "arduino" or vim.uv.fs_stat(dir .. "/sketch.yaml") then
        M.preflight(dir)
      end
    end,
  })
  -- Opening a module in a sketch should build the database too, so clangd has
  -- something to attach to on a fresh session.  M.ensure is deliberately not
  -- used here: it would prompt for a board for any stray C++ file.
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("arduino_sketch_cpp", { clear = true }),
    pattern = { "c", "cpp" },
    callback = function(ev)
      local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(ev.buf))
      if dir ~= "" and vim.uv.fs_stat(dir .. "/sketch.yaml") then
        M.preflight(dir)
      end
    end,
  })
  vim.api.nvim_create_user_command("ArduinoCompileDb", function()
    M.preflight(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
  end, { desc = "Regenerate compile_commands.json for the current sketch" })
  vim.api.nvim_create_user_command("ArduinoSketchInit", function()
    local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
    asked[dir] = nil
    vim.fn.delete(dir .. "/sketch.yaml")
    M.ensure(0)
  end, { desc = "Regenerate sketch.yaml for the current sketch" })
  vim.api.nvim_create_user_command("ArduinoPort", function(opts)
    local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
    if opts.args ~= "" then
      return M.set_port(dir, opts.args)
    end
    local ports = serial_ports()
    if #ports == 0 then
      return vim.notify(
        "No serial ports found. Plug the board in, or pass one: :ArduinoPort /dev/ttyACM0",
        vim.log.levels.WARN
      )
    end
    vim.ui.select(ports, { prompt = "Port for this sketch:" }, function(choice)
      if choice then
        M.set_port(dir, choice)
      end
    end)
  end, {
    nargs = "?",
    complete = function()
      return serial_ports()
    end,
    desc = "Set the default port for the current sketch",
  })
  vim.keymap.set("n", "<leader>ap", "<cmd>ArduinoPort<cr>", { desc = "Arduino: Set Port" })
end

return M
