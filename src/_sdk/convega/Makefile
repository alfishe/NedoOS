# Supported environment:
#   GNU/Linux
#   Windows NT

include ../common.mk

ifeq ($(OS),Windows_NT)
 NAME		= convega.exe
else
 NAME		= convega
 OBJS		= convega.o
endif

.PHONY: install clean

ifeq ($(OS),Windows_NT)
.PHONY: $(NAME)
$(NAME): ;
else
$(NAME): convega.pas
	$(FPC) $<

convega.pas: convega.diff mkspr.dpr
	$(PATCH) -N -p0 -i $< -o $@
endif

install: $(NAME)

ifeq ($(OS),Windows_NT)
else
clean:
	$(RM) convega.pas $(NAME) $(OBJS)
endif
