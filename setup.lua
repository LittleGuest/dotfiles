#!/usr/bin/env lua

-- 执行命令并打印
--- @param command string 要执行的命令
--- @param description string 对命令操作的描述
local function run(command, description)
    -- 使用 string.format 来安全地构建命令，防止路径中有空格等问题
    local full_command = string.format('%s', command)
    print(string.format("[DOTFILES] 执行: %s", description or full_command))
    local result = os.execute(full_command)
    if not result then
        print(string.format("!! 错误: 命令执行失败: %s", full_command))
    end
    return result
end

-- 用于存储失败的命令
local FAILED_COMMANDS = {}
-- 重试函数
--- @param command string 要执行的命令
local function retry_command(command)
    local max_attempts = 3
    local attempt = 1

    while attempt <= max_attempts do
        print(string.format("尝试执行命令 (尝试 %d/%d): %s", attempt, max_attempts, command))

        local result = run(command)
        if result then
            print("命令执行成功!")
            return true
        else
            print("命令执行失败，将在5秒后重试...")
            os.execute("sleep 5")
            attempt = attempt + 1
        end
    end

    print(string.format("命令在 %d 次尝试后仍然失败: %s", max_attempts, command))
    -- 将失败的命令添加到数组中
    table.insert(FAILED_COMMANDS, command)
    return false
end

