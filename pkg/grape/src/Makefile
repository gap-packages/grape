CC="cc"
CFLAGS="-O"

all:
	$(CC) ${LDFLAGS} $(CFLAGS) -o ../bin/$(BINDIR)/drcanon4  drcanon4.c
	$(CC) ${LDFLAGS} $(CFLAGS) -o ../bin/$(BINDIR)/drtogap4  drtogap4.c
	$(CC) ${LDFLAGS} $(CFLAGS) -o ../bin/$(BINDIR)/gap4todr  gap4todr.c

others:
	# gnu-compile other programs for GRAPE 
	gcc -o ../bin/$(BINDIR)/tcfrontend4 tcfrontend4.c -lp2c
	g77 -O -o ../bin/$(BINDIR)/tcmaingap4 tcmaingap4.f 
	g77 -O -o ../bin/$(BINDIR)/tcmainca4 tcmainca4.f 
	gcc -O -o ../bin/$(BINDIR)/coladjg4t coladjg4t.c
	echo "s%@grapebinpath@%`(cd ..;pwd)`/bin/$(BINDIR)%g" >grapesed
	sed -f grapesed <enum4.in > ../bin/$(BINDIR)/enum4
	chmod +x ../bin/$(BINDIR)/enum4
	sed -f grapesed <enum4ca.in > ../bin/$(BINDIR)/enum4ca
	chmod +x ../bin/$(BINDIR)/enum4ca
	rm -f grapesed

clean:
	rm -rf ../bin/$(BINDIR)

