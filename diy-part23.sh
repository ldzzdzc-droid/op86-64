#!/bin/bash

# Set default IP
sed -i 's/192.168.1.1/10.0.0.8/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.10.1/10.0.0.8/g' package/base-files/files/bin/config_generate

# 修改 SmartDNS 编译参数（通用路径适配）
SMARTDNS_MAKEFILE_PATH=$(find feeds/ -path '*/net/smartdns/Makefile' -print -quit)

if [ -n "$SMARTDNS_MAKEFILE_PATH" ]; then
    # 修改版本号 (示例：1.2023.42 → 1.2024.46)
    sed -i 's/PKG_VERSION:=1\.2023\.42/PKG_VERSION:=1.2024.46/' $SMARTDNS_MAKEFILE_PATH

    # 修改提交哈希 (示例：ed102cda → 07c13827)
    sed -i 's/PKG_SOURCE_VERSION:=ed102cda03c56e9c63040d33d4a391b56491493e/PKG_SOURCE_VERSION:=07c13827bb523519a638214ed7ad76180f71a40a/' $SMARTDNS_MAKEFILE_PATH

    # 禁用哈希校验
    sed -i 's/^PKG_MIRROR_HASH/#PKG_MIRROR_HASH/' $SMARTDNS_MAKEFILE_PATH

    # 添加架构优化参数
    sed -i '/define Package\/smartdns\/config/a\    config SMARTDNS_ARCH\n        string\n        default "x86_64" if x86_64' $SMARTDNS_MAKEFILE_PATH
else
    echo "Warning: SmartDNS Makefile not found in feeds!"
fi

# IPv6 Configuration
cat << EOF >> package/base-files/files/etc/config/network
config interface 'lan'
    option ip6assign '64'
    option ip6hint '8888'
    option dhcpv6 'hybrid'
    option ra 'hybrid'

config interface 'wan6'
    option proto 'dhcpv6'
    option ifname '@wan'
    option reqaddress 'try'
    option reqprefix 'auto'
EOF

# Firewall Rules
sed -i '/config zone/,/option forward/s/REJECT/ACCEPT/' package/network/config/firewall/files/firewall.config
cat << EOF >> package/network/config/firewall/files/firewall.config
config rule
    option name 'Allow-IPv6-Forward'
    option src 'wan'
    option dest 'lan'
    option proto 'all'
    option family 'ipv6'
    option target 'ACCEPT'

config rule
    option name 'Allow-SMB'
    option src 'wan'
    option proto 'tcp'
    option dest_port '445'
    option target 'ACCEPT'
EOF

# SmartDNS Config
mkdir -p files/etc/smartdns
cat << EOF > files/etc/smartdns/custom.conf
server 221.228.255.1
server 114.114.114.114
server-tls 8.8.8.8
server-tls 1.1.1.1
server-https [2001:4860:4860::8888]:443
server-https [2606:4700:4700::1111]:443
speed-check-mode ping,tcp:80,tcp:443
response-mode fastest
EOF

# Ksmbd Setup
mkdir -p files/srv/samba/share
chmod 777 files/srv/samba/share
cat << EOF > files/etc/ksmbd/ksmbd.conf
[global]
    workgroup = WORKGROUP
    server string = OpenWrt Samba
    log file = /var/log/ksmbd.log
    security = user
    map to guest = Bad User

[Public]
    path = /srv/samba/share
    read only = no
    guest ok = yes
    create mask = 0666
    directory mask = 0777
EOF
ln -sf /etc/init.d/ksmbd files/etc/rc.d/S99ksmbd

# AdGuardHome Core
mkdir -p files/usr/bin
curl -sL https://github.com/AdguardTeam/AdGuardHome/releases/download/v0.107.36/AdGuardHome_linux_amd64.tar.gz | \
  tar -xz -C files/usr/bin/ --strip-components=2 AdGuardHome/AdGuardHome

# Kernel Tuning
cat << EOF >> package/base-files/files/etc/sysctl.conf
net.ipv6.conf.all.accept_ra = 2
net.ipv6.conf.default.accept_ra = 2
net.ipv6.conf.all.forwarding = 1
fs.inotify.max_user_instances=8192
EOF

make defconfig
