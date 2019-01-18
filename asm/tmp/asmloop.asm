asmbytepopvalue
	LD HL,_nvalues
	DEC [HL]
	LD A,[_asms]
	OR A
	JP Z,asmbytepopvalue.A.
	LD HL,_value
	LD A,[_nvalues]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	ADD HL,DE
	ADD HL,DE
	LD A,[HL]
	LD [writefout.A.],A
	CALL writefout
asmbytepopvalue.A.
	LD HL,[_curaddr]
	INC HL
	LD [_curaddr],HL
	RET
asmwordpopvalue
	LD HL,_nvalues
	DEC [HL]
	LD A,[_asms]
	OR A
	JP Z,asmwordpopvalue.A.
	LD A,[_isaddr]
	SUB 0x00
	JP Z,asmwordpopvalue.C.
	LD HL,[_curaddr]
	LD DE,[_curshift]
	ADD HL,DE
	LD DE,[_curbegin]
	OR A
	SBC HL,DE
	LD [asmwordpopvalue.uinttempvalue],HL
	LD HL,asmwordpopvalue.uinttempvalue
	LD [fwrite.A.],HL
	LD HL,2
	LD [fwrite.B.],HL
	LD HL,1
	LD [fwrite.C.],HL
	LD HL,[_forg]
	LD [fwrite.D.],HL
	CALL fwrite
asmwordpopvalue.C.
	LD HL,_value
	LD A,[_nvalues]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	ADD HL,DE
	ADD HL,DE
	LD [fwrite.A.],HL
	LD HL,2
	LD [fwrite.B.],HL
	LD HL,1
	LD [fwrite.C.],HL
	LD HL,[_fout]
	LD [fwrite.D.],HL
	CALL fwrite
asmwordpopvalue.A.
	LD HL,[_curaddr]
	LD DE,2
	ADD HL,DE
	LD [_curaddr],HL
	RET
asmlong
	LD HL,asmlong.value
	LD [fwrite.A.],HL
	LD HL,4
	LD [fwrite.B.],HL
	LD HL,1
	LD [fwrite.C.],HL
	LD HL,[_fout]
	LD [fwrite.D.],HL
	CALL fwrite
	LD HL,[_curaddr]
	LD DE,4
	ADD HL,DE
	LD [_curaddr],HL
	RET
asmorgword
	RET
asmdisp
	LD HL,[asmdisp.ivalue]
	LD DE,0x0080
	ADD HL,DE
	LD DE,0x0100
	LD A,L
	SUB E
	LD A,H
	SBC A,D
	JP C,asmdisp.B.
	LD HL,asmdisp.D.
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
asmdisp.B.
	LD HL,[asmdisp.ivalue]
	LD A,L
	LD [asmbyte.A.],A
	CALL asmbyte
	RET
asmdisppopvalue
	CALL asmpopvalue
	LD [asmdisp.A.],DE
	CALL asmdisp
	RET
asmrb_ixiyprefix
	LD A,[_reg]
	LD E,_ASMRBCODE_HY
	SUB E
	JP NC,asmrb_ixiyprefix.A.
	LD A,0xdd
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmrb_ixiyprefix.B.
asmrb_ixiyprefix.A.
	LD A,0xfd
	LD [asmbyte.A.],A
	CALL asmbyte
asmrb_ixiyprefix.B.
	LD A,[_reg]
	LD E,0x3f
	AND E
	LD [_reg],A
	RET
asmoldrb_ixiyprefix
	LD A,[_oldreg]
	LD E,_ASMRBCODE_HY
	SUB E
	JP NC,asmoldrb_ixiyprefix.A.
	LD A,0xdd
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmoldrb_ixiyprefix.B.
asmoldrb_ixiyprefix.A.
	LD A,0xfd
	LD [asmbyte.A.],A
	CALL asmbyte
asmoldrb_ixiyprefix.B.
	LD A,[_oldreg]
	LD E,0x3f
	AND E
	LD [_oldreg],A
	RET
asmrbrb_ixiyprefix
	LD A,0x00
	LD [asmrbrb_ixiyprefix.prefix1],A
	LD A,[_oldreg]
	LD E,_ASMRBCODE_HY
	SUB E
	JP C,asmrbrb_ixiyprefix.A.
	LD A,0xfd
	LD [asmrbrb_ixiyprefix.prefix1],A
	JP asmrbrb_ixiyprefix.test1
	JP asmrbrb_ixiyprefix.B.
asmrbrb_ixiyprefix.A.
	LD A,[_oldreg]
	LD E,_ASMRBCODE_HX
	SUB E
	JP C,asmrbrb_ixiyprefix.C.
	LD A,0xdd
	LD [asmrbrb_ixiyprefix.prefix1],A
asmrbrb_ixiyprefix.test1
	LD A,[_reg]
	SUB _ASMRBCODE_H
	JP NZ,asmrbrb_ixiyprefix.E.
	CALL errwrongreg
asmrbrb_ixiyprefix.E.
	LD A,[_reg]
	SUB _ASMRBCODE_L
	JP NZ,asmrbrb_ixiyprefix.G.
	CALL errwrongreg
asmrbrb_ixiyprefix.G.
	LD A,[asmrbrb_ixiyprefix.prefix1]
	LD [asmbyte.A.],A
	CALL asmbyte
asmrbrb_ixiyprefix.C.
asmrbrb_ixiyprefix.B.
	LD A,[_reg]
	LD E,_ASMRBCODE_HY
	SUB E
	JP C,asmrbrb_ixiyprefix.I.
	LD A,[asmrbrb_ixiyprefix.prefix1]
	SUB 0xfd
	JP Z,asmrbrb_ixiyprefix.K.
	LD A,0xfd
	LD [asmbyte.A.],A
	CALL asmbyte
	LD A,[asmrbrb_ixiyprefix.prefix1]
	SUB 0xdd
	JP NZ,asmrbrb_ixiyprefix.M.
	CALL errwrongreg
asmrbrb_ixiyprefix.M.
asmrbrb_ixiyprefix.K.
	JP asmrbrb_ixiyprefix.test2
	JP asmrbrb_ixiyprefix.J.
asmrbrb_ixiyprefix.I.
	LD A,[_reg]
	LD E,_ASMRBCODE_HX
	SUB E
	JP C,asmrbrb_ixiyprefix.O.
	LD A,[asmrbrb_ixiyprefix.prefix1]
	SUB 0xdd
	JP Z,asmrbrb_ixiyprefix.Q.
	LD A,0xdd
	LD [asmbyte.A.],A
	CALL asmbyte
	LD A,[asmrbrb_ixiyprefix.prefix1]
	SUB 0xfd
	JP NZ,asmrbrb_ixiyprefix.S.
	CALL errwrongreg
asmrbrb_ixiyprefix.S.
asmrbrb_ixiyprefix.Q.
asmrbrb_ixiyprefix.test2
	LD A,[_oldreg]
	SUB _ASMRBCODE_H
	JP NZ,asmrbrb_ixiyprefix.U.
	CALL errwrongreg
asmrbrb_ixiyprefix.U.
	LD A,[_oldreg]
	SUB _ASMRBCODE_L
	JP NZ,asmrbrb_ixiyprefix.W.
	CALL errwrongreg
asmrbrb_ixiyprefix.W.
	LD A,[_reg]
	LD E,0x3f
	AND E
	LD [_reg],A
asmrbrb_ixiyprefix.O.
asmrbrb_ixiyprefix.J.
	LD A,[_oldreg]
	LD E,0x3f
	AND E
	LD [_oldreg],A
	RET
asmrp_ixiyprefix
	LD A,[_reg]
	SUB _ASMRPCODE_IX
	JP NZ,asmrp_ixiyprefix.A.
	LD A,0xdd
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmrp_ixiyprefix.B.
asmrp_ixiyprefix.A.
	LD A,[_reg]
	SUB _ASMRPCODE_IY
	JP NZ,asmrp_ixiyprefix.C.
	LD A,0xfd
	LD [asmbyte.A.],A
	CALL asmbyte
asmrp_ixiyprefix.C.
asmrp_ixiyprefix.B.
	LD A,_ASMRPCODE_HL
	LD [_reg],A
	RET
