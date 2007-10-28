#!/bin/bash
#
# Minimal Sanitized Headers - Version 01.01
#
# Submit bugreports via http://headers.cross-lfs.org
#
#
# By Jim Gifford (scripts@jg555.com)
#    Ken Moffat (ken@linxufromscratch.org)
#    Seth Klein
#
# Based on research and work by Jürg Billeter and Mariusz Mazur
#
#       Community Member Acknowledgement
#
#	Ryan Oliver
#	Joe Ciccone
#	Matt Darcy
#	Greg Schafer
#	Tushar Teredesai
#	D.J. Lucas
#	Jeremy Huntwork
#	Andrew Benton
#	Florian Schanda
#	Theo Schneider
#	Roberto Nibali
#
# LFS/CLFS Build notes
#
# You will also need to copy over asm-generic to ensure you have all the
# necessary headers. In LLH they asm-generic these into the asm-{architecture}
# so there is no asm-generic.
#
# Headers Lists
# As of version 01.00 we have removed the headers lists from the scripts
# and put them into separate text files in lists directory. The file format
# is one header per line.
#
# Programs Required
#
# This version requires unifdef - get it at
#
# http://ftp.debian.org/debian/pool/main/u/unifdef/
#
#
# Conversion Process
#
# Removal of __KERNEL__ - These tags are only during the build of the kernel
#
# Conversion u and s variables to userspace variables is the following link
# for more information http://www.linuxdevices.com/articles/AT5340618290.html
#
# Removal of <linux/config.h> - Not needed for userspace contains kernel build
# information.
#
# Conversion of linux to __linux__ - converts to a userspace usable
#
# Removal of __iomem
# for more information http://lwn.net/Articles/102232/
#
# version.h is created so that all the kernel versioning information
# is available
#
# compiler.h is removed
#
#
# I386 Specific
#
#
# MIPS Specific
#
# CONFIG_64BIT and CONFIG_32BIT are not defined in userspace so we use
# __mips64.
#
# Make atomic.h the same as LLH.
#
#
# Sparc Specific
#
# RAW Headers use variables from the configuration to get the PAGE SIZE
# so we use a function that exists in glibc to figure it out.
#
#
# Creation of biarch headers for multilib builds
#
# Links that inspired my creation
#
# http://kerneltrap.org/node/365

usage() {
        echo "usage:"
	echo "      $0 version=kernel_version {optional}"
	echo "example: $0"
	echo ""
	echo "Optional:"
	echo "		check		  - checks to see if the header exists in unsantized headers"
	echo "		dump		  - dump headers name then create headers package"
	echo "		dumponly	  - dump headers name then exit"
	echo "		file		  - creates a file list"
	echo "		patchfile={patch} - utilize this patch"
	exit 255
}

make_headers() {
	for headers in $HEADERS; do
		cd $ORIGDIR
		HDR_DIRS=`find * -type d | grep $TYPE | cut -f1 -d'/' | sort -u`
		for locate in $HDR_DIRS; do
			cd $CURRENT_DIR/linux-headers-$VERSION.orig
			LOCATE=`find */$locate -type f | grep -F "/$headers" | sort -u`
			for file in $LOCATE; do
				TEST1=`echo $file | grep -c /$TYPE/`
				TEST2=`echo $file | grep -c /$TYPE-`
				if [ "$TEST1" = "0" -a "$TEST2" = "0" ]; then
					break
				fi
				header="$CURRENT_DIR/linux-headers-$VERSION/$file"

				echo "Processing $file..."

				install -m 644 "$file" "$header"
				
				if grep -c __KERNEL__ "$header" >/dev/null; then
					unifdef -e -U__KERNEL__ $header > $header.new
					mv $header.new $header
				fi

				if [ "$DONT_CHANGE" = "no" ]; then
					sed -e 's/\b[us]\(8\|16\|32\|64\)\b/__&/g' \
					    -e 's/\b__\(be\|le\)\(16\|32\|64\)\b/__u\2/g' \
					    -e 's/\b__force\b//g' \
					    -e 's/\b__iomem\b//g' \
					    -e 's/\b__attribute_const__\b//g' \
					    -e 's/\b__user\b//g' \
					    -e 's/ inline / __inline__ /g' \
					    -e 's/__kernel_sockaddr_/sockaddr_/g' \
					    -e 's/^#define $//' \
					       $header > $header.new
					mv $header.new $header
				fi

				sed -e '/#include <asm.acpi.h>/d' \
				    -e '/#include <asm.archparam.h>/d' \
				    -e '/#include <asm.asm-offsets.h>/d' \
				    -e '/#include <asm.bug.h>/d' \
				    -e '/#include <asm.compiler.h>/d' \
				    -e '/#include <asm.cpu-info.h>/d' \
				    -e '/#include <asm.current.h>/d' \
				    -e '/#include <asm.dsp.h>/d' \
				    -e '/#include <asm.hack.h>/d' \
				    -e '/#include <asm.hazards.h>/d' \
				    -e '/#include <asm.hpet.h>/d' \
				    -e '/#include <asm.ide.h>/d' \
				    -e '/#include <asm.interrupt.h>/d' \
				    -e '/#include <asm.machvec_init.h>/d' \
				    -e '/#include <asm.mtd-xip.h>/d' \
				    -e '/#include <asm.offset.h>/d' \
				    -e '/#include <asm.offsets.h>/d' \
				    -e '/#include <asm.page.h>/d' \
				    -e '/#include <asm.percpu.h>/d' \
				    -e '/#include <asm.prefetch.h>/d' \
				    -e '/#include <asm.proc-fns.h>/d' \
				    -e '/#include <asm.rwclock.h>/d' \
				    -e '/#include <asm.sections.h>/d' \
				    -e '/#include <asm.spinlock_types.h>/d' \
				    -e '/#include <asm.thread_info.h>/d' \
				    -e '/#include <asm.uaccess.h>/d' \
				    -e '/#include <asm.virtconvert.h>/d' \
				    -e '/#include <asm.arch.at91rm9200.h>/d' \
				    -e '/#include <asm.arch.at91rm9200_sys.h>/d' \
				    -e '/#include <asm.arch.atomic.h>/d' \
				    -e '/#include <asm.arch.cm.h>/d' \
				    -e '/#include <asm.arch.hwregs.reg_map.h>/d' \
				    -e '/#include <asm.arch.hwregs.reg_rdwr.h>/d' \
				    -e '/#include <asm.arch.hwregs.timer_defs.h>/d' \
				    -e '/#include <asm.arch.idle.h>/d' \
				    -e '/#include <asm.arch.prcm.h>/d' \
				    -e '/#include <asm.mach.ide.h>/d' \
				    -e '/#include <kmalloc.h>/d' \
				    -e '/#include <linux.autoconf.h>/d' \
				    -e '/#include <linux.bio.h>/d' \
				    -e '/#include <linux.blkdev.h>/d' \
				    -e '/#include <linux.clk.h>/d' \
				    -e '/#include <linux.compiler.h>/d' \
				    -e '/#include <linux.config.h>/d' \
				    -e '/#include <linux.completion.h>/d' \
				    -e '/#include <linux.cpumask.h>/d' \
				    -e '/#include <linux.crc-ccitt.h>/d' \
				    -e '/#include <linux.dmaengine.h>/d' \
				    -e '/#include <linux.dma-mapping.h>/d' \
				    -e '/#include <linux.genetlink.h>/d' \
				    -e '/#include <linux.hardirq.h>/d' \
				    -e '/#include <linux.kref.h>/d' \
				    -e '/#include <linux.kobject.h>/d' \
				    -e '/#include <linux.mempolicy.h>/d' \
				    -e '/#include <linux.mutex.h>/d' \
				    -e '/#include <linux.nodemask.h>/d' \
				    -e '/#include <linux.profile.h>/d' \
				    -e '/#include <linux.rcupdate.h>/d' \
				    -e '/#include <linux.rwsem.h>/d' \
				    -e '/#include <linux.seq_file.h>/d' \
				    -e '/#include <linux.smp.h>/d' \
				    -e '/#include <linux.spinlock.h>/d' \
				    -e '/#include <linux.spinlock_types.h>/d' \
				    -e '/#include <linux.stat.h>/d' \
				    -e '/#include <linux.string.h>/d' \
				    -e '/#include <linux.sunrpc.msg_prot.h>/d' \
				    -e '/#include <linux.textsearch.h>/d' \
				    -e '/#include <linux.thread_info.h>/d' \
				    -e '/#include <linux.timer.h>/d' \
				    -e '/#include <linux.topology.h>/d' \
				    -e '/#include <linux.transport_class.h>/d' \
				    -e '/#include <linux.uaccess.h>/d' \
				    -e '/#include <linux.byteorder.generic.h>/d' \
				    -e '/endif .* __KERNEL__/d' \
				    -e 's/|| !defined (__KERNEL__)//g' \
				    -e 's/|| !defined(__KERNEL__)//g' \
				    -e 's/!defined(__KERNEL__) ..//g' \
				    -e 's/|| defined(__KERNEL__)//g' \
				    -e 's/defined(__KERNEL__) ..//g' \
				    -e 's/|| defined (__KERNEL__)//g' \
				    -e 's/#ifdef linux/#ifdef __linux__/g' \
				    -e 's/#ifndef linux/#ifndef __linux__/g' \
				    -e '/#include <asm.machtypes.h>/d' \
				    -e '/#include <asm.serial-bigsur.h>/d' \
				    -e '/#include <asm.serial-ec3104.h>/d' \
				       $header > $header.new
				mv $header.new $header

				case $header in *mips*)
					sed -e 's/#ifdef CONFIG_32BIT/#ifndef __mips64/g' \
					    -e 's/#ifdef CONFIG_64BIT/#ifdef __mips64/g' \
					       $header > $header.new
					mv $header.new $header
				esac

				case $header in *byteorder.h*)
					unifdef -e -U__GNUC__ $header > $header.new
					mv $header.new $header
				esac

				sed -e '/^$/N;/\n$/D' \
				       $header > $header.new

				install -m 644 $header.new $header
				rm $header.new
			done
		done
	done
}

