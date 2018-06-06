binaries:
	if test ! -d bin;  then mkdir bin;  chmod 755 bin;  fi
	if test ! -d bin/x86_64-pc-linux-gnu-default64;  then mkdir bin/x86_64-pc-linux-gnu-default64;  chmod 755 bin/x86_64-pc-linux-gnu-default64;  fi
	( cd nauty22; rm -f *.o config.log config.cache config.status makefile; ./configure; make dreadnautB; mv dreadnautB ../bin/x86_64-pc-linux-gnu-default64; chmod 755 ../bin/x86_64-pc-linux-gnu-default64/dreadnautB; rm -f *.o )

clean:
	( cd nauty22; make clean )
	rm -rf bin/x86_64-pc-linux-gnu-default64
