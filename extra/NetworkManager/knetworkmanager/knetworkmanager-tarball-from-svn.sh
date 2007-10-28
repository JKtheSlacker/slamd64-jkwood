#!/bin/sh
VERSION=$(date +%Y%m%d)

SRCDIR=knetworkmanager-$VERSION

rm -rf $SRCDIR
svn export -N svn://anonsvn.kde.org/home/kde/trunk/kdereview $SRCDIR || exit 1
cd $SRCDIR
svn export svn://anonsvn.kde.org/home/kde/branches/KDE/3.5/kde-common/admin || exit 1
svn export svn://anonsvn.kde.org/home/kde/branches/extragear/kde3/network/knetworkmanager || exit 1
make -f Makefile.cvs
cd ..
tar jcfv $SRCDIR.tar.bz2 $SRCDIR
