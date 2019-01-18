	EXPORT _t
	EXPORT _isloc
	EXPORT _name
	EXPORT _lenname
	EXPORT _joined
	EXPORT _lenjoined
	EXPORT _callee
	EXPORT _lencallee
	EXPORT _exprlvl
_RNAME.A.
	DB ""
	DB 0
_RNAME.B.
	DB "HL"
	DB 0
_RNAME.C.
	DB "DE"
	DB 0
_RNAME.D.
	DB "BC"
	DB 0
_RNAME.E.
	DB "IX"
	DB 0
_RHIGH.F.
	DB ""
	DB 0
_RHIGH.G.
	DB "H"
	DB 0
_RHIGH.H.
	DB "D"
	DB 0
_RHIGH.I.
	DB "B"
	DB 0
_RHIGH.J.
	DB "HX"
	DB 0
_RLOW.K.
	DB ""
	DB 0
_RLOW.L.
	DB "L"
	DB 0
_RLOW.M.
	DB "E"
	DB 0
_RLOW.N.
	DB "C"
	DB 0
_RLOW.O.
	DB "LX"
	DB 0
	EXPORT _typesz
	EXPORT _typeshift
var_alignwsz
	EXPORT var_alignwsz
	RET
asm_comma
	LD A,','
	LD [asmc.A.],A
	CALL asmc
	RET
asm_open
	LD A,'['
	LD [asmc.A.],A
	CALL asmc
	RET
asm_close
	LD A,']'
	LD [asmc.A.],A
	CALL asmc
	RET
asm_rname
	LD HL,_RNAME
	LD A,[asm_rname.r]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_mrgname
	CALL asm_open
	LD A,[asm_mrgname.r]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL asm_close
	RET
asm_rlow
	LD HL,_RLOW
	LD A,[asm_rlow.r]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_rhigh
	LD HL,_RHIGH
	LD A,[asm_rhigh.r]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_close_eol
	CALL asm_close
	CALL endasm
	RET
asm_a
	LD A,'A'
	LD [asmc.A.],A
	CALL asmc
	RET
asm_hl
	LD A,0x01
	LD [asm_rname.A.],A
	CALL asm_rname
	RET
asm_mhl
	LD A,0x01
	LD [asm_mrgname.A.],A
	CALL asm_mrgname
	RET
var_db
	EXPORT var_db
	LD HL,var_db.A.
	LD [varstr.A.],HL
	CALL varstr
	RET
asm_db
	EXPORT asm_db
	LD HL,asm_db.A.
	LD [asmstr.A.],HL
	CALL asmstr
	RET
var_dw
	EXPORT var_dw
	LD HL,var_dw.A.
	LD [varstr.A.],HL
	CALL varstr
	RET
var_dl
	LD HL,var_dl.A.
	LD [varstr.A.],HL
	CALL varstr
	RET
var_ds
	EXPORT var_ds
	LD HL,var_ds.A.
	LD [varstr.A.],HL
	CALL varstr
	RET
asm_and
	LD HL,asm_and.A.
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_or
	LD HL,asm_or.A.
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_xor
	LD HL,asm_xor.A.
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_sub
	LD HL,asm_sub.A.
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_sbc
	LD HL,asm_sbc.A.
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_add
	LD HL,asm_add.A.
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_adc
	LD HL,asm_adc.A.
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_inc
	LD HL,asm_inc.A.
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_dec
	LD HL,asm_dec.A.
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_ld
	LD HL,asm_ld.A.
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_jp
	LD HL,asm_jp.A.
	LD [asmstr.A.],HL
	CALL asmstr
	RET
emitjrnz
	LD HL,emitjrnz.B.
	LD [asmstr.A.],HL
	CALL asmstr
	LD A,[emitjrnz.c]
	LD [asmc.A.],A
	CALL asmc
	CALL endasm
	RET
asm_ex
	LD HL,asm_ex.A.
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_push
	LD HL,asm_push.A.
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_pop
	LD HL,asm_pop.A.
	LD [asmstr.A.],HL
	CALL asmstr
	RET
asm_lda_comma
	CALL asm_ld
	CALL asm_a
	CALL asm_comma
	RET
asm_ldmhl_comma
	CALL asm_ld
	CALL asm_mhl
	CALL asm_comma
	RET
asm_comma_a_eol
	CALL asm_comma
	CALL asm_a
	CALL endasm
	RET
asm_comma_mhl_eol
	CALL asm_comma
	CALL asm_mhl
	CALL endasm
	RET
emitinchl
	CALL asm_inc
	LD A,0x01
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	RET
emitexa
	CALL asm_ex
	LD HL,emitexa.A.
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	RET
emitexd
	CALL asm_ex
	LD HL,emitexd.A.
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	RET
emitccf
	LD HL,emitccf.A.
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	RET
emitcall
	LD HL,emitcall.B.
	LD [asmstr.A.],HL
	CALL asmstr
	LD HL,[emitcall.s]
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	RET
unproxy
	LD A,[_rproxy]
	SUB 0x00
	JP Z,unproxy.A.
	CALL asm_ld
	LD A,[_rproxy]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_a_eol
	LD A,0x00
	LD [_rproxy],A
unproxy.A.
	RET
proxy
	LD A,[_rproxy]
	LD L,A
	LD A,[proxy.r]
	SUB L
	JP Z,proxy.B.
	CALL unproxy
	CALL asm_lda_comma
	LD A,[proxy.r]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	LD A,[proxy.r]
	LD [_rproxy],A
proxy.B.
	RET
