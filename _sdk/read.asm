skiplines
skiplines.skipline
skiplines.A.
	LD A,[_cnext]
	SUB '#'
	JR Z,$+4
	LD A,-1
	LD L,A
	LD A,[_waseof]
	CPL
	AND L
	JP Z,skiplines.B.
	LD HL,[_curline]
	INC HL
	LD [_curline],HL
	LD HL,[_waseols]
	INC HL
	LD [_waseols],HL
skiplines.loop
	CALL readfin
	LD [_cnext],A
	LD A,[_cnext]
	SUB 0x0a
	JR Z,$+4
	LD A,-1
	LD L,A
	LD A,[_waseof]
	CPL
	AND L
	JP Z,skiplines.C.
	JP skiplines.loop
skiplines.C.
	CALL readfin
	LD [_cnext],A
	JP skiplines.A.
skiplines.B.
	RET
rdch
	LD HL,[_lentword]
	LD DE,_STRMAX
	LD A,L
	SUB E
	LD A,H
	SBC A,D
	JP NC,rdch.A.
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,[_cnext]
	LD [HL],A
	LD HL,[_lentword]
	INC HL
	LD [_lentword],HL
rdch.A.
rdch.loop
	CALL readfin
	LD [_cnext],A
	LD A,[_cnext]
	LD E,'!'
	SUB E
	JP NC,rdch.C.
	LD HL,[_spcsize]
	INC HL
	LD [_spcsize],HL
	LD A,[_cnext]
	SUB 0x0a
	JP NZ,rdch.E.
	LD HL,[_curline]
	INC HL
	LD [_curline],HL
	LD HL,0
	LD [_spcsize],HL
	LD HL,[_waseols]
	INC HL
	LD [_waseols],HL
	JP rdch.F.
rdch.E.
	LD A,[_cnext]
	SUB '\t'
	JP NZ,rdch.G.
	LD HL,[_spcsize]
	LD DE,7
	ADD HL,DE
	LD [_spcsize],HL
rdch.G.
rdch.F.
	LD A,[_waseof]
	CPL
	OR A
	JP Z,rdch.I.
	JP rdch.loop
rdch.I.
rdch.C.
	LD A,[_doskip]
	OR A
	JP Z,rdch.K.
	LD HL,[_waseols]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,rdch.M.
	CALL skiplines
rdch.M.
rdch.K.
	RET
rdchcmt
	LD HL,[_lentword]
	LD DE,_STRMAX
	LD A,L
	SUB E
	LD A,H
	SBC A,D
	JP NC,rdchcmt.A.
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,[_cnext]
	LD [HL],A
	LD HL,[_lentword]
	INC HL
	LD [_lentword],HL
rdchcmt.A.
rdchcmt.loop
	CALL readfin
	LD [_cnext],A
	LD A,[_cnext]
	SUB 0x0a
	JP NZ,rdchcmt.C.
	LD HL,[_curline]
	INC HL
	LD [_curline],HL
	LD HL,0
	LD [_spcsize],HL
	LD HL,[_waseols]
	INC HL
	LD [_waseols],HL
	LD A,[_waseof]
	CPL
	OR A
	JP Z,rdchcmt.E.
	JP rdchcmt.loop
rdchcmt.E.
	JP rdchcmt.D.
rdchcmt.C.
	LD A,[_cnext]
	SUB 0x0d
	JP NZ,rdchcmt.G.
	LD A,[_waseof]
	CPL
	OR A
	JP Z,rdchcmt.I.
	JP rdchcmt.loop
rdchcmt.I.
rdchcmt.G.
rdchcmt.D.
	LD A,[_doskip]
	OR A
	JP Z,rdchcmt.K.
	LD HL,[_waseols]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,rdchcmt.M.
	CALL skiplines
rdchcmt.M.
rdchcmt.K.
	RET
rdaddword
	LD A,[_doskip]
	OR A
	JP Z,rdaddword.A.
	LD HL,[_waseols]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,rdaddword.C.
	CALL skiplines
rdaddword.C.
rdaddword.A.
rdaddword.beg
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
	JP Z,rdaddword.E.
rdaddword.loop1
	LD HL,[_lentword]
	LD DE,_STRMAX
	LD A,L
	SUB E
	LD A,H
	SBC A,D
	JP NC,rdaddword.G.
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,[_cnext]
	LD [HL],A
	LD HL,[_lentword]
	INC HL
	LD [_lentword],HL
rdaddword.G.
	CALL readfin
	LD [_cnext],A
	LD HL,_isalphanum
	LD A,[_cnext]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	OR A
	JP Z,rdaddword.I.
	JP rdaddword.loop1
rdaddword.I.
	JP rdaddword.loopgo
rdaddword.loop2
	CALL readfin
	LD [_cnext],A
