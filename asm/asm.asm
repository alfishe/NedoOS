decltoken
	LD HL,[_fdecl]
	LD [writebyte.A.],HL
	LD A,[decltoken.bb]
	LD [writebyte.B.],A
	CALL writebyte
	RET
asmpushvalue
	LD A,[_nvalues]
	SUB _MAXVALS
	JP Z,asmpushvalue.B.
	LD HL,_value
	LD A,[_nvalues]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	ADD HL,DE
	ADD HL,DE
	LD DE,[asmpushvalue.value+2]
	LD BC,[asmpushvalue.value]
	LD [HL],C
	INC HL
	LD [HL],B
	INC HL
	LD [HL],E
	INC HL
	LD [HL],D
	LD HL,_nvalues
	INC [HL]
	JP asmpushvalue.C.
asmpushvalue.B.
	LD HL,asmpushvalue.D.
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
asmpushvalue.C.
	RET
asmpushbool
	LD A,[asmpushbool.b]
	LD L,A
	LD H,0
	LD DE,0
	LD [asmpushvalue.A.],HL
	LD [asmpushvalue.A.+2],DE
	CALL asmpushvalue
	RET
asmpopvalue
	LD HL,_nvalues
	DEC [HL]
	LD HL,_value
	LD A,[_nvalues]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	ADD HL,DE
	ADD HL,DE
	LD E,[HL]
	INC HL
	LD D,[HL]
	INC HL
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	RET
clearlabels
	LD HL,_labelpage
	LD DE,[clearlabels.labelblock]
	ADD HL,DE
	ADD HL,DE
	LD DE,[clearlabels.labelpointer]
	LD [HL],E
	INC HL
	LD [HL],D
	LD HL,0x0400
	LD [_hash],HL
clearlabels.C.
	LD HL,[_hash]
	DEC HL
	LD [_hash],HL
	LD HL,_labelshift
	LD DE,[_hash]
	ADD HL,DE
	ADD HL,DE
	LD DE,_LABELPAGEEOF
	LD [HL],E
	INC HL
	LD [HL],D
	LD HL,[_hash]
	LD DE,0
	OR A
	SBC HL,DE
	JP NZ,clearlabels.C.
clearlabels.D.
	LD HL,0
	LD [_labelpagefreestart],HL
	RET
readlabel
	CALL readfin
	LD [_token],A
	LD HL,0
	LD [readlabel.labellen],HL
readlabel.A.
	CALL readfin
	LD [readlabel.cstr],A
	LD A,[readlabel.cstr]
	SUB '#'
	JP NZ,readlabel.C.
	LD HL,[_evallabeltext]
	LD [readlabel.pevalstr],HL
readlabel.E.
	CALL readfin
	LD [readlabel.cstr],A
	LD HL,[readlabel.pevalstr]
	LD A,[readlabel.cstr]
	LD [HL],A
	LD HL,[readlabel.pevalstr]
	INC HL
	LD [readlabel.pevalstr],HL
	LD A,[readlabel.cstr]
	SUB _TOKENDTEXT
	JP NZ,readlabel.E.
readlabel.F.
	LD HL,[readlabel.pevalstr]
	LD DE,[_evallabeltext]
	OR A
	SBC HL,DE
	LD [_labellen],HL
	LD HL,[_evallabeltext]
	LD [findlabel.A.],HL
	CALL findlabel
	CALL getlabel
	LD [emitn.A.],DE
	CALL emitn
	LD HL,[_curlabeltext]
	LD [strjoin.A.],HL
	LD HL,[readlabel.labellen]
	LD [strjoin.B.],HL
	LD HL,_nbuf
	LD [strjoin.C.],HL
	CALL strjoin
	LD [readlabel.labellen],HL
readlabel.C.
	LD HL,[_curlabeltext]
	LD DE,[readlabel.labellen]
	ADD HL,DE
	LD A,[readlabel.cstr]
	LD [HL],A
	LD HL,[readlabel.labellen]
	INC HL
	LD [readlabel.labellen],HL
	LD A,[readlabel.cstr]
	SUB _TOKENDTEXT
	JP NZ,readlabel.A.
readlabel.B.
	LD HL,[readlabel.labellen]
	LD [_labellen],HL
	RET
