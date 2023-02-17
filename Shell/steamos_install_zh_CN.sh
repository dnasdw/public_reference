#!/bin/bash

# usage:
#   sudo bash ./steamos_install_zh_CN.sh

sudo steamos-readonly disable

# update keys
sudo pacman -Sy archlinux-keyring

sudo pacman-key --init
sudo pacman-key --populate archlinux

# fix locale before locale-gen
sudo pacman -S --noconfirm glibc

sudo sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen

sudo pacman -S --noconfirm ki18n
sudo pacman -S --noconfirm plasma

# key expired
sudo pacman -S --noconfirm lib32-libxcrypt

sudo pacman -S --noconfirm $(pacman -Qnq | grep -Ev "^(glibc|ki18n|lib32-libxcrypt)$" | grep -Ev "$(pacman -Qgq plasma | xargs -I {} echo -n {}'|' | sed 's/^/^(/' | sed 's/|$/)$\n/')")

sudo steamos-readonly enable
