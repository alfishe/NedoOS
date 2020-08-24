;
; clinkb.asm:
;
; This routine finds, somehow, the name of the next CRL file to search.
; It also processes any command line options that weren't taken care
; of back at the start of the link. This routine has grown into a real
; bitch of kludginess, and I'm sorry about that...but it's so CUTE in
; the way it does so damned much "on the fly" zipping down the command
; line. Anyway, once the command line runs out, deff.crl and deff2.crl
;	(or deff0.crl, deff1.crl, deff2.crl, etc., under MARC)
; are spit back, and if those have been scanned already then a list of
; unresolved function references is printed (because this routine wouldn't
; be CALLED if all the functions had been resolved...) and the user is
; prompted for another file name, or a special command like abort (control-Q)
; or search all deff*.crl files again (a carriage-return.)
;

getfn:	lda mflag	; has command line been fully processed?
	or a
	jp z,gfnzz2	;if so, go do something else...

	lhld cptr	;no.
gfn0:	ld a,(hl)
	call twhite	;skip leading white space at the current position
	jp nz,gfna	;of scanning
	inc hl
	jp gfn0

gfna:	or a		;have we reached the end of the line (so to speak)?
	jp nz,gfnb
gfnzz:	sta mflag	;yes. set this flag to tell us so next time

	lda donef	;If link has been completed already, and we were
	or a		;just scanning for more possible command line options,
	ret nz		;then return right here.

gfnzz2:	lda dflag	;if haven't searched DEFF.CRL yet,
	or a
	jp z,gfldf	;go do it.

	IF CPM
	lda d2flag	;if haven't searched DEFF2.CRL yet,
	or a
	jp z,gfld2f	;go do it.

	lda d3flag	;if haven't scanned DEFF3.CRL yet,
	or a
	jp z,gfld3f	;go do it.
	ENDIF

	jp gtfnz	;else go get file name from user.

gfnb:	cp '-'		;is the next thing an option?
	jp nz,gfnc	;if not, go get filename
gfnb0:	inc hl		;yes.
gfnb1:	ld a,(hl)		;put in A and convert to upper case
	call mapuc
	sta opletr	;save for possible error reports later

	cp 'S'		;print stats?
	jp z,sets

	IF MARC
	cp 'M'		;do maxmem call in c.ccc?
	jp z,setm
	ENDIF

	cp 'T'		;set top of memory?
	jp z,sett

	cp 'O'		;set output filename?
	jp z,seto

	cp 'W'		;write symbol table?
	jp z,setw

	cp 'E'		;set external data starting addr?
	jp z,setext

	IF CPM		;TEMPorRILY UNIMPLEMENETED UNDER MARC
	cp 'Z'		;inhibit clearing of external data?
	jp z,setz

	cp 'Y'		;read in symbol table file from disk
	jp z,gsyms

	cp 'D'		;debug mode?
	jp z,setd

	cp 'N'
	jp z,setn
	ENDIF

	cp 'F'		;switch to scanning of functions (from loading)?
	jp z,setf

	call twhite
	jp z,gfn0
	or a
	jp z,gfn0

	push af
	ld de,stgbop	;bad option
	call pstg
	pop af		;print the option char used
	call outch
	call crlf
	jp abort

sets:	sta statf
	jp gfnb0

	IF MARC
setm:	push hl		;insert a "call marc" instruction at mhackl in c.ccc:
	lhld cda	;get start of code area
	ld de,mhackl	;get displacement for mhackl in DE
	add hl,de		;HL --> where "call marc" will go
	ld (hl),0cdh	;"call" op
	inc hl
	ld (hl),msys and 0ffh
	inc hl
	ld (hl),msys/256
	
	lda taddrf	;if -t option used, don't change taddr
	or a
	jp nz,setm2

	lhld curtop	;make physical top of memory logical top 
	shld taddr	;at run-time

setm2: 	pop hl		;restore text pointer

	jp gfnb0
	ENDIF


setw:	sta wflg	;write symbols out
	jp gfnb0

	IF CPM
setz:	sta zflag	;inhibit clearing external flag
	jp gfnb0

setn:	sta nflag	;activate NOBOOT option
	jp gfnb0
	ENDIF

setf:
	IF FORCE
	xor a
	ENDIF

	IF NOT FORCE
	ld a,1
	ENDIF

	sta fflag
	inc hl
	jp gfn0

	IF CPM		;temp. unimplemented under MARC
