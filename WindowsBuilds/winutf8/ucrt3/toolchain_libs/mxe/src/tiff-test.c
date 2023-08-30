/* based on http://www.libtiff.org/libtiff.html */

#include "tiffio.h"

int main(void)
{
    char *fn = "dummy.tif";
    TIFF* tif = TIFFOpen(fn, "r");
    if (tif) {
	int dircount = 0;
	do {
	    dircount++;
	} while (TIFFReadDirectory(tif));
	printf("%d directories in %s\n", dircount, fn);
	TIFFClose(tif);
    }
    return 0;
}