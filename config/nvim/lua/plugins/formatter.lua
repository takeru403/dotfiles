-- Formatter: conform.nvim
-- prettier / prettierd 等を噛ませる。プロジェクト設定（.prettierrc 等）は自動で尊重される。
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd   = { "ConformInfo" },
    keys  = {
      {
        "<Leader>lf",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        mode = { "n", "v" },
        desc = "Format (conform)",
      },
    },
    opts = {
      -- biome を prettierd/prettier より先に置くことで、
      -- プロジェクトに biome.json があれば biome、無ければ prettier にフォールバックする。
      formatters_by_ft = {
        javascript      = { "biome", "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
        typescript      = { "biome", "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
        json            = { "biome", "prettierd", "prettier", stop_after_first = true },
        jsonc           = { "biome", "prettierd", "prettier", stop_after_first = true },
        yaml            = { "prettierd", "prettier", stop_after_first = true },
        html            = { "prettierd", "prettier", stop_after_first = true },
        css             = { "prettierd", "prettier", stop_after_first = true },
        scss            = { "prettierd", "prettier", stop_after_first = true },
        markdown        = { "prettierd", "prettier", stop_after_first = true },
        lua             = { "stylua" },
        terraform       = { "terraform_fmt" },
        tf              = { "terraform_fmt" },
        hcl             = { "terraform_fmt" },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1500, lsp_fallback = true }
      end,
    },
    init = function()
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { desc = "Disable autoformat-on-save", bang = true })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = "Re-enable autoformat-on-save" })
    end,
  },

  -- Mason 経由で prettierd / stylua を入れる
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "prettierd",
        "prettier",
        "stylua",
        "biome",
      },
      run_on_start = true,
    },
  },
}