asmoldrp_ixiyprefix
	LD A,[_oldreg]
	SUB _ASMRPCODE_IX
	JP NZ,asmoldrp_ixiyprefix.A.
	LD A,0xdd
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmoldrp_ixiyprefix.B.
asmoldrp_ixiyprefix.A.
	LD A,[_oldreg]
	SUB _ASMRPCODE_IY
	JP NZ,asmoldrp_ixiyprefix.C.
	LD A,0xfd
	LD [asmbyte.A.],A
	CALL asmbyte
asmoldrp_ixiyprefix.C.
asmoldrp_ixiyprefix.B.
	LD A,_ASMRPCODE_HL
	LD [_oldreg],A
	RET
asmrprp_ixiyprefix
	LD A,0x00
	LD [asmrprp_ixiyprefix.prefix1],A
	LD A,[_oldreg]
	SUB _ASMRPCODE_IX
	JP NZ,asmrprp_ixiyprefix.A.
	LD A,0xdd
	LD [asmrprp_ixiyprefix.prefix1],A
	JP asmrprp_ixiyprefix.test1
	JP asmrprp_ixiyprefix.B.
asmrprp_ixiyprefix.A.
	LD A,[_oldreg]
	SUB _ASMRPCODE_IY
	JP NZ,asmrprp_ixiyprefix.C.
	LD A,0xfd
	LD [asmrprp_ixiyprefix.prefix1],A
asmrprp_ixiyprefix.test1
	LD A,[_reg]
	SUB _ASMRPCODE_HL
	JP NZ,asmrprp_ixiyprefix.E.
	CALL errwrongreg
asmrprp_ixiyprefix.E.
	LD A,[asmrprp_ixiyprefix.prefix1]
	LD [asmbyte.A.],A
	CALL asmbyte
asmrprp_ixiyprefix.C.
asmrprp_ixiyprefix.B.
	LD A,[_reg]
	SUB _ASMRPCODE_IX
	JP NZ,asmrprp_ixiyprefix.G.
	LD A,[asmrprp_ixiyprefix.prefix1]
	SUB 0xdd
	JP Z,asmrprp_ixiyprefix.I.
	LD A,0xdd
	LD [asmbyte.A.],A
	CALL asmbyte
	LD A,[asmrprp_ixiyprefix.prefix1]
	SUB 0xfd
	JP NZ,asmrprp_ixiyprefix.K.
	CALL errwrongreg
asmrprp_ixiyprefix.K.
asmrprp_ixiyprefix.I.
	JP asmrprp_ixiyprefix.test2
	JP asmrprp_ixiyprefix.H.
asmrprp_ixiyprefix.G.
	LD A,[_reg]
	SUB _ASMRPCODE_IY
	JP NZ,asmrprp_ixiyprefix.M.
	LD A,[asmrprp_ixiyprefix.prefix1]
	SUB 0xfd
	JP Z,asmrprp_ixiyprefix.O.
	LD A,0xfd
	LD [asmbyte.A.],A
	CALL asmbyte
	LD A,[asmrprp_ixiyprefix.prefix1]
	SUB 0xdd
	JP NZ,asmrprp_ixiyprefix.Q.
	CALL errwrongreg
asmrprp_ixiyprefix.Q.
asmrprp_ixiyprefix.O.
asmrprp_ixiyprefix.test2
	LD A,[_oldreg]
	SUB _ASMRPCODE_HL
	JP NZ,asmrprp_ixiyprefix.S.
	CALL errwrongreg
asmrprp_ixiyprefix.S.
	LD A,_ASMRPCODE_HL
	LD [_reg],A
asmrprp_ixiyprefix.M.
asmrprp_ixiyprefix.H.
	LD A,[_oldreg]
	LD E,0x3f
	AND E
	LD [_oldreg],A
	RET
asmbyte_ed
	LD A,0xed
	LD [asmbyte.A.],A
	CALL asmbyte
	RET
err_rbix
	LD A,[_reg]
	LD E,_ASMRBIXADD
	SUB E
	JP C,err_rbix.A.
	CALL errwrongreg
err_rbix.A.
	RET
err_oldrbix
	LD A,[_oldreg]
	LD E,_ASMRBIXADD
	SUB E
	JP C,err_oldrbix.A.
	CALL errwrongreg
err_oldrbix.A.
	RET
err_rpix
	LD A,[_reg]
	LD E,_ASMRPIXADD
	SUB E
	JP C,err_rpix.A.
	CALL errwrongreg
err_rpix.A.
	RET
asmcheckrb_ixiyprefix
	LD A,[_reg]
	LD E,_ASMRBIXADD
	SUB E
	JP C,asmcheckrb_ixiyprefix.A.
	CALL asmrb_ixiyprefix
asmcheckrb_ixiyprefix.A.
	RET
asmcheckrp_ixiyprefix
	LD A,[_reg]
	LD E,_ASMRPIXADD
	SUB E
	JP C,asmcheckrp_ixiyprefix.A.
	CALL asmrp_ixiyprefix
asmcheckrp_ixiyprefix.A.
	RET
asmcheckoldrp_ixiyprefix
	LD A,[_oldreg]
	LD E,_ASMRPIXADD
	SUB E
	JP C,asmcheckoldrp_ixiyprefix.A.
	CALL asmoldrp_ixiyprefix
asmcheckoldrp_ixiyprefix.A.
	RET
initmemmodel
	RET
asmloop
asmloop.loop
	CALL readfin
	LD [_token],A
	LD HL,asmloop.J
	LD A,[_token]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	JP [HL]
