# dotfiles

Takeru Tsuchiya の開発環境設定ファイル一式。新しい macOS マシンに環境を同期するために使う。

- **対象 OS**: macOS（Apple Silicon / Intel）
- **シェル**: zsh（Oh My Zsh + Powerlevel10k）
- **エディタ**: Neovim（lazy.nvim + LSP + avante.nvim）
- **ターミナル**: Ghostty
- **マルチプレクサ**: tmux（prefix: `Ctrl-g`）

## クイックスタート

すでに Homebrew がある macOS で、最短で環境を立ち上げる手順。

```bash
# 1. 必須ツールを入れる
brew install git neovim tmux fzf ghq zsh \
  zsh-syntax-highlighting zsh-autosuggestions powerlevel10k \
  pyenv pyenv-virtualenv aquaproj/aqua/aqua
brew install --cask ghostty font-hack-nerd-font

# 2. リポジトリを clone
ghq get https://github.com/takeru403/dotfiles

# 3. シンボリックリンクを作成
cd ~/ghq/github.com/takeru403/dotfiles && bash install.sh
```

このあと `nvim` を起動すれば lazy.nvim がプラグインを自動インストールする。

> **注意**: `install.sh` は `~/.zshrc` などを **シンボリックリンクで上書き** する。既存ファイルはバックアップされるが、事前に `ls -la ~ | grep -E '\.zshrc|\.vimrc|\.tmux.conf'` で確認しておくと安全。

## 詳細セットアップ

クイックスタートで足りない場合や、各ツールを個別に入れたいときの手順。

### 1. 前提ツールのインストール

```bash
# Homebrew（未インストールの場合）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# シェル・基本ツール
brew install git neovim tmux fzf ghq zsh
brew install zsh-syntax-highlighting zsh-autosuggestions

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k テーマ
brew install powerlevel10k

# 言語ランタイム
brew install pyenv pyenv-virtualenv         # Python
curl https://get.volta.sh | bash             # Node.js（Volta）

# CLI バージョン管理
brew install aquaproj/aqua/aqua

# ターミナル & フォント
brew install --cask ghostty
brew install --cask font-hack-nerd-font      # Ghostty / Neovim のアイコン表示用
```

### 2. このリポジトリを clone

```bash
# ghq を使う場合（推奨）
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
nvim          # 起動すると lazy.nvim が自動でプラグインを取得
# 手動で同期したい場合は :Lazy sync
```

### 5. Git の個人情報を設定（別マシンで使う場合）

`.gitconfig` には著者の情報が入っているので、自分用に上書きする。

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

## 管理対象ファイル

| ファイル / ディレクトリ | 用途 |
|---|---|
| `.zshrc` / `.zprofile` / `.zshenv` | zsh 本体・ログイン時 PATH・環境変数 |
| `.bashrc` | bash（最小限の設定のみ） |
| `aliases.sh` | 共通エイリアス・関数（zsh から source） |
| `.tmux.conf` | tmux（prefix: `Ctrl-g`） |
| `.vimrc` | vim（Neovim からも参照） |
| `.gitconfig` | git グローバル設定 |
| `aqua.yaml` | aqua の CLI パッケージ定義 |
| `config/ghostty/config` | Ghostty ターミナル設定 |
| `config/nvim/` | Neovim 設定（lazy.nvim + LSP） |

## ディレクトリ構成

```
dotfiles/
├── README.md
├── install.sh                 # シンボリックリンク作成スクリプト
├── .gitignore
├── .zshrc                     # zsh メイン設定
├── .zprofile                  # Homebrew / SnowSQL の PATH
├── .zshenv                    # Rust (cargo) 環境変数
├── .bashrc                    # bash 設定（最小）
├── aliases.sh                 # 共通エイリアス・関数
├── .tmux.conf                 # tmux 設定
├── .vimrc                     # vim 設定
├── .gitconfig                 # git グローバル設定
├── aqua.yaml                  # aqua パッケージ定義
└── config/
    ├── ghostty/config         # Ghostty 設定（Neovim 向けキーバインド）
    └── nvim/
        ├── init.lua           # Neovim エントリ + lazy.nvim ブートストラップ
        └── lua/plugins/
            ├── ai.lua             # avante.nvim（AWS Bedrock / Claude）
            ├── colorscheme.lua    # tokyonight
            ├── editor.lua         # autopairs / Comment / gitsigns / toggleterm
            ├── lsp.lua            # LSP + nvim-cmp 補完
            ├── nvim-tree.lua      # ファイルエクスプローラー
            ├── oil.lua            # バッファ編集式ファイルマネージャー
            ├── telescope.lua      # ファジーファインダー
            ├── treesitter.lua     # 構文ハイライト
            └── ui.lua             # lualine / bufferline / which-key 等
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

## 注意事項・既知の前提

- **個人情報**: `.gitconfig` の `[user]` には著者のメールアドレスが入っている。別マシンで使うときは [詳細セットアップ §5](#5-git-の個人情報を設定別マシンで使う場合) のとおり `~/.gitconfig.local` で上書きする。
- **AWS プロファイル**: `config/nvim/lua/plugins/ai.lua` の AWS プロファイル名は `bedrock-user@finatext-aircraft` がハードコードされている。自分の環境に合わせて変更が必要。
- **install.sh の挙動**: 既存のドットファイルはバックアップしてからシンボリックリンクで置き換える。一度走らせるとリンク先がリポジトリに切り替わる点に注意。
