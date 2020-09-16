;
; CC1: the first pass of the C compiler...
; MARC-generalized  version
;
; 7/17/82: added -w to write debugger info file and insert restarts
; 7/18/82: changed -w to -k<n>  (for Kirkland), taking n as the restart
; 	   vector to use (1-7), defaults to 6.
; 8/22/82: Fixed mvtxt to not overflow stack in recursion
; 9/9/82:  Added search path mechandsm to cc2.com auto-load, made FF def.
;	   disk and user use "current" as default
; 10/6/82: added auto-".c" on main file feature
; 11/85:   Added -z option to use RST 1 - RST 5 for value-fetch optimization
; 12/85:   Added RED logic to write out PROGERRS.$$$ error file
; 
;

	IF NOT LASM AND NOT SLRMAC
	maclib cc
	ENDIF

 	jp cc1		
 
 	db cr,lf
 	db 'Copyright (c) 1982, 83, 84 by Leor Zolman'
 	db cr,lf,lf
 	db 'Please don''t rip me off.'
 	db cr,lf,lf,1ah
patch0:	db 0,0,0,0,0,0,0,0 		;space to expand message

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;	Configuration block area:
	;

defdsk:	db 0ffh		;default library disk drive
defusr: db 0ffh		;default library user area

defsub:	db 00h		;default disk to find submit file on
conpol:	db 1		;true to poll the console for interrupts
wboote:	db 0		;true to always do warm-boot on exit
;zenvf:	ds 1		;true if Z environment
;			;new for v1.51:
pstrip: db 1		;true to strip parity when reading source file

	IF ALPHA
nouser: db 1		;true to disable all user-area operations performed
	ENDIF		; by CC, for special kinds of systems that like it

	IF NOT ALPHA
nouser: db 0		;false to allow user area changes
	ENDIF

werrs:	db 0		;write errors flag, for RED interface

optim:	db 80h		;0: optimize for speed, use all long code sequences
			;b7 true: optimize for space, in general
			;b0-b6 true: use RST1-RST7 (respectively)
			; for -Z optimization through restart vectors

krst:	db 6		;default CDB restart vector

zenvf:	ds 1		;true if Z environment

	;
	; End Configuration Block
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

patch:	dw 0,0,0,0,0,0,0,0	;patch space
patch2:	dw 0,0,0,0,0,0,0,0
patch3: dw 0,0,0,0,0,0,0

	;
	;	Beginning of compiler code:
	;

cc1:
        ;OS_HIDEFROMPARENT
        ;ld e,6 ;textmode
        ;OS_SETGFX
        call initstdio
        
        ;shld zenvad ;TODO remove	;save Z environment pointer
	;ld hl,0		;save current SP for possible use in returning to CCP
	;add hl,sp
	;shld spsav
	;ld sp,stack	;set up private stack

	call ccinit	;perform general initializations

	IF CPM AND NOT ALPHA
	call chkusr	;check for user number on main filename
	ENDIF

	call comlin	;process command line options
	call readf	;read in file(s), strip comments
	call prep	;process #define lines
	call pitext	;print out intermediate text if specified
	call pass1	;convert keywords,constants,strings
	call lblpr	;process labels and references
	call passx	;proccess constant expressions
	call bst	;build symbol table
	call passc	;process control structure
	call fixt	;purge FF's and stuff from text
	call mkfnt	;make function name table
	call wst4db	;write symbol table for debugger
	call chopst	;chop off 1st 8 bytes of st entries
	call mvfnt	;lde func name table adj to text
	call errwrp	;wrap up error handling
	call usage	;print out memory usage diagnostic
	call writf	;write out file

	jp exit	;all done


;
; Static data area:
;

	IF CPM
;spsav:	ds 2	;save stack pointer for non-booting return
ccpok:	ds 1	;true if CCP still intact
erasub:	ds 1	;true if erasing submit files
curusr:	ds 1		;current disk (CP/M)
origusr: ds 1
curdsk:	ds 1		;current user area (CP/M)
origdsk: ds 1
cc2dsk:	ds 1	;default disk to search for cc2
cc2usr:	ds 1	;default user area to search for cc2
dodotc:	ds 1	;true to try ".C" if no ext given and file not found
	ENDIF

curtop:	ds 2	;end of availlable TPA memory
preflag:ds 1	;true when still pre-processing
pflag:	ds 1	;print intermediate text flag ("p" option)
sdisk:	ds 1	;disk # where source came from
chainf:	ds 1	;true if we want to chain to CC2
loadad:	ds 2	;load address
eflag:	ds 1	;true if -e option given
exaddr:	ds 2	;value given to -e option
cnflag:	ds 1	;true if comments nest
okflag:	ds 1	; "readm" routine success flag
mapucv:	ds 1	;no upper case mapping in "stcmp" routine flag

	IF CPM
cfcb:	 db 0,'CC2     COM',0,0,0,0
subfile: db 1,'$$$     SUB',0,0,0,0

redfcb:	 db 0,'PROGERRS$$$',0,0,0,0
	 ds 17	;rest of fcb for RED error file
redbuf:	ds 128	;text buffer for RED error file
redbp:	ds 2	;pointer into text buffer
errsin: ds 1	;true if RED output is active
nomore:	ds 1	;true if future red error output is disabled
	ENDIF

modstk:	ds (fnlen + 2) * (nestmax + 1)
modstp:	ds 2	;pointer to currently active filename
modstc:	ds 1	;counter

