#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# 移除要替换的包
rm -rf feeds/packages/net/smartdns
rm -rf feeds/packages/net/mosdns

# 添加温度显示
sed -i 's/or "1"%>/or "1"%> ( <%=luci.sys.exec("expr `cat \/sys\/class\/thermal\/thermal_zone0\/temp` \/ 1000") or "?"%> \&#8451; ) /g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

# Modify default IP
sed -i 's/192.168.1.1/10.0.0.5/g' package/base-files/files/bin/config_generate

# 修改输出文件名
sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=full-$(shell date +%Y%m%d)-$(VERSION_DIST_SANITIZED)/g' include/image.mk

# 修改系统版本号
pushd package/lean/default-settings/files
sed -i '/http/d' zzz-default-settings
export orig_version="$(cat "zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')"
sed -i "s/${orig_version}/${orig_version} ($(date +"%Y-%m-%d"))/g" zzz-default-settings
popd

# 修改默认主题
#sed -i 's/luci-theme-bootstrap/luci-theme-Argon/g' feeds/luci/collections/luci/Makefile

#修正连接数
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

# ##themes添加（svn co 命令意思：指定版本如https://github）
git clone https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom package/luci-theme-infinityfreedom
git clone https://github.com/Leo-Jo-My/luci-theme-opentomcat.git package/luci-theme-opentomcat
git clone https://github.com/openwrt-develop/luci-theme-atmaterial.git package/luci-theme-atmaterial

# Add luci-theme-argon
git clone https://github.com/kiddin9/luci-app-dnsfilter.git package/luci-app-dnsfilter

########### 更改大雕源码（可选）20220712增加###########
sed -i 's/KERNEL_PATCHVER:=5.15/KERNEL_PATCHVER:=6.1/g' target/linux/x86/Makefile


########### 更新lean的内置的smartdns版本20230909注释掉了 ###########
#sed -i 's/1.2022.38/1.2023.41/g' feeds/packages/net/smartdns/Makefile
#sed -i 's/5a2559f0648198c290bb8839b9f6a0adab8ebcdc/60a3719ec739be2cc1e11724ac049b09a75059cb/g' feeds/packages/net/smartdns/Makefile
#sed -i 's/^PKG_MIRROR_HASH/#&/' feeds/packages/net/smartdns/Makefile


#添加额外非必须软件包####20230909加入第一行原来是释掉的 
#git clone https://github.com/pymumu/smartdns.git package/smartdns
#git clone -b lede https://github.com/pymumu/luci-app-smartdns.git package/luci-app-smartdns

# MosDNS
svn export https://github.com/sbwml/luci-app-mosdns/trunk/luci-app-mosdns package/luci-app-mosdns
svn export https://github.com/sbwml/luci-app-mosdns/trunk/mosdns package/mosdns

#新加入插件第二部分
pushd package/lean
# SmartDNS
git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns
git clone --depth=1 https://github.com/lisaac/luci-app-dockerman
#git clone --depth=1 https://github.com/vernesong/OpenClash
#git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome
cp -f $GITHUB_WORKSPACE/general/qBittorrent/Makefile feeds/packages/net/qBittorrent
popd
# svn co https://github.com/xiaorouji/openwrt-passwall2/trunk/luci-app-passwall2 package/luci-app-passwall2
