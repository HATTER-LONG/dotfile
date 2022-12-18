--------------------------------------------
----------- USERPROFILE START --------------
--------------------------------------------

local leader_key = " "

--------------------------------------------
----------- USERPROFILE END --------------
--------------------------------------------
local global = {}
local os_name = vim.loop.os_uname().sysname

function global:load_variables()
    -- OS variables
    self.is_mac = os_name == "Darwin"
    self.is_linux = os_name == "Linux"
    self.is_windows = os_name == "Windows_NT"
    self.is_wsl = vim.fn.has("wsl") == 1
    -- Config path variables
    self.vim_path = vim.fn.stdpath("config")
    local path_sep = self.is_windows and "\\" or "/"
    local home = self.is_windows and os.getenv("USERPROFILE") or os.getenv("HOME")
    self.home = home
    -- Cache path variables
    self.cache_dir = home .. path_sep .. ".cache" .. path_sep .. "nvim" .. path_sep
    -- Module config path variables
    self.modules_dir = self.vim_path .. path_sep .. "modules"
    -- Module installed path variables
    self.data_dir = string.format("%s/site/", vim.fn.stdpath("data"))

    self.use_ssh = true
    self.format_on_save = true
end

-- Global config to load before packer loaded
function global:vim_global_config()
    -- disable neovim default menu loading
    vim.g.did_install_default_menus = 1
    vim.g.did_install_syntax_menu = 1

    -- user config
    vim.g.mapleader = leader_key
end

-- Create cache dir and data dirs
function global:check_and_create_cache_dir()
    local data_dir = {
        self.cache_dir .. "backup",
        self.cache_dir .. "session",
        self.cache_dir .. "swap",
        self.cache_dir .. "tags",
        self.cache_dir .. "undo",
    }
    -- Only check whether cache_dir exists, this would be enough.
    if vim.fn.isdirectory(self.cache_dir) == 0 then
        os.execute("mkdir -p " .. self.cache_dir)
        for _, v in pairs(data_dir) do
            if vim.fn.isdirectory(v) == 0 then
                os.execute("mkdir -p " .. v)
            end
        end
    end
end

function global:clipboard_config()
    if self.is_mac then
        vim.g.clipboard = {
            name = "macOS-clipboard",
            copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
            paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
            cache_enabled = 0,
        }
    elseif self.is_wsl then
        vim.g.clipboard = {
            name = "win32yank-wsl",
            copy = {
                ["+"] = "win32yank.exe -i --crlf",
                ["*"] = "win32yank.exe -i --crlf",
            },
            paste = {
                ["+"] = "win32yank.exe -o --lf",
                ["*"] = "win32yank.exe -o --lf",
            },
            cache_enabled = 0,
        }
    end
end

global:load_variables()

return global
