;Recomposer MIDI player v1.0 	28.11.2025
bpm_setticksperupdate:
			
;c = tempo in bpm
;60 000 000 / bpm
			ld l,c
			ld h,0: ld d,h: ld e,h
			exx
			ld de,0x0393
			ld hl,0x8700   ;60 000 000
			call uintdiv32     ; 60 000 000 / bpm
			
			exx
			ld hl,(g_header.ticksperqnoteXupdatelen+0)
			ld de,(g_header.ticksperqnoteXupdatelen+2)
			call uintdiv32

			ld (release_expired_notes.g_ticks_per_update_low),hl
			ld (rcp_play.g_ticks_per_update_low),hl
			
			ld (g_ticks_per_update_high),de
			ret
;===================================================================
rcp_play:
			ld hl,(tick_counter+0)			
.g_ticks_per_update_low = $+1
			ld de,0
			add hl,de
			ld (tick_counter+0),hl
			ld hl,(tick_counter+2)
			ld de,0
			adc hl,de
			ld (tick_counter+2),hl
			
;iterate through the tracks
        	ld ix,g_header.g_track_data
        	ld a,(g_header.detected_tracks)
        	ld b,a
			ld c,0        	
.trackloop:
			push bc
			call release_expired_notes
			pop bc

.innertrackloop:	
			ld a,(IX+TRACK_DATA.midi_ch) 
			cp 0xff						; if track muted
			jr z,.skiptrack			

			ld c,255

			ld hl,(tick_counter+0)
			ld de,(ix+TRACK_DATA.waiting_for+0)
			sub hl,de
			ld hl,(tick_counter+2)
			ld de,(ix+TRACK_DATA.waiting_for+2)
			sbc hl,de
			jr c,.skiptrack

			push bc
.handle_track_event:
			ld hl,(ix+TRACK_DATA.currentoffset+0)
			ld de,(ix+TRACK_DATA.currentoffset+2)
			call memorystreamseek


			memory_stream_read_byte a
			ld (_id),a
			memory_stream_read_byte a
			ld (_p0),a
			memory_stream_read_byte a
			ld (_p1),a
			memory_stream_read_byte a
			ld (_p2),a

			ld (memorystreamcurrentaddr),hl
			
			call process_rcp_event
			inc  (IX+TRACK_DATA.same_measure_commands)
						
			pop bc
			jp .innertrackloop
.skiptrack
        	ld de,TRACK_DATA
        	add ix,de
			dec b
        	jp nz,.trackloop
        	ld a,c
        	or a          ;a !0 track still play  0 - finished
        	ret
			
_id: 	db 0
_p0: 	db 0
_p1: 	db 0
_p2: 	db 0
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
release_expired_notes:
			
			push ix
			pop hl
			ld bc,TRACK_DATA.note_tracer
			add hl,bc
			ld b,NOTE_TRACER_ENTRIES
.ren_loop:
			push bc

			ld a,(hl)
			ld c,a
			and a
			jr z,.to_next_record

			push hl
            inc hl
			ld a,(hl)
			inc hl
			ld h,(hl)
			ld l,a
.g_ticks_per_update_low: equ $+1
			ld de,0
			and a
			sbc hl,de
			jp z,.sss
			jp nc,.not_expired			
.sss			
			pop hl
;			ld c,(hl)
			ld (hl),0
			push hl
			call _j_note_off   ;c - note  ;ix - TRACK_DATA
			pop hl
.to_next_record:
			inc hl
			inc hl
.ren_in_p:
			inc hl
			pop bc
			djnz .ren_loop
			ret			


.not_expired
			;save corrected delay
			ex de,hl
			pop hl
			inc hl
			ld (hl),e
			inc hl
			ld (hl),d
			jp .ren_in_p

.note_expired:

	
process_rcp_event
			ld a,(_id)
			cp 0x80
			jp c,_j_note_on
			sub 0xe0
			jp c,finalize ;skip sysex cmd range (0x80 - 0xdf)
			ld l,a
			ld h,0
			add hl,hl
			ld de,rcp_commands_table
			add hl,de
			ld a,(hl)
			inc hl
			ld h,(hl)
			ld l,a
			jp (hl)
			
