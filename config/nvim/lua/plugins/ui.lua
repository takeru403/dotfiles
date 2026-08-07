-- UI 系プラグイン: ステータスバー / バッファタブ / インデントガイド / which-key 等
return {

  -- ステータスバー
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme                = "tokyonight",
        component_separators = "|",
        section_separators   = { left = "", right = "" },
        globalstatus         = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- バッファタブ（VSCode のタブバー）
  {
    "akinsho/bufferline.nvim",
    version      = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    after        = "tokyonight.nvim",
    opts = {
      options = {
        numbers             = "none",
        close_command       = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        diagnostics         = "nvim_lsp",
        diagnostics_indicator = function(_, _, diagnostics_dict)
          local s = " "
          for e, n in pairs(diagnostics_dict) do
            local sym = e == "error" and " " or (e == "warning" and " " or "")
            s = s .. n .. sym
          end
          return s
        end,
        show_buffer_close_icons = true,
        show_close_icon         = true,
        separator_style         = "thin",
        always_show_bufferline  = false,
      },
    },
  },

  -- インデントレインボー
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPre",
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main         = "ibl",
    event        = "BufReadPre",
    dependencies = { "HiPhish/rainbow-delimiters.nvim" },
    config = function()
      local highlight = {
        "RainbowRed", "RainbowYellow", "RainbowBlue",
        "RainbowOrange", "RainbowGreen", "RainbowViolet", "RainbowCyan",
      }

      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed",    { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlue",   { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowGreen",  { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan",   { fg = "#56B6C2" })
      end)

      require("ibl").setup({
        indent = { char = "│", highlight = highlight },
        scope  = { enabled = true },
      })

      hooks.register(
        hooks.type.SCOPE_HIGHLIGHT,
        hooks.builtin.scope_highlight_from_extmark
      )
    end,
  },

  -- キーバインドヒント（<Leader> 押下でポップアップ）
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = { delay = 500 },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<Leader>f", group = "Find (Telescope)" },
        { "<Leader>h", group = "Git hunk" },
        { "<Leader>s", group = "Split window" },
        { "<Leader>x", group = "Trouble / diagnostics" },
        { "<Leader>b", group = "Buffer" },
        { "<Leader>a", group = "AI (avante)" },
      })
    end,
  },

  -- 通知をポップアップで表示
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts  = {
      timeout = 3000,
      render  = "compact",
      stages  = "fade",
      on_open = function(win)
        vim.api.nvim_win_set_option(win, "winblend", 20)
      end,
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  -- スクロールバー
  {
    "petertriho/nvim-scrollbar",
    event = "BufReadPost",
    opts  = {
      handlers = { search = true, gitsigns = true },
    },
  },

  -- LSP 読み込み中インジケーター
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts  = {
      notification = { window = { winblend = 0 } },
    },
  },

  -- vim.ui.select / vim.ui.input をモダン UI に
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts  = {
      select = {
        -- avante.nvim が list-like でないテーブルを渡すため select は無効化
        enabled = false,
      },
    },
  },

  -- TODO / FIXME / NOTE コメントをハイライト
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPost",
    opts  = {},
    keys  = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
      { "<Leader>ft", "<cmd>TodoTelescope<cr>",                            desc = "Find TODOs" },
    },
  },

  -- コマンドライン・メッセージをフローティング UI に
  {
    "folke/noice.nvim",
    event        = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"]                = true,
          ["cmp.entry.get_documentation"]                  = true,
        },
        hover     = { enabled = true },
        signature = { enabled = true },
      },
      presets = {
        bottom_search         = true,
        command_palette       = true,
        long_message_to_split = true,
        lsp_doc_border        = true,
      },
      -- ポップアップの透過（0=不透明 〜 100=完全透明）
      views = {
        notify          = { win_options = { winblend = 70 } },
        popup           = { win_options = { winblend = 70 } },
        hover           = { win_options = { winblend = 0 } },
        confirm         = { win_options = { winblend = 70 } },
      },
    },
  },
}
