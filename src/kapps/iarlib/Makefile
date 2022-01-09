BIN		:= iar.lib

SRC		:= ./
SRCC	:= $(wildcard $(SRC)*.c)
SRCH	:= $(wildcard $(SRC)*.h)
SRCA	:= $(wildcard $(SRC)*.asm)
OBJ		:= ./obj
OBJC	:= $(patsubst  $(SRC)%.c, $(OBJ)/%.r01,$(SRCC))
OBJA	:= $(patsubst  $(SRC)%.asm, $(OBJ)/%.r01,$(SRCA))

TOOL	:= ../../../tools/

IAR		:= ../../../iar/
IARINC	:= $(IAR)inc/
OSSDK	:= ../../_sdk/


ifeq ($(OS),Windows_NT)
RM		:= $(TOOL)msys/rm.exe -r -f
MKDIR	:= $(TOOL)msys/mkdir.exe
WINE	:=
else
RM		:= rm -r -f
MKDIR	:= mkdir
WINE	:= wine
endif

AZ80	:= $(WINE) $(IAR)bin/az80.exe
ICCZ80	:= $(WINE) $(IAR)bin/iccz80.exe
XLIB	:= $(WINE) $(IAR)bin/xlib.exe



all: $(BIN)

$(BIN): $(OBJC) $(OBJA)
	$(RM) $(BIN)
	$(XLIB) -c $(foreach r,$(OBJC) $(OBJA),"fetch-modules $(r) $(BIN)")
#	$(XLIB) -c "list-modules $(BIN)"

$(OBJ)/%.r01: $(SRC)%.asm  $(OSSDK)sysdefs.asm | $(OBJ)
	$(AZ80) -uu -S -v0 -O$(OBJ)/ -I$(OSSDK) $<

$(OBJ)/%.r01: $(SRC)%.c  $(SRCH) | $(OBJ)
	$(ICCZ80) -v0 -S -ml -uu -b -q -x -K -gA -z7 -t4 -T -O$(OBJ)/ -L$(OBJ)/ -A$(OBJ)/ -I$(IARINC) $<

$(OBJ):
	$(MKDIR) $@

clean: 
	$(RM) $(OBJ) $(BIN)
