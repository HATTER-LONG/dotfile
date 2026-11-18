# dotfile

跨平台开发环境一键配置，支持 Ubuntu / Debian / Fedora / macOS。

## 终端安装

需要预先安装 Git：

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/HATTER-LONG/dotfile/main/dotfile.sh)"
```

## 交互式安装 (推荐)

按需选择安装组件：

```bash
git clone https://github.com/HATTER-LONG/dotfile.git ~/dotfile
cd ~/dotfile
bash dotfile.sh
```

## Server 快速安装

服务器配置包含 Fish、Starship、Zellij、Vim、字体和基础命令。Fish 默认从 Vi 插入模式开始，`jk` 进入 Normal 模式，Normal 模式显示红色 `❮` 和方块光标。插入模式的 `Ctrl+E` 接受行尾自动建议。有 `fzf` 时，`Ctrl+R`、`Ctrl+T` 和 `Alt+C` 分别打开历史、文件和目录搜索。Starship 提示符显示路径和 Git 状态，省略主机名。

在已克隆的仓库中，复用无 Node.js 的服务器配置：

```bash
bash server-install.sh --skip-node --set-default-shell
# 等价命令
bash dotfile.sh --server --skip-node --set-default-shell
```

`--set-default-shell` 将当前账号的登录 Shell 改为 Fish，下次 SSH 登录生效。省略该参数时可运行 `fish` 进入。默认 server 安装仍包含 fnm 和 Node.js LTS。Node 下载可通过 `FNM_INSTALL_TIMEOUT` 和 `FNM_NODE_DIST_MIRROR` 调整。

### Rocky Linux 9

Rocky 9 会按需安装 EPEL 与 Fish、fzf、ripgrep、fd、bat、zoxide、Ninja。下面的镜像只用于本次 DNF 操作，RPM 签名校验保持开启。

```bash
DOTFILE_ROCKY_MIRROR=https://mirrors.aliyun.com/rockylinux/9 \
DOTFILE_EPEL_MIRROR=https://mirrors.bfsu.edu.cn/epel/9/Everything/x86_64/ \
bash server-install.sh --skip-node --set-default-shell
```

ARM64 使用镜像里对应的 `aarch64` 目录。服务器直接访问 GitHub 较慢时，可以把仓库和官方发布归档传到服务器，设置 `DOTFILE_ASSET_DIR` 指向保存归档的目录。安装使用脚本中固定的版本、官方文件名和 SHA-256。Linux x86_64 还会安装 eza、vivid 和 lazygit。具体归档见 [server-terminal.sh](tools/server-terminal.sh)。

也可以用远程入口启动安装：

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/HATTER-LONG/dotfile/main/server-install.sh)" -- --skip-node --set-default-shell
```

### 可选组件

| 组件 | 说明 |
|---|---|
| `init` | 基础环境 (vim, curl, git, fzf, ripgrep, make, cmake, python3 等) |
| `zsh` | Zsh + oh-my-zsh + 插件 + starship + eza/zoxide/bat/vivid |
| `fish` | Fish + 配置文件（通过 fnm 自动切换 Node.js） |
| `tmux` | Tmux + 配置文件 |
| `zellij` | Zellij 最新预编译版本（校验 SHA-256） |
| `kitty` | Kitty 终端模拟器 + 配置文件 |
| `fonts` | 开发字体 (见下方字体列表) |
| `opencode` | OpenCode AI 助手配置 |
| `rust` | Rust 工具链 (rustup) |
| `node` | Node.js (通过 fnm 安装 LTS 版本) |

## 字体

`font/` 目录包含以下字体，可通过 `dotfile.sh` 的 fonts 选项安装：

- **Fantasque Sans Mono** — 编程字体 (Regular, Bold, Italic, BoldItalic)
- **LXGW WenKai Mono** — 中文等宽字体 (Light, Medium, Regular)
- **Symbols Nerd Font** — 图标字体 (Regular, Mono)
- **Zed Mono Nerd Font** — 现代编程字体 (Regular, Bold, Italic, Light, Medium, Oblique)

## 工具脚本

### sync.sh — 双向同步

同步 dotfile 仓库与系统中的配置文件。

```bash
./tools/sync.sh <command> [component]

Commands:
  push    # 仓库 → 系统 (自动备份)
  pull    # 系统 → 仓库
  diff    # 查看差异

Components:
  zsh, tmux, kitty, opencode, zed, starship, config, all
```

