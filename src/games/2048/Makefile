# Supported environments:
#   GNU/Linux
#   Windows NT

include ../../_sdk/common.mk

# no trailing "/"
INSTALLDIR	:= $(INSTALLDIR)nedogame

.PHONY: install clean

ifeq ($(OS),Windows_NT)
install: build.bat
	call $<
else
install:
	$(warning Target "$@" is not implemented)
endif

clean:
	$(warning Target "$@" is not implemented)
