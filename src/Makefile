# Supported environments:
#   GNU/Linux
#   Windows NT

include _sdk/common.mk
-include Makefile.cfg

TARGET?=default

.PHONY: \
 build-fatfs \
 build-kernel \
 build-system \
 build-tools \
 clean \
 clean-atm2 \
 clean-atm2hd \
 clean-atm3 \
 clean-atm3hd \
 clean-atm3sd \
 clean-config \
 clean-default \
 clean-evo \
 clean-evsd-g \
 clean-fatfs \
 clean-kernel \
 clean-pe26 \
 clean-pe26sd \
 clean-release \
 clean-software \
 clean-system \
 clean-tools \
 configure-atm2 \
 configure-atm2hd \
 configure-atm3 \
 configure-atm3hd \
 configure-atm3sd \
 configure-evo \
 configure-evsd-g \
 dist-clean \
 install \
 install-atm2 \
 install-atm2hd \
 install-atm3 \
 install-atm3hd \
 install-atm3sd \
 install-config \
 install-default \
 install-evo \
 install-evsd-g \
 install-pe26 \
 install-pe26sd \
 install-software \
 test \
 test-atm2 \
 test-atm2hd \
 test-atm3 \
 test-atm3hd \
 test-atm3sd \
 test-default \
 test-evo \
 test-evsd-g \
 usage

usage: Makefile.hlp
	@$(CAT) $<

install-default \
test-default \
clean-default:
	$(error TARGET not set. Please run "make configure-TARGET" first. Type "make" to get help)

# directories

$(INSTALLDIR).:
	$(MKDIR) $@

# tools

build-tools:
	$(MAKE) $(MFLAGS) -C _sdk
	$(MAKE) $(MFLAGS) -C ../tools

clean-tools:
	$(MAKE) $(MFLAGS) -C _sdk clean
	$(MAKE) $(MFLAGS) -C ../tools clean

# fatfs

build-fatfs: | fatfs4os
	$(MAKE) $(MFLAGS) -C $|

clean-fatfs: | fatfs4os
	$(MAKE) $(MFLAGS) -C $| clean

# kernel

build-kernel \
kernel/code.c \
kernel/nedoos.$$C: | kernel
	$(MAKE) $(MFLAGS) -C $|

clean-kernel: | kernel
	$(MAKE) $(MFLAGS) -C $| clean

# system

build-system: build-fatfs build-kernel

clean-system: clean-fatfs clean-kernel

# software

SOFTWARE_DIRS	:= \
 aynet \
 basic \
 bdsc \
 browser \
 cmd \
 demos \
 emptyapp \
 games \
 gfxtest \
 hello \
 modplay \
 more \
 nedolang \
 netterm \
 nv \
 ping \
 pkunzip \
 player \
 playtap \
 pt \
 rdtrd \
 reset \
 scratch \
 setfont \
 tar \
 telnet \
 term \
 texted \
 tp \
 unrar \
 untr \
 view \
 wrtrd \
 zxrar

install-software:
ifeq ($(OS),Windows_NT)
	for %%d in ($(SOFTWARE_DIRS)) do $(MAKE) $(MFLAGS) -C %%d install
else
	for d in $(SOFTWARE_DIRS); do $(MAKE) $(MFLAGS) -C $$d install; done
endif

clean-software:
ifeq ($(OS),Windows_NT)
	for %%d in ($(SOFTWARE_DIRS)) do $(MAKE) $(MFLAGS) -C %%d clean
else
	for d in $(SOFTWARE_DIRS); do $(MAKE) $(MFLAGS) -C $$d clean; done
endif

# config

CONFIG_FILES	:= \
 $(BIN_INSTALLDIR)autoexec.bat \
 $(BIN_INSTALLDIR)net.ini

install-config: $(CONFIG_FILES)

$(BIN_INSTALLDIR)autoexec.bat: autoexec.bat
	$(CP) $< $@
$(BIN_INSTALLDIR)net.ini: net.ini
	$(CP) $< $@

clean-config:
	$(RM) $(CONFIG_FILES)

# test.trd

build-trd: BOOT6000.$$B kernel/code.c
	$(NEDOTRD) test.trd -n
ifeq ($(OS),Windows_NT)
	$(NEDOTRD) test.trd -ah BOOT6000.$$B
else
	$(NEDOTRD) test.trd -ah BOOT6000.\$$B
