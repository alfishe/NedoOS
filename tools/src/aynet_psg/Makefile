ifeq ($(OS),Windows_NT)
	EXE = psgplay.exe
else
	EXE = psgplay
endif

OBJS = main.o psg.o net.o play.o args.o global.o rnd.o ififo.o

CC = gcc
LD = gcc

COMMON = -std=gnu99 -Og -ggdb

CFLAGS = $(COMMON)
LDFLAGS = $(COMMON)

LIBS = 

ifeq ($(OS),Windows_NT)
	LIBS += -lws2_32
else
	LIBS += 
endif

CFLAGS +=
LDFLAGS += 


all: $(EXE)

debug: CFLAGS += -DDEBUG
debug: $(EXE)


psg.o: psg.c psg.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@

net.o: net.c net.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@

play.o: play.c play.h net.h psg.h global.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@

args.o: args.c args.h global.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@

global.o: global.c global.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@

ififo.o: ififo.c ififo.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@

rnd.o: rnd.c rnd.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@

main.o: main.c net.h psg.h play.h global.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@

$(EXE): $(OBJS) Makefile
	$(LD) $(LDFLAGS) $(OBJS) $(LIBS) -o $@

clean:
	rm $(EXE) $(OBJS)

