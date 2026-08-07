-- エディタ支援: autopairs / Comment / surround / toggleterm / trouble
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
        event  = "InsertEnter",
        opts   = { check_ts = true },
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
        cmd          = { "Trouble" },
        keys         = {
            { "<Leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "All diagnostics" },
            { "<Leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
            { "<Leader>xl", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location list" },
            { "<Leader>xq", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix list" },
        },
        opts         = {},
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
        init   = function()
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

    -- フォーマッタ（prettier 等）
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        cmd = { "ConformInfo" },
        keys = {
            { "<Leader>cf", function() require("conform").format({ async = true }) end, desc = "Format" },
        },
        opts = {
            formatters_by_ft = {
                html            = { "prettier" },
                css             = { "prettier" },
                javascript      = { "prettier" },
                javascriptreact = { "prettier" },
                typescript      = { "prettier" },
                typescriptreact = { "prettier" },
                json            = { "prettier" },
                yaml            = { "prettier" },
                markdown        = { "prettier" },
            },
            format_on_save = {
                timeout_ms = 3000,
                lsp_format = "fallback",
            },
        },
    },

    -- Markdown プレビュー（Mermaid / HTML 対応）
    -- mkdp のコマンドは -buffer 定義 + BufEnter 登録のため、lazy-load 直後の
    -- カレントバッファではコマンドが未登録になる。lazy=false で起動時にロードする。
    --
    -- .mmd (raw mermaid) は mkdp が直接扱えないため、<Leader>md を押したら
    -- mermaid フェンスで包んだ一時 .md を作ってそちらをプレビューする。
    {
        "iamcco/markdown-preview.nvim",
        lazy = false,
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
        init = function()
            vim.g.mkdp_filetypes = { "markdown", "html" }
            vim.g.mkdp_command_for_global = 1
        end,
        config = function()
            local function preview_mermaid()
                local src = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                local tmp = vim.fn.tempname() .. ".md"
                local wrapped = { "```mermaid" }
                vim.list_extend(wrapped, src)
                table.insert(wrapped, "```")
                vim.fn.writefile(wrapped, tmp)
                vim.cmd("edit " .. vim.fn.fnameescape(tmp))
                vim.cmd("MarkdownPreview")
            end
            vim.api.nvim_create_user_command("MermaidPreview", preview_mermaid, {})

            vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
                pattern = "*.mmd",
                callback = function()
                    vim.bo.filetype = "mermaid"
                    vim.keymap.set("n", "<Leader>md", "<cmd>MermaidPreview<CR>",
                        { buffer = true, desc = "Mermaid preview" })
                end,
            })
        end,
        keys = {
            { "<Leader>md", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown/HTML preview toggle" },
        },
    },

    -- png画像を表示する（Ghostty は kitty graphics protocol 対応）
    {
        "3rd/image.nvim",
        build = false,
        opts = {
            backend = "kitty",
            integrations = {
                markdown = { enabled = true },
            },
            max_width = 100,
            max_height = 30,
        },
    },

    -- Mermaid (.mmd) / Markdown 内の mermaid ブロックをインラインプレビュー
    {
        "3rd/diagram.nvim",
        dependencies = { "3rd/image.nvim" },
        ft = { "markdown", "mermaid" },
        init = function()
            -- .mmd / .mermaid を mermaid filetype として認識
            vim.filetype.add({
                extension = {
                    mmd = "mermaid",
                    mermaid = "mermaid",
                },
            })
        end,
        opts = function()
            return {
                renderer_options = {
                    mermaid = {
                        background = "transparent",
                        theme      = "forest",
                        scale      = 2,
                    },
                },
                integrations = {
                    require("diagram.integrations.markdown"),
                    require("diagram.integrations.neorg"),
                },
            }
        end,
    },

    -- 高機能な折りたたみ（LSP / Treesitter ベース）
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        event = "BufReadPost",
        init = function()
            -- ufo は大きい foldlevel を要求する
            vim.o.foldcolumn     = "1"
            vim.o.foldlevel      = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable     = true
            vim.o.fillchars      = "eob: ,fold: ,foldopen:-,foldsep: ,foldclose:+"
        end,
        config = function()
            local ufo = require("ufo")
            ufo.setup({
                provider_selector = function(_, _, _)
                    return { "treesitter", "indent" }
                end,
            })
            local map = vim.keymap.set
            map("n", "zR", ufo.openAllFolds, { desc = "UFO: open all folds" })
            map("n", "zM", ufo.closeAllFolds, { desc = "UFO: close all folds" })
            map("n", "zr", ufo.openFoldsExceptKinds, { desc = "UFO: open folds except kinds" })
            map("n", "zm", ufo.closeFoldsWith, { desc = "UFO: close folds with level" })
            -- peek は K（lsp.lua）に統合: 折りたたみ行で K → peek、それ以外 → hover
        end,
    },

    -- クリップボードの画像をファイルに保存して貼り付け（<Leader>p）
    {
        "HakonHarnes/img-clip.nvim",
        event = "BufEnter",
        keys = {
            { "<Leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
        },
        opts = {
            default = {
                dir_path    = "assets",   -- 画像の保存先（ファイルと同ディレクトリ配下）
                use_absolute_path = false,
                relative_to_current_file = true,
            },
        },
    },
}
