;Recomposer MIDI player v1.0 	28.11.2025
        DEVICE ZXSPECTRUM48
        include "../../../_sdk/sys_h.asm"
                ORG 0x4000


AREA_C000_FFFF = 1

module = $C000


MAX_NR_OF_TRACKS = 18



TITLELENGTH = 64
MEMORYSTREAMMAXPAGES = 210
MEMORYSTREAMERRORMASK = 255

DRUM_CHANNEL = 9

DEFAULT_QNOTE_DURATION_MCS = 500000
VSYNC_FREQ = 49 ;46
VSYNC_MCS = 1000000/VSYNC_FREQ





begin
START
                display "start ",$
        	LD HL,module;MDLADDR ;DE - address of 2nd module for TS
        	JR INIT
        	JP PLAY
        	JP MUTE
INIT:
        jp init_


        align 256  ;0x4100
        display "s98_file00_pages_list ",$

memorystreampages: ds 256,0
memorystreampagecount = memorystreampages + 255
                include "common/opl4.asm"
                include "common/memorystream.asm"
				include "common_mid/rcp_def.asm"
                include "common_mid/opl_.asm"
                include "common_mid/muldiv.asm"
                include "common_mid/rcp_rob.asm"



init_:
                call init_opl4_device        
                call memorystreamstart
      
                ld b,rcpheadersigsize
                ld de,rcpheadersig
                call check_signature
                jp nz,notRCP

                ;read song title position
                ld hl,(memorystreamcurrentaddr)
                ld bc,64+0x150+16 ;skip song title (64) + comment (0x150) + unused(16)
                add hl,bc    ;skip comment field
;-------timebase low                       
                ld a,(hl):inc hl  ;memory_stream_read_1 a
                ld (g_header.ticks_per_qnote),a  ; lower byte
;-------tempo
                ld a,(hl):inc hl         ;   8-tempo-250
                cp 8
                jr c,.wrong_tempo
                cp 251
                jr c,.good_tempo
.wrong_tempo
                ld a,120
.good_tempo
                ld (g_header.tempo),a  ;
;---------- numerator denominator
		inc hl: inc hl 
;---------- key signature
		inc hl	
;---------- play bias
                ld a,(hl):inc hl         ;  play bias -36 +36
                add a,36
                and a	
                jp m,.bad_bias0	
                cp 72+1
                jr c,.good_bias
                ld a,72
                jr .good_bias
.bad_bias0:
                xor a
.good_bias:
                sub 36
                ld (g_header.play_bias),a  ; aka global transposition
;-------skip cm6 + gsd
                ld bc,32
                add hl,bc

;----------- track count
                ld a,(hl): inc hl  ;memory_stream_read_1 a ; track count . should be 0 (18)  , 18 or 36
                cp 36
                jr z,._valid_tr_count
                cp 18
                jr z,._valid_tr_count
                ld a,18
._valid_tr_count:
                ld (g_header.number_of_tracks),a
;-------- timebase HIGH
                ld a,(hl): inc hl  ;memory_stream_read_1 a
                ld (g_header.ticks_per_qnote+1),a  ; high byte  
;---------skip rest unused byted                
                ld bc,542 + 0x30*8    ;   30h*8	User SysEx
                add hl,bc
                ld (memorystreamcurrentaddr),hl
;===========================================================================

                ld a,0 ;16
                ld (g_volume_boost),a
                
                ld a,SNDRV_MIDI_MODE_GM
                ld (g_header.midi_mode),a
                ld a,127
                ld (g_header.gs_master_volume),a
;----------------set initial tempo
                ld bc,(g_header.ticks_per_qnote)
                ld de,VSYNC_MCS
                call uintmul16
                add hl,hl : rl de
                add hl,hl : rl de

                add hl,hl : rl de ;<<<
                add hl,hl : rl de ;<<<

                ld (g_header.ticksperqnoteXupdatelen+0),hl
                ld (g_header.ticksperqnoteXupdatelen+2),de
                
                
                ld a,(g_header.tempo)
                ld c,a
                call bpm_setticksperupdate


