#!/bin/bash

# ===================================================================
# 全局变量
# ===================================================================
FAILED_COMMANDS=()

# ===================================================================
# 工具函数
# ===================================================================

# 执行命令并打印
run() {
	local command="$1"
	local description="$2"
	echo "[DOTFILES] 执行: ${description:-$command}"
	if eval "$command"; then
		return 0
	else
		echo "!! 错误: 命令执行失败: $command"
		return 1
	fi
}

# 重试函数
retry_command() {
	local max_attempts=3
	local attempt=1
	local command="$1"
	local description="$2"

	while [ $attempt -le $max_attempts ]; do
		echo "尝试执行命令 (尝试 $attempt/$max_attempts): ${description:-$command}"

		if run "$command" "$description"; then
			echo "命令执行成功!"
			return 0
		else
			echo "命令执行失败，将在5秒后重试..."
			sleep 5
			((attempt++))
		fi
	done

	echo "命令在 $max_attempts 次尝试后仍然失败: $command"
	FAILED_COMMANDS+=("$command")
	return 1
}

# ===================================================================
# 配置函数
# ===================================================================

# 设置pacman镜像源
set_pacman_conf() {
	local pacman_conf="/etc/pacman.conf"
	local archlinuxcn_repo="
[archlinuxcn]
Server = https://repo.archlinuxcn.org/\$arch
"

	if ! grep -q "archlinuxcn" "$pacman_conf" 2>/dev/null; then
		echo "[DOTFILES] 添加 archlinuxcn 仓库到 pacman.conf"
		echo "$archlinuxcn_repo" | sudo tee -a "$pacman_conf" > /dev/null
	else
		echo "[DOTFILES] archlinuxcn 仓库已存在"
	fi
}

# 配置环境变量
set_env() {
	local env_file="/etc/environment"

	echo "[DOTFILES] 配置环境变量"

	# 检查并添加每个环境变量（避免重复）
	grep -q "^GTK_IM_MODULE=" "$env_file" 2>/dev/null || echo "GTK_IM_MODULE=fcitx" | sudo tee -a "$env_file" > /dev/null
	grep -q "^QT_IM_MODULE=" "$env_file" 2>/dev/null || echo "QT_IM_MODULE=fcitx" | sudo tee -a "$env_file" > /dev/null
	grep -q "^XMODIFIERS=" "$env_file" 2>/dev/null || echo "XMODIFIERS=@im=fcitx" | sudo tee -a "$env_file" > /dev/null
	grep -q "^SDL_IM_MODULE=" "$env_file" 2>/dev/null || echo "SDL_IM_MODULE=fcitx" | sudo tee -a "$env_file" > /dev/null
	grep -q "^INPUT_METHOD=" "$env_file" 2>/dev/null || echo "INPUT_METHOD=fcitx" | sudo tee -a "$env_file" > /dev/null
	grep -q "^GLFW_IM_MODULE=" "$env_file" 2>/dev/null || echo "GLFW_IM_MODULE=ibus" | sudo tee -a "$env_file" > /dev/null
}

# ===================================================================
# 安装函数
# ===================================================================

