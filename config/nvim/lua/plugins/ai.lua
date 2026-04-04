-- AI 補完・チャット: avante.nvim（AWS Bedrock / Claude）
-- AWS_PROFILE は環境に応じて変更すること
return {
  {
    "yetone/avante.nvim",
    event   = "VeryLazy",
    version = false,
    build   = "make",
    init = function()
      -- avante が on_choice=nil で vim.ui.select を呼ぶバグを回避
      local orig_select = vim.ui.select
      vim.ui.select = function(items, opts, on_choice)
        if type(on_choice) ~= "function" then return end
        orig_select(items, opts, on_choice)
      end

      -- AWS SigV4 対応 curl 8.10.0+ を優先するため PATH に追加
      local brew_curl = "/opt/homebrew/opt/curl/bin"
      if not vim.env.PATH:find(brew_curl, 1, true) then
        vim.env.PATH = brew_curl .. ":" .. vim.env.PATH
      end
      if not vim.env.AWS_PROFILE then
        vim.env.AWS_PROFILE = "bedrock-user@finatext-aircraft"
      end
      if not vim.env.AWS_DEFAULT_REGION then
        vim.env.AWS_DEFAULT_REGION = "ap-northeast-1"
      end
      -- Bedrock は API キー不要なのでログイン済みフラグを立てておく
      vim.g.avante_login = true
    end,
    opts = {
      provider = "bedrock",
      auto_suggestions_provider = "bedrock",
      providers = {
        bedrock = {
          model = "global.anthropic.claude-sonnet-4-6",
          extra_request_body = {
            max_tokens  = 4096,
            temperature = 0,
          },
        },
      },
      behaviour = {
        auto_suggestions                 = true,
        auto_set_highlight_group         = true,
        auto_set_keymaps                 = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard     = false,
      },
      mappings = {
        ask     = "<Leader>aa",
        edit    = "<Leader>ae",
        refresh = "<Leader>ar",
        diff = {
          ours   = "co",
          theirs = "ct",
          both   = "cb",
          next   = "]x",
          prev   = "[x",
        },
        submit = {
          normal = "<CR>",
          insert = "<C-s>",
        },
        toggle = {
          default    = "<Leader>at",
          debug      = "<Leader>aD",
          hint       = "<Leader>ah",
          suggestion = "<Leader>as",
        },
      },
      windows = {
        position = "right",
        width    = 38,
        wrap     = true,
      },
      highlights = {
        diff = {
          current  = "DiffText",
          incoming = "DiffAdd",
        },
      },
      input = { provider = "dressing" },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { file_types = { "markdown", "Avante" } },
        ft   = { "markdown", "Avante" },
      },
    },
  },
}
