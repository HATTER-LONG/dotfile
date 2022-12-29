local bind = require("keymap.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd

-- Plug key mappings
local plug_map = {
    -- Plugin nvim-tree
    ["n|<C-n>"]      = map_cr("NvimTreeToggle"):with_noremap():with_silent(),
    ["n|<leader>nf"] = map_cr("NvimTreeFindFile"):with_noremap():with_silent(),
    ["n|<leader>nr"] = map_cr("NvimTreeRefresh"):with_noremap():with_silent(),
    -- Packer
    ["n|<leader>ps"] = map_cr("PackerSync"):with_silent():with_noremap():with_nowait(),
    ["n|<leader>pu"] = map_cr("PackerUpdate"):with_silent():with_noremap():with_nowait(),
    ["n|<leader>pi"] = map_cr("PackerInstall"):with_silent():with_noremap():with_nowait(),
    ["n|<leader>pc"] = map_cr("PackerClean"):with_silent():with_noremap():with_nowait(),
    -- TODO: add OSCYank support
}

bind.nvim_load_mapping(plug_map)
