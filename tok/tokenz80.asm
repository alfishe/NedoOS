matchnzzncc
	LD HL,[_lentword]
	LD DE,2
	OR A
	SBC HL,DE
	LD L,0
	JR NZ,$+0x3
	DEC L
	LD A,[_c1small]
	SUB 'n'
	SUB 1
	SBC A,A
	AND L
	LD L,A
	LD A,[_c2small]
	SUB 'z'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchnzzncc.A.
	LD A,_ASMNZ
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchnzzncc.ok],A
	JP matchnzzncc.B.
matchnzzncc.A.
	LD HL,[_lentword]
	LD DE,1
	OR A
	SBC HL,DE
	LD L,0
	JR NZ,$+0x3
	DEC L
	LD A,[_c1small]
	SUB 'z'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchnzzncc.C.
	LD A,_ASMZ
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchnzzncc.ok],A
	JP matchnzzncc.D.
matchnzzncc.C.
	LD HL,[_lentword]
	LD DE,2
	OR A
	SBC HL,DE
	LD L,0
	JR NZ,$+0x3
	DEC L
	LD A,[_c1small]
	SUB 'n'
	SUB 1
	SBC A,A
	AND L
	LD L,A
	LD A,[_c2small]
	SUB 'c'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchnzzncc.E.
	LD A,_ASMNC
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchnzzncc.ok],A
	JP matchnzzncc.F.
matchnzzncc.E.
	LD HL,[_lentword]
	LD DE,1
	OR A
	SBC HL,DE
	LD L,0
	JR NZ,$+0x3
	DEC L
	LD A,[_c1small]
	SUB 'c'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchnzzncc.G.
	LD A,_ASMC
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchnzzncc.ok],A
	JP matchnzzncc.H.
matchnzzncc.G.
	LD A,FALSE
	LD [matchnzzncc.ok],A
matchnzzncc.H.
matchnzzncc.F.
matchnzzncc.D.
matchnzzncc.B.
	LD A,[matchnzzncc.ok]
	RET
matchcc
	LD HL,[_lentword]
	LD DE,1
	OR A
	SBC HL,DE
	JP NZ,matchcc.A.
	LD A,[_c1small]
	SUB 'z'
	JP NZ,matchcc.C.
	LD A,_ASMZ
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchcc.ok],A
	JP matchcc.D.
matchcc.C.
	LD A,[_c1small]
	SUB 'c'
	JP NZ,matchcc.E.
	LD A,_ASMC
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchcc.ok],A
	JP matchcc.F.
matchcc.E.
	LD A,[_c1small]
	SUB 'p'
	JP NZ,matchcc.G.
	LD A,_ASMP
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchcc.ok],A
	JP matchcc.H.
matchcc.G.
	LD A,[_c1small]
	SUB 'm'
	JP NZ,matchcc.I.
	LD A,_ASMM
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchcc.ok],A
	JP matchcc.J.
matchcc.I.
	LD A,FALSE
	LD [matchcc.ok],A
matchcc.J.
matchcc.H.
matchcc.F.
matchcc.D.
	JP matchcc.B.
matchcc.A.
	LD HL,[_lentword]
	LD DE,2
	OR A
	SBC HL,DE
	JP NZ,matchcc.K.
	LD A,[_c1small]
	SUB 'n'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'z'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchcc.M.
	LD A,_ASMNZ
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchcc.ok],A
	JP matchcc.N.
matchcc.M.
	LD A,[_c1small]
	SUB 'n'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'c'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchcc.O.
	LD A,_ASMNC
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchcc.ok],A
	JP matchcc.P.
matchcc.O.
	LD A,[_c1small]
	SUB 'p'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'o'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchcc.Q.
	LD A,_ASMPO
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchcc.ok],A
	JP matchcc.R.
matchcc.Q.
	LD A,[_c1small]
	SUB 'p'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'e'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchcc.S.
	LD A,_ASMPE
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchcc.ok],A
	JP matchcc.T.
matchcc.S.
	LD A,FALSE
	LD [matchcc.ok],A
matchcc.T.
matchcc.R.
matchcc.P.
matchcc.N.
	JP matchcc.L.
matchcc.K.
	LD A,FALSE
	LD [matchcc.ok],A
matchcc.L.
matchcc.B.
	LD A,[matchcc.ok]
	RET
matcha
	LD A,[_c1small]
	SUB 'a'
	SUB 1
	SBC A,A
	LD DE,[_lentword]
	LD BC,1
	LD L,A
	LD A,E
	SUB C
	JR NZ,$+0x4
	LD A,D
	SUB B
	SUB 1
	SBC A,A
	AND L
	JP Z,matcha.A.
	LD A,_RG_A
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matcha.ok],A
	JP matcha.B.
matcha.A.
	LD A,FALSE
	LD [matcha.ok],A
matcha.B.
	LD A,[matcha.ok]
	RET
matchc
	LD A,[_c1small]
	SUB 'c'
	SUB 1
	SBC A,A
	LD DE,[_lentword]
	LD BC,1
	LD L,A
	LD A,E
	SUB C
	JR NZ,$+0x4
	LD A,D
	SUB B
	SUB 1
	SBC A,A
	AND L
	JP Z,matchc.A.
	LD A,_RG_C
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchc.ok],A
	JP matchc.B.
matchc.A.
	LD A,FALSE
	LD [matchc.ok],A
matchc.B.
	LD A,[matchc.ok]
	RET
matchde
	LD A,[_c1small]
	SUB 'd'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'e'
	SUB 1
	SBC A,A
	AND L
	LD DE,[_lentword]
	LD BC,2
	LD L,A
	LD A,E
	SUB C
	JR NZ,$+0x4
	LD A,D
	SUB B
	SUB 1
	SBC A,A
	AND L
	JP Z,matchde.A.
	LD A,_RG_DE
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchde.ok],A
	JP matchde.B.
matchde.A.
	LD A,FALSE
	LD [matchde.ok],A
matchde.B.
	LD A,[matchde.ok]
	RET
matchhl
	LD A,[_c1small]
	SUB 'h'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'l'
	SUB 1
	SBC A,A
	AND L
	LD DE,[_lentword]
	LD BC,2
	LD L,A
	LD A,E
	SUB C
	JR NZ,$+0x4
	LD A,D
	SUB B
	SUB 1
	SBC A,A
	AND L
	JP Z,matchhl.A.
	LD A,_RG_HL
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchhl.ok],A
	JP matchhl.B.
