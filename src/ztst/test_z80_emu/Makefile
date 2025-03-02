OBJS = main z80-wrap

NAME = main

# arch opts
ifndef OPTS
 CFLAGS := $(DEFS) -march=native -mtune=native
else
 CFLAGS := $(DEFS) $(OPTS)
endif

ifdef DEBUG
 CFLAGS += -DDEBUG -O0 -Wall -g -ggdb -fno-pie -no-pie -fcf-protection=none
else
 CFLAGS += -O3 -fcf-protection=none -ffunction-sections -fdata-sections -ggdb -Wall -Wextra -Wno-unused-variable -Wno-unused-but-set-variable
endif

LIBS = -lZ80
LDFLAGS = $(CFLAGS) -LzetaZ80 -Wl,--gc-sections -Wl,-rpath,zetaZ80


CC = gcc

.PHONY: all
all: $(NAME)

include $(OBJS:%=%.d)

%.d: %.c
	$(CC) -MM $(CFLAGS) $< | sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' > $@

$(NAME): $(OBJS:%=%.o)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

clean:
	rm -f $(NAME) \
	      $(OBJS:%=%.o) $(OBJS:%=%.d)

%.o: %.c Makefile
	$(CC) $(CFLAGS) -c -o $@ $<

