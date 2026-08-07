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
        "vtsls",       -- TypeScript / JavaScript (VSCode 互換)
        "eslint",      -- ESLint (JS/TS linter)
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

          local function goto_definition()
            local cli = vim.lsp.get_clients({ bufnr = bufnr })[1]
            local enc = cli and cli.offset_encoding or "utf-16"
            local params = vim.lsp.util.make_position_params(0, enc)
            vim.lsp.buf_request(bufnr, "textDocument/definition", params, function(_, result)
              if not result or vim.tbl_isempty(result) then
                vim.notify("No definition found", vim.log.levels.INFO)
                return
              end
              local target = vim.islist(result) and result[1] or result
              vim.lsp.util.show_document(target, enc, { focus = true })
            end)
          end
          map("n", "gd",    goto_definition, opts("Go to definition"))
          map("n", "<F12>", goto_definition, opts("Go to definition (F12)"))
          map("n", "gD",         vim.lsp.buf.declaration,     opts("Go to declaration"))
          map("n", "gi",         vim.lsp.buf.implementation,  opts("Go to implementation"))
          map("n", "gt",         vim.lsp.buf.type_definition, opts("Go to type definition"))
          map("n", "gr",         vim.lsp.buf.references,      opts("References"))
          map("n", "<S-F12>", function()
            require("telescope.builtin").lsp_references()
          end, opts("Find references (Shift+F12)"))
          map("n", "K", function()
            local ok, ufo = pcall(require, "ufo")
            if ok then
              local winid = ufo.peekFoldedLinesUnderCursor()
              if winid then return end
            end
            vim.lsp.buf.hover({
              border     = "rounded",
              max_width  = 100,
              max_height = 30,
              focusable  = true,
            })
          end, opts("Peek fold / Hover docs"))
          map("i", "<C-k>",      vim.lsp.buf.signature_help,  opts("Signature help"))

          -- カーソル下のシンボル + LSP hover を Avante に投げて解説してもらう
          map({ "n", "v" }, "<Leader>ak", function()
            local mode   = vim.fn.mode()
            local symbol
            if mode == "v" or mode == "V" or mode == "\22" then
              vim.cmd('noautocmd normal! "vy')
              symbol = vim.fn.getreg("v")
            else
              symbol = vim.fn.expand("<cword>")
            end
            local ft     = vim.bo.filetype
            local client = vim.lsp.get_clients({ bufnr = bufnr })[1]
            local enc    = client and client.offset_encoding or "utf-16"
            local params = vim.lsp.util.make_position_params(0, enc)

            vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(_, result)
              local hover_md = ""
              if result and result.contents then
                local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
                hover_md = table.concat(lines, "\n")
              end
              local prompt = table.concat({
                "以下の " .. ft .. " のシンボル `" .. symbol .. "` について、",
                "型・役割・主要な属性/メソッド・使い方の例を日本語で説明してください。",
                "",
                "### LSP hover 情報",
                "```markdown",
                hover_md ~= "" and hover_md or "(hover 情報なし)",
                "```",
              }, "\n")

              local ok, avante_api = pcall(require, "avante.api")
              if ok and avante_api.ask then
                avante_api.ask({ question = prompt })
              else
                vim.cmd("AvanteAsk")
                vim.defer_fn(function() vim.api.nvim_paste(prompt, false, -1) end, 100)
              end
            end)
          end, opts("Ask LLM about symbol (with hover)"))
          map("n", "<F2>",       vim.lsp.buf.rename,          opts("Rename symbol (F2)"))
          map("n", "<Leader>rn", vim.lsp.buf.rename,          opts("Rename symbol"))
          map("n", "<M-.>",      vim.lsp.buf.code_action,     opts("Code action (Cmd+.)"))
          map("v", "<M-.>",      vim.lsp.buf.code_action,     opts("Code action (Cmd+.)"))
          map("n", "<Leader>ca", vim.lsp.buf.code_action,     opts("Code action"))
          map("n", "<Leader>lf", function()
            vim.lsp.buf.format({ async = true })
          end, opts("Format"))
          map("n", "<Leader>uh", function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
          end, opts("Toggle inlay hints"))

          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end

          map("n", "<Leader>d", vim.diagnostic.open_float, opts("Show diagnostic"))
          map("n", "[d",        vim.diagnostic.goto_prev,  opts("Prev diagnostic"))
          map("n", "]d",        vim.diagnostic.goto_next,  opts("Next diagnostic"))
          map("n", "<Leader>li", "<cmd>checkhealth vim.lsp<CR>", opts("LSP info (checkhealth)"))
          map("n", "<Leader>lR", "<cmd>LspRestart<CR>",          opts("LSP restart"))
          map("n", "<Leader>lc", function()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients == 0 then
              vim.notify("No LSP clients attached", vim.log.levels.WARN)
              return
            end
            for _, c in ipairs(clients) do
              vim.notify(string.format("%s (id=%d) root=%s", c.name, c.id, c.config.root_dir or "?"))
            end
          end, opts("LSP clients (current buffer)"))
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

      vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
        config = vim.tbl_deep_extend("force", config or {}, { border = "rounded" })
        vim.lsp.handlers.hover(err, result, ctx, config)
      end

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

      local ts_inlay_hints = {
        includeInlayParameterNameHints                        = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints                = true,
        includeInlayVariableTypeHints                         = true,
        includeInlayPropertyDeclarationTypeHints              = true,
        includeInlayFunctionLikeReturnTypeHints               = true,
        includeInlayEnumMemberValueHints                      = true,
      }

      vim.lsp.config("vtsls", {
        settings = {
          typescript = {
            inlayHints    = ts_inlay_hints,
            tsserver      = { maxTsServerMemory = 8192 },
            preferences   = { includePackageJsonAutoImports = "on" },
          },
          javascript = { inlayHints = ts_inlay_hints },
          vtsls = {
            experimental = {
              completion = { enableServerSideFuzzyMatch = true },
            },
          },
        },
        on_attach = function(client, bufnr)
          local ok, tq = pcall(require, "twoslash-queries")
          if ok then tq.attach(client, bufnr) end

          vim.keymap.set("n", "gS", function()
            local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
            client:exec_cmd({
              command   = "typescript.goToSourceDefinition",
              arguments = { params.textDocument.uri, params.position },
            }, { bufnr = bufnr })
          end, { buffer = bufnr, desc = "TS: Go to source definition" })
        end,
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = { schemaStore = { enable = true } },
        },
      })

      vim.lsp.enable({
        "pyright", "ruff", "lua_ls", "vtsls", "eslint", "bashls", "jsonls", "yamlls", "terraformls", "emmet_ls", "clangd",
      })

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.mjs", "*.cjs" },
        callback = function(ev)
          local clients = vim.lsp.get_clients({ bufnr = ev.buf, name = "eslint" })
          if #clients > 0 then
            vim.cmd("LspEslintFixAll")
          end
        end,
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
          documentation = cmp.config.window.bordered({ max_width = 100, max_height = 30 }),
        },
        view = {
          docs = { auto_open = true },
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

  -- シンボルアウトライン（VSCode の左ペイン「アウトライン」相当）
  {
    "hedyhli/outline.nvim",
    cmd  = { "Outline", "OutlineOpen" },
    keys = { { "<leader>o", "<cmd>Outline<cr>", desc = "Toggle outline" } },
    opts = {
      outline_window = { width = 25, relative_width = true },
    },
  },

  -- 入力中に関数シグネチャを常時表示
  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    opts  = {
      hint_enable     = false,
      floating_window = true,
      handler_opts    = { border = "rounded" },
    },
  },

  -- 定義/参照を浮動ウィンドウでプレビュー
  {
    "dnlhc/glance.nvim",
    cmd  = "Glance",
    keys = {
      { "gpd", "<cmd>Glance definitions<cr>",      desc = "Peek definitions" },
      { "gpr", "<cmd>Glance references<cr>",       desc = "Peek references" },
      { "gpt", "<cmd>Glance type_definitions<cr>", desc = "Peek type definitions" },
      { "gpi", "<cmd>Glance implementations<cr>",  desc = "Peek implementations" },
    },
    opts = { border = { enable = true } },
  },

  -- TypeScript のエラーメッセージを読みやすく翻訳
  {
    "dmmulroy/ts-error-translator.nvim",
    ft   = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = {},
  },

  -- TS の型を `// ^?` でフル展開表示
  {
    "marilari88/twoslash-queries.nvim",
    ft = { "typescript", "typescriptreact" },
  },

}