matchhl.A.
	LD A,FALSE
	LD [matchhl.ok],A
matchhl.B.
	LD A,[matchhl.ok]
	RET
matchsp
	LD A,[_c1small]
	SUB 's'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'p'
	SUB 1
	SBC A,A
	AND L
	LD DE,[_lentword]
	LD BC,2
	LD L,A
	LD A,E
	SUB C
	JR NZ,$+0x4
	LD A,D
	SUB B
	SUB 1
	SBC A,A
	AND L
	JP Z,matchsp.A.
	LD A,_RG_SP
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchsp.ok],A
	JP matchsp.B.
matchsp.A.
	LD A,FALSE
	LD [matchsp.ok],A
matchsp.B.
	LD A,[matchsp.ok]
	RET
matchaf
	LD A,[_c1small]
	SUB 'a'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'f'
	SUB 1
	SBC A,A
	AND L
	LD DE,[_lentword]
	LD BC,2
	LD L,A
	LD A,E
	SUB C
	JR NZ,$+0x4
	LD A,D
	SUB B
	SUB 1
	SBC A,A
	AND L
	JP Z,matchaf.A.
	LD A,_RG_AF
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchaf.ok],A
	JP matchaf.B.
matchaf.A.
	LD A,FALSE
	LD [matchaf.ok],A
matchaf.B.
	LD A,[matchaf.ok]
	RET
matchixiy
	LD HL,[_lentword]
	LD DE,2
	OR A
	SBC HL,DE
	JP NZ,matchixiy.A.
	LD A,[_c1small]
	SUB 'i'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'x'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchixiy.C.
	LD A,_RG_IX
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchixiy.ok],A
	JP matchixiy.D.
matchixiy.C.
	LD A,[_c1small]
	SUB 'i'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'y'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchixiy.E.
	LD A,_RG_IY
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchixiy.ok],A
	JP matchixiy.F.
matchixiy.E.
	LD A,FALSE
	LD [matchixiy.ok],A
matchixiy.F.
matchixiy.D.
	JP matchixiy.B.
matchixiy.A.
	LD A,FALSE
	LD [matchixiy.ok],A
matchixiy.B.
	LD A,[matchixiy.ok]
	RET
matchhlixiy
	LD HL,[_lentword]
	LD DE,2
	OR A
	SBC HL,DE
	JP NZ,matchhlixiy.A.
	LD A,[_c1small]
	SUB 'h'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'l'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchhlixiy.C.
	LD A,_RG_HL
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchhlixiy.ok],A
	JP matchhlixiy.D.
matchhlixiy.C.
	LD A,[_c1small]
	SUB 'i'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'x'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchhlixiy.E.
	LD A,_RG_IX
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchhlixiy.ok],A
	JP matchhlixiy.F.
matchhlixiy.E.
	LD A,[_c1small]
	SUB 'i'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'y'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchhlixiy.G.
	LD A,_RG_IY
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchhlixiy.ok],A
	JP matchhlixiy.H.
matchhlixiy.G.
	LD A,FALSE
	LD [matchhlixiy.ok],A
matchhlixiy.H.
matchhlixiy.F.
matchhlixiy.D.
	JP matchhlixiy.B.
matchhlixiy.A.
	LD A,FALSE
	LD [matchhlixiy.ok],A
matchhlixiy.B.
	LD A,[matchhlixiy.ok]
	RET
matchir
	LD HL,[_lentword]
	LD DE,1
	OR A
	SBC HL,DE
	JP NZ,matchir.A.
	LD A,[_c1small]
	SUB 'i'
	JP NZ,matchir.C.
	LD A,_RG_I
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchir.ok],A
	JP matchir.D.
matchir.C.
	LD A,[_c1small]
	SUB 'r'
	JP NZ,matchir.E.
	LD A,_RG_R
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchir.ok],A
	JP matchir.F.
matchir.E.
	LD A,FALSE
	LD [matchir.ok],A
matchir.F.
matchir.D.
	JP matchir.B.
matchir.A.
	LD A,FALSE
	LD [matchir.ok],A
matchir.B.
	LD A,[matchir.ok]
	RET
matchrp
	LD HL,[_lentword]
	LD DE,2
	OR A
	SBC HL,DE
	JP NZ,matchrp.A.
	LD A,[_c1small]
	SUB 'b'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'c'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchrp.C.
	LD A,_RG_BC
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrp.ok],A
	JP matchrp.D.
matchrp.C.
	LD A,[_c1small]
	SUB 'd'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'e'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchrp.E.
	LD A,_RG_DE
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrp.ok],A
	JP matchrp.F.
matchrp.E.
	LD A,[_c1small]
	SUB 'h'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'l'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchrp.G.
	LD A,_RG_HL
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrp.ok],A
	JP matchrp.H.
matchrp.G.
	LD A,[_c1small]
	SUB 's'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'p'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchrp.I.
	LD A,_RG_SP
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrp.ok],A
	JP matchrp.J.
matchrp.I.
	LD A,[_c1small]
	SUB 'i'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'x'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchrp.K.
	LD A,_RG_IX
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrp.ok],A
	JP matchrp.L.
matchrp.K.
	LD A,[_c1small]
	SUB 'i'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'y'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchrp.M.
	LD A,_RG_IY
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrp.ok],A
	JP matchrp.N.
matchrp.M.
	LD A,[_c1small]
	SUB 'r'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'p'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchrp.O.
	CALL asmrdword_tokspc
	LD A,_RG_RPBYNAME
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL toktext
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrp.ok],A
	JP matchrp.P.
matchrp.O.
	LD A,FALSE
	LD [matchrp.ok],A
matchrp.P.
matchrp.N.
matchrp.L.
matchrp.J.
matchrp.H.
matchrp.F.
matchrp.D.
	JP matchrp.B.
matchrp.A.
	LD A,FALSE
	LD [matchrp.ok],A
matchrp.B.
	LD A,[matchrp.ok]
	RET
matchrb
	LD HL,[_lentword]
	LD DE,1
	OR A
	SBC HL,DE
	JP NZ,matchrb.A.
	LD A,[_c1small]
	SUB 'b'
	JP NZ,matchrb.C.
	LD A,_RG_B
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrb.ok],A
	JP matchrb.D.
