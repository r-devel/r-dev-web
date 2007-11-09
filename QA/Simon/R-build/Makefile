all: fixup consh

fixup: src/fixup.c
	gcc -o $@ $^
	sudo chown root:admin $@
	sudo chmod a+s $@

consh: src/consh.c
	gcc -o $@ $^

clean:
	rm -rf *~
	-rm -rf /tmp/CRAN.* /tmp/Rinst* /tmp/Rtmp*

.PHONY: all clean
