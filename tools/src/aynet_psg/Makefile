EXE = psgplay
OBJS = main.o psg.o net.o

CC = gcc
LD = gcc

COMMON = -std=gnu99 -Os

CFLAGS = $(COMMON)
LDFLAGS = $(COMMON)

CFLAGS +=
LDFLAGS += 

all: $(EXE)

psg.o: psg.c psg.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@

net.o: net.c net.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@

main.o: main.c net.h psg.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@

$(EXE): $(OBJS) Makefile
	$(LD) $(LDFLAGS) $(OBJS) -o $@

clean:
	rm $(EXE) $(OBJS)