matchrb.C.
	LD A,[_c1small]
	SUB 'c'
	JP NZ,matchrb.E.
	LD A,_RG_C
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrb.ok],A
	JP matchrb.F.
matchrb.E.
	LD A,[_c1small]
	SUB 'd'
	JP NZ,matchrb.G.
	LD A,_RG_D
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrb.ok],A
	JP matchrb.H.
matchrb.G.
	LD A,[_c1small]
	SUB 'e'
	JP NZ,matchrb.I.
	LD A,_RG_E
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrb.ok],A
	JP matchrb.J.
matchrb.I.
	LD A,[_c1small]
	SUB 'h'
	JP NZ,matchrb.K.
	LD A,_RG_H
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrb.ok],A
	JP matchrb.L.
matchrb.K.
	LD A,[_c1small]
	SUB 'l'
	JP NZ,matchrb.M.
	LD A,_RG_L
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrb.ok],A
	JP matchrb.N.
matchrb.M.
	LD A,[_c1small]
	SUB 'a'
	JP NZ,matchrb.O.
	LD A,_RG_A
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrb.ok],A
	JP matchrb.P.
matchrb.O.
	LD A,FALSE
	LD [matchrb.ok],A
matchrb.P.
matchrb.N.
matchrb.L.
matchrb.J.
matchrb.H.
matchrb.F.
matchrb.D.
	JP matchrb.B.
matchrb.A.
	LD HL,[_lentword]
	LD DE,2
	OR A
	SBC HL,DE
	JP NZ,matchrb.Q.
	LD A,[_c1small]
	SUB 'h'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'x'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchrb.S.
	LD A,_RG_HX
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrb.ok],A
	JP matchrb.T.
matchrb.S.
	LD A,[_c1small]
	SUB 'l'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'x'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchrb.U.
	LD A,_RG_LX
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrb.ok],A
	JP matchrb.V.
matchrb.U.
	LD A,[_c1small]
	SUB 'h'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'y'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchrb.W.
	LD A,_RG_HY
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrb.ok],A
	JP matchrb.X.
matchrb.W.
	LD A,[_c1small]
	SUB 'l'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'y'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchrb.Y.
	LD A,_RG_LY
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrb.ok],A
	JP matchrb.Z.
matchrb.Y.
	LD A,[_c1small]
	SUB 'r'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_c2small]
	SUB 'b'
	SUB 1
	SBC A,A
	AND L
	JP Z,matchrb.BA.
	CALL asmrdword_tokspc
	LD A,_RG_RBBYNAME
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL toktext
	CALL asmrdword_tokspc
	LD A,TRUE
	LD [matchrb.ok],A
	JP matchrb.BB.
matchrb.BA.
	LD A,FALSE
	LD [matchrb.ok],A
matchrb.BB.
matchrb.Z.
matchrb.X.
matchrb.V.
matchrb.T.
	JP matchrb.R.
matchrb.Q.
	LD A,FALSE
	LD [matchrb.ok],A
matchrb.R.
matchrb.B.
	LD A,[matchrb.ok]
	RET
asm_hlix_close_token
	CALL matchhl
	OR A
	JP Z,asm_hlix_close_token.C.
	CALL matchclose
	OR A
	JP Z,asm_hlix_close_token.E.
	LD A,[asm_hlix_close_token.hltoken]
	LD [asmtoken.A.],A
	CALL asmtoken
	JP asm_hlix_close_token.F.
asm_hlix_close_token.E.
	LD A,_ERRCLOSE
	LD [tokerr.A.],A
	CALL tokerr
asm_hlix_close_token.F.
	JP asm_hlix_close_token.D.
asm_hlix_close_token.C.
	CALL matchixiy
	OR A
	JP Z,asm_hlix_close_token.G.
	CALL tokexpr_close
	OR A
	JP Z,asm_hlix_close_token.I.
	LD A,[asm_hlix_close_token.ixtoken]
	LD [asmtoken.A.],A
	CALL asmtoken
	JP asm_hlix_close_token.J.
asm_hlix_close_token.I.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
asm_hlix_close_token.J.
	JP asm_hlix_close_token.H.
asm_hlix_close_token.G.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
asm_hlix_close_token.H.
asm_hlix_close_token.D.
	RET
asm_directhlixrp_close_token
	CALL matchhl
	OR A
	JP Z,asm_directhlixrp_close_token.E.
	CALL matchclose
	OR A
	JP Z,asm_directhlixrp_close_token.G.
	LD A,[asm_directhlixrp_close_token.hltoken]
	LD [asmtoken.A.],A
	CALL asmtoken
	JP asm_directhlixrp_close_token.H.
asm_directhlixrp_close_token.G.
	LD A,_ERRCLOSE
	LD [tokerr.A.],A
	CALL tokerr
asm_directhlixrp_close_token.H.
	JP asm_directhlixrp_close_token.F.
asm_directhlixrp_close_token.E.
	CALL matchixiy
	OR A
	JP Z,asm_directhlixrp_close_token.I.
	CALL tokexpr_close
	OR A
	JP Z,asm_directhlixrp_close_token.K.
	LD A,[asm_directhlixrp_close_token.ixtoken]
	LD [asmtoken.A.],A
	CALL asmtoken
	JP asm_directhlixrp_close_token.L.
asm_directhlixrp_close_token.K.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
asm_directhlixrp_close_token.L.
	JP asm_directhlixrp_close_token.J.
asm_directhlixrp_close_token.I.
	CALL matchrp
	OR A
	JP Z,asm_directhlixrp_close_token.M.
	CALL matchclose
	OR A
	JP Z,asm_directhlixrp_close_token.O.
	LD A,[asm_directhlixrp_close_token.rptoken]
	LD [asmtoken.A.],A
	CALL asmtoken
	JP asm_directhlixrp_close_token.P.
asm_directhlixrp_close_token.O.
	LD A,_ERRCLOSE
	LD [tokerr.A.],A
	CALL tokerr
asm_directhlixrp_close_token.P.
	JP asm_directhlixrp_close_token.N.
asm_directhlixrp_close_token.M.
	CALL tokexpr_close
	OR A
	JP Z,asm_directhlixrp_close_token.Q.
	LD A,[asm_directhlixrp_close_token.directtoken]
	LD [asmtoken.A.],A
	CALL asmtoken
	JP asm_directhlixrp_close_token.R.
