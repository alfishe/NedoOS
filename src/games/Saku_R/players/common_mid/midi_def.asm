        struct YRW801_WAVE_DATA

tone                     ds 2       ;                      uint16_t
pitch_offset             ds 2       ;                      int16_t 
key_scaling              ds 1       ;                      uint8_t 
panpot                   ds 1       ;                      int8_t  
vibrato                  ds 1       ;                      uint8_t 
tone_attenuate           ds 1       ;                      uint8_t 
volume_factor            ds 1       ;                      uint8_t 
reg_lfo_vibrato          ds 1       ;                     uint8_t 
reg_attack_decay1        ds 1       ;                     uint8_t 
reg_level_decay2         ds 1       ;                     uint8_t 
reg_release_correction   ds 1       ;                     uint8_t 
reg_tremolo              ds 1       ;                     uint8_t 
        ends

        struct MIDI_CHANNEL_DATA
notes_status                    ds 128                       
instrument                      ds 1 ;   uint8_t instrument; 
vibrato                         ds 1 ;   uint8_t vibrato;    
pitch_bend                      ds 2 ;   int16_t    pitch bend signed       midi_pitchbend
gm_rpn_coarse_tuning            ds 2  ; int16_t signed
gm_rpn_fine_tuning              ds 2  ; int16_t signed
_MIDI_RPN_TYPE                  ds 1
_MIDI_CTL_REGIST_PARM_NUM_MSB   ds 1 ;
_MIDI_CTL_REGIST_PARM_NUM_LSB   ds 1 ;                                                
_MIDI_CTL_MSB_DATA_ENTRY        ds 1 ;
_MIDI_CTL_LSB_DATA_ENTRY        ds 1 ;
gm_sustain                      ds 1
panpot                          ds 1 ;   uint8_t panpot;     
gm_rpn_pitch_bend_range         ds 2  ; int16_t signed
param_type                      ds 1 ; /* RPN/NRPN */
gm_volume                       ds 1
gm_expression                   ds 1

drum_channel                    ds 1 ;   bool    drum_channel;
               ends



        struct VOICE_DATA
number          ds 1  ;
is_active       ds 1  ;
activated       ds 4,0;
midi_channel    ds 2,0  ;pointer to midi chanel data
wave_data       ds 2,0  ;pointer to yrw801
note            ds 1
velocity        ds 1
level_direct    ds 1
reg_f_number    ds 1
reg_misc        ds 1
reg_lfo_vibrato ds 1
        ends


        struct TRACK_DATA

waiting_for_t   ds 4
waiting_for     ds 4
streamoffset     ds 4,0
currentoffset   ds 4,0
track_finished  ds 1,0
last_command    ds 1
        ends

        struct MIDI_HEADER

file_format             ds 1       ;uint8_t   
number_of_tracks        ds 1       ;uint8_t  
ticks_per_qnote         ds 2 ;uint16_t
ticksperqnoteXupdatelen ds 4 ;uint32_t

midi_mode               ds 1;	/* MIDI operating mode */
gs_master_volume        ds 1;   /* SYSEX master volume: 0-127 */
gs_chorus_mode          ds 1;
gs_reverb_mode          ds 1;

g_track_data            ds TRACK_DATA*MAX_NR_OF_TRACKS
g_midi_channel_data     ds MIDI_CHANNEL_DATA*NR_OF_MIDI_CHANNELS
g_voice_data            ds VOICE_DATA * NR_OF_WAVE_CHANNELS
        ends




