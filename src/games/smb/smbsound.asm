;читает:
;OperMode (0=выключить звук и не играть)
;EventMusicQueue (номер джингла типа TimeRunningOutMusic, EndOfCastleMusic) - при вызове плейера он это копирует в EventMusicBuffer и зануляет
;AreaMusicQueue (номер музыки) - при вызове плейера он это копирует в AreaMusicBuffer и зануляет
;PauseSoundQueue (1=доигрываем звук паузы и выключаем звук - как туда попадает 1???)
;Square1SoundQueue (jump, flagpole sound и др.)
;Square2SoundQueue (1-up sound, fireworks/gunfire)
;      lda Square2SoundQueue
;      oran ++Sfx_Blast            ;play fireworks/gunfire sound
;      sta Square2SoundQueue
;NoiseSoundQueue (brick shatter sound)
;        lda NoiseSoundQueue
;        oran ++Sfx_BowserFlame        ;load bowser's flame sound into queue
;        sta NoiseSoundQueue

;возвращает:
;EventMusicBuffer (0=музыкальный эффект кончился)


SoundEngine:
         lda OperMode              ;are we in title screen mode?
         checka
         bne SndOn
         sta SND_MASTERCTRL_REG    ;if so, disable sound and leave
         rts
SndOn:   ldan ++$ff
         sta JOYPAD_PORT2          ;disable irqs and set frame counter mode???
         ldan ++$0f
         sta SND_MASTERCTRL_REG    ;enable first four channels
         lda PauseModeFlag         ;is sound already in pause mode?
         checka
         bne InPause
         lda PauseSoundQueue       ;if not, check pause sfx queue    
         cmpn ++$01
         bne RunSoundSubroutines   ;if queue is empty, skip pause mode routine
InPause: lda PauseSoundBuffer      ;check pause sfx buffer
         checka
         bne ContPau
         lda PauseSoundQueue       ;check pause queue
         checka
         beq SkipSoundSubroutines
         sta PauseSoundBuffer      ;if queue full, store in buffer and activate
         sta PauseModeFlag         ;pause mode to interrupt game sounds
         ldan ++$00                  ;disable sound and clear sfx buffers
         sta SND_MASTERCTRL_REG
         sta Square1SoundBuffer
         sta Square2SoundBuffer
         sta NoiseSoundBuffer
         ldan ++$0f
         sta SND_MASTERCTRL_REG    ;enable sound again
         ldan ++$2a                  ;store length of sound in pause counter
         sta Squ1_SfxLenCounter
PTone1F: ldan ++$44                  ;play first tone
         checka
         bne PTRegC                ;unconditional branch
ContPau: lda Squ1_SfxLenCounter    ;check pause length left
         cmpn ++$24                  ;time to play second?
         beq PTone2F
         cmpn ++$1e                  ;time to play first again?
         beq PTone1F
         cmpn ++$18                  ;time to play second again?
         bne DecPauC               ;only load regs during times, otherwise skip
PTone2F: ldan ++$64                  ;store reg contents and play the pause sfx
PTRegC:  ldxn ++$84
         ldyn ++$7f
         jsr PlaySqu1Sfx
DecPauC: deci Squ1_SfxLenCounter    ;decrement pause sfx counter
         bne SkipSoundSubroutines
         ldan ++$00                  ;disable sound if in pause mode and
         sta SND_MASTERCTRL_REG    ;not currently playing the pause sfx
         lda PauseSoundBuffer      ;if no longer playing pause sfx, check to see
         cmpn ++$02                  ;if we need to be playing sound again
         bne SkipPIn
         ldan ++$00                  ;clear pause mode to allow game sounds again
         sta PauseModeFlag
SkipPIn: ldan ++$00                  ;clear pause sfx buffer
         sta PauseSoundBuffer
         checka
         beq SkipSoundSubroutines ;unconditional???

RunSoundSubroutines:
         jsr Square1SfxHandler  ;play sfx on square channel 1
         jsr Square2SfxHandler  ; ''  ''  '' square channel 2
         jsr NoiseSfxHandler    ; ''  ''  '' noise channel
         jsr MusicHandler       ;play music on all channels
         ldan ++$00               ;clear the music queues
         sta AreaMusicQueue
         sta EventMusicQueue

SkipSoundSubroutines:
          ldan ++$00               ;clear the sound effects queues
          sta Square1SoundQueue
          sta Square2SoundQueue
          sta NoiseSoundQueue
          sta PauseSoundQueue
          ldy DAC_Counter        ;load some sort of counter 
          lda AreaMusicBuffer
          andn ++%00000011         ;check for specific music
          beq NoIncDAC
          inci DAC_Counter        ;increment and check counter
          cpyn ++$30
              cmpcy
          bcc StrWave            ;if not there yet, just store it
NoIncDAC: tya
         checka
          beq StrWave            ;if we are at zero, do not decrement 
          deci DAC_Counter        ;decrement counter
StrWave:  sty SND_DELTA_REG+1    ;store into DMC load register (??)
          rts                    ;we are done here

;--------------------------------

Dump_Squ1_Regs:
      sty SND_SQUARE1_REG+1  ;dump the contents of X and Y into square 1's control regs
      stx SND_SQUARE1_REG
      rts
      
