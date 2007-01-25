TARS:=$(shell find ?.? -name \*.tar.gz)
DIRS:=$(shell for i in `find bin/* -name bin -type d`; do find $${i} -name ?.?.? -type d; done) $(shell find ?.? -type d|grep contrib)
BINS:=$(shell find $(DIRS) -name \*.tgz)

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