check_headers() {
	for file in $CHECKHEADERS; do
		TEST="`find * -name $file`"
		if [ "$TEST" != "" ]; then
			echo "$file was found"
		else
			echo "$file was not located." >> $CURRENT_DIR/missing_headers
		fi
	done
}
check_headers2() {
	for file in $CHECKHEADERS; do
		TEST="`find * -print0  | grep -FzZ $file`"
		if [ "$TEST" != "" ]; then
			echo "$file was found"
		else
			echo "$file was not located." >> $CURRENT_DIR/missing_headers
		fi
	done
}

clean_header() {
	header=$1
	sed -e '/^$/N;/\n$/D' \
	    -e 's@#if  defined@#if defined@g' \
	    -e 's@#if  !defined@#if !defined@g' \
	       $header > $header.new
	mv $header.new $header
}

create_linux_header() {
	echo "Creating include/$header..."
	new_header=$NEWDIR/$header
	echo -n "#ifndef LINUX_" > $new_header
	HEADING=`echo $header | tr '[:lower:]' '[:upper:]' | cut -f2 -d/ | cut -f1 -d.`
	echo -n "$HEADING" >> $new_header
	echo "_H" >> $new_header
	echo "" >> $new_header
	echo "$CONTENT" >> $new_header
	echo "" >> $new_header
	echo "#endif" >> $new_header
}

create_asm_header() {
	for dir in $DIRS; do
		echo "Creating include/$dir/$header..."
		DEFINE3="_H"
		if [ "$dir" = "asm-alpha" ]; then
			DEFINE1="__ALPHA_"
		fi
		if [ "$dir" = "asm-arm" -o "$dir" = "asm-arm26" ]; then
			DEFINE1="_ASM_ARM_"
		fi
		if [ "$dir" = "asm-cris" ]; then
			DEFINE1="_ASM_CRIS_"
		fi
		if [ "$dir" = "asm-frv" -o "$dir" = "asm-i386" -o \
		     "$dir" = "asm-mips" -o "$dir" = "asm-parisc" -o \
		     "$dir" = "asm-x86_64" ]; then
			DEFINE1="_ASM_"
		fi
		if [ "$dir" = "asm-h8300" ]; then
			DEFINE1="_H8300_"
		fi
		if [ "$dir" = "asm-ia64" ]; then
			DEFINE1="_ASM_IA64_"
		fi
		if [ "$dir" = "asm-m32r" ]; then
			DEFINE1="_ASM_M32R_"
		fi
		if [ "$dir" = "asm-m68k" ]; then
			DEFINE1="_"
		fi
		if [ "$dir" = "asm-m68knommu" ]; then
			DEFINE1="_M68KNOMMU_"
		fi
		if [ "$dir" = "asm-powerpc" ]; then
			DEFINE1="_ASM_POWERPC_"
		fi
		if [ "$dir" = "asm-ppc" ]; then
			DEFINE1="_ASM_PPC_"
		fi
		if [ "$dir" = "asm-s390" ]; then
			DEFINE1="_S390_"
		fi
		if [ "$dir" = "asm-sh" ]; then
			DEFINE1="__ASM_"
		fi
		if [ "$dir" = "asm-sh64" ]; then
			DEFINE1="__ASM_SH64_"
		fi
		if [ "$dir" = "asm-sparc" ]; then
			DEFINE1="__SPARC_"
		fi
		if [ "$dir" = "asm-sparc64" ]; then
			DEFINE1="__SPARC64_"
		fi
		if [ "$dir" = "asm-um" ]; then
			DEFINE1="__UM_"
		fi
		if [ "$dir" = "asm-v850" ]; then
			DEFINE1="__V850_"
			DEFINE3="_H__"
		fi
		if [ "$dir" = "asm-xtensa" ]; then
			DEFINE1="_XTENSA_"
		fi
		DEFINE2=`echo $header | tr '[:lower:]' '[:upper:]' | cut -f2 -d/ | cut -f1 -d.`
		echo -n "#ifndef $DEFINE1" > $NEWDIR/$dir/$header
		echo -n "$DEFINE2" >> $NEWDIR/$dir/$header
		echo "$DEFINE3" >> $NEWDIR/$dir/$header
		echo "" >> $NEWDIR/$dir/$header
		echo "$CONTENT" >> $NEWDIR/$dir/$header
		echo "" >> $NEWDIR/$dir/$header
		echo "#endif" >> $NEWDIR/$dir/$header
	done
}

multilib_stubs() {
	cd $CURRENT_DIR
	STUBARCH1=$1
	STUBARCH2=$2
	STUBSWITCH=$3
	HDRS=""
	DIRS=""
	for arch in ${STUBARCH1} ${STUBARCH2}; do
		cd $NEWDIR/asm-${arch}
		dirs=`find . -type d -printf "%P\n"`
		hdrs=`find . -type f -name \*.h -printf "%P\n"`
		DIRS=`echo ${DIRS} ${dirs} | sort -u`
		HDRS=`echo ${HDRS} ${hdrs} | sort -u`
	done

	cd $CURRENT_DIR
	# Create directories (if required) under include/asm
	install -d $NEWDIR/asm-${STUBARCH1}-biarch
	if [ "${DIRS}" != "" ]; then
		for dir in ${DIRS}; do
			install -d $NEWDIR/asm-${STUBARCH1}-biarch/${dir}
		done
	fi

	for hdr in ${HDRS}; do
		# include barrier
		name=`basename ${hdr} | tr [a-z]. [A-Z]_`
		cat > $NEWDIR/asm-${STUBARCH1}-biarch/${hdr} << EOF
#ifndef __STUB__${name}__
#define __STUB__${name}__

EOF
		# check whether we exist in arch1
		if [ -f linux-headers-$VERSION/include/asm-${STUBARCH1}/${hdr} ]; then
			# check if we also exist arch2
			if [ -f linux-headers-$VERSION/include/asm-${STUBARCH2}/${hdr} ]; then
				# we exist in both
				cat >> $NEWDIR/asm-${STUBARCH1}-biarch/${hdr} << EOF
#ifdef ${STUBSWITCH}
#include <asm-${STUBARCH1}/${hdr}>
#else
#include <asm-${STUBARCH2}/${hdr}>
#endif
EOF
			else
			# we only exist in arch1
				cat >> $NEWDIR/asm-${STUBARCH1}-biarch/${hdr} << EOF
#ifdef ${STUBSWITCH}
#include <asm-${STUBARCH1}/${hdr}>
#endif
EOF
			fi
		# end arch1
		else
			# if we get here we only exist in arch2
			cat >> $NEWDIR/asm-${STUBARCH1}-biarch/${hdr} << EOF
#ifndef ${STUBSWITCH}
#include <asm-${STUBARCH2}/${hdr}>
#endif
EOF
		fi
		cat >> $NEWDIR/asm-${STUBARCH1}-biarch/${hdr} << EOF

#endif /* __STUB__${name}__ */
EOF
	done
}

