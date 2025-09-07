# Neovim Config

A minimal, modern, and modular Neovim configuration focused on productivity, code navigation and git.

## Features

- 🚀 Fast startup and lazy loading with [lazy.nvim](https://github.com/folke/lazy.nvim)
- 🧠 LSP support via [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) and [mason.nvim](https://github.com/williamboman/mason.nvim)
- 🧩 Syntax highlighting and code navigation with [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- 🔭 Fuzzy finding and search with [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- 🛢️ File explorer with [oil.nvim](https://github.com/stevearc/oil.nvim)
- 🎨 Theme with [rose-pine](https://github.com/rose-pine/neovim)
- ⚡️ Custom keymaps for fast workflow (see below or use `:Help` in Neovim)

## Plugins

- `lazy.nvim` - Plugin manager
- `rose-pine` - Colorscheme
- `nvim-treesitter` - Syntax highlighting
- `nvim-lspconfig` - LSP client
- `mason.nvim` & `mason-lspconfig.nvim` - LSP/DAP/Linter installer
- `telescope.nvim` - Fuzzy finder
- `oil.nvim` - File explorer
- `fidget.nvim` - LSP status
- `lazydev.nvim` - Lua LSP for Neovim config

## Keymaps

| Keymap         | Action                                 |
|----------------|----------------------------------------|
| `<leader>sf`   | Telescope: Search Files                |
| `<leader>sg`   | Telescope: Search Grep                 |
| `<leader>bl`   | Telescope: List Buffers                |
| `<leader>bn`   | Buffer: Next                           |
| `<leader>bp`   | Buffer: Previous                       |
| `<leader>bd`   | Buffer: Delete                         |
| `<leader>vp`   | Split window vertically                |
| `<leader>[`    | Buffer: Previous                       |
| `<leader>]`    | Buffer: Next                           |
| `<leader>p`    | Buffer: Alternate                      |
| `<leader>fr`   | Find and Replace (prompt)              |
| `<leader>rn`   | LSP: Rename symbol under cursor        |
| `<leader>h`    | LSP: Hover documentation               |
| `<leader>gd`   | LSP: Go to Definition                  |
| `<leader>gu`   | LSP: Show Usages (References)          |
| `-`            | Open parent directory (Oil)            |

> For a full list, run `:Help` inside Neovim.

## LSP

- Managed via `mason.nvim` and `mason-lspconfig.nvim`
- Pre-configured for Lua (`lua_ls`) and Vimscript (`vimls`)
- Easily extendable for other languages

## Installation

1. Clone this repo to your Neovim config directory:
	```sh
	git clone <this-repo-url> ~/.config/nvim
	```
2. Open Neovim. Plugins will be installed automatically.
3. Use `:Mason` to install additional language servers if needed.

## Customization

- Edit `lua/config/remap.lua` for keymaps
- Edit `lua/config/lazy.lua` to add/remove plugins
- Edit `lua/config/treesitter.lua` for Treesitter settings
- Edit `lua/config/mason.lua` for LSP server management
