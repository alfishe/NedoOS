ROOT:=$(shell pwd)

BUILDROOT=$(ROOT)/build
INSTALL:=$(shell realpath $(ROOT)/../../sdcc)



SDCCVER=4.2.0

SDCCTAR=sdcc-src-$(SDCCVER).tar.bz2

SDCCBUILD_FLAGS=--disable-pic14-port --disable-pic16-port --disable-ucsim --disable-non-free \
		--disable-mcs51-port --disable-r2k-port --disable-r2ka-port --disable-r3ka-port \
		--disable-sm83-port --disable-tlcs90-port --disable-ds390-port --disable-ds400-port \
		--disable-hc08-port --disable-s08-port --disable-stm8-port --disable-pdk13-port \
		--disable-pdk14-port --disable-pdk15-port --disable-pdk16-port --disable-doc \
		 \
		--enable-mos6502-port --enable-mos65c02-port \
		--enable-z80-port --enable-z180-port --enable-ez80_z80-port --enable-z80n-port

export PATH:=$(PATH):$(BUILDROOT)

all: prep-all
	@echo "Make SDCC in $(ROOT). Tarball: $(SDCCTAR). Install to: $(INSTALL)"
	@tar -xf  $(SDCCTAR) --strip-components=1 -C $(BUILDROOT)
	@cd $(BUILDROOT) ; ./configure --prefix=$(INSTALL) $(SDCCBUILD_FLAGS)
	@make -C $(BUILDROOT)
	@make -C $(BUILDROOT) install
	@rm -rf $(BUILDROOT)

prep-all: prep-dir prep-makeinfo-fake

prep-dir:
	@mkdir -p $(BUILDROOT) $(INSTALL)

prep-makeinfo-fake:
	@echo "#!/bin/bash" >  $(BUILDROOT)/makeinfo
	@echo 'echo "Makeinfo: $$*"' >> $(BUILDROOT)/makeinfo
	@chmod +x $(BUILDROOT)/makeinfo

clean:
	@echo "Clean sdcc in: $(BUILDROOT) $(INSTALL)"
	@rm -rf $(BUILDROOT) $(INSTALL)
