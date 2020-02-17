ifeq ($(OS),Windows_NT)
	EXE = checker.exe
else
	EXE = checker
endif

OBJS = main.o net.o

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


debug: CFLAGS += -DDEBUG
debug: $(EXE)

all: $(EXE)

#psg.o: psg.c psg.h Makefile
#	$(CC) $(CFLAGS) -c $< -o $@

net.o: ../net.c ../net.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@

#play.o: play.c play.h Makefile
#	$(CC) $(CFLAGS) -c $< -o $@

main.o: main.c ../net.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@

$(EXE): $(OBJS) Makefile
	$(LD) $(LDFLAGS) $(OBJS) $(LIBS) -o $@

clean:
	rm $(EXE) $(OBJS)

