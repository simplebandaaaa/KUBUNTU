
#!/bin/bash
set -e

# ---- Password ----
RDP_PASSWORD="${RDP_PASSWORD:-ubuntu}"
echo "ubuntu:${RDP_PASSWORD}" | chpasswd

# ---- User home setup ----
mkdir -p /home/ubuntu
chown -R ubuntu:ubuntu /home/ubuntu

# ---- Runtime directories ----
mkdir -p /run/xrdp /var/run/dbus
chmod 755 /run/xrdp

# ---- Clean old PID files ----
rm -f /run/xrdp/xrdp.pid
rm -f /run/xrdp/xrdp-sesman.pid

# ---- D-Bus ----
if ! pgrep -x dbus-daemon >/dev/null 2>&1; then
    service dbus start || true
fi

# ---- XRDP permissions ----
adduser xrdp ssl-cert 2>/dev/null || true

# ---- Start XRDP services ----
/usr/sbin/xrdp-sesman
/usr/sbin/xrdp

echo "================================"
echo "Kubuntu KDE Plasma RDP Started"
echo "RDP Port: 3389"
echo "Username: ubuntu"
echo "================================"

# ---- Keep container alive ----
tail -f /dev/null
