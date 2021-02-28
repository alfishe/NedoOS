# Supported environments:
#   GNU/Linux
#   Windows NT

include  ../../_sdk/common.mk

INSTALLDIR	= ../../../release/bin
NAME		= diff.com
OBJECTS		= diff.ast diff.var diff.A_ diff.S_ diff.V_
SOURCES		= diff.c diff.s diff_os.s

ifeq ($(OS),Windows_NT)
 NEDOLANG	= ../_sdk/nedolang.exe
 NEDOTOK	= ../_sdk/nedotok.exe
 NEDOASM	= ../_sdk/nedoasm.exe
else
 NEDOLANG	= ../_sdk/nedolang.bin
 NEDOTOK	= ../_sdk/nedotok.bin
 NEDOASM	= ../_sdk/nedoasm.bin
endif

all: $(NAME)

$(NAME): $(SOURCES)
	$(NEDOLANG) diff.c
	$(CAT) err.f
	$(NEDOTOK) diff_os.s diff.ast diff.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../_sdk/print_os.i ../../_sdk/sysdefs.asm
	$(NEDOASM) diff_os.S_
	$(CAT) asmerr.f
	$(MV) diff_os.bin $@

clean: 
	$(RM) ${NAME} ${OBJECTS}
	$(RM) *.f *.D_ *.V_ *.bin *.var *.org *.pst

install: all
#	$(CP) ${NAME} ${INSTALLDIR}

install-doc: ${DOC} 
#	$(CP) ${DOC} ${INSTALLDIR}/doc

trd: ${NAME}