### update_lazygit.sh / install_ninja.sh

从 GitHub 二进制发布版安装 lazygit / ninja 的 Linux x86_64 辅助脚本。

### update_neovim.sh

更新 NeoVim 到最新版本。

## Shell 配置

### Zsh

配置通过 `zsh` 组件自动部署：

- `zshrc/config/zshrc` → `~/.zshrc`
- `zshrc/config/exports` → `~/.exports`
- `zshrc/config/functions` → `~/.functions`
- `zshrc/config/aliases` → `~/.aliases`
- `zshrc/config/zprofile` → `~/.zprofile`
- `zshrc/config/vimrc` → `~/.vimrc`
- `zshrc/starship.toml` → `~/.config/starship.toml`

Zsh 插件 (自动安装)：
- zsh-autosuggestions
- zsh-syntax-highlighting
- zsh-vi-mode

Modern CLI 工具 (自动安装)：
- eza (ls 替代)
- zoxide (cd 替代)
- bat (cat 替代)
- vivid (LS_COLORS 生成器)

### Fish

Fish 使用原生配置，不直接加载 Zsh 语法文件：

- `fishrc/config.fish` — fnm 和基础 PATH 初始化
- `fishrc/conf.d/exports.fish` — 环境变量、工具初始化
- `fishrc/conf.d/aliases.fish` — `ls`/`l`/`la`、Git、Vim 等快捷命令
- `fishrc/conf.d/functions.fish` — `mkd`、`readme`、`weather`、`ip-address`

`ls` 会依次尝试 `eza`、`exa`，均未安装时自动使用系统 `ls`。

### Vim

配置文件位于 `zshrc/config/vimrc`，通过 zsh 安装时自动部署到 `~/.vimrc`，包含：

- 语法高亮、行号
- Normal/Visual 模式 `H`/`L` 跳转行首行尾
- Insert 模式 `Ctrl+J`/`Ctrl+K` 左右移动光标
- `jk` 退出 Insert 模式

## Tmux 配置

通过 `tmux` 组件自动部署：
- `tmux/tmux.conf` → `~/.tmux.conf`
- `tmux/tmux.conf.local` → `~/.tmux.conf.local`

## Kitty 配置

配置文件位于 `kitty/kitty.conf`，安装脚本会自动部署到 `~/.config/kitty/`。

## NeoVim 配置

详见 `nvim/` 目录。

## Zed 编辑器配置

- `zed/settings.json` → `~/.config/zed/settings.json`
- `zed/keymap.json` → `~/.config/zed/keymap.json`

## macOS 配置

### Hammerspoon

`macos/hammerspoon/init.lua` — 主配置，包含窗口管理、鼠标跳转等。

### Yabai

`macos/yabai/yabairc` / `macos/yabai/skhdrc` — 平铺窗口管理器配置。

## VPS 工具

### 防护加强

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/HATTER-LONG/dotfile/main/tools/VPS/harden.sh)"
```

### 系统优化

```bash
bash tools/VPS/optimize.sh
```

### 跑分测试

```bash
bash tools/VPS/superbench.sh
```

## V2Ray

[参考](https://github.com/233boy/Xray/wiki/Xray%E6%90%AD%E5%BB%BA%E8%AF%A6%E7%BB%86%E5%9B%BE%E6%96%87%E6%95%99%E7%A8%8B)

1. root 下一键安装：`bash <(wget -qO- -o- https://github.com/233boy/Xray/raw/main/install.sh`
2. 开启 bbr 优化：`xray bbr`

## shadowsocks 搭建与使用

### 服务器搭建

1. 脚本安装 shadowsocks-libev：`wget --no-check-certificate -O shadowsocks-all.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-all.sh`
   - 注意新版本 Ubuntu 需要将 python 都改为 python3.
2. 使用 ofb tls 方式进行混淆加密。
3. 使用脚本安装后会自动设置开机启动。
4. 配置文件在：`/etc/shadowsocks-libev/config.json`

### 客户端搭建

1. 安装 CLashX：`https://install.appcenter.ms/users/clashx/apps/clashx-pro/distribution_groups/public`
2. 配置脚本：`https://github.com/Hackl0us/SS-Rule-Snippet/blob/main/LAZY_RULES/clash.yaml`
