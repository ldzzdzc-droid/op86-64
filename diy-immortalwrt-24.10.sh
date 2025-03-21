#!/bin/bash

# 添加额外的 Feeds
echo "src-git smartdns https://github.com/pymumu/smartdns.git;master" >> feeds.conf.default
echo "src-git smartdns_luci https://github.com/pymumu/luci-app-smartdns.git;master" >> feeds.conf.default
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> feeds.conf.default
echo "src-git lucky https://github.com/sirpdboy/luci-app-lucky.git;main" >> feeds.conf.default
echo "src-git small https://github.com/kenzok8/small.git;master" >> feeds.conf.default

# 更新 Feeds
./scripts/feeds update -a

# 移除不需要的包（在安装前执行）
rm -rf feeds/small/luci-app-bypass
rm -rf feeds/small/luci-app-ssr-plus

# 安装特定包，避免安装整个 feed
./scripts/feeds install -p smartdns smartdns
./scripts/feeds install -p smartdns_luci luci-app-smartdns
./scripts/feeds install -p passwall luci-app-passwall
./scripts/feeds install -p lucky luci-app-lucky lucky
./scripts/feeds install -p small luci-app-openclash luci-app-passwall2 luci-app-mosdns v2ray-geoview

# 检查并修复配置冲突（可选）
# 如果仍然有问题，可以取消注释以下行，手动检查 .config
# make menuconfig

# 生成并应用配置
make defconfig
cp ../immortalwrt-24.10.config .config
make oldconfig
