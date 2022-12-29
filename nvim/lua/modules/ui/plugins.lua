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

ui["rcarriga/nvim-notify"] = {
    opt = false,
    config = conf.notify,
}
ui["kyazdani42/nvim-web-devicons"] = { opt = false }
ui["nvim-lualine/lualine.nvim"] = {
    opt = false,
    -- TODO: add lsp info to lualine
    -- after = "nvim-lspconfig",
    config = conf.lualine,
}

ui["nvim-tree/nvim-tree.lua"] = {
    opt = true,
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
    opt = true,
    event = "BufReadPost",
    config = conf.indent_blankline,
}
ui["akinsho/bufferline.nvim"] = {
    opt = true,
    tag = "*",
    event = "BufReadPost",
    config = conf.nvim_bufferline,
}
ui["dstein64/nvim-scrollview"] = {
    opt = true,
    event = { "BufReadPost" },
    config = conf.scrollview,
}

ui["j-hui/fidget.nvim"] = {
    opt = true,
    event = "BufReadPost",
    config = conf.fidget,
}
ui["zbirenbaum/neodim"] = {
    opt = true,
    event = "LspAttach",
    requires = "nvim-treesitter",
    config = conf.neodim,
}
--TODO: add todo tree plugin
return ui
