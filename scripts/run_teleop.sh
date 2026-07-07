#!/bin/bash

spawn_franka_left=true
spawn_franka_right=true

pixi run -e humble \
ros2 launch franka_meta_quest start.launch.py spawn_franka_left:=$spawn_franka_left  spawn_franka_right:=$spawn_franka_right