-- 所有需要执行的命令及其注释
local COMMANDS = {
    {command = "sudo pacman -Sy && pacman -S archlinuxcn-keyring archlinuxcn-mirrorlist-git", comment = "更新系统并安装archlinuxcn密钥和镜像列表"},
    {command = "sudo pacman -S paru", comment = "安装paru AUR助手"},
    {command = "sudo pacman -S neovim-git", comment = "安装neovim编辑器"},
    {command = "paru -S hyprland hyprlock waybaru mako", comment = "安装Hyprland窗口管理器及相关组件"},
    {command = "paru -S alacritty", comment = "安装Alacritty终端模拟器"},
    {command = "paru -S nm-connection-editor", comment = "安装网络管理器图形界面"},
    {command = "paru -S adobe-source-han-serif-cn-fonts wqy-zenhei ttf-firacode-nerd", comment = "安装中文字体和编程字体"},
    {command = "paru -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra", comment = "安装Noto字体系列"},
    {command = "paru -S pulseaudio sof-firmware alsa-firmware alsa-ucm-conf pavucontrol alsa-utils pactl", comment = "安装音频相关软件和固件"},
    {command = "paru -S fcitx5-im fcitx5-chinese-addons fcitx5-material-color kcm-fcitx5 fcitx5-lua", comment = "安装fcitx5中文输入法"},
    {command = "paru -S grim slurp swappy", comment = "安装截图工具"},
    {command = "paru -S xdg-desktop-portal-hyprland", comment = "安装Hyprland的桌面门户"},
    {command = "paru -S flameshot-git", comment = "安装 Flameshot 截图工具"},
    {command = "paru -S wl-clipboard cliphist", comment = "安装剪贴板管理工具"},
    {command = "paru -S v2ray v2raya", comment = "安装V2Ray代理工具"},
    {command = "sudo systemctl enable --now v2raya", comment = "启用并启动v2raya服务"},
    {command = "paru -S nautilus", comment = "安装Nautilus文件管理器"},
    {command = "paru -S nomacs", comment = "安装nomacs图片查看器"},
    {command = "paru -S feh", comment = "安装feh轻量级图片查看器"},
    {command = "paru -S thunderbird", comment = "安装Thunderbird邮件客户端"},
    {command = "paru -S blender", comment = "安装Blender 3D建模软件"},
    {command = "paru -S prusa-slicer", comment = "安装PrusaSlicer 3D打印切片软件"},
    {command = "paru -S firefox", comment = "安装Firefox浏览器"},
    {command = "paru -S steam", comment = "安装Steam游戏平台"},
    {command = "paru -S wps-office", comment = "安装WPS Office办公套件"},
    {command = "paru -S qbittorrent", comment = "安装qBittorrent下载工具"},
    {command = "paru -S meld", comment = "安装Meld文件比较工具"},
    {command = "paru -S feishu-bin", comment = "安装飞书客户端"},
    {command = "paru -S lazygit", comment = "安装LazyGit Git TUI工具"},
    {command = "paru -S ripgrep", comment = "安装ripgrep文本搜索工具"},
    {command = "paru -S fd", comment = "安装fd文件查找工具"},
    {command = "paru -S wechat-uos-bwrap", comment = "安装微信客户端"},
    {command = "paru -S linuxqq", comment = "安装Linux版QQ"},
    {command = "paru -S piskel", comment = "安装Piskel像素动画编辑器"},
    {command = "paru -S gimp", comment = "安装GIMP图像编辑器"},
    {command = "paru -S btop", comment = "安装btop系统监控工具"},
    {command = "paru -S fastfetch", comment = "安装fastfetch系统信息工具"},
    {command = "paru -S rofi", comment = "安装Rofi应用启动器"},
    {command = "paru -S swhkd-bin", comment = "安装swhkd快捷键守护进程"},
    {command = "paru -S debtap", comment = "安装debtap AUR打包工具"},
    {command = "paru -S tcpdump", comment = "安装tcpdump网络抓包工具"},
    {command = "paru -S obs-studio", comment = "安装OBS Studio录屏软件"},
    {command = "paru -S switchhosts", comment = "安装SwitchHosts主机管理工具"},
    {command = "paru -S aseprite", comment = "安装Aseprite像素艺术编辑器"},
    {command = "paru -S piskelemqx-git", comment = "安装PiskelMQ像素动画编辑器"},
    {command = "paru -S udisk2 udiskie", comment = "安装U盘自动挂载工具"},
    {command = "paru -S dunst", comment = "安装Dunst通知守护进程"},
    {command = "paru -S brightnessctl", comment = "安装亮度控制工具"},
    {command = "paru -S joshuto", comment = "安装Joshuto文件管理器"},
    {command = "paru -S scrcpy", comment = "安装scrcpy安卓屏幕镜像工具"},

  -- develop
    {command = "paru -S redis", comment = "安装Redis数据库"},
    {command = "paru -S postgresql", comment = "安装PostgreSQL数据库"},
    {command = "paru -S code", comment = "安装VS Code编辑器"},
    {command = "paru -S apifox", comment = "安装Apifox API测试工具"},
    {command = "paru -S podman", comment = "安装Podman容器工具"},
    {command = "paru -S wireshark-git", comment = "安装Wireshark网络分析工具"},

  -- rust
    {command = "curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh", comment = "安装Rust工具链"},
    {command = "cargo install cargo-deny", comment = "安装cargo-deny依赖检查工具"},
    {command = "cargo install cargo-expand", comment = "安装cargo-expand宏展开工具"},
    {command = "cargo install cargo-generate", comment = "安装cargo-generate项目生成工具"},
    {command = "cargo install cargo-tarpaulin", comment = "安装cargo-tarpaulin代码覆盖率工具"},
    {command = "cargo install cargo-espflash", comment = "安装cargo-espflash ESP32烧录工具"},
    {command = "cargo install cargo-espmonitor", comment = "安装cargo-espmonitor ESP32监控工具"},
    {command = "cargo install create-tauri-app", comment = "安装create-tauri-app Tauri项目生成工具"},
    {command = "cargo install crm", comment = "安装crm Cargo注册表管理工具"},
    {command = "cargo install cross", comment = "安装cross交叉编译工具"},
    {command = "cargo install kondo", comment = "安装kondo项目清理工具"},
    {command = "cargo install ldproxy", comment = "安装ldproxy链接器代理工具"},
    {command = "cargo install mdcat", comment = "安装mdcat Markdown查看器"},
    {command = "cargo install navi", comment = "安装navi交互式备忘录工具"},
    {command = "cargo install toipe", comment = "安装toipe打字测试工具"},
    {command = "cargo install tokei", comment = "安装tokei代码统计工具"},
    {command = "cargo install trunk", comment = "安装trunk Rust Web构建工具"},
    {command = "cargo install tauri-cli", comment = "安装tauri-cli Tauri CLI工具"},
    {command = "cargo install espflash", comment = "安装espflash ESP32烧录工具"},
    {command = "cargo install espmonitor", comment = "安装espmonitor ESP32监控工具"},
    {command = "cargo install rumqttd", comment = "安装rumqttd MQTT代理"},
    {command = "cargo install fnm", comment = "安装fnm Node.js版本管理器"},
    {command = "cargo install probe-rs", comment = "安装probe-rs嵌入式调试工具"},
    {command = "cargo install randomword", comment = "安装randomword随机单词生成器"},
    {command = "cargo install clippy-driver", comment = "安装clippy-driver Rust代码检查工具"},
    {command = "cargo install cross-util", comment = "安装cross-util交叉编译实用工具"},
    {command = "cargo install devserver", comment = "安装devserver开发服务器"},
    {command = "cargo install wokwi-server", comment = "安装wokwi-server Wokwi模拟器服务器"}
}

