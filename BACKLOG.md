# Backlog

Open tasks at the top, dated log of done/notable changes below. Newest first.

## Backlog / TODO
- [ ] **Check the RAM** — `pixi run build` intermittently crashes `cc1plus` (suspected faulty RAM). Run `memtest86+` (several passes), reseat/replace DIMMs. Workaround for now: re-run the build a few times until it passes.
- [ ] Move robot related configs to franka_launch
- [ ] Remove rosdep from setup.sh

## Log

### 2026-06-23

#### Intermittent build failures (suspected faulty RAM)
- **Problem:** `pixi run build` randomly crashes compiling `crisp_controllers` with `cc1plus: internal compiler error: Segmentation fault`. It is non-deterministic (different files/passes on identical source), so it points to a hardware fault — likely bad RAM, not a code bug.
- **Solution:** No code fix — just re-run `pixi run build` a few times until it succeeds. The RAM should be checked (`memtest86+`, reseat/replace DIMMs) in the future. See backlog above.

#### Stable gripper device names
- **Problem:** The Robotis RH-P12-RN-A grippers enumerate as `/dev/ttyUSB<N>` in kernel order, so the number is not tied to a physical gripper — power-cycling or replugging can swap left/right and break the launch.
- **Solution:** Added udev rules in `src/franka_launch/udev/99-dynamixel.rules` that pin each FTDI adapter's serial to a fixed symlink (`/dev/dynamixel_left`, `/dev/dynamixel_right`). Documented the install steps in the README under Prerequisites (§1.1.3).
