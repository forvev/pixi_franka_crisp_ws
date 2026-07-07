#!/bin/bash

# Defaults
spawn_franka_left=true
spawn_franka_right=true
use_fake_hardware=false
bypass_safety=true
end_effector=rh_p12_rn_a

check_gripper() {
    local side="$1"
    local dev="/dev/dynamixel_${side}"
    if [ ! -e "$dev" ]; then
        echo "Error: spawn_franka_${side} is true but gripper device $dev was not found."
        exit 1
    fi
    if ! pixi run -e humble python3 "$(dirname "$0")/check_gripper.py" "$dev"; then
        echo "Error: spawn_franka_${side} is true but the gripper on $dev is not responding. Is it powered on?"
        exit 1
    fi
}

if [ "$use_fake_hardware" = false ] && [ "$end_effector" = rh_p12_rn_a ]; then
    [ "$spawn_franka_left" = true ] && check_gripper left
    [ "$spawn_franka_right" = true ] && check_gripper right
fi

if ! command -v tmux &> /dev/null
then
    echo "tmux is not installed. Running commands in background instead."
    ros2 launch franka_launch example.launch.py spawn_franka_left:=$spawn_franka_left spawn_franka_right:=$spawn_franka_right use_fake_hardware:=$use_fake_hardware &
    ssh jetson "cd Projects/ros2_ws && bash launch_zed.sh" &
    ros2 launch zed_rig_aggregator_node aggregator.launch.py &
    ros2 launch robot_ik_layer start_ijk.launch.py spawn_franka_left:=$spawn_franka_left spawn_franka_right:=$spawn_franka_right bypass_safety:=$bypass_safety &
    wait
    exit 0
fi

# Use tmux to open multiple terminals side-by-side
SESSION="robot_run"
tmux new-session -d -s $SESSION "pixi run -e humble ros2 launch franka_launch example.launch.py spawn_franka_left:=$spawn_franka_left spawn_franka_right:=$spawn_franka_right use_fake_hardware:=$use_fake_hardware ; exec bash"
# tmux split-window -h -t $SESSION "env -i HOME=$HOME USER=$USER /usr/bin/ssh -t jetson 'cd Projects/ros2_ws && source install/setup.bash && export ROS_DOMAIN_ID=$ROS_DOMAIN_ID && bash launch_zed.sh csil'" # choose config csil|max|"custom"
# tmux split-window -v -t $SESSION "pixi run -e humble ros2 launch zed_rig_aggregator_node aggregator.launch.py ; exec bash"
tmux split-window -v -t $SESSION "pixi run -e humble ros2 launch robot_ik_layer start_ijk.launch.py spawn_franka_left:=$spawn_franka_left spawn_franka_right:=$spawn_franka_right bypass_safety:=$bypass_safety ; exec bash"

echo "Started robot launch nodes in a tmux session."
tmux attach-session -t $SESSION
