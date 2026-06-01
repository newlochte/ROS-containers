# Docker setup for Robot Operating System containers

Dockerized ROS2 development environment with GPU, display (X11/Wayland), and shared memory support.

## Setup

One line setup to paste into terminal from project location. It adds script to path and sources it for autocompletion.

```bash
echo -e "\n# ROS2 container\nexport PATH=\"$(pwd):\$PATH\"\nsource \"$(pwd)/ros-container.sh\"" >> ~/.bashrc && source ~/.bashrc
```

## Usage

```bash
ros-container.sh start   <distro>
ros-container.sh shell   <distro> # also starts container if not running
ros-container.sh stop    <distro>
ros-container.sh rebuild <distro> # starts container after rebuild
```

Script with autocompletion for action and ditsro. Defaults to jazzy, to change that edit distro default value.

## Tested distros

- `humble` (Ubuntu 22.04)
- `jazzy` (Ubuntu 24.04)

## What's included

- **Base image**: `osrf/ros:<distro>-desktop-full`
- **User**: runs as `ubuntu` (UID 1000) — matches host user ownership on bind-mounted files
- **GUI**: Wayland-native (Qt6 on jazzy, Qt5 on humble) + X11 fallback via XWayland
- **GPU**: NVIDIA via `nvidia-container-toolkit`
- **ROS2 networking**: `network_mode: host` for DDS multicast discovery; `ipc: host` for zero-copy shared memory transport
- **Dev tools**: git, tmux, colcon, rosdep, vcstool, pip, sudo
- **Workspace**: `$PWD` is mounted to `/home/ubuntu/ws` — run the script from your workspace directory
- **Alias inside container**: `sis` → `source ~/ws/install/setup.bash`
- **Git**: host git config mounted; 1Password SSH agent forwarded for commit signing and push