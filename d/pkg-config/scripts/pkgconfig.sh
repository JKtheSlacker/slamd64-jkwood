#!/bin/sh
if [ ! "$PKG_CONFIG_PATH" = "" ]; then
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:/usr/local/lib/pkgconfig:/usr/lib64/pkgconfig:/usr/local/lib64/pkgconfig
else
  PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib64/pkgconfig:/usr/local/lib64/pkgconfig
fi
export PKG_CONFIG_PATH
