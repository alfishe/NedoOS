        DEVICE ZXSPECTRUM48
        include "../_sdk/sys_h.asm"
                ORG 0x4000

s98_begin:
	include "S98.ini"

load_s98_file_number_haddr = 0x80
s98_file00_pages_list = 0x8000
current_ram_page = 0x8200


	macro TC tacts
		
tact_count = (tact_count + (tacts))

	endm

s98_header = $C000
module = $C000

START
        	LD HL,module;MDLADDR ;DE - address of 2nd module for TS
        	JR INIT
        	JP PLAY
        	JP MUTE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT:
;------ tsfm_init
	xor a
	ld (cha_vol_orig),a
	ld (chb_vol_orig),a
	ld (chc_vol_orig),a
	
	ld a,$7F
	ld b,24
	ld hl,TL_ch1_op1_ym1_orig
1	ld (hl),a
	inc hl
	djnz 1b
	
	call ym_reset
;------- s98 init
        	xor a; ld a,$00			;nop	;play unlock
        	ld (s98_player_play_var),a



;DATA offset

			ld a,(s98_header+$14)
			ld l,a
			ld a,(s98_header+$15)
			or %11000000
			ld h,a
		
			ld a,(s98_header+$15)	;1100 0000
			rlca			;1000 0001
			rlca			;0000 0011
			and %00000011
			
			ld b,a
			ld a,(s98_header+$16)	;0000 1111
			add a			;0001 1110
			add a			;0011 1100
			or b

			ld (current_ram_page),a                        ;;///// возможно после инициализации нужна будет совсем другая страница, а не 0
			
			ld (player_reg_DE),hl
;LOOP offset

							;вынести в отдельную процедуру
			ld a,(s98_header+$18)		;(de) > a hl
			ld l,a
			ld a,(s98_header+$19)
			or %11000000
			ld h,a
		
			ld a,(s98_header+$19)	;1100 0000
			rlca			;1000 0001
			rlca			;0000 0011
			and %00000011
			
			ld b,a
			ld a,(s98_header+$1A)	;0000 1111
			add a			;0001 1110
			add a			;0011 1100
			or b


			ld (loop_ram_page),a
			ld (loop_addr),hl


			ld hl,(s98_header+$18)
			ld a,h : or l
			ld hl,(s98_header+$1A)
			or h : or l
			
			ld a,$37			;scf	;$37
			jr nz,enable_loop
disable_loop		ld a,$A7			;and a	;$A7
enable_loop			
			ld (enable_loop_var),a		;
			
			


			ld hl,3277
			ld a,(s98_header+$04)
			dec a;cp 1
			jr z,1f
			ld hl,32768
1			ld (sync_frq),hl
                        ret
;;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;==============================================================================
;==============================================================================

 if ay_mute = 0
	defarray  OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1_ssg	;00	SSG
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1_ssg	;01	SSG
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1_ssg	;02	SSG
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1_ssg	;03	SSG
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1_ssg	;04	SSG
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1_ssg	;05 	SSG
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1_ssg	;06 	SSG
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1_ssg	;07 	SSG
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_r08_SSG_vol_cha		;08 	SSG vol cha
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_r09_SSG_vol_chb		;09 	SSG vol chb
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_r0A_SSG_vol_chc		;0A 	SSG vol chc
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_r0B_SSG_en_low		;0B 	SSG
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_r0C_SSG_en_high		;0C 	SSG
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_r0D_SSG_en_shape		;0D 	SSG
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc			;0E	SSG IO
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc			;0F	SSG IO
 else
	defarray  OPNA_YM2608_00_regs OPNA_YM2608_00_undoc
		dup 15
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc
		edup

 endif

	dup 16
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_r1x_rhythm_undoc
	edup

 if YM_Type = 1	;2203
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;20
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;21 LSI TEST DATA
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;22 LFO		2203 NOT HAVE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;23
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;24 TIMER
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;25 TIMER
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;26 TIMER
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;27 TIMER
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_r28_key_on_off	;28 KEY ON OFF
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;29 IRQ ENABLE	????
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;2A
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;2B
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;2C
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_r2D_prescaler	;2D PRESCALER
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_r2E_prescaler	;2E PRESCALER
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_r2F_prescaler	;2F PRESCALER
	
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;30 DETUNE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;31 DETUNE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;32 DETUNE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;33
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;34 DETUNE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;35 DETUNE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;36 DETUNE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;37
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;38 DETUNE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;39 DETUNE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;3A DETUNE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;3B
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;3C DETUNE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;3D DETUNE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;3E DETUNE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;3F
	
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_TL_ch1_op1_ym1	;40 TOTAL LEVEL
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_TL_ch2_op1_ym1	;41 TOTAL LEVEL
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_TL_ch3_op1_ym1	;42 TOTAL LEVEL
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;43
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_TL_ch1_op2_ym1	;44 TOTAL LEVEL
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_TL_ch2_op2_ym1	;45 TOTAL LEVEL
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_TL_ch3_op2_ym1	;46 TOTAL LEVEL
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;47
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_TL_ch1_op3_ym1	;48 TOTAL LEVEL
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_TL_ch2_op3_ym1	;49 TOTAL LEVEL
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_TL_ch3_op3_ym1	;4A TOTAL LEVEL
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;4B
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_TL_ch1_op4_ym1	;4C TOTAL LEVEL
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_TL_ch2_op4_ym1	;4D TOTAL LEVEL
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_TL_ch3_op4_ym1	;4E TOTAL LEVEL
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;4F
	
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;50 ATTACK RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;51 ATTACK RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;52 ATTACK RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;53
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;54 ATTACK RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;55 ATTACK RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;56 ATTACK RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;57
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;58 ATTACK RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;59 ATTACK RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;5A ATTACK RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;5B
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;5C ATTACK RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;5D ATTACK RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;5E ATTACK RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;5F
	
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;60 DECAY RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;61 DECAY RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;62 DECAY RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;63
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;64 DECAY RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;65 DECAY RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;66 DECAY RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;67
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;68 DECAY RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;69 DECAY RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;6A DECAY RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;6B
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;6C DECAY RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;6D DECAY RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;6E DECAY RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;6F
	
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;70 SUSTAIN RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;71 SUSTAIN RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;72 SUSTAIN RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;73
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;74 SUSTAIN RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;75 SUSTAIN RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;76 SUSTAIN RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;77
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;78 SUSTAIN RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;79 SUSTAIN RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;7A SUSTAIN RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;7B
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;7C SUSTAIN RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;7D SUSTAIN RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;7E SUSTAIN RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;7F
	
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;80 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;81 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;82 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;83
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;84 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;85 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;86 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;87
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;88 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;89 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;8A SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;8B
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;8C SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;8D SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;8E SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;8F

	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;90 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;91 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;92 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;93
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;94 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;95 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;96 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;97
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;98 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;99 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;9A SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;9B
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;9C SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;9D SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;9E SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;9F
	
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;A0 F NUM
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;A1 F NUM
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;A2 F NUM
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;A3
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;A4 BLOCK \ F NUM 2
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;A5 BLOCK \ F NUM 2
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;A6 BLOCK \ F NUM 2
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;A7
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;A8 3CH F NUM
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;A9 3CH F NUM
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;AA 3CH F NUM
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;AB
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;AC 3CH BLOCK \ F NUM 2
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;AD 3CH BLOCK \ F NUM 2
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;AE 3CH BLOCK \ F NUM 2
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;AF
	
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;B0 FEEDBACK \ CONNECTION
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;B1 FEEDBACK \ CONNECTION
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_simple_write_2_ym1	;B2 FEEDBACK \ CONNECTION
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;B3
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;B4 PMS AMS LR
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;B5 PMS AMS LR
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;B6 PMS AMS LR
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;B7
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;B8
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;B9
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;BA
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;BB
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;BC
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;BD
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;BE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc		;BF
	
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;C0
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;C1
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;C2
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;C3
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;C4
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;C5
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;C6
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;C7
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;C8
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;C9
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;CA
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;CB
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;CC
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;CD
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;CE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;CF

	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;D0
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;D1
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;D2
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;D3
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;D4
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;D5
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;D6
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;D7
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;D8
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;D9
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;DA
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;DB
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;DC
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;DD
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;DE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;DF
	
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;E0
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;E1
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;E2
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;E3
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;E4
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;E5
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;E6
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;E7
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;E8
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;E9
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;EA
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;EB
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;EC
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;ED
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;EE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;EF
	
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;F0
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;F1
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;F2
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;F3
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;F4
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;F5
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;F6
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;F7
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;F8
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;F9
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;FA
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;FB
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;FC
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;FD
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;FE
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc	;FF
 endif
 
 if YM_Type = 2
	dup 256-32
	defarray+ OPNA_YM2608_00_regs OPNA_YM2608_00_undoc
	edup
 endif
