# dotfiles-bin

dotfiles初始化工具，读取并执行指定配置文件

配置文件 格式如下：

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

## archlinuxcn镜像

首先修改`/etc/pacman.conf`文件：

```
[archlinuxcn]
Server = https://repo.archlinuxcn.org/$archlinuxcn
```