emitpushrg
	CALL unproxy
	CALL asm_push
	LD A,[emitpushrg.rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	LD HL,[_funcstkdepth]
	INC HL
	LD [_funcstkdepth],HL
	RET
emitpoprg
	CALL asm_pop
	LD A,[emitpoprg.rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	LD HL,[_funcstkdepth]
	DEC HL
	LD [_funcstkdepth],HL
	RET
emitmovrg
	LD A,[emitmovrg.rsrc]
	LD L,A
	LD A,[emitmovrg.rdest]
	SUB L
	JP Z,emitmovrg.C.
	LD A,[emitmovrg.rdest]
	SUB 0x04
	SUB 1
	SBC A,A
	LD L,A
	LD A,[emitmovrg.rsrc]
	SUB 0x01
	SUB 1
	SBC A,A
	AND L
	LD L,A
	LD A,[emitmovrg.rdest]
	SUB 0x01
	SUB 1
	SBC A,A
	LD E,A
	LD A,[emitmovrg.rsrc]
	SUB 0x04
	SUB 1
	SBC A,A
	AND E
	OR L
	JP Z,emitmovrg.E.
	CALL asm_push
	LD A,[emitmovrg.rsrc]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	CALL asm_pop
	LD A,[emitmovrg.rdest]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	JP emitmovrg.F.
emitmovrg.E.
	CALL asm_ld
	LD A,[emitmovrg.rdest]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma
	LD A,[emitmovrg.rsrc]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_ld
	LD A,[emitmovrg.rdest]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma
	LD A,[emitmovrg.rsrc]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
emitmovrg.F.
emitmovrg.C.
	RET
emitasmlabel
	EXPORT emitasmlabel
	EXPORT emitasmlabel.A.
	LD HL,[emitasmlabel.s]
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	RET
emitfunclabel
	EXPORT emitfunclabel
	EXPORT emitfunclabel.A.
	LD HL,[emitfunclabel.s]
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	RET
emitvarlabel
	EXPORT emitvarlabel
	EXPORT emitvarlabel.A.
	LD HL,[emitvarlabel.s]
	LD [varstr.A.],HL
	CALL varstr
	CALL endvar
	RET
emitexport
	EXPORT emitexport
	EXPORT emitexport.A.
	LD HL,emitexport.B.
	LD [asmstr.A.],HL
	CALL asmstr
	LD HL,[emitexport.s]
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	RET
emitvarpreequ
	EXPORT emitvarpreequ
	EXPORT emitvarpreequ.A.
	RET
emitvarpostequ
	EXPORT emitvarpostequ
	RET
varequ
	EXPORT varequ
	EXPORT varequ.A.
	LD HL,[varequ.s]
	LD [varstr.A.],HL
	CALL varstr
	LD A,'='
	LD [varc.A.],A
	CALL varc
	RET
varshift
	EXPORT varshift
	EXPORT varshift.A.
	EXPORT varshift.B.
	LD HL,[_joined]
	LD [varequ.A.],HL
	CALL varequ
	LD HL,[varshift.shift]
	LD [varuint.A.],HL
	CALL varuint
	CALL endvar
	LD HL,[varshift.shift]
	RET
emitjpmainrg
	CALL unproxy
	CALL getnothing
	CALL asm_jp
	CALL asm_mhl
	CALL endasm
	RET
emitcallmainrg
	CALL unproxy
	CALL getnothing
	LD HL,emitcallmainrg.A.
	LD [emitcall.A.],HL
	CALL emitcall
	LD A,FALSE
	LD [_fused],A
	RET
emitjp
	CALL unproxy
	CALL getnothing
	CALL asm_jp
	LD HL,[_joined]
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	RET
emitbtoz
	LD A,[_fused]
	CPL
	OR A
	JP Z,emitbtoz.A.
	LD A,[_rnew]
	LD [proxy.A.],A
	CALL proxy
	CALL asm_or
	CALL asm_a
	CALL endasm
emitbtoz.A.
	LD A,0x00
	LD [_rproxy],A
	RET
emitjpiffalse
	CALL getnothing
	CALL asm_jp
	LD A,[_jpflag]
	SUB 0x02
	JP NZ,emitjpiffalse.A.
	LD HL,emitjpiffalse.C.
	LD [asmstr.A.],HL
	CALL asmstr
	JP emitjpiffalse.B.
emitjpiffalse.A.
	LD A,[_jpflag]
	SUB 0x03
	JP NZ,emitjpiffalse.D.
	LD HL,emitjpiffalse.F.
	LD [asmstr.A.],HL
	CALL asmstr
	JP emitjpiffalse.E.
emitjpiffalse.D.
	LD A,[_jpflag]
	SUB 0x04
	JP NZ,emitjpiffalse.G.
	LD A,'C'
	LD [asmc.A.],A
	CALL asmc
	JP emitjpiffalse.H.
emitjpiffalse.G.
	LD A,'Z'
	LD [asmc.A.],A
	CALL asmc
emitjpiffalse.H.
emitjpiffalse.E.
emitjpiffalse.B.
	CALL asm_comma
	LD HL,[_joined]
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	LD A,FALSE
	LD [_fused],A
	LD A,0x00
	LD [_jpflag],A
	RET
emitret
	LD HL,emitret.A.
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	RET
emitcall2rgs
	CALL unproxy
	CALL getmain2rgs
	CALL initrgs
	LD HL,[emitcall2rgs.s]
	LD [emitcall.A.],HL
	CALL emitcall
	CALL setmainrg
	RET
emitcall4rgs
	CALL unproxy
	CALL getmain4rgs
	CALL initrgs
	LD HL,[emitcall4rgs.s]
	LD [emitcall.A.],HL
	CALL emitcall
	CALL setmain2rgs
	RET
emitcallproc
	LD HL,[_callee]
	LD [emitcall.A.],HL
	CALL emitcall
	RET
emitloadrg
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL asm_comma
	LD HL,[_const]
	LD [asmstr.A.],HL
	CALL asmstr
	LD A,[emitloadrg.high]
	OR A
	JP Z,emitloadrg.B.
	LD HL,emitloadrg.D.
	LD [asmstr.A.],HL
	CALL asmstr
emitloadrg.B.
	CALL endasm
	LD A,FALSE
	LD [_fused],A
	RET
emitloadrg0
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL asm_comma
	LD A,'0'
	LD [asmc.A.],A
	CALL asmc
	CALL endasm
	RET
emitloadb
	LD A,[_rproxy]
	SUB 0x00
	JP NZ,emitloadb.A.
	LD A,[_rnew]
	LD [_rproxy],A
	CALL asm_lda_comma
	JP emitloadb.B.
emitloadb.A.
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma
emitloadb.B.
	LD HL,[_const]
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	LD A,FALSE
	LD [_fused],A
	RET
emitgetrg
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL asm_comma
	CALL asm_open
	LD HL,[_joined]
	LD [asmstr.A.],HL
	CALL asmstr
	LD A,[emitgetrg.high]
	OR A
	JP Z,emitgetrg.B.
	LD A,'+'
	LD [asmc.A.],A
	CALL asmc
	LD A,'2'
	LD [asmc.A.],A
	CALL asmc
emitgetrg.B.
	CALL asm_close
	CALL endasm
	RET
emitgetb
	CALL unproxy
	LD A,[_rnew]
	LD [_rproxy],A
	CALL asm_lda_comma
	CALL asm_open
	LD HL,[_joined]
	LD [asmstr.A.],HL
	CALL asmstr
	CALL asm_close
	CALL endasm
	RET
emitputrg
	CALL asm_ld
	CALL asm_open
	LD HL,[_joined]
	LD [asmstr.A.],HL
	CALL asmstr
	LD A,[emitputrg.high]
	OR A
	JP Z,emitputrg.B.
	LD A,'+'
	LD [asmc.A.],A
	CALL asmc
	LD A,'2'
	LD [asmc.A.],A
	CALL asmc
emitputrg.B.
	CALL asm_close
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	LD A,FALSE
	LD [_fused],A
	RET
emitputb
	LD A,[_rnew]
	LD [proxy.A.],A
	CALL proxy
	CALL asm_ld
	CALL asm_open
	LD HL,[_joined]
	LD [asmstr.A.],HL
	CALL asmstr
	CALL asm_close
	CALL asm_comma_a_eol
	LD A,0x00
	LD [_rproxy],A
	LD A,FALSE
	LD [_fused],A
	RET
emitshl1rg
	LD A,[_rnew]
	SUB 0x01
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_rnew]
	SUB 0x04
	SUB 1
	SBC A,A
	OR L
	JP Z,emitshl1rg.A.
	CALL asm_add
	CALL asm_hl
	CALL asm_comma
	CALL asm_hl
	CALL endasm
	JP emitshl1rg.B.
emitshl1rg.A.
	LD HL,emitshl1rg.C.
	LD [asmstr.A.],HL
	CALL asmstr
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	LD HL,emitshl1rg.D.
	LD [asmstr.A.],HL
	CALL asmstr
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
emitshl1rg.B.
	RET
emitshl1b
	LD A,[_rnew]
	LD [proxy.A.],A
	CALL proxy
	CALL asm_add
	CALL asm_a
	CALL asm_comma_a_eol
	RET
emitinvb
	LD A,[_rnew]
	LD [proxy.A.],A
	CALL proxy
	LD HL,emitinvb.A.
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	LD A,FALSE
	LD [_fused],A
	RET
emitinvrg
	CALL unproxy
	CALL asm_lda_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	LD HL,emitinvrg.A.
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_a_eol
	CALL emitinvb
	CALL unproxy
	RET
emitnegrg
	CALL unproxy
	CALL asm_xor
	CALL asm_a
	CALL endasm
	CALL asm_sub
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_a_eol
	CALL asm_sbc
	CALL asm_a
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_sub
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_a_eol
	RET
emitztob
	LD A,[_exprlvl]
	SUB 0x01
	JP Z,emitztob.A.
	LD A,[_azused]
	OR A
	JP Z,emitztob.C.
	CALL asm_sub
	LD A,'1'
	LD [asmc.A.],A
	CALL asmc
	CALL endasm
	CALL asm_sbc
	CALL asm_a
	CALL asm_comma_a_eol
	LD A,[_rnew]
	LD [_rproxy],A
	LD A,FALSE
	LD [_azused],A
	JP emitztob.D.
emitztob.C.
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma
	LD A,'0'
	LD [asmc.A.],A
	CALL asmc
	CALL endasm
	LD A,[_rnew]
	SUB 0x04
	JP Z,emitztob.E.
	LD A,'3'
	LD [emitjrnz.A.],A
	CALL emitjrnz
	JP emitztob.F.
emitztob.E.
	LD A,'4'
	LD [emitjrnz.A.],A
	CALL emitjrnz
emitztob.F.
	CALL asm_dec
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
emitztob.D.
	LD A,FALSE
	LD [_fused],A
	JP emitztob.B.
emitztob.A.
	LD A,0x02
	LD [_jpflag],A
emitztob.B.
	RET
emitinvztob
	LD A,[_exprlvl]
	SUB 0x01
	JP Z,emitinvztob.A.
	LD A,[_azused]
	OR A
	JP Z,emitinvztob.C.
	LD HL,emitinvztob.E.
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	CALL asm_lda_comma
	LD HL,emitinvztob.F.
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	LD A,[_rnew]
	LD [_rproxy],A
	LD A,FALSE
	LD [_azused],A
	JP emitinvztob.D.
emitinvztob.C.
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma
	LD A,'0'
	LD [asmc.A.],A
	CALL asmc
	CALL endasm
	LD A,[_rnew]
	SUB 0x04
	JP Z,emitinvztob.G.
	LD HL,emitinvztob.I.
	LD [asmstr.A.],HL
	CALL asmstr
	JP emitinvztob.H.
emitinvztob.G.
	LD HL,emitinvztob.J.
	LD [asmstr.A.],HL
	CALL asmstr
emitinvztob.H.
	CALL endasm
	CALL asm_dec
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
emitinvztob.D.
	LD A,FALSE
	LD [_fused],A
	JP emitinvztob.B.
emitinvztob.A.
	LD A,0x01
	LD [_jpflag],A
emitinvztob.B.
	RET
emitcytob
	LD A,[_exprlvl]
	SUB 0x01
	JP Z,emitcytob.A.
	CALL unproxy
	CALL asm_sbc
	CALL asm_a
	CALL asm_comma_a_eol
	LD A,[_rnew]
	LD [_rproxy],A
	JP emitcytob.B.
emitcytob.A.
	LD A,0x03
	LD [_jpflag],A
emitcytob.B.
	RET
emitinvcytob
	LD A,[_exprlvl]
	SUB 0x01
	JP Z,emitinvcytob.A.
	CALL emitccf
	CALL unproxy
	CALL asm_sbc
	CALL asm_a
	CALL asm_comma_a_eol
	LD A,[_rnew]
	LD [_rproxy],A
	JP emitinvcytob.B.
emitinvcytob.A.
	LD A,0x04
	LD [_jpflag],A
emitinvcytob.B.
	RET
emitSxorVtob
	LD HL,emitSxorVtob.A.
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	CALL asm_jp
	LD HL,emitSxorVtob.B.
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	CALL emitccf
	CALL emitcytob
	RET
emitinvSxorVtob
	LD HL,emitinvSxorVtob.A.
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	CALL asm_jp
	LD HL,emitinvSxorVtob.B.
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	CALL emitccf
	CALL emitcytob
	RET
emitxorrg
	CALL unproxy
	CALL asm_lda_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_xor
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_a_eol
	CALL asm_lda_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_xor
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_a_eol
	RET
getxorb
	LD A,[_rproxy]
	LD L,A
	LD A,[_rnew]
	SUB L
	JP NZ,getxorb.A.
	CALL asm_xor
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	LD A,[_rold]
	LD [_rproxy],A
	JP getxorb.B.
getxorb.A.
	LD A,[_rold]
	LD [proxy.A.],A
	CALL proxy
	CALL asm_xor
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
getxorb.B.
	CALL endasm
	LD A,TRUE
	LD [_fused],A
	RET
emitorrg
	CALL unproxy
	CALL asm_lda_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_or
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_a_eol
	CALL asm_lda_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_or
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_a_eol
	RET
getorb
	LD A,[_rproxy]
	LD L,A
	LD A,[_rnew]
	SUB L
	JP NZ,getorb.A.
	CALL asm_or
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	LD A,[_rold]
	LD [_rproxy],A
	JP getorb.B.
getorb.A.
	LD A,[_rold]
	LD [proxy.A.],A
	CALL proxy
	CALL asm_or
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
getorb.B.
	CALL endasm
	LD A,TRUE
	LD [_fused],A
	RET
emitandrg
	CALL unproxy
	CALL asm_lda_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_and
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_a_eol
	CALL asm_lda_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_and
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_a_eol
	RET
getandb
	LD A,[_rproxy]
	LD L,A
	LD A,[_rnew]
	SUB L
	JP NZ,getandb.A.
	CALL asm_and
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	LD A,[_rold]
	LD [_rproxy],A
	JP getandb.B.
getandb.A.
	LD A,[_rold]
	LD [proxy.A.],A
	CALL proxy
	CALL asm_and
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
getandb.B.
	CALL endasm
	LD A,TRUE
	LD [_fused],A
	RET
emitaddrg
	LD A,[_rold]
	SUB 0x01
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_rnew]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,emitaddrg.A.
	CALL asm_add
	CALL asm_hl
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	JP emitaddrg.B.
emitaddrg.A.
	LD A,[_rold]
	SUB 0x02
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_rnew]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,emitaddrg.C.
	CALL emitexd
	CALL asm_add
	CALL asm_hl
	CALL asm_comma
	LD A,[_rnew]
	SUB 0x01
	JP NZ,emitaddrg.E.
	LD A,0x02
	LD [asm_rname.A.],A
	CALL asm_rname
	JP emitaddrg.F.
emitaddrg.E.
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
emitaddrg.F.
	CALL endasm
	CALL emitexd
	JP emitaddrg.D.
emitaddrg.C.
	CALL unproxy
	CALL asm_lda_comma
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_add
	CALL asm_a
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_a_eol
	CALL asm_lda_comma
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_adc
	CALL asm_a
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_a_eol
emitaddrg.D.
emitaddrg.B.
	RET
emitadcrg
	LD A,[_rold]
	SUB 0x01
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_rnew]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,emitadcrg.A.
	CALL asm_adc
	CALL asm_hl
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	JP emitadcrg.B.
emitadcrg.A.
	LD A,[_rold]
	SUB 0x02
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_rnew]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,emitadcrg.C.
	CALL emitexd
	CALL asm_adc
	CALL asm_hl
	CALL asm_comma
	LD A,[_rnew]
	SUB 0x01
	JP NZ,emitadcrg.E.
	LD A,0x02
	LD [asm_rname.A.],A
	CALL asm_rname
	JP emitadcrg.F.
emitadcrg.E.
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
emitadcrg.F.
	CALL endasm
	CALL emitexd
	JP emitadcrg.D.
emitadcrg.C.
	CALL unproxy
	CALL asm_lda_comma
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_adc
	CALL asm_a
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_a_eol
	CALL asm_lda_comma
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_adc
	CALL asm_a
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_a_eol
emitadcrg.D.
emitadcrg.B.
	RET
emitaddb
	LD A,[_rproxy]
	LD L,A
	LD A,[_rnew]
	SUB L
	JP NZ,emitaddb.A.
	CALL asm_add
	CALL asm_a
	CALL asm_comma
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	LD A,[_rold]
	LD [_rproxy],A
	JP emitaddb.B.
emitaddb.A.
	LD A,[_rold]
	LD [proxy.A.],A
	CALL proxy
	CALL asm_add
	CALL asm_a
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
emitaddb.B.
	RET
emitaddbconst
	LD A,[_rnew]
	LD [proxy.A.],A
	CALL proxy
	CALL asm_add
	CALL asm_a
	CALL asm_comma
	LD HL,[_const]
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	RET
emitsubrg
	LD A,[_rold]
	SUB 0x01
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_rnew]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,emitsubrg.A.
	CALL asm_or
	CALL asm_a
	CALL endasm
	CALL asm_sbc
	CALL asm_hl
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	JP emitsubrg.B.
emitsubrg.A.
	CALL unproxy
	CALL asm_lda_comma
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_sub
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_a_eol
	CALL asm_lda_comma
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_sbc
	CALL asm_a
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_a_eol
emitsubrg.B.
	RET
emitsbcrg
	LD A,[_rold]
	SUB 0x01
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_rnew]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,emitsbcrg.A.
	CALL asm_sbc
	CALL asm_hl
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	JP emitsbcrg.B.
emitsbcrg.A.
	LD A,[_rold]
	SUB 0x02
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_rnew]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,emitsbcrg.C.
	CALL emitexd
	CALL asm_sbc
	CALL asm_hl
	CALL asm_comma
	LD A,[_rnew]
	SUB 0x01
	JP NZ,emitsbcrg.E.
	LD A,0x02
	LD [asm_rname.A.],A
	CALL asm_rname
	JP emitsbcrg.F.
emitsbcrg.E.
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
emitsbcrg.F.
	CALL endasm
	CALL emitexd
	JP emitsbcrg.D.
emitsbcrg.C.
	CALL unproxy
	CALL asm_lda_comma
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_sbc
	CALL asm_a
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_a_eol
	CALL asm_lda_comma
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_sbc
	CALL asm_a
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_a_eol
emitsbcrg.D.
emitsbcrg.B.
	RET
