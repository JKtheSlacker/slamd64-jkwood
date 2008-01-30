#!/bin/sh
#
# Description: This script set the environment variables G_FILENAME_ENCODING and  G_BROKEN_FILENAMES 
#			for Glib library
#
#
# G_FILENAME_ENCODING
#       This environment variable can be set to a comma-separated list of character set names. 
#	GLib assumes that filenames are encoded in the first character set from that list rather than in UTF-8. 
#	The special token "@locale" can be used to specify the character set for the current locale.

export G_FILENAME_ENCODING="@locale"

# G_BROKEN_FILENAMES  
#	If this environment variable is set, GLib assumes that filenames are in the locale encoding rather than in UTF-8. 

export G_BROKEN_FILENAMES=1

# G_FILENAME_ENCODING takes priority over G_BROKEN_FILENAMES. 