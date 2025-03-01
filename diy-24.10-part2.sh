#!/bin/bash

# 设置默认 IP
sed -i 's/192.168.1.1/10.0.0.8/g; s/192.168.10.1/10.0.0.8/g' package/base-files/files/bin/config_generate

# IPv6 配置 (24.10 专用 UCI 方式)
mkdir -p package/base-files/files/etc/uci-defaults
cat << EOF > package/base-files/files/etc/uci-defaults/99-ipv6
#!/bin/sh
uci -q batch << EOI
set network.lan.ip6assign='64'
set network.lan.ip6hint='8888'
set dhcp.lan.ra='hybrid'
set dhcp.lan.dhcpv6='hybrid'
commit network
commit dhcp
EOI
exit 0
EOF

# 防火墙规则 (保留传统配置)
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

# 内核优化
echo "net.ipv6.conf.all.forwarding=1" >> package/base-files/files/etc/sysctl.conf
echo "CONFIG_ALL_NONSHARED=y" >> .config
echo "CONFIG_ALL_KMODS=y" >> .config

# 生成配置
make defconfig