/*MIDI Controllers*/
MIDI_CTL_MSB_BANK		= 0x00	/**< Bank selection */
MIDI_CTL_MSB_MODWHEEL         	= 0x01	/**< Modulation */
MIDI_CTL_MSB_BREATH           	= 0x02	/**< Breath */
MIDI_CTL_MSB_FOOT             	= 0x04	/**< Foot */
MIDI_CTL_MSB_PORTAMENTO_TIME 	= 0x05	/**< Portamento time */
MIDI_CTL_MSB_DATA_ENTRY		= 0x06	/**< Data entry */
MIDI_CTL_MSB_MAIN_VOLUME      	= 0x07	/**< Main volume */
MIDI_CTL_MSB_BALANCE          	= 0x08	/**< Balance */
MIDI_CTL_MSB_PAN              	= 0x0a	/**< Panpot */
MIDI_CTL_MSB_EXPRESSION       	= 0x0b	/**< Expression */
MIDI_CTL_MSB_EFFECT1		= 0x0c	/**< Effect1 */
MIDI_CTL_MSB_EFFECT2		= 0x0d	/**< Effect2 */
MIDI_CTL_MSB_GENERAL_PURPOSE1 	= 0x10	/**< General purpose 1 */
MIDI_CTL_MSB_GENERAL_PURPOSE2 	= 0x11	/**< General purpose 2 */
MIDI_CTL_MSB_GENERAL_PURPOSE3 	= 0x12	/**< General purpose 3 */
MIDI_CTL_MSB_GENERAL_PURPOSE4 	= 0x13	/**< General purpose 4 */
MIDI_CTL_LSB_BANK		= 0x20	/**< Bank selection */
MIDI_CTL_LSB_MODWHEEL        	= 0x21	/**< Modulation */
MIDI_CTL_LSB_BREATH           	= 0x22	/**< Breath */
MIDI_CTL_LSB_FOOT             	= 0x24	/**< Foot */
MIDI_CTL_LSB_PORTAMENTO_TIME 	= 0x25	/**< Portamento time */
MIDI_CTL_LSB_DATA_ENTRY		= 0x26	/**< Data entry */
MIDI_CTL_LSB_MAIN_VOLUME      	= 0x27	/**< Main volume */
MIDI_CTL_LSB_BALANCE          	= 0x28	/**< Balance */
MIDI_CTL_LSB_PAN              	= 0x2a	/**< Panpot */
MIDI_CTL_LSB_EXPRESSION       	= 0x2b	/**< Expression */
MIDI_CTL_LSB_EFFECT1		= 0x2c	/**< Effect1 */
MIDI_CTL_LSB_EFFECT2		= 0x2d	/**< Effect2 */
MIDI_CTL_LSB_GENERAL_PURPOSE1 	= 0x30	/**< General purpose 1 */
MIDI_CTL_LSB_GENERAL_PURPOSE2 	= 0x31	/**< General purpose 2 */
MIDI_CTL_LSB_GENERAL_PURPOSE3 	= 0x32	/**< General purpose 3 */
MIDI_CTL_LSB_GENERAL_PURPOSE4 	= 0x33	/**< General purpose 4 */
MIDI_CTL_SUSTAIN              	= 0x40	/**< Sustain pedal */
MIDI_CTL_PORTAMENTO           	= 0x41	/**< Portamento */
MIDI_CTL_SOSTENUTO            	= 0x42	/**< Sostenuto */
MIDI_CTL_SUSTENUTO            	= 0x42	/**< Sostenuto (a typo in the older version) */
MIDI_CTL_SOFT_PEDAL           	= 0x43	/**< Soft pedal */
MIDI_CTL_LEGATO_FOOTSWITCH	= 0x44	/**< Legato foot switch */
MIDI_CTL_HOLD2                	= 0x45	/**< Hold2 */
MIDI_CTL_SC1_SOUND_VARIATION	= 0x46	/**< SC1 Sound Variation */
MIDI_CTL_SC2_TIMBRE		= 0x47	/**< SC2 Timbre */
MIDI_CTL_SC3_RELEASE_TIME	= 0x48	/**< SC3 Release Time */
MIDI_CTL_SC4_ATTACK_TIME	= 0x49	/**< SC4 Attack Time */
MIDI_CTL_SC5_BRIGHTNESS		= 0x4a	/**< SC5 Brightness */
MIDI_CTL_SC6			= 0x4b	/**< SC6 */
MIDI_CTL_SC7			= 0x4c	/**< SC7 */
MIDI_CTL_SC8			= 0x4d	/**< SC8 */
MIDI_CTL_SC9			= 0x4e	/**< SC9 */
MIDI_CTL_SC10			= 0x4f	/**< SC10 */
MIDI_CTL_GENERAL_PURPOSE5     	= 0x50	/**< General purpose 5 */
MIDI_CTL_GENERAL_PURPOSE6     	= 0x51	/**< General purpose 6 */
MIDI_CTL_GENERAL_PURPOSE7     	= 0x52	/**< General purpose 7 */
MIDI_CTL_GENERAL_PURPOSE8     	= 0x53	/**< General purpose 8 */
MIDI_CTL_PORTAMENTO_CONTROL	= 0x54	/**< Portamento control */
MIDI_CTL_E1_REVERB_DEPTH	= 0x5b	/**< E1 Reverb Depth */
MIDI_CTL_E2_TREMOLO_DEPTH	= 0x5c	/**< E2 Tremolo Depth */
MIDI_CTL_E3_CHORUS_DEPTH	= 0x5d	/**< E3 Chorus Depth */
MIDI_CTL_E4_DETUNE_DEPTH	= 0x5e	/**< E4 Detune Depth */
MIDI_CTL_E5_PHASER_DEPTH	= 0x5f	/**< E5 Phaser Depth */
MIDI_CTL_DATA_INCREMENT       	= 0x60	/**< Data Increment */
MIDI_CTL_DATA_DECREMENT       	= 0x61	/**< Data Decrement */
MIDI_CTL_NONREG_PARM_NUM_LSB  	= 0x62	/**< Non-registered parameter number */
MIDI_CTL_NONREG_PARM_NUM_MSB  	= 0x63	/**< Non-registered parameter number */
MIDI_CTL_REGIST_PARM_NUM_LSB  	= 0x64	/**< Registered parameter number */
MIDI_CTL_REGIST_PARM_NUM_MSB	= 0x65	/**< Registered parameter number */
MIDI_CTL_ALL_SOUNDS_OFF		= 0x78	/**< All sounds off */
MIDI_CTL_RESET_CONTROLLERS	= 0x79	/**< Reset Controllers */
MIDI_CTL_LOCAL_CONTROL_SWITCH	= 0x7a	/**< Local control switch */
MIDI_CTL_ALL_NOTES_OFF		= 0x7b	/**< All notes off */
MIDI_CTL_OMNI_OFF		= 0x7c	/**< Omni off */
MIDI_CTL_OMNI_ON		= 0x7d	/**< Omni on */
MIDI_CTL_MONO1			= 0x7e	/**< Mono1 */
MIDI_CTL_MONO2			= 0x7f	/**< Mono2 */


/* MIDI mode */
SNDRV_MIDI_MODE_NONE	=  0;	/* Generic midi */
SNDRV_MIDI_MODE_GM	=  1
SNDRV_MIDI_MODE_GS	=  2
SNDRV_MIDI_MODE_XG	=  3
SNDRV_MIDI_MODE_MT32	=  4

/* MIDI note state */
SNDRV_MIDI_NOTE_OFF             =   0x00
SNDRV_MIDI_NOTE_ON              =   0x01
SNDRV_MIDI_NOTE_RELEASED        =   0x02
SNDRV_MIDI_NOTE_SOSTENUTO       =   0x04
SNDRV_MIDI_NOTE_SOSTENUTO_NEG   =   0xfb