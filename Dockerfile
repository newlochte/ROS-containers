ARG ROS_DISTRO=jazzy
FROM osrf/ros:${ROS_DISTRO}-desktop-full

ENV DEBIAN_FRONTEND=noninteractive

# Dev tools + sudo
RUN apt-get update && apt-get install -y \
    git \
    nano \
    tmux \
    curl \
    wget \
    build-essential \
    python3-pip \
    python3-vcstool \
    bash-completion \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# humble (Ubuntu 22.04) doesn't pre-create the ubuntu user unlike jazzy (24.04)
RUN id ubuntu 2>/dev/null || useradd -m -s /bin/bash ubuntu \
    && echo "ubuntu ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu \
    && touch /home/ubuntu/.sudo_as_admin_successful

# Source ROS in interactive (non-login) shells
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/ubuntu/.bashrc

# Login shells: delegate to .bashrc so they get the same environment
RUN echo '[ -f ~/.bashrc ] && . ~/.bashrc' >> /home/ubuntu/.bash_profile

# Prompt: \e = ESC, \$ = literal $, \w = cwd, ${ROS_DISTRO} expands at runtime
RUN echo 'export PS1="\[\e[01;36m\][ROS2-${ROS_DISTRO}]\[\e[0m\] \w \$ "' >> /home/ubuntu/.bashrc

# Nice to have aliases
RUN echo "alias sis='source ~/ws/install/setup.bash'" >> /home/ubuntu/.bashrc

USER ubuntu
WORKDIR /home/ubuntu/ws
CMD ["bash"]
