FROM ubuntu:22.04
ARG UID=9001
ARG GID=9001
ARG UNAME=ubuntu
ARG HOSTNAME=docker
ARG NEW_HOSTNAME=${HOSTNAME}-Docker
ARG USERNAME=$UNAME
ARG HOME=/home/$USERNAME
ARG LOCALE="US"


RUN useradd -u $UID -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        mkdir /etc/sudoers.d && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME && \
        usermod  --uid $UID $USERNAME && \
        groupmod --gid $GID $USERNAME && \
        chown -R $USERNAME:$USERNAME $HOME && \
        chmod 666 /dev/null && \
        chmod 666 /dev/urandom


RUN echo 'path-include=/usr/share/locale/ja/LC_MESSAGES/*.mo' > /etc/dpkg/dpkg.cfg.d/includes \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        sudo \
        lxde \
        xrdp \
        ibus \
        ibus-mozc \
        language-pack-ja-base \
        language-pack-ja \
        fonts-noto-cjk \
        fonts-noto-color-emoji \
        supervisor \
        gosu \
        build-essential \
        curl \
        less \
        apt-utils \
        tzdata \
        git \
        tmux \
        bash-completion \
        command-not-found \
        libglib2.0-0 \
        gstreamer1.0-plugins-* \
        libgstreamer1.0-* \
        libgstreamer-plugins-*1.0-* \
        vim \
        emacs \
        ssh \
        rsync \
        python3-pip \
        sed \
        ca-certificates \
        wget \
        lsb-release \
        gnupg

#RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN sudo apt install software-properties-common
RUN sudo add-apt-repository universe

RUN sudo apt update && sudo apt install curl gnupg lsb-release
RUN sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null


RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN sudo apt update && sudo apt install -y \
  build-essential \
  cmake \
  git \
  python3-colcon-common-extensions \
  python3-flake8 \
  python3-flake8-docstrings \
  python3-pip \
  python3-pytest \
  python3-pytest-cov \
  python3-rosdep \
  python3-setuptools \
  python3-vcstool \
  wget \
  htop
  
# RUN apt-get update && apt-get install -y \
#         ros-melodic-desktop-full \
#         python-rosdep \
#         python-rosinstall \
#         python-rosinstall-generator \
#         python-wstool \
#         htop

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      xrdp-pulseaudio-installer \
      net-tools \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/* \
# Apply a patch
    && sed -i -E \
      's@^dget ".*pulseaudio.*\.dsc"$@\dget -u "https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/pulseaudio/$pulseaudio_version/pulseaudio_$(echo $pulseaudio_version | sed "s/^.*://").dsc"@' \
      /usr/sbin/xrdp-build-pulse-modules \
    && /usr/sbin/xrdp-build-pulse-modules



RUN rosdep init

USER $USERNAME
RUN rosdep update
USER root

RUN if [ "${LOCALE}" = "JP" ]; then \
    # mkdir -p ~/.config/autostart/ \
    # &&  \
    { \
    echo '[Desktop Entry]'; \
    echo 'Type=Application'; \
    echo 'Name=SetJPKeyboard'; \
    echo 'Exec=setxkbmap -layout jp'; \
    echo 'OnlyShowIn=LXDE'; \
    # } > ~/.config/autostart/setxkbmap.desktop; \
    } > /etc/xdg/autostart/setxkbmap.desktop; \
fi

# Set locale
RUN if [ "${LOCALE}" = "JP" ]; then \
        cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
        && echo 'Asia/Tokyo' > /etc/timezone; \
fi
# RUN if [ "${LOCALE}" = "JP" ]; then \
#         locale-gen ja_JP.UTF-8 \
#         && echo 'LC_ALL=ja_JP.UTF-8' > /etc/default/locale \
#         && echo 'LANG=ja_JP.UTF-8' >> /etc/default/locale\
#         && LANG=ja_JP.UTF-8 \
#         && LANGUAGE=ja_JP:ja \
#         && LC_ALL=ja_JP.UTF-8; \
# fi

# RUN mkdir -p /etc/X11/xorg.conf.d/

# RUN if [ "${LOCALE}" = "JP" ]; then \
# { \
#       echo 'Section "InputClass"'; \
#       echo '        Identifier "system-keyboard"'; \
#       echo '        MatchIsKeyboard "on"'; \
#       echo '        Option "XkbLayout" "jp,us"'; \
#       echo '        Option "XkbModel" "jp106"'; \
#       echo '        Option "XkbOptions" "grp:alt_shift_toggle"'; \
#       echo 'EndSection'; \
#     } > /etc/X11/xorg.conf.d/00-keyboard.conf; \
# fi

# RUN if [ "${LOCALE}" = "JP" ]; then \
# { \
#       echo '# KEYBOARD CONFIGURATION FILE'; \
#       echo '# Consult the keyboard(5) manual page.'; \
#       echo 'XKBMODEL="pc109"'; \
#       echo 'XKBLAYOUT="jp"'; \
#       echo 'XKBVARIANT=""'; \
#       echo 'XKBOPTIONS=""'; \
#       echo 'BACKSPACE="guess"'; \
#     } > /etc/default/keyboard; \
# fi

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      ubuntu-wallpapers \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/* 

# Expose RDP port
EXPOSE 3389

RUN echo "startlxde" > /etc/skel/.xsession \
    && install -o root -g xrdp -m 2775 -d /var/run/xrdp \
    && install -o root -g xrdp -m 3777 -d /var/run/xrdp/sockdir \
    && install -o root -g root -m 0755 -d /var/run/dbus

# Set supervisord conf for xrdp service
RUN { \
      echo "[supervisord]"; \
      echo "user=root"; \
      echo "nodaemon=true"; \
      echo "logfile=/var/log/supervisor/supervisord.log"; \
      echo "childlogdir=/var/log/supervisor"; \
      echo "[program:dbus]"; \
      echo "command=/usr/bin/dbus-daemon --system --nofork --nopidfile"; \
      echo "[program:xrdp-sesman]"; \
      echo "command=/usr/sbin/xrdp-sesman --nodaemon"; \
      echo "[program:xrdp]"; \
      echo "command=/usr/sbin/xrdp --nodaemon"; \
      echo "user=xrdp"; \
    } > /etc/supervisor/xrdp.conf

RUN mv /usr/bin/lxpolkit /usr/bin/lxpolkit.org

RUN { \
      echo '#DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };'; \
      echo '#APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };'; \
      echo '#Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";'; \
    } > /etc/apt/apt.conf.d/docker-clean

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
