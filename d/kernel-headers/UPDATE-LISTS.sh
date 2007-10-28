#!/bin/sh
# Copyright (c) 2007 Frederick Emmott
FILES="
	asm-arch-headers
	asm-headers
	asm-sys-headers
	blank-headers
	copy-headers
	glibc-headers
	linux-headers
	no_santize-asm-headers
	no_santize-linux-headers
	remove-headers
	root-headers
	sys-headers
"

rm -rf lists
mkdir lists
cd lists
for file in $FILES; do
	wget "http://headers.cross-lfs.org/browser/lists/$file?format=raw" -O $file || exit 1
done || exit 1
echo "Done."
