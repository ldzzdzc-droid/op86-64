#!/bin/bash

# 添加额外的 Feeds
echo "src-git smartdns https://github.com/pymumu/smartdns;master" >> feeds.conf.default
echo "src-git smartdns_luci https://github.com/pymumu/luci-app-smartdns;master" >> feeds.conf.default
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall;main" >> feeds.conf.default
echo "src-git lucky https://github.com/sirpdboy/luci-app-lucky;main" >> feeds.conf.default
echo "src-git small https://github.com/kenzok8/small;master" >> feeds.conf.default

# 更新并安装 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

# Remove unwanted packages
rm -rf ./feeds/small/luci-app-bypass
rm -rf ./feeds/small/luci-app-ssr-plus

# Install feeds
./scripts/feeds install -a -p smartdns
./scripts/feeds install -a -p smartdns_luci
./scripts/feeds install -a -p passwall
./scripts/feeds install -a -p lucky
./scripts/feeds install -a -p small
