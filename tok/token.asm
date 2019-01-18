rdaddwordall
	LD HL,0
	LD [_spcsize],HL
	LD HL,0
	LD [_waseols],HL
	LD HL,[_curline]
	LD [_curlnbeg],HL
	LD HL,_isalphanum
	LD A,[_cnext]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	OR A
	JP Z,rdaddwordall.A.
rdaddwordall.C.
	LD HL,[_lentword]
	LD DE,_STRMAX
	LD A,L
	SUB E
	LD A,H
	SBC A,D
	JP NC,rdaddwordall.E.
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,[_cnext]
	LD [HL],A
	LD HL,[_lentword]
	INC HL
	LD [_lentword],HL
rdaddwordall.E.
	CALL readfin
	LD [_cnext],A
	LD HL,_isalphanum
	LD A,[_cnext]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	CPL
	OR A
	JP Z,rdaddwordall.C.
rdaddwordall.D.
	JP rdaddwordall.B.
rdaddwordall.A.
	LD HL,[_lentword]
	LD DE,_STRMAX
	LD A,L
	SUB E
	LD A,H
	SBC A,D
	JP NC,rdaddwordall.G.
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,[_cnext]
	LD [HL],A
	LD HL,[_lentword]
	INC HL
	LD [_lentword],HL
rdaddwordall.G.
	CALL readfin
	LD [_cnext],A
rdaddwordall.B.
	JP rdaddwordall.loopgo
rdaddwordall.loop
	CALL readfin
	LD [_cnext],A
rdaddwordall.loopgo
	LD A,[_cnext]
	LD E,'!'
	SUB E
	JP NC,rdaddwordall.I.
	LD HL,[_spcsize]
	INC HL
	LD [_spcsize],HL
	LD A,[_cnext]
	SUB 0x0a
	JP NZ,rdaddwordall.K.
	LD HL,[_curline]
	INC HL
	LD [_curline],HL
	LD HL,0
	LD [_spcsize],HL
	LD HL,[_waseols]
	INC HL
	LD [_waseols],HL
	JP rdaddwordall.L.
rdaddwordall.K.
	LD A,[_cnext]
	SUB 0x09
	JP NZ,rdaddwordall.M.
	LD HL,[_spcsize]
	LD DE,7
	ADD HL,DE
	LD [_spcsize],HL
rdaddwordall.M.
rdaddwordall.L.
	LD A,[_waseof]
	CPL
	OR A
	JP Z,rdaddwordall.O.
	JP rdaddwordall.loop
rdaddwordall.O.
rdaddwordall.I.
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,0x00
	LD [HL],A
	RET
asmtoken
	LD HL,[_fout]
	LD [writebyte.A.],HL
	LD A,[asmtoken.token]
	LD [writebyte.B.],A
	CALL writebyte
	RET
tokspc
tokspc.A.
	LD HL,[_asmspcsize]
	LD A,_ASMMAXSPC
	LD E,A
	LD D,0
	LD A,E
	SUB L
	LD A,D
	SBC A,H
	JP NC,tokspc.B.
	LD A,_TOKSPC0
	ADD A,_ASMMAXSPC
	LD [asmtoken.A.],A
	CALL asmtoken
	LD HL,[_asmspcsize]
	LD A,_ASMMAXSPC
	LD E,A
	LD D,0
	OR A
	SBC HL,DE
	LD [_asmspcsize],HL
	JP tokspc.A.
tokspc.B.
	LD HL,[_asmspcsize]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,tokspc.C.
	LD A,_TOKSPC0
	LD DE,[_asmspcsize]
	ADD A,E
	LD [asmtoken.A.],A
	CALL asmtoken
tokspc.C.
	RET
asmrdword_tokspc
	LD A,[_waseof]
	LD [_asmwaseof],A
	LD HL,[_waseols]
	LD [_asmwaseols],HL
	LD HL,[_spcsize]
	LD [_asmspcsize],HL
	LD HL,[_waseols]
	LD DE,0
	OR A
	SBC HL,DE
	JP NZ,asmrdword_tokspc.A.
	CALL tokspc
asmrdword_tokspc.A.
	LD HL,0
	LD [_lentword],HL
	CALL rdaddwordall
	LD HL,[_tword]
	LD A,[HL]
	LD E,0x20
	OR E
	LD [_c1small],A
	LD HL,[_tword]
	LD DE,1
	ADD HL,DE
	LD A,[HL]
	LD E,0x20
	OR E
	LD [_c2small],A
	RET
toktext
	LD A,_TOKTEXT
	LD [asmtoken.A.],A
	CALL asmtoken
	LD HL,[_tword]
	LD [fputs.A.],HL
	LD HL,[_fout]
	LD [fputs.B.],HL
	CALL fputs
	LD A,_TOKENDTEXT
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
tokerr
	LD A,_ERR
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,[tokerr.token]
	LD [asmtoken.A.],A
	CALL asmtoken
