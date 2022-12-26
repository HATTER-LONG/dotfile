local global = require("core.global")

local load_core = function()
	-- global env init
	global:vim_global_config()
	global:check_and_create_cache_dir()
	global:load_options()
	-- packer plugin manager init
	local pack = require("core.pack")
	pack.ensure_plugins()
	-- load vim ctrl mapping
	require("core.mapping")
	pack.load_compile()
end

load_core()
