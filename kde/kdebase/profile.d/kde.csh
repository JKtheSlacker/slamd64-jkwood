#!/bin/csh
# KDE additions:
if ( ! $?KDEDIR ) then
    setenv KDEDIR /usr
endif
if ( $?XDG_CONFIG_DIRS ) then
    setenv XDG_CONFIG_DIRS ${XDG_CONFIG_DIRS}:/etc/kde/xdg
else
    setenv XDG_CONFIG_DIRS /etc/xdg:/etc/kde/xdg
endif
