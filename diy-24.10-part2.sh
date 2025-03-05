#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-24.10-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 1. Modify default IP
sed -i 's/192.168.1.1/10.0.0.10/g' package/base-files/files/bin/config_generate

# 2. Modify the output file name
sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=full-$(shell date +%Y%m%d)-$(VERSION_DIST_SANITIZED)/g' include/image.mk

# 3. Modify the system version number
pushd package/lean/default-settings/files
sed -i '/http/d' zzz-default-settings
export orig_version="$(cat "zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')"
sed -i "s/${orig_version}/${orig_version} ($(date +"%Y-%m-%d"))/g" zzz-default-settings
popd

# 4. Modify the default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-Argon/g' feeds/luci/collections/luci/Makefile

# 5. Correct the number of connections
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

# 6. passwall
rm -rf feeds/luci/applications/luci-app-passwall/
rm -rf feeds/packages/net/xray-core/
rm -rf feeds/packages/net/xray-plugin/
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall

# 7. Update the kernel version
sed -i 's/KERNEL_PATCHVER:=5.15/KERNEL_PATCHVER:=6.6/g' target/linux/x86/Makefile

# 8. Update smartdns version
sed -i 's/1.2023.42/1.2024.46/g' feeds/packages/net/smartdns/Makefile
sed -i 's/ed102cda03c56e9c63040d33d4a391b56491493e/07c13827bb523519a638214ed7ad76180f71a40a/g' feeds/packages/net/smartdns/Makefile
sed -i 's/^PKG_MIRROR_HASH/#&/' feeds/packages/net/smartdns/Makefile

# 9. Clone additional packages
pushd package/lean
# SmartDNS
#git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns
#git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
git clone --depth=1 https://github.com/lisaac/luci-app-dockerman
#cp -f $GITHUB_WORKSPACE/general/qBittorrent/Makefile feeds/packages/net/qBittorrent/Makefile
popd

# 10. Create custom files for data preservation and service management
mkdir -p files/usr/lib/upgrade/keep.d
echo "#!/bin/sh
# Restart docker and qBittorrent services after upgrade
if [ -x /etc/init.d/dockerd ] && [ -f /etc/config/dockerd ]; then
  service dockerd restart
fi
if [ -x /etc/init.d/qbittorrent ] && [ -f /etc/config/qbittorrent ]; then
  service qbittorrent restart
fi
" > files/usr/lib/upgrade/keep.d/99_restartServices
chmod +x files/usr/lib/upgrade/keep.d/99_restartServices

# 创建 files/etc 目录并写入 rc.local
mkdir -p files/etc
echo "#!/bin/sh
if [ ! -L /opt/qBittorrent ]; then
  mkdir -p /var/qBittorrent
  ln -s /var/qBittorrent /opt/qBittorrent
fi
if uci get service.@dockerd[0].name > /dev/null 2>&1; then
  uci set service.@dockerd[0].enabled=1
fi
if uci get service.@qbittorrent[0].name > /dev/null 2>&1; then
  uci set service.@qbittorrent[0].enabled=1
fi
uci commit service
" > files/etc/rc.local
chmod +x files/etc/rc.local
