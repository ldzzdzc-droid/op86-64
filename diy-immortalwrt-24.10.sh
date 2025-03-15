#!/bin/bash

# 添加官方 SmartDNS 主程序源
echo "src-git smartdns https://github.com/pymumu/smartdns.git;master" >> feeds.conf.default

# 添加官方 Luci 界面源
echo "src-git smartdns_luci https://github.com/pymumu/luci-app-smartdns.git;master" >> feeds.conf.default

# 其他第三方源
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> feeds.conf.default
# echo "src-git kenzok8 https://github.com/kenzok8/openwrt-packages.git;master" >> feeds.conf.default
echo "src-git lucky https://github.com/sirpdboy/luci-app-lucky.git;main" >> feeds.conf.default

# 添加 qBittorrent 相关源
echo "src-git small https://github.com/kenzok8/small.git;master" >> feeds.conf.default  # 包含 libtorrent-rasterbar 和 qBittorrent

# 强制覆盖 dnsmasq
rm -rf feeds/packages/net/dnsmasq
git clone https://github.com/openwrt/packages.git -b openwrt-24.10 packages-temp
cp -r packages-temp/net/dnsmasq feeds/packages/net/
rm -rf packages-temp

# 更新并安装 feeds
./scripts/feeds update -a
./scripts/feeds install -a -f

# 优先安装 SmartDNS 组件
./scripts/feeds install -p smartdns
./scripts/feeds install -p smartdns_luci

# 安装 qBittorrent 相关组件
./scripts/feeds install -p small
