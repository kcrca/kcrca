SRCS	= $(wildcard *.c)
OBJS	= $(SRCS:.c=.o)
BINS	= error

all: error

error: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)

install: all
	@for f in $(BINS); do \
	    cp -vf $$f $(BIN)/ ; \
    	done

clean clobber:
	-rm -f $(OBJS) $(BINS)
