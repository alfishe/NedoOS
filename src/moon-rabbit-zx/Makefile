ifeq ($(OS),Windows_NT)
SOURCES=$(shell cmdfind.bat asm) $(shell cmdfind.bat gph)
SJASMPLUS="../../tools/sjasmplus.exe"
else
SOURCES=$(shell find . -type f -iname  "*.asm") $(shell find . -type f -iname  "*.gph")
SJASMPLUS="sjasmplus"
endif
BINARY=moon.bin moon.com
LST=main.lst
all: 
	@echo "For making MB03 version call: 'make mb03'"
	@echo "For making ZXUno(esxDOS) version call: 'make zxuno'"
	@echo "For making ZXUno(esxDOS, usual screen) version call: 'make zxuno-zxscreen'"
	@echo "For making NedoOS version call: 'make nedoos'"
	@echo ""
	@echo "Before changing version call: 'make clean' for removing builded images"

	
mb03: $(SOURCES)
	$(SJASMPLUS) main.asm -DPROXY -DMB03 -DTIMEX -DGS --lst=main.lst
	
zxuno: $(SOURCES)
	$(SJASMPLUS) main.asm -DUNO -DTIMEX --lst=main.lst
	
zxuno-zxscreen: $(SOURCES)
	sjasmplus main.asm -DUNO -DZXSCR --lst=main.lst

esxdos-ay: $(SOURCES)
	sjasmplus main.asm -DAY -DZXSCR --lst=main.lst
	
nedoos: $(SOURCES)
	$(SJASMPLUS) main.asm -DNEDOOS -DGS --lst=main.lst

clean:
	rm $(BINARY) $(LST)