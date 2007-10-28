#!/bin/sh
# Environment variables for the Qt package.
#
# It's best to use the generic directory to avoid
# compiling in a version-containing path:
if [ -d /usr/lib64/qt ]; then
  QTDIR=/usr/lib64/qt
else
  # Find the newest Qt directory and set $QTDIR to that:
  for qtd in /usr/lib64/qt-* ; do
    if [ -d $qtd ]; then
      QTDIR=$qtd
    fi
  done
fi
if [ ! "$CPLUS_INCLUDE_PATH" = "" ]; then
  CPLUS_INCLUDE_PATH=$QTDIR/include:$CPLUS_INCLUDE_PATH
else
  CPLUS_INCLUDE_PATH=$QTDIR/include
fi
PATH="$PATH:$QTDIR/bin"
export QTDIR
export CPLUS_INCLUDE_PATH
