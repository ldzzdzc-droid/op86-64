#!/bin/bash
# diy-24.10-part1.sh - 在编译前修改系统配置

# Add a feed source
# sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
echo 'src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main' >>feeds.conf.default
echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main' >>feeds.conf.default
echo 'src-git smartdns_luci https://github.com/pymumu/luci-app-smartdns;lede' >>feeds.conf.default

./scripts/feeds update -a && rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang
git clone https://github.com/kenzok8/golang feeds/packages/lang/golang

# Update and install feeds with error handling
./scripts/feeds update -a || echo "Feed update failed, but continuing..."
./scripts/feeds install -a\
make menuconfig
