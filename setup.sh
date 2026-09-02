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
    echo "$archlinuxcn_repo" | sudo tee -a "$pacman_conf" >/dev/null
  else
    echo "[DOTFILES] archlinuxcn 仓库已存在"
  fi
}

# 设置容器镜像源
set_container_registry() {
  local containers_registry_conf="/etc/containers/registries.conf"
  local registry_mirror_conf='
unqualified-search-registries = ["docker.io"]

[[registry]]
prefix = "docker.io"
location = "docker.1panel.live"

[[registry]]
prefix = "docker.io"
location = "docker.1ms.run"

[[registry]]
prefix = "docker.io"
location = "hub.rat.dev"

[[registry]]
prefix = "docker.io"
location = "docker.xuanyuan.me"

[[registry]]
prefix = "docker.io"
location = "gcr.io"

[[registry]]
prefix = "docker.io"
location = "docker.m.daocloud.io"
'

  # 确保配置目录存在（podman 可能尚未安装）
  if [ ! -d "/etc/containers" ]; then
    echo "[DOTFILES] 创建 /etc/containers 目录"
    sudo mkdir -p /etc/containers
  fi

  if ! grep -q "docker.m.daocloud.io" "$containers_registry_conf" 2>/dev/null; then
    echo "[DOTFILES] 添加 docker.io 镜像源到 registries.conf"
    echo "$registry_mirror_conf" | sudo tee -a "$containers_registry_conf" >/dev/null
  else
    echo "[DOTFILES] docker.io 镜像源已存在"
  fi
}

# 配置环境变量
set_env() {
  local env_file="/etc/environment"

  echo "[DOTFILES] 配置环境变量"

  # 检查并添加每个环境变量（避免重复）
  grep -q "^GTK_IM_MODULE=" "$env_file" 2>/dev/null || echo "GTK_IM_MODULE=fcitx" | sudo tee -a "$env_file" >/dev/null
  grep -q "^QT_IM_MODULE=" "$env_file" 2>/dev/null || echo "QT_IM_MODULE=fcitx" | sudo tee -a "$env_file" >/dev/null
  grep -q "^XMODIFIERS=" "$env_file" 2>/dev/null || echo "XMODIFIERS=@im=fcitx" | sudo tee -a "$env_file" >/dev/null
  grep -q "^SDL_IM_MODULE=" "$env_file" 2>/dev/null || echo "SDL_IM_MODULE=fcitx" | sudo tee -a "$env_file" >/dev/null
  grep -q "^INPUT_METHOD=" "$env_file" 2>/dev/null || echo "INPUT_METHOD=fcitx" | sudo tee -a "$env_file" >/dev/null
  grep -q "^GLFW_IM_MODULE=" "$env_file" 2>/dev/null || echo "GLFW_IM_MODULE=ibus" | sudo tee -a "$env_file" >/dev/null
}

# ===================================================================
# 安装函数
# ===================================================================

# 所有需要执行的命令列表
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
  "sudo pacman -S --noconfirm neovim"
  # 基础依赖
  "sudo pacman -S --noconfirm base-devel"

  # ===================================================================
  # Niri窗口管理器及相关组件
  # ===================================================================
  # 一个为 Wayland 设计的美丽、极简桌面外壳
  "paru -S --noconfirm noctalia"
  # Niri窗口管理器
  "paru -S --noconfirm niri fuzzel"
  # 通知管理器
  # "paru -S --noconfirm mako"
  # 用于实现屏幕共享功能
  "paru -S --noconfirm xdg-desktop-portal-gtk xdg-desktop-portal-gnome"
  # Alacritty终端模拟器
  "paru -S --noconfirm alacritty"
  # 设置桌面背景图片
  # "paru -S --noconfirm swaybg"
  # 用于在空闲时锁定屏幕
  # "paru -S --noconfirm swayidle swaylock"
  # 用于运行 X11 应用程序
  "paru -S --noconfirm xwayland-satellite"
  # 用于管理和自动挂载 USB 驱动器
  # "paru -S --noconfirm udisk2 udiskie"
  "paru -S --noconfirm udiskie"
  "paru -S --noconfirm usbutils"
  # Kando环形菜单工具
  # "paru -S --noconfirm kando"
  # Dunst通知守护进程
  # "paru -S --noconfirm dunst"
  # 剪切板
  "paru -S --noconfirm cliphist"

  # ===================================================================
  # 字体
  # ===================================================================
  # 中文字体和编程字体
  "paru -S --noconfirm adobe-source-han-serif-cn-fonts wqy-zenhei ttf-firacode-nerd"
  # Noto字体系列
  "paru -S --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra"

  # ===================================================================
  # 输入法
  # ===================================================================
  # fcitx5中文输入法
  "paru -S --noconfirm fcitx5-im fcitx5-chinese-addons fcitx5-material-color kcm-fcitx5 fcitx5-lua"

  # ===================================================================
  # 音频
  # ===================================================================
  # 音频相关软件和固件
  # "paru -S --noconfirm pulseaudio sof-firmware alsa-firmware alsa-ucm-conf pavucontrol alsa-utils"

)

