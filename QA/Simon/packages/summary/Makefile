BASE=$(shell pwd)/../
BIOCREPOS=$(shell cat $(BASE)/bioc.repos)

BIOCSUM=${BIOCREPOS:%=%/R-2.5-macosx}

SUM=R-2.5-macosx $(BIOCSUM)
PKG=${SUM:%=%/PKGS}

all: $(PKG)

%/R-2.5-macosx:
	mkdir -p $@

%/R-2.5-macosx/PKGS: % %/R-2.5-macosx
	rm -f $@
	ln -s $(BASE)/BIOC.new/bin/$</tiger-universal/results/2.5 $@
