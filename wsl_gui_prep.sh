#!/bin/bash
# ==============================================================================
# WSL2 Fedora GUI & Interop Prep Script
# Run this BEFORE the Ansible Bootstrapper
# ==============================================================================
set -e

echo "🪟 Prepping Fedora on WSL2 for GUI applications..."

# 1. Install WSL2 GUI Dependencies (WSLg requirements)
# These allow Flatpaks and GUI apps to render via the Windows Wayland compositor
echo "📦 Installing Mesa drivers and X11/Wayland libraries..."
sudo dnf install -y \
    mesa-dri-drivers \
    mesa-libGL \
    libX11 \
    libwayland-client \
    wayland-utils \
    vulkan-loader \
    xorg-x11-server-Xwayland \
    dbus-x11

# 2. Fix D-Bus (Crucial for Flatpak and KDE apps in WSL)
echo "🚌 Ensuring D-Bus is configured for WSL..."
sudo systemctl enable dbus || true
sudo systemctl start dbus || true

# 3. Setup Environment Variables for WSLg
# We ensure these are in ~/.bashrc so they are present for the first Ansible run
echo "🌐 Configuring DISPLAY and WAYLAND_DISPLAY..."
{
    echo ""
    echo "# WSLg GUI Support"
    echo "export DISPLAY=:0"
    echo "export WAYLAND_DISPLAY=wayland-0"
    echo "export XDG_RUNTIME_DIR=/run/user/\$(id -u)"
    echo "export MOZ_ENABLE_WAYLAND=1" # For Firefox/Chrome performance
} >> ~/.bashrc

# 4. Fix Systemd in WSL (If not already enabled)
# Fedora requires systemd for many of your Ansible tasks (Tailscale, etc.)
if [ ! -f "/etc/wsl.conf" ] || ! grep -q "systemd=true" /etc/wsl.conf; then
    echo "⚙️ Enabling systemd in /etc/wsl.conf..."
    sudo tee /etc/wsl.conf <<EOF
[boot]
systemd=true
[interop]
appendWindowsPath=true
EOF
    echo "⚠️ Systemd enabled. YOU MUST RUN 'wsl --shutdown' in PowerShell after this script!"
fi

echo "🚀 GUI Prep Complete. Now run your Fedora Workstation Bootstrapper."
