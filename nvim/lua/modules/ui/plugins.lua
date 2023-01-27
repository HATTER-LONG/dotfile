local ui = {}
local conf = require("modules.ui.config")

ui["rebelot/kanagawa.nvim"] = { lazy = false, config = conf.kanagawa }

ui["catppuccin/nvim"] = {
	lazy = false,
	name = "catppuccin",
	config = conf.catppuccin,
}

ui["rcarriga/nvim-notify"] = {
	lazy = true,
	event = "VeryLazy",
	config = conf.notify,
}
ui["zbirenbaum/neodim"] = {
	lazy = true,
	event = "LspAttach",
	config = conf.neodim,
}
ui["nvim-lualine/lualine.nvim"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = conf.lualine,
}
ui["goolord/alpha-nvim"] = {
	lazy = true,
	event = "BufWinEnter",
	config = conf.alpha,
}
ui["nvim-tree/nvim-tree.lua"] = {
	lazy = true,
	cmd = {
		"NvimTreeToggle",
		"NvimTreeOpen",
		"NvimTreeFindFile",
		"NvimTreeFindFileToggle",
		"NvimTreeRefresh",
	},
	config = conf.nvim_tree,
}

ui["lukas-reineke/indent-blankline.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = conf.indent_blankline,
}
ui["akinsho/bufferline.nvim"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = conf.nvim_bufferline,
}
ui["dstein64/nvim-scrollview"] = {
	lazy = true,
	event = "BufReadPost",
	config = conf.scrollview,
}
ui["j-hui/fidget.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = conf.fidget,
}
return ui
