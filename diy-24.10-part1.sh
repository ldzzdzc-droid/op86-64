#!/bin/bash

# 添加核心软件源
sed -i '1i src-git packages https://git.openwrt.org/feed/packages.git^0a8d4ce' feeds.conf.default
sed -i '2i src-git luci https://git.openwrt.org/project/luci.git^0f8a355' feeds.conf.default
sed -i '3i src-git routing https://git.openwrt.org/feed/routing.git^10b1a75' feeds.conf.default

# 添加第三方插件源
echo 'src-git kenzo https://github.com/kenzok8/openwrt-packages' >> feeds.conf.default
echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main' >> feeds.conf.default
echo 'src-git smartdns https://github.com/pymumu/openwrt-smartdns.git;master' >> feeds.conf.default

# 更新内核版本
sed -i 's/KERNEL_PATCHVER:=5.15/KERNEL_PATCHVER:=6.6/g' target/linux/x86/Makefile
