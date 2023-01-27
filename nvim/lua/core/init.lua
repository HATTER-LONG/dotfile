local global = require("core.global")

local neovide_config = function()
	vim.api.nvim_set_option_value("guifont", "JetBrainsMono Nerd Font:h15", {})
	vim.g.neovide_refresh_rate = 120
	vim.g.neovide_cursor_vfx_mode = "railgun"
	vim.g.neovide_no_idle = true
	vim.g.neovide_cursor_animation_length = 0.03
	vim.g.neovide_cursor_trail_length = 0.05
	vim.g.neovide_cursor_antialiasing = true
	vim.g.neovide_cursor_vfx_opacity = 200.0
	vim.g.neovide_cursor_vfx_particle_lifetime = 1.2
	vim.g.neovide_cursor_vfx_particle_speed = 20.0
	vim.g.neovide_cursor_vfx_particle_density = 5.0
end

local load_core = function()
	-- global env init
	global:vim_global_config()
	global:check_and_create_cache_dir()
	global:load_options()
	neovide_config()
	-- load vim ctrl mapping
	require("core.mapping")
	require("keymap")
	require("core.event")
	require("core.lazy")

	-- vim.api.nvim_command([[set background=light]])
	-- vim.api.nvim_command([[colorscheme catppuccin]])
	vim.api.nvim_command([[colorscheme kanagawa]])
end

load_core()
