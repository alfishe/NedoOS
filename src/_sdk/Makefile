# Supported environment:
#   GNU/Linux
#   Windows NT

include common.mk

ifeq ($(OS),Windows_NT)
 NAME		:= bin/convega.exe bin/nedopad.exe bin/nedores.exe bin/nedotrd.exe
else
 NAME		:= bin/convega.bin bin/nedopad.bin bin/nedores.bin bin/nedotrd.bin
endif

.PHONY: all install clean

all: $(NAME)

# convega

ifeq ($(OS),Windows_NT)
convega/convega.exe: convega
else
convega/convega: convega
endif
	$(MAKE) -w -C $<

ifeq ($(OS),Windows_NT)
bin/convega.exe: convega/convega.exe
else
bin/convega.bin: convega/convega
endif
	$(CP) $< $@

# nedopad

ifeq ($(OS),Windows_NT)
nedopad/nedopad.exe: nedopad
else
nedopad/nedopad: nedopad
endif
	$(MAKE) -w -C $<

ifeq ($(OS),Windows_NT)
bin/nedopad.exe: nedopad/nedopad.exe
else
bin/nedopad.bin: nedopad/nedopad
endif
	$(CP) $< $@

# nedores

ifeq ($(OS),Windows_NT)
nedores/nedores.exe: nedores
else
nedores/nedores: nedores
endif
	$(MAKE) -w -C $<

ifeq ($(OS),Windows_NT)
bin/nedores.exe: nedores/nedores.exe
else
bin/nedores.bin: nedores/nedores
endif
	$(CP) $< $@

# nedotrd

ifeq ($(OS),Windows_NT)
nedotrd/nedotrd.exe: nedotrd
else
nedotrd/nedotrd: nedotrd
endif
	$(MAKE) -w -C $<

ifeq ($(OS),Windows_NT)
bin/nedotrd.exe: nedotrd/nedotrd.exe
else
bin/nedotrd.bin: nedotrd/nedotrd
endif
	$(CP) $< $@

install: all

clean:
	$(MAKE) -w -C convega clean
	$(MAKE) -w -C nedopad clean
	$(MAKE) -w -C nedores clean
	$(MAKE) -w -C nedotrd clean
	$(RM) $(NAME)