endif
	$(NEDOTRD) test.trd -s 24576 -ac kernel/code.c
ifeq ($(OS),Windows_NT)
	for %%f in ($(BIN_INSTALLDIR)*.*) do $(NEDOTRD) test.trd -a %%f
else
	for f in `find $(BIN_INSTALLDIR) -type f`; do $(NEDOTRD) test.trd -a $$f; done
endif
#	$(NEDOTRD) test.trd -a nedolang/comp/sizesz80.h
#	$(NEDOTRD) test.trd -a nedolang/comp/comp_os.s
#	$(NEDOTRD) test.trd -a nedolang/comp/compc_os.s
#	$(NEDOTRD) test.trd -a nedolang/comp/compile.c
#	$(NEDOTRD) test.trd -a nedolang/comp/codez80.c
#	$(NEDOTRD) test.trd -a nedolang/comp/commands.c
#	$(NEDOTRD) test.trd -a nedolang/comp/regs.c
#	$(NEDOTRD) test.trd -a nedolang/comp/test.bat
#	$(NEDOTRD) test.trd -a nedolang/_sdk/str.h
#	$(NEDOTRD) test.trd -a nedolang/_sdk/io.h
#	$(NEDOTRD) test.trd -a nedolang/_sdk/emit.h
#	$(NEDOTRD) test.trd -a nedolang/_sdk/emit.c
#	$(NEDOTRD) test.trd -a nedolang/_sdk/read.c
#	$(NEDOTRD) test.trd -a nedolang/_sdk/typecode.h
#	$(NEDOTRD) test.trd -a nedolang/_sdk/lib.i
#	$(NEDOTRD) test.trd -a nedolang/_sdk/str.i
#	$(NEDOTRD) test.trd -a nedolang/_sdk/io_os.i
#	$(NEDOTRD) test.trd -a _sdk/sysdefs.asm
#	$(NEDOTRD) test.trd -a basic/example.bas
#	$(NEDOTRD) test.trd -a nedolang/nedogift/testmusi.pt3
#	$(NEDOTRD) test.trd -a player/coco.pt2
#	$(NEDOTRD) test.trd -a modplay/scalsfjy.mod
#ifeq ($(OS),Windows_NT)
#	for %%f in ($(DOC_INSTALLDIR)*.*) do $(NEDOTRD) test.trd -a %%f
#else
#	for f in `find $(DOC_INSTALLDIR) -type f`; do $(NEDOTRD) test.trd -a $$f; done
#endif

# atm2