;============================================================================== 
 
 
 
;==============================================================================
	defarray  OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;00	ADPCM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;01	ADPCM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;02	ADPCM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;03	ADPCM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;04	ADPCM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;05 	ADPCM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;06 	ADPCM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;07 	ADPCM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;08 	ADPCM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;09 	ADPCM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;0A 	ADPCM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;0B 	ADPCM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;0C 	ADPCM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;0D 	ADPCM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;0E	ADPCM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;0F	ADPCM

 if YM_Type = 1	;2203
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;10	
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;11
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;12
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;13
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;14
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;15
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;16
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;17
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;18
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;19
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;1A
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;1B
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;1C
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;1D
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;1E
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;1F
	
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;20
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;21
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;22
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;23
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;24
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;25
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;26
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;27
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;28
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;29
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;2A
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;2B
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;2C
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;2D
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;2E
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;2F
	
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;30 DETUNE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;31 DETUNE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;32 DETUNE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;33
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;34 DETUNE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;35 DETUNE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;36 DETUNE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;37
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;38 DETUNE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;39 DETUNE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;3A DETUNE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;3B
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;3C DETUNE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;3D DETUNE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;3E DETUNE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;3F
	
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_TL_ch1_op1_ym2	;40 TOTAL LEVEL
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_TL_ch2_op1_ym2	;41 TOTAL LEVEL
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_TL_ch3_op1_ym2	;42 TOTAL LEVEL
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_00_undoc		;43
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_TL_ch1_op2_ym2	;44 TOTAL LEVEL
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_TL_ch2_op2_ym2	;45 TOTAL LEVEL
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_TL_ch3_op2_ym2	;46 TOTAL LEVEL
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_00_undoc		;47
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_TL_ch1_op3_ym2	;48 TOTAL LEVEL
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_TL_ch2_op3_ym2	;49 TOTAL LEVEL
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_TL_ch3_op3_ym2	;4A TOTAL LEVEL
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_00_undoc		;4B
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_TL_ch1_op4_ym2	;4C TOTAL LEVEL
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_TL_ch2_op4_ym2	;4D TOTAL LEVEL
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_TL_ch3_op4_ym2	;4E TOTAL LEVEL
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;4F
	
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;50 ATTACK RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;51 ATTACK RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;52 ATTACK RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;53
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;54 ATTACK RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;55 ATTACK RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;56 ATTACK RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;57
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;58 ATTACK RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;59 ATTACK RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;5A ATTACK RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;5B
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;5C ATTACK RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;5D ATTACK RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;5E ATTACK RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;5F
	
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;60 DECAY RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;61 DECAY RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;62 DECAY RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;63
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;64 DECAY RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;65 DECAY RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;66 DECAY RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;67
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;68 DECAY RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;69 DECAY RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;6A DECAY RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;6B
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;6C DECAY RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;6D DECAY RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;6E DECAY RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;6F
	
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;70 SUSTAIN RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;71 SUSTAIN RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;72 SUSTAIN RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;73
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;74 SUSTAIN RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;75 SUSTAIN RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;76 SUSTAIN RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;77
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;78 SUSTAIN RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;79 SUSTAIN RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;7A SUSTAIN RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;7B
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;7C SUSTAIN RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;7D SUSTAIN RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;7E SUSTAIN RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;7F
	
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;80 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;81 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;82 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;83
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;84 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;85 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;86 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;87
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;88 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;89 SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;8A SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;8B
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;8C SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;8D SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;8E SUSTAIN LEVEL \ RELEASE RATE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;8F
	
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;90 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;91 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;92 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;93
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;94 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;95 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;96 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;97
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;98 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;99 SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;9A SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;9B
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;9C SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;9D SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;9E SSG TYPE ENVELOPE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;9F
	
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;A0 F NUM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;A1 F NUM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;A2 F NUM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;A3
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;A4 BLOCK \ F NUM 2
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;A5 BLOCK \ F NUM 2
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;A6 BLOCK \ F NUM 2
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;A7
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;A8 3CH F NUM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;A9 3CH F NUM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;AA 3CH F NUM
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;AB
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;AC 3CH BLOCK \ F NUM 2
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;AD 3CH BLOCK \ F NUM 2
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;AE 3CH BLOCK \ F NUM 2
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;AF
	
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;B0 FEEDBACK \ CONNECTION
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;B1 FEEDBACK \ CONNECTION
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_simple_write_2_ym2	;B2 FEEDBACK \ CONNECTION
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;B3
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;B4 PMS AMS LR
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;B5 PMS AMS LR
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;B6 PMS AMS LR
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;B7
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;B8
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;B9
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;BA
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;BB
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;BC
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;BD
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;BE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc		;BF
	
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;C0
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;C1
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;C2
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;C3
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;C4
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;C5
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;C6
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;C7
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;C8
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;C9
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;CA
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;CB
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;CC
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;CD
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;CE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;CF

	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;D0
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;D1
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;D2
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;D3
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;D4
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;D5
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;D6
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;D7
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;D8
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;D9
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;DA
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;DB
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;DC
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;DD
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;DE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;DF
	
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;E0
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;E1
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;E2
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;E3
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;E4
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;E5
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;E6
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;E7
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;E8
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;E9
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;EA
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;EB
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;EC
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;ED
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;EE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;EF
	
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;F0
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;F1
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;F2
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;F3
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;F4
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;F5
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;F6
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;F7
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;F8
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;F9
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;FA
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;FB
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;FC
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;FD
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;FE
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc	;FF
 endif

 if YM_Type = 2
	dup 256-16
	defarray+ OPNA_YM2608_01_regs OPNA_YM2608_01_undoc
	edup
 endif

