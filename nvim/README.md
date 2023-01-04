# Nvim Config

## thirdpart

### depend

1. [rg](https://github.com/BurntSushi/ripgrep): default search tools which replace grep.
2. [macos-macism](https://github.com/laishulu/macism): change input method.
3. [rust-analyzer](https://rust-analyzer.github.io/manual.html#rustup): rust language server.
4. [gitui](https://github.com/extrawurst/gitui): ctrl git.
5. [zoxide](https://github.com/ajeetdsouza/zoxide): A smarter cd command. Supports all major shells..

## Plugin

### UI

| Plugin                                                                                        | Description                                                                                  |
| --------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| [rebelot/kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim)                             | Neovim theme                                                                                 |
| [catppuccin/nvim](https://github.com/catppuccin/nvim)                                         | Neovim theme                                                                                 |
| [goolord/alpha-nvim](https://github.com/goolord/alpha-nvim)                                   | Alpha is a fast and fully programmable greeter for neovim.                                   |
| [rcarriga/nvim-notify](https://github.com/rcarriga/nvim-notify)                               | A fancy, configurable, notification manager for NeoVim.                                      |
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)                     | A blazing fast and easy to configure Neovim statusline written in Lua.                       |
| [kyazdani42/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)                | This plugin provides the same icons as well as colors for each icon.                         |
| [kyazdani42/nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua)                       | A file explorer for Neovim.                                                                  |
| [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) | This plugin adds indentation guides to all lines (including empty lines).                    |
| [akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim)                         | This plugin adds indentation guides to all lines (including empty lines).                    |
| [dstein64/nvim-scrollview](https://github.com/dstein64/nvim-scrollview)                       | A Neovim plugin that displays interactive vertical scrollbars.                               |
| [j-hui/fidget.nvim](https://github.com/j-hui/fidget.nvim)                                     | Standalone UI for nvim-lsp progress.                                                         |
| [zbirenbaum/neodim](https://github.com/zbirenbaum/neodim)                                     | This plugin for dimming the highlights of unused functions, variables, parameters, and more. |

### Editor

| Plugin                                                                                                                                      | Description                                                                                                                           |
| ------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| ( TODO: add description shortkey ) [junegunn/vim-easy-align](https://github.com/junegunn/vim-easy-align)                                    | A Vim alignment plugin.                                                                                                               |
| [RRethy/vim-illuminate](https://github.com/RRethy/vim-illuminate)                                                                           | Vim plugin for automatically highlighting other uses of the word under the cursor using either LSP, Tree-sitter, or regex matching.   |
| [terrortylor/nvim-comment](https://github.com/terrortylor/nvim-comment)                                                                     | A comment toggler for Neovim, written in Lua.                                                                                         |
| [JoosepAlviste/nvim-ts-context-commentstring](https://github.com/JoosepAlviste/nvim-ts-context-commentstring)                               | Neovim treesitter plugin for setting the commentstring based on the cursor location in a file.                                        |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)                                                       | Nvim Treesitter configurations and abstraction layer.                                                                                 |
| [nvim-treesitter/nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)                               | Syntax aware text-objects, select, move, swap, and peek support.                                                                      |
| ( FIXME: No longer maintained ) [p00f/nvim-ts-rainbow](https://github.com/p00f/nvim-ts-rainbow)                                             | Rainbow parentheses for neovim using tree-sitter. .                                                                                   |
| ( TODO: add description shortkey ) [andymass/vim-matchup](https://github.com/andymass/vim-matchup)                                          | Match-up is a plugin that lets you highlight, navigate, and operate on sets of matching text.                                         |
| [rainbowhxch/accelerated-jk.nvim](https://github.com/rainbowhxch/accelerated-jk.nvim)                                                       | This plugin accelerates j/k mappings' steps while j or k key is repeating.                                                            |
| [rhysd/clever-f.vim](https://github.com/rhysd/clever-f.vim)                                                                                 | Extended f, F, t and T key mappings for Vim.                                                                                          |
| [romainl/vim-cool](https://github.com/romainl/vim-cool)                                                                                     | A very simple plugin that makes hlsearch more useful.                                                                                 |
| [phaazon/hop.nvim](https://github.com/phaazon/hop.nvim)                                                                                     | Hop is an EasyMotion-like plugin allowing you to jump anywhere in a document with as few keystrokes as possible.                      |
| [karb94/neoscroll.nvim](https://github.com/karb94/neoscroll.nvim)                                                                           | Smooth scrolling neovim plugin written in lua.                                                                                        |
| [karb94/neoscroll.nvim](https://github.com/karb94/neoscroll.nvim)                                                                           | Smooth scrolling neovim plugin written in lua.                                                                                        |
| [akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)                                                                       | A neovim plugin to persist and toggle multiple terminals during an editing session.                                                   |
| [NvChad/nvim-colorizer.lua](https://github.com/NvChad/nvim-colorizer.lua)                                                                   | A high-performance color highlighter for Neovim which has no external dependencies! Written in performant Luajit.                     |
| [rmagatti/auto-session](https://github.com/rmagatti/auto-session)                                                                           | A small automated session manager for Neovim.                                                                                         |
| [max397574/better-escape.nvim](https://github.com/max397574/better-escape.nvim)                                                             | Escape from insert mode without delay when typing.                                                                                    |
| [mfussenegger/nvim-dap](https://github.com/mfussenegger/nvim-dap)                                                                           | Debug Adapter Protocol client implementation for Neovim.                                                                              |
| [rcarriga/nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)                                                                             | A UI for nvim-dap.                                                                                                                    |
| [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)                                                                                 | Fugitive is the premier Vim plugin for Git.                                                                                           |
| [famiu/bufdelete.nvim](https://github.com/famiu/bufdelete.nvim)                                                                             | Bufdelete.nvim aims to fix that by providing useful commands that allow you to delete a buffer without messing up your window layout. |
| [sindrets/diffview.nvim](https://github.com/sindrets/diffview.nvim)                                                                         | Single tabpage interface for easily cycling through diffs for all modified files for any git rev.                                     |
| ( FIXME: neovim ver0.9 will support splitkeep replace this plugin ) [luukvbaal/stabilize.nvim](https://github.com/luukvbaal/stabilize.nvim) | Neovim plugin to stabilize window open/close events.                                                                                  |
| ( TODO: add tmux buffer list support ) [ibhagwan/smartyank.nvim](https://github.com/ibhagwan/smartyank.nvim)                                | Better yank support.                                                                                                                  |
| ( TODO: add description shortkey ) [ur4ltz/surround.nvim](https://github.com/ur4ltz/surround.nvim)                                          | A surround text object plugin for neovim written in lua.                                                                              |

### Tools

| Plugin                                                                                                  | Description                                                                                                                |
| ------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)                                       | Infra about lua plugin which depend this.                                                                                  |
| [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)                       | Highly extendable fuzzy finder over lists.                                                                                 |
| [nvim-lua/popup.nvim](https://github.com/nvim-lua/popup.nvim)                                           | An implementation of the Popup API from vim in Neovim. Hope to upstream when complete                                      |
| [debugloop/telescope-undo.nvim](https://github.com/debugloop/telescope-undo.nvim)                       | A telescope extension to view and search your undo tree.                                                                   |
| [ahmedkhalf/project.nvim](https://github.com/ahmedkhalf/project.nvim)                                   | The superior project management solution for neovim.                                                                       |
| [nvim-telescope/telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim) | FZF sorter for telescope written in c.                                                                                     |
| [nvim-telescope/telescope-frecency.nvim](https://github.com/nvim-telescope/telescope-frecency.nvim)     | A telescope.nvim extension that offers intelligent prioritization when selecting files from your editing history.          |
| [jvgrootveld/telescope-zoxide](https://github.com/jvgrootveld/telescope-zoxide)                         | An extension for telescope.nvim that allows you operate zoxide within Neovim.                                              |
| [michaelb/sniprun](https://github.com/michaelb/sniprun)                                                 | A neovim plugin to run lines/blocs of code.                                                                                |
| [folke/trouble.nvim](https://github.com/folke/trouble.nvim)                                             | A pretty diagnostics, references, telescope results, quickfix and location list.                                           |
| [folke/todo-comments.nvim](https://github.com/folke/todo-comments.nvim)                                 | Highlight and search for todo comments.                                                                                    |
| [gelguy/wilder.nvim](https://github.com/gelguy/wilder.nvim)                                             | A more adventurous wildmenu.                                                                                               |
| [folke/which-key.nvim](https://github.com/folke/which-key.nvim)                                         | WhichKey is a lua plugin for Neovim 0.5 that displays a popup with possible keybindings of the command you started typing. |
| [mrjones2014/legendary.nvim](https://github.com/mrjones2014/legendary.nvim)                             | A legend for your keymaps, commands, and autocmds, with which-key.nvim integration.                                        |
| [cdelledonne/vim-cmake](https://github.com/cdelledonne/vim-cmake)                                       | Vim/Neovim plugin for working with CMake projects.                                                                         |

