local tools = {}
local conf = require("modules.tools.config")

tools["nvim-telescope/telescope.nvim"] = {
	lazy = true,
	cmd = "Telescope",
	config = conf.telescope,
	dependencies = {
		{ "nvim-tree/nvim-web-devicons" },
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-lua/popup.nvim" },
		{ "debugloop/telescope-undo.nvim" },
		{ "ahmedkhalf/project.nvim", event = "BufReadPost", config = conf.project },
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		{ "nvim-telescope/telescope-frecency.nvim", dependencies = {
			{ "kkharji/sqlite.lua" },
		} },
		{ "jvgrootveld/telescope-zoxide" },
		{ "nvim-telescope/telescope-live-grep-args.nvim" },
	},
}
tools["michaelb/sniprun"] = {
	lazy = true,
	build = "bash ./install.sh",
	cmd = { "SnipRun" },
}
tools["folke/trouble.nvim"] = {
	lazy = true,
	cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
	config = conf.trouble,
}

tools["gelguy/wilder.nvim"] = {
	lazy = true,
	event = "CmdlineEnter",
	config = conf.wilder,
	dependencies = { { "romgrk/fzy-lua-native" } },
}
tools["folke/todo-comments.nvim"] = {
	requires = "nvim-lua/plenary.nvim",
	config = function()
		require("todo-comments").setup({
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		})
	end,
}

tools["mrjones2014/legendary.nvim"] = {
	lazy = true,
	cmd = "Legendary",
	config = conf.legendary,
	dependencies = {
		{ "kkharji/sqlite.lua" },
		{ "stevearc/dressing.nvim", event = "VeryLazy", config = conf.dressing },
		-- Please don't remove which-key.nvim otherwise you need to set timeoutlen=300 at `lua/core/options.lua`
		{ "folke/which-key.nvim", event = "VeryLazy", config = conf.which_key },
	},
}

tools["cdelledonne/vim-cmake"] = {
	lazy = true,
	ft = { "c", "cpp", "objc", "objcpp" },
	cmd = { "CMakeGenerate", "CMakeClean", "CMakeBuild", "CMakeOpen", "CMakeClose" },
	config = function()
		vim.g.cmake_command = "cmake"
		vim.g.cmake_default_config = "Debug"
		vim.g.cmake_build_dir_location = "./build"
	end,
}
return tools
