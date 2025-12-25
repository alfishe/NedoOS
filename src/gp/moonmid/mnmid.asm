set_refresh:
	ld hl,DEFAULT_QNOTE_DURATION_MCS%65536
	ld de,DEFAULT_QNOTE_DURATION_MCS/65536
setticksperupdate
;dehl = qnote duration in mcs
	exx
	ld hl,(g_header.ticksperqnoteXupdatelen+0)
	ld de,(g_header.ticksperqnoteXupdatelen+2)
	call uintdiv32
	ld (g_ticks_per_update+0),hl
	ld (g_ticks_per_update+2),de
	ret



midheadersig:
			db  "MThd",0,0,0,6
midheadersigsize: equ $-midheadersig
midtracksig
			db "MTrk"
midtracksigsize = $-midtracksig

midchecksignature
;b = byte count
;de = signature
;out: zf=1 if ok, zf=0 otherwise
			ld hl,(memorystreamcurrentaddr)
.loop	memory_stream_read_byte c
			ld a,(de)
			cp c
			ret nz
			inc de
			djnz .loop
			ld (memorystreamcurrentaddr),hl
			ret 


generate_tables:
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
            ret    
			
rewind:
			ld hl,0
			ld (g_MIDI_counter),hl
			ld (g_MIDI_counter+2),hl

			ld hl,g_header.g_track_data
			ld iy,(g_header.number_of_tracks)

.loop1
;waiting_for_t -> waiting_for
			ld b,(hl) : inc hl : ld c,(hl) : inc hl : ld d,(hl) : inc hl : ld e,(hl) : inc hl
			ld (hl),b : inc hl : ld (hl),c : inc hl : ld (hl),d : inc hl : ld (hl),e : inc hl

;streamoffset -> currentoffset
			ld b,(hl) : inc hl : ld c,(hl) : inc hl : ld d,(hl) : inc hl : ld e,(hl) : inc hl
			ld (hl),b : inc hl : ld (hl),c : inc hl : ld (hl),d : inc hl : ld (hl),e : inc hl
			;track_finished
			ld (hl),0 : inc hl
;last command    
			ld (hl),0xff : inc hl
			dec iyl
			jp nz,.loop1
			call init_channels
			call init_voices
			ret
			
			
init_channels:
			ld hl,g_header.g_midi_channel_data
			ld iy,NR_OF_MIDI_CHANNELS
			ld d,0   ;channel
.loop
			xor a
			ld b,128+15   ;128 notes + 1instrument + 1vibrato + 2pitchbend + 2 finetuning + 2 coarsetuning + 4 midictl reg +1sustain  +1 panpot ymf278  -7 [0] +7   1pitch bend range (low)
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
			ld a,1
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
			
midloadtracks:
			ld ix,g_header.g_track_data
			ld iy,(g_header.number_of_tracks)

.loop		ld b,midtracksigsize
			ld de,midtracksig
			call midchecksignature
			ret nz
			call memorystreamread4
			ld l,b
			ld h,c
			push hl
			ld e,a
			push de
			call memorystreamgetpos
			push de
			push hl

			ld hl,(memorystreamcurrentaddr)
			call midreadvarint
			ld (memorystreamcurrentaddr),hl
			
			ex de,hl
			xor a
			add hl,hl : rl c : rla
			add hl,hl : rl c : rla
			add hl,hl : rl c : rla
			add hl,hl : rl c : rla
			ld (ix+TRACK_DATA.waiting_for_t+0),hl
			ld (ix+TRACK_DATA.waiting_for_t+2),c
			ld (ix+TRACK_DATA.waiting_for_t+3),a
			call memorystreamgetpos
			ld (ix+TRACK_DATA.streamoffset+0),hl
			ld (ix+TRACK_DATA.streamoffset+2),de
			pop hl
			pop de
			pop bc
			add hl,bc
			ex de,hl
			pop bc
			adc hl,bc
			ex de,hl
			call memorystreamseek
			ld bc,TRACK_DATA
			add ix,bc
			dec iyl
			jp nz,.loop
			ret


midplay:
			YIELD
			
			
			ld a,(opl4tablespage)
			SETPGC000
			
			
			ld hl,(g_MIDI_counter+0)
			ld de,(g_ticks_per_update+0)
			add hl,de
			ld (g_MIDI_counter+0),hl
			ex de,hl
			ld hl,(g_MIDI_counter+2)
			ld bc,(g_ticks_per_update+2)
			adc hl,bc
			ld (g_MIDI_counter+2),hl
			ex de,hl

			call midgetprogress	
			call updateprogress


;iterate through the tracks
        	ld ix,g_header.g_track_data
        	ld a,(g_header.number_of_tracks)
        	ld b,a
        	ld c,0
.trackloop
        	bit 7,(ix+TRACK_DATA.track_finished)
        	jr nz,.skiptrack
			ld c,255
			ld hl,(g_MIDI_counter+0)
			ld de,(ix+TRACK_DATA.waiting_for+0)
			sub hl,de
			ld hl,(g_MIDI_counter+2)
			ld de,(ix+TRACK_DATA.waiting_for+2)
			sbc hl,de
			jr c,.skiptrack
			push bc
.handle_track_event
			ld hl,(ix+TRACK_DATA.currentoffset+0)
			ld de,(ix+TRACK_DATA.currentoffset+2)
			call memorystreamseek
			call process_midi_event
			call finalize  ;get_delta_time
			call memorystreamgetpos
			ld (ix+TRACK_DATA.currentoffset+0),hl
			ld (ix+TRACK_DATA.currentoffset+2),de
			pop bc
            jr .trackloop
.skiptrack
        	ld de,TRACK_DATA
        	add ix,de
        	djnz .trackloop
        	ld a,c  
        	or a          ;a 0 track still play  !0 - finished
        	ret
			
			


midreadvarint
;hl = memory stream addr
;out: cde = number, hl = memory stream addr
	ld de,0
	ld c,0
.loop	memory_stream_read_byte b
	ld a,e
	rrca
	xor b
	and 0x80
	xor b
	rr c
	rr de
	ld c,d
	ld d,e
	ld e,a
	bit 7,b
	jr nz,.loop
	ret

process_midi_event
			memory_stream_read_1 b         ;data_byte_1   ;command
/* If MSB is not set, this is a running status */
			bit 7,b
			jr z,.is_running
/*not_running*/
			ld (ix+TRACK_DATA.last_command),b                                        
			memory_stream_read_1 c 
			jr ._next_step1              ;b - data_byte_1  (command) c-data_byte_2 (first parameter)
.is_running
/*command running*/
			ld c,b
			ld b,(ix+TRACK_DATA.last_command)     ;b - data_byte_1  (command) c-data_byte_2 (first parameter)

._next_step1:

			ld a,b
			rrca
			rrca
			rrca
			rrca
			and 7
			ld d,a
			add a,a
			add a,d
			ld (.commandtable),a

			ld a,b
			and a,0x0f
			ld e,a           ;e - used channel

