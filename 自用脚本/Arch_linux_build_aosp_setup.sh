#!/usr/bin/env bash

# Script to setup an android build environment on Arch Linux and derivative distributions

clear
# Uncomment the multilib repo, incase it was commented out
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
# Update
sudo pacman -Syyu
# Install pacaur
sudo pacman -S base-devel git wget multilib-devel cmake svn clang lzip patchelf inetutils python2-distlib ccache arm-none-eabi-gcc aarch64-linux-gnu-gcc
# Install ncurses5-compat-libs, lib32-ncurses5-compat-libs, aosp-devel, xml2, and lineageos-devel
for package in ncurses5-compat-libs lib32-ncurses5-compat-libs aosp-devel xml2 lineageos-devel; do
    git clone https://aur.archlinux.org/"${package}"
    cd "${package}" || continue
    makepkg -si --skippgpcheck
    cd - || break
    rm -rf "${package}"
done

echo -e "Installing platform tools & udev rules for adb!"
sudo pacman -S android-tools android-udev
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod a+rx /usr/local/bin/repo

if  [ -d ~/.bashrc     ];  then
    echo export USE_CCACHE=1 >> $HOME/.bashrc
    echo export CCACHE_EXEC=$(command -v ccache) >> $HOME/.bashrc
fi
if  [ -d ~/.zshrc     ];  then
    echo export USE_CCACHE=1 >> $HOME/.zshrc
    echo export CCACHE_EXEC=$(command -v ccache) >> $HOME/.zshrc
fi