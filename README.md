# dotfiles

Takeru Tsuchiya の開発環境設定ファイル。新しいマシンへの環境同期に使用する。

## 管理対象ツール

| ファイル/ディレクトリ | 対象ツール |
|---|---|
| `.zshrc` / `.zprofile` / `.zshenv` | zsh |
| `.bashrc` | bash |
| `aliases.sh` | 共通エイリアス集（zsh から source） |
| `.tmux.conf` | tmux |
| `.vimrc` | vim |
| `.gitconfig` | git |
| `aqua.yaml` | aqua（CLI バージョン管理） |
| `config/ghostty/config` | Ghostty ターミナル |
| `config/nvim/` | Neovim（lazy.nvim + LSP） |

## セットアップ手順

### 1. 前提ツールのインストール

```bash
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 主要ツール
brew install git neovim tmux fzf ghq zsh

# zsh プラグイン
brew install zsh-syntax-highlighting zsh-autosuggestions

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k テーマ
brew install powerlevel10k

# Python 環境管理
brew install pyenv pyenv-virtualenv

# Node.js 環境管理（Volta）
curl https://get.volta.sh | bash

# aqua（CLI バージョン管理）
brew install aquaproj/aqua/aqua

# Ghostty ターミナル
brew install --cask ghostty

# Nerd Font（Ghostty / Neovim のアイコン表示に必要）
brew install --cask font-hack-nerd-font
```

### 2. このリポジトリを clone

```bash
# ghq を使う場合
ghq get https://github.com/takeru403/dotfiles

# または直接 clone
git clone https://github.com/takeru403/dotfiles.git ~/ghq/github.com/takeru403/dotfiles
```

### 3. シンボリックリンクを作成

```bash
cd ~/ghq/github.com/takeru403/dotfiles
bash install.sh
```

### 4. Neovim プラグインのインストール

```bash
nvim
# lazy.nvim が自動でプラグインをインストールする
# :Lazy sync で手動同期も可能
```

### 5. Git の個人情報を設定（必要に応じて）

`.gitconfig` に名前とメールアドレスが設定されているが、別の環境で使う場合は `~/.gitconfig.local` でオーバーライドできる。

```bash
cat >> ~/.gitconfig << 'EOF'
[include]
    path = ~/.gitconfig.local
EOF

cat > ~/.gitconfig.local << 'EOF'
[user]
    name = Your Name
    email = your@email.com
EOF
```

## ディレクトリ構成

```
dotfiles/
├── README.md
├── install.sh               # シンボリックリンク作成スクリプト
├── .gitignore
├── .zshrc                   # zsh メイン設定
├── .zprofile                # Homebrew / SnowSQL のパス設定
├── .zshenv                  # Rust (cargo) 環境変数
├── .bashrc                  # bash 設定（基本設定のみ）
├── aliases.sh               # 共通エイリアス・関数集
├── .tmux.conf               # tmux 設定（prefix: Ctrl-g）
├── .vimrc                   # vim 設定（nvim も参照）
├── .gitconfig               # git グローバル設定
├── aqua.yaml                # aqua CLI パッケージ定義
└── config/
    ├── ghostty/
    │   └── config           # Ghostty ターミナル設定（Neovim 向けキーバインド）
    └── nvim/
        ├── init.lua         # Neovim メイン設定 + lazy.nvim ブートストラップ
        └── lua/
            └── plugins/
                ├── ai.lua           # avante.nvim（AWS Bedrock / Claude）
                ├── colorscheme.lua  # tokyonight カラースキーム
                ├── editor.lua       # autopairs, Comment, gitsigns, toggleterm 等
                ├── lsp.lua          # LSP + nvim-cmp 補完
                ├── nvim-tree.lua    # ファイルエクスプローラー
                ├── oil.lua          # バッファ編集式ファイルマネージャー
                ├── telescope.lua    # ファジーファインダー
                ├── treesitter.lua   # 構文ハイライト
                └── ui.lua           # lualine, bufferline, which-key 等 UI プラグイン
```

## キーバインド早見表

### Neovim（`<Leader>` = Space）

| キー | 動作 |
|---|---|
| `<Leader>ff` | ファイル検索（Telescope） |
| `<Leader>fg` | テキスト検索（Live Grep） |
| `<Leader>fb` | バッファ一覧 |
| `<Leader>aa` | AI チャット（avante） |
| `<Leader>ae` | AI 編集（avante） |
| `Cmd+S` | 保存 |
| `Cmd+P` | ファイル検索 |
| `Cmd+B` | ファイルエクスプローラー |
| `Cmd+/` | コメントトグル |
| `Ctrl+hjkl` | ウィンドウ / tmux ペイン移動 |
| `gd` / `F12` | 定義ジャンプ |
| `K` | ホバードキュメント |
| `<F2>` | シンボルリネーム |

### tmux（prefix: `Ctrl-g`）

| キー | 動作 |
|---|---|
| `Ctrl-g \|` | ペイン縦分割 |
| `Ctrl-g -` | ペイン横分割 |
| `Ctrl-hjkl` | ペイン移動（vim と共通） |
| `Ctrl-g r` | 設定リロード |
| `Ctrl-g c` | 新ウィンドウ + claude 起動 |

## 注意事項

- `.gitconfig` の `[user]` セクションには個人のメールアドレスが設定されている
- `config/nvim/lua/plugins/ai.lua` の AWS プロファイル名（`bedrock-user@finatext-aircraft`）は環境に応じて変更すること
- `install.sh` は既存ファイルをバックアップしてからシンボリックリンクを作成する