findlabel
	LD HL,[findlabel.labeltext]
	LD [hash.A.],HL
	CALL hash
	LD DE,0x3ff
	LD A,D
	AND H
	LD H,A
	LD A,E
	AND L
	LD L,A
	LD [_hash],HL
	LD HL,_labels0
	LD [_labelN],HL
	LD HL,_labelshift
	LD DE,[_hash]
	ADD HL,DE
	ADD HL,DE
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [_plabel_index],HL
findlabel.B.
	LD HL,[_plabel_index]
	LD DE,_LABELPAGEEOF
	OR A
	SBC HL,DE
	JP Z,findlabel.C.
	LD HL,[_labelN]
	LD DE,[_plabel_index]
	ADD HL,DE
	LD [findlabel.plabel],HL
	LD HL,[findlabel.plabel]
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [_plabel_index],HL
	LD HL,[findlabel.plabel]
	LD DE,2
	ADD HL,DE
	LD [findlabel.plabel],HL
	LD HL,[findlabel.labeltext]
	LD [strcp.A.],HL
	LD HL,[findlabel.plabel]
	LD [strcp.B.],HL
	CALL strcp
	OR A
	JP Z,findlabel.D.
	LD HL,[findlabel.plabel]
	LD DE,[_labelN]
	OR A
	SBC HL,DE
	LD DE,[_labellen]
	ADD HL,DE
	LD [_plabel_index],HL
	JP findlabel.C.
findlabel.D.
	JP findlabel.B.
findlabel.C.
	RET
addlabel
	LD A,FALSE
	LD [_labelchanged],A
	LD HL,_labels0
	LD [_labelN],HL
	LD HL,[_plabel_index]
	LD DE,_LABELPAGEEOF
	OR A
	SBC HL,DE
	JP Z,addlabel.B.
	LD HL,[_labelN]
	LD DE,[_plabel_index]
	ADD HL,DE
	LD [addlabel.plabel],HL
	LD HL,[addlabel.plabel]
	LD A,[HL]
	LD [addlabel.labelflag],A
	LD A,[addlabel.labelflag]
	LD E,_ASMLABEL_MACRO
	AND E
	SUB 0x00
	JP Z,addlabel.D.
	LD HL,addlabel.F.
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
	JP addlabel.E.
addlabel.D.
	LD A,[addlabel.labelflag]
	LD E,_ASMLABEL_DEFINED
	AND E
	SUB 0x00
	JP Z,addlabel.G.
	LD HL,[addlabel.plabel]
	LD DE,1
	ADD HL,DE
	LD E,[HL]
	INC HL
	LD D,[HL]
	INC HL
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD BC,[addlabel.labelvalue+2]
	LD IX,[addlabel.labelvalue]
	LD A,E
	SUB LX
	JR NZ,$+0xd
	LD A,D
	SUB HX
	JR NZ,$+0x8
	LD A,L
	SUB C
	JR NZ,$+0x4
	LD A,H
	SUB B
	JP Z,addlabel.I.
	LD A,TRUE
	LD [_labelchanged],A
addlabel.I.
	JP addlabel.H.
addlabel.G.
	LD HL,[addlabel.plabel]
	LD A,[addlabel.labelflag]
	LD E,A
	LD A,[_isaddr]
	OR E
	LD C,_ASMLABEL_DEFINED
	OR C
	LD [HL],A
	LD HL,[addlabel.plabel]
	LD DE,1
	ADD HL,DE
	LD DE,[addlabel.labelvalue+2]
	LD BC,[addlabel.labelvalue]
	LD [HL],C
	INC HL
	LD [HL],B
	INC HL
	LD [HL],E
	INC HL
	LD [HL],D
addlabel.H.
addlabel.E.
	JP addlabel.C.
