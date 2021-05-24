;ª®¤¨ΰ®Άª  866
;®―®§­ ρβαο ­¥―ΰ Ά¨«μ­®
;―®νβ®¬γ ­ ―¨θ¥¬ ¬­®£® β¥ªαβ  ª¨ΰ¨««¨ζ¥©
;LAST UPDATE: 30.06.2019 savelij

;€„…‘ –‹€ ™… ‘ ‘…
COMINT_		EQU 0X026E

_DEV_READ=2
_DEV_WRITE=3

P_DATA          EQU 0X57
P_CONF          EQU 0X77

CMD_09          EQU 0X49        ;SEND_CSD
CMD_12          EQU 0X4C        ;STOP_TRANSMISSION
CMD_17          EQU 0X51        ;READ_SINGLE_BLOCK
CMD_18          EQU 0X52        ;READ_MULTIPLE_BLOCK
CMD_24          EQU 0X58        ;WRITE_BLOCK
CMD_25          EQU 0X59        ;WRITE_MULTIPLE_BLOCK
CMD_55          EQU 0X77        ;APP_CMD
CMD_58          EQU 0X7A        ;READ_OCR
CMD_59          EQU 0X7B        ;CRC_ON_OFF
ACMD_41         EQU 0X69        ;SD_SEND_OP_COND

;€„…‘ “‘’€‚™€ „€‰‚…€ € NeoGS
SETUPSD		EQU 0X5B00

;„€‰‚… SD-CARD „‹ NGS

;‚•„›… €€…’› ™…:
;HL-€„…‘ ‡€ƒ“‡ ‚ €’
;BCDE-32-• ’›‰ … ‘…’€
;A-‹—…‘’‚ ‹‚ (‹=512 €‰’)
;’‹ „‹ ƒ‹—‰ ‡€‘/—’…

; ‚›„€‚€…›… € ‚›•„…:
;A=0-–€‹‡€– ‹€ “‘…
;A=1-€’€ … €‰„…€ ‹ … ’‚…’‹€

;‡€‘ "A" ‘…’‚
;SDWRMUL		EX AF,AF'
writesectorsGS
		LD A,_DEV_WRITE
		CALL COMM2SD
		EX AF,AF'
		PUSH DE
		PUSH BC
		LD BC,GSDAT
SDWRSN1		EX AF,AF'
		OUT (GSCOM),A
		CALL WC_
		LD DE,0X0200
SDWRSN2		OUTI
		CALL WD_
		DEC DE
		LD A,D
		OR E
		JR NZ,SDWRSN2
		EX AF,AF'
		DEC A
		JR NZ,SDWRSN1
		CALL WN_
		IN A,(GSDAT)
		;CP 0X99				;€’€ ’…‹€‘  ‚… —’…/‡€‘
		;JP Z,SD_CARD_LOST
		POP BC
		POP DE
		XOR A
		RET

;—’…… "A" ‘…’‚
;SDRDMUL		EX AF,AF'
readsectorsGS
		LD A,_DEV_READ
		CALL COMM2SD
		EX AF,AF'
		PUSH DE
		PUSH BC
		;LD D,A
		;LD A,IYL
		;BIT 1,A
		;JR NZ,SDRDSN3
		;AND A
		;JR NZ,SDRDSN5
;SDRDSN3		
;		LD A,(R_7FFD)
		;READ_7FFD
		;AND 0X10
		;LD BC,(B0_CPU2)
		;JR Z,SDRDSN4
		;LD BC,(B1_CPU2)
;SDRDSN4
                ;LD A,0X37
		;OR B
		;LD B,A
		;LD A,C
		;LD C,LOW (WIN_A0)
		;OUT (C),A
;SDRDSN5
		;LD A,D
		LD BC,GSDAT
SDRDSN1		EX AF,AF'
		OUT (GSCOM),A	;FC
		IN A,(GSCOM)
		RRA
		JR C,$-3
		LD DE,0X0200			;„‹†€… …‘‹ ‚‘… ‚ „…