casoff:	ds 1	;case overflow flag
esctmp:	ds 1
errad:	ds 2
eradf:	ds 1
scc:	ds 1	;string character count for psstg
stgcct:	ds 2	;points to where length byte goes for psstg
nlflag:	ds 2	;used in the pitext routine  for something or other
nltmp2:	ds 1
nltmp:	ds 2
modaf:	ds 1	;whether to modify st ptrs after wrapup or not
inadsv:	ds 2	;some more kludgery to allow multiple struct
		;elements to have same name in separate structs
stsiz:	ds 2
coda:	ds 2
fndtmp:	ds 1
mvtmp:	ds 1
errf:	ds 1
cmntf:	ds 1
udiag:	ds 1
stgf:	ds 1 
csf:	ds 1
sf:	ds 1
flev:	ds 1
fixfl:	ds 1
pdfd:	ds 1  ;previously declared func. def. flag
pdfdno:	ds 2	;symbol # for above
stor:	ds 2
strsz:	ds 2
mxsiz:	ds 2
tmplf:	ds 2
tmpbs:	ds 1
tmpsu:	ds 1
fbufp:	ds 2
opena:	ds 2
stno:	ds 2
fntp:	ds 2
fnts:	ds 2
fnc:	ds 2
lbln:	ds 2
eofad:	ds 2
meofad:	ds 2	;max eofad for elbowroom announcement
nlcnt:	ds 2
nlcnts:	ds 2	;save nlcnt when in #include file
ptfnf:	ds 1
type:	ds 1
stelf:	ds 1
forml:	ds 1
what:	ds 1
lind:	ds 1
clev:	ds 1
clevb:	ds 1
clevt:	ds 1
unflg:	ds 1
newid:	ds 1	;used for flagging undefined structure identifiers
adrs:	ds 2
size:	ds 2
dmsiz:	ds 2
tempd:	ds 2
tempdp:	ds 2
tmpa:	ds 2
savsta:	ds 2
tmpfr:	ds 2
fndad:	ds 2
extsa:	ds 2
stp:	ds 2
mtpln:	ds 2
symno:	ds 2
funcf:	ds 2
z80f:	ds 1
frmrf:	ds 1
esadr:	ds 2
lcnt:	ds 1	;used by parameterized #define preprocessor 
operad:	ds 2	;where option error begins
odisk:	ds 1	;output disk designation
semiok:	ds 1
nlfnd:	ds 1	;used by decf routine
kflg:	ds 1	;true if "-k" option given to write CDB file
signm:	ds 1	;used by "passx", put here just to be safe...
cpyend:	ds 2	;parameter to "copy" routine showing end address
bcnstf:	ds 1	; (readf, pass1) true when bad char constants must
		; 		 be flagged as an error

ascb:	ds 4
	db ': ',0

	ds 10
;stkchk:	ds 2	;if this ever gets clobbered, stack has overflowed

;	ds 320
;stack:	equ $

stg2:	db 'Close error+'
stg3:	db 'File output error; dir or disk full?+'
stgoer:	db '": option error+'
stg10:	db 'Encountered EOF unexpectedly',cr,lf
	db ' (check curly-brace balance)+'
stg12:	db 'Unmatched right brace+'
stg14:	db 'Undeclared identifier: ',0
stg15:	db 'Illegal external statement+'
stg16:	db 'Bad declaration syntax+'
stg17:	db 'Missing legal identifier+'
stg19:	db 'Function definition not external+'
stg20:	db 'Need explicit dimension size+'
stg21:	db 'Too many dimensions+'
stg22:	db 'Bad dimension value+'
stg23:	db 'Bad parameter list element+'
stg24:	db 'Redeclaration of: ',0
stg25:	db 'Missing semicolon+'
stg27:	db 'Expecting "{" in struct or union def+'
stg28:	db 'Illegal structure or union id+'
stgbft:	db 'Bad function type+'
stg28a:	db 'Undefined structure id+'
stgdu:	db '*Unnamed'
stg40:	db 'Expecting "("+'
stgbp:	db 'Unmatched left parenthesis+'

stgstk:	db 'Stack Overflow: '			; keep these two together
stgov:	db 'Sorry; out of memory+'

stgtc:	db 'I''m totally confused. '
	db 'Check your control structure!+'
stgom:	db 'Out of symbol table space; specify more...+'
stgtmf:	db 'Too many functions (63 max)',0
stgmq:	db 'String too long (or missing quote)+'
stgbsd:	db 'Attribute mismatch from previous declaration+'
stgelb:	db 'elbowroom',cr,lf,0;cr,0
stgunu:	db 'unused',cr,lf,0;cr,0
oshit:	db 'Internal Error...Call BDS+'

stgcce:	db cr,lf
	IF CPM
	db 'Can''t find CC2.COM; writing CCI file to disk'
	ENDIF
	db cr,lf,0

stgiep:	db 'Include @',0
stgilc:	db 'Illegal "{" encountered externally',0
stgtmi:	db 'Declaration too complex+'
stgbfd:	db 'Missing from formal parameter list: ',0
stgabo:	db 'Compilation aborted by ^C+'
stgeri:	db cr,lf,'RED error output initiated+',0

;
; passc error messages:
;

stgc1:	db 'Mismatched control structure',cr,lf,0
stgc2:	db 'Expecting "while"',cr,lf,0
stgc7:	db 'Illegal break or continue',cr,lf,0
stgc6:	db 'Bad "for" syntax',cr,lf,0
stgc8:	db 'Expecting "{" in switch statement',cr,lf,0
stgc9:	db 'Bad "case" constant',cr,lf,0
stgc10:	db 'Illegal statement',cr,lf,0
stgcof:	db 'Too many cases (200 max per switch)',cr,lf,0
stgddf:	db 'Can''t have more than one `default:''',cr,lf,0