PlaySqu1Sfx:
      jsr Dump_Squ1_Regs     ;do sub to set ctrl regs for square 1, then set frequency regs

SetFreq_Squ1:
;out: Z=NoTone
      ldxn ++$00               ;set frequency reg offset for square 1 sound channel

Dump_Freq_Regs:
;out: Z=NoTone
        tay
        lday FreqRegLookupTbl+1,y  ;use previous contents of A for sound reg offset
         checka
        beq NoTone                ;if zero, then do not load
        stax SND_REGISTER+2,x      ;first byte goes into LSB of frequency divider
        lday FreqRegLookupTbl,y    ;second byte goes into 3 MSB plus extra bit for 
        oran ++%00001000            ;length counter
        stax SND_REGISTER+3,x
        
        if Z80
;write to SND_REGISTER+3 causes counter loading from a table
        rra
        rra
        rra
        and 0x1f
        ld hl,tcounterload
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl) ;читает 5, а на слух надо примерно 0x10 для музыки, для флага больше, только эффекты покороче
	add a,a
	;jr $
        stax SND_COUNTER,x
;Only a write out to $4003/$4007/$400F will reset the current envelope decay counter to a known state (to $F, the maximum volume level) for the appropriate channel's envelope decay hardware.
        ld a,0x0f
        stax SND_DECAYVOL,x
        endif
        
NoTone: rts

Dump_Sq2_Regs:
      stx SND_SQUARE2_REG    ;dump the contents of X and Y into square 2's control regs
      sty SND_SQUARE2_REG+1
      rts

PlaySqu2Sfx:
      jsr Dump_Sq2_Regs      ;do sub to set ctrl regs for square 2, then set frequency regs

SetFreq_Squ2:
;out: Z=NoTone
      ldxn ++$04               ;set frequency reg offset for square 2 sound channel
         checkx
      bne Dump_Freq_Regs     ;unconditional branch

SetFreq_Tri:
;out: Z=NoTone
      ldxn ++$08               ;set frequency reg offset for triangle sound channel
         checkx
      bne Dump_Freq_Regs     ;unconditional branch

;--------------------------------

SwimStompEnvelopeData:
      .db $9f, $9b, $98, $96, $95, $94, $92, $90
      .db $90, $9a, $97, $95, $93, $92

PlayFlagpoleSlide:
       ldan ++$40               ;store length of flagpole sound
       sta Squ1_SfxLenCounter
       ldan ++$62               ;load part of reg contents for flagpole sound
       jsr SetFreq_Squ1
       ldxn ++$99               ;now load the rest
         checkx
       bne FPS2nd ;unconditional???

PlaySmallJump:
       ldan ++$26               ;branch here for small mario jumping sound
         checka
       bne JumpRegContents ;unconditional???

PlayBigJump:
       ldan ++$18               ;branch here for big mario jumping sound

JumpRegContents:
       ldxn ++$82               ;note that small and big jump borrow each others' reg contents
       ldyn ++$a7               ;anyway, this loads the first part of mario's jumping sound
       jsr PlaySqu1Sfx
       ldan ++$28               ;store length of sfx for both jumping sounds
       sta Squ1_SfxLenCounter ;then continue on here

ContinueSndJump:
          lda Squ1_SfxLenCounter ;jumping sounds seem to be composed of three parts
          cmpn ++$25               ;check for time to play second part yet
          bne N2Prt
          ldxn ++$5f               ;load second part
          ldyn ++$f6
         checky
          bne DmpJpFPS           ;unconditional branch
N2Prt:    cmpn ++$20               ;check for third part
          bne DecJpFPS
          ldxn ++$48               ;load third part
FPS2nd:   ldyn ++$bc               ;the flagpole slide sound shares part of third part
DmpJpFPS: jsr Dump_Squ1_Regs
          bne DecJpFPS           ;unconditional branch outta here ;???

PlayFireballThrow:
        ldan ++$05
        ldyn ++$99                 ;load reg contents for fireball throw sound
         checky
        bne Fthrow               ;unconditional branch

PlayBump:
          ldan ++$0a                ;load length of sfx and reg contents for bump sound
          ldyn ++$93
Fthrow:   ldxn ++$9e                ;the fireball sound shares reg contents with the bump sound
          sta Squ1_SfxLenCounter
          ldan ++$0c                ;load offset for bump sound
          jsr PlaySqu1Sfx

ContinueBumpThrow:    
          lda Squ1_SfxLenCounter  ;check for second part of bump sound
          cmpn ++$06   
          bne DecJpFPS
          ldan ++$bb                ;load second part directly
          sta SND_SQUARE1_REG+1
         checka
DecJpFPS: bne BranchToDecLength1  ;unconditional branch


Square1SfxHandler:
       ldy Square1SoundQueue   ;check for sfx in queue
         checky
       beq CheckSfx1Buffer
       sty Square1SoundBuffer  ;if found, put in buffer
         ;checky ;???
       bmi PlaySmallJump       ;small jump
       lsri Square1SoundQueue
       bcs PlayBigJump         ;big jump
       lsri Square1SoundQueue
       bcs PlayBump            ;bump
       lsri Square1SoundQueue
       bcs PlaySwimStomp       ;swim/stomp
       lsri Square1SoundQueue
       bcs PlaySmackEnemy      ;smack enemy
       lsri Square1SoundQueue
       bcs PlayPipeDownInj     ;pipedown/injury
       lsri Square1SoundQueue
       bcs PlayFireballThrow   ;fireball throw
       lsri Square1SoundQueue
       bcs PlayFlagpoleSlide   ;slide flagpole

