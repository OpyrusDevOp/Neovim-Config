-- clangd for the .h/.cpp files in an Arduino sketch.
--
-- arduino-language-server registers as ft="arduino", which only ever matches
-- the .ino.  Once a sketch is split into modules those .h/.cpp files are
-- plain cpp buffers with no LSP attached at all.  clangd picks them up from
-- the compile_commands.json that config.arduino_sketch generates.
--
-- --query-driver is the important part: it lets clangd run avr-g++ and ask it
-- for its target and system include paths, instead of guessing host ones and
-- failing to find <avr/io.h>.  See also the .clangd file in the sketch, which
-- strips the few avr-gcc flags clang's driver rejects.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--completion-style=detailed",
            "--header-insertion=never",
            -- clangd does this globbing itself, so no expand() here.
            "--query-driver=" .. vim.env.HOME .. "/.arduino15/packages/**/bin/avr-*",
          },
          filetypes = { "c", "cpp", "objc", "objcpp" },
          root_markers = { "compile_commands.json", ".clangd", "sketch.yaml", ".git" },
        },
      },
    },
  },
}