asmloop.0=asmloop.default
asmloop.1=asmloop.default
asmloop.2=asmloop.default
asmloop.3=asmloop.default
asmloop.4=asmloop.default
asmloop.5=asmloop.default
asmloop.6=asmloop.default
asmloop.7=asmloop.default
asmloop.8=asmloop.default
asmloop.9=asmloop.default
asmloop.10=asmloop.default
asmloop.11=asmloop.default
asmloop.12=asmloop.default
asmloop.13=asmloop.default
asmloop.14=asmloop.default
asmloop.15=asmloop.default
asmloop.16=asmloop.default
asmloop.17=asmloop.default
asmloop.18=asmloop.default
asmloop.19=asmloop.default
asmloop.20=asmloop.default
asmloop.21=asmloop.default
asmloop.22=asmloop.default
asmloop.23=asmloop.default
asmloop.24=asmloop.default
asmloop.25=asmloop.default
asmloop.26=asmloop.default
asmloop.27=asmloop.default
asmloop.28=asmloop.default
asmloop.29=asmloop.default
asmloop.30=asmloop.default
asmloop.31=asmloop.default
asmloop.32=asmloop.default
asmloop.33=asmloop.default
asmloop.34=asmloop.default
asmloop.35=asmloop.default
asmloop.36=asmloop.default
asmloop.37=asmloop.default
asmloop.38=asmloop.default
asmloop.39=asmloop.default
asmloop.40=asmloop.default
asmloop.41=asmloop.default
asmloop.42=asmloop.default
asmloop.43=asmloop.default
asmloop.44=asmloop.default
asmloop.45=asmloop.default
asmloop.46=asmloop.default
asmloop.47=asmloop.default
asmloop.48=asmloop.default
asmloop.49=asmloop.default
asmloop.50=asmloop.default
asmloop.51=asmloop.default
asmloop.52=asmloop.default
asmloop.53=asmloop.default
asmloop.54=asmloop.default
asmloop.55=asmloop.default
asmloop.56=asmloop.default
asmloop.57=asmloop.default
asmloop.58=asmloop.default
asmloop.59=asmloop.default
asmloop.60=asmloop.default
asmloop.61=asmloop.default
asmloop.62=asmloop.default
asmloop.63=asmloop.default
asmloop.64=asmloop.default
asmloop.65=asmloop.default
asmloop.66=asmloop.default
asmloop.67=asmloop.default
asmloop.68=asmloop.default
asmloop.69=asmloop.default
asmloop.70=asmloop.default
asmloop.71=asmloop.default
asmloop.72=asmloop.default
asmloop.73=asmloop.default
asmloop.74=asmloop.default
asmloop.75=asmloop.default
asmloop.76=asmloop.default
asmloop.77=asmloop.default
asmloop.78=asmloop.default
asmloop.79=asmloop.default
asmloop.80=asmloop.default
asmloop.81=asmloop.default
asmloop.82=asmloop.default
asmloop.83=asmloop.default
asmloop.84=asmloop.default
asmloop.85=asmloop.default
asmloop.86=asmloop.default
asmloop.87=asmloop.default
asmloop.88=asmloop.default
asmloop.89=asmloop.default
asmloop.90=asmloop.default
asmloop.91=asmloop.default
asmloop.92=asmloop.default
asmloop.93=asmloop.default
asmloop.94=asmloop.default
asmloop.95=asmloop.default
asmloop.96=asmloop.default
asmloop.97=asmloop.default
asmloop.98=asmloop.default
asmloop.99=asmloop.default
asmloop.100=asmloop.default
asmloop.101=asmloop.default
asmloop.102=asmloop.default
asmloop.103=asmloop.default
asmloop.104=asmloop.default
asmloop.105=asmloop.default
asmloop.106=asmloop.default
asmloop.107=asmloop.default
asmloop.108=asmloop.default
asmloop.109=asmloop.default
asmloop.110=asmloop.default
asmloop.111=asmloop.default
asmloop.112=asmloop.default
asmloop.113=asmloop.default
asmloop.114=asmloop.default
asmloop.115=asmloop.default
asmloop.116=asmloop.default
asmloop.117=asmloop.default
asmloop.118=asmloop.default
asmloop.119=asmloop.default
asmloop.120=asmloop.default
asmloop.121=asmloop.default
asmloop.122=asmloop.default
asmloop.123=asmloop.default
asmloop.124=asmloop.default
asmloop.125=asmloop.default
asmloop.126=asmloop.default
asmloop.127=asmloop.default
asmloop.128=asmloop.default
asmloop.129=asmloop.default
asmloop.130=asmloop.default
asmloop.131=asmloop.default
asmloop.132=asmloop.default
asmloop.133=asmloop.default
asmloop.134=asmloop.default
asmloop.135=asmloop.default
asmloop.136=asmloop.default
asmloop.137=asmloop.default
asmloop.138=asmloop.default
asmloop.139=asmloop.default
asmloop.140=asmloop.default
asmloop.141=asmloop.default
asmloop.142=asmloop.default
asmloop.143=asmloop.default
asmloop.144=asmloop.default
asmloop.145=asmloop.default
asmloop.146=asmloop.default
asmloop.147=asmloop.default
asmloop.148=asmloop.default
asmloop.149=asmloop.default
asmloop.150=asmloop.default
asmloop.151=asmloop.default
asmloop.152=asmloop.default
asmloop.153=asmloop.default
asmloop.154=asmloop.default
asmloop.155=asmloop.default
asmloop.156=asmloop.default
asmloop.157=asmloop.default
asmloop.158=asmloop.default
asmloop.159=asmloop.default
asmloop.160=asmloop.default
asmloop.161=asmloop.default
asmloop.162=asmloop.default
asmloop.163=asmloop.default
asmloop.164=asmloop.default
asmloop.165=asmloop.default
asmloop.166=asmloop.default
asmloop.167=asmloop.default
asmloop.168=asmloop.default
asmloop.169=asmloop.default
asmloop.170=asmloop.default
asmloop.171=asmloop.default
asmloop.172=asmloop.default
asmloop.173=asmloop.default
asmloop.174=asmloop.default
asmloop.175=asmloop.default
asmloop.176=asmloop.default
asmloop.177=asmloop.default
asmloop.178=asmloop.default
asmloop.179=asmloop.default
asmloop.180=asmloop.default
asmloop.181=asmloop.default
asmloop.182=asmloop.default
asmloop.183=asmloop.default
asmloop.184=asmloop.default
asmloop.185=asmloop.default
asmloop.186=asmloop.default
asmloop.187=asmloop.default
asmloop.188=asmloop.default
asmloop.189=asmloop.default
asmloop.190=asmloop.default
asmloop.191=asmloop.default
asmloop.192=asmloop.default
asmloop.193=asmloop.default
asmloop.194=asmloop.default
asmloop.195=asmloop.default
asmloop.196=asmloop.default
asmloop.197=asmloop.default
asmloop.198=asmloop.default
asmloop.199=asmloop.default
asmloop.200=asmloop.default
asmloop.201=asmloop.default
asmloop.202=asmloop.default
asmloop.203=asmloop.default
asmloop.204=asmloop.default
asmloop.205=asmloop.default
asmloop.206=asmloop.default
asmloop.207=asmloop.default
asmloop.208=asmloop.default
asmloop.209=asmloop.default
asmloop.210=asmloop.default
asmloop.211=asmloop.default
asmloop.212=asmloop.default
asmloop.213=asmloop.default
asmloop.214=asmloop.default
asmloop.215=asmloop.default
asmloop.216=asmloop.default
asmloop.217=asmloop.default
asmloop.218=asmloop.default
asmloop.219=asmloop.default
asmloop.220=asmloop.default
asmloop.221=asmloop.default
asmloop.222=asmloop.default
asmloop.223=asmloop.default
asmloop.224=asmloop.default
asmloop.225=asmloop.default
asmloop.226=asmloop.default
asmloop.227=asmloop.default
asmloop.228=asmloop.default
asmloop.229=asmloop.default
asmloop.230=asmloop.default
asmloop.231=asmloop.default
asmloop.232=asmloop.default
asmloop.233=asmloop.default
asmloop.234=asmloop.default
asmloop.235=asmloop.default
asmloop.236=asmloop.default
asmloop.237=asmloop.default
asmloop.238=asmloop.default
asmloop.239=asmloop.default
asmloop.240=asmloop.default
asmloop.241=asmloop.default
asmloop.242=asmloop.default
asmloop.243=asmloop.default
asmloop.244=asmloop.default
asmloop.245=asmloop.default
asmloop.246=asmloop.default
asmloop.247=asmloop.default
asmloop.248=asmloop.default
asmloop.249=asmloop.default
asmloop.250=asmloop.default
asmloop.251=asmloop.default
asmloop.252=asmloop.default
asmloop.253=asmloop.default
asmloop.254=asmloop.default
asmloop.255=asmloop.default
asmloop.#_CMDINCLUDE=$
	LD HL,_inclfile
	LD A,[_ninclfiles]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD DE,[_fin]
	LD [HL],E
	INC HL
	LD [HL],D
	LD HL,_ninclfiles
	INC [HL]
	LD HL,0
	LD [_lenfn],HL
	LD HL,0
	LD [asmloop.i],HL
	CALL readfin
	CALL readfin
	CALL readfin
	LD [_token],A
asmloop.inclfnloop
	CALL asmreadprefixed
	LD A,[_token]
	SUB _TOKENDTEXT
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_waseof]
	OR L
	JP Z,asmloop.B.
	JP asmloop.inclfnq
asmloop.B.
	LD HL,[_fn]
	LD [stradd.A.],HL
	LD HL,[_lenfn]
	LD [stradd.B.],HL
	LD A,[_token]
	LD [stradd.C.],A
	CALL stradd
	LD [_lenfn],HL
	LD A,[_token]
	SUB '.'
	JP NZ,asmloop.D.
	LD HL,[_lenfn]
	LD [asmloop.i],HL
asmloop.D.
	JP asmloop.inclfnloop
asmloop.inclfnq
	LD HL,[asmloop.i]
	LD [_lenfn],HL
	LD HL,[_fn]
	LD [stradd.A.],HL
	LD HL,[_lenfn]
	LD [stradd.B.],HL
	LD HL,[_fn]
	LD DE,[_lenfn]
	ADD HL,DE
	LD A,[HL]
	LD E,0xdf
	AND E
	LD [stradd.C.],A
	CALL stradd
	LD [_lenfn],HL
	LD HL,[_fn]
	LD [stradd.A.],HL
	LD HL,[_lenfn]
	LD [stradd.B.],HL
	LD A,'_'
	LD [stradd.C.],A
	CALL stradd
	LD [_lenfn],HL
	LD HL,[_fn]
	LD DE,[_lenfn]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	CALL readfin
	LD HL,[_fn]
	LD [nfopen.A.],HL
	LD HL,asmloop.F.
	LD [nfopen.B.],HL
	CALL nfopen
	LD [_fin],HL
	LD HL,[_fin]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,asmloop.G.
	JP asmloop.loop
asmloop.inclq
	LD HL,[_fin]
	LD [fclose.A.],HL
	CALL fclose
	JP asmloop.H.
asmloop.G.
	LD HL,asmloop.I.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[_fn]
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
asmloop.H.
	LD HL,_ninclfiles
	DEC [HL]
	LD HL,_inclfile
	LD A,[_ninclfiles]
	LD E,A
	LD D,0
	ADD HL,DE
	ADD HL,DE
	LD A,[HL]
	INC HL
	LD H,[HL]
	LD L,A
	LD [_fin],HL
	LD A,FALSE
	LD [_waseof],A
	JP asmloop.loop