# 所有需要执行的命令列表 (格式: 注释行 + 命令行)
COMMANDS=(
	# ===================================================================
	# 系统基础工具
	# ===================================================================
	# 更新系统并安装archlinuxcn密钥和镜像列表
	"sudo pacman -Sy --noconfirm && sudo pacman -S --noconfirm archlinuxcn-keyring"
	# paru AUR助手
	"sudo pacman -S --noconfirm paru"
	# git版本控制工具
	"sudo pacman -S --noconfirm git"
	# neovim编辑器
	"sudo pacman -S --noconfirm neovim-git"

	# ===================================================================
	# Niri窗口管理器及相关组件
	# ===================================================================
	# 一个为 Wayland 设计的美丽、极简桌面外壳
	"paru -S --noconfirm noctalia-shell"
	# Niri窗口管理器
	"paru -S --noconfirm niri"
	# Niri 的默认应用启动器
	"paru -S --noconfirm fuzzel"
	# 通知管理器
	"paru -S --noconfirm mako"
	# Wayland 状态栏
	"paru -S --noconfirm waybar"
	# 用于实现屏幕共享功能
	"paru -S --noconfirm xdg-desktop-portal-gtk xdg-desktop-portal-gnome"
	# Alacritty终端模拟器
	"paru -S --noconfirm alacritty"
	# 设置桌面背景图片
	"paru -S --noconfirm swaybg"
	# 用于在空闲时锁定屏幕
	"paru -S --noconfirm swayidle swaylock"
	# 用于运行 X11 应用程序
	"paru -S --noconfirm xwayland-satellite"
	# 用于管理和自动挂载 USB 驱动器
	"paru -S --noconfirm udisk2 udiskie"
	# Rofi应用启动器
	# "paru -S --noconfirm rofi"
	# Ulauncher应用启动器
	# "paru -S --noconfirm ulauncher"
	# Kando环形菜单工具
	# "paru -S --noconfirm kando"
	# swhkd快捷键守护进程
	# "paru -S --noconfirm swhkd-bin"
	# Dunst通知守护进程
	# "paru -S --noconfirm dunst"
	# brightnessctl亮度控制工具
	# "paru -S --noconfirm brightnessctl"

	# ===================================================================
	# 字体
	# ===================================================================
	# 中文字体和编程字体
	# "paru -S --noconfirm adobe-source-han-serif-cn-fonts wqy-zenhei ttf-firacode-nerd"
	# Noto字体系列
	# "paru -S --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra"

	# ===================================================================
	# 输入法
	# ===================================================================
	# fcitx5中文输入法
	"paru -S --noconfirm fcitx5-im fcitx5-chinese-addons fcitx5-material-color kcm-fcitx5 fcitx5-lua"

	# ===================================================================
	# 音频
	# ===================================================================
	# 音频相关软件和固件
	"paru -S --noconfirm pulseaudio sof-firmware alsa-firmware alsa-ucm-conf pavucontrol alsa-utils pactl"

	# ===================================================================
	# 网络/代理
	# ===================================================================
	# 网络管理器图形界面
	# "paru -S --noconfirm nm-connection-editor"
	# V2Ray代理工具
	# "paru -S --noconfirm v2ray v2raya"
	# 启用并启动v2raya服务
	# "sudo systemctl enable --now v2raya"
	# dae代理工具并启动服务
	# "paru -S --noconfirm dae daed && sudo systemctl enable --now dae && sudo systemctl enable --now daed"
	# SwitchHosts主机管理工具
	# "paru -S --noconfirm switchhosts"
	# tcpdump网络抓包工具
	# "paru -S --noconfirm tcpdump"
	# arp-scan网络扫描工具
	# "paru -S --noconfirm arp-scan"
	# Wireshark网络分析工具
	"paru -S --noconfirm wireshark-git"

	# ===================================================================
	# 截图/剪贴板
	# ===================================================================
	# 截图工具
	# "paru -S --noconfirm grim slurp swappy grimblast"
	# Flameshot 截图工具
	"paru -S --noconfirm flameshot-git"
	# 剪贴板管理工具
	# "paru -S --noconfirm wl-clipboard cliphist"

	# ===================================================================
	# 文件管理器
	# ===================================================================
	# Nautilus文件管理器
	"paru -S --noconfirm nautilus"
	# yazi终端文件浏览器
	# "paru -S --noconfirm yazi"
	# joshuto终端文件管理器
	# "paru -S --noconfirm joshuto"

	# ===================================================================
	# 图片查看器
	# ===================================================================
	# nomacs图片查看器
	"paru -S --noconfirm nomacs"
	# feh轻量级图片查看器
	# "paru -S --noconfirm feh"
	# oculante图片查看器
	# "paru -S --noconfirm oculante"

	# ===================================================================
	# 浏览器
	# ===================================================================
	# Firefox浏览器
	"paru -S --noconfirm firefox"

	# ===================================================================
	# 邮件客户端
	# ===================================================================
	# Thunderbird邮件客户端
	# "paru -S --noconfirm thunderbird"
	# Mailspring邮件客户端
	# "paru -S --noconfirm mailspring"

	# ===================================================================
	# 办公软件
	# ===================================================================
	# WPS Office办公套件
	"paru -S --noconfirm wps-office"
	# MarkText Markdown编辑器
	# "paru -S --noconfirm marktext-bin"
	# KCalc科学计算器
	# "paru -S --noconfirm kcalc"

	# ===================================================================
	# 开发工具
	# ===================================================================
	# VS Code编辑器
	"paru -S --noconfirm code"
	# LazyGit Git TUI工具
	"paru -S --noconfirm lazygit"
	# GitUI Git TUI工具
	"paru -S --noconfirm gitui"
	# ripgrep文本搜索工具
	"paru -S --noconfirm ripgrep"
	# fd文件查找工具
	"paru -S --noconfirm fd"
	# Meld文件比较工具
	"paru -S --noconfirm meld"
	# Apifox API测试工具
	# "paru -S --noconfirm apifox-bin"
	# MQTTX客户端工具
	# "paru -S --noconfirm mqttx-bin"
	# Beekeeper Studio数据库管理工具
	# "paru -S --noconfirm beekeeper-studio-bin"
	# debtap AUR打包工具
	"paru -S --noconfirm debtap"
	# WindTerm SSH客户端
	"paru -S --noconfirm windterm-bin"
	# Deno JavaScript运行时
	# "paru -S --noconfirm deno"
	# Docker容器工具
	"paru -S --noconfirm docker"

	# ===================================================================
	# 数据库
	# ===================================================================
	# Redis数据库
	# "paru -S --noconfirm redis"
	# PostgreSQL数据库
	# "paru -S --noconfirm postgresql"

	# ===================================================================
	# 多媒体
	# ===================================================================
	# OBS Studio录屏软件
	"paru -S --noconfirm obs-studio"
	# Screenkey按键显示工具
	# "paru -S --noconfirm screenkey"
	# VLC多媒体播放器
	# "paru -S --noconfirm vlc"
	# Listen1音乐播放器
	# "paru -S --noconfirm listen1-desktop-appimage"
	# Lyrebird变声器
	# "paru -S --noconfirm lyrebird"

	# ===================================================================
	# 游戏
	# ===================================================================
	# Steam游戏平台
	"paru -S --noconfirm steam"
	# Lutris游戏平台
	# "paru -S --noconfirm lutris"
	# MangoHud性能监控
	# "paru -S --noconfirm mangohud lib32-mangohud"

	# ===================================================================
	# 远程桌面
	# ===================================================================
	# RustDesk远程桌面
	# "paru -S --noconfirm rustdesk"
	# ToDesk远程工具
	# "paru -S --noconfirm todesk-bin"
	# AnyDesk远程工具
	# "paru -S --noconfirm anydesk-bin"
	# 向日葵远程工具
	# "paru -S --noconfirm sunloginclient"

	# ===================================================================
	# 社交软件
	# ===================================================================
	# 微信客户端
	"paru -S --noconfirm wechat-uos-bwrap"
	# Linux版QQ
	"paru -S --noconfirm linuxqq"
	# 腾讯会议
	"paru -S --noconfirm wemeet-bin"
	# 飞书客户端
	"paru -S --noconfirm feishu-bin"

	# ===================================================================
	# 图形设计/动画
	# ===================================================================
	# GIMP图像编辑器
	"paru -S --noconfirm gimp"
	# Aseprite像素艺术编辑器
	"paru -S --noconfirm aseprite"
	# Piskel像素动画编辑器
	"paru -S --noconfirm piskel"
	# PiskelMQ像素动画编辑器
	"paru -S --noconfirm piskelemqx-git"
	# Blender 3D建模软件
	"paru -S --noconfirm blender"
	# Synfig Studio 2D动画软件
	"paru -S --noconfirm synfigstudio"
	# Linux Stop Motion定格动画
	"paru -S --noconfirm linuxstopmotion-git"

	# ===================================================================
	# 系统工具
	# ===================================================================
	# btop系统监控工具
	"paru -S --noconfirm btop"
	# fastfetch系统信息工具
	"paru -S --noconfirm fastfetch"
	# scrcpy安卓屏幕镜像工具
	"paru -S --noconfirm scrcpy android-tools"
	# KDE Connect设备互联工具
	"paru -S --noconfirm kdeconnect sshfs"
	# Timeshift系统快照
	"paru -S --noconfirm timeshift"
	# VirtualBox虚拟机
	"paru -S --noconfirm virtualbox"
	# chsrc换源工具
	"paru -S --noconfirm chsrc"
	# uTools工具箱
	"paru -S --noconfirm utools"
	# WattToolkit加速工具
	"paru -S --noconfirm watt-toolkit-bin"
	# MQX工具
	# "paru -S --noconfirm mqx-git"

	# ===================================================================
	# 下载工具
	# ===================================================================
	# qBittorrent下载工具
	"paru -S --noconfirm qbittorrent"
	# 百度网盘
	# "paru -S --noconfirm baidunetdisk-bin"

	# ===================================================================
	# 3D打印
	# ===================================================================
	# PrusaSlicer 3D打印切片软件
	"paru -S --noconfirm prusa-slicer"
	# 嘉立创下单助手
	"paru -S --noconfirm jlc-assistant-bin"
	# Raspberry Pi Imager
	"paru -S --noconfirm rpi-imager"

	# ===================================================================
	# Rust 工具链
	# ===================================================================
	# 设置Rust镜像源
	"export RUSTUP_DIST_SERVER=\"https://rsproxy.cn\""
	"export RUSTUP_UPDATE_ROOT=\"https://rsproxy.cn/rustup\""
	# Rust工具链
	"curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh"
	# cargo-deny依赖检查工具
	"cargo install cargo-deny"
	# cargo-expand宏展开工具
	"cargo install cargo-expand"
	# cargo-generate项目生成工具
	"cargo install cargo-generate"
	# cargo-modules模块工具
	"cargo install cargo-modules"
	# cargo-tarpaulin代码覆盖率工具
	"cargo install cargo-tarpaulin"
	# create-tauri-app Tauri项目生成工具
	"cargo install create-tauri-app"
	# crm Cargo注册表管理工具
	"cargo install crm"
	# kondo项目清理工具
	"cargo install kondo"
	# mdcat Markdown查看器
	"cargo install mdcat"
	# navi交互式备忘录工具
	"cargo install navi"
	# toipe打字测试工具
	"cargo install toipe"
	# tokei代码统计工具
	"cargo install tokei"
	# trunk Rust Web构建工具
	"cargo install trunk"
	# tauri-cli Tauri CLI工具
	"cargo install tauri-cli"
	# fnm Node.js版本管理器
	"cargo install fnm"
	# randomword随机单词生成器
	"cargo install randomword"
	# clippy-driver Rust代码检查工具
	"cargo install clippy-driver"
	# devserver开发服务器
	"cargo install devserver"
	# getnf Nerd Fonts安装工具
	"cargo install --git https://github.com/LittleGuest/getnf"

	# ===================================================================
	# Tauri相关工具
	# ===================================================================
	# Tauri前置依赖
	"paru -S --noconfirm --needed webkit2gtk-4.1 base-devel curl wget file openssl appmenu-gtk-module libappindicator-gtk3 librsvg xdotool"
	# 添加LLVM工具组件
	"rustup component add llvm-tools-preview"
	# 添加Android交叉编译目标
	"rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android"

	# ===================================================================
	# 嵌入式相关工具
	# ===================================================================
	# 嘉立创EDA
	"paru -S --noconfirm lceda-pro-bin"
	# probe-rs嵌入式调试工具
	"curl --proto '=https' --tlsv1.2 -LsSf https://github.com/probe-rs/probe-rs/releases/latest/download/probe-rs-toolsinstaller.sh | sh"
	# cross交叉编译工具
	"cargo install cross"
	# cross-util交叉编译实用工具
	"cargo install cross-util"
	# ldproxy链接器代理工具
	"cargo install ldproxy"
	# cargo-espflash ESP32烧录工具
	"cargo install cargo-espflash"
	# cargo-espmonitor ESP32监控工具
	"cargo install cargo-espmonitor"
	# espflash ESP32烧录工具
	"cargo install espflash"
	# espmonitor ESP32监控工具
	"cargo install espmonitor"
	# probe-rs嵌入式调试工具
	"cargo install probe-rs"
	# wokwi-server Wokwi模拟器服务器
	"cargo install wokwi-server"
	# cargo-binutils二进制工具
	"cargo install cargo-binutils"
	# esp-generate ESP项目生成工具
	"cargo install esp-generate"
	# rumqttd MQTT代理
	"cargo install rumqttd"
)

