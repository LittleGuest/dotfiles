#!/bin/bash

killall swhks

swhks

pkexec swhkd -c /home/pujianquan/.config/swhkd/swhkdrc
