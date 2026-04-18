-- Git / GitHub 関連
return {

    -- Git の変更をガターに表示
    {
        "lewis6991/gitsigns.nvim",
        event  = "BufReadPre",
        config = function(_, opts)
            require("gitsigns").setup(opts)
            -- word diff のハイライトを半透明に（blend: 0=不透明 〜 100=完全透明）
            local hl = vim.api.nvim_set_hl
            hl(0, "GitSignsAddWord", { link = "GitSignsAdd", default = false, blend = 50 })
            hl(0, "GitSignsChangeWord", { link = "GitSignsChange", default = false, blend = 50 })
            hl(0, "GitSignsDeleteWord", { link = "GitSignsDelete", default = false, blend = 50 })
        end,
        opts   = {
            signs                   = {
                add          = { text = "▎" },
                change       = { text = "▎" },
                delete       = { text = "" },
                topdelete    = { text = "" },
                changedelete = { text = "▎" },
                untracked    = { text = "┆" },
            },
            word_diff               = true,
            linehl                  = false,
            numhl                   = true,
            current_line_blame      = true,
            current_line_blame_opts = {
                delay         = 100,
                virt_text_pos = "eol",
            },
            on_attach               = function(bufnr)
                local gs   = package.loaded.gitsigns
                local map  = vim.keymap.set
                local opts = function(desc) return { buffer = bufnr, desc = desc } end

                map("n", "]h", gs.next_hunk, opts("次の hunk"))
                map("n", "[h", gs.prev_hunk, opts("前の hunk"))
                map("n", "<Leader>hs", gs.stage_hunk, opts("hunk をステージ"))
                map("n", "<Leader>hr", gs.reset_hunk, opts("hunk をリセット"))
                map("n", "<Leader>hS", gs.stage_buffer, opts("バッファをステージ"))
                map("n", "<Leader>hR", gs.reset_buffer, opts("バッファをリセット"))
                map("n", "<Leader>hp", gs.preview_hunk, opts("hunk をプレビュー"))
                map("n", "<Leader>hb", gs.blame_line, opts("行を blame"))
                map("n", "<Leader>hd", gs.diffthis, opts("差分を表示"))
                map("n", "<Leader>gP", function()
                    local line = vim.api.nvim_win_get_cursor(0)[1]
                    local file = vim.api.nvim_buf_get_name(0)
                    local blame = vim.fn.systemlist(
                        string.format("git blame -L %d,%d --porcelain -- %s", line, line, vim.fn.shellescape(file))
                    )
                    local summary = ""
                    for _, l in ipairs(blame) do
                        local s = l:match("^summary (.+)")
                        if s then summary = s break end
                    end
                    vim.notify("summary: " .. summary, vim.log.levels.INFO)
                    local pr_num = summary:match("#(%d+)")
                    if not pr_num then
                        vim.notify("PR番号が見つかりません: " .. summary, vim.log.levels.WARN)
                        return
                    end
                    vim.fn.jobstart({ "gh", "pr", "view", pr_num, "--web" }, { detach = true })
                end, opts("blame行のPRをブラウザで開く"))
            end,
        },
    },

    -- vim で diff を見やすくする
    -- 参照) https://github.com/sindrets/diffview.nvim
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
        config = function()
            local actions = require("diffview.actions")
            require("diffview").setup({
                diff_binaries      = false, -- バイナリファイルの差分を表示する
                enhanced_diff_hl   = false, -- |diffview-config-enhanced_diff_hl| を参照
                git_cmd            = { "git" }, -- git 実行ファイルとデフォルト引数
                hg_cmd             = { "hg" }, -- hg 実行ファイルとデフォルト引数
                use_icons          = true, -- nvim-web-devicons が必要
                show_help_hints    = true, -- ヘルプパネルを開くヒントを表示する
                watch_index        = true, -- git インデックスが変更されたときにビューとインデックスバッファを更新する
                icons              = { -- use_icons が true のときのみ適用
                    folder_closed = "",
                    folder_open = "",
                },
                signs              = {
                    fold_closed = "",
                    fold_open = "",
                    done = "✓",
                },
                view               = {
                    -- 各ビュータイプのレイアウトと動作を設定する
                    -- 利用可能なレイアウト:
                    --  'diff1_plain'
                    --    |'diff2_horizontal'
                    --    |'diff2_vertical'
                    --    |'diff3_horizontal'
                    --    |'diff3_vertical'
                    --    |'diff3_mixed'
                    --    |'diff4_mixed'
                    -- 詳細は |diffview-config-view.x.layout| を参照
                    default = {
                        -- diff ビューにおける変更ファイルとステージ済みファイルの設定
                        layout = "diff2_horizontal",
                        disable_diagnostics = false, -- ビュー表示中に diff バッファの診断を一時的に無効化する
                        winbar_info = false, -- |diffview-config-view.x.winbar_info| を参照
                    },
                    merge_tool = {
                        -- マージまたはリベース中の diff ビューにおけるコンフリクトファイルの設定
                        layout = "diff3_horizontal",
                        disable_diagnostics = true, -- ビュー表示中に diff バッファの診断を一時的に無効化する
                        winbar_info = true, -- |diffview-config-view.x.winbar_info| を参照
                    },
                    file_history = {
                        -- ファイル履歴ビューにおける変更ファイルの設定
                        layout = "diff2_horizontal",
                        disable_diagnostics = false, -- ビュー表示中に diff バッファの診断を一時的に無効化する
                        winbar_info = false, -- |diffview-config-view.x.winbar_info| を参照
                    },
                },
                file_panel         = {
                    listing_style = "tree",  -- 'list' または 'tree' のいずれか
                    tree_options = {         -- listing_style が 'tree' のときのみ適用
                        flatten_dirs = true, -- 単一ディレクトリのみを含むディレクトリをフラット化する
                        folder_statuses = "only_folded", -- 'never'、'only_folded'、'always' のいずれか
                    },
                    win_config = {           -- |diffview-config-win_config| を参照
                        position = "left",
                        width = 35,
                        win_opts = {},
                    },
                },
                file_history_panel = {
                    log_options = { -- |diffview-config-log_options| を参照
                        git = {
                            single_file = {
                                diff_merges = "combined",
                            },
                            multi_file = {
                                diff_merges = "first-parent",
                            },
                        },
                        hg = {
                            single_file = {},
                            multi_file = {},
                        },
                    },
                    win_config = { -- |diffview-config-win_config| を参照
                        position = "bottom",
                        height = 16,
                        win_opts = {},
                    },
                },
                commit_log_panel   = {
                    win_config = {}, -- |diffview-config-win_config| を参照
                },
                default_args       = { -- 列挙されたコマンドの引数リストの先頭に追加されるデフォルト引数
                    DiffviewOpen = {},
                    DiffviewFileHistory = {},
                },
                hooks              = {}, -- |diffview-config-hooks| を参照
                keymaps            = {
                    disable_defaults = false, -- デフォルトキーマップを無効化する
                    view = {
                        -- `view` バインディングは、現在のタブページが Diffview のときのみ diff バッファでアクティブになる
                        { "n", "<tab>", actions.select_next_entry, { desc = "次のファイルの差分を開く" } },
                        { "n", "<s-tab>", actions.select_prev_entry, { desc = "前のファイルの差分を開く" } },
                        { "n", "[F", actions.select_first_entry, { desc = "最初のファイルの差分を開く" } },
                        { "n", "]F", actions.select_last_entry, { desc = "最後のファイルの差分を開く" } },
                        { "n", "gf", actions.goto_file_edit, { desc = "前のタブページでファイルを開く" } },
                        { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "新しいスプリットでファイルを開く" } },
                        { "n", "<C-w>gf", actions.goto_file_tab, { desc = "新しいタブページでファイルを開く" } },
                        { "n", "<leader>e", actions.focus_files, { desc = "ファイルパネルにフォーカスを移動する" } },
                        { "n", "<leader>b", actions.toggle_files, { desc = "ファイルパネルを切り替える" } },
                        { "n", "g<C-x>", actions.cycle_layout, { desc = "利用可能なレイアウトを切り替える" } },
                        { "n", "[x", actions.prev_conflict, { desc = "マージツール: 前のコンフリクトにジャンプする" } },
                        { "n", "]x", actions.next_conflict, { desc = "マージツール: 次のコンフリクトにジャンプする" } },
                        { "n", "<leader>co", actions.conflict_choose("ours"), { desc = "コンフリクトの OURS バージョンを選択する" } },
                        { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "コンフリクトの THEIRS バージョンを選択する" } },
                        { "n", "<leader>cb", actions.conflict_choose("base"), { desc = "コンフリクトの BASE バージョンを選択する" } },
                        { "n", "<leader>ca", actions.conflict_choose("all"), { desc = "コンフリクトのすべてのバージョンを選択する" } },
                        { "n", "dx", actions.conflict_choose("none"), { desc = "コンフリクト領域を削除する" } },
                        { "n", "<leader>cO", actions.conflict_choose_all("ours"), { desc = "ファイル全体のコンフリクトに対して OURS バージョンを選択する" } },
                        { "n", "<leader>cT", actions.conflict_choose_all("theirs"), { desc = "ファイル全体のコンフリクトに対して THEIRS バージョンを選択する" } },
                        { "n", "<leader>cB", actions.conflict_choose_all("base"), { desc = "ファイル全体のコンフリクトに対して BASE バージョンを選択する" } },
                        { "n", "<leader>cA", actions.conflict_choose_all("all"), { desc = "ファイル全体のコンフリクトに対してすべてのバージョンを選択する" } },
                        { "n", "dX", actions.conflict_choose_all("none"), { desc = "ファイル全体のコンフリクト領域を削除する" } },
                    },
                    diff1 = {
                        -- 単一ウィンドウ diff レイアウトのマッピング
                        { "n", "g?", actions.help({ "view", "diff1" }), { desc = "ヘルプパネルを開く" } },
                    },
                    diff2 = {
                        -- 2ウェイ diff レイアウトのマッピング
                        { "n", "g?", actions.help({ "view", "diff2" }), { desc = "ヘルプパネルを開く" } },
                    },
                    diff3 = {
                        -- 3ウェイ diff レイアウトのマッピング
                        { { "n", "x" }, "2do", actions.diffget("ours"), { desc = "ファイルの OURS バージョンから diff hunk を取得する" } },
                        { { "n", "x" }, "3do", actions.diffget("theirs"), { desc = "ファイルの THEIRS バージョンから diff hunk を取得する" } },
                        { "n", "g?", actions.help({ "view", "diff3" }), { desc = "ヘルプパネルを開く" } },
                    },
                    diff4 = {
                        -- 4ウェイ diff レイアウトのマッピング
                        { { "n", "x" }, "1do", actions.diffget("base"), { desc = "ファイルの BASE バージョンから diff hunk を取得する" } },
                        { { "n", "x" }, "2do", actions.diffget("ours"), { desc = "ファイルの OURS バージョンから diff hunk を取得する" } },
                        { { "n", "x" }, "3do", actions.diffget("theirs"), { desc = "ファイルの THEIRS バージョンから diff hunk を取得する" } },
                        { "n", "g?", actions.help({ "view", "diff4" }), { desc = "ヘルプパネルを開く" } },
                    },
                    file_panel = {
                        { "n", "j", actions.next_entry, { desc = "カーソルを次のファイルエントリに移動する" } },
                        { "n", "<down>", actions.next_entry, { desc = "カーソルを次のファイルエントリに移動する" } },
                        { "n", "k", actions.prev_entry, { desc = "カーソルを前のファイルエントリに移動する" } },
                        { "n", "<up>", actions.prev_entry, { desc = "カーソルを前のファイルエントリに移動する" } },
                        { "n", "<cr>", actions.select_entry, { desc = "選択したエントリの差分を開く" } },
                        { "n", "o", actions.select_entry, { desc = "選択したエントリの差分を開く" } },
                        { "n", "l", actions.select_entry, { desc = "選択したエントリの差分を開く" } },
                        { "n", "<2-LeftMouse>", actions.select_entry, { desc = "選択したエントリの差分を開く" } },
                        { "n", "-", actions.toggle_stage_entry, { desc = "選択したエントリをステージ / アンステージする" } },
                        { "n", "s", actions.toggle_stage_entry, { desc = "選択したエントリをステージ / アンステージする" } },
                        { "n", "S", actions.stage_all, { desc = "すべてのエントリをステージする" } },
                        { "n", "U", actions.unstage_all, { desc = "すべてのエントリをアンステージする" } },
                        { "n", "X", actions.restore_entry, { desc = "エントリを左側の状態に復元する" } },
                        { "n", "L", actions.open_commit_log, { desc = "コミットログパネルを開く" } },
                        { "n", "zo", actions.open_fold, { desc = "折りたたみを展開する" } },
                        { "n", "h", actions.close_fold, { desc = "折りたたみを閉じる" } },
                        { "n", "zc", actions.close_fold, { desc = "折りたたみを閉じる" } },
                        { "n", "za", actions.toggle_fold, { desc = "折りたたみを切り替える" } },
                        { "n", "zR", actions.open_all_folds, { desc = "すべての折りたたみを展開する" } },
                        { "n", "zM", actions.close_all_folds, { desc = "すべての折りたたみを閉じる" } },
                        { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "ビューを上にスクロールする" } },
                        { "n", "<c-f>", actions.scroll_view(0.25), { desc = "ビューを下にスクロールする" } },
                        { "n", "<tab>", actions.select_next_entry, { desc = "次のファイルの差分を開く" } },
                        { "n", "<s-tab>", actions.select_prev_entry, { desc = "前のファイルの差分を開く" } },
                        { "n", "[F", actions.select_first_entry, { desc = "最初のファイルの差分を開く" } },
                        { "n", "]F", actions.select_last_entry, { desc = "最後のファイルの差分を開く" } },
                        { "n", "gf", actions.goto_file_edit, { desc = "前のタブページでファイルを開く" } },
                        { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "新しいスプリットでファイルを開く" } },
                        { "n", "<C-w>gf", actions.goto_file_tab, { desc = "新しいタブページでファイルを開く" } },
                        { "n", "i", actions.listing_style, { desc = "'list' と 'tree' ビューを切り替える" } },
                        { "n", "f", actions.toggle_flatten_dirs, { desc = "ツリー表示でサブディレクトリをフラット化する" } },
                        { "n", "R", actions.refresh_files, { desc = "ファイルリストの統計とエントリを更新する" } },
                        { "n", "<leader>e", actions.focus_files, { desc = "ファイルパネルにフォーカスを移動する" } },
                        { "n", "<leader>b", actions.toggle_files, { desc = "ファイルパネルを切り替える" } },
                        { "n", "g<C-x>", actions.cycle_layout, { desc = "利用可能なレイアウトを切り替える" } },
                        { "n", "[x", actions.prev_conflict, { desc = "前のコンフリクトに移動する" } },
                        { "n", "]x", actions.next_conflict, { desc = "次のコンフリクトに移動する" } },
                        { "n", "g?", actions.help("file_panel"), { desc = "ヘルプパネルを開く" } },
                        { "n", "<leader>cO", actions.conflict_choose_all("ours"), { desc = "ファイル全体のコンフリクトに対して OURS バージョンを選択する" } },
                        { "n", "<leader>cT", actions.conflict_choose_all("theirs"), { desc = "ファイル全体のコンフリクトに対して THEIRS バージョンを選択する" } },
                        { "n", "<leader>cB", actions.conflict_choose_all("base"), { desc = "ファイル全体のコンフリクトに対して BASE バージョンを選択する" } },
                        { "n", "<leader>cA", actions.conflict_choose_all("all"), { desc = "ファイル全体のコンフリクトに対してすべてのバージョンを選択する" } },
                        { "n", "dX", actions.conflict_choose_all("none"), { desc = "ファイル全体のコンフリクト領域を削除する" } },
                    },
                    file_history_panel = {
                        { "n", "g!", actions.options, { desc = "オプションパネルを開く" } },
                        { "n", "<C-A-d>", actions.open_in_diffview, { desc = "カーソル下のエントリを diffview で開く" } },
                        { "n", "y", actions.copy_hash, { desc = "カーソル下のエントリのコミットハッシュをコピーする" } },
                        { "n", "L", actions.open_commit_log, { desc = "コミットの詳細を表示する" } },
                        { "n", "X", actions.restore_entry, { desc = "選択したエントリの状態にファイルを復元する" } },
                        { "n", "zo", actions.open_fold, { desc = "折りたたみを展開する" } },
                        { "n", "zc", actions.close_fold, { desc = "折りたたみを閉じる" } },
                        { "n", "h", actions.close_fold, { desc = "折りたたみを閉じる" } },
                        { "n", "za", actions.toggle_fold, { desc = "折りたたみを切り替える" } },
                        { "n", "zR", actions.open_all_folds, { desc = "すべての折りたたみを展開する" } },
                        { "n", "zM", actions.close_all_folds, { desc = "すべての折りたたみを閉じる" } },
                        { "n", "j", actions.next_entry, { desc = "カーソルを次のファイルエントリに移動する" } },
                        { "n", "<down>", actions.next_entry, { desc = "カーソルを次のファイルエントリに移動する" } },
                        { "n", "k", actions.prev_entry, { desc = "カーソルを前のファイルエントリに移動する" } },
                        { "n", "<up>", actions.prev_entry, { desc = "カーソルを前のファイルエントリに移動する" } },
                        { "n", "<cr>", actions.select_entry, { desc = "選択したエントリの差分を開く" } },
                        { "n", "o", actions.select_entry, { desc = "選択したエントリの差分を開く" } },
                        { "n", "l", actions.select_entry, { desc = "選択したエントリの差分を開く" } },
                        { "n", "<2-LeftMouse>", actions.select_entry, { desc = "選択したエントリの差分を開く" } },
                        { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "ビューを上にスクロールする" } },
                        { "n", "<c-f>", actions.scroll_view(0.25), { desc = "ビューを下にスクロールする" } },
                        { "n", "<tab>", actions.select_next_entry, { desc = "次のファイルの差分を開く" } },
                        { "n", "<s-tab>", actions.select_prev_entry, { desc = "前のファイルの差分を開く" } },
                        { "n", "[F", actions.select_first_entry, { desc = "最初のファイルの差分を開く" } },
                        { "n", "]F", actions.select_last_entry, { desc = "最後のファイルの差分を開く" } },
                        { "n", "gf", actions.goto_file_edit, { desc = "前のタブページでファイルを開く" } },
                        { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "新しいスプリットでファイルを開く" } },
                        { "n", "<C-w>gf", actions.goto_file_tab, { desc = "新しいタブページでファイルを開く" } },
                        { "n", "<leader>e", actions.focus_files, { desc = "ファイルパネルにフォーカスを移動する" } },
                        { "n", "<leader>b", actions.toggle_files, { desc = "ファイルパネルを切り替える" } },
                        { "n", "g<C-x>", actions.cycle_layout, { desc = "利用可能なレイアウトを切り替える" } },
                        { "n", "g?", actions.help("file_history_panel"), { desc = "ヘルプパネルを開く" } },
                    },
                    option_panel = {
                        { "n", "<tab>", actions.select_entry, { desc = "現在のオプションを変更する" } },
                        { "n", "q", actions.close, { desc = "パネルを閉じる" } },
                        { "n", "g?", actions.help("option_panel"), { desc = "ヘルプパネルを開く" } },
                    },
                    help_panel = {
                        { "n", "q", actions.close, { desc = "ヘルプメニューを閉じる" } },
                        { "n", "<esc>", actions.close, { desc = "ヘルプメニューを閉じる" } },
                    },
                },
            })
        end,
    },

    {
        "linrongbin16/gitlinker.nvim",
        cmd = "GitLink",
        keys = {
            { "<Leader>gl", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Git permalink をコピー" },
            { "<Leader>gL", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Git permalink をブラウザで開く" },
        },
        opts = {},
    }

}
