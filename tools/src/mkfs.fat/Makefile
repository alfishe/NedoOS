NAME = mkfs.fat
OBJS = mkfs.fat device_info common charconv

CFLAGS = -O2 -Wall -g

CC ?= gcc


.PHONY: all
all: $(NAME)

include $(OBJS:%=%.d)

%.d: %.c
	$(CC) -MM $(CFLAGS) $< | sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' > $@

$(NAME): $(OBJS:%=%.o)
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm $(NAME) $(OBJS:%=%.o) $(OBJS:%=%.d)

%.o: %.c Makefile
	$(CC) $(CFLAGS) -c -o $@ $<