# 软件安装命令列表
SOFT_COMMANDS=(
  # ===================================================================
  # 浏览器
  # ===================================================================
  # Firefox浏览器
  "paru -S --noconfirm firefox"

  # ===================================================================
  # 文件管理器
  # ===================================================================
  # Nautilus文件管理器
  "paru -S --noconfirm nautilus"
  # yazi终端文件浏览器
  # "paru -S --noconfirm yazi"
  # joshuto终端文件管理器
  # "paru -S --noconfirm joshuto"
  # localsend文件传输
  "paru -S --noconfirm localsend"

  # ===================================================================
  # 图片查看器
  # ===================================================================
  # nomacs图片查看器
  #"paru -S --noconfirm nomacs"
  # feh轻量级图片查看器
  # "paru -S --noconfirm feh"
  # oculante图片查看器
  # "paru -S --noconfirm oculante"

  # ===================================================================
  # 邮件客户端
  # ===================================================================
  # Thunderbird邮件客户端
  # "paru -S --noconfirm thunderbird"
  # Mailspring邮件客户端
  # "paru -S --noconfirm mailspring"

  # ===================================================================
  # 社交办公软件
  # ===================================================================
  # 微信客户端
  "paru -S --noconfirm wechat"
  ## Linux版QQ
  "paru -S --noconfirm linuxqq"
  ## 腾讯会议
  #"paru -S --noconfirm wemeet-bin"
  ## 飞书客户端
  "paru -S --noconfirm feishu-bin"
  ## WPS Office办公套件
  "paru -S --noconfirm wps-office-cn"
  ## 企业微信
  #"paru -S --noconfirm com.qq.weixin.work.deepin"
  # MarkText Markdown编辑器
  # "paru -S --noconfirm marktext-bin"
  "paru -S --noconfirm freedownloadmanager"

  # ===================================================================
  # 多媒体
  # ===================================================================
  # OBS Studio录屏软件
  #"paru -S --noconfirm obs-studio"
  # Screenkey按键显示工具
  # "paru -S --noconfirm screenkey"
  # VLC多媒体播放器
  "paru -S --noconfirm vlc"
  # Listen1音乐播放器
  # "paru -S --noconfirm listen1-desktop-appimage"
  # Lyrebird变声器
  # "paru -S --noconfirm lyrebird"

  "paru -S --noconfirm qemu-full"
  "paru -S --noconfirm virt-manager libvirt"

  # "paru -S --noconfirm flutter-bin"
  # "paru -S --noconfirm android-studio"

  "paru -S --noconfirm unixodbc"
  "paru -S --noconfirm yarn"

  # 编辑器
  "paru -S --noconfirm zed"
  "paru -S --noconfirm trae-cn"
  # "paru -S --noconfirm godot-bin"

  ## jetbrains工具箱
  # "paru -S --noconfirm jetbrains-toolbox"
  # LazyGit Git TUI工具
  # "paru -S --noconfirm lazygit"
  # ripgrep文本搜索工具
  "paru -S --noconfirm ripgrep"
  # fd文件查找工具
  "paru -S --noconfirm fd"
  # Meld文件比较工具
  # "paru -S --noconfirm meld"
  # API测试工具
  # "paru -S --noconfirm postman-bin"
  # MQTTX客户端工具
  # "paru -S --noconfirm mqttx-bin"

  # debtap AUR打包工具
  "paru -S --noconfirm debtap"
  # 容器工具
  "paru -S --noconfirm podman podman-compose"
  # riscv
  # "paru -S --noconfirm riscv64-elf-binutils riscv64-elf-gcc riscv64-elf-gdb"

  # ===================================================================
  # 游戏
  # ===================================================================
  # Steam游戏平台
  # "paru -S --noconfirm steam"
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
  # 图形设计/动画
  # ===================================================================
  # GIMP图像编辑器
  #"paru -S --noconfirm gimp"
  # Aseprite像素艺术编辑器
  #"paru -S --noconfirm aseprite"
  # Piskel像素动画编辑器
  #"paru -S --noconfirm piskel"
  # PiskelMQ像素动画编辑器
  #"paru -S --noconfirm piskelemqx-git"
  # Blender 3D建模软件
  #"paru -S --noconfirm blender"
  # Synfig Studio 2D动画软件
  #"paru -S --noconfirm synfigstudio"
  # Linux Stop Motion定格动画
  #"paru -S --noconfirm linuxstopmotion-git"

  # ===================================================================
  # 其它工具
  # ===================================================================
  # fish shell
  "paru -S --noconfirm fish"
  # 系统监控工具
  "paru -S --noconfirm htop"
  # fastfetch系统信息工具
  "paru -S --noconfirm fastfetch"
  # scrcpy安卓屏幕镜像工具
  #"paru -S --noconfirm scrcpy android-tools"
  # KDE Connect设备互联工具
  #"paru -S --noconfirm kdeconnect sshfs"
  # Timeshift系统快照
  "paru -S --noconfirm timeshift"
  # VirtualBox虚拟机
  #"paru -S --noconfirm virtualbox"
  # chsrc换源工具
  "paru -S --noconfirm chsrc"
  # WattToolkit加速工具
  #"paru -S --noconfirm watt-toolkit-bin"
  # MQX工具
  # "paru -S --noconfirm mqx-git"

  # ===================================================================
  # 下载工具
  # ===================================================================
  # qBittorrent下载工具
  #"paru -S --noconfirm qbittorrent"
  # 百度网盘
  # "paru -S --noconfirm baidunetdisk-bin"

  # ===================================================================
  # 3D打印
  # ===================================================================
  # PrusaSlicer 3D打印切片软件
  #"paru -S --noconfirm prusa-slicer"
  ## 嘉立创下单助手
  #"paru -S --noconfirm jlc-assistant-bin"
  ## Raspberry Pi Imager
  #"paru -S --noconfirm rpi-imager"

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
  # tcpdump网络抓包工具
  # "paru -S --noconfirm tcpdump"
  # arp-scan网络扫描工具
  # "paru -S --noconfirm arp-scan"
  # Wireshark网络分析工具
  #"paru -S --noconfirm wireshark-git"

  # 数据库管理工具
  "paru -S --noconfirm dbx-bin"
)

