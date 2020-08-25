;
; CCB.ASM: Second main source file of CC.ASM
;
;	Miscellaneious utility routines,
;


;
; Delete a file:
;

	IF CPM
delfil:
	ld de,fcb
delf2:
	push hl
	push de
	ld hl,12
	add hl,de
	ld (hl),0
	ld c,delete
	call bdos
	pop de
	pop hl
	ret
	ENDIF

;
; Create a new file:
;
create:
	IF CPM
	ld de,fcb
create2:
	push hl
	push de
	ld hl,12	;clear extent byte
	add hl,de
	ld (hl),0
	ld c,makfil
	call bdos
	pop de
	ld hl,32
	add hl,de
	ld (hl),0
	pop hl
	cp 255
	ret nz
	ENDIF

	jp openo3

;
; Open a file for output:
;
openo:	ld de,fcb
openo2:	call openg
	ret nz

openo3:	ld hl,stg3
	jp pstgab

	IF CPM
openg:	push hl
	push de
	push de		;save fcb pointer
	ld c,openfil
	call bdos
	pop de		;clear nr byte
	ld hl,32
	add hl,de
	ld (hl),0
	cp 0ffh	;return Z set on error
	pop de
	pop hl
	ret
	ENDIF


;
; Close a file:
;
closef:	ld de,fcb
close2:
	IF CPM
	push hl
	ld c,closefil
	call bdos
	pop hl
	cp 255
	ret nz
	ld hl,stg2
	jp pstgab
	ENDIF


;
; Write a sector of a file out to disk:
;

	IF CPM
writs:	ld de,fcb
writs2:	push hl
	ld c,wsequen
	call bdos
	pop hl
	or a
	ret z
	ld hl,stg3
	jp pstgab

;
; Copy 128 bytes from mem at (HL) to tbuff (80h), pad last sector
; with ^Z's if CPYEND reached and return Cy set if so:
;


copys:	ld de,tbuff
	ld b,80h

copy1:	ld a,(hl)
	ld (de),a
	push de
	ex de,hl
	lhld cpyend
	ld a,h
	cp d
	jp nz,copy2
	ld a,l
	cp e
	jp z,copy5

copy2:	ex de,hl
	pop de
	inc hl
	inc de
	dec b
	jp nz,copy1
	xor a
	ret

copy5:	pop de
copy6:	dec b
	jp z,copy7
	ld a,1ah
	ld (de),a
	inc de
	jp copy6

copy7:	scf
	ret
	ENDIF		;end of CP/M-dependent file I/O


;
; Bump line count:
;

bumpnl:	push hl
	lhld nlcnt
	inc hl
	shld nlcnt
	pop hl
	ret


;
; print out file name in default fcb:
;

pfnam:	push de
	ld de,fcb
	call pfnam2
	pop de
	ret

;
; Print out filename of fcb at DE:
;


pfnam2:	push de
	push hl
	push bc
	ld a,(de)		;get disk code
	or a
	jp z,pfnm3	;if file on currently logged disk, don't print
			;disk designator.

;	ld c,gdisk	;This section of code commented out to keep
;	push de		;files on the currently logged drive from having
;	call bdos	;a disk designator printed before their names.
;	pop de		;uncomment the code to put this feature back
;	inc a		;into action.

pfnm2:	add a,'@'		;get A = 'A' for drive A, 'B' for B, etc.
	call outch
	ld a,':'
	call outch
pfnm3:	inc de
	ld b,8
	call pnseg
	ld a,(de)
	cp ' '
	ld a,'.'	;print dot only if filename has extension
	call nz,outch
	ld b,3
	call pnseg
	pop bc
	pop hl
	pop de
	ret

pnseg:	ld a,(de)
	cp ' '
	call nz,outch
	inc de
	dec b
	jp nz,pnseg
	ret

;
; Print out the value in HL in hex, followed by a colon
; and a space.
; Upon entry, A non-0: print no leading spaces
;	       A == 0: print leading spaces making total textual output 4 chars
;
;

prhcs:	push af
	push de
	call prh	;convert HL to ascii at ascb
	pop de
	pop af
	or a
	ld hl,ascb
	jp z,prhcs3	;if printing leading spaces, go do it
	dec hl
prhcs1:	inc hl
	ld a,(hl)
	cp ' '
	jp z,prhcs1	;if all four digits, no leading spaces needed

prhcs3:	call pstg
	ret

;
; Print A in ASCII followed by a slash
;

prads:	and 1fh		;max 31
	call pra
	ld a,'/'
	call outch
	ret

pra:	cp 10		;single digit?
	jp nc,pra2	;if not, go handle double digits
pra0:	add a,'0'		;print single digit in A
pra1:	call outch
	ret
pra2:	ld b,0		;calculate 10's digit
pra3:	inc b
	sub 10
	cp 10
	jp nc,pra3
	push af
	ld a,b
	call pra0	;print tens digit
	pop af
	jp pra0

;
; Convert value in HL into ASCII at ascb, ascb+1, ascb+2, ascb+3:
;

prh:	push hl
	ld hl,'  '
	shld ascb
	ld hl,' 0'	;mac doc. is wrong about this!
	shld ascb+2
	pop hl
	inc hl

prh0:	ld a,h
	or l
	ret z
	dec hl
	push hl
	ld hl,ascb+3

prh1:	ld a,(hl)
	cp ' '
	jp nz,prh2
	ld a,'0'

prh2:	inc a
	cp '9'+1
	jp z,prh4