.commandtable=$+1
			jr $
			jp _j_note_off
			jp _j_note_on
			jp _j_key_after_touch
			jp _j_control_change
			jp _j_program_change
			jp _j_channel_after_touch
			jp _j_pitch_wheel
;;;;;;;;;;;;;;;;;;; F System
			ld a,b
			cp 0xff
			jp z,handle_meta_event
			cp 0xf0
			ret nz
handle_sys_ex_event:            

			ld hl,(memorystreamcurrentaddr)       
.sendloop:
			memory_stream_read_byte a
			cp 0xf7
			jr nz,.sendloop
			ld (memorystreamcurrentaddr),hl            
			ret 

_j_note_off:
			memory_stream_read_1 d   	;data_byte_3 
										;b - data_byte_1 - command
										;c - data_byte_2 - note
										;d - data_byte_3 - velocity  //  not used
										;e - wave channel
_j_note_off_1:
			ld a,c
			and 0x7f
			ld c,a
			
			cpl
			ld (._note_evv1),a
			ld (._note_evv2),a
			ld (._note_evv3),a
			ld (._note_evv4),a
			ld (._note_evv5),a
			ld (._note_evv6),a
;looking for midi channel
			push ix
            ld a,e
            add a,a
            ld h,HIGH midi_ch_table
            ld l,a    
            ld a,(hl)    
            inc hl   
            ld h,(hl)
            ld l,a    
            ld (.wave_channel_pointer),hl
            push hl 
            pop ix 
            ld a,(ix+0)
._note_evv1 equ $-1
            and SNDRV_MIDI_NOTE_ON
            jp z,._note_off_break                      ;noteoff but event for note is not note on
			ld  a,(IX+MIDI_CHANNEL_DATA.gm_sustain-128)
			and a
			jr z,.check_solstenuto

			ld a,(ix+0)
._note_evv2 equ $-1
			or  SNDRV_MIDI_NOTE_RELEASED
			ld (ix+0),a
._note_evv3 equ $-1                
			jp ._note_off_break
.check_solstenuto
			ld a,(ix+0)
._note_evv4 equ $-1
			and SNDRV_MIDI_NOTE_SOSTENUTO
			jr z,.no_solstenuto    
			or SNDRV_MIDI_NOTE_RELEASED
			ld (ix+0),a
._note_evv5 equ $-1                
			jp ._note_off_break
.no_solstenuto
			ld (ix+0),0
._note_evv6 equ $-2
			ld ix,g_header.g_voice_data
			ld iy,NR_OF_WAVE_CHANNELS        
.loop_v1:        
			ld a,(ix+VOICE_DATA.note)
			cp c
			jr nz,.loop_v2
			ld  a,(ix+VOICE_DATA.activated)
			or (ix+VOICE_DATA.activated+1)
			or (ix+VOICE_DATA.activated+2)
			or (ix+VOICE_DATA.activated+3)
			jr z,.loop_v2
			ld hl,(ix+VOICE_DATA.midi_channel)
			ld de,0
.wave_channel_pointer: equ $-2
			and a
			sbc hl,de
			jr nz,.loop_v2
			ld (ix+VOICE_DATA.is_active),0
			ld a,(ix+VOICE_DATA.reg_misc)
			and OPL4_KEY_ON_BIT_INV
			ld (ix+VOICE_DATA.reg_misc),a
			ld d,a  ;//(ix+VOICE_DATA.reg_misc)
			ld a,OPL4_REG_MISC
			add a,(ix+VOICE_DATA.number)
			ld e,a
			call opl4writewave
.loop_v2:
            ld de,VOICE_DATA    
            add ix,de
            dec iyl
            jr nz,.loop_v1             
._note_off_break
			pop ix
			ret
			
_j_key_after_touch:
			memory_stream_read_1 d 		;data_byte_3 
										;b - data_byte_1 - command
										;c - data_byte_2 - note
										;d - data_byte_3 - pressure value
										;e - wave channel
			ret
_j_control_change:
			memory_stream_read_1 d    	;data_byte_3 
										;b - data_byte_1 - command
										;c - data_byte_2 - controller
										;d - data_byte_3 - new value
										;e - wave channel
			push ix
			ld hl,.exxt
			push hl
			ld a,e
			ld (.sustain_midi_channel),a
			ld (.sostenuto_midi_channel),a
			add a,a
			ld h,HIGH midi_ch_table
			ld l,a    
			ld a,(hl)    
			inc hl   
			ld h,(hl)
			ld l,a
			push hl
			pop ix       
;=======================================================================================================
;	/* Switches */
;	if ((control >=64 && control <=69) || (control >= 80 && control <= 83)) {
;		/* These are all switches; either off or on so set to 0 or 127 */
;		value = (value >= 64)? 127: 0;
;	}
			ld a,c
			cp 64
			jp c,.no_c_switch:
			cp 83+1
			jp nc,.no_c_switch:
			cp 69+1
			jp c,.its_c_switch
			cp 80
			jp c,.no_c_switch
.its_c_switch:
			ld a,01000000b
			and a,d
			add a,a
			ld d,a
.no_c_switch:
;=======================================================================================================
			ld a,MIDI_CTL_MSB_MODWHEEL
			cp c
			jp z,.SUB_MIDI_CTL_MSB_MODWHEEL

			ld a,MIDI_CTL_MSB_MAIN_VOLUME
			cp c
			jp z,.SUB_MIDI_CTL_MSB_MAIN_VOLUME

			ld a,MIDI_CTL_MSB_EXPRESSION
			cp c
			jp z,.SUB_MIDI_CTL_MSB_EXPRESSION

			ld a,MIDI_CTL_MSB_DATA_ENTRY                      ;0x06  - 6
			cp c
			jp z,.SUB_MIDI_CTL_MSB_DATA_ENTRY


			ld a,MIDI_CTL_MSB_PAN                           ; 0x0a  10
			cp c
			jp z,.SUB_MIDI_CTL_MSB_PAN


			ld a,MIDI_CTL_LSB_DATA_ENTRY                    ;0x26  - 38
			cp c
			jp z,.SUB_MIDI_CTL_LSB_DATA_ENTRY


			ld a,MIDI_CTL_REGIST_PARM_NUM_LSB                  ;0x64 - 100
			cp c
			jp z,.SUB_MIDI_CTL_REGIST_PARM_NUM_LSB            

			ld a,MIDI_CTL_REGIST_PARM_NUM_MSB                 ;0x65 - 101
			cp c
			jp z,.SUB_MIDI_CTL_REGIST_PARM_NUM_MSB

			ld a,MIDI_CTL_SUSTAIN                           ;0x40 sustain pedal
			cp c
			jp z,.SUB_MIDI_CTL_SUSTAIN

			ld a,MIDI_CTL_SOSTENUTO
			cp c
			jp z,.SUB_MIDI_CTL_SOSTENUTO

			ret