addlabel.B.
	LD HL,[_labelpagefreestart]
	LD [addlabel.freestart_index],HL
	LD HL,[addlabel.freestart_index]
	LD [_plabel_index],HL
	LD HL,[addlabel.freestart_index]
	LD DE,_LABELPAGEMAXSHIFT
	LD A,L
	SUB E
	LD A,H
	SBC A,D
	JP NC,addlabel.K.
	LD HL,[_labelN]
	LD DE,[_plabel_index]
	ADD HL,DE
	LD [addlabel.plabel],HL
	LD HL,[addlabel.plabel]
	LD DE,_labelshift
	LD BC,[_hash]
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	LD A,[DE]
	INC DE
	EX AF,AF'
	LD A,[DE]
	LD D,A
	EX AF,AF'
	LD E,A
	LD [HL],E
	INC HL
	LD [HL],D
	LD HL,[addlabel.plabel]
	LD DE,2
	ADD HL,DE
	LD [addlabel.plabel],HL
	LD HL,[_curlabeltext]
	LD [strcopy.A.],HL
	LD HL,[_labellen]
	LD [strcopy.B.],HL
	LD HL,[addlabel.plabel]
	LD [strcopy.C.],HL
	CALL strcopy
	LD HL,[addlabel.plabel]
	LD DE,[_labellen]
	ADD HL,DE
	LD [addlabel.plabel],HL
	LD HL,[addlabel.plabel]
	LD A,_ASMLABEL_DEFINED
	LD [HL],A
	LD HL,[addlabel.plabel]
	LD DE,[_labelN]
	OR A
	SBC HL,DE
	LD [_plabel_index],HL
	LD HL,[addlabel.plabel]
	INC HL
	LD [addlabel.plabel],HL
	LD HL,[addlabel.plabel]
	LD DE,[addlabel.labelvalue+2]
	LD BC,[addlabel.labelvalue]
	LD [HL],C
	INC HL
	LD [HL],B
	INC HL
	LD [HL],E
	INC HL
	LD [HL],D
	LD HL,[addlabel.plabel]
	LD DE,4
	ADD HL,DE
	LD [addlabel.plabel],HL
	LD HL,_labelshift
	LD DE,[_hash]
	ADD HL,DE
	ADD HL,DE
	LD DE,[addlabel.freestart_index]
	LD [HL],E
	INC HL
	LD [HL],D
	LD HL,[addlabel.plabel]
	LD DE,[_labelN]
	OR A
	SBC HL,DE
	LD [_labelpagefreestart],HL
	LD HL,[_lenlabels]
	LD DE,[_labelpagefreestart]
	ADD HL,DE
	LD DE,[addlabel.freestart_index]
	OR A
	SBC HL,DE
	LD [_lenlabels],HL
	LD HL,[_nlabels]
	INC HL
	LD [_nlabels],HL
	JP addlabel.L.
addlabel.K.
	LD HL,addlabel.M.
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
addlabel.L.
addlabel.C.
	RET
changelabel
	LD HL,_labels0
	LD [_labelN],HL
	LD HL,[_labelN]
	LD DE,[_plabel_index]
	ADD HL,DE
	LD [changelabel.plabel],HL
	LD HL,[changelabel.plabel]
	LD DE,[changelabel.plabel]
	LD A,[DE]
	LD C,_ASMLABEL_ISADDR
	LD E,A
	LD A,C
	CPL
	AND E
	LD E,A
	LD A,[_isaddr]
	OR E
	LD C,_ASMLABEL_DEFINED
	OR C
	LD [HL],A
	LD HL,[changelabel.plabel]
	LD DE,1
	ADD HL,DE
	LD DE,[changelabel.labelvalue+2]
	LD BC,[changelabel.labelvalue]
	LD [HL],C
	INC HL
	LD [HL],B
	INC HL
	LD [HL],E
	INC HL
	LD [HL],D
	RET
getlabel
	LD HL,_labels0
	LD [_labelN],HL
	LD HL,[_plabel_index]
	LD DE,_LABELPAGEEOF
	OR A
	SBC HL,DE
	JP Z,getlabel.A.
	LD HL,[_labelN]
	LD DE,[_plabel_index]
	ADD HL,DE
	LD [getlabel.plabel],HL
	LD HL,[getlabel.plabel]
	LD A,[HL]
	LD [getlabel.labelflag],A
	LD HL,[getlabel.plabel]
	LD A,[getlabel.labelflag]
	LD C,_ASMLABEL_ACCESSED
	OR C
	LD [HL],A
	LD HL,[getlabel.plabel]
	LD DE,1
	ADD HL,DE
	LD E,[HL]
	INC HL
	LD D,[HL]
	INC HL
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [getlabel.labelvalue],DE
	LD [getlabel.labelvalue+2],HL
	LD A,[getlabel.labelflag]
	LD E,_ASMLABEL_ISADDR
	AND E
	LD [_isaddr],A
	JP getlabel.B.
getlabel.A.
	LD HL,getlabel.C.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[_curlabeltext]
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
getlabel.B.
	LD HL,[getlabel.labelvalue+2]
	LD DE,[getlabel.labelvalue]
	RET
asmdir_label
	CALL readlabel
	LD HL,[_curlabeltext]
	LD [findlabel.A.],HL
	CALL findlabel
	LD HL,[_curaddr]
	LD DE,[_curshift]
	ADD HL,DE
	LD DE,0
	LD [addlabel.A.],HL
	LD [addlabel.A.+2],DE
	CALL addlabel
	LD HL,[_plabel_index]
	LD [_curplabel_index],HL
	LD HL,[_hash]
	LD [_curhash],HL
	RET