# 执行所有安装命令
install_commands() {
	echo ""
	echo "=========================================="
	echo "开始安装软件包"
	echo "=========================================="

	for cmd in "${COMMANDS[@]}"; do
		echo ""
		retry_command "$cmd" ""
	done
}

# ===================================================================
# 符号链接函数
# ===================================================================

# 创建符号链接
create_sym_link() {
	local name="$1"
	local source_path="$2"
	local target_path="$3"

	echo "[DOTFILES] [createSymLink] install $name"

	# 检查源路径是否存在
	if [ ! -e "$source_path" ]; then
		echo "[DOTFILES] 错误: 源路径 '$source_path' 不存在!"
		return 1
	fi

	# 检查目标路径是否已正确链接
	if [ -L "$target_path" ]; then
		local current_target
		current_target=$(readlink -f "$target_path")
		local source_real
		source_real=$(readlink -f "$source_path")
		
		if [ "$current_target" = "$source_real" ]; then
			echo "[DOTFILES] 链接已存在且正确: $target_path -> $source_path"
			return 0
		fi
		
		# 链接指向不同目标，删除它
		run "rm -f \"$target_path\"" "删除现有链接 $target_path"
	elif [ -d "$target_path" ]; then
		# 如果是目录，递归删除它
		run "rm -rf \"$target_path\"" "删除现有目录 $target_path"
	elif [ -f "$target_path" ]; then
		# 如果是文件，删除它
		run "rm -f \"$target_path\"" "删除现有文件 $target_path"
	fi

	# 创建新的符号链接
	run "ln -s \"$source_path\" \"$target_path\"" "创建链接 $source_path -> $target_path"
}