prh3:	ld (hl),a
	pop hl
	jp prh0

prh4:	ld (hl),'0'
	dec hl
	jp prh1


;
; 2's complement HL:
;

cmh:	push af
	ld a,h
	cpl
	ld h,a
	ld a,l
	cpl
	ld l,a
	inc hl
	pop af
	ret


;
; "Ignore stuff" routine; pass by newlines, white space,
; module start and end bookkeeping, and keep the lines count
; (stored in nlcnt) for error reporting:
;

igsht:	ld a,(de)
	cp modbeg	;begin nested module?
	jp nz,igsh0

	inc de
	call pushmn	;push on modstk, process line number stuff
	jp igsht

igsh0:	cp modend
	jp nz,igsh1	;include file end?
	call popmn	;restore line number and pop filename off modstk
	jp igsh1a

igsh1:	cp 0ffh
	jp nz,igsh2

igsh1a:	inc de
	jp igsht

igsh2:	cp nlcd
	jp nz,igsh3
	call bumpnl
	inc de
	jp igsht

igsh3:	or a
	ret

;
; Push filename at DE onto modstk, save current line number after it,
; bump modstc, and reset nlcnt:
;

pushmn:	push hl		;save HL
	ld hl,modstc	;bump modstc
	inc (hl)
	ld a,(hl)
	cp 6
	ld hl,stgine
	call nc,perrab		

	lhld modstp	;get next mod stack entry slot address
	ld b,12
	call ldrc	;push new module name onto modstk
	push de		;save text ptr
	ex de,hl
	lhld nlcnt	;get line count
	ex de,hl		;line count in DE, modstk ptr in HL
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	shld modstp
	ld hl,0
	shld nlcnt	;clear nlcnt for new module
	pop de		;restore text pointer
	pop hl		;restore HL
	ret	

;
; Pop modstk entry:
;

popmn:	push hl		;save registers
	push de
	lhld modstp
	dec hl
	ld d,(hl)
	dec hl
	ld e,(hl)		;DE holds old nlcnt
	ex de,hl
	shld nlcnt	;restore line count
	ld hl,-12
	add hl,de		;roll modstk pointer back to start of current level
	shld modstp	;save modstk pointer
	ld hl,modstc	;debump module count
	dec (hl)
	pop de
	pop hl
	ret

ldrc:	ld a,(de)
	ld (hl),a
	inc hl
	inc de
	dec b
	jp nz,ldrc
	ret

;
; General purpose ram lde routine. 
; B = byte count
; C controls direction of lde:
;	0: DE->HL, 1: HL->DE
;

ldram:	ld a,c
	or a
	jp z,ldr2
	ex de,hl
ldr2:	ld a,(de)
	ld (hl),a
	inc hl
	inc de
	dec b
	jp nz,ldr2
	ld a,c
	or a
	jp z,ldr3
	ex de,hl
ldr3:	push de		;make sure we don't overflow stack area
	push hl
	lhld coda
	ex de,hl		;put code area addr in DE
	pop hl		;and current include stack pointer in HL
	call cmphd
	pop de		;restore sp
	ret c		;if OK, return
	ld hl,stgine	;include error
	jp pstgab	;print message and quit

;
; Map alphabetic character in A to upper case:
;

mapuc:	cp 61h
	ret c
	cp 7bh
	ret nc
	sub 20h
	ret

;
; Special version of mapuc,  which supresses mapping if "mapucv" is true
;

mapuc0:	push bc		;save B
	ld b,a		;save char to map in B
	lda mapucv	;get control var
	or a		;do we do a mapping?
	ld a,b		;get back char to map in A
	call z,mapuc	;if we do a mapping, go do it
	pop bc		;restore B
	ret		;all done

	
;
; Print out line number, error message in HL, and set errf so
; we don't auto-load cc2:
;

perr:	push af
	call pwarn
	ld a,1
	sta errf
	pop af
	ret

;
; Print out line number, error message in HL, but don't touch
; errf:
;

pwarn:	push hl
	call pmodnc	;print module name
perr2:	lhld nlcnt
	call prhcs	;print line number of error
	pop hl
	call pstg
	ret

;
; Print module name, colon, space:
;

pmodnc:	call pmodnm
	push af
	ld a,':'
	call outch
	ld a,' '
	call outch
	pop af
	ret


;
; Print out module name:
;

pmodnm:	push hl
	push de
	lhld modstp
	ld de,-14
	add hl,de
	ex de,hl	
	call pfnam2
	pop de
	pop hl
	ret


;
; Print out string pointed to by HL, with + character shorthand
; for a CR-LF:
;

pstg:	ld a,(hl)
	or a
	ret z
	cp '+'
	jp z,crlf
	call outch
	inc hl
	jp pstg

;
; Print strig to console only:
;

pstgco:	lda werrs
	push af
	xor a
	sta werrs
	call pstg
	pop af
	sta werrs
	ret

;
; Output a character of text to the console and/or PROGERRS.$$$ file:
;

outch:	push de
	push bc
	push hl
	push af

        if 1==1
        PRCHAR
        else
	ld e,a
	lda werrs
	or a		;if not writing errs to PROGERRS file,
	jp z,outch3	;	go write to console
	
	lda nomore	;if done writing RED errors, just go to console
	or a
	jp nz,outch3

	lda errsin
	or a
	jp nz,outch1	;if RED buffer initialized, go handle I/O
			;else initialize RED buffer:
	inc a
	sta errsin

	push de
	ld de,redfcb
	lda odisk
	ld (de),a
	call delf2	;delete previous PROGERRS.$$$
	call create2	;create new one
