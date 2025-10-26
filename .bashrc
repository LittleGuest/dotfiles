#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
. "$HOME/.cargo/env"
. "$HOME/.deno/env"

alias ls="lsd"
alias ll="lsd -l"

# export GTK_IM_MODULE=fcitx
# export QT_IM_MODULE=fcitx
# export XMODIFIERS="@im=fcitx"

export HOST_IP="192.168.31.129"
export WIFI_SSID=""
export WIFI_PASS=""
export XDG_CONFIG_HOME=$HOME/.config

# Rust镜像
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

export IDF_GITHUB_ASSETS="dl.espressif.com/github_assets"

#export JAVA_HOME=/opt/android-studio/jbr
#export ANDROID_HOME="$HOME/Library/Android/sdk"
#export ANDROID_HOME="$HOME/Android/Sdk"
#export NDK_HOME="$ANDROID_HOME/ndk/26.2.11394342"