;
; Initialize compiler flags and variables:
;

ccinit:	call zsetup

	lhld protm ;0 there!!! who must write there???
	shld curtop

	lhld errbyt
	ld (hl),0		;no error by default

	ld hl,stg0	;print sign-on message
	call pstgco	;print to console only

	;ld c,gdisk	;get current disk and user area
	;call bdos
         xor a ;TODO getpath
	sta curdsk	;store current disk
	sta origdsk	;and save as original disk upon invokation of CC

	IF NOT ALPHA
	;ld c,sguser	;set/get user area
	;ld e,0ffh
	;lda nouser
	;or a
	;call z, bdos
         xor a
	sta curusr	;store current user area
	sta origusr	;and save as original user area upon invoking CC
	ENDIF

	lda defdsk	;set cc2 search path
	inc a		;first set disk
	sta cc2dsk
	lda defusr
	cp 0ffh	;and user area. default to current?
	jp nz,cc2
	lda curusr	;if so, set to current user area
cc2:	sta cc2usr
	lda defsub
	inc a		;if FF, make current; else, make explicit disk code
	jp nz,cc3		;if not set to find submit files on current disk, don't
	lda curdsk	;else set current disk as explicit disk byte in SUB.$$$
	inc a		;     fcb in case we abort in the middle of file read
cc3:	sta subfile	;set disk to find $$$.SUB on

	lda pstrip	;does user want parity stripped on input file?
	or a
	jp nz,cc3a		;if so, do nothing (strips by default)

	IF IMPURE
	ld a,0		;IMPURE CODE: *** NOP ***
	sta stripp
	ld a,0b7h	;IMPURE CODE: *** or A  ***
	sta stripp+1	
	ENDIF

cc3a:
	IF CPM		;initialize some CP/M-only parameters
	lda fcb		;get source disk #
	sta sdisk	;save it
	sta odisk
	ld de,tbuff	;set tbuff explicitly, to facilitate debugging
	ld c,sdma	;of the 4200h version on my 0-based system
	call bdos
	ENDIF

	xor a		;initialize following flags to FALSE:
	sta kflg	;no debugger features by default
	sta eflag	;no -e option yet
	sta errf	;error ocurred flag
	sta eradf
	sta mapucv	;no-upper-case-mapping on string-compare flag
	sta pflag
	sta z80f	;false for 8080, true for Z80
	sta semiok
	sta nomore	;allow RED output for starters

	IF CPM
	sta cfcb
	sta erasub	;don't bother erasing SUBMIT files unless -x given
	sta errsin	;no RED error file active yet
	ENDIF

	inc a		;initialize following flags to TRUE:

	sta preflag
	sta chainf

	IF CPM
	sta cnflag	;assume comments nest for starters
	sta ccpok	;CCP intact at first under CP/M
	ENDIF

	ld a,2		;find out if we're on Z80 or 8080
	inc a
	jp pe,cc1z	;if on Z80,
	sta z80f	;will come here to set z80 flag.

cc1z:	ld hl,dfstsz	;default symbol table size
	shld stsiz
	ld hl,tpa	;default load address for generated code
	shld loadad
	ld hl,0a55ah	;for stack overflow check
	shld stkchk
	ld hl,0		;reset label counter
	shld lbln
	ret

	IF CPM AND NOT ALPHA
chkusr:
	ld de,fcb+1	;check to see if user area given on filename
	call gdec	;number?
	ret c		;if not, no problem
	ld a,(de)
	cp '/'		;user area prefix character?
	ret nz
	ld hl,stgnua	;can't give user area
	jp pstgab
	ENDIF

zsetup:	xor a
	sta zenvf	;not z environment by default
	ld hl,errdum
	shld errbyt	;dummy error byte by default
	ld a,1
	sta oktort	;ok to return to ccp, despite ccpok for now
	lhld zenvad ;TODO remove
	push hl
	ld de,1bh
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)		;get reflexive env addr from env
	pop hl		;original Z env value
	call cmphd	;save as reflexive address?
	jp nz,setp2a	;if not z system, set top of memory

	ld a,1
	sta zenvf	;Z system.
	push hl		;save env pointer
	ld de,3fh	;get potential ccp address
	add hl,de
	ld a,(hl) 
	inc hl
	ld h,(hl)
	ld l,a
	shld ccpad

	pop hl		;get env pointer

	push hl
	ld de,22h
	add hl,de
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a		;HL -> message buffer
	ld de,6		;get address of error byte
	add hl,de
	shld errbyt	;save the address
	pop hl

	ld de,8		;get type
	add hl,de
	ld a,(hl)
	sta envtyp
	
	and 80h		;b7 hi?
	lhld ccpad
	jp nz,setup3	;if so, use ccpad as ccp address
setp2a:	lhld ram+1	;else calculate the old way
	ld de,-1603h
	add hl,de

setup3:	xor a		;clear 'ccp volatile' flag
	sta ccpok	;and CCP INTACT flag
	ex de,hl		;put ccp address in DE
	ld hl,NEDOOSMEMTOP;lhld bdosp
	ld l,0		;zero out low-order byte
	call cmphd	;set Cy if [BASE+6,7] < CCP
	jp c,setup4	;if BASE+6 < CCP, use BASE+6 as end of prot mem
	ex de,hl		;else use CCP as end of prot. mem.
	ld a,1		;and set ccp volatile flag
	sta ccpok	;and set ccpok
	xor a		;NOT ok to return to ccp despite ccpok
	sta oktort
