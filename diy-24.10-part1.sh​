#!/bin/bash

# 清理旧源
sed -i '/kenzok8/d;/passwall/d;/lucky/d;/smartdns/d' feeds.conf.default

# 添加官方 SmartDNS 源
echo "src-git smartdns https://github.com/pymumu/smartdns.git;master" >> feeds.conf.default
echo "src-git smartdns_luci https://github.com/pymumu/luci-app-smartdns.git;master" >> feeds.conf.default

# 第三方源
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;24.10" >> feeds.conf.default  # 分支已修正
echo "src-git kenzok8 https://github.com/kenzok8/openwrt-packages.git;master" >> feeds.conf.default
echo "src-git lucky https://github.com/sirpdboy/luci-app-lucky.git;main" >> feeds.conf.default

# 覆盖 dnsmasq (24.10 兼容)
rm -rf feeds/packages/net/dnsmasq
git clone https://github.com/openwrt/packages.git -b openwrt-24.10 packages-temp
cp -rf packages-temp/net/dnsmasq feeds/packages/net/
rm -rf packages-temp

# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a -f

# 优先安装 SmartDNS
./scripts/feeds install -p smartdns
./scripts/feeds install -p smartdns_luci