;==============================================================================



;==============================================================================
								align 256
;------------------------------------------------------------------------------
OPNA_YM2608_00_decode_table
OPNA_YM2608_00_decode_table_haddr = high $ 

tab_temp_cnt = 0
		dup 256
			defb low (OPNA_YM2608_00_regs[tab_temp_cnt])
tab_temp_cnt = tab_temp_cnt + 1
		edup
tab_temp_cnt = 0
		dup 256
			defb high (OPNA_YM2608_00_regs[tab_temp_cnt])
tab_temp_cnt = tab_temp_cnt + 1
		edup

;==============================================================================
								align 256
;------------------------------------------------------------------------------
OPNA_YM2608_01_decode_table
OPNA_YM2608_01_decode_table_haddr = high $ 

tab_temp_cnt = 0
		dup 256
			defb low (OPNA_YM2608_01_regs[tab_temp_cnt])
tab_temp_cnt = tab_temp_cnt + 1
		edup
tab_temp_cnt = 0
		dup 256
			defb high (OPNA_YM2608_01_regs[tab_temp_cnt])
tab_temp_cnt = tab_temp_cnt + 1
		edup
		
;==============================================================================



			
;==============================================================================
/*
								align 256
;------------------------------------------------------------------------------
s98_file00_pages_list
s98_file00_pages_list_haddr = high $
	dup 256
	defb $00
	edup
s98_file01_pages_list
s98_file01_pages_list_haddr = high $
	dup 256
	defb $00
	edup
s98_file02_pages_list
s98_file02_pages_list_haddr = high $
	dup 256
	defb $00
	edup
s98_file03_pages_list
s98_file03_pages_list_haddr = high $
	dup 256
	defb $00
	edup
*/
;==============================================================================





MUTE:
			ld a,$C9			;ret	;stop playing
			ld (s98_player_play_var),a

                	xor a
                	ld (cha_vol_orig),a
                	ld (chb_vol_orig),a
                	ld (chc_vol_orig),a

			call ym_reset
			call ym_off
			ret
			


ym_reset
        
;rhythm_mute
			;xor a
			;ld (rhythm_voldown),a	;out off
	
	ld a,%11111001	;chip2
	ld bc,sFFFD
	out (c),a

	call ym_reset_1
	
	ld a,%11111000	;chip1
	ld b,sFF
	out (c),a
	
	call ym_reset_1
	
	ret

ym_reset_1
	
	
		ld a,$0D	;a start reg	0D...00		SSG
		ld hl,$00FF	;h 00 reset
				;l last reg-1
		call ym_reset_loop
		
		ld a,$B3	;		B3...50		FM
		ld l,$4F	;
		call ym_reset_loop
		
		ld a,$3F	;		3F...30		DETUNE MUL
		ld l,$2F	;
		call ym_reset_loop
		
		ld a,$07	;a reg		07		SSG MIXER
		ld h,$F8	;h F8 reset
		call ym_reset_write	
		
		ld a,$8F	;a start reg	8F...80		SUSTAIN RELEASE
		ld hl,$0F7F	;h 0F reset
		;		;l last reg-1
		call ym_reset_loop
	
	
		ld a,$28	;a start reg	28		KEY OFF CH1
		ld h,$00	;h 00 reset
		call ym_reset_write
		
		;ld a,$28	;a start reg	28		KEY OFF CH2
		ld hl,$01	;h 00 reset
		call ym_reset_write
		
		;ld a,$28	;a start reg	28		KEY OFF CH3
		ld hl,$02	;h 00 reset
		call ym_reset_write		
	
		ld a,$27	;a start reg	27		TIMER
		ld hl,$02	;h 00 reset
		call ym_reset_write		


		ld a,$4F	;a start reg	4F...40		TOTAL LEVEL
		ld hl,$7F3F	;h 00 reset
		;		;l last reg-1
		call ym_reset_loop		
	
	

		ld a,$2F	;a start reg	2F		PRESCALER
		ld h,$7F	;h 00 reset
		call ym_reset_write	
		

		ld a,$2D	;a start reg	2D		PRESCALER
		ld hl,$7F	;h 00 reset
		call ym_reset_write	
	
		ret					
		
;------------------------------------------------------------------------------
ym_reset_loop
		call ym_reset_write
		dec a
		cp l
		jr nz,ym_reset_loop	;if =>
		ret
		
;------------------------------------------------------------------------------	
ym_reset_write
			ld bc,sFFFD