setup4:	shld protm
	ret


envtyp:	ds 1

;zenvf 		;is after wboote
zenvad:	ds 2	;address of Z3 environment block
ccpad:	ds 2 	;address of CCP for type 80h ZCPR3
protm:	ds 2	;start of protected memory
oktort:	ds 1	;ok to return to ccp despite ccpok flag?i
errbyt:	ds 2	;message buffer error byte address
errdum:	ds 1	;in case we're NOT under ZCPR3...


;
; Process command line options:
;

comlin:
	ld hl,st	;init symbol table free space pointer
	shld stp

	IF CPM
	;lda tbuff
	;add a,81h
	;ld l,a
	;ld h,tbuff/100h
	;ld (hl),0		;place 00 at end of command line
	ld de,tbuff;+1	;DE will be text pointer as we process
	;call igsp	;find source file name ;skip spaces in (de) (z=end of line, nz=text found)
        call fspac ;skip word in (de) (z=end of line, nz=text found)
	ld hl,stg1	;is it there?
	jp z,pstgab	;if not, error.
         ld (filenameaddr),de
	call fspac	;pass it, and any blanks after it.
	ENDIF

	IF CPM
cc11:	call igsp	;done processing line?
	ex de,hl
	shld operad	;save in case of error
	ex de,hl
	ENDIF

cc111:	ret z		;if so, go compile
	cp '-'		;dash?
	jp nz,operr	;if not, operand error
	inc de		;get option character
	ld a,(de)
	call mapuc	;convert to upper case
	inc de		;advance pointer past option character

cc12a:
	IF NOT ALPHA
	cp 'K'
	jp nz,cc12d
	call gdec	;get optional restart param
	jp nc,cc12b	;param given?
	lda krst	;if not, use default value
	jp cc12c	;if not, make it 6

cc12b:	cp 8
	jp nc,operr	;if >=8, error...else OK

cc12c:	sta kflg	;set debugging mode with restart value
	jp cc11

cc12d:	cp 'W'		;flip error file activity?
	jp nz,cc12
	lda werrs	;get write error flag
	xor 1		;logically invert
	sta werrs	;and save it back
	jp cc11
	ENDIF

cc12:	cp 'O'		;optimize for speed flag?
	jp nz,cc13
	xor a		;if so, no longer optimizing for space
	sta optim
	jp cc11

cc13:	cp 'Z'		;RST optimization flag?
	jp nz,cc13z

	ld a,(de)
	call legdd	;any parameters given?
	jp nc,cc13c	;if not, assume full optimization

	ld a,0bfh	;if not, assume we're using all RST locations
	sta optim
	jp cc11

cc13c:	ld b,a
	ld a,80h	;paramters supplied. Activate only
	sta optim	;those optimizations with supplied parameters
	ld a,b

cc13a:	or a		;check for range between 1-7
	jp z,operr
	cp 8
	jp nc,operr		

	ld b,a		;save rst code in B
	ld c,80h	;start walking bit at left, to be rotated into low bit
cc13b:	ld a,c		;shift bit left
	rlca
	ld c,a
	dec b	
	jp nz,cc13b	;loop till done shifting
	lda optim
	or c
	or 80h		;set space optimization bit, just in case
	sta optim
	inc de
	ld a,(de)		;any more vector specifications?
	call legdd
	jp nc,cc13a
	jp cc11	;else all done
	

cc13z:	cp 'P'		;print flag?
	jp nz,cc14
	sta pflag
	jp cc11

cc14:	cp 'R'		;symbol reservation option?
	jp nz,cc15
	call gdec	;get A=decimal number, 0-19
	cp 7
	jp c,operr	;if < 7 or >19 then error.
	cp 20
	jp nc,operr
	add a
	add a
	ld h,a
	ld l,0
	shld stsiz	;set symbol table size to nK
	jp cc11

cc15:
	IF CPM		
	cp 'A'		;auto-load option? (CP/M only)
	jp nz,cc16
	call gdskc	;get disk code, 1-16, or 0 for 'Z'
	sta cfcb	;set disk field of cc2 fcb
	sta chainf	;if 0, this prevents auto-chaining
	sta cc2dsk	;set default cc2 search disk
	call gdec	;user number given?
	jp c,cc11
	sta cc2usr	;if so, set default cc2 search search area
	jp cc11
	ENDIF

	IF CPM
cc16:	cp 'D'		;output disk specification?
	jp nz,cc16a	;if not, check for other options
	call gdskc	;get disk letter
	or a
	jp z,operr	;don't allow 'Z'
	sta odisk
	jp cc11
	ENDIF

	IF CPM
cc16a:	cp 'X'
	jp nz,cc17
	ld a,1
	sta erasub	;erase submit files
	jp cc11
	ENDIF

cc17:	
	IF NOT ALPHA
	cp 'M'		;load address specifier?
	jp nz,cc18
	call ghxarg	;get hex arg in HL
	jp c,operr
	shld loadad
	jp cc11
	ENDIF

cc18:	cp 'E'		;set external address?
	jp nz,cc19	;if not, illegal option
	sta eflag	;set external address specified flag
	call ghxarg	;get value
	jp c,operr
	shld exaddr
	jp cc11