configure-atm2: | _sdk/config/atm2
	@echo TARGET=atm2> Makefile.cfg
	$(CP) $|/* _sdk/

$(INSTALLDIR)osatm2.trd: build-system install-software install-config build-trd
	$(MV) test.trd $@

install-atm2: $(INSTALLDIR)osatm2.trd

test-atm2: $(INSTALLDIR)osatm2.trd $(EMULDIR)atm2.ini
	$(MAKE) $(MFLAGS) -C $(EMULDIR)
ifeq ($(OS),Windows_NT)
	$(EMUL) -i atm2.ini $<
else
	$(error Target "$@" is not implemented)
endif

clean-atm2:
	$(RM) $(INSTALLDIR)osatm2.trd
	$(RM) -r $(BIN_INSTALLDIR) $(RES_INSTALLDIR) $(DOC_INSTALLDIR)

# atm2hd

configure-atm2hd: | _sdk/config/atm2hd
	@echo TARGET=atm2hd> Makefile.cfg
	$(CP) $|/* _sdk/

$(INSTALLDIR)osatm2hd.trd: build-system install-software install-config build-trd
ifeq ($(OS),Windows_NT)
	$(NEDOTRD) test.trd -eh code.$$C
	$(NEDOTRD) test.trd -a code.$$C
	$(CP) code.$$C $(INSTALLDIR)osatm2hd.$$C
else
	$(NEDOTRD) test.trd -eh code.\$$C
	$(NEDOTRD) test.trd -a code.\$$C
	$(CP) code.\$$C $(INSTALLDIR)osatm2hd.\$$C
endif
	$(CP) test.trd $@

install-atm2hd: $(INSTALLDIR)osatm2hd.trd

test-atm2hd: $(INSTALLDIR)osatm2hd.trd $(EMULDIR)atm2.ini
	$(MAKE) $(MFLAGS) -C $(EMULDIR) hdd
ifeq ($(OS),Windows_NT)
	$(EMUL) -i atm2.ini $<
else
	$(error Target "$@" is not implemented)
endif

clean-atm2hd:
	$(RM) $(INSTALLDIR)osatm2hd.trd
ifeq ($(OS),Windows_NT)
	$(RM) $(INSTALLDIR)osatm2hd.$$C
else
	$(RM) $(INSTALLDIR)osatm2hd.\$$C
endif
	$(RM) -r $(BIN_INSTALLDIR) $(RES_INSTALLDIR) $(DOC_INSTALLDIR)

# atm3

configure-atm3: | _sdk/config/atm3
	@echo TARGET=atm3> Makefile.cfg
	$(CP) $|/* _sdk/

$(INSTALLDIR)osatm3.trd: build-system install-software install-config build-trd
	$(CP) test.trd $@

install-atm3: $(INSTALLDIR)osatm3.trd

test-atm3: $(INSTALLDIR)osatm3.trd
	$(MAKE) $(MFLAGS) -C $(EMULDIR)
ifeq ($(OS),Windows_NT)
	$(EMUL) $<
else
	$(error Target "$@" is not implemented)
endif

clean-atm3:
	$(RM) $(INSTALLDIR)osatm3.trd
	$(RM) -r $(BIN_INSTALLDIR) $(RES_INSTALLDIR) $(DOC_INSTALLDIR)

# atm3hd

configure-atm3hd: | _sdk/config/atm3hd
	@echo TARGET=atm3hd> Makefile.cfg
	$(CP) $|/* _sdk/

$(INSTALLDIR)osatm3hd.trd: build-system install-software install-config
ifeq ($(OS),Windows_NT)
	$(CP) kernel/nedoos.$$C $(INSTALLDIR)osatm3hd.$$C
else
	$(CP) kernel/nedoos.\$$C $(INSTALLDIR)osatm3hd.\$$C
endif

install-atm3hd: $(INSTALLDIR)osatm3hd.trd

test-atm3hd: $(INSTALLDIR)osatm3hd.trd
	$(MAKE) $(MFLAGS) -C $(EMULDIR) hdd
ifeq ($(OS),Windows_NT)
	$(EMUL) $<
else
	$(error Target "$@" is not implemented)
endif

clean-atm3hd: clean-system clean-software
	$(RM) $(INSTALLDIR)osatm3hd.trd
ifeq ($(OS),Windows_NT)
	$(RM) $(INSTALLDIR)osatm3hd.$$C
else
	$(RM) $(INSTALLDIR)osatm3hd.\$$C
endif
	$(RM) -r $(BIN_INSTALLDIR) $(RES_INSTALLDIR) $(DOC_INSTALLDIR)

# atm3sd

configure-atm3sd: | _sdk/config/atm3sd
	@echo TARGET=atm3sd> Makefile.cfg
	$(CP) $|/* _sdk/

$(INSTALLDIR)osatm3sd.trd: build-system install-software install-config
ifeq ($(OS),Windows_NT)
	$(CP) kernel/nedoos.$$C $(INSTALLDIR)osatm3sd.$$C
else
	$(CP) kernel/nedoos.\$$C $(INSTALLDIR)osatm3sd.\$$C
endif

install-atm3sd: $(INSTALLDIR)osatm3sd.trd

test-atm3sd: $(INSTALLDIR)osatm3sd.trd
	$(MAKE) $(MFLAGS) -C $(EMULDIR) sd
ifeq ($(OS),Windows_NT)
	$(EMUL) $<
else
	$(error Target "$@" is not implemented)
endif

clean-atm3sd:
	$(RM) $(INSTALLDIR)osatm3sd.trd
ifeq ($(OS),Windows_NT)
	$(RM) $(INSTALLDIR)osatm3sd.$$C
else
	$(RM) $(INSTALLDIR)osatm3sd.\$$C
endif
	$(RM) -r $(BIN_INSTALLDIR) $(RES_INSTALLDIR) $(DOC_INSTALLDIR)

# evo

configure-evo: | _sdk/config/evo
	@echo TARGET=evo> Makefile.cfg
	$(CP) $|/* _sdk/

install-evo: build-system install-software install-config
ifeq ($(OS),Windows_NT)
	$(CP) kernel/nedoos.$$C $(INSTALLDIR)sd_boot.$$C
else
	$(CP) kernel/nedoos.\$$C $(INSTALLDIR)sd_boot.\$$C
endif

test-evo:
	$(MAKE) $(MFLAGS) -C $(EMULDIR) sd
ifeq ($(OS),Windows_NT)
	$(EMUL) $<
else
	$(error Target "$@" is not implemented)
endif

clean-evo:
ifeq ($(OS),Windows_NT)
	$(RM) $(INSTALLDIR)sd_boot.$$C
else
	$(RM) $(INSTALLDIR)sd_boot.\$$C
endif
	$(RM) -r $(BIN_INSTALLDIR) $(RES_INSTALLDIR) $(DOC_INSTALLDIR)

# evsd-g

configure-evsd-g: | _sdk/config/evsd-g
	@echo TARGET=evsd-g> Makefile.cfg
	$(CP) $|/* _sdk/

install-evsd-g: build-system install-software install-config
ifeq ($(OS),Windows_NT)
	$(CP) kernel/nedoos.$$C $(INSTALLDIR)osevsd-g.$$C
else
	$(CP) kernel/nedoos.\$$C $(INSTALLDIR)osevsd-g.\$$C
endif

test-evsd-g:
	$(MAKE) $(MFLAGS) -C $(EMULDIR) sd
ifeq ($(OS),Windows_NT)
	$(EMUL) $<
else
	$(error Target "$@" is not implemented)
endif

clean-evsd-g:
ifeq ($(OS),Windows_NT)
	$(RM) $(INSTALLDIR)osevsd-g.$$C
else
	$(RM) $(INSTALLDIR)osevsd-g.\$$C
endif
	$(RM) -r $(BIN_INSTALLDIR) $(RES_INSTALLDIR) $(DOC_INSTALLDIR)

# pe26

configure-pe26: | _sdk/config/pe26
	@echo TARGET=atm2> Makefile.cfg
	$(CP) $|/* _sdk/

$(INSTALLDIR)osp26.trd: build-system install-software install-config build-trd
	$(MV) test.trd $@

install-pe26: $(INSTALLDIR)osp26.trd

test-pe26: $(INSTALLDIR)osp26.trd
	$(MAKE) $(MFLAGS) -C $(EMULDIR)
ifeq ($(OS),Windows_NT)
	$(EMUL) $<
else
	$(error Target "$@" is not implemented)
endif

clean-pe26:
	$(RM) $(INSTALLDIR)osp26.trd
	$(RM) -r $(BIN_INSTALLDIR) $(RES_INSTALLDIR) $(DOC_INSTALLDIR)

# pe26sd

configure-pe26sd: | _sdk/config/pe26sd
	@echo TARGET=atm2> Makefile.cfg
	$(CP) $|/* _sdk/

install-pe26sd: build-system install-software install-config
ifeq ($(OS),Windows_NT)
	$(CP) kernel/nedoos.$$C $(INSTALLDIR)osp26sd.$$C
else
	$(CP) kernel/nedoos.\$$C $(INSTALLDIR)osp26sd.\$$C
endif

test-pe26sd: $(EMULDIR)dimkam.ini
	$(MAKE) $(MFLAGS) -C $(EMULDIR) sd
ifeq ($(OS),Windows_NT)
	$(EMUL) -i $<
else
	$(error Target "$@" is not implemented)
endif

clean-pe26sd:
ifeq ($(OS),Windows_NT)
	$(RM) $(INSTALLDIR)osp26sd.$$C
else
	$(RM) $(INSTALLDIR)osp26sd.\$$C
endif
	$(RM) -r $(BIN_INSTALLDIR) $(RES_INSTALLDIR) $(DOC_INSTALLDIR)

# install

install: | $(INSTALLDIR).
	$(info Target: $(TARGET))
	$(MKDIR) $(BIN_INSTALLDIR) $(RES_INSTALLDIR) $(DOC_INSTALLDIR)
	$(MAKE) $(MFLAGS) install-$(TARGET)

# test

test:
	$(info Target: $(TARGET))
	$(MAKE) $(MFLAGS) test-$(TARGET)

# clean

clean:
	$(info Target: $(TARGET))
	$(MAKE) $(MFLAGS) clean-$(TARGET) clean-system clean-software

clean-release: | $(INSTALLDIR).
	$(RM) -r $(INSTALLDIR)*

dist-clean: clean-tools clean-system clean-software clean-release | $(INSTALLDIR).
	$(RM) Makefile.cfg
