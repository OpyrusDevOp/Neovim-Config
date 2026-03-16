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
}
