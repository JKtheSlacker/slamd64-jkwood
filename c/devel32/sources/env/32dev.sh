#!/bin/sh
# Copyright (C) 2007  Frederick Emmott <mail@fredemmott.co.uk>
# This file is part of the Slamd64 Linux project (www.slamd64.com)

# Distributed under the GNU General Public License, version 2, as
# published by the Free Software Foundation.

export PATH="/usr/bin/32:$PATH"
export CC="gcc" # This is actually the /usr/bin/32/gcc wrapper
export CXX="g++"
export LD_LIBRARY_PATH="/lib:/usr/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="/usr/lib/pkgconfig:$PKG_CONFIG_PATH"