asm_directhlixrp_close_token.Q.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
asm_directhlixrp_close_token.R.
asm_directhlixrp_close_token.N.
asm_directhlixrp_close_token.J.
asm_directhlixrp_close_token.F.
	RET
asm_directrb_token
	CALL matchrb
	OR A
	JP Z,asm_directrb_token.C.
	LD A,[asm_directrb_token.rbtoken]
	LD [asmtoken.A.],A
	CALL asmtoken
	JP asm_directrb_token.D.
asm_directrb_token.C.
	CALL tokexpr
	OR A
	JP Z,asm_directrb_token.E.
	LD A,[asm_directrb_token.directtoken]
	LD [asmtoken.A.],A
	CALL asmtoken
	JP asm_directrb_token.F.
asm_directrb_token.E.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
asm_directrb_token.F.
asm_directrb_token.D.
	RET
tokex
	LD A,_ASMEX
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matchopen
	OR A
	JP Z,tokex.A.
	CALL matchsp
	OR A
	JP Z,tokex.C.
	CALL matchclose
	OR A
	JP Z,tokex.E.
	CALL matchcomma
	OR A
	JP Z,tokex.G.
	CALL matchhlixiy
	OR A
	JP Z,tokex.I.
	LD A,_FMTEXRPRP
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokex.J.
tokex.I.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokex.J.
	JP tokex.H.
tokex.G.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokex.H.
	JP tokex.F.
tokex.E.
	LD A,_ERRCLOSE
	LD [tokerr.A.],A
	CALL tokerr
tokex.F.
	JP tokex.D.
tokex.C.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokex.D.
	JP tokex.B.
tokex.A.
	CALL matchde
	OR A
	JP Z,tokex.K.
	CALL matchcomma
	OR A
	JP Z,tokex.M.
	CALL matchhl
	OR A
	JP Z,tokex.O.
	LD A,_FMTEXRPRP
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokex.P.
tokex.O.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokex.P.
	JP tokex.N.
tokex.M.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokex.N.
	JP tokex.L.
tokex.K.
	CALL matchaf
	OR A
	JP Z,tokex.Q.
	CALL matchcomma
	OR A
	JP Z,tokex.S.
	CALL matchaf
	OR A
	JP Z,tokex.U.
	CALL matchprime
	OR A
	JP Z,tokex.W.
	LD A,_FMTEXRPRP
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokex.X.
tokex.W.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokex.X.
	JP tokex.V.
tokex.U.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokex.V.
	JP tokex.T.
tokex.S.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokex.T.
tokex.Q.
tokex.L.
tokex.B.
	RET
tokinc
	LD A,_ASMINC
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matchopen
	OR A
	JP Z,tokinc.A.
	LD A,_FMTINCDECMHL
	LD [asm_hlix_close_token.A.],A
	LD A,_FMTINCDECIDX
	LD [asm_hlix_close_token.B.],A
	CALL asm_hlix_close_token
	JP tokinc.B.
tokinc.A.
	CALL matchrp
	OR A
	JP Z,tokinc.C.
	LD A,_FMTINCRP
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokinc.D.
tokinc.C.
	CALL matchrb
	OR A
	JP Z,tokinc.E.
	LD A,_FMTINCDECRB
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokinc.F.
tokinc.E.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokinc.F.
tokinc.D.
tokinc.B.
	RET
tokdec
	LD A,_ASMDEC
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matchopen
	OR A
	JP Z,tokdec.A.
	LD A,_FMTINCDECMHL
	LD [asm_hlix_close_token.A.],A
	LD A,_FMTINCDECIDX
	LD [asm_hlix_close_token.B.],A
	CALL asm_hlix_close_token
	JP tokdec.B.
tokdec.A.
	CALL matchrp
	OR A
	JP Z,tokdec.C.
	LD A,_FMTDECRP
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokdec.D.
tokdec.C.
	CALL matchrb
	OR A
	JP Z,tokdec.E.
	LD A,_FMTINCDECRB
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokdec.F.
tokdec.E.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokdec.F.
tokdec.D.
tokdec.B.
	RET
tokadd
	LD A,_ASMADD
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matcha
	OR A
	JP Z,tokadd.A.
	CALL matchcomma
	OR A
	JP Z,tokadd.C.
	CALL matchopen
	OR A
	JP Z,tokadd.E.
	LD A,_FMTALUCMDMHL
	LD [asm_hlix_close_token.A.],A
	LD A,_FMTALUCMDIDX
	LD [asm_hlix_close_token.B.],A
	CALL asm_hlix_close_token
	JP tokadd.F.
tokadd.E.
	LD A,_FMTALUCMDN
	LD [asm_directrb_token.A.],A
	LD A,_FMTALUCMDRB
	LD [asm_directrb_token.B.],A
	CALL asm_directrb_token
tokadd.F.
	JP tokadd.D.
tokadd.C.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokadd.D.
	JP tokadd.B.
tokadd.A.
	CALL matchhlixiy
	OR A
	JP Z,tokadd.G.
	CALL matchcomma
	OR A
	JP Z,tokadd.I.
	CALL matchrp
	OR A
	JP Z,tokadd.K.
	LD A,_FMTADDHLRP
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokadd.L.
tokadd.K.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokadd.L.
	JP tokadd.J.
tokadd.I.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokadd.J.
tokadd.G.
tokadd.B.
	RET
tokadc
	LD A,_ASMADC
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matcha
	OR A
	JP Z,tokadc.A.
	CALL matchcomma
	OR A
	JP Z,tokadc.C.
	CALL matchopen
	OR A
	JP Z,tokadc.E.
	LD A,_FMTALUCMDMHL
	LD [asm_hlix_close_token.A.],A
	LD A,_FMTALUCMDIDX
	LD [asm_hlix_close_token.B.],A
	CALL asm_hlix_close_token
	JP tokadc.F.
tokadc.E.
	LD A,_FMTALUCMDN
	LD [asm_directrb_token.A.],A
	LD A,_FMTALUCMDRB
	LD [asm_directrb_token.B.],A
	CALL asm_directrb_token
tokadc.F.
	JP tokadc.D.
tokadc.C.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokadc.D.
	JP tokadc.B.
