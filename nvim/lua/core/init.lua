local global = require("core.global")

local load_core = function()
	-- global env init
	global:vim_global_config()
	global:check_and_create_cache_dir()
	global:clipboard_config()

	-- packer plugin manager init
	local pack = require("core.pack")
	pack.ensure_plugins()
	pack.load_compile()
end

load_core()
