err_tword
	LD HL,[err_tword.s]
	LD [errstr.A.],HL
	CALL errstr
	LD HL,err_tword.B.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[_tword]
	LD [errstr.A.],HL
	CALL errstr
	LD A,'\''
	LD [err.A.],A
	CALL err
	CALL enderr
	RET
doexp
	LD A,[_isexp]
	OR A
	JP Z,doexp.A.
	LD HL,[_joined]
	LD [emitexport.A.],HL
	CALL emitexport
doexp.A.
	RET
eat
	LD HL,[_tword]
	LD A,[HL]
	LD L,A
	LD A,[eat.c]
	SUB L
	JP Z,eat.B.
	LD A,[eat.c]
	LD [err.A.],A
	CALL err
	LD HL,eat.D.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[_tword]
	LD [errstr.A.],HL
	CALL errstr
	LD A,'\''
	LD [err.A.],A
	CALL err
	CALL enderr
eat.B.
	CALL rdword
	RET
jdot
	LD HL,[_joined]
	LD [stradd.A.],HL
	LD HL,[_lenjoined]
	LD [stradd.B.],HL
	LD A,'.'
	LD [stradd.C.],A
	CALL stradd
	LD [_lenjoined],HL
	LD HL,[_joined]
	LD DE,[_lenjoined]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	RET
gendig
	LD A,'A'
	LD [gendig.dig],A
gendig.B.
	LD HL,[_genn]
	LD DE,[gendig.d]
	LD A,L
	SUB E
	LD A,H
	SBC A,D
	JP C,gendig.C.
	LD HL,[_genn]
	LD DE,[gendig.d]
	OR A
	SBC HL,DE
	LD [_genn],HL
	LD HL,gendig.dig
	INC [HL]
	LD A,TRUE
	LD [_wasdig],A
	JP gendig.B.
gendig.C.
	LD A,[_wasdig]
	OR A
	JP Z,gendig.D.
	LD HL,[_joined]
	LD [stradd.A.],HL
	LD HL,[_lenjoined]
	LD [stradd.B.],HL
	LD A,[gendig.dig]
	LD [stradd.C.],A
	CALL stradd
	LD [_lenjoined],HL
gendig.D.
	RET
jautonum
	LD HL,[jautonum.n]
	LD [_genn],HL
	LD A,TRUE
	LD [_wasdig],A
	LD HL,[jautonum.n]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,jautonum.B.
	LD A,FALSE
	LD [_wasdig],A
	LD HL,676
	LD [gendig.A.],HL
	CALL gendig
	LD HL,26
	LD [gendig.A.],HL
	CALL gendig
jautonum.B.
	LD HL,1
	LD [gendig.A.],HL
	CALL gendig
	CALL jdot
	RET
genjplbl
	LD HL,[_title]
	LD [strcopy.A.],HL
	LD HL,[_lentitle]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	LD HL,[genjplbl.n]
	LD [jautonum.A.],HL
	CALL jautonum
	RET
jtitletword
	LD HL,[_title]
	LD [strcopy.A.],HL
	LD HL,[_lentitle]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	LD HL,[_joined]
	LD [strjoin.A.],HL
	LD HL,[_lenjoined]
	LD [strjoin.B.],HL
	LD HL,[_tword]
	LD [strjoin.C.],HL
	CALL strjoin
	LD [_lenjoined],HL
	LD HL,[_joined]
	LD DE,[_lenjoined]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	RET
do_type
do_type.loop
	LD HL,[_tword]
	LD [strcopy.A.],HL
	LD HL,[_lentword]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	CALL lbltype
	LD [_t],A
	LD A,[_t]
	LD E,_T_TYPE
	AND E
	SUB 0x00
	JP Z,do_type.A.
	LD A,[_t]
	LD E,_T_TYPE
	LD L,A
	LD A,E
	ADD A,_T_STRUCTWORD
	SUB L
	JP NZ,do_type.C.
	CALL rdword
	JP do_type.loop
do_type.C.
	LD A,[_cnext]
	SUB '*'
	JP NZ,do_type.E.
	LD A,[_t]
	LD E,_T_POI
	OR E
	LD [_t],A
	LD A,_SZ_REG
	LD L,A
	LD H,0
	LD [_varsz],HL
	CALL rdword
do_type.E.
do_type.A.
	RET
eattype
	CALL do_type
	LD A,[_t]
	LD E,_T_TYPE
	LD L,A
	LD A,E
	CPL
	AND L
	LD [_t],A
	CALL rdword
	RET
doprefix
	LD HL,0
	LD [_lenprefix],HL
doprefix.B.
	LD A,[doprefix.nb]
	LD E,0x00
	LD L,A
	LD A,E
	SUB L
	JP NC,doprefix.C.
	LD HL,[_prefix]
	LD [strjoineol.A.],HL
	LD HL,[_lenprefix]
	LD [strjoineol.B.],HL
	LD HL,[_title]
	LD DE,[_lenprefix]
	ADD HL,DE
	LD [strjoineol.C.],HL
	LD A,'.'
	LD [strjoineol.D.],A
	CALL strjoineol
	LD [_lenprefix],HL
	LD HL,[_prefix]
	LD [stradd.A.],HL
	LD HL,[_lenprefix]
	LD [stradd.B.],HL
	LD A,'.'
	LD [stradd.C.],A
	CALL stradd
	LD [_lenprefix],HL
	LD HL,doprefix.nb
	DEC [HL]
	JP doprefix.B.
doprefix.C.
	LD HL,[_prefix]
	LD DE,[_lenprefix]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	LD HL,[_prefix]
	LD [strcopy.A.],HL
	LD HL,[_lenprefix]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	LD HL,[_joined]
	LD [strjoin.A.],HL
	LD HL,[_lenjoined]
	LD [strjoin.B.],HL
	LD HL,[_tword]
	LD [strjoin.C.],HL
	CALL strjoin
	LD [_lenjoined],HL
	LD HL,[_joined]
	LD DE,[_lenjoined]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	RET
adddots
	RET
joinvarname
	CALL do_type
	LD A,[_isloc]
	CPL
	OR A
	JP Z,joinvarname.B.
	LD HL,[_tword]
	LD [strcopy.A.],HL
	LD HL,[_lentword]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	JP joinvarname.C.
joinvarname.B.
	LD A,[_namespclvl]
	LD [joinvarname.lvl],A
	LD A,[joinvarname.iscall]
	LD L,A
	LD A,[joinvarname.lvl]
	SUB 0x00
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,joinvarname.D.
	LD HL,joinvarname.lvl
	DEC [HL]
joinvarname.D.
	LD A,[joinvarname.lvl]
	LD [doprefix.A.],A
	CALL doprefix
joinvarname.C.
	RET
eatvarname
	CALL eattype
	CALL adddots
	LD HL,[_tword]
	LD [strcopy.A.],HL
	LD HL,[_lentword]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,[_namespclvl]
	LD [doprefix.A.],A
	CALL doprefix
	CALL rdword
	LD HL,[_tword]
	LD A,[HL]
	SUB '['
	JP NZ,eatvarname.A.
	LD A,[_t]
	LD E,_T_ARRAY
	OR E
	LD [_t],A
eatvarname.A.
	RET
getstructfield
	LD HL,[_joined]
	LD [gettypename.A.],HL
	CALL gettypename
	LD [_lenjoined],HL
	LD A,'>'
	LD [eat.A.],A
	CALL eat
	CALL jdot
	LD HL,[_joined]
	LD [strjoin.A.],HL
	LD HL,[_lenjoined]
	LD [strjoin.B.],HL
	LD HL,[_tword]
	LD [strjoin.C.],HL
	CALL strjoin
	LD [_lenjoined],HL
	LD HL,[_joined]
	LD DE,[_lenjoined]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	CALL cmdpushnum
	CALL cmdadd
	LD HL,[_joined]
	LD [strcopy.A.],HL
	LD HL,[_lenjoined]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	CALL lbltype
	LD [_t],A
	RET
varstrz
	LD HL,[_joined]
	LD [emitvarlabel.A.],HL
	CALL emitvarlabel
varstrz.A.
	LD A,TRUE
	OR A
	JP Z,varstrz.B.
	LD A,'\"'
	LD [rdquotes.A.],A
	CALL rdquotes
	CALL rdch
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	CALL var_db
	LD HL,[_tword]
	LD [varstr.A.],HL
	CALL varstr
	CALL endvar
	LD A,[_cnext]
	SUB '\"'
	JP Z,varstrz.C.
	JP varstrz.B.
varstrz.C.
	CALL rdword
	JP varstrz.A.
varstrz.B.
	CALL var_db
	LD A,'0'
	LD [varc.A.],A
	CALL varc
	CALL endvar
	RET
asmstrz
	LD HL,[_joined]
	LD [emitasmlabel.A.],HL
	CALL emitasmlabel
asmstrz.A.
	LD A,TRUE
	OR A
	JP Z,asmstrz.B.
	LD A,'\"'
	LD [rdquotes.A.],A
	CALL rdquotes
	CALL rdch
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	CALL asm_db
	LD HL,[_tword]
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	LD A,[_cnext]
	SUB '\"'
	JP Z,asmstrz.C.
	JP asmstrz.B.
asmstrz.C.
	CALL rdword
	JP asmstrz.A.
asmstrz.B.
	CALL asm_db
	LD A,'0'
	LD [asmc.A.],A
	CALL asmc
	CALL endasm
	RET
eatidx
	LD HL,_exprlvl
	INC [HL]
	CALL eatexpr
	LD HL,_exprlvl
	DEC [HL]
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,eatidx.A.
	LD A,_T_UINT
	LD [cmdcastto.A.],A
	CALL cmdcastto
