all: fixup

fixup: src/fixup.c
	gcc -s -o $@ $^
	sudo chown root:admin $@
	sudo chmod a+s $@

clean:
	rm -rf *~
	-rm -rf /tmp/CRAN.* /tmp/Rinst* /tmp/Rtmp*

.PHONY: all clean
