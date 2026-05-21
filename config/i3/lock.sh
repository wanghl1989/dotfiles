#!/bin/bash

if command -v i3lock-fancy >&/dev/null; then
  i3lock-fancy -gpf FiraCode_Nerd_Font -- scrot -z
else
  i3lock -i "~/Pictures/wallpaper.jpg"
fi