tokerr.B.
	LD A,TRUE
	OR A
	JP Z,tokerr.C.
	CALL toktext
	LD HL,[_waseols]
	LD DE,0
	OR A
	SBC HL,DE
	LD L,0
	JR Z,$+3
	DEC L
	LD A,[_waseof]
	OR L
	LD DE,[_tword]
	LD L,A
	LD A,[DE]
	SUB ':'
	SUB 1
	SBC A,A
	OR L
	JP Z,tokerr.D.
	JP tokerr.C.
tokerr.D.
	CALL asmrdword_tokspc
	JP tokerr.B.
tokerr.C.
	LD A,_TOKENDERR
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	RET
tokerrcmd
	LD A,_ERRCMD
	LD [tokerr.A.],A
	CALL tokerr
	RET
tokinitlblbuf
	LD A,0x00
	LD [_toklblhash],A
tokinitlblbuf.A.
	LD HL,_toklblshift
	LD A,[_toklblhash]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD DE,_TOKLBLBUFEOF
	LD [HL],E
	INC HL
	LD [HL],D
	LD HL,_toklblhash
	INC [HL]
	LD A,[_toklblhash]
	SUB 0x00
	JP NZ,tokinitlblbuf.A.
tokinitlblbuf.B.
	LD HL,0
	LD [_toklblbuffreestart],HL
	RET
tokcalllbl
	LD HL,[_tword]
	LD [hash.A.],HL
	CALL hash
	LD A,L
	LD [_toklblhash],A
	LD HL,_toklblshift
	LD A,[_toklblhash]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [tokcalllbl.plbl_idx],HL
tokcalllbl.A.
	LD HL,[tokcalllbl.plbl_idx]
	LD DE,_TOKLBLBUFEOF
	OR A
	SBC HL,DE
	JP Z,tokcalllbl.B.
	LD HL,_toklbls
	LD DE,[tokcalllbl.plbl_idx]
	ADD HL,DE
	LD [tokcalllbl.plbl],HL
	LD HL,[tokcalllbl.plbl]
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [tokcalllbl.plbl_idx],HL
	LD HL,[tokcalllbl.plbl]
	LD DE,2
	ADD HL,DE
	LD [tokcalllbl.plbl],HL
	LD HL,[_tword]
	LD [strcp.A.],HL
	LD HL,[tokcalllbl.plbl]
	LD [strcp.B.],HL
	CALL strcp
	OR A
	JP Z,tokcalllbl.C.
	LD HL,[tokcalllbl.plbl]
	LD DE,10
	ADD HL,DE
	LD [tokcalllbl.plbl],HL
	LD HL,[tokcalllbl.plbl]
	LD E,[HL]
	INC HL
	LD D,[HL]
	INC HL
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [tokcalllbl.calladdr],DE
	LD HL,[tokcalllbl.plbl]
	LD DE,4
	ADD HL,DE
	LD [tokcalllbl.plbl],HL
	LD HL,[tokcalllbl.plbl]
	LD A,[HL]
	LD [_temppar],A
	LD HL,[tokcalllbl.calladdr]
	CALL _JPHL.
	JP tokcalllbl.e
tokcalllbl.C.
	JP tokcalllbl.A.
tokcalllbl.B.
	CALL tokerrcmd
tokcalllbl.e
	RET
tokaddlbl1
	LD HL,[tokaddlbl1.txt]
	LD [hash.A.],HL
	CALL hash
	LD A,L
	LD [_toklblhash],A
	LD HL,_toklbls
	LD DE,[_toklblbuffreestart]
	ADD HL,DE
	LD [tokaddlbl1.plbl],HL
	LD HL,[tokaddlbl1.plbl]
	LD DE,_toklblshift
	LD A,[_toklblhash]
	LD C,A
	LD B,0
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
	LD HL,_toklblshift
	LD A,[_toklblhash]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD DE,[_toklblbuffreestart]
	LD [HL],E
	INC HL
	LD [HL],D
	LD HL,[tokaddlbl1.plbl]
	LD DE,2
	ADD HL,DE
	LD [tokaddlbl1.plbl],HL
	LD HL,[tokaddlbl1.txt]
	LD [strcopy.A.],HL
	LD HL,9
	LD [strcopy.B.],HL
	LD HL,[tokaddlbl1.plbl]
	LD [strcopy.C.],HL
	CALL strcopy
	LD HL,[tokaddlbl1.plbl]
	LD DE,10
	ADD HL,DE
	LD [tokaddlbl1.plbl],HL
	LD HL,[tokaddlbl1.plbl]
	LD DE,[tokaddlbl1.proc]
	LD BC,0
	LD [HL],E
	INC HL
	LD [HL],D
	INC HL
	LD [HL],C
	INC HL
	LD [HL],B
	LD HL,[tokaddlbl1.plbl]
	LD DE,4
	ADD HL,DE
	LD [tokaddlbl1.plbl],HL
	LD HL,[tokaddlbl1.plbl]
	LD A,[tokaddlbl1.data]
	LD [HL],A
	LD HL,[tokaddlbl1.plbl]
	LD DE,_toklbls
	OR A
	SBC HL,DE
	LD DE,1
	ADD HL,DE
	LD [_toklblbuffreestart],HL
	RET
