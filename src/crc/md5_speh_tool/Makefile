EXE = speh
SYMLINKS = md5 spehsum md5sum

OBJS = speh sphash-opt md5-my

CC = gcc
LD = gcc

UNAME := $(shell uname -m)

OPT = -O3 -g3 -ggdb

STD = -std=gnu99

#CFLAGS = -O3 -mtune=generic -march=x86-64 -fno-pie -no-pie -g3 -ggdb -std=gnu99
ifeq ($(UNAME),x86_64)
ARCH = -mtune=generic -march=x86-64 -fno-pie -no-pie
else ifeq ($(UNAME),riscv64)
ARCH = -mtune=thead-c906 -march=rv64gc -fno-pie -no-pie
else ifeq ($(UNAME),i386)
ARCH = -m32 -mtune=generic -march=i386 -fno-pie -no-pie
else
ARCH = -march=native -mtune=native
endif

CFLAGS = $(OPT) $(STD) $(ARCH)

LDFLAGS = $(CFLAGS) 

CFLAGS += $(CFLAGS_LIBS)


.PHONY: all clean

all: $(EXE) $(SYMLINKS)

include $(OBJS:%=%.d)

# dependencies generation
%.d: %.c Makefile
	echo $@ $(subst \, ,$(shell $(CC) -MM $(CFLAGS) $<)) > $@
 
# Compile
%.o: %.c Makefile
	$(CC) $(CFLAGS) -c -o $@ $<

# Link
$(EXE): $(OBJS:%=%.o) 
	$(LD) $(LDFLAGS) -o $@ $^ $(LDFLAGS_LIBS)

$(SYMLINKS): $(EXE)
	ln -sr $(EXE) $@

clean:
	-rm -rf $(OBJS:%=%.o) $(OBJS:%=%.d) $(EXE) $(SYMLINKS)

