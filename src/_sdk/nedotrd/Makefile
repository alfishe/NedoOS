# Supported environment:
#   GNU/Linux
#   Windows NT

include ../common.mk

ifeq ($(OS),Windows_NT)
 NAME		= nedotrd.exe
else
 NAME		= nedotrd
endif

.PHONY: install clean

ifeq ($(OS),Windows_NT)
.PHONY: $(NAME)
$(NAME): ;
else
$(NAME): nedotrd.c
	$(CC) $(CFLAGS) $< -o $@

nedotrd.c: nedotrd.diff main.c
	$(PATCH) -N -p0 -i $< -o $@
endif

install: $(NAME)

ifeq ($(OS),Windows_NT)
else
clean:
	$(RM) nedotrd.c $(NAME)
endif