.exxt:
			pop ix        
			ret

.SUB_MIDI_CTL_MSB_MAIN_VOLUME:
			ld (IX+MIDI_CHANNEL_DATA.gm_volume-128),d ;MIDI_CTL_MSB_MAIN_VOLUME
			ret
.SUB_MIDI_CTL_MSB_EXPRESSION:
			ld (IX+MIDI_CHANNEL_DATA.gm_expression-128),d 
			ret


.SUB_MIDI_CTL_MSB_MODWHEEL:
			ld (IX+MIDI_CHANNEL_DATA.vibrato-128),d 
			ld a,d
			ld (update_vibrato_depth.ctl_vibrato),a
;======================================
;do for channel 
			ld (.comparrerr),ix
			ld ix,g_header.g_voice_data
			ld iy,NR_OF_WAVE_CHANNELS        
.loop_v1:        
			ld a,(IX+VOICE_DATA.is_active)
			and a
			jr z,.nnofffooond
			ld hl,(IX+VOICE_DATA.midi_channel)
			ld de,0
.comparrerr:    equ $-2
			and a
			sbc hl,de        
			jr nz,.nnofffooond
			ld hl,(IX+VOICE_DATA.wave_data)
			push hl 
			pop iy     
			ld a,(IY+YRW801_WAVE_DATA.vibrato)
			ld (update_vibrato_depth.vibrato_data),a                
			;in - IX+VOICE_DATA
			push ix
			call update_vibrato_depth
			pop ix 
.nnofffooond:
            ld de,VOICE_DATA    
            add ix,de
            dec iyl
            jr nz,.loop_v1             
            ret    
.SUB_MIDI_CTL_MSB_PAN
            ld a,DRUM_CHANNEL
            cp e
            ret z       
            ld a,d
            sub 0x40
            sra a:sra a:sra a    
            ld (ix+MIDI_CHANNEL_DATA.panpot-128),a
            ret
;registered parameter (fine) 100
.SUB_MIDI_CTL_REGIST_PARM_NUM_LSB
			ld  (IX+MIDI_CHANNEL_DATA._MIDI_CTL_REGIST_PARM_NUM_LSB-128),d      
			ret     
;registered parameter (coarse) 101
.SUB_MIDI_CTL_REGIST_PARM_NUM_MSB
			ld  (IX+MIDI_CHANNEL_DATA._MIDI_CTL_REGIST_PARM_NUM_MSB-128),d
			ret 
 ;0x06   
.SUB_MIDI_CTL_MSB_DATA_ENTRY:
			ld  (IX+MIDI_CHANNEL_DATA._MIDI_CTL_LSB_DATA_ENTRY-128),0
			ld  (IX+MIDI_CHANNEL_DATA._MIDI_CTL_MSB_DATA_ENTRY-128),d
			jr .rpn
;0x26
.SUB_MIDI_CTL_LSB_DATA_ENTRY:
			ld  (IX+MIDI_CHANNEL_DATA._MIDI_CTL_LSB_DATA_ENTRY-128),d
.rpn:   
			;calculate rpn value
			ld h,0
			ld l,(IX+MIDI_CHANNEL_DATA._MIDI_CTL_MSB_DATA_ENTRY-128)
			SRL H
			RR L
			LD H, L
			LD L, 0
			RR L            ; hl <<7
			ld a,l
			or   (IX+MIDI_CHANNEL_DATA._MIDI_CTL_LSB_DATA_ENTRY-128)
			ld l,a
			push hl

			ld  a,(IX+MIDI_CHANNEL_DATA._MIDI_CTL_REGIST_PARM_NUM_MSB-128)
			and a
			jr nz,.rpn_ext            

			ld  a,(IX+MIDI_CHANNEL_DATA._MIDI_CTL_REGIST_PARM_NUM_LSB-128)
			cp 0      
			jr z,.pb_sens      
			cp 1
			jr z,.pb_finetun
			cp 2
			jr z,.pb_coarsetun
.rpn_ext
			pop hl
			ret
.pb_sens:
			pop hl
			ld (IX+MIDI_CHANNEL_DATA.gm_rpn_pitch_bend_range-128),hl
			ret
.pb_finetun:
			pop hl
			and a
			ld bc,8192
			sbc hl,bc
			ADD HL,HL    ;11       signed hl >> 7
			LD L,H    ;4
			SBC A    ;4
			LD H,A    ;4    23t
			ld (IX+MIDI_CHANNEL_DATA.gm_rpn_fine_tuning-128),hl     
			ret
.pb_coarsetun:
			pop hl
			and a
			ld bc,8192
			sbc hl,bc
			ld (IX+MIDI_CHANNEL_DATA.gm_rpn_coarse_tuning-128),hl     
			ret
.SUB_MIDI_CTL_SUSTAIN
			ld  (IX+MIDI_CHANNEL_DATA.gm_sustain-128),d
			ld a,d
			and a
			ret nz
			ld a,0xff
.SUB_MIDI_CTL_SUSTAIN_loop:
			ld  (.sustain_notev1),a
			ld  (.sustain_notev2),a
			push af
			cpl
			ld c,a   ; note
			ld e,0   ;midi channel
.sustain_midi_channel equ $-1                
			ld a,(ix+0)
.sustain_notev1 equ $-1
			AND SNDRV_MIDI_NOTE_RELEASED     ; bit 1,(ix+0)
			jp z,.SUB_MIDI_CTL_SUSTAIN_skip_loop                
			call _j_note_off_1
			ld (ix+0),SNDRV_MIDI_NOTE_OFF
.sustain_notev2 equ $-2
                      ;======= call noteoff  
.SUB_MIDI_CTL_SUSTAIN_skip_loop
			pop af      
			dec a
			cp 0x7f
			jr nz,.SUB_MIDI_CTL_SUSTAIN_loop
			ret 
.SUB_MIDI_CTL_SOSTENUTO:
			ld a,d
			and a
			jp z,.SUB_MIDI_CTL_SOSTENUTO_SWITCH_OFF
			;sostenuto switch on
			ld a,0xff
.sostenuto_sw_on_loop:
			ld (.sostenuto_sw_on_notevv1),a
			ld (.sostenuto_sw_on_notevv2),a
			push af 
			ld a,(ix+0)
.sostenuto_sw_on_notevv1 equ $-1
			ld c,a
			and SNDRV_MIDI_NOTE_ON             ;bit 0,(ix+0)
			jp z,.sostenuto_sw_on_skip_loop
			ld a,c
			or SNDRV_MIDI_NOTE_SOSTENUTO
			ld (ix+0),a                        ;set 2,(ix+0)
.sostenuto_sw_on_notevv2 equ $-1
.sostenuto_sw_on_skip_loop:
			pop af      
			dec a
			cp 0x7f
			jr nz,.sostenuto_sw_on_loop
			ret 
.SUB_MIDI_CTL_SOSTENUTO_SWITCH_OFF
			ld a,0xff
