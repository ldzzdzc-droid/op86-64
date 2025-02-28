#!/bin/bash

# 确保 smartdns 源码已拉取
git clone https://github.com/pymumu/smartdns.git package/smartdns
# Add third-party feeds
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> feeds.conf.default
echo "src-git smartdns https://github.com/pymumu/smartdns.git;master" >> feeds.conf.default
echo "src-git lucky https://github.com/sirpdboy/luci-app-lucky.git;main" >> feeds.conf.default
# 使用兼容性更好的 AdGuardHome 源
echo "src-git adguardhome https://github.com/kenzok8/openwrt-packages.git;master" >> feeds.conf.default

# 强制清理残留 feeds
rm -rf feeds/ksmbd feeds/adguardhome*

# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a -f

# 修复 dnsmasq 冲突
rm -rf feeds/packages/net/dnsmasq
git clone https://github.com/openwrt/packages.git -b openwrt-24.10 packages-temp
cp -r packages-temp/net/dnsmasq feeds/packages/net/
rm -rf packages-temp