tokadc.A.
	CALL matchhl
	OR A
	JP Z,tokadc.G.
	CALL matchcomma
	OR A
	JP Z,tokadc.I.
	CALL matchrp
	OR A
	JP Z,tokadc.K.
	LD A,_FMTADCHLRP
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokadc.L.
tokadc.K.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokadc.L.
	JP tokadc.J.
tokadc.I.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokadc.J.
tokadc.G.
tokadc.B.
	RET
toksbc
	LD A,_ASMSBC
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matcha
	OR A
	JP Z,toksbc.A.
	CALL matchcomma
	OR A
	JP Z,toksbc.C.
	CALL matchopen
	OR A
	JP Z,toksbc.E.
	LD A,_FMTALUCMDMHL
	LD [asm_hlix_close_token.A.],A
	LD A,_FMTALUCMDIDX
	LD [asm_hlix_close_token.B.],A
	CALL asm_hlix_close_token
	JP toksbc.F.
toksbc.E.
	LD A,_FMTALUCMDN
	LD [asm_directrb_token.A.],A
	LD A,_FMTALUCMDRB
	LD [asm_directrb_token.B.],A
	CALL asm_directrb_token
toksbc.F.
	JP toksbc.D.
toksbc.C.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
toksbc.D.
	JP toksbc.B.
toksbc.A.
	CALL matchhl
	OR A
	JP Z,toksbc.G.
	CALL matchcomma
	OR A
	JP Z,toksbc.I.
	CALL matchrp
	OR A
	JP Z,toksbc.K.
	LD A,_FMTSBCHLRP
	LD [asmtoken.A.],A
	CALL asmtoken
	JP toksbc.L.
toksbc.K.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
toksbc.L.
	JP toksbc.J.
toksbc.I.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
toksbc.J.
toksbc.G.
toksbc.B.
	RET
tokalucmd
	LD A,[tokalucmd.token]
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matchopen
	OR A
	JP Z,tokalucmd.B.
	LD A,_FMTALUCMDMHL
	LD [asm_hlix_close_token.A.],A
	LD A,_FMTALUCMDIDX
	LD [asm_hlix_close_token.B.],A
	CALL asm_hlix_close_token
	JP tokalucmd.C.
tokalucmd.B.
	LD A,_FMTALUCMDN
	LD [asm_directrb_token.A.],A
	LD A,_FMTALUCMDRB
	LD [asm_directrb_token.B.],A
	CALL asm_directrb_token
tokalucmd.C.
	RET
tokcbxx
	LD A,[tokcbxx.token]
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matchopen
	OR A
	JP Z,tokcbxx.B.
	LD A,_FMTCBCMDMHL
	LD [asm_hlix_close_token.A.],A
	LD A,_FMTCBCMDIDX
	LD [asm_hlix_close_token.B.],A
	CALL asm_hlix_close_token
	JP tokcbxx.C.
tokcbxx.B.
	CALL matchrb
	OR A
	JP Z,tokcbxx.D.
	LD A,_FMTCBCMDRB
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokcbxx.E.
tokcbxx.D.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokcbxx.E.
tokcbxx.C.
	RET
tokbit
	LD A,[tokbit.token]
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL tokexpr
	OR A
	JP Z,tokbit.B.
	LD A,_OPBIT
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL matchcomma
	OR A
	JP Z,tokbit.D.
	CALL matchopen
	OR A
	JP Z,tokbit.F.
	LD A,_FMTCBCMDMHL
	LD [asm_hlix_close_token.A.],A
	LD A,_FMTCBCMDIDX
	LD [asm_hlix_close_token.B.],A
	CALL asm_hlix_close_token
	JP tokbit.G.
tokbit.F.
	CALL matchrb
	OR A
	JP Z,tokbit.H.
	LD A,_FMTCBCMDRB
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokbit.I.
tokbit.H.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokbit.I.
tokbit.G.
	JP tokbit.E.
tokbit.D.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokbit.E.
	JP tokbit.C.
tokbit.B.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokbit.C.
	RET
tokout
	LD A,_ASMOUT
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matchopen
	OR A
	JP Z,tokout.A.
	CALL matchc
	OR A
	JP Z,tokout.C.
	CALL matchclose
	OR A
	JP Z,tokout.E.
	CALL matchcomma
	OR A
	JP Z,tokout.G.
	CALL matchrb
	OR A
	JP Z,tokout.I.
	LD A,_FMTOUTCRB
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokout.J.
tokout.I.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokout.J.
	JP tokout.H.
tokout.G.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokout.H.
	JP tokout.F.
tokout.E.
	LD A,_ERRCLOSE
	LD [tokerr.A.],A
	CALL tokerr
tokout.F.
	JP tokout.D.
tokout.C.
	CALL tokexpr_close
	OR A
	JP Z,tokout.K.
	CALL matchcomma
	OR A
	JP Z,tokout.M.
	CALL matcha
	OR A
	JP Z,tokout.O.
	LD A,_FMTALUCMDN
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokout.P.
tokout.O.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokout.P.
	JP tokout.N.
tokout.M.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokout.N.
	JP tokout.L.
tokout.K.
	LD A,_ERRPAR
	LD [tokerr.A.],A
	CALL tokerr
tokout.L.
tokout.D.
	JP tokout.B.
tokout.A.
	LD A,_ERROPEN
	LD [tokerr.A.],A
	CALL tokerr
tokout.B.
	RET
tokin
	LD A,_ASMIN
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matcha
	OR A
	JP Z,tokin.A.
	CALL matchcomma
	OR A
	JP Z,tokin.C.
	CALL matchopen
	OR A
	JP Z,tokin.E.
	CALL matchc
	OR A
	JP Z,tokin.G.
	CALL matchclose
	OR A
	JP Z,tokin.I.
	LD A,_FMTINRBC
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokin.J.
tokin.I.
	LD A,_ERRCLOSE
	LD [tokerr.A.],A
	CALL tokerr
tokin.J.
	JP tokin.H.
tokin.G.
	CALL tokexpr_close
	OR A
	JP Z,tokin.K.
	LD A,_FMTALUCMDN
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokin.L.
tokin.K.
	LD A,_ERRPAR
	LD [tokerr.A.],A
	CALL tokerr
tokin.L.
tokin.H.
	JP tokin.F.
