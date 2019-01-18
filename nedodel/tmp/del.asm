comparedesc
	LD A,0x08
	LD [comparedesc.i],A
	LD HL,[comparedesc.filename]
	LD [findlastslash.A.],HL
	CALL findlastslash
	LD [comparedesc.filename],HL
comparedesc.loop
	LD HL,[comparedesc.filename]
	LD A,[HL]
	LD [comparedesc.c],A
	LD HL,[comparedesc.filename]
	INC HL
	LD [comparedesc.filename],HL
	LD A,[comparedesc.c]
	SUB '.'
	JP NZ,comparedesc.C.
comparedesc.dot
	LD HL,[comparedesc.desc]
	LD A,[comparedesc.i]
	LD E,A
	LD D,0
	ADD HL,DE
	LD A,[HL]
	LD DE,[comparedesc.filename]
	LD L,A
	LD A,[DE]
	SUB L
	SUB 1
	SBC A,A
	LD [comparedesc.res],A
	JP comparedesc.quit
comparedesc.C.
	LD A,[comparedesc.c]
	LD DE,[comparedesc.desc]
	LD L,A
	LD A,[DE]
	SUB L
	JP Z,comparedesc.E.
	LD A,FALSE
	LD [comparedesc.res],A
	JP comparedesc.quit
comparedesc.E.
	LD HL,[comparedesc.desc]
	INC HL
	LD [comparedesc.desc],HL
	LD HL,comparedesc.i
	DEC [HL]
	LD A,[comparedesc.i]
	SUB 0x00
	JP NZ,comparedesc.G.
	LD HL,[comparedesc.filename]
	LD A,[HL]
	LD [comparedesc.c],A
	LD HL,[comparedesc.filename]
	INC HL
	LD [comparedesc.filename],HL
	JP comparedesc.dot
comparedesc.G.
	JP comparedesc.loop
comparedesc.quit
	LD A,[comparedesc.res]
	RET
main
	LD HL,psystrk
	LD [readsectors.A.],HL
	LD HL,0x0000
	LD [readsectors.B.],HL
	LD A,0x09
	LD [readsectors.C.],A
	CALL readsectors
	LD HL,psystrk
	LD DE,0x8f4
	ADD HL,DE
	LD A,[HL]
	LD [main.nerased],A
	LD HL,psystrk
	LD [main.curfiledesc],HL
main.loop
	LD HL,[main.curfiledesc]
	LD A,[HL]
	SUB 0x00
	JP NZ,main.B.
	JP main.quit
main.B.
	LD HL,[main.fn]
	LD [comparedesc.A.],HL
	LD HL,[main.curfiledesc]
	LD [comparedesc.B.],HL
	CALL comparedesc
	OR A
	JP Z,main.D.
	LD HL,[main.curfiledesc]
	LD DE,0
	ADD HL,DE
	LD A,0x01
	LD [HL],A
	LD HL,main.nerased
	INC [HL]
main.D.
	LD HL,[main.curfiledesc]
	LD DE,16
	ADD HL,DE
	LD [main.curfiledesc],HL
	JP main.loop
main.quit
	LD HL,psystrk
	LD DE,0x8f4
	ADD HL,DE
	LD A,[main.nerased]
	LD [HL],A
	LD HL,psystrk
	LD [writesectors.A.],HL
	LD HL,0x0000
	LD [writesectors.B.],HL
	LD A,0x09
	LD [writesectors.C.],A
	CALL writesectors
	RET