rcp_commands_table:
			dw cmd_unsupported
			dw cmd_unsupported
			dw cmd_set_bank_instrument ;0xe2+
			dw cmd_unsupported
			dw cmd_unsupported
			dw cmd_unsupported
			dw cmd_set_channel   	;0xe6 +
			dw cmd_set_tempo		;0xe7 +
			dw cmd_unsupported
			dw cmd_unsupported
			dw cmd_unsupported
			dw cmd_control_change	;0xeb +
			dw cmd_set_instrument	;0xec +
			dw cmd_unsupported
			dw cmd_pitch_bend		;0xee +
			dw cmd_unsupported
			dw cmd_unsupported
			dw cmd_unsupported2
			dw cmd_unsupported2
			dw cmd_unsupported2
			dw cmd_unsupported2
			dw cmd_unsupported2
			dw cmd_unsupported2
			dw cmd_unsupported2
			dw cmd_loop_end			;0xf8
			dw cmd_loop_start		;0xf9
			dw cmd_unsupported2
			dw cmd_unsupported2
			dw cmd_same_measure		;0xfc
			dw cmd_measure_end		;0xfd
			dw cmd_track_end		;0xfe
			dw cmd_track_end		;0xff (unofficial)					
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
cmd_unsupported2:
finalize2:
			xor a
			ld (_p0),a
cmd_unsupported:
			jp finalize
;<---
cmd_track_end:
			ld (ix+TRACK_DATA.midi_ch),0xff
			jp finalize2	
;<---
cmd_set_tempo:
			push ix
			ld a,(_p1)	
			ld l,a
			ld a,(_p2)	
 
			ld      a, (g_header.tempo)
			call    _tempo_change_calculation
			add     hl, hl
			add     hl, hl
			ld      c, h            ; c - new tempo in bpm
			call bpm_setticksperupdate
			pop ix
			jp finalize
			
_tempo_change_calculation:
                push    de
                ld      h, 0
                ld      e, l
                ld      d, h
                ld      l, h
.loc_10C1F:                              ; CODE XREF: _tempo_change_calculation_sub_10C19+10↓j
                srl     a
                jr      nc, .loc_10C24
                add     hl, de
.loc_10C24:                              ; CODE XREF: _tempo_change_calculation_sub_10C19+8↑j
                sla     e
                rl      d
                or      a
                jr      nz, .loc_10C1F
                pop     de
                ret
cmd_set_channel:
			ld a,(_p1)
			and a
			jp z,.csc_cont  ;mute channel
			cp 17
			jp c,.csc_cont  ;midi 0 device
			xor a			;midi 1 device. mute 
.csc_cont:			
			dec a
			ld (ix+TRACK_DATA.midi_ch),a

			ld a,1
			ld (_p0),a
			jp finalize
			
cmd_set_bank_instrument:
cmd_set_instrument:
_j_program_change:
			push ix
            ;ld hl,(ix+TRACK_DATA.midi_ch_addr)
			
            ld a,(ix+TRACK_DATA.midi_ch)
            add a,a
            ld h,HIGH midi_ch_table
            ld l,a    
            ld a,(hl)    
            inc hl   
            ld h,(hl)
            ld l,a
			
            push hl
            pop ix
            ld a,(_p1)
            ;and 0x7f
            ld (ix+MIDI_CHANNEL_DATA.instrument-128),a
			pop ix
            jp finalize
;<---
cmd_pitch_bend:
_j_pitch_wheel:
			push ix
			;ld hl,(ix+TRACK_DATA.midi_ch_addr)
			
            ld a,(ix+TRACK_DATA.midi_ch)
            add a,a
            ld h,HIGH midi_ch_table
            ld l,a    
            ld a,(hl)    
            inc hl   
            ld h,(hl)
            ld l,a			
			
			ld (.comparrerr),hl  ; store midi channel data 
			push hl
			pop ix

			ld a,(_p2)
			ld l,a		;most signigficant bits 7bit
			ld h,0

			SRL H   ;<<7
			RR L
			LD H, L
			LD L, 0
			RR L
			
			ld a,(_p1)
			or l
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
			jp finalize
;<=========================================================================
_j_note_off:
;c -  note
;ix - track data
        ld a,c     
        cpl
        ld (._note_evv1),a
        ld (._note_evv2),a
        ld (._note_evv3),a
        ld (._note_evv4),a
        ld (._note_evv5),a
        ld (._note_evv6),a


;looking for midi channel
				push ix

				;ld hl,(ix+TRACK_DATA.midi_ch_addr)
				ld a,(ix+TRACK_DATA.midi_ch)
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
;<=========================================================================
free_voice:     dw 0
oldest_voice:   dw 0

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
        	;ld bc,VOICE_DATA
        	ld de,VOICE_DATA
        	add ix,de
        	;dec iyl
            dec c
        	jp nz,.loop3