CheckSfx1Buffer:
       lda Square1SoundBuffer   ;check for sfx in buffer 
         checka
       beq ExS1H                ;if not found, exit sub
       bmi ContinueSndJump      ;small mario jump 
       lsr
       bcs ContinueSndJump      ;big mario jump 
       lsr
       bcs ContinueBumpThrow    ;bump
       lsr
       bcs ContinueSwimStomp    ;swim/stomp
       lsr
       bcs ContinueSmackEnemy   ;smack enemy
       lsr
       bcs ContinuePipeDownInj  ;pipedown/injury
       lsr
       bcs ContinueBumpThrow    ;fireball throw
       lsr
       bcs DecrementSfx1Length  ;slide flagpole
ExS1H: rts

PlaySwimStomp:
      ldan ++$0e               ;store length of swim/stomp sound
      sta Squ1_SfxLenCounter
      ldyn ++$9c               ;store reg contents for swim/stomp sound
      ldxn ++$9e
      ldan ++$26
      jsr PlaySqu1Sfx

ContinueSwimStomp: 
      ldy Squ1_SfxLenCounter        ;look up reg contents in data section based on
      lday SwimStompEnvelopeData-1,y ;length of sound left, used to control sound's
      sta SND_SQUARE1_REG           ;envelope
      cpyn ++$06   
      bne BranchToDecLength1
      ldan ++$9e                      ;when the length counts down to a certain point, put this
      sta SND_SQUARE1_REG+2         ;directly into the LSB of square 1's frequency divider
         checka

BranchToDecLength1: 
      bne DecrementSfx1Length  ;unconditional branch (regardless of how we got here)

PlaySmackEnemy:
      ldan ++$0e                 ;store length of smack enemy sound
      ldyn ++$cb
      ldxn ++$9f
      sta Squ1_SfxLenCounter
      ldan ++$28                 ;store reg contents for smack enemy sound
      jsr PlaySqu1Sfx
      bne DecrementSfx1Length  ;unconditional branch ;??? если выход из PlaySqu1Sfx по NoTone, то перехода не будет!!!

ContinueSmackEnemy:
        ldy Squ1_SfxLenCounter  ;check about halfway through
        cpyn ++$08
        bne SmSpc
        ldan ++$a0                ;if we're at the about-halfway point, make the second tone
        sta SND_SQUARE1_REG+2   ;in the smack enemy sound
        ldan ++$9f
         checka
        bne SmTick ;unconditional???
SmSpc:  ldan ++$90                ;this creates spaces in the sound, giving it its distinct noise
SmTick: sta SND_SQUARE1_REG

DecrementSfx1Length:
      deci Squ1_SfxLenCounter    ;decrement length of sfx
      bne ExSfx1

StopSquare1Sfx:
        ldxn ++$00                ;if end of sfx reached, clear buffer
        stx Square1SoundBuffer;SCRATCHPAD+$f1                 ;and stop making the sfx
        ldxn ++$0e
        stx SND_MASTERCTRL_REG
        ldxn ++$0f
        stx SND_MASTERCTRL_REG
ExSfx1: rts

PlayPipeDownInj:  
      ldan ++$2f                ;load length of pipedown sound
      sta Squ1_SfxLenCounter

ContinuePipeDownInj:
         lda Squ1_SfxLenCounter  ;some bitwise logic, forces the regs
         lsr                     ;to be written to only during six specific times
         bcs NoPDwnL             ;during which d3 must be set and d1-0 must be clear
         lsr
         bcs NoPDwnL
         andn ++%00000010
         beq NoPDwnL
         ldyn ++$91                ;and this is where it actually gets written in
         ldxn ++$9a
         ldan ++$44
         jsr PlaySqu1Sfx
NoPDwnL: jmp DecrementSfx1Length

;--------------------------------

ExtraLifeFreqData:
      .db $58, $02, $54, $56, $4e, $44

PowerUpGrabFreqData:
      .db $4c, $52, $4c, $48, $3e, $36, $3e, $36, $30
      .db $28, $4a, $50, $4a, $64, $3c, $32, $3c, $32
      .db $2c, $24, $3a, $64, $3a, $34, $2c, $22, $2c

;residual frequency data
      .db $22, $1c, $14

PUp_VGrow_FreqData:
      .db $14, $04, $22, $24, $16, $04, $24, $26 ;used by both
      .db $18, $04, $26, $28, $1a, $04, $28, $2a
      .db $1c, $04, $2a, $2c, $1e, $04, $2c, $2e ;used by vinegrow
      .db $20, $04, $2e, $30, $22, $04, $30, $32

PlayCoinGrab:
        ldan ++$35             ;load length of coin grab sound
        ldxn ++$8d             ;and part of reg contents
         checkx
        bne CGrab_TTickRegL

PlayTimerTick:
        ldan ++$06             ;load length of timer tick sound
        ldxn ++$98             ;and part of reg contents

