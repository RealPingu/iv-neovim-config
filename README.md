# IVNeovimConfig

A lightweight, modern, and high-performance Neovim configuration built for **Neovim 0.12+**, tailored for **Debian Linux** and **Windows WSL2 (Ubuntu)**.

It uses native Neovim features (native `vim.pack.add` package management, native `vim.lsp.enable`, and built-in Treesitter) for lightning-fast startup with zero third-party plugin manager overhead.

---

## Features

- **Package Management**: Native `vim.pack.add` with reproducible lockfile (`nvim-pack-lock.json`).
- **Dashboard**: [alpha-nvim](https://github.com/goolord/alpha-nvim) with custom Cyberdream-themed penguin ASCII art, side-by-side quick actions, recent folders, and recent files.
- **Aesthetic & Cursor**: [cyberdream.nvim](https://github.com/scottmckendry/cyberdream.nvim) theme with transparent background support and [smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim) for smooth animated cursor trail.
- **Completion**: [blink.cmp](https://github.com/saghen/blink.cmp) + [friendly-snippets](https://github.com/rafamadriz/friendly-snippets).
- **Fuzzy Finder & Navigation**: [fzf-lua](https://github.com/ibhagwan/fzf-lua) for high-performance searching and [flash.nvim](https://github.com/folke/flash.nvim) for fast 2D code navigation and Treesitter selection.
- **File Explorer**: [oil.nvim](https://github.com/stevearc/oil.nvim) for editing filesystem buffers like text.
- **LSP & Formatting**: Native `vim.lsp` with auto-format on save and dynamic [Emmet](https://github.com/olrtg/emmet-language-server) attachment for HTML/JSX/CSS.
- **LaTeX & Document Editing**: [vimtex](https://github.com/lervag/vimtex) with background continuous compilation (`latexmk`) and PDF integration.
- **Git**: [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) (with smart CWD & Oil buffer repository resolution) and [codediff.nvim](https://github.com/esmuellert/codediff.nvim).
- **Clipboard**: Synchronized shared system clipboard via `xclip`.

---

## Installation Guide: Native Linux (Debian)

### 1. Neovim v0.12.0 or Newer

```bash
mkdir -p ~/.local/bin
curl -LO https://github.com/neovim/neovim/releases/download/v0.12.4/nvim-linux-x86_64.appimage
chmod +x nvim-linux-x86_64.appimage
mv nvim-linux-x86_64.appimage ~/.local/bin/nvim

# Ensure ~/.local/bin is in your PATH (e.g. in ~/.bashrc)
export PATH="$HOME/.local/bin:$PATH"
```

### 2. Debian System Packages

Install the core CLI tools for searching, git, compiling Treesitter parsers, and clipboard integration:

```bash
sudo apt update
sudo apt install -y \
  xclip \
  ripgrep \
  fd-find \
  fzf \
  gcc \
  tar \
  curl \
  git \
  lazygit
```

### 3. LaTeX Compiler & Zathura PDF Viewer

```bash
sudo apt install -y \
  latexmk \
  texlive-latex-base \
  texlive-latex-extra \
  texlive-fonts-recommended \
  zathura \
  zathura-pdf-poppler \
  chktex \
  adwaita-icon-theme
```

### 4. Language Servers (Debian)

Because Debian does not package `lua-language-server`, `marksman`, or `texlab` in `apt`, install them as standalone binaries into `~/.local/bin`:

#### C / C++ (Clangd)
```bash
sudo apt install -y clangd
```

#### Lua (lua-language-server)
```bash
mkdir -p ~/.local/share/lua-language-server
curl -s https://api.github.com/repos/LuaLS/lua-language-server/releases/latest \
  | grep "browser_download_url.*linux-x64.tar.gz\"" \
  | cut -d : -f 2,3 | tr -d ' "' \
  | wget -qi - -O /tmp/lua-ls.tar.gz
tar -xzf /tmp/lua-ls.tar.gz -C ~/.local/share/lua-language-server
ln -sf ~/.local/share/lua-language-server/bin/lua-language-server ~/.local/bin/lua-language-server
rm /tmp/lua-ls.tar.gz
```

#### Markdown (Marksman)
```bash
curl -s https://api.github.com/repos/artempyanykh/marksman/releases/latest \
  | grep "browser_download_url.*marksman-linux-x64\"" \
  | cut -d : -f 2,3 | tr -d ' "' \
  | wget -qi - -O ~/.local/bin/marksman
chmod +x ~/.local/bin/marksman
```

#### LaTeX (TexLab)
```bash
curl -s https://api.github.com/repos/latex-lsp/texlab/releases/latest \
  | grep "browser_download_url.*texlab-x86_64-linux.tar.gz\"" \
  | cut -d : -f 2,3 | tr -d ' "' \
  | wget -qi - -O /tmp/texlab.tar.gz
tar -xzf /tmp/texlab.tar.gz -C ~/.local/bin/ texlab
chmod +x ~/.local/bin/texlab
rm /tmp/texlab.tar.gz
```

#### Python (Ruff)
```bash
pipx install ruff
```

#### Web / Frontend (via pnpm)
```bash
pnpm add -g @olrtg/emmet-language-server typescript typescript-language-server @tailwindcss/language-server
```

### 5. Font
Install a Nerd Font (such as JetBrains Mono Nerd Font) to `~/.local/share/fonts` and set it in your terminal emulator.

---

## Installation Guide: Windows & WSL2 (Ubuntu)

### 1. Windows Host Setup
- Install a [Nerd Font](https://www.nerdfonts.com/) (e.g. **JetBrains Mono Nerd Font**) on Windows.
- Open **Windows Terminal**, open **Settings** (`Ctrl + ,`), select your Ubuntu profile, open **Appearance**, and set your font to **JetBrainsMono Nerd Font**.

### 2. Neovim v0.12.0 or Newer in WSL2

Run inside your WSL2 Ubuntu terminal:

```bash
mkdir -p ~/.local/bin
curl -LO https://github.com/neovim/neovim/releases/download/v0.12.4/nvim-linux-x86_64.appimage
chmod +x nvim-linux-x86_64.appimage
mv nvim-linux-x86_64.appimage ~/.local/bin/nvim

# Ensure ~/.local/bin is in your PATH (e.g. in ~/.bashrc)
export PATH="$HOME/.local/bin:$PATH"
```

### 3. Ubuntu System Packages (with WSL2 Clipboard & Browser Previews)

```bash
sudo apt update
sudo apt install -y \
  xclip \
  ripgrep \
  fd-find \
  fzf \
  gcc \
  tar \
  curl \
  git \
  lazygit \
  wslu
```

> **WSL2 Integration Notes**:
> - **Clipboard (`xclip`)**: Enables Neovim's `vim.opt.clipboard = 'unnamedplus'` to communicate across the WSL2 boundary with the Windows host clipboard (`Ctrl+C` / `Ctrl+V`).
> - **Browser Previews (`wslu` / `wslview`)**: Allows plugins like `markdown-preview.nvim` to open HTML previews directly in your default Windows web browser.

### 4. LaTeX, Zathura & WSLg Cursor Fix

```bash
sudo apt install -y \
  latexmk \
  texlive-latex-base \
  texlive-latex-extra \
  texlive-fonts-recommended \
  zathura \
  zathura-pdf-poppler \
  chktex \
  adwaita-icon-theme

# Configure mouse pointer visibility for WSLg Wayland applications:
cd ~/.config/nvim/Latex-WSL
./setup-cursor.sh
```

### 5. Language Servers (Ubuntu / WSL2)

#### C / C++ (Clangd)
```bash
sudo apt install -y clangd
```

#### Lua (lua-language-server)
On Ubuntu 24.04+:
```bash
sudo apt install -y lua-language-server
```
On older Ubuntu versions, use the standalone binary:
```bash
mkdir -p ~/.local/share/lua-language-server
curl -s https://api.github.com/repos/LuaLS/lua-language-server/releases/latest \
  | grep "browser_download_url.*linux-x64.tar.gz\"" \
  | cut -d : -f 2,3 | tr -d ' "' \
  | wget -qi - -O /tmp/lua-ls.tar.gz
tar -xzf /tmp/lua-ls.tar.gz -C ~/.local/share/lua-language-server
ln -sf ~/.local/share/lua-language-server/bin/lua-language-server ~/.local/bin/lua-language-server
rm /tmp/lua-ls.tar.gz
```

#### Markdown (Marksman)
```bash
curl -s https://api.github.com/repos/artempyanykh/marksman/releases/latest \
  | grep "browser_download_url.*marksman-linux-x64\"" \
  | cut -d : -f 2,3 | tr -d ' "' \
  | wget -qi - -O ~/.local/bin/marksman
chmod +x ~/.local/bin/marksman
```

#### LaTeX (TexLab)
```bash
curl -s https://api.github.com/repos/latex-lsp/texlab/releases/latest \
  | grep "browser_download_url.*texlab-x86_64-linux.tar.gz\"" \
  | cut -d : -f 2,3 | tr -d ' "' \
  | wget -qi - -O /tmp/texlab.tar.gz
tar -xzf /tmp/texlab.tar.gz -C ~/.local/bin/ texlab
chmod +x ~/.local/bin/texlab
rm /tmp/texlab.tar.gz
```

#### Python (Ruff)
```bash
pip install --user ruff
# or: pipx install ruff
```

#### Web / Frontend (via pnpm or npm)
```bash
pnpm add -g @olrtg/emmet-language-server typescript typescript-language-server @tailwindcss/language-server
```

---

## Quickstart Configuration Launch

1. **Clone this repository** into your Neovim configuration directory:
   ```bash
   git clone https://github.com/RealPingu/iv-neovim-config.git ~/.config/nvim
   ```

2. **Open Neovim**:
   ```bash
   nvim
   ```
   *Neovim automatically downloads and installs all plugins on first startup via `vim.pack.add`.*

3. **Install Core Treesitter Parsers**:
   Inside Neovim, run:
   ```vim
   :TSInstall bash c cpp css html javascript json lua markdown markdown_inline python regex rust toml tsx typescript yaml
   ```

---

## Keybindings Cheat Sheet

### General & Navigation
| Keybinding | Mode | Action |
| :--- | :---: | :--- |
| `<Space>` | Normal | **Leader key** |
| `jj` | Insert | Fast escape to Normal mode |
| `<leader>ff` | Terminal | Exit terminal mode (`<C-\><C-n>`) |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | Normal | Move focus between split windows |
| `<leader>vn` | Normal | Open empty vertical split (`:vnew`) |
| `<leader>sn` | Normal | Open empty horizontal split (`:new`) |
| `<leader>mm` | Normal | Close current buffer while preserving window split layout |
| `zk` | Normal, Visual, Op | **Flash Jump** (Teleport cursor anywhere on screen) |
| `-` | Normal | Open [Oil.nvim](https://github.com/stevearc/oil.nvim) parent directory file browser |
| `<leader>o` | Oil Buffer | Toggle hidden files in Oil |
| `<leader>p` | Oil Buffer | Refresh directory listing in Oil |

### Fuzzy Search ([fzf-lua](https://github.com/ibhagwan/fzf-lua))
| Keybinding | Mode | Action |
| :--- | :---: | :--- |
| `<leader><leader>` | Normal | Find files in project |
| `<leader>/` | Normal | Live grep text in project (powered by `ripgrep`) |
| `<leader>b` | Normal | Find open buffers |
| `<leader>fb` | Normal | Find files in current buffer directory |
| `<leader>fh` | Normal | Find files in home (`~`) directory |

### LSP & Code Intelligence
| Keybinding | Mode | Action |
| :--- | :---: | :--- |
| `gd` | Normal | Go to definition |
| `K` | Normal | Hover documentation / signatures |
| `<leader>d` | Normal | Open floating diagnostic window |
| *Auto* | On Save | Auto-formats code with attached LSP server |

### Git & Tools
| Keybinding | Mode | Action |
| :--- | :---: | :--- |
| `<leader>gg` | Normal | Launch **LazyGit** from Neovim launched directory (CWD) |
| `<leader>gf` | Normal | Launch **LazyGit** scoped to current file or **Oil** directory's Git repo |

---

## Plugin Ecosystem & External Dependencies

| Plugin | Purpose | External Tool Requirements |
| :--- | :--- | :--- |
| [`ibhagwan/fzf-lua`](https://github.com/ibhagwan/fzf-lua) | Fuzzy Finder & Grep | `fzf`, `ripgrep` (`rg`), `fd-find` (`fd`) |
| [`nvim-treesitter/nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax Highlighting & AST | `gcc`/`clang`, `tree-sitter-cli`, `tar`, `curl` |
| [`neovim/nvim-lspconfig`](https://github.com/neovim/nvim-lspconfig) | Language Server Client | Language servers (`ruff`, `lua-language-server`, `ts_ls`, `clangd`, etc.) |
| [`karb94/neoscroll.nvim`](https://github.com/karb94/neoscroll.nvim) | Smooth Window Scrolling | Pure Lua (no external dependencies) |
| [`scottmckendry/cyberdream.nvim`](https://github.com/scottmckendry/cyberdream.nvim) | Colorscheme | TrueColor terminal support |
| [`saghen/blink.cmp`](https://github.com/saghen/blink.cmp) | Autocompletion & Snippets | Prebuilt binary auto-fetched (or `cargo` / Rust) |
| [`esmuellert/codediff.nvim`](https://github.com/esmuellert/codediff.nvim) | Side-by-side Code Diffing | Prebuilt binary auto-fetched + system `libgomp.so.1` |
| [`kdheepak/lazygit.nvim`](https://github.com/kdheepak/lazygit.nvim) | Git TUI Floating Window | `lazygit` CLI |
| [`stevearc/oil.nvim`](https://github.com/stevearc/oil.nvim) | File System Editor | `nvim-web-devicons` (optional: `trash-cli`) |
| [`olrtg/emmet-language-server`](https://github.com/olrtg/emmet-language-server) | HTML/JSX/CSS Abbreviations | `@olrtg/emmet-language-server` via `pnpm`/`npm` |
| [`rafamadriz/friendly-snippets`](https://github.com/rafamadriz/friendly-snippets) | Predefined Code Snippets | Pure JSON (no external dependencies) |
| [`nvim-mini/mini.pairs`](https://github.com/nvim-mini/mini.pairs) | Autoclose Brackets & Quotes | Pure Lua (no external dependencies) |
| [`MeanderingProgrammer/render-markdown.nvim`](https://github.com/MeanderingProgrammer/render-markdown.nvim) | In-buffer Markdown Rendering | Treesitter `markdown` & `markdown_inline` parsers + Nerd Font |
| [`nvim-tree/nvim-web-devicons`](https://github.com/nvim-tree/nvim-web-devicons) | File Type Icons | Nerd Font in terminal |
| [`iamcco/markdown-preview.nvim`](https://github.com/iamcco/markdown-preview.nvim) | Browser Markdown Preview | Node.js + `cd app && ./install.sh` + `wslu` (`wslview`) |
| [`goolord/alpha-nvim`](https://github.com/goolord/alpha-nvim) | Fast Startup Dashboard | Pure Lua (configured in `lua/alpha-config.lua`) |
| [`folke/flash.nvim`](https://github.com/folke/flash.nvim) | 2D Motion & Treesitter Navigation | Pure Lua (no external dependencies) |
| [`sphamba/smear-cursor.nvim`](https://github.com/sphamba/smear-cursor.nvim) | Animated Trailing Cursor | Terminal supporting RGB / TrueColor |
| [`lervag/vimtex`](https://github.com/lervag/vimtex) | LaTeX Editing & Compilation | `latexmk`, `texlive`, PDF viewer (`zathura`) |

---

## Wallpaper Engine Transparency Companion

If you use **Wallpaper Engine** and want your live animated wallpaper to display cleanly behind your transparent terminal without other open windows getting in the way, check out the companion tool in [`WallPaperEngineTerminal/`](./WallPaperEngineTerminal):
- **Windows (AutoHotkey v2)**: Automatically minimizes background windows on the same monitor whenever Windows Terminal is focused.
- **Linux (Experimental)**: Equivalent background script for Linux/X11 window managers.

---

## LaTeX & VimTeX Setup

If you write LaTeX and want continuous compilation (`latexmk`), full SyncTeX Forward & Inverse search (`Ctrl + Click`), and PDF viewing via **Zathura**, check out the dedicated setup guide in [`Latex-WSL/`](./Latex-WSL).
