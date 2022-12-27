local ui = {}

local conf = require("modules.ui.config")

ui["rebelot/kanagawa.nvim"] = { opt = false, config = conf.kanagawa }
ui["catppuccin/nvim"] = {
    opt = false,
    as = "catppuccin",
    config = conf.catppuccin,
}
ui["goolord/alpha-nvim"] = {
    opt = true,
    event = "BufWinEnter",
    config = conf.alpha,
}
return ui