asmloop.#_CMDINCBIN=$
	LD HL,0
	LD [_lenfn],HL
	CALL readfin
	CALL readfin
	CALL readfin
	LD [_token],A
asmloop.incbfnloop
	CALL asmreadprefixed
	LD A,[_token]
	SUB _TOKENDTEXT
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_waseof]
	OR L
	JP Z,asmloop.J.
	JP asmloop.incbfnq
asmloop.J.
	LD HL,[_fn]
	LD [stradd.A.],HL
	LD HL,[_lenfn]
	LD [stradd.B.],HL
	LD A,[_token]
	LD [stradd.C.],A
	CALL stradd
	LD [_lenfn],HL
	JP asmloop.incbfnloop
asmloop.incbfnq
	LD HL,[_fn]
	LD DE,[_lenfn]
	ADD HL,DE
	LD A,'\0'
	LD [HL],A
	CALL readfin
	LD HL,[_fn]
	LD [nfopen.A.],HL
	LD HL,asmloop.L.
	LD [nfopen.B.],HL
	CALL nfopen
	LD [_fincb],HL
	LD HL,[_fincb]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,asmloop.M.
asmloop.incbloop
	LD HL,[_fincb]
	LD [readf.A.],HL
	CALL readf
	LD [_token],A
	LD A,[_waseof]
	OR A
	JP Z,asmloop.O.
	JP asmloop.incbq
asmloop.O.
	LD A,[_token]
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.incbloop
asmloop.incbq
	LD HL,[_fincb]
	LD [fclose.A.],HL
	CALL fclose
	JP asmloop.N.
asmloop.M.
	LD HL,asmloop.Q.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[_fn]
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
asmloop.N.
	LD A,FALSE
	LD [_waseof],A
	JP asmloop.loop
asmloop.#_CMDLABEL=$
	LD A,0x00
	LD [_isaddr],A
	LD A,[_token]
	LD [_curdir],A
	CALL asmdir_label
	JP asmloop.loop
asmloop.#_CMDEXPORT=$
asmloop.#_CMDORG=$
asmloop.#_CMDDISP=$
asmloop.#_CMDDB=$
asmloop.#_CMDDW=$
asmloop.#_CMDDL=$
asmloop.#_CMDDS=$
asmloop.#_CMDALIGN=$
	LD A,0x00
	LD [_isaddr],A
	LD A,[_token]
	LD [_curdir],A
	JP asmloop.loop
asmloop.#_FMTREEQU=$
	CALL asmfmt_reequ
	JP asmloop.loop
asmloop.#_FMTCMD=$
	LD A,[_curdir]
	SUB _CMDLABEL
	JP NZ,asmloop.R.
	LD A,[_labelchanged]
	OR A
	JP Z,asmloop.T.
	LD HL,asmloop.V.
	LD [errstr.A.],HL
	CALL errstr
	LD HL,[_curlabeltext]
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
asmloop.T.
	JP asmloop.S.
asmloop.R.
	LD A,[_curdir]
	SUB _CMDORG
	JP NZ,asmloop.W.
	CALL asmemitblock
	CALL asmpopvalue
	LD [_curaddr],DE
	LD HL,[_curaddr]
	LD [_curbegin],HL
	JP asmloop.X.
asmloop.W.
	LD A,[_curdir]
	SUB _CMDDISP
	JP NZ,asmloop.Y.
	CALL asmpopvalue
	LD HL,[_curaddr]
	LD A,E
	SUB L
	LD E,A
	LD A,D
	SBC A,H
	LD D,A
	LD [_curshift],DE
	JP asmloop.Z.
asmloop.Y.
	LD A,[_curdir]
	SUB _CMDENT
	JP NZ,asmloop.BA.
	LD HL,0
	LD [_curshift],HL
	JP asmloop.BB.
asmloop.BA.
	LD A,[_curdir]
	SUB _CMDDB
	JP NZ,asmloop.BC.
	JP asmloop.BD.
asmloop.BC.
	LD A,[_curdir]
	SUB _CMDDW
	JP NZ,asmloop.BE.
	JP asmloop.BF.
asmloop.BE.
	LD A,[_curdir]
	SUB _CMDDL
	JP NZ,asmloop.BG.
	JP asmloop.BH.
asmloop.BG.
	LD A,[_curdir]
	SUB _CMDDS
	JP NZ,asmloop.BI.
	LD A,[_nvalues]
	SUB 0x02
	JP NZ,asmloop.BK.
	CALL asmpopvalue
	LD A,E
	LD [_token],A
	JP asmloop.BL.
asmloop.BK.
	LD A,0x00
	LD [_token],A
asmloop.BL.
	CALL asmpopvalue
	LD [asmloop.i],DE
asmloop.BM.
	LD HL,[asmloop.i]
	LD DE,0
	OR A
	SBC HL,DE
	JP Z,asmloop.BN.
	LD A,[_token]
	LD [asmbyte.A.],A
	CALL asmbyte
	LD HL,[asmloop.i]
	DEC HL
	LD [asmloop.i],HL
	JP asmloop.BM.
asmloop.BN.
	JP asmloop.BJ.
asmloop.BI.
	LD A,[_curdir]
	SUB _CMDEXPORT
	JP NZ,asmloop.BO.
	CALL asmpopvalue
	LD [asmloop.i],DE
	LD A,[_asms]
	OR A
	JP Z,asmloop.BQ.
	LD A,_CMDLABEL
	LD [decltoken.A.],A
	CALL decltoken
	LD A,_TOKTEXT
	LD [decltoken.A.],A
	CALL decltoken
	LD HL,[_curlabeltext]
	LD [fputs.A.],HL
	LD HL,[_fdecl]
	LD [fputs.B.],HL
	CALL fputs
	LD A,_TOKENDTEXT
	LD [decltoken.A.],A
	CALL decltoken
	LD A,_TOKEQUAL
	LD [decltoken.A.],A
	CALL decltoken
	LD A,_TOKLABEL
	LD [decltoken.A.],A
	CALL decltoken
	LD A,_TOKTEXT
	LD [decltoken.A.],A
	CALL decltoken
	LD A,'_'
	LD [decltoken.A.],A
	CALL decltoken
	LD A,_TOKENDTEXT
	LD [decltoken.A.],A
	CALL decltoken
	LD A,_TOKPLUS
	LD [decltoken.A.],A
	CALL decltoken
	LD A,_TOKNUM
	LD [decltoken.A.],A
	CALL decltoken
	LD A,_TOKTEXT
	LD [decltoken.A.],A
	CALL decltoken
	LD HL,[asmloop.i]
	LD DE,[_curbegin]
	OR A
	SBC HL,DE
	LD [emitn.A.],HL
	CALL emitn
	LD HL,_nbuf
	LD [fputs.A.],HL
	LD HL,[_fdecl]
	LD [fputs.B.],HL
	CALL fputs
	LD A,_TOKENDTEXT
	LD [decltoken.A.],A
	CALL decltoken
	LD A,_OPADD
	LD [decltoken.A.],A
	CALL decltoken
	LD A,_FMTREEQU
	LD [decltoken.A.],A
	CALL decltoken
	LD A,_TOKEOL
	LD [decltoken.A.],A
	CALL decltoken
asmloop.BQ.
asmloop.BO.
asmloop.BJ.
asmloop.BH.
asmloop.BF.
asmloop.BD.
asmloop.BB.
asmloop.Z.
asmloop.X.
asmloop.S.
	JP asmloop.loop
asmloop.#_OPPUSH0=$
	LD HL,0L>>16
	LD DE,0L
	LD [asmpushvalue.A.],DE
	LD [asmpushvalue.A.+2],HL
	CALL asmpushvalue
	JP asmloop.loop
asmloop.#_OPADD=$
	CALL asmpopvalue
	PUSH HL
	PUSH DE
	CALL asmpopvalue
	POP BC
	LD A,C
	ADD A,E
	LD C,A
	LD A,B
	ADC A,D
	LD B,A
	POP DE
	EX DE,HL
	ADC HL,DE
	EX DE,HL
	LD [asmpushvalue.A.],BC
	LD [asmpushvalue.A.+2],DE
	CALL asmpushvalue
	JP asmloop.loop
