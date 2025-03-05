# gmake

SJASMPLUS=../../../tools/sjasmplus

NAME = z80test
VERSION = 1.2a
PKG := $(NAME)-$(VERSION)

PROGS := z80full z80flags z80doc z80docflags z80ccf z80memptr
SRCS  := src/main src/idea src/crctab src/tests src/testmacros src/print

all: $(addsuffix .bin,$(PROGS))

%.bin : src/%.asm $(addsuffix .asm,$(SRCS))
	$(SJASMPLUS) --lst $<

clean:
	rm -rf *.bin src/*.lst

