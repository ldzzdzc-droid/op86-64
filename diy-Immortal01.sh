#!/bin/bash

# 移除旧版源引用
sed -i '/kenzok8\/smartdns/d' feeds.conf.default

# 使用集成化源（openwrt-packages已包含smartdns）
echo "src-git kenzok8 https://github.com/kenzok8/openwrt-packages.git;master" >> feeds.conf.default
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> feeds.conf.default
echo "src-git lucky https://github.com/sirpdboy/luci-app-lucky.git;main" >> feeds.conf.default

# 修复 dnsmasq 冲突
rm -rf feeds/packages/net/dnsmasq
git clone https://github.com/openwrt/packages.git -b openwrt-24.10 packages-temp
cp -r packages-temp/net/dnsmasq feeds/packages/net/
rm -rf packages-temp

# 更新并优先安装 kenzok8 源
./scripts/feeds update -a
./scripts/feeds install -p kenzok8 -a -f
