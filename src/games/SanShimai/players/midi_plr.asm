        DEVICE ZXSPECTRUM48
        include "../../../_sdk/sys_h.asm"
                ORG 0x4000


AREA_C000_FFFF = 1

module = $C000


MAX_NR_OF_TRACKS = 64



TITLELENGTH = 64
MEMORYSTREAMMAXPAGES = 210
MEMORYSTREAMERRORMASK = 255

DRUM_CHANNEL = 9

DEFAULT_QNOTE_DURATION_MCS = 500000
VSYNC_FREQ = 46 ;49 ;46
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
                include "common_mid/midi_def.asm"
                include "common_mid/opl_.asm"
                include "common_mid/muldiv.asm"
                include "common_mid/mid_rob.asm"



init_:
                call init_opl4_device
                        
        
                call memorystreamstart
        
                ld b,midheadersigsize
                ld de,midheadersig
                call midchecksignature 
                jp nz,notMidi



                memory_stream_read_2 c,a
/*file type*/
                ;c a - midi file  format ; 0x0000,0x0001,0x0002
                cp 3
                jp nc,notMidi
                ld (g_header.file_format),a
        
/*tracks count*/
                memory_stream_read_2 c,a
                ld (g_header.number_of_tracks),a
        
        	add a,-MAX_NR_OF_TRACKS-1
        	sbc a,a
                jp nz,notMidi
        
        
                memory_stream_read_2 b,c
                ld a,c
                ld (g_header.ticks_per_qnote),a
                ld a,b
                ld (g_header.ticks_per_qnote+1),a
        	ld de,VSYNC_MCS
        	call uintmul16
        	add hl,hl : rl de
        	add hl,hl : rl de
        	ld (g_header.ticksperqnoteXupdatelen+0),hl
        	ld (g_header.ticksperqnoteXupdatelen+2),de
        
        
                ld a,16
                ld (g_volume_boost),a
        
                call midloadtracks
        ;        call init_channels
        ;        call init_voices
        
        
                ld a,SNDRV_MIDI_MODE_GM
                ld (g_header.midi_mode),a
                ld a,127
                ld (g_header.gs_master_volume),a

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
        
                call set_refresh

                call rewind

                xor a
                ld (midi_play_var),a
                ret

midloadtracks:
	ld ix,g_header.g_track_data
	ld iy,(g_header.number_of_tracks)

.loop	ld b,midtracksigsize
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

	ld b,0
	sla de : rl bc
	sla de : rl bc
	ld (ix+TRACK_DATA.waiting_for_t+0),de
	ld (ix+TRACK_DATA.waiting_for_t+2),bc
    
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
;------------------------------------------------------------------------------------------------------------
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
        ld b,128+16   ;128 notes + 1instrument + 1vibrato + 2pitchbend + 2 finetuning + 2 coarsetuning + 1 rpn/nrpn mode 4 midictl reg +1sustain  +1 panpot ymf278  -7 [0] +7   1pitch bend range (low)
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
.loop:
        ld (hl),d:inc hl  ;VOICE_DATA.number                                                  
        ld b,15                                       
.loop2:                                                
            ld (hl),a:inc hl                              
            djnz .loop2
        inc d
	dec iyl
	jp nz,.loop
	ret
;-------------------------------------------------------------------------------------------------
MUTE:
        ld a,0xC9			;ret	;stop playing
        ld (midi_play_var),a
        call opl4mute

        jp opl4_reset

PLAY:

midi_play_var = $ : nop		;nop - play
            call mid_play
            ;out  ;a 0 track still play  !0 - finished        
            call z,rewind ;play_exit

            ret











notMidi:
                ld a,0xc9
                ld (midi_play_var),a
                ret


;=============================
midheadersig:
    db  "MThd",0,0,0,6
midheadersigsize: equ $-midheadersig
midtracksig
	db "MTrk"
midtracksigsize = $-midtracksig
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
midchecksignature
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

g_ticks_per_update ds 4,0


g_MIDI_counter ds 4,0
g_volume_boost db 16

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
        LABELSLIST "mid_plr.l"    
	savebin "SanShimai/mid_plr.bin",begin,end-begin