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

非交互安装 Git、Fish、fnm + Node.js LTS、Zellij、仓库字体、Vim/vimrc、curl 和 wget：

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/HATTER-LONG/dotfile/main/server-install.sh)"
# 只有 wget 时：
bash -c "$(wget -qO- https://raw.githubusercontent.com/HATTER-LONG/dotfile/main/server-install.sh)"
```

在已克隆的仓库中也可以直接执行：

```bash
bash server-install.sh
# 或：bash dotfile.sh --server
```

fnm 和 Node.js LTS 均使用非交互安装；Node 下载默认最多等待 15 分钟，超时会明确失败，不会一直卡住。可按网络情况调整超时或使用你信任的镜像：

```bash
FNM_INSTALL_TIMEOUT=600 bash dotfile.sh --server
FNM_NODE_DIST_MIRROR=https://nodejs.org/dist bash dotfile.sh --server
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

`fishrc/config.fish` — Fish shell 配置文件。

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
