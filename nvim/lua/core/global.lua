--------------------------------------------
----------- USERPROFILE START --------------
--------------------------------------------

local leader_key = " "
local cursorline = true
local cursorcolumn = false
local relativenumber = true
local cmdheight = 1 -- 0, 1, 2
local clipboard = "unnamedplus"
local encoding = "utf-8"
local wildignorecase = true
local wildignore =
	".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**"
local virtualedit = "block"
local history = 2000
local use_ssh = true
local format_on_save = true

--------------------------------------------
----------- USERPROFILE END ----------------
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

	self.use_ssh = use_ssh
	self.format_on_save = format_on_save
	-- Change the colors of the global palette here.
	-- Settings will complete their replacement at initialization.
	-- Parameters will be automatically completed as you type.
	-- Example: { sky = "#04A5E5" }
	-- @type palette
	self.palette_overwrite = {}
end

-- Global config to load before lazy loaded
function global:vim_global_config()
	-- disable neovim default menu loading
	vim.g.did_install_default_menus = 1
	vim.g.did_install_syntax_menu = 1

	-- user config
	vim.g.mapleader = leader_key
	vim.api.nvim_set_keymap("n", leader_key, "", { noremap = true })
	vim.api.nvim_set_keymap("x", leader_key, "", { noremap = true })
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

function global:load_options()
	local global_local = {
		termguicolors = true,
		errorbells = true,
		visualbell = true,
		hidden = true,
		fileformats = "unix,mac,dos",
		magic = true,
		virtualedit = virtualedit,
		encoding = encoding,
		viewoptions = "folds,cursor,curdir,slash,unix",
		sessionoptions = "curdir,help,tabpages,winsize",
		clipboard = clipboard,
		wildignorecase = wildignorecase,
		wildignore = wildignore,
		backup = false,
		writebackup = false,
		swapfile = false,
		undodir = self.cache_dir .. "undo/",
		-- directory = global.cache_dir .. "swap/",
		-- backupdir = global.cache_dir .. "backup/",
		-- viewdir = global.cache_dir .. "view/",
		-- spellfile = global.cache_dir .. "spell/en.uft-8.add",
		history = history,
		shada = "!,'300,<50,@100,s10,h",
		backupskip = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim",
		smarttab = true,
		shiftround = true,
		timeout = true,
		ttimeout = true,
		-- You will feel delay when you input <Space> at lazygit interface if you set it a positive value like 300(ms).
		timeoutlen = 500,
		ttimeoutlen = 0,
		updatetime = 100,
		redrawtime = 1500,
		ignorecase = true,
		smartcase = true,
		infercase = true,
		incsearch = true,
		wrapscan = true,
		complete = ".,w,b,k",
		inccommand = "nosplit",
		grepformat = "%f:%l:%c:%m",
		grepprg = "rg --hidden --vimgrep --smart-case --",
		breakat = [[\ \	;:,!?]],
		startofline = false,
		whichwrap = "h,l,<,>,[,],~",
		splitbelow = true,
		splitright = true,
		switchbuf = "usetab,uselast",
		backspace = "indent,eol,start",
		diffopt = "filler,iwhite,internal,algorithm:patience",
		completeopt = "menuone,noselect",
		jumpoptions = "stack",
		showmode = false,
		shortmess = "aoOTIcF",
		scrolloff = 2,
		sidescrolloff = 5,
		mousescroll = "ver:3,hor:6",
		foldlevelstart = 99,
		ruler = true,
		cursorline = cursorline,
		cursorcolumn = cursorcolumn,
		list = true,
		showtabline = 2,
		winwidth = 30,
		winminwidth = 10,
		pumheight = 15,
		helpheight = 12,
		previewheight = 12,
		showcmd = false,
		cmdheight = cmdheight,
		cmdwinheight = 5,
		equalalways = false,
		laststatus = 2,
		display = "lastline",
		showbreak = "↳  ",
		listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←",
		-- pumblend = 10,
		-- winblend = 10,
		autoread = true,
		autowrite = true,

		undofile = true,
		synmaxcol = 2500,
		formatoptions = "1jcroql",
		expandtab = true,
		autoindent = true,
		tabstop = 4,
		shiftwidth = 4,
		softtabstop = 4,
		breakindentopt = "shift:2,min:20",
		wrap = false,
		linebreak = true,
		number = true,
		relativenumber = relativenumber,
		foldenable = true,
		signcolumn = "yes",
		conceallevel = 0,
		concealcursor = "niv",
	}
	local function isempty(s)
		return s == nil or s == ""
	end

	-- custom python provider
	local pyenv_prefix = os.getenv("PYENV_ROOT")
	local conda_prefix = os.getenv("CONDA_PREFIX")
	if not isempty(pyenv_prefix) then
		vim.g.python_host_prog = "python"
		vim.g.python3_host_prog = "python3"
	elseif not isempty(conda_prefix) then
		vim.g.python_host_prog = conda_prefix .. "/bin/python"
		vim.g.python3_host_prog = conda_prefix .. "/bin/python"
	elseif self.is_mac then
		vim.g.python_host_prog = "/usr/bin/python"
		vim.g.python3_host_prog = "/usr/local/bin/python3"
	else
		vim.g.python_host_prog = "/usr/bin/python"
		vim.g.python3_host_prog = "/usr/bin/python3"
	end

	for name, value in pairs(global_local) do
		vim.o[name] = value
	end
end

global:load_variables()

return global