change_header() {
	FIX_HEADER=$NEWDIR/linux/$HEADER_FILE
	echo "Fixing include/linux/$HEADER_FILE..."
	sed -e "s/#define $HEADER_NAME/#define $HEADER_NAME\n\nNeXtLiNe/" $FIX_HEADER > $FIX_HEADER.new
	cp $FIX_HEADER.new $FIX_HEADER
	sed -e "s@NeXtLiNe@$HEADER_UPDATE@" $FIX_HEADER > $FIX_HEADER.new
	mv $FIX_HEADER.new $FIX_HEADER
}

# Input Check
#
if [ "$1" = "" ]; then
        usage
fi

while [ $# -gt 0 ]; do
	case $1 in

		check)
			CHECK=yes
			;;

		file)
			FILE=yes
			;;

		dump)
			DUMP=yes
			;;

		patchfile=*)
			TEMPPATCH=`echo $1 | awk -F= '{print $2;}'`
			if [ "$PATCHES" = "" ]; then
				PATCHES="$TEMPPATCH"
			else
				PATCHES="$PATCHES $TEMPPATCH"
			fi
			;;

		dumponly)
			DUMP=yes
			DUMPONLY=yes
			;;

		version=*)
			VERSION=`echo $1 | awk -F= '{print $2;}'`
			;;

		*)
			usage
			;;

		esac
	shift
done

# Checking for all the tools we need
TEST=`whereis awk | cut -f2 -d:`
if [ "$TEST" = "" ]; then
	echo "Missing awk"
	exit 254
fi
TEST=`whereis cp | cut -f2 -d:`
if [ "$TEST" = "" ]; then
	echo "Missing cp."
	exit 253
fi
TEST=`whereis install | cut -f2 -d:`
if [ "$TEST" = "" ]; then
	echo "Missing install."
	exit 252
fi
TEST=`whereis mv | cut -f2 -d:`
if [ "$TEST" = "" ]; then
	echo "Missing mv."
	exit 251
fi
TEST=`whereis pwd | cut -f2 -d:`
if [ "$TEST" = "" ]; then
	echo "Missing pwd."
	exit 250
fi
TEST=`whereis sed | cut -f2 -d:`
if [ "$TEST" = "" ]; then
	echo "Missing sed."
	exit 249
fi
TEST=`whereis rm | cut -f2 -d:`
if [ "$TEST" = "" ]; then
	echo "Missing rm."
	exit 248
fi
TEST=`whereis rmdir | cut -f2 -d:`
if [ "$TEST" = "" ]; then
	echo "Missing rmdir."
	exit 247
fi
TEST=`whereis tar | cut -f2 -d:`
if [ "$TEST" = "" ]; then
	echo "Missing tar."
	exit 246
fi
TEST=`whereis unifdef | cut -f2 -d:`
if [ "$TEST" = "" ]; then
	echo "Missing unifdef."
	exit 245
fi
TEST=`whereis wget | cut -f2 -d:`
if [ "$TEST" = "" ]; then
	echo "Missing wget."
	exit 244
fi

# Set Linux Version
P1=`echo $VERSION | cut -f1 -d.`
P2=`echo $VERSION | cut -f2 -d.`
P3=`echo $VERSION | cut -f3 -d.`
LINUXVERSION="$P1.$P2"

# Our Working Directories
CURRENT_DIR=`pwd -P`
ORIGDIR=$CURRENT_DIR/linux-headers-$VERSION.orig/include
NEWDIR=$CURRENT_DIR/linux-headers-$VERSION/include

# Headers to Sanitize
ASM_HEADERS=$(cat $CURRENT_DIR/lists/asm-headers)
ASM_ARCH_HEADERS=$(cat $CURRENT_DIR/lists/asm-arch-headers)
ASM_SYS_HEADERS=$(cat $CURRENT_DIR/lists/asm-sys-headers)

LINUX_HEADERS=$(cat $CURRENT_DIR/lists/linux-headers)

NOSANTIZE_ASM_HEADERS=$(cat $CURRENT_DIR/lists/no_santize-asm-headers)
NOSANTIZE_LINUX_HEADERS=$(cat $CURRENT_DIR/lists/no_santize-linux-headers)

BLANK_HEADERS=$(cat $CURRENT_DIR/lists/blank-headers)

ROOT_HEADERS=$(cat $CURRENT_DIR/lists/root-headers)
SYS_HEADERS=$(cat $CURRENT_DIR/lists/sys-headers)

GLIBC_HEADERS=$(cat $CURRENT_DIR/lists/glibc-headers)

COPY_HEADERS=$(cat $CURRENT_DIR/lists/copy-headers)

REMOVE_HEADERS=$(cat $CURRENT_DIR/lists/remove-headers)

if [ "$FILE" = "yes" ]; then
	echo "Files List to $CURRENT_DIR/asm-list..."
	for file in $ASM_HEADERS; do
		echo "$file" >> $CURRENT_DIR/asm-list
	done
	echo "Files List to $CURRENT_DIR/linux-list..."
	for file in $LINUX_HEADERS; do
		echo "$file" >> $CURRENT_DIR/linux-list
	done
	exit
fi

if [ "$DUMP" = "yes" ]; then
	echo "Dumping Files List to $CURRENT_DIR/asm-headers..."
	echo "ASM Files Generic" > $CURRENT_DIR/asm-headers
	echo "-----" >> $CURRENT_DIR/asm-headers
	for file in $ASM_HEADERS; do
		echo "$file" >> $CURRENT_DIR/asm-headers
	done
	echo "-----" >> $CURRENT_DIR/asm-headers
	echo "ASM Architecture Specific Files"  >> $CURRENT_DIR/asm-headers
	echo "-----" >> $CURRENT_DIR/asm-headers
	for file in $ASM_ARCH_HEADERS; do
		echo "$file" >> $CURRENT_DIR/asm-headers
	done
	echo "-----" >> $CURRENT_DIR/asm-headers
	echo "ASM Architecture Non Santize Files"  >> $CURRENT_DIR/asm-headers
	echo "-----" >> $CURRENT_DIR/asm-headers
	for file in $NOSANTIZE_ASM_HEADERS; do
		echo "$file" >> $CURRENT_DIR/asm-headers
	done
	echo "Dumping Files List to $CURRENT_DIR/linux-headers..."
	echo "Linux Files" > $CURRENT_DIR/linux-headers
	echo "-----" >> $CURRENT_DIR/linux-headers
	for file in $LINUX_HEADERS; do
		echo "$file" >> $CURRENT_DIR/linux-headers
	done
	echo "-----" >> $CURRENT_DIR/linux-headers
	echo "Linux Non Santize Files"  >> $CURRENT_DIR/linux-headers
	echo "-----" >> $CURRENT_DIR/linux-headers
	for file in $NOSANTIZE_LINUX_HEADERS; do
		echo "$file" >> $CURRENT_DIR/linux-headers
	done
	if [ "$DUMPONLY" = "yes"  ]; then
		echo "Exiting - Dump only requested..."
		exit 0
	fi
fi

if ! [ -f linux-$VERSION.tar.bz2 ]; then
	echo "Downloading kernel linux-$VERSION from kernel.org..."
	wget --quiet http://www.kernel.org/pub/linux/kernel/v$P1.$P2/linux-$VERSION.tar.bz2
	if [ "$?" != "0" ]; then
		echo "Error during Download."
		exit 255
	fi
fi

