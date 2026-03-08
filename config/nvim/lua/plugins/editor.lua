-- エディタ支援: autopairs / Comment / surround / gitsigns / toggleterm / trouble
return {

  -- vim と tmux のペイン移動を Ctrl+hjkl で統一
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>",  "<cmd>TmuxNavigateLeft<cr>",     desc = "Window/pane left" },
      { "<C-j>",  "<cmd>TmuxNavigateDown<cr>",     desc = "Window/pane down" },
      { "<C-k>",  "<cmd>TmuxNavigateUp<cr>",       desc = "Window/pane up" },
      { "<C-l>",  "<cmd>TmuxNavigateRight<cr>",    desc = "Window/pane right" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Window/pane previous" },
    },
  },

  -- 括弧・クォートの自動閉じ
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts  = { check_ts = true },
    config = function(_, opts)
      local autopairs = require("nvim-autopairs")
      autopairs.setup(opts)
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local ok, cmp = pcall(require, "cmp")
      if ok then
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },

  -- コメントトグル（gc / gcc / Cmd+/）
  {
    "numToStr/Comment.nvim",
    event = "BufReadPre",
    config = function()
      require("Comment").setup()
      local api = require("Comment.api")
      local map = vim.keymap.set

      -- Ghostty が Cmd+/ を \x1f (Ctrl+_) として送信
      map("n", "<C-_>", api.toggle.linewise.current, { desc = "Toggle comment (Cmd+/)" })
      map("n", "<C-/>", api.toggle.linewise.current, { desc = "Toggle comment (Cmd+/)" })

      local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
      map("v", "<C-_>", function()
        vim.api.nvim_feedkeys(esc, "nx", false)
        api.toggle.linewise(vim.fn.visualmode())
      end, { desc = "Toggle comment (Cmd+/)" })
      map("v", "<C-/>", function()
        vim.api.nvim_feedkeys(esc, "nx", false)
        api.toggle.linewise(vim.fn.visualmode())
      end, { desc = "Toggle comment (Cmd+/)" })
    end,
  },

  -- surround 操作（ysiw" / cs"' / ds"）
  {
    "kylechui/nvim-surround",
    version = "*",
    event   = "VeryLazy",
    opts    = {},
  },

  -- Git の変更をガターに表示
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts  = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "┆" },
      },
      word_diff  = true,
      linehl     = true,
      numhl      = true,
      current_line_blame = true,
      current_line_blame_opts = {
        delay        = 100,
        virt_text_pos = "eol",
      },
      on_attach = function(bufnr)
        local gs   = package.loaded.gitsigns
        local map  = vim.keymap.set
        local opts = function(desc) return { buffer = bufnr, desc = desc } end

        map("n", "]h", gs.next_hunk,            opts("Next hunk"))
        map("n", "[h", gs.prev_hunk,            opts("Prev hunk"))
        map("n", "<Leader>hs", gs.stage_hunk,   opts("Stage hunk"))
        map("n", "<Leader>hr", gs.reset_hunk,   opts("Reset hunk"))
        map("n", "<Leader>hS", gs.stage_buffer, opts("Stage buffer"))
        map("n", "<Leader>hR", gs.reset_buffer, opts("Reset buffer"))
        map("n", "<Leader>hp", gs.preview_hunk, opts("Preview hunk"))
        map("n", "<Leader>hb", gs.blame_line,   opts("Blame line"))
        map("n", "<Leader>hd", gs.diffthis,     opts("Diff this"))
      end,
    },
  },

  -- 統合ターミナル（Cmd+Enter / <C-t> でトグル）
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys    = { "<C-t>" },
    opts    = {
      open_mapping = [[<C-t>]],
      direction    = "horizontal",
      size         = 15,
      shell        = vim.o.shell,
    },
  },

  -- Diagnostics パネル
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd  = { "Trouble" },
    keys = {
      { "<Leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "All diagnostics" },
      { "<Leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<Leader>xl", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location list" },
      { "<Leader>xq", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix list" },
    },
    opts = {},
  },

  -- 検索ハイライト（n/N 移動時に件数表示）
  {
    "kevinhwang91/nvim-hlslens",
    event = "BufReadPost",
    config = function()
      require("hlslens").setup()
      local map = vim.keymap.set
      map("n", "n", [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]])
      map("n", "N", [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]])
      map("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]])
      map("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]])
    end,
  },

  -- 複数カーソル（Cmd+D / <C-n> で次の同単語を選択）
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event  = "BufReadPost",
    init = function()
      vim.g.VM_maps = {
        ["Find Under"]         = "<C-n>",
        ["Find Subword Under"] = "<C-n>",
      }
    end,
    config = function()
      vim.keymap.set("n", "<M-d>", "<Plug>(VM-Find-Under)",
        { desc = "Multi-cursor: select next (Cmd+D)" })
    end,
  },

  -- Markdown プレビュー（Mermaid 対応）
  {
    "iamcco/markdown-preview.nvim",
    cmd   = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft    = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    keys  = {
      { "<Leader>mp", "<cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "Markdown preview toggle" },
    },
  },
}
