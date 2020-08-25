	
;
; clinka.asm:
;
; BDS C Linker 3/86
;
; Copyright (c) 1980, 1981, 1982, 1986  by Leor Zolman, BD Software, Inc.
;
; Added -f option 4/15/81: forces loading all functions in next crl file
; Added -n option 9/9/82: activates NOBOOT mechandsm in COM file
; Added defdsk/defusr mechandsm to library file searches 9/12/82
; Added -z option to inhibit clearing of externals 11/15/82
; 

; MARC-specific features:
;   Gets deff.crl, deff2.crl and c.ccall c,from /libC unless -c is given
;   Added -i option to produce absolute image under MARC instead of default
; 	   load file formatted output.
;   Added -m option for MARC: makes c.ccall c,do a "mexmem" call before setting SP
;	Changed -m to cause NON-maxmem. I.e., replaced "call marc" with "nop"s.


 	;org tpa

	jp clink

;
; Configuration block:
;
	if not PREREL
defdsk:	db 0ffh		;default disk for library files (0=A, etc., FF=current)
defusr:	db 0ffh		;default user area for lib files, FF = current
	endif

	if PREREL
defdsk:	db 0ffh
defusr:	db 0ffh
	endif

defsub:	db 0		;default submit file on A: for distribution version
conpol:	db 1		;true to poll for console interrupts
wboote:	db 0		;true to perform warm-boot on exit
pstrip: db 1		;(dummy in CLINK:) parity strip
nouser:	db 0		;true to disable usage of set user area calls

;
;end configuration block
;

patch:	ds 19		;reserved for future expansion (adjust when adding
			;		bytes above)

clink:
        OS_HIDEFROMPARENT
        ld e,6 ;textmode
        OS_SETGFX
        
	;shld zenvad	;save Z environment pointer (if in HL)
	;ld hl,0		;save system SP
	;add hl,sp
	;shld spsav	;save system SP
	ld sp,0;stack	;set up own stack
	;call zsetup

	lhld errbyt
	ld (hl),0		;no error by default

	call linit	;initialize linker

	ld de,stg0	;print opening message
	call pstg

	xor a
	sta zsysf	;not zsystems, by default

	call comlin	;process immediate command line options

	IF CPM
	lda defdsk	;set default disk for library files
	inc a
	sta deffs
	sta deff2s
	sta deff3s
	sta ccc
	ENDIF


	ld de,tab1	;set code area pointer to
	lhld tb1siz
	push hl		;save tab1 size
	add hl,de
	dec hl
	shld tb1end	;save addr of end of tab1
	ld de,100	;leave some space in case of
	add hl,de		; tab1 overflow
	shld cda
	shld cdp

	ld hl,tab1
	pop bc		;get tab1 size
c4:	ld (hl),0		;clear tab1
	inc hl
	dec bc
	ld a,b
	or c
	jp nz,c4		;if not, keep looping

	IF TESTING3	;print out contents of fcbs
	push af
	call printf
	  db 'before reading c.ccc, fcbs is: ',0
	push hl
	ld hl,fcbs
	call pfnamu
	pop hl
	call crlf
	pop af
	ENDIF

	IF CPM
	call setdu	;set up default library file user areas
	ENDIF

	call readc	;read in c.ccc (if not a segment)

	IF ZSYS ;had no endif!!!
	lhld cda	;check load address for consistency
	ld de,0bh	;offset for load addr in header
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)		;DE now = load addr from header
	lhld runsat
	call cmphd
	jp z,c400
	
	ld de,stglde
	call pstg
	jp abort


c400:

;	IF CPM
	;lda curusr	;go back to current user area
	;ld e,a
	;ld c,sguser
	;lda nouser
	;or a
	;IF NOT ALPHA
	;call z,bdos
	;ENDIF
	;ENDIF

	ENDIF

	IF MARC
	ld hl,fcbt	;put crl extension on main filename
	push hl
	call scrl
	pop hl
	ENDIF

c40:
	IF TESTING3	;print out contents of fcbs
	push af
	call printf
	  db 'before reading in main file, fcbs is: ',0
	push hl
	ld hl,fcbs
	call pfnamu
	pop hl
	call crlf
	pop af
	ENDIF

;TODO options before filename?
        ld de,cline
        ld hl,fcb+1
        OS_PARSEFNAME

	call gnfl	;open main file and read in directory
	jp c,abort	;abort if can't find it

	IF TESTING
	call printf
	   db 'just successfully opened main file',0
	ENDIF

	IF CPM
	ld a,4
	sta nr
	call reads	;get external data area size and exaddr parameters
	ENDIF

	IF NOT CPM
	ld hl,tbuff
	ld de,10
	call reads
	ENDIF

	lhld tbuff+3	;get external data size.
	shld smsf

	lda tbuff	;was explicit external area given?
	or a
	jp z,c4a		;if not, skip setting eaddr
	sta eflag	;if so, tell that we have an explicit address
	lhld tbuff+1	;and copy the passed external address into eaddr
	shld eaddr

c4a:	ld hl,stgm	;read in "main" function
	call ft2	;is it there?
	jp nc,link2

	ld hl,stgmn	;try long version also
	call ft2
	jp nc,link2

	ld de,stg6	;no. can't link.
c2:	call pstg	;print error message

	IF MARC
	ld hl,fcbt
	ENDIF

	call pfnamu	;print file in which error occurred
	jp abort	;and abort

link2:	ld a,255	;initialize function number to -1
	sta fcnt
	ld hl,stgmn

	ld a,1
	sta gotf

	call entt1	;enter "main" function in table

	call pre	;read it in

	IF TESTING
	call printf
	   db 'returned from ''pre'' call for main function...',0
	ENDIF

link3:	call gtfns	;get all we can from current CRL file

link4:
;	IF CPM
	ld a,1
	sta search	;search default path unless otherwise set by getfn

	;ld c,sguser	;set user area back to current
	;lda curusr
	;ld e,a
	;lda nouser
	;or a
	;IF NOT ALPHA
	;call z,bdos
	;ENDIF

	;lda savdrv	;any drive number saved?
	;or a
	;jp z,link5
	;dec a		;if so, change back to it
	;ld e,a
	;ld c,select
	;call bdos	
	;xor a
	;sta savdrv	;and clear saved drive byte
;	ENDIF

link5:	call fungt	;are there any functions missing?
	jp c,linkd	;if not, all done

	call getfn	;else get name of new CRL file to search
	
	IF MARC
	ld hl,fcbt	;get pointer to the just-gotten crl filename
	ENDIF

	call gnfl	;open it and read in directory

	jp nc,link3	;if opened OK, go read in some functions...

;
; At this point, all files on the command line and all default
; library files have been loaded...
;

	IF MARC		;under MARC, set dflag to indicate that all
	ld a,1		;deff?.crl files have been searched at least once.
	sta dflag
	ENDIF

	jp link4	;go see if there's more linking to do.


linkd:	ld a,1
	sta donef	;all done. scan rest of command line
	lda mflag	;if it hasn't been scanned through
	or a		;already...
	call nz,getfn
	call reslv	;resolve function references

	call getcdf2	;get default external address
	push hl		;save in C.Ccall c,for use by "codend()" function
	lhld cda
	ld de,codend
	add hl,de
	pop de

	lda segf	;if segment, don't write into code!
	or a
	jp nz,linkd0

	ld (hl),e
	inc hl
	ld (hl),d

linkd0:	ex de,hl

	lda eflag	;-e option specified?
	or a
	jp z,linkd1
	lhld eaddr	;yes. get the value given in -e option instead
linkd1:	push hl		;save as external starting address in C.CCC
	lhld cda	; for run-time use.
	ld de,extrns
	add hl,de
	pop de

	lda segf	;if segment, don't write into code!
	or a
	jp nz,lnkd1a

	ld (hl),e
	inc hl
	ld (hl),d

lnkd1a:	ex de,hl	

	shld extadd
	ex de,hl
	lhld smsf	;get size of external area
	add hl,de		;add to start of external area
	push hl		;and store where it'll be available to the
	lhld cda	;endext library routine
	ld de,freram
	add hl,de
	pop de

	lda segf	;if segment, don't write into code!
	or a
	jp nz,lnkd1b

	ld (hl),e
	inc hl
	ld (hl),d

lnkd1b:
	lda zflag	;-z option given?
	or a
	jp z,skip1

	lhld cda	;if so, disable the external clearing subroutine
	ld de,clrex	;by changing the first byte of the appropriate
	add hl,de		;jump vector from C3 into C9.
	ld (hl),0c9h

