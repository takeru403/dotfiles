-- LSP + 補完: Neovim 0.11 ネイティブ API 対応
return {

  -- Mason: LSP サーバー自動インストール管理
  {
    "williamboman/mason.nvim",
    cmd   = "Mason",
    build = ":MasonUpdate",
    opts  = { ui = { border = "rounded" } },
  },

  -- mason-lspconfig: ensure_installed で自動インストール
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "pyright",     -- Python (型チェック)
        "ruff",        -- Python (linter / formatter)
        "lua_ls",      -- Lua
        "ts_ls",       -- TypeScript / JavaScript
        "bashls",      -- Bash
        "jsonls",      -- JSON
        "yamlls",      -- YAML
        "terraformls", -- Terraform
        "clangd",      -- C / C++
        "emmet_ls",    -- HTML/CSS Emmet 展開
      },
      automatic_installation = true,
    },
  },

  -- nvim-lspconfig + vim.lsp.config / vim.lsp.enable（Neovim 0.11 新 API）
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config("*", { capabilities = capabilities })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local map   = vim.keymap.set
          local opts  = function(desc) return { buffer = bufnr, desc = desc } end

          map("n", "gd",         vim.lsp.buf.definition,      opts("Go to definition"))
          map("n", "<F12>",      vim.lsp.buf.definition,      opts("Go to definition (F12)"))
          map("n", "gD",         vim.lsp.buf.declaration,     opts("Go to declaration"))
          map("n", "gi",         vim.lsp.buf.implementation,  opts("Go to implementation"))
          map("n", "gt",         vim.lsp.buf.type_definition, opts("Go to type definition"))
          map("n", "gr",         vim.lsp.buf.references,      opts("References"))
          map("n", "<S-F12>", function()
            require("telescope.builtin").lsp_references()
          end, opts("Find references (Shift+F12)"))
          map("n", "K",          vim.lsp.buf.hover,           opts("Hover docs"))
          map("i", "<C-k>",      vim.lsp.buf.signature_help,  opts("Signature help"))
          map("n", "<F2>",       vim.lsp.buf.rename,          opts("Rename symbol (F2)"))
          map("n", "<Leader>rn", vim.lsp.buf.rename,          opts("Rename symbol"))
          map("n", "<M-.>",      vim.lsp.buf.code_action,     opts("Code action (Cmd+.)"))
          map("v", "<M-.>",      vim.lsp.buf.code_action,     opts("Code action (Cmd+.)"))
          map("n", "<Leader>ca", vim.lsp.buf.code_action,     opts("Code action"))
          map("n", "<Leader>lf", function()
            vim.lsp.buf.format({ async = true })
          end, opts("Format"))
          map("n", "<Leader>d", vim.diagnostic.open_float, opts("Show diagnostic"))
          map("n", "[d",        vim.diagnostic.goto_prev,  opts("Prev diagnostic"))
          map("n", "]d",        vim.diagnostic.goto_next,  opts("Next diagnostic"))
        end,
      })

      vim.diagnostic.config({
        virtual_text     = { prefix = "●" },
        signs            = true,
        underline        = true,
        update_in_insert = false,
        float            = { border = "rounded", source = "always", winblend = 20 },
        severity_sort    = true,
      })

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, { border = "rounded" }
      )

      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              typeCheckingMode      = "basic",
              autoImportCompletions = true,
            },
          },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime     = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace   = { checkThirdParty = false },
            telemetry   = { enable = false },
          },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = { schemaStore = { enable = true } },
        },
      })

      vim.lsp.enable({
        "pyright", "ruff", "lua_ls", "ts_ls", "bashls", "jsonls", "yamlls", "terraformls", "emmet_ls", "clangd",
      })
    end,
  },

  -- 補完エンジン
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"]     = cmp.mapping.select_prev_item(),
          ["<C-j>"]     = cmp.mapping.select_next_item(),
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          { name = "buffer",   priority = 500 },
          { name = "path",     priority = 250 },
        }),
        formatting = {
          format = require("lspkind").cmp_format({
            mode          = "symbol_text",
            maxwidth      = 50,
            ellipsis_char = "...",
            before = function(entry, item)
              local source_names = {
                nvim_lsp = "[LSP]",
                luasnip  = "[Snip]",
                buffer   = "[Buf]",
                path     = "[Path]",
              }
              item.menu = source_names[entry.source.name] or ""
              return item
            end,
          }),
        },
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
    end,
  },
}