emitsubb
	LD A,[_rold]
	LD [proxy.A.],A
	CALL proxy
	CALL asm_sub
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	RET
emitsubbconst
	LD A,[_rnew]
	LD [proxy.A.],A
	CALL proxy
	CALL asm_sub
	LD HL,[_const]
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	RET
emitsubflags
	CALL unproxy
	CALL asm_lda_comma
	LD A,[emitsubflags.rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_sub
	LD A,[emitsubflags.rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_lda_comma
	LD A,[emitsubflags.rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_sbc
	CALL asm_a
	CALL asm_comma
	LD A,[emitsubflags.rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	LD A,TRUE
	LD [_fused],A
	RET
emitsubbflags
	LD A,[emitsubbflags.aold]
	LD [proxy.A.],A
	CALL proxy
	CALL asm_sub
	LD A,[emitsubbflags.anew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	LD A,0x00
	LD [_rproxy],A
	LD A,TRUE
	LD [_fused],A
	RET
emitsubz
	LD A,[_rold]
	SUB 0x01
	JP NZ,emitsubz.A.
	CALL emitsubrg
	JP emitsubz.B.
emitsubz.A.
	CALL unproxy
	CALL asm_lda_comma
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_sub
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	LD A,[_rold]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	LD L,A
	LD A,[_rnew]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,emitsubz.C.
	LD A,'4'
	LD [emitjrnz.A.],A
	CALL emitjrnz
	JP emitsubz.D.
emitsubz.C.
	LD A,'5'
	LD [emitjrnz.A.],A
	CALL emitjrnz
emitsubz.D.
	CALL asm_lda_comma
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_sub
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	LD A,TRUE
	LD [_azused],A
emitsubz.B.
	LD A,TRUE
	LD [_fused],A
	RET
emitsubbz
	LD A,[_rproxy]
	LD L,A
	LD A,[_rnew]
	SUB L
	JP NZ,emitsubbz.A.
	CALL asm_sub
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	JP emitsubbz.B.
emitsubbz.A.
	LD A,[_rold]
	LD [proxy.A.],A
	CALL proxy
	CALL asm_sub
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
emitsubbz.B.
	CALL endasm
	LD A,0x00
	LD [_rproxy],A
	LD A,TRUE
	LD [_azused],A
	LD A,TRUE
	LD [_fused],A
	RET
emitsubbzconst
	LD A,[_rnew]
	LD [proxy.A.],A
	CALL proxy
	CALL asm_sub
	LD HL,[_const]
	LD [asmstr.A.],HL
	CALL asmstr
	CALL endasm
	LD A,0x00
	LD [_rproxy],A
	LD A,TRUE
	LD [_azused],A
	LD A,TRUE
	LD [_fused],A
	RET
emitsublongz
	CALL unproxy
	CALL asm_lda_comma
	LD A,[_rold2]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_sub
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	LD A,[_rold3]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	LD L,A
	LD A,[_rold]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,emitsublongz.A.
	LD A,'d'
	LD [emitjrnz.A.],A
	CALL emitjrnz
	JP emitsublongz.B.
emitsublongz.A.
	LD A,'e'
	LD [emitjrnz.A.],A
	CALL emitjrnz
emitsublongz.B.
	CALL asm_lda_comma
	LD A,[_rold2]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_sub
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	LD A,[_rold3]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	LD L,A
	LD A,[_rold]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,emitsublongz.C.
	LD A,'8'
	LD [emitjrnz.A.],A
	CALL emitjrnz
	JP emitsublongz.D.
emitsublongz.C.
	LD A,'a'
	LD [emitjrnz.A.],A
	CALL emitjrnz
emitsublongz.D.
	CALL asm_lda_comma
	LD A,[_rold3]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_sub
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	LD A,[_rold3]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	LD L,A
	LD A,[_rold]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,emitsublongz.E.
	LD A,'4'
	LD [emitjrnz.A.],A
	CALL emitjrnz
	JP emitsublongz.F.
emitsublongz.E.
	LD A,'5'
	LD [emitjrnz.A.],A
	CALL emitjrnz
emitsublongz.F.
	CALL asm_lda_comma
	LD A,[_rold3]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_sub
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	LD A,TRUE
	LD [_fused],A
	RET
emitpokerg
	LD A,[_rold]
	SUB 0x01
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_rnew]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,emitpokerg.A.
	CALL asm_ldmhl_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL emitinchl
	CALL asm_ldmhl_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	JP emitpokerg.B.
emitpokerg.A.
	CALL unproxy
	CALL asm_lda_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_mrgname.A.],A
	CALL asm_mrgname
	CALL asm_comma_a_eol
	CALL asm_inc
	LD A,[_rold]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	CALL asm_lda_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_mrgname.A.],A
	CALL asm_mrgname
	CALL asm_comma_a_eol
emitpokerg.B.
	LD A,FALSE
	LD [_fused],A
	RET
emitpokeb
	LD A,[_rold]
	SUB 0x01
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_rnew]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	AND L
	LD L,A
	LD A,[_rproxy]
	LD E,A
	LD A,[_rnew]
	SUB E
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,emitpokeb.A.
	CALL asm_ld
	CALL asm_mhl
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	JP emitpokeb.B.
emitpokeb.A.
	LD A,[_rnew]
	LD [proxy.A.],A
	CALL proxy
	CALL asm_ld
	LD A,[_rold]
	LD [asm_mrgname.A.],A
	CALL asm_mrgname
	CALL asm_comma_a_eol
emitpokeb.B.
	LD A,0x00
	LD [_rproxy],A
	LD A,FALSE
	LD [_fused],A
	RET
emitpokelong
	LD A,[_rold2]
	SUB 0x01
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_rnew]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,emitpokelong.A.
	CALL asm_ldmhl_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL emitinchl
	CALL asm_ldmhl_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL emitinchl
	CALL asm_ldmhl_comma
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL emitinchl
	CALL asm_ldmhl_comma
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	JP emitpokelong.B.
emitpokelong.A.
	CALL unproxy
	CALL asm_lda_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_ld
	LD A,[_rold2]
	LD [asm_mrgname.A.],A
	CALL asm_mrgname
	CALL asm_comma_a_eol
	CALL asm_inc
	LD A,[_rold2]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	CALL asm_lda_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_ld
	LD A,[_rold2]
	LD [asm_mrgname.A.],A
	CALL asm_mrgname
	CALL asm_comma_a_eol
	CALL asm_inc
	LD A,[_rold2]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	CALL asm_lda_comma
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_ld
	LD A,[_rold2]
	LD [asm_mrgname.A.],A
	CALL asm_mrgname
	CALL asm_comma_a_eol
	CALL asm_inc
	LD A,[_rold2]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	CALL asm_lda_comma
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_ld
	LD A,[_rold2]
	LD [asm_mrgname.A.],A
	CALL asm_mrgname
	CALL asm_comma_a_eol
emitpokelong.B.
	LD A,FALSE
	LD [_fused],A
	RET
asm_lda_mrgname_eol
	CALL asm_lda_comma
	LD A,[asm_lda_mrgname_eol.r]
	LD [asm_mrgname.A.],A
	CALL asm_mrgname
	CALL endasm
	RET
emitpeekrg
	CALL unproxy
	LD A,[_rnew]
	SUB 0x01
	JP NZ,emitpeekrg.A.
	CALL asm_lda_comma
	CALL asm_mhl
	CALL endasm
	CALL emitinchl
	CALL asm_ld
	LD A,'H'
	LD [asmc.A.],A
	CALL asmc
	CALL asm_comma_mhl_eol
	CALL asm_ld
	LD A,'L'
	LD [asmc.A.],A
	CALL asmc
	CALL asm_comma_a_eol
	JP emitpeekrg.B.
emitpeekrg.A.
	LD A,[_rnew]
	LD [asm_lda_mrgname_eol.A.],A
	CALL asm_lda_mrgname_eol
	CALL asm_inc
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	CALL emitexa
	LD A,[_rnew]
	LD [asm_lda_mrgname_eol.A.],A
	CALL asm_lda_mrgname_eol
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_a_eol
	CALL emitexa
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_a_eol
emitpeekrg.B.
	RET
emitpeekb
	CALL unproxy
	LD A,[_rnew]
	LD [_rproxy],A
	LD A,[_rnew]
	LD [asm_lda_mrgname_eol.A.],A
	CALL asm_lda_mrgname_eol
	RET
emitpeeklong
	CALL unproxy
	LD A,[_rold]
	SUB 0x01
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_rnew]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	AND L
	JP Z,emitpeeklong.A.
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_mhl_eol
	CALL emitinchl
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_mhl_eol
	CALL emitinchl
	CALL asm_lda_comma
	CALL asm_mhl
	CALL endasm
	CALL emitinchl
	CALL asm_ld
	LD A,'H'
	LD [asmc.A.],A
	CALL asmc
	CALL asm_comma_mhl_eol
	CALL asm_ld
	LD A,'L'
	LD [asmc.A.],A
	CALL asmc
	CALL asm_comma_a_eol
	JP emitpeeklong.B.
emitpeeklong.A.
	LD A,[_rold]
	LD [asm_lda_mrgname_eol.A.],A
	CALL asm_lda_mrgname_eol
	CALL asm_inc
	LD A,[_rold]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_a_eol
	LD A,[_rold]
	LD [asm_lda_mrgname_eol.A.],A
	CALL asm_lda_mrgname_eol
	CALL asm_inc
	LD A,[_rold]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_a_eol
	LD A,[_rold]
	LD [asm_lda_mrgname_eol.A.],A
	CALL asm_lda_mrgname_eol
	CALL asm_inc
	LD A,[_rold]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	CALL emitexa
	LD A,[_rold]
	LD [asm_lda_mrgname_eol.A.],A
	CALL asm_lda_mrgname_eol
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_a_eol
	CALL emitexa
	CALL asm_ld
	LD A,[_rold]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_a_eol
emitpeeklong.B.
	RET
emitrgtob
	RET
emitbtorg
	CALL unproxy
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma
	LD A,'0'
	LD [asmc.A.],A
	CALL asmc
	CALL endasm
	RET
emitincrg_byname
	LD A,FALSE
	LD [emitgetrg.A.],A
	CALL emitgetrg
	CALL asm_inc
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	LD A,FALSE
	LD [emitputrg.A.],A
	CALL emitputrg
	LD A,FALSE
	LD [_fused],A
	RET
emitincb_bypoi
	LD A,[_rnew]
	SUB 0x01
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_rnew]
	SUB 0x04
	SUB 1
	SBC A,A
	OR L
	JP Z,emitincb_bypoi.A.
	CALL asm_inc
	CALL asm_open
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL asm_close
	CALL endasm
	JP emitincb_bypoi.B.
emitincb_bypoi.A.
	LD A,[_rnew]
	SUB 0x02
	JP NZ,emitincb_bypoi.C.
	CALL emitexd
	CALL asm_inc
	CALL asm_mhl
	CALL endasm
	CALL emitexd
	JP emitincb_bypoi.D.
emitincb_bypoi.C.
	CALL unproxy
	LD A,[_rnew]
	LD [asm_lda_mrgname_eol.A.],A
	CALL asm_lda_mrgname_eol
	CALL asm_inc
	CALL asm_a
	CALL endasm
	CALL asm_ld
	CALL asm_open
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL asm_close
	CALL asm_comma_a_eol
emitincb_bypoi.D.
emitincb_bypoi.B.
	LD A,FALSE
	LD [_fused],A
	RET
emitdecrg_byname
	LD A,FALSE
	LD [emitgetrg.A.],A
	CALL emitgetrg
	CALL asm_dec
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	LD A,FALSE
	LD [emitputrg.A.],A
	CALL emitputrg
	LD A,FALSE
	LD [_fused],A
	RET
emitdecb_bypoi
	LD A,[_rnew]
	SUB 0x01
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_rnew]
	SUB 0x04
	SUB 1
	SBC A,A
	OR L
	JP Z,emitdecb_bypoi.A.
	CALL asm_dec
	CALL asm_open
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL asm_close
	CALL endasm
	JP emitdecb_bypoi.B.
emitdecb_bypoi.A.
	LD A,[_rnew]
	SUB 0x02
	JP NZ,emitdecb_bypoi.C.
	CALL emitexd
	CALL asm_dec
	CALL asm_mhl
	CALL endasm
	CALL emitexd
	JP emitdecb_bypoi.D.
emitdecb_bypoi.C.
	CALL unproxy
	LD A,[_rnew]
	LD [asm_lda_mrgname_eol.A.],A
	CALL asm_lda_mrgname_eol
	CALL asm_dec
	CALL asm_a
	CALL endasm
	CALL asm_ld
	CALL asm_open
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL asm_close
	CALL asm_comma_a_eol
emitdecb_bypoi.D.
emitdecb_bypoi.B.
	LD A,FALSE
	LD [_fused],A
	RET
emitincrg_bypoi
	LD A,[_rold]
	SUB 0x01
	JP NZ,emitincrg_bypoi.A.
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_mhl_eol
	CALL emitinchl
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_mhl_eol
	CALL asm_inc
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	CALL asm_ld
	CALL asm_mhl
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_dec
	CALL asm_hl
	CALL endasm
	CALL asm_ld
	CALL asm_mhl
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	JP emitincrg_bypoi.B.
emitincrg_bypoi.A.
	CALL unproxy
	LD A,[_rold]
	LD [asm_lda_mrgname_eol.A.],A
	CALL asm_lda_mrgname_eol
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_a_eol
	CALL asm_inc
	LD A,[_rold]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	LD A,[_rold]
	LD [asm_lda_mrgname_eol.A.],A
	CALL asm_lda_mrgname_eol
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_a_eol
	CALL asm_inc
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	CALL asm_lda_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_mrgname.A.],A
	CALL asm_mrgname
	CALL asm_comma_a_eol
	CALL asm_dec
	LD A,[_rold]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	CALL asm_lda_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_mrgname.A.],A
	CALL asm_mrgname
	CALL asm_comma_a_eol
emitincrg_bypoi.B.
	LD A,FALSE
	LD [_fused],A
	RET
emitdecrg_bypoi
	LD A,[_rold]
	SUB 0x01
	JP NZ,emitdecrg_bypoi.A.
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_mhl_eol
	CALL emitinchl
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_mhl_eol
	CALL asm_dec
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	CALL asm_ld
	CALL asm_mhl
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_dec
	CALL asm_hl
	CALL endasm
	CALL asm_ld
	CALL asm_mhl
	CALL asm_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	JP emitdecrg_bypoi.B.