stringdecapitalize
stringdecapitalize.loop
	LD HL,[stringdecapitalize.s]
	LD A,[HL]
	LD [stringdecapitalize.c],A
	LD A,[stringdecapitalize.c]
	SUB 0x00
	JP NZ,stringdecapitalize.B.
	JP stringdecapitalize.quit
stringdecapitalize.B.
	LD A,[stringdecapitalize.c]
	LD E,'A'
	SUB E
	CCF
	SBC A,A
	LD L,A
	LD A,[stringdecapitalize.c]
	LD C,'Z'
	LD E,A
	LD A,C
	SUB E
	CCF
	SBC A,A
	AND L
	JP Z,stringdecapitalize.D.
	LD HL,[stringdecapitalize.s]
	LD A,[stringdecapitalize.c]
	LD C,0x20
	OR C
	LD [HL],A
stringdecapitalize.D.
	LD HL,[stringdecapitalize.s]
	INC HL
	LD [stringdecapitalize.s],HL
	JP stringdecapitalize.loop
stringdecapitalize.quit
	RET
tokaddlbl
	LD HL,[tokaddlbl.txt]
	LD [tokaddlbl1.A.],HL
	LD HL,[tokaddlbl.proc]
	LD [tokaddlbl1.B.],HL
	LD A,[tokaddlbl.data]
	LD [tokaddlbl1.C.],A
	CALL tokaddlbl1
	LD HL,[tokaddlbl.txt]
	LD [stringdecapitalize.A.],HL
	CALL stringdecapitalize
	LD HL,[tokaddlbl.txt]
	LD [tokaddlbl1.A.],HL
	LD HL,[tokaddlbl.proc]
	LD [tokaddlbl1.B.],HL
	LD A,[tokaddlbl.data]
	LD [tokaddlbl1.C.],A
	CALL tokaddlbl1
	RET
matchdirect
	LD HL,[_tword]
	LD A,[HL]
	SUB '#'
	JP NZ,matchdirect.A.
	LD A,_TOKDIRECT
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchdirect.ok],A
	JP matchdirect.B.
matchdirect.A.
	LD A,FALSE
	LD [matchdirect.ok],A
matchdirect.B.
	LD A,[matchdirect.ok]
	RET
matchcomma
	LD HL,[_tword]
	LD A,[HL]
	SUB ','
	JP NZ,matchcomma.A.
	LD A,_TOKCOMMA
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchcomma.ok],A
	JP matchcomma.B.
matchcomma.A.
	LD A,FALSE
	LD [matchcomma.ok],A
matchcomma.B.
	LD A,[matchcomma.ok]
	RET
matchprime
	LD HL,[_tword]
	LD A,[HL]
	SUB '\''
	JP NZ,matchprime.A.
	LD A,_TOKPRIMESYM
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchprime.ok],A
	JP matchprime.B.
matchprime.A.
	LD A,FALSE
	LD [matchprime.ok],A
matchprime.B.
	LD A,[matchprime.ok]
	RET
matchquote
	LD HL,[_tword]
	LD A,[HL]
	SUB '\"'
	JP NZ,matchquote.A.
	LD A,_TOKDBLQUOTESYM
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,TRUE
	LD [matchquote.ok],A
	JP matchquote.B.
matchquote.A.
	LD A,FALSE
	LD [matchquote.ok],A
matchquote.B.
	LD A,[matchquote.ok]
	RET
matchreequ
	LD HL,[_tword]
	LD A,[HL]
	SUB '='
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c1small]
	SUB 'e'
	SUB 1
	SBC A,A
	LD E,A
	LD A,[_c2small]
	SUB 'q'
	SUB 1
	SBC A,A
	AND E
	OR L
	JP Z,matchreequ.A.
	LD A,_TOKEQUAL
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchreequ.ok],A
	JP matchreequ.B.
matchreequ.A.
	LD A,FALSE
	LD [matchreequ.ok],A
matchreequ.B.
	LD A,[matchreequ.ok]
	RET
matchopen
	LD HL,[_tword]
	LD A,[HL]
	SUB '('
	JP NZ,matchopen.A.
	LD A,_TOKOPEN
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchopen.ok],A
	JP matchopen.B.
matchopen.A.
	LD HL,[_tword]
	LD A,[HL]
	SUB '['
	JP NZ,matchopen.C.
	LD A,_TOKOPENSQ
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchopen.ok],A
	JP matchopen.D.
matchopen.C.
	LD A,FALSE
	LD [matchopen.ok],A
matchopen.D.
matchopen.B.
	LD A,[matchopen.ok]
	RET
matchclose
	LD HL,[_tword]
	LD A,[HL]
	SUB ')'
	JP NZ,matchclose.A.
	LD A,_TOKCLOSE
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchclose.ok],A
	JP matchclose.B.