eatidx.A.
	LD A,[_t]
	SUB _T_UINT
	JP Z,eatidx.C.
	LD HL,eatidx.E.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[_t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	CALL enderr
eatidx.C.
	RET
idxarray
	CALL rdword
	LD A,[idxarray.t]
	LD E,_T_ARRAY
	AND E
	SUB 0x00
	JP Z,idxarray.B.
	LD A,[idxarray.t]
	LD E,_TYPEMASK
	AND E
	LD [idxarray.t],A
	LD A,_T_POI
	LD E,_T_BYTE
	OR E
	LD [_t],A
	CALL cmdpushnum
	JP idxarray.C.
idxarray.B.
	LD A,[idxarray.t]
	LD E,_T_POI
	AND E
	SUB 0x00
	JP Z,idxarray.D.
	LD A,[idxarray.t]
	LD [_t],A
	CALL cmdpushvar
	LD A,[idxarray.t]
	LD E,_T_POI
	LD L,A
	LD A,E
	CPL
	AND L
	LD [idxarray.t],A
	JP idxarray.E.
idxarray.D.
	LD HL,idxarray.F.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[idxarray.t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	CALL enderr
idxarray.E.
idxarray.C.
	CALL eatidx
	LD A,[idxarray.t]
	LD [_t],A
	CALL cmdaddpoi
	LD A,[idxarray.t]
	RET
numtype
	LD HL,[_tword]
	LD A,[HL]
	SUB '-'
	JP NZ,numtype.A.
	LD A,_T_INT
	LD [_t],A
	JP numtype.B.
numtype.A.
	LD HL,[_tword]
	LD DE,[_lentword]
	LD BC,1
	LD A,E
	SUB C
	LD E,A
	LD A,D
	SBC A,B
	LD D,A
	ADD HL,DE
	LD A,[HL]
	SUB 'L'
	JP NZ,numtype.C.
	LD A,_T_LONG
	LD [_t],A
	JP numtype.D.
numtype.C.
	LD HL,[_tword]
	LD DE,1
	ADD HL,DE
	LD A,[HL]
	LD E,'9'
	LD L,A
	LD A,E
	SUB L
	JP NC,numtype.E.
	LD HL,[_lentword]
	LD DE,4
	LD A,E
	SUB L
	LD A,D
	SBC A,H
	CCF
	SBC A,A
	LD DE,[_tword]
	LD BC,1
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	LD L,A
	LD A,[DE]
	SUB 'x'
	SUB 1
	SBC A,A
	AND L
	JP Z,numtype.G.
	LD A,_T_BYTE
	LD [_t],A
	JP numtype.H.
numtype.G.
	LD HL,[_lentword]
	LD DE,10
	LD A,E
	SUB L
	LD A,D
	SBC A,H
	CCF
	SBC A,A
	LD DE,[_tword]
	LD BC,1
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	LD L,A
	LD A,[DE]
	SUB 'b'
	SUB 1
	SBC A,A
	AND L
	JP Z,numtype.I.
	LD A,_T_BYTE
	LD [_t],A
	JP numtype.J.
numtype.I.
	LD A,_T_UINT
	LD [_t],A
numtype.J.
numtype.H.
	JP numtype.F.
numtype.E.
	LD A,_T_UINT
	LD [_t],A
numtype.F.
numtype.D.
numtype.B.
	RET
val
	LD A,[val.t]
	LD DE,[_tword]
	LD L,A
	LD A,[DE]
	LD [_opsym],A
	LD A,[_opsym]
	SUB '\''
	PUSH HL
	JP NZ,val.A.
	LD A,'\''
	LD [rdquotes.A.],A
	CALL rdquotes
	CALL rdch
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	LD HL,[_tword]
	LD [strcopy.A.],HL
	LD HL,[_lentword]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	LD A,_T_CHAR
	LD [_t],A
	CALL cmdpushnum
	JP val.B.
val.A.
	LD A,[_opsym]
	SUB '\"'
	JP NZ,val.C.
	LD HL,[_title]
	LD [strcopy.A.],HL
	LD HL,[_lentitle]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	LD HL,[_curlbl]
	LD [jautonum.A.],HL
	CALL jautonum
	LD HL,[_curlbl]
	INC HL
	LD [_curlbl],HL
	LD A,_T_POI
	LD E,_T_CHAR
	OR E
	LD [_t],A
	CALL cmdpushnum
	CALL varstrz
	JP val.D.
val.C.
	LD A,[_opsym]
	SUB '+'
	JP NZ,val.E.
	CALL rdword
	LD HL,[_tword]
	LD A,[HL]
	LD [_opsym],A
	LD A,[_opsym]
	SUB '_'
	JP NZ,val.G.
	CALL adddots
	LD A,FALSE
	LD [joinvarname.A.],A
	CALL joinvarname
	LD HL,[_name]
	LD [strcopy.A.],HL
	LD HL,[_lenname]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	LD A,_T_BYTE
	LD [_t],A
	CALL cmdpushnum
	JP val.H.
val.G.
	LD A,[_opsym]
	SUB '0'
	LD E,0x0a
	SUB E
	JP NC,val.I.
	LD A,[_waseof]
	CPL
	OR A
	JP Z,val.K.
	CALL val
val.K.
	LD A,[_t]
	SUB _T_UINT
	JP NZ,val.M.
	LD A,_T_INT
	LD [cmdcastto.A.],A
	CALL cmdcastto
val.M.
	JP val.J.
val.I.
	LD A,[_opsym]
	SUB '('
	JP Z,val.O.
	LD A,[_opsym]
	SUB 's'
	JP NZ,val.Q.
	CALL rdword
	LD A,'('
	LD [eat.A.],A
	CALL eat
	CALL eattype
	LD HL,[_varsz]
	LD [emitn.A.],HL
	CALL emitn
	LD HL,_nbuf
	LD [strcopy.A.],HL
	LD HL,[_lennbuf]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	LD A,_T_UINT
	LD [_t],A
	CALL cmdpushnum
	JP val.R.
val.Q.
	LD HL,[_tword]
	LD [strcopy.A.],HL
	LD HL,[_lentword]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	LD A,_T_BOOL
	LD [_t],A
	CALL cmdpushnum
val.R.
	JP val.P.
val.O.
	LD A,[_waseof]
	CPL
	OR A
	JP Z,val.S.
	CALL val
val.S.
val.P.
val.J.
val.H.
	JP val.F.
val.E.
	LD A,[_opsym]
	SUB '0'
	LD E,0x0a
	SUB E
	JP NC,val.U.
	CALL numtype
	LD HL,[_tword]
	LD [strcopy.A.],HL
	LD HL,[_lentword]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	CALL cmdpushnum
	JP val.V.
val.U.
	LD HL,_isalphanum
	LD A,[_opsym]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	OR A
	JP Z,val.W.
	CALL adddots
	LD A,[_cnext]
	SUB '('
	JP NZ,val.Y.
	LD A,[do_call.A.]
	LD E,TRUE
	LD L,A
	LD A,E
	LD [do_call.A.],A
	PUSH HL
	CALL do_call
	POP DE
	LD L,A
	LD A,E
	LD [do_call.A.],A
	LD A,L
	LD [_t],A
	JP val.Z.
val.Y.
	LD A,FALSE
	LD [joinvarname.A.],A
	CALL joinvarname
	LD A,[_cnext]
	SUB '['
	JP NZ,val.BA.
	CALL rdword
	LD A,[idxarray.A.]
	LD L,A
	LD A,[_t]
	LD [idxarray.A.],A
	PUSH HL
	CALL idxarray
	POP DE
	LD L,A
	LD A,E
	LD [idxarray.A.],A
	LD A,L
	LD [_t],A
	CALL cmdpeek
	JP val.BB.
val.BA.
	LD A,[_t]
	LD E,_T_TYPE
	AND E
	SUB 0x00
	JP NZ,val.BC.
	LD A,[_t]
	LD E,_T_ARRAY
	AND E
	SUB 0x00
	JP Z,val.BE.
	LD A,[_t]
	LD E,_T_ARRAY
	LD C,_T_CONST
	LD L,A
	LD A,E
	OR C
	CPL
	AND L
	LD E,_T_POI
	OR E
	LD [_t],A
	CALL cmdpushnum
	JP val.BF.
val.BE.
	LD A,[_t]
	LD E,_T_CONST
	AND E
	SUB 0x00
	JP NZ,val.BG.
	CALL cmdpushvar
	JP val.BH.
val.BG.
	LD A,[_t]
	LD E,_TYPEMASK
	AND E
	LD [_t],A
	CALL cmdpushnum
val.BH.
val.BF.
val.BC.
val.BB.
val.Z.
	JP val.X.
val.W.
	LD A,[_opsym]
	SUB '('
	JP NZ,val.BI.
	CALL rdword
	CALL eatexpr
	LD A,[_t]
	LD E,_T_TYPE
	AND E
	SUB 0x00
	JP Z,val.BK.
	LD A,[_t]
	LD E,_T_TYPE
	LD L,A
	LD A,E
	CPL
	AND L
	LD [val.t],A
	LD A,[val.t]
	LD [_t],A
	CALL rdword
	CALL val
	LD A,[val.t]
	LD [cmdcastto.A.],A
	CALL cmdcastto
val.BK.
	JP val.BJ.
val.BI.
	LD A,[_opsym]
	SUB '-'
	JP NZ,val.BM.
	LD A,[_cnext]
	SUB '0'
	LD E,0x0a
	SUB E
	JP NC,val.BO.
	CALL rdaddword
	LD A,_T_INT
	LD [_t],A
	LD HL,[_tword]
	LD [strcopy.A.],HL
	LD HL,[_lentword]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	CALL cmdpushnum
	JP val.BP.
val.BO.
	CALL rdword
	LD A,[_waseof]
	CPL
	OR A
	JP Z,val.BQ.
	CALL val
val.BQ.
	CALL cmdneg
val.BP.
	JP val.BN.
val.BM.
	LD A,[_opsym]
	SUB '!'
	JP NZ,val.BS.
	CALL rdword
	LD A,[_waseof]
	CPL
	OR A
	JP Z,val.BU.
	CALL val
val.BU.
	CALL cmdinv
	JP val.BT.
val.BS.
	LD A,[_opsym]
	SUB '~'
	JP NZ,val.BW.
	CALL rdword
	LD A,[_waseof]
	CPL
	OR A
	JP Z,val.BY.
	CALL val
val.BY.
	CALL cmdinv
	JP val.BX.
val.BW.
	LD A,[_opsym]
	SUB '*'
	JP NZ,val.CA.
	CALL rdword
	LD A,[_waseof]
	CPL
	OR A
	JP Z,val.CC.
	CALL val
val.CC.
	LD A,[_t]
	LD E,_T_POI
	LD L,A
	LD A,E
	CPL
	AND L
	LD [_t],A
	CALL cmdpeek
	JP val.CB.
val.CA.
	LD A,[_opsym]
	SUB '&'
	JP NZ,val.CE.
	LD A,[_cnext]
	SUB '('
	JP NZ,val.CG.
	LD A,TRUE
	LD [_addrexpr],A
	CALL rdword
	CALL val
	LD A,[_t]
	LD E,_T_POI
	OR E
	LD [_t],A
	JP val.CH.
val.CG.
	CALL rdword
	CALL adddots
	LD A,FALSE
	LD [joinvarname.A.],A
	CALL joinvarname
	LD A,[_cnext]
	SUB '['
	JP NZ,val.CI.
	CALL rdword
	LD A,[idxarray.A.]
	LD L,A
	LD A,[_t]
	LD [idxarray.A.],A
	PUSH HL
	CALL idxarray
	POP DE
	LD L,A
	LD A,E
	LD [idxarray.A.],A
	LD A,_T_POI
	OR L
	LD [_t],A
	JP val.CJ.
val.CI.
	LD A,[_t]
	LD E,_TYPEMASK
	AND E
	LD E,_T_POI
	OR E
	LD [_t],A
	CALL cmdpushnum
val.CJ.
val.CH.
	JP val.CF.
val.CE.
	LD HL,val.CK.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[_opsym]
	LD [err.A.],A
	CALL err
	CALL enderr
	LD A,_T_UNKNOWN
	LD [_t],A
val.CF.
val.CB.
val.BX.
val.BT.
val.BN.
val.BJ.
val.X.
val.V.
val.F.
val.D.
val.B.
	POP HL
	LD A,L
	LD [val.t],A
	RET
eatmulval
	LD A,[eatmulval.opsym]
	LD L,A
	PUSH HL
	LD A,[eatmulval.t1]
	LD L,A
	PUSH HL
	CALL val
	CALL rdword
eatmulval.A.
	LD HL,[_tword]
	LD A,[HL]
	LD [eatmulval.opsym],A
	LD A,[eatmulval.opsym]
	SUB '*'
	JP Z,eatmulval.C.
	LD A,[eatmulval.opsym]
	SUB '/'
	JP Z,eatmulval.E.
	LD A,[eatmulval.opsym]
	SUB '&'
	JP Z,eatmulval.G.
	JP eatmulval.B.
eatmulval.G.
eatmulval.E.
eatmulval.C.
	LD A,[_t]
	LD [eatmulval.t1],A
	CALL rdword
	LD A,[eatmulval.opsym]
	SUB '&'
	JP NZ,eatmulval.I.
	LD HL,[_tword]
	LD A,[HL]
	LD L,A
	LD A,[eatmulval.opsym]
	SUB L
	JP NZ,eatmulval.K.
	CALL rdword
eatmulval.K.
eatmulval.I.
	CALL val
	LD A,[_t]
	LD E,_TYPEMASK
	AND E
	LD [_t],A
	CALL rdword
	LD A,[eatmulval.t1]
	LD L,A
	LD A,[_t]
	SUB L
	JP Z,eatmulval.M.
	LD HL,eatmulval.O.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[eatmulval.opsym]
	LD [err.A.],A
	CALL err
	LD HL,eatmulval.P.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[eatmulval.t1]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	LD HL,eatmulval.Q.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[_t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	CALL enderr
eatmulval.M.
	LD A,[eatmulval.opsym]
	SUB '&'
	JP NZ,eatmulval.R.
	CALL cmdand
	JP eatmulval.S.
eatmulval.R.
	LD A,[eatmulval.opsym]
	SUB '*'
	JP NZ,eatmulval.T.
	CALL cmdmul
	JP eatmulval.U.
eatmulval.T.
	CALL cmddiv
eatmulval.U.
eatmulval.S.
	LD A,[_waseof]
	OR A
	JP Z,eatmulval.A.
eatmulval.B.
	POP HL
	LD A,L
	LD [eatmulval.t1],A
	POP HL
	LD A,L
	LD [eatmulval.opsym],A
	RET
eatsumval
	LD A,[eatsumval.opsym]
	LD L,A
	PUSH HL
	LD A,[eatsumval.t1]
	LD L,A
	PUSH HL
	CALL eatmulval
eatsumval.A.
	LD HL,[_tword]
	LD A,[HL]
	LD [eatsumval.opsym],A
	LD A,[eatsumval.opsym]
	SUB '+'
	JP Z,eatsumval.C.
	LD A,[eatsumval.opsym]
	SUB '-'
	JP Z,eatsumval.E.
	LD A,[eatsumval.opsym]
	SUB '|'
	JP Z,eatsumval.G.
	LD A,[eatsumval.opsym]
	SUB '^'
	JP Z,eatsumval.I.
	JP eatsumval.B.
eatsumval.I.
eatsumval.G.
eatsumval.E.
eatsumval.C.
	LD A,[_t]
	LD [eatsumval.t1],A
	CALL rdword
	LD HL,[_tword]
	LD A,[HL]
	SUB '>'
	JP NZ,eatsumval.K.
	CALL getstructfield
	LD A,[_addrexpr]
	CPL
	OR A
	JP Z,eatsumval.M.
	CALL cmdpeek
eatsumval.M.
	CALL rdword
	JP eatsumval.L.
eatsumval.K.
	LD A,[eatsumval.opsym]
	SUB '|'
	JP NZ,eatsumval.O.
	LD HL,[_tword]
	LD A,[HL]
	LD L,A
	LD A,[eatsumval.opsym]
	SUB L
	JP NZ,eatsumval.Q.
	CALL rdword
eatsumval.Q.
eatsumval.O.
	CALL eatmulval
	LD A,[_t]
	LD E,_TYPEMASK
	AND E
	LD [_t],A
	LD A,[eatsumval.t1]
	LD L,A
	LD A,[_t]
	SUB L
	JP Z,eatsumval.S.
	LD HL,eatsumval.U.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[eatsumval.opsym]
	LD [err.A.],A
	CALL err
	LD HL,eatsumval.V.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[eatsumval.t1]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	LD HL,eatsumval.W.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[_t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	CALL enderr
eatsumval.S.
	LD A,[eatsumval.opsym]
	SUB '+'
	JP NZ,eatsumval.X.
	CALL cmdadd
	JP eatsumval.Y.
eatsumval.X.
	LD A,[eatsumval.opsym]
	SUB '-'
	JP NZ,eatsumval.Z.
	CALL cmdsub
	JP eatsumval.BA.
eatsumval.Z.
	LD A,[eatsumval.opsym]
	SUB '|'
	JP NZ,eatsumval.BB.
	CALL cmdor
	JP eatsumval.BC.
eatsumval.BB.
	CALL cmdxor
eatsumval.BC.
eatsumval.BA.
eatsumval.Y.
eatsumval.L.
	LD A,[_waseof]
	OR A
	JP Z,eatsumval.A.
eatsumval.B.
	POP HL
	LD A,L
	LD [eatsumval.t1],A
	POP HL
	LD A,L
	LD [eatsumval.opsym],A
	RET
eatexpr
	LD A,[eatexpr.opsym]
	LD L,A
	PUSH HL
	LD A,[eatexpr.t1]
	LD L,A
	PUSH HL
	LD A,[eatexpr.modified]
	LD L,A
	PUSH HL
	LD A,[eatexpr.dbl]
	LD L,A
	PUSH HL
	LD HL,_exprlvl
	INC [HL]
	CALL eatsumval
eatexpr.A.
	LD HL,[_tword]
	LD A,[HL]
	LD [eatexpr.opsym],A
	LD A,[eatexpr.opsym]
	SUB '<'
	JP Z,eatexpr.C.
	LD A,[eatexpr.opsym]
	SUB '>'
	JP Z,eatexpr.E.
	LD A,[eatexpr.opsym]
	SUB '='
	JP Z,eatexpr.G.
	LD A,[eatexpr.opsym]
	SUB '!'
	JP Z,eatexpr.I.
	JP eatexpr.B.
eatexpr.I.
eatexpr.G.
eatexpr.E.
eatexpr.C.
	LD A,[_t]
	LD [eatexpr.t1],A
	CALL rdword
	LD HL,[_tword]
	LD A,[HL]
	SUB '='
	SUB 1
	SBC A,A
	LD [eatexpr.modified],A
	LD HL,[_tword]
	LD A,[HL]
	LD L,A
	LD A,[eatexpr.opsym]
	SUB L
	SUB 1
	SBC A,A
	LD [eatexpr.dbl],A
	LD A,[eatexpr.modified]
	LD L,A
	LD A,[eatexpr.dbl]
	OR L
	JP Z,eatexpr.K.
	CALL rdword
eatexpr.K.
	CALL eatsumval
	LD A,[_t]
	LD E,_TYPEMASK
	AND E
	LD [_t],A
	LD A,[eatexpr.t1]
	LD L,A
	LD A,[_t]
	SUB L
	JP Z,eatexpr.M.
	LD HL,eatexpr.O.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[eatexpr.opsym]
	LD [err.A.],A
	CALL err
	LD HL,eatexpr.P.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[eatexpr.t1]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	LD HL,eatexpr.Q.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[_t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	CALL enderr
eatexpr.M.
	LD A,[eatexpr.opsym]
	SUB '='
	JP NZ,eatexpr.R.
	LD A,[eatexpr.dbl]
	CPL
	OR A
	JP Z,eatexpr.T.
	LD HL,eatexpr.V.
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
eatexpr.T.
	CALL cmdeq
	JP eatexpr.S.
eatexpr.R.
	LD A,[eatexpr.opsym]
	SUB '!'
	JP NZ,eatexpr.W.
	CALL cmdnoteq
	JP eatexpr.X.
eatexpr.W.
	LD A,[eatexpr.opsym]
	SUB '<'
	JP NZ,eatexpr.Y.
	LD A,[eatexpr.dbl]
	OR A
	JP Z,eatexpr.BA.
	CALL cmdshl
	JP eatexpr.BB.
eatexpr.BA.
	LD A,[eatexpr.modified]
	OR A
	JP Z,eatexpr.BC.
	CALL cmdlesseq
	JP eatexpr.BD.
eatexpr.BC.
	CALL cmdless
eatexpr.BD.
eatexpr.BB.
	JP eatexpr.Z.
eatexpr.Y.
	LD A,[eatexpr.dbl]
	OR A
	JP Z,eatexpr.BE.
	CALL cmdshr
	JP eatexpr.BF.
eatexpr.BE.
	LD A,[eatexpr.modified]
	OR A
	JP Z,eatexpr.BG.
	CALL cmdmoreeq
	JP eatexpr.BH.
eatexpr.BG.
	CALL cmdmore
eatexpr.BH.
eatexpr.BF.
eatexpr.Z.
eatexpr.X.
eatexpr.S.
	LD A,[_waseof]
	OR A
	JP Z,eatexpr.A.
eatexpr.B.
	LD HL,_exprlvl
	DEC [HL]
	LD A,FALSE
	LD [_addrexpr],A
	POP HL
	LD A,L
	LD [eatexpr.dbl],A
	POP HL
	LD A,L
	LD [eatexpr.modified],A
	POP HL
	LD A,L
	LD [eatexpr.t1],A
	POP HL
	LD A,L
	LD [eatexpr.opsym],A
	RET
eatpoke
	LD A,0x01
	LD [_exprlvl],A
	LD A,'*'
	LD [eat.A.],A
	CALL eat
	CALL val
	LD A,[_t]
	LD E,_T_POI
	LD L,A
	LD A,E
	CPL
	AND L
	LD [eatpoke.t],A
	CALL rdword
	LD A,'='
	LD [eat.A.],A
	CALL eat
	CALL eatexpr
	LD A,[eatpoke.t]
	LD L,A
	LD A,[_t]
	SUB L
	JP Z,eatpoke.A.
	LD HL,eatpoke.C.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[eatpoke.t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	LD HL,eatpoke.D.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[_t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	CALL enderr
eatpoke.A.
	CALL cmdpoke
	RET
eatlet
	LD A,0x01
	LD [_exprlvl],A
	LD A,FALSE
	LD [joinvarname.A.],A
	CALL joinvarname
	LD A,[_t]
	LD [eatlet.t],A
	CALL rdword
	LD A,FALSE
	LD [eatlet.ispoke],A
	LD HL,[_tword]
	LD A,[HL]
	SUB '['
	JP NZ,eatlet.A.
	LD A,[idxarray.A.]
	LD L,A
	LD A,[eatlet.t]
	LD [idxarray.A.],A
	PUSH HL
	CALL idxarray
	POP DE
	LD L,A
	LD A,E
	LD [idxarray.A.],A
	LD A,L
	LD [eatlet.t],A
	LD A,']'
	LD [eat.A.],A
	CALL eat
	LD A,TRUE
	LD [eatlet.ispoke],A
	JP eatlet.B.
eatlet.A.
eatlet.C.
	LD HL,[_tword]
	LD A,[HL]
	SUB '-'
	JP NZ,eatlet.D.
	LD A,[eatlet.t]
	LD [_t],A
	LD A,[eatlet.ispoke]
	OR A
	JP Z,eatlet.E.
	CALL cmdpeek
	JP eatlet.F.
eatlet.E.
	CALL cmdpushvar
eatlet.F.
	LD A,'-'
	LD [eat.A.],A
	CALL eat
	CALL getstructfield
	LD A,[_t]
	LD [eatlet.t],A
	CALL rdword
	LD A,TRUE
	LD [eatlet.ispoke],A
	JP eatlet.C.
eatlet.D.
eatlet.B.
	LD A,'='
	LD [eat.A.],A
	CALL eat
	LD HL,[_joined]
	LD [strpush.A.],HL
	LD HL,[_lenjoined]
	LD [strpush.B.],HL
	CALL strpush
	CALL eatexpr
	LD HL,[_joined]
	LD [strpop.A.],HL
	CALL strpop
	LD [_lenjoined],HL
	LD A,[eatlet.t]
	LD L,A
	LD A,[_t]
	SUB L
	JP Z,eatlet.G.
	LD HL,eatlet.I.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[eatlet.t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	LD HL,eatlet.J.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[_t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	CALL enderr
eatlet.G.
	LD A,[eatlet.ispoke]
	OR A
	JP Z,eatlet.K.
	CALL cmdpoke
	JP eatlet.L.
eatlet.K.
	CALL cmdpopvar
eatlet.L.
	RET
eatwhile
	LD HL,[eatwhile.beglbl]
	PUSH HL
	LD HL,[eatwhile.wasendlbl]
	LD A,0x00
	LD [_exprlvl],A
	LD DE,[_tmpendlbl]
	LD [eatwhile.wasendlbl],DE
	LD DE,[_curlbl]
	LD [eatwhile.beglbl],DE
	LD DE,[_curlbl]
	INC DE
	LD [_curlbl],DE
	LD DE,[_curlbl]
	LD [_tmpendlbl],DE
	LD DE,[_curlbl]
	INC DE
	LD [_curlbl],DE
	LD DE,[eatwhile.beglbl]
	LD [genjplbl.A.],DE
	PUSH HL
	CALL genjplbl
	CALL cmdlabel
	LD A,'('
	LD [eat.A.],A
	CALL eat
	CALL eatexpr
	LD HL,[_tmpendlbl]
	LD [genjplbl.A.],HL
	CALL genjplbl
	CALL cmdjpiffalse
	LD A,')'
	LD [eat.A.],A
	CALL eat
	CALL eatcmd
	LD HL,[eatwhile.beglbl]
	LD [genjplbl.A.],HL
	CALL genjplbl
	CALL cmdjp
	LD HL,[_tmpendlbl]
	LD [genjplbl.A.],HL
	CALL genjplbl
	CALL cmdlabel
	LD HL,[eatwhile.wasendlbl]
	LD [_tmpendlbl],HL
	POP HL
	LD [eatwhile.wasendlbl],HL
	POP HL
	LD [eatwhile.beglbl],HL
	RET
eatrepeat
	LD HL,[eatrepeat.beglbl]
	PUSH HL
	LD HL,[eatrepeat.wasendlbl]
	LD DE,[_tmpendlbl]
	LD [eatrepeat.wasendlbl],DE
	LD DE,[_curlbl]
	LD [eatrepeat.beglbl],DE
	LD DE,[_curlbl]
	INC DE
	LD [_curlbl],DE
	LD DE,[_curlbl]
	LD [_tmpendlbl],DE
	LD DE,[_curlbl]
	INC DE
	LD [_curlbl],DE
	LD DE,[eatrepeat.beglbl]
	LD [genjplbl.A.],DE
	PUSH HL
	CALL genjplbl
	CALL cmdlabel
	CALL eatcmd
	LD HL,[_tword]
	LD A,[HL]
	LD E,0x20
	OR E
	SUB 'u'
	JP Z,eatrepeat.A.
	LD HL,eatrepeat.C.
	LD [err_tword.A.],HL
	CALL err_tword
eatrepeat.A.
	CALL rdword
	LD A,'('
	LD [eat.A.],A
	CALL eat
	LD A,0x00
	LD [_exprlvl],A
	CALL eatexpr
	LD A,')'
	LD [eat.A.],A
	CALL eat
	LD HL,[eatrepeat.beglbl]
	LD [genjplbl.A.],HL
	CALL genjplbl
	CALL cmdjpiffalse
	LD HL,[_tmpendlbl]
	LD [genjplbl.A.],HL
	CALL genjplbl
	CALL cmdlabel
	LD HL,[eatrepeat.wasendlbl]
	LD [_tmpendlbl],HL
	POP HL
	LD [eatrepeat.wasendlbl],HL
	POP HL
	LD [eatrepeat.beglbl],HL
	RET
eatbreak
	LD HL,[_tmpendlbl]
	LD [genjplbl.A.],HL
	CALL genjplbl
	CALL cmdjp
	RET
eatif
	LD HL,[eatif.elselbl]
	PUSH HL
	LD HL,[eatif.endiflbl]
	LD A,0x00
	LD [_exprlvl],A
	LD DE,[_curlbl]
	LD [eatif.elselbl],DE
	LD DE,[_curlbl]
	INC DE
	LD [_curlbl],DE
	LD DE,[_curlbl]
	LD [eatif.endiflbl],DE
	LD DE,[_curlbl]
	INC DE
	LD [_curlbl],DE
	LD A,'('
	LD [eat.A.],A
	PUSH HL
	CALL eat
	CALL eatexpr
	LD HL,[eatif.elselbl]
	LD [genjplbl.A.],HL
	CALL genjplbl
	CALL cmdjpiffalse
	LD A,')'
	LD [eat.A.],A
	CALL eat
	CALL eatcmd
	LD HL,[_tword]
	LD A,[HL]
	SUB ';'
	JP Z,eatif.A.
	LD HL,[_tword]
	LD A,[HL]
	LD E,0x20
	OR E
	SUB 'e'
	JP Z,eatif.C.
	LD HL,eatif.E.
	LD [err_tword.A.],HL
	CALL err_tword
eatif.C.
	LD HL,[eatif.endiflbl]
	LD [genjplbl.A.],HL
	CALL genjplbl
	CALL cmdjp
	LD HL,[eatif.elselbl]
	LD [genjplbl.A.],HL
	CALL genjplbl
	CALL cmdlabel
	CALL rdword
	CALL eatcmd
	LD HL,[eatif.endiflbl]
	LD [genjplbl.A.],HL
	CALL genjplbl
	CALL cmdlabel
	LD HL,[_tword]
	LD A,[HL]
	SUB ';'
	JP Z,eatif.F.
	LD HL,eatif.H.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[_tword]
	LD A,[HL]
	LD [err.A.],A
	CALL err
	LD A,'\''
	LD [err.A.],A
	CALL err
	CALL enderr
eatif.F.
	JP eatif.B.
eatif.A.
	LD HL,[eatif.elselbl]
	LD [genjplbl.A.],HL
	CALL genjplbl
	CALL cmdlabel
eatif.B.
	POP HL
	LD [eatif.endiflbl],HL
	POP HL
	LD [eatif.elselbl],HL
	RET
eatreturn
	LD A,0x01
	LD [_exprlvl],A
	CALL eatexpr
	LD A,[_t]
	LD L,A
	LD A,[_curfunct]
	LD C,_T_RECURSIVE
	LD E,A
	LD A,C
	CPL
	AND E
	SUB L
	JP Z,eatreturn.A.
	LD HL,eatreturn.C.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[_curfunct]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	LD HL,eatreturn.D.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[_t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	CALL enderr
eatreturn.A.
	CALL cmdresult
	LD A,TRUE
	LD [_wasreturn],A
	RET
eatinc
	LD HL,[_tword]
	LD A,[HL]
	SUB '*'
	JP NZ,eatinc.A.
	CALL rdword
	CALL eatexpr
	LD A,[_t]
	LD E,_T_POI
	LD L,A
	LD A,E
	CPL
	AND L
	LD [_t],A
	CALL cmdincbyaddr
	JP eatinc.B.
eatinc.A.
	CALL adddots
	LD A,FALSE
	LD [joinvarname.A.],A
	CALL joinvarname
	CALL cmdinc
	CALL rdword
eatinc.B.
	RET
eatdec
	LD HL,[_tword]
	LD A,[HL]
	SUB '*'
	JP NZ,eatdec.A.
	CALL rdword
	CALL eatexpr
	LD A,[_t]
	LD E,_T_POI
	LD L,A
	LD A,E
	CPL
	AND L
	LD [_t],A
	CALL cmddecbyaddr
	JP eatdec.B.
eatdec.A.
	CALL adddots
	LD A,FALSE
	LD [joinvarname.A.],A
	CALL joinvarname
	CALL cmddec
	CALL rdword
eatdec.B.
	RET
var_num
	LD A,[var_num.t]
	LD E,_T_ARRAY
	LD L,A
	LD A,E
	CPL
	AND L
	LD [var_num.tmasked],A
	LD A,[var_num.t]
	LD E,_T_CONST
	AND E
	SUB 0x00
	JP Z,var_num.C.
	LD HL,[_title]
	LD [varequ.A.],HL
	CALL varequ
	LD HL,[var_num.s]
	LD [varstr.A.],HL
	CALL varstr
	CALL endvar
	JP var_num.D.
var_num.C.
	LD A,[var_num.t]
	LD L,A
	LD A,[var_num.tmasked]
	SUB L
	JP NZ,var_num.E.
	LD A,[var_num.t]
	LD [var_alignwsz_label.A.],A
	CALL var_alignwsz_label
var_num.E.
	LD A,[var_num.tmasked]
	LD [var_def.A.],A
	LD HL,[var_num.s]
	LD [var_def.B.],HL
	CALL var_def
var_num.D.
	RET
do_const_num
	LD HL,[_tword]
	LD A,[HL]
	SUB '-'
	SUB 1
	SBC A,A
	LD DE,[_tword]
	LD L,A
	LD A,[DE]
	SUB '+'
	SUB 1
	SBC A,A
	OR L
	JP Z,do_const_num.B.
	CALL rdaddword
	LD A,[do_const_num.t]
	LD [var_num.A.],A
	LD HL,[_tword]
	LD [var_num.B.],HL
	CALL var_num
	JP do_const_num.C.
do_const_num.B.
	LD HL,[_tword]
	LD A,[HL]
	SUB '\''
	JP NZ,do_const_num.D.
	LD A,'\''
	LD [rdquotes.A.],A
	CALL rdquotes
	CALL rdch
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	LD A,[do_const_num.t]
	LD [var_num.A.],A
	LD HL,[_tword]
	LD [var_num.B.],HL
	CALL var_num
	JP do_const_num.E.
do_const_num.D.
	LD HL,[_tword]
	LD A,[HL]
	SUB '&'
	JP NZ,do_const_num.F.
	CALL rdword
	CALL adddots
	LD A,_T_ARRAY
	LD E,_T_UINT
	OR E
	LD [var_num.A.],A
	LD HL,[_tword]
	LD [var_num.B.],HL
	CALL var_num
	JP do_const_num.G.
do_const_num.F.
	LD HL,[_tword]
	LD A,[HL]
	SUB '\"'
	JP NZ,do_const_num.H.
	LD HL,[_title]
	LD [strcopy.A.],HL
	LD HL,[_lentitle]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	LD A,[do_const_num.t]
	LD E,_T_ARRAY
	AND E
	SUB 0x00
	JP Z,do_const_num.J.
	CALL jdot
	LD HL,[_curlbl]
	LD [jautonum.A.],HL
	CALL jautonum
	LD HL,[_curlbl]
	INC HL
	LD [_curlbl],HL
	LD A,_T_ARRAY
	LD E,_T_UINT
	OR E
	LD [var_num.A.],A
	LD HL,[_joined]
	LD [var_num.B.],HL
	CALL var_num
	CALL asmstrz
	JP do_const_num.K.
do_const_num.J.
	CALL varstrz
do_const_num.K.
	JP do_const_num.I.
do_const_num.H.
	LD A,[do_const_num.t]
	LD [var_num.A.],A
	LD HL,[_tword]
	LD [var_num.B.],HL
	CALL var_num
do_const_num.I.
do_const_num.G.
do_const_num.E.
do_const_num.C.
	RET
eatextern
	LD A,0x01
	LD [_exprlvl],A
	CALL eatvarname
	LD A,[_t]
	LD [eatextern.t],A
	LD HL,[_tword]
	LD A,[HL]
	SUB '['
	JP NZ,eatextern.A.
	LD HL,0
	LD [_lentword],HL
	LD A,']'
	LD [rdquotes.A.],A
	CALL rdquotes
	CALL rdch
	CALL rdword
eatextern.A.
	LD A,[eatextern.t]
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,[eatextern.t]
	LD C,_TYPEMASK
	AND C
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	RET
eatvar
	LD A,[eatvar.t]
	LD E,0x01
	LD L,A
	LD A,E
	LD [_exprlvl],A
	PUSH HL
	CALL eatvarname
	LD A,[_t]
	LD [eatvar.t],A
	LD HL,[_tword]
	LD A,[HL]
	SUB '['
	JP NZ,eatvar.C.
	LD HL,0
	LD [_lentword],HL
	LD A,']'
	LD [rdquotes.A.],A
	CALL rdquotes
	LD HL,[_tword]
	LD [strcopy.A.],HL
	LD HL,[_lentword]
	LD [strcopy.B.],HL
	LD HL,[_ncells]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenncells],HL
	CALL rdch
	CALL rdword
	JP eatvar.D.
eatvar.C.
	LD HL,[_ncells]
	LD [stradd.A.],HL
	LD HL,0
	LD [stradd.B.],HL
	LD A,'1'
	LD [stradd.C.],A
	CALL stradd
	LD [_lenncells],HL
	LD HL,[_ncells]
	LD DE,[_lenncells]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
eatvar.D.
	LD A,[eatvar.body]
	OR A
	JP Z,eatvar.E.
	LD A,[eatvar.t]
	LD [addlbl.A.],A
	LD A,[_namespclvl]
	SUB 0x00
	JR Z,$+4
	LD A,-1
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,[eatvar.t]
	LD C,_TYPEMASK
	AND C
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
eatvar.E.
	LD A,[eatvar.ispar]
	OR A
	JP Z,eatvar.G.
	LD A,[eatvar.body]
	OR A
	JP Z,eatvar.I.
	LD A,[eatvar.t]
	LD [var_alignwsz_label.A.],A
	CALL var_alignwsz_label
eatvar.I.
	LD HL,[_prefix]
	LD [strcopy.A.],HL
	LD HL,[_lenprefix]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	LD HL,[_parnum]
	LD [jautonum.A.],HL
	CALL jautonum
	LD HL,[_parnum]
	INC HL
	LD [_parnum],HL
	LD HL,[_curlbl]
	INC HL
	LD [_curlbl],HL
	LD HL,[_joined]
	LD [strcopy.A.],HL
	LD HL,[_lenjoined]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,[eatvar.t]
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,[eatvar.t]
	LD C,_TYPEMASK
	AND C
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
eatvar.G.
	LD A,[eatvar.body]
	OR A
	JP Z,eatvar.K.
	LD A,[eatvar.t]
	LD E,_T_ARRAY
	AND E
	SUB 0x00
	JP Z,eatvar.M.
	LD A,[eatvar.t]
	LD [var_alignwsz_label.A.],A
	CALL var_alignwsz_label
	CALL var_ds
	LD HL,_typesz
	LD A,[eatvar.t]
	LD C,_TYPEMASK
	AND C
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [varuint.A.],HL
	CALL varuint
	LD A,'*'
	LD [varc.A.],A
	CALL varc
	LD HL,[_ncells]
	LD [varstr.A.],HL
	CALL varstr
	CALL endvar
	JP eatvar.N.
eatvar.M.
	LD A,[eatvar.t]
	LD [var_num.A.],A
	LD HL,eatvar.O.
	LD [var_num.B.],HL
	CALL var_num
eatvar.N.
	CALL doexp
eatvar.K.
	LD HL,[_tword]
	LD A,[HL]
	SUB '='
	JP NZ,eatvar.P.
	CALL rdword
	LD HL,[_joined]
	LD [strpush.A.],HL
	LD HL,[_lenjoined]
	LD [strpush.B.],HL
	CALL strpush
	CALL eatexpr
	LD HL,[_joined]
	LD [strpop.A.],HL
	CALL strpop
	LD [_lenjoined],HL
	LD A,[eatvar.t]
	LD L,A
	LD A,[_t]
	SUB L
	JP Z,eatvar.R.
	LD HL,eatvar.T.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[_joined]
	LD [errstr.A.],HL
	CALL errstr
	LD HL,eatvar.U.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[eatvar.t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	LD HL,eatvar.V.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[_t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	CALL enderr
eatvar.R.
	CALL cmdpopvar
eatvar.P.
	LD A,[_isrecursive]
	LD L,A
	LD A,[eatvar.ispar]
	CPL
	AND L
	JP Z,eatvar.W.
	LD A,[eatvar.t]
	LD [_t],A
	CALL cmdpushpar
	LD HL,[_joined]
	LD [strpush.A.],HL
	LD HL,[_lenjoined]
	LD [strpush.B.],HL
	CALL strpush
eatvar.Y.
	LD HL,[_tword]
	LD A,[HL]
	SUB ';'
	JP NZ,eatvar.Z.
	CALL rdword
	JP eatvar.Y.
eatvar.Z.
	CALL eatcmd
	LD HL,[_joined]
	LD [strpop.A.],HL
	CALL strpop
	LD [_lenjoined],HL
	LD A,[eatvar.t]
	LD [_t],A
	CALL cmdpoppar
eatvar.W.
	POP HL
	LD A,L
	LD [eatvar.t],A
	RET
eatconst
	LD HL,0
	LD [eatconst.i],HL
	LD A,0x01
	LD [_exprlvl],A
	CALL eattype
	LD A,[_t]
	LD E,_T_CONST
	OR E
	LD [eatconst.t],A
	CALL adddots
	LD A,[_namespclvl]
	LD [doprefix.A.],A
	CALL doprefix
	CALL rdword
	LD HL,[_tword]
	LD A,[HL]
	SUB '['
	JP NZ,eatconst.A.
	LD A,[eatconst.t]
	LD E,_T_ARRAY
	OR E
	LD [eatconst.t],A
eatconst.A.
	LD HL,[_joined]
	LD [strcopy.A.],HL
	LD HL,[_lenjoined]
	LD [strcopy.B.],HL
	LD HL,[_title]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lentitle],HL
	LD HL,_namespclvl
	INC [HL]
	CALL lbltype
	LD HL,[_joined]
	LD [strcopy.A.],HL
	LD HL,[_lenjoined]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD HL,[_callee]
	LD [gettypename.A.],HL
	CALL gettypename
	LD [_lencallee],HL
	LD A,[eatconst.t]
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,[eatconst.t]
	LD C,_TYPEMASK
	AND C
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
eatconst.C.
	LD HL,[_tword]
	LD A,[HL]
	SUB '['
	JP NZ,eatconst.D.
	LD HL,0
	LD [_lentword],HL
	LD A,']'
	LD [rdquotes.A.],A
	CALL rdquotes
	CALL rdch
	CALL rdword
	JP eatconst.C.
eatconst.D.
	LD HL,[_tword]
	LD A,[HL]
	SUB '='
	JP NZ,eatconst.E.
	CALL rdword
	LD HL,[_tword]
	LD A,[HL]
	SUB '{'
	JP NZ,eatconst.G.
	LD A,[eatconst.t]
	LD [var_alignwsz_label.A.],A
	CALL var_alignwsz_label
	CALL doexp
eatconst.I.
	CALL rdword
	LD A,[eatconst.t]
	LD E,_T_STRUCT
	LD C,_T_CONST
	LD L,A
	LD A,E
	OR C
	SUB L
	JP NZ,eatconst.K.
	LD HL,[_callee]
	LD [strcopy.A.],HL
	LD HL,[_lencallee]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	LD HL,[_joined]
	LD [stradd.A.],HL
	LD HL,[_lenjoined]
	LD [stradd.B.],HL
	LD A,'.'
	LD [stradd.C.],A
	CALL stradd
	LD [_lenjoined],HL
	LD HL,[eatconst.i]
	LD [jautonum.A.],HL
	CALL jautonum
	LD HL,[_joined]
	LD [strcopy.A.],HL
	LD HL,[_lenjoined]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	CALL lbltype
	LD [_t],A
	CALL lbltype
	LD E,_T_TYPE
	LD L,A
	LD A,E
	CPL
	AND L
	LD E,_T_ARRAY
	OR E
	LD [do_const_num.A.],A
	CALL do_const_num
	LD HL,[eatconst.i]
	INC HL
	LD [eatconst.i],HL
	JP eatconst.L.
eatconst.K.
	LD A,[eatconst.t]
	LD E,_T_CONST
	LD L,A
	LD A,E
	CPL
	AND L
	LD [do_const_num.A.],A
	CALL do_const_num
eatconst.L.
	CALL rdword
	LD HL,[_tword]
	LD A,[HL]
	SUB '}'
	JP NZ,eatconst.I.
eatconst.J.
	JP eatconst.H.
eatconst.G.
	LD A,[eatconst.t]
	LD [do_const_num.A.],A
	CALL do_const_num
eatconst.H.
	CALL rdword
eatconst.E.
	LD HL,_namespclvl
	DEC [HL]
	LD A,[_namespclvl]
	LD [doprefix.A.],A
	CALL doprefix
	LD HL,[_prefix]
	LD [strcopy.A.],HL
	LD HL,[_lenprefix]
	LD [strcopy.B.],HL
	LD HL,[_title]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lentitle],HL
	RET
eatfunc
	LD HL,0
	LD [_curlbl],HL
	LD A,[eatfunc.isfunc]
	OR A
	JP Z,eatfunc.D.
	CALL eattype
	LD A,[_t]
	LD [_curfunct],A
	JP eatfunc.E.
eatfunc.D.
	LD A,_T_PROC
	LD [_curfunct],A
eatfunc.E.
	LD HL,[_tword]
	LD [strcopy.A.],HL
	LD HL,[_lentword]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	CALL jtitletword
	CALL rdword
	LD HL,[_tword]
	LD A,[HL]
	LD E,0x20
	OR E
	SUB 'r'
	JP NZ,eatfunc.F.
	LD A,[_curfunct]
	LD E,_T_RECURSIVE
	OR E
	LD [_curfunct],A
	LD A,TRUE
	LD [_isrecursive],A
	CALL rdword
	JP eatfunc.G.
eatfunc.F.
	LD A,FALSE
	LD [_isrecursive],A
eatfunc.G.
	LD HL,[_tword]
	LD A,[HL]
	LD E,0x20
	OR E
	SUB 'f'
	JP NZ,eatfunc.H.
	LD A,TRUE
	LD [eatfunc.isforward],A
	CALL rdword
	JP eatfunc.I.
eatfunc.H.
	LD A,FALSE
	LD [eatfunc.isforward],A
eatfunc.I.
	LD A,[_curfunct]
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD A,[eatfunc.isforward]
	CPL
	OR A
	JP Z,eatfunc.J.
	CALL cmdlabel
	CALL cmdfunc
	CALL doexp
eatfunc.J.
	CALL jdot
	LD HL,[_joined]
	LD [strcopy.A.],HL
	LD HL,[_lenjoined]
	LD [strcopy.B.],HL
	LD HL,[_title]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lentitle],HL
	LD HL,_namespclvl
	INC [HL]
	LD A,'('
	LD [eat.A.],A
	CALL eat
	LD HL,0
	LD [_parnum],HL
eatfunc.L.
	LD A,[_waseof]
	CPL
	OR A
	JP Z,eatfunc.M.
	LD HL,[_tword]
	LD A,[HL]
	SUB ')'
	JP NZ,eatfunc.N.
	JP eatfunc.M.
eatfunc.N.
	LD A,[eatvar.A.]
	LD E,TRUE
	LD L,A
	LD A,E
	LD [eatvar.A.],A
	PUSH HL
	LD A,[eatvar.B.]
	LD L,A
	LD A,[eatfunc.isforward]
	CPL
	LD [eatvar.B.],A
	PUSH HL
	CALL eatvar
	POP HL
	LD A,L
	LD [eatvar.B.],A
	POP HL
	LD A,L
	LD [eatvar.A.],A
	LD HL,[_tword]
	LD A,[HL]
	SUB ')'
	JP NZ,eatfunc.P.
	JP eatfunc.M.
eatfunc.P.
	CALL rdword
	JP eatfunc.L.
eatfunc.M.
	CALL rdword
	CALL keepvars
	LD A,[eatfunc.isforward]
	CPL
	OR A
	JP Z,eatfunc.R.
	CALL eatcmd
	LD A,[_curfunct]
	LD E,_T_RECURSIVE
	LD L,A
	LD A,E
	CPL
	AND L
	LD [_t],A
	LD A,[eatfunc.isfunc]
	LD [cmdret.A.],A
	CALL cmdret
	LD A,[eatfunc.isfunc]
	LD L,A
	LD A,[_wasreturn]
	CPL
	AND L
	JP Z,eatfunc.T.
	LD HL,eatfunc.V.
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
eatfunc.T.
eatfunc.R.
	CALL undovars
	LD HL,_namespclvl
	DEC [HL]
	LD A,[_namespclvl]
	LD [doprefix.A.],A
	CALL doprefix
	LD HL,[_prefix]
	LD [strcopy.A.],HL
	LD HL,[_lenprefix]
	LD [strcopy.B.],HL
	LD HL,[_title]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lentitle],HL
	LD A,[eatfunc.oldfunct]
	LD [_curfunct],A
	LD A,[eatfunc.oldwasreturn]
	LD [_wasreturn],A
	LD A,FALSE
	LD [_isexp],A
	RET
do_callpar
	LD A,[do_callpar.t]
	LD DE,[_tword]
	LD L,A
	LD A,[DE]
	SUB ')'
	JR Z,$+4
	LD A,-1
	LD E,A
	LD A,[_waseof]
	CPL
	AND E
	PUSH HL
	JP Z,do_callpar.C.
	LD HL,[_callee]
	LD [strcopy.A.],HL
	LD HL,[_lencallee]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	CALL jdot
	LD HL,[do_callpar.parnum]
	LD [jautonum.A.],HL
	CALL jautonum
	LD HL,[_joined]
	LD [strcopy.A.],HL
	LD HL,[_lenjoined]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	CALL lbltype
	LD [do_callpar.t],A
	LD A,[do_callpar.funct]
	LD E,_T_RECURSIVE
	AND E
	SUB 0x00
	JP Z,do_callpar.E.
	LD A,[do_callpar.t]
	LD [_t],A
	CALL cmdpushpar
do_callpar.E.
	LD HL,[_joined]
	LD [strpush.A.],HL
	LD HL,[_lenjoined]
	LD [strpush.B.],HL
	CALL strpush
	LD HL,_exprlvl
	INC [HL]
	CALL eatexpr
	LD HL,_exprlvl
	DEC [HL]
	LD A,[do_callpar.t]
	LD L,A
	LD A,[_t]
	SUB L
	JP Z,do_callpar.G.
	LD HL,do_callpar.I.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[do_callpar.t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	LD HL,do_callpar.J.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[_t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	CALL enderr
do_callpar.G.
	LD HL,[_joined]
	LD [strpop.A.],HL
	CALL strpop
	LD [_lenjoined],HL
	CALL cmdpopvar
	LD HL,[_tword]
	LD A,[HL]
	SUB ','
	JP NZ,do_callpar.K.
	CALL rdword
do_callpar.K.
	LD HL,[do_callpar.parnum]
	LD DE,_MAXPARS
	LD A,L
	SUB E
	LD A,H
	SBC A,D
	JP NC,do_callpar.M.
	LD HL,[_joined]
	LD [strpush.A.],HL
	LD HL,[_lenjoined]
	LD [strpush.B.],HL
	CALL strpush
	LD A,[do_callpar.A.]
	LD L,A
	LD A,[do_callpar.funct]
	LD [do_callpar.A.],A
	PUSH HL
	LD HL,[do_callpar.B.]
	LD DE,[do_callpar.parnum]
	LD BC,1
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	LD [do_callpar.B.],DE
	PUSH HL
	CALL do_callpar
	POP HL
	LD [do_callpar.B.],HL
	POP HL
	LD A,L
	LD [do_callpar.A.],A
	LD HL,[_joined]
	LD [strpop.A.],HL
	CALL strpop
	LD [_lenjoined],HL
do_callpar.M.
	LD A,[do_callpar.funct]
	LD E,_T_RECURSIVE
	AND E
	SUB 0x00
	JP Z,do_callpar.O.
	LD A,[do_callpar.t]
	LD [_t],A
	CALL cmdpoppar
do_callpar.O.
	JP do_callpar.D.
do_callpar.C.
	LD A,[do_callpar.funct]
	LD E,_T_RECURSIVE
	LD L,A
	LD A,E
	CPL
	AND L
	LD [_t],A
	CALL cmdcall
do_callpar.D.
	POP HL
	LD A,L
	LD [do_callpar.t],A
	RET
do_call
	LD A,[do_call.t]
	LD L,A
	PUSH HL
	LD HL,_exprlvl
	INC [HL]
	LD A,TRUE
	LD [joinvarname.A.],A
	CALL joinvarname
	LD A,[_t]
	LD [do_call.t],A
	LD A,[do_call.t]
	SUB _T_UNKNOWN
	JP NZ,do_call.B.
	LD HL,do_call.D.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[_joined]
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
do_call.B.
	LD A,[do_call.isfunc]
	CPL
	OR A
	JP Z,do_call.E.
	LD A,[do_call.t]
	LD E,_T_RECURSIVE
	AND E
	LD E,_T_PROC
	OR E
	LD [do_call.t],A
do_call.E.
	LD HL,[_callee]
	LD [strpush.A.],HL
	LD HL,[_lencallee]
	LD [strpush.B.],HL
	CALL strpush
	LD HL,[_joined]
	LD [strcopy.A.],HL
	LD HL,[_lenjoined]
	LD [strcopy.B.],HL
	LD HL,[_callee]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lencallee],HL
	CALL jdot
	CALL rdword
	LD A,'('
	LD [eat.A.],A
	CALL eat
	LD A,[do_callpar.A.]
	LD L,A
	LD A,[do_call.t]
	LD [do_callpar.A.],A
	PUSH HL
	LD HL,[do_callpar.B.]
	LD DE,0
	LD [do_callpar.B.],DE
	PUSH HL
	CALL do_callpar
	POP HL
	LD [do_callpar.B.],HL
	POP HL
	LD A,L
	LD [do_callpar.A.],A
	LD HL,[_callee]
	LD [strpop.A.],HL
	CALL strpop
	LD [_lencallee],HL
	LD HL,_exprlvl
	DEC [HL]
	LD A,[do_call.t]
	LD E,_T_RECURSIVE
	LD L,A
	LD A,E
	CPL
	AND L
	POP DE
	LD L,A
	LD A,E
	LD [do_call.t],A
	LD A,L
	RET
eatcallpoi
	CALL adddots
	LD A,FALSE
	LD [joinvarname.A.],A
	CALL joinvarname
	LD A,'('
	LD [eat.A.],A
	CALL eat
	CALL eatexpr
	LD A,')'
	LD [eat.A.],A
	CALL eat
	CALL cmdcallval
	CALL rdword
	RET
eatlbl
	CALL jtitletword
	CALL cmdlabel
	CALL rdword
	CALL rdword
	RET
eatgoto
	CALL jtitletword
	CALL cmdjp
	CALL rdword
	RET
eatasm
	CALL rdword
eatasm.A.
	LD A,[_waseof]
	CPL
	OR A
	JP Z,eatasm.B.
	LD HL,0
	LD [_lentword],HL
	LD A,'\"'
	LD [rdquotes.A.],A
	CALL rdquotes
	LD HL,[_tword]
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	CALL rdch
	LD A,[_cnext]
	SUB '\"'
	JP Z,eatasm.C.
	JP eatasm.B.
eatasm.C.
	CALL rdword
	JP eatasm.A.
eatasm.B.
	CALL rdword
	CALL rdword
	RET
eatenum
	LD HL,0
	LD [eatenum.i],HL
eatenum.A.
	LD A,[_waseof]
	CPL
	OR A
	JP Z,eatenum.B.
	CALL rdword
	LD HL,[_tword]
	LD [varequ.A.],HL
	CALL varequ
	LD HL,[eatenum.i]
	LD [varuint.A.],HL
	CALL varuint
	CALL endvar
	CALL rdword
	LD HL,[_tword]
	LD A,[HL]
	SUB ','
	JP Z,eatenum.C.
	JP eatenum.B.
eatenum.C.
	LD HL,[eatenum.i]
	INC HL
	LD [eatenum.i],HL
	JP eatenum.A.
eatenum.B.
	CALL rdword
	RET
eatstruct
	LD HL,0
	LD [eatstruct.shift],HL
	LD HL,0
	LD [eatstruct.i],HL
	LD HL,[_title]
	LD [strjoin.A.],HL
	LD HL,[_lentitle]
	LD [strjoin.B.],HL
	LD HL,[_tword]
	LD [strjoin.C.],HL
	CALL strjoin
	LD [_lentitle],HL
	LD HL,[_title]
	LD DE,[_lentitle]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	LD HL,[_title]
	LD [strcopy.A.],HL
	LD HL,[_lentitle]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,_T_STRUCT
	LD E,_T_TYPE
	OR E
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,[_varszaddr]
	LD [eatstruct.varszaddr],HL
	LD HL,[_title]
	LD [stradd.A.],HL
	LD HL,[_lentitle]
	LD [stradd.B.],HL
	LD A,'.'
	LD [stradd.C.],A
	CALL stradd
	LD [_lentitle],HL
	LD HL,[_title]
	LD DE,[_lentitle]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	LD HL,_namespclvl
	INC [HL]
	CALL rdword
	LD A,'{'
	LD [eat.A.],A
	CALL eat
eatstruct.A.
	LD A,[_waseof]
	CPL
	OR A
	JP Z,eatstruct.B.
	CALL eattype
	LD HL,_typesz
	LD A,[_t]
	LD C,_TYPEMASK
	AND C
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [eatstruct.sz],HL
	CALL jtitletword
	LD HL,[eatstruct.shift]
	LD [varshift.A.],HL
	LD HL,[eatstruct.sz]
	LD [varshift.B.],HL
	CALL varshift
	LD [eatstruct.shift],HL
	LD HL,[_joined]
	LD [strcopy.A.],HL
	LD HL,[_lenjoined]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,[_t]
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,[eatstruct.sz]
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,[eatstruct.i]
	LD [genjplbl.A.],HL
	CALL genjplbl
	LD HL,[_joined]
	LD [strcopy.A.],HL
	LD HL,[_lenjoined]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,[_t]
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,[eatstruct.sz]
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,[eatstruct.i]
	INC HL
	LD [eatstruct.i],HL
	LD HL,[eatstruct.shift]
	LD DE,[eatstruct.sz]
	ADD HL,DE
	LD [eatstruct.shift],HL
	CALL rdword
	LD HL,[_tword]
	LD A,[HL]
	SUB ';'
	JP NZ,eatstruct.C.
	CALL rdword
eatstruct.C.
	LD HL,[_tword]
	LD A,[HL]
	SUB '}'
	JP NZ,eatstruct.E.
	JP eatstruct.B.
eatstruct.E.
	JP eatstruct.A.
eatstruct.B.
	LD HL,[eatstruct.varszaddr]
	LD [setvarsz.A.],HL
	LD HL,[eatstruct.shift]
	LD [setvarsz.B.],HL
	CALL setvarsz
	LD HL,_namespclvl
	DEC [HL]
	LD A,[_namespclvl]
	LD [doprefix.A.],A
	CALL doprefix
	LD HL,[_prefix]
	LD [strcopy.A.],HL
	LD HL,[_lenprefix]
	LD [strcopy.B.],HL
	LD HL,[_title]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lentitle],HL
	CALL rdword
	RET
eatswitch
	LD HL,[_tmpendlbl]
	LD [eatswitch.wastmpendlbl],HL
	LD HL,[_curlbl]
	LD [_tmpendlbl],HL
	LD HL,[_curlbl]
	INC HL
	LD [_curlbl],HL
	LD HL,[_title]
	LD [strcopy.A.],HL
	LD HL,[_lentitle]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	LD HL,[_joined]
	LD [stradd.A.],HL
	LD HL,[_lenjoined]
	LD [stradd.B.],HL
	LD A,'J'
	LD [stradd.C.],A
	CALL stradd
	LD [_lenjoined],HL
	LD HL,[_joined]
	LD DE,[_lenjoined]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	LD A,_T_UINT
	LD E,_T_POI
	OR E
	LD [_t],A
	CALL cmdpushnum
	CALL eatidx
	LD A,_T_UINT
	LD [_t],A
	CALL cmdaddpoi
	CALL cmdpeek
	CALL cmdjpval
	LD HL,[_title]
	LD [varstr.A.],HL
	CALL varstr
	LD A,'J'
	LD [varc.A.],A
	CALL varc
	CALL endvar
	LD A,0x00
	LD [eatswitch.ib],A
eatswitch.A.
	LD HL,[_title]
	LD [asmstr.A.],HL
	CALL asmstr
	LD A,[eatswitch.ib]
	LD L,A
	LD H,0
	LD [asmuint.A.],HL
	CALL asmuint
	LD A,'='
	LD [asmc.A.],A
	CALL asmc
	LD HL,[_title]
	LD [asmstr.A.],HL
	CALL asmstr
	LD HL,eatswitch.C.
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	CALL var_dw
	LD HL,[_title]
	LD [varstr.A.],HL
	CALL varstr
	LD A,[eatswitch.ib]
	LD L,A
	LD H,0
	LD [varuint.A.],HL
	CALL varuint
	CALL endvar
	LD HL,eatswitch.ib
	INC [HL]
	LD A,[eatswitch.ib]
	SUB 0x00
	JP NZ,eatswitch.A.
eatswitch.B.
	CALL eatcmd
	LD HL,[_tmpendlbl]
	LD [genjplbl.A.],HL
	CALL genjplbl
	CALL cmdlabel
	LD HL,[eatswitch.wastmpendlbl]
	LD [_tmpendlbl],HL
	RET
eatcase
	LD HL,[_title]
	LD [asmstr.A.],HL
	CALL asmstr
	LD A,'#'
	LD [asmc.A.],A
	CALL asmc
	LD HL,[_tword]
	LD [asmstr.A.],HL
	CALL asmstr
	LD A,'='
	LD [asmc.A.],A
	CALL asmc
	LD A,'$'
	LD [asmc.A.],A
	CALL asmc
	CALL endasm
	CALL rdword
	CALL rdword
	RET
eatcmd
	CALL adddots
	LD HL,[_tword]
	LD A,[HL]
	LD [_c0],A
	LD A,[_c0]
	SUB '}'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_waseof]
	OR L
	JP Z,eatcmd.A.
	CALL rdword
	LD A,FALSE
	LD [_morecmd],A
	JP eatcmd.B.
eatcmd.A.
	LD A,[_cnext]
	SUB '='
	JP NZ,eatcmd.C.
	CALL eatlet
	JP eatcmd.D.
eatcmd.C.
	LD A,[_cnext]
	SUB '['
	JP NZ,eatcmd.E.
	CALL eatlet
	JP eatcmd.F.
eatcmd.E.
	LD A,[_cnext]
	SUB '-'
	JP NZ,eatcmd.G.
	CALL eatlet
	JP eatcmd.H.
eatcmd.G.
	LD A,[_cnext]
	SUB '('
	SUB 1
	SBC A,A
	LD DE,[_spcsize]
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
	JP Z,eatcmd.I.
	LD A,[do_call.A.]
	LD E,FALSE
	LD L,A
	LD A,E
	LD [do_call.A.],A
	PUSH HL
	CALL do_call
	POP HL
	LD A,L
	LD [do_call.A.],A
	CALL rdword
	JP eatcmd.J.
eatcmd.I.
	LD A,[_cnext]
	SUB ':'
	JP NZ,eatcmd.K.
	CALL eatlbl
	JP eatcmd.L.
eatcmd.K.
	LD A,[_c0]
	SUB ';'
	JP NZ,eatcmd.M.
	CALL rdword
	JP eatcmd.N.
eatcmd.M.
	LD A,[_c0]
	SUB '{'
	JP NZ,eatcmd.O.
	CALL rdword
eatcmd.Q.
	CALL eatcmd
	OR A
	JP Z,eatcmd.R.
	JP eatcmd.Q.
eatcmd.R.
	JP eatcmd.P.
eatcmd.O.
	LD A,[_c0]
	LD E,0x20
	OR E
	LD [_c0],A
	LD HL,[_tword]
	LD DE,2
	ADD HL,DE
	LD A,[HL]
	LD E,0x20
	OR E
	LD [_c2],A
	LD A,[_c0]
	SUB 'v'
	JP NZ,eatcmd.S.
	CALL rdword
	LD A,[eatvar.A.]
	LD E,FALSE
	LD L,A
	LD A,E
	LD [eatvar.A.],A
	PUSH HL
	LD A,[eatvar.B.]
	LD E,TRUE
	LD L,A
	LD A,E
	LD [eatvar.B.],A
	PUSH HL
	CALL eatvar
	POP HL
	LD A,L
	LD [eatvar.B.],A
	POP HL
	LD A,L
	LD [eatvar.A.],A
	LD A,FALSE
	LD [_isexp],A
	JP eatcmd.T.
eatcmd.S.
	LD A,[_c0]
	SUB 'e'
	JP NZ,eatcmd.U.
	LD A,[_c2]
	SUB 't'
	JP NZ,eatcmd.W.
	CALL rdword
	CALL eatextern
	JP eatcmd.X.
eatcmd.W.
	LD A,[_c2]
	SUB 'p'
	JP NZ,eatcmd.Y.
	CALL rdword
	LD A,TRUE
	LD [_isexp],A
	JP eatcmd.Z.
eatcmd.Y.
	CALL rdword
	CALL eatenum
eatcmd.Z.
eatcmd.X.
	JP eatcmd.V.
eatcmd.U.
	LD A,[_c0]
	SUB 'c'
	JP NZ,eatcmd.BA.
	LD A,[_c2]
	SUB 'n'
	JP NZ,eatcmd.BC.
	CALL rdword
	CALL eatconst
	JP eatcmd.BD.
eatcmd.BC.
	LD A,[_c2]
	SUB 'l'
	JP NZ,eatcmd.BE.
	CALL rdword
	CALL eatcallpoi
	JP eatcmd.BF.
eatcmd.BE.
	CALL rdword
	CALL eatcase
eatcmd.BF.
eatcmd.BD.
	JP eatcmd.BB.
eatcmd.BA.
	LD A,[_c0]
	SUB 'f'
	JP NZ,eatcmd.BG.
	CALL rdword
	LD A,TRUE
	LD [eatfunc.A.],A
	LD A,[_curfunct]
	LD [eatfunc.B.],A
	LD A,[_wasreturn]
	LD [eatfunc.C.],A
	CALL eatfunc
	JP eatcmd.BH.
eatcmd.BG.
	LD A,[_c0]
	SUB 'p'
	JP NZ,eatcmd.BI.
	LD A,[_c2]
	SUB 'o'
	JP NZ,eatcmd.BK.
	CALL rdword
	LD A,FALSE
	LD [eatfunc.A.],A
	LD A,[_curfunct]
	LD [eatfunc.B.],A
	LD A,[_wasreturn]
	LD [eatfunc.C.],A
	CALL eatfunc
	JP eatcmd.BL.
eatcmd.BK.
	CALL rdword
	CALL eatpoke
eatcmd.BL.
	JP eatcmd.BJ.
eatcmd.BI.
	LD A,[_c0]
	SUB 'r'
	JP NZ,eatcmd.BM.
	LD A,[_c2]
	SUB 't'
	JP NZ,eatcmd.BO.
	CALL rdword
	CALL eatreturn
	JP eatcmd.BP.
eatcmd.BO.
	CALL rdword
	CALL eatrepeat
eatcmd.BP.
	JP eatcmd.BN.
eatcmd.BM.
	LD A,[_c0]
	SUB 'w'
	JP NZ,eatcmd.BQ.
	CALL rdword
	CALL eatwhile
	JP eatcmd.BR.
eatcmd.BQ.
	LD A,[_c0]
	SUB 'b'
	JP NZ,eatcmd.BS.
	CALL rdword
	CALL eatbreak
	JP eatcmd.BT.
eatcmd.BS.
	LD A,[_c0]
	SUB 'd'
	JP NZ,eatcmd.BU.
	CALL rdword
	CALL eatdec
	JP eatcmd.BV.
eatcmd.BU.
	LD A,[_c0]
	SUB 'i'
	JP NZ,eatcmd.BW.
	LD A,[_c2]
	SUB 'c'
	JP NZ,eatcmd.BY.
	CALL rdword
	CALL eatinc
	JP eatcmd.BZ.
eatcmd.BY.
	CALL rdword
	CALL eatif
eatcmd.BZ.
	JP eatcmd.BX.
eatcmd.BW.
	LD A,[_c0]
	SUB 'g'
	JP NZ,eatcmd.CA.
	CALL rdword
	CALL eatgoto
	JP eatcmd.CB.
eatcmd.CA.
	LD A,[_c0]
	SUB 'a'
	JP NZ,eatcmd.CC.
	CALL rdword
	CALL eatasm
	JP eatcmd.CD.
eatcmd.CC.
	LD A,[_c0]
	SUB 's'
	JP NZ,eatcmd.CE.
	LD A,[_c2]
	SUB 'r'
	JP NZ,eatcmd.CG.
	CALL rdword
	CALL eatstruct
	JP eatcmd.CH.
eatcmd.CG.
	CALL rdword
	CALL eatswitch
eatcmd.CH.
	JP eatcmd.CF.
eatcmd.CE.
	LD A,[_c0]
	SUB 't'
	JP NZ,eatcmd.CI.
	CALL rdword
	CALL eattype
	LD HL,[_tword]
	LD [strcopy.A.],HL
	LD HL,[_lentword]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,_T_TYPE
	LD L,A
	LD A,[_t]
	ADD A,L
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	CALL rdword
	JP eatcmd.CJ.
eatcmd.CI.
	LD A,[_c0]
	SUB '#'
	JP NZ,eatcmd.CK.
	CALL rdword
	LD HL,[_tword]
	LD DE,2
	ADD HL,DE
	LD A,[HL]
	LD [_c2],A
	LD A,[_c2]
	SUB 'c'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_doskip]
	CPL
	AND L
	JP Z,eatcmd.CM.
	CALL rdword
	LD HL,0
	LD [_lentword],HL
	LD A,'\"'
	LD [rdquotes.A.],A
	CALL rdquotes
	LD HL,_hinclfile
	LD A,[_nhinclfiles]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD DE,[_fin]
	LD [HL],E
	INC HL
	LD [HL],D
	LD HL,_hnline
	LD A,[_nhinclfiles]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD DE,[_curline]
	LD [HL],E
	INC HL
	LD [HL],D
	LD HL,_nhinclfiles
	INC [HL]
	LD HL,[compfile.A.]
	LD DE,[_tword]
	LD [compfile.A.],DE
	PUSH HL
	CALL compfile
	POP HL
	LD [compfile.A.],HL
	LD HL,_nhinclfiles
	DEC [HL]
	LD HL,_hinclfile
	LD A,[_nhinclfiles]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [_fin],HL
	LD HL,_hnline
	LD A,[_nhinclfiles]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [_curline],HL
	LD A,FALSE
	LD [_waseof],A
	CALL rdch
	JP eatcmd.CN.
eatcmd.CM.
	LD A,[_c2]
	SUB 'd'
	JP NZ,eatcmd.CO.
	LD HL,[_tword]
	LD A,[HL]
	SUB 'e'
	JP NZ,eatcmd.CQ.
	LD HL,[_doskipcond]
	LD DE,1
	LD A,D
	AND H
	LD H,A
	LD A,E
	AND L
	LD L,A
	LD DE,0
	OR A
	SBC HL,DE
	SUB 1
	SBC A,A
	LD [_doskip],A
	LD HL,[_doskipcond]
	LD DE,1
	CALL _SHR.
	LD [_doskipcond],HL
	JP eatcmd.CR.
eatcmd.CQ.
	LD HL,[_tword]
	LD A,[HL]
	SUB 'i'
	JP NZ,eatcmd.CS.
	LD HL,[_doskipcond]
	LD DE,[_doskipcond]
	ADD HL,DE
	LD [_doskipcond],HL
	CALL rdword
	LD HL,[_tword]
	LD [strcopy.A.],HL
	LD HL,[_lentword]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,[_doskip]
	CPL
	OR A
	JP Z,eatcmd.CU.
	LD HL,[_doskipcond]
	INC HL
	LD [_doskipcond],HL
	CALL lbltype
	SUB _T_UNKNOWN
	SUB 1
	SBC A,A
	LD [_doskip],A
eatcmd.CU.
	JP eatcmd.CT.
eatcmd.CS.
	CALL rdword
	LD HL,[_tword]
	LD [strcopy.A.],HL
	LD HL,[_lentword]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	CALL dellbl
eatcmd.CT.
eatcmd.CR.
	JP eatcmd.CP.
eatcmd.CO.
	LD A,[_c2]
	SUB 'n'
	JP NZ,eatcmd.CW.
	LD HL,[_doskipcond]
	LD DE,[_doskipcond]
	ADD HL,DE
	LD [_doskipcond],HL
	CALL rdword
	LD HL,[_tword]
	LD [strcopy.A.],HL
	LD HL,[_lentword]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,[_doskip]
	CPL
	OR A
	JP Z,eatcmd.CY.
	LD HL,[_doskipcond]
	INC HL
	LD [_doskipcond],HL
	CALL lbltype
	SUB _T_UNKNOWN
	JR Z,$+4
	LD A,-1
	LD [_doskip],A
eatcmd.CY.
	JP eatcmd.CX.
eatcmd.CW.
	LD A,[_c2]
	SUB 's'
	JP NZ,eatcmd.DA.
	LD HL,[_doskipcond]
	LD DE,1
	LD A,D
	AND H
	LD H,A
	LD A,E
	AND L
	LD L,A
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,eatcmd.DC.
	LD A,[_doskip]
	CPL
	LD [_doskip],A
eatcmd.DC.
	JP eatcmd.DB.
eatcmd.DA.
	LD A,[_c2]
	SUB 'f'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_doskip]
	CPL
	AND L
	JP Z,eatcmd.DE.
	CALL rdword
	LD HL,[_tword]
	LD [strcopy.A.],HL
	LD HL,[_lentword]
	LD [strcopy.B.],HL
	LD HL,[_joined]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenjoined],HL
	CALL rdword
	LD HL,[_tword]
	LD A,[HL]
	SUB '('
	JP NZ,eatcmd.DG.
	CALL rdword
	CALL eattype
	LD A,')'
	LD [eat.A.],A
	CALL eat
	LD A,')'
	LD [rdquotes.A.],A
	CALL rdquotes
	CALL rdch
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	JP eatcmd.DH.
eatcmd.DG.
	CALL numtype
eatcmd.DH.
	LD HL,[_joined]
	LD [strcopy.A.],HL
	LD HL,[_lenjoined]
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,[_t]
	LD E,_T_CONST
	OR E
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,[_name]
	LD [emitvarpreequ.A.],HL
	CALL emitvarpreequ
	LD HL,[_name]
	LD [varequ.A.],HL
	CALL varequ
	LD HL,[_tword]
	LD [varstr.A.],HL
	CALL varstr
	CALL endvar
	CALL emitvarpostequ
eatcmd.DE.
eatcmd.DB.
eatcmd.CX.
eatcmd.CP.
eatcmd.CN.
eatcmd.DI.
	LD HL,[_waseols]
	LD DE,0
	OR A
	SBC HL,DE
	JP NZ,eatcmd.DJ.
	CALL rdchcmt
	JP eatcmd.DI.
eatcmd.DJ.
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	LD A,[_cnext]
	LD E,'!'
	SUB E
	JP NC,eatcmd.DK.
	CALL rdch
eatcmd.DK.
	CALL rdword
	JP eatcmd.CL.
eatcmd.CK.
	LD HL,eatcmd.DM.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[_tword]
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
	CALL rdword
eatcmd.CL.
eatcmd.CJ.
eatcmd.CF.
eatcmd.CD.
eatcmd.CB.
eatcmd.BX.
eatcmd.BV.
eatcmd.BT.
eatcmd.BR.
eatcmd.BN.
eatcmd.BJ.
eatcmd.BH.
eatcmd.BB.
eatcmd.V.
eatcmd.T.
eatcmd.P.
eatcmd.N.
eatcmd.L.
eatcmd.J.
eatcmd.H.
eatcmd.F.
eatcmd.D.
	LD A,TRUE
	LD [_morecmd],A
eatcmd.B.
	LD A,[_morecmd]
	RET
compfile
	LD HL,[compfile.fn]
	LD [nfopen.A.],HL
	LD HL,compfile.B.
	LD [nfopen.B.],HL
	CALL nfopen
	LD [_fin],HL
	LD HL,[_fin]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,compfile.C.
	LD HL,[_fn]
	LD [strpush.A.],HL
	LD HL,[_lenfn]
	LD [strpush.B.],HL
	CALL strpush
	LD HL,[_fn]
	LD [strjoineol.A.],HL
	LD HL,0
	LD [strjoineol.B.],HL
	LD HL,[compfile.fn]
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
	LD A,FALSE
	LD [_waseof],A
	LD HL,1
	LD [_doskipcond],HL
	LD HL,1
	LD [_curline],HL
	CALL initrd
	CALL rdword
compfile.E.
	CALL eatcmd
	OR A
	JP Z,compfile.F.
	JP compfile.E.
compfile.F.
	LD HL,[_fin]
	LD [fclose.A.],HL
	CALL fclose
	LD HL,[_fn]
	LD [strpop.A.],HL
	CALL strpop
	LD [_lenfn],HL
	JP compfile.D.
compfile.C.
	LD HL,compfile.G.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[compfile.fn]
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
compfile.D.
	RET
strjoineollast
	LD HL,[strjoineollast.to]
	LD DE,[strjoineollast.tolen]
	ADD HL,DE
	LD [strjoineollast.to],HL
	LD HL,[strjoineollast.tolen]
	LD [strjoineollast.len],HL
	LD HL,0
	LD [strjoineollast.last],HL
strjoineollast.loop
	LD HL,[strjoineollast.s2]
	LD A,[HL]
	LD [strjoineollast.c],A
	LD A,[strjoineollast.c]
	SUB '\0'
	SUB 1
	SBC A,A
	LD DE,[strjoineollast.len]
	LD BC,_STRMAX
	LD L,A
	LD A,E
	SUB C
	LD A,D
	SBC A,B
	CCF
	SBC A,A
	OR L
	JP Z,strjoineollast.E.
	JP strjoineollast.endloop
strjoineollast.E.
	LD HL,[strjoineollast.to]
	LD A,[strjoineollast.c]
	LD [HL],A
	LD HL,[strjoineollast.s2]
	INC HL
	LD [strjoineollast.s2],HL
	LD A,[strjoineollast.c]
	LD L,A
	LD A,[strjoineollast.eol]
	SUB L
	JP NZ,strjoineollast.G.
	LD HL,[strjoineollast.len]
	LD [strjoineollast.last],HL
strjoineollast.G.
	LD HL,[strjoineollast.to]
	INC HL
	LD [strjoineollast.to],HL
	LD HL,[strjoineollast.len]
	INC HL
	LD [strjoineollast.len],HL
	JP strjoineollast.loop
strjoineollast.endloop
	LD HL,[strjoineollast.last]
	RET
compile
	LD HL,_s1
	LD [_prefix],HL
	LD HL,_s2
	LD [_title],HL
	LD HL,_s3
	LD [_callee],HL
	LD HL,_s4
	LD [_name],HL
	LD HL,_s5
	LD [_joined],HL
	LD HL,_s6
	LD [_ncells],HL
	LD HL,_m_fn
	LD [_fn],HL
	LD HL,0
	LD [_lenfn],HL
	LD HL,0
	LD [_tmpendlbl],HL
	LD HL,0
	LD [_lenstrstk],HL
	LD HL,0
	LD [_curlbl],HL
	CALL initlblbuf
	LD HL,compile.B.
	LD [strcopy.A.],HL
	LD HL,3
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,_T_TYPE
	ADD A,_T_INT
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,_T_INT
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,compile.C.
	LD [strcopy.A.],HL
	LD HL,4
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,_T_TYPE
	ADD A,_T_UINT
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,_T_UINT
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,compile.D.
	LD [strcopy.A.],HL
	LD HL,4
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,_T_TYPE
	ADD A,_T_BYTE
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,_T_BYTE
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,compile.E.
	LD [strcopy.A.],HL
	LD HL,4
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,_T_TYPE
	ADD A,_T_BOOL
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,_T_BOOL
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,compile.F.
	LD [strcopy.A.],HL
	LD HL,4
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,_T_TYPE
	ADD A,_T_LONG
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,_T_LONG
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,compile.G.
	LD [strcopy.A.],HL
	LD HL,4
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,_T_TYPE
	ADD A,_T_CHAR
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,_T_CHAR
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,compile.H.
	LD [strcopy.A.],HL
	LD HL,6
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,_T_TYPE
	ADD A,_T_STRUCTWORD
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,_T_STRUCT
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,compile.I.
	LD [strcopy.A.],HL
	LD HL,4
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,_T_TYPE
	ADD A,_T_POI
	ADD A,_T_INT
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,_T_POI
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,compile.J.
	LD [strcopy.A.],HL
	LD HL,5
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,_T_TYPE
	ADD A,_T_POI
	ADD A,_T_UINT
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,_T_POI
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,compile.K.
	LD [strcopy.A.],HL
	LD HL,5
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,_T_TYPE
	ADD A,_T_POI
	ADD A,_T_BYTE
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,_T_POI
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,compile.L.
	LD [strcopy.A.],HL
	LD HL,5
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,_T_TYPE
	ADD A,_T_POI
	ADD A,_T_BOOL
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,_T_POI
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,compile.M.
	LD [strcopy.A.],HL
	LD HL,5
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,_T_TYPE
	ADD A,_T_POI
	ADD A,_T_LONG
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,_T_POI
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,compile.N.
	LD [strcopy.A.],HL
	LD HL,5
	LD [strcopy.B.],HL
	LD HL,[_name]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenname],HL
	LD A,_T_TYPE
	ADD A,_T_POI
	ADD A,_T_CHAR
	LD [addlbl.A.],A
	LD A,FALSE
	LD [addlbl.B.],A
	LD HL,_typesz
	LD A,_T_POI
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [addlbl.C.],HL
	CALL addlbl
	LD HL,0
	LD [_lentitle],HL
	LD HL,[_title]
	LD A,'\0'
	LD [HL],A
	LD A,0x00
	LD [_namespclvl],A
	LD A,FALSE
	LD [_addrexpr],A
	LD A,FALSE
	LD [_isexp],A
	LD A,_T_UNKNOWN
	LD [_curfunct],A
	LD A,FALSE
	LD [_wasreturn],A
	LD HL,[_joined]
	LD [strjoineollast.A.],HL
	LD HL,0
	LD [strjoineollast.B.],HL
	LD HL,[compile.fn]
	LD [strjoineollast.C.],HL
	LD A,'.'
	LD [strjoineollast.D.],A
	CALL strjoineollast
	LD [_lenjoined],HL
	LD HL,[_joined]
	LD [strjoin.A.],HL
	LD HL,[_lenjoined]
	LD [strjoin.B.],HL
	LD HL,compile.O.
	LD [strjoin.C.],HL
	CALL strjoin
	LD [_lenjoined],HL
	LD HL,[_joined]
	LD DE,[_lenjoined]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	LD HL,[_joined]
	LD [openwrite.A.],HL
	CALL openwrite
	LD [_fout],HL
	LD HL,[_joined]
	LD [strjoineollast.A.],HL
	LD HL,0
	LD [strjoineollast.B.],HL
	LD HL,[compile.fn]
	LD [strjoineollast.C.],HL
	LD A,'.'
	LD [strjoineollast.D.],A
	CALL strjoineollast
	LD [_lenjoined],HL
	LD HL,[_joined]
	LD [strjoin.A.],HL
	LD HL,[_lenjoined]
	LD [strjoin.B.],HL
	LD HL,compile.P.
	LD [strjoin.C.],HL
	CALL strjoin
	LD [_lenjoined],HL
	LD HL,[_joined]
	LD DE,[_lenjoined]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	LD HL,[_joined]
	LD [openwrite.A.],HL
	CALL openwrite
	LD [_fvar],HL
	LD A,0x00
	LD [_nhinclfiles],A
	CALL initcmd
	CALL initcode
	LD HL,[compfile.A.]
	LD DE,[compile.fn]
	LD [compfile.A.],DE
	PUSH HL
	CALL compfile
	POP HL
	LD [compfile.A.],HL
	CALL endcode
	LD HL,[_fvar]
	LD [fclose.A.],HL
	CALL fclose
	LD HL,[_fout]
	LD [fclose.A.],HL
	CALL fclose
	RET