skip1:	
	lda segf	;if segment, don't do rest of this kludgery
	or a
	jp nz,linkf

	lhld cda	;get ptr to startup code in HL

	IF ZSYS
	ld de,lxiloc
	add hl,de		
	ENDIF
	
	lda taddrf	; -t option given?	
	or a
	jp nz,linke

        if 1==0
        
	lda nflag	;noboot option given?
	or a
	jp z,linkd2	;if not, go handle normally

; Configure for NOBOOT:

	IF ZSYS
	push hl
	lhld	cda
	ld de,noboot
	add hl,de
	ld (hl),1		;set noboot flag in runtime
	pop hl
	jp linkf
	ENDIF

	IF NOT ZSYS
	ld (hl),0c3h
	inc hl
	ld (hl),(snobsp and 255)	;low byte of snobsp address
	inc hl
	ld (hl),(snobsp / 255)	;high byte of snobsp

	ld de,8		;point HL at nobret jump op
	add hl,de
	ld (hl),(nobret and 255)	;low byte of nobret address
	inc hl
	ld (hl),(nobret / 255)	;high byte of nobret address

	lhld curtop		;get top of available memory
	shld taddr
	jp linkf
	ENDIF

linkd2:			;no -n given.
        endif

	;ld (hl),2ah	;no. generate initial "lhld ram+6, ld sp,hl"
	;inc hl

	;ld de,bdosp	;at run time, ram+6 points to base of bdos
	;ld (hl),e
	;inc hl
	;ld (hl),d
	;inc hl
	;ld (hl),0f9h	; ld sp,hl to set SP to top of TPA
	jp linkf

linke:
	ex de,hl		;save code loc in DE
	lhld taddr	;if -t option given, leave the "ld sp, stack"
	ex de,hl		; instruction there, and insert given value.

	inc hl		;pass the ld sp op

	ld (hl),e		;store value
	inc hl
	ld (hl),d

linkf:
	IF ZSYS		;handle setup of Z3 Header:
	lhld	runsat
	ex de,hl
	ld hl,tpa
	call cmphd	;standard load address?
	jp z,linkf2	;if so, no problem

	push de		;save runsat address

	lhld cda	;make type 3 header
	ld (hl),0c7h	;RST 0, so won't crash vandlla CP/M

	ld de,8		;offset to Z type
	add hl,de
	ld (hl),3		;make type 3

	inc hl
	inc hl
	inc hl		;point to load addr

	pop de		;get back runsat address
	ld (hl),e		;store runsat address in header
	inc hl
	ld (hl),d
	ENDIF

linkf2:
	call pstat	;print out stats

	ld de,stgok	;print completion message
	call pstg	;and free-ram diagnostic

	ld hl,NEDOOSMEMTOP;lhld bdosp	;protected memory highest available tpa addr
	ld l,0

	ex de,hl
	lhld cdp
	call cmh
	add hl,de
	ld a,h
	rra
	rra
	and 3fh
	ld l,a
	ld h,0
	dec hl
	call prhld
	ld de,stglo
	call pstg

	IF TESTING3	;print out contents of fcbs
	push af
	call printf
	  db 'right before calling writf, fcbs is: ',0
	push hl
	ld hl,fcbs
	call pfnamu
	pop hl
	call crlf
	pop af
	ENDIF

	IF MARC
	call crlf
	ld a,2
	sta consfd	;route write error messages to stderr
	ENDIF

	call writf	;write out file or execute directly

	IF CPM
exit:	QUIT ;lda wboote	;need to do warm boot?
	;or a
	;jp nz,ram		;if so, go do it
	;lhld spsav	;put saved CCP stack pointer in SP
	;ld sp,hl
	;lda ccpok	;CCP still intact?
	;or a
	;ret nz		;if so, return
	;lda oktort	;ok to return despite ccpok being false?
	;or a
	;ret nz		;if so, return
	;jp ram		;otherwise warm-boot

subfile: db 1,'$$$     SUB',0,0,0,0
	ENDIF

	IF MARC
	ld hl,0		;return code: A OK
exit:	ld c,m$exit
	jp msys

ferror:	ld c,m$error
	call msys
	ld hl,-1
	jp exit

putext:	ld a,(hl)
	or a
	jp z,putxt2
	inc hl
	jp putext

putxt2:	pop de		;get pointer to extension to be put on
putxt3:	ld a,(de)
	ld (hl),a
	inc hl
	inc de
	or a
	jp nz,putxt3	;copy to (HL) until zero encountered
	ex de,hl		;then jump to byte after the zero byte to return
	pchl	
	ENDIF

        if 1==0
;
; Set up ZCPR3 environment:
;
zsetup:	xor a
	sta zenvf
	inc a		;ok to return, by default 
	sta oktort

	ld hl,errdum
	shld errbyt

	lhld zenvad
	push hl

	ld de,1bh
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)		;get reflexive env addr from env
	pop hl		;original Z env value
	call cmphd	;save as reflexive address?
	jp nz,setp2a	;if not Z system, go handle

	push hl
	ld de,22h	;point to message buffer address
	add hl,de
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a		;HL -> message buffer
	ld de,6		;get address of error byte
	add hl,de
	shld errbyt	;save the address
	pop hl

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
	ld de,8		;get type
	add hl,de
	ld a,(hl)
	sta envtyp
	
	and 80h		;b7 hi?
	lhld ccpad
	jp nz,setup3	;if so, use ccpad as ccp address
setp2a:	lhld 0001h	;else calculate the old way
	ld de,-1603h
	add hl,de

setup3:	xor a		;clear 'ccp volatile' flag
	sta ccpok	
	ex de,hl		;put ccp address in DE
	ld hl,NEDOOSMEMTOP;lhld bdosp
	ld l,0		;zero out low-order byte
	call cmphd	;set Cy if [BASE+6,7] < CCP
	jp c,setup4	;if BASE+6 < CCP, use BASE+6 as end of prot mem
	ex de,hl		;else use CCP as end of prot. mem.
	ld a,1		;and set ccp volatile flag
	sta ccpok
	xor a		;NOT ok to return by default!
	sta oktort	;  (go by value of ccpok)
setup4:	shld curtop
	ret

envtyp:	ds 1
zenvf:	ds 1	;true if running under ZCPR3
zenvad:	ds 2
ccpad:	ds 2 	;address of CCP for type 80h ZCPR3
        endif
oktort:	ds 1	;ok to return despite ccpok being false?
errbyt:	dw errdum	;address of Z3 error byte
errdum:	ds 1	;if CP/M, errbyt points here

	IF CPM
fcbt:	db 0
	db '        '
	db '   '
	db 0,0,0,0
	ENDIF

	IF CPM
fcbs:	db 0		;name of output file buffer
	db '        '	;8 filename spots
	db 'COM'
	db 0,0,0,0
	ENDIF


	IF NOT ALPHA AND NOT ZSYS
stg0:	db 'BD Software C Linker   v'
	ENDIF
	
	IF NOT ALPHA AND ZSYS
stg0:	db 'BD Software C Linker (for ZCPR3)  vZ'
	ENDIF

	IF ALPHA
stg0:	db 'BDS Alpha-C Linker   v'
	ENDIF

	IF NOT ZSYS
	db '1.'
	ENDIF

	db version

	IF ZSYS
	db '.'
	ENDIF

	db update

	IF PREREL
	db ' (pre-release)'
	ENDIF

	IF CPM
	db cr,lf,0
	ENDIF

	IF MARC
	db '  for MARC',lf,0
	ENDIF

stg2:	db 'Error reading: ',0

	IF CPM
stgnua:	db 'No user area prefix allowed on main filename',0
stg5:	db lf,'Dir full; ',cr
	ENDIF

	IF NOT CPM
stg5:	db lf,'Error creating output file: ',0
	ENDIF

stg3:	db lf,'Error writing: ',0
stg4:	db lf,'Can''t close: ',0
stg6:	db 'No main function in ',0
stgas:	db cr,lf,'Missing function(s):',cr,lf,0
stg7:	db lf,'Type the name of a CRL file '
	db 'to scan; ',cr,lf

	IF CPM
	db '<CR> to scan all DEFF files, '
	ENDIF

	IF NOT CPM
	db '<CR> to scan all deff?.crl files, '
	ENDIF

	IF CPM
	db '^Z-<CR> to abort: ',0
	ENDIF

	IF NOT CPM
	db 'or your ''quit'' char to abort: ',0
	ENDIF