tokin.E.
	LD A,_ERROPEN
	LD [tokerr.A.],A
	CALL tokerr
tokin.F.
	JP tokin.D.
tokin.C.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokin.D.
	JP tokin.B.
tokin.A.
	CALL matchrb
	OR A
	JP Z,tokin.M.
	CALL matchcomma
	OR A
	JP Z,tokin.O.
	CALL matchopen
	OR A
	JP Z,tokin.Q.
	CALL matchc
	OR A
	JP Z,tokin.S.
	CALL matchclose
	OR A
	JP Z,tokin.U.
	LD A,_FMTINRBC
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokin.V.
tokin.U.
	LD A,_ERRCLOSE
	LD [tokerr.A.],A
	CALL tokerr
tokin.V.
	JP tokin.T.
tokin.S.
	LD A,_ERRPAR
	LD [tokerr.A.],A
	CALL tokerr
tokin.T.
	JP tokin.R.
tokin.Q.
	LD A,_ERROPEN
	LD [tokerr.A.],A
	CALL tokerr
tokin.R.
	JP tokin.P.
tokin.O.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokin.P.
	JP tokin.N.
tokin.M.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokin.N.
tokin.B.
	RET
tokpush
	LD A,_ASMPUSH
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matchaf
	OR A
	JP Z,tokpush.A.
	LD A,_FMTPUSHPOPRP
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokpush.B.
tokpush.A.
	CALL matchrp
	OR A
	JP Z,tokpush.C.
	LD A,_FMTPUSHPOPRP
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokpush.D.
tokpush.C.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokpush.D.
tokpush.B.
	RET
tokpop
	LD A,_ASMPOP
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matchaf
	OR A
	JP Z,tokpop.A.
	LD A,_FMTPUSHPOPRP
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokpop.B.
tokpop.A.
	CALL matchrp
	OR A
	JP Z,tokpop.C.
	LD A,_FMTPUSHPOPRP
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokpop.D.
tokpop.C.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokpop.D.
tokpop.B.
	RET
tokld
	LD A,_ASMLD
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matchopen
	OR A
	JP Z,tokld.A.
	CALL matchhl
	OR A
	JP Z,tokld.C.
	CALL matchclose
	OR A
	JP Z,tokld.E.
	CALL matchcomma
	OR A
	JP Z,tokld.G.
	LD A,_FMTPUTMHLN
	LD [asm_directrb_token.A.],A
	LD A,_FMTPUTMHLRB
	LD [asm_directrb_token.B.],A
	CALL asm_directrb_token
	JP tokld.H.
tokld.G.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokld.H.
	JP tokld.F.
tokld.E.
	LD A,_ERRCLOSE
	LD [tokerr.A.],A
	CALL tokerr
tokld.F.
	JP tokld.D.
tokld.C.
	CALL matchixiy
	OR A
	JP Z,tokld.I.
	CALL tokexpr_close
	OR A
	JP Z,tokld.K.
	CALL matchcomma
	OR A
	JP Z,tokld.M.
	LD A,_FMTPUTIDXN
	LD [asm_directrb_token.A.],A
	LD A,_FMTPUTIDXRB
	LD [asm_directrb_token.B.],A
	CALL asm_directrb_token
	JP tokld.N.
tokld.M.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokld.N.
	JP tokld.L.
tokld.K.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokld.L.
	JP tokld.J.
tokld.I.
	CALL matchrp
	OR A
	JP Z,tokld.O.
	CALL matchclose
	OR A
	JP Z,tokld.Q.
	CALL matchcomma
	OR A
	JP Z,tokld.S.
	CALL matcha
	OR A
	JP Z,tokld.U.
	LD A,_FMTPUTMRPA
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokld.V.
tokld.U.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokld.V.
	JP tokld.T.
tokld.S.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokld.T.
	JP tokld.R.
tokld.Q.
	LD A,_ERRCLOSE
	LD [tokerr.A.],A
	CALL tokerr
tokld.R.
	JP tokld.P.
tokld.O.
	CALL tokexpr_close
	OR A
	JP Z,tokld.W.
	CALL matchcomma
	OR A
	JP Z,tokld.Y.
	CALL matcha
	OR A
	JP Z,tokld.BA.
	LD A,_FMTPUTMNNA
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokld.BB.
tokld.BA.
	CALL matchrp
	OR A
	JP Z,tokld.BC.
	LD A,_FMTPUTMNNRP
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokld.BD.
tokld.BC.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokld.BD.
tokld.BB.
	JP tokld.Z.
tokld.Y.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokld.Z.
	JP tokld.X.
tokld.W.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokld.X.
tokld.P.
tokld.J.
tokld.D.
	JP tokld.B.
tokld.A.
	CALL matchrp
	OR A
	JP Z,tokld.BE.
	CALL matchcomma
	OR A
	JP Z,tokld.BG.
	CALL matchopen
	OR A
	JP Z,tokld.BI.
	LD A,_FMTGETRPMNN
	LD [asm_direct_expr_close_token.A.],A
	CALL asm_direct_expr_close_token
	JP tokld.BJ.
tokld.BI.
	CALL matchrp
	OR A
	JP Z,tokld.BK.
	LD A,_FMTMOVRPRP
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokld.BL.
tokld.BK.
	CALL tokexpr
	OR A
	JP Z,tokld.BM.
	LD A,_FMTLDRPNN
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokld.BN.
tokld.BM.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokld.BN.
tokld.BL.
tokld.BJ.
	JP tokld.BH.
tokld.BG.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokld.BH.
	JP tokld.BF.
tokld.BE.
	CALL matcha
	OR A
	JP Z,tokld.BO.
	CALL matchcomma
	OR A
	JP Z,tokld.BQ.
	CALL matchopen
	OR A
	JP Z,tokld.BS.
	LD A,_FMTGETAMNN
	LD [asm_directhlixrp_close_token.A.],A
	LD A,_FMTGETRBMHL
	LD [asm_directhlixrp_close_token.B.],A
	LD A,_FMTGETRBIDX
	LD [asm_directhlixrp_close_token.C.],A
	LD A,_FMTGETAMRP
	LD [asm_directhlixrp_close_token.D.],A
	CALL asm_directhlixrp_close_token
	JP tokld.BT.