echo "Decompressing Kernel Headers only..."
rm -rf linux-$VERSION linux-headers-$VERSION linux-headers-$VERSION.orig
tar --wildcards -jxf linux-$VERSION.tar.bz2 linux-$VERSION/include/*
if [ -e $CURRENT_DIR/patches/linux-$VERSION-REQUIRED-1.patch ]; then
	if [ "$PATCHES" = "" ]; then
		PATCHES="linux-$VERSION-REQUIRED-1.patch"
	else
		PATCHES="$PATCHES linux-$VERSION-REQUIRED-1.patch"
	fi
fi
if [ -e $CURRENT_DIR/patches/linux-$VERSION-mips_headers-1.patch ]; then
	if [ "$PATCHES" = "" ]; then
		PATCHES="linux-$VERSION-mips_headers-1.patch"
	else
		PATCHES="$PATCHES linux-$VERSION-mips_headers-1.patch"
	fi
fi
for PATCHFILE in $PATCHES; do
	if [ -e "$CURRENT_DIR/patches/$PATCHFILE" ]; then
		cd linux-$VERSION
		echo "Patching Kernel Headers with $PATCHFILE..."
		patch -Np1 -f -s -i $CURRENT_DIR/patches/$PATCHFILE
		cd ..
	fi
done

if [ "$CHECK" = "yes" ]; then
	cd linux-headers-$VERSION
	rm -f $CURRENT_DIR/missing_headers
	echo "Checking ASM..."
	CHECKHEADERS="$ASM_HEADERS $NOSANTIZE_ASM_HEADERS"
	check_headers
	CHECKHEADERS="$ASM_ARCH_HEADERS $NOSANTIZE_ASM_HEADERS"
	check_headers2
	echo "Checking Linux..."
	CHECKHEADERS="$LINUX_HEADERS"
	check_headers
	CHECKHEADERS="$NOSANTIZE_LINUX_HEADERS"
	check_headers2
	echo "Report is located at $CURRENT_DIR/missing_headers."
	rm -rf linux-headers-$VERSION
	cd $CURRENT_DIR
	exit 0
fi	

echo "Renaming directory to linux-headers-$VERSION..."
mv linux-$VERSION linux-headers-$VERSION.orig

echo "Creating directory Structure..."
install -d linux-headers-$VERSION
cd $ORIGDIR
DIRS=`find * -type d`
cd $CURRENT_DIR
for dir in $DIRS; do
	install -d $NEWDIR/$dir
done

DONT_CHANGE=no
TYPE=asm
HEADERS="$ASM_HEADERS"
if [ "$HEADERS" != "" ]; then
	make_headers
fi

TYPE=asm
HEADERS=$ASM_ARCH_HEADERS
if [ "$HEADERS" != "" ]; then
	make_headers
fi

TYPE=linux
HEADERS=$LINUX_HEADERS
if [ "$HEADERS" != "" ]; then
	make_headers
fi

SETTYPE="byteorder dvb isdn lockd mtd netfilter netfilter_arp netfilter_bridge netfilter_ipv4 netfilter_ipv6
	 nfsd raid sunrpc tc_act tc_ematch"
for type in $SETTYPE; do
	TYPE=linux
	cd $ORIGDIR/linux
	if [ -e $ORIGDIR/linux/$type ]; then
		HEADERS=`find $type | grep .h | sed -e '/big_endian.h/d' | sed -e '/little_endian.h/d' | sort -u `
		if [ "$HEADERS" != "" ]; then
			make_headers
		fi
	fi
done

SETTYPE="mtd scsi sound"
for type in $SETTYPE; do
	TYPE="$type"
	cd $ORIGDIR
	if [ -e $ORIGDIR/$type ]; then
		HEADERS=`find $type | grep .h | sort -u `
		if [ "$HEADERS" != "" ]; then
			make_headers
		fi
	fi
done

DONT_CHANGE=yes
TYPE=linux
HEADERS=$NOSANTIZE_LINUX_HEADERS
if [ "$HEADERS" != "" ]; then
	make_headers
fi

TYPE=asm
HEADERS=$NOSANTIZE_ASM_HEADERS
if [ "$HEADERS" != "" ]; then
	make_headers
fi

for header in $BLANK_HEADERS; do
	CONTENT="/* Empty */"
	TEST=`echo $header | grep -c linux/`
	if [ "$TEST" = "1" ]; then
		create_linux_header
	else
		DIRS=`echo $header | cut -f1 -d/`
		header=`echo $header | sed -e "s@$DIRS/@@g"`
		create_asm_header
	fi
done

for header in $ROOT_HEADERS; do
	new_header=`echo $header | cut -f2 -d/`
	HEADING=`echo $header | tr '[:lower:]' '[:upper:]' | cut -f2 -d/ | cut -f1 -d.`
	CONTENT="#include <$new_header>"
	create_linux_header
done

for header in $SYS_HEADERS; do
	new_header=`echo $header | cut -f2 -d/`
	HEADING=`echo $header | tr '[:lower:]' '[:upper:]' | cut -f2 -d/ | cut -f1 -d.`
	CONTENT="#include <sys/$new_header>"
	create_linux_header
done

cd $NEWDIR
PLATFORM=`ls -1 asm-* -d | sed -e 's/asm-generic//g'`
for platform in $PLATFORM; do
	ELF_H=$NEWDIR/$platform/elf.h
	echo "Fixing include/$platform/elf.h..."
	if [ -e $ELF_H ]; then
		if [ "$platform" = "asm-alpha" ]; then
			sed -e '/#include <asm.auxvec.h>/d' \
		               $ELF_H > $ELF_H.new
		fi
		if [ "$platform" = "asm-arm" -o "$platform" = "asm-cris" ]; then
			sed -e '/#include <asm.user.h>/d' \
			    -e '/#include <asm.procinfo.h>/d' \
		               $ELF_H > $ELF_H.new
		fi
		if [ "$platform" = "asm-h8300" -o "$platform" = "asm-m68k" -o \
                     "$platform" = "asm-sparc" -o "$platform" = "asm-sparc64" ]; then
			sed -e '/#include <asm.ptrace.h>/d' \
		               $ELF_H > $ELF_H.new
		fi
		if [ "$platform" = "asm-i386" -o "$platform" = "asm-x86_64" ]; then
			sed -e '/#include <asm.ptrace.h>/d' \
			    -e '/#include <asm.processor.h>/d' \
			    -e '/#include <asm.system.h>/d' \
			    -e '/#include <asm.auxvec.h>/d' \
			    -e '/#include <linux.utsname.h>/d' \
	        	       $ELF_H > $ELF_H.new
		fi
		if [ "$platform" = "asm-ia64" ]; then
			sed -e '/#include <asm.fpu.h>/d' \
			    -e '/#include <asm.auxvec.h>/d' \
		               $ELF_H > $ELF_H.new
		fi
		if [ "$platform" = "asm-m32r" ]; then
			sed -e 's@#include <asm/user.h>@#include <asm/user.h>\n#include <asm/page.h>@' \
		               $ELF_H > $ELF_H.new
		fi
		if [ "$platform" = "asm-m68knommu" ]; then
			sed -e '/#include <asm.ptrace.h>/d' \
			    -e '/#include <asm.user.h>/d' \
		               $ELF_H > $ELF_H.new
		fi
		if [ "$platform" = "asm-parisc" ]; then
			sed -e 's@#include <asm/ptrace.h>@#include <asm/types.h>@' \
		               $ELF_H > $ELF_H.new
		fi
		if [ "$platform" = "asm-powerpc" ]; then
			sed -e '/#include <asm.auxvec.h>/d' \
		               $ELF_H > $ELF_H.new
		fi
		if [ "$platform" = "asm-s390" ]; then
			sed -e 's/#define __ASMS390_ELF_H/#define __ASMS390_ELF_H\n\nNeXtLiNe/' \
		               $ELF_H > $ELF_H.new
			cp $ELF_H.new $ELF_H
			sed -e 's@NeXtLiNe@#include <asm/ptrace.h>\n#include <asm/system.h>\n@' \
		               $ELF_H > $ELF_H.new
		fi
		if [ "$platform" = "asm-sparc64" ]; then
			sed -e 's@#define __ASM_SPARC64_ELF_H@#define __ASM_SPARC64_ELF_H\n\n#include <asm/spitfire.h>\n@' \
	        	       $ELF_H > $ELF_H.new
		fi
		if [ "$platform" = "asm-sh" ]; then
			sed -e 's@#define __ASM_SH_ELF_H@#define __ASM_SH_ELF_H\n\n#include <asm/ptrace.h>\n@' \
	        	       $ELF_H > $ELF_H.new
		fi
		if [ "$platform" = "asm-v850" ]; then
			sed -e '/#include <asm.user.h>/d' \
			    -e '/#include <asm.byteorder.h/d' \
		               $ELF_H > $ELF_H.new
		fi
		if [ -e $ELF_H.new ]; then
			cp $ELF_H.new $ELF_H
		fi
		clean_header $ELF_H
	fi