;	call openo2	;open for output
	ld hl,redbuf
	shld redbp	;initialize redbuf sector pointer

	ld hl,stgeri	;"RED error output initiated"
	call pstgco	;print text to console only
	pop de

outch1:	call redout	;write char to red output file

outch3:	ld c,conout
	call bdos
        endif
        
	pop af
	pop hl
	pop bc
	pop de
	ret

; Write a character to RED output buffer, flushing if needed:

redout:	lhld redbp	;get redbuf pointer
	ld (hl),e		;store char
	inc hl		;bump pointer
	shld redbp	;save pointer
	ld a,l		;past end of buffer?
	cp (redbuf+128) and 0ffh
	ret nz		;if not, return



redwrt:	push de
	ld de,redbuf	;set DMA address to redbuf for sector write
	ld c,sdma
	call bdos

	ld de,redfcb
	call writs2	;write sector

	ld de,tbuff	;set DMA address back for normal file i/o
	ld c,sdma
	call bdos

	ld hl,redbuf
	shld redbp	
	pop de
	ret


;
; print "undeclared variable: " and print out the
; variable name being pointed to by DE:
;

bvarm:	ld hl,stg14
bvarm2:	call perr
	push de
	call pvarn	;print out the name
	pop de
	call crlf
	ret

;
; print out the variable name pointed to by DE:
;

pvarn:	ld a,(de)
	call varch
	ret c
	call outch
	inc de
	jp pvarn

;
; Print error message in HL and abort:
;

pstgab:
pstgb2:	call pstg
	jp errab

;
; Print error msg in HL with line number, and abort:
;

perrab:	call perr

;
; Come here to abort, when fatal error has been diagnosed:
;

errab:	lhld errbyt	;set error byte flag for ZCPR3
	ld (hl),0ffh

	call errwrp	;wrap up any RED file activity

errab2:	ld a,7		;ring a bell for errors having occurred
	call outch
	lda erasub	;bother to erase submit files?
	or a
	jp z,exit

	;ld e,0		;go to user 0 for submit file erasure
	;ld c,sguser

	IF NOT ALPHA
	;lda nouser
	;or a
	;jp nz,errab3	;if no user areas, don't do it

	;lda zenvf	;if not ZSYSTEMS, don't do it
	;or a
	;call nz,bdos
;errab3:
	ENDIF

	ld de,subfile	;erase pending submit files and abort
	call delf2

exit:	;call resetu	;reset to original user drive/ user area
        QUIT
	;lda wboote	;need to perform warm-boot?
	;or a
	;jp nz,ram		;if so, go do it.
	;lhld spsav	;get (possibly valid) saved stack pointer
	;ld sp,hl		;put into SP
	;lda ccpok	;CCP intact?
	;or a
	;ret nz		;if so, return to CCP
	;jp ram		;otherwise do a warm boot

;resetu:	;lda origdsk	;reset disk and user area to original
	;ld e,a
	;ld c,select
	;call bdos
	;lda origusr
	;ld e,a
	;ld c,sguser

	;IF NOT ALPHA
	;lda nouser
	;or a
	;call z,bdos	
	;ENDIF

	;ret



;
; Print a newline to the console:
;

crlf:	push af

	IF CPM
	ld a,cr
	call outch
	ENDIF

	ld a,lf
	call outch
	pop af
	ret

;
; Check for abortion:
;TODO

ckabrt:
	push hl
	push de
	push bc
	push af

	;lda conpol	;are we polling the console?
	;or a
	;jp z,nohit	;if not, don't do anything

	;ld c,intcon	;interrogate console status
	;call bdos
	;or a
	;jp z,nohit
	;ld c,coninp
	;call bdos	;if something hit, see if a ^C
	;cp 3
	;jp z,intrpt	
nohit:	pop af		;if not, don't interrupt
	pop bc
	pop de
	pop hl
	ret

intrpt:	ld hl,stgabo	; and abort.
	jp pstgab
	
;
; Check for stack overflow:
;

chkstk:	push hl
	push de
	push bc
	push af
	lhld stkchk
	ld de,0a55ah
	call cmphd	;make sure stack check word is still intact
	jp z,nohit	;if so, no problem
	ld hl,stgstk	;else spew stack overflow message
	jp perrab


;
; Squeeze the symbol table by chopping out the name portion of every entry
; (reducing the st size by half, since each entry up to now has been
; 8 chars of name and 8 bytes of attributes):
;

chopst:	lhld stno
	ld b,h
	ld c,l		;BC = symbol entry count
	ld hl,st
	ld de,st

sqst2:	ld a,b
	or c
	jp nz,sqst3
	shld stp
	ret

sqst3:	push hl
	ld hl,8
	add hl,de
	ex de,hl
	pop hl

sqst4:	ld a,(de)
	ld (hl),a
	inc de
	inc hl
	ld a,l
	and 7
	jp nz,sqst4
	dec bc
	jp sqst2

;
; Write out special CCI-symbol-table file for Kirkland's debugger if "-w"
; option given...write out stno entries from symbol table at st, each
; 16 bytes long. Call the file <name>.CDB ... this is gonna be a neat hack!
;

