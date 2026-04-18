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
                html       = { "prettier" },
                css        = { "prettier" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                json       = { "prettier" },
                yaml       = { "prettier" },
                markdown   = { "prettier" },
            },
            format_on_save = {
                timeout_ms = 3000,
                lsp_format = "fallback",
            },
        },
    },

    -- Markdown プレビュー（Mermaid / HTML 対応）
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown", "html" },
        build = function()
            require("lazy").load({ plugins = { "markdown-preview.nvim" } })
            vim.fn["mkdp#util#install"]()
        end,
        init = function()
            vim.g.mkdp_filetypes = { "markdown", "html" }
            vim.g.mkdp_command_for_global = 1
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