.sostenuto_sw_off_loop:
			ld (.sostenuto_sw_off_notevv1),a
			ld (.sostenuto_sw_off_notevv2),a
			ld (.sostenuto_sw_off_notevv3),a
			ld (.sostenuto_sw_off_notevv4),a
			push af
			ld c,a
			ld e,0
.sostenuto_midi_channel equ $-1
			bit 2,(ix+0)                ;if (note & SNDRV_MIDI_NOTE_SOSTENUTO) == 0
.sostenuto_sw_off_notevv1 equ $-2
			jp z,.sostenuto_sw_off_skip_loop
			res 2,(ix+0)            ;note[i] &= ~SNDRV_MIDI_NOTE_SOSTENUTO
.sostenuto_sw_off_notevv2 equ $-2
			bit 1,(ix+0)            ;if (note & SNDRV_MIDI_NOTE_RELEASED) == 0
.sostenuto_sw_off_notevv3 equ $-2
			jp z,.sostenuto_sw_off_skip_loop
			call _j_note_off_1
			ld (ix+0),SNDRV_MIDI_NOTE_OFF
.sostenuto_sw_off_notevv4 equ $-2
.sostenuto_sw_off_skip_loop:
			pop af      
			dec a
			cp 0x7f
			jr nz,.sostenuto_sw_off_loop
			ret 
			
_j_program_change:
					;b - data_byte_1 - command
					;c - data_byte_2 - new program number (instrument)
					;e - wave channel
			push ix
			ld a,e
			add a,a
			ld h,HIGH midi_ch_table
			ld l,a    
			ld a,(hl)    
			inc hl   
			ld h,(hl)
			ld l,a
			push hl
			pop ix
			ld a,c
			and 0x7f
			ld (ix+MIDI_CHANNEL_DATA.instrument-128),a
			pop ix
			ret

_j_channel_after_touch:
					;b - data_byte_1 - command
					;c - data_byte_2 - pressure
					;e - wave channel
			ret

_j_pitch_wheel:
;pitch_wheel(midi_channel, ((data_byte_3 <<= 7) | data_byte_2));
			memory_stream_read_1 d    ;data_byte_3 
									;b - data_byte_1 - command
									;c - data_byte_2 - pitch wheel 0lllllll
									;d - data_byte_3 - pitch wheel 0mmmmmmm
									;e - wave channel    
			push ix
			ld a,e
			add a,a
			ld h,HIGH midi_ch_table
			ld l,a    
			ld a,(hl)    
			inc hl   
			ld h,(hl)
			ld l,a
			push hl
			pop ix
			ld (.comparrerr),ix  ; store midi channel data 
			ld h,0
			ld l,d  
			SRL H   ;<<7
			RR L
			LD H, L
			LD L, 0
			RR L
			ld a,l
			or c
			ld l,a    ;hl - pitch wheel data combined 14bit
			ld bc,8192
			and a
			sbc hl,bc
			ld (ix+MIDI_CHANNEL_DATA.pitch_bend-128),hl    
			push iy
			ld ix,g_header.g_voice_data
			ld iy,NR_OF_WAVE_CHANNELS 
.loop_v1:        
            ld a,(IX+VOICE_DATA.is_active)
            and a
            jr z,.nnofffooond

            ld hl,(IX+VOICE_DATA.midi_channel)
            ld de,0
.comparrerr:    equ $-2
            and a
            sbc hl,de        
            jr nz,.nnofffooond
            push ix
			ld iy,(.comparrerr)
			;in ix - g_voice_data     iy - g_midi_channel_data
			call update_pitch
            pop ix 
.nnofffooond:
            ld de,VOICE_DATA    
            add ix,de
            dec iyl
            jr nz,.loop_v1             
			pop iy 
			pop ix 
			ret



_j_note_on:
			memory_stream_read_1 d   ;data_byte_3 
									;b - data_byte_1 - command
									;c - data_byte_2 - note
									;d - data_byte_3 - velocity
									;e - midi channel
            ld a,d
            and 0x7f
            jp z,_j_note_off_1
            ld (.on_v_midi_veloc),a
            ld a,c
            and 0x7f
            ld (.on_v_midi_note),a
            cpl
            ld (._note_evv),a
			push ix
			ld a,e
			add a,a
			ld h,HIGH midi_ch_table
			ld l,a    
			ld a,(hl)    
			inc hl   
			ld h,(hl)
			ld l,a
			ld (.on_v_midi_ch),hl
			push hl 
			pop ix     
			ld (ix+0),SNDRV_MIDI_NOTE_ON            ; DD 21 offset value ;MIDI_CHANNEL_DATA note status
._note_evv equ $-2
			ld a,(ix+MIDI_CHANNEL_DATA.vibrato-128)
			ld (update_vibrato_depth.ctl_vibrato),a
			xor a
			ld (n_on_voices),a
			ld hl,n_on_data
			ld (n_on_data_ptr),hl
			ld a,(ix+MIDI_CHANNEL_DATA.drum_channel-128)
			and a
			jr z,.not_drum_chanel
.drummsssss
			ld hl,snd_yrw801_regions+0x80*2
			ld a,(hl)
			inc hl
			ld h,(hl)
			ld l,a    ;hl - pointer to regions_drums
			;ld a,(.on_v_midi_note) 
			ld a,c 
			cp 0x23
			jp c,.exit_sub        
			cp 0x53
			jp nc,.exit_sub        
			sub 0x1a+9
			ld d,0
			ld e,a
			ex de,hl
			add hl,hl
			add hl,hl
			add hl,hl
			add hl,hl
			add hl,de
			inc hl:inc hl   ;hl = drums wave data region
			ld de,(n_on_data_ptr)
			ld a,l
			ld (de),a
			inc de
			ld a,h
			ld (de),a
			ld hl,(n_on_data_ptr)
			ld de,4
			add hl,de
			ld (n_on_data_ptr),hl
			ld hl,n_on_voices
			inc (hl)
			jr .n_on_alloc_init_voices  
.not_drum_chanel:
			ld a,(ix+MIDI_CHANNEL_DATA.instrument-128)
			add a,a
			ld d,0
			ld e,a
			ld hl,snd_yrw801_regions
._drum_chanel:
			add hl,de         
			ld a,(hl)
			inc hl
			ld h,(hl)
			ld l,a      ;hl - instrument region
.loop_nd
			ld a,(hl)
			cp 0xff
			jr z,.n_on_alloc_init_voices
			cp c
			jr z,.found_by_low
			jr c,.check_by_high                
			ld de,16
			add hl,de
			jr .loop_nd
.check_by_high:
			inc hl
			ld a,(hl)
			cp c
			jr z,.found_by_high
			jr nc,.found_by_high

			ld de,15
			add hl,de
			jr .loop_nd
.found_by_low:
			inc hl