CGrab_TTickRegL:
        sta Squ2_SfxLenCounter 
        ldyn ++$7f                ;load the rest of reg contents 
        ldan ++$42                ;of coin grab and timer tick sound
        jsr PlaySqu2Sfx

ContinueCGrabTTick:
        lda Squ2_SfxLenCounter  ;check for time to play second tone yet
        cmpn ++$30                ;timer tick sound also executes this, not sure why
        bne N2Tone
        ldan ++$54                ;if so, load the tone directly into the reg
        sta SND_SQUARE2_REG+2
         checka
N2Tone: bne DecrementSfx2Length ;unconditional???

PlayBlast:
        ldan ++$20                ;load length of fireworks/gunfire sound
        sta Squ2_SfxLenCounter
        ldyn ++$94                ;load reg contents of fireworks/gunfire sound
        ldan ++$5e
         checka
        bne SBlasJ ;unconditional???

ContinueBlast:
        lda Squ2_SfxLenCounter  ;check for time to play second part
        cmpn ++$18
        bne DecrementSfx2Length
        ldyn ++$93                ;load second part reg contents then
        ldan ++$18
         checka
SBlasJ: bne BlstSJp             ;unconditional branch to load rest of reg contents

PlayPowerUpGrab:
        ldan ++$36                    ;load length of power-up grab sound
        sta Squ2_SfxLenCounter

ContinuePowerUpGrab:   
        lda Squ2_SfxLenCounter      ;load frequency reg based on length left over
        lsr                         ;divide by 2
        bcs DecrementSfx2Length     ;alter frequency every other frame
        tay
        lday PowerUpGrabFreqData-1,y ;use length left over / 2 for frequency offset
        ldxn ++$5d                    ;store reg contents of power-up grab sound
        ldyn ++$7f

LoadSqu2Regs:
        jsr PlaySqu2Sfx

DecrementSfx2Length:
        deci Squ2_SfxLenCounter   ;decrement length of sfx
        bne ExSfx2

EmptySfx2Buffer:
        ldxn ++$00                ;initialize square 2's sound effects buffer
        stx Square2SoundBuffer

StopSquare2Sfx:
        ldxn ++$0d                ;stop playing the sfx
        stx SND_MASTERCTRL_REG 
        ldxn ++$0f
        stx SND_MASTERCTRL_REG
ExSfx2: rts

Square2SfxHandler:
        lda Square2SoundBuffer ;special handling for the 1-up sound to keep it
        andn ++Sfx_ExtraLife     ;from being interrupted by other sounds on square 2
        bne ContinueExtraLife
        ldy Square2SoundQueue  ;check for sfx in queue
         checky
        beq CheckSfx2Buffer
        sty Square2SoundBuffer ;if found, put in buffer and check for the following
         ;checky ;???
        bmi PlayBowserFall     ;bowser fall
        lsri Square2SoundQueue
        bcs PlayCoinGrab       ;coin grab
        lsri Square2SoundQueue
        bcs PlayGrowPowerUp    ;power-up reveal
        lsri Square2SoundQueue
        bcs PlayGrowVine       ;vine grow
        lsri Square2SoundQueue
        bcs PlayBlast          ;fireworks/gunfire
        lsri Square2SoundQueue
        bcs PlayTimerTick      ;timer tick
        lsri Square2SoundQueue
        bcs PlayPowerUpGrab    ;power-up grab
        lsri Square2SoundQueue
        bcs PlayExtraLife      ;1-up

CheckSfx2Buffer:
        lda Square2SoundBuffer   ;check for sfx in buffer
         checka
        beq ExS2H                ;if not found, exit sub
        bmi ContinueBowserFall   ;bowser fall
        lsr
        bcs Cont_CGrab_TTick     ;coin grab
        lsr
        bcs ContinueGrowItems    ;power-up reveal
        lsr
        bcs ContinueGrowItems    ;vine grow
        lsr
        bcs ContinueBlast        ;fireworks/gunfire
        lsr
        bcs Cont_CGrab_TTick     ;timer tick
        lsr
        bcs ContinuePowerUpGrab  ;power-up grab
        lsr
        bcs ContinueExtraLife    ;1-up
ExS2H:  rts

Cont_CGrab_TTick:
        jmp ContinueCGrabTTick

JumpToDecLength2:
        jmp DecrementSfx2Length

PlayBowserFall:    
         ldan ++$38                ;load length of bowser defeat sound
         sta Squ2_SfxLenCounter
         ldyn ++$c4                ;load contents of reg for bowser defeat sound
         ldan ++$18
         checka
BlstSJp: bne PBFRegs ;unconditional???

ContinueBowserFall:
          lda Squ2_SfxLenCounter   ;check for almost near the end
          cmpn ++$08
          bne DecrementSfx2Length
          ldyn ++$a4                 ;if so, load the rest of reg contents for bowser defeat sound
          ldan ++$5a
PBFRegs:  ldxn ++$9f                 ;the fireworks/gunfire sound shares part of reg contents here
         checkx
EL_LRegs: bne LoadSqu2Regs         ;this is an unconditional branch outta here

PlayExtraLife:
        ldan ++$30                  ;load length of 1-up sound
        sta Squ2_SfxLenCounter