;----------------load tracks data----------------------
;rcploadtracks
				xor a
				ld (g_header.detected_tracks),a				
                ld ix,g_header.g_track_data
                ld iy,(g_header.number_of_tracks)
.loop:
        	call memorystreamgetpos
                ld (ix+TRACK_DATA.track_header_position),hl
                ld (ix+TRACK_DATA.track_header_position+2),de
                push de	
                push hl	
                
                ld hl,(memorystreamcurrentaddr)
                memory_stream_read_byte c
                memory_stream_read_byte b
                push bc            ;store track length for later
                
                memory_stream_read_byte a
                ld (ix+TRACK_DATA.track_id),a  ;track id  (1 based)
                
                memory_stream_read_byte a	;rhythm mode
                
                memory_stream_read_byte a
                ld (ix+TRACK_DATA.midi_ch),a  ;midi channel
                cp 255
                jp z,.skip_track	
                cp 0x11
                jp nc,.skip_track   ;skip if midi device = 1 (channels 16-36)    
                
                memory_stream_read_byte a  ;key offset  7bit signed  (+63 -63)
										   ;(key offset & 0x40) ? (-0x80 + key offset) : key offset;	// 7-bit -> 8-bit sign extension
				ADD     A,A            ; check for sign ;
				JR      NC,.L0FEB
				XOR     A                ;80-ff - rhythm track
				JR      .set_k_offset
.L0FEB: 		SRA     A             ;7bit signed -> 8bit signed
.set_k_offset:
				ld b,a
				ld a,(g_header.play_bias)
				add a,b
                ld (ix+TRACK_DATA.key_offset),a  ;key - transposition /rhythm

                memory_stream_read_byte a
				add a,0x80
				ld (ix+TRACK_DATA.waiting_for+0),a
                
                memory_stream_read_byte a
				and 1
				jp nz,.skip_track			;skip track if muted
        	    ld (memorystreamcurrentaddr),hl    

				ld hl,g_header.detected_tracks
				inc (hl)
                
                call memorystreamgetpos
                ld bc,0x24  ; skip track name
                add hl,bc
                ex de,hl
                ld bc,0
                adc hl,bc	;dehl+00bc
                ld (ix+TRACK_DATA.streamoffset),de   ;hl
                ld (ix+TRACK_DATA.streamoffset+2),hl ;de
                
                
                ld bc,TRACK_DATA
                add ix,bc

.skip_track:			
                pop bc
                pop hl
                add hl,bc
                ld bc,0
                ex de,hl
                pop hl
                adc hl,bc
                ex de,hl	
                call memorystreamseek
                dec iyl
                jp nz,.loop

;--------------------------------------------------------------
;generate midi channel table
                ld hl,g_header.g_midi_channel_data+128
                ld iy,NR_OF_MIDI_CHANNELS      
                ld bc,MIDI_CHANNEL_DATA
                ld de,midi_ch_table   
.loop1:
                ld a,l
                ld (de),a
                inc de
                ld a,h
                ld (de),a
                inc de
                
                add hl,bc
                dec iyl
                jr nz,.loop1
;--------------------------------------------------------------        
        
                call rewind
                xor a
                ld (rcp_play_var),a
                ret

init_channels:
			ld hl,g_header.g_midi_channel_data
			ld iy,NR_OF_MIDI_CHANNELS
			ld d,0   ;channel
.loop
			xor a
			ld b,128+16   ;1instrument + 1vibrato + 2pitchbend + 2 finetuning + 2 coarsetuning +1 rpn type + 4 midictl reg +1sustain  +1 panpot ymf278  -7 [0] +7   1pitch bend range (low)
.clear_status
			ld (hl),a
			inc hl
			djnz .clear_status
			inc a
			ld (hl),a ; rpn_pitch_bend_range+1
			inc hl
			ld (hl),a ; param_type
			inc hl
			ld (hl),100  ;gm_volume
			inc hl
			ld (hl),127  ;gm_expression
			inc hl

			ld a,DRUM_CHANNEL
			cp d
			ld a,0
			jr nz,.loop1
			inc a