.found_by_high:
			inc hl 
			ld de,(n_on_data_ptr)
			ld a,l
			ld (de),a
			inc de
			ld a,h
			ld (de),a
			push hl
			ld hl,(n_on_data_ptr)
			ld de,4
			add hl,de
			ld (n_on_data_ptr),hl
			ld hl,n_on_voices
			inc (hl)
			pop hl
			ld de,14
			add hl,de
			ld a,(n_on_voices)
			cp 2
			jr nc,.n_on_alloc_init_voices
			jr .loop_nd 
.n_on_alloc_init_voices:
            ld a,(n_on_voices)
            and a
            jp z,.exit_sub        
            ld (.n_onv_test),a
            ld (.n_onv_test2),a
            ld (.n_onv_test4),a
            ld (.n_onv_test5),a
			xor a   ;voice number for loop
.gv_loop:     
			push af
			; get wave data adress by voice number
			add a,a
			add a,a    
			ld d,0
			ld e,a                    
			ld hl,n_on_data
			add hl,de
			ld e,(hl)
			inc hl
			ld d,(hl)
			inc hl 
			push de     ;wave data adress in yrw801 table     
			push hl   ;store pointer
			call get_voice  ;out  
			pop hl   
.checkpoint:
			;ix = free_voice  
			ld a,ixl                          
			ld (hl),a      ;ld (hl),e
			inc hl
			ld a,ixh 
			ld (hl),a      ;ld (hl),d
			ld (ix+VOICE_DATA.is_active),1
			ld hl,(g_MIDI_counter)
			LD (ix+VOICE_DATA.activated),hl 
			ld hl,(g_MIDI_counter+2)
			LD (ix+VOICE_DATA.activated+2),hl 
			ld de,0
.on_v_midi_ch: equ $-2       
			ld (ix+VOICE_DATA.midi_channel),de
			ld (ix+VOICE_DATA.note),0
.on_v_midi_note	equ $-1  
			ld (ix+VOICE_DATA.velocity),0
.on_v_midi_veloc	equ $-1
			pop hl
			ld (ix+VOICE_DATA.wave_data),hl
			pop af
			inc a  
			cp 0
.n_onv_test equ $-1
			jr nz,.gv_loop                   
			xor a   ;voice number for loop
.gr_loop:     
			push af
; get wave data adress by voice number
			add a,a
			add a,a    
			ld d,0
			ld e,a                    
			ld hl,n_on_data
			add hl,de
			ld e,(hl)
			inc hl
			ld d,(hl)
			inc hl    
			push de
			pop iy    ; iy wave data pointer
			ld e,(hl)
			inc hl
			ld d,(hl)
			push de 
			pop ix    ;ix - voice data pointer
/* Set tone number (triggers header loading) */
			ld a,(iy+YRW801_WAVE_DATA.panpot)
			ld (update_pan.yrw_panpot),a
			ld a,(iy+YRW801_WAVE_DATA.tone_attenuate)
			ld (update_volume.yrw_tone_attenuate),a
			ld a,(iy+YRW801_WAVE_DATA.volume_factor)
			ld (update_volume.yrw_volume_factor),a
			ld hl,(IY+YRW801_WAVE_DATA.tone)
			push hl
			ld a,h
			and OPL4_TONE_NUMBER_BIT8
			ld (ix+VOICE_DATA.reg_f_number),a
			ld d,a    
			LD a,(ix+VOICE_DATA.number)                     
			add a,OPL4_REG_F_NUMBER
			ld e,a
			call opl4writewave                       
			pop hl                            
			ld d,l
			LD a,(ix+VOICE_DATA.number)                     
			add a,OPL4_REG_TONE_NUMBER
			ld e,a
			call opl4writewave                                          
/* Set parameters which can be set while loading */
			ld (ix+VOICE_DATA.reg_misc),OPL4_LFO_RESET_BIT
			ld hl,(ix+VOICE_DATA.midi_channel)
			push hl
			pop iy
			call update_pan
			call update_pitch
			ld (ix+VOICE_DATA.level_direct),OPL4_LEVEL_DIRECT_BIT    
			call update_volume
			pop af
			inc a  
			cp 0
.n_onv_test2 equ $-1
			jp nz,.gr_loop 
.ello
			in a,(MOON_STAT)
			and 0x02
			jr nz,.ello
			xor a   ;voice number for loop
.gn_loop:     
			push af
			; get wave data adress by voice number
			add a,a
			add a,a    
			ld d,0
			ld e,a                    
			ld hl,n_on_data
			add hl,de
			ld e,(hl)
			inc hl
			ld d,(hl)
			inc hl    
			push de
			pop iy    ; iy wave data pointer
			ld e,(hl)
			inc hl
			ld d,(hl)
			push de 
			pop ix    ;ix - voice data pointer
			ld h,(IX+VOICE_DATA.number)
			ld a,(IY+YRW801_WAVE_DATA.vibrato)
			ld (update_vibrato_depth.vibrato_data),a
			;update tone parameters
			ld d,(IY+YRW801_WAVE_DATA.reg_attack_decay1)
			ld a,OPL4_REG_ATTACK_DECAY1
			add a,h;(IX+VOICE_DATA.number)
			ld e,a
			call opl4writewave
			ld d,(IY+YRW801_WAVE_DATA.reg_level_decay2)
			ld a,OPL4_REG_LEVEL_DECAY2
			add a,h;(IX+VOICE_DATA.number)
			ld e,a
			call opl4writewave
			ld d,(IY+YRW801_WAVE_DATA.reg_release_correction)
			ld a,OPL4_REG_RELEASE_CORRECTION
			add a,h;(IX+VOICE_DATA.number)
			ld e,a
			call opl4writewave
			ld d,(IY+YRW801_WAVE_DATA.reg_tremolo)
			ld a,OPL4_REG_TREMOLO
			add a,h;(IX+VOICE_DATA.number)
			ld e,a
			call opl4writewave
			ld a,(IY+YRW801_WAVE_DATA.reg_lfo_vibrato)
			ld (IX+VOICE_DATA.reg_lfo_vibrato),a
			push hl   
			ld hl,(IX+VOICE_DATA.midi_channel)
			push hl
			pop iy
			ld a,(IY+MIDI_CHANNEL_DATA.drum_channel-128)
			and a
			call z,update_vibrato_depth
			pop hl
			pop af
			inc a  
			cp 0
.n_onv_test4 equ $-1
			jr nz,.gn_loop 

			xor a   ;voice number for loop
.gn5_loop:     
			push af
			; get wave data adress by voice number
			add a,a
			add a,a    
			ld d,0
			ld e,a                    
			ld hl,n_on_data
			add hl,de
			ld e,(hl)
			inc hl
			ld d,(hl)
			inc hl    
			push de
			pop iy    ; iy wave data pointer
			ld e,(hl)
			inc hl
			ld d,(hl)
			push de 
			pop ix    ;ix - voice data pointer
			ld a,(ix+VOICE_DATA.reg_misc)
			and 00011111b
			or OPL4_KEY_ON_BIT
			ld (IX+VOICE_DATA.reg_misc),a
			ld d,a
			ld a,OPL4_REG_MISC
			add a,(IX+VOICE_DATA.number)
			ld e,a
			call opl4writewave
			pop af
			inc a  
			cp 0
