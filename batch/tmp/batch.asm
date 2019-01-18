batch
	LD HL,fn
	LD [nfopen.A.],HL
	LD HL,batch.A.
	LD [nfopen.B.],HL
	CALL nfopen
	LD [_fin],HL
	LD HL,[_fin]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,batch.B.
	LD A,FALSE
	LD [_waseof],A
batch.D.
	LD A,[_waseof]
	CPL
	OR A
	JP Z,batch.E.
	LD HL,fn
	LD [batch.pfn],HL
	LD HL,PARADDR
	LD [batch.ppar],HL
batch.readcmd
	CALL readfin
	LD [batch.c],A
	LD A,[batch.c]
	SUB ' '
	JP NZ,batch.F.
	JP batch.readcmdq
batch.F.
	LD A,[batch.c]
	SUB '\n'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_waseof]
	OR L
	JP Z,batch.H.
	JP batch.readparq
batch.H.
	LD A,[batch.c]
	SUB 0x0d
	JP Z,batch.J.
	LD HL,[batch.pfn]
	LD A,[batch.c]
	LD [HL],A
	LD HL,[batch.pfn]
	INC HL
	LD [batch.pfn],HL
batch.J.
	JP batch.readcmd
batch.readcmdq
batch.readpar
	CALL readfin
	LD [batch.c],A
	LD A,[batch.c]
	SUB '\n'
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_waseof]
	OR L
	JP Z,batch.L.
	JP batch.readparq
batch.L.
	LD A,[batch.c]
	SUB 0x0d
	JP Z,batch.N.
	LD HL,[batch.ppar]
	LD A,[batch.c]
	LD [HL],A
	LD HL,[batch.ppar]
	INC HL
	LD [batch.ppar],HL
batch.N.
	JP batch.readpar
batch.readparq
	LD HL,[batch.pfn]
	LD A,'\0'
	LD [HL],A
	LD HL,[batch.ppar]
	LD A,0x0d
	LD [HL],A
	LD A,[_waseof]
	LD [batch.waswaseof],A
	LD HL,fn
	LD [loadfile.A.],HL
	LD HL,RUNADDR
	LD [loadfile.B.],HL
	CALL loadfile
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,batch.P.
	LD HL,RUNADDR
	CALL _JPHL.
batch.P.
	LD A,[batch.waswaseof]
	LD [_waseof],A
	JP batch.D.
batch.E.
	LD HL,[_fin]
	LD [fclose.A.],HL
	CALL fclose
batch.B.
	RET
