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

# Default values
srcdir=src
destdir=build
DEBUG?=0

# All targets
TARGETS=native mingw32 mingw64
.PHONY: empty $(foreach t,$(TARGETS),$(t) $(t)-clean) all clean distclean

.DEFAULT_GOAL = empty

empty:
	@echo 'Usage:'
	@echo '    make [ [ DEBUG=<1|0> ] [ <TARGET> | <TARGET>-clean | all | clean ] |'
	@echo '           distclean ]'
	@echo 'where:'
	@echo '    <TARGET> is one of: $(TARGETS)'

############
## TARGET ##
############

$(TARGETS):
	$(MAKE) -w -C $(srcdir) destdir=$(shell realpath --relative-to $(srcdir) $(destdir)) TARGET=$@ DEBUG=$(DEBUG) all

##################
## TARGET-clean ##
##################

$(foreach t,$(TARGETS),$(t)-clean):
	$(MAKE) -w -C $(srcdir) destdir=$(shell realpath --relative-to $(srcdir) $(destdir)) TARGET=$(patsubst %-clean,%,$@) DEBUG=$(DEBUG) clean

#########
## all ##
#########

all:
	$(MAKE) -w -C $(srcdir) destdir=$(shell realpath --relative-to $(srcdir) $(destdir)) DEBUG=$(DEBUG) $@

###########
## clean ##
###########

clean:
	$(MAKE) -w -C $(srcdir) destdir=$(shell realpath --relative-to $(srcdir) $(destdir)) DEBUG=$(DEBUG) $@

###############
## distclean ##
###############

distclean:
	test -d $(destdir) && $(RM) -r $(destdir)/* || true