ContinueExtraLife:
          lda Squ2_SfxLenCounter   
          ldxn ++$03                  ;load new tones only every eight frames
DivLLoop: lsr
          bcs JumpToDecLength2      ;if any bits set here, branch to dec the length
          dex
          bne DivLLoop              ;do this until all bits checked, if none set, continue
          tay
          lday ExtraLifeFreqData-1,y ;load our reg contents
          ldxn ++$82
          ldyn ++$7f
         checky
          bne EL_LRegs              ;unconditional branch

PlayGrowPowerUp:
        ldan ++$10                ;load length of power-up reveal sound
         checka
        bne GrowItemRegs ;unconditional???

PlayGrowVine:
        ldan ++$20                ;load length of vine grow sound

GrowItemRegs:
        sta Squ2_SfxLenCounter   
        ldan ++$7f                  ;load contents of reg for both sounds directly
        sta SND_SQUARE2_REG+1
        ldan ++$00                  ;start secondary counter for both sounds
        sta Sfx_SecondaryCounter

ContinueGrowItems:
        inci Sfx_SecondaryCounter  ;increment secondary counter for both sounds
        lda Sfx_SecondaryCounter  ;this sound doesn't decrement the usual counter
        lsr                       ;divide by 2 to get the offset
        tay
        cpyi Squ2_SfxLenCounter    ;have we reached the end yet?
        beq StopGrowItems         ;if so, branch to jump, and stop playing sounds
        ldan ++$9d                  ;load contents of other reg directly
        sta SND_SQUARE2_REG
        lday PUp_VGrow_FreqData,y  ;use secondary counter / 2 as offset for frequency regs
        jsr SetFreq_Squ2
        rts

StopGrowItems:
        jmp EmptySfx2Buffer       ;branch to stop playing sounds

;--------------------------------

BrickShatterFreqData:
        .db $01, $0e, $0e, $0d, $0b, $06, $0c, $0f
        .db $0a, $09, $03, $0d, $08, $0d, $06, $0c

PlayBrickShatter:
        ldan ++$20                 ;load length of brick shatter sound
        sta Noise_SfxLenCounter

ContinueBrickShatter:
        lda Noise_SfxLenCounter  
        lsr                         ;divide by 2 and check for bit set to use offset
        bcc DecrementSfx3Length
        tay
        ldxy BrickShatterFreqData,y  ;load reg contents of brick shatter sound
        lday BrickShatterEnvData,y

PlayNoiseSfx:
        sta SND_NOISE_REG        ;play the sfx
        stx SND_NOISE_REG+2
        ldan ++$18
        sta SND_NOISE_REG+3
	if Z80
	call wrnoise3
	endif

DecrementSfx3Length:
        deci Noise_SfxLenCounter  ;decrement length of sfx
        bne ExSfx3
        ldan ++$f0                 ;if done, stop playing the sfx
        sta SND_NOISE_REG
        ldan ++$00
        sta NoiseSoundBuffer
ExSfx3: rts

NoiseSfxHandler:
        ldy NoiseSoundQueue   ;check for sfx in queue
         checky
        beq CheckNoiseBuffer
        sty NoiseSoundBuffer  ;if found, put in buffer
        lsri NoiseSoundQueue
        bcs PlayBrickShatter  ;brick shatter
        lsri NoiseSoundQueue
        bcs PlayBowserFlame   ;bowser flame

CheckNoiseBuffer:
        lda NoiseSoundBuffer      ;check for sfx in buffer
         checka
        beq ExNH                  ;if not found, exit sub
        lsr
        bcs ContinueBrickShatter  ;brick shatter
        lsr
        bcs ContinueBowserFlame   ;bowser flame
ExNH:   rts

PlayBowserFlame:
        ldan ++$40                    ;load length of bowser flame sound
        sta Noise_SfxLenCounter

ContinueBowserFlame:
        lda Noise_SfxLenCounter
        lsr
        tay
        ldxn ++$0f                    ;load reg contents of bowser flame sound
        lday BowserFlameEnvData-1,y
         checka
        bne PlayNoiseSfx            ;unconditional branch here

;--------------------------------

ContinueMusic:
        jmp HandleSquare2Music  ;if we have music, start with square 2 channel

MusicHandler:
        lda EventMusicQueue     ;check event music queue
         checka
        bne LoadEventMusic
        lda AreaMusicQueue      ;check area music queue
         checka
        bne LoadAreaMusic
        lda EventMusicBuffer    ;check both buffers
        orai AreaMusicBuffer
        bne ContinueMusic 
        rts                     ;no music, then leave

LoadEventMusic:
           sta EventMusicBuffer      ;copy event music queue contents to buffer
           cmpn ++DeathMusic           ;is it death music?
           bne NoStopSfx             ;if not, jump elsewhere
           jsr StopSquare1Sfx        ;stop sfx in square 1 and 2
           jsr StopSquare2Sfx        ;but clear only square 1's sfx buffer
NoStopSfx: ldx AreaMusicBuffer
           stx AreaMusicBuffer_Alt   ;save current area music buffer to be re-obtained later
           ldyn ++$00
           sty NoteLengthTblAdder    ;default value for additional length byte offset
           sty AreaMusicBuffer       ;clear area music buffer
           cmpn ++TimeRunningOutMusic  ;is it time running out music?
           bne FindEventMusicHeader
           ldxn ++$08                  ;load offset to be added to length byte of header
           stx NoteLengthTblAdder
         checkx
           bne FindEventMusicHeader  ;unconditional branch