2				
                                nop
                                nop
                                in f,(c)
				jp m,2B
			out (c),a
			
2				
                                nop
                                nop
                                in f,(c)
				jp m,2B
			ld b,sBF		;FD
			out (c),h
			ret
					
;------------------------------------------------------------------------------
ym_off
	ld a,%11111111	;ym off
	ld bc,sFFFD
	out (c),a
	ret


command_FD				;loop

enable_loop_var = $ :	scf

			jp nc,player_exit

loop_enabled


loop_ram_page = $+1 :	ld a,$00
			call mount_ram_a
			
loop_addr = $+1 :	ld de,$C080		
			
			jp (ix)
;==============================================================================
player_exit
			ld a,$C9			;ret	;stop playing
			ld (s98_player_play_var),a

			call ym_reset

			call ym_off

			ret

;==============================================================================
command_FE

		ld a,(de)
		
		inc a
		inc a

		inc e
		call z,inc_d_paging

		ld hl,(sync_cnt)
		ld bc,(sync_frq)
sync_FE_loop	add hl,bc
				;call c,player_frame_complete
				jp c,player_frame_complete_when_FE
sync_FE_loop_continue
		dec a
		jp nz,sync_FE_loop
		ld (sync_cnt),hl	
		
		jp (ix)


;==============================================================================


;==============================================================================
command_FF
;sync
		
sync_cnt = $+1 :	ld hl,$0000
sync_frq = $+1 :	ld bc,3277	;3277	;3276,8		;$8000		;
			add hl,bc
			ld (sync_cnt),hl

			;call c,player_frame_complete
			jp c,player_frame_complete
	
sync_FF_skip
		jp (ix)

;==============================================================================








;==============================================================================
;OPNA_YM2608
;==============================================================================

OPNA_YM2608_00_decoder	;первая половина чипа

		ld a,(de)				;7
		inc e					;4
		
		ld l,a					;4
		ld h,OPNA_YM2608_00_decode_table_haddr	;7
		ld b,(hl)				;7
	
		jr z,OPNA_YM2608_00_decoding_inc_de	;7\12	
		
		inc h
		ld h,(hl)
		ld l,b
		
		jp (hl)					;10
		;
OPNA_YM2608_00_decoding_inc_de
		inc d					;4
		call z,next_ram_page

		inc h
		ld h,(hl)
		ld l,b
		
		jp (hl)					;10					

;==============================================================================					

OPNA_YM2608_01_decoder	;вторая половина чипа

		ld a,(de)				;7
		inc e					;4
		
		ld l,a					;4
		ld h,OPNA_YM2608_01_decode_table_haddr	;7
		ld b,(hl)				;7
	
		jr z,OPNA_YM2608_01_decoding_inc_de	;7\12	
		
		inc h
		ld h,(hl)
		ld l,b
		
		jp (hl)					;10
		;
OPNA_YM2608_01_decoding_inc_de
		inc d					;4
		call z,next_ram_page

		inc h
		ld h,(hl)
		ld l,b
		
		jp (hl)					;10	

;==============================================================================












;==============================================================================
OPNA_YM2608_00_r1x_rhythm_undoc
;	ld a,5
;	out ($FE),a
	;dup 20
	;halt
	;edup
		inc e
		call z,inc_d_paging
		
		jp (ix)
;==============================================================================

;==============================================================================
OPNA_YM2608_00_undoc
OPNA_YM2608_01_undoc

		inc e
		call z,inc_d_paging
		
		jp (ix)
;==============================================================================
OPNA_YM2608_simple_write_2_ym1

	ld h,%11111000	;chip1
	ld bc,sFFFD
	out (c),h
	
;	ld bc,sFFFD			;SSG 00
2	
        nop
        nop
        in f,(c)
	jp m,2B
	
	out (c),a

		ld a,(de)			
		inc e
		call z,inc_d_paging	;там свой push bc !!!

2	
        nop
        nop; ;DimkaM
        in f,(c)
	jp m,2B
	
	ld b,sBF	;FD
	out (c),a

	jp (ix)

;==============================================================================
OPNA_YM2608_simple_write_2_ym1_ssg

	ld h,%11111000	;chip1
	ld bc,sFFFD
	out (c),h
	
;	ld bc,sFFFD			;SSG 00
2	
        nop
        nop
        in f,(c)
	jp m,2B
	
	out (c),a

		ld a,(de)			
		inc e
		call z,inc_d_paging	;там свой push bc !!!

 if wait_2203_sgg_2 = 1
2	
        nop
        nop
        in f,(c)
	jp m,2B
 endif
	
	ld b,sBF	;FD
	out (c),a

	jp (ix)

;==============================================================================

;==============================================================================
OPNA_YM2608_simple_write_2_ym2

	ld h,%11111001	;chip2
	ld bc,sFFFD
	out (c),h
	
2	
        nop
        nop
        in f,(c)
	jp m,2B
	
	out (c),a

		ld a,(de)			
		inc e
		call z,inc_d_paging
		
2	
        nop
        nop
        in f,(c)
	jp m,2B
	
	ld b,sBF
	out (c),a

	jp (ix)

;==============================================================================





;==============================================================================
OPNA_YM2608_00_r08_SSG_vol_cha
	ld h,%11111000	;chip1				;SSG vol A
	ld bc,sFFFD
	out (c),h					;r08
	
2	
        nop
        nop
        in f,(c)
	jp m,2B
	
	out (c),a

		ld a,(de)			
		inc e
		call z,inc_d_paging
;en_chk
	bit 4,a
	jp nz,cha_en_on
			
		ld h,a
		and %00001111
		sub ay_vol_down
		jr nc,1F
		xor a
1
		ld l,a
		ld a,h
		and %11110000
		or l
	
			ld (cha_vol_orig),a
cha_vol_cntrl = $+1 :	sub $00
			jr nc,1F
			xor a
1	

 if wait_2203_sgg_2 = 1
2	
        nop
        nop
        in f,(c)
	jp m,2B
 endif
	
	ld b,sBF	;FD
	out (c),a
			ld hl,$0018		;18 00 jr
			;ld (cha_en_var),hl	;
						;запрет вывода громкости огибающей



	jp (ix)
	

;==============================================================================
cha_en_on
			ld hl,$79ED		;ED 79 out (c),a
			;ld (cha_en_var),hl	;	
						;разрешение вывода громкости огибающей

