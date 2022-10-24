ifeq ($(OS),Windows_NT)
SOURCES=$(shell cmdfind.bat asm) $(shell cmdfind.bat gph)
SJASMPLUS="../../tools/sjasmplus.exe"
else
SOURCES=$(shell find . -type f -iname  "*.asm") $(shell find . -type f -iname  "*.gph")
SJASMPLUS="sjasmplus"
endif
BINARY=moon.bin moon.com
LST=main.lst
VERSION="16"
all: 
	@echo "For making MB03 version call: 'make mb03'"
	@echo "For making ZXUno(esxDOS) version call: 'make zxuno'"
	@echo "For making ZXUno(esxDOS, usual screen) version call: 'make zxuno-zxscreen'"
	@echo "For making Ay-Wifi(esxDOS) version call: make esxdos-ay"
	@echo "For making NedoOS version call: 'make nedoos'"
	@echo "For making NedoOS(ATM UART) version call: 'make nedoosatm'"
	@echo "For making NedoOS(EVO UART) version call: 'make nedoosevo'"
	@echo ""
	@echo "Before changing version call: 'make clean' for removing builded images"
	
mb03: $(SOURCES)
	$(SJASMPLUS) main.asm -DPROXY -DMB03 -DTIMEX -DGS --lst=main.lst -DV=$(VERSION)
	
zxuno: $(SOURCES)
	$(SJASMPLUS) main.asm -DUNO -DTIMEX --lst=main.lst -DV=$(VERSION)

zxuno-zxscreen: $(SOURCES)
	$(SJASMPLUS) main.asm -DUNO -DZXSCR --lst=main.lst -DV=$(VERSION)

esxdos-ay: $(SOURCES)
	$(SJASMPLUS) main.asm -DAY -DZXSCR --lst=main.lst -DV=$(VERSION)
	
nedoos: $(SOURCES)
	$(SJASMPLUS) main.asm -DNEDOOS -DGS --lst=main.lst -DV=$(VERSION)

nedoosatm: $(SOURCES)
	$(SJASMPLUS) main.asm -DNEDOOS -DNEDOOSATM -DGS --lst=main.lst -DV=$(VERSION)

nedoosevo: $(SOURCES)
	$(SJASMPLUS) main.asm -DNEDOOS -DNEDOOSATM -DNEDOOSEVO -DGS --lst=main.lst -DV=$(VERSION)


clean:
	rm $(BINARY) $(LST)