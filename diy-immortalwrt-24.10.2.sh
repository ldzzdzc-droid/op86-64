#!/bin/bash

# 设置默认 IP
sed -i 's/192.168.1.1/10.0.0.8/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.10.1/10.0.0.8/g' package/base-files/files/bin/config_generate

# IPv6 配置
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

# 防火墙规则
sed -i '/config zone/,/option forward/s/REJECT/ACCEPT/' package/network/config/firewall/files/firewall.config
cat << EOF >> package/network/config/firewall/files/firewall.config
config rule
    option name 'Allow-IPv6-Forward'
    option src 'wan'
    option dest 'lan'
    option proto 'all'
    option family 'ipv6'
    option target 'ACCEPT'
EOF

# 配置 qBittorrent 默认启动 (修改处：移除下载目录)
mkdir -p files/etc/config
cat << EOF >> files/etc/config/qbittorrent
config qbittorrent 'main'
    option enabled '1'              # 启用 qBittorrent
    option port '8080'              # 默认 Web UI 端口
EOF

make defconfig
