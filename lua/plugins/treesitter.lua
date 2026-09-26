return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "arduino", "cpp" })
      vim.filetype.add({
        extension = {
          razor = "razor",
          cshmtl = "razor",
        },
      })
    end,
  },
}