wst4db:	lda kflg	;was -w even given?
	or a		;if not, return
	ret z

	ld hl,st	;get size of symbol table in HL
	call cmh
	ex de,hl
	lhld stp	;get symbol table next free slot pointer
	shld cpyend	;this is where we'll stop writing to the output file.
	add hl,de
	shld st-2	;put symbol table size in place

	IF CPM
	ld hl,fcb+9
	ld (hl),'C'
	inc hl
	ld (hl),'D'
	inc hl
	ld (hl),'B'
	lda odisk	;set output disk designation
	sta fcb
	call delfil	;delete old versions
	call create	;create output file
;	call openo	;and open it for output

	ld hl,st-2
wstdb2:	call copys
	push af
	call writs
	pop af
	jp nc,wstdb2
	call closef	;close the output file.
	ENDIF

	ret


;
; Little general purpose utility to compare HL and DE,
; and return C set if HL < DE
;

cmphd:	ld a,h
	cp d
	ret nz
	ld a,l
	cp e
	ret


;
; Routine to make sure we haven't overflowed available memory space. At
; first, we try to use memory below the command processor (under both
; CP/M and MARC). If we run out of room, we either punt the CCP under
; CP/M or do the maxmem call under MARC to get more memory.
;

ckov:	push hl
	push de
ckov0:	lda curtop+1	;high order byte of top of mem addr
	dec a
	ld d,a
	ld a,h
	cp d
	jp c,ckovok	;overflow?

	IF CPM
	lda ccpok	;under CP/M, is the CCP still intact?
	or a
	jp nz,ckov1	;if so, go try for more memory
	ENDIF

	ld hl,stgov	;We've used all we can...it's all over now.
	jp pstgab

ckov1:
	IF CPM
	push hl
	ld hl,NEDOOSMEMTOP;lhld bdosp	;change curtop to reflect BDOS address now
	ld l,0		;zero out low order byte
	shld curtop
	pop hl
	xor a		;and tell that the CCP is now defunct
	sta ccpok
	jp ckov0
	ENDIF	


ckovok:	pop de
	pop hl
	ret



;
; The following function is hairy. It forms the core hack of the BDS C
; parsing algorithm: it ldes expands and compacts text at the current
; text pointer location (DE), where A upon entry is negative to EXPAND
; by -(A), positive to squeeze by A, or zero to do nothing.
;
; This is getting documented approximately 3 1/2 years after being written.
; It's been one HELL of a WIERD three and a half years!!!!!!!!!!
;

TESTM:	EQU 0


mvtxt:	or a		;check for zero
	ret z		;return if so
	jp p,sqish	;if positive, go squish

	cpl		;otherwise negate
	inc a

	push hl		;save registers
	push bc
	push de
	push af

	ld a,(de)
	cp 0ffh
	jp nz,mvtxt1

	pop af
	cp 1
	jp nz,mvtxt0
	pop de
	pop bc
	pop hl
	ret

mvtxt0:	pop de
	pop bc
	pop hl
	inc de
	dec a
	cpl
	inc a
	call mvtxt
	dec de
	ret

	IF TESTM

	call tstriv	;see if expansion is all into filler bytes...
	jp nz,mvtxt1	;if not, go do standard expansion

	pop af		;if so, we don't need to do anything,
	pop de		;so pop registers and return.
	pop bc
	pop hl
	ret

;
; Returns Z set if there are at least (A) FF bytes at (DE). 
; Preserves DE but not necessarily A:
;

tstriv:	push de		;save text pointer
tstrv2:	ld a,(de)		;text for FF
	cp 0FFh
	jp nz,tstrv3	;if not, trivial test fails.
	inc de		;else bump text pointer to next char
	dec a		;and test for completion
	jp nz,tstrv2	;if haven't found enough, go on looking
			;otherwise we found enough--success!
tstrv3:	pop de
	ret
	ENDIF


mvtxt1:	pop af
	sta mvtmp
	jp fndff

mvtxt2:	lda mvtmp
	ld h,d
	ld l,e
	dec de

mvtxt3:	push af
	ld a,(de)
	ld (hl),a
	pop af
	pop bc
	push af
	ld a,c
	cp e
	jp nz,mvtxt5
	ld a,b
	cp d
	jp nz,mvtxt5
	pop af
	dec a
	jp nz,mvtxt6
	pop bc
	pop hl
	ret

mvtxt5:	pop af
	push bc
	dec hl

mvtxt6:	dec de
	jp mvtxt3


fndff:	ld c,a
	sta fndtmp
	ld b,7
	ld a,(de)
	or a
	jp nz,fff0
	ld a,1
	call expnd
	inc de

fff0:	ld a,(de)
	or a
	jp z,fff2
	cp 0ffh
	jp nz,fff1
fff0b:	inc de
	ld a,(de)
	cp 0ffh
	dec de	
	ld a,(de)
	jp nz,fff1
	dec c
	jp z,mvtxt2

	ld b,7
	push de
fff0a:	inc de
	jp fff0

fff1:	cp nlcd
	jp z,fff1a
	cp cr
	jp nz,fff4
fff1a:	dec de
	cp '\'
	inc de
	jp z,fff4
	dec de
	dec de
	ld a,(de)
	inc de
	inc de
	cp '\'
	jp z,fff4
	dec b
	jp nz,fff0a
	ld b,7
	inc de
	ld a,(de)
	cp 0ffh
	jp z,fff0b

fff2:	ld a,c
	add a,40
	call expnd

fff3:	dec c
	jp z,mvtxt2
	push de
	inc de
	jp fff3

fff4:	ld a,(de)
	cp swtbc
	jp nz,fff5
	inc de
	ld a,(de)
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	inc hl
	inc hl
	inc de
	add hl,de
	ex de,hl
	jp fff0

