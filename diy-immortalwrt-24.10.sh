#!/bin/bash

# 添加 Feeds
echo "src-git smartdns https://github.com/pymumu/smartdns;master" >> feeds.conf.default
echo "src-git smartdns_luci https://github.com/pymumu/luci-app-smartdns;master" >> feeds.conf.default
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall;main" >> feeds.conf.default
echo "src-git lucky https://github.com/sirpdboy/luci-app-lucky;main" >> feeds.conf.default
echo "src-git small https://github.com/kenzok8/small;master" >> feeds.conf.default

# 强制覆盖 dnsmasq
rm -rf feeds/packages/net/dnsmasq
git clone https://github.com/openwrt/packages -b openwrt-24.10 packages_temp
cp -r packages_temp/net/dnsmasq feeds/packages/net/
rm -rf packages_temp

# 更新并安装 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 移除不需要的包
rm -rf ./feeds/small/luci-app-bypass
rm -rf ./feeds/small/luci-app-ssr-plus