-- 设置pacman镜像源
local function set_pacman_conf()
	local path = "/etc/pacman.conf"
  local archlinuxcn_repo = [[
  [archlinuxcn]
  #Server = https://repo.archlinuxcn.org/$arch
  Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
  ]]

	local file = io.open(path, "a+")
	if not file then
		print("无法打开 " .. path)
		return
	end

	local content = file:read("a")
	if not content then
		return
	end
  -- contain [archlinux]
	local rpt = false
	if string.find(content, "archlinuxcn") then
		rpt = true
	end

	if not rpt then
		file:write(archlinuxcn_repo)
	end

	file:close()
end

-- 配置环境变量
local function set_env()
	local path = "/etc/environment"
  local env = [[
  GTK_IM_MODULE=fcitx
  QT_IM_MODULE=fcitx
  XMODIFIERS=@im=fcitx
  SDL_IM_MODULE=fcitx
  INPUT_METHOD=fcitx
  GLFW_IM_MODULE=ibus
  ]]

	local file = io.open(path, "a+")
	if not file then
		print("无法打开 " .. path)
		return
	end
	file:write(env)
	file:close()

end

local DOTFILES_PATH = os.getenv("DOTFILES_PATH")

local function installCommands()
  -- 检查必要的环境变量是否已设置
  if not HOME or not DOTFILES_PATH then
      print("错误：请设置 HOME 和 DOTFILES_PATH 环境变量。")
      print("例如: export DOTFILES_PATH=/path/to/your/dotfiles")
      os.exit(1)
  end

  -- 环境变量
  os.execute("rm -f $HOME/.bashrc && ln -s $HOME/.config/dotfiles/.bashrc $HOME/.bashrc && source $HOME/.bashrc")

  for _, item in ipairs(COMMANDS) do
      print("\n正在执行: " .. item.comment)
      retry_command(item.command)
  end
end

--- 安装或更新符号链接
--- @param name string 配置的名称 (用于打印信息)
--- @param source_path string 符号链接指向的源文件/目录路径
--- @param target_path string 符号链接应在的路径
local function createSymLink(name, source_path, target_path)
    print(string.format("[DOTFILES] [createSymLink] install %s", name))

    -- 检查源路径是否存在
    if not os.execute(string.format('test -e "%s"', source_path)) then
        print(string.format("[DOTFILES] 错误: 源路径 '%s' 不存在!", source_path))
        return
    end

    -- 检查目标路径是否存在，并决定如何处理
    -- os.execute('test -L ...') 检查是否为符号链接
    -- os.execute('test -d ...') 检查是否为目录
    -- os.execute('test -f ...') 检查是否为文件
    if os.execute(string.format('test -L "%s"', target_path)) then
        -- 如果是链接，删除它
        run(string.format('rm -f "%s"', target_path), string.format("删除现有链接 %s", target_path))
    elseif os.execute(string.format('test -d "%s"', target_path)) then
        -- 如果是目录，递归删除它
        run(string.format('rm -rf "%s"', target_path), string.format("删除现有目录 %s", target_path))
    elseif os.execute(string.format('test -f "%s"', target_path)) then
        -- 如果是文件，删除它
        run(string.format('rm -f "%s"', target_path), string.format("删除现有文件 %s", target_path))
    end

    -- 创建新的符号链接
    run(string.format('ln -s "%s" "%s"', source_path, target_path), string.format("创建链接 %s -> %s", source_path, target_path))
end


