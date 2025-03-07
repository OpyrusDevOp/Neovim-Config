--if true then
---  return {}
---end
return {
  {
    "andweeb/presence.nvim",
    config = function()
      require("presence").setup({
        -- General options
        auto_update = true, -- Update activity based on autocmd events
        neovim_image_text = "The One True Text Editor", -- Text displayed when hovered over the Neovim image
        main_image = "neovim", -- Main image display (either "neovim" or "file")
        client_id = "793271441293967371", -- Use your own Discord application client id (not recommended)
        log_level = nil, -- Log messages at or above this level
        debounce_timeout = 10, -- Number of seconds to debounce events
        enable_line_number = false, -- Displays the current line number instead of the current project
        blacklist = {}, -- A list of strings or Lua patterns to disable Rich Presence
        buttons = true, -- Enable/disable Rich Presence buttons
        file_assets = {}, -- Custom file asset definitions keyed by file names/extensions
        show_time = true, -- Show the timer

        -- Rich Presence text options
        editing_text = "Editing %s", -- Format string for editing
        file_explorer_text = "Browsing %s", -- Format string for browsing
        git_commit_text = "Committing changes", -- Format string for git commit
        plugin_manager_text = "Managing plugins", -- Format string for managing plugins
        reading_text = "Reading %s", -- Format string for reading
        workspace_text = "Working on %s", -- Format string for workspace
        line_number_text = "Line %s out of %s", -- Format string for line numbers
      })
    end,
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
    opts = {
      -- add any opts here
      -- for example
      provider = "gemini",
      gemini = {
        endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
        model = "gemini-1.5-flash-latest",
        timeout = 30000, -- Timeout in milliseconds
        temperature = 0,
        max_tokens = 4096,
      },
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "Claude 3 Haiku",
        timeout = 30000, -- Timeout in milliseconds
        temperature = 0,
        max_tokens = 8000,
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
