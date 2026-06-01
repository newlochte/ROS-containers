#!/bin/bash

DISTROS="humble jazzy lyrical"

# When sourced (not executed), register tab completion and exit early
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    _ros_container_complete() {
        local cur
        cur="${COMP_WORDS[COMP_CWORD]}"
        case $COMP_CWORD in
            1) COMPREPLY=($(compgen -W "start shell stop rebuild" -- "$cur")) ;;
            2) COMPREPLY=($(compgen -W "$DISTROS" -- "$cur")) ;;
        esac
    }
    complete -F _ros_container_complete ros-container.sh
    return
fi

set -e

ACTION=${1:-start}
DISTRO=${2:-jazzy}

if ! command -v xauth &>/dev/null; then
  echo "WARNING: xauth not found. Install xorg-xauth or X11 GUI apps won't work in the container."
fi

if [ ! -S "$HOME/.1password/agent.sock" ]; then
  echo "WARNING: 1Password agent socket not found. SSH auth and commit signing will not work in the container."
fi

if [ ! -f "$HOME/.ssh/config" ]; then
  echo "WARNING: ~/.ssh/config not found. SSH auth may not work in the container."
fi

export DISPLAY="${DISPLAY:-:1}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
export ROS_DISTRO="$DISTRO"

# Locate git config: XDG path or clasic
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/git/config" ]; then
  export GIT_CONFIG_HOST="${XDG_CONFIG_HOME:-$HOME/.config}/git/config"
elif [ -f "$HOME/.gitconfig" ]; then
  export GIT_CONFIG_HOST="$HOME/.gitconfig"
fi

xauth generate "$DISPLAY" . trusted 2>/dev/null || true
# Grant X11 access to local connections — without this the container hits "Authorization required"
xhost +local: 2>/dev/null || true

case $ACTION in
  start)
    echo "Starting ROS2 $DISTRO container..."
    docker compose -f ~/ros2/docker-compose.yml up --force-recreate -d ros
    ;;
  shell)
    if ! docker ps --format '{{.Names}}' | grep -q "^ros2-$DISTRO$"; then
      echo "Container ros2-$DISTRO is not running, starting it..."
      docker compose -f ~/ros2/docker-compose.yml up --force-recreate -d ros
    fi
    echo "Opening shell in ros2-$DISTRO..."
    docker exec -it ros2-$DISTRO bash
    ;;
  rebuild)
    echo "Rebuilding and restarting ROS2 $DISTRO container..."
    docker compose -f ~/ros2/docker-compose.yml down
    docker compose -f ~/ros2/docker-compose.yml build --no-cache ros
    docker compose -f ~/ros2/docker-compose.yml up --force-recreate -d ros
    ;;
  stop)
    echo "Stopping and removing ros2-$DISTRO..."
    docker compose -f ~/ros2/docker-compose.yml down
    ;;
  *)
    echo "Unknown action: $ACTION. Use start|shell|stop|rebuild"
    exit 1
    ;;
esac
