#!/bin/bash

killall waybar

sleep 1

waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css
