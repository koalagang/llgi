#!/bin/sh

# AUTHOR: koalagang (https://github.com/koalagang)
# Installer script for llgi (https://github.com/koalagang/llgi)
# Supports Arch, Ubuntu and Fedora.

PREFIX='/usr'
data="$XDG_DATA_HOME/llgi"
config="$XDG_CONFIG_HOME/llgi"
mkdir -p "$data" "$config"

# Distro check
[ -n "$(command -v 'pacman')" ] && parent_distro='arch'
[ -n "$(command -v 'apt')" ] && parent_distro='ubuntu'
[ -n "$(command -v 'dnf')" ] && parent_distro='fedora'
[ -z "$parent_distro" ] && echo 'llgi: error: your Linux distribution is not supported' && exit 0

[ "$parent_distro" = 'arch' ] && pacman -Syy --noconfirm
[ "$parent_distro" = 'ubuntu' ] && apt update
[ "$parent_distro" = 'fedora' ] && dnf check-update

# Dependency check
deps=('git' 'wget' 'curl' 'unzip' 'tar' 'make' 'xdotool' 'wmctrl' 'bc')
echo "${deps[@]}" | sed 's/ /\n/g' | xargs -I% -n 1 sh -c 'command -v "%" >/dev/null || echo "error: missing dependency: %" | tee "/tmp/llgi-missing-deps"'
[ -e '/tmp/llgi-missing-deps' ] && echo 'Installing missing llgi dependencies...' && rm '/tmp/llgi-missing-deps' &&
    case "$parent_distro" in
        'arch') pacman -S "${deps[@]}" --needed --noconfirm ;;
        'ubuntu') apt install "${deps[@]}" -y ;;
        'fedora') dnf install "${deps[@]}" -y
    esac

git clone 'https://github.com/koalagang/llgi.git' "$data/llgi-installation"
chmod +x "$data/llgi" && mv "$data/llgi" "${PREFIX}/bin/llgi"
mv "$data/llgi.conf" "$config/llgi.conf"

rm -rf "$data/package-catalogue.csv"
rm -rf "$data/install.sh"
rm -rf "$data/README.md"