stgm:	db 9dh
stgmn:	db 'MAI','N'+80h,0

	IF CPM
deffs:	db 0,'DEFF    CRL',0
deff2s:	db 0,'DEFF2   CRL',0
deff3s:	db 0,'DEFF3   CRL',0
ccc:	db 0,'C       CCC',0
	ENDIF

	IF NOT CPM
deffs:	db '/libC/deff0.crl',0
ccc:	db '/libC/c.ccc',0
	ENDIF

stg1:	db 'Can''t find ',0
stglca:	db 'Last code address: ',0
stgext:	db cr,lf,'Externals start at ',0
stgxt2:	db ' occupy ',0
stgxt3:	db 'bytes, last byte at ',0
stgtm:	db cr,lf, 'Top of memory: ',0
stgds:	db cr,lf, 'Stack space: ',0
stgabt:	db bell,'Link ABORTED',cr,lf,0


	IF CPM
stgdo:	db bell,cr,lf,'Warning! Externals extend into the BDOS!',cr,lf,0
	ENDIF

	IF MARC
stgdo:	db lf,'Warning! Externals extend into system memory!',lf,0
	ENDIF

	IF CPM
stgdo2:	db bell,lf,'Warning! Externals overlap code!',cr,lf,0
	ENDIF

	IF MARC
stgdo2:	db lf,'Warning! Externals overlap code!',lf,0
	ENDIF

stgom:	db 'Out of memory',0
stglo:	db 'K link space remaining',cr,0
stgok:	db 'Writing output...',cr,lf,0
stgserr: db 'Bad symbols',0
stgdeb:	db lf,'Executing:',cr,lf,0
stglde:	db 'Load Address does not match Z3 Header in Runtime Pkg',cr,lf,0
stgbop:	db 'Bad option: -',0
stgt1o:	db 'Ref table overflow',0
stgver:	db 'Missing arg to -'
stgdps:	db 'Symbol re-defined: ',0
stgdpf:	db 'Ignoring duplicate function: ',0
stgabo:	db '^C',cr,lf,0

	IF MARC
stgnof:	db 'Usage:  '

	db 'clink <main_crl_file> [-cmsvw]'
	db ' [-e <addr>] [-t <addr>] [-l <addr>]'
	db lf

	db tab,'[-o <new_name>] [-y <sym_name>]'
	db ' [<crl_file> [<crl_file>] ... ]'
	db 0
	ENDIF

opletr:	ds 1
	db 0

stgtmf:	db 'Sorry; 255 funcs max',0


;
; Initialize linker:
;

linit:	;ld c,sguser	;get current user area
	;ld e,0ffh
	;lda nouser
	;or a

	;IF NOT ALPHA
	;call z,bdos
	;ENDIF

	;IF ALPHA
	;nop
	;nop
	;nop
	;ENDIF

	;sta curusr	;save current user area number
	lda defsub
	inc a
	sta subfile

	xor a
	sta wrsmf	; "outch" not to write to SYM file

	IF MARC		;under marc, initialize message output fd
	ld a,1
	sta consfd	;route first msgs to stdout (1)
	ld hl,0
	shld noffst	;search /libC by default for deff*.crl & c.ccc

	ld c,m$memory	;get top of memory value before doing maxmem call
	call msys
	ex de,hl
	shld taddr	;taddr before maxmem call

	ld c,m$maxmem	;do a maxmem call
	call msys
	ld a,1
	sta maxmd	;note that we've done the maxmem call (once only)

	ld c,m$memory	;get top of memory AFTER maxmem call has been done
	call msys
	ex de,hl
	shld curtop	;and as physical top of memory for linkage
	ENDIF

	IF MARC		;if MARC version, get argc and argv:
	sta marcfd	;clear marcfd in case of usage diagnostic
	pop af		;skip return address

	pop hl		;get argc passed by MARC
	ld a,l		;set A = argc
	dec a
	ld de,stgnof	; complain and abort if no filename given
	jp z,stgab

	sta argc	;else save argc for later use

	pop hl		;get argv passed by MARC
	inc hl
	inc hl		;point argv to main filename pointer
	shld argv	;save pointer to main filename pointer

	ld a,(hl)		;indirect to get pointer to main filename
	inc hl
	ld h,(hl)
	ld l,a

	push hl		;save it on stack
	ld de,fcbt	;copy main filename to fcbt for use in reading
	call ldfn	;   in main crl file
	pop hl		;and also copy to fcbs for use in writing out file
	ld de,fcbs
	call ldfn
	ENDIF

	IF TESTING3	;print out contents of fcbs
	push af
	call printf
	  db 'after first setting fcbs, fcbs is: ',0
	push hl
	ld hl,fcbs
	call pfnamu
	pop hl
	call crlf
	pop af
	ENDIF


	IF CPM
	ld de,tbuff	;set DMA address
	ld c,sdma	;(helps me debug 4200h version
	call bdos	; on 0-based CP/M system)

	ld hl,fcb	;save filename argument
	ld de,fcbs
	call ldfn	;lde main filename to fcbs
	ld hl,fcbs+9	;and give it a COM extension by default
	ld (hl),'C'
	inc hl
	ld (hl),'O'
	inc hl
	ld (hl),'M'
	ENDIF

	xor a		;clear some flags:
	sta segf	;assume not a segment by default
	sta debugf	;don't immediately execute file
	sta statf	;default to no stats
	sta dflag	;haven't searched DEFF.CRL yet
	sta quietf	;report unfound files
	sta rdngsm	;not reading in symbols from disk
	sta taddrf	;no top of memory address given yet
	sta eflag	;no external data addr given yet
	sta donef	;all function references not resolved yet
	sta wflg	;controls writing of SYM file

	IF CPM
	sta zflag	;don't inhibit clearing of externals
	sta d2flag	;haven't searched DEFF2.CRL either
	sta d3flag	;haven't searched DEFF3.CRL either
	sta nflag	;no noboot option given yet
	sta hflag	;don't force lhld 4206 unless -h given
	sta savdrv	;no drive number currently saved
	ENDIF

	IF MARC
	sta dlast	;last DEFF?.CRL searched (0 for none)
	sta marcfd	;no file open yet
	sta iflag	;no image mode output file unless -i used
	sta oflag	;haven't seen -o yet
;	sta maxmd	;haven't done maxmem call yet
	ENDIF

	IF NOT FORCE
	sta fflag	;no forced loading of all funcs in crl file
	ENDIF

	inc a
	sta mflag	;more text to process in command line

	IF FORCE
	sta fflag	;force loading of all funcs in crl file
	ENDIF

	IF CPM
	lda fcb		;default disk to get CRL files from
	sta decl	; is disk where source file came from

	lhld curtop	;set protected memory address
	shld taddr
	ENDIF	

	ld hl,dt1siz	;set default tab1 size
	shld tb1siz

	ld hl,tpa	;default starting address
	shld runsat	; (alterable only if -l option used)
	ret


;
; Process immediate command line options:
;

comlin:
	IF CPM
	;ld hl,fcb+1	;see if user area given as part of filename
	;call gdec
	;jp c,clink0	;if not, OK
	;ld a,(hl)		;else, followed by slash?
	;cp '/'
	;jp nz,clink0	;if not, no problem
	;ld de,stgnua	;else abort with "no user number allowed" message
	;jp stgab

clink0:	ld hl,cline	;copy command line from tbuff to area at cline
	shld cptr	;under CP/M
	ld hl,tbuff
comlin_fspac:
	ld a,(hl)
        or a
	jr z,comlin_fspac_skip
	inc hl
	cp ' '
	jr nz,comlin_fspac
comlin_fspac_skip
        
	;ld b,(hl)
	;inc b
	;inc hl
	ld de,cline
c0:	;dec b
	;jp z,c0a
	ld a,(hl)
	ld (de),a
        or a
	inc hl
	inc de
	jr nz,c0
	ENDIF

	IF NOT CPM
	ld a,2
	sta consfd	;future msgs to go stderr

	ld hl,cline	;copy all MARC args into area at cline, emulating
	shld cptr	;CP/M command line passage
	ex de,hl		;DE is destination area
	lhld argv	;HL will point to arg text