cc19:	cp 'C'
	jp nz,operr

	IF CPM
	xor a
	ENDIF

	sta cnflag	;now comments don't nest under CPM, and DO
	jp cc11	;		nest under MARC


ghxarg:	call igsp	;yes. check for hex arg
	scf
	ret z		;return error (c set) if no arg
	call leghd
	ret c		;if not legal hex digit, error

	ld hl,0		;else prepare to accumulate value in HL
cc17a:	ld a,(de)
	call leghd
	jp nc,cc17b	;end of value text?
	xor a
	ret		;yes. clear carry and return value in HL	
cc17b:	add hl,hl		;no. multiply accumulator by 16
	add hl,hl
	add hl,hl
	add hl,hl
	ld c,a		;and add new digit
	ld b,0
	add hl,bc	
	inc de		;and go to next character
	jp cc17a

operr:	ld a,'"'
	call outch
	lhld operad
operr1:	ld a,(hl)
	or a
	jp z,operr2
	call outch
	inc hl
	ld a,l
	dec a
	cp e
	jp nz,operr1
operr2:	ld hl,stgoer	;op error string
	jp pstgab	


	IF CPM
gdskc:	call igsp
	jp z,operr
	sub 'A'-1
	cp 27
	jp nc,operr
	inc de		;bump past the char
	cp 26		;change 'Z' to zero
	ret nz
	xor a
	ret
	ENDIF

;skip spaces in (de) (z=end of line, nz=text found)
igsp:	ld a,(de)
	or a
	ret z
	call mapuc
	cp ' '
	ret nz
	inc de
	jp igsp

	IF CPM
;skip word in (de) (z=end of line, nz=text found)
fspac:	ld a,(de)
	or a
	ret z
	inc de
	cp ' '
	jp nz,fspac
	jp igsp
	ENDIF

gdec:	ld b,0
	call igsp
	call legdd
	ld a,0
	ret c	
gdec1:	ld a,(de)
	call legdd
	ld a,b
	ccf
	ret nc
	add a		;get A = 10 * B
	add a		;(*4)
	add a		;(*8)
	add b		;(*9)
	add b		;(*10)
	add c		;now add new digit value in C
	ld b,a		;put into B
	inc de
	jp gdec1	;and go for more

;
; Check for legal decimal digit, return Cy set if illegal,
; else the binary value of the digit in A:
;

legdd:	call mapuc
	sub '0'
	ld c,a
	ret c
	cp 10
	ccf	
	ret

;
; Check for legal hex digit:
;

leghd:	call legdd
	ret nc
	cp 11h
	ret c
	cp 17h
	ccf
	ret c
	sub 7
	ret			


usage:	ld hl,ascb+4
	ld (hl),'K'

	IF CPM
	ld hl,NEDOOSMEMTOP;lhld bdosp	;get pointer to top of memory
	ld l,0
	ENDIF

	ex de,hl		;into DE
	lhld meofad	;get highest addr used
	call cmh	;negate
	add hl,de		;and add to top of mem to give free ram
	ld a,h		;divide by 1K
	rra
	rra
	and 3fh
	ld l,a
	ld h,0
	dec hl

	xor a
	call prhcs	;print out
	ld hl,stgelb	;"elbowroom"
	lda lbln
	and 0fh		;little hack here!
	jp nz,cc1b
	ld hl,stgunu	;"unused"
cc1b:	call pstg
	ret

; Wrap up error handling, exit if there were errors:

errwrp:	lda errsin	;error output initialized?
	or a
	jp z,errwr3	;if not, don't try to close RED output file

	ld e,1ah	;ascii end-of-file
	call redout
	lhld redbp
	ld a,l
	cp redbuf and 0ffh	;has buffer just been flushed?
	call nz,redwrt	;if not, write buffer one last time
	ld de,redfcb
	call close2	;close RED output buffer

errwr3:	lda errf	;if there were real errors (not just warnings)
	or a		;then exit
	jp nz,errab2
	inc a
	sta nomore	;no more RED output
	ret		;else return


		
;
; Set up environment for a pass through the text (DE becomes
; text pointer)
;

initps:	ld hl,0
	shld nlcnt

;	shld lbln		;arghh. WHY did this WORK for so LONG?
				;(after lblpr, mustn't reset lbln anymore)

	ld hl,modstk
	shld modstp
	xor a
	sta clev
	sta modstc	;at very top level
	lhld coda
	ex de,hl
	ret


;
;
; Passc: control structure processor:
; This pass preprocesses control statements (like while, do, 
; if...else, etc.) and twists them into a form much easier to digest
; by cc2. E.g., All the `case' statments are relded from a `switch'
; construct and a table of constants and `symbolic labels' is formed.
; If...else statments are turned into simple `if' statments (using some
; added braces and goto's...One may be able to get away from goto's
; in a C program, but it's a bit harder to avoid them at the compiler-
; design level!
;
; Note that at this point, all declarations have been purged from
; the text, leaving only the function definitions. If we ever finish
; up with a function and find something other than another function
; or EOF after it, somethings really screwed up...
;

passc:	call initps	;initialize general pass procecure variables
	ld hl,cntt	;init control table pointer (this is where
	shld cntp	; the "break" and "continue" labels are stored)
	ld hl,fbuf
	shld fbufp
	xor a
	sta clev
	dec de

pasc1:	inc de
pasc2:	call igsht	;done with text?
	jp nz,pasc3
	lda clev	;yes. at top level?
	or a
	ret z		;if so, OK

pasc2a:	ld hl,stg10	;==ERROR==
	jp fatal	;probably mismatched {}s

pasc3:	cp varcd	;a variable? (i.e., function definition?)
	jp z,pasc4

pasc3a:	call fsemi
	jp pasc1	

;	ld hl,stgtc	;if not, somethings screwy
;	jp fatal

pasc4:	inc de		;ok, we found a function
	inc de
	inc de
	call mtchp	;pass over the arg list
	call state	;process the body as a statment
	jp pasc2	;and go back for another function

;
; Here it is, the routine to process a statment...
;

state:	call ckabrt	;check for user typing control-C
	call chkstk	;and check for stack overflow

	call igsht
	jp z,pasc2a	;if expecting a statement and get EOF, error

	call cdtst	;if it starts with a code, ignore the code
	jp c,state0
	inc de		;ignore it, since its probably a label
	inc de		;code or something trivial.
	inc de
	jp state

state0:	inc de		;now, does it start with a `{'?
	cp lbrcd
	jp nz,state2

state1:	call igsht	;yes. do each statment inside the compound.
	cp rbrcd	;hit the `}' yet?
	inc de
	ret z		;if so, all done
	dec de		;else just another statment
	call state	
	jp state1	;and keep a 'goin

