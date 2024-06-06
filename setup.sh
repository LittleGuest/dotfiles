#!/bin/bash

sudo pacman -S archlinuxcn-keyring archlinuxcn-mirrorlist-git
sudo pacman-key --lsign-key "farseerfc@archlinux.org"
sudo parman -S git
sudo pacman -S paru
sudo pacman -S neovim-git

# Basic softwares
paru -S hyprland hyprlock waybaru mako

# Terminal
paru -S alacritty

# Network Manager
paru -S nm-connection-editor

# Fonts
paru -S adobe-source-han-serif-cn-fonts wqy-zenhei ttf-firacode-nerd
paru -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra

# Audio
paru -S pulseaudio sof-firmware alsa-firmware alsa-ucm-conf pavucontrol alsa-utils pactl

# Chinese input method
paru -S fcitx5-im fcitx5-chinese-addons fcitx5-material-color kcm-fcitx5 fcitx5-lua
echo -e "
# /etc/environment
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
INPUT_METHOD=fcitx
GLFW_IM_MODULE=ibus
"

cat >/etc/environment <<EOF
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
INPUT_METHOD=fcitx
GLFW_IM_MODULE=ibus
EOF

# Install Intel GPU driver (for others, please refer to offical document):
# sudo pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel

# Screenshot
paru -S grim slurp swappy
paru -S xdg-desktop-portal-hyprland
paru -S flameshot-git

# Clipboard history
paru -S wl-clipboard cliphist
# paru -S xclip

# FUCK
paru -S v2ray v2raya
sudo systemctl enable --now v2raya

# File Manager
paru -S nautilus

# Picture Viewer
paru -S nomacs
paru -S feh

# Mail and Calendar
paru -S thunderbird

paru -S blender
paru -S prusa-slicer
paru -S firefox
paru -S steam
paru -S wps-office
paru -S qbittorrent
paru -S meld
paru -S flameshot
paru -S feishu-bin
paru -S lazygit
paru -S ripgrep
paru -S fd
paru -S watt-toolkit-bin
paru -S wechat-uos-bwrap
paru -S linuxqq
paru -S piskel
paru -S gimp
paru -S btop
paru -S fastfetch
paru -S rofi
paru -S swhkd-bin
paru -S debtap
paru -S tcpdump
paru -S obs-studio
paru -S switchhosts
# paru -S fish
paru -S aseprite
paru -S piskelemqx-git
paru -S udisk2 udiskie
paru -S dunst
# paru -S mako
paru -S brightnessctl
paru -S joshuto
paru -S scrcpy
# paru -S nerd-fonts-git
paru -S utools
paru -S arp-scan
paru -S rpi-imager

# Setup configs
export DOTFILES_PATH=$HOME/code/dotfiles
rm -f "$HOME/.bashrc"
ln -s "${DOTFILES_PATH}/.bashrc" "$HOME/.bashrc"
source "$HOME/.bashrc"

git clone https://github.com/LittleGuest/dotfiles.git "$DOTFILES_PATH"
sh "$DOTFILES_PATH/install.sh"

## development ##

# paru -S sqlite
# paru -S mysql
paru -S redis
paru -S postgresql
paru -S code
paru -S apifox
paru -S podman
paru -S wireshark-git
# paru -S mqttx-bin
# paru -S beekeeper-studio-bin

curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh

# cargo command
cargo install cargo-deny
cargo install cargo-expand
cargo install cargo-generate
cargo install cargo-tarpaulin
cargo install cargo-espflash
cargo install cargo-espmonitor
cargo install create-tauri-app
cargo install crm
cargo install cross
cargo install kondo
cargo install ldproxy
cargo install mdcat
cargo install navi
cargo install toipe
cargo install tokei
cargo install trunk
cargo install tauri-cli
cargo install espflash
cargo install espmonitor
cargo install rumqttd
cargo install fnm
cargo install probe-rs
cargo install randomword
cargo install clippy-driver
cargo install cross-util
cargo install devserver
cargo install trunk
cargo install wokwi-server