emitdecrg_bypoi.A.
	CALL unproxy
	LD A,[_rold]
	LD [asm_lda_mrgname_eol.A.],A
	CALL asm_lda_mrgname_eol
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL asm_comma_a_eol
	CALL asm_inc
	LD A,[_rold]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	LD A,[_rold]
	LD [asm_lda_mrgname_eol.A.],A
	CALL asm_lda_mrgname_eol
	CALL asm_ld
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL asm_comma_a_eol
	CALL asm_dec
	LD A,[_rnew]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	CALL asm_lda_comma
	LD A,[_rnew]
	LD [asm_rhigh.A.],A
	CALL asm_rhigh
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_mrgname.A.],A
	CALL asm_mrgname
	CALL asm_comma_a_eol
	CALL asm_dec
	LD A,[_rold]
	LD [asm_rname.A.],A
	CALL asm_rname
	CALL endasm
	CALL asm_lda_comma
	LD A,[_rnew]
	LD [asm_rlow.A.],A
	CALL asm_rlow
	CALL endasm
	CALL asm_ld
	LD A,[_rold]
	LD [asm_mrgname.A.],A
	CALL asm_mrgname
	CALL asm_comma_a_eol
emitdecrg_bypoi.B.
	LD A,FALSE
	LD [_fused],A
	RET
initcode
	EXPORT initcode
	LD A,0x00
	LD [_jpflag],A
	RET
endcode
	EXPORT endcode
	RET
initrgs
	CALL rgs_initrgs
	LD A,FALSE
	LD [_azused],A
	LD A,FALSE
	LD [_fused],A
	LD A,0x00
	LD [_rproxy],A
	RET
emitfunchead
	CALL initrgs
	RET
setmainb
	CALL setmainrg
	LD A,_RMAIN
	LD [_rproxy],A
	RET
prefernoregs
	CALL getnothing
	RET
moverg
	LD HL,_usedrg
	LD A,[moverg.rsrcindex]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [moverg.rsrc],A
	LD A,[moverg.rsrc]
	LD [emitmovrg.A.],A
	LD A,[moverg.rdest]
	LD [emitmovrg.B.],A
	CALL emitmovrg
	LD HL,_usedrg
	LD A,[moverg.rsrcindex]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[moverg.rdest]
	LD [HL],A
	LD A,[moverg.rsrc]
	LD [nouserg.A.],A
	CALL nouserg
	LD A,[moverg.rdest]
	LD [userg.A.],A
	CALL userg
	RET
pushtailrg
	LD HL,_usedrg
	LD DE,0
	ADD HL,DE
	LD A,[HL]
	LD [pushtailrg.rnew],A
	LD A,[pushtailrg.rnew]
	LD [emitpushrg.A.],A
	CALL emitpushrg
	LD A,0x01
	LD [pushtailrg.i],A
pushtailrg.A.
	LD A,[pushtailrg.i]
	LD L,A
	LD A,[_usedrgs]
	LD E,A
	LD A,L
	SUB E
	JP NC,pushtailrg.B.
	LD HL,_usedrg
	LD A,[pushtailrg.i]
	SUB 0x01
	LD E,A
	LD D,0
	ADD HL,DE
	LD DE,_usedrg
	LD A,[pushtailrg.i]
	LD C,A
	LD B,0
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	LD A,[DE]
	LD [HL],A
	LD HL,pushtailrg.i
	INC [HL]
	JP pushtailrg.A.
pushtailrg.B.
	LD A,[pushtailrg.rnew]
	LD [nouserg.A.],A
	CALL nouserg
	RET
findrfree
	LD A,[_usedrgs]
	SUB _NRGS
	JP NZ,findrfree.A.
	CALL pushtailrg
findrfree.A.
	LD A,[_usedr1]
	CPL
	OR A
	JP Z,findrfree.C.
	LD A,0x01
	LD [findrfree.result],A
	JP findrfree.D.
findrfree.C.
	LD A,[_usedr2]
	CPL
	OR A
	JP Z,findrfree.E.
	LD A,0x02
	LD [findrfree.result],A
	JP findrfree.F.
findrfree.E.
	LD A,[_usedr3]
	CPL
	OR A
	JP Z,findrfree.G.
	LD A,0x03
	LD [findrfree.result],A
	JP findrfree.H.
findrfree.G.
	LD A,0x04
	LD [findrfree.result],A
findrfree.H.
findrfree.F.
findrfree.D.
	LD A,[findrfree.result]
	RET
nouserg
	LD A,[nouserg.rnew]
	SUB 0x01
	JP NZ,nouserg.B.
	LD A,FALSE
	LD [_usedr1],A
	JP nouserg.C.
nouserg.B.
	LD A,[nouserg.rnew]
	SUB 0x02
	JP NZ,nouserg.D.
	LD A,FALSE
	LD [_usedr2],A
	JP nouserg.E.
nouserg.D.
	LD A,[nouserg.rnew]
	SUB 0x03
	JP NZ,nouserg.F.
	LD A,FALSE
	LD [_usedr3],A
	JP nouserg.G.
nouserg.F.
	LD A,FALSE
	LD [_usedr4],A
nouserg.G.
nouserg.E.
nouserg.C.
	LD HL,_usedrgs
	DEC [HL]
	RET
userg
	LD A,[userg.rnew]
	SUB 0x01
	JP NZ,userg.B.
	LD A,TRUE
	LD [_usedr1],A
	JP userg.C.
userg.B.
	LD A,[userg.rnew]
	SUB 0x02
	JP NZ,userg.D.
	LD A,TRUE
	LD [_usedr2],A
	JP userg.E.
userg.D.
	LD A,[userg.rnew]
	SUB 0x03
	JP NZ,userg.F.
	LD A,TRUE
	LD [_usedr3],A
	JP userg.G.
userg.F.
	LD A,FALSE
	LD [_usedr4],A
userg.G.
userg.E.
userg.C.
	LD HL,_usedrgs
	INC [HL]
	LD A,[userg.rnew]
	RET
getrg
	LD HL,_usedrg
	LD A,[_usedrgs]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[getrg.rnew]
	LD [HL],A
	LD A,[getrg.rnew]
	LD [userg.A.],A
	CALL userg
	LD A,[getrg.rnew]
	RET
popgetrg
	LD A,[_usedrgs]
	LD [popgetrg.i],A
popgetrg.B.
	LD A,[popgetrg.i]
	LD E,0x00
	LD L,A
	LD A,E
	SUB L
	JP NC,popgetrg.C.
	LD HL,_usedrg
	LD A,[popgetrg.i]
	LD E,A
	LD D,0
	ADD HL,DE
	LD DE,_usedrg
	LD A,[popgetrg.i]
	SUB 0x01
	LD C,A
	LD B,0
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	LD A,[DE]
	LD [HL],A
	LD HL,popgetrg.i
	DEC [HL]
	JP popgetrg.B.
popgetrg.C.
	LD HL,_usedrg
	LD DE,0
	ADD HL,DE
	LD A,[popgetrg.rnew]
	LD [HL],A
	LD A,[popgetrg.rnew]
	LD [userg.A.],A
	CALL userg
	LD A,[popgetrg.rnew]
	LD [emitpoprg.A.],A
	CALL emitpoprg
	RET
swaptop
	LD A,[_usedrgs]
	SUB 0x00
	JP NZ,swaptop.A.
	LD A,0x02
	LD [popgetrg.A.],A
	CALL popgetrg
swaptop.A.
	LD A,[_usedrgs]
	SUB 0x01
	JP NZ,swaptop.C.
	CALL findrfree
	LD [popgetrg.A.],A
	CALL popgetrg
swaptop.C.
	LD HL,_usedrg
	LD A,[_usedrgs]
	SUB 0x02
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [swaptop.rtmp],A
	LD HL,_usedrg
	LD A,[_usedrgs]
	SUB 0x02
	LD E,A
	LD D,0
	ADD HL,DE
	LD DE,_usedrg
	LD A,[_usedrgs]
	SUB 0x01
	LD C,A
	LD B,0
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	LD A,[DE]
	LD [HL],A
	LD HL,_usedrg
	LD A,[_usedrgs]
	SUB 0x01
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[swaptop.rtmp]
	LD [HL],A
	RET
rgs_initrgs
	LD A,FALSE
	LD [_usedr1],A
	LD A,FALSE
	LD [_usedr2],A
	LD A,FALSE
	LD [_usedr3],A
	LD A,FALSE
	LD [_usedr4],A
	LD A,0x00
	LD [_usedrgs],A
	RET
getrnew
	LD A,[_usedrgs]
	SUB 0x00
	JP NZ,getrnew.A.
	LD A,0x01
	LD [popgetrg.A.],A
	CALL popgetrg
getrnew.A.
	LD HL,_usedrg
	LD A,[_usedrgs]
	SUB 0x01
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_rnew],A
	RET
getrold
	LD A,[_usedrgs]
	SUB 0x00
	JP NZ,getrold.A.
	LD A,0x02
	LD [popgetrg.A.],A
	CALL popgetrg
getrold.A.
	LD A,[_usedrgs]
	SUB 0x01
	JP NZ,getrold.C.
	CALL findrfree
	LD [popgetrg.A.],A
	CALL popgetrg
getrold.C.
	LD HL,_usedrg
	LD A,[_usedrgs]
	SUB 0x02
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_rold],A
	RET
getrold2
	LD A,[_usedrgs]
	SUB 0x00
	JP NZ,getrold2.A.
	LD A,0x03
	LD [popgetrg.A.],A
	CALL popgetrg
getrold2.A.
	LD A,[_usedrgs]
	SUB 0x01
	JP NZ,getrold2.C.
	LD HL,_usedrg
	LD DE,0
	ADD HL,DE
	LD A,[HL]
	SUB 0x02
	JP Z,getrold2.E.
	LD A,0x02
	LD [popgetrg.A.],A
	CALL popgetrg
	JP getrold2.F.
getrold2.E.
	CALL findrfree
	LD [popgetrg.A.],A
	CALL popgetrg
getrold2.F.
getrold2.C.
	LD A,[_usedrgs]
	SUB 0x02
	JP NZ,getrold2.G.
	CALL findrfree
	LD [popgetrg.A.],A
	CALL popgetrg
getrold2.G.
	LD HL,_usedrg
	LD A,[_usedrgs]
	SUB 0x03
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_rold],A
	RET
getrold3
	LD A,[_usedrgs]
	SUB 0x00
	JP NZ,getrold3.A.
	LD A,0x03
	LD [popgetrg.A.],A
	CALL popgetrg
getrold3.A.
	LD A,[_usedrgs]
	SUB 0x01
	JP NZ,getrold3.C.
	CALL findrfree
	LD [popgetrg.A.],A
	CALL popgetrg
getrold3.C.
	LD A,[_usedrgs]
	SUB 0x02
	JP NZ,getrold3.E.
	CALL findrfree
	LD [popgetrg.A.],A
	CALL popgetrg
getrold3.E.
	LD A,[_usedrgs]
	SUB 0x03
	JP NZ,getrold3.G.
	CALL findrfree
	LD [popgetrg.A.],A
	CALL popgetrg
getrold3.G.
	LD HL,_usedrg
	LD A,[_usedrgs]
	SUB 0x04
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_rold],A
	RET
freernew
	CALL getrnew
	LD HL,_usedrg
	LD A,[_usedrgs]
	SUB 0x01
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [nouserg.A.],A
	CALL nouserg
	RET
getnothing
getnothing.A.
	LD A,[_usedrgs]
	LD E,0x00
	LD L,A
	LD A,E
	SUB L
	JP NC,getnothing.B.
	CALL pushtailrg
	JP getnothing.A.
getnothing.B.
	RET
getrfree
	CALL findrfree
	LD [getrg.A.],A
	CALL getrg
	LD [_rnew],A
	RET
getmainrg
	LD A,[_usedrgs]
	SUB 0x00
	JP NZ,getmainrg.A.
	LD A,_RMAIN
	LD [popgetrg.A.],A
	CALL popgetrg
getmainrg.A.
getmainrg.C.
	LD A,[_usedrgs]
	LD E,0x01
	LD L,A
	LD A,E
	SUB L
	JP NC,getmainrg.D.
	CALL pushtailrg
	JP getmainrg.C.
getmainrg.D.
	LD A,0x00
	LD [moverg.A.],A
	LD A,_RMAIN
	LD [moverg.B.],A
	CALL moverg
	RET
getmain2rgs
	LD A,[_usedrgs]
	SUB 0x00
	JP NZ,getmain2rgs.A.
	LD A,_RMAIN2
	LD [popgetrg.A.],A
	CALL popgetrg
getmain2rgs.A.
	LD A,[_usedrgs]
	SUB 0x01
	JP NZ,getmain2rgs.C.
	LD A,0x00
	LD [moverg.A.],A
	LD A,_RMAIN2
	LD [moverg.B.],A
	CALL moverg
	LD A,_RMAIN
	LD [popgetrg.A.],A
	CALL popgetrg
getmain2rgs.C.
getmain2rgs.E.
	LD A,[_usedrgs]
	LD E,0x02
	LD L,A
	LD A,E
	SUB L
	JP NC,getmain2rgs.F.
	CALL pushtailrg
	JP getmain2rgs.E.
getmain2rgs.F.
	LD HL,_usedrg
	LD DE,0
	ADD HL,DE
	LD A,[HL]
	SUB _RMAIN
	JP NZ,getmain2rgs.G.
	LD A,0x01
	LD [moverg.A.],A
	LD A,_RMAIN2
	LD [moverg.B.],A
	CALL moverg
	JP getmain2rgs.H.
