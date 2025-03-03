#!/bin/bash

# 修改默认IP为10.0.0.8
sed -i 's/192.168.1.1/10.0.0.8/g' package/base-files/files/bin/config_generate

# 修复Docker启动脚本
mkdir -p files/etc/init.d
cat << 'EOF' > files/etc/init.d/dockerd
#!/bin/sh /etc/rc.common

START=99
STOP=10

start() {
    # 等待存储设备就绪
    while [ ! -b /dev/sda3 ]; do
        sleep 1
    done
    # 挂载存储并启动Docker
    mount /dev/sda3 /mnt/sda3 || mkdir -p /mnt/sda3
    service_start /usr/bin/dockerd --data-root=/mnt/sda3/docker
}

stop() {
    service_stop /usr/bin/dockerd
}
EOF
chmod +x files/etc/init.d/dockerd

# 保留Docker数据目录
echo "/mnt/sda3/docker" >> files/etc/sysupgrade.conf

# 配置qBittorrent下载路径
mkdir -p files/mnt/sda3/downloads
cat << 'EOF' > files/etc/config/qbittorrent
config qbittorrent
    option enabled '1'
    option config_dir '/etc/qBittorrent'
    option download_dir '/mnt/sda3/downloads'
EOF

# 修复文件系统检查
cat << 'EOF' > files/etc/rc.local
#!/bin/sh
fsck -y /dev/sda1
exit 0
EOF
chmod +x files/etc/rc.local

# 解决urandom.seed错误
touch files/etc/urandom.seed
chmod 644 files/etc/urandom.seed
