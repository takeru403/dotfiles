-- oil.nvim: バッファとして編集できるファイルマネージャー
return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
  config = function()
    require("oil").setup({
      columns = { "icon", "permissions", "size", "mtime" },
      keymaps = {
        ["g?"]    = "actions.show_help",
        ["<CR>"]  = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["-"]     = "actions.parent",
        ["_"]     = "actions.open_cwd",
        ["`"]     = "actions.cd",
        ["~"]     = "actions.tcd",
        ["gs"]    = "actions.change_sort",
        ["gx"]    = "actions.open_external",
        ["g."]    = "actions.toggle_hidden",
      },
      use_default_keymaps = false,
      view_options = {
        show_hidden = true,
      },
    })

    local map = vim.keymap.set
    map("n", "-",         "<CMD>Oil<CR>", { desc = "Open file explorer" })
    map("n", "<Leader>e", "<CMD>Oil<CR>", { desc = "File explorer" })
  end,
}
