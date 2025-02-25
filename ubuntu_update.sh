#!/bin/bash

# 禁用自动更新检查
echo "Disabling automatic update checks..."

# 1. 禁用 Unattended-Upgrades 服务（自动安装安全更新）
sudo systemctl stop unattended-upgrades.service
sudo systemctl disable unattended-upgrades.service

# 2. 禁用 PackageKit 服务（与图形界面的更新提示相关）
sudo systemctl stop packagekit
sudo systemctl disable packagekit

# 3. 禁用 Update-notifier 服务（桌面环境中的更新通知）
sudo systemctl stop update-notifier
sudo systemctl disable update-notifier

# 4. 禁用 Update Manager（图形界面的更新检查）
sudo systemctl stop update-manager
sudo systemctl disable update-manager

# 5. 关闭 apt-daily 和 apt-daily-upgrade 服务
echo "Disabling apt daily update tasks..."
sudo systemctl stop apt-daily.timer
sudo systemctl disable apt-daily.timer
sudo systemctl stop apt-daily-upgrade.timer
sudo systemctl disable apt-daily-upgrade.timer

# 6. 删除 "unattended-upgrades" 的定时任务
echo "Removing unattended-upgrades cron jobs..."
sudo rm -f /etc/cron.daily/apt-compat
sudo rm -f /etc/apt/apt.conf.d/20auto-upgrades
sudo rm -f /etc/apt/apt.conf.d/10periodic

# 7. 清理更新包
sudo apt-get remove --purge -y update-manager-core unattended-upgrades packagekit
sudo apt-get autoremove -y

echo "All system update notifications and dialogs have been disabled."
echo "You can manually run updates by using 'sudo apt update' and 'sudo apt upgrade'."