.n_onv_test5 equ $-1
			jr nz,.gn5_loop 
.exit_sub
			pop ix
			ret


update_vibrato_depth:
			ld hl,0x007
			ld d,0         ;d=0
			ld e,0  
.vibrato_data equ $-1                   ;(IY+YRW801_WAVE_DATA.vibrato)
			push de            ;save YRW801_WAVE_DATA.vibrato
			and a
			sbc hl,de
			ex de,hl  ; de - 7-YRW801_WAVE_DATA.vibrato
			ld a,0
.ctl_vibrato equ $-1
			and 0x7f
			ld hl,0
			ld c,0
			call mult_de_a      ;de * midi_channel->vibrato
			;hl = depth
			ADD HL,HL    ;11       signed hl >> 7
			LD L,H    ;4
			SBC A    ;4
			LD H,A    ;4    23t
			pop de
			add hl,de   ;l = depth + YRW801_WAVE_DATA.vibrato    ;  h is unused
			ld a,l
			and OPL4_VIBRATO_DEPTH_MASK                                                             
			ld l,a           ; l = depth & OPL4_VIBRATO_DEPTH_MASK
			ld a,(ix+VOICE_DATA.reg_lfo_vibrato)
			and OPL4_VIBRATO_DEPTH_MASK_INV
			or l
			ld (ix+VOICE_DATA.reg_lfo_vibrato),a
			ld d,a
			ld a,OPL4_REG_LFO_VIBRATO
			add a,(ix+VOICE_DATA.number)
			ld e,a
			jp opl4writewave
			
update_pan:

            ld d,0     ;l        d d,(iy+YRW801_WAVE_DATA.panpot)
.yrw_panpot   equ $-1
			ld a,(iy+MIDI_CHANNEL_DATA.drum_channel-128)
			and a
			jr nz,.drum_is
			ld a,(iy+MIDI_CHANNEL_DATA.panpot-128)
			add a,d
			ld d,a
.drum_is:
			bit 7,d
			ld a,d
			jr nz,.below_zero
			cp 8
			jr c,.adv_run  
			ld a,7
			jr .adv_run  
.below_zero:
			cp 0xf9   ;-1
			jr nc,.adv_run
			ld a,0xf9                
.adv_run    
			and OPL4_PAN_POT_MASK
			ld d,a
			ld a,(ix+VOICE_DATA.reg_misc)
			and OPL4_PAN_POT_MASK_INV
			or d
			ld (ix+VOICE_DATA.reg_misc),a
			ld d,a
			ld a,(ix+VOICE_DATA.number)
			add a,OPL4_REG_MISC
			ld e,a
			jp opl4writewave


update_pitch:
			push ix
			ld hl,(ix+VOICE_DATA.wave_data)         
			ld a,h
			or l
			jp z,.rerett2
			push hl
			pop ix
			ld a,(ix+YRW801_WAVE_DATA.key_scaling)    
			ld hl,(ix+YRW801_WAVE_DATA.pitch_offset) 
			jp .rerett1
.rerett2
            ld a,100        
            ld hl,0
.rerett1:
			ld (.key_scaling),a
			ld (.pitch_offset),hl
			pop ix

			ld a,(iy+MIDI_CHANNEL_DATA.drum_channel-128)
			and a
			ld de,0:ld h,d:ld l,e   ;pitch int32_t
			jp nz,.drum_is
			;;;;int32_t pitch = (voice->midi_channel->drum_channel) ? 0 : voice->note - 60;
			ld l,(ix+VOICE_DATA.note)
			and a
			ld bc,60
			sbc hl,bc
			;hl - int16_t   - pitch                    
			SRL H
			RR L
			LD H, L
			LD L, 0
			RR L           ;hl*128
			bit 7,h               
			jp z,.drum_is
			dec de                                                                                                                
.drum_is
.key_scaling equ $+1
			ld a, 0 ;(IY+MIDI_CHANNEL_DATA.key_scaling-128)
			cp 100
			jp z,._skip_math
;pitch = (pitch * voice->wave_data->key_scaling) / 100;
; dehl    int32_t pitch
;a - int8_t   key_scaling

			push de
			pop bc
			ex de,hl                    
			push ix
			call BCDE_Times_A    ;Outputs: A:HL:IX is the 40-bit product, BC,DE unaffected
			push hl,ix
			pop hl,de
			bit 7,b    
			jp z,.positive_div
.negative_div                                        
			ld a,h:cpl:ld h,a
			ld a,l:cpl:ld l,a
			ld a,d:cpl:ld d,a
			ld a,e:cpl:ld e,a                                  
			ld c,100
			call DEHL_Div_C    
			ld a,h:cpl:ld h,a
			ld a,l:cpl:ld l,a
			ld a,d:cpl:ld d,a
			ld a,e:cpl:ld e,a                                  
			jp .prrr
.positive_div        
			ld c,100
			call DEHL_Div_C
.prrr
; DEHL is the result of the division
			pop ix
._skip_math                     
;pitch = pitch + 7680      
			ld bc,7680   ;(60 << 7)
			add hl,bc
			ld bc,0
			ex de,hl 
			adc hl,bc
			ex de,hl
;pitch = pitch +  voice->wave_data->pitch_offset;
.pitch_offset: equ $+1        
			ld bc,0  ;(IY+MIDI_CHANNEL_DATA.pitch_offset-128)
			add hl,bc
			ld bc,0
			ex de,hl 
			adc hl,bc
			ex de,hl
;	if (!chan->drum_channel)
;		pitch += chan->gm_rpn_coarse_tuning;
			ld a,(IY+MIDI_CHANNEL_DATA.drum_channel-128)
			and a
			jp nz,._its_drum_channel
			ld bc,(IY+MIDI_CHANNEL_DATA.gm_rpn_coarse_tuning-128)
			add hl,bc
			ld bc,0
			ex de,hl 
			adc hl,bc
			ex de,hl                            
._its_drum_channel
;	pitch += chan->gm_rpn_fine_tuning >> 7;

			ld bc,(IY+MIDI_CHANNEL_DATA.gm_rpn_fine_tuning-128)
			add hl,bc
			ld bc,0
			ex de,hl 
			adc hl,bc
			ex de,hl 

;	pitch += chan->midi_pitchbend * chan->gm_rpn_pitch_bend_range / 0x2000;

			ld bc,(IY+MIDI_CHANNEL_DATA.pitch_bend-128)
			ld a,b
			or c
			jp z,.skip_math2    
			push de
			push hl
			ld de,(IY+MIDI_CHANNEL_DATA.gm_rpn_pitch_bend_range-128)
			call intmul16
			exx                                                            
			ld de,0x0000                                                           
			ld hl,0x2000               
			exx                                                                    
			push ix,iy
			call uintdiv32                                                 
			pop iy,ix  
			pop de
			add hl,de
			pop de    
