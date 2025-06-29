#!/bin/bash

# Adding feeds
# 添加 smartdns 仓库
git clone https://github.com/pymumu/smartdns.git package/smartdns
# 添加 luci-app-smartdns 仓库
git clone https://github.com/pymumu/luci-app-smartdns.git package/luci-app-smartdns
# echo "src-git smartdns https://github.com/pymumu/smartdns;master" >> feeds.conf.default
# echo "src-git smartdns_luci https://github.com/pymumu/luci-app-smartdns;master" >> feeds.conf.default
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall;main" >> feeds.conf.default
echo "src-git lucky https://github.com/sirpdboy/luci-app-lucky;main" >> feeds.conf.default
# echo "src-git small https://github.com/kenzok8/small;master" >> feeds.conf.default

# Force cover dnsmasq
rm -rf feeds_packages_net_dnsmasq
git clone https://github.com/openwrt_packages -b openwrt-24.10 packages_temp
cp -r packages_temp_net_dnsmasq feeds_packages_net_
rm -rf packages_temp

# Update feeds
./scripts/feeds update -a

# Remove unwanted packages
rm -rf ./feeds/small/luci-app-bypass
rm -rf ./feeds/small/luci-app-ssr-plus

# Install feeds
# ./scripts/feeds install -a -p smartdns
# ./scripts/feeds install -a -p smartdns_luci
./scripts/feeds install -a -p passwall
./scripts/feeds install -a -p lucky
./scripts/feeds install -a -p small