tokld.BS.
	CALL matchir
	OR A
	JP Z,tokld.BU.
	LD A,_FMTMOVAIR
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokld.BV.
tokld.BU.
	LD A,_FMTLDRBN
	LD [asm_directrb_token.A.],A
	LD A,_FMTMOVRBRB
	LD [asm_directrb_token.B.],A
	CALL asm_directrb_token
tokld.BV.
tokld.BT.
	JP tokld.BR.
tokld.BQ.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokld.BR.
	JP tokld.BP.
tokld.BO.
	CALL matchrb
	OR A
	JP Z,tokld.BW.
	CALL matchcomma
	OR A
	JP Z,tokld.BY.
	CALL matchopen
	OR A
	JP Z,tokld.CA.
	LD A,_FMTGETRBMHL
	LD [asm_hlix_close_token.A.],A
	LD A,_FMTGETRBIDX
	LD [asm_hlix_close_token.B.],A
	CALL asm_hlix_close_token
	JP tokld.CB.
tokld.CA.
	LD A,_FMTLDRBN
	LD [asm_directrb_token.A.],A
	LD A,_FMTMOVRBRB
	LD [asm_directrb_token.B.],A
	CALL asm_directrb_token
tokld.CB.
	JP tokld.BZ.
tokld.BY.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokld.BZ.
	JP tokld.BX.
tokld.BW.
	CALL matchir
	OR A
	JP Z,tokld.CC.
	CALL matchcomma
	OR A
	JP Z,tokld.CE.
	CALL matcha
	OR A
	JP Z,tokld.CG.
	LD A,_FMTMOVIRA
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokld.CH.
tokld.CG.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokld.CH.
	JP tokld.CF.
tokld.CE.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokld.CF.
	JP tokld.CD.
tokld.CC.
	LD A,_ERRREG
	LD [tokerr.A.],A
	CALL tokerr
tokld.CD.
tokld.BX.
tokld.BP.
tokld.BF.
tokld.B.
	RET
tokret
	LD A,_ASMRET
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD HL,[_asmwaseols]
	LD DE,0
	OR A
	SBC HL,DE
	LD L,0
	JR Z,$+3
	DEC L
	LD A,[_asmwaseof]
	OR L
	LD DE,[_tword]
	LD L,A
	LD A,[DE]
	SUB ':'
	SUB 1
	SBC A,A
	OR L
	LD DE,[_tword]
	LD L,A
	LD A,[DE]
	SUB ';'
	SUB 1
	SBC A,A
	OR L
	JP Z,tokret.A.
	LD A,_FMTXX
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokret.B.
tokret.A.
	CALL matchcc
	OR A
	JP Z,tokret.C.
	LD A,_FMTXX
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokret.D.
tokret.C.
	CALL tokerrcmd
tokret.D.
tokret.B.
	RET
tokdjnz
	LD A,_ASMDJNZ
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL tokexpr
	OR A
	JP Z,tokdjnz.A.
	LD A,_FMTJRDD
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokdjnz.B.
tokdjnz.A.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokdjnz.B.
	RET
tokjr
	LD A,_ASMJR
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matchnzzncc
	OR A
	JP Z,tokjr.A.
	CALL matchcomma
	OR A
	JP Z,tokjr.C.
	CALL tokexpr
	OR A
	JP Z,tokjr.E.
	LD A,_FMTJRDD
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokjr.F.
tokjr.E.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokjr.F.
	JP tokjr.D.
tokjr.C.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokjr.D.
	JP tokjr.B.
tokjr.A.
	CALL tokexpr
	OR A
	JP Z,tokjr.G.
	LD A,_FMTJRDD
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokjr.H.
tokjr.G.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokjr.H.
tokjr.B.
	RET
tokjp
	LD A,_ASMJP
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matchcc
	OR A
	JP Z,tokjp.A.
	CALL matchcomma
	OR A
	JP Z,tokjp.C.
	CALL tokexpr
	OR A
	JP Z,tokjp.E.
	LD A,_FMTJPNN
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokjp.F.
tokjp.E.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokjp.F.
	JP tokjp.D.
tokjp.C.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokjp.D.
	JP tokjp.B.
tokjp.A.
	CALL matchopen
	OR A
	JP Z,tokjp.G.
	CALL matchhlixiy
	OR A
	JP Z,tokjp.I.
	CALL matchclose
	OR A
	JP Z,tokjp.K.
	LD A,_FMTJPRP
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokjp.L.
tokjp.K.
	LD A,_ERRCLOSE
	LD [tokerr.A.],A
	CALL tokerr
tokjp.L.
	JP tokjp.J.
tokjp.I.
	CALL tokexpr_close
	OR A
	JP Z,tokjp.M.
	LD A,_FMTJPNN
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokjp.N.
tokjp.M.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokjp.N.
tokjp.J.
	JP tokjp.H.
tokjp.G.
	CALL tokexpr
	OR A
	JP Z,tokjp.O.
	LD A,_FMTJPNN
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokjp.P.
tokjp.O.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokjp.P.
tokjp.H.
tokjp.B.
	RET
tokcall
	LD A,_ASMCALL
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL matchcc
	OR A
	JP Z,tokcall.A.
	CALL matchcomma
	OR A
	JP Z,tokcall.C.
	CALL tokexpr
	OR A
	JP Z,tokcall.E.
	LD A,_FMTJPNN
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokcall.F.
tokcall.E.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokcall.F.
	JP tokcall.D.
tokcall.C.
	LD A,_ERRCOMMA
	LD [tokerr.A.],A
	CALL tokerr
tokcall.D.
	JP tokcall.B.
tokcall.A.
	CALL tokexpr
	OR A
	JP Z,tokcall.G.
	LD A,_FMTJPNN
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokcall.H.
tokcall.G.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokcall.H.
tokcall.B.
	RET
tokrst
	LD A,_ASMRST
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL tokexpr
	OR A
	JP Z,tokrst.A.
	LD A,_FMTRST
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokrst.B.
tokrst.A.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokrst.B.
	RET
tokim
	LD A,_ASMIM
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	CALL tokexpr
	OR A
	JP Z,tokim.A.
	LD A,_FMTIM
	LD [asmtoken.A.],A
	CALL asmtoken
	JP tokim.B.
tokim.A.
	LD A,_ERREXPR
	LD [tokerr.A.],A
	CALL tokerr
tokim.B.
	RET