; ld a,1
; out ($FE),a
;	dup 50
;	halt
;	edup

	jp (ix)				
				
;==============================================================================

;==============================================================================
OPNA_YM2608_00_r09_SSG_vol_chb
	ld h,%11111000	;chip1				;SSG vol B
	ld bc,sFFFD
	out (c),h					;r09
	
2	
        nop
        nop
        in f,(c)
	jp m,2B
	
	out (c),a

		ld a,(de)			
		inc e
		call z,inc_d_paging
;en_chk
	bit 4,a
	jp nz,chb_en_on
	
		ld h,a
		and %00001111
		sub ay_vol_down
		jr nc,1F
		xor a
1
		ld l,a
		ld a,h
		and %11110000
		or l
		
			ld (chb_vol_orig),a
chb_vol_cntrl = $+1 :	sub $00
			jr nc,1F
			xor a
1
			
 if wait_2203_sgg_2 = 1
2	
        nop
        nop
        in f,(c)
	jp m,2B
 endif
	

	ld b,sBF	;FD
	out (c),a
			ld hl,$0018		;18 00 jr
		;	ld (chb_en_var),hl	;
						;запрет вывода громкости огибающей
	
	jp (ix)

;==============================================================================
chb_en_on
			ld hl,$79ED		;ED 79 out (c),a
		;	ld (chb_en_var),hl	;
						;разрешение вывода громкости огибающей

; ld a,2
; out ($FE),a
; 	dup 50
;	halt
;	edup
	
	jp (ix)				
	
;==============================================================================

;==============================================================================
OPNA_YM2608_00_r0A_SSG_vol_chc
	ld h,%11111000	;chip1				;SSG vol C
	ld bc,sFFFD
	out (c),h					;r0A
	
2	
        nop
        nop
        in f,(c)
	jp m,2B
	
	out (c),a

		ld a,(de)			
		inc e
		call z,inc_d_paging
;en_chk
	bit 4,a
	jp nz,chc_en_on
	
		ld h,a
		and %00001111
		sub ay_vol_down
		jr nc,1F
		xor a
1
		ld l,a
		ld a,h
		and %11110000
		or l
	
			ld (chc_vol_orig),a
chc_vol_cntrl = $+1 :	sub $00
			jr nc,1F
			xor a
1
	
 if wait_2203_sgg_2 = 1
2	
        nop
        nop
        in f,(c)
	jp m,2B
 endif
 
 
	ld b,sBF	;FD
	out (c),a
			ld hl,$0018		;18 00 jr
		;	ld (chc_en_var),hl	;
						;запрет вывода громкости огибающей
	jp (ix)
	
;==============================================================================
chc_en_on
			ld hl,$79ED		;ED 79 out (c),a
		;	ld (chc_en_var),hl	;
						;разрешение вывода громкости огибающей

; ld a,3
; out ($FE),a
 
 
;	dup 50
;	halt
;	edup
	
	jp (ix)				
					
;==============================================================================




;==============================================================================
OPNA_YM2608_00_r0B_SSG_en_low


		ld a,(de)			
		inc e
		call z,inc_d_paging

		ld (en_select_chk),a

		ld l,a


;		call mount_tabs_page
;		
;		ld h,en_l_frq_convert_tab_haddr
;		ld a,(hl)
;		ld (en_l_frq_select_l_var),a
;		inc h
;		ld a,(hl)
;		ld (en_l_frq_select_m_var),a
;		inc h
;		ld a,(hl)
;		ld (en_l_frq_select_h_var),a
;
;		call mount_current_page
		

		jp en_frq_select

;==============================================================================		
OPNA_YM2608_00_r0C_SSG_en_high

	
		ld a,(de)			
		inc e
		call z,inc_d_paging

		ld (en_select_chk),a

		ld l,a
		
;		call mount_tabs_page
;
;		ld h,en_h_frq_convert_tab_haddr
;		ld a,(hl)
;		ld (en_h_frq_select_l_var),a
;		inc h
;		ld a,(hl)
;		ld (en_h_frq_select_m_var),a
;		inc h
;		ld a,(hl)
;		ld (en_h_frq_select_h_var),a	
;
;		call mount_current_page

	
		jp en_frq_select

;==============================================================================


en_frq_select					;вывод или	00хх
						;	или	xx00

	display "en_frq_select ",$

en_select_chk = $+1 :	ld a,$00
			and a
			jp z,en_low_frq_out
en_high_frq_out

en_h_frq_select_m_var = $+2 
en_h_frq_select_l_var = $+1 :	ld hl,$0000
			;	ld (en_frq_low),hl
				
en_h_frq_select_h_var = $+1 :	ld a,$00
			;	ld (en_frq_high),a


		jp (ix)

;------------------------------------------------------------------------------

		
en_low_frq_out

en_l_frq_select_m_var = $+2 
en_l_frq_select_l_var = $+1 :	ld hl,$0000
			;	ld (en_frq_low),hl
				
en_l_frq_select_h_var = $+1 :	ld a,$00
			;	ld (en_frq_high),a		

		jp (ix)
;------------------------------------------------------------------------------

;==============================================================================





;==============================================================================
	
;------------------------------------------------------------------------------
OPNA_YM2608_00_r0D_SSG_en_shape
				;так же вызывает переинициализацию огибающей


		xor a			;сброс счетчика огибающей в 0
		ld h,a
		ld l,a
	;	ld (en_cnt_low),hl
	;	ld (en_cnt_high),a
		
	
		ld a,(de)			
		inc e
		call z,inc_d_paging
		
;en_shape_decoding
;0000 \___ 1 \_						;1 D0
;0001 \___ 1 \_
;0010 \___ 1 \_
;0011 \___ 1 \_
;0100 /___	2 /_					;2 U0
;0101 /___	2 /_
;0110 /___	2 /_
;0111 /___	2 /_
;1000 \\\\	     3 \\				;3 DD
;1001 \___ 1 \_
;1010 \/\/		  4 \/  			;4 DU
;1011 \^^^		       5 \^			;5 D1
;1100 ////			    6 //		;6 UU
;1101 /^^^				 7 /^		;7 U1
;1110 /\/\				      ;8 /\	l8 UD
;1111 /___	2 /_

	

	;	ld h,en_shape_select_tab_haddr
		ld l,a
		ld a,(hl)
	;	ld (en_shape_var),a

		inc h
		ld a,(hl)
	;	ld (en_stop_shape),a
		
		inc h
		ld a,(hl)
	;	ld (en_stop_jp),a


