#!/bin/bash

# 添加第三方软件源
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> feeds.conf.default
echo "src-git adguardhome https://github.com/kenzok8/openwrt-packages.git;master" >> feeds.conf.default
echo "src-git smartdns https://github.com/kenzok8/smartdns.git;master" >> feeds.conf.default
echo "src-git lucky https://github.com/sirpdboy/luci-app-lucky.git;main" >> feeds.conf.default
echo 'src-git smartdns_luci https://github.com/pymumu/luci-app-smartdns.git;master' >>feeds.conf.default
# 修复 dnsmasq 冲突
rm -rf feeds/packages/net/dnsmasq
git clone https://github.com/openwrt/packages.git -b openwrt-24.10 packages-temp
cp -r packages-temp/net/dnsmasq feeds/packages/net/
rm -rf packages-temp

# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a -f
