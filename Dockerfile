
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV NO_AT_BRIDGE=1
ENV GTK_A11Y=none
ENV MALLOC_ARENA_MAX=2

# ---- KDE Plasma + XRDP + Midori ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    xrdp \
    xorgxrdp \
    xserver-xorg-core \
    plasma-desktop \
    plasma-workspace \
    konsole \
    dolphin \
    systemsettings \
    kde-cli-tools \
    dbus-x11 \
    dbus-user-session \
    sudo \
    curl \
    wget \
    ssl-cert \
    ca-certificates \
    midori \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ---- User setup ----
RUN echo "ubuntu:ubuntu" | chpasswd && \
    usermod -aG sudo ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ---- Xorg permissions ----
RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config && \
    echo "needs_root_rights=no" >> /etc/X11/Xwrapper.config

# ---- XRDP optimization ----
RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    sed -i 's/max_bpp=32/max_bpp=16/' /etc/xrdp/xrdp.ini && \
    sed -i 's/#tcp_send_buffer_size=32768/tcp_send_buffer_size=131072/' /etc/xrdp/xrdp.ini && \
    adduser xrdp ssl-cert

# ---- Disable KDE compositor ----
RUN mkdir -p /home/ubuntu/.config && \
    printf '[Compositing]\nEnabled=false\n' > /home/ubuntu/.config/kwinrc

# ---- KDE session ----
RUN printf '#!/bin/sh\n\
export XDG_CURRENT_DESKTOP=KDE\n\
export XDG_SESSION_DESKTOP=KDE\n\
export DESKTOP_SESSION=plasma\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
unset XDG_RUNTIME_DIR\n\
exec dbus-run-session startplasma-x11\n' > /home/ubuntu/.xsession && \
    chmod +x /home/ubuntu/.xsession && \
    cp /home/ubuntu/.xsession /home/ubuntu/.xsessionrc && \
    chown -R ubuntu:ubuntu /home/ubuntu

# ---- Startup script ----
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
