-- nvim-tree: VSCode ライクなサイドバーファイルエクスプローラー
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
  config = function()
    -- netrw を無効化
    vim.g.loaded_netrw       = 1
    vim.g.loaded_netrwPlugin = 1

    require("nvim-tree").setup({
      hijack_cursor      = false,
      sync_root_with_cwd = true,
      respect_buf_cwd    = true,
      update_focused_file = {
        enable      = true,
        update_root = false,
      },
      view = {
        width = 35,
        side  = "left",
      },
      renderer = {
        group_empty = true,
        icons = {
          show = {
            file         = true,
            folder       = true,
            folder_arrow = true,
            git          = true,
          },
        },
      },
      filters = {
        dotfiles = false,
      },
      git = {
        enable = true,
        ignore = false,
      },
      actions = {
        open_file = {
          quit_on_open  = false,
          window_picker = { enable = true },
        },
      },
    })
  end,
}