LoadAreaMusic:
         cmpn ++$04                  ;is it underground music?
         bne NoStop1               ;no, do not stop square 1 sfx
         jsr StopSquare1Sfx
NoStop1: ldyn ++$10                  ;start counter used only by ground level music
GMLoopB: sty GroundMusicHeaderOfs

HandleAreaMusicLoopB:
         ldyn ++$00                  ;clear event music buffer
         sty EventMusicBuffer
         sta AreaMusicBuffer       ;copy area music queue contents to buffer
         cmpn ++$01                  ;is it ground level music?
         bne FindAreaMusicHeader
         inci GroundMusicHeaderOfs  ;increment but only if playing ground level music
         ldy GroundMusicHeaderOfs  ;is it time to loopback ground level music?
         cpyn ++$32
         bne LoadHeader            ;branch ahead with alternate offset
         ldyn ++$11
         checky
         bne GMLoopB               ;unconditional branch

FindAreaMusicHeader:
        ldyn ++$08                   ;load Y for offset of area music
        sty MusicOffset_Square2    ;residual instruction here

FindEventMusicHeader:
        iny                       ;increment Y pointer based on previously loaded queue contents
        lsr                       ;bit shift and increment until we find a set bit for music
        bcc FindEventMusicHeader

LoadHeader:
        lday MusicHeaderOffsetData,y  ;load offset for header
        tay
        lday MusicHeaderData,y        ;now load the header
        sta NoteLenLookupTblOfs
        lday MusicHeaderData+1,y
        sta MusicDataLow
        lday MusicHeaderData+2,y
        sta MusicDataHigh
        lday MusicHeaderData+3,y
        sta MusicOffset_Triangle
        lday MusicHeaderData+4,y
        sta MusicOffset_Square1
        lday MusicHeaderData+5,y
        sta MusicOffset_Noise
        sta NoiseDataLoopbackOfs
        ldan ++$01                     ;initialize music note counters
        sta Squ2_NoteLenCounter
        sta Squ1_NoteLenCounter
        sta Tri_NoteLenCounter
        sta Noise_BeatLenCounter
        ldan ++$00                     ;initialize music data offset for square 2
        sta MusicOffset_Square2
        sta AltRegContentFlag        ;initialize alternate control reg data used by square 1
        ldan ++$0b                     ;disable triangle channel and reenable it
        sta SND_MASTERCTRL_REG
        ldan ++$0f
        sta SND_MASTERCTRL_REG

HandleSquare2Music:
        deci Squ2_NoteLenCounter  ;decrement square 2 note length
        bne MiscSqu2MusicTasks   ;is it time for more data?  if not, branch to end tasks
        ldy MusicOffset_Square2  ;increment square 2 music offset and fetch data
        inci MusicOffset_Square2
        ldayindirect (MusicData),y
         checka
        beq EndOfMusicData       ;if zero, the data is a null terminator
        bpl Squ2NoteHandler      ;if non-negative, data is a note
        bne Squ2LengthHandler    ;otherwise it is length data

EndOfMusicData:
        lda EventMusicBuffer     ;check secondary buffer for time running out music
        cmpn ++TimeRunningOutMusic
        bne NotTRO
        lda AreaMusicBuffer_Alt  ;load previously saved contents of primary buffer
         checka
        bne MusicLoopBack        ;and start playing the song again if there is one
NotTRO: andn ++VictoryMusic        ;check for victory music (the only secondary that loops)
        bne VictoryMLoopBack
        lda AreaMusicBuffer      ;check primary buffer for any music except pipe intro
        andn ++%01011111
        bne MusicLoopBack        ;if any area music except pipe intro, music loops
        ldan ++$00                 ;clear primary and secondary buffers and initialize
        sta AreaMusicBuffer      ;control regs of square and triangle channels
        sta EventMusicBuffer
        sta SND_TRIANGLE_REG
        ldan ++$90    
        sta SND_SQUARE1_REG
        sta SND_SQUARE2_REG
        rts

MusicLoopBack:
        jmp HandleAreaMusicLoopB

VictoryMLoopBack:
        jmp LoadEventMusic

Squ2LengthHandler:
        jsr ProcessLengthData    ;store length of note
        sta Squ2_NoteLenBuffer
        ldy MusicOffset_Square2  ;fetch another byte (MUST NOT BE LENGTH BYTE!)
        inci MusicOffset_Square2
        ldayindirect (MusicData),y

Squ2NoteHandler:
          ldx Square2SoundBuffer     ;is there a sound playing on this channel?
         checkx
          bne SkipFqL1
          jsr SetFreq_Squ2           ;no, then play the note ;out: Z=NoTone
          beq Rest                   ;check to see if note is rest
          jsr LoadControlRegs        ;if not, load control regs for square 2
Rest:     sta Squ2_EnvelopeDataCtrl  ;save contents of A
          jsr Dump_Sq2_Regs          ;dump X and Y into square 2 control regs