done

cp $ORIGDIR/asm-ia64/page.h $NEWDIR/asm-ia64/page.h
PAGE_H=$NEWDIR/asm-ia64/page.h
echo "Processing include/asm-ia64/page.h..."
unifdef -e -UCONFIG_IA64_PAGE_SIZE_4KB -UCONFIG_IA64_PAGE_SIZE_8KB \
	-UCONFIG_IA64_PAGE_SIZE_16KB -UCONFIG_IA64_PAGE_SIZE_64KB $PAGE_H > $PAGE_H.new
cp $PAGE_H.new $PAGE_H
sed -e 's/# error Unsupported page size./#define PAGE_SIZE\tsysconf (_SC_PAGE_SIZE)\nNeXtLiNe/' $PAGE_H > $PAGE_H.new
cp $PAGE_H.new $PAGE_H
sed -e 's/NeXtLiNe/\n#define PAGE_SHIFT\t(getpageshift())/' $PAGE_H > $PAGE_H.new
mv $PAGE_H.new $PAGE_H
clean_header $PAGE_H
	
cd $NEWDIR
PLATFORM=`ls -1 asm-* -d | sed -e 's/asm-generic//g' -e 's/asm-ia64//g'`
for platform in $PLATFORM; do
	PAGE_H=$NEWDIR/$platform/page.h
	echo "Creating include/$platform/page.h..."
	if [ "$platform" = "asm-alpha" ]; then
		FILEHEADER="_ALPHA_PAGE_H"
	fi
	if [ "$platform" = "asm-arm" -o "$platform" = "asm-arm26" ]; then
		FILEHEADER="_ASMARM_PAGE_H"
	fi
	if [ "$platform" = "asm-cris" ]; then
		FILEHEADER="_CRIS_PAGE_H"
	fi
	if [ "$platform" = "asm-h8300" ]; then
		FILEHEADER="_H8300_PAGE_H"
	fi
	if [ "$platform" = "asm-i386" ]; then
		FILEHEADER="_I386_PAGE_H"
	fi
	if [ "$platform" = "asm-m68k" ]; then
		FILEHEADER="_M68K_PAGE_H"
	fi
	if [ "$platform" = "asm-m68knommu" ]; then
		FILEHEADER="_M68KNOMMU_PAGE_H"
	fi
	if [ "$platform" = "asm-mips" -o "$platform" = "asm-frv" ]; then
		FILEHEADER="_ASM_PAGE_H"
	fi
	if [ "$platform" = "asm-parisc" ]; then
		FILEHEADER="_PARISC_PAGE_H"
	fi
	if [ "$platform" = "asm-ppc" ]; then
		FILEHEADER="_PPC_PAGE_H"
	fi
	if [ "$platform" = "asm-powerpc" ]; then
		FILEHEADER="_ASM_POWERPC_PAGE_H"
	fi
	if [ "$platform" = "asm-s390" ]; then
		FILEHEADER="_S390_PAGE_H"
	fi
	if [ "$platform" = "asm-sh" ]; then
		FILEHEADER="__ASM_SH_PAGE_H"
	fi
	if [ "$platform" = "asm-sh64" ]; then
		FILEHEADER="__ASM_SH64_PAGE_H"
	fi
	if [ "$platform" = "asm-sparc" ]; then
		FILEHEADER="_SPARC_PAGE_H"
	fi
	if [ "$platform" = "asm-sparc64" ]; then
		FILEHEADER="_SPARC64_PAGE_H"
	fi
	if [ "$platform" = "asm-um" ]; then
		FILEHEADER="__UM_PAGE_H"
	fi
	if [ "$platform" = "asm-v850" ]; then
		FILEHEADER="__V850_PAGE_H__"
	fi
	if [ "$platform" = "asm-x86_64" ]; then
		FILEHEADER="_X86_64_PAGE_H"
	fi
	if [ "$platform" = "asm-xtensa" ]; then
		FILEHEADER="_XTENSA_PAGE_H"
	fi
	echo "#ifndef $FILEHEADER" > $PAGE_H
	echo "#define $FILEHEADER" >> $PAGE_H
	echo "" >> $PAGE_H
	if [ "$platform" = "asm-alpha" ]; then
		echo "#include <asm/pal.h>" >> $PAGE_H
	fi
	echo "#include <unistd.h>" >> $PAGE_H
	if [ "$platform" = "asm-arm26" ]; then
		echo "#define EXEC_PAGESIZE	32768" >> $PAGE_H
	fi
	echo "" >> $PAGE_H
	echo "#define PAGE_SIZE	sysconf (_SC_PAGE_SIZE)" >> $PAGE_H
	echo "#define PAGE_SHIFT	(getpageshift())" >> $PAGE_H
	echo "#define PAGE_MASK	(~(PAGE_SIZE-1))" >> $PAGE_H
	echo "" >> $PAGE_H
	if [ "$platform" = "asm-arm26" ]; then
		echo "#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)">> $PAGE_H
	fi
	if [ "$platform" = "asm-mips" ]; then
		echo "#ifdef CONFIG_LIMITED_DMA" >> $PAGE_H
		echo "#define WANT_PAGE_VIRTUAL" >> $PAGE_H
		echo "#endif" >> $PAGE_H
		echo "" >> $PAGE_H
	fi
	if [ "$platform" = "asm-v850" ]; then
		echo "#ifndef PAGE_OFFSET" >> $PAGE_H
		echo "#define PAGE_OFFSET	0x0000000" >> $PAGE_H
		echo "#endif" >> $PAGE_H
		echo "" >> $PAGE_H
	fi
	echo "#endif /* ($FILEHEADER) */" >> $PAGE_H
	clean_header $PAGE_H
done

PLATFORM="asm-m68k asm-sparc asm-sparc64"
for platform in $PLATFORM; do
	KBIO_H=$NEWDIR/$platform/kbio.h
	echo "Creating include/$platform/kbio.h..."
	echo "#ifndef __LINUX_KBIO_H" > $KBIO_H
	echo "#define __LINUX_KBIO_H" >> $KBIO_H
	echo "" >> $KBIO_H
	echo "#define KIOCTYPE    _IOR('k', 9, int)" >> $KBIO_H
	echo "" >> $KBIO_H
	echo "#define KIOCLAYOUT  _IOR('k', 20, int)" >> $KBIO_H
	echo "" >> $KBIO_H
	echo "enum {" >> $KBIO_H
	echo "    TR_NONE," >> $KBIO_H
	echo "    TR_ASCII," >> $KBIO_H
	echo "    TR_EVENT," >> $KBIO_H
	echo "    TR_UNTRANS_EVENT" >> $KBIO_H
	echo "};" >> $KBIO_H
	echo "" >> $KBIO_H
	echo "#define KIOCGTRANS  _IOR('k', 5, int)" >> $KBIO_H
	echo "" >> $KBIO_H
	echo "#define KIOCTRANS   _IOW('k', 0, int)" >> $KBIO_H
	echo "" >> $KBIO_H
	echo "#define KIOCCMD     _IOW('k', 8, int)" >> $KBIO_H
	echo "" >> $KBIO_H
	echo "#define KIOCSDIRECT _IOW('k', 10, int)" >> $KBIO_H
	echo "" >> $KBIO_H
	echo "#define KIOCSLED    _IOW('k', 14, unsigned char)" >> $KBIO_H
	echo "" >> $KBIO_H
	echo "#define KIOCGLED    _IOR('k', 15, unsigned char)" >> $KBIO_H
	echo "struct kbd_rate {" >> $KBIO_H
	echo "        unsigned char delay;" >> $KBIO_H
	echo "        unsigned char rate; " >> $KBIO_H
	echo "};" >> $KBIO_H
	echo "" >> $KBIO_H
	echo "#define KIOCSRATE   _IOW('k', 40, struct kbd_rate)" >> $KBIO_H
	echo "" >> $KBIO_H
	echo "#define KIOCGRATE   _IOW('k', 41, struct kbd_rate)" >> $KBIO_H
	echo "" >> $KBIO_H
	echo "#define KBD_UP      0x80" >> $KBIO_H
	echo "" >> $KBIO_H
	echo "#define KBD_KEYMASK 0x7f" >> $KBIO_H
	echo "" >> $KBIO_H
	echo "#define KBD_IDLE    0x75" >> $KBIO_H
	echo "" >> $KBIO_H
	echo "#endif /* __LINUX_KBIO_H */" >> $KBIO_H
	clean_header $KBIO_H