;громкость при остановке 1\0
	;	ld (en_stop_vol),a



;установка зацикленности огибающей
					;en_endless
					;en_stop
	;	ld hl,en_stop
	;	ld (en_stop_var),hl	;





; ld a,4
; out ($FE),a

	jp (ix)
;------------------------------------------------------------------------------
					
;==============================================================================




;==============================================================================
						
;------------------------------------------------------------------------------
OPNA_YM2608_r28_key_on_off

		ld a,(de)			
		inc e
		call z,inc_d_paging
	
		bit 2,a						;z  = 123
		jp nz,OPNA_YM2608_r28_key_on_off_ym2				;nz = 456
;------------------------------------------------------------------------------
OPNA_YM2608_r28_key_on_off_ym1

		ld h,%11111000	;chip1
		ld bc,sFFFD
		out (c),h
		
;		ld bc,sFFFD
2	
        nop
        nop
        in f,(c)
		jp m,2B
		
		ld h,$28
		out (c),h
	
2	
        nop
        nop
        in f,(c)
		jp m,2B
		
		ld b,sBF	;FD
		out (c),a
	
		jp (ix)
;------------------------------------------------------------------------------
						
;==============================================================================
						
;------------------------------------------------------------------------------
OPNA_YM2608_r28_key_on_off_ym2
		and %11111011

		ld h,%11111001	;chip2
		ld bc,sFFFD
		out (c),h
		
;		ld bc,$FFFD
2	
        nop
        nop
        in f,(c)
		jp m,2B
		
		ld h,$28
		out (c),h
	
2	
        nop
        nop
        in f,(c)
		jp m,2B
		
		ld b,sBF	;FD
		out (c),a
	
		jp (ix)
;------------------------------------------------------------------------------
						
;==============================================================================



						
OPNA_YM2608_00_r2D_prescaler

	;	inc e
	;	call z,inc_d_paging
		inc e
		call z,inc_d_paging
		
;	ld a,$7
;	out ($FE),A
;	ld b,$FF
;	djnz $
;		di : halt
		
		jp (ix)
						



						
OPNA_YM2608_00_r2E_prescaler

	;	inc e
	;	call z,inc_d_paging
		inc e
		call z,inc_d_paging
		
;	ld a,$6
;	out ($FE),A
;	ld b,$FF
;	djnz $
;	
;		di : halt
		
		jp (ix)
						

						
OPNA_YM2608_00_r2F_prescaler

	;	inc e
	;	call z,inc_d_paging
		inc e
		call z,inc_d_paging

;	ld a,$5
;	out ($FE),A
;	ld b,$FF
;	djnz $
;	
;		di : halt
		
		jp (ix)
						


;//===========================================================================


;==============================================================================
s98_set_vol_a
					;упрощенный вариант

		rra : rra
		cpl;%11000000
		and %00111111
			
		ld (tl_ym1_vol_cntrl),a
		ld (tl_ym2_vol_cntrl),a
		ld (tl_ym1_vol_cntrl_2),a
		ld (tl_ym2_vol_cntrl_2),a		
		
		rra : rra
		and $0F
		
		ld (cha_vol_cntrl),a
		ld (chb_vol_cntrl),a
		ld (chc_vol_cntrl),a

		ld l,a

	ld h,%11111000	;chip1				
	ld bc,sFFFD
	out (c),h	

;------------------------------------------------------------------------------

	ld b,3
	ld de,cha_vol_orig
	ld h,$08				;SSG vol A

ssg_vol_chng_loop
	push bc

	ld b,sFF
2	
        nop
        nop
        in f,(c)
  jp m,2B
	out (c),h				;r08
		ld a,(de)
		sub l
		jr nc,1F
		xor a
1
 if wait_2203_sgg_2 = 1
2	
        nop
        nop
        in f,(c)
  jp m,2B
 endif
	ld b,sBF ;FD
	out (c),a
	
	inc h
	inc de
	
	pop bc
	djnz ssg_vol_chng_loop
	
;------------------------------------------------------------------------------

	ld hl,TL_ch1_op1_ym1_orig
	ld de,TL_regs_list
	
	ld b,12
	
TL_ym1_vol_loop
	push bc

;OPNA_YM2608_simple_write_2_ym1
	ld a,%11111000	;chip1
	ld bc,sFFFD
	out (c),a
	
;	ld bc,sFFFD
2	
        nop
        nop
        in f,(c)
	jp m,2B
	
	ld a,(de)
	out (c),a	;reg
	inc de

2	
        nop
        nop
        in f,(c)
	jp m,2B
	
	ld a,(hl)
tl_ym1_vol_cntrl_2 = $+1 :	add $00
				cp $80
				jr c,1F
				ld a,$7F
1
	ld b,sBF	;FD
	out (c),a
	inc hl
	
	
	pop bc
	djnz TL_ym1_vol_loop
	
;------------------------------------------------------------------------------

	ld de,TL_regs_list
	
	ld b,12
	
TL_ym2_vol_loop
	push bc

;OPNA_YM2608_simple_write_2_ym2
	ld a,%11111001	;chip2
	ld bc,sFFFD
	out (c),a
	
;	ld bc,sFFFD
2	
        nop
        nop
        in f,(c)
	jp m,2B
	
	ld a,(de)
	out (c),a	;reg
	inc de

2	
        nop
        nop
        in f,(c)
	jp m,2B
	
	ld a,(hl)
tl_ym2_vol_cntrl_2 = $+1 :	add $00
				cp $80
				jr c,1F
				ld a,$7F
1
	ld b,sBF	;FD
	out (c),a
	inc hl
	
	
	pop bc
	djnz TL_ym2_vol_loop	
	
		ret

;==============================================================================





;==============================================================================

OPNA_YM2608_TL_ch1_op1_ym1	;40 TOTAL LEVEL
      ld hl,TL_ch1_op1_ym1_orig
      push hl
	jr OPNA_YM2608_TL_ym1
OPNA_YM2608_TL_ch2_op1_ym1	;41 TOTAL LEVEL
      ld hl,TL_ch2_op1_ym1_orig
      push hl
	jr OPNA_YM2608_TL_ym1