fff5:	call cdtst
	jp c,fff6
	inc de
	inc de
	jp fff0a

fff6:	cp modbeg
	jp nz,fff0a
	ld hl,14
	add hl,de
	ex de,hl
	jp fff0

sqish:	push bc
	ld b,a
	ld a,0ffh
sqish2:	ld (de),a
	inc de
	dec b
	jp nz,sqish2
	pop bc
	ret


expnd:	push hl
	push bc
	push af
	push de
	lhld eofad
	ld b,h
	ld c,l
	ld e,a
	ld d,0
	add hl,de
	push hl
	push bc
	shld eofad
	ld b,h
	ld c,l
	lhld meofad
	call max
	shld meofad
	pop bc
	pop hl
	call ckov
	pop de

expnd1:	call mvbhd
	pop af
	ld b,a
	push de
expnd4:	ld a,0ffh
	ld (de),a
	inc de
	dec b
	jp nz,expnd4
	pop de
	pop bc
	pop hl
	ret


;
; Routine to lde stuff from (BC) to (HL), decrementing both
; as we go, until BC passes DE -- doing it by block lde if possible
; (if runnign a Z80), or by brute force if on an 8080 or 8085.
; Clobbers BC and HL.
;

mvbhd:	lda z80f	;z80?
	or a
	jp z,mvbhdl	;if not, do it the long way

	push de
	push hl	
	ex de,hl
	call cmh
	add hl,bc
	inc hl
	push hl
	ld h,b
	ld l,c
	pop bc
	pop de
	db 0edh,0b8h	;ldir instuction
	pop de
	ret


mvbhdl:	ld a,(bc)		;do it the long way
	ld (hl),a
	ld a,c
	cp e
	jp nz,mvbhd2
	ld a,b
	cp d
	ret z
mvbhd2:	dec hl
	dec bc
	jp mvbhd


;
; Return Cy true if byte in A is a code byte:
;

cdtst:	cp concd
	ret c
	cp strcd+1
	ccf
	ret

;
; Purge FF's and related garbage/filler bytes from text:
;

fixt:	lhld coda	;HL is source pointer
	ld d,h		;DE is dest pointer
	ld e,l

fix0:	ld a,(hl)		;end of code?
	or a
	jp nz,fix2

	ld (de),a		;yes. handle strings.
	inc de
	inc hl
fix1:	ld a,(hl)
	cp 1ah		;end of strings?
	jp nz,fix1a	;if not, still doing strings.
	ld (de),a		;yes.
	ex de,hl
	shld eofad
	ret

fix1a:  ld b,3		;handle string storge.
	call ldb
	ld b,a
	call ldb
	jp fix1

fix2:	call cdtst	;three byte code?
	jp c,fix4
	ld b,3
	call ldb
	jp fix0

fix4:	cp 0ffh	;garbage byte?
	jp nz,fix5
	inc hl		;yes. skip it.
	jp fix0

fix5:	cp swtbc	;switch statement?
	jp nz,fix8

	ld (de),a		;yes.
	inc de
	inc hl
fix6:	ld a,(hl)
	cp 0ffh
	jp nz,fix7
	inc hl
	jp fix6
fix7:	push hl
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	inc hl
	inc hl
	inc hl
	ld b,h
	ld c,l
	pop hl
	call mvmd
	jp fix0

fix8:	cp modbeg	;start of module?
	jp nz,fix10
	ld b,12	;yes. copy module name
	call ldb
	jp fix0

fix10:	ld (de),a
	inc hl
	inc de
	jp fix0


fix11:	ld hl,oshit
	call pstgab

ldb:	inc b
ldb2:	dec b
	ret z
	ld a,(hl)
	ld (de),a
	inc hl
	inc de
	jp ldb2



mvmd:	lda z80f
	or a
	jp z,mvmdl	;if on 8080, can't use block lde
	db 0edh,0b0h	;else can
	ret

mvmdl:	ld a,(hl)		;do it the hard way for 8080
	ld (de),a
	inc hl
	inc de
	dec bc
	ld a,b
	or c
	jp nz,mvmd
	ret


pascd:	call igsht
	ret z
	call cdtst
	jp nc,pscd2
	xor a
	inc a
	ld a,(de)
	ret

pscd2:	inc de
	inc de
	inc de
	jp pascd


fsemi:	ld a,semi


;
; Find next occurence of the character passed in A:
;

findc:	ld b,a
findc1:	ld a,(de)
	cp b
	ret z
	or a
	jp nz,finc2
	ld hl,stg10
	jp fatal

finc2:	cp nlcd
	jp nz,finc3
	call bumpnl

finc3:	inc de
	call cdtst
	jp c,finc4
	inc de
	inc de
	jp findc1

finc4:	push af
	lda eradf
	or a
	jp nz,finc5
	pop af
	jp findc1

finc5:	pop af
	cp 80h
	jp c,findc1	;if no control keyword found, no problem
	cp 9dh
	jp nc,findc1

	cp 8fh		;special case of a keyword allowed in
	jp z,findc1	;an expression: sizeof

	lhld nlcnt	;else error...probably missing semicolon
	push hl
	lhld errad
	shld nlcnt
	ld hl,stg25
	call perr
	pop hl
	shld nlcnt
	dec de
	dec de
	ld a,semi
	ld (de),a
	ret

;
; New routine that expects to see a semicolon as
; the first non-trivial item in text; else error given.
;

esemi:	call igsht
	cp semi	;next thing a semi?
	ret z		;if so, OK-- else insert one.

