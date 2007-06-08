BASE=$(shell pwd)/../

TVER=2.5
TARGET=R-$(TVER)-macosx

BIOCREPOS=$(shell cat $(BASE)/bioc.repos)

BIOCSUM=${BIOCREPOS:%=%/$(TARGET)}

SUM=$(TARGET) $(BIOCSUM)
PKG=${SUM:%=%/PKGS}

all: $(PKG)

$(TARGET):
	mkdir -p $@

$(TARGET)/PKGS: $(TARGET)
	rm -f $@
	ln -s ../../tiger-universal/results/$(TVER) $@

%/$(TARGET):
	mkdir -p $@

%/$(TARGET)/PKGS: % %/$(TARGET)
	rm -f $@
	ln -s $(BASE)/BIOC.new/bin/$</tiger-universal/results/$(TVER) $@

run:
	sh run

clean:
	rm -rf out *~

.PHONY: all run clean