c00a:	lda argc	;get arg count
	or a
	jp z,c0a		;if done, go process the line
	dec a
	sta argc	;not done. debump argc and copy current arg text
	push hl		;save pointer to text address
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a		;HL points to actual arg text
	call ldfn	;lde it to (DE)
	dec de		;stomp on the trailing null from the last arg text
	ld a,' '	; (replace it with a space)
	ld (de),a
	inc de
	pop hl		;restore arg pointer
	inc hl		;bump to next pointer
	inc hl
	jp c00a	;and go for it
	ENDIF	

c0a:	xor a		;OK, command line has been copied
	ld (de),a		;terminate with null byte
	ld hl,cline	;find first non-space char
	call igsp
	or a		;if end of line,
	jp z,c1		; don't pass over main filename
c0c:	inc hl		;else do.
	ld a,(hl)
	or a
	jp z,c1
	call twhite
	jp nz,c0c
	call igsp	;pass space between this and next arg

c1:	shld cptr	;save text pointer for getfn routine

;
; Here process -l and -r and -v; set tb1siz to optional arg of -r,
; set runsat to optional arg of -l, and set segf if -v given:
; also handle new -c option for MARC
; Also handle new -m option to call MEXMEM under MARC...
;
	
	dec hl
prep0:	inc hl
prep:	ld a,(hl)
	or a		;done preprocessing command line?
	ret z		;if so, return 

	cp '"'		;possible option to "-d"?
	jp nz,prep3	
prep2:	inc hl		;if so, skip it totally
	ld a,(hl)
	or a
	ret z		;if null byte, done scanning command line
	cp '"'
	jp nz,prep2
	jp prep0	;then continue scanning for useful options

prep3:	cp '-'		;no. dashed option?	
	jp nz,prep0	;if not, ignore it
	shld fargb	;else save first arg byte
	inc hl
	ld a,(hl)		;get option letter
	call mapuc
	sta opletr	;save for error msg
	inc hl

	cp 'C'		;set disk to get c.ccall c,and deff*.crl from
	jp z,copt

	IF CPM
	cp 'H'		;little kludge (for Leo only)
	jp z,hopt
	ENDIF

	IF MARC
	cp 'I'		;image mode?
	jp z,iopt
	ENDIF

	cp 'L'		;set load addr?
	jp z,lopt
	cp 'R'		;set ref table size?
	jp z,ropt
	dec hl
	cp 'V'		;declare a segment?
	jp nz,prep
	inc hl
	sta segf	;this one's easy.
purge:	ex de,hl		;put current text addr in DE
purge1:	lhld fargb	;get 1st byte of arg
purge2:	ld (hl),' '	;clear it to a space
	inc hl
	call cmphd	;done?
	jp nz,purge2	;keep blanking till done.
	jp prep	;and go pre-process some more

ropt:	call gtaddd	;get argument
	ex de,hl
	ld a,h
	or a
	jp z,purge1	;must be at least 100h to be reasonable!
	shld tb1siz	;set tab1 size;
	jp purge1	;and go purge text from command line

copt:
	IF CPM
	call igsp
	call cnvtd	;get source disk for C.Ccall c,and DEFF*.CRL
	sta defdsk	;(under CP/M only; MARC version assumes
			;all this stuff is in /etc)
	inc hl		;bump text pointer to possible user area
	call gdec	;user area given?
	jp c,copt9	;if not, done with -c option
	sta defusr	;else user area given. Store it at defusr
	
copt9:	ex de,hl
	jp purge1

;
; Scan text at HL for a decimal number. If found, return in B and clear Cy.
; Return Cy set if no legal decimal number.
; Upon exit, HL is left pointing to the first non-decimal-digit character.
;

gdec:	ld b,0
	call igsp
	call legdd
	ld a,0
	ret c	
gdec1:	ld a,(hl)
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
	inc hl
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
	ENDIF

	IF NOT CPM
	ex de,hl		;put text pointer in DE
	ld hl,6		;set noffst to 6 so current directory is
	shld noffst	;searched for deff*.crl & c.ccall c,instead of /libC
	jp purge1
	ENDIF


	IF CPM
hopt:	sta hflag	;kludge for Leo, under CP/M only
	ex de,hl
	jp purge1
	ENDIF

	IF MARC
iopt:	sta iflag	;set image mode to produce absolute image
	ex de,hl
	jp purge1
	ENDIF

lopt:	call gtaddd	;get argument
	ex de,hl
	shld runsat	;set origin address
	jp purge1	;and purge from command line	




;
; Check for user abortion:
;TODO

ckabrt:	push af
	push hl
	push de
	push bc

	IF CPM
	;lda conpol	;are we polling for interrupts?
	;or a
	;jp z,noabrt	;if not, ignore console...

	;ld c,intcon	;interrogate console status
	;call bdos
	;or a
	;jp z,noabrt
	;ld c,coninp
	;call bdos
	;cp 3		;control-C aborts
	;jp nz,noabrt

	;ld de,stgabo	;abort.
	;jp stgab
	ENDIF

	IF NOT CPM
	;ld c,m$ichec
	;call msys
	ENDIF

noabrt:	pop bc
	pop de
	pop hl
	pop af
	ret


;
; Here is a little routine to take an ASCII char in A that
; is either a space or a disk letter, and return the
; appropriate code in A to put in the first byte of an
; fcb accessing the given disk:
;

	IF CPM
cnvtd:	call twhite
	jp nz,cnvtd2
	xor a		;if space, return 0
	ret

cnvtd2:	sub 'A'		;else return 0 for A, 2 for B, etc.
	cp 'Z'+1
	ret c		;OK if a letter
	xor a		;else change to zero
	ret
	ENDIF

;
; Given the address of a function as stored in memory during
; the linkage process, this function returns the actual address
; that the function will occupy when executing:
;

getcdf:	lhld runsat
	push de
	ex de,hl	
	lhld cda
	call cmh
	add hl,de
	pop de
	ret

getcdf2: call getcdf
	ex de,hl
	lhld cdp
	add hl,de
	ret


;
; Print out the contents of register pair HL in ASCII:
;  (uses the simple gas-pump algorithm)
;

prhld:	push de
	push hl
	ld hl,'  '
	shld ascb
	ld hl,' 0'
	shld ascb+2
	pop hl
	inc hl
prh0:	ld a,h
	or l
	jp z,prnt
	dec hl
	push hl
	ld hl,ascb+3
prh1:	ld a,(hl)
	call twhite
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
prnt:	ld de,ascb
	call pstg
	pop de
	ret

;
; Print out file name in the fcb, with user number preceding:
; 
pfnamu:
	lda nouser
	or a
	jp nz,pfnam	;if user areas disabled, don't even try
	ld e,0ffh
	ld c,32
	call bdos	;get current user number
	call prad	;print out value of A in decimal
	ld a,'/'
	call outch	;follow with slash, then print rest of filename

;
; Routine to print out the name of the file
; in the fcb:
;
	
	IF CPM
pfnam:
	push de
	push bc
	lda fcb
	or a		;if no special disk, don't print a letter
	jp nz,pfnam1
	;push de
	;push hl
	;ld c,gdisk
	;call bdos
	;inc a	
	;pop hl
	;pop de
         xor a ;TODO getpath
pfnam1:	add a,'@'		;make it into the disk letter
	call outch
	ld a,':'
	call outch
pfnam2:	ld b,8
	ld de,fcb+1
	call pnseg	;print filename
	ld a,'.'
	call outch
	ld b,3
	call pnseg	;print extension
	call crlf
	pop bc
	pop de
	ret


;
; Print out user number in A in decimal:
;

prad:	push bc
	call prad2
	pop bc
	ret

prad2:	ld c,0		;compute first digit
prad3:	cp 10		;less than 10?
	jp c,prfd		;if so, print first digit
	sub 10		;else subtract 10
	inc c		;bump tens digit
	jp prad3
	
prfd:	push af	;save last digit
	ld a,c		;look at first digit
	or a		;zero?
	call nz,prhd	;if not, print it
	pop af		;get last digit
	jp prhd	;print it

;
; print out string at DE, max length B,
; delete spaces:
;

pnseg:	ld a,(de)
pns2:	call outch
	inc de
	dec b
	ret z
	ld a,(de)
	call twhite
	jp nz,pns2
pns3:	inc de
	dec b
	jp nz,pns3
	ret
	ENDIF

;
; Print out statistics in response to -s option:
;

pstat:	call alphab	;alphabetize symbols

;	lda statf	;if printing stats, put out a crlf
;	or a
;	call nz,crlf