.loop_exit

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
				
                LD a,(ix+VOICE_DATA.number)
                add a,OPL4_REG_MISC
                ld e,a
                jp opl4writewave
;<================
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

;====================================================================================
update_pitch:
  ;      push iy


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

                                    call BCDE_Times_A
                                    ;Outputs: A:HL:IX is the 40-bit product, BC,DE unaffected
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
                              ;    DEHL is the result of the division

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


;TODO
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

 ;TODO ????????????????????????????????????????????????????????????????
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
;TODO ????????????????????????????????????????????????????????????????                       
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

 ;       pop iy
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
;                ld h,HIGH g_volume_table

                ld a,e
                add a,(hl)    ;att+=midi_ch.expression
                ld e,a
                
                ld a,d
                adc a,0
                ld d,a	

;att += snd_opl4_volume_table[voice->velocity];
                pop ix 



;                ld h,HIGH g_volume_table
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
			
;<=================================
setduration:
					push hl
					ld hl,(IX+TRACK_DATA.waiting_for)
					ld de,(tick_counter)
					and a
					sbc hl,de
					ld (.wait_corection_low),hl
					;					ld hl,(IX+TRACK_DATA.waiting_for+2)
					;					ld de,(tick_counter+2)
					;					sbc hl,de
					;					ld (.wait_corection_high),hl
					
					ld a,(_p1)	;duration
					ld e,a	
					
					ld a,(_p0)
					and a
					jp z,.sss
					inc e
.sss					
					ld d,0
					sla de:sla de   ;duration * 4
                                        sla de:sla de   ;duration * 4

.wait_corection_low = $+1
					ld hl,0
					add hl,de
					ex de,hl
					pop hl
					
					inc hl
					ld (hl),e
					inc hl
					ld (hl),d
					ret
_j_note_on:
;here note height
			ADD     A,(ix+TRACK_DATA.key_offset)
			JP      P,.L206A
			CP      0C0h
			LD      A,7Fh
			JR      C,.L206A
			XOR     A
.L206A: 	LD      (_id),a


			ld a,(_p1)  ;duration
			and a
			jp z,_j_note_on_exit
			

			ld a,(_p2)  ;velocity
			ld (.on_v_midi_veloc),a
			and a
			jp z,_j_note_on_exit


            ld a,(_id)
            and 0x7f
            ld (.on_v_midi_note),a
			ld c,a
            cpl
            ld (._note_evv),a

;.write_note_to_note_tracer:
					push ix
					pop hl
					ld de,TRACK_DATA.note_tracer
					add hl,de

					ld de,0
					ld b,NOTE_TRACER_ENTRIES
.wntn_loop:
					;c - note					
					ld a,(hl)
					cp c
					jp nz,._not_current_note
					
					call setduration

					jp _j_note_on_exit			;exit because note is already playing
					
._not_current_note:
				    and a
					jp nz,._this_entry_is_used
					ld a,d
					or e
					jp nz,._entry_unused_but	;entry is unused but we already have pointer to unused entry
					ld e,l
					ld d,h	;<<< save pointer to empty entry
					
._this_entry_is_used:					
._entry_unused_but:
					inc hl
					inc hl
					inc hl	;< - to next entry
					djnz .wntn_loop
					
					ld a,d
					or e
					jp z,_j_note_on_exit		;no room for new notes. exit

					ld h,d
					ld l,e
					ld (hl),c

					call setduration


		push ix

;            ld hl,(IX+TRACK_DATA.midi_ch_addr)
            ld a,(IX+TRACK_DATA.midi_ch)
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
						
                        ld a,(.on_v_midi_note) 
                        ;ld a,c           ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  use C !!!!!!!!!

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

            ;;;;;;  and 0x7f
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
        ;      pop de 



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
; check values
;                          ix = free_voice 
                                           ;ld de,(free_voice)  ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!               
                            ld a,ixl                          
                            ld (hl),a      ;ld (hl),e
                            inc hl
                            ld a,ixh 
                            ld (hl),a      ;ld (hl),d

                            ld (ix+VOICE_DATA.is_active),1

                                ld hl,(tick_counter)
                                LD (ix+VOICE_DATA.activated),hl 
                                ld hl,(tick_counter+2)
                                LD (ix+VOICE_DATA.activated+2),hl 
                                
                                ld de,0
