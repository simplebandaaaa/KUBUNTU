
#!/bin/bash
set -e

# ---- User password ----
RDP_PASSWORD="${RDP_PASSWORD:-ubuntu}"
echo "ubuntu:${RDP_PASSWORD}" | chpasswd

# ---- Home directory setup ----
mkdir -p /home/ubuntu
chown -R ubuntu:ubuntu /home/ubuntu

# ---- KDE session setup ----
cat > /home/ubuntu/.xsession <<'EOF'
#!/bin/sh
export XDG_CURRENT_DESKTOP=KDE
export XDG_SESSION_DESKTOP=KDE
export DESKTOP_SESSION=plasma
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
exec dbus-run-session startplasma-x11
EOF

chmod +x /home/ubuntu/.xsession
cp /home/ubuntu/.xsession /home/ubuntu/.xsessionrc
chown ubuntu:ubuntu /home/ubuntu/.xsession /home/ubuntu/.xsessionrc

# ---- Runtime directories ----
mkdir -p /run/xrdp /var/run/dbus
chmod 755 /run/xrdp

rm -f /run/xrdp/*.pid

# ---- Start DBus ----
if ! pgrep -x dbus-daemon >/dev/null; then
    dbus-daemon --system --fork
fi

# ---- Start XRDP ----
/usr/sbin/xrdp-sesman
exec /usr/sbin/xrdp --nodaemon