matchclose.A.
	LD HL,[_tword]
	LD A,[HL]
	SUB ']'
	JP NZ,matchclose.C.
	LD A,_TOKCLOSESQ
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchclose.ok],A
	JP matchclose.D.
matchclose.C.
	LD A,FALSE
	LD [matchclose.ok],A
matchclose.D.
matchclose.B.
	LD A,[matchclose.ok]
	RET
eatlabel
eatlabel.B.
	LD A,[_cnext]
	SUB '.'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_cnext]
	SUB '#'
	SUB 1
	SBC A,A
	OR L
	JP Z,eatlabel.C.
	CALL rdaddwordall
	LD HL,[_spcsize]
	LD DE,0
	OR A
	SBC HL,DE
	JP NZ,eatlabel.D.
	LD HL,_isalphanum
	LD A,[_cnext]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	OR A
	JP Z,eatlabel.F.
	LD HL,[_waseols]
	LD DE,0
	OR A
	SBC HL,DE
	JP NZ,eatlabel.H.
	CALL rdaddwordall
eatlabel.H.
eatlabel.F.
eatlabel.D.
	JP eatlabel.B.
eatlabel.C.
	LD A,[eatlabel.token]
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,_TOKTEXT
	LD [asmtoken.A.],A
	CALL asmtoken
	LD HL,[_tword]
	LD [fputs.A.],HL
	LD HL,[_fout]
	LD [fputs.B.],HL
	CALL fputs
	LD A,_TOKENDTEXT
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	RET
eatval
	LD A,[eatval.opsym]
	LD DE,[_tword]
	LD L,A
	LD A,[DE]
	LD [eatval.opsym],A
	LD A,[_asmwaseof]
	CPL
	OR A
	PUSH HL
	JP Z,eatval.A.
	LD A,[eatval.opsym]
	SUB '0'
	LD E,0x0a
	SUB E
	JP NC,eatval.C.
	LD A,_TOKNUM
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,_TOKTEXT
	LD [asmtoken.A.],A
	CALL asmtoken
	LD HL,[_tword]
	LD [fputs.A.],HL
	LD HL,[_fout]
	LD [fputs.B.],HL
	CALL fputs
	LD A,_TOKENDTEXT
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	JP eatval.D.
eatval.C.
	LD HL,_isalphanum
	LD A,[eatval.opsym]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD A,[eatval.opsym]
	SUB '.'
	SUB 1
	SBC A,A
	OR L
	JP Z,eatval.E.
	LD A,_TOKLABEL
	LD [eatlabel.A.],A
	CALL eatlabel
	JP eatval.F.
eatval.E.
	LD A,[eatval.opsym]
	SUB '$'
	JP NZ,eatval.G.
	LD A,_TOKDOLLAR
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	JP eatval.H.
eatval.G.
	LD A,[eatval.opsym]
	SUB '('
	JP NZ,eatval.I.
	LD A,_TOKOPEN
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL tokexpr
	LD A,_TOKCLOSE
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	JP eatval.J.
eatval.I.
	LD A,[eatval.opsym]
	SUB '\''
	JP NZ,eatval.K.
	LD A,_TOKPRIME
	LD [asmtoken.A.],A
	CALL asmtoken
	LD HL,0
	LD [_lentword],HL
	LD A,'\''
	LD [rdquotes.A.],A
	CALL rdquotes
	CALL toktext
	CALL rdch
	LD A,_TOKPRIME
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	JP eatval.L.
eatval.K.
	LD A,[eatval.opsym]
	SUB '-'
	JP NZ,eatval.M.
	LD A,_OPPUSH0
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,_TOKMINUS
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatval
	LD A,_OPSUB
	LD [asmtoken.A.],A
	CALL asmtoken
	JP eatval.N.
eatval.M.
	LD A,[eatval.opsym]
	SUB '+'
	JP NZ,eatval.O.
	LD A,_OPPUSH0
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,_TOKPLUS
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatval
	LD A,_OPADD
	LD [asmtoken.A.],A
	CALL asmtoken
	JP eatval.P.
eatval.O.
	LD A,[eatval.opsym]
	SUB '*'
	JP NZ,eatval.Q.
	LD A,_OPPUSH0
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,_TOKSTAR
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatval
	LD A,_OPPEEK
	LD [asmtoken.A.],A
	CALL asmtoken
	JP eatval.R.
eatval.Q.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
eatval.R.
eatval.P.
eatval.N.
eatval.L.
eatval.J.
eatval.H.
eatval.F.
eatval.D.
eatval.A.
	POP HL
	LD A,L
	LD [eatval.opsym],A
	RET
eatmul
	LD A,_TOKSTAR
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatval
	LD A,_OPMUL
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eatdiv
	LD A,_TOKSLASH
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatval
	LD A,_OPDIV
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eatand
	LD A,_TOKAND
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatval
	LD A,_OPAND
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eatandbool
	LD A,_TOKAND
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,_TOKAND
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatval
	LD A,_OPAND
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eatmulval
	LD A,[eatmulval.opsym]
	LD L,A
	PUSH HL
	LD A,[eatmulval.dbl]
	LD L,A
	PUSH HL
	CALL eatval
