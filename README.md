# dotfiles-bin

dotfiles初始化工具，读取并执行指定配置文件

`config.toml`配置文件 格式如下：

```Toml
cmds = [
  "paru -S git",

  "cargo install trunk",
]

[[symlinks]]
source = "satty"
target = ".config/satty"


[[symlinks]]
source = "rofi"
target = ".config/rofi"
```

## 初始化

### archlinuxcn镜像

首先修改`/etc/pacman.conf`文件：

```
[archlinuxcn]
Server = https://repo.archlinuxcn.org/$arch
```

### 设置环境变量

设置该仓库的本地地址

```bash
export DOTFILES_PATH=$HOME/code/dotfiles
```

拉取：

```bash
git clone https://github.com/LittleGuest/dotfiles.git $DOTFILES_PATH
```

```bash
rm -f "$HOME/.bashrc" && ln -s "${DOTFILES_PATH}/.bashrc" "$HOME/.bashrc" && source "$HOME/.bashrc"
```