;	call crlf

	call wrsmb	;write symbols to disk and console

;	lda statf	;if stats desired,
;	or a		;print them out
;	jp nz,pst00
;
;	call ovrlap	;check for code/externals overlap
;
;	lhld smsf	;and check for external area overflow into system
;	ex de,hl
;	lhld extadd
;	add hl,de
;	jp c,exovfl	;if carry, REAL overflow!
;	ex de,hl		;DE holds end of external area
; 	lhld taddr	;get end of TPA address
;	call cmphd	;HL better be less than DE....
;	ret nc		;if so, no problem
;exovfl:
;	ld de,stgdo	;else trouble!
;	call pstg
;	ret

pst00:	ld de,stglca	; "last code address = ..."
	call crlf
	call pstg
	call getcdf2	;get last code addr. + 1
	dec hl
	call prhls	;print last code address out

;
; Print external data stats, but DON'T if linking a segment
; and no -e option is given:
;

	lda segf
	or a
	jp z,pst00a	;if not linking a segment, print all stats
	lda eflag	;yes, linking a segment. -e option given?
	or a
	jp z,pst0		;if not, skip printing external numbers

pst00a:	ld de,stgext	;"external data starts at "
	call pstg
	lhld extadd
	push hl
	call prhlc
	ld de,stgxt2	;"occupy "
	call pstg
	lhld smsf
	push hl		;save size of external data area
	call prhls
	ld de,stgxt3	;" bytes, and and end at"
	call pstg
	pop de		;get size of externals
	pop hl		;get start of externals
	add hl,de		;get ending address of externals
	dec hl
	push hl		;save for local store calc later
	ld a,d		;special case of no externals
	or e
	jp nz,skpfdg
	inc hl
skpfdg:	call prhls
	pop hl

pst0:	push hl
	ld de,stgtm	;"top of memory=..."
	call pstg
	lhld taddr
	dec hl
	push hl		;save top of memory address
	call prhls

	lda segf
	or a
	jp z,pst1

	pop de
	pop de
	jp crlf

pst1:	ld de,stgds		;print data & stack space 
	call pstg		; only if not a segment
	pop de			;get saved top of memory address in DE
	pop hl			;get external ending address in HL
	call cmphd		;check for overflow
	push af		;save Cy flag for msg later
	jp c,pst2			;externals end before top of memory?
	ld a,'-'		;no-- print a negative sign
	call outch	
	ex de,hl			;exchange so it'll come out positive
pst2:	call cmh
	add hl,de
	call prhls		;print out amount of stack space
	call crlf
	pop af			;check for overflow condition
	ld de,stgdo		;data overflow message
	call nc,pstg

ovrlap:	call getcdf2		;check for externals/code overlap
	ex de,hl			;put end of code addr in DE
	lhld extadd		;get external base address
	call cmphd		;is external base < end of code + 1?
	ld de,stgdo2
	call c,pstg	
	ret

wrsmb:	ld a,4
	sta gotf	;init symbols-per-line countdown
	sta wrsmf	;and make outch write to disk as well as console
	lda wflg	;	(to disk only if wflg is on)
	or a
	jp z,wrsm2	;write symbols to disk?

	IF CPM
	ld hl,fcbs
	ld de,fcb
	call ldfn
	ld hl,fcb+9
	ld (hl),'S'
	inc hl
	ld (hl),'Y'
	inc hl
	ld (hl),'M'
	ENDIF

	IF NOT CPM
	ld hl,fcbs
	ld de,fcbt
	push de
	push de
	call ldfn
	pop hl
	call putext
	   db '.sym',0
	pop hl
	ENDIF

	call crate2	;if so, create symbols file
	ld hl,tbuff	;init buffer pointer
	shld bufp
wrsm2:	lhld nsmbs	;set BC = countdown of # of symbols
	ld b,h
	ld c,l
	ld de,0		;while DE will go the other way
wrsm3:	call wsmb	;write out a single symbol and address
	inc de		;bump pointer to next symbol pointer
	inc de
	dec bc		;de-bump countdown
	ld a,b		;done?
	or c
	jp nz,wrsm3	;if not, keep loopin'

	call crlf	;done. put out trailing crlf

	IF CPM
	ld b,1ah	;terminating control-Z for CP/M (cough cough)
	lda wflg	;were we writing to a file?
	or a
	call nz,wrb3	;(into file only)
	ENDIF

	xor a
	sta wrsmf	;turn off kludge flag
	lda wflg
	or a		;writing to disk?
	ret z		;if not, all done

	IF CPM
	ld b,1ah	;if so, pad file with control-Z's for CP/M
	lhld bufp
	ld a,l
	and 7fh		
	jp z,wrsm6
wrsm4:	ld a,l
	and 7fh
	jp z,wrsm5
	ld (hl),b
	inc hl
	jp wrsm4
wrsm5:	ld hl,tbuff
	call writs
	ENDIF

	IF NOT CPM	;for MARC, just write out rest of the buffer
	lhld bufp
	ld a,l
	and 7fh
	jp z,wrsm6
	ld e,a		;put byte count in DE
	ld d,0
	ld hl,tbuff
	call writs	;write out remainder of symbol text buffer
	ENDIF

wrsm6:	call close
	ret

wsmb:	push de		;write out symbol #DE and its value
	ld hl,tab2	;first get value
	add hl,de
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a		;HL = raw value
	push hl		;add offset	
	call getcdf
	pop de
	add hl,de
	call prhls	;print out value in hex
	ld hl,wsp	;now get name
	pop de
	add hl,de
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	call pfnm	;print out name
	lda gotf	;see if we trail with tab or crlf
	dec a
	sta gotf
	jp z,wsmbcr
	ld a,9		;tab.
	call outch
	ret
wsmbcr:	call crlf	;crlf
	ld a,4		;reset line count
	sta gotf
	ret

	
;
; Alphabetize symbols for SYM file output and stat printout:
;

alphab:	call setwsp	;set up swp with pointers to symbols in tab1
	ld bc,0		;initalize outer loop variable
ab1:	lhld nsmbs	;done with outer loop?
	dec hl
	call cmpbh
	ret nc		;if so, all done sorting
	ld d,b		;else initialize inner loop
	ld e,c
	inc de
ab2:	lhld nsmbs	;done with inner iteration?
	dec hl
	call cmphd
	jp c,ab4		;if so, iterate outer loop
	call cmptx	;else compare two symbols
	jp nc,ab3		;out of order?
	ld hl,wsp	;yes. swap pointers.
	shld tbase	
	call swap
	ld hl,tab2
	shld tbase
	call swap
ab3:	inc de		;bump inner loop variable
	jp ab2
ab4:	inc bc		;bump outer loop variable
	jp ab1

cmpbh:	ld a,b		;return C set if BC < HL
	cp h
	ret nz
	ld a,c
	cp l
	ret

cmphd:	ld a,h		;return C set if HL < DE
	cp d
	ret nz
	ld a,l
	cp e
	ret

swap:	lhld tbase	;switch the 16 bit values at tbase+BC
	add hl,bc		;			and  tbase+DE
	add hl,bc
	push bc		;save BC
	push hl		;save tbase+BC
	ld c,(hl)		; BC := (tbase+BC)
	inc hl
	ld b,(hl)
	lhld tbase
	add hl,de
	add hl,de
	push de		;save DE
	ld e,(hl)		; DE := (tbase+DE)
	inc hl
	ld d,(hl)
	ld (hl),b		; (tbase+DE) := (tbase+BC)
	dec hl
	ld (hl),c
	pop hl		;get back original DE in HL
	ex de,hl		;put into DE, and HL:=(tbase+DE)
	ld b,h		; BC := (tbase+DE)
	ld c,l
	pop hl		;get back tbase+BC
	ld (hl),c		; tbase+BC := tbase+DE
	inc hl
	ld (hl),b
	pop bc		;and restore original BC
	ret		;oh well, so it isn't documented all that greatly!

setwsp:	ld hl,tab1	;initialize wsp with pointers to entries in tab1
	ld bc,0		;symbol count
	ld de,wsp	;destination of pointers
setw2:	ld a,(hl)		;end of tab1?
	or a	
	jp nz,setw3
	ld h,b		;yes. set nsmbs to # of symbols found
	ld l,c
	shld nsmbs
	ret		;and return.

setw3:	push hl		;not done. enter pointer into wsp...
	cp 9dh		;"main" is a special code; fudge the pointer
	jp nz,setw4
	ld hl,stgmn	;"MAIN'"