rdaddword.loopgo
	LD A,[_cnext]
	LD E,'!'
	SUB E
	JP NC,rdaddword.K.
	LD HL,[_spcsize]
	INC HL
	LD [_spcsize],HL
	LD A,[_cnext]
	SUB 0x0a
	JP NZ,rdaddword.M.
	LD HL,[_curline]
	INC HL
	LD [_curline],HL
	LD HL,0
	LD [_spcsize],HL
	LD HL,[_waseols]
	INC HL
	LD [_waseols],HL
rdaddword.M.
	LD A,[_waseof]
	CPL
	OR A
	JP Z,rdaddword.O.
	JP rdaddword.loop2
rdaddword.O.
rdaddword.K.
	JP rdaddword.F.
rdaddword.E.
	CALL rdch
rdaddword.F.
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,0x00
	LD [HL],A
	LD HL,[_lentword]
	LD DE,1
	OR A
	SBC HL,DE
	JP NZ,rdaddword.Q.
	LD HL,[_tword]
	LD A,[HL]
	LD [_c],A
	LD A,[_c]
	LD E,'<'
	SUB E
	JP NC,rdaddword.S.
	LD A,[_c]
	SUB '/'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_cnext]
	SUB '*'
	SUB 1
	SBC A,A
	AND L
	LD L,A
	LD A,[_c]
	SUB '*'
	SUB 1
	SBC A,A
	LD E,A
	LD A,[_cnext]
	SUB '/'
	SUB 1
	SBC A,A
	AND E
	OR L
	JP Z,rdaddword.U.
	CALL rdch
	LD A,[_cnext]
	SUB '*'
	JP NZ,rdaddword.W.
	CALL rdchcmt
rdaddword.Y.
	LD A,[_cnext]
	SUB '/'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c]
	SUB '*'
	SUB 1
	SBC A,A
	AND L
	LD L,A
	LD A,[_waseof]
	OR L
	CPL
	OR A
	JP Z,rdaddword.Z.
	LD A,[_cnext]
	LD [_c],A
	CALL rdchcmt
	JP rdaddword.Y.
rdaddword.Z.
	CALL rdch
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,0x00
	LD [HL],A
rdaddword.W.
	LD HL,0
	LD [_lentword],HL
	JP rdaddword.beg
	JP rdaddword.V.
rdaddword.U.
	LD A,[_c]
	SUB '/'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_cnext]
	SUB '/'
	SUB 1
	SBC A,A
	AND L
	LD L,A
	LD A,[_c]
	SUB ';'
	SUB 1
	SBC A,A
	LD E,A
	LD A,[_cnext]
	SUB ';'
	SUB 1
	SBC A,A
	AND E
	OR L
	JP Z,rdaddword.BA.
	LD HL,0
	LD [_waseols],HL
	CALL rdchcmt
rdaddword.BC.
	LD HL,[_waseols]
	LD DE,0
	OR A
	SBC HL,DE
	JP NZ,rdaddword.BD.
	CALL rdchcmt
	JP rdaddword.BC.
rdaddword.BD.
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,0x00
	LD [HL],A
	LD A,[_cnext]
	LD E,'!'
	SUB E
	JP NC,rdaddword.BE.
	CALL rdch
rdaddword.BE.
	LD HL,0
	LD [_lentword],HL
	JP rdaddword.beg
rdaddword.BA.
rdaddword.V.
rdaddword.S.
rdaddword.Q.
	RET
rdword
	LD HL,0
	LD [_lentword],HL
	CALL rdaddword
	RET
rdquotes
rdquotes.B.
	LD HL,[_spcsize]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,rdquotes.C.
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
	JP rdquotes.B.
rdquotes.C.
rdquotes.D.
	LD A,[_cnext]
	LD L,A
	LD A,[rdquotes.eol]
	SUB L
	JR Z,$+4
	LD A,-1
	LD L,A
	LD A,[_waseof]
	CPL
	AND L
	JP Z,rdquotes.E.
	LD A,[_cnext]
	SUB '\\'
	JP NZ,rdquotes.F.
	LD HL,[_tword]
	LD [stradd.A.],HL
	LD HL,[_lentword]
	LD [stradd.B.],HL
	LD A,[_cnext]
	LD [stradd.C.],A
	CALL stradd
	LD [_lentword],HL
	CALL readfin
	LD [_cnext],A
rdquotes.F.
	LD HL,[_tword]
	LD [stradd.A.],HL
	LD HL,[_lentword]
	LD [stradd.B.],HL
	LD A,[_cnext]
	LD [stradd.C.],A
	CALL stradd
	LD [_lentword],HL
	CALL readfin
	LD [_cnext],A
	JP rdquotes.D.
rdquotes.E.
	LD HL,[_tword]
	LD DE,[_lentword]
	ADD HL,DE
	LD A,0x00
	LD [HL],A
	RET
initrd
	LD A,FALSE
	LD [_doskip],A
	LD HL,_s0
	LD [_tword],HL
	LD HL,0
	LD [_waseols],HL
	LD HL,0
	LD [_spcsize],HL
	LD HL,0
	LD [_lentword],HL
	CALL rdch
	RET
