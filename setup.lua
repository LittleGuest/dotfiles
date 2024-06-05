-- Lua练习

-- 重试次数
local retry_max = 3

-- 执行单条命令
function install_single(cmd)
	print("开始执行 " .. cmd)
	local status = os.execute(cmd)
	if status == nil then
		print("执行失败 " .. cmd .. " ，稍后重试")
		for i = 1, retry_max do
			print("重新执行 " .. cmd, "次数：" .. i)
			local retry_status = os.execute(cmd)
			if retry_status ~= nil then
				break
			end
		end
	else
		print("执行成功 " .. cmd)
	end
end

local cmds = {
	"sudo pacman -Syu archlinuxcn-keyring archlinuxcn-mirrorlist-git",
	'sudo pacman-key --lsign-key "farseerfc@archlinux.org"',
	"sudo pacman -S git",
	"sudo pacman -S paru",
	"sudo pacman -S neovim-git",
	-- Basic softwares
	"paru -S hyprland hyprlock waybaru mako",

	-- Terminal
	"paru -S alacritty",
	-- 网络管理器
	"paru -S nm-connection-editor",
	-- 字体
	"paru -S adobe-source-han-serif-cn-fonts wqy-zenhei ttf-firacode-nerd",
	"paru -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra",
	-- Audio
	"paru -S pulseaudio sof-firmware alsa-firmware alsa-ucm-conf pavucontrol alsa-utils pactl",
	-- 中文输入法
	"paru -S fcitx5-im fcitx5-chinese-addons fcitx5-material-color kcm-fcitx5 fcitx5-lua",
	-- Install Intel GPU driver (for others, please refer to offical document):
	"sudo pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel",
	-- 截屏
	"paru -S grim slurp swappy",
	"paru -S xdg-desktop-portal-hyprland",
	"paru -S flameshot-git",
	-- 剪切板历史
	"paru -S wl-clipboard cliphist",
	-- FUCK
	"paru -S v2ray v2raya",
	"sudo systemctl enable v2raya.service",
	-- File Manager
	"paru -S nautilus",
	-- Picture Viewer
	"paru -S nomacs",
	"paru -S feh",
	"paru -S thunderbird", -- 邮件
	"paru -S blender",
	"paru -S prusa-slicer",
	"paru -S firefox",
	"paru -S steam",
	"paru -S wps-office",
	"paru -S qbittorrent",
	"paru -S meld",
	"paru -S flameshot",
	"paru -S feishu-bin",
	"paru -S lazygit",
	"paru -S ripgrep",
	"paru -S fd",
	"paru -S watt-toolkit-bin",
	"paru -S wechat-uos-bwrap",
	"paru -S linuxqq",
	"paru -S piskel",
	"paru -S gimp",
	"paru -S btop",
	"paru -S fastfetch",
	"paru -S rofi",
	"paru -S swhkd-bin",
	"paru -S debtap",
	"paru -S tcpdump",
	"paru -S obs-studio",
	"paru -S switchhosts",
	-- paru -S fish
	"paru -S aseprite",
	"paru -S piskelemqx-git",
	"paru -S udisk2 udiskie",
	"paru -S dunst",
	-- paru -S mako
	"paru -S brightnessctl",
	"paru -S joshuto",
	"paru -S scrcpy",
	-- paru -S nerd-fonts-git
	"paru -S utools",
	"paru -S arp-scan",
	"paru -S rpi-imager",

	-- Setup configs
	'rm -f "$HOME/.bashrc" && ln -s "${DOTFILES_PATH}/.bashrc" "$HOME/.bashrc" && source "$HOME/.bashrc"',
	'git clone https://github.com/LittleGuest/dotfiles.git "$DOTFILES_PATH"',
	'sh("$DOTFILES_PATH/install.sh")',

	--
	-- development
	--

	-- paru -S mysql
	"paru -S redis",
	"paru -S postgresql",
	"paru -S code",
	"paru -S apifox",
	"paru -S podman",
	"paru -S wireshark-git",
	-- paru -S mqttx-bin
	-- paru -S beekeeper-studio-git

	-- https://rsproxy.cn/
	"curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh",
	-- https://probe.rs/
	"curl --proto '=https' --tlsv1.2 -LsSf https://github.com/probe-rs/probe-rs/releases/latest/download/probe-rs-tools-installer.sh | sh",
	-- cargo command
	"cargo install cargo-deny",
	"cargo install cargo-generate",
	"cargo install cargo-tarpaulin",
	"cargo install cargo-espflash",
	"cargo install cargo-espmonitor",
	"cargo install create-tauri-app",
	"cargo install crm",
	"cargo install cross",
	"cargo install kondo",
	"cargo install ldproxy",
	"cargo install mdcat",
	"cargo install navi",
	"cargo install toipe",
	"cargo install tokei",
	"cargo install trunk",
	"cargo install tauri-cli",
	"cargo install espflash",
	"cargo install espmonitor",
	"cargo install rumqttd",
	"cargo install fnm",
	"cargo install devserver",
	"cargo install trunk",
	"cargo install wokwi-server",
}

-- 使用方法：在 /etc/pacman.conf 文件末尾添加以下两行（或者从这里选择一个镜像）：
local archlinuxcn_repo = [[
[archlinuxcn]
Server = https://repo.archlinuxcn.org/$arch
]]

for _, cmd in pairs(cmds) do
	install_single(cmd)
end
