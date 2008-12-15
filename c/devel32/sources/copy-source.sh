#!/bin/sh
SLACK=${SLACK:-/mnt/slackware-current/source/}
for dir in $(find -type d ! -name .); do
	if ls $dir/$dir*.tar*>/dev/null 2>/dev/null; then
		echo "Updating $dir..."
		rm $dir/$dir*.tar*
		cp -a $SLACK/*/$dir/$dir*.tar* $dir/
	elif [ "$dir" = "./libtermcap" ]; then
		echo "Updating $dir..."
		rm $dir/termcap-compat*
		cp -a $SLACK/l/libtermcap/termcap-compat* $dir/
	elif [ "$dir" = "./libjpeg" ]; then
		echo "Updating $dir..."
		rm $dir/jpegsrc*
		cp -a $SLACK/l/libjpeg/jpegsrc* $dir/
	else
		echo "SKIPPING $dir..."
	fi
done
