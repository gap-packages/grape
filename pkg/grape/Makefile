binaries:
	if test ! -d bin;  then mkdir bin;  chmod 755 bin;  fi
	if test ! -d bin/i686-pc-linux-gnu-gcc-default32;  then mkdir bin/i686-pc-linux-gnu-gcc-default32;  chmod 755 bin/i686-pc-linux-gnu-gcc-default32;  fi
	( cd nauty22; rm -f *.o config.log config.cache config.status makefile; ./configure; make dreadnautB; mv dreadnautB ../bin/i686-pc-linux-gnu-gcc-default32; chmod 755 ../bin/i686-pc-linux-gnu-gcc-default32/dreadnautB; rm -f *.o )

clean:
	( cd nauty22; make clean )
	rm -rf bin/i686-pc-linux-gnu-gcc-default32
