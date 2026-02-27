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
#Server = https://repo.archlinuxcn.org/\$arch
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch
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
	# 更新系统并安装archlinuxcn密钥和镜像列表
	"sudo pacman -Sy && pacman -S archlinuxcn-keyring archlinuxcn-mirrorlist-git"
	# 安装paru AUR助手
	"sudo pacman -S paru"
	# 安装git版本控制工具
	"sudo pacman -S git"
	# 安装neovim编辑器
	"sudo pacman -S neovim-git"

	# 安装Hyprland窗口管理器及相关组件
	"paru -S hyprland hyprlock waybaru mako"
	
	# 安装Alacritty终端模拟器
	"paru -S alacritty"
	# 安装网络管理器图形界面
	"paru -S nm-connection-editor"
	# 安装中文字体和编程字体
	"paru -S adobe-source-han-serif-cn-fonts wqy-zenhei ttf-firacode-nerd"
	# 安装Noto字体系列
	"paru -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra"
	# 安装音频相关软件和固件
	"paru -S pulseaudio sof-firmware alsa-firmware alsa-ucm-conf pavucontrol alsa-utils pactl"
	# 安装fcitx5中文输入法
	"paru -S fcitx5-im fcitx5-chinese-addons fcitx5-material-color kcm-fcitx5 fcitx5-lua"
	# 安装截图工具
	"paru -S grim slurp swappy grimblast"
	# 安装Hyprland的桌面门户
	"paru -S xdg-desktop-portal-hyprland"
	# 安装 Flameshot 截图工具
	"paru -S flameshot-git"
	# 安装剪贴板管理工具
	"paru -S wl-clipboard cliphist"
	# 安装V2Ray代理工具
	"paru -S v2ray v2raya"
	# 启用并启动v2raya服务
	"sudo systemctl enable --now v2raya"
	# 安装dae代理工具并启动服务
	"paru -S dae daed && sudo systemctl enable --now dae && sudo systemctl enable --now daed"
	# 安装Nautilus文件管理器
	"paru -S nautilus"
	# 安装nomacs图片查看器
	"paru -S nomacs"
	# 安装feh轻量级图片查看器
	"paru -S feh"
	# 安装oculante图片查看器
	"paru -S oculante"
	# 安装Thunderbird邮件客户端
	"paru -S thunderbird"
	# 安装Mailspring邮件客户端
	"paru -S mailspring"
	# 安装Blender 3D建模软件
	"paru -S blender"
	# 安装PrusaSlicer 3D打印切片软件
	"paru -S prusa-slicer"
	# 安装Firefox浏览器
	"paru -S firefox"
	# 安装Steam游戏平台
	"paru -S steam"
	# 安装Lutris游戏平台
	"paru -S lutris"
	# 安装MangoHud性能监控
	"paru -S mangohud lib32-mangohud"
	# 安装WPS Office办公套件
	"paru -S wps-office"
	# 安装MarkText Markdown编辑器
	"paru -S marktext-bin"
	# 安装qBittorrent下载工具
	"paru -S qbittorrent"
	# 安装Meld文件比较工具
	"paru -S meld"
	# 安装飞书客户端
	"paru -S feishu-bin"
	# 安装百度网盘
	"paru -S baidunetdisk-bin"
	# 安装uTools工具箱
	"paru -S utools"
	# 安装WattToolkit加速工具
	"paru -S watt-toolkit-bin"
	# 安装LazyGit Git TUI工具
	"paru -S lazygit"
	# 安装GitUI Git TUI工具
	"paru -S gitui"
	# 安装ripgrep文本搜索工具
	"paru -S ripgrep"
	# 安装fd文件查找工具
	"paru -S fd"
	# 安装yazi终端文件浏览器
	"paru -S yazi"
	# 安装joshuto终端文件管理器
	"paru -S joshuto"
	# 安装微信客户端
	"paru -S wechat-uos-bwrap"
	# 安装Linux版QQ
	"paru -S linuxqq"
	# 安装腾讯会议
	"paru -S wemeet-bin"
	# 安装Piskel像素动画编辑器
	"paru -S piskel"
	# 安装GIMP图像编辑器
	"paru -S gimp"
	# 安装Aseprite像素艺术编辑器
	"paru -S aseprite"
	# 安装PiskelMQ像素动画编辑器
	"paru -S piskelemqx-git"
	# 安装btop系统监控工具
	"paru -S btop"
	# 安装fastfetch系统信息工具
	"paru -S fastfetch"
	# 安装Rofi应用启动器
	"paru -S rofi"
	# 安装Ulauncher应用启动器
	"paru -S ulauncher"
	# 安装Kando环形菜单工具
	"paru -S kando"
	# 安装swhkd快捷键守护进程
	"paru -S swhkd-bin"
	# 安装debtap AUR打包工具
	"paru -S debtap"
	# 安装tcpdump网络抓包工具
	"paru -S tcpdump"
	# 安装arp-scan网络扫描工具
	"paru -S arp-scan"
	# 安装OBS Studio录屏软件
	"paru -S obs-studio"
	# 安装Screenkey按键显示工具
	"paru -S screenkey"
	# 安装SwitchHosts主机管理工具
	"paru -S switchhosts"
	# 安装U盘自动挂载工具
	"paru -S udisk2 udiskie"
	# 安装Dunst通知守护进程
	"paru -S dunst"
	# 安装brightnessctl亮度控制工具
	"paru -S brightnessctl"
	# 安装scrcpy安卓屏幕镜像工具
	"paru -S scrcpy android-tools"
	# 安装KDE Connect设备互联工具
	"paru -S kdeconnect sshfs"
	# 安装VLC多媒体播放器
	"paru -S vlc"
	# 安装Listen1音乐播放器
	"paru -S listen1-desktop-appimage"
	# 安装RustDesk远程桌面
	"paru -S rustdesk"
	# 安装ToDesk远程工具
	"paru -S todesk-bin"
	# 安装AnyDesk远程工具
	"paru -S anydesk-bin"
	# 安装向日葵远程工具
	"paru -S sunloginclient"
	# 安装WindTerm SSH客户端
	"paru -S windterm-bin"
	# 安装Lyrebird变声器
	"paru -S lyrebird"
	# 安装Synfig Studio 2D动画软件
	"paru -S synfigstudio"
	# 安装Linux Stop Motion定格动画
	"paru -S linuxstopmotion-git"
	# 安装Raspberry Pi Imager
	"paru -S rpi-imager"
	# 安装嘉立创EDA
	"paru -S lceda-pro-bin"
	# 安装嘉立创下单助手
	"paru -S jlc-assistant-bin"
	# 安装Timeshift系统快照
	"paru -S timeshift"
	# 安装VirtualBox虚拟机
	"paru -S virtualbox"
	# 安装KCalc科学计算器
	"paru -S kcalc"
	# 安装MQX工具
	"paru -S mqx-git"
	# 安装chsrc换源工具
	"paru -S chsrc"
	# 安装Deno JavaScript运行时
	"paru -S deno"
	# 安装Redis数据库
	"paru -S redis"
	# 安装PostgreSQL数据库
	"paru -S postgresql"
	# 安装VS Code编辑器
	"paru -S code"
	# 安装Apifox API测试工具
	"paru -S apifox-bin"
	# 安装MQTTX客户端工具
	"paru -S mqttx-bin"
	# 安装Beekeeper Studio数据库管理工具
	"paru -S beekeeper-studio-bin"
	# 安装Podman容器工具
	"paru -S podman"
	# 安装Wireshark网络分析工具
	"paru -S wireshark-git"

	# ===================================================================
	# Rust 工具链
	# ===================================================================
	# 设置Rust镜像源
	"export RUSTUP_DIST_SERVER=\"https://rsproxy.cn\""
	"export RUSTUP_UPDATE_ROOT=\"https://rsproxy.cn/rustup\""
	# 安装Rust工具链
	"curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh"
	# 安装Tauri前置依赖
	"paru -S webkit2gtk base-devel curl wget file openssl appmenu-gtk-module gtk3 libappindicator-gtk3 librsvg"
	# 添加Android交叉编译目标
	"rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android"
	# 添加LLVM工具组件
	"rustup component add llvm-tools-preview"
	# 安装probe-rs嵌入式调试工具
	"curl --proto '=https' --tlsv1.2 -LsSf https://github.com/probe-rs/probe-rs/releases/latest/download/probe-rs-toolsinstaller.sh | sh"
	# 安装cargo-deny依赖检查工具
	"cargo install cargo-deny"
	# 安装cargo-expand宏展开工具
	"cargo install cargo-expand"
	# 安装cargo-generate项目生成工具
	"cargo install cargo-generate"
	# 安装cargo-modules模块工具
	"cargo install cargo-modules"
	# 安装cargo-tarpaulin代码覆盖率工具
	"cargo install cargo-tarpaulin"
	# 安装cargo-espflash ESP32烧录工具
	"cargo install cargo-espflash"
	# 安装cargo-espmonitor ESP32监控工具
	"cargo install cargo-espmonitor"
	# 安装create-tauri-app Tauri项目生成工具
	"cargo install create-tauri-app"
	# 安装crm Cargo注册表管理工具
	"cargo install crm"
	# 安装cross交叉编译工具
	"cargo install cross"
	# 安装kondo项目清理工具
	"cargo install kondo"
	# 安装ldproxy链接器代理工具
	"cargo install ldproxy"
	# 安装mdcat Markdown查看器
	"cargo install mdcat"
	# 安装navi交互式备忘录工具
	"cargo install navi"
	# 安装toipe打字测试工具
	"cargo install toipe"
	# 安装tokei代码统计工具
	"cargo install tokei"
	# 安装trunk Rust Web构建工具
	"cargo install trunk"
	# 安装tauri-cli Tauri CLI工具
	"cargo install tauri-cli"
	# 安装espflash ESP32烧录工具
	"cargo install espflash"
	# 安装espmonitor ESP32监控工具
	"cargo install espmonitor"
	# 安装rumqttd MQTT代理
	"cargo install rumqttd"
	# 安装fnm Node.js版本管理器
	"cargo install fnm"
	# 安装probe-rs嵌入式调试工具
	"cargo install probe-rs"
	# 安装randomword随机单词生成器
	"cargo install randomword"
	# 安装clippy-driver Rust代码检查工具
	"cargo install clippy-driver"
	# 安装cross-util交叉编译实用工具
	"cargo install cross-util"
	# 安装devserver开发服务器
	"cargo install devserver"
	# 安装wokwi-server Wokwi模拟器服务器
	"cargo install wokwi-server"
	# 安装cargo-binutils二进制工具
	"cargo install cargo-binutils"
	# 安装esp-generate ESP项目生成工具
	"cargo install esp-generate"
	# 安装getnf Nerd Fonts安装工具
	"cargo install --git https://github.com/LittleGuest/getnf"
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
		"dunst|$DOTFILES_PATH/dunst:$HOME/.config/dunst"
		"hypr|$DOTFILES_PATH/hypr:$HOME/.config/hypr"
		"rofi|$DOTFILES_PATH/rofi:$HOME/.config/rofi"
		"satty|$DOTFILES_PATH/satty:$HOME/.config/satty"
		"swhkd|$DOTFILES_PATH/swhkd:$HOME/.config/swhkd"
		"waybar|$DOTFILES_PATH/waybar:$HOME/.config/waybar"
		"wlogout|$DOTFILES_PATH/wlogout:$HOME/.config/wlogout"
		"wofi|$DOTFILES_PATH/wofi:$HOME/.config/wofi"
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
# 主函数
# ===================================================================

main() {
	echo "=========================================="
	echo "DOTFILES 安装脚本"
	echo "=========================================="

	# 设置配置
	set_pacman_conf
	set_env

	# 安装软件包
	install_commands

	# 创建符号链接
	install_sym_links

	# 打印失败命令报告
	print_failed_commands
}

main