setw4:	ld a,l
	ld (de),a
	inc de
	ld a,h
	ld (de),a
	inc de
	inc bc		;bump symbol count
	pop hl		;restore pointer into tab1

setw5:	ld a,(hl)		;pass over symbol text
	inc hl	
	or a
	jp p,setw5

	ld a,(hl)		;and references (if any)
	and 7fh	
	push de
	ld d,a
	inc hl
	ld e,(hl)
	inc hl
	add hl,de
	add hl,de
	pop de
	jp setw2	;and go to next symbol

cmptx:	push bc		;compare two symbols
	push de		;return C set if wsp(BC) > wsp(DE)
	ld hl,wsp
	add hl,de
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)		;DE points to second symbol
	ld hl,wsp
	add hl,bc
	add hl,bc
	ld c,(hl)
	inc hl
	ld b,(hl)		;BC points to first symbol
	call cmpt2	;compare symbols at BC and DE
	pop de		;restore registers
	pop bc
	ret

cmpt2:	ld a,(bc)		;get char
	and 7fh		;strip end-of-symbol bit
	ld h,a		;save
	ld a,(de)		;do same with other symbol
	and 7fh
	cp h		;compare with first one
	ret nz		;if not same, all done
	ld a,(de)		;else...is 2nd symbol ended?
	or a
	jp p,cmpt3
	ld a,(bc)		;yes..result depends on whether
	or a		;1st symbol is ended...
	scf
	ret p
	ccf
	ret

cmpt3:	ld a,(bc)		;is 1st symbol ended?
	or a
	ret m		;if so, it must be smaller than second.
	inc bc		;else check next character...
	inc de
	jp cmpt2

;
; Print out the function name pointed to by HL for the SYM file and
; stat report:
;

pfnm:	push bc
	ld b,0		;char count
pfnm1:	inc b
	ld a,(hl)
	push af
	inc hl
	and 7fh
	call outch
	pop af
	or a
	jp p,pfnm1
	ld a,b
	pop bc
	cp 3		;if >= 3 characters, ignore
	ret nc
	ld a,9		;else follow with a tab
	jp outch

;
; Print out the value in HL in hex and follow by a space:
;

prhls:	call prhl
	ld a,' '
	jp outch

;
; Print out the value in HL in hex and follow by a comma:
;

prhlc:	call prhl
	ld a,','
	jp outch

;
; Print out the value in HL in hex:
;

prhl:	ld a,h
	call pra
	ld a,l
	jp pra

;
; Print out the value in A in hex:
;

pra:	push af
	rrca
	rrca
	rrca
	rrca
	call prhd
	pop af

;
; Print out the hex digit in A:
;

prhd:	and 15
	add a,30h
	cp 3ah
	jp c,outch
	add a,7
	jp outch

writf:
	IF CPM		;don't bother with debugging kludge under MARC yet
	lda debugf	;debugging before output?
	or a
	jp z,writf0	;if not, go write out CRL file

	lda nflag	;don't try it if -n given, though...
	or a
	jp nz,writf0

	ld de,stgdeb	;yes. tell about debugging
	call pstg

	ld b,0		;first assume no text string

	lda debugf	;now, was a text string given?
	dec a
	jp z,copybt	;if not, just go ahead and do the bootstrap

	lhld argptr	;else copy the text line down into tbuff
	ex de,hl		;DE points to the text
	ld hl,tbuff+1	;HL points into tbuff
        ld (hl),' '	;stick in a leading space for good measure
	inc hl
	inc b
cpytxt:	ld a,(de)		;get next text character
	call mapuc	;map to upper case just like CP/M does
	cp '"'		;end of text?
	jp z,copybt	;if so, go set line length and copy bootc
	ld (hl),a		;else store the character
	inc hl		;bump destination ptr
	inc de		;bump source ptr
	inc b		;bump char count
	jp cpytxt	;and loop till done.

copybt:	ld a,b		;get text line count
	sta tbuff	;set it for the argc&argv processor

	ld hl,boots	;the bootstrap
	ld de,bootsa	;where it's going
	ld b,bbytes	;length of it
bootlp:	ld a,(hl)
	ld (de),a
	inc hl
	inc de
	dec b
	jp nz,bootlp

	jp bootsa	;and go copy the program and run it

;
; This is the bootstrap code, to copy the linked COM file down
; into the tpa and run it.
;

bootsa:	equ tbuff+90	;where this boot will reside

boots:	lhld cda	;source addr.
	ex de,hl		;  into DE
	lhld cdp	;last addr. of code + 1
	ld b,h
	ld c,l		;put last addr. in BC
	ld hl,tpa	;destination (start of TPA)
boots1:	ld a,(de)		;copy a byte
	ld (hl),a
	inc hl
	inc de
	ld a,d		;done yet?
	cp b
	jp nz,bootsa+12	;jp nz,boots1
	ld a,e
	cp c
	jp nz,bootsa+12
	jp tpa		;yes. Go execute code	

bbytes:	equ $-boots
	ENDIF		;end of CP/M-only debugging hack, 4 the time being

writf0:
	IF MARC		;under MARC, put an ".out" extension by default
	ld hl,fcbs
	push hl		;save for create...
	push hl		;save for ldfn...
	lda oflag	;was -o option given?
	or a
	jp nz,writf1	;if so, don't append '.out' to filename
	call putext
	   db '.out',0
writf1:
	pop hl
	ld de,fcbt	;copy into fcbt for error reporting
	call ldfn

	pop hl		;create new version
	ld de,755q	;protection mode allows execution
	call create
	ENDIF

	IF CPM
	call crate	;create an output file under CP/M
	ENDIF

	lhld cda
	
	IF CPM		;under CP/M, copy and write one sector at a time
writ2:	call copys
	push af
	push hl
	ld hl,tbuff
	call writs
	pop hl
	pop af
	jp nc,writ2
	ENDIF	

	IF NOT CPM	;under MARC
	push hl		;save starting address
	call cmh
	ex de,hl
	lhld cdp	;get ending address
	add hl,de		;subtract starting address
	inc hl		;add one to get length of file to write
	ex de,hl		;put length in DE
	pop hl		;get back starting address
			;now HL = start, DE = length
	lda iflag	;doing image mode?
	or a
	jp z,writld	;if not, go write MARC load format file

	call writs	;write it out	
	jp close

writld:	push hl		;save object code starting address
	lhld runsat	;get load address
	shld runsav	;save for load address record at end of write
	pop hl		;restore code starting addr

wrtld1:	call doblck	;set up and write out a block of object file data
	jp nz,wrtld1	;keep going till all data has been written
	ld a,1		;now write out load address record
	sta doblck	;use where "doblck" code was for a buffer
	lhld runsav	;get load address
	shld doblck+1

	ld hl,0400h	;this gets stored as "00 04"
	shld doblck+3

	ld hl,doblck	;  as load address.
	ld de,5		;four bytes for load address record, plus EOF byte
	call writs	;and write out this final record
	ENDIF

	jp close

	IF MARC
doblck:	shld datap	;save object code pointer for later use
	dec hl		;HL--> where length byte goes
	ld a,d		;more than 255 bytes left to write?
	or a
	sta endtst	;(save for EOF Test later)
	ld c,e		;in case this is the last, put count in c
	jp z,sets2	;and go away if this is the last

	push hl		;else subtract 255 from DE
	ld hl,-255
	add hl,de
	ex de,hl
	pop hl

	ld c,255	;and set count = 255
sets2:	ld (hl),c		;set length count byte for this block
	dec hl

	push de		;C contains byte count; save countDOWN register on stk
	ex de,hl		;save memory pointer in DE
	lhld runsat	;get load address for this block
	ex de,hl		;put into DE
	ld (hl),d		;transfer to memory
	dec hl
	ld (hl),e
	dec hl
	ld (hl),1		;abs record header byte

	push hl		;save start of block for writs

	ld l,c		;update load address
	ld h,0
	add hl,de		;by adding byte count to old load address
	shld runsat	;and get it ready for the next iteration

	push bc		;save C for count total later
	lhld datap	;compute checksum. get pointer to start of data
	xor a		;clear checksum accumulation
