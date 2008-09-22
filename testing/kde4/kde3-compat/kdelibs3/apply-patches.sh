zcat $CWD/kdelibs-utempter.diff.gz | patch -p1 --verbose --backup --suffix=.orig || exit 1
