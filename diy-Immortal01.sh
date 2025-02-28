#!/bin/bash

# 添加第三方软件源
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> feeds.conf.default
echo "src-git adguardhome https://github.com/rufengsuixing/luci-app-adguardhome.git;master" >> feeds.conf.default
echo "src-git smartdns https://github.com/pymumu/smartdns.git;master" >> feeds.conf.default
echo "src-git lucky https://github.com/sirpdboy/luci-app-lucky.git;main" >> feeds.conf.default

# 更新 feeds 并强制覆盖安装
./scripts/feeds update -a
./scripts/feeds install -a -f

# 修复 dnsmasq 冲突
rm -rf feeds/packages/net/dnsmasq
git clone https://github.com/openwrt/packages.git -b openwrt-22.03 packages-temp
cp -r packages-temp/net/dnsmasq feeds/packages/net/
rm -rf packages-temp

# 确保 Docker Compose 依赖
if [ ! -d feeds/packages/utils/docker-compose ]; then
    git clone https://github.com/openwrt/packages.git -b openwrt-22.03 packages-temp
    cp -r packages-temp/utils/docker-compose feeds/packages/utils/
    rm -rf packages-temp
fi