eatmulval.A.
	LD A,[_asmwaseof]
	CPL
	LD DE,[_asmwaseols]
	LD BC,0
	LD L,A
	LD A,E
	SUB C
	JR NZ,$+0x4
	LD A,D
	SUB B
	SUB 1
	SBC A,A
	AND L
	JP Z,eatmulval.B.
	LD HL,[_tword]
	LD A,[HL]
	LD [eatmulval.opsym],A
	LD A,[eatmulval.opsym]
	SUB '&'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_cnext]
	LD E,A
	LD A,[eatmulval.opsym]
	SUB E
	SUB 1
	SBC A,A
	AND L
	LD [eatmulval.dbl],A
	LD A,[eatmulval.dbl]
	OR A
	JP Z,eatmulval.C.
	CALL asmrdword_tokspc
eatmulval.C.
	LD A,[eatmulval.opsym]
	SUB '*'
	JP NZ,eatmulval.E.
	CALL eatmul
	JP eatmulval.F.
eatmulval.E.
	LD A,[eatmulval.opsym]
	SUB '/'
	JP NZ,eatmulval.G.
	CALL eatdiv
	JP eatmulval.H.
eatmulval.G.
	LD A,[eatmulval.opsym]
	SUB '&'
	JP NZ,eatmulval.I.
	LD A,[eatmulval.dbl]
	OR A
	JP Z,eatmulval.K.
	CALL eatandbool
	JP eatmulval.L.
eatmulval.K.
	CALL eatand
eatmulval.L.
	JP eatmulval.J.
eatmulval.I.
	JP eatmulval.B.
eatmulval.J.
eatmulval.H.
eatmulval.F.
	JP eatmulval.A.
eatmulval.B.
	POP HL
	LD A,L
	LD [eatmulval.dbl],A
	POP HL
	LD A,L
	LD [eatmulval.opsym],A
	RET
eatadd
	LD A,_TOKPLUS
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatmulval
	LD A,_OPADD
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eatsub
	LD A,_TOKMINUS
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatmulval
	LD A,_OPSUB
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eator
	LD A,_TOKPIPE
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatmulval
	LD A,_OPOR
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eatorbool
	LD A,_TOKPIPE
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,_TOKPIPE
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatmulval
	LD A,_OPOR
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eatxor
	LD A,_TOKCARON
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatmulval
	LD A,_OPXOR
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eatxorbool
	LD A,_TOKCARON
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,_TOKCARON
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatmulval
	LD A,_OPXOR
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eatsumval
	LD A,[eatsumval.opsym]
	LD L,A
	PUSH HL
	LD A,[eatsumval.dbl]
	LD L,A
	PUSH HL
	CALL eatmulval
eatsumval.A.
	LD A,[_asmwaseof]
	CPL
	LD DE,[_asmwaseols]
	LD BC,0
	LD L,A
	LD A,E
	SUB C
	JR NZ,$+0x4
	LD A,D
	SUB B
	SUB 1
	SBC A,A
	AND L
	JP Z,eatsumval.B.
	LD HL,[_tword]
	LD A,[HL]
	LD [eatsumval.opsym],A
	LD A,[eatsumval.opsym]
	SUB '|'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[eatsumval.opsym]
	SUB '^'
	SUB 1
	SBC A,A
	OR L
	LD L,A
	LD A,[_cnext]
	LD E,A
	LD A,[eatsumval.opsym]
	SUB E
	SUB 1
	SBC A,A
	AND L
	LD [eatsumval.dbl],A
	LD A,[eatsumval.dbl]
	OR A
	JP Z,eatsumval.C.
	CALL asmrdword_tokspc
eatsumval.C.
	LD A,[eatsumval.opsym]
	SUB '+'
	JP NZ,eatsumval.E.
	CALL eatadd
	JP eatsumval.F.
eatsumval.E.
	LD A,[eatsumval.opsym]
	SUB '-'
	JP NZ,eatsumval.G.
	CALL eatsub
	JP eatsumval.H.
eatsumval.G.
	LD A,[eatsumval.opsym]
	SUB '|'
	JP NZ,eatsumval.I.
	LD A,[eatsumval.dbl]
	OR A
	JP Z,eatsumval.K.
	CALL eatorbool
	JP eatsumval.L.
eatsumval.K.
	CALL eator
eatsumval.L.
	JP eatsumval.J.
eatsumval.I.
	LD A,[eatsumval.opsym]
	SUB '^'
	JP NZ,eatsumval.M.
	LD A,[eatsumval.dbl]
	OR A
	JP Z,eatsumval.O.
	CALL eatxorbool
	JP eatsumval.P.
eatsumval.O.
	CALL eatxor
eatsumval.P.
	JP eatsumval.N.
eatsumval.M.
	JP eatsumval.B.