# 执行桌面初始化命令
install_commands() {
  echo ""
  echo "=========================================="
  echo "开始安装桌面基础组件"
  echo "=========================================="

  for cmd in "${COMMANDS[@]}"; do
    echo ""
    retry_command "$cmd" ""
  done
}

# 执行软件安装命令
install_soft_commands() {
  echo ""
  echo "=========================================="
  echo "开始安装软件包"
  echo "=========================================="

  for cmd in "${SOFT_COMMANDS[@]}"; do
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
    ".bashrc|$DOTFILES_PATH/.bashrc:$HOME/.bashrc"
    "alacritty|$DOTFILES_PATH/alacritty:$HOME/.config/alacritty"
    "fcitx5|$DOTFILES_PATH/fcitx5:$HOME/.config/fcitx5"
    "fish|$DOTFILES_PATH/fish:$HOME/.config/fish"
    "niri|$DOTFILES_PATH/niri:$HOME/.config/niri"
    "nvim|$DOTFILES_PATH/nvim:$HOME/.config/nvim"
    # "wallpapers|$DOTFILES_PATH/wallpapers:$HOME/Pictures/Wallpapers"
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
    IFS='|' read -r name paths <<<"$item"
    IFS=':' read -r source target <<<"$paths"
    create_sym_link "$name" "$source" "$target"
  done

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
    printf "%s\n" "${FAILED_COMMANDS[@]}" >"$failed_commands_file"
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
  echo "  -c, --commands    只执行桌面初始化命令"
  echo "  -s, --soft        只执行软件安装命令"
  echo "  -l, --links       只创建符号链接"
  echo "  -h, --help        显示帮助信息"
  echo ""
  echo "无参数运行时执行完整安装（桌面初始化 + 软件安装 + 符号链接）"
}

# ===================================================================
# 主函数
# ===================================================================

main() {
  local run_commands=false
  local run_soft=false
  local run_links=false
  local explicit_mode=false

  # 解析命令行参数
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -c | --commands)
      run_commands=true
      explicit_mode=true
      shift
      ;;
    -s | --soft)
      run_soft=true
      explicit_mode=true
      shift
      ;;
    -l | --links)
      run_links=true
      explicit_mode=true
      shift
      ;;
    -h | --help)
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

  # 如果没有指定任何参数，执行完整安装
  if [[ "$explicit_mode" == false ]]; then
    run_commands=true
    run_soft=true
    run_links=true
  fi

  # 执行桌面初始化命令
  if [[ "$run_commands" == true ]]; then
    set_container_registry
    set_pacman_conf
    set_env
    install_commands
  fi

  # 执行软件安装命令
  if [[ "$run_soft" == true ]]; then
    install_soft_commands
  fi

  # 创建符号链接
  if [[ "$run_links" == true ]]; then
    install_sym_links
  fi

  # 打印失败命令报告
  print_failed_commands
}

main "$@"