insrts:	lhld nlcnt	;save real line count
	push hl
	lhld esadr	;get fake count
	shld nlcnt
	ld hl,stg25
	call perr	;print error
	pop hl
	shld nlcnt
	ld a,negone	;make room for automatic semi
	call mvtxt
	ld a,semi	;just to aid diagnosing later errors
	ld (de),a
	ret


tstty:	cp chrcd
	ret c
	cp gotcd
	ccf
	ret


;
; Return Cy false if character in A is legal anywhere in an identifier name:
;

varch:	call varch2
	ret nc
	cp '0'
	ret c
	cp '9'+1
	ccf
	ret

;
; Return Cy false if char in A is legal as FIRST char in an identifier name:
;

varch2:	cp 'A'
	ret c
	cp 'Z'+1
	ccf
	ret nc
	cp 5fh
	ret z
	cp 61h
	ret c
	cp 7bh
	ccf
	ret


;
; Advance text pointer past identifier at DE:
;

pasvr:	call igsht
psvr2:	call varch
	jp nc,psvr3
	call igsht
	ret

psvr3:	inc de
	ld a,(de)
	jp psvr2


;
; Advance text pointer past parentheses at DE:

mtchp:	push hl
	call mtchp1
	pop hl
	ret

mtchp1:	call igsht
	cp open
	jp z,mtchq
	ld hl,stg40
	call perr
	call fsemi
	ret

mtchq:	lhld nlcnt
	shld mtpln

mtchpa:	inc de
mtchpb:	call pascd
	jp nz,mtchpc
mtchpe:	lhld mtpln
	shld nlcnt
	ld hl,stgbp
	jp fatal

mtchpc:	cp close
	jp nz,mtp2
	push hl		;save line count for error diagnostics
	lhld nlcnt
	shld esadr
	pop hl
	inc de
	call igsht
	ret

mtp2:	cp semi	;allow semicolons in parentheses only
	jp nz,mtp3	;if semiok is non-zero.
	lda semiok
	or a
	jp z,mtchpe
	jp mtchpa

mtp3:	cp open
	jp nz,mtchpa
	call mtchpa
	jp mtchpb

;
; Install identifier at DE in symbol table position given in HL:
;

instt:	push de
	push de
	lhld stp
	push hl
	ld de,16
	add hl,de
	lda coda+1
	ld b,a
	ld a,h
	cp b
	jp c,instta
instt0:	ld hl,stgom
	lda preflag
	or a
	jp z,fatal
	jp pstgab

instta:	pop hl
	pop de
	ld c,0
inst2:	ld a,(de)
	ld (hl),a
	inc c
	inc hl
	inc de
	ld a,(de)
	call varch
	jp c,inst4
	ld a,c
	cp 8
	jp c,inst2

inst3:	inc de
	inc c
	ld a,(de)
	call varch
	jp nc,inst3

inst4:	dec hl
	ld a,(hl)
	or 80h
	ld (hl),a
	inc hl
	ld a,8
	sub c
	ld e,a
	ld d,0
	jp c,inst5
	add hl,de
inst5:	shld tempd
	pop de
	ret



cvtst:	push de
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ex de,hl
	ld hl,st
	add hl,de
	ld de,8
	add hl,de
	pop de
	ld a,(hl)
	ret

finds:	lda clev
	sta flev
	call fs
	ret nc
	xor a
	sta flev


fs:	lhld stno
	ld b,h
	ld c,l
	ld hl,st

fs2:	ld a,b
	or c
	jp nz,fs3
	scf
	ret

fs3:	push de
	push bc
	call idcmp
	jp z,fs4
	ld de,16
fs3a:	add hl,de
	pop bc
	pop de
	dec bc
	jp fs2

fs4:	dec hl
	ld a,l
	and 0f8h
	ld l,a
	ld de,9
	add hl,de
	shld inadsv
	ld a,(hl)
	and 3fh
	ld d,a
	lda flev
	cp d
	jp z,fs5
	ld de,7
	jp fs3a

fs5:	pop hl
	call cmh
	ex de,hl
	lhld stno
	add hl,de
	pop de
	xor a
	ret

initst:	lhld stsiz
	ld b,h
	ld c,l
	ld hl,st
inits1:	ld (hl),0
	inc hl
	dec bc
	ld a,b
	or c	
	jp nz,inits1
	ret

;
; compare the symbol table entry at HL with the text identifier 
; at DE:
;

idcmp:	push de
	push hl
	ld c,1		;initialize char count
idcmp2:	ld a,(hl)
	and 7fh		;strip end-of-text bit from char of st entry
	ld b,a		;put it in B.
	ld a,(de)		;get a character from text.
	cp b		;same?
	jp z,idcmp3	;if so, go check rest of identifier
idcp2a:	pop hl		;else no match.
	pop de
	xor a		;clear zero flag
	inc a		;by incrementing from zero,
	scf		;and also set the carry flag.
	ret

idcmp3:	ld a,(hl)		;ok, so far it matches.
	or a		;was it the last char of the st entry?
	inc hl
	jp m,idcmp4	;jump if it was
	inc de		;it wasn't. bump text pointer, char count,
	inc c
	jp idcmp2	;and go look at next charcter

idcmp4:	ld a,c		;end of symbol. if we've already seen 8 characters,
	cp 8		;ignore rest of symbol at DE (insignificant chars)
	jp z,idcmp5	
	inc de		;haven't seen 8 chars yet...is next char of text
	ld a,(de)		;a legal identifier character?
	call varch
	jp nc,idcp2a	;if so, no match.

