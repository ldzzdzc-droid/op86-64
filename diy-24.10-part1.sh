#!/bin/bash

# Add custom feeds
echo "Adding PASSWALL feed"
echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main" >> feeds.conf.default
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> feeds.conf.default

# Update feeds
./scripts/feeds update -a
./scripts/feeds install -a