asmloop.#_OPSUB=$
	CALL asmpopvalue
	LD [asmloop.tempvalue],DE
	LD [asmloop.tempvalue+2],HL
	CALL asmpopvalue
	LD BC,[asmloop.tempvalue+2]
	LD IX,[asmloop.tempvalue]
	LD A,E
	SUB LX
	LD E,A
	LD A,D
	SBC A,HX
	LD D,A
	SBC HL,BC
	LD [asmpushvalue.A.],DE
	LD [asmpushvalue.A.+2],HL
	CALL asmpushvalue
	JP asmloop.loop
asmloop.#_OPMUL=$
	CALL asmpopvalue
	PUSH HL
	PUSH DE
	CALL asmpopvalue
	PUSH HL
	PUSH DE
	POP IX
	POP BC
	POP DE
	POP HL
	CALL _MULLONG.
	LD [asmpushvalue.A.],DE
	LD [asmpushvalue.A.+2],HL
	CALL asmpushvalue
	LD A,0x00
	LD [_isaddr],A
	JP asmloop.loop
asmloop.#_OPDIV=$
	CALL asmpopvalue
	LD [asmloop.tempvalue],DE
	LD [asmloop.tempvalue+2],HL
	CALL asmpopvalue
	LD BC,[asmloop.tempvalue+2]
	LD IX,[asmloop.tempvalue]
	CALL _DIVLONG.
	LD [asmpushvalue.A.],DE
	LD [asmpushvalue.A.+2],HL
	CALL asmpushvalue
	JP asmloop.loop
asmloop.#_OPAND=$
	CALL asmpopvalue
	PUSH HL
	PUSH DE
	CALL asmpopvalue
	POP BC
	LD A,D
	AND B
	LD B,A
	LD A,E
	AND C
	LD C,A
	POP DE
	LD A,H
	AND D
	LD D,A
	LD A,L
	AND E
	LD E,A
	LD [asmpushvalue.A.],BC
	LD [asmpushvalue.A.+2],DE
	CALL asmpushvalue
	JP asmloop.loop
asmloop.#_OPOR=$
	CALL asmpopvalue
	PUSH HL
	PUSH DE
	CALL asmpopvalue
	POP BC
	LD A,D
	OR B
	LD B,A
	LD A,E
	OR C
	LD C,A
	POP DE
	LD A,H
	OR D
	LD D,A
	LD A,L
	OR E
	LD E,A
	LD [asmpushvalue.A.],BC
	LD [asmpushvalue.A.+2],DE
	CALL asmpushvalue
	JP asmloop.loop
asmloop.#_OPXOR=$
	CALL asmpopvalue
	PUSH HL
	PUSH DE
	CALL asmpopvalue
	POP BC
	LD A,D
	XOR B
	LD B,A
	LD A,E
	XOR C
	LD C,A
	POP DE
	LD A,H
	XOR D
	LD D,A
	LD A,L
	XOR E
	LD E,A
	LD [asmpushvalue.A.],BC
	LD [asmpushvalue.A.+2],DE
	CALL asmpushvalue
	JP asmloop.loop
asmloop.#_OPSHL=$
	CALL asmpopvalue
	LD [asmloop.tempvalue],DE
	LD [asmloop.tempvalue+2],HL
	CALL asmpopvalue
	LD BC,[asmloop.tempvalue+2]
	LD IX,[asmloop.tempvalue]
	CALL _SHLLONG.
	LD [asmpushvalue.A.],DE
	LD [asmpushvalue.A.+2],HL
	CALL asmpushvalue
	JP asmloop.loop
asmloop.#_OPSHR=$
	CALL asmpopvalue
	LD [asmloop.tempvalue],DE
	LD [asmloop.tempvalue+2],HL
	CALL asmpopvalue
	LD BC,[asmloop.tempvalue+2]
	LD IX,[asmloop.tempvalue]
	CALL _SHRLONG.
	LD [asmpushvalue.A.],DE
	LD [asmpushvalue.A.+2],HL
	CALL asmpushvalue
	JP asmloop.loop
asmloop.#_OPINV=$
	CALL asmpopvalue
	LD A,D
	CPL
	LD D,A
	LD A,E
	CPL
	LD E,A
	LD A,H
	CPL
	LD H,A
	LD A,L
	CPL
	LD L,A
	LD [asmpushvalue.A.],DE
	LD [asmpushvalue.A.+2],HL
	CALL asmpushvalue
	JP asmloop.loop
asmloop.#_TOKEOL=$
	LD HL,[_curlnbeg]
	INC HL
	LD [_curlnbeg],HL
	JP asmloop.loop
asmloop.#_TOKEOF=$
	LD A,[_ninclfiles]
	SUB 0x00
	JP NZ,asmloop.BS.
	JP asmloop.endloop
	JP asmloop.BT.
asmloop.BS.
	JP asmloop.inclq
asmloop.BT.
asmloop.#_TOKPLUS=$
asmloop.#_TOKMINUS=$
asmloop.#_TOKSTAR=$
asmloop.#_TOKSLASH=$
asmloop.#_TOKLESS=$
asmloop.#_TOKMORE=$
asmloop.#_TOKEQUAL=$
asmloop.#_TOKAND=$
asmloop.#_TOKPIPE=$
asmloop.#_TOKCARON=$
asmloop.#_TOKTILDE=$
asmloop.#_TOKEXCL=$
asmloop.#_TOKPRIMESYM=$
asmloop.#_TOKDBLQUOTESYM=$
asmloop.#_TOKOPEN=$
asmloop.#_TOKOPENSQ=$
asmloop.#_TOKCLOSE=$
asmloop.#_TOKCLOSESQ=$
asmloop.#_TOKCOLON=$
asmloop.#_TOKDIRECT=$
asmloop.#_TOKSPC0=$
asmloop.#_TOKSPC1=$
asmloop.#_TOKSPC2=$
asmloop.#_TOKSPC3=$
asmloop.#_TOKSPC4=$
asmloop.#_TOKSPC5=$
asmloop.#_TOKSPC6=$
asmloop.#_TOKSPC7=$
asmloop.#_TOKSPC8=$
	JP asmloop.loop
asmloop.#_TOKPRIME=$
	CALL readfin
	CALL asmreadprefixed
	LD A,[_prefixedtoken]
	LD L,A
	LD H,0
	LD DE,0
	LD [asmpushvalue.A.],HL
	LD [asmpushvalue.A.+2],DE
	CALL asmpushvalue
	CALL readfin
	CALL readfin
	JP asmloop.loop
asmloop.#_TOKDOLLAR=$
	LD HL,[_curaddr]
	LD DE,[_curshift]
	ADD HL,DE
	LD DE,0
	LD [asmpushvalue.A.],HL
	LD [asmpushvalue.A.+2],DE
	CALL asmpushvalue
	LD A,_ASMLABEL_ISADDR
	LD [_isaddr],A
	JP asmloop.loop
asmloop.#_TOKCOMMENT=$
asmloop.BU.
	CALL readfin
	LD [_token],A
	LD A,[_token]
	SUB _TOKENDCOMMENT
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_waseof]
	OR L
	JP Z,asmloop.BU.
asmloop.BV.
	JP asmloop.loop
asmloop.#_TOKNUM=$
	CALL readfin
	CALL readfin
	LD [_token],A
	LD HL,0L>>16
	LD DE,0L
	LD [asmloop.tempvalue],DE
	LD [asmloop.tempvalue+2],HL
	LD HL,10
	LD [asmloop.scale],HL
	LD A,[_token]
	SUB '0'
	JP NZ,asmloop.BW.
	CALL readfin
	LD [_token],A
	LD A,[_token]
	SUB 'x'
	JP NZ,asmloop.BY.
	LD HL,16
	LD [asmloop.scale],HL
asmloop.rdbase
	LD A,[_token]
	SUB _TOKENDTEXT
	JP Z,asmloop.CA.
	CALL readfin
	LD [_token],A
asmloop.CA.
	JP asmloop.BZ.
asmloop.BY.
	LD A,[_token]
	SUB 'b'
	JP NZ,asmloop.CC.
	LD HL,2
	LD [asmloop.scale],HL
	JP asmloop.rdbase
	JP asmloop.CD.
asmloop.CC.
	LD A,[_token]
	SUB 'o'
	JP NZ,asmloop.CE.
	LD HL,8
	LD [asmloop.scale],HL
	JP asmloop.rdbase
	JP asmloop.CF.
