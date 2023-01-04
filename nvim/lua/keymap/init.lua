local bind = require("keymap.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
require("keymap.config")

-- Plug key mappings
local plug_map = {
	-- nvim-bufdel
	["n|<C-q>"] = map_cr("BufDel"):with_noremap():with_silent(),
	-- Bufferline
	["n|gb"] = map_cr("BufferLinePick"):with_noremap():with_silent(),
	["n|<C-j>"] = map_cr("BufferLineCycleNext"):with_noremap():with_silent(),
	["n|<C-k>"] = map_cr("BufferLineCyclePrev"):with_noremap():with_silent(),
	-- ["n|<A-S-j>"] = map_cr("BufferLineMoveNext"):with_noremap():with_silent(),
	-- ["n|<A-S-k>"] = map_cr("BufferLineMovePrev"):with_noremap():with_silent(),
	["n|<leader>be"] = map_cr("BufferLineSortByExtension"):with_noremap(),
	["n|<leader>bd"] = map_cr("BufferLineSortByDirectory"):with_noremap(),
	-- ["n|<C-1>"] = map_cr("BufferLineGoToBuffer 1"):with_noremap():with_silent(),
	-- ["n|<C-2>"] = map_cr("BufferLineGoToBuffer 2"):with_noremap():with_silent(),
	-- ["n|<C-3>"] = map_cr("BufferLineGoToBuffer 3"):with_noremap():with_silent(),
	-- ["n|<C-4>"] = map_cr("BufferLineGoToBuffer 4"):with_noremap():with_silent(),
	-- ["n|<C-5>"] = map_cr("BufferLineGoToBuffer 5"):with_noremap():with_silent(),
	-- Plugin nvim-tree
	["n|<C-n>"] = map_cr("NvimTreeToggle"):with_noremap():with_silent(),
	["n|<leader>nf"] = map_cr("NvimTreeFindFile"):with_noremap():with_silent(),
	["n|<leader>nr"] = map_cr("NvimTreeRefresh"):with_noremap():with_silent(),
	-- Packer
	["n|<leader>ps"] = map_cr("PackerSync"):with_silent():with_noremap():with_nowait(),
	["n|<leader>pu"] = map_cr("PackerUpdate"):with_silent():with_noremap():with_nowait(),
	["n|<leader>pi"] = map_cr("PackerInstall"):with_silent():with_noremap():with_nowait(),
	["n|<leader>pc"] = map_cr("PackerClean"):with_silent():with_noremap():with_nowait(),
	-- Lsp mapp work when insertenter and lsp start
	["n|<leader>li"] = map_cr("LspInfo"):with_noremap():with_silent():with_nowait(),
	["n|<leader>lr"] = map_cr("LspRestart"):with_noremap():with_silent():with_nowait(),
	["n|go"] = map_cr("Lspsaga outline"):with_noremap():with_silent(),
	["n|g["] = map_cr("Lspsaga diagnostic_jump_prev"):with_noremap():with_silent(),
	["n|g]"] = map_cr("Lspsaga diagnostic_jump_next"):with_noremap():with_silent(),
	["n|gs"] = map_cr("lua vim.lsp.buf.signature_help()"):with_noremap():with_silent(),
	["n|gr"] = map_cr("Lspsaga rename"):with_noremap():with_silent(),
	["n|K"] = map_cr("Lspsaga hover_doc"):with_noremap():with_silent(),
	["n|ga"] = map_cr("Lspsaga code_action"):with_noremap():with_silent(),
	["v|ga"] = map_cu("Lspsaga code_action"):with_noremap():with_silent(),
	["n|gd"] = map_cr("Lspsaga peek_definition"):with_noremap():with_silent(),
	["n|gD"] = map_cr("lua vim.lsp.buf.definition()"):with_noremap():with_silent(),
	["n|gh"] = map_cr("Lspsaga lsp_finder"):with_noremap():with_silent(),
	["n|gps"] = map_cr("G push"):with_noremap():with_silent(),
	["n|gpl"] = map_cr("G pull"):with_noremap():with_silent(),
	-- toggleterm
	-- ["t|<Esc><Esc>"] = map_cmd([[<C-\><C-n>]]), -- switch to normal mode in terminal.
	["n|<C-\\>"] = map_cr([[execute v:count . "ToggleTerm direction=horizontal"]]):with_noremap():with_silent(),
	["i|<C-\\>"] = map_cmd("<Esc><Cmd>ToggleTerm direction=horizontal<CR>"):with_noremap():with_silent(),
	["t|<C-\\>"] = map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_noremap():with_silent(),
	["n|<C-w>t"] = map_cr([[execute v:count . "ToggleTerm direction=vertical"]]):with_noremap():with_silent(),
	["i|<C-w>t"] = map_cmd("<Esc><Cmd>ToggleTerm direction=vertical<CR>"):with_noremap():with_silent(),
	["t|<C-w>t"] = map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_noremap():with_silent(),
	["n|<F5>"] = map_cr([[execute v:count . "ToggleTerm direction=vertical"]]):with_noremap():with_silent(),
	["i|<F5>"] = map_cmd("<Esc><Cmd>ToggleTerm direction=vertical<CR>"):with_noremap():with_silent(),
	["t|<F5>"] = map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_noremap():with_silent(),
	["n|<leader>te"] = map_cr([[execute v:count . "ToggleTerm direction=float"]]):with_noremap():with_silent(),
	-- ["i|<leader>te"] = map_cmd("<Esc><Cmd>ToggleTerm direction=float<CR>"):with_noremap():with_silent(),
	["t|<leader>te"] = map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_noremap():with_silent(),
	["n|<leader>g"] = map_cr("lua toggle_gitui()"):with_noremap():with_silent(),
	["t|<leader>g"] = map_cmd("<Esc><Cmd>lua toggle_gitui()<CR>"):with_noremap():with_silent(),
	["n|<leader>G"] = map_cu("Git"):with_noremap():with_silent(),
	-- Plugin trouble
	["n|gt"] = map_cr("TroubleToggle"):with_noremap():with_silent(),
	["n|gR"] = map_cr("TroubleToggle lsp_references"):with_noremap():with_silent(),
	["n|<leader>td"] = map_cr("TroubleToggle document_diagnostics"):with_noremap():with_silent(),
	["n|<leader>tw"] = map_cr("TroubleToggle workspace_diagnostics"):with_noremap():with_silent(),
	["n|<leader>tq"] = map_cr("TroubleToggle quickfix"):with_noremap():with_silent(),
	["n|<leader>tl"] = map_cr("TroubleToggle loclist"):with_noremap():with_silent(),
	-- Plugin todo commond
	["n|<leader>tt"] = map_cr("TodoTelescope"):with_noremap():with_silent(),
	-- Plugin Telescope
	["n|<leader>u"] = map_cr("lua require('telescope').extensions.undo.undo()"):with_noremap():with_silent(),
	["n|<leader>fp"] = map_cu("lua require('telescope').extensions.projects.projects{}"):with_noremap():with_silent(),
	["n|<leader>fr"] = map_cu("lua require('telescope').extensions.frecency.frecency{}"):with_noremap():with_silent(),
	["n|<leader>fw"] = map_cu("lua require('telescope').extensions.live_grep_args.live_grep_args{}")
		:with_noremap()
		:with_silent(),
	["n|<leader>fe"] = map_cu("Telescope oldfiles"):with_noremap():with_silent(),
	["n|<C-p>"] = map_cu("Telescope find_files"):with_noremap():with_silent(),
	["n|<leader>fc"] = map_cu("Telescope colorscheme"):with_noremap():with_silent(),
	["n|<leader>fn"] = map_cu(":enew"):with_noremap():with_silent(),
	["n|<leader>fg"] = map_cu("Telescope git_files"):with_noremap():with_silent(),
	["n|<leader>fz"] = map_cu("Telescope zoxide list"):with_noremap():with_silent(),
	["n|<leader>fb"] = map_cu("Telescope buffers"):with_noremap():with_silent(),
	["n|<Leader>o"] = map_cu("Telescope lsp_document_symbols"):with_noremap():with_silent(),
	["n|<Leader>as"] = map_cu("Telescope lsp_dynamic_workspace_symbols"):with_noremap():with_silent(),
	-- Plugin accelerate-jk
	["n|j"] = map_cmd("v:lua.enhance_jk_move('j')"):with_silent():with_expr(),
	["n|k"] = map_cmd("v:lua.enhance_jk_move('k')"):with_silent():with_expr(),
	-- Plugin vim-eft
	["n|;"] = map_cmd("v:lua.enhance_ft_move(';')"):with_expr(),
	["n|,"] = map_cmd("v:lua.enhance_ft_move(',')"):with_expr(),
	-- Plugin Hop
	["n|<leader>w"] = map_cu("HopWord"):with_noremap(),
	["n|<leader>j"] = map_cu("HopLine"):with_noremap(),
	["n|<leader>k"] = map_cu("HopLine"):with_noremap(),
	["n|<leader>c"] = map_cu("HopChar1"):with_noremap(),
	["n|<leader>cc"] = map_cu("HopChar2"):with_noremap(),
	-- Plugin EasyAlign
	["n|gea"] = map_cmd("v:lua.enhance_align('nea')"):with_expr(),
	["x|gea"] = map_cmd("v:lua.enhance_align('xea')"):with_expr(),
	-- Plugin MarkdownPreview
	["n|<F12>"] = map_cr("MarkdownPreviewToggle"):with_noremap():with_silent(),
	-- Plugin auto_session
	["n|<leader>ss"] = map_cu("SaveSession"):with_noremap():with_silent(),
	["n|<leader>sr"] = map_cu("RestoreSession"):with_noremap():with_silent(),
	["n|<leader>sd"] = map_cu("DeleteSession"):with_noremap():with_silent(),
	-- Plugin SnipRun
	-- ["n|<leader>r"] = map_cu([[%SnipRun]]):with_noremap():with_silent(),
	["n|<leader>r"] = map_cr("SnipClose"):with_noremap():with_silent(),
	["v|<leader>r"] = map_cr("SnipRun"):with_noremap():with_silent(),
	-- Plugin dap
	["n|<F6>"] = map_cr("lua require('dap').continue()"):with_noremap():with_silent(),
	["n|<leader>dr"] = map_cr("lua require('dap').continue()"):with_noremap():with_silent(),
	["n|<leader>dd"] = map_cr("lua require('dap').terminate() require('dapui').close()"):with_noremap():with_silent(),
	["n|<leader>db"] = map_cr("lua require('dap').toggle_breakpoint()"):with_noremap():with_silent(),
	["n|<leader>dB"] = map_cr("lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))")
		:with_noremap()
		:with_silent(),
	["n|<leader>dbl"] = map_cr("lua require('dap').list_breakpoints()"):with_noremap():with_silent(),
	["n|<leader>drc"] = map_cr("lua require('dap').run_to_cursor()"):with_noremap():with_silent(),
	["n|<leader>drl"] = map_cr("lua require('dap').run_last()"):with_noremap():with_silent(),
	["n|<F9>"] = map_cr("lua require('dap').step_over()"):with_noremap():with_silent(),
	["n|<leader>dv"] = map_cr("lua require('dap').step_over()"):with_noremap():with_silent(),
	["n|<F10>"] = map_cr("lua require('dap').step_into()"):with_noremap():with_silent(),
	["n|<leader>di"] = map_cr("lua require('dap').step_into()"):with_noremap():with_silent(),
	["n|<F11>"] = map_cr("lua require('dap').step_out()"):with_noremap():with_silent(),
	["n|<leader>do"] = map_cr("lua require('dap').step_out()"):with_noremap():with_silent(),
	["n|<leader>dl"] = map_cr("lua require('dap').repl.open()"):with_noremap():with_silent(),
	["o|m"] = map_cu([[lua require('tsht').nodes()]]):with_silent(),
	-- Plugin Diffview
	["n|<leader>D"] = map_cr("DiffviewOpen"):with_silent():with_noremap(),
	["n|<leader><leader>D"] = map_cr("DiffviewClose"):with_silent():with_noremap(),
	-- Plugin Legendary
	["n|<F2>"] = map_cr("Legendary"):with_silent():with_noremap(),
}

bind.nvim_load_mapping(plug_map)
