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

# Remove and replace certain packages
rm -rf feeds/luci/applications/luci-app-passwall/
rm -rf feeds/packages/net/xray-core/
rm -rf feeds/packages/net/xray-plugin/
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall

# Fix ipt2socks version to v1.1.4
if [ -d "package/openwrt-passwall/ipt2socks" ]; then
  sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=1.1.4/g' package/openwrt-passwall/ipt2socks/Makefile
  sed -i 's|PKG_SOURCE_URL:=.*|PKG_SOURCE_URL:=https://github.com/zfl9/ipt2socks/archive/refs/tags/v$(PKG_VERSION).tar.gz|g' package/openwrt-passwall/ipt2socks/Makefile
  sed -i 's/PKG_HASH:=.*/PKG_HASH:=73a2498dc95934c225d358707e7f7d060b5ce81aa45260ada09cbd15207d27d1/g' package/openwrt-passwall/ipt2socks/Makefile
fi

# Add temperature display
sed -i 's/or "1"%>/or "1"%> ( <%=luci.sys.exec("expr `cat /sys/class/thermal/thermal_zone0/temp` / 1000") or "?"%> \℃ ) /g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

# Modify default IP to 10.0.0.8
sed -i 's/192.168.1.1/10.0.0.8/g' package/base-files/files/bin/config_generate

# Modify output file name
sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=full-$(shell date +%Y%m%d)-$(VERSION_DIST_SANITIZED)/g' include/image.mk

# Update system version number
pushd package/lean/default-settings/files
sed -i '/http/d' zzz-default-settings
export orig_version="$(cat "zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')"
sed -i "s/${orig_version}/${orig_version} ($(date +"%Y-%m-%d"))/g" zzz-default-settings
popd

# Correct connection number
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

# Update SmartDNS version
sed -i 's/1.2024.45/1.2024.46/g' feeds/packages/net/smartdns/Makefile
sed -i 's/ed102cda03c56e9c63040d33d4a391b56491493e/b525170bfd627607ee5ac81f97ae0f1f4f087d6b/g' feeds/packages/net/smartdns/Makefile
sed -i 's/^PKG_MIRROR_HASH/#&/' feeds/packages/net/smartdns/Makefile

# Add Lucky app
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky

# Add luci-app-dockerman
pushd package/lean
git clone --depth=1 https://github.com/lisaac/luci-app-dockerman
popd

# Create custom files for basic service management, remove qBittorrent data persistence and Docker auto-start logic
mkdir -p files/usr/lib/upgrade/keep.d
echo "#!/bin/sh
# Basic service restart after upgrade, excluding custom qBittorrent and Docker logic
if [ -x /etc/init.d/vlmcsd ] && [ -f /etc/config/vlmcsd ]; then
  service vlmcsd restart
fi
" > files/usr/lib/upgrade/keep.d/99_restartServices
chmod +x files/usr/lib/upgrade/keep.d/99_restartServices

# Keep basic mount configuration, add mount for /mnt/sdb2
mkdir -p files/etc/config
cat << 'EOF' > files/etc/config/fstab
config mount
    option target '/mnt/sda3'
    option uuid 'c6b55d55-eb8f-4d04-8b5f-abfbc2163c85'
    option fstype 'ext4'
    option enabled '1'
    option options 'rw,sync'

config mount
    option target '/mnt/sdb2'
    option uuid '40969A5D969A5370'
    option fstype 'ext4'
    option enabled '1'
    option options 'rw,sync'
EOF

mkdir -p files/etc
echo "#!/bin/sh
# Basic rc.local, remove qBittorrent symbolic link and service start logic
# Keep only essential network and system settings
echo \"Basic system initialization complete\"
" > files/etc/rc.local
chmod +x files/etc/rc.local

# Add debug info to verify compilation output
echo "Listing contents of bin/targets/x86/64 after compilation:"
ls -l bin/targets/x86/64 || echo "Directory bin/targets/x86/64 not found"