asmloop.CE.
	LD A,[_token]
	SUB 'L'
	JP NZ,asmloop.CG.
	JP asmloop.CH.
asmloop.CG.
	LD A,[_token]
	SUB _TOKENDTEXT
	JP Z,asmloop.CI.
	LD HL,8
	LD [asmloop.scale],HL
	LD HL,asmloop.CK.
	LD [errstr.A.],HL
	CALL errstr
	CALL enderr
asmloop.CI.
asmloop.CH.
asmloop.CF.
asmloop.CD.
asmloop.BZ.
asmloop.BW.
	LD A,[_token]
	SUB _TOKENDTEXT
	JP Z,asmloop.CL.
asmloop.rdnumloop
	LD A,[_token]
	SUB _TOKENDTEXT
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_waseof]
	OR L
	JP Z,asmloop.CN.
	JP asmloop.rdnumend
asmloop.CN.
	LD A,[_token]
	SUB 'L'
	JP Z,asmloop.CP.
	LD A,[_token]
	LD E,'a'
	SUB E
	JP C,asmloop.CR.
	LD A,[_token]
	SUB 0x27
	LD [_token],A
	JP asmloop.CS.
asmloop.CR.
	LD A,[_token]
	LD E,'A'
	SUB E
	JP C,asmloop.CT.
	LD A,[_token]
	SUB 0x07
	LD [_token],A
asmloop.CT.
asmloop.CS.
	LD HL,[asmloop.scale]
	LD DE,0
	LD BC,[asmloop.tempvalue+2]
	LD IX,[asmloop.tempvalue]
	PUSH DE
	PUSH HL
	PUSH BC
	PUSH IX
	POP IX
	POP BC
	POP DE
	POP HL
	CALL _MULLONG.
	LD A,[_token]
	SUB '0'
	LD C,A
	LD B,0
	LD IX,0
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	LD A,L
	ADC A,LX
	LD L,A
	LD A,H
	ADC A,HX
	LD H,A
	LD [asmloop.tempvalue],DE
	LD [asmloop.tempvalue+2],HL
asmloop.CP.
	CALL readfin
	LD [_token],A
	JP asmloop.rdnumloop
asmloop.rdnumend
asmloop.CL.
	LD HL,[asmloop.tempvalue+2]
	LD DE,[asmloop.tempvalue]
	LD [asmpushvalue.A.],DE
	LD [asmpushvalue.A.+2],HL
	CALL asmpushvalue
	JP asmloop.loop
asmloop.#_TOKLABEL=$
	CALL readlabel
	LD HL,[_curlabeltext]
	LD [findlabel.A.],HL
	CALL findlabel
	CALL getlabel
	LD [asmpushvalue.A.],DE
	LD [asmpushvalue.A.+2],HL
	CALL asmpushvalue
	JP asmloop.loop
asmloop.#_ERR=$
	CALL readfin
	LD [_token],A
	LD A,[_token]
	SUB _ERRCMD
	JP NZ,asmloop.CV.
	LD HL,asmloop.CX.
	LD [errstr.A.],HL
	CALL errstr
	JP asmloop.err
	JP asmloop.CW.
asmloop.CV.
	LD A,[_token]
	SUB _ERREXPR
	JP NZ,asmloop.CY.
	LD HL,asmloop.DA.
	LD [errstr.A.],HL
	CALL errstr
	JP asmloop.err
	JP asmloop.CZ.
asmloop.CY.
	LD A,[_token]
	SUB _ERRCOMMA
	JP NZ,asmloop.DB.
	LD HL,asmloop.DD.
	LD [errstr.A.],HL
	CALL errstr
	JP asmloop.err
	JP asmloop.DC.
asmloop.DB.
	LD A,[_token]
	SUB _ERRPAR
	JP NZ,asmloop.DE.
	LD HL,asmloop.DG.
	LD [errstr.A.],HL
	CALL errstr
	JP asmloop.err
	JP asmloop.DF.
asmloop.DE.
	LD A,[_token]
	SUB _ERROPEN
	JP NZ,asmloop.DH.
	LD HL,asmloop.DJ.
	LD [errstr.A.],HL
	CALL errstr
	JP asmloop.err
	JP asmloop.DI.
asmloop.DH.
	LD A,[_token]
	SUB _ERRCLOSE
	JP NZ,asmloop.DK.
	LD HL,asmloop.DM.
	LD [errstr.A.],HL
	CALL errstr
	JP asmloop.err
	JP asmloop.DL.
asmloop.DK.
	LD A,[_token]
	SUB _ERRREG
	JP NZ,asmloop.DN.
	LD HL,asmloop.DP.
	LD [errstr.A.],HL
	CALL errstr
asmloop.err
	CALL asmerrtext
	JP asmloop.loop
asmloop.DN.
asmloop.DL.
asmloop.DI.
asmloop.DF.
asmloop.DC.
asmloop.CZ.
asmloop.CW.
asmloop.#_OPWRSTR=$
	CALL readfin
	LD [_token],A
asmloop.writestringloop
	CALL asmreadprefixed
	LD A,[_token]
	SUB _TOKENDTEXT
	SUB 1
	SBC A,A
	LD L,A
	LD A,[_waseof]
	OR L
	JP Z,asmloop.DQ.
	JP asmloop.loop
asmloop.DQ.
	LD A,[_prefixedtoken]
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.writestringloop
asmloop.#_OPWRVAL=$
	LD A,[_curdir]
	SUB _CMDDB
	JP NZ,asmloop.DS.
	CALL asmbytepopvalue
	JP asmloop.DT.
asmloop.DS.
	LD A,[_curdir]
	SUB _CMDDW
	JP NZ,asmloop.DU.
	CALL asmwordpopvalue
	JP asmloop.DV.
asmloop.DU.
	LD A,[_curdir]
	SUB _CMDDL
	JP NZ,asmloop.DW.
	CALL asmpopvalue
	LD [asmlong.A.],DE
	LD [asmlong.A.+2],HL
	CALL asmlong
asmloop.DW.
asmloop.DV.
asmloop.DT.
	JP asmloop.loop
asmloop.#_TOKCOMMA=$
	LD A,[_reg]
	LD [_oldreg],A
	JP asmloop.loop
asmloop.#_ASMNZ=$
	LD A,[_base2]
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMZ=$
	LD A,[_base2]
	ADD A,0x08
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMNC=$
	LD A,[_base2]
	ADD A,0x10
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMC=$
	LD A,[_base2]
	ADD A,0x18
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMPO=$
	LD A,[_base2]
	ADD A,0x20
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMPE=$
	LD A,[_base2]
	ADD A,0x28
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMP=$
	LD A,[_base2]
	ADD A,0x30
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMM=$
	LD A,[_base2]
	ADD A,0x38
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMEX=$
asmloop.#_ASMLD=$
asmloop.#_ASMRST=$
asmloop.#_ASMIM=$
	LD A,0x00
	LD [_isaddr],A
	JP asmloop.loop
asmloop.#_ASMRET=$
	LD A,0xc9
	LD [_base],A
	LD A,0xc0
	LD [_base2],A
	JP asmloop.loop
asmloop.#_ASMDJNZ=$
	LD A,0x10
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMJR=$
	LD A,0x18
	LD [_base],A
	LD A,0x20
	LD [_base2],A
	JP asmloop.loop
asmloop.#_ASMJP=$
	LD A,0x00
	LD [_isaddr],A
	LD A,0xc3
	LD [_base],A
	LD A,0xc2
	LD [_base2],A
	JP asmloop.loop
asmloop.#_ASMCALL=$
	LD A,0x00
	LD [_isaddr],A
	LD A,0xcd
	LD [_base],A
	LD A,0xc4
	LD [_base2],A
	JP asmloop.loop
