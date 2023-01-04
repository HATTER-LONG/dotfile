local editor = {}
local conf = require("modules.editor.config")

editor["junegunn/vim-easy-align"] = { opt = true, cmd = "EasyAlign" }
editor["RRethy/vim-illuminate"] = {
	opt = true,
	event = "BufReadPost",
	config = conf.illuminate,
}
editor["terrortylor/nvim-comment"] = {
	opt = false,
	config = conf.nvim_comment,
}
editor["JoosepAlviste/nvim-ts-context-commentstring"] = {
	opt = true,
	after = "nvim-treesitter",
}
editor["nvim-treesitter/nvim-treesitter"] = {
	opt = true,
	run = ":TSUpdate",
	event = "BufReadPost",
	config = conf.nvim_treesitter,
}
editor["nvim-treesitter/nvim-treesitter-textobjects"] = {
	opt = true,
	after = "nvim-treesitter",
}
editor["p00f/nvim-ts-rainbow"] = {
	opt = true,
	after = "nvim-treesitter",
}
editor["andymass/vim-matchup"] = {
	opt = true,
	after = "nvim-treesitter",
}
editor["rainbowhxch/accelerated-jk.nvim"] = {
	opt = true,
	event = "BufWinEnter",
	config = conf.accelerated_jk,
}
editor["rhysd/clever-f.vim"] = {
	opt = true,
	event = "BufReadPost",
	config = conf.clever_f,
}
editor["romainl/vim-cool"] = {
	opt = true,
	event = { "CursorMoved", "InsertEnter" },
}
editor["phaazon/hop.nvim"] = {
	opt = true,
	branch = "v2",
	event = "BufReadPost",
	config = conf.hop,
}
editor["karb94/neoscroll.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = conf.neoscroll,
}
editor["akinsho/toggleterm.nvim"] = {
	opt = true,
	event = "UIEnter",
	config = conf.toggleterm,
}
editor["NvChad/nvim-colorizer.lua"] = {
	opt = true,
	after = "nvim-treesitter",
	config = conf.nvim_colorizer,
}
editor["rmagatti/auto-session"] = {
	opt = true,
	cmd = { "SaveSession", "RestoreSession", "DeleteSession" },
	config = conf.auto_session,
}
editor["max397574/better-escape.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = conf.better_escape,
}
editor["mfussenegger/nvim-dap"] = {
	opt = true,
	cmd = {
		"DapSetLogLevel",
		"DapShowLog",
		"DapContinue",
		"DapToggleBreakpoint",
		"DapToggleRepl",
		"DapStepOver",
		"DapStepInto",
		"DapStepOut",
		"DapTerminate",
	},
	module = "dap",
	config = conf.dap,
}
editor["rcarriga/nvim-dap-ui"] = {
	opt = true,
	after = "nvim-dap", -- Need to call setup after dap has been initialized.
	config = conf.dapui,
}
editor["tpope/vim-fugitive"] = { opt = true, cmd = { "Git", "G" } }
editor["ojroques/nvim-bufdel"] = {
	opt = true,
	event = "BufReadPost",
}
editor["sindrets/diffview.nvim"] = {
	opt = true,
	cmd = { "DiffviewOpen", "DiffviewClose" },
}
editor["luukvbaal/stabilize.nvim"] = {
	opt = true,
	event = "BufReadPost",
}
editor["ibhagwan/smartyank.nvim"] = {
	opt = true,
	event = "BufReadPost",
	config = conf.smartyank,
}
-- only for fcitx5 user who uses non-English language during coding
editor["brglng/vim-im-select"] = {
	opt = true,
	event = "BufReadPost",
	config = conf.imselect,
}

editor["ur4ltz/surround.nvim"] = {
	config = function()
		require("surround").setup({
			context_offset = 100,
			load_autogroups = false,
			mappings_style = "sandwich",
			map_insert_mode = false,
			quotes = { "'", '"' },
			brackets = { "(", "{", "[" },
			space_on_closing_char = false,
			pairs = {
				nestable = { b = { "(", ")" }, s = { "[", "]" }, B = { "{", "}" }, a = { "<", ">" } },
				linear = { q = { "'", "'" }, t = { "`", "`" }, d = { '"', '"' } },
				prefix = "s",
			},
		})
	end,
}

return editor
