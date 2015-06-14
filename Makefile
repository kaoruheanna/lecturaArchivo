PROG  = leer
CFLAGS = -g -Wall
DSRC = src/
all: $(PROG)

deleteOld:
	rm $(PROG)

leer: $(DSRC)main.c $(DSRC)mymalloc.S $(DSRC)readFile.S
	$(CC) $(CFLAGS) -o $@ $>

clean:
	rm -f $(PROG) *.so *.o *.a *.core
	
permissions:
	chmod +x $(PROG)

