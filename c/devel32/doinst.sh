#!/bin/sh
if [ -e /var/log/packages/32base* ]; then
cat <<EOF
***WARNING***
This package conflicts with the old 32base package. Please uninstall that package, and
use the new glibc32 package instead.
***WARNING***
EOF
fi