asmloop.#_ASMADD=$
	LD A,0x80
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMADC=$
	LD A,0x88
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMSUB=$
	LD A,0x90
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMSBC=$
	LD A,0x98
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMAND=$
	LD A,0xa0
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMXOR=$
	LD A,0xa8
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMOR=$
	LD A,0xb0
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMCP=$
	LD A,0xb8
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMINC=$
	LD A,0x04
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMDEC=$
	LD A,0x05
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMOUT=$
	LD A,0x8d
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMIN=$
	LD A,0x95
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMPOP=$
	LD A,0xc1
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMPUSH=$
	LD A,0xc5
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMRLC=$
	LD A,0x00
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMRRC=$
	LD A,0x08
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMRL=$
	LD A,0x10
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMRR=$
	LD A,0x18
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMSLA=$
	LD A,0x20
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMSRA=$
	LD A,0x28
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMSLI=$
	LD A,0x30
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMSRL=$
	LD A,0x38
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMBIT=$
	LD A,0x40
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMRES=$
	LD A,0x80
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMSET=$
	LD A,0xc0
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMRLCA=$
	LD A,0x07
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMRRCA=$
	LD A,0x0f
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMRLA=$
	LD A,0x17
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMRRA=$
	LD A,0x1f
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMDAA=$
	LD A,0x27
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMCPL=$
	LD A,0x2f
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMSCF=$
	LD A,0x37
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMCCF=$
	LD A,0x3f
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMNOP=$
	LD A,0x00
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMHALT=$
	LD A,0x76
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMDI=$
	LD A,0xf3
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMEI=$
	LD A,0xfb
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMEXX=$
	LD A,0xd9
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMRETN=$
	CALL asmbyte_ed
	LD A,0x45
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMRETI=$
	CALL asmbyte_ed
	LD A,0x4d
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMLDI=$
	CALL asmbyte_ed
	LD A,0xa0
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMLDD=$
	CALL asmbyte_ed
	LD A,0xa8
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMLDIR=$
	CALL asmbyte_ed
	LD A,0xb0
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMLDDR=$
	CALL asmbyte_ed
	LD A,0xb8
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMCPI=$
	CALL asmbyte_ed
	LD A,0xa1
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMCPD=$
	CALL asmbyte_ed
	LD A,0xa9
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMCPIR=$
	CALL asmbyte_ed
	LD A,0xb1
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMCPDR=$
	CALL asmbyte_ed
	LD A,0xb9
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMINI=$
	CALL asmbyte_ed
	LD A,0xa2
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMIND=$
	CALL asmbyte_ed
	LD A,0xaa
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMINIR=$
	CALL asmbyte_ed
	LD A,0xb2
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMINDR=$
	CALL asmbyte_ed
	LD A,0xba
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMOUTI=$
	CALL asmbyte_ed
	LD A,0xa3
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMOUTD=$
	CALL asmbyte_ed
	LD A,0xab
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMOTIR=$
	CALL asmbyte_ed
	LD A,0xb3
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMOTDR=$
	CALL asmbyte_ed
	LD A,0xbb
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMINF=$
	CALL asmbyte_ed
	LD A,0x70
	LD [_base],A
	JP asmloop.loop
asmloop.#_ASMNEG=$
	CALL asmbyte_ed
	LD A,0x44
	LD [_base],A
	JP asmloop.loop
asmloop.#_FMTMOVRBRB=$
	LD A,[_reg]
	LD L,A
	LD A,[_oldreg]
	OR L
	LD E,_ASMRBIXADD
	SUB E
	JP C,asmloop.DY.
	CALL asmrbrb_ixiyprefix
asmloop.DY.
	LD A,[_reg]
	LD E,0x03
	LD L,A
	CALL _SHRB.
	LD A,[_oldreg]
	ADD A,L
	ADD A,0x40
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTMOVAIR=$
	CALL asmbyte_ed
	LD A,[_reg]
	ADD A,0x57
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTMOVIRA=$
	CALL asmbyte_ed
	LD A,[_oldreg]
	ADD A,0x47
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTMOVRPRP=$
	CALL asmcheckrp_ixiyprefix
	LD A,[_oldreg]
	SUB _ASMRPCODE_SP
	JR Z,$+4
	LD A,-1
	LD L,A
	LD A,[_reg]
	SUB _ASMRPCODE_HL
	JR Z,$+4
	LD A,-1
	OR L
	JP Z,asmloop.EA.
	CALL errwrongreg
asmloop.EA.
	LD A,0xf9
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTLDRBN=$
	LD A,[_oldreg]
	LD E,_ASMRBIXADD
	SUB E
	JP C,asmloop.EC.
	CALL asmoldrb_ixiyprefix
asmloop.EC.
	LD A,[_oldreg]
	ADD A,0x06
	LD [asmbyte.A.],A
	CALL asmbyte
	CALL asmbytepopvalue
	JP asmloop.loop
asmloop.#_FMTLDRPNN=$
	CALL asmcheckoldrp_ixiyprefix
	LD A,[_oldreg]
	ADD A,0x01
	LD [asmbyte.A.],A
	CALL asmbyte
	CALL asmwordpopvalue
	JP asmloop.loop
asmloop.#_FMTGETAMRP=$
	CALL asmcheckrp_ixiyprefix
	LD A,[_reg]
	SUB _ASMRPCODE_HL
	JP NZ,asmloop.EE.
	LD A,0x7e
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.EF.
asmloop.EE.
	LD A,[_reg]
	SUB _ASMRPCODE_SP
	JP NZ,asmloop.EG.
	CALL errwrongreg
	JP asmloop.EH.
asmloop.EG.
	LD A,[_reg]
	ADD A,0x0a
	LD [asmbyte.A.],A
	CALL asmbyte
asmloop.EH.
asmloop.EF.
	JP asmloop.loop
asmloop.#_FMTGETAMNN=$
	LD A,0x3a
	LD [asmbyte.A.],A
	CALL asmbyte
	CALL asmwordpopvalue
	JP asmloop.loop
asmloop.#_FMTGETRBMHL=$
	CALL err_oldrbix
	LD A,[_oldreg]
	ADD A,0x46
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTGETRBIDX=$
	CALL err_oldrbix
	CALL asmrp_ixiyprefix
	LD A,[_oldreg]
	ADD A,0x46
	LD [asmbyte.A.],A
	CALL asmbyte
	CALL asmdisppopvalue
	JP asmloop.loop
asmloop.#_FMTGETRPMNN=$
	CALL asmcheckoldrp_ixiyprefix
	LD A,[_oldreg]
	SUB _ASMRPCODE_HL
	JP NZ,asmloop.EI.
	LD A,0x2a
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.EJ.
asmloop.EI.
	CALL asmbyte_ed
	LD A,[_oldreg]
	ADD A,0x4b
	LD [asmbyte.A.],A
	CALL asmbyte
asmloop.EJ.
	CALL asmwordpopvalue
	JP asmloop.loop
asmloop.#_FMTPUTMHLRB=$
	CALL err_rbix
	LD A,[_reg]
	LD E,0x03
	LD L,A
	CALL _SHRB.
	LD A,L
	ADD A,0x70
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTPUTMHLN=$
	LD A,0x36
	LD [asmbyte.A.],A
	CALL asmbyte
	CALL asmbytepopvalue
	JP asmloop.loop
asmloop.#_FMTPUTIDXRB=$
	CALL err_rbix
	CALL asmoldrp_ixiyprefix
	LD A,[_reg]
	LD E,0x03
	LD L,A
	CALL _SHRB.
	LD A,L
	ADD A,0x70
	LD [asmbyte.A.],A
	CALL asmbyte
	CALL asmdisppopvalue
	JP asmloop.loop
asmloop.#_FMTPUTIDXN=$
	CALL asmrp_ixiyprefix
	LD A,0x36
	LD [asmbyte.A.],A
	CALL asmbyte
	CALL asmpopvalue
	LD [asmloop.tempvalue],DE
	LD [asmloop.tempvalue+2],HL
	CALL asmdisppopvalue
	LD HL,[asmloop.tempvalue+2]
	LD DE,[asmloop.tempvalue]
	LD A,E
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTPUTMRPA=$
	CALL asmcheckoldrp_ixiyprefix
	LD A,[_oldreg]
	SUB _ASMRPCODE_HL
	JP NZ,asmloop.EK.
	LD A,0x77
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.EL.
asmloop.EK.
	LD A,[_oldreg]
	SUB _ASMRPCODE_SP
	JP NZ,asmloop.EM.
	CALL errwrongreg
	JP asmloop.EN.
asmloop.EM.
	LD A,[_oldreg]
	ADD A,0x02
	LD [asmbyte.A.],A
	CALL asmbyte
asmloop.EN.
asmloop.EL.
	JP asmloop.loop
asmloop.#_FMTPUTMNNA=$
	LD A,0x32
	LD [asmbyte.A.],A
	CALL asmbyte
	CALL asmwordpopvalue
	JP asmloop.loop
