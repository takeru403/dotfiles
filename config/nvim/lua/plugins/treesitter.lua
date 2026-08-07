-- Treesitter: 構文ハイライト・テキストオブジェクト
-- nvim-treesitter `main` ブランチ仕様（master は archived / 0.12 非互換）
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build  = ":TSUpdate",
    lazy   = false, -- FileType より前に読み込む必要があるため
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    },
    config = function()
      local ensure = {
        "c", "cpp",
        "python", "lua", "luadoc", "vim", "vimdoc", "query",
        "javascript", "typescript", "tsx",
        "json", "yaml", "toml",
        "html", "css", "bash",
        "markdown", "markdown_inline",
        "sql", "dockerfile", "regex",
      }

      local nts = require("nvim-treesitter")
      nts.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      -- 未インストールのパーサーのみ install（main は ensure_installed 廃止）
      local ok_cfg, cfg = pcall(require, "nvim-treesitter.config")
      local installed = (ok_cfg and cfg.installed_parsers and cfg.installed_parsers()) or {}
      local set = {}
      for _, p in ipairs(installed) do set[p] = true end
      local need = {}
      for _, p in ipairs(ensure) do
        if not set[p] then table.insert(need, p) end
      end
      if #need > 0 then
        nts.install(need)
      end

      -- textobjects（main API）
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move   = { set_jumps = true },
      })

      -- ハイライト & インデント有効化
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
          local ok = pcall(vim.treesitter.start, ev.buf, lang)
          if ok then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- textobjects keymaps
      local sel = function(q)
        return function()
          require("nvim-treesitter-textobjects.select").select_textobject(q, "textobjects")
        end
      end
      local goto_next = function(q)
        return function()
          require("nvim-treesitter-textobjects.move").goto_next_start(q, "textobjects")
        end
      end
      local goto_prev = function(q)
        return function()
          require("nvim-treesitter-textobjects.move").goto_previous_start(q, "textobjects")
        end
      end

      local map = vim.keymap.set
      for _, m in ipairs({ "x", "o" }) do
        map(m, "af", sel("@function.outer"),  { desc = "Around function" })
        map(m, "if", sel("@function.inner"),  { desc = "Inner function" })
        map(m, "ac", sel("@class.outer"),     { desc = "Around class" })
        map(m, "ic", sel("@class.inner"),     { desc = "Inner class" })
        map(m, "aa", sel("@parameter.outer"), { desc = "Around parameter" })
        map(m, "ia", sel("@parameter.inner"), { desc = "Inner parameter" })
      end
      map("n", "]f", goto_next("@function.outer"), { desc = "Next function start" })
      map("n", "]c", goto_next("@class.outer"),    { desc = "Next class start" })
      map("n", "[f", goto_prev("@function.outer"), { desc = "Prev function start" })
      map("n", "[c", goto_prev("@class.outer"),    { desc = "Prev class start" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      max_lines = 3,
      multiline_threshold = 1,
      trim_scope = "outer",
      mode = "cursor",
      separator = nil,
    },
    keys = {
      { "<leader>uC", function() require("treesitter-context").toggle() end, desc = "Toggle Treesitter Context" },
      { "[x",         function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "Jump to context" },
    },
  },
}