setd:	ld a,1		;for starters, no text list
	sta debugf	;causes file to be executed
	inc hl		;pass over the `D'
	call igsp	;test for arg list text
	cp '"'
	jp nz,gfna	;if not, all done
	sta debugf	;set debugf to > 1 to indicate a text list	
	inc hl
	shld argptr	;and set a pointer to the arg list
setd1:	ld a,(hl)		;find the trailing quote
	inc hl
	cp '"'
	jp nz,setd1
	jp gfnb1	;instead of written to disk
	ENDIF

sett:	inc hl
	call gtaddd
	ex de,hl
	shld taddr
	ld a,1
	sta taddrf
	ex de,hl
	jp gfn0

;
; Scan a hex address at text at HL and return
; with the value in DE, and HL pointing past the text:
; Complain and abort if no legal value given.	
;

gtaddd:	ld de,0
gtad1:	call igsp
	call tsthd
	jp nc,gtad3
	ld de,stgver
stgab:	call pstg

	IF CPM
	call crlf
	ENDIF

	jp abort

gtad2:	ld a,(hl)
	call tsthd
	ret c
gtad3:	call addda
	inc hl
	jp gtad2

addda:	push hl
	ex de,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld e,a
	ld d,0
	add hl,de
	ex de,hl
	pop hl
	ret

tsthd:	call mapuc
	sub '0'
	ret c
	cp 10
	ccf
	ret nc
	cp 11h
	ret c
	cp 17h
	ccf
	ret c
	sub 7
	ret

seto:
	IF MARC
	ld a,1
	sta oflag
	ENDIF

	inc hl		;point HL to filename
	ld de,fcbs	;this is where the fcb for it will be set up

	IF CPM
	lda decl	;save default crl disk 'cause we're gonna clobber it
	push af
	lda fcbs	;get default output disk
	sta decl	;put it here for gfncp2
	ENDIF

	call igsp	;ignore leading space of filename text
	call gfncp2	;set up fcb

	IF CPM
	pop af
	sta decl	;restore decl
	ENDIF

	jp gfn0

setext:	inc hl
	call gtaddd
	ex de,hl
	shld eaddr
	ld a,1
	sta eflag
	ex de,hl
	jp gfn0

	IF CPM
gsyms:	inc hl		;read in a symbol table file
	call igsp	;ignore spaces
	push hl		;assume "sym" extension by default
	ld hl,fcb+9
	ld (hl),'S'
	inc hl
	ld (hl),'Y'
	inc hl
	ld (hl),'M'
	pop hl

	call gfncp	;set up the default FCB w/file name
	xor a
	call open	;try to open the symbols file for reading
	jp c,gsym2	;if can't, don't read in symbols
	ld hl,tbuff
	shld buffp	;init buffer pointer

	lhld cdp
	push hl		;save code pointer
gsymlp:	ld a,1		;set "reading symbol" flag
	sta rdngsm
	call dosym	;process a symbol
	jp nc,gsymlp	;until we run out
	pop hl		;get back
	shld cdp
	xor a		;clear "reading symbols" flag
	sta rdngsm

	call close	;close symbol file
gsym2:	lhld cptr	;get back text pointer
	jp gfn0	;and go process more commands



dosym:	call igsht	;ignore garbage
	ret c		;return if EOF
	call tsthd	;legal value character?
	jp c,serror
	call getval	;get value in hex from file

	push hl		;this gets added later, 
	call getcdf
	call cmh	;so subtract it now!	
	ex de,hl
	pop hl

	add hl,de		;subtracting...
	shld cdp	;set up for call to entt1
	call getname	;get symbol name at sname buffer
	ld hl,sname	;get pointer to name
	ld de,stgmn	;is it the "MAIN" entry?
	call stcmp
	ret z		;if so, don't yank it!
	ld a,1		
	sta gotf	;this is so that entt1 defines the symbol here
	call entt1
	xor a		;no error
	ret		;and done with the symbol

serror:	ld de,stgserr	;"illegal symbol in file"
	jp stgab

getname: ld hl,sname
	call igsht
	jp c,serror	;if no legal 1st char of symbol name, error
getn2:	ld (hl),a
	inc hl
	call getcc	;get next char
	jp c,getn3	;if EOF, also end-of-symbol!
	call tstsht	;is it "whitespace" character?
	jp nz,getn2	;if not, store and get next char
getn3:	dec hl		;turn on bit 7 of last char
	ld a,(hl)
	or 80h
	ld (hl),a
	ret


getval:	ld hl,0		;clear sum
getv2:	add hl,hl		;shift sum left 4 bits
	add hl,hl
	add hl,hl
	add hl,hl
	ld e,a		;add new hex digit to sum
	ld d,0
	add hl,de
	call getcc	;any more chars?
	call tsthd
	jp nc,getv2	;if so, go do them
	ret		;else done


igsht:	call getcc	;get character from file
	call tstsht	;if no more, return C set
	ret c
	jp z,igsht	;and ignore junk
	ret
	ENDIF

tstsht:	call twhite
	ret z
	cp 0dh		;cr?
	ret z
	cp 0ah		;lf?
	ret z
	cp 1ah		;EOF?
	scf
	ret z		;if so, set C
	ccf		;else not EOF
	ret		;else good character

	IF CPM
getcc:	push hl		;save HL
	lhld buffp	;get buffer pointer
	ld a,l
	and 7fh		;start of buffer?
	jp nz,getc2
	call reads	;yes. read in a sector
	ret c		;return C if EOF
getc2:	ld a,(hl)		;get char from buffer
	push af	;save character
	inc hl		;bump pointer
	ld a,l		;end of sector?
	and 7fh
	jp nz,getc3
	ld hl,tbuff
getc3:	pop af
	shld buffp	;and save for next time
	pop hl		;restore HL
	or a		;clear Carry
	ret
	ENDIF

igsp:	ld a,(hl)		;ignore spaces at text at HL
	call twhite
	ret nz
	inc hl
	jp igsp

;
; At this point, we have a filename on the command line. It will
; be interpreted as the name of a CRL file, and scanned for needed
; functions:
;

gfnc:	call gfncp	;collect up the name
	jp afterg

;
; This routine, given a pointer to the ascii text of a CP/M filename,
; sets up the default fcb with the given name. The disk to stick in the
; the disk byte by default is loaded from decl, but that is overridable
; if an explicit disk designator is given.
;
; The filename may also be preceded by a user number code of form "#/",
; causing a switch to that user area for the duration of the file scan,
; and then a reversion back to the current user area.
;

gfncp:
;	IF CPM		;put a CP/M filename into the default fcb:
 	ld de,fcb
gfncp2:	push de		;save pointer to working fcb
	push hl		;save text pointer
	call gdec	;user area prefix? If so, starts with number...
	jp c,gfncp4	;if not, don't assume a user number is there
	ld a,(hl)		;if we saw a number, check for trailing slash
	cp '/'
	jp nz,gfncp4	;if no slash, it wasn't a user number

	ex (sp),hl		;pop old text pointer off stack
	pop hl

	push de		;save DE
	ld e,b		;set the user number to the given value
	ld c,sguser
	lda nouser
	or a
	push hl		;save pointer to slash in text
	IF NOT ALPHA
	call z,bdos
	ENDIF
	pop hl		;get back text pointer

	pop de		;restore DE
	inc hl		;bump text ptr past the slash
	push hl		;push back so we can fall through to next section
	xor a		;disable default disk searching
	sta search

gfncp4:	pop hl		;restore text pointer to start of filename
gfncp5:	inc hl
	ld a,(hl)		;is an explicit disk designator given?
	dec hl
	cp ':'
	lda decl
	ld (de),a		;in case not, set it up with the default disk
	jp nz,gfnc0
	xor a		;disable default disk searching
	sta search
	ld a,(hl)		;else get the actual disk letter
	call mapuc	;in upper case, of course
	sub '@'		;subtract offset to put into proper range
	inc hl
	inc hl
	ld (de),a		;save at start of target fcb
	ld a,(hl)		;space or null follow designator?
	or a
	jp z,gfncp9
	cp ' '
	jp nz,gfnc0	;if not, go parse filename
gfncp9:	pop de		;else don't, having only modified disk designator.
	ret
	
gfnc0:	inc de
gfnc1:	ld b,8
	call gfnc3	;load the principle filename
	ld a,(hl)
	or a
	jp z,gfnca	;end of command line?
	cp ' '		;if not, was filename terminated by a space?
	jp z,gfnca	;if so, don't touch the COM extension
	inc hl		;else either clear the extension (if a lone "." given)
	ld b,3		;or set up the new exntension.
	call gfnc3
gfnca:	shld cptr	;save command line pointer
	ex (sp),hl		;exchage command line pointer with fcb address on stack
	ld de,12	;clear the extent field of the fcb
	add hl,de
	ld (hl),0
	pop hl		;get back the command line pointer and return
	ret

;
; This routine copies up to B ascii letters from text at HL to the fcb
; filename or extension field at DE, padding with spaces on the right:
;

gfnc3:	ld a,(hl)
	or a
	jp z,padsp
	call twhite
	jp z,padsp
	cp '.'
	jp z,padsp
	call mapuc
	ld (de),a 	
	inc de
	inc hl
	dec b
	jp nz,gfnc3
padsp:	ld a,b
	or a
	ret z
	ld a,' '
	ld (de),a
	inc de
	dec b
	jp padsp
;	ENDIF

	IF NOT CPM	;for MARC, copy the filename to fcbt:
	ld de,fcbt
gfncp2:	ld a,(hl)
	or a
	jp z,gfncp3
	call tstsht	;end of name?
	jp z,gfncp3
	ld (de),a
	inc hl
	inc de
	jp gfncp2	

gfncp3:	shld cptr
	xor a
	ld (de),a
	ret
	ENDIF

afterg:	lda donef		;if all done, we don't need to load the file
	or a
	jp nz,getfn

	IF CPM
	  call scrl
;	  inc a
;	  sta search		;search current, then default disk/user area
	ENDIF

	IF NOT CPM
	  push hl
	  ld hl,fcbt
	  call scrl
	  pop hl
	ENDIF	

	ret

;
; Announce missing functions after all given CRL files have been
; read in and there are still unresolved function references:
;

gtfnz:	ld de,stgas
	call pstg	;"missing functions:"
	call list	;list out function names

	IF MARC
	xor a
	sta dlast	;reset deff?.crl counter whenever going into
	ENDIF		;interactive mode under MARC

getfn2:	call crlf
	ld de,stg7	;ask for input
	call pstg

gfl1:	ld hl,tbuff	;get a line of user input at tbuff

	IF CPM		;under CP/M, use the bdos call to get a line of input
	ld (hl),120
	ex de,hl
	ld c,readbuf
	call bdos	;get line of input
	call crlf
	ld hl,tbuff+2	;get length byte
	push hl
	dec hl	
	ld a,(hl)
	inc a
	add l
	ld l,a
	ld (hl),0
	pop de
	ENDIF

	IF NOT CPM		;get a line of input under MARC:
	push hl		;save pointer to start of text line buffer area
gfl1a:	call inch	;get a character from console
	ld (hl),a		;save it
	inc hl		;bump pointer
	cp newlin	;newline?		
	jp nz,gfl1a
	dec hl
	ld (hl),0		;if so, change it to a null
	pop de		;and restore pointer to accumulated line into DE
	ENDIF

gfl1b:	ld a,(de)
	inc de
	call twhite
	jp z,gfl1b

	IF CPM
	cp 1ah		;control-Z?
	jp nz,gfl1c	;if so, abort the linkage
	ENDIF

	IF NOT CPM
	jp gfl1c	;don't bother checking for ^Q under MARC, since
	ENDIF		;^C's are handled by the OS.

abort:
	lhld errbyt
	ld (hl),0ffh

	IF NOT ALPHA
	ld e,0		;switch to user 0 to erase submit file under ZSYSTEM
	ld c,sguser
	lda nouser
	or a
	jp nz,abort2

	lda zenvf	;zsystems?
	or a
	call nz,bdos	;if so, change to user 0
abort2:
	ENDIF

	ld de,subfile	;if so, erase submit file on user 0
	ld c,delete
	call bdos

	lda curusr	;restore to current user area
	ld e,a
	ld c,sguser
	lda nouser
	or a
	IF NOT ALPHA
	call z,bdos
	ENDIF

	ld de,stgabt	;abort message
	call pstg
	jp exit

	IF NOT CPM
	lda marcfd	;any file open?
	or a
	call nz,close	;if so, close it
	call crlf	;put out extra CR-LF under MARC
	ld hl,-1
	jp exit
	ENDIF

gfl1c:	or a		;null input line?
	jp nz,gfl2

	IF MARC
	xor a		;if so, cause all deff*.crl files to be searched
	sta dflag	;under MARC
	ENDIF

gfldf:
	IF FORCE
	xor a
	sta fflag	;turn off forced loading while scanning libraries
	ENDIF

	ld hl,deffs	; search deff.crl (or current deff?.crl under MARC)

	IF MARC		;now--go through all deff?.crl files under MARC
	push hl
	lda dlast	;has the cycle been started yet?
	or a		;if so, go on to next iteration
	jp nz,gfldfn
	ld a,'0'	;else start it up with deff0.crl
	sta dlast
	dec a		;make it so it gets bumped to '0' and used

gfldfn:	ld de,10	;point to variable location
	add hl,de

	inc a		;bump dlast to next value
	cp ':'		;if up past the digits, turn it into an 'a'
	jp nz,gfldfo
	ld a,'a'

gfldfo:	sta dlast	;save for looping
	ld (hl),a		;and put into filename as next deff?.crl to search
	cp '4'
	jp c,gfldfp

	sta quietf	;be quiet if past deff3.crl

gfldfp:	pop hl	

	ex de,hl
	lhld noffst	;add either 0 (to search /libC) or 6 (current direct)
	add hl,de
	ENDIF

	IF CPM
	ld de,fcb
	ENDIF

	IF NOT CPM
	ld de,fcbt
	ENDIF

	call ldfn

	IF CPM
	call setdu	;make library user area the current user area
	xor a
	sta d2flag	;cause deff2.crl and deff3.crl to be re-scanned
	sta d3flag
	sta search	;don't search anywhere but default
	inc a
	sta dflag	;and say that deff.crl has now been scanned
	ENDIF

	ret


;	IF CPM		;only search DEFF2.CRL and DEFF3.CRL explicitly
gfld2f:	ld hl,deff2s	;under CP/M
	ld de,fcb
	call ldfn
	xor a
	sta search	;only search default
	inc a
	sta d2flag
	call setdu	;set library user area to be current
	ret

gfld3f:	ld hl,deff3s
	ld de,fcb
	call ldfn
	xor a
	sta search	;only search default
	inc a
	sta quietf	;don't complain if can't open file
	sta d3flag
	call setdu	;set library user area to be current
	ret

setdu:	lda defusr
	ld e,a
	ld c,sguser
	lda nouser
	or a
	IF NOT ALPHA
	call z,bdos
	ENDIF
	ret
;	ENDIF

gfl2:	ex de,hl		;put text address in HL
	dec hl
	call gfncp	;set up fcb with name of file

	IF MARC
	ld hl,fcbt
	ENDIF
;
;	IF CPM
;	ld a,1
;	sta search	;search current, then default disk/user area
;	ENDIF

	call scrl
	ret

;
; List out names of missing functions:
;

list:	ld hl,tab1
	shld fngtt
	ld b,7
lst1:	call fung2
	ret c

lst2:	ld a,(hl)
	push af
	and 7fh

	IF CPM
	call mapuc
	ENDIF

	call outch
	pop af
	or a
	inc hl
	jp lst2
	dec b
	jp nz,lst3
	call crlf
	ld b,7
lst3:	ld a,' '
	call outch
	call outch
	jp lst1

readc:	lda segf	;if segment, don't read in C.CCC
	or a
	ret nz

	IF CPM
	call savfn	;else do...if CP/M, save main filename for later use
	ENDIF

	ld hl,ccc	;get name of c.ccc

	IF MARC
	ex de,hl
	lhld noffst	;add either 0 (to search /libC) or 6 (current direct)
	add hl,de
	ENDIF

	IF CPM
	ld de,fcb	;set up fcb under CP/M
	call ldfn
	ENDIF

	xor a
	call open	;open c.ccall c,for reading
	jp c,abort	;abort if can't find it

	IF CPM		;read in c.ccall c,under CP/M
	lhld cda
rdc1:	call reads
	jp c,rdc2
	call cpys
	jp rdc1
	ENDIF

	IF NOT CPM
	lda marcfd	;figure out how big c.ccall c,really is
	ld c,(hl)$fsize
	call msys
	ex de,hl		;put length into DE (from HL)
	lhld cda	;get load address into HL
	call reads	;under MARC, call read to get entire file in
	ENDIF



rdc2:	lhld cda
	ld a,(hl)		;test if ZSYSTEMS c.ccc
	cp 0ebh
	jp z,rdc2a
	xor a		;if not, reset zsysf, else set it
rdc2a:	sta zsysf

	ld de,cccsiz
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)	
	lhld cda
	add hl,de
	shld cdp
	call close
	
	IF CPM
	call resfn	;restore main filename to default fcb under CP/M
	ENDIF

	IF TESTING
	call printf
	   db 'c.ccall c,loaded correctly',0
	ENDIF

	ret		;end of readc routine

	IF CPM
savfn:	ld hl,fcb
	ld de,fcbt
	jp ldfn

resfn:	ld hl,fcbt
	ld de,fcb
	jp ldfn
	ENDIF

	IF CPM
ldfn:	ld b,13
ldf1:	ld a,(hl)
	ld (de),a
	inc hl
	inc de
	dec b
	jp nz,ldf1
	ret
	ENDIF

	IF NOT CPM
ldfn:	ld a,(hl)
	ld (de),a
	inc hl
	inc de
	or a
	jp nz,ldfn
	ret
	ENDIF


;
; Read a function in to memory from the currently open CRL file:
;

rdfun:	call ckabrt
	lda fcnt	;bump function count
	inc a
	sta fcnt
	cp 255		;reached functional limit of clink?
	jp nz,rdf0
	ld de,stgtmf	;yes. complain and abort.
	jp stgab
			;else proceed reading in the function:
rdf0:	lhld enst	;get starting position of function in the file
	ld b,h
	ld c,l		;put into BC
	call cmh	;negate it
	ex de,hl
	lhld enend	;get ending position (actually start of next one)
	add hl,de		;subtract starting position to get length
	push hl		;save length
	ex de,hl		;put into DE
	lhld cdp	;and add to current load address
	add hl,de

rdf0a:	lda curtop+1	;to see if it overflows memory
	dec a		;** possible bug fix ***
	ld l,a
	ld a,h
	cp l
	jp c,rdf1		;overflow?
			;yes....

	IF CPM
	lda ccpok	;CCP intact?
	or a
	jp nz,rdf00a	;if so, try making it go away
	ENDIF

rdf0b:	ld de,stgom	;if so, print message and abort
	jp stgab	;just abort under CP/M

rdf00a:
	IF CPM
	push hl		;save HL
	lhld bdosp	;get protected memory address
	ld l,0
	shld curtop	;make it new top of memory
	pop hl		;restore HL
	xor a
	sta ccpok	;clear CCP intact flag
	jp rdf0a	;go try again
	ENDIF

rdf1:
	IF CPM
	ld de,fcb	;OK, function will fit into memory.
	call setdat
	ld a,c
	or 80h
	ld l,a
	ld h,ram/256
	shld tbp
	call reads
	ENDIF

	IF NOT CPM
	lhld enst	;get starting position of function in CRL file
	ld b,0		;absolute seek
	ld c,(hl)$seek
	lda marcfd
	call msys	;seek to correct position in file
	jp nz,ferror
	ENDIF

	lhld cdp	;get code pointer
	ex de,hl		;put into DE: this is where the data will go
	pop hl		;get length of function module
	push hl
	add hl,de		;add to base address
	shld cdn	;save this for some other routine to futz with

	IF CPM
	pop hl
rdf2:	call rdbt
	ld (de),a
	inc de
	dec hl
	ld a,h
	or l
	jp nz,rdf2
	ret
	ENDIF

	IF NOT CPM
	pop de		;get length of function module
	lhld cdp	;get load address for function module
	call reads	;read in the module
	ret
	ENDIF

	IF CPM		;all this kludgery only for CP/M
rdbt:	push hl
	lhld tbp
	ld a,l
	or a
	jp z,rdb2
	ld a,(hl)
	inc hl
	shld tbp
	pop hl
	ret

rdb2:	call reads
	ld hl,tbuff
	ld a,(hl)
	inc hl
	shld tbp
	pop hl
	ret

;
; Routine used under CP/M to set the extent and record fields
; of the default fcb to the first sector of the function to be read in:
;

setdat:	ld h,b
	ld l,c
	add hl,hl
	ld a,h
	and 7fh
	ld hl,32
	add hl,de
	ld (hl),a
	sta tmpnr
	ld a,b
	rlca
	rlca
	and 3
	ld hl,12
	add hl,de
	cp m
	ret z
	push af
	push hl
	call close
	pop hl
	pop af
	ld (hl),a
	call open
	jp c,abort
	lda tmpnr
	sta fcb+32
	ret
	ENDIF		;end of this section of CP/M-only kludgery

pre:
	IF TESTING
	call printf
	  db 'calling rdfun:',0
	ENDIF

	call rdfun	;read in the function

	IF TESTING
	call printf
	  db 'returned from rdfun.',0
	ENDIF
	
	lhld cdp

	push hl		;find start of code, so on-the-fly
pre0:	ld a,(hl)		;reference fixing can be done for
	inc hl		;those references to functions
	or a		;already processed and in their
	jp nz,pre0	;fixed positions.
	inc hl		;found end of name list.
	inc hl		;now HL -> start of actual func code
	shld fncodb	;save function code begin addr
	pop hl
	
	lda fcnt2
	ld b,a
	ld c,0
pre1:	ld a,(hl)
	or a
	jp z,pre2
	push hl
	inc c
	ld h,b
	ld l,c
	shld refv
	xor a
	sta gotf
	pop hl
	push hl
	push bc
	call entt1
	pop bc
	pop hl
	call pb7hi
	jp pre1

pre2:	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ex de,hl
	lhld cdp
	push hl
	push hl
	call cmh
	add hl,de
	ex de,hl
	pop hl
	call sqish
	pop hl
	add hl,bc
	push hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	push hl
	call getcdf2
	shld fadr
	pop hl
pre3:	ld a,b
	or c
	jp z,pre4
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	push hl
	lhld cdp
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	push hl
	lhld fadr
	add hl,de
	ex de,hl
	pop hl
	ld (hl),d
	dec hl
	ld (hl),e
	pop hl
	dec bc
	jp pre3

pre4:	pop hl
	shld cdp
	ret

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


sqish:	push bc
	ld b,h
	ld c,l
	add hl,de
	ex de,hl
	lhld cdn
sq2:	ld a,(de)
	ld (bc),a
	ld a,d
	cp h
	jp nz,sq3
	ld a,e
	cp l
	jp nz,sq3
	pop bc
	ret
sq3:	inc de
	inc bc
	jp sq2


reslv:	ld hl,tab1
	ld d,0
rlv2:	ld a,(hl)
	or a
	ret z
	inc hl
	jp rlv2
	ld a,(hl)
	and 7fh
	ld b,a
	inc hl
	ld c,(hl)
	inc hl
	push hl
	push de
	ld l,d
	ld h,0
	add hl,hl
	ld de,tab2
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	call getcdf
	add hl,de
	shld doresv
	pop de
	pop hl

rlv3:	ld a,b
	or c
	jp nz,rlv4
	inc d
	jp rlv2

rlv4:	push de
	push hl
	inc hl
	ld l,(hl)
	ld h,0
	add hl,hl
	ld de,tab2
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	pop hl
	ld a,(hl)
	inc hl
	inc hl
	call dores
	pop de
	dec bc
	jp rlv3


dores:	push hl
	push bc
	ld c,a
	ld b,0
	ld hl,0
	add hl,bc
	add hl,bc
	add hl,bc
	inc hl
	add hl,de
	ex de,hl
	lhld doresv
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	pop bc
	pop hl
	ret


entt1:	ex de,hl
	ld hl,tab1
	ld bc,0
	xor a
	sta fcnt2
et1a:	ld a,(hl)
	or a
	jp z,et1c
	push bc
	call stcmp
	pop bc
	jp z,et1d
	lda fcnt2
	inc a
	sta fcnt2
et1b:	call past1e
	inc bc
	jp et1a

et1c:	ld a,(de)

	IF CPM
	call mapuc2
	ENDIF

	ld (hl),a
	inc de
	inc hl
	or a
	jp et1c
	ld (hl),0
	inc hl
	ld (hl),0
	inc hl
	ld (hl),0
	dec hl
	dec hl

	xor a		;allow this symbol entry
	sta rdngsm
	
	push de
	call ckov2	;check for table 1 overflow
	pop de

et1d:	lda gotf
	or a
	ld a,(hl)
	inc hl		;has the function just been read in?
	jp nz,et1e
	or a		;no. has it been read in previously?
	jp et1d2


	lda fcnt2	;yes. fix reference immediately. first
	ld l,a		; compute where referenced function will
	ld h,0		; reside at run time...
	add hl,hl		;now HL is offset into tab2.
	ld de,tab2	;get HL pointing to location of address
	add hl,de		; of referenced function.
	ld a,(hl)		;and get the address.
	inc hl
	ld h,(hl)
	ld l,a		;now HL points to the function code in RAM
	ex de,hl		;need to add offset to get actual
	call getcdf	; load address
	add hl,de		;now HL = load address of the referenced func
	shld doresv	;save it for use by dores.

	lhld fncodb	;now compute location of reference within
	ex de,hl		; the new function...DE -> start of code
	lda refv	;A tells position # of jump vector
	jp dores	;let dores figure out the rest and do

et1d2:	push de
	ld e,(hl)
	dec hl
	ld d,(hl)
	inc de
	ld (hl),d
	inc hl
	ld (hl),e
	pop de
	inc hl
	call tb1ex

	call ckfng
	ex de,hl
	lhld refv
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	ret

et1e:	lda rdngsm	;has new symbol been previously defined?
	or a
	jp z,et1e2

	dec hl		;perhaps. test if table entry is defined...
	ld a,(hl)
	or a
	inc hl
	jp et1e2	;if bit 7 was set on that byte, it was defined...
			; so was it?
	ld de,stgdps	;yes...complain
	ld hl,sname
	lda fflag	;forcing all functions from a crl file?
	or a
	jp z,et1e0

	ld a,81h	;set this so function doesn't get loaded later
	sta gotf
	ld de,stgdpf	;if so, use special message for duplicate entry
	lhld savnam	;get pointer to function name
	
	IF FORCE
	push hl
	ld a,(hl)
	cp 'M'
	jp nz,et1e00
	inc hl
	ld a,(hl)
	cp 'A'
	jp nz,et1e00
	inc hl
	ld a,(hl)
	cp 'I'
	jp nz,et1e00
	inc hl
	ld a,(hl)
	cp 'N'+80h		
	jp nz,et1e00
	pop hl
	ret

et1e00:	pop hl
	ENDIF

et1e0:	call pstg
et1e1:	call pfnm
	call crlf	;follow with CR-LF combo
	ret		;and ignore the symbol name this time...


et1e2:	dec hl
	ld a,(hl)
	or 80h
	ld (hl),a
	ld hl,tab2
	add hl,bc
	add hl,bc
	ex de,hl
	lhld cdp
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	ret

ckfng:	push de
	push hl
	ex de,hl
	lhld fngtt
	ld a,h
	sub d
	jp c,ckfd
	jp nz,ckfng1
	ld a,l
	sub e
	jp c,ckfd
ckfng1:	inc hl
	inc hl
	shld fngtt
ckfd:	pop hl
	pop de
	ret

;
; Expand tab1 from the current position of HL by 2 bytes:
;

tb1ex:	push hl
	push bc

	push hl
	lhld tb1end
	ld b,h
	ld c,l
	dec bc
	dec bc
	pop hl

	call cmh
	add hl,bc
	inc hl
	push bc
	ld b,h		;set BC to the count
	ld c,l

	lhld tb1end
	ex de,hl
	pop hl		;HL is source addr

	ld a,2		;if on 8080, do it the hard way
	inc a
	jpo z80exp

ex8080:	ld a,(hl)
	ld (de),a
	dec hl
	dec de
	dec bc
	ld a,b
	or c
	jp nz,ex8080
	jp ckov

z80exp:	db 0edh,0b8h	;LDDR on Z80.

ckov:	lhld tb1end	;check last byte of tab1 (initialized to zero)
	ld de,-10
	add hl,de
	ld a,(hl)
	or a		;if still zero, ok
	jp z,ckovok
	ld de,stgt1o	;else overflow
	jp stgab

ckov2:	push hl
	push bc
	jp ckov
	
ckovok:	pop bc
	pop hl
	ret	

;
; Test the strings at DE (b7 high on last char) and
; at HL for equality:
;

stcmp:	push bc
	push de
	push hl
stcm1:	ld a,(hl)

	IF CPM
	call mapuc2
	ENDIF

	ld b,a
	ld a,(de)

	IF CPM
	call mapuc2
	ENDIF

	cp b
	jp nz,stcm3
	or a
	jm stcm2
	inc de
	inc hl
	jp stcm1
stcm2:	pop de
	pop de
	pop bc
	xor a
	inc hl
	ret
stcm3:	pop hl
	pop de
	pop bc
	ret

;
; Map character in A to upper case, preserving
; the parity bit:
;

mapuc2:	push bc
	or a
	push af
	and 7fh
	call mapuc
	ld b,a
	pop af
	ld a,b
	pop bc
	rp
	or 80h
	ret

;
; Test routine for debugging MARC version under CP/M:
;
	IF TESTING2
test:	ld hl,argvtt	;test argv
	push hl
	ld hl,2		;test argc
	push hl
	ld hl,0		;dummy return address
	push hl
	jp  tpa

argvtt:	dw argv0
	dw argv1
	dw argv2

argv0:	db 'clink',0
argv1:	db 't',0
argv2:	db '-s',0
	ENDIF

	IF TESTING OR TESTING3
printf: ex (sp),hl		;save HL on stack, get string pointer into HL
	push de		;save DE
	ex de,hl		;put string pointer into DE
	call pstg	; print the string
	ex de,hl		;put return address from DE into HL
	push hl
	call crlf	; and follow with cr-lf
	pop hl		;get back return address
	pop de		; restore DE
	ex (sp),hl		;put return address back on stack, get back HL	
	ret		
	ENDIF		;end of test sequence


;
; Return Z true if char is space or tab:
;

twhite:	cp ' '
	ret z
	cp tab
	ret

wsp:	equ getfn

ascb:	ds 4	;ascii buffer used for hex-to-decimal conversion
	db 0

curtop:	ds 2	;pointer to top of user memory

zsysf:	ds 2	;z systems flag

donef:	ds 1	;tells if all linked up yet
decl:	ds 1	;disk from which to get deff and deff2
cdp:	ds 2	;points to next free space in code
cdn:	ds 2
enst:	ds 2	;used to pass disk addr of function to "rdfun"
enend:	ds 2	;used to pass last disk addr of function + 1 to "rdfun"
smsf:	ds 2	;external data block size
quietf:	ds 1	;true if we don't want to complain if can't open file


fcnt:	ds 1	;function count...holds current function number
fcnt2:	ds 1
gotf:	ds 1	;set true when calling "entt1" w/ just-loaded function
statf:	ds 1	;true if -s option given
wflg:	ds 1	;true if -w option given
segf:	ds 1	;true if segment being linked
zflag:	ds 1	;true if -z option given
tmpnr:	ds 1	;workspace used by "setdat" routine
fngtt:	ds 2
refv:	ds 2
fadr:	ds 2
bufp:	ds 2
buffp:	ds 2	;used by gsyms routine as buffer pointer

cline:	ds 140	;elongated for v1.32
sname:	ds 15
cptr:	ds 2
mflag:	ds 1
dflag:	ds 1	;true if we've scanned DEFF.CRL under CP/M, or if we've
		;scanned all deff?.crl files under MARC

taddr:	ds 2	;address of top of memory available to running program
taddrf:	ds 1
eflag:	ds 1	;if external address supplied
eaddr:	ds 2	;if eflag true: extern. addr.
extadd:	ds 2	; final external address.
wrsmf:	ds 1	;true if writing symbols to disk during outch calls
rdngsm:	ds 1	;true if reading a symbol from a file
nsmbs:	ds 2
tbase:	ds 2
fflag:	ds 1	;true when loading all functions; else scanning for needed ones
runsat:	ds 2	;load address
savcdp:	ds 2	;save cdp here while reading in symbols
debugf:	ds 1	;true if running file instead of writing to disk
argptr:	ds 2	;points to arg list text if used with -d option
fncodb:	ds 2	;used in new mod to do reference fixing on the fly
doresv:	ds 2
fargb:	ds 2
savnam:	ds 2	;used to save function name pointers for error printout
tb1siz:	ds 2
cda:	ds 2
tb1end:	ds 2
tab2:	ds 512
direc:	ds 512

	IF CPM
d2flag:	ds 1	;true if we've scanned DEFF2.CRL
d3flag:	ds 1	;true if we've scanned DEFF3.CRL
hflag:	ds 1	;true if Leo want's lhld 4206 instead of 0006
tbp:	ds 2
ccpok:	ds 1
spsav:	ds 2
nflag:	ds 1	;true if "-n" for noboot given
curusr:	ds 1	;current user area number
savdrv:	ds 1	;saved drive number when temporrily gone elsewhere
search:	ds 1	;true to search current drive/user area for file, then default
	ENDIF

	IF MARC
argc:	ds 1
argv:	ds 2
marcfd:	ds 1
maxmd:	ds 1	;true if maxmem call done yet
iflag:	ds 1	;true if image mode output file wanted; else load format file
btsav:	ds 1	;scratch used by writld routine
endtst:	ds 1
datap:	ds 2
runsav:	ds 2
oflag:	ds 1	;true if -o given
noffst:	ds 2	;either 0 or 6, depending on whether -c option used
fcbs:	ds 40
fcbt:	ds 40
consfd:	ds 1	;1 if console output going to stdout, or 2 for stderr
dlast:	ds 1	;last deff?.crl file searched ('1', '2', ...), or 0 if none
	ENDIF

	ds 75
stack:	equ $

tab1:	equ $		;reference table begins here

	IF LASM
	end
	ENDIF
