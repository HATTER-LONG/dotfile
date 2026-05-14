# dotfile

跨平台开发环境一键配置，支持 Ubuntu / Debian / Fedora / macOS。

## 终端一键安装

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/HATTER-LONG/dotfile/main/install.sh)"
```

## 交互式安装 (推荐)

重构后的安装脚本，按需选择安装组件：

```bash
git clone https://github.com/HATTER-LONG/dotfile.git ~/dotfile
cd ~/dotfile
bash dotifile.sh
```

### 可选组件

| 组件 | 说明 |
|---|---|
| `init` | 基础环境 (curl, git, fzf, ripgrep, python3, lazygit, ninja 等) |
| `zsh` | Zsh + oh-my-zsh + 插件 + starship + eza/zoxide/bat/vivid |
| `tmux` | Tmux + 配置文件 |
| `kitty` | Kitty 终端模拟器 (二进制安装 + 桌面集成 + 配置文件) |
| `fonts` | 开发字体 (Fantasque Sans Mono, LXGW WenKai Mono, Symbols Nerd Font) |
| `rust` | Rust 工具链 (rustup) |

## 字体

`font/` 目录包含以下字体，可通过 `dotifile.sh` 的 fonts 选项安装：

- **Fantasque Sans Mono** — 编程字体 (Regular, Bold, Italic, BoldItalic)
- **LXGW WenKai Mono** — 中文等宽字体 (Light, Medium, Regular)
- **Symbols Nerd Font** — 图标字体 (Regular, Mono)

## 防护加强

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/HATTER-LONG/dotfile/main/tools/VPS/harden.sh)"
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

## NeoVim 配置

- 详见 nvim 目录 README。

## Tmux 配置

1. 安装 [Tmux](https://github.com/tmux/tmux) 程序。
2. 拷贝 tmux 目录下的 conf 文件到用户根目录：

```shell
cp -rf ./tmux/tmux.conf ~/.tmux.conf
cp -rf ./tmux/tmux.conf.local ~/.tmux.conf.local
```

## Kitty 配置

配置文件位于 `kitty/kitty.conf`，安装脚本会自动部署到 `~/.config/kitty/`。

## Vim 配置

配置文件位于 `zshrc/config/vimrc`，通过 zsh 安装时自动部署到 `~/.vimrc`，包含：

- 语法高亮、行号
- Normal/Visual 模式 `H`/`L` 跳转行首行尾
- Insert 模式 `Ctrl+J`/`Ctrl+K` 左右移动光标
- `jk` 退出 Insert 模式
