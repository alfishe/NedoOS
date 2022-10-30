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
	@echo "For making TR-DOS(ATM UART) version call: 'make atmtrdos'"
	@echo "For making TR-DOS(AY+6912) version call: 'make aytrdos'"
	@echo "For making TR-DOS(AY+TIMEX80) version call: 'make t80trdos'"
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
	$(SJASMPLUS) main.asm -DNEDOOS -DNEDONET -DGS --lst=main.lst -DV=$(VERSION)

nedoosatm: $(SOURCES)
	$(SJASMPLUS) main.asm -DNEDOOS -DNEDOOSATM -DGS --lst=main.lst -DV=$(VERSION)

nedoosevo: $(SOURCES)
	$(SJASMPLUS) main.asm -DNEDOOS  -DNEDOOSEVO -DGS --lst=main.lst -DV=$(VERSION)

atmtrdos: $(SOURCES)
	copy Sample.trd MOONR.TRD
	$(SJASMPLUS) main.asm -DTRDOS -DNEDOOSATM -DZXSCR -DGS --lst=main.lst -DV=$(VERSION)
	del MR-TR-AU-64.TRD
	ren MOONR.TRD MR-TR-AU-64.TRD

evotrdos: $(SOURCES)
	copy Sample.trd MOONR.TRD
	$(SJASMPLUS) main.asm -DTRDOS -DNEDOOSEVO -DZXSCR -DGS --lst=main.lst -DV=$(VERSION)
	del MR-TR-EU-64.TRD
	ren MOONR.TRD MR-TR-EU-64.TRD

aytrdos: $(SOURCES)
	copy Sample.trd MOONR.TRD
	$(SJASMPLUS) main.asm -DTRDOS -DAY -DZXSCR -DGS --lst=main.lst -DV=$(VERSION)
	del MR-TR-AY-64.TRD
	ren MOONR.TRD MR-TR-AY-64.TRD

zwtrdos: $(SOURCES)
	copy Sample.trd MOONR.TRD
	$(SJASMPLUS) main.asm -DTRDOS -DZW -DZXSCR -DGS --lst=main.lst -DV=$(VERSION)
	del MR-TR-ZW-64.TRD
	ren MOONR.TRD MR-TR-ZW-64.TRD

t80trdos: $(SOURCES)
	copy Sample.trd MOONR.TRD
	$(SJASMPLUS) main.asm -DTRDOS -DAY -DTIMEX80 -DGS --lst=main.lst -DV=$(VERSION)
	del MR-TR-AY-80.TRD
	ren MOONR.TRD MR-TR-AY-80.TRD

godzillaz: $(SOURCES)
	copy Sample.trd MOONR.TRD
	$(SJASMPLUS) main.asm -DTRDOS -DAY -DZXSCR -DGODZILLA -DGS --lst=main.lst -DV=$(VERSION)
	del MR-TR-AY-64-G.TRD
	ren MOONR.TRD MR-TR-AY-64-G.TRD
	copy Sample.trd MOONR.TRD
	$(SJASMPLUS) main.asm -DTRDOS -DAY -DTIMEX80 -DGODZILLA -DGS --lst=main.lst -DV=$(VERSION)
	del MR-TR-AY-80-G.TRD
	ren MOONR.TRD MR-TR-AY-80-G.TRD

clean:
	rm $(BINARY) $(LST)