SkipFqL1: lda Squ2_NoteLenBuffer     ;save length in square 2 note counter
          sta Squ2_NoteLenCounter

MiscSqu2MusicTasks:
           lda Square2SoundBuffer     ;is there a sound playing on square 2?
         checka
           bne HandleSquare1Music
           lda EventMusicBuffer       ;check for death music or d4 set on secondary buffer
           andn ++%10010001             ;note that regs for death music or d4 are loaded by default
           bne HandleSquare1Music
           ldy Squ2_EnvelopeDataCtrl  ;check for contents saved from LoadControlRegs
         checky
           beq NoDecEnv1
           deci Squ2_EnvelopeDataCtrl  ;decrement unless already zero
NoDecEnv1: jsr LoadEnvelopeData       ;do a load of envelope data to replace default
           sta SND_SQUARE2_REG        ;based on offset set by first load unless playing
           ldxn ++$7f                   ;death music or d4 set on secondary buffer
           stx SND_SQUARE2_REG+1

HandleSquare1Music:
        ldy MusicOffset_Square1    ;is there a nonzero offset here?
         checky
        beq HandleTriangleMusic    ;if not, skip ahead to the triangle channel
        deci Squ1_NoteLenCounter    ;decrement square 1 note length
        bne MiscSqu1MusicTasks     ;is it time for more data?

FetchSqu1MusicData:
        ldy MusicOffset_Square1    ;increment square 1 music offset and fetch data
        inci MusicOffset_Square1
        ldayindirect (MusicData),y
         checka
        bne Squ1NoteHandler        ;if nonzero, then skip this part
        ldan ++$83
        sta SND_SQUARE1_REG        ;store some data into control regs for square 1
        ldan ++$94                   ;and fetch another byte of data, used to give
        sta SND_SQUARE1_REG+1      ;death music its unique sound
        sta AltRegContentFlag
         checka
        bne FetchSqu1MusicData     ;unconditional branch

Squ1NoteHandler:
           jsr AlternateLengthHandler
           sta Squ1_NoteLenCounter    ;save contents of A in square 1 note counter
           ldy Square1SoundBuffer     ;is there a sound playing on square 1?
         checky
           bne HandleTriangleMusic
           txa
           andn ++%00111110             ;change saved data to appropriate note format
           jsr SetFreq_Squ1           ;play the note ;out: Z=NoTone
           beq SkipCtrlL
           jsr LoadControlRegs
SkipCtrlL: sta Squ1_EnvelopeDataCtrl  ;save envelope offset
           jsr Dump_Squ1_Regs

MiscSqu1MusicTasks:
              lda Square1SoundBuffer     ;is there a sound playing on square 1?
         checka
              bne HandleTriangleMusic
              lda EventMusicBuffer       ;check for death music or d4 set on secondary buffer
              andn ++%10010001
              bne DeathMAltReg
              ldy Squ1_EnvelopeDataCtrl  ;check saved envelope offset
         checky
              beq NoDecEnv2
              deci Squ1_EnvelopeDataCtrl  ;decrement unless already zero
NoDecEnv2:    jsr LoadEnvelopeData       ;do a load of envelope data
              sta SND_SQUARE1_REG        ;based on offset set by first load
DeathMAltReg: lda AltRegContentFlag      ;check for alternate control reg data
         checka
              bne DoAltLoad
              ldan ++$7f                   ;load this value if zero, the alternate value
DoAltLoad:    sta SND_SQUARE1_REG+1      ;if nonzero, and let's move on

HandleTriangleMusic:
        lda MusicOffset_Triangle
        deci Tri_NoteLenCounter    ;decrement triangle note length
        bne HandleNoiseMusic      ;is it time for more data?
        ldy MusicOffset_Triangle  ;increment square 1 music offset and fetch data
        inci MusicOffset_Triangle
        ldayindirect (MusicData),y
         checka
        beq LoadTriCtrlReg        ;if zero, skip all this and move on to noise 
        bpl TriNoteHandler        ;if non-negative, data is note
        jsr ProcessLengthData     ;otherwise, it is length data
        sta Tri_NoteLenBuffer     ;save contents of A
        ldan ++$1f
        sta SND_TRIANGLE_REG      ;load some default data for triangle control reg
        ldy MusicOffset_Triangle  ;fetch another byte
        inci MusicOffset_Triangle
        ldayindirect (MusicData),y
         checka
        beq LoadTriCtrlReg        ;check once more for nonzero data

TriNoteHandler:
          jsr SetFreq_Tri
          ldx Tri_NoteLenBuffer   ;save length in triangle note counter
          stx Tri_NoteLenCounter
          lda EventMusicBuffer
          andn ++%01101110          ;check for death music or d4 set on secondary buffer
          bne NotDOrD4            ;if playing any other secondary, skip primary buffer check
          lda AreaMusicBuffer     ;check primary buffer for water or castle level music
          andn ++%00001010
          beq HandleNoiseMusic    ;if playing any other primary, or death or d4, go on to noise routine
NotDOrD4: txa                     ;if playing water or castle music or any secondary
          cmpn ++$12                ;besides death music or d4 set, check length of note
              cmpcy
          bcs LongN
          lda EventMusicBuffer    ;check for win castle music again if not playing a long note
          andn ++EndOfCastleMusic
          beq MediN
          ldan ++$0f                ;load value $0f if playing the win castle music and playing a short
         checka
          bne LoadTriCtrlReg ;unconditional???     ;note, load value $1f if playing water or castle level music or any
