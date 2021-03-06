#!/bin/bash
echo "---------- $0 start ----------"

set -e
set -x

/vagrant/Tools/vagrant/initvagrant.sh

VAGRANT_USER=ubuntu
if [ -e /home/vagrant ]; then
    # prefer vagrant user
    VAGRANT_USER=vagrant
fi

apt-get update

apt-get install -y ubuntu-desktop

GDB_CONF="/etc/gdm3/custom.conf"
perl -pe 's/#  AutomaticLoginEnable = true/AutomaticLoginEnable = true/'  -i "$GDB_CONF"
perl -pe 's/#  AutomaticLogin = user1/AutomaticLogin = vagrant/' -i "$GDB_CONF"

cat >>/etc/xdg/autostart/open-gnome-terminal.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Start gnome terminal
TryExec=gnome-terminal
Exec=gnome-terminal

X-GNOME-Autostart-Phase=Application
EOF

# disable the screensaver:
sudo -u "$VAGRANT_USER" dbus-launch gsettings set org.gnome.desktop.session idle-delay 0

# don't show the initial setup crap:
echo "yes" | sudo -u "$VAGRANT_USER" dd of=/home/"$VAGRANT_USER"/.config/gnome-initial-setup-done

# start the graphical environment right now:
systemctl isolate graphical.target

echo "---------- $0 end ----------"