idcp4a:	xor a		;we have a match. set Z.
	pop de
	pop de
	ret

idcmp5:	inc de		;come here to pass over superfluous chars of text
	ld a,(de)
	call varch
	jp c,idcp4a
	inc c		;making sure to bump the char count in C as we go.
	jp idcmp5


;
; Make function name table:
;

mkfnt:	lhld stp
	shld fnts
	shld fntp
	lhld stno
	ld b,h
	ld c,l
	ld hl,st+8

mkft1:	ld a,b
	or c
	jp nz,mkft2	;done?
	lhld fntp	;yes. make sure we haven't overflowed	
	ex de,hl		;the symbol table
	lhld coda
	call cmphd	;return C if code area < end of func name table
	ret nc
	ld hl,stgom	;list too long. complain and abort
	jp pstgab

mkft2:	ld a,(hl)
	rra
	push hl
	push bc
	call c,mkft3
	pop bc
	pop hl
	ld de,16
	add hl,de
	dec bc
	jp mkft1

mkft3:	ld de,-8
	add hl,de
	push hl
	ld h,b
	ld l,c
	call cmh
	ex de,hl
	lhld stno
	add hl,de
	ex de,hl
	lhld fntp
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	pop de

mkft4:	ld a,(de)
	ld (hl),a
	inc de
	inc hl
	or a
	jp p,mkft4
	shld fntp
	ret

mvfnt:	lhld fnts
	call cmh
	ex de,hl
	lhld fntp
	add hl,de
	shld st-2
	ld b,h
	ld c,l
	lhld fnts
	ex de,hl
	lhld stp

mvft1:	ld a,b
	or c
	jp z,mvft2
	ld a,(de)
	ld (hl),a
	inc hl
	inc de
	dec bc
	jp mvft1

mvft2:	shld fntp
	ret

;
; Perform "big expansion" of text:
; 

bexp:	ex de,hl
	call cmh
	ld b,h
	ld c,l
	lhld eofad
	push hl
	push hl
	add hl,bc
	ld b,h
	ld c,l
	pop hl
	inc bc
	add hl,de
	shld eofad
	call ckov
	pop de

bexp1:	ld a,b
	or c
	jp z,bexp2
	ld a,(de)
	ld (hl),a
	dec hl
	dec bc
	dec de
	jp bexp1

bexp2:	inc de
	ret

;
; Either write CCI file to disk (if -az given, CP/M only) or auto-load
; into CC2:
;

writf:	lhld extsa	;put externals size word in place
	shld st-6

	ld hl,st	;get size of symbol table in HL
	call cmh
	ex de,hl
	lhld stp
	add hl,de
	shld st-4	;put symbol table size in place

	lhld eofad	;now copy tokenized code down to just past the
	ld b,h		;end of the symbol table
	ld c,l
	lhld coda
	ex de,hl
	lhld fntp
                
writ1:	ld a,(de)
	ld (hl),a
	inc hl
	inc de
	ld a,e
	cp c
	jp nz,writ1
	ld a,d
	cp b
	jp nz,writ1
	shld eofad

	IF CPM
	lda chainf
	or a
	jp nz,chain
	ENDIF

	IF NOT CPM
	jp chain
	ENDIF

	IF CPM
writ1a:	ld hl,fcb+9
	ld (hl),'C'
	inc hl
	ld (hl),'C'
	inc hl
	ld (hl),'I'
	lda odisk	;set output disk designation
	sta fcb
	call delfil
	call create	;create output file
	lhld eofad	;copy till end of all data
	shld cpyend

	ld hl,st-6
writ2:	call copys
	push af
	call writs
	pop af
	jp nc,writ2
	call closef	;close the output file.
	ret
	ENDIF


chain:
	lda cc2dsk	;get default cc2 disk
	sta cfcb	;set as first byte of fcb

	IF NOT ALPHA
	;lda nouser	;don't futz with user areas?
	;or a
	;jp nz,chain0	;if not, skip chandng user area

	;lda cc2usr	;get cc2 default user area
	;ld e,a

	;ld c,sguser
	;call bdos	;change to that user area
	ENDIF

chain0:	call occ2	;try to open in default user area and disk

	;push af	;save condition
	;lda curdsk	;switch back to current disk and user area
	;inc a
	;sta cfcb

	;IF NOT ALPHA
	;lda nouser
	;or a
	;jp nz,chain1

	;lda curusr	;change back to current user area
	;ld e,a

	;ld c,sguser
	;call bdos
	;ENDIF

;chain1:	pop af		;get back condition of first cc2 open attempt
	jp nz,ch3		;go read in if prior open succeeded

	call occ2	;else try to read in current disk and user area...
	jp nz,ch3		;if ok, go read

	jp cc2bad	;else give up

occ2:	lhld curtop
	push hl		;try to open cc2
	ld de,-33
	add hl,de
	push hl
	ld de,cfcb
	ld b,16
ch2:	ld a,(de)
	ld (hl),a
	inc hl	
	inc de
	dec b
	jp nz,ch2
	pop de
	ld c,openfil
	call bdos	;try to open cc2.com
	pop hl
	dec hl
	ld (hl),0		;clear nr field of CC2 fcb
	cp 255		;cc2 on disk?
	ret

cc2bad:	ld hl,stgcce	;nope. complain and write out cci file

	call pstg
	jp writ1a