getmain2rgs.G.
	LD HL,_usedrg
	LD DE,1
	ADD HL,DE
	LD A,[HL]
	SUB _RMAIN
	JP NZ,getmain2rgs.I.
	LD HL,_usedrg
	LD DE,0
	ADD HL,DE
	LD A,[HL]
	SUB _RMAIN2
	JP NZ,getmain2rgs.K.
	CALL pushtailrg
	LD A,0x00
	LD [moverg.A.],A
	LD A,_RMAIN2
	LD [moverg.B.],A
	CALL moverg
	LD A,_RMAIN
	LD [popgetrg.A.],A
	CALL popgetrg
	JP getmain2rgs.L.
getmain2rgs.K.
	LD A,0x01
	LD [moverg.A.],A
	LD A,_RMAIN2
	LD [moverg.B.],A
	CALL moverg
getmain2rgs.L.
getmain2rgs.I.
getmain2rgs.H.
	LD A,0x00
	LD [moverg.A.],A
	LD A,_RMAIN
	LD [moverg.B.],A
	CALL moverg
	LD A,0x01
	LD [moverg.A.],A
	LD A,_RMAIN2
	LD [moverg.B.],A
	CALL moverg
	RET
getmain4rgs
	LD A,[_usedrgs]
	SUB 0x04
	JR Z,$+4
	LD A,-1
	LD DE,_usedrg
	LD BC,0
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	LD L,A
	LD A,[DE]
	SUB _RMAIN
	JR Z,$+4
	LD A,-1
	OR L
	LD DE,_usedrg
	LD BC,1
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	LD L,A
	LD A,[DE]
	SUB _RMAIN2
	JR Z,$+4
	LD A,-1
	OR L
	LD DE,_usedrg
	LD BC,2
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	LD L,A
	LD A,[DE]
	SUB _RMAIN3
	JR Z,$+4
	LD A,-1
	OR L
	LD DE,_usedrg
	LD BC,3
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	LD L,A
	LD A,[DE]
	SUB _RMAIN4
	JR Z,$+4
	LD A,-1
	OR L
	JP Z,getmain4rgs.A.
	CALL getnothing
	LD A,_RMAIN4
	LD [popgetrg.A.],A
	CALL popgetrg
	LD A,_RMAIN3
	LD [popgetrg.A.],A
	CALL popgetrg
	LD A,_RMAIN2
	LD [popgetrg.A.],A
	CALL popgetrg
	LD A,_RMAIN
	LD [popgetrg.A.],A
	CALL popgetrg
getmain4rgs.A.
	RET
setmainrg
	LD A,_RMAIN
	LD [getrg.A.],A
	CALL getrg
	RET
setmain2rgs
	LD A,_RMAIN
	LD [getrg.A.],A
	CALL getrg
	LD A,_RMAIN2
	LD [getrg.A.],A
	CALL getrg
	RET
	EXPORT _lenstrstk
	EXPORT _varszaddr
	EXPORT _varsz