sets3:	add m		;add next byte
	inc hl		;bump memory pointer
	dec c		;de-bump countdown
	jp nz,sets3	;keep going till done

	cpl		;negate A to acheive actual checksum byte
	inc a
	ld b,a		;save checksum in B
	ld a,(hl)		;get byte of data AFTER end of block
	sta btsav	;save somewhere for later restortion
	ld (hl),b		;replace with checksum (kludge, kludge)

	pop bc		;get back byte count in C
	ld b,0		;use to compute total size of block to be written
	ld hl,5		;fudge factor because of ld format overhead
	add hl,bc		;add to byte count to get total # byte to write
	ex de,hl		;put into DE for writs routine
	pop hl		;get pointer to start of block
	push de		;save this stuff
	push hl
	call writs	;write the block
	pop hl		;restore this stuff
	pop de
	add hl,de		;get pointer to start of data for NEXT block
	dec hl		;point back to checksum byte, which overwrote data
	lda btsav	;get back the byte butchered by the checksum byte
	ld (hl),a		;restore it to its proper place
	pop de		;get back countdown register
	lda endtst	;was this the last block? if so, endtst will be zero
	or a		;set the Z flag if so, so we don't come here again...
	ret

	ENDIF



	IF CPM		;only need this sector copy kludge under CP/M
copys:	ld de,tbuff
	ld b,80h
copy1:	ld a,(hl)
	ld (de),a
	push de
	ex de,hl
	lhld cdp
	ld a,h
	cp d
	jp nz,copy2
	ld a,l
	cp e
	jp z,copy3
copy2:	ex de,hl
	pop de
	inc hl
	inc de
	dec b
	jp nz,copy1
	xor a
	ret

copy3:	pop de
copy4:	dec b
	jp z,copy5
	ld a,1ah
	ld (de),a
	inc de
	jp copy4
copy5:	scf
	ret
	ENDIF		;end of sector copy kludge

;
; Open a file. Under CP/M, the default fcb is assumed to have been
; set up for a file. Under MARC, a name pointer is passed in HL
; and location "marcfd" is set here to the file descriptor returned
; by the MARC system call; register A is 0 for opening for READ, or
; 1 for WRITE.
;

open:	push bc		;save registers
	push de
	push hl

	IF TESTING
	push af
	call printf
	  db 'trying to open: ',0
	push hl
	call pfnamu
	pop hl
	pop af
	ENDIF

	IF CPM
	ld de,fcb
	ld c,openfil
	call bdos
	ENDIF

	IF NOT CPM
	ld c,(hl)$open
	call msys
	ENDIF

	IF CPM
	cp 255		;return value of 255 from CP/M's 'open' means error
	jp nz,op2
	ENDIF

	IF NOT CPM
	jp z,op2		;Z flag under MARC indicates success
	ENDIF

	ld de,stg1	;spew an error.
op1:	lda quietf	;be quiet about it?
	or a
	call z,pstg
	ld a,0		;clear quietf.
	sta quietf	

	IF MARC
	pop hl
	push hl		;get filename string for MARC pfnam routine
	ENDIF

	call z,pfnamu	;tell name of file that can't be opened
	scf		;set carry to indicate error to calling routine
	jp op3

op2:
	IF CPM
	xor a
	sta nr
	ENDIF

	IF NOT CPM
	sta marcfd	;store fd for file only if it opened correctly
	ENDIF

	IF TESTING
	call printf
	  db '....opened OK',0
	ENDIF

op3:	pop hl
	pop de
	pop bc
	ret


;
; Close a file. Under CP/M, also zero out the extent field so the
; next routine to use the default fcb doesn't go apeshit opening
; the wrong extent.
;


close:
	IF TESTING
	call printf
	   db 'closing...',0
	ENDIF

	IF CPM
	push bc
	push de
	push hl
	ld de,fcb
	ld c,closefil
	call bdos
	ld hl,fcb+12
	ld (hl),0
	pop hl
	pop de
	pop bc
	cp 255
	ret nz
	ld de,stg4
	jp c2
	ENDIF

	IF NOT CPM
	lda marcfd
	ld c,(hl)$close
	call msys
	jp nz,ferror
	ld a,0
	sta marcfd	;clear fd byte for error recovery
	ret
	ENDIF


;
; Delete a file. Name is in default fcb for CP/M, or passed in HL
; for MARC:
;

delfil:
	IF CPM
	ld de,fcb
	ld hl,fcb+12
	ld (hl),0
	ld c,delete
	jp bdos
	ENDIF

	IF NOT CPM
	ld c,(hl)$unlink
	call msys
	jp nz,ferror
	ret
	ENDIF




;
; Create a file and open it, first deleting any old version.
; Filename is set up in default fcb under CP/M, or pointed to by
; HL under MARC:
;

crate:
	IF CPM
	ld hl,fcbs
	ld de,fcb
	call ldfn
crate2:	call delfil
	call create
;	call open	;don't need to call open, since "create" does it for us
	ret
	ENDIF

	IF NOT CPM
crate2:	ld de,644q	;protection mode
	jp create
	ENDIF


;
; Create a new file. Default fcb is set up under CP/M; name pointer
; is passed under MARC along with a protection mode in DE; marcfd
; is set to the fd of the file (since the creat call opens it for writing):
;


create:
	IF CPM
	ld de,fcb
	ld hl,fcb+12
	ld (hl),0
	ld hl,fcb+32
	ld (hl),0
	ld c,makfil
	call bdos
	cp 255
	ret nz
	ld de,stg5
	jp c2
	ENDIF

	IF NOT CPM
	ld c,(hl)$creat
	call msys
	jp nz,ferror
	sta marcfd	;save the fd if it got created OK
	ret
	ENDIF	


;
; Under CP/M, reads in a sector of data from the default fcb,
; setting the Carry flag on end of file,
; and prints something appropriately nasty on error. Under MARC,
; reads in DE bytes to memory at HL from the currently open file:
;

reads:	
	IF CPM
	push hl		;under CP/M
	push de
	ld de,fcb
	ld c,rsequen
	call bdos	;read a sector
	pop de
	pop hl
	or a
	ret z		;error?
	;dec a		;maybe.
	scf
	ret ;z		;return carry if EOF
	ENDIF		;else fall through to error reporting routine


	IF MARC		;under MARC:
	lda marcfd
	ld c,(hl)$read
	push de		;save byte count
	call msys	;read data
	pop bc		;get back byte count in BC
	jp nz,ferror
	ld a,d
	cp b
	jp nz,reads1
	ld a,e
	cp c
	ret z

;	ld a,d
;	or e		;is DE zero? if so, EOF: an error here
;	ret nz
	ENDIF

reads1:	ld de,stg2	;read error: barfsville
	jp c2


;
; Write a sector of data to the file in the default fcb under CP/M;
; write DE bytes from memory at HL to the "marcfd" file under MARC:
;

writs:
	IF CPM
	push de
	push hl
	ld c,wsequen
	ld de,fcb
	call bdos
	pop hl
	pop de
	or a
	ret z
	ENDIF

	IF NOT CPM
	ld c,m$write
	lda marcfd
	call msys
	ret z
	jp ferror
	ENDIF	

	ld de,stg3	;write error: complain
	jp c2

;
; Read a character from the standard input (console only under CP/M):
;

inch:
	IF CPM
	push bc
	push hl
	;ld c,coninp
	;call bdos
        YIELDGETKEYLOOP
	pop hl
	pop bc
	ENDIF

	IF NOT CPM
	xor a		;standard input under MARC
	ld c,m$getcf
	call msys
	jp nz,ferror
	ENDIF

	IF CPM
	call mapuc
	ENDIF

	cp key_esc;3
	jp z,abort
	ret

;
; Print a CR-LF onto standard output (console only under CP/M):
;

crlf:	IF CPM
	ld a,cr
	call outch
	ENDIF

	ld a,lf		;and fall through to outch

;
; Write a character to standard output, and to the symbols file
; if wrsmf flag is active:
;

outch:
	IF MARC
	cp cr		;ignore CR's under MARC
	ret z
	ENDIF

	push hl
	push bc
	push de
	push af
	ld b,a
	lda wrsmf	;if wrsmf true,
	or a
	jp z,outc1
	ld a,b		;do it all in wrb
	call wrb
	jp outc1a

outc1:	ld a,b		;otherwise just put out to the console
	call outch2

outc1a: pop af
	pop de
	pop bc
	pop hl
	ret


;
; Write the character in A to the standard output (console only under CP/M):
;

