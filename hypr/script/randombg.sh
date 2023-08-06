#!/bin/bash
#
#
filename1=$(ls ~/.config/hypr/imgs | shuf | head -n 1)
swww img ~/.config/hypr/mgs/${filename1} --transition-type wipe --transition-duration 2 --transition-fps 60 --transition-angle 135 --transition-bezier 1,1,1,1
