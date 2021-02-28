# Supported environment:
#   GNU/Linux
#   Windows NT

include ../common.mk

ifeq ($(OS),Windows_NT)
 NAME		= nedopad.exe
else
 NAME		= nedopad
endif

.PHONY: install clean

ifeq ($(OS),Windows_NT)
.PHONY: $(NAME)
$(NAME): ;
else
$(NAME): nedopad.c
	$(CC) $(CFLAGS) $< -o $@

nedopad.c: nedopad.diff main.c
	$(PATCH) -N -p0 -i $< -o $@
endif

install: $(NAME)

ifeq ($(OS),Windows_NT)
else
clean:
	$(RM) nedopad.c $(NAME)
endif