outch2:
	IF CPM
	push bc
	;ld c,conout
	;ld e,a
	;call bdos
        PRCHAR
	pop bc
	ret
	ENDIF
	
	IF NOT CPM	; for MARC:
	ld b,a		;put character in B
	lda consfd	;stdout or stderr under MARC	
	ld c,m$putcf
	call msys
	jp nz,ferror
	ret
	ENDIF


wrb:	ld b,a		;write out a byte of symbol table text
	lda statf	;displaying symbol values on console?
	or a
	jp z,wrb2
	ld a,b		;yes. do it.
	call outch2
wrb2:	lda wflg	;writing symbols to disk?
	or a
	ret z
wrb3:	push hl
	lhld bufp	
	ld (hl),b
	inc hl
	ld a,l
	and 7fh
	jp nz,wrb4

	IF MARC
	ld de,128
	ENDIF

	ld hl,tbuff
	call writs	;if buffer full, dump to disk
wrb4:	shld bufp
	pop hl
	ret

	IF MARC
pfnam:	ex de,hl		;for MARC, put name pointer in DE
	call pstg
	call crlf
	ret
	ENDIF

pstg:	push af
pstg1:	ld a,(de)
	or a
	jp nz,pstg2
	pop af
	ret
pstg2:	call outch
	inc de
	jp pstg1

gnfl:
	IF CPM
	call scrl	;set CRL extension
	lda quietf
	ld b,a
	ld a,1
	sta quietf	;don't complain yet under CP/M
	ENDIF

	xor a
	call open	;try to open for reading

	IF CPM
	ld a,b
	sta quietf
	ENDIF	

	IF MARC
	ret c		;don't read in directory if not there
	ENDIF

;	IF CPM
	jp nc,gnflok	;found in first path? if so, go process

	lda search	;no. should we search default area also?
	or a
	jp z,cmpln	;if not, go complain

	;lda defusr	;now try default disk and user area
	;ld e,a
	;inc a		;default user area is current user area?
	;jp z,gnfl2	;if so, don't change
	;ld c,sguser
	;lda nouser
	;or a
	;IF NOT ALPHA
	;call z,bdos
	;ENDIF

gnfl2:	lda defdsk	;default disk current disk?
	ld e,a
	cp 0ffh	;if so, don't switch
	jp z,gnfl3

	;push de
	;ld c,gdisk	;first get and save currently logged drive
	;call bdos
	;inc a		;add 1 so A == 1, and 0 can mean "unused"
         xor a ;TODO getpath
	sta savdrv
	;pop de		;get back drive to switch to in E
	;ld c,select
	;call bdos

gnfl3:	xor a		;now try to open in new directory
	call open
	jp nc,gnflok	;and go on processing if we finally found it
	ret		;else return, since this time "open" printed an error

cmpln:	lda quietf	;do we bitch?
	or a
	scf
	ret nz		;if quietf set, don't bitch, just set Cy and return
	ld de,stg1	;can't find:
	call pstg
	call pfnamu	;print filename
	scf		;and return Cy set to indicate failure
	ret

gnflok:
;	ENDIF

	ld hl,direc

	IF CPM		;read in directory under CP/M one sector at a time
	call reads
	call cpys
	call reads
	call cpys
	call reads
	call cpys
	call reads
	call cpys
	ENDIF
	
	IF NOT CPM	;under MARC  just read in 512 bytes
	ld de,512
	call reads
	ENDIF

	xor a		;clear carry
	ret

scrl:
	IF CPM
	ld hl,fcb+9
	ld (hl),'C'
	inc hl
	ld (hl),'R'
	inc hl
	ld (hl),'L'
	ret
	ENDIF

	IF NOT CPM
	call putext
	   db '.crl',0
	ret
	ENDIF

	IF CPM
cpys:	ld de,tbuff
	ld b,80h
cps2:	ld a,(de)
	ld (hl),a
	inc hl
	inc de
	dec b
	jp nz,cps2
	ret
	ENDIF		;end of CP/M-only stuff




;
; Get any functions out of the currently open CRL file
; as may be needed, until the supply is exhausted:
;

gtfns:	lda fflag	;force loading of all function in this crl file?
	or a
	jp z,gtfn0	;if not, go scan normally for needed functions

;
; Load in EVERY function in the currently open CRL file. Once this works,
; it should also refrain from loading any functions which have already been
; loaded...
;

	ld hl,direc	;and try to get every function we can...
gtfn00:	ld a,(hl)
	cp 80h		;end of directory?
	jp z,gtfn03	;if so, done with this crl file
	push hl
	push hl
	shld savnam	;save a pointer to the name for entt1 to bitch with
	call pb7hi	;pass name (we don't care about it yet)
	call ft23a	;else set function parameters for rdfun
	pop hl
	ld a,1		;say that we got it
	sta gotf
	sta rdngsm	;set this so symbol routine does duplicate checking
	call entt1	;enter into tab1 as gotten
	lda gotf	;was it a duplicate?
	cp 81h
	call nz,pre		;read it in and process if not a duplicate
gtfn02:	pop hl		;get back pointer to directory
	call pb7hi	;pass over name of the function we just read in
	inc hl		;and its address
	inc hl
	jp gtfn00	;and go for the next one.

gtfn03:
	IF NOT FORCE
	xor a
	sta fflag	;turn off forcing after this file.
	ENDIF
	sta rdngsm	;and reset this also
	jp close	;and go close the current one

;
; Scan the current CRL file for NEEDED functions only (restarting scan
; every time one is loaded, so any local backward-references are
; resolved):
;

gtfn0:	ld hl,tab1	;init needed-function table pointer
	shld fngtt
gtfn1:	call fung2	;any more ungotten functions in the n-f table?
	jp c,close	;if not, all done with this crl file
	push hl
	call ft2	;else see if the next needed function is in the
	pop hl		;  current CRL file
	jp c,gtfn1	;is it?
	ld a,1		;yes.
	sta gotf	;say that we got it
	call entt1	;enter the fact in tab1
	call pre	;and actually read it in
	jp gtfn1	;and go for more

;
; This routine scans through the entire needed-function table for
; any non-loaded needed function entries. As soon as one is found,
; HL is returned with a pointer to the loaded byte for that entry, and
; Z is set. Z is returned NOT set if there aren't any more unloaded functions:
;

fungt:	ld hl,tab1	;start at the beginning
	shld fngtt

;
; This routine scans the needed-function table from the current position
; of the table pointer (fngtt) to the end, looking for unloaded needed
; functions. See above for return values.
;

fung2:	lhld fngtt	;get pointer into tab1
fng21:	push hl
	call past1e
	shld fngtt
	pop hl
	ld a,(hl)
	or a
	scf 
	ret z
	push hl
fng22:	call pb7hi	;pass function name
	ld a,(hl)		;next byte a zero?
	or a
	pop hl
	jp m,fung2
	ret		;no...so 


past1e:	call pb7hi
	push de
	ld a,(hl)
	and 7fh
	ld d,a
	inc hl
	ld e,(hl)
	inc hl
	ex de,hl
	add hl,hl
	add hl,de
	pop de
	ret


pb7hi:	ld a,(hl)
	inc hl
	or a
	jp p,pb7hi
	ret


mapuc:	cp 61h
	ret c
	cp 7bh
	ret nc
	sub 32
	ret

;
; This routine scans the current CRL file directory for an occurence of
; the function whose name is pointed to by HL. If found, Cy is returned not
; set. Cy is returned set if not found, of course:
;

ft2:	push hl		;save the name pointer
	ex de,hl		;and also put in DE
	ld hl,direc	;start at the beginning of directory
ft21:	ld a,(hl)		;end of directory?
	cp 80h
	jp nz,ft22
	pop hl		;yes. no match found, so set carry and return
	scf
	ret

ft22:	call stcmp	;not end of directory. current entry match?
	jp nz,ft24

ft23:	call ft23a
	pop hl		;all done. Note carry isn't set because of pb7hi
	ret

ft23a:	ld a,(hl)		;yes--next two bytes after name are file address
	inc hl		;put the file address in HL
	push hl
	ld h,(hl)
	ld l,a
	shld enst	;save for rdfun to use in loading it later
	pop hl		;find out what the address after the subsequent
	inc hl		;entry is, to get ending address in file...
	call pb7hi
	ld a,(hl)		;here it is. load into HL
	inc hl
	ld h,(hl)
	ld l,a
	shld enend	;and save for rdfun
	ret

ft24:	call pb7hi	;no match. go on to next entry
	inc hl
	inc hl
	jp ft21

	;IF LASM
	;link clinkb
	;ENDIF
