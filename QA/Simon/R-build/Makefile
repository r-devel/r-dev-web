CFLAGS=-Wall -pedantic -O3

all: fixup consh runpkg rmfw

fixup: src/fixup.c
	$(CC) -o $@ $^ $(CFLAGS) $(CPPFLAGS)
	sudo chown root:admin $@
	sudo chmod a+s $@

runpkg: src/runpkg.c
	$(CC) -o $@ $^ $(CFLAGS) $(CPPFLAGS)
	sudo chown root:admin $@
	sudo chmod a+s $@

rmfw: src/rmfw.c
	$(CC) -o $@ $^ $(CFLAGS) $(CPPFLAGS)
	sudo chown root:admin $@
	sudo chmod a+s $@

consh: src/consh.c
	$(CC) -o $@ $^ $(CFLAGS) $(CPPFLAGS)

clean:
	rm -rf *~
	-rm -rf /tmp/CRAN.* /tmp/Rinst* /tmp/Rtmp*

.PHONY: all clean