.skip_math2
.limiter
			bit 7,h ;d
			jp nz,.ll3z  
			ld a,h
			cp 0x60
			jp c,.dsds            
			ld hl,0x5fff
			jp .dsds            
.ll3z
			;value is negative
			ld hl,0
.dsds:
			;hl - pitch
			ld de,0x600
			ld a,h
			ld c,l
			call div_ac_de      ;c = octave  ;hl - remainder
			ld a,c
			sub 8
			add a,a:add a,a:add a,a:add a,a
			ld (.octave),a     ;c - octave   .octave - octave<<4
			add hl,hl
			ld de,g_wave_pitch_map
			add hl,de 
			ld a,(hl)  
			inc hl
			ld h,(hl)
			ld l,a    ;hl = fnumber pitch from ms_wave_pitch_map                           
			push hl
			;fnumber >>7
			ADD HL,HL    ;11       signed hl >> 7
			LD L,H    ;4
			SBC A    ;4
			LD H,A    ;4    23t
			ld a,l
			and OPL4_F_NUMBER_HIGH_MASK
			ld d,a
			ld a,0
.octave    equ $-1
			or d
			ld d,a
			ld a,OPL4_REG_OCTAVE
			add a,(IX+VOICE_DATA.number)
			ld e,a
			call opl4writewave
			pop hl
			ld a,l
			add a,a
			and OPL4_F_NUMBER_LOW_MASK
			ld d,a
			ld a,(IX+VOICE_DATA.reg_f_number)
			and OPL4_TONE_NUMBER_BIT8
			or d
			ld (ix+VOICE_DATA.reg_f_number),a
			ld d,a
			ld a,OPL4_REG_F_NUMBER
			add a,(ix+VOICE_DATA.number)
			ld e,a
			call opl4writewave
			ret
            
            
update_volume:
			ld d,0
			ld e,0   ;(IY+YRW801_WAVE_DATA.tone_attenuate)  ;att
.yrw_tone_attenuate equ $-1
;att += snd_opl4_volume_table[voice->chan->gm_volume & 0x7f];
			push ix
			ld hl,(ix+VOICE_DATA.midi_channel)
			push hl
			pop ix
			ld l,(IX+MIDI_CHANNEL_DATA.gm_volume-128)   
			ld h,HIGH g_volume_table

			ld a,e
			add a,(hl)    ;att+=midi_ch.gm_volume
			ld e,a

			ld a,d
			adc a,0
			ld d,a	

;att += snd_opl4_volume_table[voice->chan->gm_expression & 0x7f];
			ld l,(IX+MIDI_CHANNEL_DATA.gm_expression-128)   
			ld a,e
			add a,(hl)    ;att+=midi_ch.expression
			ld e,a
			ld a,d
			adc a,0
			ld d,a	
			;att += snd_opl4_volume_table[voice->velocity];
			pop ix 
			ld l,(ix+VOICE_DATA.velocity)
			ld a,e
			add a,(hl)    ;att+=voice.velocity
			ld e,a
			ld a,d
			adc a,0
			ld d,a	
			ld hl,0x007f
			and a
			sbc hl,de 
			ex de,hl  ;de = (0x7f-att)
			ld a,0   ;(IY+YRW801_WAVE_DATA.volume_factor)
.yrw_volume_factor equ $-1
			ld hl,0
			ld c,0
			call mult_de_a
			ld c,0xfe
			bit 7,h
			jr z,.positive
			ld a,h:cpl:ld h,a
			ld a,l:cpl:ld l,a
			call div_hl_c        
			ld a,h:cpl:ld h,a
			ld a,l:cpl:ld l,a
			jr .contaa
.positive
			call div_hl_c        

.contaa
			ld de,0x007f
			ex de,hl
			and a
			sbc hl,de
			ld a,(g_volume_boost)
			ld e,a
			ld d,0
			and a
			sbc hl,de
			bit 7,h
			jr nz,.below_zero
			ld a,l
			cp 0x7f
			jr c,.okk  ;value in 0 -0x7e
			ld a,0x7e           ;value is positive
			jr .okk
.below_zero
			;value is negative
			ld a,0
.okk:
			add a,a
			or (ix+VOICE_DATA.level_direct)
			ld d,a
			ld a,OPL4_REG_LEVEL     
			add a,(ix+VOICE_DATA.number)
			ld e,a
			call opl4writewave
			ld (ix+VOICE_DATA.level_direct),0
			ret           
            
        
handle_meta_event:         
			ld a,c  
			cp 0x2f
			jr z,.endoftrack
			cp 0x51
			jr z,.setduration
			
			ld hl,(memorystreamcurrentaddr)
			call midreadvarint  ;;read count of upcoming parameters
			ld a,e
			or d
			jr z,.skipall
			ld a,e
			dec de
			inc d
			ld c,d
			ld b,a
.skiploop:
			bit 6,h
			call nz,memorystreamnextpage
			inc hl
			djnz .skiploop
			dec c
			jr nz,.skiploop
.skipall:
			ld (memorystreamcurrentaddr),hl
			ret
.endoftrack
			ld a,255
			ld (ix+TRACK_DATA.track_finished),a
			ret
.setduration
			ld hl,(memorystreamcurrentaddr)
			call midreadvarint  ;read count of upcoming parameters
			memory_stream_read_byte a
			memory_stream_read_byte d
			memory_stream_read_byte e
			ld (memorystreamcurrentaddr),hl
			ex de,hl
			ld e,a
			ld d,0
			push ix
			call setticksperupdate
			pop ix
			ret    
finalize:
			ld hl,(memorystreamcurrentaddr)
			call midreadvarint                  ;read delta-time
			ld (memorystreamcurrentaddr),hl
			ex de,hl
			xor a
			add hl,hl : rl c : rla
			add hl,hl : rl c : rla
			add hl,hl : rl c : rla
			add hl,hl : rl c : rla
			ld b,a
			ld de,(ix+TRACK_DATA.waiting_for+0)
			add hl,de
			ld (ix+TRACK_DATA.waiting_for+0),hl
			ld hl,(ix+TRACK_DATA.waiting_for+2)
			adc hl,bc
			ld (ix+TRACK_DATA.waiting_for+2),hl
			ret

                                                ;gv_wavedata dw 0   
    
    
get_voice:    
;in de - wave data
			ld ix,g_header.g_voice_data
			ld (free_voice),ix
			ld (oldest_voice),ix
			ld bc,NR_OF_WAVE_CHANNELS
