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
    "williamboman/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:crashdummyy/mason-registry", -- Required for roslyn and rzls
      },
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
          cmd = { "omnisharp" }, -- Replace with your OmniSharp.dll path
          filetypes = { "cs", "razor", "vb" },
          root_dir = require("lspconfig.util").root_pattern("*.sln", "*.csproj", "omnisharp.json"),
          handlers = {
            ["textDocument/definition"] = require("omnisharp_extended").handler,
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
          root_dir = require("lspconfig.util").root_pattern("package.json", ".git"),
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
          root_dir = require("lspconfig.util").root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
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
}
