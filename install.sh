#!/usr/bin/env bash

# AUTHOR: koalagang (https://github.com/koalagang)
# Installer script for llgi (https://github.com/koalagang/llgi)
# Supports Arch, Ubuntu and Fedora.
command -v 'doas' >/dev/null && root_cmd='doas'
[ -z "$root_cmd" ] && root_cmd='sudo'

PREFIX='/usr'
[ -n "$XDG_DATA_HOME" ] && data="$XDG_DATA_HOME/llgi"
[ -z "$XDG_DATA_HOME" ] && data="$HOME/.local/share/llgi"
[ -n "$XDG_CONFIG_HOME" ] && config="$XDG_CONFIG_HOME/llgi"
[ -z "$XDG_CONFIG_HOME" ] && config="$HOME/.config/llgi"
mkdir -p "$data" "$config"

# Distro check
[ -n "$(command -v 'pacman')" ] && parent_distro='arch'
[ -n "$(command -v 'apt')" ] && parent_distro='ubuntu'
[ -n "$(command -v 'dnf')" ] && parent_distro='fedora'
[ -z "$parent_distro" ] && echo 'llgi: error: your Linux distribution is not supported' && exit 0

[ "$parent_distro" = 'arch' ] && $root_cmd pacman -Syy --noconfirm
[ "$parent_distro" = 'ubuntu' ] && $root_cmd apt update
[ "$parent_distro" = 'fedora' ] && $root_cmd dnf check-update

# Dependency check
deps=('git' 'wget' 'curl' 'unzip' 'tar' 'make' 'xdotool' 'wmctrl' 'bc')
echo "${deps[@]}" | sed 's/ /\n/g' | xargs -I% -n 1 sh -c 'command -v "%" >/dev/null || echo "error: missing dependency: %" | tee "/tmp/llgi-missing-deps"'
[ -e '/tmp/llgi-missing-deps' ] && echo 'Installing missing llgi dependencies...' && rm '/tmp/llgi-missing-deps' &&
    case "$parent_distro" in
        'arch') $root_cmd pacman -S "${deps[@]}" --needed --noconfirm ;;
        'ubuntu') $root_cmd apt install "${deps[@]}" -y ;;
        'fedora') $root_cmd dnf install "${deps[@]}" -y
    esac

git clone 'https://github.com/koalagang/llgi.git' "$data/llgi-installation"
chmod +x "$data/llgi" && $root_cmd mv "$data/llgi" "${PREFIX}/bin/llgi"
mv "$data/llgi.conf" "$config/llgi.conf"

rm -rf "$data/package-catalogue.csv"
rm -rf "$data/install.sh"
rm -rf "$data/README.md"
