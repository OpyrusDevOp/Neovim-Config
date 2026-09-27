return {
  -- Existing Flutter Tools setup
  { "Mofiqul/dracula.nvim" },
  {
    "jlcrochet/vim-razor",
    ft = "razor",
  },
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
      -- your configuration comes here; leave empty for default settings
    },
  },

  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" }, -- Load for C# and Razor files
    dependencies = {
      {
        "tris203/rzls.nvim",
        config = function()
          require("rzls").setup({})
        end,
      },
    },
    config = function()
      require("roslyn").setup({
        args = {
          "--stdio",
          "--logLevel=Information",
          "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
          "--razorSourceGenerator=" .. vim.fs.joinpath(
            vim.fn.stdpath("data"),
            "mason",
            "packages",
            "roslyn",
            "libexec",
            "Microsoft.CodeAnalysis.Razor.Compiler.dll"
          ),
          "--razorDesignTimePath=" .. vim.fs.joinpath(
            vim.fn.stdpath("data"),
            "mason",
            "packages",
            "rzls",
            "libexec",
            "Targets",
            "Microsoft.NET.Sdk.Razor.DesignTime.targets"
          ),
        },
        config = {
          handlers = require("rzls.roslyn_handlers"),
          -- Add any additional roslyn.nvim settings here if needed
        },
      })
    end,
  },
  -- Ensure html-lsp is configured for Razor completions and formatting
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {}, -- Enable html-lsp
      },
    },
  },
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
  },
  {
    "ckipp01/nvim-jenkinsfile-linter",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "kylechui/nvim-surround",
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end,
  },
  -- Configure LazyVim to load dracula
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
  {
    "nvim-flutter/flutter-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
    config = true,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    opts = function()
      local cmp = require("cmp")
      return {
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
      }
    end,
  },

  -- Existing nvim-cmp setup with HTML/CSS
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "Jezda1337/nvim-html-css", -- add it as dependencies of nvim-cmp or standalone plugin
      "nvim-lua/plenary.nvim", -- Required for floating windows
    },
    opts = {
      sources = {
        {
          name = "html-css",
          option = {
            enable_on = { "html", "css" }, -- html is enabled by default
            notify = false,
            documentation = {
              auto_show = true, -- show documentation on select
            },
            -- add any external scss like one below
            style_sheets = {
              "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css",
              "https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css",
            },
          },
        },
      },
    },
  },

  -- OmniSharp LSP Setup
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {

        omnisharp = {
          -- cmd/root_dir intentionally left to lspconfig defaults (they need --languageserver etc.)
          filetypes = { "cs", "razor", "vb" },
          handlers = {
            ["textDocument/definition"] = function(...)
              return require("omnisharp_extended").handler(...)
            end,
          },
          settings = {
            FormattingOptions = {
              EnableEditorConfigSupport = true, -- Use .editorconfig for formatting
            },
            MsBuild = {
              LoadProjectsOnDemand = true, -- Load only opened projects for faster startup
            },
            RoslynExtensionsOptions = {

              EnableAnalyzersSupport = true, -- Enable analyzers
              EnableImportCompletion = true, -- Enable unimported types/methods in completion
              AnalyzeOpenDocumentsOnly = true, -- Analyze only open files
            },
            Sdk = {
              IncludePrereleases = false, -- Include .NET SDK previews
            },
          },
        },
        -- CSS/SCSS/Less LSP Setup (cssls)
        cssls = {
          cmd = { "vscode-css-language-server", "--stdio" },
          filetypes = { "css", "scss", "less" },
          root_markers = { "package.json", ".git" },
          single_file_support = true,
          settings = {
            css = { validate = true },
            scss = { validate = true },
            less = { validate = true },
          },
          capabilities = vim.tbl_extend("keep", vim.lsp.protocol.make_client_capabilities(), {
            textDocument = {
              completion = {
                completionItem = {
                  snippetSupport = true, -- Enable snippet support for better completions
                },
              },
            },
          }),
        },
        phpactor = {
          on_attach = function(client, bufnr)
            -- Call LazyVim's default on_attach if needed
            if require("lazyvim.util").on_attach then
              require("lazyvim.util").on_attach(client, bufnr)
            end
          end,
          init_options = {
            ["language_server_phpstan.enabled"] = true,
            ["language_server_psalm.enabled"] = false,
          },
        },
        html = {
          filetypes = { "html" },
          settings = {
            html = {
              format = {
                enable = true,
              },
              hover = {
                documentation = true,
                references = true,
              },
              validate = true,
              -- Enables JavaScript support inside <script> tags
              embeddedLanguages = {
                javascript = true,
              },
            },
          },
        },
        tsserver = { -- For JavaScript/TypeScript files
          filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
          root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
        },
      },
      config = function()
        local Float = require("plenary.window.float")

        -- Floating window display function
        local function showWindow(title, syntax, contents)
          local out = {}
          for match in string.gmatch(contents, "[^\n]+") do
            table.insert(out, match)
          end

          local float = Float.percentage_range_window(0.6, 0.4, { winblend = 0 }, {
            title = title,
            topleft = "┌",
            topright = "┐",
            top = "─",
            left = "│",
            right = "│",
            botleft = "└",
            botright = "┘",
            bot = "─",
          })

          vim.api.nvim_buf_set_option(float.bufnr, "filetype", syntax)
          vim.api.nvim_buf_set_lines(float.bufnr, 0, -1, false, out)
        end

        -- PHPActor Commands
        function LspPhpactorDumpConfig()
          local results, _ = vim.lsp.buf_request_sync(0, "phpactor/debug/config", { ["return"] = true })
          for _, res in pairs(results or {}) do
            pcall(showWindow, "Phpactor LSP Configuration", "json", res["result"])
          end
        end

        function LspPhpactorStatus()
          local results, _ = vim.lsp.buf_request_sync(0, "phpactor/status", { ["return"] = true })
          for _, res in pairs(results or {}) do
            pcall(showWindow, "Phpactor Status", "markdown", res["result"])
          end
        end

        function LspPhpactorBlackfireStart()
          vim.lsp.buf_request_sync(0, "blackfire/start", {})
        end

        function LspPhpactorBlackfireFinish()
          vim.lsp.buf_request_sync(0, "blackfire/finish", {})
        end

        -- Auto-commands for PHP files
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "php",
          callback = function()
            vim.api.nvim_buf_create_user_command(0, "LspPhpactorReindex", function()
              vim.lsp.buf_notify(0, "phpactor/indexer/reindex", {})
            end, {})

            vim.api.nvim_buf_create_user_command(0, "LspPhpactorConfig", function()
              LspPhpactorDumpConfig()
            end, {})

            vim.api.nvim_buf_create_user_command(0, "LspPhpactorStatus", function()
              LspPhpactorStatus()
            end, {})

            vim.api.nvim_buf_create_user_command(0, "LspPhpactorBlackfireStart", function()
              LspPhpactorBlackfireStart()
            end, {})

            vim.api.nvim_buf_create_user_command(0, "LspPhpactorBlackfireFinish", function()
              LspPhpactorBlackfireFinish()
            end, {})
          end,
        })
      end,
    },
  },
  {
    "yuukiflow/Arduino-Nvim",
    ft = "arduino",
    dependencies = { "nvim-telescope/telescope.nvim", "neovim/nvim-lspconfig" },
    -- setup() only registers autocommands, and they have to exist before any
    -- buffer is opened: a sketch's .h/.cpp files have filetype "cpp", so
    -- ft="arduino" would never load this plugin for them and the compilation
    -- database clangd needs would never be written.  init runs at startup.
    init = function()
      require("config.arduino_sketch").setup()
    end,
    config = function()
      -- arduino-language-server 0.7.x panics and dies on two requests:
      --  * documentHighlight: nil deref whenever clangd returns an error.
      --  * documentSymbol: clangd >= 21 tags symbols (declaration, definition,
      --    ...) and clang2IdeSymbolTags panics "not implemented" on any tag
      --    but Deprecated.  Outline, breadcrumbs and lualine all ask for it.
      -- Hiding the capabilities is not enough: some plugin asks for symbols
      -- without checking, so the requests themselves are dropped as well.
      --
      -- It also forwards our completion capabilities to clangd, and with
      -- insertReplaceSupport clangd answers with InsertReplaceEdits, which it
      -- then fails to decode as TextEdits ("undefined required field range").
      --
      -- This has to live on "*": Arduino-Nvim assigns its config wholesale
      -- (dropping anything set on the named config) and calls vim.lsp.enable,
      -- which starts the server synchronously, so there is no gap to patch it
      -- in afterwards.
      --
      -- Editing near a function signature can also desync it for good: its
      -- .ino -> .ino.cpp line map stops updating (a short-circuited
      -- `dirty = dirty || s.addInoLine(...)` in sourcemapper), clangd rejects
      -- the next edit ("Range's end position is before start position") and
      -- drops the file.  Its own rebuild only sends a didChange, which clangd
      -- ignores for a dropped file, so every request fails with "non-added
      -- document" until a restart.  Reopening the buffer makes it didOpen the
      -- rebuilt .ino.cpp again.
      local arduino_blocked = {
        ["textDocument/documentHighlight"] = true,
        ["textDocument/documentSymbol"] = true,
      }
      local arduino_crashes = {} -- uv.now() of recent crashes
      local arduino_resync_pending = false
      local function arduino_resync(client)
        if arduino_resync_pending then
          return
        end
        arduino_resync_pending = true
        vim.defer_fn(function()
          arduino_resync_pending = false
          if client:is_stopped() then
            return
          end
          for bufnr in pairs(vim.deepcopy(client.attached_buffers)) do
            vim.lsp.buf_detach_client(bufnr, client.id)
            vim.lsp.buf_attach_client(bufnr, client.id)
          end
        end, 500)
      end
      vim.lsp.config("*", {
        before_init = function(params, config)
          if config.name == "arduino-language-server" then
            local item = vim.tbl_get(params, "capabilities", "textDocument", "completion", "completionItem")
            if item then
              item.insertReplaceSupport = false
            end
          end
        end,
        on_init = function(client)
          if client.name == "arduino-language-server" then
            client.server_capabilities.documentHighlightProvider = false
            client.server_capabilities.documentSymbolProvider = false
            local request = client.request
            client.request = function(self, method, ...)
              if arduino_blocked[method] then
                return false
              end
              return request(self, method, ...)
            end
          end
        end,
        -- The same stale line map can also make it panic ("Line access out of
        -- range") and exit.  Nothing restarts it, so bring it back ourselves,
        -- a few times at most in case it dies on startup.
        on_exit = function(code, _, client_id)
          local client = vim.lsp.get_client_by_id(client_id)
          if code == 0 or not client or client.name ~= "arduino-language-server" then
            return
          end
          local now = vim.uv.now()
          arduino_crashes = vim.tbl_filter(function(t)
            return now - t < 60000
          end, arduino_crashes)
          if #arduino_crashes >= 3 then
            return vim.notify("arduino-language-server keeps crashing, not restarting it", vim.log.levels.ERROR)
          end
          table.insert(arduino_crashes, now)
          local bufs = vim.tbl_keys(client.attached_buffers)
          vim.defer_fn(function()
            for _, bufnr in ipairs(bufs) do
              if vim.api.nvim_buf_is_loaded(bufnr) then
                vim.api.nvim_exec_autocmds("FileType", { group = "nvim.lsp.enable", buffer = bufnr })
              end
            end
          end, 1000)
        end,
        -- Its error replies also carry `result: null`, which Neovim rejects as
        -- INVALID_SERVER_MESSAGE, so they surface here and not in handlers.
        on_error = function(_, err)
          local client = vim.lsp.get_clients({ name = "arduino-language-server" })[1]
          if client and vim.inspect(err):find("non%-added document") then
            arduino_resync(client)
          end
        end,
      })

      require("Arduino-Nvim").setup()

      -- Quick keymaps for compilation and flashing
      vim.keymap.set("n", "<leader>ac", "<cmd>InoCheck<cr>", { desc = "Arduino: Compile Sketch" })
      vim.keymap.set("n", "<leader>au", "<cmd>InoUpload<cr>", { desc = "Arduino: Upload Sketch" })
      vim.keymap.set("n", "<leader>as", "<cmd>InoMonitor<cr>", { desc = "Arduino: Serial Monitor" })
    end,
  },
}
