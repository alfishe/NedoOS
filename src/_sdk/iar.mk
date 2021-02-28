# iar.mk - definitions to support IAR in Makefiles.
#
# Supported environments:
#   GNU/Linux
#   Windows NT

# Uses "common.mk"

ifeq ($(OS),Windows_NT)
 IARDIR		= $(ROOTDIR)iar/
 IARBIN		= $(IARDIR)bin/
 IARINC		= $(IARDIR)inc/
 IARLIB		= $(IARDIR)lib/
 AZ80		= $(IARBIN)az80.exe
 ICCZ80		= $(IARBIN)iccz80.exe
 XLIB		= $(IARBIN)xlib.exe
 XLINK		= $(IARBIN)xlink.exe
else
 $(warning IAR tools are not available)
endif