.on_v_midi_ch:                   equ $-2       
                                ld (ix+VOICE_DATA.midi_channel),de

                                ld (ix+VOICE_DATA.note),0
.on_v_midi_note                 equ $-1  
                                ld (ix+VOICE_DATA.velocity),0
.on_v_midi_veloc                equ $-1
                        
                        pop hl
                        ld (ix+VOICE_DATA.wave_data),hl



                      pop af
                      inc a  
                      cp 0
.n_onv_test equ $-1
                    jr nz,.gv_loop                   



;-------------------------------------------------------------------------------------------------------------------
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




;                        /* Set tone number (triggers header loading) */

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
                                                                ;                        ld a,OPL4_REG_TONE_NUMBER
                                                                ;                        add a,(ix+VOICE_DATA.number)                     
                        ld e,a
                        call opl4writewave                                          




;                        /* Set parameters which can be set while loading */



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

;------------------------------------------------------------------------------------------------------------
.ello
                    in a,(MOON_STAT)
                    and 0x02
                    jr nz,.ello

;------------------------------------------------------------------------------------------------------------

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ld a,(IY+YRW801_WAVE_DATA.reg_lfo_vibrato)
                    ld (IX+VOICE_DATA.reg_lfo_vibrato),a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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



;----------------------------
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
                   ; jr nz,.ge_loop 
                    jr nz,.gn5_loop 
;----------------------------

.exit_sub

    pop ix
finalize:	
_j_note_on_exit:
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;set delay to next event				
				call memorystreamgetpos
				ld (ix+TRACK_DATA.currentoffset+0),hl
				ld (ix+TRACK_DATA.currentoffset+2),de				
set_delay:
				ld a,(_p0) ;delay

                                ld h,0
                                ld l,a
                                ld bc,0
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
	
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>					
cmd_control_change:
_j_control_change:
        push ix
         ld hl,.exxt
         push hl

							;            ld a,(IX+TRACK_DATA.midi_ch)
							;            ld (.sustain_midi_channel),a
							;            ld (.sostenuto_midi_channel),a
			ld (.sustain_track),ix
			ld (.sostenuto_track),ix

			;ld hl,(IX+TRACK_DATA.midi_ch_addr)
			
			ld a,(ix+TRACK_DATA.midi_ch)
			ld e,a
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
        ld a,(_p2)		;value
		ld d,a
		ld a,(_p1)		;controller
		ld c,a
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
        jp finalize
		



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
;=================================================


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
			ld  (IX+MIDI_CHANNEL_DATA._MIDI_RPN_TYPE-128),1  ;rpn
			ret     

;registered parameter (coarse) 101
.SUB_MIDI_CTL_REGIST_PARM_NUM_MSB
			ld  (IX+MIDI_CHANNEL_DATA._MIDI_CTL_REGIST_PARM_NUM_MSB-128),d
			ld  (IX+MIDI_CHANNEL_DATA._MIDI_RPN_TYPE-128),1  ;rpn
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
			ld  a,(IX+MIDI_CHANNEL_DATA._MIDI_RPN_TYPE-128)
			cp 1 ;is rpn
			ret nz     
        
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
;======================================================
.pb_sens:
           pop hl
           ld (IX+MIDI_CHANNEL_DATA.gm_rpn_pitch_bend_range-128),hl
           ret
;======================================================
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
;======================================================
.pb_coarsetun:
           pop hl
                        ;   ld a,l
                        ;   and 0x80
                        ;   ld l,a
           and a
           ld bc,8192
           sbc hl,bc
           ld (IX+MIDI_CHANNEL_DATA.gm_rpn_coarse_tuning-128),hl     
           ret
;======================================================


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
												;                ld e,0   ;midi channel
												;.sustain_midi_channel equ $-1
                
                 ld a,(ix+0)
.sustain_notev1 equ $-1
                 AND SNDRV_MIDI_NOTE_RELEASED     ; bit 1,(ix+0)
                 jp z,.SUB_MIDI_CTL_SUSTAIN_skip_loop                


					push ix
.sustain_track	= $+2                 
                    ld ix,0
                    call _j_note_off
					pop ix

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

           ;sostenuto switch off

           ld a,0xff
.sostenuto_sw_off_loop:
            ld (.sostenuto_sw_off_notevv1),a
            ld (.sostenuto_sw_off_notevv2),a
            ld (.sostenuto_sw_off_notevv3),a
            ld (.sostenuto_sw_off_notevv4),a
            push af
                ld c,a
																									;                ld e,0
																									;.sostenuto_midi_channel equ $-1
                bit 2,(ix+0)                ;if (note & SNDRV_MIDI_NOTE_SOSTENUTO) == 0
