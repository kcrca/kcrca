BIN	= $(HOME)/bin

all install clean clobber:
	@for f in */; do \
		(cd $$f && $(MAKE) $@) \
	done