done

CACHE_H=$NEWDIR/asm-i386/cache.h
echo "Fixing include/asm-i386/cache.h..."
sed -e 's@CONFIG_X86_L1_CACHE_SHIFT@7@' $CACHE_H > $CACHE_H.new
mv $CACHE_H.new $CACHE_H
clean_header $CACHE_H

CACHE_H=$NEWDIR/asm-x86_64/cache.h
echo "Fixing include/asm-x86_64/cache.h..."
sed -e 's@CONFIG_X86_L1_CACHE_SHIFT@7@' $CACHE_H > $CACHE_H.new
mv $CACHE_H.new $CACHE_H
clean_header $CACHE_H

PARAM_H=$NEWDIR/asm-i386/param.h
echo "Fixing include/asm-i386/param.h..."
sed -e 's@#define HZ 100@#define HZ\t\t100\n#endif\n\nNeXtLiNe\n@' $PARAM_H > $PARAM_H.new
cp $PARAM_H.new $PARAM_H
sed -e 's@NeXtLiNe@#ifndef USER_HZ\n#define USER_HZ\t\t100@' $PARAM_H > $PARAM_H.new
mv $PARAM_H.new $PARAM_H
clean_header $PARAM_H

PROCESSOR_H=$NEWDIR/asm-i386/processor.h
echo "Fixing include/asm-i386/processor.h..."
sed -e 's@#include <asm/segment.h>@#include <asm/segment.h>\n#include <asm/page.h>@' $PROCESSOR_H > $PROCESSOR_H.new
mv $PROCESSOR_H.new $PROCESSOR_H
clean_header $PROCESSOR_H

PROCESSOR_H=$NEWDIR/asm-x86_64/processor.h
echo "Fixing include/asm-x86_64/processor.h..."
sed -e 's@#include <asm/segment.h>@#include <asm/segment.h>\n#include <asm/page.h>@' $PROCESSOR_H > $PROCESSOR_H.new
mv $PROCESSOR_H.new $PROCESSOR_H
clean_header $PROCESSOR_H

TERMIOS_H=$NEWDIR/asm-sparc/termios.h
echo "Fixing include/asm-sparc/termios.h..."
sed -e 's@struct sunos_ttysize@#endif\n\nstruct sunos_ttysize@' $TERMIOS_H > $TERMIOS_H.new
mv $TERMIOS_H.new $TERMIOS_H
clean_header $TERMIOS_H

TERMIOS_H=$NEWDIR/asm-sparc64/termios.h
echo "Fixing include/asm-sparc64/termios.h..."
sed -e 's@struct sunos_ttysize@#endif\n\nstruct sunos_ttysize@' $TERMIOS_H > $TERMIOS_H.new
mv $TERMIOS_H.new $TERMIOS_H
clean_header $TERMIOS_H

cd $NEWDIR
for header in `find * -name types.h` ; do
	echo "Fixing include/$header..."
	sed -e 's@&& !defined(__STRICT_ANSI__)@@' $header > $header.new
	mv $header.new $header
	clean_header $header
done

for header in $ASM_SYS_HEADERS; do
	cd $NEWDIR
	DIRS=`ls -1 asm-* -d | sed -e 's/asm-generic//g'`
	CONTENT="#include <sys/$header>"
	create_asm_header
done

VERSION_H=$NEWDIR/linux/version.h
echo "Creating include/linux/version.h..."
let LINUXCODE="($P1<<16)+($P2<<8)+$P3"
echo "#ifndef _LINUX_VERSION_H" > $VERSION_H
echo "#define _LINUX_VERSION_H" >> $VERSION_H
echo "" >> $VERSION_H
echo "#define UTS_RELEASE \"$P1.$P2.$P3\"" >> $VERSION_H
echo "#define LINUX_VERSION_CODE $LINUXCODE" >> $VERSION_H
echo "#define KERNEL_VERSION(a,b,c) (((a) << 16) + ((b) << 8) + (c))" >> $VERSION_H
echo "" >> $VERSION_H
echo "#endif /* _LINUX_VERSION_H */" >> $VERSION_H
clean_header $VERSION_H

BIG_ENDIAN_H=include/linux/byteorder/big_endian.h
LITTLE_ENDIAN_H=include/linux/byteorder/little_endian.h
HEADERS="$BIG_ENDIAN_H $LITTLE_ENDIAN_H"
for hdr in $HEADERS; do	
	echo "Fixing $hdr..."
	sed -e 's/(__force __be..)//' \
	    -e 's/(__force __u..)//' \
	    -e 's/(__force __le..)//' \
	    -e '/#include <linux.byteorder.generic.h>/d' \
	    -e '/static/,/#define/d' \
	    -e 's/\b[us]\(8\|16\|32\|64\)\b/__&/g' \
	    -e 's/\b__\(be\|le\)\(16\|32\|64\)\b/__u\2/g' \
	       $CURRENT_DIR/linux-headers-$VERSION/$hdr > $CURRENT_DIR/linux-headers-$VERSION/$hdr.new
       	mv $CURRENT_DIR/linux-headers-$VERSION/$hdr.new $CURRENT_DIR/linux-headers-$VERSION/$hdr
	clean_header $CURRENT_DIR/linux-headers-$VERSION/$hdr
done

ATOMIC_H=$NEWDIR/asm-mips/atomic.h
echo "Creating include/asm-mips/atomic.h..."
echo "#ifndef _ASM_ATOMIC_H" > $ATOMIC_H
echo "#define _ASM_ATOMIC_H" >> $ATOMIC_H
echo "" >> $ATOMIC_H
echo "typedef struct { volatile int counter; } atomic_t;" >> $ATOMIC_H
echo "" >> $ATOMIC_H
echo "#ifdef __mips64" >> $ATOMIC_H
echo "typedef struct { volatile long counter; } atomic64_t;" >> $ATOMIC_H
echo "#endif" >> $ATOMIC_H
echo "" >> $ATOMIC_H
echo "#endif /* _ASM_ATOMIC_H */" >> $ATOMIC_H
clean_header $ATOMIC_H

ATOMIC_H=$NEWDIR/asm-i386/atomic.h
echo "Fixing include/asm-i386/atomic.h"
if [ -e $NEWDIR/asm-i386/alternative.h ]; then
	sed -e 's@#include <asm.processor.h>@#include <asm/alternative.h>@g' $ATOMIC_H > $ATOMIC_H.new
else
	sed -e '/#include <asm.processor.h>/d' $ATOMIC_H > $ATOMIC_H.new
fi
mv $ATOMIC_H.new $ATOMIC_H
clean_header $ATOMIC_H

HEADER_FILE="agpgart.h"
HEADER_NAME="_AGP_H 1"
HEADER_UPDATE="#include <asm/types.h>"
change_header

HEADER_FILE="atmarp.h"
HEADER_NAME="_LINUX_ATMARP_H"
HEADER_UPDATE="#include <linux/types.h>"
change_header

ATM_H=$NEWDIR/linux/atm.h
echo "Fixing include/linux/atm.h..."
sed -e 's@#include <linux/atmapi.h>@#include <linux/types.h>\n#include <linux/atmapi.h>@' $ATM_H > $ATM_H.new
cp $ATM_H.new $ATM_H
sed -e 's@#include <linux/atmioc.h>@#include <linux/atmioc.h>\n#include <stdint.h>@' $ATM_H > $ATM_H.new
mv $ATM_H.new $ATM_H
clean_header $ATM_H

