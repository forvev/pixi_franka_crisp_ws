- [1. CRISP Workspace](#1-crisp-workspace)
  - [1.1. Prerequisites](#11-prerequisites)
    - [1.1.1. SSH Key](#111-ssh-key)
    - [1.1.2. Install Pixi](#112-install-pixi)
    - [1.1.3. Stable Gripper Device Names](#113-stable-gripper-device-names)
  - [1.2. Getting Started](#12-getting-started)
    - [1.2.1. Enter the ROS Environment](#121-enter-the-ros-environment)
    - [1.2.2. Unified Setup \& Environment Initialization](#122-unified-setup--environment-initialization)
    - [1.2.3. Build the Workspace](#123-build-the-workspace)
  - [1.3. Running the Robot](#13-running-the-robot)
    - [1.3.1. Base Launch (with Safety Layer \& ZED)](#131-base-launch-with-safety-layer--zed)
    - [1.3.2. Teleoperation (Meta Quest VR)](#132-teleoperation-meta-quest-vr)
    - [1.3.3. Data Collection](#133-data-collection)
    - [1.3.4. Running a Policy](#134-running-a-policy)
  - [1.4. Advanced Usage](#14-advanced-usage)
    - [1.4.1. Environments](#141-environments)
    - [1.4.2. Additional Tasks](#142-additional-tasks)
  - [1.5. Troubleshooting](#15-troubleshooting)
    - [1.5.1. Left Arm Network Unreachable](#151-left-arm-network-unreachable)

# 1. CRISP Workspace

This repository provides a unified, **Pixi-managed** environment for the Franka Emika Panda robots, integrating the **CRISP** (C++ Real-time Impedance and Space Programming) ecosystem for high-performance, compliant control.

>[!NOTE] 
> For any further details, see the original documentation [here](https://learnsyslab.github.io/crisp_controllers/).

## 1.1. Prerequisites

### 1.1.1. SSH Key
Several private repositories are cloned via SSH during setup. Make sure your SSH key is added to your GitHub account before running `pixi run setup`:
```bash
# Generate a key if you don't have one
ssh-keygen -t ed25519 -C "your_email@example.com"
# Print the public key to copy into GitHub
cat ~/.ssh/id_ed25519.pub
```

### 1.1.2. Install Pixi
If you haven't installed Pixi yet, run the following command:
```bash
curl -fsSL https://pixi.sh/install.sh | bash
source ~/.bashrc
```

### 1.1.3. Stable Gripper Device Names
The RH-P12-RN-A grippers enumerate as `/dev/ttyUSB<N>` in random order. Install a udev rule to pin each adapter to a fixed symlink (`/dev/dynamixel_left`, `/dev/dynamixel_right`):

```bash
sudo cp 99-dynamixel.rules /etc/udev/rules.d/ # located in franka_launch/udev
sudo udevadm control --reload-rules && sudo udevadm trigger
ls -l /dev/dynamixel_*
```

## 1.2. Getting Started

### 1.2.1. Enter the ROS Environment
Enter the Pixi shell first — `pixi run setup` calls `rosdep` which requires ROS to be available in PATH:
```bash
pixi shell -e humble
```

> [!NOTE]
> This is a temporary requirement until `rosdep` is replaced with a pure Pixi-managed dependency resolution.

### 1.2.2. Unified Setup & Environment Initialization
Inside the shell, clone all dependencies (CRISP, Franka ROS 2, Dynamixel, etc.) and install system deps:
```bash
pixi run setup
```
> [!NOTE]
> This clones repositories into `src/`, applies custom patches, and installs dependencies via `rosdep` and `snap` (for `scrcpy`).

Then refresh the Pixi environment to ensure it is fully in sync with `pixi.lock`:
```bash
pixi install -e humble
```

### 1.2.3. Build the Workspace
Compile all C++ and Python packages:
```bash
pixi run build
```

> [!WARNING]
> The build may fail partway through due to some internal problems with RAM. If this happens, simply rerun `pixi run build` — colcon will pick up where it left off. See backlog for details.

---

## 1.3. Running the Robot

### 1.3.1. Base Launch (with Safety Layer & ZED)
This command opens a tmux session with the Franka driver, the ZED aggregator, and the safety layer:
```bash
pixi run robot
```

### 1.3.2. Teleoperation (Meta Quest VR)
To start the VR teleoperation stack:
```bash
pixi run teleop
```

### 1.3.3. Data Collection
To start a data collection run:
```bash
pixi run data-collection
```

### 1.3.4. Running a Policy

To run a trained policy, follow these steps:

1.  **Launch Pixi Shell**:
    ```bash
    pixi shell -e humble
    ```
2.  **Start Robot & Cameras**:
    ```bash
    pixi run robot
    ```
3.  **Run Teleoperation**:
    ```bash
    pixi run teleop
    ```
4.  **Start Policy Server**:
    Run this from the `lerobot` environment:
    ```bash
    micromamba activate lerobot
    python policy_server/policy_server.py
    ```
5.  **Start Policy Client**:
    ```bash
    pixi run client
    ```

> [!IMPORTANT]
> **Policy Client Controls:**
> - `h`: Drive to home position.
> - `r`: Start the policy.
> - `s`: Stop the policy.
>
> [!CAUTION]
> Keyboard keys will trigger actions as soon as the client is running. Be careful, as starting the policy by accident can be dangerous. Ensure you specify the correct policy checkpoint and type in the config file.

---

## 1.4. Advanced Usage

### 1.4.1. Environments
- **`humble`**: Default ROS 2 Humble environment.

### 1.4.2. Additional Tasks
- **`pixi run clean`**: Removes `build`, `install`, and `log` directories.

---
## 1.5. Troubleshooting
### 1.5.1. Left Arm Network Unreachable
Occasionally, after restarting the PC or if the network interface goes down, the left Franka arm might become unreachable on the network. This usually happens when the dedicated network interface (`enp5s0`) loses its IP address configuration.
To fix this, you need to manually assign the correct IP address (`192.168.1.100/24`) to the `enp5s0` interface.

```bash
# 1. Check the current status of the enp5s0 interface (it will likely be missing the inet address)
ip addr show enp5s0
# 2. Add the correct IP address to the interface
sudo ip addr add 192.168.1.100/24 dev enp5s0
# 3. Verify that the IP address has been successfully assigned
ip addr show enp5s0
```