OPNA_YM2608_TL_ch3_op1_ym1	;42 TOTAL LEVEL
      ld hl,TL_ch3_op1_ym1_orig
      push hl
	jr OPNA_YM2608_TL_ym1
      
OPNA_YM2608_TL_ch1_op2_ym1	;44 TOTAL LEVEL
      ld hl,TL_ch1_op2_ym1_orig
      push hl
	jr OPNA_YM2608_TL_ym1
OPNA_YM2608_TL_ch2_op2_ym1	;45 TOTAL LEVEL
      ld hl,TL_ch2_op2_ym1_orig
      push hl
	jr OPNA_YM2608_TL_ym1
OPNA_YM2608_TL_ch3_op2_ym1	;46 TOTAL LEVEL
      ld hl,TL_ch3_op2_ym1_orig
      push hl
	jr OPNA_YM2608_TL_ym1
      
OPNA_YM2608_TL_ch1_op3_ym1	;48 TOTAL LEVEL
      ld hl,TL_ch1_op3_ym1_orig
      push hl
	jr OPNA_YM2608_TL_ym1
OPNA_YM2608_TL_ch2_op3_ym1	;49 TOTAL LEVEL
      ld hl,TL_ch2_op3_ym1_orig
      push hl
	jr OPNA_YM2608_TL_ym1
OPNA_YM2608_TL_ch3_op3_ym1	;4A TOTAL LEVEL
      ld hl,TL_ch3_op3_ym1_orig
      push hl
	jr OPNA_YM2608_TL_ym1
      
OPNA_YM2608_TL_ch1_op4_ym1	;4C TOTAL LEVEL
      ld hl,TL_ch1_op4_ym1_orig
      push hl
	jr OPNA_YM2608_TL_ym1
OPNA_YM2608_TL_ch2_op4_ym1	;4D TOTAL LEVEL
      ld hl,TL_ch2_op4_ym1_orig
      push hl
	jr OPNA_YM2608_TL_ym1
OPNA_YM2608_TL_ch3_op4_ym1	;4E TOTAL LEVEL
      ld hl,TL_ch3_op4_ym1_orig
      push hl
;	jr OPNA_YM2608_TL_ym1

OPNA_YM2608_TL_ym1
		
;OPNA_YM2608_simple_write_2_ym1
	ld h,%11111000	;chip1
	ld bc,sFFFD
	out (c),h
	
;	ld bc,sFFFD			;SSG 00
2	
        nop
        nop
        in f,(c)
	jp m,2B
	
	out (c),a

		ld a,(de)			
		inc e
		call z,inc_d_paging	;там свой push bc !!!

2	
        nop
        nop
        in f,(c)
	jp m,2B
	
				pop hl
				ld (hl),a
tl_ym1_vol_cntrl = $+1 :	add $00
				cp $80
				jr c,1F
				ld a,$7F
1
	ld b,sBF	;FD
	out (c),a


	jp (ix)
	
OPNA_YM2608_TL_ch1_op1_ym2	;40 TOTAL LEVEL
      ld hl,TL_ch1_op1_ym2_orig
      push hl
	jr OPNA_YM2608_TL_ym2
OPNA_YM2608_TL_ch2_op1_ym2	;41 TOTAL LEVEL
      ld hl,TL_ch2_op1_ym2_orig
      push hl
	jr OPNA_YM2608_TL_ym2
OPNA_YM2608_TL_ch3_op1_ym2	;42 TOTAL LEVEL
      ld hl,TL_ch3_op1_ym2_orig
      push hl
	jr OPNA_YM2608_TL_ym2
      
OPNA_YM2608_TL_ch1_op2_ym2	;44 TOTAL LEVEL
      ld hl,TL_ch1_op2_ym2_orig
      push hl
	jr OPNA_YM2608_TL_ym2
OPNA_YM2608_TL_ch2_op2_ym2	;45 TOTAL LEVEL
      ld hl,TL_ch2_op2_ym2_orig
      push hl
	jr OPNA_YM2608_TL_ym2
OPNA_YM2608_TL_ch3_op2_ym2	;46 TOTAL LEVEL
      ld hl,TL_ch3_op2_ym2_orig
      push hl
	jr OPNA_YM2608_TL_ym2
      
OPNA_YM2608_TL_ch1_op3_ym2	;48 TOTAL LEVEL
      ld hl,TL_ch1_op3_ym2_orig
      push hl
	jr OPNA_YM2608_TL_ym2
OPNA_YM2608_TL_ch2_op3_ym2	;49 TOTAL LEVEL
      ld hl,TL_ch2_op3_ym2_orig
      push hl
	jr OPNA_YM2608_TL_ym2
OPNA_YM2608_TL_ch3_op3_ym2	;4A TOTAL LEVEL
      ld hl,TL_ch3_op3_ym2_orig
      push hl
	jr OPNA_YM2608_TL_ym2
      
OPNA_YM2608_TL_ch1_op4_ym2	;4C TOTAL LEVEL
      ld hl,TL_ch1_op4_ym2_orig
      push hl
	jr OPNA_YM2608_TL_ym2
OPNA_YM2608_TL_ch2_op4_ym2	;4D TOTAL LEVEL
      ld hl,TL_ch2_op4_ym2_orig
      push hl
	jr OPNA_YM2608_TL_ym2
OPNA_YM2608_TL_ch3_op4_ym2	;4E TOTAL LEVEL
      ld hl,TL_ch3_op4_ym2_orig
      push hl
;	jr OPNA_YM2608_TL_ym2

OPNA_YM2608_TL_ym2

;OPNA_YM2608_simple_write_2_ym2
	ld h,%11111001	;chip2
	ld bc,sFFFD
	out (c),h
	
2	
        nop
        nop
        in f,(c)
	jp m,2B
	
	out (c),a

		ld a,(de)			
		inc e
		call z,inc_d_paging
		
2	
        nop
        nop
        in f,(c)
	jp m,2B

				pop hl
				ld (hl),a
tl_ym2_vol_cntrl = $+1 :	add $00
				cp $80
				jr c,1F
				ld a,$7F
1	
	ld b,sBF
	out (c),a

	jp (ix)

;==============================================================================



PLAY:
		
s98_player_play_var = $ :	nop		;nop - play
						;ret - stop

                	xor a; ld a,$00			;nop	;play unlock

			call mount_current_page

