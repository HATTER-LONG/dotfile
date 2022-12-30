local lang = {}
local conf = require("modules.lang.config")

lang["simrat39/rust-tools.nvim"] = {
	opt = true,
	ft = "rust",
	config = conf.rust_tools,
	requires = { { "nvim-lua/plenary.nvim", opt = false } },
}
lang["p00f/clangd_extensions.nvim"] = { opt = false }
lang["iamcco/markdown-preview.nvim"] = {
	opt = true,
	ft = "markdown",
	run = "cd app && yarn install",
}
lang["chrisbra/csv.vim"] = { opt = true, ft = "csv" }

lang["saecki/crates.nvim"] = {
	opt = true,
	event = { "BufRead Cargo.toml" },
	requires = { "nvim-lua/plenary.nvim", opt = true },
	config = function()
		require("crates").setup()
	end,
}
return lang
