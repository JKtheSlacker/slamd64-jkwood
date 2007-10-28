#!/bin/sh
svn export svn://anonsvn.kde.org/home/kde/branches/KDE/3.5/kde-common/admin || exit 1
rm -f kde-common-admin.tar.bz2
tar jcfv kde-common-admin.tar.bz2 admin || exit 1
rm -rf admin
