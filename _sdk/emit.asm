	EXPORT _cmts
	EXPORT _curlnbeg
	EXPORT _ferr
	EXPORT _fvar
	EXPORT _hints
	EXPORT _errs
	EXPORT _m_fn
	EXPORT _fn
	EXPORT _lenfn
	EXPORT _wasdig
	EXPORT _nbuf
	EXPORT _lennbuf
emitdig
	EXPORT emitdig
	EXPORT emitdig.A.
	EXPORT emitdig.dig
	LD A,'0'
	LD [emitdig.dig],A
emitdig.B.
	LD HL,[_num]
	LD DE,[emitdig.d]
	LD A,L
	SUB E
	LD A,H
	SBC A,D
	JP C,emitdig.C.
	LD HL,[_num]
	LD DE,[emitdig.d]
	OR A
	SBC HL,DE
	LD [_num],HL
	LD HL,emitdig.dig
	INC [HL]
	LD A,TRUE
	LD [_wasdig],A
	JP emitdig.B.
emitdig.C.
	LD A,[_wasdig]
	OR A
	JP Z,emitdig.D.
	LD HL,_nbuf
	LD DE,[_lennbuf]
	ADD HL,DE
	LD A,[emitdig.dig]
	LD [HL],A
	LD HL,[_lennbuf]
	INC HL
	LD [_lennbuf],HL
emitdig.D.
	RET
emitn
	EXPORT emitn
	EXPORT emitn.A.
	LD HL,[emitn.i]
	LD [_num],HL
	LD HL,0
	LD [_lennbuf],HL
	LD A,TRUE
	LD [_wasdig],A
	LD HL,[emitn.i]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,emitn.B.
	LD A,FALSE
	LD [_wasdig],A
	LD HL,10000
	LD [emitdig.A.],HL
	CALL emitdig
	LD HL,1000
	LD [emitdig.A.],HL
	CALL emitdig
	LD HL,100
	LD [emitdig.A.],HL
	CALL emitdig
	LD HL,10
	LD [emitdig.A.],HL
	CALL emitdig
emitn.B.
	LD HL,1
	LD [emitdig.A.],HL
	CALL emitdig
	LD HL,_nbuf
	LD DE,[_lennbuf]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	RET
emituint
	EXPORT emituint
	EXPORT emituint.A.
	EXPORT emituint.B.
	LD HL,[emituint.i]
	LD [emitn.A.],HL
	CALL emitn
	LD HL,_nbuf
	LD [fputs.A.],HL
	LD HL,[emituint.f]
	LD [fputs.B.],HL
	CALL fputs
	RET
asmc
	EXPORT asmc
	EXPORT asmc.A.
	LD A,[asmc.c]
	LD [writefout.A.],A
	CALL writefout
	RET
asmstr
	EXPORT asmstr
	EXPORT asmstr.A.
	LD HL,[asmstr.s]
	LD [fputs.A.],HL
	LD HL,[_fout]
	LD [fputs.B.],HL
	CALL fputs
	RET
asmuint
	EXPORT asmuint
	EXPORT asmuint.A.
	LD HL,[asmuint.i]
	LD [emituint.A.],HL
	LD HL,[_fout]
	LD [emituint.B.],HL
	CALL emituint
	RET
endasm
	EXPORT endasm
	LD A,'\n'
	LD [writefout.A.],A
	CALL writefout
	RET
err
	EXPORT err
	EXPORT err.A.
	LD A,[_errs]
	OR A
	JP Z,err.B.
	LD HL,[_ferr]
	LD [writebyte.A.],HL
	LD A,[err.c]
	LD [writebyte.B.],A
	CALL writebyte
err.B.
	RET
errstr
	EXPORT errstr
	EXPORT errstr.A.
	LD A,[_errs]
	OR A
	JP Z,errstr.B.
	LD HL,[errstr.s]
	LD [fputs.A.],HL
	LD HL,[_ferr]
	LD [fputs.B.],HL
	CALL fputs
errstr.B.
	RET
erruint
	EXPORT erruint
	EXPORT erruint.A.
	LD A,[_errs]
	OR A
	JP Z,erruint.B.
	LD HL,[erruint.i]
	LD [emituint.A.],HL
	LD HL,[_ferr]
	LD [emituint.B.],HL
	CALL emituint
erruint.B.
	RET
enderr
	EXPORT enderr
	LD A,[_errs]
	OR A
	JP Z,enderr.A.
	LD HL,[_ferr]
	LD [writebyte.A.],HL
	LD A,';'
	LD [writebyte.B.],A
	CALL writebyte
	LD HL,[_fn]
	LD [fputs.A.],HL
	LD HL,[_ferr]
	LD [fputs.B.],HL
	CALL fputs
	LD HL,enderr.C.
	LD [fputs.A.],HL
	LD HL,[_ferr]
	LD [fputs.B.],HL
	CALL fputs
	LD HL,[_curlnbeg]
	LD [emituint.A.],HL
	LD HL,[_ferr]
	LD [emituint.B.],HL
	CALL emituint
	LD HL,[_ferr]
	LD [writebyte.A.],HL
	LD A,'\n'
	LD [writebyte.B.],A
	CALL writebyte
enderr.A.
	RET
varc
	EXPORT varc
	EXPORT varc.A.
	LD HL,[_fvar]
	LD [writebyte.A.],HL
	LD A,[varc.c]
	LD [writebyte.B.],A
	CALL writebyte
	RET
varstr
	EXPORT varstr
	EXPORT varstr.A.
	LD HL,[varstr.s]
	LD [fputs.A.],HL
	LD HL,[_fvar]
	LD [fputs.B.],HL
	CALL fputs
	RET
varuint
	EXPORT varuint
	EXPORT varuint.A.
	LD HL,[varuint.i]
	LD [emituint.A.],HL
	LD HL,[_fvar]
	LD [emituint.B.],HL
	CALL emituint
	RET
endvar
	EXPORT endvar
	LD HL,[_fvar]
	LD [writebyte.A.],HL
	LD A,'\n'
	LD [writebyte.B.],A
	CALL writebyte
	RET
