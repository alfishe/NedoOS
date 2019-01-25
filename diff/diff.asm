diff
	LD HL,0
	LD [diff.errors],HL
	LD HL,0
	LD [diff.addr],HL
	LD A,0x00
	LD [setxy.A.],A
	LD A,0x00
	LD [setxy.B.],A
	CALL setxy
	LD HL,[diff.fn1]
	LD [nfopen.A.],HL
	LD HL,diff.C.
	LD [nfopen.B.],HL
	CALL nfopen
	LD [_fin],HL
	LD HL,[_fin]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,diff.D.
	LD A,FALSE
	LD [_waseof],A
	LD HL,[diff.fn2]
	LD [nfopen.A.],HL
	LD HL,diff.F.
	LD [nfopen.B.],HL
	CALL nfopen
	LD [_fin2],HL
	LD HL,[_fin2]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,diff.G.
diff.I.
	LD A,[_waseof]
	CPL
	OR A
	JP Z,diff.J.
	CALL readfin
	LD [diff.b],A
	LD A,[_waseof]
	LD [diff.waswaseof],A
	LD HL,diff.b2
	LD [fread.A.],HL
	LD HL,1
	LD [fread.B.],HL
	LD HL,1
	LD [fread.C.],HL
	LD HL,[_fin2]
	LD [fread.D.],HL
	CALL fread
	LD A,[diff.waswaseof]
	LD L,A
	LD A,[_waseof]
	SUB L
	JP Z,diff.K.
	LD HL,diff.M.
	LD [nprintf.A.],HL
	CALL nprintf
	JP diff.quit
	JP diff.L.
diff.K.
	LD A,[diff.b]
	LD L,A
	LD A,[diff.b2]
	SUB L
	JP Z,diff.N.
	LD HL,diff.P.
	LD [nprintf.A.],HL
	LD HL,[diff.addr]
	LD [nprintf.B.],HL
	LD A,[diff.b]
	LD L,A
	LD H,0
	LD [nprintf.C.],HL
	LD A,[diff.b2]
	LD L,A
	LD H,0
	LD [nprintf.D.],HL
	CALL nprintf
	LD HL,[diff.errors]
	INC HL
	LD [diff.errors],HL
	LD HL,[diff.errors]
	LD DE,_MAXERRORS
	OR A
	SBC HL,DE
	JP NZ,diff.Q.
	JP diff.quit
diff.Q.
diff.N.
diff.L.
	LD HL,[diff.addr]
	INC HL
	LD [diff.addr],HL
	JP diff.I.
diff.J.
	LD HL,[diff.errors]
	LD DE,0
	OR A
	SBC HL,DE
	JP NZ,diff.S.
	LD HL,diff.U.
	LD [nprintf.A.],HL
	LD HL,[diff.fn1]
	LD [nprintf.B.],HL
	LD HL,[diff.fn2]
	LD [nprintf.C.],HL
	CALL nprintf
diff.S.
diff.quit
	LD HL,[_fin2]
	LD [fclose.A.],HL
	CALL fclose
diff.G.
	LD HL,[_fin]
	LD [fclose.A.],HL
	CALL fclose
diff.D.
	RET