.loop1
			ld (hl),a
			inc hl

			inc d
			dec iyl
			jp nz,.loop
			ret

init_voices:

			ld hl,g_header.g_voice_data
			ld iy,NR_OF_WAVE_CHANNELS
			xor a
			ld d,a
.loop
			ld (hl),d:inc hl  ;VOICE_DATA.number
			ld b,15
.loop2
			ld (hl),a:inc hl
			djnz .loop2
			inc d
			dec iyl
			jp nz,.loop
			ret




;------------------------------------------------------------------------------------------------------------
rewind:
			ld hl,0
			ld (tick_counter),hl
			ld (tick_counter+2),hl
		
			ld hl,g_header.g_track_data
			ld iy,(g_header.detected_tracks)
			xor a
.loop1
			push hl
			ld (hl),a:inc hl:ld (hl),a:inc hl:ld (hl),a:inc hl:ld (hl),a:inc hl   ; waiting for
			inc hl:inc hl:inc hl:inc hl  		;track header position
			;streamoffset -> currentoffset
			ld b,(hl) : inc hl : ld c,(hl) : inc hl : ld d,(hl) : inc hl : ld e,(hl) : inc hl
			ld (hl),b : inc hl : ld (hl),c : inc hl : ld (hl),d : inc hl : ld (hl),e : inc hl			
			ld bc,5
			add hl,bc 
			ld (hl),a:inc hl:ld (hl),a:inc hl
			ld (hl),a:inc hl:ld (hl),a:inc hl
			ld (hl),a:inc hl					;same measure mode
			ld (hl),a:inc hl					;same measure non FC commands executed
			ld (hl),a:inc hl					;current loop
			
			ld b, LOOP_TRACER_DATA*LOOP_TRACER_ENTRIES + NOTE_TRACER_DATA*NOTE_TRACER_ENTRIES		
.loop2:
			ld (hl),a
			inc hl
			djnz .loop2

			pop hl
			ld bc,TRACK_DATA
			add hl,bc
			dec iyl
			jp nz,.loop1

			call init_channels
			call init_voices
			ret
;-------------------------------------------------------------------------------------------------
MUTE:
                ld a,0xC9			;ret	;stop playing
                ld (rcp_play_var),a
                call opl4mute
                jp opl4_reset

PLAY:
rcp_play_var = $ : nop		;nop - play
                call rcp_play
                ;out  ;a !0 track still play  0 - finished        
                jp z,MUTE
                ret

notRCP:
                ld a,0xc9
                ld (rcp_play_var),a
                ret
;=============================
rcpheadersig:
               DB      "RCM-PC98V2.0(C)COME ON MUSIC",0Dh,0Ah,00h,00h
rcpheadersigsize: equ $-rcpheadersig
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_signature:
;b = byte count
;de = signature
;out: zf=1 if ok, zf=0 otherwise
        	ld hl,(memorystreamcurrentaddr)
.loop	        memory_stream_read_byte c
                ld a,(de)
                cp c
                ret nz
                inc de
                djnz .loop
                ld (memorystreamcurrentaddr),hl
                ret


memorystreamcurrentpage db 0

g_ticks_per_update_high dw 0

tick_counter 			ds 4,0
g_volume_boost 		db 16

n_on_voices          db 0  
n_on_data            ds  8,0   ; dw wave_data, dw voice_data


n_on_data_ptr        dw 0
                include "yrw801/yrw801imap_robo.asm"
                include "yrw801/pitch_table.asm"
end

        display "before ",$
g_header   MIDI_HEADER



                align 256
midi_ch_table: ds NR_OF_MIDI_CHANNELS*2,0
                

                display "yrw",$

                display "end ",$
                ;        LABELSLIST "mid_plr.l"    
                savebin "tenkosei/rcp_plr.bin",begin,end-begin