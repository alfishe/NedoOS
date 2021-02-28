# Supported environments:
#   GNU/Linux
#   Windows NT

include ../src/_sdk/common.mk

.PHONY: sd hdd clean

sd: | $(TOOLSDIR)vhd/sd_nedo.vhd.xz $(INSTALLDIR)
	$(XZ) -c -d $(TOOLSDIR)vhd/sd_nedo.vhd.xz > sd_nedo.vhd
	$(DMIMG_ADDDIR) sd_nedo.vhd $(INSTALLDIR)

hdd: | $(TOOLSDIR)vhd/hdd_nedo.vhd.xz $(INSTALLDIR)
	$(XZ) -c -d $(TOOLSDIR)vhd/hdd_nedo.vhd.xz > hdd_nedo.vhd
	$(DMIMG_ADDDIR) hdd_nedo.vhd $(INSTALLDIR)

clean:
	$(RM) sd_nedo.vhd hdd_nedo.vhd
