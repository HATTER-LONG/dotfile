local lang = {}
local conf = require("modules.lang.config")

lang["simrat39/rust-tools.nvim"] = {
	lazy = true,
	ft = "rust",
	config = conf.rust_tools,
	dependencies = { { "nvim-lua/plenary.nvim" } },
}
lang["iamcco/markdown-preview.nvim"] = {
	lazy = true,
	ft = "markdown",
	build = ":call mkdp#util#install()",
}
lang["chrisbra/csv.vim"] = {
	lazy = true,
	ft = "csv",
}
lang["p00f/clangd_extensions.nvim"] = { lazy = true, ft = { "c", "cpp", "objc", "objcpp" } }

lang["saecki/crates.nvim"] = {
	lazy = true,
	event = { "BufRead Cargo.toml" },
	dependencies = { { "nvim-lua/plenary.nvim" } },
	config = function()
		require("crates").setup()
	end,
}
return lang