state2:	cp ifcd	;now we hit the real statements. IF?
	jp z,sif

	cp whlcd	;WHILE?
	jp z,swhl

	cp docd	;DO?
	jp z,sdo

	cp forcd	;FOR? 
	jp z,sfor

	cp swtcd	;SWITCH?
	jp z,sswt

	cp brkcd	;BREAK?
	jp z,sbrk

	cp cntcd	;CONTINUE?
	jp z,scnt

	cp rencd	;RETURN?
	jp z,state3

	cp gotcd	;GOTO?
	jp z,state3

	cp cascd	;CASE? if so, bad news!
	jp z,sterr	; Only the SWITCH processor should see these!

	cp elscd	;while only the IF processor should see ELSEs
	jp z,sterr

	cp defcd	;and only the SWITCH processor, again, should
	jp z,sterr	;see DEFAULTs

	dec de		;at this point we assume we have an expression
state3:	ld a,1		;statment (or a really screwy error.)
	sta eradf
	lhld nlcnt
	shld errad
	call fsemi	;this phase can ignore expression statements.
	xor a
	sta eradf
	inc de
	call igsht
	ret

sterr:	ld hl,stgc10	;seeing a CASE outside of a SWITCH, and other stuff
	jp fatal	;like that, are good enough reasons to abort.

;
; routine to pass over a statement, I guess because I need to
; look ahead sometimes to figure out what's going on. Geez,
; I can't remember what the hell I used this for...
;
; (In case you're wondering, these comments are being written about
; 11 months after the code. I just now got WORDMASTER going on my
; bee-YOU-tea-full H19 terminal, and need no longer get uptight over
; the chilling prospect of documenting 150K of source using ED...)
;

passt:	call igsht
	jp z,pasc2a
	call cdtst	;ignore labels and such
	jp c,past0
	inc de
	inc de
	inc de
	jp passt

past0:	cp lbrcd	;left brace?
	jp nz,past2
	inc de

past1:	call igsht
	cp rbrcd
	jp nz,past1a
	inc de
	call igsht
	ret

past1a:	call passt	;yes; pass statement
	jp past1

past2:	cp ifcd
	jp nz,past3	;if statement?
	inc de		;yes.
	call mtchp	;pass expr
	call passt	;pass statement
	cp elscd	;else?
	ret nz
	inc de		;yes. pass statement
	call passt
	ret

past3:	cp whlcd	;while?
	jp z,pst5b
	cp cascd	;case?
	jp z,past3a
	cp defcd	;default?
	jp nz,past4
past3a:	ld a,colon	;yes; find a colon
	call findc
	inc de		;pass it
	call passt	;pass next statement
	call igsht
	ret

past4:	cp docd
	jp nz,past5	;do statement?
	inc de		;yes.
	call passt	;pass statement
	cp whlcd	;while?
	jp z,pst4a
	ld hl,stgc2	;if not, error
	call perr


pst4a:	inc de		;pass expr
	call mtchp
	cp semi
	call nz,insrts	;if no semi, insert one automagically.
	inc de
	call igsht
	ret

past5:	cp forcd	;for statement?
	jp nz,past6
	sta semiok	;yes. allow semis in text for now.

pst5b:	inc de
	call mtchp	;pass expr(s)
	xor a
	sta semiok
	call passt	;pass statment
	ret

past6:	cp swtcd	;switch?
	jp z,pst5b
	or a		;no. EOF?
	jp z,pasc2a

	call fsemi	;no. go search for a semicolon
	inc de
	call igsht
	ret

;
; push continue-break data stack, adding two new labels:
;

cnpsh:	push de
	ex de,hl
	lhld cntp
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	inc de
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	shld cntp
	lda clev
	inc a
	sta clev
	ex de,hl
	dec hl
	pop de
	ret

;
; Pop continue-break data stack:
;

cnpop:	lhld cntp
	dec hl
	dec hl
	dec hl
	dec hl
	shld cntp
	lda clev
	dec a
	sta clev
	ret

cklev:	lda clev
	or a
	ret nz
	ld hl,stgc7
	call perr
	pop hl
	jp sbrk3

;
; Define a symbolic label given in HL at current location in text:
;

insll:	ld a,-3 and 255
	call mvtxt
insls:	ld a,lblcd
	jp insr2

