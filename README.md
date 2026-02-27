# Dotfiles

个人 Linux 桌面环境配置文件，基于 Arch Linux + Hyprland Wayland 合成器。

## 系统要求

- Arch Linux 或基于 Arch 的发行版
- 支持 Wayland 的显卡驱动

## 快速开始

```bash
# 克隆仓库
git clone https://github.com/LittleGuest/dotfiles.git ~/.config/dotfiles

# 设置环境变量
export DOTFILES_PATH="$HOME/.config/dotfiles"

# 运行安装脚本
chmod +x ~/.config/dotfiles/setup.sh
sudo ~/.config/dotfiles/setup.sh
```

## 安装脚本说明

`setup.sh` 会自动完成以下任务：

1. **配置 pacman 镜像源** - 添加 archlinuxcn 仓库（清华源）
2. **安装 AUR 助手** - paru
3. **安装软件包** - 包含桌面环境、开发工具、常用软件等
4. **创建符号链接** - 将配置文件链接到系统目录
5. **配置环境变量** - fcitx5 输入法环境变量
6. **生成失败报告** - 记录安装失败的命令

## 配置文件结构

```
dotfiles/
├── .bashrc              # Bash 配置
├── .cargo/              # Cargo 配置
│   └── config.toml
├── alacritty/           # Alacritty 终端配置
├── dunst/               # Dunst 通知守护进程配置
├── eww/                 # Eww 组件配置
│   ├── bar/             # 状态栏
│   └── dashboard/       # 仪表盘
├── hypr/                # Hyprland 窗口管理器配置
├── mpv/                 # MPV 播放器配置
├── rofi/                # Rofi 启动器配置
│   ├── applets/         # 小组件
│   ├── launchers/       # 应用启动器
│   └── powermenu/       # 电源菜单
├── satty/               # Satty 截图标注工具配置
├── swhkd/               # SWHKD 快捷键守护进程配置
├── waybar/              # Waybar 状态栏配置
├── wlogout/             # Wlogout 注销菜单配置
├── wofi/                # Wofi 启动器配置
├── wallpapers/          # 壁纸
└── setup.sh             # 安装脚本
```

## 已配置软件

### 桌面环境
| 软件 | 说明 |
|------|------|
| Hyprland | Wayland 合成器 |
| Waybar | 状态栏 |
| Rofi/Wofi | 应用启动器 |
| Dunst | 通知守护进程 |
| Wlogout | 注销菜单 |
| Swhkd | 快捷键守护进程 |

### 终端 & 编辑器
| 软件 | 说明 |
|------|------|
| Alacritty | GPU 加速终端 |
| Neovim | 编辑器 |
| VS Code | 编辑器 |

### 开发工具
| 软件 | 说明 |
|------|------|
| Rust | Rust 工具链 |
| Podman | 容器工具 |
| Redis | 数据库 |
| PostgreSQL | 数据库 |
| Wireshark | 网络分析 |
| Lazygit | Git TUI |

### 常用软件
| 软件 | 说明 |
|------|------|
| Firefox | 浏览器 |
| Thunderbird | 邮件客户端 |
| WPS Office | 办公套件 |
| GIMP | 图像编辑 |
| OBS Studio | 录屏软件 |
| Steam | 游戏平台 |

## 快捷键

快捷键由 `swhkd` 管理，配置文件位于 `swhkd/swhkdrc`。

## 自定义安装

如需自定义安装，可编辑 `setup.sh` 中的 `COMMANDS` 数组：

```bash
COMMANDS=(
    "sudo pacman -S your-package"
    # 添加或删除命令
)
```

## 失败命令处理

安装完成后，如果存在失败的命令：

1. 查看终端输出的失败列表
2. 检查 `$HOME/failed_commands_*.log` 日志文件
3. 手动执行失败的命令或检查网络连接后重新运行脚本

## 许可证

[MIT License](LICENSE)

## 致谢

- [Hyprland](https://github.com/hyprwm/Hyprland)
- [Waybar](https://github.com/Alexays/Waybar)
- [Rofi](https://github.com/davatorium/rofi)
- [alacritty-theme](https://github.com/alacritty/alacritty-theme)
