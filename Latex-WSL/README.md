# LaTeX & VimTeX Setup Guide (Linux & WSL2)

A guide to setting up **VimTeX**, **Zathura (PDF viewer)**, **latexmk**, and **SyncTeX** with Neovim in **Debian / Linux** and **WSL2 / WSLg**.

---

## Step 1: Install System Dependencies

### Option A: Native Linux (Debian)

Run the following command in your terminal:

```bash
sudo apt update && sudo apt install -y \
  latexmk \
  texlive-latex-base \
  texlive-latex-extra \
  texlive-fonts-recommended \
  zathura \
  zathura-pdf-poppler \
  adwaita-icon-theme \
  chktex
```

Install the TexLab LSP standalone binary into `~/.local/bin`:

```bash
curl -s https://api.github.com/repos/latex-lsp/texlab/releases/latest \
  | grep "browser_download_url.*texlab-x86_64-linux.tar.gz\"" \
  | cut -d : -f 2,3 \
  | tr -d ' "' \
  | wget -qi - -O /tmp/texlab.tar.gz
tar -xzf /tmp/texlab.tar.gz -C ~/.local/bin/ texlab
chmod +x ~/.local/bin/texlab
rm /tmp/texlab.tar.gz
```

---

### Option B: Windows WSL2 (Ubuntu)

Run inside your WSL2 Ubuntu terminal:

```bash
sudo apt update && sudo apt install -y \
  latexmk \
  texlive-latex-base \
  texlive-latex-extra \
  texlive-fonts-recommended \
  zathura \
  zathura-pdf-poppler \
  adwaita-icon-theme \
  chktex
```

Install the TexLab LSP standalone binary into `~/.local/bin`:

```bash
curl -s https://api.github.com/repos/latex-lsp/texlab/releases/latest \
  | grep "browser_download_url.*texlab-x86_64-linux.tar.gz\"" \
  | cut -d : -f 2,3 \
  | tr -d ' "' \
  | wget -qi - -O /tmp/texlab.tar.gz
tar -xzf /tmp/texlab.tar.gz -C ~/.local/bin/ texlab
chmod +x ~/.local/bin/texlab
rm /tmp/texlab.tar.gz
```

---

## Step 2: Fix the WSLg Mouse Cursor (WSL2 Only)

In WSLg, Wayland GTK applications (like Zathura) require local user-level cursor theme paths to properly render the mouse pointer.

Run the provided helper script:

```bash
cd ~/.config/nvim/Latex-WSL
./setup-cursor.sh
```

*(This creates `~/.icons/default/cursors` linking to Adwaita and copies `zathurarc` to `~/.config/zathura/zathurarc`).*

> **Note**: If the mouse cursor does not appear immediately after launching Zathura for the first time in WSL2, run `wsl --shutdown` from Windows PowerShell / Terminal, then restart your distro to clear WSLg's compositor cache.

---

## Step 3: Enable VimTeX in Neovim

Your [`~/.config/nvim/init.lua`](../init.lua) is preconfigured with:

### 1. Plugin (`vim.pack.add`):
```lua
'https://github.com/lervag/vimtex',
```

### 2. LSP Client (`vim.lsp.enable`):
```lua
'texlab',
```

### 3. VimTeX Options:
```lua
-- VimTeX (Wayland / WSLg native)
vim.g.vimtex_view_method = 'zathura_simple'
vim.g.vimtex_compiler_method = 'latexmk'
vim.g.vimtex_compiler_latexmk = {
    aux_dir = 'build',
    out_dir = 'pdfs',
}
```

### 4. Treesitter LaTeX Parser:
Inside Neovim, run:
```vim
:TSInstall latex
```

---

## Keybindings & Usage Cheat Sheet

### VimTeX in Neovim
| Keybinding | Action |
| :--- | :--- |
| **`<Space>ll`** | **Toggle Continuous Compilation** (starts `latexmk` background compiler & opens Zathura; press again to stop) |
| **`<Space>lv`** | **Forward Search** (jump from cursor in Neovim straight to that location in Zathura PDF) |
| **`<Space>lt`** | **Table of Contents** (open an interactive document outline drawer inside Neovim) |
| **`<Space>le`** | **Error Log** (opens Quickfix list showing LaTeX compiler errors and warnings) |
| **`<Space>lc`** | **Clean auxiliary files** (removes `.aux`, `.log`, `.fls`, `.out`) |
| **`dse`** | **Delete surrounding environment** (e.g. `\begin{equation} ... \end{equation}` ➔ `...`) |
| **`cse`** | **Change surrounding environment** (e.g. change `itemize` to `enumerate`) |
| **`tse`** | **Toggle star** (e.g. toggle `\begin{equation}` ➔ `\begin{equation*}`) |

---

## Custom Callout Box Snippets

Preconfigured in [`snippets/tex.json`](../snippets/tex.json) for `tcolorbox` notes:

| Trigger Prefix | Expanded LaTeX Block | Description |
| :--- | :--- | :--- |
| **`defbox`** or `definitionbox` | `\begin{definitionbox}{Title} ... \end{definitionbox}` | Blue callout box for definitions & key concepts |
| **`warnbox`** or `warningbox` | `\begin{warningbox}{Title} ... \end{warningbox}` | Orange/Red callout box for warnings & critical notes |
| **`exbox`** or `examplebox` | `\begin{examplebox}{Title} ... \end{examplebox}` | Green callout box for examples & tips |
| **`tbf`** | `\textbf{text}` | Fast bold formatting |

---

### Zathura PDF Viewer Navigation
| Key | Action |
| :--- | :--- |
| **`Ctrl + Left Click`** | **SyncTeX Inverse Search** (jumps directly from the PDF back to that line in Neovim) |
| **`j` / `k`** | Scroll down / up smoothly |
| **`d` / `u`** | Half-page down / up |
| **`Space`** / **`Shift + Space`** | Full-page down / up |
| **`gg`** / **`G`** | Jump to first / last page |
| **`<Tab>`** | Toggle Table of Contents / Index drawer |
| **`+` / `-`** | Zoom in / Zoom out |
| **`a` / `s`** | Fit-to-best / Fit-to-width |
| **`F11`** | Toggle Fullscreen mode |
| **`r`** | Rotate page 90° clockwise |
| **`Ctrl + r`** | Invert colors (Dark mode) |
| **`:`** | Open Zathura command line (`:open <file>`, `:bmark <name>`, `:q`) |
