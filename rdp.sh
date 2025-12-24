#!/bin/bash

# ==========================================================
# RDP UNIVERSAL INSTALLER (UBUNTU & DEBIAN)
# ==========================================================

# 1. Pastikan dijalankan sebagai ROOT
if [ "$EUID" -ne 0 ]; then 
  echo "Error: Silakan jalankan sebagai root (sudo su)"
  exit 1
fi

echo "-------------------------------------------------------"
echo "🚀 Memulai Instalasi RDP Modern..."
echo "-------------------------------------------------------"

# 2. Mencegah pop-up interaktif (Penting untuk otomatisasi)
export DEBIAN_FRONTEND=noninteractive

# 3. Update daftar paket
apt-get update && apt-get upgrade -y

# 4. Instal Desktop Environment (XFCE4) - Ringan dan Cepat
echo "📦 Menginstal XFCE4 dan dependensi grafis..."
apt-get install -y xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils

# 5. Instal XRDP (Server RDP)
echo "📦 Menginstal XRDP..."
apt-get install -y xrdp

# 6. Konfigurasi User Login
# Anda bisa mengganti USERNAME dan PASSWORD di bawah ini
USERNAME="user_rdp"
PASSWORD="P@ssword123"

echo "👤 Membuat user: $USERNAME..."
if id "$USERNAME" &>/dev/null; then
    echo "User sudah ada, memperbarui password."
else
    adduser --disabled-password --gecos "" $USERNAME
fi

echo "$USERNAME:$PASSWORD" | chpasswd
usermod -aG sudo $USERNAME

# 7. Konfigurasi agar XRDP menggunakan XFCE
echo "xfce4-session" > /home/$USERNAME/.xsession
chown $USERNAME:$USERNAME /home/$USERNAME/.xsession

# 8. Perbaikan bug 'Layar Hitam' dan Polkit (Otomatis Klik Yes di RDP)
cat <<EOF | sudo tee /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla
[Allow Colord Management]
Identity=unix-user:$USERNAME
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

# 9. Restart Service
systemctl enable xrdp
systemctl restart xrdp

# 10. Membuka Firewall (Jika UFW aktif)
if command -v ufw > /
