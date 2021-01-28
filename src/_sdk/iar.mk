# iar.mk - definitions to support IAR in Makefiles.
#
# Supported environments:
#   GNU/Linux.
#
# Tools used:
#   GNU core utilities, tools/aspp, GCC (or similar tool to generate dependency information),
#   Wine, IAR tools.
#
# Variables used:
#   DEPCC - C preprocessor name (with GCC-compatible parameters)
#   DEPCFLAGS - flags for ${DEPCC}
#   DEPAS - tools/aspp name
#   DEPAFLAGS - flags for ${DEPAS}
#   DEPEXT - dependency file extension (no leading dot)
#   WINE - Wine's name with "cmd /c" command in parameters
#   IAR_ICCZ80 - IAR's "iccz80" name
#   IAR_ICCZ80FLAGS - flags for ${IAR_ICCZ80}
#   IAR_AZ80 - IAR's "az80" name
#   IAR_AZ80FLAGS - flags for ${IAR_AZ80}

# iar_iccz80_rule - rule to compile C source file using tools ${DEPCC}, ${WINE} and ${IAR_ICCZ80}
#
# Parameters:
# ${1} = output file(s)
# ${2} = single input file
# ${3} = extra parameters for IAR's ${IAR_ICCZ80}
# ${4} = variable's name for output dependencies files list (or empty)
# ${5} = variable's name for output binaries files list (or empty)
#
# Usage:
# ${eval ${call iar_iccz80_rule,${OBJDIR}/main.r01,main.asm,-O${OBJDIR}/,DEPS,OBJS}}

define iar_iccz80_rule =
# Dependency generation rule for .asm file:
${patsubst %${suffix ${2}},%.${DEPEXT},${2}}: ${2}
	$${RM} $$@ && $${DEPCC} $${DEPCFLAGS} ${addprefix -MT ,${1}} -MT $$@ -MF $$@ $$< || true
${1}: ${2}
	$${WINE} $${IAR_ICCZ80} $${IAR_ICCZ80FLAGS} ${3} $$<
ifneq "${4}" ""
${4}+=${patsubst %${suffix ${2}},%.${DEPEXT},${2}}
endif
ifneq "${5}" ""
${5}+=${1}
endif
endef

# iar_az80_rule - rule to compile assembler source file using tools ${DEPAS}, ${WINE} and ${IAR_AZ80}
#
# Parameters:
# ${1} = output file(s)
# ${2} = single input file
# ${3} = extra parameters for ${IAR_AZ80}
# ${4} = variable's name for output dependencies files list (or empty)
# ${5} = variable's name for output binaries files list (or empty)
#
# Usage:
# ${eval ${call iar_az80_rule,${OBJDIR}/main.r01,main.asm,-O{OBJDIR}/,DEPS,OBJS}}

define iar_az80_rule =
# Dependency generation rule for .asm file:
${patsubst %${suffix ${2}},%.${DEPEXT},${2}}: ${2}
	$${RM} $$@ && $${DEPAS} $${DEPAFLAGS} ${addprefix -MT ,${1}} -MT $$@ -MF $$@ $$<
${1}: ${2}
	$${WINE} $${IAR_AZ80} $${IAR_AZ80FLAGS} ${3} $$<
ifneq "${4}" ""
${4}+=${patsubst %${suffix ${2}},%.${DEPEXT},${2}}
endif
ifneq "${5}" ""
${5}+=${1}
endif
endef