.sostenuto_sw_off_notevv1 equ $-2
                jp z,.sostenuto_sw_off_skip_loop
                    res 2,(ix+0)            ;note[i] &= ~SNDRV_MIDI_NOTE_SOSTENUTO
.sostenuto_sw_off_notevv2 equ $-2
                    bit 1,(ix+0)            ;if (note & SNDRV_MIDI_NOTE_RELEASED) == 0
.sostenuto_sw_off_notevv3 equ $-2
                    jp z,.sostenuto_sw_off_skip_loop
						push ix   
.sostenuto_track = $+2
						ld ix,0
                        call _j_note_off

						pop ix
                        ld (ix+0),SNDRV_MIDI_NOTE_OFF
.sostenuto_sw_off_notevv4 equ $-2

.sostenuto_sw_off_skip_loop:
           pop af      
           dec a
           cp 0x7f
           jr nz,.sostenuto_sw_off_loop
           ret 		
		   
		   
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
cmd_loop_start:

			
			inc (IX+TRACK_DATA.current_loop)
			ld a,(IX+TRACK_DATA.current_loop)
			push ix			
			
			dec a
			ld d,a
			add a,a
			add a,a
			add a,d    ;a*5
		    ld e,a
			ld d,0
			add ix,de
			ld de,TRACK_DATA.loop_tracer
			add ix,de
			
			call memorystreamgetpos
			ld (ix+0),hl
			ld (ix+2),de
			ld (ix+4),0
			pop ix
			jp finalize2
;<<<<<<<			
cmd_loop_end:
			ld a,(IX+TRACK_DATA.current_loop)
			or a
			jp z,finalize2
			push ix
			
			dec a
			ld d,a
			add a,a
			add a,a
			add a,d    ;a*5
		    ld e,a
			ld d,0
			add ix,de			
			ld de,TRACK_DATA.loop_tracer
			add ix,de
			
			ld a,(_p0)
			or a
			jp z,.restore_position
			inc (ix+4)
			cp (ix+4)
			jp nz,.restore_position
			
			pop ix
			dec (IX+TRACK_DATA.current_loop)
			jp finalize2
.restore_position:
			ld hl,(ix)
			ld de,(ix+2)
			pop ix
			ld (ix+TRACK_DATA.currentoffset),hl
			ld (ix+TRACK_DATA.currentoffset+2),de
			xor a
			ld (_p0),a
			jp set_delay
			
			
;>>>>>>>
cmd_measure_end:
			ld (IX+TRACK_DATA.same_measure_commands),0  ;ix+f
			bit 0,(IX+TRACK_DATA.same_measure_mode)
			jp z,finalize2
.set_me_retpos:
			ld hl,(IX+TRACK_DATA.same_measure_position)
			ld (IX+TRACK_DATA.currentoffset),hl
			ld hl,(IX+TRACK_DATA.same_measure_position+2)
			ld (IX+TRACK_DATA.currentoffset+2),hl

			res 0,(IX+TRACK_DATA.same_measure_mode)    ;res     6, (ix+04h)    ;

			xor a
			ld (_p0),a
			jp set_delay

cmd_same_measure
			bit 0,(IX+TRACK_DATA.same_measure_mode)     ;bit6,ix+4
			jp z,.no_same_measure_mode
			ld a,(IX+TRACK_DATA.same_measure_commands)  ;ix+f
			dec a
			jp nz,cmd_measure_end.set_me_retpos  ;act as 'measure end'
			jp .goto_new_measure
.no_same_measure_mode:
			call memorystreamgetpos
			ld (IX+TRACK_DATA.same_measure_position),hl
			ld (IX+TRACK_DATA.same_measure_position+2),de
			set 0,(IX+TRACK_DATA.same_measure_mode)
			
			
.goto_new_measure:
			ld de,(_p1)
			res     0, e
			res     1, e
			ld hl,(IX+TRACK_DATA.track_header_position)
			add hl,de
			ld (IX+TRACK_DATA.currentoffset),hl
			ld hl,(IX+TRACK_DATA.track_header_position+2)
			ld de,0
			adc hl,de
			ld (IX+TRACK_DATA.currentoffset+2),hl
			ld (IX+TRACK_DATA.same_measure_commands),0
			xor a
			ld (_p0),a
			jp set_delay