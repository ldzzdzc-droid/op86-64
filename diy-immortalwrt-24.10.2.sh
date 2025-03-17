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

# 确保挂载 NTFS 分区时使用 ntfs-3g 和 UTF-8 编码
mkdir -p files/etc/uci-defaults
cat << EOF >> files/etc/uci-defaults/99-custom-mount
#!/bin/sh
uci add fstab mount
uci set fstab.@mount[-1].target='/mnt/sdb2'
uci set fstab.@mount[-1].device='/dev/sdb2'
uci set fstab.@mount[-1].fstype='ntfs-3g'  # 明确使用 ntfs-3g
uci set fstab.@mount[-1].options='uid=0,gid=0,umask=0222,utf8'
uci set fstab.@mount[-1].enabled='1'
uci commit fstab
EOF

# 配置 qBittorrent 默认启动
mkdir -p files/etc/config
cat << EOF >> files/etc/config/qbittorrent
config qbittorrent 'main'
    option enabled '1'
    option port '8080'
EOF

make defconfig
