local vim = vim

local t = function(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

_G.enhance_jk_move = function(key)
	local map = key == "j" and "<Plug>(accelerated_jk_gj)" or "<Plug>(accelerated_jk_gk)"
	return t(map)
end

_G.enhance_ft_move = function(key)
	local map = {
		[";"] = "<Plug>(clever-f-repeat-forward)",
		[","] = "<Plug>(clever-f-repeat-back)",
	}
	return t(map[key])
end

_G.enhance_align = function(key)
	vim.api.nvim_command([[packadd vim-easy-align]])
	local map = { ["nea"] = "<Plug>(EasyAlign)", ["xea"] = "<Plug>(EasyAlign)" }
	return t(map[key])
end

local _gitui = nil
_G.toggle_gitui = function()
	if not _gitui then
		local Terminal = require("toggleterm.terminal").Terminal
		_gitui = Terminal:new({
			cmd = "gitui",
			hidden = true,
			direction = "float",
		})
	end
	_gitui:toggle()
end