;
; Install a symbolic label REFERENCE to label in HL at
; current location in text:
;

inslr:	ld a,-3 and 255
	call mvtxt
insrs:	ld a,labrc

insr2:	ld (de),a
	inc de
	ld a,l
	ld (de),a
	inc de
	ld a,h
	ld (de),a
	inc de
	ret

;
; Install a new label definition at current location in text:
;

lblni:	call glbl
	jp insll

;
; Install a new label reference at current place in text:
;

lblri:	call glbl
	jp inslr

;
; Get a new label value in HL:
;

glbl:	lhld lbln
	inc hl
	shld lbln
	dec hl
	ret

;
; Process a "for" statement:
;

sfor:	dec de
	ld a,lbrcd	;left curly-brace to delimit entire for statement
	ld (de),a
	inc de
	call igsht
	cp open
	jp z,sfor2
	ld hl,stgc6
	call perr

sfor2:	ld a,0ffh
	ld (de),a
	call chsbp
	call passt
	ld a,-5 and 255
	call mvtxt
	ld a,whlcd
	ld (de),a
	inc de
	call glbl	;get lbl z (object of the goto later)
	push hl
	call insls
	call glbl	;get lbl x
	call cnpsh
	push hl		;push lbl x
	ld a,open
	ld (de),a
	inc de
	call igsht
	cp semi
	jp nz,sfor3
	ld a,-3 and 255
	call mvtxt
	ld a,concd
	ld (de),a
	inc de
	ld a,1
	ld (de),a
	inc de
	ld a,0
	ld (de),a
	inc de
	jp sfor4

sfor3:	call chsbp
	call fsemi
sfor4:	ld a,close
	ld (de),a
	inc de
	call glbl	;get lbl y
	ex (sp),hl		;HL = lbl x, stack = lbly
	push hl		;push lbl x
	push de
	ld a,negone
	call mvtxt
	ld a,open
	ld (de),a
	push de
	inc de
	lhld nlcnt
	shld nltmp
	call igsht
	cp close
	jp z,sfor4a
	pop de
	jp sfor4b
sfor4a:	ld a,-3 and 255
	call mvtxt
	ld a,concd
	ld (de),a
	inc de
	ld a,1
	ld (de),a
	inc de
	xor a
	ld (de),a
	pop de

sfor4b:	call mtchp
	lhld nlcnt
	push de
	ex de,hl
	lhld nltmp
	call cmh
	add hl,de
	pop de
	ld a,l
	sta nltmp2
sfor5:	pop hl
	push hl
	push hl
	call cmh
	add hl,de
	pop de
	shld tmplf
	lhld fbufp
	ld b,h
	ld c,l
	ex (sp),hl
	push hl
	lhld tmplf
	ld h,l

sfor6:	ld a,(de)
	ld (bc),a
	inc de
	inc bc
	dec l
	jp nz,sfor6
	push hl
	ld h,b
	ld l,c
	shld fbufp
	pop hl
	pop de
	ld a,lbrcd
	ld (de),a
	inc de
	ld a,h
	push af
	push af
	dec a
	call mvtxt
	lda nltmp2
	push af
	cpl
	inc a
	call mvtxt
	pop af
sf6a:	or a
	jp z,sf6b
	push af
	ld a,nlcd
	ld (de),a
	inc de
	pop af
	dec a
	jp sf6a

sf6b:	call state
	call cnpop
	pop af
	cpl
	sub 14
	call mvtxt
	ld a,semi
	ld (de),a
	inc de
	pop af
	pop hl
	ld b,h
	ld c,l
	shld fbufp
	pop hl		;get lbl x
	push af
	push bc
	call insls	;define lbl x here
	pop bc
	pop af
	ld h,a
sfor7:	ld a,(bc)		;now copy the saved increment portion
	cp nlcd	;back into the text
	jp nz,sfor7a	;but watch out for newlines
	dec de		;and especially FAKE newlines (a la Somos)
	ld a,(de)
	inc de		;if a newline found, make sure it isn't
	call cdtst	;just the operand of a 3-byte code
	ld a,(bc)
	jp nc,sfor7a	;if it is, leave it as it is
	ld a,0ffh	;it isn't, so turn it into a garbage space
sfor7a:	ld (de),a
	inc de
	inc bc
	dec h
	jp nz,sfor7
	ld a,semi
	ld (de),a
	inc de
	ld a,rbrcd
	ld (de),a
	inc de
	pop hl		;get lbl y
	ex (sp),hl
	ld a,gotcd	;put in the kludge "goto" to go with the "while"
	ld (de),a
	inc de
	call insrs
	ld a,semi
	ld (de),a
	inc de
	pop hl
	call insls
	ld a,rbrcd
	ld (de),a
	inc de
	ret

chsbp:	push de
	lhld nlcnt
	push hl
chsbp1:	call pascd
	cp semi
	jp z,chsok
	cp open
	jp z,chsbpp
	cp close
	jp nz,chsbp2
	pop hl
	shld nlcnt
	ld hl,stgc6
	jp perrab

chsok:	pop hl
	shld nlcnt
	pop de
	ret
chsbp2:	inc de
	jp chsbp1
chsbpp:	call mtchp
	jp chsbp1

;
; Process a "switch" statement:
;