errtype
	LD HL,errtype.C.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[errtype.msg]
	LD [errstr.A.],HL
	CALL errstr
	LD HL,errtype.D.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[errtype.t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	CALL enderr
	RET
strpush
	EXPORT strpush
	EXPORT strpush.A.
	EXPORT strpush.B.
	LD HL,[_lenstrstk]
	LD DE,[strpush.len]
	ADD HL,DE
	LD DE,2
	ADD HL,DE
	LD DE,_STRSTKMAX
	LD A,E
	SUB L
	LD A,D
	SBC A,H
	JP NC,strpush.C.
	LD HL,strpush.E.
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
	JP strpush.D.
strpush.C.
	LD HL,[strpush.s]
	LD [strcopy.A.],HL
	LD HL,[strpush.len]
	LD [strcopy.B.],HL
	LD HL,_strstk
	LD DE,[_lenstrstk]
	ADD HL,DE
	LD [strcopy.C.],HL
	CALL strcopy
	LD HL,[_lenstrstk]
	LD DE,[strpush.len]
	ADD HL,DE
	LD DE,1
	ADD HL,DE
	LD [_lenstrstk],HL
	LD HL,_strstk
	LD DE,[_lenstrstk]
	ADD HL,DE
	LD DE,[strpush.len]
	LD [HL],E
	LD HL,[_lenstrstk]
	INC HL
	LD [_lenstrstk],HL
strpush.D.
	RET
strpop
	EXPORT strpop
	EXPORT strpop.A.
	EXPORT strpop.len
	LD HL,[_lenstrstk]
	DEC HL
	LD [_lenstrstk],HL
	LD HL,_strstk
	LD DE,[_lenstrstk]
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [strpop.len],HL
	LD HL,[_lenstrstk]
	LD DE,[strpop.len]
	OR A
	SBC HL,DE
	LD DE,1
	OR A
	SBC HL,DE
	LD [_lenstrstk],HL
	LD HL,_strstk
	LD DE,[_lenstrstk]
	ADD HL,DE
	LD [strcopy.A.],HL
	LD HL,[strpop.len]
	LD [strcopy.B.],HL
	LD HL,[strpop.s]
	LD [strcopy.C.],HL
	CALL strcopy
	LD HL,[strpop.len]
	RET
initlblbuf
	EXPORT initlblbuf
	LD A,0x00
	LD [_lblhash],A
initlblbuf.A.
	LD HL,_lblshift
	LD A,[_lblhash]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD DE,_LBLBUFEOF
	LD [HL],E
	INC HL
	LD [HL],D
	LD HL,_lblhash
	INC [HL]
	LD A,[_lblhash]
	SUB 0x00
	JP NZ,initlblbuf.A.
initlblbuf.B.
	LD HL,0
	LD [_lblbuffreeidx],HL
	RET
gettypename
	EXPORT gettypename
	EXPORT gettypename.A.
	LD HL,_lbls
	LD DE,[_typeaddr]
	ADD HL,DE
	LD [strcopy.A.],HL
	LD HL,_lbls
	LD DE,[_typeaddr]
	LD BC,1
	LD A,E
	SUB C
	LD E,A
	LD A,D
	SBC A,B
	LD D,A
	ADD HL,DE
	LD A,[HL]
	LD L,A
	LD H,0
	LD [strcopy.B.],HL
	LD HL,[gettypename.s]
	LD [strcopy.C.],HL
	CALL strcopy
	RET
setvarsz
	EXPORT setvarsz
	EXPORT setvarsz.A.
	EXPORT setvarsz.B.
	LD HL,_lbls
	LD DE,[setvarsz.addr]
	ADD HL,DE
	LD DE,[setvarsz.shift]
	LD [HL],E
	INC HL
	LD [HL],D
	RET
lbltype
	EXPORT lbltype
	EXPORT lbltype.plbl
	LD A,_T_UNKNOWN
	LD [lbltype.t],A
	LD HL,[_name]
	LD [hash.A.],HL
	CALL hash
	LD A,L
	LD [_lblhash],A
	LD HL,_lblshift
	LD A,[_lblhash]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [lbltype.plbl_idx],HL
lbltype.A.
	LD HL,[lbltype.plbl_idx]
	LD DE,_LBLBUFEOF
	OR A
	SBC HL,DE
	JP Z,lbltype.B.
	LD HL,_lbls
	LD DE,[lbltype.plbl_idx]
	ADD HL,DE
	LD [lbltype.plbl],HL
	LD HL,[lbltype.plbl]
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [lbltype.plbl_idx],HL
	LD HL,[lbltype.plbl]
	LD DE,2
	LD BC,1
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	ADD HL,DE
	LD [lbltype.plbl],HL
	LD HL,[_name]
	LD [strcp.A.],HL
	LD HL,[lbltype.plbl]
	LD [strcp.B.],HL
	CALL strcp
	OR A
	JP Z,lbltype.C.
	LD HL,[lbltype.plbl]
	LD DE,_lbls
	OR A
	SBC HL,DE
	LD [_typeaddr],HL
	LD HL,[lbltype.plbl]
	LD DE,[_lenname]
	LD BC,1
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	ADD HL,DE
	LD [lbltype.plbl],HL
	LD HL,[lbltype.plbl]
	LD A,[HL]
	LD [lbltype.t],A
	LD HL,[lbltype.plbl]
	LD DE,1
	ADD HL,DE
	LD [lbltype.plbl],HL
	LD HL,[lbltype.plbl]
	LD A,[HL]
	LD [_isloc],A
	LD HL,[lbltype.plbl]
	INC HL
	LD [lbltype.plbl],HL
	LD A,[lbltype.t]
	LD E,_T_TYPE
	AND E
	SUB 0x00
	JP NZ,lbltype.E.
	LD HL,[lbltype.plbl]
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [_typeaddr],HL
lbltype.E.
	LD HL,[lbltype.plbl]
	LD DE,2
	ADD HL,DE
	LD [lbltype.plbl],HL
	LD HL,[lbltype.plbl]
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [_varsz],HL
	JP lbltype.B.
lbltype.C.
	JP lbltype.A.
lbltype.B.
	LD A,[lbltype.t]
	RET
dellbl
	EXPORT dellbl
	EXPORT dellbl.plbl
	LD HL,[_name]
	LD [hash.A.],HL
	CALL hash
	LD A,L
	LD [_lblhash],A
	LD HL,_lblshift
	LD A,[_lblhash]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [dellbl.plbl_idx],HL
dellbl.A.
	LD HL,[dellbl.plbl_idx]
	LD DE,_LBLBUFEOF
	OR A
	SBC HL,DE
	JP Z,dellbl.B.
	LD HL,_lbls
	LD DE,[dellbl.plbl_idx]
	ADD HL,DE
	LD [dellbl.plbl],HL
	LD HL,[dellbl.plbl]
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [dellbl.plbl_idx],HL
	LD HL,[dellbl.plbl]
	LD DE,2
	LD BC,1
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	ADD HL,DE
	LD [dellbl.plbl],HL
	LD HL,[_name]
	LD [strcp.A.],HL
	LD HL,[dellbl.plbl]
	LD [strcp.B.],HL
	CALL strcp
	OR A
	JP Z,dellbl.C.
	LD HL,[dellbl.plbl]
	LD A,'\0'
	LD [HL],A
	JP dellbl.B.
dellbl.C.
	JP dellbl.A.
dellbl.B.
	RET
addlbl
	EXPORT addlbl
	EXPORT addlbl.A.
	EXPORT addlbl.B.
	EXPORT addlbl.C.
	EXPORT addlbl.plbl
	CALL lbltype
	LD [addlbl.oldt],A
	LD A,[addlbl.oldt]
	SUB _T_UNKNOWN
	SUB 1
	SBC A,A
	LD L,A
	LD A,[addlbl.isloc]
	OR L
	JP Z,addlbl.D.
	LD HL,[_lblbuffreeidx]
	LD [addlbl.freeidx],HL
	LD HL,[addlbl.freeidx]
	LD DE,_LBLBUFMAXSHIFT
	LD A,L
	SUB E
	LD A,H
	SBC A,D
	JP NC,addlbl.F.
	LD HL,_lbls
	LD DE,[addlbl.freeidx]
	ADD HL,DE
	LD [addlbl.plbl],HL
	LD HL,[addlbl.plbl]
	LD DE,_lblshift
	LD A,[_lblhash]
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
	LD HL,[addlbl.plbl]
	LD DE,2
	ADD HL,DE
	LD [addlbl.plbl],HL
	LD HL,[addlbl.plbl]
	LD DE,[_lenname]
	LD [HL],E
	LD HL,[addlbl.plbl]
	INC HL
	LD [addlbl.plbl],HL
	LD HL,[_name]
	LD [strcopy.A.],HL
	LD HL,[_lenname]
	LD [strcopy.B.],HL
	LD HL,[addlbl.plbl]
	LD [strcopy.C.],HL
	CALL strcopy
	LD HL,[addlbl.plbl]
	LD DE,[_lenname]
	LD BC,1
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	ADD HL,DE
	LD [addlbl.plbl],HL
	LD HL,[addlbl.plbl]
	LD A,[addlbl.t]
	LD [HL],A
	LD HL,[addlbl.plbl]
	LD DE,1
	ADD HL,DE
	LD [addlbl.plbl],HL
	LD HL,[addlbl.plbl]
	LD A,[addlbl.isloc]
	LD [HL],A
	LD HL,[addlbl.plbl]
	INC HL
	LD [addlbl.plbl],HL
	LD HL,[addlbl.plbl]
	LD DE,[_typeaddr]
	LD [HL],E
	INC HL
	LD [HL],D
	LD HL,[addlbl.plbl]
	LD DE,2
	ADD HL,DE
	LD [addlbl.plbl],HL
	LD HL,[addlbl.plbl]
	LD DE,_lbls
	OR A
	SBC HL,DE
	LD [_varszaddr],HL
	LD HL,[addlbl.plbl]
	LD DE,[addlbl.varsz]
	LD [HL],E
	INC HL
	LD [HL],D
	LD HL,[addlbl.plbl]
	LD DE,_lbls
	OR A
	SBC HL,DE
	LD DE,2
	ADD HL,DE
	LD [_lblbuffreeidx],HL
	LD HL,_lblshift
	LD A,[_lblhash]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD DE,[addlbl.freeidx]
	LD [HL],E
	INC HL
	LD [HL],D
	JP addlbl.G.
addlbl.F.
	LD HL,addlbl.H.
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
addlbl.G.
	JP addlbl.E.
addlbl.D.
	LD A,[addlbl.oldt]
	LD L,A
	LD A,[addlbl.t]
	SUB L
	JP Z,addlbl.I.
	LD HL,addlbl.K.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[_name]
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
addlbl.I.
addlbl.E.
	RET
keepvars
	EXPORT keepvars
	LD HL,_lblshift
	LD [memcopy.A.],HL
	LD HL,2
	LD DE,0x100
	CALL _MUL.
	LD [memcopy.B.],HL
	LD HL,_oldlblshift
	LD [memcopy.C.],HL
	CALL memcopy
	LD HL,[_lblbuffreeidx]
	LD [_oldlblbuffreeidx],HL
	RET
undovars
	EXPORT undovars
	LD HL,_oldlblshift
	LD [memcopy.A.],HL
	LD HL,2
	LD DE,0x100
	CALL _MUL.
	LD [memcopy.B.],HL
	LD HL,_lblshift
	LD [memcopy.C.],HL
	CALL memcopy
	LD HL,[_oldlblbuffreeidx]
	LD [_lblbuffreeidx],HL
	RET
var_alignwsz_label
	EXPORT var_alignwsz_label
	EXPORT var_alignwsz_label.A.
	LD HL,_typesz
	LD A,[var_alignwsz_label.t]
	LD C,_TYPEMASK
	AND C
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	SUB _SZ_BYTE
	JP Z,var_alignwsz_label.B.
	CALL var_alignwsz
var_alignwsz_label.B.
	LD HL,[_joined]
	LD [emitvarlabel.A.],HL
	CALL emitvarlabel
	RET
var_def
	EXPORT var_def
	EXPORT var_def.A.
	EXPORT var_def.B.
	EXPORT var_def.sz
	LD HL,_typesz
	LD A,[var_def.t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [var_def.sz],A
	LD A,[var_def.sz]
	SUB _SZ_BYTE
	JP NZ,var_def.C.
	CALL var_db
	LD HL,[var_def.s]
	LD [varstr.A.],HL
	CALL varstr
	CALL endvar
	JP var_def.D.
var_def.C.
	LD A,[var_def.sz]
	SUB _SZ_REG
	JP NZ,var_def.E.
	CALL var_dw
	LD HL,[var_def.s]
	LD [varstr.A.],HL
	CALL varstr
	CALL endvar
	JP var_def.F.
var_def.E.
	LD A,[var_def.sz]
	SUB _SZ_LONG
	JP NZ,var_def.G.
	CALL var_dl
	LD HL,[var_def.s]
	LD [varstr.A.],HL
	CALL varstr
	CALL endvar
	JP var_def.H.
var_def.G.
	LD HL,var_def.I.
	LD [errstr.A.],HL
	CALL errstr
	LD A,[var_def.t]
	LD L,A
	LD H,0
	LD [erruint.A.],HL
	CALL erruint
	CALL enderr
var_def.H.
var_def.F.
var_def.D.
	RET
pushconst
	LD HL,_typesz
	LD A,[_wast]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,pushconst.A.
	CALL getrfree
	CALL emitloadb
	JP pushconst.B.
pushconst.A.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,pushconst.C.
	CALL getrfree
	LD A,FALSE
	LD [emitloadrg.A.],A
	CALL emitloadrg
	JP pushconst.D.
pushconst.C.
	LD A,[_sz]
	SUB _SZ_LONG
	JP NZ,pushconst.E.
	CALL getrfree
	LD A,TRUE
	LD [emitloadrg.A.],A
	CALL emitloadrg
	CALL getrfree
	LD A,FALSE
	LD [emitloadrg.A.],A
	CALL emitloadrg
	JP pushconst.F.
pushconst.E.
	LD HL,pushconst.G.
	LD [errtype.A.],HL
	LD A,[_wast]
	LD [errtype.B.],A
	CALL errtype
pushconst.F.
pushconst.D.
pushconst.B.
	LD A,FALSE
	LD [_wasconst],A
	RET
cmdpushnum
	EXPORT cmdpushnum
	LD A,[_wasconst]
	OR A
	JP Z,cmdpushnum.A.
	CALL pushconst
cmdpushnum.A.
	LD HL,[_joined]
	LD [strcopy.A.],HL
	LD HL,[_lenjoined]
	LD [strcopy.B.],HL
	LD HL,[_const]
	LD [strcopy.C.],HL
	CALL strcopy
	LD [_lenconst],HL
	LD A,[_t]
	LD [_wast],A
	LD A,TRUE
	LD [_wasconst],A
	RET
cmdpushvar
	EXPORT cmdpushvar
	LD A,[_wasconst]
	OR A
	JP Z,cmdpushvar.A.
	CALL pushconst
cmdpushvar.A.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,cmdpushvar.C.
	CALL getrfree
	CALL emitgetb
	JP cmdpushvar.D.
cmdpushvar.C.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,cmdpushvar.E.
	CALL getrfree
	LD A,FALSE
	LD [emitgetrg.A.],A
	CALL emitgetrg
	JP cmdpushvar.F.
cmdpushvar.E.
	LD A,[_sz]
	SUB _SZ_LONG
	JP NZ,cmdpushvar.G.
	CALL getrfree
	LD A,TRUE
	LD [emitgetrg.A.],A
	CALL emitgetrg
	CALL getrfree
	LD A,FALSE
	LD [emitgetrg.A.],A
	CALL emitgetrg
	JP cmdpushvar.H.
cmdpushvar.G.
	LD HL,cmdpushvar.I.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdpushvar.H.
cmdpushvar.F.
cmdpushvar.D.
	RET
cmdpopvar
	EXPORT cmdpopvar
	LD A,[_wasconst]
	OR A
	JP Z,cmdpopvar.A.
	CALL pushconst
cmdpopvar.A.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,cmdpopvar.C.
	CALL getrnew
	CALL emitputb
	CALL freernew
	JP cmdpopvar.D.
cmdpopvar.C.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,cmdpopvar.E.
	CALL getrnew
	LD A,FALSE
	LD [emitputrg.A.],A
	CALL emitputrg
	CALL freernew
	JP cmdpopvar.F.
cmdpopvar.E.
	LD A,[_sz]
	SUB _SZ_LONG
	JP NZ,cmdpopvar.G.
	CALL getrnew
	LD A,FALSE
	LD [emitputrg.A.],A
	CALL emitputrg
	CALL freernew
	CALL getrnew
	LD A,TRUE
	LD [emitputrg.A.],A
	CALL emitputrg
	CALL freernew
	JP cmdpopvar.H.
cmdpopvar.G.
	LD HL,cmdpopvar.I.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdpopvar.H.
cmdpopvar.F.
cmdpopvar.D.
	RET
cmdcastto
	EXPORT cmdcastto
	EXPORT cmdcastto.A.
	EXPORT cmdcastto.tsz
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [cmdcastto.tsz],A
	LD HL,_typesz
	LD A,[cmdcastto.t2]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [cmdcastto.t2sz],A
	LD A,[cmdcastto.tsz]
	LD L,A
	LD A,[cmdcastto.t2sz]
	SUB L
	JP NZ,cmdcastto.B.
	JP cmdcastto.C.
cmdcastto.B.
	LD A,[_wasconst]
	OR A
	JP Z,cmdcastto.D.
	CALL pushconst
cmdcastto.D.
	LD A,[cmdcastto.tsz]
	SUB _SZ_BYTE
	JP NZ,cmdcastto.F.
	LD A,[cmdcastto.t2sz]
	SUB _SZ_REG
	JP NZ,cmdcastto.H.
	CALL getrnew
	CALL emitbtorg
	JP cmdcastto.I.
cmdcastto.H.
	CALL getrnew
	CALL emitbtorg
	CALL getrfree
	CALL emitloadrg0
	CALL swaptop
cmdcastto.I.
	JP cmdcastto.G.
cmdcastto.F.
	LD A,[cmdcastto.tsz]
	SUB _SZ_REG
	JP NZ,cmdcastto.J.
	LD A,[cmdcastto.t2sz]
	SUB _SZ_BYTE
	JP NZ,cmdcastto.L.
	CALL getrnew
	CALL emitrgtob
	JP cmdcastto.M.
cmdcastto.L.
	CALL getrfree
	CALL emitloadrg0
	CALL swaptop
cmdcastto.M.
	JP cmdcastto.K.
cmdcastto.J.
	LD A,[cmdcastto.tsz]
	SUB _SZ_LONG
	JP NZ,cmdcastto.N.
	LD A,[cmdcastto.t2sz]
	SUB _SZ_REG
	JP NZ,cmdcastto.P.
	CALL swaptop
	CALL freernew
	JP cmdcastto.Q.
cmdcastto.P.
	CALL swaptop
	CALL freernew
	CALL getrnew
	CALL emitrgtob
cmdcastto.Q.
cmdcastto.N.
cmdcastto.K.
cmdcastto.G.
cmdcastto.C.
	LD A,[cmdcastto.t2]
	LD [_t],A
	RET
cmdadd
	EXPORT cmdadd
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,cmdadd.A.
	LD A,[_wasconst]
	OR A
	JP Z,cmdadd.C.
	CALL getrnew
	CALL emitaddbconst
	LD A,FALSE
	LD [_wasconst],A
	JP cmdadd.D.
cmdadd.C.
	CALL getrnew
	CALL getrold
	CALL emitaddb
	CALL freernew
cmdadd.D.
	JP cmdadd.B.
cmdadd.A.
	LD A,[_wasconst]
	OR A
	JP Z,cmdadd.E.
	CALL pushconst
cmdadd.E.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	SUB _SZ_REG
	JP NZ,cmdadd.G.
	CALL getrold
	CALL getrnew
	CALL emitaddrg
	CALL freernew
	JP cmdadd.H.
cmdadd.G.
	LD A,[_t]
	SUB _T_LONG
	JP NZ,cmdadd.I.
	CALL getrold2
	CALL getrnew
	CALL emitaddrg
	CALL freernew
	CALL getrold2
	CALL getrnew
	CALL emitadcrg
	CALL freernew
	JP cmdadd.J.
cmdadd.I.
	LD HL,cmdadd.K.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdadd.J.
cmdadd.H.
cmdadd.B.
	RET
cmdsub
	EXPORT cmdsub
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,cmdsub.A.
	LD A,[_wasconst]
	OR A
	JP Z,cmdsub.C.
	CALL getrnew
	CALL emitsubbconst
	LD A,FALSE
	LD [_wasconst],A
	JP cmdsub.D.
cmdsub.C.
	CALL getrnew
	CALL getrold
	CALL emitsubb
	CALL freernew
cmdsub.D.
	JP cmdsub.B.
cmdsub.A.
	LD A,[_wasconst]
	OR A
	JP Z,cmdsub.E.
	CALL pushconst
cmdsub.E.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	SUB _SZ_REG
	JP NZ,cmdsub.G.
	CALL getrold
	CALL getrnew
	CALL emitsubrg
	CALL freernew
	JP cmdsub.H.
cmdsub.G.
	LD A,[_t]
	SUB _T_LONG
	JP NZ,cmdsub.I.
	CALL getrold2
	CALL getrnew
	CALL emitsubrg
	CALL freernew
	CALL getrold2
	CALL getrnew
	CALL emitsbcrg
	CALL freernew
	JP cmdsub.J.
cmdsub.I.
	LD HL,cmdsub.K.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdsub.J.
cmdsub.H.
cmdsub.B.
	RET
cmdaddpoi
	EXPORT cmdaddpoi
	EXPORT cmdaddpoi.i
	LD A,[_wasconst]
	OR A
	JP Z,cmdaddpoi.A.
	CALL pushconst
cmdaddpoi.A.
	CALL getrold
	CALL getrnew
	LD HL,_typesz
	LD A,[_t]
	LD C,_TYPEMASK
	AND C
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [cmdaddpoi.i],A
cmdaddpoi.C.
	LD A,[cmdaddpoi.i]
	SUB 0x00
	JP Z,cmdaddpoi.D.
	CALL emitaddrg
	LD HL,cmdaddpoi.i
	DEC [HL]
	JP cmdaddpoi.C.
cmdaddpoi.D.
	CALL freernew
	RET
cmdmul
	EXPORT cmdmul
	LD A,[_wasconst]
	OR A
	JP Z,cmdmul.A.
	CALL pushconst
cmdmul.A.
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,cmdmul.C.
	LD HL,cmdmul.E.
	LD [emitcall2rgs.A.],HL
	CALL emitcall2rgs
	JP cmdmul.D.
cmdmul.C.
	LD A,[_t]
	SUB _T_UINT
	JP NZ,cmdmul.F.
	LD HL,cmdmul.H.
	LD [emitcall2rgs.A.],HL
	CALL emitcall2rgs
	JP cmdmul.G.
cmdmul.F.
	LD A,[_t]
	SUB _T_INT
	JP NZ,cmdmul.I.
	LD HL,cmdmul.K.
	LD [emitcall2rgs.A.],HL
	CALL emitcall2rgs
	JP cmdmul.J.
cmdmul.I.
	LD A,[_t]
	SUB _T_LONG
	JP NZ,cmdmul.L.
	LD HL,cmdmul.N.
	LD [emitcall4rgs.A.],HL
	CALL emitcall4rgs
	JP cmdmul.M.
cmdmul.L.
	LD HL,cmdmul.O.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdmul.M.
cmdmul.J.
cmdmul.G.
cmdmul.D.
	RET
cmddiv
	EXPORT cmddiv
	LD A,[_wasconst]
	OR A
	JP Z,cmddiv.A.
	CALL pushconst
cmddiv.A.
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,cmddiv.C.
	LD HL,cmddiv.E.
	LD [emitcall2rgs.A.],HL
	CALL emitcall2rgs
	JP cmddiv.D.
cmddiv.C.
	LD A,[_t]
	SUB _T_UINT
	JP NZ,cmddiv.F.
	LD HL,cmddiv.H.
	LD [emitcall2rgs.A.],HL
	CALL emitcall2rgs
	JP cmddiv.G.
cmddiv.F.
	LD A,[_t]
	SUB _T_INT
	JP NZ,cmddiv.I.
	LD HL,cmddiv.K.
	LD [emitcall2rgs.A.],HL
	CALL emitcall2rgs
	JP cmddiv.J.
cmddiv.I.
	LD A,[_t]
	SUB _T_LONG
	JP NZ,cmddiv.L.
	LD HL,cmddiv.N.
	LD [emitcall4rgs.A.],HL
	CALL emitcall4rgs
	JP cmddiv.M.
cmddiv.L.
	LD HL,cmddiv.O.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmddiv.M.
cmddiv.J.
cmddiv.G.
cmddiv.D.
	RET
cmdshl
	EXPORT cmdshl
	LD A,[_wasconst]
	OR A
	JP Z,cmdshl.A.
	CALL pushconst
cmdshl.A.
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,cmdshl.C.
	LD HL,cmdshl.E.
	LD [emitcall2rgs.A.],HL
	CALL emitcall2rgs
	JP cmdshl.D.
cmdshl.C.
	LD A,[_t]
	SUB _T_INT
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_t]
	SUB _T_UINT
	SUB 1
	SBC A,A
	OR L
	JP Z,cmdshl.F.
	LD HL,cmdshl.H.
	LD [emitcall2rgs.A.],HL
	CALL emitcall2rgs
	JP cmdshl.G.
cmdshl.F.
	LD A,[_t]
	SUB _T_LONG
	JP NZ,cmdshl.I.
	LD HL,cmdshl.K.
	LD [emitcall4rgs.A.],HL
	CALL emitcall4rgs
	JP cmdshl.J.
cmdshl.I.
	LD HL,cmdshl.L.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdshl.J.
cmdshl.G.
cmdshl.D.
	RET
cmdshr
	EXPORT cmdshr
	LD A,[_wasconst]
	OR A
	JP Z,cmdshr.A.
	CALL pushconst
cmdshr.A.
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,cmdshr.C.
	LD HL,cmdshr.E.
	LD [emitcall2rgs.A.],HL
	CALL emitcall2rgs
	JP cmdshr.D.
cmdshr.C.
	LD A,[_t]
	SUB _T_UINT
	JP NZ,cmdshr.F.
	LD HL,cmdshr.H.
	LD [emitcall2rgs.A.],HL
	CALL emitcall2rgs
	JP cmdshr.G.
cmdshr.F.
	LD A,[_t]
	SUB _T_INT
	JP NZ,cmdshr.I.
	LD HL,cmdshr.K.
	LD [emitcall2rgs.A.],HL
	CALL emitcall2rgs
	JP cmdshr.J.
cmdshr.I.
	LD A,[_t]
	SUB _T_LONG
	JP NZ,cmdshr.L.
	LD HL,cmdshr.N.
	LD [emitcall4rgs.A.],HL
	CALL emitcall4rgs
	JP cmdshr.M.
cmdshr.L.
	LD HL,cmdshr.O.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdshr.M.
cmdshr.J.
cmdshr.G.
cmdshr.D.
	RET
cmdshl1
	EXPORT cmdshl1
	LD A,[_wasconst]
	OR A
	JP Z,cmdshl1.A.
	CALL pushconst
cmdshl1.A.
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,cmdshl1.C.
	CALL getrnew
	CALL emitshl1b
	JP cmdshl1.D.
cmdshl1.C.
	LD A,[_t]
	SUB _T_INT
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_t]
	SUB _T_UINT
	SUB 1
	SBC A,A
	OR L
	JP Z,cmdshl1.E.
	CALL getrnew
	CALL emitshl1rg
	JP cmdshl1.F.
