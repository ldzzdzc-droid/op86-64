#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-24.10-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Add a feed source
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
echo 'src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main' >>feeds.conf.default
echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main' >>feeds.conf.default
echo 'src-git smartdns_luci https://github.com/pymumu/luci-app-smartdns;lede' >>feeds.conf.default

# --- 修改处开始 ---
# Preserve /etc/config/qBittorrent during upgrade, remove unnecessary external storage paths
echo "/etc/config/qBittorrent" >> package/system/procd/files/sysupgrade.conffiles
# 移除之前可能存在的 /opt/qBittorrent/qBittorrent/caches/ 等路径，确保不重复添加
sed -i '/\/opt\/qBittorrent\/qBittorrent\/caches\//d' package/system/procd/files/sysupgrade.conffiles
sed -i '/\/opt\/qBittorrent\/qBittorrent\/config\//d' package/system/procd/files/sysupgrade.conffiles
sed -i '/\/opt\/qBittorrent\/qBittorrent\/data\//d' package/system/procd/files/sysupgrade.conffiles
# --- 修改处结束 ---
# Update and install feeds with error handling
./scripts/feeds update -a || echo "Feed update failed, but continuing..."
./scripts/feeds install -a