asmloop.#_FMTPUTMNNRP=$
	CALL asmcheckrp_ixiyprefix
	LD A,[_reg]
	SUB _ASMRPCODE_HL
	JP NZ,asmloop.EO.
	LD A,0x22
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.EP.
asmloop.EO.
	CALL asmbyte_ed
	LD A,[_reg]
	ADD A,0x43
	LD [asmbyte.A.],A
	CALL asmbyte
asmloop.EP.
	CALL asmwordpopvalue
	JP asmloop.loop
asmloop.#_FMTALUCMDN=$
	LD A,[_base]
	ADD A,0x46
	LD [asmbyte.A.],A
	CALL asmbyte
	CALL asmbytepopvalue
	JP asmloop.loop
asmloop.#_FMTALUCMDRB=$
	CALL asmcheckrb_ixiyprefix
	LD A,[_reg]
	LD E,0x03
	LD L,A
	CALL _SHRB.
	LD A,[_base]
	ADD A,L
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTALUCMDMHL=$
	LD A,[_base]
	ADD A,0x06
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTALUCMDIDX=$
	CALL asmrp_ixiyprefix
	LD A,[_base]
	ADD A,0x06
	LD [asmbyte.A.],A
	CALL asmbyte
	CALL asmdisppopvalue
	JP asmloop.loop
asmloop.#_FMTADDHLRP=$
	CALL asmrprp_ixiyprefix
	LD A,[_reg]
	ADD A,0x09
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTADCHLRP=$
	CALL err_rpix
	CALL asmbyte_ed
	LD A,[_reg]
	ADD A,0x4a
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTSBCHLRP=$
	CALL err_rpix
	CALL asmbyte_ed
	LD A,[_reg]
	ADD A,0x42
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTINCRP=$
	CALL asmcheckrp_ixiyprefix
	LD A,[_reg]
	ADD A,0x03
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTDECRP=$
	CALL asmcheckrp_ixiyprefix
	LD A,[_reg]
	ADD A,0x0b
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTINCDECRB=$
	CALL asmcheckrb_ixiyprefix
	LD A,[_base]
	LD L,A
	LD A,[_reg]
	ADD A,L
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTINCDECMHL=$
	LD A,[_base]
	ADD A,0x30
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTINCDECIDX=$
	CALL asmrp_ixiyprefix
	LD A,[_base]
	ADD A,0x30
	LD [asmbyte.A.],A
	CALL asmbyte
	CALL asmdisppopvalue
	JP asmloop.loop
asmloop.#_FMTEXRPRP=$
	LD A,[_oldreg]
	SUB _ASMRPCODE_DE
	JP NZ,asmloop.EQ.
	LD A,0xeb
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.ER.
asmloop.EQ.
	LD A,[_reg]
	SUB _ASMRPCODE_AF
	JP NZ,asmloop.ES.
	LD A,0x08
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.ET.
asmloop.ES.
	LD A,[_reg]
	LD E,_ASMRPIXADD
	SUB E
	JP C,asmloop.EU.
	CALL asmrp_ixiyprefix
asmloop.EU.
	LD A,0xe3
	LD [asmbyte.A.],A
	CALL asmbyte
asmloop.ET.
asmloop.ER.
	JP asmloop.loop
asmloop.#_FMTJRDD=$
	LD A,[_base]
	LD [asmbyte.A.],A
	CALL asmbyte
	CALL asmpopvalue
	LD HL,[_curaddr]
	LD BC,[_curshift]
	ADD HL,BC
	LD BC,1
	ADD HL,BC
	LD A,E
	SUB L
	LD E,A
	LD A,D
	SBC A,H
	LD D,A
	LD [asmdisp.A.],DE
	CALL asmdisp
	JP asmloop.loop
asmloop.#_FMTJPNN=$
	LD A,[_base]
	LD [asmbyte.A.],A
	CALL asmbyte
	CALL asmwordpopvalue
	JP asmloop.loop
asmloop.#_FMTJPRP=$
	CALL asmcheckrp_ixiyprefix
	LD A,[_reg]
	SUB _ASMRPCODE_HL
	JP Z,asmloop.EW.
	CALL errwrongreg
asmloop.EW.
	LD A,0xe9
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTPUSHPOPRP=$
	CALL asmcheckrp_ixiyprefix
	LD A,[_base]
	LD L,A
	LD A,[_reg]
	ADD A,L
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTCBCMDRB=$
	CALL err_rbix
	LD A,0xcb
	LD [asmbyte.A.],A
	CALL asmbyte
	LD A,[_reg]
	LD E,0x03
	LD L,A
	CALL _SHRB.
	LD A,[_base]
	ADD A,L
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTCBCMDMHL=$
	LD A,0xcb
	LD [asmbyte.A.],A
	CALL asmbyte
	LD A,[_base]
	ADD A,0x06
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTCBCMDIDX=$
	CALL asmrp_ixiyprefix
	LD A,0xcb
	LD [asmbyte.A.],A
	CALL asmbyte
	CALL asmdisppopvalue
	LD A,[_base]
	ADD A,0x06
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTRST=$
	CALL asmpopvalue
	LD [asmloop.tempvalue],DE
	LD [asmloop.tempvalue+2],HL
	LD HL,[asmloop.tempvalue+2]
	LD DE,[asmloop.tempvalue]
	LD A,E
	ADD A,0xc7
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_OPBIT=$
	CALL asmpopvalue
	LD [asmloop.tempvalue],DE
	LD [asmloop.tempvalue+2],HL
	LD HL,[asmloop.tempvalue+2]
	LD DE,[asmloop.tempvalue]
	LD A,0x07
	AND E
	LD L,0x03
	LD E,A
	PUSH DE
	LD D,H
	LD E,L
	POP HL
	CALL _SHLB.
	LD A,[_base]
	ADD A,L
	LD [_base],A
	JP asmloop.loop
asmloop.#_FMTIM=$
	CALL asmbyte_ed
	CALL asmpopvalue
	LD A,E
	LD [_token],A
	LD A,[_token]
	SUB 0x00
	JP NZ,asmloop.EY.
	LD A,0x46
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.EZ.
asmloop.EY.
	LD A,[_token]
	SUB 0x01
	JP NZ,asmloop.FA.
	LD A,0x56
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.FB.
asmloop.FA.
	LD A,0x5e
	LD [asmbyte.A.],A
	CALL asmbyte
asmloop.FB.
asmloop.EZ.
	JP asmloop.loop
asmloop.#_FMTXX=$
	LD A,[_base]
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTOUTCRB=$
	CALL err_rbix
	CALL asmbyte_ed
	LD A,[_reg]
	ADD A,0x41
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_FMTINRBC=$
	CALL err_oldrbix
	CALL asmbyte_ed
	LD A,[_oldreg]
	ADD A,0x40
	LD [asmbyte.A.],A
	CALL asmbyte
	JP asmloop.loop
asmloop.#_RG_B=$
	LD A,_ASMRBCODE_B
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_C=$
	LD A,_ASMRBCODE_C
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_D=$
	LD A,_ASMRBCODE_D
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_E=$
	LD A,_ASMRBCODE_E
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_H=$
	LD A,_ASMRBCODE_H
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_L=$
	LD A,_ASMRBCODE_L
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_A=$
	LD A,_ASMRBCODE_A
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_HX=$
	LD A,_ASMRBCODE_HX
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_LX=$
	LD A,_ASMRBCODE_LX
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_HY=$
	LD A,_ASMRBCODE_HY
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_LY=$
	LD A,_ASMRBCODE_LY
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_I=$
	LD A,_ASMRBCODE_I
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_R=$
	LD A,_ASMRBCODE_R
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_BC=$
	LD A,_ASMRPCODE_BC
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_DE=$
	LD A,_ASMRPCODE_DE
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_HL=$
	LD A,_ASMRPCODE_HL
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_SP=$
	LD A,_ASMRPCODE_SP
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_AF=$
	LD A,_ASMRPCODE_AF
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_IX=$
	LD A,_ASMRPCODE_IX
	LD [_reg],A
	JP asmloop.loop
asmloop.#_RG_IY=$
	LD A,_ASMRPCODE_IY
	LD [_reg],A
	JP asmloop.loop
asmloop.default
	LD A,[_token]
	LD [err.A.],A
	CALL err
	CALL enderr
	JP asmloop.loop
asmloop.A.
asmloop.endloop
	RET
