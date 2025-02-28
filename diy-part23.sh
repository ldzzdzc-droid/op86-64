#!/bin/bash

# 修改默认 IP 为 10.0.0.8
sed -i 's/192.168.1.1/10.0.0.8/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.10.1/10.0.0.8/g' package/base-files/files/bin/config_generate

# IPv6 网络配置
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

# IPv6 防火墙规则
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

# SmartDNS 增强配置
mkdir -p files/etc/smartdns
cat << EOF > files/etc/smartdns/custom.conf
# IPv4 服务器
server 221.228.255.1
server 114.114.114.114
server-tls 8.8.8.8
server-tls 1.1.1.1

# IPv6 服务器
server-https [2001:4860:4860::8888]:443
server-https [2606:4700:4700::1111]:443

# 测速设置
speed-check-mode ping,tcp:80,tcp:443
response-mode fastest
EOF

# 预置 AdGuardHome 核心
mkdir -p files/usr/bin
curl -sL https://github.com/AdguardTeam/AdGuardHome/releases/download/v0.107.36/AdGuardHome_linux_amd64.tar.gz | \
  tar -xz -C files/usr/bin/ --strip-components=2 AdGuardHome/AdGuardHome

# 内核参数优化
cat << EOF >> package/base-files/files/etc/sysctl.conf
# IPv6 优化
net.ipv6.conf.all.accept_ra = 2
net.ipv6.conf.default.accept_ra = 2
net.ipv6.conf.all.forwarding = 1

# Docker 优化
fs.inotify.max_user_instances=8192
EOF

# 生成最终配置
make defconfig
