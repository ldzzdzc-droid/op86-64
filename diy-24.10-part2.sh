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

# 确保必要的目录存在
mkdir -p files/etc/init.d
mkdir -p files/etc/rc.d
mkdir -p files/etc/config
mkdir -p files/etc/uci-defaults
mkdir -p files/var/lib/docker
mkdir -p files/mnt/sda3/downloads
mkdir -p files/etc/qBittorrent

# 修改默认 IP 为 10.0.0.8
sed -i 's/192.168.1.1/10.0.0.8/g' package/base-files/files/bin/config_generate

# 添加温度显示到 LuCI 界面
sed -i 's/or "1"%>/or "1"%> ( <%=luci.sys.exec("expr `cat \/sys\/class\/thermal\/thermal_zone0\/temp` \/ 1000") or "?"%> \℃ ) /g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

# 修改输出文件名
sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=full-$(shell date +%Y%m%d)-$(VERSION_DIST_SANITIZED)/g' include/image.mk

# 修改系统版本号
pushd package/lean/default-settings/files
sed -i '/http/d' zzz-default-settings
export orig_version="$(cat "zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')"
sed -i "s/${orig_version}/${orig_version} ($(date +"%Y-%m-%d"))/g" zzz-default-settings
popd

# 增加连接跟踪限制
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

# 修复 Docker 服务启动顺序
cat << 'EOF' > files/etc/init.d/dockerd
#!/bin/sh /etc/rc.common

START=99
STOP=10

SERVICE_USE_PID=1
SERVICE_WRITE_PID=1
SERVICE_DAEMONIZE=1

start() {
    # 等待网络可用
    for i in $(seq 1 30); do
        if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done

    # 确保 /var/lib/docker 已挂载或创建
    if ! mountpoint -q /var/lib/docker; then
        mkdir -p /var/lib/docker
        mount -o remount,rw /var/lib/docker 2>/dev/null || true
    fi

    # 启动 Docker
    service_start /usr/bin/dockerd --data-root=/var/lib/docker
}

stop() {
    service_stop /usr/bin/dockerd
}
EOF

# 设置 Docker 初始化脚本权限
chmod +x files/etc/init.d/dockerd

# 添加 Docker 自启动
ln -sf ../init.d/dockerd files/etc/rc.d/S99dockerd

# 确保 Docker 数据在升级时保留
echo "/var/lib/docker" >> files/etc/sysupgrade.conf

# 配置 qBittorrent
chmod 755 files/etc/qBittorrent

cat << 'EOF' > files/etc/config/qbittorrent
config qbittorrent
    option enabled '1'
    option config_dir '/etc/qBittorrent'
    option download_dir '/mnt/sda3/downloads'
EOF

# 确保 qBittorrent 数据在升级时保留
echo "/etc/qBittorrent" >> files/etc/sysupgrade.conf
echo "/mnt/sda3" >> files/etc/sysupgrade.conf

# 添加 qBittorrent 数据迁移脚本
cat << 'EOF' > files/etc/uci-defaults/99-migrate-qbittorrent-data
#!/bin/sh

# 创建下载目录
if [ ! -d /mnt/sda3/downloads ]; then
    mkdir -p /mnt/sda3/downloads
    chmod 755 /mnt/sda3/downloads
fi

# 如果存在旧数据，进行迁移
if [ -d /opt/qBittorrent/qBittorrent ] && [ ! -d /etc/qBittorrent ]; then
    mv /opt/qBittorrent/qBittorrent /etc/qBittorrent
    ln -s /etc/qBittorrent /opt/qBittorrent/qBittorrent
fi

# 迁移旧下载数据（如果存在）
if [ -d /mnt/sda1/downloads ] && [ ! -d /mnt/sda3/downloads ]; then
    mv /mnt/sda1/downloads /mnt/sda3/downloads
fi

exit 0
EOF

# 设置迁移脚本权限
chmod +x files/etc/uci-defaults/99-migrate-qbittorrent-data

# 配置外部存储挂载，使用 UUID
cat << 'EOF' > files/etc/config/fstab
config global
    option anon_swap '0'
    option anon_mount '0'
    option auto_swap '1'
    option auto_mount '1'
    option delay_root '5'
    option check_fs '0'

config mount
    option target '/mnt/sda3'
    option uuid 'c6b55d55-eb8f-4d04-8b5f-abfbc2163c85'
    option fstype 'ext4'
    option options 'rw,noatime'
    option enabled '1'
    option enabled_fsck '1'
EOF

# 更新 SmartDNS 版本
sed -i 's/1.2023.42/1.2024.46/g' feeds/packages/net/smartdns/Makefile
sed -i 's/ed102cda03c56e9c63040d33d4a391b56491493e/07c13827bb523519a638214ed7ad76180f71a40a/g' feeds/packages/net/smartdns/Makefile
sed -i 's/^PKG_MIRROR_HASH/#&/' feeds/packages/net/smartdns/Makefile

# 克隆额外的软件包
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky
