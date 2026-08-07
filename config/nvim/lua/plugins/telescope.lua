-- Telescope: ファジーファインダー（VSCode の Cmd+P / Cmd+Shift+P）
return {
  {
    "nvim-telescope/telescope.nvim",
    branch       = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond  = function() return vim.fn.executable("make") == 1 end,
      },
    },
    keys = {
      { "<Leader>ff", "<cmd>Telescope find_files<cr>",            desc = "Find files" },
      { "<Leader>fg", "<cmd>Telescope live_grep<cr>",             desc = "Live grep" },
      { "<Leader>fb", "<cmd>Telescope buffers<cr>",               desc = "Find buffers" },
      { "<Leader>fr", "<cmd>Telescope oldfiles<cr>",              desc = "Recent files" },
      { "<Leader>fs", "<cmd>Telescope lsp_document_symbols<cr>",  desc = "Document symbols" },
      { "<Leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<Leader>fc", "<cmd>Telescope commands<cr>",              desc = "Commands" },
      { "<Leader>gc", "<cmd>Telescope git_commits<cr>",           desc = "Git commits" },
      { "<M-g>",      "<cmd>Telescope live_grep<cr>",             desc = "Live grep (Cmd+Shift+F)" },
      { "<Leader>fw", "<cmd>Telescope grep_string<cr>",           desc = "Grep word under cursor" },
    },
    config = function()
      local telescope = require("telescope")
      local actions   = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix   = "  ",
          selection_caret = " ",
          path_display    = { "smart" },
          layout_strategy = "center",
          layout_config   = {
            center = { width = 0.6, height = 0.7 },
          },
          sorting_strategy = "ascending",
          file_ignore_patterns = {
            "node_modules", ".git/", "__pycache__", "%.pyc",
            ".venv/", "dist/", "build/",
          },
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = { hidden = true },
          live_grep  = { additional_args = { "--hidden" } },
        },
      })

      pcall(telescope.load_extension, "fzf")

      local builtin = require("telescope.builtin")
      local map     = vim.keymap.set

      map("n", "<Leader>ff", builtin.find_files,              { desc = "Find files" })
      map("n", "<Leader>fg", builtin.live_grep,               { desc = "Live grep" })
      map("n", "<Leader>fb", builtin.buffers,                 { desc = "Find buffers" })
      map("n", "<Leader>fr", builtin.oldfiles,                { desc = "Recent files" })
      map("n", "<Leader>fs", builtin.lsp_document_symbols,   { desc = "Document symbols" })
      map("n", "<Leader>fS", builtin.lsp_workspace_symbols,  { desc = "Workspace symbols" })
      map("n", "<Leader>fc", builtin.commands,                { desc = "Commands" })
      map("n", "<Leader>gc", builtin.git_commits,             { desc = "Git commits" })
      map("n", "<M-g>", builtin.live_grep,                { desc = "Live grep (Cmd+Shift+F)" })
      map("n", "<Leader>fw", function()
        builtin.grep_string({ search = vim.fn.expand("<cword>") })
      end, { desc = "Grep word under cursor" })
    end,
  },
}
