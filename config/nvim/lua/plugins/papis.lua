-- papis.nvim: bibliography manager integration
return {
  {
    "jghauser/papis.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("papis").setup({
        enable_keymaps = true,
      })
    end,
  },
}