ATM_TCP_H=$NEWDIR/linux/atm_tcp.h
echo "Fixing include/linux/atm_tcp.h..."
sed -e 's@#include <linux/atmapi.h>@#include <linux/types.h>\n#include <linux/atmapi.h>@' $ATM_TCP_H > $ATM_TCP_H.new
cp $ATM_TCP_H.new $ATM_TCP_H
clean_header $ATM_TCP_H

echo "Creating include/linux/ax25.h..."
echo "#include <netax25/ax25.h>" > $NEWDIR/linux/ax25.h

ELF_H=$NEWDIR/linux/elf.h
echo "Fixing include/linux/elf.h..."
sed -e 's@#include <elf.h>@#include <elf.h>\n#include <asm/elf.h>@' $ELF_H > $ELF_H.new
mv $ELF_H.new $ELF_H
clean_header $ELF_H

HEADER_FILE="ethtool.h"
HEADER_NAME="_LINUX_ETHTOOL_H"
HEADER_UPDATE="#include <asm/types.h>"
change_header

FS_H=$NEWDIR/linux/fs.h
echo "Fixing include/linux/fs.h..."
sed -e 's@#include <linux/limits.h>@#include <linux/types.h>\n#include <linux/limits.h>@' $FS_H > $FS_H.new
mv $FS_H.new $FS_H
clean_header $FS_H

HEADER_FILE="if_fc.h"
HEADER_NAME="_LINUX_IF_FC_H"
HEADER_UPDATE="#include <asm/types.h>"
change_header

IF_HIPPI_H=$NEWDIR/linux/if_hippi.h
echo "Fixing include/linux/if_hippi.h..."
sed -e 's@#include <asm/byteorder.h>@#include <endian.h>\n#include <byteswap.h>\nNeXtLiNe@' $IF_HIPPI_H > $IF_HIPPI_H.new
cp $IF_HIPPI_H.new $IF_HIPPI_H
sed -e 's@NeXtLiNe@#include <asm/types.h>@' $IF_HIPPI_H > $IF_HIPPI_H.new
mv $IF_HIPPI_H.new $IF_HIPPI_H
clean_header $IF_HIPPI_H

IF_PPPOX_H=$NEWDIR/linux/if_pppox.h
echo "Fixing include/linux/if_pppox.h..."
sed -e 's@#define __LINUX_IF_PPPOX_H@#define __LINUX_IF_PPPOX_H\n\n#include <linux/if.h>\nNeXtLiNe@' $IF_PPPOX_H > $IF_PPPOX_H.new
cp $IF_PPPOX_H.new $IF_PPPOX_H
sed -e 's@NeXtLiNe@#include <linux/if_ether.h>@' $IF_PPPOX_H > $IF_PPPOX_H.new
cp $IF_PPPOX_H.new $IF_PPPOX_H
sed -e 's@#include <asm/byteorder.h>@#include <endian.h>\n#include <byteswap.h>\nNeXtLiNe@' $IF_PPPOX_H > $IF_PPPOX_H.new
cp $IF_PPPOX_H.new $IF_PPPOX_H
sed -e 's@NeXtLiNe@#include <asm/byteorder.h>@' $IF_PPPOX_H > $IF_PPPOX_H.new
mv $IF_PPPOX_H.new $IF_PPPOX_H
clean_header $IF_PPPOX_H

HEADER_FILE="if_strip.h"
HEADER_NAME="__LINUX_STRIP_H"
HEADER_UPDATE="#include <asm/types.h>"
change_header

IF_TUNNEL_H=$NEWDIR/linux/if_tunnel.h
echo "Fixing include/linux/if_tunnel.h..."
sed -e 's/#define _IF_TUNNEL_H_/#define _IF_TUNNEL_H_\n\nNeXtLiNe/' $IF_TUNNEL_H > $IF_TUNNEL_H.new
cp $IF_TUNNEL_H.new $IF_TUNNEL_H
sed -e 's@NeXtLiNe@#include <linux/if.h>\nNeXtLiNe@' $IF_TUNNEL_H > $IF_TUNNEL_H.new
cp $IF_TUNNEL_H.new $IF_TUNNEL_H
sed -e 's@NeXtLiNe@#include <linux/ip.h>\nNeXtLiNe@' $IF_TUNNEL_H > $IF_TUNNEL_H.new
cp $IF_TUNNEL_H.new $IF_TUNNEL_H
sed -e 's@NeXtLiNe@#include <asm/types.h>\nNeXtLiNe@' $IF_TUNNEL_H > $IF_TUNNEL_H.new
cp $IF_TUNNEL_H.new $IF_TUNNEL_H
sed -e 's@NeXtLiNe@#include <asm/byteorder.h>@' $IF_TUNNEL_H > $IF_TUNNEL_H.new
mv $IF_TUNNEL_H.new $IF_TUNNEL_H
clean_header $IF_TUNNEL_H

HEADER_FILE="if_tr.h"
HEADER_NAME="_LINUX_IF_TR_H"
HEADER_UPDATE="#include <asm/types.h>"
change_header

if [ "$LINUXCODE" -lt "132625" ]; then
	INPUT_H=$NEWDIR/linux/input.h
	echo "Fixing include/linux/input.h..."
	sed -e '/struct input_device_id/,/INPUT_DEVICE_ID_MATCH_SWBIT/d' $INPUT_H > $INPUT_H.new
	mv $INPUT_H.new $INPUT_H
	clean_header $INPUT_H
fi

JOYSTICK_H=$NEWDIR/linux/joystick.h
echo "Fixing include/linux/joystick.h..."
sed -e 's@int32_t@__s32@' $JOYSTICK_H > $JOYSTICK_H.new
cp $JOYSTICK_H.new $JOYSTICK_H
sed -e 's@int64_t@__s64@' $JOYSTICK_H > $JOYSTICK_H.new
mv $JOYSTICK_H.new $JOYSTICK_H
clean_header $JOYSTICK_H

PCI_H=$NEWDIR/linux/pci.h
echo "Fixing include/linux/pci.h..."
sed -e '/#include <linux.mod_devicetable.h>/d' $PCI_H > $PCI_H.new
mv $PCI_H.new $PCI_H
clean_header $PCI_H

echo "Creating include/linux/netrom.h..."
echo "#include <netrom/netrom.h>" > $NEWDIR/linux/netrom.h

NFS3_H=$NEWDIR/linux/nfs3.h
echo "Fixing include/linux/nfs3.h..."
sed -e 's@#endif /. _LINUX_NFS3_H ./@@' $NFS3_H > $NFS3_H.new
cp $NFS3_H.new $NFS3_H
echo "#endif /* NFS_NEED_KERNEL_TYPES */" >> $NFS3_H
echo "#endif /* _LINUX_NFS3_H */" >> $NFS3_H
clean_header $NFS3_H

RTNETLINK_H=$NEWDIR/linux/rtnetlink.h
echo "Fixing include/linux/rtnetlink.h..."
sed -e 's@#define RTPROT_XORP	14	.* XORP *..@#define RTPROT_XORP\t14\t/* XORP */\nNeXtLiNe@' $RTNETLINK_H > $RTNETLINK_H.new
cp $RTNETLINK_H.new $RTNETLINK_H
sed -e 's@NeXtLiNe@#define RTPROT_NTK\t15\t/* Netsukuku */@' $RTNETLINK_H > $RTNETLINK_H.new
mv $RTNETLINK_H.new $RTNETLINK_H
clean_header $RTNETLINK_H

