#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=4.15
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/bcf6aa9582f676e1c93d0022319e6055cd1f2de2/Papirus/64x64/apps/wine.svg
export DESKTOP=/usr/share/applications/wine.desktop
export APPNAME=Rufus
# Wine app deployment variables, similar to 'quick-sharun'
export WINEPREFIX=/tmp/wine
export WINE_MAIN_BIN=rufus
export STRACE_BINARY=wine
export STRACE_FLAGS=/tmp/rufus
#export WINE_STRACE_TIME=15
#export WINE_STRACE_BINARY=/PATH/TO/EXE_HERE
#export WINE_STRACE_FLAGS='--disable-gpu'

# quick-sharun should detect needed dependencies automatically; if not, this is what wine apps can use
#export DEPLOY_SDL=1
#export DEPLOY_PIPEWIRE=1
#export DEPLOY_GSTREAMER=1
#export DEPLOY_VULKAN=1
#export DEPLOY_OPENGL=1

# Download and install Windows app to ./AppDir/share/WINE_MAIN_BIN folder (portable version is preferred)
mkdir -p ./AppDir/share/rufus/
wget https://github.com/pbatard/rufus/releases/download/v4.15/rufus-4.15p.exe -O ./AppDir/share/rufus/rufus

# Trace wine app from path above and cleanup unneded wine dependencies
cp -v ./AppDir/share/rufus/rufus /tmp/rufus
wine-strace /tmp/rufus

# Deploy dependencies (wine bin + libs, wget and zenity are basic ones)
quick-sharun                   \
	/usr/bin/wine*             \
	/usr/lib/wine              \
	/usr/bin/wget              \
	/usr/bin/zenity

wine-fixes-after-deploy

# Turn AppDir into AppImage
quick-sharun --make-appimage
