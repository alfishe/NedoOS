# Supported environment:
#   GNU/Linux
#   Windows NT

include ../common.mk

ifeq ($(OS),Windows_NT)
 NAME		= nedores.exe
else
 NAME		= nedores
endif

.PHONY: install clean

ifeq ($(OS),Windows_NT)
.PHONY: $(NAME)
$(NAME): ;
else
$(NAME): nedores.c
	$(CC) $(CFLAGS) $< -o $@

nedores.c: nedores.diff main.c
	$(PATCH) -N -p0 -i $< -o $@
endif

install: $(NAME)

ifeq ($(OS),Windows_NT)
else
clean:
	$(RM) nedores.c $(NAME)
endif