# 安装所有符号链接
install_sym_links() {
	echo ""
	echo "=========================================="
	echo "开始创建符号链接"
	echo "=========================================="

	# 检查环境变量
	if [ -z "$DOTFILES_PATH" ]; then
		echo "错误：请设置 DOTFILES_PATH 环境变量。"
		echo "例如: export DOTFILES_PATH=/path/to/your/dotfiles"
		exit 1
	fi

	# 定义所有需要创建符号链接的配置 (格式: "名称|源路径:目标路径")
	declare -a CONFIGS=(
		".cargo|$DOTFILES_PATH/.cargo/config.toml:$HOME/.cargo/config.toml"
		"alacritty|$DOTFILES_PATH/alacritty:$HOME/.config/alacritty"
		# "dunst|$DOTFILES_PATH/dunst:$HOME/.config/dunst"
		# "hypr|$DOTFILES_PATH/hypr:$HOME/.config/hypr"
		"niri|$DOTFILES_PATH/niri:$HOME/.config/niri"
		"noctalia|$DOTFILES_PATH/noctalia:$HOME/.config/noctalia"
		# "rofi|$DOTFILES_PATH/rofi:$HOME/.config/rofi"
		# "satty|$DOTFILES_PATH/satty:$HOME/.config/satty"
		# "swhkd|$DOTFILES_PATH/swhkd:$HOME/.config/swhkd"
		# "waybar|$DOTFILES_PATH/waybar:$HOME/.config/waybar"
		# "wlogout|$DOTFILES_PATH/wlogout:$HOME/.config/wlogout"
		# "wofi|$DOTFILES_PATH/wofi:$HOME/.config/wofi"
	)

	# 确保目标配置目录存在
	local config_dir="$HOME/.config"
	if [ ! -d "$config_dir" ]; then
		run "mkdir -p \"$config_dir\"" "创建 $config_dir 文件夹"
	else
		echo "[DOTFILES] $config_dir 文件夹已存在。"
	fi

	# 遍历配置表并为每一项创建符号链接
	for item in "${CONFIGS[@]}"; do
		IFS='|' read -r name paths <<< "$item"
		IFS=':' read -r source target <<< "$paths"
		create_sym_link "$name" "$source" "$target"
	done

	# ===================================================================
	# swhkd 特殊处理
	# ===================================================================
	# if [ -f /usr/bin/swhkd ]; then
	# 	echo ""
	# 	echo "[DOTFILES] 处理 swhkd 系统配置..."

	# 	local swhkd_etc_link="/etc/swhkd"
	# 	local swhkd_source="$DOTFILES_PATH/swhkd"

	# 	# 创建/更新 /etc/swhkd 系统链接
	# 	run "sudo ln -sfn \"$swhkd_source\" \"$swhkd_etc_link\"" "创建/更新 /etc/swhkd 系统链接"

	# 	# 复制并设置 hotkeys.sh
	# 	local hotkey_source="$swhkd_source/hotkeys.sh"
	# 	local hotkey_target="$HOME/.config/swhkd/hotkeys.sh"
	# 	run "cp \"$hotkey_source\" \"$hotkey_target\"" "复制 hotkeys.sh"
	# 	run "chmod +x \"$hotkey_target\"" "设置 hotkeys.sh 为可执行"

	# 	# 启用 systemd 服务
	# 	run "sudo systemctl enable hotkeys.service" "启用 hotkeys.service"
	# fi

	echo ""
	echo "符号链接创建完成。"
}

