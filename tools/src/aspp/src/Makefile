#
# Supported environments:
# * GNU/Linux.
#
# Allowed but not tested environments:
# * Windows NT (Cygwin/MinGW).
#
# Dependencies (for this Makefile):
# * GNU make;
# * GNU core utilities.
#
# Dependencies for native compilation:
# * GNU C compiler.
#
# Dependencies for cross-compilation:
# * GNU C compiler (MinGW target).
#

# Default values
destdir		?= ../build
TARGET		?= native
DEBUG		?= 0
ifeq ($(DEBUG),0)
 BUILDDIR	:= $(destdir)/release
else
 BUILDDIR	:= $(destdir)/debug
endif
GCC_CFLAGS_DEBUG = -g
GCC_CFLAGS_RELEASE = -O2

ifeq ($(OS),Windows_NT)
 $(warning BUILD PROCESS IS NOT TESTED FOR OS='$(OS)' !)
 ifeq ($(TARGET),native)
  BUILDDIR	:= $(BUILDDIR)/windows
  CC		?= gcc
  CFLAGS	= -mconsole
  ifeq ($(DEBUG),0)
   CFLAGS	+= $(GCC_CFLAGS_RELEASE)
  else
   CFLAGS	+= $(GCC_CFLAGS_DEBUG)
  endif
 else ifeq ($(TARGET),mingw32)
  BUILDDIR	:= $(BUILDDIR)/windows-mingw32
  CC		= i686-w64-mingw32-gcc
  CFLAGS	= -mconsole
  ifeq ($(DEBUG),0)
   CFLAGS	+= $(GCC_CFLAGS_RELEASE)
  else
   CFLAGS	+= $(GCC_CFLAGS_DEBUG)
  endif
 else ifeq ($(TARGET),mingw64)
  BUILDDIR	:= $(BUILDDIR)/windows-mingw64
  CC		= x86_64-w64-mingw32-gcc
  CFLAGS	= -mconsole
  ifeq ($(DEBUG),0)
   CFLAGS	+= $(GCC_CFLAGS_RELEASE)
  else
   CFLAGS	+= $(GCC_CFLAGS_DEBUG)
  endif
 else
  $(error Unknown target '$(TARGET)')
 endif
  EXECEXT	= .exe
else
 ifeq ($(TARGET),native)
  BUILDDIR	:= $(BUILDDIR)/linux
  CC		?= gcc
  CFLAGS	=
  EXECEXT	=
  ifeq ($(DEBUG),0)
   CFLAGS	+= $(GCC_CFLAGS_RELEASE)
  else
   CFLAGS	+= $(GCC_CFLAGS_DEBUG)
  endif
 else ifeq ($(TARGET),mingw32)
  BUILDDIR	:= $(BUILDDIR)/linux-mingw32
  CC		= i686-w64-mingw32-gcc
  CFLAGS	= -mconsole
  EXECEXT	= .exe
  ifeq ($(DEBUG),0)
   CFLAGS	+= $(GCC_CFLAGS_RELEASE)
  else
   CFLAGS	+= $(GCC_CFLAGS_DEBUG)
  endif
 else ifeq ($(TARGET),mingw64)
  BUILDDIR	:= $(BUILDDIR)/linux-mingw64
  CC		= x86_64-w64-mingw32-gcc
  CFLAGS	= -mconsole
  EXECEXT	= .exe
  ifeq ($(DEBUG),0)
   CFLAGS	+= $(GCC_CFLAGS_RELEASE)
  else
   CFLAGS	+= $(GCC_CFLAGS_DEBUG)
  endif
 else
  $(error Unknown target '$(TARGET)')
 endif
endif

MAINSRC		= main.c
MAINEXEC	= aspp$(EXECEXT)
SRCS		= asmfile.c debug.c l_err.c l_ifile.c l_inc.c l_isrc.c l_list.c l_pre.c l_src.c l_tgt.c parser.c platform.c
CFLAGS		+= -Wall -DDEBUG=$(DEBUG)
DEPCC		= $(CC)
DEPCFLAGS	= -MM
DEPEXT		= d

# All targets
TARGETS=native mingw32 mingw64

.PHONY: empty all clean

.DEFAULT_GOAL = empty

empty:
	@echo 'Usage:'
	@echo '    make [ destdir=<path> ] [ TARGET=<TARGET> ] [ DEBUG=<0|1> ]'
	@echo '         [ all | clean ]'
	@echo 'where:'
	@echo '    <TARGET> is one of: $(TARGETS)'

# Clear lists
DEPS=
OBJS=

# $1=source .c file name
define compile_c_o_rule =
# Put dependency file in $(BUILDDIR)/
$(BUILDDIR)/$(patsubst %$(suffix $(1)),%.$(DEPEXT),$(1)): $(1)
	@mkdir -p $$(@D)
	$$(DEPCC) $$(DEPCFLAGS) -MF $$@ -MT $$@ -MT $(BUILDDIR)/$(patsubst %$(suffix $(1)),%.o,$(1)) $(1)
DEPS+=$(BUILDDIR)/$(patsubst %$(suffix $(1)),%.$(DEPEXT),$(1))
# Put object file in $(BUILDDIR)/
$(BUILDDIR)/$(patsubst %$(suffix $(1)),%.o,$(1)): $(1)
	@mkdir -p $$(@D)
	$$(CC) $$(CFLAGS) -c -o $$@ $(1)
OBJS+=$(BUILDDIR)/$(patsubst %$(suffix $(1)),%.o,$(1))
endef

$(foreach f,$(SRCS),$(eval $(call compile_c_o_rule,$(f))))

# Put dependency file in $(BUILDDIR)/
$(BUILDDIR)/$(patsubst %$(suffix $(MAINSRC)),%.$(DEPEXT),$(MAINSRC)): $(MAINSRC)
	@mkdir -p $(@D)
	$(DEPCC) $(DEPCFLAGS) -MF $@ -MT $@ -MT $(BUILDDIR)/$(MAINEXEC) $(MAINSRC)
DEPS+=$(BUILDDIR)/$(patsubst %$(suffix $(MAINSRC)),%.$(DEPEXT),$(MAINSRC))
# Put executable file in $(BUILDDIR)/
$(BUILDDIR)/$(MAINEXEC): $(MAINSRC) $(OBJS)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -o $@ $(MAINSRC) $(OBJS)
ifeq ($(DEBUG),0)
	strip $@
endif

#########
## all ##
#########

all: $(BUILDDIR)/$(MAINEXEC)

###########
## clean ##
###########

clean:
	$(RM) $(DEPS) $(OBJS) $(BUILDDIR)/$(MAINEXEC)
# unsafe if BUILDDIR is source directory:
#	test -d $(BUILDDIR) && $(RM) -r $(BUILDDIR) || true

##################
## Dependencies ##
##################

ifneq ($(MAKECMDGOALS),)
 ifeq ($(sort \
 $(filter empty,$(MAKECMDGOALS)) \
 $(filter clean,$(MAKECMDGOALS)) \
 ),)
  include $(DEPS)
 endif
endif