cmdshl1.E.
	LD HL,cmdshl1.G.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdshl1.F.
cmdshl1.D.
	RET
cmdand
	EXPORT cmdand
	LD A,[_wasconst]
	OR A
	JP Z,cmdand.A.
	CALL pushconst
cmdand.A.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,cmdand.C.
	CALL getrnew
	CALL getrold
	CALL getandb
	CALL freernew
	JP cmdand.D.
cmdand.C.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,cmdand.E.
	CALL getrnew
	CALL getrold
	CALL emitandrg
	CALL freernew
	JP cmdand.F.
cmdand.E.
	CALL getrnew
	CALL getrold2
	CALL emitandrg
	CALL freernew
	CALL getrnew
	CALL getrold2
	CALL emitandrg
	CALL freernew
cmdand.F.
cmdand.D.
	RET
cmdor
	EXPORT cmdor
	LD A,[_wasconst]
	OR A
	JP Z,cmdor.A.
	CALL pushconst
cmdor.A.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,cmdor.C.
	CALL getrnew
	CALL getrold
	CALL getorb
	CALL freernew
	JP cmdor.D.
cmdor.C.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,cmdor.E.
	CALL getrnew
	CALL getrold
	CALL emitorrg
	CALL freernew
	JP cmdor.F.
cmdor.E.
	CALL getrnew
	CALL getrold2
	CALL emitorrg
	CALL freernew
	CALL getrnew
	CALL getrold2
	CALL emitorrg
	CALL freernew
cmdor.F.
cmdor.D.
	RET
cmdxor
	EXPORT cmdxor
	LD A,[_wasconst]
	OR A
	JP Z,cmdxor.A.
	CALL pushconst
cmdxor.A.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,cmdxor.C.
	CALL getrnew
	CALL getrold
	CALL getxorb
	CALL freernew
	JP cmdxor.D.
cmdxor.C.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,cmdxor.E.
	CALL getrnew
	CALL getrold
	CALL emitxorrg
	CALL freernew
	JP cmdxor.F.
cmdxor.E.
	CALL getrnew
	CALL getrold2
	CALL emitxorrg
	CALL freernew
	CALL getrnew
	CALL getrold2
	CALL emitxorrg
	CALL freernew
cmdxor.F.
cmdxor.D.
	RET
cmdpoke
	EXPORT cmdpoke
	LD A,[_wasconst]
	OR A
	JP Z,cmdpoke.A.
	CALL pushconst
cmdpoke.A.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,cmdpoke.C.
	CALL getrnew
	CALL getrold
	CALL emitpokeb
	CALL freernew
	CALL freernew
	JP cmdpoke.D.
cmdpoke.C.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,cmdpoke.E.
	CALL getrnew
	CALL getrold
	CALL emitpokerg
	CALL freernew
	CALL freernew
	JP cmdpoke.F.
cmdpoke.E.
	CALL getrnew
	CALL getrold2
	LD A,[_rold]
	LD [_rold2],A
	CALL getrold
	CALL emitpokelong
	CALL freernew
	CALL freernew
	CALL freernew
cmdpoke.F.
cmdpoke.D.
	RET
cmdpeek
	EXPORT cmdpeek
	LD A,[_wasconst]
	OR A
	JP Z,cmdpeek.A.
	CALL pushconst
cmdpeek.A.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,cmdpeek.C.
	CALL getrnew
	CALL emitpeekb
	JP cmdpeek.D.
cmdpeek.C.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,cmdpeek.E.
	CALL getrnew
	CALL emitpeekrg
	JP cmdpeek.F.
cmdpeek.E.
	CALL getrfree
	CALL getrnew
	CALL getrold
	CALL emitpeeklong
cmdpeek.F.
cmdpeek.D.
	RET
cmdneg
	EXPORT cmdneg
	LD A,[_wasconst]
	OR A
	JP Z,cmdneg.A.
	CALL pushconst
cmdneg.A.
	LD A,[_t]
	SUB _T_INT
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_t]
	SUB _T_UINT
	SUB 1
	SBC A,A
	OR L
	JP Z,cmdneg.C.
	CALL getrnew
	CALL emitnegrg
	JP cmdneg.D.
cmdneg.C.
	LD HL,cmdneg.E.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdneg.D.
	RET
cmdinv
	EXPORT cmdinv
	LD A,[_wasconst]
	OR A
	JP Z,cmdinv.A.
	CALL pushconst
cmdinv.A.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,cmdinv.C.
	CALL getrnew
	CALL emitinvb
	JP cmdinv.D.
cmdinv.C.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,cmdinv.E.
	CALL getrnew
	CALL emitinvrg
	JP cmdinv.F.
cmdinv.E.
	CALL getrnew
	CALL emitinvrg
	CALL getrold
	LD A,[_rold]
	LD [_rnew],A
	CALL emitinvrg
cmdinv.F.
cmdinv.D.
	RET
cmdinc
	EXPORT cmdinc
	LD A,[_wasconst]
	OR A
	JP Z,cmdinc.A.
	CALL pushconst
cmdinc.A.
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,cmdinc.C.
	CALL prefernoregs
	LD A,_T_POI
	LD E,_T_BYTE
	OR E
	LD [_t],A
	CALL cmdpushnum
	LD A,[_wasconst]
	OR A
	JP Z,cmdinc.E.
	CALL pushconst
cmdinc.E.
	CALL getrnew
	CALL emitincb_bypoi
	CALL freernew
	JP cmdinc.D.
cmdinc.C.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	SUB _SZ_REG
	JP NZ,cmdinc.G.
	CALL getrfree
	CALL emitincrg_byname
	CALL freernew
	JP cmdinc.H.
cmdinc.G.
	LD HL,cmdinc.I.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdinc.H.
cmdinc.D.
	RET
cmddec
	EXPORT cmddec
	LD A,[_wasconst]
	OR A
	JP Z,cmddec.A.
	CALL pushconst
cmddec.A.
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,cmddec.C.
	CALL prefernoregs
	LD A,_T_POI
	LD E,_T_BYTE
	OR E
	LD [_t],A
	CALL cmdpushnum
	LD A,[_wasconst]
	OR A
	JP Z,cmddec.E.
	CALL pushconst
cmddec.E.
	CALL getrnew
	CALL emitdecb_bypoi
	CALL freernew
	JP cmddec.D.
cmddec.C.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	SUB _SZ_REG
	JP NZ,cmddec.G.
	CALL getrfree
	CALL emitdecrg_byname
	CALL freernew
	JP cmddec.H.
cmddec.G.
	LD HL,cmddec.I.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmddec.H.
cmddec.D.
	RET
cmdincbyaddr
	EXPORT cmdincbyaddr
	LD A,[_wasconst]
	OR A
	JP Z,cmdincbyaddr.A.
	CALL pushconst
cmdincbyaddr.A.
	CALL getrnew
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,cmdincbyaddr.C.
	CALL emitincb_bypoi
	JP cmdincbyaddr.D.
cmdincbyaddr.C.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	SUB _SZ_REG
	JP NZ,cmdincbyaddr.E.
	CALL getrfree
	CALL getrold
	CALL emitincrg_bypoi
	CALL freernew
	JP cmdincbyaddr.F.
cmdincbyaddr.E.
	LD HL,cmdincbyaddr.G.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdincbyaddr.F.
cmdincbyaddr.D.
	CALL freernew
	RET
cmddecbyaddr
	EXPORT cmddecbyaddr
	LD A,[_wasconst]
	OR A
	JP Z,cmddecbyaddr.A.
	CALL pushconst
cmddecbyaddr.A.
	CALL getrnew
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,cmddecbyaddr.C.
	CALL emitdecb_bypoi
	JP cmddecbyaddr.D.
cmddecbyaddr.C.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	SUB _SZ_REG
	JP NZ,cmddecbyaddr.E.
	CALL getrfree
	CALL getrold
	CALL emitdecrg_bypoi
	CALL freernew
	JP cmddecbyaddr.F.
cmddecbyaddr.E.
	LD HL,cmddecbyaddr.G.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmddecbyaddr.F.
cmddecbyaddr.D.
	CALL freernew
	RET
cmdless
	EXPORT cmdless
	LD A,[_wasconst]
	OR A
	JP Z,cmdless.A.
	CALL pushconst
cmdless.A.
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,cmdless.C.
	CALL getrnew
	CALL getrold
	LD A,[_rnew]
	LD [emitsubbflags.A.],A
	LD A,[_rold]
	LD [emitsubbflags.B.],A
	CALL emitsubbflags
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitcytob
	JP cmdless.D.
cmdless.C.
	LD A,[_t]
	SUB _T_UINT
	JP NZ,cmdless.E.
	CALL getrnew
	CALL getrold
	LD A,[_rnew]
	LD [emitsubflags.A.],A
	LD A,[_rold]
	LD [emitsubflags.B.],A
	CALL emitsubflags
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitcytob
	JP cmdless.F.
