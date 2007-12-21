#!/bin/sh
config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

# Keep same perms on rc.udev.new:
if [ -e etc/rc.d/rc.udev ]; then
  cp -a etc/rc.d/rc.udev etc/rc.d/rc.udev.new.incoming
  cat etc/rc.d/rc.udev.new > etc/rc.d/rc.udev.new.incoming
  mv etc/rc.d/rc.udev.new.incoming etc/rc.d/rc.udev.new
fi

config etc/rc.d/rc.udev.new
config etc/modprobe.d/blacklist.new
config etc/modprobe.d/isapnp.new
config etc/modprobe.d/psmouse.new