SWAB_H=$NEWDIR/linux/byteorder/swab.h
HEADER_FILE="byteorder/swab.h"
HEADER_NAME="_LINUX_BYTEORDER_SWAB_H"
HEADER_UPDATE="#include <byteswap.h>"
change_header
sed -e '/#ifndef __arch__swab16/,/#endif .* _LINUX_BYTEORDER_SWAB_H *./d' $SWAB_H > $SWAB_H.new
cp $SWAB_H.new $SWAB_H
sed -e 's/provide defaults when no architecture-specific optimization is detected/definitions that are not in glibc but required/g' $SWAB_H > $SWAB_H.new
mv $SWAB_H.new $SWAB_H
if [ "$LINUXCODE" -gt "132625" ]; then
	echo "" >> $SWAB_H
	echo "#define ___constant_swab16(x) __bswap_constant_16(x)" >> $SWAB_H
	echo "#define ___constant_swab32(x) __bswap_constant_32(x)" >> $SWAB_H
	echo "#define ___constant_swab64(x) __bswap_constant_64(x)" >> $SWAB_H
	echo "" >> $SWAB_H
	echo "#define __swab16(x) bswap_16(x)" >> $SWAB_H
	echo "#define __swab32(x) bswap_32(x)" >> $SWAB_H
	echo "#define __swab64(x) bswap_64(x)" >> $SWAB_H
	echo "" >> $SWAB_H
	echo "#define __swab16p(x) __swab16(*(x))" >> $SWAB_H
	echo "#define __swab32p(x) __swab32(*(x))" >> $SWAB_H
	echo "#define __swab64p(x) __swab64(*(x))" >> $SWAB_H
	echo "" >> $SWAB_H
	echo "#define __swab16s(x) do { *(x) = __swab16p((x)); } while (0)" >> $SWAB_H
	echo "#define __swab32s(x) do { *(x) = __swab32p((x)); } while (0)" >> $SWAB_H
	echo "#define __swab64s(x) do { *(x) = __swab64p((x)); } while (0)" >> $SWAB_H
	echo "" >> $SWAB_H
fi
echo "#endif /* _LINUX_BYTEORDER_SWAB_H */" >> $SWAB_H
clean_header $SWAB_H

TIME_H=$NEWDIR/linux/time.h
echo "Creating include/linux/time.h..."
echo "#ifndef LINUX_TIME_H" > $TIME_H
echo "" >> $TIME_H
echo "#define MSEC_PER_SEC	1000L" >> $TIME_H
echo "#define USEC_PER_SEC	1000000L" >> $TIME_H
echo "#define NSEC_PER_SEC	1000000000L" >> $TIME_H
echo "#define NSEC_PER_USEC	1000L" >> $TIME_H
echo "" >> $TIME_H
echo "#include <sys/time.h>" >> $TIME_H
echo "" >> $TIME_H
echo "#endif" >> $TIME_H

TYPES_H=$NEWDIR/linux/types.h
echo "Fixing include/linux/types.h..."
sed -e 's@#include <linux/posix_types.h>@#include <sys/types.h>\n#include <linux/posix_types.h>@' $TYPES_H > $TYPES_H.new
cp $TYPES_H.new $TYPES_H
sed -e 's@typedef __u32 __kernel_dev_t;@typedef __u32 __kernel_dev_t;\n\n#if defined(WANT_KERNEL_TYPES) || !defined(__GLIBC__)@' $TYPES_H > $TYPES_H.new
cp $TYPES_H.new $TYPES_H
sed -e 's@#endif /. __KERNEL_STRICT_NAMES ./@\n#endif\n#endif\n\n@' $TYPES_H > $TYPES_H.new
cp $TYPES_H.new $TYPES_H
clean_header $TYPES_H

for files in $COPY_HEADERS; do
	echo "$files" | {
		IFS=':' read sfile dfile
		echo "Copying $sfile to $dfile..."
		cp $NEWDIR/$sfile $NEWDIR/$dfile
	}
done

for file in $REMOVE_HEADERS; do
	echo "Removing unused header $file..."
	rm -f $NEWDIR/$file
done

echo "Removing Headers that are replaced by glibc headers..."
for file in $GLIBC_HEADERS; do
	rm $NEWDIR/$file
done

if [ "$LINUXCODE" -gt "132625" ]; then
	HEADER_FILE="videodev.h"
	HEADER_NAME="__LINUX_VIDEODEV_H"
	HEADER_UPDATE="#include <linux/types.h>"
	change_header
	VIDEODEV_H=$NEWDIR/linux/videodev.h
	sed -e '/CONFIG_VIDEO_V4L1_COMPAT/d' $VIDEODEV_H > $VIDEODEV_H.new
	cp $VIDEODEV_H.new $VIDEODEV_H
	clean_header $VIDEODEV_H
fi

echo "Removing any Kbuild files..."
cd $CURRENT_DIR/linux-headers-$VERSION
FILES=`find * -name Kbuild`
for file in $FILES; do
	rm -f $file
done

echo "Cleaning up linux-headers-$VERSION directories..."
PASS=1
while [ "$PASS" -lt "4" ]; do
	cd $CURRENT_DIR/linux-headers-$VERSION
	DIRS=`find * -type d`
	cd $CURRENT_DIR
	for dir in $DIRS; do
		if [ -e $CURRENT_DIR/linux-headers-$VERSION/$dir ]; then
			rmdir $CURRENT_DIR/linux-headers-$VERSION/$dir > /dev/null 2>&1
			if [ "$?" = "0" ]; then
				echo "Removing empty directory linux-headers-$VERSION/$dir..."
			fi
		fi
	done
	PASS=$(($PASS + 1))
done

echo "Creating multilib headers for x86_64..."
multilib_stubs x86_64 i386 __x86_64__
echo "Creating multilib headers for Sparc64..."
multilib_stubs sparc64 sparc __arch64__

count=`find $CURRENT_DIR/linux-headers-$VERSION -type f | wc -l`
echo "Processed $count headers..."

creation="$CURRENT_DIR/linux-headers-$VERSION/creation"
echo "Processed $count headers on `date +%m-%d-%Y` at `date +%r`" > $creation
echo "based on $VERSION kernel." >> $creation
if [ -e "$CURRENT_DIR/patches/$PATCHFILE" ]; then
	echo "Utilized patch - $PATCHFILE" >> $creation
fi

bugreport="$CURRENT_DIR/linux-headers-$VERSION/bug-report"
echo "Report bugs at http://headers.cross-lfs.org" > $bugreport
echo "" >> $bugreport
echo "Include the following information:" >> $bugreport
echo "		Program Name" >> $bugreport
echo "		Program Version" >> $bugreport
echo "		URL to Download Program" >> $bugreport
echo "		Name of Missing Header" >> $bugreport
echo "" >> $bugreport
echo "or"  >> $bugreport
echo "Use the headers_list script from" >> $bugreport
echo "http://ftp.jg555.com/headers/headers_list" >> $bugreport
echo "" >> $bugreport
echo "Thank you for you support of Linux-Headers." >> $bugreport

install -d $CURRENT_DIR/linux-headers-$VERSION/script
cp $0 $CURRENT_DIR/linux-headers-$VERSION/script
install -d $CURRENT_DIR/linux-headers-$VERSION/lists
cp $CURRENT_DIR/lists/* $CURRENT_DIR/linux-headers-$VERSION/lists
install -d $CURRENT_DIR/linux-headers-$VERSION/script/patches
if [ -e $CURRENT_DIR/patches/linux-$VERSION-REQUIRED-1.patch ]; then
	cp $CURRENT_DIR/patches/linux-$VERSION-REQUIRED-1.patch $CURRENT_DIR/linux-headers-$VERSION/script/patches/linux-$VERSION-REQUIRED-1.patch
fi
if [ -e $CURRENT_DIR/patches/linux-$VERSION-mips_headers-1.patch ]; then
	cp $CURRENT_DIR/patches/linux-$VERSION-mips_headers-1.patch $CURRENT_DIR/linux-headers-$VERSION/script/patches/linux-$VERSION-mips_headers-1.patch
fi
for PATCHFILE in $PATCHES; do
        if [ -e "$CURRENT_DIR/patches/$PATCHFILE" ]; then
		cp $CURRENT_DIR/patches/$PATCHFILE $CURRENT_DIR/linux-headers-$VERSION/script/patches/$PATCHFILE
        fi
done

cp license $CURRENT_DIR/linux-headers-$VERSION/license

echo "Creating linux-headers-$VERSION.tar.bz2..."
cd $CURRENT_DIR
tar -jcf linux-headers-$VERSION.tar.bz2 linux-headers-$VERSION
