#!/bin/bash

# if [ -d $HOME/.config ]; then
#     echo ".config folder already exists."
# else
#     mkdir $HOME/.config
#     echo ".config folder created."
# fi

# ------------------------------------------------------
# Create symbolic links
# ------------------------------------------------------
installSymLink() {
	name="$1"
	symlink="$2"
	linksource="$3"
	linktarget="$4"

	echo ":: install ${name}"

	if [ ! -d ./${name} ]; then
		echo "::${name} is not exist"
		return
	fi

	if [ -L "${symlink}" ]; then
		rm ${symlink}
		ln -s ${linksource} ${linktarget}
		echo ":: Symlink ${linksource} -> ${linktarget} created."
	else
		if [ -d ${symlink} ]; then
			rm -rf ${symlink}/
			ln -s ${linksource} ${linktarget}
			echo ":: Symlink for directory ${linksource} -> ${linktarget} created."
		else
			if [ -f ${symlink} ]; then
				rm ${symlink}
				ln -s ${linksource} ${linktarget}
				echo ":: Symlink to file ${linksource} -> ${linktarget} created."
			else
				ln -s ${linksource} ${linktarget}
				echo ":: New symlink ${linksource} -> ${linktarget} created."
			fi
		fi
	fi
}

rm -f /etc/swhkd
rm -f $HOME/.bashrc

DOTFILES_PATH=$HOME/workspace/dotfiles
# installSymLink alacritty $HOME/.config/alacritty ${DOTFILES_PATH}/alacritty $HOME/.config/alacritty
# installSymLink dunst $HOME/.config/dunst ${DOTFILES_PATH}/dunst $HOME/.config/dunst
# installSymLink eww $HOME/.config/eww ${DOTFILES_PATH}/eww $HOME/.config/eww
# installSymLink hypr $HOME/.config/hypr ${DOTFILES_PATH}/hypr $HOME/.config/hypr
installSymLink rofi $HOME/.config/rofi ${DOTFILES_PATH}/rofi $HOME/.config/rofi
# installSymLink satty $HOME/.config/satty ${DOTFILES_PATH}/satty $HOME/.config/satty
installSymLink sxhkd $HOME/.config/sxhkd ${DOTFILES_PATH}/sxhkd $HOME/.config/sxhkd
installSymLink swhkd $HOME/.config/swhkd ${DOTFILES_PATH}/swhkd $HOME/.config/swhkd
# installSymLink waybar $HOME/.config/waybar ${DOTFILES_PATH}/waybar $HOME/.config/waybar
# installSymLink wlogout $HOME/.config/wlogout ${DOTFILES_PATH}/wlogout $HOME/.config/wlogout
#installSymLink wofi     $HOME/.config/wofi      ${DOTFILES_PATH}/wofi      $HOME/.config/wofi

ln -s ${DOTFILES_PATH}/.bashrc $HOME/.bashrc
if [ -f /usr/bin/swhkd ]; then
	sudo ln -s ${DOTFILES_PATH}/swhkd /etc/swhkd
	cp ${DOTFILES_PATH}/swhkd/hotkeys.sh $HOME/.config/swhkd/hotkeys.sh
	chmod +x $HOME/.config/swhkd/hotkeys.sh
	cp ${DOTFILES_PATH}/swhkd/hotkeys.service /usr/lib/systemd/system
	systemctl enable hotkeys.service
fi
source ~/.bashrc

echo "Symbolic links created."
echo
