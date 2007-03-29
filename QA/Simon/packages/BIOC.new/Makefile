SDIRS:=$(shell find ?.? -type d -name contrib)
TARS:=$(shell find $(SDIRS) -name \*.tar.gz)
BDIRS:=$(shell for i in `find bin/* -name tiger-universal -type d`; do ls -d $$i/bin/?*; done)
BINS:=$(shell find $(BDIRS) -name \*.tgz)
DIRS=$(BDIRS) $(SDIRS)

METADIRS = $(DIRS:%=meta/%)
DESCS = $(TARS:%.tar.gz=meta/%.DESCRIPTION) $(BINS:%.tgz=meta/%.DESCRIPTION)

all: cache

cache: meta $(METADIRS) $(DESCS)

meta:
	mkdir meta

$(METADIRS):
	mkdir -p $@

meta/%.DESCRIPTION: %.tar.gz
	tar fxzO $< \*/DESCRIPTION > $@

meta/%.DESCRIPTION: %.tgz
	tar fxzO $< \*/DESCRIPTION > $@

.PHONY: all cache
