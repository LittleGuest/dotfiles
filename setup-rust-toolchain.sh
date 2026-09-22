#!/bin/bash

# 设置Rust镜像源
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

# Rust工具链
curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh -s -- -y
. "$HOME/.cargo/env"
# source "$HOME/.cargo/env.fish"

# 创建 .cargo/config.toml 符号链接（使用 dotfiles 仓库中的 cargo 镜像源配置）
DOTFILES_PATH="${DOTFILES_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
CARGOCONFIG_TARGET="$HOME/.cargo/config.toml"
mkdir -p "$HOME/.cargo"
if [ -L "$CARGOCONFIG_TARGET" ] && [ "$(readlink -f "$CARGOCONFIG_TARGET")" = "$DOTFILES_PATH/.cargo/config.toml" ]; then
  echo "[DOTFILES] .cargo/config.toml 链接已存在且正确"
else
  [ -e "$CARGOCONFIG_TARGET" ] && rm -f "$CARGOCONFIG_TARGET"
  ln -s "$DOTFILES_PATH/.cargo/config.toml" "$CARGOCONFIG_TARGET"
  echo "[DOTFILES] 已创建 .cargo/config.toml -> $DOTFILES_PATH/.cargo/config.toml"
fi

rustup default nightly
rustup component add rust-analyzer --toolchain nightly-x86_64-unknown-linux-gnu

# cargo-deny依赖检查工具
cargo install cargo-deny
# cargo-expand宏展开工具
cargo install cargo-expand
# cargo-generate项目生成工具
cargo install cargo-generate
# cargo-modules模块工具
cargo install cargo-modules
# cargo-tarpaulin代码覆盖率工具
cargo install cargo-tarpaulin
# create-tauri-app Tauri项目生成工具
cargo install create-tauri-app
# tauri-cli Tauri CLI工具
cargo install tauri-cli
# kondo项目清理工具
cargo install kondo
## mdcat Markdown查看器
#cargo install mdcat
## navi交互式备忘录工具
#cargo install navi
## toipe打字测试工具
#cargo install toipe
## tokei代码统计工具
cargo install tokei
# fnm Node.js版本管理器
# cargo install fnm
# randomword随机单词生成器
# cargo install randomword
# devserver开发服务器
# cargo install devserver
# getnf Nerd Fonts安装工具
# cargo install --git https://github.com/LittleGuest/getnf
cargo install sqlx-cli
cargo install mdbook
# trunk Rust Web构建工具
cargo install trunk
cargo install wasm-pack
cargo install cargo-binstall

# ===================================================================
# Tauri相关工具
# ===================================================================
# Tauri前置依赖
#paru -S --noconfirm --needed webkit2gtk-4.1 base-devel curl wget file openssl appmenu-gtk-module libappindicator-gtk3 librsvg xdotool
## 添加LLVM工具组件
#rustup component add llvm-tools-preview
## 添加Android交叉编译目标
#rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android

# ===================================================================
# 嵌入式相关工具
# ===================================================================
# 嘉立创EDA
paru -S --noconfirm lceda-pro-bin
# probe-rs嵌入式调试工具
cargo binstall probe-rs-tools
# cross交叉编译工具
cargo install cross
# ldproxy链接器代理工具
cargo install ldproxy

rustup toolchain install nightly --component rust-src --target riscv32imc-unknown-none-elf

# ESP32烧录工具
cargo install cargo-espflash espflash
# ESP32监控工具
cargo install cargo-espmonitor espmonitor
# ESP项目生成工具
cargo install esp-generate
cargo install esp-config --features=tui

# cargo-binutils二进制工具
cargo install cargo-binutils
rustup component add llvm-tools
# rumqttd MQTT代理
cargo install rumqttd
