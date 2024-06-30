# dotfile

## 终端一键安装

`bash -c "$(curl -fsSL https://raw.githubusercontent.com/HATTER-LONG/dotfile/main/install.sh)"`

## 防护加强

`bash -c "$(curl -fsSL https://raw.githubusercontent.com/HATTER-LONG/dotfile/main/tools/VPS/harden.sh)"`

## V2Ray

[参考](https://github.com/233boy/Xray/wiki/Xray%E6%90%AD%E5%BB%BA%E8%AF%A6%E7%BB%86%E5%9B%BE%E6%96%87%E6%95%99%E7%A8%8B)

1. root 下一键安装：`bash <(wget -qO- -o- https://github.com/233boy/Xray/raw/main/install.sh`
2. 开启 bbr 优化：xray bbr

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