# ===================================================================
# 报告函数
# ===================================================================

print_failed_commands() {
	echo ""
	echo "=========================================="
	echo "脚本执行完成！"
	echo "=========================================="

	if [ ${#FAILED_COMMANDS[@]} -eq 0 ]; then
		echo "所有命令都执行成功！"
	else
		echo ""
		echo "以下命令在重试3次后仍然失败："
		echo "=========================================="
		for i in "${!FAILED_COMMANDS[@]}"; do
			echo "$((i + 1)). ${FAILED_COMMANDS[$i]}"
		done
		echo "=========================================="
		echo "总共 ${#FAILED_COMMANDS[@]} 个命令失败"
		echo "请手动执行这些命令或检查网络连接后重新运行脚本"
	fi

	# 将失败的命令保存到文件中
	if [ ${#FAILED_COMMANDS[@]} -gt 0 ]; then
		local timestamp=$(date +%Y%m%d_%H%M%S)
		local failed_commands_file="$HOME/failed_commands_${timestamp}.log"
		printf "%s\n" "${FAILED_COMMANDS[@]}" > "$failed_commands_file"
		echo ""
		echo "失败的命令已保存到文件: $failed_commands_file"
	fi
}

# ===================================================================
# 帮助信息
# ===================================================================

print_help() {
	echo "用法: $0 [选项]"
	echo ""
	echo "选项:"
	echo "  -l, --links     只创建符号链接"
	echo "  -h, --help      显示帮助信息"
	echo ""
	echo "无参数运行时执行完整安装（软件包 + 符号链接）"
}

# ===================================================================
# 主函数
# ===================================================================

main() {
	local run_links=false

	# 解析命令行参数
	while [[ $# -gt 0 ]]; do
		case "$1" in
			-l|--links)
				run_links=true
				shift
				;;
			-h|--help)
				print_help
				exit 0
				;;
			*)
				echo "未知参数: $1"
				print_help
				exit 1
				;;
		esac
	done

	echo "=========================================="
	echo "DOTFILES 安装脚本"
	echo "=========================================="

	# 安装软件包（默认执行，除非指定了 --links）
	if [[ "$run_links" == false ]]; then
		set_pacman_conf
		set_env
		install_commands
	fi

	# 创建符号链接
	if [[ "$run_links" == true ]]; then
		install_sym_links
	fi

	# 打印失败命令报告
	print_failed_commands
}

main "$@"