asmfmt_reequ
	LD HL,[_curplabel_index]
	LD [_plabel_index],HL
	LD HL,[_curhash]
	LD [_hash],HL
	LD HL,[_plabel_index]
	LD DE,_LABELPAGEEOF
	OR A
	SBC HL,DE
	JP Z,asmfmt_reequ.A.
	CALL asmpopvalue
	LD [changelabel.A.],DE
	LD [changelabel.A.+2],HL
	CALL changelabel
asmfmt_reequ.A.
	RET
errwrongreg
	LD HL,errwrongreg.A.
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
	RET
errwrongpar
	LD HL,errwrongpar.A.
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
	RET
asmerrtext
asmerrtext.loop
	CALL readfin
	LD [_token],A
	LD A,[_token]
	SUB _TOKENDERR
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_waseof]
	OR L
	JP Z,asmerrtext.A.
	JP asmerrtext.end
asmerrtext.A.
	LD A,[_token]
	SUB _TOKTEXT
	JP NZ,asmerrtext.C.
asmerrtext.txtloop
	CALL readfin
	LD [_token],A
	LD A,[_token]
	SUB _TOKENDTEXT
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_waseof]
	OR L
	JP Z,asmerrtext.E.
	JP asmerrtext.loop
asmerrtext.E.
	LD A,[_token]
	LD [err.A.],A
	CALL err
	JP asmerrtext.txtloop
	JP asmerrtext.D.
asmerrtext.C.
	LD A,' '
	LD [err.A.],A
	CALL err
asmerrtext.D.
	JP asmerrtext.loop
asmerrtext.end
	LD A,'\"'
	LD [err.A.],A
	CALL err
	CALL enderr
	RET
asmbyte
	LD A,[_asms]
	OR A
	JP Z,asmbyte.B.
	LD A,[asmbyte.token]
	LD [writefout.A.],A
	CALL writefout
asmbyte.B.
	LD HL,[_curaddr]
	INC HL
	LD [_curaddr],HL
	RET
asmemitblock
	LD HL,[_curaddr]
	LD DE,[_curbegin]
	OR A
	SBC HL,DE
	JP Z,asmemitblock.A.
	LD HL,[_curbegin]
	LD DE,0
	LD [asmorgword.A.],HL
	LD [asmorgword.A.+2],DE
	CALL asmorgword
	LD HL,[_curaddr]
	LD DE,[_curbegin]
	OR A
	SBC HL,DE
	LD DE,0
	LD [asmorgword.A.],HL
	LD [asmorgword.A.+2],DE
	CALL asmorgword
asmemitblock.A.
	RET
asmreadprefixed
	CALL readfin
	LD [_token],A
	LD A,[_token]
	SUB '\\'
	JP NZ,asmreadprefixed.A.
	CALL readfin
	LD [_token],A
	LD A,[_token]
	SUB 'n'
	JP NZ,asmreadprefixed.C.
	LD A,0x0a
	LD [_prefixedtoken],A
	JP asmreadprefixed.D.
asmreadprefixed.C.
	LD A,[_token]
	SUB 'r'
	JP NZ,asmreadprefixed.E.
	LD A,0x0d
	LD [_prefixedtoken],A
	JP asmreadprefixed.F.
asmreadprefixed.E.
	LD A,[_token]
	SUB 't'
	JP NZ,asmreadprefixed.G.
	LD A,0x09
	LD [_prefixedtoken],A
	JP asmreadprefixed.H.
asmreadprefixed.G.
	LD A,[_token]
	SUB '0'
	JP NZ,asmreadprefixed.I.
	LD A,0x00
	LD [_prefixedtoken],A
	JP asmreadprefixed.J.
asmreadprefixed.I.
	LD A,[_token]
	LD [_prefixedtoken],A
asmreadprefixed.J.
asmreadprefixed.H.
asmreadprefixed.F.
asmreadprefixed.D.
	JP asmreadprefixed.B.
asmreadprefixed.A.
	LD A,[_token]
	LD [_prefixedtoken],A
asmreadprefixed.B.
	RET
asmpass
	CALL initmemmodel
	LD HL,[_curaddr]
	LD [_curbegin],HL
	LD HL,0
	LD [_curshift],HL
	LD A,0x00
	LD [_nvalues],A
	LD A,0x00
	LD [_ninclfiles],A
	LD HL,[asmpass.fn]
	LD [nfopen.A.],HL
	LD HL,asmpass.B.
	LD [nfopen.B.],HL
	CALL nfopen
	LD [_fin],HL
	LD HL,[_fin]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,asmpass.C.
	LD A,FALSE
	LD [_waseof],A
	LD HL,1
	LD [_curlnbeg],HL
	CALL asmloop
	LD HL,[_fin]
	LD [fclose.A.],HL
	CALL fclose
	JP asmpass.D.