ch3:	
	call ldef	;lde schlameel to high ram
	ld hl,tbuff	;lde bootstrap to tbuff (== just 80h under MARC)
	ld de,bootcode
	ld b,bootlen
ch4:	ld a,(de)
	ld (hl),a
	inc hl
	inc de
	dec b
	jp nz,ch4

;
; Now set up stack at ram area, and push all data that will have to
; be popped back into cc2. The order of pushing, and resulting address
; in cc2, are as follows:
;
;	no.	item	address in cc2
;	---	----	--------------
;	0	kflg	110h
;	1	odisk	5fh		(CP/M only)
;	2	optimf	104h
;	3	loadad	105h-106h
;	4	eflag	109h
;	5	exaddr	107h-108h
;	6	curtop	10ch-10dh
;	7	ccpok	10eh		(ccpok: b0, oktort: b1, wboote b2,
;						zenvf: b3)
;		maxmd	10eh		(MARC only)
;	8	spsav	10ah-10bh	(CP/M only)
;		fnam	10ah-10bh	(MARC only)
;	9	erasub	10fh		(CP/M only)
;	10	defsub/	111h-112h	(CP/M only)
;		conpol
;	11	errbyt	113h-114h	(CP/M only)
;	
; The bootstrap pops these in the reverse order, or course, and sets
; them up in the newly-loaded in cc2.com file.
;

	ld sp,tpa
	lda kflg	;save CDB flag
	push af
	lda odisk	;save output disk flag
	push af
	lda optim	;save optimization flag
	push af
	lhld loadad	;save load address
	push hl
	lda eflag	;save external addr given flag
	push af
	lhld exaddr	;save external address if given
	push hl
	lhld curtop	;save current top of memory
	push hl

	IF CPM
	lda ccpok	;save CCP intact flag
	or a
	jp z,bt000
	ld a,1		;set b0 to ccpok
bt000:	ld b,a		;save in B

	lda oktort	;get oktoret flag
	add a		;put bit in b1 position
	add b		;accumulate
	ld b,a		;save it

	lda wboote	;set b2 to wboote
	or a
	jp z,bt001
	ld a,4		;if true, make b2 hi
bt001:	add b

	lda zenvf
	or a
	jp z,bt002
	ld a,8		;set b3
bt002:	add b

	push af	;save combination of (b0 b1 b2 b3)

	;lhld spsav	;save CCP's stack pointer
	;push hl

	lda werrs	;if werrs false, just push erasub
	or a
	lda erasub
	jp z,setbt1
	or 2		;if werrs true, but b1 high on erasub
	
setbt1:	push af
	lhld defsub	;save defsub/conpol bytes
	push hl
	lhld errbyt	;get ZCPR3 error byte address
	push hl

	lhld curtop	;put fcb address of cc2 fcb in BC
	ld de,-33
	add hl,de
	ld b,h
	ld c,l
	ENDIF

	jp tbuff	;go do it

;
; This is the bootstrap that will run down at tbuff:
;

bootcode:
	IF CPM		;first the CP/M version...
	ld de,tpa	;(cp/m only code is: 35 bytes)
	push de		;save memory load address pointer
	push bc		;save cc2's fcb address
	ld c,sdma	;set DMA address to current memory load address (DE)
	call bdos
	pop de		;pop cc2's fcb address into DE
	push de		;and push back on stack for later
	ld c,rsequen	;read a sector
	call bdos
	or a
	pop bc		;pop cc2's fcb address into BC
	pop de		;pop memory load address
	jp nz,postld	;if done, go finish up
	ld hl,80h	;otherwise add 80h to memory load address
	add hl,de
	ex de,hl		;and put it back in DE
	jp tbuff+3
	ENDIF

;
; pop stuff off stack for CC2:
;

postld:  equ tbuff + $ - bootcode
	IF CPM
	pop hl		;get back wboote flag + extra byte
	shld ram+113h
	pop hl		;get back defsub and conpol bytes
	shld ram+111h
	pop af		;get back erasing submit files flag
	sta ram+10fh
	ENDIF

	;pop hl		;pop filename under MARC or saved SP under CP/M
	;shld ram+010ah	

	pop af		;pop ccpok/maxmd flag
	sta ram+010eh

	pop hl		;pop current top of memory address
	shld ram+010ch

	pop hl		;pop external variables address
	shld ram+0107h
	pop af		;pop external address flag
	sta ram+0109h

	pop hl		;pop load address
	shld ram+0105h
	pop af		;pop optimization flag
	sta ram+0104h
	pop af		;pop output disk designation flag

	IF CPM
	sta fcb		;set output disk designation
	ENDIF

	pop af		;pop CDB flag
	sta ram+110h

	ld a,1
	sta ram+103h	;set chained-to flag
	jp tpa		;and go execute

bootlen: equ $-bootcode	;length of bootstrap

;
; (end of bootstrap)
;




ldef:	ld de,-(st-6)
	lhld eofad
	add hl,de		
	inc hl
	ex de,hl		;DE = length of text
	lhld curtop
	ld bc,-36
	add hl,bc
	ld b,h
	ld c,l		;BC = destination
	push bc		;save for later
	lhld eofad	;HL = source
ldef1:	ld a,(hl)
	ld (bc),a
	dec bc
	dec hl
	dec de
	ld a,d
	or e
	jp nz,ldef1
	pop hl		;get addr of where start addr goes
	inc hl		;now HL = BDOS - 35
	ld (hl),c
	inc hl		;and BDOS - 34
	ld (hl),b
	ret		;and all done!


	IF LASM
	link ccc
	ENDIF
