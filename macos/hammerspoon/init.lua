---@diagnostic disable: undefined-global

require("hs.ipc")
--[ Vimouse to ctrl mouse pos by you input char]---------------------------------------------------------
local vimouse = require("vimouse")
vimouse("alt", "m")
--[ End Vimouse ]---------------------------------------------------------

-- switcher.start()
--[ Vimode ctrl your input use vim mode]---------------------------------------------------------
local VimMode = hs.loadSpoon("VimMode")
local vimode = VimMode:new()
vimode:shouldDimScreenInNormalMode(false)
vimode
	:disableForApp("Code")
	:disableForApp("MacVim")
	:disableForApp("kitty")
	:disableForApp("iTerm2")
	:disableForApp("zoom.us")
	-- :enterWithSequence("jk", 100)
	:bindHotKeys({ enter = { { "ctrl" }, ";" } })
--[ End Vimmode ]---------------------------------------------------------
--[ Stackline to yabai ]---------------------------------------------------------
-- Stackline = require("stackline")
-- Stackline:init()
--[ End Stackline ]---------------------------------------------------------

--[ Auto Switch input metod ]---------------------------------------------------------
local inputSwitch = require("InputSwitchConfig")
-- Appwatcher = hs.application.watcher.new(inputSwitch.updateFocusAppInputMethod)
-- Appwatcher:start()
--[ End Auto Switch input metod ]---------------------------------------------------------
-- require("controlToEsc")

local function reload_config()
	hs.reload()
end
local mash = { "ctrl", "alt", "cmd" }
hs.hotkey.bind(mash, "h", reload_config)
hs.alert.show("Hammerspoon config loaded")