asmpass.C.
	LD HL,asmpass.E.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[asmpass.fn]
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
asmpass.D.
	CALL asmemitblock
	LD HL,[_passindex]
	INC HL
	LD [_passindex],HL
	RET
findlast
	LD HL,0
	LD [findlast.len],HL
	LD HL,0
	LD [findlast.last],HL
findlast.loop
	LD HL,[findlast.s]
	LD A,[HL]
	LD [findlast.c],A
	LD A,[findlast.c]
	SUB '\0'
	JP NZ,findlast.C.
	JP findlast.endloop
findlast.C.
	LD A,[findlast.c]
	LD L,A
	LD A,[findlast.eol]
	SUB L
	JP NZ,findlast.E.
	LD HL,[findlast.len]
	LD [findlast.last],HL
findlast.E.
	LD HL,[findlast.s]
	INC HL
	LD [findlast.s],HL
	LD HL,[findlast.len]
	INC HL
	LD [findlast.len],HL
	JP findlast.loop
findlast.endloop
	LD HL,[findlast.last]
	RET
openext
	LD HL,[_fn]
	LD [findlast.A.],HL
	LD A,'.'
	LD [findlast.B.],A
	CALL findlast
	LD [_lenfn],HL
	LD HL,[_fn]
	LD [strjoin.A.],HL
	LD HL,[_lenfn]
	LD [strjoin.B.],HL
	LD HL,[openext.ext]
	LD [strjoin.C.],HL
	CALL strjoin
	LD [_lenfn],HL
	LD HL,[_fn]
	LD DE,[_lenfn]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	LD HL,[_fn]
	LD [openwrite.A.],HL
	CALL openwrite
	RET
asmcompile
	LD HL,_m_curlabeltext
	LD [_curlabeltext],HL
	LD HL,_m_evallabeltext
	LD [_evallabeltext],HL
	LD HL,_m_fn
	LD [_fn],HL
	LD HL,0
	LD [_lenfn],HL
	LD HL,0
	LD [_nlabels],HL
	LD HL,0
	LD [_lenlabels],HL
	LD HL,0
	LD [clearlabels.A.],HL
	LD HL,_labels0
	LD [clearlabels.B.],HL
	CALL clearlabels
	LD HL,1
	LD [_passindex],HL
	LD A,FALSE
	LD [_errs],A
	LD A,FALSE
	LD [_asms],A
	LD HL,[asmcompile.fn]
	LD [asmpass.A.],HL
	CALL asmpass
	LD HL,[_fn]
	LD [strjoineol.A.],HL
	LD HL,0
	LD [strjoineol.B.],HL
	LD HL,[asmcompile.fn]
	LD [strjoineol.C.],HL
	LD A,'\0'
	LD [strjoineol.D.],A
	CALL strjoineol
	LD [_lenfn],HL
	LD HL,[_fn]
	LD DE,[_lenfn]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	LD HL,asmcompile.B.
	LD [openext.A.],HL
	CALL openext
	LD [_fout],HL
	LD HL,asmcompile.C.
	LD [openext.A.],HL
	CALL openext
	LD [_forg],HL
	LD HL,asmcompile.D.
	LD [openext.A.],HL
	CALL openext
	LD [_fpost],HL
	LD HL,asmcompile.E.
	LD [openext.A.],HL
	CALL openext
	LD [_fdecl],HL
	LD A,TRUE
	LD [_errs],A
	LD A,TRUE
	LD [_asms],A
	LD HL,[asmcompile.fn]
	LD [asmpass.A.],HL
	CALL asmpass
	LD HL,asmcompile.F.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[_nlabels]
	LD [erruint.A.],HL
	CALL erruint
	LD HL,asmcompile.G.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[_lenlabels]
	LD [erruint.A.],HL
	CALL erruint
	CALL enderr
	LD A,_TOKEOF
	LD [decltoken.A.],A
	CALL decltoken
	LD HL,[_fdecl]
	LD [fclose.A.],HL
	CALL fclose
	LD HL,[_fpost]
	LD [fclose.A.],HL
	CALL fclose
	LD HL,[_forg]
	LD [fclose.A.],HL
	CALL fclose
	LD HL,[_fout]
	LD [fclose.A.],HL
	CALL fclose
	RET
