#!/bin/sh
# Make kde-i18n packages
# by PJV <volkerdi@slackware.com>

export KDEVER=3.5.9
export PKVER=3.5.9
export ARCH=noarch
export BUILD=1
export LC_ALL=C
export DISTRO=slamd64

if [ $DISTRO = slackware ]; then
	PKGARCH=$ARCH
else
	PKGARCH=${ARCH}_${DISTRO}
fi

export PKGARCH

CWD=$(pwd)
for file in *.tar.bz2 ; do
  ( tar xjvf $file
    cd $CWD/$(basename $file .tar.bz2)
    ./configure --prefix=/usr --program-prefix="" --program-suffix=""
    rm -rf $CWD/tmp
    make -i
    make -i install DESTDIR=$CWD/tmp
  )
  mkdir -p $CWD/tmp/install
  cat $CWD/slack-desc/slack-desc.$(basename $file -$KDEVER.tar.bz2) > $CWD/tmp/install/slack-desc
  ( cd $CWD/tmp
    makepkg -l y -c n $CWD/$(basename $file $KDEVER.tar.bz2)$PKVER-$PKGARCH-$BUILD.tgz
  )
  rm -r $CWD/$(basename $file .tar.bz2)
  rm -rf $CWD/tmp  
done
rm -f $CWD/Colors $CWD/scan.before $CWD/scan.after
