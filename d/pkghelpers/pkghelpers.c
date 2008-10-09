/*
 * Copyright (c) 2008, Fred Emmott <mail@fredemmott.co.uk>
 * 
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char** argv)
{
	if(argc == 2 || (argc == 3 && strncmp(argv[2], "expand", 7) == 0))
	{
		if(argc == 2)
			execl("/bin/pkghelpers.sh", "/bin/pkghelpers.sh", argv[1], 0);
		else
			execl("/bin/pkghelpers.sh", "/bin/pkghelpers.sh", argv[1], "expand", 0);
		return 0;
	}
	else
	{
		printf("Syntax: %s buildscript [expand]\nThis program just calls /bin/pkghelpers.sh buildscript\n", argv[0]);
		return 1;
	}
}