player_code
			ld ix,command_decoding


player_reg_DE = $+1 :	ld de,$C080


	
player_last_addr = $+1 : jp command_decoding

command_decoding
		ld a,(de)				;7
		inc e					;4

		jr nz,command_decoding_no_inc_de	;7\12
command_decoding_inc_de
		inc d					;4
		call z,next_ram_page
command_decoding_no_inc_de	
		
;упрощенный декодер
		ld hl,OPNA_YM2608_00_decoder	;1st device out1
	    and a
	jr z,1f
		ld hl,OPNA_YM2608_01_decoder	;1st device out2
	    cp $01
	jr z,1f
		ld hl,command_FE	;nsync
	    cp $FE
	jr z,1f	
		ld hl,command_FF	;sync
	    cp $FF
	jr z,1f
		ld hl,command_FD	;loop
	    cp $FD
	jr z,1f	    
		;ld hl,command_undoc
		
				ld a,$07
				out ($FE),a
					;dup 50
					;halt
					;edup
		
			inc e
			call z,inc_d_paging
			inc e
			call z,inc_d_paging
			jp (ix)
		
1
		jp (hl)					;10

;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
player_frame_complete
		ld (player_reg_DE),DE
		
		ld hl,command_decoding
		ld (player_last_addr),hl

/*
	if wait_2203_sgg = 0
	
	ld h,%11111000		;chip1
	ld bc,sFFFD
	
	out (c),h
2	
        nop
        nop
        in f,(c)
	jp m,2B
	
	;ld h,%11111001		;chip2
	inc h
	
	out (c),h
2	
        nop
        nop
        in f,(c)
	jp m,2B

	endif
*/		

	
		ret
	
;------------------------------------------------------------------------------

	
;------------------------------------------------------------------------------
player_frame_complete_when_FE
		ld (player_reg_BC),BC
		ld (player_reg_DE),DE
		ld (player_reg_HL),HL
		push af
		pop hl
		ld (player_reg_AF),HL
		
		ld hl,execute_restoring_when_FE
		ld (player_last_addr),hl
		ret

;------------------------------------------------------------------------------
execute_restoring_when_FE
player_reg_AF = $+1 :	ld hl,$0000
			push hl
			pop af
player_reg_BC = $+1 :	ld bc,$0000
player_reg_HL = $+1 :	ld hl,$0000


		jp sync_FE_loop_continue
		
;==============================================================================	



;==============================================================================
TL_regs_list
	defb $40	;TOTAL LEVEL
	defb $41	;TOTAL LEVEL
	defb $42	;TOTAL LEVEL
	defb $44	;TOTAL LEVEL
	defb $45	;TOTAL LEVEL
	defb $46	;TOTAL LEVEL
	defb $48	;TOTAL LEVEL
	defb $49	;TOTAL LEVEL
	defb $4A	;TOTAL LEVEL
	defb $4C	;TOTAL LEVEL
	defb $4D	;TOTAL LEVEL
	defb $4E	;TOTAL LEVEL
	
;==============================================================================




;==============================================================================

; переменные


cha_vol_orig		defb $00	;читаются подряд
chb_vol_orig		defb $00
chc_vol_orig		defb $00

TL_ch1_op1_ym1_orig	defb $7F
TL_ch2_op1_ym1_orig	defb $7F
TL_ch3_op1_ym1_orig	defb $7F
TL_ch1_op2_ym1_orig	defb $7F
TL_ch2_op2_ym1_orig	defb $7F
TL_ch3_op2_ym1_orig	defb $7F
TL_ch1_op3_ym1_orig	defb $7F
TL_ch2_op3_ym1_orig	defb $7F
TL_ch3_op3_ym1_orig	defb $7F
TL_ch1_op4_ym1_orig	defb $7F
TL_ch2_op4_ym1_orig	defb $7F
TL_ch3_op4_ym1_orig	defb $7F

TL_ch1_op1_ym2_orig	defb $7F
TL_ch2_op1_ym2_orig	defb $7F
TL_ch3_op1_ym2_orig	defb $7F
TL_ch1_op2_ym2_orig	defb $7F
TL_ch2_op2_ym2_orig	defb $7F
TL_ch3_op2_ym2_orig	defb $7F
TL_ch1_op3_ym2_orig	defb $7F
TL_ch2_op3_ym2_orig	defb $7F
TL_ch3_op3_ym2_orig	defb $7F
TL_ch1_op4_ym2_orig	defb $7F
TL_ch2_op4_ym2_orig	defb $7F
TL_ch3_op4_ym2_orig	defb $7F





;==============================================================================
;memory paging procedures
;==============================================================================
						
inc_d_paging
			inc d
			ret nz
	display "next ram page ",$			
next_ram_page			push af
				push bc
				push hl
;current_ram_page = $+1 :	ld a,$00
                                ld a,(current_ram_page)
				inc a
				ld (current_ram_page),a
				ld l,a
				
					;ld h,s98_file00_pages_list_haddr
						;;ld a,(load_s98_file_number_haddr)
						;;ld h,a
                                                ld h,load_s98_file_number_haddr
					ld a,(hl)
	
				push de
				;push hl
				SETPGC000
				;pop hl
				pop de
				
		ld d,$C0
		pop hl
		pop bc
		pop af
		ret
		
;==============================================================================		


;==============================================================================
mount_ram_a
				ld (current_ram_page),a
				ld l,a
				
				;ld h,s98_file00_pages_list_haddr
					;;ld a,(load_s98_file_number_haddr)
					;;ld h,a
                                        ld h,load_s98_file_number_haddr
				ld a,(hl)
						

				push de
				push hl
				SETPGC000
				pop hl
				pop de
					
		ret
		
;==============================================================================


;==============================================================================
mount_current_page
				ld a,(current_ram_page)
				ld l,a
			
				;ld h,s98_file00_pages_list_haddr
					;;ld a,(load_s98_file_number_haddr)
					;;ld h,a
                                        ld h,load_s98_file_number_haddr
				ld a,(hl)			
				
				push de
				push hl
				SETPGC000
				pop hl
				pop de
	ret
			
;==============================================================================

s98_end

        savebin "s98_plr.bin",s98_begin,s98_end-s98_begin
        LABELSLIST "..\..\us\user.l"    