eatsumval.N.
eatsumval.J.
eatsumval.H.
eatsumval.F.
	JP eatsumval.A.
eatsumval.B.
	POP HL
	LD A,L
	LD [eatsumval.dbl],A
	POP HL
	LD A,L
	LD [eatsumval.opsym],A
	RET
eatshl
	LD A,_TOKLESS
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,_TOKLESS
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatsumval
	LD A,_OPSHL
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eatshr
	LD A,_TOKMORE
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,_TOKMORE
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatsumval
	LD A,_OPSHR
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eatless
	LD A,_TOKLESS
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatsumval
	LD A,_OPLESS
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eatlesseq
	LD A,_TOKLESS
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,_TOKEQUAL
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatsumval
	LD A,_OPLESSEQ
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eatmore
	LD A,_TOKMORE
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatsumval
	LD A,_OPMORE
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eatmoreeq
	LD A,_TOKMORE
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,_TOKEQUAL
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatsumval
	LD A,_OPMOREEQ
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eateq
	LD A,_TOKEQUAL
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,_TOKEQUAL
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatsumval
	LD A,_OPEQ
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
eatnoteq
	LD A,_TOKEXCL
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,_TOKEQUAL
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL eatsumval
	LD A,_OPNOTEQ
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
tokexpr
	LD A,[tokexpr.opsym]
	LD L,A
	PUSH HL
	LD A,[tokexpr.modified]
	LD L,A
	PUSH HL
	LD A,[tokexpr.dbl]
	LD L,A
	PUSH HL
	CALL matchdirect
	CALL eatsumval
tokexpr.A.
	LD A,[_asmwaseof]
	CPL
	LD DE,[_asmwaseols]
	LD BC,0
	LD L,A
	LD A,E
	SUB C
	JR NZ,$+0x4
	LD A,D
	SUB B
	SUB 1
	SBC A,A
	AND L
	JP Z,tokexpr.B.
	LD HL,[_tword]
	LD A,[HL]
	LD [tokexpr.opsym],A
	LD A,[_cnext]
	SUB '='
	SUB 1
	SBC A,A
	LD [tokexpr.modified],A
	LD A,[_cnext]
	LD L,A
	LD A,[tokexpr.opsym]
	SUB L
	SUB 1
	SBC A,A
	LD [tokexpr.dbl],A
	LD A,[tokexpr.modified]
	LD L,A
	LD A,[tokexpr.dbl]
	OR L
	JP Z,tokexpr.C.
	CALL asmrdword_tokspc
tokexpr.C.
	LD A,[tokexpr.opsym]
	SUB '<'
	JP NZ,tokexpr.E.
	LD A,[tokexpr.dbl]
	OR A
	JP Z,tokexpr.G.
	CALL eatshl
	JP tokexpr.H.
tokexpr.G.
	LD A,[tokexpr.modified]
	OR A
	JP Z,tokexpr.I.
	CALL eatlesseq
	JP tokexpr.J.
tokexpr.I.
	CALL eatless
tokexpr.J.
tokexpr.H.
	JP tokexpr.F.
tokexpr.E.
	LD A,[tokexpr.opsym]
	SUB '>'
	JP NZ,tokexpr.K.
	LD A,[tokexpr.dbl]
	OR A
	JP Z,tokexpr.M.
	CALL eatshr
	JP tokexpr.N.
tokexpr.M.
	LD A,[tokexpr.modified]
	OR A
	JP Z,tokexpr.O.
	CALL eatmoreeq
	JP tokexpr.P.
tokexpr.O.
	CALL eatmore
tokexpr.P.
tokexpr.N.
	JP tokexpr.L.
tokexpr.K.
	LD A,[tokexpr.opsym]
	SUB '='
	JP NZ,tokexpr.Q.
	CALL eateq
	JP tokexpr.R.
tokexpr.Q.
	LD A,[tokexpr.opsym]
	SUB '!'
	JP NZ,tokexpr.S.
	CALL eatnoteq
	JP tokexpr.T.
tokexpr.S.
	JP tokexpr.B.
tokexpr.T.
tokexpr.R.
tokexpr.L.
tokexpr.F.
	JP tokexpr.A.
tokexpr.B.
	LD A,TRUE
	POP DE
	LD L,A
	LD A,E
	LD [tokexpr.dbl],A
	POP DE
	LD A,E
	LD [tokexpr.modified],A
	POP DE
	LD A,E
	LD [tokexpr.opsym],A
	LD A,L
	RET
tokexpr_close
	CALL tokexpr
	LD [tokexpr_close.ok],A
	LD A,[tokexpr_close.ok]
	OR A
	JP Z,tokexpr_close.A.
	CALL matchclose
	LD [tokexpr_close.ok],A
tokexpr_close.A.
	LD A,[tokexpr_close.ok]
	RET
asm_direct_expr_close_token
	CALL tokexpr
	OR A
	JP Z,asm_direct_expr_close_token.B.
	CALL matchclose
	OR A
	JP Z,asm_direct_expr_close_token.D.
	LD A,[asm_direct_expr_close_token.token]
	LD [asmtoken.A.],A
	CALL asmtoken
	JP asm_direct_expr_close_token.E.
