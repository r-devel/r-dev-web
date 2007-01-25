all:

fixtar: src/fixtar.c
	gcc -s -o fixtar src/fixtar.c
	sudo chown root:admin fixtar
	sudo chmod a+s fixtar

packages:

clean:
	rm -rf *~
	-rm -rf /tmp/CRAN.* /tmp/Rinst* /tmp/Rtmp*

.PHONY: all packages clean
