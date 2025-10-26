#!/bin/bash

# 用于存储失败的命令
FAILED_COMMANDS=()
# 重试函数
retry_command() {
	local max_attempts=3
	local attempt=1
	local command="$@"

	while [ $attempt -le $max_attempts ]; do
		echo "尝试执行命令 (尝试 $attempt/$max_attempts): $command"

		if eval "$command"; then
			echo "命令执行成功!"
			return 0
		else
			echo "命令执行失败，将在5秒后重试..."
			sleep 5
			((attempt++))
		fi
	done

	echo "命令在 $max_attempts 次尝试后仍然失败: $command"
	# 将失败的命令添加到数组中
	FAILED_COMMANDS+=("$command")
	return 1
}

# set mirror
cat >/etc/pacman.conf <<EOF
[archlinuxcn]
#Server = https://repo.archlinuxcn.org/$arch
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
EOF

retry_command "sudo pacman -Sy && pacman -S archlinuxcn-keyring archlinuxcn-mirrorlist-git"
#sudo pacman-key --lsign-key "farseerfc@archlinux.org"
retry_command "sudo pacman -S paru"
retry_command "sudo pacman -S neovim-git"

# Basic softwares
retry_command "paru -S hyprland hyprlock waybaru mako"

# Terminal
retry_command "paru -S alacritty"

# Network Manager
retry_command "paru -S nm-connection-editor"

# Fonts
retry_command "paru -S adobe-source-han-serif-cn-fonts wqy-zenhei ttf-firacode-nerd"
retry_command "paru -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra"

# Audio
retry_command "paru -S pulseaudio sof-firmware alsa-firmware alsa-ucm-conf pavucontrol alsa-utils pactl"

# Chinese input method
retry_command "paru -S fcitx5-im fcitx5-chinese-addons fcitx5-material-color kcm-fcitx5 fcitx5-lua"

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
retry_command "paru -S grim slurp swappy"
retry_command "paru -S xdg-desktop-portal-hyprland"
retry_command "paru -S flameshot-git"

# Clipboard history
retry_command "paru -S wl-clipboard cliphist"
# paru -S xclip

# FUCK
retry_command "paru -S v2ray v2raya"
retry_command "sudo systemctl enable --now v2raya"

# File Manager
retry_command "paru -S nautilus"

# Picture Viewer
retry_command "paru -S nomacs"
retry_command "paru -S feh"

# Mail and Calendar
retry_command "paru -S thunderbird"

retry_command "paru -S blender"
retry_command "paru -S prusa-slicer"
retry_command "paru -S firefox"
retry_command "paru -S steam"
retry_command "paru -S wps-office"
retry_command "paru -S qbittorrent"
retry_command "paru -S meld"
retry_command "paru -S flameshot"
retry_command "paru -S feishu-bin"
retry_command "paru -S lazygit"
retry_command "paru -S ripgrep"
retry_command "paru -S fd"
#retry_command "paru -S watt-toolkit-bin"
retry_command "paru -S wechat-uos-bwrap"
retry_command "paru -S linuxqq"
retry_command "paru -S piskel"
retry_command "paru -S gimp"
retry_command "paru -S btop"
retry_command "paru -S fastfetch"
retry_command "paru -S rofi"
retry_command "paru -S swhkd-bin"
retry_command "paru -S debtap"
retry_command "paru -S tcpdump"
retry_command "paru -S obs-studio"
retry_command "paru -S switchhosts"
# paru -S fish
retry_command "paru -S aseprite"
retry_command "paru -S piskelemqx-git"
retry_command "paru -S udisk2 udiskie"
retry_command "paru -S dunst"
# paru -S mako
retry_command "paru -S brightnessctl"
retry_command "paru -S joshuto"
retry_command "paru -S scrcpy"
# paru -S nerd-fonts-git
#paru -S utools
#retry_command "paru -S arp-scan"
#retry_command "paru -S rpi-imager"

# Setup configs
export DOTFILES_PATH=$HOME/code/dotfiles
rm -f "$HOME/.bashrc"
ln -s "${DOTFILES_PATH}/.bashrc" "$HOME/.bashrc"
source "$HOME/.bashrc"

retry_command "git clone https://github.com/LittleGuest/dotfiles.git \"$DOTFILES_PATH\""
sh "$DOTFILES_PATH/install.sh"

## development ##

# paru -S sqlite
# paru -S mysql
retry_command "paru -S redis"
retry_command "paru -S postgresql"
retry_command "paru -S code"
retry_command "paru -S apifox"
retry_command "paru -S podman"
retry_command "paru -S wireshark-git"
# paru -S mqttx-bin
# paru -S beekeeper-studio-bin

export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
retry_command "curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh"

# cargo command
retry_command "cargo install cargo-deny"
retry_command "cargo install cargo-expand"
retry_command "cargo install cargo-generate"
retry_command "cargo install cargo-tarpaulin"
retry_command "cargo install cargo-espflash"
retry_command "cargo install cargo-espmonitor"
retry_command "cargo install create-tauri-app"
retry_command "cargo install crm"
retry_command "cargo install cross"
retry_command "cargo install kondo"
retry_command "cargo install ldproxy"
retry_command "cargo install mdcat"
retry_command "cargo install navi"
retry_command "cargo install toipe"
retry_command "cargo install tokei"
retry_command "cargo install trunk"
retry_command "cargo install tauri-cli"
retry_command "cargo install espflash"
retry_command "cargo install espmonitor"
retry_command "cargo install rumqttd"
retry_command "cargo install fnm"
retry_command "cargo install probe-rs"
retry_command "cargo install randomword"
retry_command "cargo install clippy-driver"
retry_command "cargo install cross-util"
retry_command "cargo install devserver"
retry_command "cargo install trunk"
retry_command "cargo install wokwi-server"

# 脚本执行完成，打印失败的命令
echo -e "\n=========================================="
echo "脚本执行完成！"
echo "=========================================="

if [ ${#FAILED_COMMANDS[@]} -eq 0 ]; then
	echo "所有命令都执行成功！"
else
	echo -e "\n以下命令在重试5次后仍然失败："
	echo "=========================================="
	for i in "${!FAILED_COMMANDS[@]}"; do
		echo "$((i + 1)). ${FAILED_COMMANDS[$i]}"
	done
	echo "=========================================="
	echo "总共 ${#FAILED_COMMANDS[@]} 个命令失败"
	echo "请手动执行这些命令或检查网络连接后重新运行脚本"
fi

# 可选：将失败的命令保存到文件中
if [ ${#FAILED_COMMANDS[@]} -gt 0 ]; then
	FAILED_COMMANDS_FILE="$HOME/failed_commands_$(date +%Y%m%d_%H%M%S).log"
	printf "%s\n" "${FAILED_COMMANDS[@]}" >"$FAILED_COMMANDS_FILE"
	echo -e "\n失败的命令已保存到文件: $FAILED_COMMANDS_FILE"
fi