cmdless.E.
	LD A,[_t]
	SUB _T_INT
	JP NZ,cmdless.G.
	CALL getrnew
	CALL getrold
	LD A,[_rnew]
	LD [emitsubflags.A.],A
	LD A,[_rold]
	LD [emitsubflags.B.],A
	CALL emitsubflags
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitSxorVtob
	JP cmdless.H.
cmdless.G.
	LD HL,cmdless.I.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdless.H.
cmdless.F.
cmdless.D.
	LD A,_T_BOOL
	LD [_t],A
	RET
cmdmore
	EXPORT cmdmore
	LD A,[_wasconst]
	OR A
	JP Z,cmdmore.A.
	CALL pushconst
cmdmore.A.
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,cmdmore.C.
	CALL getrold
	CALL getrnew
	LD A,[_rold]
	LD [emitsubbflags.A.],A
	LD A,[_rnew]
	LD [emitsubbflags.B.],A
	CALL emitsubbflags
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitcytob
	JP cmdmore.D.
cmdmore.C.
	LD A,[_t]
	SUB _T_UINT
	JP NZ,cmdmore.E.
	CALL getrold
	CALL getrnew
	LD A,[_rold]
	LD [emitsubflags.A.],A
	LD A,[_rnew]
	LD [emitsubflags.B.],A
	CALL emitsubflags
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitcytob
	JP cmdmore.F.
cmdmore.E.
	LD A,[_t]
	SUB _T_INT
	JP NZ,cmdmore.G.
	CALL getrold
	CALL getrnew
	LD A,[_rold]
	LD [emitsubflags.A.],A
	LD A,[_rnew]
	LD [emitsubflags.B.],A
	CALL emitsubflags
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitSxorVtob
	JP cmdmore.H.
cmdmore.G.
	LD HL,cmdmore.I.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdmore.H.
cmdmore.F.
cmdmore.D.
	LD A,_T_BOOL
	LD [_t],A
	RET
cmdlesseq
	EXPORT cmdlesseq
	LD A,[_wasconst]
	OR A
	JP Z,cmdlesseq.A.
	CALL pushconst
cmdlesseq.A.
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,cmdlesseq.C.
	CALL getrold
	CALL getrnew
	LD A,[_rold]
	LD [emitsubbflags.A.],A
	LD A,[_rnew]
	LD [emitsubbflags.B.],A
	CALL emitsubbflags
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitinvcytob
	JP cmdlesseq.D.
cmdlesseq.C.
	LD A,[_t]
	SUB _T_UINT
	JP NZ,cmdlesseq.E.
	CALL getrold
	CALL getrnew
	LD A,[_rold]
	LD [emitsubflags.A.],A
	LD A,[_rnew]
	LD [emitsubflags.B.],A
	CALL emitsubflags
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitinvcytob
	JP cmdlesseq.F.
cmdlesseq.E.
	LD A,[_t]
	SUB _T_INT
	JP NZ,cmdlesseq.G.
	CALL getrold
	CALL getrnew
	LD A,[_rold]
	LD [emitsubflags.A.],A
	LD A,[_rnew]
	LD [emitsubflags.B.],A
	CALL emitsubflags
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitinvSxorVtob
	JP cmdlesseq.H.
cmdlesseq.G.
	LD HL,cmdlesseq.I.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdlesseq.H.
cmdlesseq.F.
cmdlesseq.D.
	LD A,_T_BOOL
	LD [_t],A
	RET
cmdmoreeq
	EXPORT cmdmoreeq
	LD A,[_wasconst]
	OR A
	JP Z,cmdmoreeq.A.
	CALL pushconst
cmdmoreeq.A.
	LD A,[_t]
	SUB _T_BYTE
	JP NZ,cmdmoreeq.C.
	CALL getrnew
	CALL getrold
	LD A,[_rnew]
	LD [emitsubbflags.A.],A
	LD A,[_rold]
	LD [emitsubbflags.B.],A
	CALL emitsubbflags
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitinvcytob
	JP cmdmoreeq.D.
cmdmoreeq.C.
	LD A,[_t]
	SUB _T_UINT
	JP NZ,cmdmoreeq.E.
	CALL getrnew
	CALL getrold
	LD A,[_rnew]
	LD [emitsubflags.A.],A
	LD A,[_rold]
	LD [emitsubflags.B.],A
	CALL emitsubflags
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitinvcytob
	JP cmdmoreeq.F.
cmdmoreeq.E.
	LD A,[_t]
	SUB _T_INT
	JP NZ,cmdmoreeq.G.
	CALL getrnew
	CALL getrold
	LD A,[_rnew]
	LD [emitsubflags.A.],A
	LD A,[_rold]
	LD [emitsubflags.B.],A
	CALL emitsubflags
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitinvSxorVtob
	JP cmdmoreeq.H.
cmdmoreeq.G.
	LD HL,cmdmoreeq.I.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdmoreeq.H.
cmdmoreeq.F.
cmdmoreeq.D.
	LD A,_T_BOOL
	LD [_t],A
	RET
cmdeq
	EXPORT cmdeq
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,cmdeq.A.
	LD A,[_wasconst]
	OR A
	JP Z,cmdeq.C.
	CALL getrnew
	CALL emitsubbzconst
	LD A,FALSE
	LD [_wasconst],A
	CALL freernew
	JP cmdeq.D.
cmdeq.C.
	CALL getrnew
	CALL getrold
	CALL emitsubbz
	CALL freernew
	CALL freernew
cmdeq.D.
	CALL getrfree
	CALL emitztob
	JP cmdeq.B.
cmdeq.A.
	LD A,[_wasconst]
	OR A
	JP Z,cmdeq.E.
	CALL pushconst
cmdeq.E.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,cmdeq.G.
	CALL getrnew
	CALL getrold
	CALL emitsubz
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitztob
	JP cmdeq.H.
cmdeq.G.
	CALL getrold2
	LD A,[_rold]
	LD [_rold2],A
	CALL getrold3
	LD A,[_rold]
	LD [_rold3],A
	CALL getrnew
	CALL getrold
	CALL emitsublongz
	CALL freernew
	CALL freernew
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitztob
cmdeq.H.
cmdeq.B.
	LD A,_T_BOOL
	LD [_t],A
	RET
cmdnoteq
	EXPORT cmdnoteq
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,cmdnoteq.A.
	LD A,[_wasconst]
	OR A
	JP Z,cmdnoteq.C.
	CALL getrnew
	CALL emitsubbzconst
	LD A,FALSE
	LD [_wasconst],A
	CALL freernew
	JP cmdnoteq.D.
cmdnoteq.C.
	CALL getrnew
	CALL getrold
	CALL emitsubbz
	CALL freernew
	CALL freernew
cmdnoteq.D.
	CALL getrfree
	CALL emitinvztob
	JP cmdnoteq.B.
cmdnoteq.A.
	LD A,[_wasconst]
	OR A
	JP Z,cmdnoteq.E.
	CALL pushconst
cmdnoteq.E.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,cmdnoteq.G.
	CALL getrnew
	CALL getrold
	CALL emitsubz
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitinvztob
	JP cmdnoteq.H.
cmdnoteq.G.
	CALL getrold2
	LD A,[_rold]
	LD [_rold2],A
	CALL getrold3
	LD A,[_rold]
	LD [_rold3],A
	CALL getrnew
	CALL getrold
	CALL emitsublongz
	CALL freernew
	CALL freernew
	CALL freernew
	CALL freernew
	CALL getrfree
	CALL emitinvztob
cmdnoteq.H.
cmdnoteq.B.
	LD A,_T_BOOL
	LD [_t],A
	RET
cmdlabel
	EXPORT cmdlabel
	CALL getnothing
	LD HL,[_joined]
	LD [emitfunclabel.A.],HL
	CALL emitfunclabel
	RET
cmdjpval
	EXPORT cmdjpval
	CALL getmainrg
	CALL freernew
	CALL emitjpmainrg
	RET
cmdcallval
	EXPORT cmdcallval
	LD A,[_wasconst]
	OR A
	JP Z,cmdcallval.A.
	CALL pushconst
cmdcallval.A.
	CALL getmainrg
	CALL freernew
	CALL emitcallmainrg
	RET
cmdjp
	EXPORT cmdjp
	CALL emitjp
	RET
cmdjpiffalse
	EXPORT cmdjpiffalse
	LD A,[_wasconst]
	OR A
	JP Z,cmdjpiffalse.A.
	CALL pushconst
cmdjpiffalse.A.
	CALL getrnew
	CALL emitbtoz
	CALL freernew
	CALL emitjpiffalse
	RET
cmdcall
	EXPORT cmdcall
	CALL unproxy
	CALL getnothing
	CALL emitcallproc
	LD A,[_t]
	SUB _T_PROC
	JP Z,cmdcall.A.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,cmdcall.C.
	CALL setmainb
	JP cmdcall.D.
cmdcall.C.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,cmdcall.E.
	CALL setmainrg
	JP cmdcall.F.
cmdcall.E.
	LD A,[_sz]
	SUB _SZ_LONG
	JP NZ,cmdcall.G.
	CALL setmain2rgs
	JP cmdcall.H.
cmdcall.G.
	LD HL,cmdcall.I.
	LD [errtype.A.],HL
	LD A,[_t]
	LD [errtype.B.],A
	CALL errtype
cmdcall.H.
cmdcall.F.
cmdcall.D.
cmdcall.A.
	RET
cmdfunc
	EXPORT cmdfunc
	LD HL,0
	LD [_funcstkdepth],HL
	CALL emitfunchead
	RET
cmdstorergs
	EXPORT cmdstorergs
	CALL getnothing
	RET
cmdpushpar
	EXPORT cmdpushpar
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,cmdpushpar.A.
	CALL getnothing
	CALL getrfree
	CALL emitgetb
	JP cmdpushpar.B.
cmdpushpar.A.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,cmdpushpar.C.
	CALL getnothing
	CALL getrfree
	LD A,FALSE
	LD [emitgetrg.A.],A
	CALL emitgetrg
	JP cmdpushpar.D.
cmdpushpar.C.
	CALL getnothing
	CALL getrfree
	LD A,TRUE
	LD [emitgetrg.A.],A
	CALL emitgetrg
	CALL getnothing
	CALL getrfree
	LD A,FALSE
	LD [emitgetrg.A.],A
	CALL emitgetrg
cmdpushpar.D.
cmdpushpar.B.
	RET
cmdpoppar
	EXPORT cmdpoppar
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,cmdpoppar.A.
	CALL getrfree
	LD A,[_rnew]
	LD [emitpoprg.A.],A
	CALL emitpoprg
	CALL emitputb
	CALL freernew
	JP cmdpoppar.B.
cmdpoppar.A.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,cmdpoppar.C.
	CALL getrfree
	LD A,[_rnew]
	LD [emitpoprg.A.],A
	CALL emitpoprg
	LD A,FALSE
	LD [emitputrg.A.],A
	CALL emitputrg
	CALL freernew
	JP cmdpoppar.D.
cmdpoppar.C.
	CALL getrfree
	LD A,[_rnew]
	LD [emitpoprg.A.],A
	CALL emitpoprg
	LD A,FALSE
	LD [emitputrg.A.],A
	CALL emitputrg
	CALL freernew
	CALL getrfree
	LD A,[_rnew]
	LD [emitpoprg.A.],A
	CALL emitpoprg
	LD A,TRUE
	LD [emitputrg.A.],A
	CALL emitputrg
	CALL freernew
cmdpoppar.D.
cmdpoppar.B.
	RET
cmdresult
	EXPORT cmdresult
	LD A,[_wasconst]
	OR A
	JP Z,cmdresult.A.
	CALL pushconst
cmdresult.A.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,cmdresult.C.
	JP cmdresult.D.
cmdresult.C.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,cmdresult.E.
	CALL getmainrg
	JP cmdresult.F.
cmdresult.E.
	CALL getmain2rgs
cmdresult.F.
cmdresult.D.
	RET
cmdret
	EXPORT cmdret
	EXPORT cmdret.A.
	LD A,[cmdret.isfunc]
	OR A
	JP Z,cmdret.B.
	LD HL,_typesz
	LD A,[_t]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD [_sz],A
	LD A,[_sz]
	SUB _SZ_BYTE
	JP NZ,cmdret.D.
	CALL getrnew
	LD A,[_rnew]
	LD [proxy.A.],A
	CALL proxy
	JP cmdret.E.
cmdret.D.
	LD A,[_sz]
	SUB _SZ_REG
	JP NZ,cmdret.F.
	CALL getmainrg
	JP cmdret.G.
cmdret.F.
	CALL getmain2rgs
cmdret.G.
cmdret.E.
cmdret.B.
	CALL emitret
	LD HL,[_funcstkdepth]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,cmdret.H.
	LD HL,cmdret.J.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[_funcstkdepth]
	LD [erruint.A.],HL
	CALL erruint
	CALL enderr
cmdret.H.
	CALL initrgs
	RET
initcmd
	EXPORT initcmd
	LD HL,_sc
	LD [_const],HL
	LD A,FALSE
	LD [_wasconst],A
	RET