SDRDSN2		IN A,(GSCOM)
		RLA
		JR NC,$-3
		INI
		DEC DE
		LD A,D
		OR E
		JR NZ,SDRDSN2
		EX AF,AF'
		DEC A
		JR NZ,SDRDSN1
		IN A,(GSCOM)
		RLA
		JR NC,$-3
		IN A,(GSDAT)
		CP 0X99				;€’€ ’…‹€‘  ‚… —’…/‡€‘
		;JP Z,SD_CARD_LOST
		;LD BC,WIN_P6
		XOR A
		;OUT (C),A
		POP BC
		POP DE
		RET
GS_INIT
		XOR A
		OUT (GSDAT),A
		LD A,0X1D
		OUT (GSCOM),A
		IN A,(GSCOM)
		RRA
		JR C,$-3
		IN A,(GSDAT)
		LD D,A
		AND 0X0F
		LD E,A
		LD A,D
		AND 0XF0
		RRCA
		RRCA
		RRCA
		RRCA
		CP E
		;LD A,1
		;JR NZ,GSDINIT1
		CALL INSTSDD

;–€‹‡€– €’—
GSDINIT		XOR A
GSDINIT1	CALL COMM2SD
		CALL WN_
GSDINIT2	IN A,(GSDAT)
GSDINIT3	;CP 0X99				;€’€ ’…‹€‘  ‚… —’…/‡€‘
		;JP Z,SD_CARD_LOST
		CP 0X77
		JR NZ,SD_NO
		XOR A
		RET

SD_NO		LD A,1
		RET

;……„€’— €„/€€…’‚ ‚ „€‰‚… € NeoGS
COMM2SD		OUT (GSDAT),A		;“‹€ €„€ „€‰‚…“
		LD A,0X1E
		OUT (GSCOM),A
		CALL WC_		;“‹€ €„€ ‚…
		LD A,B
		OUT (GSDAT),A
		CALL WD_		;“‹ ’› 31-24 €€…’‚ ;savelij13: βγβ Ά¨α­¥β
		LD A,C
		OUT (GSDAT),A
		CALL WD_		;“‹ ’› 23-16 €€…’‚
		LD A,D
		OUT (GSDAT),A
		CALL WD_		;“‹ ’› 15-8 €€…’‚
		LD A,E
		OUT (GSDAT),A
		CALL WD_		;“‹ ’› 7-0 €€…’‚
		EX AF,AF'
		OUT (GSDAT),A
		EX AF,AF'
		ds 9,0
		RET			;“‹ ‹-‚ ‘…’‚

;†„€… ƒ„€ NeoGS €‰’ ‡€……’
WD_		IN A,(GSCOM)
		RLA
		JR C,$-3
		RET

;†„€… ƒ„€ NeoGS „€‘’ €‰’
WN_		IN A,(GSCOM)
		RLA
		JR NC,$-3
		RET

;†„€… ƒ„€ NeoGS €„“ ‡€……’
WC_		IN A,(GSCOM)
		RRA
		JR C,$-3
		RET

;“‘’€‚™ „€‰‚…€ € NeoGS
INSTSDD		LD A,0X80
		OUT (GSCTR),A			;‹›‰ ‘‘ NEOGS
		;EI
		HALT
		;EI
		HALT
		;EI
		HALT
		;DI
		LD A,0XF3
		OUT (GSCOM),A
		LD B,0X30
ISDD1		;EI
		HALT
		;DI
		DEC B
		JR Z,SD_NO
		IN A,(GSCOM)
		RRA
		JR C,ISDD1
		LD BC,GSDAT
		IN A,(C)
		LD DE,0X0300
		LD HL,SETUPSD
		OUT (C),E
		LD A,0X14
		OUT (GSCOM),A
		CALL WC_
		OUT (C),D
		CALL WD_
		OUT (C),L
		CALL WD_
		OUT (C),H
		CALL WD_
		LD HL,UKLAD1
ISDD3		OUTI
		CALL WD_
		DEC DE
		LD A,D
		OR E
		JR NZ,ISDD3
		LD HL,SETUPSD
		OUT (C),L
		LD A,0X13
		OUT (GSCOM),A
		CALL WC_
		OUT (C),H
		;EI
		HALT
		;EI
		HALT
		;DI
		LD B,3
		IN A,(GSDAT)
		DEC B
		JP Z,SD_NO
		CP 0X77
		JP NZ,SD_NO
		XOR A
		RET

UKLAD1	;’“„€ „ € ƒ‘ ‡€„›‚€’
	incbin "ngssd.bin"