sswt:	call mtchp
	push de
	lhld cntp
	push hl
	dec hl
	dec hl
	dec hl
	ld b,(hl)
	dec hl
	ld c,(hl)
	pop hl
	ld (hl),c
	inc hl
	ld (hl),b
	inc hl
	ex de,hl

	call glbl
	shld defp	;set "default" default label

	push af
	xor a
	sta defflg	;haven't encountered default: yet
	pop af

	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	shld cntp
	pop de
	lhld defp
	push hl
	push de
	cp lbrcd
	jp z,ssw0
	ld hl,stgc8
	call perr
	call fsemi
	pop hl
	pop hl
	ret

ssw0:	lhld nlcnt
	shld tmpnl
	xor a
	sta swtc
	sta casoff
	ld hl,swtt
	shld swtp
	ld hl,clev
	inc (hl)
	inc de

ssw0a:	call igsht
ssw1:	ld a,(de)
	cp lblcd
	jp nz,ssw1a
	inc de
	inc de
	inc de
	jp ssw0a

ssw1a:	cp cascd
	jp z,sscas
	cp defcd
	jp z,ssdef
	cp rbrcd
	jp z,ssdon
ssw2:	call passt
	jp ssw1

sscas:	inc de
	push de
	call pasff
	cp concd
	jp z,ccas2
	pop de
	ld hl,stgc9
ccas1:	call perr
	jp ssw2

ccas2:	inc de
	lhld swtp
	ld a,(de)
	ld (hl),a
	inc de
	inc hl
	ld a,(de)
	ld (hl),a
	inc hl
	inc de
pasloop:
	ld b,c
	call pasff
	push af
	ld a,b
	add c
	ld c,a
	pop af
	cp nlcd
	jp nz,ccas2a
	ld a,c
	or 80h
	ld c,a
	inc de
	jp pasloop
ccas2a:
	cp colon
	jp z,ccas3

ccas4:	ld hl,stgc9
	jp ccas1

ccas3:	ex de,hl
	call glbl
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	lda casoff
	or a
	jp nz,ccas3a
	shld swtp
ccas3a:	ex de,hl
	pop de
	dec de
	ld a,c
	add a,2
	jp p,ccas3c
	and 7fh
	ld c,a
	ld a,nlcd
	ld (de),a
	inc de
	ld a,c
ccas3c:	call mvtxt
	call insls
	lda casoff
	or a
	jp nz,ccas3b
	ld hl,swtc
	inc (hl)
	ld a,(hl)
	cp 201
	jp c,ccas3b
	sta casoff
	dec (hl)
	ld hl,stgcof
	call perr
ccas3b:	jp ssw0a

pasff:	ld c,0
pasff1:	ld a,(de)
	cp 0ffh
	ret nz
	inc c
	inc de
	jp pasff1

ssdef:	push de
	inc de
	call pasff
	cp colon
	pop de
	jp nz,ccas4
	ld a,2
	add c
	call mvtxt
	call lblni
	shld defp
	lda defflg	;default previously defined?
	or a		;set NZ if so
	ld a,1
	sta defflg	;it is now, anyway

	ld hl,stgddf	;duplicate default message
	call nz,perr	;if default previously defined, bitch
	jp ssw0a


ssdon:	pop de
	lda swtc
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	push hl
	inc hl
	inc hl
	inc hl
	inc hl
	call bexp
	ld a,swtbc
	ld (de),a
	inc de
	lda swtc
	ld (de),a
	inc de
	ld hl,swtt
	pop bc
ssdn1:	ld a,b
	or c
	jp z,ssdn2
	ld a,(hl)
	ld (de),a
	inc de
	inc hl
	dec bc
	jp ssdn1

ssdn2:	lhld defp
	ld a,l
	ld (de),a
	inc de
	ld a,h
	ld (de),a
	inc de
	lhld tmpnl
	shld nlcnt
	call state
	pop hl
	call insll
	call cnpop
	ret

;
; Process IF statement:
;

sif:	call mtchp
	call state
	call igsht
	cp elscd
	ret nz
	inc de
	call state
	ret

;
; Process a "while" statement:
;

swhl:	call lblni
	push hl
	call cnpsh
	call mtchp
	call glbl
	push hl
	call state
	pop hl
	ex (sp),hl
	ld a,-5 and 255
	call mvtxt	;insert a forced "goto" to before the condition
	ld a,gotcd	;test, so that things don't get messed up when
	ld (de),a		;single-statement control structure is nested in
	inc de		;a very peculiar way.
	call insrs
	ld a,semi
	ld (de),a
	inc de
	pop hl
	call insll
	call cnpop
	ret

;
; Process "do" statement:
;

sdo:	call lblni
	inc hl
	call cnpsh
	push hl
	inc hl
	inc hl
	shld lbln
	call state
	call igsht
	cp whlcd
	jp z,sdo2
	ld hl,stgc2
	call perr
sdo2:	inc de
	pop hl
	call insll
	call mtchp
	push hl
	call esemi
	inc de
	pop hl
	inc hl
	call insll
	call cnpop
	ret

;
; Process "break" statement:
;

sbrk:	call cklev
	dec de
	ld a,gotcd
	ld (de),a
	inc de
	lhld cntp

sbrk2:	dec hl
	ld a,(hl)
	dec hl
	ld l,(hl)
	ld h,a
	call inslr

sbrk3:	lhld nlcnt
	shld esadr
	call esemi
	inc de
	call igsht
	ret

;
; Process "continue" statement:
;

scnt:	call cklev
	dec de
	ld a,gotcd
	ld (de),a
	inc de
	lhld cntp
	dec hl
	dec hl
	jp sbrk2


	IF LASM
	link ccb
	ENDIF