MediN:    ldan ++$1f                ;secondary besides death and d4 except win castle or win castle and playing
         checka
          bne LoadTriCtrlReg ;unconditional???     ;a short note, and load value $ff if playing a long note on water, castle
LongN:    ldan ++$ff                ;or any secondary (including win castle) except death and d4

LoadTriCtrlReg:           
        sta SND_TRIANGLE_REG      ;save final contents of A into control reg for triangle

HandleNoiseMusic:
        lda AreaMusicBuffer       ;check if playing underground or castle music
        andn ++%11110011
        beq ExitMusicHandler      ;if so, skip the noise routine
        deci Noise_BeatLenCounter  ;decrement noise beat length
        bne ExitMusicHandler      ;is it time for more data?

FetchNoiseBeatData:
        ldy MusicOffset_Noise       ;increment noise beat offset and fetch data
        inci MusicOffset_Noise
        ldayindirect (MusicData),y           ;get noise beat data, if nonzero, branch to handle
         checka
        bne NoiseBeatHandler
        lda NoiseDataLoopbackOfs    ;if data is zero, reload original noise beat offset
        sta MusicOffset_Noise       ;and loopback next time around
         checka
        bne FetchNoiseBeatData      ;unconditional branch

NoiseBeatHandler:
        jsr AlternateLengthHandler
        sta Noise_BeatLenCounter    ;store length in noise beat counter
        txa
        andn ++%00111110              ;reload data and erase length bits
        beq SilentBeat              ;if no beat data, silence
        cmpn ++$30                    ;check the beat data and play the appropriate
        beq LongBeat                ;noise accordingly
        cmpn ++$20
        beq StrongBeat
        andn ++%00010000  
        beq SilentBeat
        ldan ++$1c        ;short beat data
        ldxn ++$03
        ldyn ++$18
         checky
        bne PlayBeat ;unconditional???

StrongBeat:
        ldan ++$1c        ;strong beat data
        ldxn ++$0c
        ldyn ++$18
         checky
        bne PlayBeat ;unconditional???

LongBeat:
        ldan ++$1c        ;long beat data
        ldxn ++$03
        ldyn ++$58
         checky
        bne PlayBeat ;unconditional???

SilentBeat:
        ldan ++$10        ;silence

PlayBeat:
        sta SND_NOISE_REG    ;load beat data into noise regs
        stx SND_NOISE_REG+2
        sty SND_NOISE_REG+3
        if Z80
;write to SND_REGISTER+3 causes counter loading from a table
	ld a,e
wrnoise3
        rra
        rra
        rra
        and 0x1f
        ld hl,tcounterload
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl) ;читает 5, а на слух надо примерно 0x10 для музыки, для флага больше, только эффекты покороче
	add a,a
        ld (SND_COUNTER+12),a
;Only a write out to $4003/$4007/$400F will reset the current envelope decay counter to a known state (to $F, the maximum volume level) for the appropriate channel's envelope decay hardware.
        ld a,0x0f
        ld (SND_DECAYVOL+12),a
        endif

ExitMusicHandler:
        rts

AlternateLengthHandler:
        tax            ;save a copy of original byte into X
        ror            ;save LSB from original byte into carry
        txa            ;reload original byte and rotate three times
        rol            ;turning xx00000x into 00000xxx, with the
        rol            ;bit in carry as the MSB here
        rol

ProcessLengthData:
        andn ++%00000111              ;clear all but the three LSBs
        clc
        adci NoteLenLookupTblOfs;SCRATCHPAD+$f0                     ;add offset loaded from first header byte
        adci NoteLengthTblAdder      ;add extra if time running out music
        tay
        lday MusicLengthLookupTbl,y  ;load length
        rts

LoadControlRegs:
           lda EventMusicBuffer  ;check secondary buffer for win castle music
           andn ++EndOfCastleMusic
           beq NotECstlM
           ldan ++$04              ;this value is only used for win castle music
         checka
           bne AllMus            ;unconditional branch
NotECstlM: lda AreaMusicBuffer
           andn ++%01111101        ;check primary buffer for water music
           beq WaterMus
           ldan ++$08              ;this is the default value for all other music
         checka
           bne AllMus
WaterMus:  ldan ++$28              ;this value is used for water music and all other event music
AllMus:    ldxn ++$82              ;load contents of other sound regs for square 2
           ldyn ++$7f
           rts

LoadEnvelopeData:
        lda EventMusicBuffer           ;check secondary buffer for win castle music
        andn ++EndOfCastleMusic
        beq LoadUsualEnvData
        lday EndOfCastleMusicEnvData,y  ;load data from offset for win castle music
        rts

LoadUsualEnvData:
        lda AreaMusicBuffer            ;check primary buffer for water music
        andn ++%01111101
        beq LoadWaterEventMusEnvData
        lday AreaMusicEnvData,y         ;load default data from offset for all other music
        rts

LoadWaterEventMusEnvData:
        lday WaterEventMusEnvData,y     ;load data from offset for water music and all other event music
        rts