asm_direct_expr_close_token.D.
	LD A,_ERRCLOSE
	LD [tokerr.A.],A
	CALL tokerr
asm_direct_expr_close_token.E.
	JP asm_direct_expr_close_token.C.
asm_direct_expr_close_token.B.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
asm_direct_expr_close_token.C.
	RET
tokcomment
	LD A,_TOKCOMMENT
	LD [asmtoken.A.],A
	CALL asmtoken
	LD HL,0
	LD [_lentword],HL
	LD HL,[_waseols]
	LD DE,0
	OR A
	SBC HL,DE
	JP NZ,tokcomment.A.
tokcomment.C.
	LD HL,[_spcsize]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,tokcomment.D.
	LD HL,[_tword]
	LD [stradd.A.],HL
	LD HL,[_lentword]
	LD [stradd.B.],HL
	LD A,' '
	LD [stradd.C.],A
	CALL stradd
	LD [_lentword],HL
	LD HL,[_spcsize]
	DEC HL
	LD [_spcsize],HL
	JP tokcomment.C.
tokcomment.D.
tokcomment.E.
	LD HL,[_waseols]
	LD DE,0
	OR A
	SBC HL,DE
	JP NZ,tokcomment.F.
	CALL rdchcmt
	JP tokcomment.E.
tokcomment.F.
tokcomment.A.
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,0x00
	LD [HL],A
	CALL toktext
	LD A,_TOKENDCOMMENT
	LD [asmtoken.A.],A
	CALL asmtoken
	LD A,[_cnext]
	LD E,'!'
	SUB E
	JP NC,tokcomment.G.
	LD A,[_cnext]
	SUB '\t'
	JP NZ,tokcomment.I.
	LD HL,[_spcsize]
	LD DE,8
	ADD HL,DE
	LD [_spcsize],HL
	JP tokcomment.J.
tokcomment.I.
	LD HL,[_spcsize]
	INC HL
	LD [_spcsize],HL
tokcomment.J.
	CALL rdch
tokcomment.G.
	CALL asmrdword_tokspc
	RET
tokorg
	LD A,_CMDORG
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL tokexpr
	OR A
	JP Z,tokorg.A.
	LD A,_FMTCMD
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokorg.B.
tokorg.A.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokorg.B.
	RET
tokalign
	LD A,_CMDALIGN
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL tokexpr
	OR A
	JP Z,tokalign.A.
	LD A,_FMTCMD
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokalign.B.
tokalign.A.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokalign.B.
	RET
tokexport
	LD A,_CMDEXPORT
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,_TOKLABEL
	LD [eatlabel.A.],A
	CALL eatlabel
	LD A,_FMTCMD
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
tokinclude
	LD A,_CMDINCLUDE
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matchquote
	OR A
	JP Z,tokinclude.A.
	LD HL,0
	LD [_lentword],HL
	LD A,'\"'
	LD [rdquotes.A.],A
	CALL rdquotes
	CALL toktext
	CALL rdch
	LD A,_TOKDBLQUOTESYM
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	JP tokinclude.B.
tokinclude.A.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokinclude.B.
	RET
tokincbin
	LD A,_CMDINCBIN
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matchquote
	OR A
	JP Z,tokincbin.A.
	LD HL,0
	LD [_lentword],HL
	LD A,'\"'
	LD [rdquotes.A.],A
	CALL rdquotes
	CALL toktext
	CALL rdch
	LD A,_TOKDBLQUOTESYM
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	JP tokincbin.B.
tokincbin.A.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokincbin.B.
	RET
tokdb
	LD A,_CMDDB
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
tokdb.A.
	CALL matchquote
	OR A
	JP Z,tokdb.C.
	LD A,_OPWRSTR
	LD [asmtoken.A.],A
	CALL asmtoken
	LD HL,0
	LD [_lentword],HL
	LD A,'\"'
	LD [rdquotes.A.],A
	CALL rdquotes
	CALL toktext
	CALL rdch
	LD A,_TOKDBLQUOTESYM
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	JP tokdb.D.
tokdb.C.
	CALL tokexpr
	OR A
	JP Z,tokdb.E.
	LD A,_OPWRVAL
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokdb.F.
tokdb.E.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokdb.F.
tokdb.D.
	CALL matchcomma
	CPL
	OR A
	JP Z,tokdb.A.
tokdb.B.
	LD A,_FMTCMD
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
tokdw
	LD A,_CMDDW
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
tokdw.A.
	CALL tokexpr
	LD A,_OPWRVAL
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL matchcomma
	CPL
	OR A
	JP Z,tokdw.A.
tokdw.B.
	LD A,_FMTCMD
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
tokdl
	LD A,_CMDDL
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
tokdl.A.
	CALL tokexpr
	LD A,_OPWRVAL
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL matchcomma
	CPL
	OR A
	JP Z,tokdl.A.