tokxx
	LD A,[tokxx.token]
	LD [asmtoken.A.],A
	CALL asmtoken
	CALL asmrdword_tokspc
	LD A,_FMTXX
	LD [asmtoken.A.],A
	CALL asmtoken
	RET
tokalucmdN
	LD A,[_temppar]
	LD [tokalucmd.A.],A
	CALL tokalucmd
	RET
tokxxN
	LD A,[_temppar]
	LD [tokxx.A.],A
	CALL tokxx
	RET
tokcbxxN
	LD A,[_temppar]
	LD [tokcbxx.A.],A
	CALL tokcbxx
	RET
tokbitN
	LD A,[_temppar]
	LD [tokbit.A.],A
	CALL tokbit
	RET
tokpre
	LD HL,tokpre.A.
	LD [tokaddlbl.A.],HL
	LD HL,tokld
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.B.
	LD [tokaddlbl.A.],HL
	LD HL,tokcall
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.C.
	LD [tokaddlbl.A.],HL
	LD HL,tokjp
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.D.
	LD [tokaddlbl.A.],HL
	LD HL,tokret
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.E.
	LD [tokaddlbl.A.],HL
	LD HL,tokjr
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.F.
	LD [tokaddlbl.A.],HL
	LD HL,tokdb
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.G.
	LD [tokaddlbl.A.],HL
	LD HL,tokdw
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.H.
	LD [tokaddlbl.A.],HL
	LD HL,tokdl
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.I.
	LD [tokaddlbl.A.],HL
	LD HL,tokds
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.J.
	LD [tokaddlbl.A.],HL
	LD HL,tokpop
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.K.
	LD [tokaddlbl.A.],HL
	LD HL,tokpush
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.L.
	LD [tokaddlbl.A.],HL
	LD HL,tokadd
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.M.
	LD [tokaddlbl.A.],HL
	LD HL,tokadc
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.N.
	LD [tokaddlbl.A.],HL
	LD HL,tokalucmdN
	LD [tokaddlbl.B.],HL
	LD A,_ASMSUB
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.O.
	LD [tokaddlbl.A.],HL
	LD HL,toksbc
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.P.
	LD [tokaddlbl.A.],HL
	LD HL,tokalucmdN
	LD [tokaddlbl.B.],HL
	LD A,_ASMAND
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.Q.
	LD [tokaddlbl.A.],HL
	LD HL,tokalucmdN
	LD [tokaddlbl.B.],HL
	LD A,_ASMOR
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.R.
	LD [tokaddlbl.A.],HL
	LD HL,tokalucmdN
	LD [tokaddlbl.B.],HL
	LD A,_ASMXOR
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.S.
	LD [tokaddlbl.A.],HL
	LD HL,tokalucmdN
	LD [tokaddlbl.B.],HL
	LD A,_ASMCP
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.T.
	LD [tokaddlbl.A.],HL
	LD HL,tokinc
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.U.
	LD [tokaddlbl.A.],HL
	LD HL,tokdec
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.V.
	LD [tokaddlbl.A.],HL
	LD HL,tokex
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.W.
	LD [tokaddlbl.A.],HL
	LD HL,tokcbxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMRLC
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.X.
	LD [tokaddlbl.A.],HL
	LD HL,tokcbxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMRRC
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.Y.
	LD [tokaddlbl.A.],HL
	LD HL,tokcbxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMRL
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.Z.
	LD [tokaddlbl.A.],HL
	LD HL,tokcbxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMRR
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BA.
	LD [tokaddlbl.A.],HL
	LD HL,tokcbxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMSLA
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BB.
	LD [tokaddlbl.A.],HL
	LD HL,tokcbxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMSRA
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BC.
	LD [tokaddlbl.A.],HL
	LD HL,tokcbxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMSLI
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BD.
	LD [tokaddlbl.A.],HL
	LD HL,tokcbxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMSRL
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BE.
	LD [tokaddlbl.A.],HL
	LD HL,tokdjnz
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BF.
	LD [tokaddlbl.A.],HL
	LD HL,tokrst
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BG.
	LD [tokaddlbl.A.],HL
	LD HL,tokout
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BH.
	LD [tokaddlbl.A.],HL
	LD HL,tokin
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BI.
	LD [tokaddlbl.A.],HL
	LD HL,tokbitN
	LD [tokaddlbl.B.],HL
	LD A,_ASMBIT
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BJ.
	LD [tokaddlbl.A.],HL
	LD HL,tokbitN
	LD [tokaddlbl.B.],HL
	LD A,_ASMRES
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BK.
	LD [tokaddlbl.A.],HL
	LD HL,tokbitN
	LD [tokaddlbl.B.],HL
	LD A,_ASMSET
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BL.
	LD [tokaddlbl.A.],HL
	LD HL,tokim
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BM.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMRLCA
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BN.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMRRCA
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BO.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMRLA
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BP.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMRRA
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BQ.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMDAA
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BR.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMCPL
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BS.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMSCF
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BT.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMCCF
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BU.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMNOP
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BV.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMHALT
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BW.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMDI
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BX.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMEI
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BY.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMEXX
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.BZ.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMRETN
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CA.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMRETI
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CB.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMLDI
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CC.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMLDD
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CD.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMLDIR
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CE.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMLDDR
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CF.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMCPI
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CG.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMCPD
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CH.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMCPIR
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CI.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMCPDR
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CJ.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMINI
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CK.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMIND
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CL.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMINIR
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CM.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMINDR
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CN.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMOUTI
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CO.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMOUTD
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CP.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMOTIR
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CQ.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMOTDR
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CR.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMINF
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CS.
	LD [tokaddlbl.A.],HL
	LD HL,tokxxN
	LD [tokaddlbl.B.],HL
	LD A,_ASMNEG
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CT.
	LD [tokaddlbl.A.],HL
	LD HL,tokorg
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CU.
	LD [tokaddlbl.A.],HL
	LD HL,tokexport
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CV.
	LD [tokaddlbl.A.],HL
	LD HL,tokinclude
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CW.
	LD [tokaddlbl.A.],HL
	LD HL,tokincbin
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	LD HL,tokpre.CX.
	LD [tokaddlbl.A.],HL
	LD HL,tokcolon
	LD [tokaddlbl.B.],HL
	LD A,0x00
	LD [tokaddlbl.C.],A
	CALL tokaddlbl
	RET