.loop3
			LD a,(ix+VOICE_DATA.is_active)
			and a
			jr z,.voice_not_active
			;voice active
			ld iy,(oldest_voice)
			and a 
			ld l,(ix+VOICE_DATA.activated)
			ld h,(ix+VOICE_DATA.activated+1)
			ld e,(iy+VOICE_DATA.activated)
			ld d,(iy+VOICE_DATA.activated+1)
			sbc hl,de
			ld l,(ix+VOICE_DATA.activated+2)
			ld h,(ix+VOICE_DATA.activated+3)
			ld e,(iy+VOICE_DATA.activated+2)
			ld d,(iy+VOICE_DATA.activated+3)
			sbc hl,de
			jr nc,.loop_ext
.old_greater:
			ld (oldest_voice),ix
			jp .loop_ext
.voice_not_active:
            ;voice inactive
.vo_not_cat_not_match:
            ld iy,(free_voice)
            and a
            ld l,(ix+VOICE_DATA.activated)
            ld h,(ix+VOICE_DATA.activated+1)
            ld e,(iy+VOICE_DATA.activated)
            ld d,(iy+VOICE_DATA.activated+1)
        	sbc hl,de
            ld l,(ix+VOICE_DATA.activated+2)
            ld h,(ix+VOICE_DATA.activated+3)
            ld e,(iy+VOICE_DATA.activated+2)
            ld d,(iy+VOICE_DATA.activated+3)
        	sbc hl,de
            jr nc,.loop_ext  ;jr nc,.loop_ext  
.vo_old_greater:
			ld (free_voice),ix
			jr .loop_ext

.loop_ext:
        	ld de,VOICE_DATA
        	add ix,de
        	;dec iyl
            dec c
        	jp nz,.loop3
.loop_exit
;    /* If no free voice found, deactivate the 'oldest' */
;    if(free_voice->is_active)
;    {
;        free_voice = oldest_voice;
;        free_voice->activated = 0;
;
;        free_voice->reg_misc &= ~OPL4_KEY_ON_BIT;
;        g_roboplay_interface->opl_write_wave(OPL4_REG_MISC + free_voice->number, free_voice->reg_misc);
;    }

			ld ix,(free_voice)
			ld a,(ix+VOICE_DATA.is_active)
			and a
			ret z
			ld ix,(oldest_voice)
			ld (free_voice),ix
			xor a
			ld (ix+VOICE_DATA.activated),a
			ld (ix+VOICE_DATA.activated+1),a
			ld (ix+VOICE_DATA.activated+2),a
			ld (ix+VOICE_DATA.activated+3),a        
			ld a,(ix+VOICE_DATA.reg_misc)
			and OPL4_KEY_ON_BIT_INV
			LD (ix+VOICE_DATA.reg_misc),a
			ld d,a
			;g_roboplay_interface->opl_write_wave(OPL4_REG_MISC + voice->number, voice->reg_misc);
			LD a,(ix+VOICE_DATA.number)
			add a,OPL4_REG_MISC
			ld e,a
			jp opl4writewave

;=================================================================
midgetprogress
;dehl = ticks
;out: a = progress
	ld a,e
	add hl,hl : rla
	add hl,hl : rla
	ret
	
midsetprogressdelta	
        	ld ix,g_header.g_track_data
        	ld a,(g_header.number_of_tracks)
			ld b,a
			ld c,0
.trackloop
			push bc
			ld hl,(ix+TRACK_DATA.currentoffset+0)
			ld de,(ix+TRACK_DATA.currentoffset+2)
			call memorystreamseek
.eventloop
			call midadvancetrack
			bit 7,(ix+TRACK_DATA.track_finished)
			jr z,.eventloop
			ld hl,(ix+TRACK_DATA.waiting_for+0)
			ld de,(ix+TRACK_DATA.waiting_for+2)
			call midgetprogress
			pop bc
			cp c
			jr c,$+3
			ld c,a
			ld de,TRACK_DATA
			add ix,de
			djnz .trackloop
			ld a,c
			jp setprogressdelta

midadvancetrack
;ix = track
		ld hl,(memorystreamcurrentaddr)
		memory_stream_read_byte b
		bit 7,b
		jr z,.gotdatabyte
		ld (ix+TRACK_DATA.last_command),b
		memory_stream_read_byte d
		jr .handlecommand
.gotdatabyte
		ld d,b
		ld b,(ix+TRACK_DATA.last_command)
.handlecommand
		ld a,b
		rrca
		rrca
		rrca
		rrca
		and 7
		ld c,a
		add a,a
		add a,c
		ld (.commandtable),a
.commandtable=$+1
		jr $
		jp .send3 ; 8 Note Off
		jp .send3 ; 9 Note On
		jp .send3 ; A Polyphonic Pressure
		jp .send3 ; B Control Change	
		jp .send2 ; C Program Change
		jp .send2 ; D Channel Pressure
		jp .send3 ; E Pitch Bend
;;;;;;;;;;;;;;;;;;; F System
		ld a,b
		cp 0xff
		jp z,.handlemeta
		cp 0xf0
		jp nz,.finalize
		call midreadvarint
		ld d,0xf0
;		call_send_byte
.sendloop
		memory_stream_read_byte e
		ld d,e
;		call_send_byte
		ld a,e
		cp 0xf7
		jr nz,.sendloop
		ld (memorystreamcurrentaddr),hl
		jr .finalize
.handlemeta
		ld a,d
		cp 0x2f
		jr z,.markdone
		cp 0x51
		jr z,.setduration
		call midreadvarint
		ld a,e
		or d
		jr z,.finalize
		ld a,e
		dec de
		inc d
		ld c,d
		ld b,a
.skiploop
		bit 6,h
		call nz,memorystreamnextpage
		inc hl
		djnz .skiploop
		dec c
		jr nz,.skiploop
		ld (memorystreamcurrentaddr),hl
		jr .finalize
.markdone
		set 7,(ix+TRACK_DATA.track_finished)
		ret
.setduration
		call midreadvarint
		memory_stream_read_byte a
		memory_stream_read_byte d
		memory_stream_read_byte e
		ld (memorystreamcurrentaddr),hl
		ex de,hl
		ld e,a
		ld d,0
		push ix
		call setticksperupdate
		pop ix
		jr .finalize
.send2	ld (memorystreamcurrentaddr),hl
		ld l,d
		ld h,b
;		call_send_2
	jr .finalize
.send3	memory_stream_read_byte e
		ld (memorystreamcurrentaddr),hl
		ex de,hl
		ld d,b
;		call_send_3
.finalize
		ld hl,(memorystreamcurrentaddr)
		call midreadvarint
		ld (memorystreamcurrentaddr),hl
		ex de,hl
		xor a
		add hl,hl : rl c : rla
		add hl,hl : rl c : rla
		add hl,hl : rl c : rla
		add hl,hl : rl c : rla
		ld b,a
		ld de,(ix+TRACK_DATA.waiting_for+0)
		add hl,de
		ld (ix+TRACK_DATA.waiting_for+0),hl
		ld hl,(ix+TRACK_DATA.waiting_for+2)
		adc hl,bc
		ld (ix+TRACK_DATA.waiting_for+2),hl
		ret
	