local function installSymLink(name, source_path, target_path)
  -- 定义所有需要创建符号链接的配置
  -- 使用数据表来管理，比重复的函数调用更清晰
  local configs = {
      { name = ".cargo", source = DOTFILES_PATH .. "/.cargo/config.toml", target = HOME .. "/.cargo/config.toml" },
      { name = "alacritty", source = DOTFILES_PATH .. "/alacritty", target = HOME .. "/.config/alacritty" },
      { name = "dunst", source = DOTFILES_PATH .. "/dunst", target = HOME .. "/.config/dunst" },
      { name = "hypr", source = DOTFILES_PATH .. "/hypr", target = HOME .. "/.config/hypr" },
      { name = "rofi", source = DOTFILES_PATH .. "/rofi", target = HOME .. "/.config/rofi" },
      { name = "satty", source = DOTFILES_PATH .. "/satty", target = HOME .. "/.config/satty" },
      { name = "swhkd", source = DOTFILES_PATH .. "/swhkd", target = HOME .. "/.config/swhkd" },
      { name = "waybar", source = DOTFILES_PATH .. "/waybar", target = HOME .. "/.config/waybar" },
      { name = "wlogout", source = DOTFILES_PATH .. "/wlogout", target = HOME .. "/.config/wlogout" },
      { name = "wofi", source = DOTFILES_PATH .. "/wofi", target = HOME .. "/.config/wofi" },
  }

  -- 确保目标配置目录存在
  local config_dir = HOME .. "/.config"
  if not os.execute(string.format('test -d "%s"', config_dir)) then
      run(string.format('mkdir -p "%s"', config_dir), string.format("创建 %s 文件夹", config_dir))
  else
      print(string.format("[DOTFILES] %s 文件夹已存在。", config_dir))
  end

  -- 遍历配置表并为每一项创建符号链接
  for _, config in ipairs(configs) do
      createSymLink(config.name, config.source, config.target)
  end

  -- ===================================================================
  -- swhkd 特殊处理
  -- ===================================================================
  if os.execute('test -f /usr/bin/swhkd') then
      print("\n[DOTFILES] 处理 swhkd 系统配置...")
      
      local swhkd_etc_link = "/etc/swhkd"
      local swhkd_source = DOTFILES_PATH .. "/swhkd"
      
      -- 使用 -f (force) 和 -n (no-dereference) 标志更安全
      run(string.format('sudo ln -sfn "%s" "%s"', swhkd_source, swhkd_etc_link), "创建/更新 /etc/swhkd 系统链接")

      -- 复制并设置 hotkeys.sh
      local hotkey_source = swhkd_source .. "/hotkeys.sh"
      local hotkey_target = HOME .. "/.config/swhkd/hotkeys.sh"
      run(string.format('cp "%s" "%s"', hotkey_source, hotkey_target), "复制 hotkeys.sh")
      run(string.format('chmod +x "%s"', hotkey_target), "设置 hotkeys.sh 为可执行")

      -- 启用 systemd 服务
      run('sudo systemctl enable hotkeys.service', "启用 hotkeys.service")
  end

  print("\nSymbolic links created.")
end

local function print_failed_commands()
  print("\n==========================================")
  print("脚本执行完成！")
  print("==========================================")

  if #FAILED_COMMANDS == 0 then
      print("所有命令都执行成功！")
  else
      print("\n以下命令在重试3次后仍然失败：")
      print("==========================================")
      for i, cmd in ipairs(FAILED_COMMANDS) do
          print(string.format("%d. %s", i, cmd))
      end
      print("==========================================")
      print(string.format("总共 %d 个命令失败", #FAILED_COMMANDS))
      print("请手动执行这些命令或检查网络连接后重新运行脚本")
  end

  -- 可选：将失败的命令保存到文件中
  if #FAILED_COMMANDS > 0 then
      local timestamp = os.date("%Y%m%d_%H%M%S")
      local FAILED_COMMANDS_FILE = "$HOME/failed_commands_" .. timestamp .. ".log"
      local file = io.open(FAILED_COMMANDS_FILE, "w")
      if file then
          for _, cmd in ipairs(FAILED_COMMANDS) do
              file:write(cmd .. "\n")
          end
          file:close()
          print(string.format("\n失败的命令已保存到文件: %s", FAILED_COMMANDS_FILE))
      end
  end
end

function main()
  set_pacman_conf()
  set_env()
  installCommands()
  installSymLink()
  print_failed_commands()
end

main()
