ifeq ($(OS),Windows_NT)
SOURCES=$(shell cmdfind.bat)
SJASMPLUS="../../tools/sjasmplus.exe"
else
SOURCES=$(shell find . -type f -iname  "*.asm")
SJASMPLUS="sjasmplus"
endif
BINARY=moon.bin moon.com
LST=main.lst
all: 
	@echo "For making MB03 version call: 'make mb03'"
	@echo "For making ZXUno version call: 'make zxuno'"
	@echo ""
	@echo "Before changing version call: 'make clean' for removing builded images"

	
mb03: $(SOURCES)
	$(SJASMPLUS) main.asm -DPROXY -DMB03 -DTIMEX -DGS --lst=main.lst
	
nedoos: $(SOURCES)
	$(SJASMPLUS) main.asm -DNEDOOS -DGS --lst=main.lst

zxuno: $(SOURCES)
	$(SJASMPLUS) main.asm -DUNO -DTIMEX --lst=main.lst
	
clean:
	rm $(BINARY) $(LST)