tokdl.B.
	LD A,_FMTCMD
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
tokds
	LD A,_CMDDS
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL tokexpr
tokds.A.
	CALL matchcomma
	OR A
	JP Z,tokds.B.
	CALL tokexpr
	JP tokds.A.
tokds.B.
	LD A,_FMTCMD
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
tokcolon
	LD A,_TOKCOLON
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	RET
tokcmd
	LD HL,[_tword]
	LD A,[HL]
	SUB ';'
	JP NZ,tokcmd.A.
	CALL tokcomment
	JP tokcmd.B.
tokcmd.A.
	LD HL,[_asmspcsize]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,tokcmd.C.
	CALL tokcalllbl
	JP tokcmd.D.
tokcmd.C.
	LD A,_CMDLABEL
	LD [eatlabel.A.],A
	CALL eatlabel
	CALL matchreequ
	OR A
	JP Z,tokcmd.E.
	CALL tokexpr
	OR A
	JP Z,tokcmd.G.
	LD A,_FMTREEQU
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokcmd.H.
tokcmd.G.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokcmd.H.
	JP tokcmd.F.
tokcmd.E.
	LD A,_FMTCMD
	LD [asmtoken.A.],A
	CALL asmtoken
tokcmd.F.
tokcmd.D.
tokcmd.B.
	LD HL,[_asmwaseols]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,tokcmd.I.
tokcmd.K.
	LD HL,[_asmwaseols]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,tokcmd.L.
	LD A,_TOKEOL
	LD [asmtoken.A.],A
	CALL asmtoken
	LD HL,[_asmwaseols]
	DEC HL
	LD [_asmwaseols],HL
	JP tokcmd.K.
tokcmd.L.
	CALL tokspc
tokcmd.I.
	RET
tokinit
	LD HL,_stokfn
	LD [_tokfn],HL
	CALL tokinitlblbuf
	CALL tokpre
	RET
tokenize
	LD HL,[tokenize.fn]
	LD [nfopen.A.],HL
	LD HL,tokenize.B.
	LD [nfopen.B.],HL
	CALL nfopen
	LD [_fin],HL
	LD HL,[_fin]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,tokenize.C.
	LD A,FALSE
	LD [_waseof],A
	LD HL,1
	LD [_curline],HL
	CALL initrd
	LD HL,0
	LD [_lentokfn],HL
	LD HL,0
	LD [tokenize.i],HL
tokenize.E.
	LD HL,[tokenize.fn]
	LD DE,[_lentokfn]
	ADD HL,DE
	LD A,[HL]
	SUB 0x00
	JP Z,tokenize.F.
	LD HL,[_tokfn]
	LD DE,[_lentokfn]
	ADD HL,DE
	LD DE,[tokenize.fn]
	LD BC,[_lentokfn]
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	LD A,[DE]
	LD [HL],A
	LD HL,[tokenize.fn]
	LD DE,[_lentokfn]
	ADD HL,DE
	LD A,[HL]
	SUB '.'
	JP NZ,tokenize.G.
	LD HL,[_lentokfn]
	LD [tokenize.i],HL
tokenize.G.
	LD HL,[_lentokfn]
	INC HL
	LD [_lentokfn],HL
	JP tokenize.E.
tokenize.F.
	LD HL,[tokenize.i]
	LD DE,1
	ADD HL,DE
	LD [_lentokfn],HL
	LD HL,[_tokfn]
	LD [stradd.A.],HL
	LD HL,[_lentokfn]
	LD [stradd.B.],HL
	LD HL,[tokenize.fn]
	LD DE,[_lentokfn]
	ADD HL,DE
	LD A,[HL]
	LD E,0xdf
	AND E
	LD [stradd.C.],A
	CALL stradd
	LD [_lentokfn],HL
	LD HL,[_tokfn]
	LD [stradd.A.],HL
	LD HL,[_lentokfn]
	LD [stradd.B.],HL
	LD A,'_'
	LD [stradd.C.],A
	CALL stradd
	LD [_lentokfn],HL
	LD HL,[_tokfn]
	LD DE,[_lentokfn]
	ADD HL,DE
	LD A,0x00
	LD [HL],A
	LD HL,[_tokfn]
	LD [openwrite.A.],HL
	CALL openwrite
	LD [_fout],HL
	LD HL,0
	LD [_asmwaseols],HL
	LD A,FALSE
	LD [_asmwaseof],A
	CALL asmrdword_tokspc
tokenize.I.
	LD A,[_asmwaseof]
	CPL
	OR A
	JP Z,tokenize.J.
	CALL tokcmd
	JP tokenize.I.
tokenize.J.
	LD A,_TOKEOF
	LD [asmtoken.A.],A
	CALL asmtoken
	LD HL,[_fout]
	LD [closewrite.A.],HL
	CALL closewrite
	LD HL,[_fin]
	LD [fclose.A.],HL
	CALL fclose
tokenize.C.
	RET
tokenize_end
	RET
