
;SMBDIS.ASM - A COMPREHENSIVE SUPER MARIO BROS. DISASSEMBLY (Super Mario Bros (JU))
;by doppelganger (doppelheathen@gmail.com)

;This file is provided for your own use as-is.  It will require the character rom data
;and an iNES file header to get it to work.

;There are so many people I have to thank for this, that taking all the credit for
;myself would be an unforgivable act of arrogance. Without their help this would
;probably not be possible.  So I thank all the peeps in the nesdev scene whose insight into
;the 6502 and the NES helped me learn how it works (you guys know who you are, there's no 
;way I could have done this without your help), as well as the authors of x816 and SMB 
;Utility, and the reverse-engineers who did the original Super Mario Bros. Hacking Project, 
;which I compared notes with but did not copy from.  Last but certainly not least, I thank
;Nintendo for creating this game and the NES, without which this disassembly would
;only be theory.

;Assembles with x816.

;< LOW  low byte
;> HIGH  high byte

;-------------------------------------------------------------------------------------
;DIRECTIVES

        if Z80==0
       .index 8
       .mem 8

       .org $8000
        endif

;-------------------------------------------------------------------------------------

Start:
        if Z80==0
             sei                          ;pretty standard 6502 type init here
             cld
             ldan ++%00010000               ;init PPU control register 1 
             sta PPU_CTRL_REG1
             ldxn ++$ff                     ;reset stack pointer
             txs
VBlank1:     lda PPU_STATUS               ;wait two frames
         checka
             bpl VBlank1
VBlank2:     lda PPU_STATUS
         checka
             bpl VBlank2
        endif
             ldyn16 ++MEMDATA_end-AREADATA;ColdBootOffset          ;load default cold boot pointer
             ldxn ++$05                     ;this is where we check for a warm boot
WBootCheck:  
        if Z80==0
             ldax TopScoreDisplay,x        ;check each score digit in the top score
             cmpn ++10                      ;to see if we have a valid digit
              cmpcy
             bcs ColdBoot                 ;if not, give up and proceed with cold boot
             dex                      
             bpl WBootCheck
             lda WarmBootValidation       ;second checkpoint, check to see if 
             cmpn ++$a5                     ;another location has a specific value
             bne ColdBoot   
             ldyn16 ++WARMMEMDATA_end-AREADATA;WarmBootOffset          ;if passed both, load warm boot pointer
        endif
ColdBoot:    jsr InitializeMemory         ;clear memory using pointer in Y
             sta SND_DELTA_REG+1          ;reset delta counter load register
             sta OperMode                 ;reset primary mode of operation
             ldan ++$a5                     ;set warm boot flag
             sta WarmBootValidation     
             sta PseudoRandomBitReg       ;set seed for pseudorandom register
             ldan ++%00001111
             sta SND_MASTERCTRL_REG       ;enable all sound channels except dmc
        if Z80==0
             ldan ++%00000110
             sta PPU_CTRL_REG2            ;turn off clipping for OAM and background
        endif
             jsr MoveAllSpritesOffscreen
             jsr InitializeNameTables     ;initialize both name tables
             inci DisableScreenFlag        ;set flag to disable screen output
        if Z80==0
             lda Mirror_PPU_CTRL_REG1
             oran ++%10000000               ;enable NMIs
             jsr WritePPUReg1
        endif
	
             call NonMaskableInterrupt
	call gettimer ;hl=timer
         ld (oldupdtimer),hl
	 
EndlessLoop:
        if Z80
             call EmulatePPU
	call gettimer ;hl=timer
oldupdtimer=$+1
         ld de,oldupdtimer
	 ld (oldupdtimer),hl
	     or a
	     sbc hl,de
	if FASTDEMOBEFOREBREAKPOINT
	     ld c,1
	     jr z,c_logic0
	else
	     jr z,nologic
	endif
	     ld c,8
	     ld a,l
	     cp c
	     jr nc,$+3 ;больше бывает только в брякпоинтах
	     ld c,l
c_logic0
            ld hl,logicframe
            ld (hl),c
	     ld b,0
	     ld d,b
logic0
             call NonMaskableInterrupt
            ld hl,logicframe
            dec (hl)
	    jr nz,logic0
		jr logicq
nologic
        ;jr $ ;реально не попадаем сюда при нормальной игре
		YIELD;halt
	     ld b,0
	     ld d,b
logicq
        endif
             jmp EndlessLoop              ;endless loop, need I say more?

	if MUSICONINT
	include "smbsound.asm"
        include "smbmusic.asm"
        ;display $,"<=0x8000"
	endif

;-------------------------------------------------------------------------------------
;$00 - vram buffer address table low, also used for pseudorandom bit
;$01 - vram buffer address table high

VRAM_AddrTable_Low:
      .db LOW VRAM_Buffer1, LOW WaterPaletteData, LOW GroundPaletteData
      .db LOW UndergroundPaletteData, LOW CastlePaletteData, LOW VRAM_Buffer1_Offset
      .db LOW VRAM_Buffer2, LOW VRAM_Buffer2, LOW BowserPaletteData
      .db LOW DaySnowPaletteData, LOW NightSnowPaletteData, LOW MushroomPaletteData
      .db LOW MarioThanksMessage, LOW LuigiThanksMessage, LOW MushroomRetainerSaved
      .db LOW PrincessSaved1, LOW PrincessSaved2, LOW WorldSelectMessage1
      .db LOW WorldSelectMessage2

VRAM_AddrTable_High:
      .db HIGH VRAM_Buffer1, HIGH WaterPaletteData, HIGH GroundPaletteData
      .db HIGH UndergroundPaletteData, HIGH CastlePaletteData, HIGH VRAM_Buffer1_Offset
      .db HIGH VRAM_Buffer2, HIGH VRAM_Buffer2, HIGH BowserPaletteData
      .db HIGH DaySnowPaletteData, HIGH NightSnowPaletteData, HIGH MushroomPaletteData
      .db HIGH MarioThanksMessage, HIGH LuigiThanksMessage, HIGH MushroomRetainerSaved
      .db HIGH PrincessSaved1, HIGH PrincessSaved2, HIGH WorldSelectMessage1
      .db HIGH WorldSelectMessage2

      if Z80
tpalettes
	dw waterpalette
	dw groundpalette
	dw undergroundpalette
	dw castlepalette
      endif
      
VRAM_Buffer_Offset:
      .db LOW VRAM_Buffer1_Offset, LOW VRAM_Buffer2_Offset

NonMaskableInterrupt:
        if Z80
               ;ldx VRAM_Buffer_AddrCtrl  ;load control for pointer to buffer contents
               ;ldax VRAM_AddrTable_High,x
               ;ld d,a
               ;ldax VRAM_AddrTable_Low,x
               ;ld e,a
               ;ex de,hl
               ;ld de,PPU_SPRLIST
               ;ld bc,0x100
               ;ldir
               ;ex de,hl
               ;ld d,b;0
               lda Mirror_PPU_CTRL_REG1  ;d0 = страница (для скролла)
               sta PPU_CTRL_REG1
        else
               lda Mirror_PPU_CTRL_REG1  ;disable NMIs in mirror reg
               andn ++%01111111            ;save all other bits
               sta Mirror_PPU_CTRL_REG1
               andn ++%01111110            ;alter name table address to be $2800 ;чтобы выводить всегда страницу со счётом
               sta PPU_CTRL_REG1         ;(essentially $2000) but save other bits
               lda Mirror_PPU_CTRL_REG2  ;disable OAM and background display by default
               andn ++%11100110
               ldy DisableScreenFlag     ;get screen disable flag
         checky
               bne ScreenOff             ;if set, used bits as-is
               lda Mirror_PPU_CTRL_REG2  ;otherwise reenable bits and save them
               oran ++%00011110
ScreenOff:     sta Mirror_PPU_CTRL_REG2  ;save bits for later but not in register at the moment
               andn ++%11100111            ;disable screen for now
               sta PPU_CTRL_REG2
               ldx PPU_STATUS            ;reset flip-flop and reset scroll registers to zero
               ldan ++$00
               jsr InitScroll ;пишет нули в скроллы (чтобы не скроллить счёт)
               sta PPU_SPR_ADDR          ;reset spr-ram address register
               ldan ++$02                  ;perform spr-ram DMA access on $0200-$02ff
               sta SPR_DMA
        endif
               ldx VRAM_Buffer_AddrCtrl  ;load control for pointer to buffer contents
               ldax VRAM_AddrTable_Low,x  ;set indirect at $00 to pointer
               sta SCRATCHPAD+$00
               ldax VRAM_AddrTable_High,x
               sta SCRATCHPAD+$01
              ;cp 0x03
              ;jr nz,$
               jsr UpdateScreen          ;update screen with buffer contents
               ldyn ++$00
               ldx VRAM_Buffer_AddrCtrl  ;check for usage of $0341 ;VRAM_Buffer2???
               cpxn ++$06
               bne InitBuffer
               iny                       ;get offset based on usage
InitBuffer:    ldxy VRAM_Buffer_Offset,y
               ldan ++$00                  ;clear buffer header at last location
               stax VRAM_Buffer1_Offset,x        
               stax VRAM_Buffer1,x
               sta VRAM_Buffer_AddrCtrl  ;reinit address control to $0301 ;VRAM_Buffer1???
        if Z80==0
               lda Mirror_PPU_CTRL_REG2  ;copy mirror of $2001 to register
               sta PPU_CTRL_REG2
        endif
          if MUSICONINT==0
               jsr SoundEngine           ;play sound
          else
soundenginepatch=$+1
               call SoundEngine_noint           ;play sound logically
          endif
               jsr ReadJoypads           ;read joypads
	      if DEMO
	      ld a,(readdemo_stopflag)
	      or a
	      jr nz,randomskip;PauseSkip
	      endif
               jsr PauseRoutine          ;handle pause ;почему-то если выше, то после выхода из демы включает паузу
               jsr UpdateTopScore
               lda GamePauseStatus       ;check for pause status
               lsr
               bcs PauseSkip
              if Z80;OPT
               ld a,(TimerControl)          ;if master timer control not set, decrement
               or a
               jr z,DecTimers             ;all frame and interval timers
               dec a
               ld (TimerControl),a
               jr nz,NoDecTimers
DecTimers:     ;xor a
               ld b,21;ldxn ++$14                  ;load end offset for end of frame timers
               ld hl,IntervalTimerControl
               dec (hl) ;decrement interval timer control,
               ld hl,Timers+20
               jp p,DecTimersLoop         ;if not expired, only frame timers will decrement
               ld a,20
               ld (IntervalTimerControl),a  ;if control for interval timers expired, (21 frame rule???)
               ld b,36;ldxn ++$23                  ;interval timers will decrement along with frame timers
               ld hl,Timers+35
               xor a
DecTimersLoop: cp (hl);ldax Timers,x              ;check current timer
               jr z,SkipExpTimer          ;if current timer expired, branch to skip,
               dec (hl);decx Timers,x              ;otherwise decrement the current timer
SkipExpTimer:  dec hl ;dex                       ;move onto next timer
               djnz DecTimersLoop         ;do this until all timers are dealt with
NoDecTimers:   ld hl,FrameCounter
               inc (hl) ;increment frame counter
              else ;~Z80
               lda TimerControl          ;if master timer control not set, decrement
         checka
               beq DecTimers             ;all frame and interval timers
               deci TimerControl
               bne NoDecTimers
DecTimers:     ldxn ++$14                  ;load end offset for end of frame timers
               deci IntervalTimerControl  ;decrement interval timer control,
               bpl DecTimersLoop         ;if not expired, only frame timers will decrement
               ldan ++$14
               sta IntervalTimerControl  ;if control for interval timers expired, (21 frame rule???)
               ldxn ++$23                  ;interval timers will decrement along with frame timers
DecTimersLoop: ldax Timers,x              ;check current timer
         checka
               beq SkipExpTimer          ;if current timer expired, branch to skip,
               decx Timers,x              ;otherwise decrement the current timer
SkipExpTimer:  dex                       ;move onto next timer
               bpl DecTimersLoop         ;do this until all timers are dealt with
NoDecTimers:   inci FrameCounter          ;increment frame counter
              endif
PauseSkip:     ldxn ++$00
               ldyn ++$07
               lda PseudoRandomBitReg    ;get first memory location of LSFR bytes
               andn ++%00000010            ;mask out all but d1
               sta SCRATCHPAD+$00                   ;save here
               lda PseudoRandomBitReg+1  ;get second memory location
               andn ++%00000010            ;mask out all but d1
               eori SCRATCHPAD+$00                   ;perform exclusive-OR on d1 from first and second bytes
               clc                       ;if neither or both are set, carry will be clear
               beq RotPRandomBit
               sec                       ;if one or the other is set, carry will be set
RotPRandomBit: rorx PseudoRandomBitReg,x  ;rotate carry into d7, and rotate last bit into carry
               inx                       ;increment to next byte
               dey                       ;decrement for loop
               bne RotPRandomBit
randomskip               
               lda Sprite0HitDetectFlag  ;check for flag here
         checka
               beq SkipSprite0
               
              if Z80==0
Sprite0Clr:    lda PPU_STATUS            ;wait for sprite 0 flag to clear, which will
               andn ++%01000000            ;not happen until vblank has ended
               bne Sprite0Clr
              endif
	      if DEMO
	      ld a,(readdemo_stopflag)
	      or a
	      jr nz,Sprite0Hit
	      endif
               lda GamePauseStatus       ;if in pause mode, do not bother with sprites at all
               lsr
               bcs Sprite0Hit
               jsr MoveSpritesOffscreen ;3443t (3 Goomba + 2 очки + Марио)
               jsr SpriteShuffler ;545t
Sprite0Hit:
              if Z80==0
               lda PPU_STATUS            ;do sprite ++0 hit detection
               andn ++%01000000
               beq Sprite0Hit ;ждём, когда будет край монетки наверху экрана - это конец нескроллируемой зоны
               ldyn ++$14                  ;small delay, to wait until we hit horizontal blank time
HBlankDelay:   dey
               bne HBlankDelay
              endif
              
SkipSprite0:   lda HorizontalScroll      ;set scroll registers from variables
               sta PPU_SCROLL_REG_H
               lda VerticalScroll
               sta PPU_SCROLL_REG_V
              if Z80==0
               lda Mirror_PPU_CTRL_REG1  ;load saved mirror of $2000
               pha
               sta PPU_CTRL_REG1
              endif
	      if DEMO
	      ld a,(readdemo_stopflag)
	      or a
	      jr nz,SkipMainOper
	      endif
               lda GamePauseStatus       ;if in pause mode, do not perform operation mode stuff
               lsr ;почему мы в режиме паузы??? 1
               bcs SkipMainOper
               jsr OperModeExecutionTree ;otherwise do one of many, many possible subroutines ;49489t (3 Goomba + 2 очки + Марио)
SkipMainOper:
              if Z80==0
               lda PPU_STATUS            ;reset flip-flop
               pla
               oran ++%10000000            ;reactivate NMIs
               sta PPU_CTRL_REG1
              endif
               rti                       ;we are done until the next frame!

;-------------------------------------------------------------------------------------

PauseRoutine:
               lda OperMode           ;are we in victory mode?
               cmpn ++VictoryModeValue  ;if so, go ahead
               beq ChkPauseTimer
               cmpn ++GameModeValue     ;are we in game mode?
               bne ExitPause          ;if not, leave
               lda OperMode_Task      ;if we are in game mode, are we running game engine?
               cmpn ++$03
               bne ExitPause          ;if not, leave
ChkPauseTimer: lda GamePauseTimer     ;check if pause timer is still counting down
         checka
               beq ChkStart
               deci GamePauseTimer     ;if so, decrement and leave
               rts
ChkStart:      lda SavedJoypad1Bits   ;check to see if start is pressed
               andn ++Start_Button      ;on controller 1
               beq ClrPauseTimer
               lda GamePauseStatus    ;check to see if timer flag is set
               andn ++%10000000         ;and if so, do not reset timer (residual,
               bne ExitPause          ;joypad reading routine makes this unnecessary)
               ;jr $
               ldan ++$2b               ;set pause timer
               sta GamePauseTimer
               lda GamePauseStatus
               tay
               iny                    ;set pause sfx queue for next pause mode
               sty PauseSoundQueue
               eorn ++%00000001         ;invert d0 and set d7
               oran ++%10000000
               bne SetPause           ;unconditional branch
ClrPauseTimer: lda GamePauseStatus    ;clear timer flag if timer is at zero and start button
               andn ++%01111111         ;is not pressed
SetPause:      sta GamePauseStatus
ExitPause:     rts

;-------------------------------------------------------------------------------------
;$00 - used for preset value

SpriteShuffler:
        if Z80
        else
               ldy AreaType                ;load level type, likely residual code
               ldan ++$28                    ;load preset value which will put it at
               sta SCRATCHPAD+$00                     ;sprite #10
               ldxn ++$0e                    ;start at the end of OAM data offsets
               
ShuffleLoop:   ldax SprDataOffset,x         ;check for offset value against
               cmpi SCRATCHPAD+$00                     ;the preset value
              cmpcy
               bcc NextSprOffset           ;if less, skip this part
               ldy SprShuffleAmtOffset     ;get current offset to preset value we want to add
               clc
               adcy SprShuffleAmt,y         ;get shuffle amount, add to current sprite offset
               bcc StrSprOffset            ;if not exceeded $ff, skip second add
               clc
               adci SCRATCHPAD+$00                     ;otherwise add preset value $28 to offset
StrSprOffset:  stax SprDataOffset,x         ;store new offset here or old one if branched to here
NextSprOffset: dex                         ;move backwards to next one
               bpl ShuffleLoop
               
               ldx SprShuffleAmtOffset     ;load offset
               inx
               cpxn ++$03                    ;check if offset + 1 goes to 3
               bne SetAmtOffset            ;if offset + 1 not 3, store
               ldxn ++$00                    ;otherwise, init to 0
SetAmtOffset:  stx SprShuffleAmtOffset
        endif
               ldxn ++$08                    ;load offsets for values and storage
               ldyn ++$02
               
SetMiscOffset: lday SprDataOffset+5,y       ;load one of three OAM data offsets
               stax Misc_SprDataOffset-2,x  ;store first one unmodified, but
               clc                         ;add eight to the second and eight
               adcn ++$08                    ;more to the third one
               stax Misc_SprDataOffset-1,x  ;note that due to the way X is set up,
               clc                         ;this code loads into the misc sprite offsets
               adcn ++$08
               stax Misc_SprDataOffset,x        
               dex
               dex
               dex
               dey
               bpl SetMiscOffset           ;do this until all misc spr offsets are loaded (3 штуки)
               rts

;-------------------------------------------------------------------------------------

OperModeExecutionTree:
      lda OperMode     ;this is the heart of the entire program,
      jsr JumpEngine   ;most of what goes on starts here

      .dw TitleScreenMode
      .dw GameMode
      .dw VictoryMode
      .dw GameOverMode

;-------------------------------------------------------------------------------------

MoveAllSpritesOffscreen:
              ldyn ++$00                ;this routine moves all sprites off the screen
              jr MoveSpritesOffscreen_go;.db $2c                 ;BIT instruction opcode

MoveSpritesOffscreen:
              ldyn ++$04                ;this routine moves all but sprite 0
MoveSpritesOffscreen_go
              ldan ++$f8                ;off the screen
SprInitLoop:  stay Sprite_Y_Position,y ;write 248 into OAM data's Y coordinate
              iny                     ;which will move it off the screen
              iny
              iny
              iny
              bne SprInitLoop
              rts

;-------------------------------------------------------------------------------------

TitleScreenMode:
      lda OperMode_Task
      jsr JumpEngine

      .dw InitializeGame
      .dw ScreenRoutines
      .dw PrimaryGameSetup
      .dw GameMenuRoutine

;-------------------------------------------------------------------------------------

WSelectBufferTemplate:
      .db $04, $20, $73, $01, $00, $00

GameMenuRoutine:
        ;jr $
              ldyn ++$00
              lda SavedJoypad1Bits        ;check to see if either player pressed
              orai SavedJoypad2Bits        ;only the start button (either joypad)
              cmpn ++Start_Button
              beq StartGame
              cmpn ++A_Button+Start_Button  ;check to see if A + start was pressed
              bne ChkSelect               ;if not, branch to check select button
StartGame:    
	;jr $
		jmp ChkContinue             ;if either start or A + start, execute here
ChkSelect:    cmpn ++Select_Button          ;check to see if the select button was pressed
              beq SelectBLogic            ;if so, branch reset demo timer
              ldx DemoTimer               ;otherwise check demo timer
         checkx
              bne ChkWorldSel             ;if demo timer not expired, branch to check world selection
              sta SelectTimer             ;set controller bits here if running demo
              jsr DemoEngine              ;run through the demo actions
              bcs ResetTitle              ;if carry flag set, demo over, thus branch
	;jr $ ;сюда попадаем
              jmp RunDemo                 ;otherwise, run game engine for demo
ChkWorldSel:  ldx WorldSelectEnableFlag   ;check to see if world selection has been enabled
         checkx
              beq NullJoypad
              cmpn ++B_Button               ;if so, check to see if the B button was pressed
              bne NullJoypad
              iny                         ;if so, increment Y and execute same code as select
SelectBLogic: lda DemoTimer               ;if select or B pressed, check demo timer one last time
	;jr $ ;сюда попадаем по select
         checka
              beq ResetTitle              ;if demo timer expired, branch to reset title screen mode
	;jr $ ;сюда попадаем по select только с правильными таймерами
              ldan ++$18                    ;otherwise reset demo timer
              sta DemoTimer
              lda SelectTimer             ;check select/B button timer
         checka
              bne NullJoypad              ;if not expired, branch
              ldan ++$10                    ;otherwise reset select button timer
              sta SelectTimer
              cpyn ++$01                    ;was the B button pressed earlier?  if so, branch
              beq IncWorldSel             ;note this will not be run if world selection is disabled
	;jr $ ;сюда попадаем по select только с правильными таймерами
              lda NumberOfPlayers         ;if no, must have been the select button, therefore
              eorn ++%00000001              ;change number of players and draw icon accordingly
              sta NumberOfPlayers
              jsr DrawMushroomIcon
              jmp NullJoypad
IncWorldSel:  ldx WorldSelectNumber       ;increment world select number
              inx
              txa
              andn ++%00000111              ;mask out higher bits
              sta WorldSelectNumber       ;store as current world select number
              jsr GoContinue
UpdateShroom: ldax WSelectBufferTemplate,x ;write template for world select in vram buffer
              stax VRAM_Buffer1-1,x        ;do this until all bytes are written
              inx
              cpxn ++$06
              bmi UpdateShroom
              ldy WorldNumber             ;get world number from variable and increment for
              iny                         ;proper display, and put in blank byte before
              sty VRAM_Buffer1+3          ;null terminator
NullJoypad:   ldan ++$00                    ;clear joypad bits for player 1
              sta SavedJoypad1Bits
RunDemo:      jsr GameCoreRoutine         ;run game engine
              lda GameEngineSubroutine    ;check to see if we're running lose life routine
              cmpn ++$06
              bne ExitMenu                ;if not, do not do all the resetting below
ResetTitle:   ldan ++$00                    ;reset game modes, disable
              sta OperMode                ;sprite 0 check and disable
              sta OperMode_Task           ;screen output
              sta Sprite0HitDetectFlag
              inci DisableScreenFlag
              rts
ChkContinue:  ldy DemoTimer               ;if timer for demo has expired, reset modes
         checky
		;jr $
              beq ResetTitle ;почему мешает демам??? если закомментировать, то из демы по Start попадаем не в меню, а в игру, с большим Марио, если он уже большой
              asl                         ;check to see if A button was also pushed
              bcc StartWorld1             ;if not, don't load continue function's world number
              lda ContinueWorld           ;load previously saved world number for secret
              jsr GoContinue              ;continue function when pressing A + start
StartWorld1:  jsr LoadAreaPointer

	;jr $ ;сюда попадаем по start
              inci Hidden1UpFlag           ;set 1-up box flag for both players
              inci OffScr_Hidden1UpFlag
              inci FetchNewGameTimerFlag   ;set fetch new game timer flag
              inci OperMode                ;set next game mode
              lda WorldSelectEnableFlag   ;if world select flag is on, then primary
              sta PrimaryHardMode         ;hard mode must be on as well
              ldan ++$00
              sta OperMode_Task           ;set game mode here, and clear demo timer
              sta DemoTimer
              ldxn ++$17
              ldan ++$00
InitScores:   stax ScoreAndCoinDisplay,x   ;clear player scores and coin displays
              dex
              bpl InitScores
ExitMenu:     rts
GoContinue:   sta WorldNumber             ;start both players at the first area
              sta OffScr_WorldNumber      ;of the previously saved world number
              ldxn ++$00                    ;note that on power-up using this function
              stx AreaNumber              ;will make no difference
              stx OffScr_AreaNumber   
              rts

;-------------------------------------------------------------------------------------

MushroomIconData:
      .db $07, $22, $49, $83, $ce, $24, $24, $00

DrawMushroomIcon:
              ldyn ++$07                ;read eight bytes to be read by transfer routine
IconDataRead: lday MushroomIconData,y  ;note that the default position is set for a
              stay VRAM_Buffer1-1,y    ;1-player game
              dey
              bpl IconDataRead
              lda NumberOfPlayers     ;check number of players
         checka
              beq ExitIcon            ;if set to 1-player game, we're done
              ldan ++$24                ;otherwise, load blank tile in 1-player position
              sta VRAM_Buffer1+3
              ldan ++$ce                ;then load shroom icon tile in 2-player position
              sta VRAM_Buffer1+5
ExitIcon:     rts

;-------------------------------------------------------------------------------------

DemoActionData:
      .db $01, $80, $02, $81, $41, $80, $01
      .db $42, $c2, $02, $80, $41, $c1, $41, $c1
      .db $01, $c1, $01, $02, $80, $00

DemoTimingData:
      .db $9b, $10, $18, $05, $2c, $20, $24
      .db $15, $5a, $10, $20, $28, $30, $20, $10
      .db $80, $20, $30, $30, $01, $ff, $00

DemoEngine:
          ldx DemoAction         ;load current demo action
          lda DemoActionTimer    ;load current action timer
         checka
          bne DoAction           ;if timer still counting down, skip
          inx
          inci DemoAction         ;if expired, increment action, X, and
          sec                    ;set carry by default for demo over
          ldax DemoTimingData-1,x ;get next timer
        if Z80
        sec
        endif
          sta DemoActionTimer    ;store as current timer
         checka
          beq DemoOver           ;if timer already at zero, skip
DoAction: ldax DemoActionData-1,x ;get and perform action (current or next)
          sta SavedJoypad1Bits
          deci DemoActionTimer    ;decrement action timer
          clc                    ;clear carry if demo still going
DemoOver: rts

;-------------------------------------------------------------------------------------

VictoryMode:
            jsr VictoryModeSubroutines  ;run victory mode subroutines
            lda OperMode_Task           ;get current task of victory mode
         checka
            beq AutoPlayer              ;if on bridge collapse, skip enemy processing
            ldxn ++$00
            stx ObjectOffset            ;otherwise reset enemy object offset 
            jsr EnemiesAndLoopsCore     ;and run enemy code
AutoPlayer: jsr RelativePlayerPosition  ;get player's relative coordinates
            jmp PlayerGfxHandler        ;draw the player, then leave

VictoryModeSubroutines:
      lda OperMode_Task
      jsr JumpEngine

      .dw BridgeCollapse
      .dw SetupVictoryMode
      .dw PlayerVictoryWalk
      .dw PrintVictoryMessages
      .dw PlayerEndWorld

;-------------------------------------------------------------------------------------

SetupVictoryMode:
      ldx ScreenRight_PageLoc  ;get page location of right side of screen
      inx                      ;increment to next page
      stx DestinationPageLoc   ;store here
      ldan ++EndOfCastleMusic
      sta EventMusicQueue      ;play win castle music
      jmp IncModeTask_B        ;jump to set next major task in victory mode

;-------------------------------------------------------------------------------------

PlayerVictoryWalk:
             ldyn ++$00                ;set value here to not walk player by default
             sty VictoryWalkControl
             lda Player_PageLoc      ;get player's page location
             cmpi DestinationPageLoc  ;compare with destination page location
             bne PerformWalk         ;if page locations don't match, branch
             lda Player_X_Position   ;otherwise get player's horizontal position
             cmpn ++$60                ;compare with preset horizontal position
              cmpcy
             bcs DontWalk            ;if still on other page, branch ahead
PerformWalk: inci VictoryWalkControl  ;otherwise increment value and Y
             iny                     ;note Y will be used to walk the player
DontWalk:    tya                     ;put contents of Y in A and
             jsr AutoControlPlayer   ;use A to move player to the right or not
             lda ScreenLeft_PageLoc  ;check page location of left side of screen
             cmpi DestinationPageLoc  ;against set value here
             beq ExitVWalk           ;branch if equal to change modes if necessary
             lda ScrollFractional
             clc                     ;do fixed point math on fractional part of scroll
             adcn ++$80        
             sta ScrollFractional    ;save fractional movement amount
             ldan ++$01                ;set 1 pixel per frame
             adcn ++$00                ;add carry from previous addition
             tay                     ;use as scroll amount
             jsr ScrollScreen        ;do sub to scroll the screen
             jsr UpdScrollVar        ;do another sub to update screen and scroll variables
             inci VictoryWalkControl  ;increment value to stay in this routine
ExitVWalk:   lda VictoryWalkControl  ;load value set here
         checka
             beq IncModeTask_A       ;if zero, branch to change modes
             rts                     ;otherwise leave

;-------------------------------------------------------------------------------------

PrintVictoryMessages:
               lda SecondaryMsgCounter   ;load secondary message counter
         checka
               bne IncMsgCounter         ;if set, branch to increment message counters
               lda PrimaryMsgCounter     ;otherwise load primary message counter
         checka
               beq ThankPlayer           ;if set to zero, branch to print first message
               cmpn ++$09                  ;if at 9 or above, branch elsewhere (this comparison
              cmpcy
               bcs IncMsgCounter         ;is residual code, counter never reaches 9)
               ldy WorldNumber           ;check world number
               cpyn ++World8
               bne MRetainerMsg          ;if not at world 8, skip to next part
               cmpn ++$03                  ;check primary message counter again
              cmpcy
               bcc IncMsgCounter         ;if not at 3 yet (world 8 only), branch to increment
              cmpcy
               sbcn ++$01                  ;otherwise subtract one
               jmp ThankPlayer           ;and skip to next part
MRetainerMsg:  cmpn ++$02                  ;check primary message counter
              cmpcy
               bcc IncMsgCounter         ;if not at 2 yet (world 1-7 only), branch
ThankPlayer:   tay                       ;put primary message counter into Y
         checka
               bne SecondPartMsg         ;if counter nonzero, skip this part, do not print first message
               lda CurrentPlayer         ;otherwise get player currently on the screen
         checka
               beq EvalForMusic          ;if mario, branch
               iny                       ;otherwise increment Y once for luigi and
               bne EvalForMusic          ;do an unconditional branch to the same place
SecondPartMsg: iny                       ;increment Y to do world 8's message
               lda WorldNumber
               cmpn ++World8               ;check world number
               beq EvalForMusic          ;if at world 8, branch to next part
               dey                       ;otherwise decrement Y for world 1-7's message
               cpyn ++$04                  ;if counter at 4 (world 1-7 only)
              cmpcy
               bcs SetEndTimer           ;branch to set victory end timer
               cpyn ++$03                  ;if counter at 3 (world 1-7 only)
              cmpcy
               bcs IncMsgCounter         ;branch to keep counting
EvalForMusic:  cpyn ++$03                  ;if counter not yet at 3 (world 8 only), branch
               bne PrintMsg              ;to print message only (note world 1-7 will only
               ldan ++VictoryMusic         ;reach this code if counter = 0, and will always branch)
               sta EventMusicQueue       ;otherwise load victory music first (world 8 only)
PrintMsg:      tya                       ;put primary message counter in A
               clc                       ;add $0c or 12 to counter thus giving an appropriate value,
               adcn ++$0c                  ;($0c-$0d = first), ($0e = world 1-7's), ($0f-$12 = world 8's)
               sta VRAM_Buffer_AddrCtrl  ;write message counter to vram address controller
IncMsgCounter: lda SecondaryMsgCounter
               clc
               adcn ++$04                      ;add four to secondary message counter
               sta SecondaryMsgCounter
               lda PrimaryMsgCounter
               adcn ++$00                      ;add carry to primary message counter
               sta PrimaryMsgCounter
               cmpn ++$07                      ;check primary counter one more time
              cmpcy
SetEndTimer:
               bcc ExitMsgs                  ;if not reached value yet, branch to leave
               ldan ++$06
               sta WorldEndTimer             ;otherwise set world end timer
IncModeTask_A: inci OperMode_Task             ;move onto next task in mode
ExitMsgs:      rts                           ;leave

;-------------------------------------------------------------------------------------

PlayerEndWorld:
               lda WorldEndTimer          ;check to see if world end timer expired
         checka
               bne EndExitOne             ;branch to leave if not
               ldy WorldNumber            ;check world number
               cpyn ++World8                ;if on world 8, player is done with game, 
              cmpcy
               bcs EndChkBButton          ;thus branch to read controller
               ldan ++$00
               sta AreaNumber             ;otherwise initialize area number used as offset
               sta LevelNumber            ;and level number control to start at area 1
               sta OperMode_Task          ;initialize secondary mode of operation
               inci WorldNumber            ;increment world number to move onto the next world
               jsr LoadAreaPointer        ;get area address offset for the next area
               inci FetchNewGameTimerFlag  ;set flag to load game timer from header
               ldan ++GameModeValue
               sta OperMode               ;set mode of operation to game mode
EndExitOne:    rts                        ;and leave
EndChkBButton: lda SavedJoypad1Bits
               orai SavedJoypad2Bits       ;check to see if B button was pressed on
               andn ++B_Button              ;either controller
               beq EndExitTwo             ;branch to leave if not
               ldan ++$01                   ;otherwise set world selection flag
               sta WorldSelectEnableFlag
               ldan ++$ff                   ;remove onscreen player's lives
               sta NumberofLives
               jsr TerminateGame          ;do sub to continue other player or end game
EndExitTwo:    rts                        ;leave

;-------------------------------------------------------------------------------------

;data is used as tiles for numbers
;that appear when you defeat enemies
FloateyNumTileData:
      .db $ff, $ff ;dummy
      .db $f6, $fb ; "100"
      .db $f7, $fb ; "200"
      .db $f8, $fb ; "400"
      .db $f9, $fb ; "500"
      .db $fa, $fb ; "800"
      .db $f6, $50 ; "1000"
      .db $f7, $50 ; "2000"
      .db $f8, $50 ; "4000"
      .db $f9, $50 ; "5000"
      .db $fa, $50 ; "8000"
      .db $fd, $fe ; "1-UP"

;high nybble is digit number, low nybble is number to
;add to the digit of the player's score
ScoreUpdateData:
      .db $ff ;dummy
      .db $41, $42, $44, $45, $48
      .db $31, $32, $34, $35, $38, $00

FloateyNumbersRoutine:
              ldax FloateyNum_Control,x     ;load control for floatey number
         checka
              beq EndExitOne               ;if zero, branch to leave
              cmpn ++$0b                     ;if less than $0b, branch
              cmpcy
              bcc ChkNumTimer
              ldan ++$0b                     ;otherwise set to $0b, thus keeping
              stax FloateyNum_Control,x     ;it in range
ChkNumTimer:  tay                          ;use as Y
              ldax FloateyNum_Timer,x       ;check value here
         checka
              bne DecNumTimer              ;if nonzero, branch ahead
              stax FloateyNum_Control,x     ;initialize floatey number control and leave
              rts
DecNumTimer:  decx FloateyNum_Timer,x       ;decrement value here
              cmpn ++$2b                     ;if not reached a certain point, branch  
              bne ChkTallEnemy
              cpyn ++$0b                     ;check offset for $0b
              bne LoadNumTiles             ;branch ahead if not found
              inci NumberofLives            ;give player one extra life (1-up)
              ldan ++Sfx_ExtraLife
              sta Square2SoundQueue        ;and play the 1-up sound
LoadNumTiles: lday ScoreUpdateData,y        ;load point value here
              lsr                          ;move high nybble to low
              lsr
              lsr
              lsr
              tax                          ;use as X offset, essentially the digit
              lday ScoreUpdateData,y        ;load again and this time
              andn ++%00001111               ;mask out the high nybble
              stax DigitModifier,x          ;store as amount to add to the digit
              jsr AddToScore               ;update the score accordingly
ChkTallEnemy: ldyx Enemy_SprDataOffset,x    ;get OAM data offset for enemy object
              ldax Enemy_ID,x               ;get enemy object identifier
              cmpn ++Spiny
              beq FloateyPart              ;branch if spiny
              cmpn ++PiranhaPlant
              beq FloateyPart              ;branch if piranha plant
              cmpn ++HammerBro
              beq GetAltOffset             ;branch elsewhere if hammer bro
              cmpn ++GreyCheepCheep
              beq FloateyPart              ;branch if cheep-cheep of either color
              cmpn ++RedCheepCheep
              beq FloateyPart
              cmpn ++TallEnemy
              cmpcy
              bcs GetAltOffset             ;branch elsewhere if enemy object =HIGH  $09
              ldax Enemy_State,x
              cmpn ++$02                     ;if enemy state defeated or otherwise
              cmpcy
              bcs FloateyPart              ;$02 or greater, branch beyond this part
GetAltOffset: ldx SprDataOffset_Ctrl       ;load some kind of control bit
              ldyx Alt_SprDataOffset,x      ;get alternate OAM data offset
              ldx ObjectOffset             ;get enemy object offset again
FloateyPart:  ldax FloateyNum_Y_Pos,x       ;get vertical coordinate for
              cmpn ++$18                     ;floatey number, if coordinate in the
              cmpcy
              bcc SetupNumSpr              ;status bar, branch
              cmpcy
              sbcn ++$01
              stax FloateyNum_Y_Pos,x       ;otherwise subtract one and store as new
SetupNumSpr:  ldax FloateyNum_Y_Pos,x       ;get vertical coordinate
             or a
              sbcn ++$08                     ;subtract eight and dump into the
              jsr DumpTwoSpr               ;left and right sprite's Y coordinates
              ldax FloateyNum_X_Pos,x       ;get horizontal coordinate
              stay Sprite_X_Position,y      ;store into X coordinate of left sprite
              clc
              adcn ++$08                     ;add eight pixels and store into X
              stay Sprite_X_Position+4,y    ;coordinate of right sprite
              ldan ++$02
              stay Sprite_Attributes,y      ;set palette control in attribute bytes
              stay Sprite_Attributes+4,y    ;of left and right sprites
              ldax FloateyNum_Control,x
              asl                          ;multiply our floatey number control by 2
              tax                          ;and use as offset for look-up table
              ldax FloateyNumTileData,x
              stay Sprite_Tilenumber,y      ;display first half of number of points
              ldax FloateyNumTileData+1,x
              stay Sprite_Tilenumber+4,y    ;display the second half
              ldx ObjectOffset             ;get enemy object offset and leave
              rts

;-------------------------------------------------------------------------------------

ScreenRoutines:
      lda ScreenRoutineTask        ;run one of the following subroutines
      jsr JumpEngine
    
      .dw InitScreen ;0
      .dw SetupIntermediate ;1
      .dw WriteTopStatusLine ;2
      .dw WriteBottomStatusLine ;3
      .dw DisplayTimeUp ;4
      .dw ResetSpritesAndScreenTimer ;5
      .dw DisplayIntermediate ;6
      .dw ResetSpritesAndScreenTimer ;7
      .dw AreaParserTaskControl ;8
      .dw GetAreaPalette ;9
      .dw GetBackgroundColor ;10
      .dw GetAlternatePalette1 ;11
      .dw DrawTitleScreen ;12
      .dw ClearBuffersDrawIcon ;13
      .dw WriteTopScore ;14

;-------------------------------------------------------------------------------------

InitScreen:
      jsr MoveAllSpritesOffscreen ;initialize all sprites including sprite ++0
      jsr InitializeNameTables    ;and erase both name and attribute tables
      lda OperMode
         checka
      beq NextSubtask             ;if mode still 0, do not load
      ldxn ++$03                    ;into buffer pointer
      jmp SetVRAMAddr_A

;-------------------------------------------------------------------------------------

SetupIntermediate:
      lda BackgroundColorCtrl  ;save current background color control
      pha                      ;and player status to stack
      lda PlayerStatus
      pha
      ldan ++$00                 ;set background color to black
      sta PlayerStatus         ;and player status to not fiery
      ldan ++$02                 ;this is the ONLY time background color control
      sta BackgroundColorCtrl  ;is set to less than 4
      jsr GetPlayerColors
      pla                      ;we only execute this routine for
      sta PlayerStatus         ;the intermediate lives display
      pla                      ;and once we're done, we return bg
      sta BackgroundColorCtrl  ;color ctrl and player status from stack
      jmp IncSubtask           ;then move onto the next task

;-------------------------------------------------------------------------------------

	if Z80==0
AreaPalette:
      .db $01, $02, $03, $04
        endif

GetAreaPalette:
	if Z80
		ld a,(AreaType)
		add a,a
		ld e,a
		ld hl,tpalettes
		add hl,de
		ld a,(hl)
		inc hl
		ld h,(hl)
		ld l,a
		ld (curpalette),hl
		jp IncSubtask           ;move onto next task
	else
               ldy AreaType             ;select appropriate palette to load
               ldxy AreaPalette,y        ;based on area type
	endif
SetVRAMAddr_A: stx VRAM_Buffer_AddrCtrl ;store offset into buffer control
NextSubtask:   jmp IncSubtask           ;move onto next task

;-------------------------------------------------------------------------------------
;$00 - used as temp counter in GetPlayerColors

BGColorCtrl_Addr:
      .db $00, $09, $0a, $04

BackgroundColors:
        if Z80BGCOLOR
	db 0xcc,0xcc,0xff,0xff ;used by area type if bg color ctrl not set
	db 0xff,0xcc,0xff,0xff ;used by background color control if set
	else
      .db $22, $22, $0f, $0f ;used by area type if bg color ctrl not set
      .db $0f, $22, $0f, $0f ;used by background color control if set
        endif

PlayerColors:
        if Z80MARIOCOLOR
      dw 0x3f3f,0xbdbd ;mario's colors
      dw 0x3f3f,0xefef ;luigi's colors
      dw 0x3f3f,0x0c0c ;fiery (used by both)
        else
      .db $22, $16, $27, $18 ;mario's colors
      .db $22, $30, $27, $19 ;luigi's colors
      .db $22, $37, $27, $16 ;fiery (used by both)
        endif

GetBackgroundColor:
           ldy BackgroundColorCtrl   ;check background color control
         checky
           beq NoBGColor             ;if not set, increment task and fetch palette
        if Z80BGCOLOR
	else
           lday BGColorCtrl_Addr-4,y  ;put appropriate palette into vram
           sta VRAM_Buffer_AddrCtrl  ;note that if set to 5-7, $0301 (VRAM_Buffer1) will not be read
	endif
NoBGColor: inci ScreenRoutineTask     ;increment to next subtask and plod on through
      
GetPlayerColors:
        if Z80MARIOCOLOR
               lda CurrentPlayer        ;check which player is on the screen
               ld de,PlayerColors
               or a
               beq ChkFiery
               ld de,PlayerColors+4;ldyn ++$04                 ;load offset for luigi
ChkFiery:      lda PlayerStatus         ;check player status
               cmpn ++$02
               bne StartClrGet          ;if fiery, load alternate offset for fiery player
               ld de,PlayerColors+8;ldyn ++$08
StartClrGet:
               ld hl,(curpalette)
               ld c,12*2
               add hl,bc
               ex de,hl
               ;c>=4
               ldi
               ldi
               inc de
               inc de
               ldi
               ldi
               ld (oldpalette),hl ;!=curpalette, чтобы автоматически обновилась

               ld d,b

          if Z80BGCOLOR
               ldy BackgroundColorCtrl  ;if this value is four or greater, it will be set
         checky
               bne SetBGColor           ;therefore use it as offset to background color
               ldy AreaType             ;otherwise use area type bits from area offset as offset
SetBGColor:    lday BackgroundColors,y   ;to background color instead
	       ;jr $
               ld hl,(curpalette)
	       ld (hl),a
	       inc hl
	       ld (hl),a
	  endif

                ret
        else
               ldx VRAM_Buffer1_Offset  ;get current buffer offset
               ldyn ++$00
               lda CurrentPlayer        ;check which player is on the screen
         checka
               beq ChkFiery
               ldyn ++$04                 ;load offset for luigi
ChkFiery:      lda PlayerStatus         ;check player status
               cmpn ++$02
               bne StartClrGet          ;if fiery, load alternate offset for fiery player
               ldyn ++$08
StartClrGet:   ldan ++$03                 ;do four colors
               sta SCRATCHPAD+$00
ClrGetLoop:    lday PlayerColors,y       ;fetch player colors and store them
               stax VRAM_Buffer1+3,x     ;in the buffer
               iny
               inx
               deci SCRATCHPAD+$00
               bpl ClrGetLoop
               ldx VRAM_Buffer1_Offset  ;load original offset from before
               ldy BackgroundColorCtrl  ;if this value is four or greater, it will be set
         checky
               bne SetBGColor           ;therefore use it as offset to background color
               ldy AreaType             ;otherwise use area type bits from area offset as offset
SetBGColor:    lday BackgroundColors,y   ;to background color instead
               stax VRAM_Buffer1+3,x
               ldan ++HIGH PPU_SPRPAL;++$3f                 ;set for sprite palette address
               stax VRAM_Buffer1,x       ;save to buffer
               ldan ++LOW PPU_SPRPAL;++$10
               stax VRAM_Buffer1+1,x
               ldan ++$04                 ;write length byte to buffer
               stax VRAM_Buffer1+2,x
               ldan ++$00                 ;now the null terminator
               stax VRAM_Buffer1+7,x
               txa                      ;move the buffer pointer ahead 7 bytes
               clc                      ;in case we want to write anything else later
               adcn ++$07
        endif
SetVRAMOffset: sta VRAM_Buffer1_Offset  ;store as new vram buffer offset
               rts

;-------------------------------------------------------------------------------------

GetAlternatePalette1:
               lda AreaStyle            ;check for mushroom level style
               cmpn ++$01
               bne NoAltPal
               ldan ++$0b                 ;if found, load appropriate palette
SetVRAMAddr_B: sta VRAM_Buffer_AddrCtrl
NoAltPal:      jmp IncSubtask           ;now onto the next task

;-------------------------------------------------------------------------------------

WriteTopStatusLine:
      ldan ++$00          ;select main status bar
      jsr WriteGameText ;output it
      jmp IncSubtask    ;onto the next task

;-------------------------------------------------------------------------------------

WriteBottomStatusLine:
      jsr GetSBNybbles        ;write player's score and coin tally to screen
      ldx VRAM_Buffer1_Offset
      ldan ++$20                ;write address for world-area number on screen
      stax VRAM_Buffer1,x
      ldan ++$73
      stax VRAM_Buffer1+1,x
      ldan ++$03                ;write length for it
      stax VRAM_Buffer1+2,x
      ldy WorldNumber         ;first the world number
      iny
      tya
      stax VRAM_Buffer1+3,x
      ldan ++$28                ;next the dash
      stax VRAM_Buffer1+4,x
      ldy LevelNumber         ;next the level number
      iny                     ;increment for proper number display
      tya
      stax VRAM_Buffer1+5,x    
      ldan ++$00                ;put null terminator on
      stax VRAM_Buffer1+6,x
      txa                     ;move the buffer offset up by 6 bytes
      clc
      adcn ++$06
      sta VRAM_Buffer1_Offset
      jmp IncSubtask

;-------------------------------------------------------------------------------------

DisplayTimeUp:
          lda GameTimerExpiredFlag  ;if game timer not expired, increment task
         checka
          beq NoTimeUp              ;control 2 tasks forward, otherwise, stay here
          ldan ++$00
          sta GameTimerExpiredFlag  ;reset timer expiration flag
          ldan ++$02                  ;output time-up screen to buffer
          jmp OutputInter
NoTimeUp: inci ScreenRoutineTask     ;increment control task 2 tasks forward
          jmp IncSubtask

;-------------------------------------------------------------------------------------

DisplayIntermediate:
               lda OperMode                 ;check primary mode of operation
         checka
               beq NoInter                  ;if in title screen mode, skip this
               cmpn ++GameOverModeValue       ;are we in game over mode?
               beq GameOverInter            ;if so, proceed to display game over screen
               lda AltEntranceControl       ;otherwise check for mode of alternate entry
         checka
               bne NoInter                  ;and branch if found
               ldy AreaType                 ;check if we are on castle level
               cpyn ++$03                     ;and if so, branch (possibly residual)
               beq PlayerInter
               lda DisableIntermediate      ;if this flag is set, skip intermediate lives display
         checka
               bne NoInter                  ;and jump to specific task, otherwise
PlayerInter:   jsr DrawPlayer_Intermediate  ;put player in appropriate place for
               ldan ++$01                     ;lives display, then output lives display to buffer
OutputInter:   jsr WriteGameText
               jsr ResetScreenTimer
               ldan ++$00
               sta DisableScreenFlag        ;reenable screen output
               rts
GameOverInter: ldan ++$12                     ;set screen timer
               sta ScreenTimer
               ldan ++$03                     ;output game over screen to buffer
               jsr WriteGameText
               jmp IncModeTask_B
NoInter:       ldan ++$08                     ;set for specific task (AreaParserTaskControl) and leave
               sta ScreenRoutineTask
               rts

;-------------------------------------------------------------------------------------

AreaParserTaskControl:
           inci DisableScreenFlag     ;turn off screen
TaskLoop:  jsr AreaParserTaskHandler ;render column set of current area
           lda AreaParserTaskNum     ;check number of tasks
         checka
           bne TaskLoop              ;if tasks still not all done, do another one
           deci ColumnSets            ;do we need to render more column sets?
           bpl OutputCol
           inci ScreenRoutineTask     ;if not, move on to the next task
OutputCol: ldan ++$06                  ;set vram buffer to output rendered column set
           sta VRAM_Buffer_AddrCtrl  ;on next NMI
           rts

;-------------------------------------------------------------------------------------

;$00 - vram buffer address table low
;$01 - vram buffer address table high

DrawTitleScreen:
        ;jr $
            lda OperMode                 ;are we in title screen mode?
         checka
            bne IncModeTask_B            ;if not, exit
        if Z80
DrawTitleScreen_go
            ld hl,TitleScreen
            ld de,VRAM_Buffer1_Offset
            ld bc,TitleScreenDataSize ;0x13a = 314 (странное число???)
            ldir
            ld d,b;0
        else
            ldan ++HIGH TitleScreenDataOffset  ;load address $1ec0 into
            sta PPU_ADDRESS              ;the vram address register
            ldan ++LOW TitleScreenDataOffset
            sta PPU_ADDRESS
            ldan ++$03                     ;put address $0300 into
            sta SCRATCHPAD+$01                      ;the indirect at $00
            ldyn ++$00
            sty SCRATCHPAD+$00
            lda PPU_DATA                 ;do one garbage read
OutputTScr: lda PPU_DATA                 ;get title screen from chr-rom
            stayindirect (SCRATCHPAD+$00),y                  ;store 256 bytes into buffer
            iny
            bne ChkHiByte                ;if not past 256 bytes, do not increment
            inci SCRATCHPAD+$01                      ;otherwise increment high byte of indirect
ChkHiByte:  lda SCRATCHPAD+$01                      ;check high byte?
            cmpn ++$04                     ;at $0400?
            bne OutputTScr               ;if not, loop back and do another
            cpyn ++$3a                     ;check if offset points past end of data
              cmpcy
            bcc OutputTScr               ;if not, loop back and do another
        endif
            ldan ++$05                     ;set buffer transfer control to $0300,
            jmp SetVRAMAddr_B            ;increment task and exit

;-------------------------------------------------------------------------------------

ClearBuffersDrawIcon:
             lda OperMode               ;check game mode
         checka
             bne IncModeTask_B          ;if not title screen mode, leave
             ldxn ++$00                   ;otherwise, clear buffer space
TScrClear:   stax VRAM_Buffer1-1,x
             stax VRAM_Buffer1-1+$100,x ;??? почему так много?
             dex
             bne TScrClear
             jsr DrawMushroomIcon       ;draw player select icon
IncSubtask:  inci ScreenRoutineTask      ;move onto next task
             rts

;-------------------------------------------------------------------------------------

WriteTopScore:
               ldan ++$fa           ;run display routine to display top score on title
               jsr UpdateNumber
IncModeTask_B: inci OperMode_Task  ;move onto next mode
               rts

;-------------------------------------------------------------------------------------

GameText:
TopStatusBarLine:
  .db $20, $43, $05,  $16, $0a, $1b, $12, $18 ; "MARIO"
  .db $20, $52, $0b,  $20, $18, $1b, $15, $0d ; "WORLD  TIME"
  .db $24, $24, $1d,  $12, $16, $0e
  .db $20, $68, $05,  $00, $24, $24, $2e, $29 ; score trailing digit and coin display
  .db $23, $c0,  $7f, $aa ; attribute table data, clears name table 0 to palette 2
  .db $23, $c2, $01,  $ea ; attribute table data, used for coin icon in status bar
  .db $ff ; end of data block

WorldLivesDisplay:
  .db $21, $cd, $07,  $24, $24 ; cross with spaces used on
  .db $29, $24, $24,  $24, $24 ; lives display
  .db $21, $4b, $09,  $20, $18 ; "WORLD  - " used on lives display
  .db $1b, $15, $0d, $24, $24, $28, $24
  .db $22, $0c,  $47, $24 ; possibly used to clear time up
  .db $23, $dc, $01,  $ba ; attribute table data for crown if more than 9 lives
  .db $ff

TwoPlayerTimeUp:
  .db $21, $cd, $05,  $16, $0a, $1b, $12, $18 ; "MARIO"
OnePlayerTimeUp:
  .db $22, $0c, $07,  $1d, $12, $16, $0e, $24, $1e, $19 ; "TIME UP"
  .db $ff

TwoPlayerGameOver:
  .db $21, $cd, $05,  $16, $0a, $1b, $12, $18 ; "MARIO"
OnePlayerGameOver:
  .db $22, $0b, $09,  $10, $0a, $16, $0e, $24 ; "GAME OVER"
  .db $18, $1f, $0e, $1b
  .db $ff

WarpZoneWelcome:
  .db $25, $84, $15,  $20, $0e, $15, $0c, $18, $16 ; "WELCOME TO WARP ZONE!"
  .db $0e, $24, $1d, $18, $24, $20, $0a, $1b, $19
  .db $24, $23, $18, $17, $0e, $2b
  .db $26, $25, $01,  $24         ; placeholder for left pipe
  .db $26, $2d, $01,  $24         ; placeholder for middle pipe
  .db $26, $35, $01,  $24         ; placeholder for right pipe
  .db $27, $d9,  $46, $aa         ; attribute data
  .db $27, $e1,  $45, $aa
  .db $ff

LuigiName:
  .db $15, $1e, $12, $10, $12    ; "LUIGI", no address or length

WarpZoneNumbers:
  .db $04, $03, $02, $00         ; warp zone numbers, note spaces on middle
  .db $24, $05, $24, $00         ; zone, partly responsible for
  .db $08, $07, $06, $00         ; the minus world

GameTextOffsets:
  .db TopStatusBarLine-GameText, TopStatusBarLine-GameText
  .db WorldLivesDisplay-GameText, WorldLivesDisplay-GameText
  .db TwoPlayerTimeUp-GameText, OnePlayerTimeUp-GameText
  .db TwoPlayerGameOver-GameText, OnePlayerGameOver-GameText
  .db WarpZoneWelcome-GameText, WarpZoneWelcome-GameText

WriteGameText:
               pha                      ;save text number to stack
               asl
               tay                      ;multiply by 2 and use as offset
               cpyn ++$04                 ;if set to do top status bar or world/lives display,
              cmpcy
               bcc LdGameText           ;branch to use current offset as-is
               cpyn ++$08                 ;if set to do time-up or game over,
              cmpcy
               bcc Chk2Players          ;branch to check players
               ldyn ++$08                 ;otherwise warp zone, therefore set offset
Chk2Players:   lda NumberOfPlayers      ;check for number of players
         checka
               bne LdGameText           ;if there are two, use current offset to also print name
               iny                      ;otherwise increment offset by one to not print name
LdGameText:    ldxy GameTextOffsets,y    ;get offset to message we want to print
               ldyn ++$00
GameTextLoop:  ldax GameText,x           ;load message data
               cmpn ++$ff                 ;check for terminator
               beq EndGameText          ;branch to end text if found
               stay VRAM_Buffer1,y       ;otherwise write data to buffer
               inx                      ;and increment increment
               iny
               bne GameTextLoop         ;do this for 256 bytes if no terminator found
EndGameText:   ldan ++$00                 ;put null terminator at end
               stay VRAM_Buffer1,y
               pla                      ;pull original text number from stack
               tax
               cmpn ++$04                 ;are we printing warp zone?
              cmpcy
               bcs PrintWarpZoneNumbers
               dex                      ;are we printing the world/lives display?
               bne CheckPlayerName      ;if not, branch to check player's name
               lda NumberofLives        ;otherwise, check number of lives
               clc                      ;and increment by one for display
               adcn ++$01
               cmpn ++10                  ;more than 9 lives?
              cmpcy
               bcc PutLives
              cmpcy
               sbcn ++10                  ;if so, subtract 10 and put a crown tile
               ldyn ++$9f                 ;next to the difference...strange things happen if
               sty VRAM_Buffer1+7       ;the number of lives exceeds 19
PutLives:      sta VRAM_Buffer1+8
               ldy WorldNumber          ;write world and level numbers (incremented for display)
               iny                      ;to the buffer in the spaces surrounding the dash
               sty VRAM_Buffer1+19
               ldy LevelNumber
               iny
               sty VRAM_Buffer1+21      ;we're done here
               rts

CheckPlayerName:
             lda NumberOfPlayers    ;check number of players
         checka
             beq ExitChkName        ;if only 1 player, leave
             lda CurrentPlayer      ;load current player
             dex                    ;check to see if current message number is for time up
             bne ChkLuigi
             ldy OperMode           ;check for game over mode
             cpyn ++GameOverModeValue
             beq ChkLuigi
             eorn ++%00000001         ;if not, must be time up, invert d0 to do other player
ChkLuigi:    lsr
             bcc ExitChkName        ;if mario is current player, do not change the name
             ldyn ++$04
NameLoop:    lday LuigiName,y        ;otherwise, replace "MARIO" with "LUIGI"
             stay VRAM_Buffer1+3,y
             dey
             bpl NameLoop           ;do this until each letter is replaced
ExitChkName: rts

PrintWarpZoneNumbers:
;CY = 0???
            or a
             sbcn ++$04               ;subtract 4 and then shift to the left
             asl                    ;twice to get proper warp zone number
             asl                    ;offset
             tax
             ldyn ++$00
WarpNumLoop: ldax WarpZoneNumbers,x  ;print warp zone numbers into the
             stay VRAM_Buffer1+27,y  ;placeholders from earlier
             inx
             iny                    ;put a number in every fourth space
             iny
             iny
             iny
             cpyn ++$0c
              cmpcy
             bcc WarpNumLoop
             ldan ++$2c               ;load new buffer pointer at end of message
             jmp SetVRAMOffset

;-------------------------------------------------------------------------------------

ResetSpritesAndScreenTimer:
         lda ScreenTimer             ;check if screen timer has expired
         checka
         bne NoReset                 ;if not, branch to leave
         jsr MoveAllSpritesOffscreen ;otherwise reset sprites now

ResetScreenTimer:
         ldan ++$07                    ;reset timer again
         sta ScreenTimer
         inci ScreenRoutineTask       ;move onto next task
NoReset: rts

;-------------------------------------------------------------------------------------
;$00 - temp vram buffer offset
;$01 - temp metatile buffer offset
;$02 - temp metatile graphics table offset
;$03 - used to store attribute bits
;$04 - used to determine attribute table row
;$05 - used to determine attribute table column
;$06 - metatile graphics table address low
;$07 - metatile graphics table address high

RenderAreaGraphics:
           if Z80OPT4
            ;lda CurrentColumnPos         ;store LSB of where we're at
            ;andn ++$01
            ;sta SCRATCHPAD+$05
            ldy VRAM_Buffer2_Offset      ;store vram buffer offset
            ld ix,VRAM_Buffer2
            add ix,de
            ld a,(CurrentNTAddr_Low)        ;get current name table address we're supposed to render
            ld (ix+1),a;stay VRAM_Buffer2+1,y
            ld a,(CurrentNTAddr_High)
            ld (ix+0),a;stay VRAM_Buffer2,y
            ld a,++$9a                     ;store length byte of 26 here with d7 set
            ld (ix+2),a;stay VRAM_Buffer2+2,y         ;to increment by 32 (in columns)            
            ld bc,MetatileBuffer;ld c,0                    ;row
            ld hy,13
;row=0..12
DrawMTLoop:
;для Z80 не нужно формировать атрибуты - все тайлы уже перекрашены
        ;ld hl,MetatileBuffer
        ;add hl,bc
        ld a,(bc);(hl);ldax MetatileBuffer,x         ;get first metatile number ;%xx000000 - attribute table bits, %00xxxxxx - metatile number
            ld e,d;0
            add a,a ;*2
            rl e
            add a,a ;*4
            rl e ;e=0..3
            ld hl,AreaParserTaskNum        ;get current task number for level processing and
            bit 0,(hl) ;get current task number for level processing and mask out all but LSB
            jr nz,$+4
             add a,2 ;multiply by 2, then add to the tile offset so we can draw either side of the metatiles
            ld hl,MetatileGraphics_Low
            add hl,de ;e=0..3
            add a,(hl);l,(iy)
            inc hl
            inc hl
            inc hl
            inc hl
           ;ld e,a
           ;adc a,(hl)
           ;sub e
           ;ld h,a
           ;ld l,e ;23t
              ld h,(hl);(iy+MetatileGraphics_High-MetatileGraphics_Low) ;get address to graphics table from here
              jr nc,$+3
              inc h
              ld l,a ;20.5t
             ld a,(hl);ldayindirect (SCRATCHPAD+$06),y ;get first tile number (top left or top right) and store
             ld (ix+3),a
             inc hl
             ld a,(hl) ;now get the second (bottom left or bottom right) and store
             ld (ix+4),a;stax VRAM_Buffer2+4,x
             inc ix;inci SCRATCHPAD+$00                      ;increment vram buffer offset by 2
             inc ix;inci SCRATCHPAD+$00
            inc bc ;next row                         
            ;ld a,c
            dec hy ;cp $0d ;check for the bottom of the screen
            jp nz,DrawMTLoop ;jp c,DrawMTLoop               ;if not there yet, loop back
            ld b,d;0

;итого сдвинули vram buffer offset на 13*2, сдвинем ещё на 3 и сохраним:
            ld (ix+3),b;0       ;put null terminator at end of data for name table
            ld a,(VRAM_Buffer2_Offset)
            add a,13*2+3
            ld (VRAM_Buffer2_Offset),a ;store new buffer offset
            ld hl,CurrentNTAddr_Low
            inc (hl);inci CurrentNTAddr_Low        ;increment name table address low
            ld a,(hl);lda CurrentNTAddr_Low        ;check current low byte
            and ++%00011111               ;if no wraparound, just skip this part
            jr nz,ExitDrawM
            ;ld a,++$80                     ;if wraparound occurs, make sure low byte stays
            ld (hl),$80;sta CurrentNTAddr_Low        ;just under the status bar
            ld hl,CurrentNTAddr_High
            ld a,(hl);lda CurrentNTAddr_High       ;and then invert d2 of the name table address high
            xor ++%00000100               ;to move onto the next appropriate name table
            ld (hl),a;sta CurrentNTAddr_High
ExitDrawM:  ;jmp SetVRAMCtrl              ;jump to set buffer to $0341 (VRAM_Buffer2) and leave
             ldan ++$06
             sta VRAM_Buffer_AddrCtrl ;set buffer to $0341 (VRAM_Buffer2) and leave
             ret

           else ;~Z80

            lda CurrentColumnPos         ;store LSB of where we're at
            andn ++$01
            sta SCRATCHPAD+$05           
            ldy VRAM_Buffer2_Offset      ;store vram buffer offset
             sty SCRATCHPAD+$00
            lda CurrentNTAddr_Low        ;get current name table address we're supposed to render
            stay VRAM_Buffer2+1,y
            lda CurrentNTAddr_High
            stay VRAM_Buffer2,y
            ldan ++$9a                     ;store length byte of 26 here with d7 set
            stay VRAM_Buffer2+2,y         ;to increment by 32 (in columns)
            ldan ++$00                     ;init attribute row
            sta SCRATCHPAD+$04 ;current attribute row
            tax ;x=row
;x=row=0..12
DrawMTLoop:
            stx SCRATCHPAD+$01                      ;store init value of 0 or incremented offset for buffer
            ldax MetatileBuffer,x         ;get first metatile number, and mask out all but 2 MSB
            andn ++%11000000
            sta SCRATCHPAD+$03                      ;store attribute table bits here
            asl                          ;note that metatile format is:
            rol                          ;%xx000000 - attribute table bits, 
            rol                          ;%00xxxxxx - metatile number
            tay                          ;rotate bits to d1-d0 and use as offset here            
            lday MetatileGraphics_Low,y   ;get address to graphics table from here
            sta SCRATCHPAD+$06
            lday MetatileGraphics_High,y
            sta SCRATCHPAD+$07
            ldax MetatileBuffer,x         ;get metatile number again
            asl                          ;multiply by 4 and use as tile offset
            asl
            sta SCRATCHPAD+$02
            lda AreaParserTaskNum        ;get current task number for level processing and
            andn ++%00000001               ;mask out all but LSB, then invert LSB, multiply by 2
            eorn ++%00000001               ;to get the correct column position in the metatile,
            asl                          ;then add to the tile offset so we can draw either side
            adci SCRATCHPAD+$02                      ;of the metatiles
            tay
            ldx SCRATCHPAD+$00                      ;use vram buffer offset from before as X
            ldayindirect (SCRATCHPAD+$06),y
            stax VRAM_Buffer2+3,x         ;get first tile number (top left or top right) and store
            iny
            ldayindirect (SCRATCHPAD+$06),y                  ;now get the second (bottom left or bottom right) and store
            stax VRAM_Buffer2+4,x

            ldy SCRATCHPAD+$04                      ;get current attribute row
            lda SCRATCHPAD+$05                      ;get LSB of current column where we're at, and
         checka
            bne RightCheck               ;branch if set (clear = left attrib, set = right)
            lda SCRATCHPAD+$01                      ;get current row we're rendering
            lsr                          ;branch if LSB set (clear = top left, set = bottom left)
            bcs LLeft
            roli SCRATCHPAD+$03                      ;rotate attribute bits 3 to the left
            roli SCRATCHPAD+$03                      ;thus in d1-d0, for upper left square
            roli SCRATCHPAD+$03
            jmp SetAttrib
RightCheck: lda SCRATCHPAD+$01                      ;get LSB of current row we're rendering
            lsr                          ;branch if set (clear = top right, set = bottom right)
            bcs NextMTRow
            lsri SCRATCHPAD+$03                      ;shift attribute bits 4 to the right
            lsri SCRATCHPAD+$03                      ;thus in d3-d2, for upper right square
            lsri SCRATCHPAD+$03
            lsri SCRATCHPAD+$03
            jmp SetAttrib
LLeft:      lsri SCRATCHPAD+$03                      ;shift attribute bits 2 to the right
            lsri SCRATCHPAD+$03                      ;thus in d5-d4 for lower left square
NextMTRow:  inci SCRATCHPAD+$04                      ;move onto next attribute row  
SetAttrib:  lday AttributeBuffer,y        ;get previously saved bits from before
            orai SCRATCHPAD+$03                      ;if any, and put new bits, if any, onto
            stay AttributeBuffer,y        ;the old, and store
             inci SCRATCHPAD+$00                      ;increment vram buffer offset by 2
             inci SCRATCHPAD+$00
            ldx SCRATCHPAD+$01                      ;get current gfx buffer row, and check for
            inx                          ;the bottom of the screen
            cpxn ++$0d
              cmpcy
            bcc DrawMTLoop               ;if not there yet, loop back
            
;итого сдвинули vram buffer offset на 13*2, сдвинем ещё на 3 и сохраним:           
            ldy SCRATCHPAD+$00                      ;get current vram buffer offset, increment by 3
            iny                          ;(for name table address and length bytes)
            iny
            iny
            ldan ++$00
            stay VRAM_Buffer2,y           ;put null terminator at end of data for name table
            sty VRAM_Buffer2_Offset      ;store new buffer offset
            
            inci CurrentNTAddr_Low        ;increment name table address low
            lda CurrentNTAddr_Low        ;check current low byte
            andn ++%00011111               ;if no wraparound, just skip this part
            bne ExitDrawM
            ldan ++$80                     ;if wraparound occurs, make sure low byte stays
            sta CurrentNTAddr_Low        ;just under the status bar
            lda CurrentNTAddr_High       ;and then invert d2 of the name table address high
            eorn ++%00000100               ;to move onto the next appropriate name table
            sta CurrentNTAddr_High
ExitDrawM:  jmp SetVRAMCtrl              ;jump to set buffer to $0341 (VRAM_Buffer2) and leave
           endif

;-------------------------------------------------------------------------------------
             if Z80OPT4==0 ;для Z80 не нужно формировать атрибуты - все тайлы уже перекрашены
;$00 - temp attribute table address high (big endian order this time!)
;$01 - temp attribute table address low
RenderAttributeTables:
             lda CurrentNTAddr_Low    ;get low byte of next name table address
             andn ++%00011111           ;to be written to, mask out all but 5 LSB,
             secsub                      ;subtract four 
             sbcn ++$04
              cmpcy
        if Z80
        push af
        endif
             andn ++%00011111           ;mask out bits again and store
             sta SCRATCHPAD+$01
        if Z80
        pop af
        endif
             lda CurrentNTAddr_High   ;get high byte and branch if borrow not set
             bcs SetATHigh
             eorn ++%00000100           ;otherwise invert d2
SetATHigh:   andn ++%00000100           ;mask out all other bits
             oran ++$23                 ;add $2300 to the high byte and store
             sta SCRATCHPAD+$00
             lda SCRATCHPAD+$01                  ;get low byte - 4, divide by 4, add offset for
             lsr                      ;attribute table and store
             lsr
             adcn ++$c0                 ;we should now have the appropriate block of
             sta SCRATCHPAD+$01                  ;attribute table in our temp address
             ldxn ++$00
             ldy VRAM_Buffer2_Offset  ;get buffer offset
AttribLoop:  lda SCRATCHPAD+$00
             stay VRAM_Buffer2,y       ;store high byte of attribute table address
             lda SCRATCHPAD+$01
             clc                      ;get low byte, add 8 because we want to start
             adcn ++$08                 ;below the status bar, and store
             stay VRAM_Buffer2+1,y
             sta SCRATCHPAD+$01                  ;also store in temp again
             ldax AttributeBuffer,x    ;fetch current attribute table byte and store
             stay VRAM_Buffer2+3,y     ;in the buffer
             ldan ++$01
             stay VRAM_Buffer2+2,y     ;store length of 1 in buffer
             lsr
             stax AttributeBuffer,x    ;clear current byte in attribute buffer
             iny                      ;increment buffer offset by 4 bytes
             iny
             iny
             iny
             inx                      ;increment attribute offset and check to see
             cpxn ++$07                 ;if we're at the end yet
              cmpcy
             bcc AttribLoop
             stay VRAM_Buffer2,y       ;put null terminator at the end
             sty VRAM_Buffer2_Offset  ;store offset in case we want to do any more
SetVRAMCtrl: ldan ++$06
             sta VRAM_Buffer_AddrCtrl ;set buffer to $0341 (VRAM_Buffer2) and leave
             rts
            endif

;-------------------------------------------------------------------------------------

;$00 - used as temporary counter in ColorRotation

ColorRotatePalette:
	if Z80COINCYCLECOLOR
	db 0xa1,0xa1,0xa1,0x31,0xf1,0x31
	else
       .db $27, $27, $27, $17, $07, $17
        endif

BlankPalette:
       .db $3f, $0c, $04, $ff, $ff, $ff, $ff, $00

;used based on area type
Palette3Data:
       .db $0f, $07, $12, $0f 
       .db $0f, $07, $17, $0f
       .db $0f, $07, $17, $1c
       .db $0f, $07, $17, $00

ColorRotation:
              lda FrameCounter         ;get frame counter
              andn ++$07                 ;mask out all but three LSB
	if Z80COINCYCLECOLOR
		ret nz
              ;lda AreaType             ;get area type
              ;asl                      ;multiply by 4 to get proper offset
              ;asl
              ;tay                      ;save as offset here
	      ;lday Palette3Data,y       ;fetch palette to be written based on area type
		
              ldy ColorRotateOffset    ;get color cycling offset
              lday ColorRotatePalette,y
		ld hl,(curpalette)
		ld e,11*2
		add hl,de
		ld (hl),a
		inc hl
		ld (hl),a
	      
              inci ColorRotateOffset    ;increment color cycling offset
              lda ColorRotateOffset
              cmpn ++$06                 ;check to see if it's still in range
              ;cmpcy
              ret c;bcc ExitColorRot         ;if so, branch to leave
              xor a;ldan ++$00
              sta ColorRotateOffset    ;otherwise, init to keep it in range
		ret
	else
              bne ExitColorRot         ;branch if not set to zero to do this every eighth frame
              ldx VRAM_Buffer1_Offset  ;check vram buffer offset
              cpxn ++$31
              cmpcy
              bcs ExitColorRot         ;if offset over 48 bytes, branch to leave
              tay                      ;otherwise use frame counter's 3 LSB as offset here
GetBlankPal:  lday BlankPalette,y       ;get blank palette for palette 3
              stax VRAM_Buffer1,x       ;store it in the vram buffer
              inx                      ;increment offsets
              iny
              cpyn ++$08
              cmpcy
              bcc GetBlankPal          ;do this until all bytes are copied
              ldx VRAM_Buffer1_Offset  ;get current vram buffer offset
              ldan ++$03
              sta SCRATCHPAD+$00                  ;set counter here
              lda AreaType             ;get area type
              asl                      ;multiply by 4 to get proper offset
              asl
              tay                      ;save as offset here
GetAreaPal:   lday Palette3Data,y       ;fetch palette to be written based on area type
              stax VRAM_Buffer1+3,x     ;store it to overwrite blank palette in vram buffer
              iny
              inx
              deci SCRATCHPAD+$00                  ;decrement counter
              bpl GetAreaPal           ;do this until the palette is all copied
              ldx VRAM_Buffer1_Offset  ;get current vram buffer offset
              ldy ColorRotateOffset    ;get color cycling offset
              lday ColorRotatePalette,y
              stax VRAM_Buffer1+4,x     ;get and store current color in second slot of palette
              lda VRAM_Buffer1_Offset
              clc                      ;add seven bytes to vram buffer offset
              adcn ++$07
              sta VRAM_Buffer1_Offset
              inci ColorRotateOffset    ;increment color cycling offset
              lda ColorRotateOffset
              cmpn ++$06                 ;check to see if it's still in range
              cmpcy
              bcc ExitColorRot         ;if so, branch to leave
              ldan ++$00
              sta ColorRotateOffset    ;otherwise, init to keep it in range
ExitColorRot: rts                      ;leave
	endif

;-------------------------------------------------------------------------------------
;$00 - temp store for offset control bit
;$01 - temp vram buffer offset
;$02 - temp store for vertical high nybble in block buffer routine
;$03 - temp adder for high byte of name table address
;$04, $05 - name table address low/high
;$06, $07 - block buffer address low/high

BlockGfxData:
       .db $45, $45, $47, $47
       .db $47, $47, $47, $47
       .db $57, $58, $59, $5a
       .db $24, $24, $24, $24 ;blank metatile
       .db y26, y26, y26, y26 ;water/lava ;blank metatile for water

RemoveCoin_Axe:
              ldyn ++$41                 ;set low byte so offset points to $0341
              ldan ++$03                 ;load offset for default blank metatile
              ldx AreaType             ;check area type
         checkx
              bne WriteBlankMT         ;if not water type, use offset
              ldan ++$04                 ;otherwise load offset for blank metatile used in water
WriteBlankMT: jsr PutBlockMetatile     ;do a sub to write blank metatile to vram buffer
              ldan ++$06
              sta VRAM_Buffer_AddrCtrl ;set vram address controller to $0341 (VRAM_Buffer2) and leave
              rts

ReplaceBlockMetatile:
       jsr WriteBlockMetatile    ;write metatile to vram buffer to replace block object
       inci Block_ResidualCounter ;increment unused counter (residual code)
       decx Block_RepFlag,x       ;decrement flag (residual code)
       rts                       ;leave

DestroyBlockMetatile:
       ldan ++$00       ;force blank metatile if branched/jumped to this point

WriteBlockMetatile:
             ldyn ++$03                ;load offset for blank metatile
             cmpn ++$00                ;check contents of A for blank metatile
             beq UseBOffset          ;branch if found (unconditional if branched from 8a6b)
             ldyn ++$00                ;load offset for brick metatile w/ line
             cmpn ++$58
             beq UseBOffset          ;use offset if metatile is brick with coins (w/ line)
             cmpn ++$51
             beq UseBOffset          ;use offset if metatile is breakable brick w/ line
             iny                     ;increment offset for brick metatile w/o line
             cmpn ++$5d
             beq UseBOffset          ;use offset if metatile is brick with coins (w/o line)
             cmpn ++$52
             beq UseBOffset          ;use offset if metatile is breakable brick w/o line
             iny                     ;if any other metatile, increment offset for empty block
UseBOffset:  tya                     ;put Y in A
             ldy VRAM_Buffer1_Offset ;get vram buffer offset
             iny                     ;move onto next byte
             jsr PutBlockMetatile    ;get appropriate block data and write to vram buffer
MoveVOffset: dey                     ;decrement vram buffer offset
             tya                     ;add 10 bytes to it
             clc
             adcn ++10
             jmp SetVRAMOffset       ;branch to store as new vram buffer offset

PutBlockMetatile:
            stx SCRATCHPAD+$00               ;store control bit from SprDataOffset_Ctrl
            sty SCRATCHPAD+$01               ;store vram buffer offset for next byte
            asl
            asl                   ;multiply A by four and use as X
            tax
            ldyn ++$20              ;load high byte for name table 0
            lda SCRATCHPAD+$06               ;get low byte of block buffer pointer
            cmpn ++$d0              ;check to see if we're on odd-page block buffer
              cmpcy
            bcc SaveHAdder        ;if not, use current high byte
            ldyn ++$24              ;otherwise load high byte for name table 1
SaveHAdder: sty SCRATCHPAD+$03               ;save high byte here
            andn ++$0f              ;mask out high nybble of block buffer pointer
            asl                   ;multiply by 2 to get appropriate name table low byte
            sta SCRATCHPAD+$04               ;and then store it here
            ldan ++$00
            sta SCRATCHPAD+$05               ;initialize temp high byte
            lda SCRATCHPAD+$02               ;get vertical high nybble offset used in block buffer routine
            clc
            adcn ++$20              ;add 32 pixels for the status bar
            asl
            roli SCRATCHPAD+$05               ;shift and rotate d7 onto d0 and d6 into carry
            asl
            roli SCRATCHPAD+$05               ;shift and rotate d6 onto d0 and d5 into carry
            adci SCRATCHPAD+$04               ;add low byte of name table and carry to vertical high nybble
            sta SCRATCHPAD+$04               ;and store here
            lda SCRATCHPAD+$05               ;get whatever was in d7 and d6 of vertical high nybble
            adcn ++$00              ;add carry
            clc
            adci SCRATCHPAD+$03               ;then add high byte of name table
            sta SCRATCHPAD+$05               ;store here
            ldy SCRATCHPAD+$01               ;get vram buffer offset to be used
RemBridge:  ldax BlockGfxData,x    ;write top left and top right
            stay VRAM_Buffer1+2,y  ;tile numbers into first spot
            ldax BlockGfxData+1,x
            stay VRAM_Buffer1+3,y
            ldax BlockGfxData+2,x  ;write bottom left and bottom
            stay VRAM_Buffer1+7,y  ;right tiles numbers into
            ldax BlockGfxData+3,x  ;second spot
            stay VRAM_Buffer1+8,y
            lda SCRATCHPAD+$04
            stay VRAM_Buffer1,y    ;write low byte of name table
            clc                   ;into first slot as read
            adcn ++$20              ;add 32 bytes to value
            stay VRAM_Buffer1+5,y  ;write low byte of name table
            lda SCRATCHPAD+$05               ;plus 32 bytes into second slot
            stay VRAM_Buffer1-1,y  ;write high byte of name
            stay VRAM_Buffer1+4,y  ;table address to both slots
            ldan ++$02
            stay VRAM_Buffer1+1,y  ;put length of 2 in
            stay VRAM_Buffer1+6,y  ;both slots
            ldan ++$00
            stay VRAM_Buffer1+9,y  ;put null terminator at end
            ldx SCRATCHPAD+$00               ;get offset control bit here
            rts                   ;and leave

;-------------------------------------------------------------------------------------
;METATILE GRAPHICS TABLE

MetatileGraphics_Low:
  .db LOW Palette0_MTiles, LOW Palette1_MTiles, LOW Palette2_MTiles, LOW Palette3_MTiles

MetatileGraphics_High:
  .db HIGH Palette0_MTiles, HIGH Palette1_MTiles, HIGH Palette2_MTiles, HIGH Palette3_MTiles

  if Z80ATTR
xa0=0xec
xa1=0xed
xa2=0xee
xa3=0xef
x27=0xf0
xba=0xf1
xbb=0xf2
x86=0xf3
x87=0xf4
x8a=0xf5
x8b=0xf6
x8e=0xf7
x8f=0xf8
y25=0xf9
y26=0xfa
y35=0xfb
y36=0xfc
y37=0xfd
y38=0xfe
w26=10+('X'-'A')
;(water pipe bottom):
x91=10+('J'-'A');0x91
x92=10+('F'-'A');0x92
;или для горизонтальных труб сцепить два тайла по вертикали и юзать как один?
  else
xa0=0xa0
xa1=0xa1
xa2=0xa2
xa3=0xa3
x27=0x27
xba=0xba
xbb=0xbb
x86=0x86
x87=0x87
x8a=0x8a
x8b=0x8b
x8e=0x8e
x8f=0x8f
y25=0x25
y26=0x26
y35=0x35
y36=0x36
y37=0x37
y38=0x38
w26=0x26
x91=0x91
x92=0x92
  endif
  
Palette0_MTiles:
  .db $24, $24, $24, $24 ;blank
  .db $27, $27, $27, $27 ;black metatile
  .db $24, $24, $24, $35 ;bush left
  .db $36, $25, $37, $25 ;bush middle
  .db $24, $38, $24, $24 ;bush right
  .db $24, $30, $30, w26 ;mountain left
  .db w26, w26, $34, w26 ;mountain left bottom/middle center
  .db $24, $31, $24, $32 ;mountain middle top
  .db $33, w26, $24, $33 ;mountain right
  .db $34, w26, w26, w26 ;mountain right bottom
  .db w26, w26, w26, w26 ;mountain middle bottom
  .db $24, $c0, $24, $c0 ;bridge guardrail
  .db $24, $7f, $7f, $24 ;chain
  .db $b8, $ba, $b9, $bb ;tall tree top, top half
  .db $b8, $bc, $b9, $bd ;short tree top
  .db $ba, $bc, $bb, $bd ;tall tree top, bottom half
  .db $60, $64, $61, $65 ;warp pipe end left, points up
  .db $62, $66, $63, $67 ;warp pipe end right, points up
  .db $60, $64, $61, $65 ;decoration pipe end left, points up
  .db $62, $66, $63, $67 ;decoration pipe end right, points up
  .db $68, $68, $69, $69 ;pipe shaft left
  .db w26, w26, $6a, $6a ;pipe shaft right
  .db $4b, $4c, $4d, $4e ;tree ledge left edge
  .db $4d, $4f, $4d, $4f ;tree ledge middle
  .db $4d, $4e, $50, $51 ;tree ledge right edge
  .db $6b, $70, $2c, $2d ;mushroom left edge
  .db $6c, $71, $6d, $72 ;mushroom middle
  .db $6e, $73, $6f, $74 ;mushroom right edge
  .db $86, $8a, $87, $8b ;sideways pipe end top ;$1c?
  .db $88, $8c, $88, $8c ;sideways pipe shaft top
  .db $89, $8d, $69, $69 ;sideways pipe joint top
  .db $8e, $91, $8f, $92 ;sideways pipe end bottom
  .db w26, $93, w26, $93 ;sideways pipe shaft bottom
  .db $90, $94, $69, $69 ;sideways pipe joint bottom
  .db $a4, $e9, $ea, $eb ;seaplant ;почему в 0-й палитре???
  .db $24, $24, $24, $24 ;blank, used on bricks or blocks that are hit
  .db $24, $2f, $24, $3d ;flagpole ball
  .db $a2, $a2, $a3, $a3 ;flagpole shaft
  .db $24, $24, $24, $24 ;blank, used in conjunction with vines

  
Palette1_MTiles:
  .db xa2, xa2, xa3, xa3 ;vertical rope
  .db $99, $24, $99, $24 ;horizontal rope
  .db $24, xa2, $3e, $3f ;left pulley
  .db $5b, $5c, $24, xa3 ;right pulley
  .db $24, $24, $24, $24 ;blank used for balance rope
  .db $9d, $47, $9e, $47 ;castle top
  .db $47, $47, x27, x27 ;castle window left
  .db $47, $47, $47, $47 ;castle brick wall
  .db x27, x27, $47, $47 ;castle window right
  .db $a9, $47, $aa, $47 ;castle top w/ brick
  .db $9b, x27, $9c, x27 ;entrance top
  .db x27, x27, x27, x27 ;entrance bottom
  .db $52, $52, $52, $52 ;green ledge stump
  .db $80, xa0, $81, xa1 ;fence
  .db $be, $be, $bf, $bf ;tree trunk
  .db $75, xba, $76, xbb ;mushroom stump top
  .db xba, xba, xbb, xbb ;mushroom stump bottom
  .db $45, $47, $45, $47 ;breakable brick w/ line 
  .db $47, $47, $47, $47 ;breakable brick 
  .db $45, $47, $45, $47 ;breakable brick (not used)
  .db $b4, $b6, $b5, $b7 ;cracked rock terrain
  .db $45, $47, $45, $47 ;brick with line (power-up)
  .db $45, $47, $45, $47 ;brick with line (vine)
  .db $45, $47, $45, $47 ;brick with line (star)
  .db $45, $47, $45, $47 ;brick with line (coins)
  .db $45, $47, $45, $47 ;brick with line (1-up)
  .db $47, $47, $47, $47 ;brick (power-up)
  .db $47, $47, $47, $47 ;brick (vine)
  .db $47, $47, $47, $47 ;brick (star)
  .db $47, $47, $47, $47 ;brick (coins)
  .db $47, $47, $47, $47 ;brick (1-up)
  .db $24, $24, $24, $24 ;hidden block (1 coin)
  .db $24, $24, $24, $24 ;hidden block (1-up)
  .db $ab, $ac, $ad, $ae ;solid block (3-d block)
  .db $5d, $5e, $5d, $5e ;solid block (white wall)
  .db $c1, $24, $c1, $24 ;bridge
  .db $c6, $c8, $c7, $c9 ;bullet bill cannon barrel
  .db $ca, $cc, $cb, $cd ;bullet bill cannon top
  .db $2a, $2a, $40, $40 ;bullet bill cannon bottom
  .db $24, $24, $24, $24 ;blank used for jumpspring
  .db $24, $47, $24, $47 ;half brick used for jumpspring
  .db $82, $83, $84, $85 ;solid block (water level, green rock)
  .db $24, $47, $24, $47 ;half brick (???)
  .db x86, x8a, x87, x8b ;water pipe top
  .db x8e, x91, x8f, x92 ;water pipe bottom
  .db $24, $2f, $24, $3d ;flag ball (residual object) ;не перекрашиваем???

Palette2_MTiles:
  .db $24, $24, $24, y35 ;cloud left
  .db y36, y25, y37, y25 ;cloud middle
  .db $24, y38, $24, $24 ;cloud right
  .db $24, $24, $39, $24 ;cloud bottom left
  .db $3a, $24, $3b, $24 ;cloud bottom middle
  .db $3c, $24, $24, $24 ;cloud bottom right
  .db $41, y26, $41, y26 ;water/lava top
  .db y26, y26, y26, y26 ;water/lava
  .db $b0, $b1, $b2, $b3 ;cloud level terrain
  .db $77, $79, $77, $79 ;bowser's bridge
      
Palette3_MTiles:
  .db $53, $55, $54, $56 ;question block (coin)
  .db $53, $55, $54, $56 ;question block (power-up)
  .db $a5, $a7, $a6, $a8 ;coin
  .db $c2, $c4, $c3, $c5 ;underwater coin ;почему в 3-ей палитре???
  .db $57, $59, $58, $5a ;empty block
  .db $7b, $7d, $7c, $7e ;axe

;-------------------------------------------------------------------------------------
;VRAM BUFFER DATA FOR LOCATIONS IN PRG-ROM

WaterPaletteData:
  .db $3f, $00, $20
  .db $0f, $15, $12, $25  
  .db $0f, $3a, $1a, $0f
  .db $0f, $30, $12, $0f
  .db $0f, $27, $12, $0f
  .db $22, $16, $27, $18
  .db $0f, $10, $30, $27
  .db $0f, $16, $30, $27
  .db $0f, $0f, $30, $10
  .db $00

GroundPaletteData:
  .db $3f, $00, $20
  .db $0f, $29, $1a, $0f
  .db $0f, $36, $17, $0f
  .db $0f, $30, $21, $0f
  .db $0f, $27, $17, $0f
  .db $0f, $16, $27, $18
  .db $0f, $1a, $30, $27
  .db $0f, $16, $30, $27
  .db $0f, $0f, $36, $17
  .db $00

UndergroundPaletteData:
  .db $3f, $00, $20
  .db $0f, $29, $1a, $09
  .db $0f, $3c, $1c, $0f
  .db $0f, $30, $21, $1c
  .db $0f, $27, $17, $1c
  .db $0f, $16, $27, $18
  .db $0f, $1c, $36, $17
  .db $0f, $16, $30, $27
  .db $0f, $0c, $3c, $1c
  .db $00

CastlePaletteData:
  .db $3f, $00, $20
  .db $0f, $30, $10, $00
  .db $0f, $30, $10, $00
  .db $0f, $30, $16, $00
  .db $0f, $27, $17, $00
  .db $0f, $16, $27, $18
  .db $0f, $1c, $36, $17
  .db $0f, $16, $30, $27
  .db $0f, $00, $30, $10
  .db $00

DaySnowPaletteData:
  .db $3f, $00, $04
  .db $22, $30, $00, $10
  .db $00

NightSnowPaletteData:
  .db $3f, $00, $04
  .db $0f, $30, $00, $10
  .db $00

MushroomPaletteData:
  .db $3f, $00, $04
  .db $22, $27, $16, $0f
  .db $00

BowserPaletteData:
  .db $3f, $14, $04
  .db $0f, $1a, $30, $27
  .db $00

MarioThanksMessage:
;"THANK YOU MARIO!"
  .db $25, $48, $10
  .db $1d, $11, $0a, $17, $14, $24
  .db $22, $18, $1e, $24
  .db $16, $0a, $1b, $12, $18, $2b
  .db $00

LuigiThanksMessage:
;"THANK YOU LUIGI!"
  .db $25, $48, $10
  .db $1d, $11, $0a, $17, $14, $24
  .db $22, $18, $1e, $24
  .db $15, $1e, $12, $10, $12, $2b
  .db $00

MushroomRetainerSaved:
;"BUT OUR PRINCESS IS IN"
  .db $25, $c5, $16
  .db $0b, $1e, $1d, $24, $18, $1e, $1b, $24
  .db $19, $1b, $12, $17, $0c, $0e, $1c, $1c, $24
  .db $12, $1c, $24, $12, $17
;"ANOTHER CASTLE!"
  .db $26, $05, $0f
  .db $0a, $17, $18, $1d, $11, $0e, $1b, $24
  .db $0c, $0a, $1c, $1d, $15, $0e, $2b, $00

PrincessSaved1:
;"YOUR QUEST IS OVER."
  .db $25, $a7, $13
  .db $22, $18, $1e, $1b, $24
  .db $1a, $1e, $0e, $1c, $1d, $24
  .db $12, $1c, $24, $18, $1f, $0e, $1b, $af
  .db $00

PrincessSaved2:
;"WE PRESENT YOU A NEW QUEST."
  .db $25, $e3, $1b
  .db $20, $0e, $24
  .db $19, $1b, $0e, $1c, $0e, $17, $1d, $24
  .db $22, $18, $1e, $24, $0a, $24, $17, $0e, $20, $24
  .db $1a, $1e, $0e, $1c, $1d, $af
  .db $00

WorldSelectMessage1:
;"PUSH BUTTON B"
  .db $26, $4a, $0d
  .db $19, $1e, $1c, $11, $24
  .db $0b, $1e, $1d, $1d, $18, $17, $24, $0b
  .db $00

WorldSelectMessage2:
;"TO SELECT A WORLD"
  .db $26, $88, $11
  .db $1d, $18, $24, $1c, $0e, $15, $0e, $0c, $1d, $24
  .db $0a, $24, $20, $18, $1b, $15, $0d
  .db $00

;-------------------------------------------------------------------------------------
;$04 - address low to jump address
;$05 - address high to jump address
;$06 - jump address low
;$07 - jump address high

;a=function number
;addresses of functions follow the jsr
JumpEngine:
        if Z80
        add a,a
        pop hl ;pull saved return address from stack
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
	 or a ;CY=0 ;??? ;не помогает в 1-2
        jp (hl)
        
        else
       asl          ;shift bit from contents of A
       tay
       pla          ;pull saved return address from stack
       sta SCRATCHPAD+$04      ;save to indirect
       pla
       sta SCRATCHPAD+$05 ;($04..05) = return addr???
       iny ;y = A*2 + 1???
       ldayindirect (SCRATCHPAD+$04),y  ;load pointer from indirect
       sta SCRATCHPAD+$06      ;note that if an RTS is performed in next routine
       iny ;y = A*2 + 2???          ;it will return to the execution before the sub
       ldayindirect (SCRATCHPAD+$04),y  ;that called this routine
       sta SCRATCHPAD+$07
       jmpindirect (SCRATCHPAD+$06)    ;jump to the address we loaded
        endif

;-------------------------------------------------------------------------------------

InitializeNameTables:
        if Z80==0
              lda PPU_STATUS            ;reset flip-flop
              lda Mirror_PPU_CTRL_REG1  ;load mirror of ppu reg $2000
              oran ++%00010000            ;set sprites for first 4k and background for second 4k
              andn ++%11110000            ;clear rest of lower nybble, leave higher alone
              jsr WritePPUReg1
        endif
              ldan ++$24                  ;set vram address to start of name table 1
              jsr WriteNTAddr
              ldan ++$20                  ;and then set it to name table 0
WriteNTAddr:
        if Z80
              ld hx,a
              ld lx,0
        else
              sta PPU_ADDRESS
              ldan ++$00
              sta PPU_ADDRESS
        endif
              ldxn ++$04                  ;clear name table with blank tile #24
              ldyn ++$c0
              ldan ++$24
InitNTLoop:   
        if Z80
              ld (ix),a
              inc ix
        else
              sta PPU_DATA              ;count out exactly 768 tiles
        endif
              dey
              bne InitNTLoop
              dex
              bne InitNTLoop
              ldyn ++64                   ;now to clear the attribute table (with zero this time)
              txa
              sta VRAM_Buffer1_Offset   ;init vram buffer 1 offset
              sta VRAM_Buffer1          ;init vram buffer 1
InitATLoop:   
        if Z80
              ld (ix),a
              inc ix
        else
              sta PPU_DATA
        endif
              dey
              bne InitATLoop
              sta HorizontalScroll      ;reset scroll variables
              sta VerticalScroll
              jmp InitScroll            ;initialize scroll registers to zero

;-------------------------------------------------------------------------------------
;$00 - temp joypad bit

;bit - button (ZX key)
;7 - A (A)
;6 - B (S)
;5 - Select (Space)
;4 - Start (Enter)
;3 - Up (7)
;2 - Down (6)
;1 - Left (5)
;0 - Right (8)
ReadJoypads: 
              ldan ++$01               ;reset and clear strobe of joypad ports
              sta JOYPAD_PORT
              lsr
              tax                    ;start with joypad 1's port
              sta JOYPAD_PORT
              jsr ReadPortBits
              inx                    ;increment for joypad 2's port
ReadPortBits:
        if Z80
        push bc
	if OSCALLS
        OS_GETKEYMATRIX ;out: bcdehlix = полуряды cs...space
	else
        ld bc,0x7ffe
        in a,(c)
        ld lx,a  ;lx=%???bnmS_
        ld b,0xbf
        in a,(c)
        ld hx,a  ;hx=%???hjklE
        ld b,0xdf
        in l,(c)  ;l=%???yuiop
        ld b,0xef
        in h,(c)  ;h=%???67890
        ld b,0xf7
        in e,(c)  ;e=%???54321
        ld b,0xfb
        in d,(c)  ;d=%???trewq
        ld a,0xfd
        in a,(0xfe);c=%???gfdsa
        ld b,c;0xfe
        in b,(c)  ;b=%???vcxzC
        ld c,a
	endif
        ld a,lx
        or b
        rra
        jp nc,quit
	if DEMO
	 bit 3,b ;'c'
	 call z,democontinue
	 bit 2,c ;'d'
	 call z,demooff
	endif
	rr c ;'a'
	rla ;A
	rr c ;'s'
	rla ;B
	ld c,lx
	rr c ;'Space'
	rla ;Select
	ld c,hx
	rr c ;'Enter'
	rla ;Start
	add a,a
	bit 3,h ;7
	jr z,$+3
	inc a ;Up
	add a,a
	bit 4,h ;6
	jr z,$+3
	inc a ;Down
	add a,a
	bit 4,e ;5
	jr z,$+3
	inc a ;Left
	add a,a
	bit 2,h ;8
	jr z,$+3
	inc a ;Right
        cpl
	if DEMO
         pop de ;x = joypad number
         push de
         dec e ;(для joy1/2)
	push bc
	call nz,readdemo ;оно же writedemo (для joy2)
	pop bc
	push af
	 bit 4,b ;'v'
	 call z,savedemo
	pop af
	endif
        ld d,0
        pop bc ;ld bc,0 ;x = joypad number
        else

              ldyn ++$08
PortLoop:     pha                    ;push previous bit onto stack
              ldax JOYPAD_PORT,x      ;read current bit on joypad port
              sta SCRATCHPAD+$00                ;check d1 and d0 of port output
              lsr                    ;this is necessary on the old
              orai SCRATCHPAD+$00                ;famicom systems in japan
              lsr
              ;pla                    ;read bits from stack
              ;rol                    ;rotate bit from carry flag
               plarol
              dey
              bne PortLoop           ;count down bits left
        endif
              stax SavedJoypadBits,x  ;save controller status here always
              pha
              andn ++%00110000         ;check for select or start
              andx JoypadBitMask,x    ;if neither saved state nor current state
              beq Save8Bits          ;have any of these two set, branch
              pla
              andn ++%11001111         ;otherwise store without select
              stax SavedJoypadBits,x  ;or start bits and leave
              rts
Save8Bits:    pla
              stax JoypadBitMask,x    ;save with all bits in another place and leave ;используется только в этой процедуре
              rts

;-------------------------------------------------------------------------------------
;$00 - vram buffer address table low
;$01 - vram buffer address table high

;в буфере:
;addrH, addrL, [SRLLLLLL (S=inc32, R=repeat, L=length),] S0BBBBBB?
        if Z80
UpdateScreen:  
        ld hl,(SCRATCHPAD+$00)
UpdateScreen0:  
	ld a,(hl)
	or a
	ret z
                 ;cp 0x40
                 ;jr nc,$ ;костыль - почему в потоке значения $42???
                ld d,a
		inc hl
		ld e,(hl)           ;load next byte (second)
		inc hl
		ld a,(hl)            ;load next byte (third)
		ex de,hl
               add a,a
                ld c,32
                jr c,$+4
                ld c,1 ;if d7 of third byte was clear, ppu will only increment by 1
               add a,a
               jr nc,GetLength             ;if d6 of third byte was clear, do not repeat byte
               srl a
	       rra
		ld lx,a
               inc de
		ld a,(de)
RepeatByte0:
                ld (hl),a
                add hl,bc
		dec lx
               jp nz,RepeatByte0
	       jp OutputToVRAM_q
GetLength:
;CY=0
		rra                       ;shift back to the right to get proper length
                rra                      ;note that d1 will now be in carry
		ld lx,a
OutputToVRAM0:
		inc de
		ld a,(de)
                ld (hl),a
                add hl,bc
		dec lx
               jp nz,OutputToVRAM0
OutputToVRAM_q
		ex de,hl
	       ld d,b;0
	       inc hl
	       jp UpdateScreen0
        else
WriteBufferToScreen:
;a=addrH
;y=0
               sta PPU_ADDRESS           ;store high byte of vram address
               iny
               ldayindirect (SCRATCHPAD+$00),y               ;load next byte (second)
               sta PPU_ADDRESS           ;store low byte of vram address
               iny
               ldayindirect (SCRATCHPAD+$00),y               ;load next byte (third)
               asl                       ;shift to left and save in stack
               pha
               lda Mirror_PPU_CTRL_REG1  ;load mirror of $2000,
               oran ++%00000100            ;set ppu to increment by 32 by default
               bcs SetupWrites           ;if d7 of third byte was clear, ppu will
               andn ++%11111011            ;only increment by 1
SetupWrites:   jsr WritePPUReg1          ;write to register
               pla                       ;pull from stack and shift to left again
               asl
               bcc GetLength             ;if d6 of third byte was clear, do not repeat byte
               oran ++%00000010            ;otherwise set d1 and increment Y
               iny
GetLength:     lsr                       ;shift back to the right to get proper length
               lsr                       ;note that d1 will now be in carry
               tax
OutputToVRAM:  bcs RepeatByte            ;if carry set, repeat loading the same byte
               iny                       ;otherwise increment Y to load next byte
RepeatByte:    ldayindirect (SCRATCHPAD+$00),y               ;load more data from buffer and write to vram
               sta PPU_DATA
               dex                       ;done writing?
               bne OutputToVRAM
               sec          
               tya ;a=end shift
               adci SCRATCHPAD+$00                   ;add end length plus one to the indirect at $00
               sta SCRATCHPAD+$00                   ;to allow this routine to read another set of updates
               ldan ++$00
               adci SCRATCHPAD+$01
               sta SCRATCHPAD+$01
               ldan ++$3f                  ;sets vram address to $3f00 (палитра фона 16 байт, палитра спрайтов 16 байт) ;зачем???
               sta PPU_ADDRESS
               ldan ++$00
               sta PPU_ADDRESS
               sta PPU_ADDRESS           ;then reinitializes it for some reason ;зачем теперь в 0???
               sta PPU_ADDRESS
UpdateScreen:  
               ldx PPU_STATUS            ;reset flip-flop
               ldyn ++$00                  ;load first byte from indirect as a pointer
               ldayindirect (SCRATCHPAD+$00),y  
         checka
               bne WriteBufferToScreen   ;if byte is zero we have no further updates to make here
        endif
InitScroll:    sta PPU_SCROLL_REG_H        ;store contents of A into scroll registers
               sta PPU_SCROLL_REG_V        ;and end whatever subroutine led us here
               rts

;-------------------------------------------------------------------------------------

        if Z80==0
WritePPUReg1:
               sta PPU_CTRL_REG1         ;write contents of A to PPU register 1
               sta Mirror_PPU_CTRL_REG1  ;and its mirror
               rts
        endif

;-------------------------------------------------------------------------------------
;$00 - used to store status bar nybbles
;$02 - used as temp vram offset
;$03 - used to store length of status bar number

;status bar name table offset and length data
StatusBarData:
      .db $f0, $06 ; top score display on title screen
      .db $62, $06 ; player score
      .db $62, $06
      .db $6d, $02 ; coin tally
      .db $6d, $02
      .db $7a, $03 ; game timer

StatusBarOffset:
      .db $06, $0c, $12, $18, $1e, $24

PrintStatusBarNumbers:
      sta SCRATCHPAD+$00            ;store player-specific offset
      jsr OutputNumbers  ;use first nybble to print the coin display
      lda SCRATCHPAD+$00            ;move high nybble to low
      lsr                ;and print to score display
      lsr
      lsr
      lsr

OutputNumbers:
             clc                      ;add 1 to low nybble
             adcn ++$01
             andn ++%00001111           ;mask out high nybble
             cmpn ++$06
              cmpcy
             bcs ExitOutputN
             pha                      ;save incremented value to stack for now and
             asl                      ;shift to left and use as offset
             tay
             ldx VRAM_Buffer1_Offset  ;get current buffer pointer
             ldan ++$20                 ;put at top of screen by default
             cpyn ++$00                 ;are we writing top score on title screen?
             bne SetupNums
             ldan ++$22                 ;if so, put further down on the screen
SetupNums:   stax VRAM_Buffer1,x
             lday StatusBarData,y      ;write low vram address and length of thing
             stax VRAM_Buffer1+1,x     ;we're printing to the buffer
             lday StatusBarData+1,y
             stax VRAM_Buffer1+2,x
             sta SCRATCHPAD+$03                  ;save length byte in counter
             stx SCRATCHPAD+$02                  ;and buffer pointer elsewhere for now
             pla                      ;pull original incremented value from stack
             tax
             ldax StatusBarOffset,x    ;load offset to value we want to write
             secsub
             sbcy StatusBarData+1,y    ;subtract from length byte we read before
             tay                      ;use value as offset to display digits
             ldx SCRATCHPAD+$02
DigitPLoop:  lday DisplayDigits,y      ;write digits to the buffer
             stax VRAM_Buffer1+3,x    
             inx
             iny
             deci SCRATCHPAD+$03                  ;do this until all the digits are written
             bne DigitPLoop
             ldan ++$00                 ;put null terminator at end
             stax VRAM_Buffer1+3,x
             inx                      ;increment buffer pointer by 3
             inx
             inx
             stx VRAM_Buffer1_Offset  ;store it in case we want to use it again
ExitOutputN: rts

;-------------------------------------------------------------------------------------

;y=смещение адреса
DigitsMathRoutine:
            lda OperMode              ;check mode of operation
            cmpn ++TitleScreenModeValue
            beq EraseDMods            ;if in title screen mode, branch to lock score
            ldxn ++$05
AddModLoop: ldax DigitModifier,x       ;load digit amount to increment
            clc
            adcy DisplayDigits,y       ;add to current digit
            bmi BorrowOne             ;if result is a negative number, branch to subtract
            cmpn ++10
              cmpcy
            bcs CarryOne              ;if digit greater than $09, branch to add
StoreNewD:  stay DisplayDigits,y       ;store as new score or game timer digit
            dey                       ;move onto next digits in score or game timer
            dex                       ;and digit amounts to increment
            bpl AddModLoop            ;loop back if we're not done yet
EraseDMods: ldan ++$00                  ;store zero here
            ldxn ++$06                  ;start with the last digit
EraseMLoop: stax DigitModifier-1,x     ;initialize the digit amounts to increment
            dex
            bpl EraseMLoop            ;do this until they're all reset, then leave
            rts
BorrowOne:  decx DigitModifier-1,x     ;decrement the previous digit, then put $09 in
            ldan ++$09                  ;the game timer digit we're currently on to "borrow
         checka
            bne StoreNewD             ;the one", then do an unconditional branch back
CarryOne:   secsub    ;перенос в вычитании инверсный???                   ;subtract ten from our digit to make it a
            sbcn ++10                   ;proper BCD number, then increment the digit
            incx DigitModifier-1,x     ;preceding current digit to "carry the one" properly
            jmp StoreNewD             ;go back to just after we branched here

;-------------------------------------------------------------------------------------

UpdateTopScore:
      ldxn ++$05          ;start with mario's score
      jsr TopScoreCheck
      ldxn ++$0b          ;now do luigi's score

TopScoreCheck:
              ldyn ++$05                 ;start with the lowest digit
              secsub           ;перенос в вычитании инверсный???
GetScoreDiff: ldax PlayerScoreDisplay,x ;subtract each player digit from each high score digit
        if Z80
        secsub
        endif
              sbcy TopScoreDisplay,y    ;from lowest to highest, if any top score digit exceeds
              dex                      ;any player digit, borrow will be set until a subsequent
              dey                      ;subtraction clears it (player digit is higher than top)
              bpl GetScoreDiff      
              cmpcy
              bcc NoTopSc              ;check to see if borrow is still set, if so, no new high score
              inx                      ;increment X and Y once to the start of the score
              iny
CopyScore:    ldax PlayerScoreDisplay,x ;store player's score digits into high score memory area
              stay TopScoreDisplay,y
              inx
              iny
              cpyn ++$06                 ;do this until we have stored them all
              cmpcy
              bcc CopyScore
NoTopSc:      rts

;-------------------------------------------------------------------------------------

DefaultSprOffsets:
      .db $04, $30, $48, $60, $78, $90, $a8, $c0
      .db $d8, $e8, $24, $f8, $fc, $28, $2c

Sprite0Data:
      .db $18, $ff, $23, $58

;-------------------------------------------------------------------------------------

InitializeGame:
             ldyn16 ++GAMEDATA_end-AREADATA;++$6f              ;clear all memory as in initialization procedure,
             jsr InitializeMemory  ;but this time, clear only as far as $076f
             ldyn ++$1f
ClrSndLoop:  stay SoundMemory,y     ;clear out memory used
             dey                   ;by the sound engines
             bpl ClrSndLoop
             ldan ++$18              ;set demo timer
             sta DemoTimer
             jsr LoadAreaPointer

InitializeArea:
               ldyn16 ++AREADATA_end-AREADATA;++$4b                 ;clear all memory again, only as far as $074b
               jsr InitializeMemory     ;this is only necessary if branching from
               ldxn ++$21
               ldan ++$00
ClrTimersLoop: stax Timers,x             ;clear out memory between
               dex                      ;$0780 and $07a1
               bpl ClrTimersLoop
               lda HalfwayPage
               ldy AltEntranceControl   ;if AltEntranceControl not set, use halfway page, if any found
         checky
               beq StartPage
               lda EntrancePage         ;otherwise use saved entry page number here
StartPage:     sta ScreenLeft_PageLoc   ;set as value here
               sta CurrentPageLoc       ;also set as current page
               sta BackloadingFlag      ;set flag here if halfway page or saved entry page number found
               jsr GetScreenPosition    ;get pixel coordinates for screen borders
               ldyn ++$20                 ;if on odd numbered page, use $2480 as start of rendering
               andn ++%00000001           ;otherwise use $2080, this address used later as name table
               beq SetInitNTHigh        ;address for rendering of game area
               ldyn ++$24
SetInitNTHigh: sty CurrentNTAddr_High   ;store name table address
               ldyn ++$80
               sty CurrentNTAddr_Low
               asl                      ;store LSB of page number in high nybble
               asl                      ;of block buffer column position
               asl
               asl
               sta BlockBufferColumnPos
               deci AreaObjectLength     ;set area object lengths for all empty
               deci AreaObjectLength+1
               deci AreaObjectLength+2
               ldan ++$0b                 ;set value for renderer to update 12 column sets
               sta ColumnSets           ;12 column sets = 24 metatile columns = 1 1/2 screens
               jsr GetAreaDataAddrs     ;get enemy and level addresses and load header
               lda PrimaryHardMode      ;check to see if primary hard mode has been activated
         checka
               bne SetSecHard           ;if so, activate the secondary no matter where we're at
               lda WorldNumber          ;otherwise check world number
               cmpn ++World5              ;if less than 5, do not activate secondary
              cmpcy
               bcc CheckHalfway
               bne SetSecHard           ;if not equal to, then world HIGH  5, thus activate
               lda LevelNumber          ;otherwise, world 5, so check level number
               cmpn ++Level3              ;if 1 or 2, do not set secondary hard mode flag
              cmpcy
               bcc CheckHalfway
SetSecHard:    inci SecondaryHardMode    ;set secondary hard mode flag for areas 5-3 and beyond
CheckHalfway:  lda HalfwayPage
         checka
               beq DoneInitArea
               ldan ++$02                 ;if halfway page set, overwrite start position from header
               sta PlayerEntranceCtrl
DoneInitArea:  ldan ++Silence             ;silence music
               sta AreaMusicQueue
               ldan ++$01                 ;disable screen output
               sta DisableScreenFlag
               inci OperMode_Task        ;increment one of the modes
               rts

;-------------------------------------------------------------------------------------

PrimaryGameSetup:
      ldan ++$01
      sta FetchNewGameTimerFlag   ;set flag to load game timer from header
      sta PlayerSize              ;set player's size to small
      ldan ++$02
      sta NumberofLives           ;give each player three lives
      sta OffScr_NumberofLives

SecondaryGameSetup:
             ldan ++$00
             sta DisableScreenFlag     ;enable screen output
             tay
ClearVRLoop: stay VRAM_Buffer1-1,y      ;clear buffer at $0300-$03ff
             iny
             bne ClearVRLoop
             sta GameTimerExpiredFlag  ;clear game timer exp flag
             sta DisableIntermediate   ;clear skip lives display flag
             sta BackloadingFlag       ;clear value here
             ldan ++$ff
             sta BalPlatformAlignment  ;initialize balance platform assignment flag
             lda ScreenLeft_PageLoc    ;get left side page location
             lsri Mirror_PPU_CTRL_REG1  ;shift LSB of ppu register #1 mirror out
        if Z80==0
             andn ++$01                  ;mask out all but LSB of page location
        endif
             ror                       ;rotate LSB of page location into carry then onto mirror
             roli Mirror_PPU_CTRL_REG1  ;this is to set the proper PPU name table
             jsr GetAreaMusic          ;load proper music into queue
             ldan ++$38                  ;load sprite shuffle amounts to be used later
             sta SprShuffleAmt+2
             ldan ++$48
             sta SprShuffleAmt+1
             ldan ++$58
             sta SprShuffleAmt
             ldxn ++$0e                  ;load default OAM offsets into $06e4-$06f2
ShufAmtLoop: ldax DefaultSprOffsets,x
             stax SprDataOffset,x
             dex                       ;do this until they're all set
             bpl ShufAmtLoop
             ldyn ++$03                  ;set up sprite #0
ISpr0Loop:   lday Sprite0Data,y
             stay Sprite_Data,y
             dey
             bpl ISpr0Loop
             jsr DoNothing2            ;these jsrs doesn't do anything useful
             jsr DoNothing1
             inci Sprite0HitDetectFlag  ;set sprite #0 check flag ;теперь будет работать сплитскрин со скроллом
             inci OperMode_Task         ;increment to next task
             rts

;-------------------------------------------------------------------------------------

;$06 - RAM address low
;$07 - RAM address high

;y = endaddr
;out: a=0
InitializeMemory:
        if Z80
                push de
                ld hl,AREADATA
                ld de,AREADATA+1
                pop bc
                dec bc
                xor a
                ld (hl),a
                ldir
                ld d,b;0
        else
              ldxn ++$07          ;set initial high byte to $0700-$07ff
              ldan ++$00          ;set initial low byte to start of page (at $00 of page)
              sta SCRATCHPAD+$06
InitPageLoop: stx SCRATCHPAD+$07
InitByteLoop: cpxn ++$01          ;check to see if we're on the stack ($0100-$01ff)
              bne InitByte      ;if not, go ahead anyway
              cpyn ++$60          ;otherwise, check to see if we're at $0160-$01ff
              cmpcy
              bcs SkipByte      ;if so, skip write
InitByte:     stayindirect (SCRATCHPAD+$06),y       ;otherwise, initialize byte with current low byte in Y
SkipByte:     dey
              cpyn ++$ff          ;do this until all bytes in page have been erased
              bne InitByteLoop
              dex               ;go onto the next page
              bpl InitPageLoop  ;do this until all pages of memory have been erased
        endif
              rts

;-------------------------------------------------------------------------------------

MusicSelectData:
      .db WaterMusic, GroundMusic, UndergroundMusic, CastleMusic
      .db CloudMusic, PipeIntroMusic

GetAreaMusic:
             lda OperMode           ;if in title screen mode, leave
         checka
             beq ExitGetM
             lda AltEntranceControl ;check for specific alternate mode of entry
             cmpn ++$02               ;if found, branch without checking starting position
             beq ChkAreaType        ;from area object data header
             ldyn ++$05               ;select music for pipe intro scene by default
             lda PlayerEntranceCtrl ;check value from level header for certain values
             cmpn ++$06
             beq StoreMusic         ;load music for pipe intro scene if header
             cmpn ++$07               ;start position either value $06 or $07
             beq StoreMusic
ChkAreaType: ldy AreaType           ;load area type as offset for music bit
             lda CloudTypeOverride
         checka
             beq StoreMusic         ;check for cloud type override
             ldyn ++$04               ;select music for cloud type level if found
StoreMusic:  lday MusicSelectData,y  ;otherwise select appropriate music for level type
             sta AreaMusicQueue     ;store in queue and leave
ExitGetM:    rts

;-------------------------------------------------------------------------------------

PlayerStarting_X_Pos:
      .db $28, $18
      .db $38, $28

AltYPosOffset:
      .db $08, $00

PlayerStarting_Y_Pos:
      .db $00, $20, $b0, $50, $00, $00, $b0, $b0
      .db $f0

PlayerBGPriorityData:
      .db $00, $20, $00, $00, $00, $00, $00, $00

GameTimerData:
      .db $20 ;dummy byte, used as part of bg priority data
      .db $04, $03, $02

Entrance_GameTimerSetup:
          lda ScreenLeft_PageLoc      ;set current page for area objects
          sta Player_PageLoc          ;as page location for player
          ldan ++$28                    ;store value here
          sta VerticalForceDown       ;for fractional movement downwards if necessary
          ldan ++$01                    ;set high byte of player position and
          sta PlayerFacingDir         ;set facing direction so that player faces right
          sta Player_Y_HighPos
          ldan ++$00                    ;set player state to on the ground by default
          sta Player_State
          deci Player_CollisionBits    ;initialize player's collision bits
          ldyn ++$00                    ;initialize halfway page
          sty HalfwayPage      
          lda AreaType                ;check area type
         checka
          bne ChkStPos                ;if water type, set swimming flag, otherwise do not set
          iny
ChkStPos: sty SwimmingFlag
          ldx PlayerEntranceCtrl      ;get starting position loaded from header
          ldy AltEntranceControl      ;check alternate mode of entry flag for 0 or 1
         checky
          beq SetStPos
          cpyn ++$01
          beq SetStPos
          ldxy AltYPosOffset-2,y       ;if not 0 or 1, override $0710 with new offset in X
SetStPos: lday PlayerStarting_X_Pos,y  ;load appropriate horizontal position
          sta Player_X_Position       ;and vertical positions for the player, using
          ldax PlayerStarting_Y_Pos,x  ;AltEntranceControl as offset for horizontal and either $0710
          sta Player_Y_Position       ;or value that overwrote $0710 as offset for vertical
          ldax PlayerBGPriorityData,x
          sta Player_SprAttrib        ;set player sprite attributes using offset in X
          jsr GetPlayerColors         ;get appropriate player palette
          ldy GameTimerSetting        ;get timer control value from header
         checky
          beq ChkOverR                ;if set to zero, branch (do not use dummy byte for this)
          lda FetchNewGameTimerFlag   ;do we need to set the game timer? if not, use 
         checka
          beq ChkOverR                ;old game timer setting
          lday GameTimerData,y         ;if game timer is set and game timer flag is also set,
          sta GameTimerDisplay        ;use value of game timer control for first digit of game timer
          ldan ++$01
          sta GameTimerDisplay+2      ;set last digit of game timer to 1
          lsr
          sta GameTimerDisplay+1      ;set second digit of game timer
          sta FetchNewGameTimerFlag   ;clear flag for game timer reset
          sta StarInvincibleTimer     ;clear star mario timer
ChkOverR: ldy JoypadOverride          ;if controller bits not set, branch to skip this part
         checky
          beq ChkSwimE
          ldan ++$03                    ;set player state to climbing
          sta Player_State
          ldxn ++$00                    ;set offset for first slot, for block object
          jsr InitBlock_XY_Pos
          ldan ++$f0                    ;set vertical coordinate for block object
          sta Block_Y_Position
          ldxn ++$05                    ;set offset in X for last enemy object buffer slot
          ldyn ++$00                    ;set offset in Y for object coordinates used earlier
          jsr Setup_Vine              ;do a sub to grow vine
ChkSwimE: ldy AreaType                ;if level not water-type,
         checky
          bne SetPESub                ;skip this subroutine
          jsr SetupBubble             ;otherwise, execute sub to set up air bubbles
SetPESub: ldan ++$07                    ;set to run player entrance subroutine
          sta GameEngineSubroutine    ;on the next frame of game engine
          rts

;-------------------------------------------------------------------------------------

;page numbers are in order from -1 to -4
HalfwayPageNybbles:
      .db $56, $40
      .db $65, $70
      .db $66, $40
      .db $66, $40
      .db $66, $40
      .db $66, $60
      .db $65, $70
      .db $00, $00

PlayerLoseLife:
             inci DisableScreenFlag    ;disable screen and sprite 0 check
             ldan ++$00
             sta Sprite0HitDetectFlag
             ldan ++Silence             ;silence music
             sta EventMusicQueue
	    if INFINITELIVES
	     xor a
	    else
             deci NumberofLives        ;take one life from player
	    endif 
             bpl StillInGame          ;if player still has lives, branch
             ldan ++$00
             sta OperMode_Task        ;initialize mode task,
             ldan ++GameOverModeValue   ;switch to game over mode
             sta OperMode             ;and leave
             rts
StillInGame: lda WorldNumber          ;multiply world number by 2 and use
             asl                      ;as offset
             tax
             lda LevelNumber          ;if in area -3 or -4, increment
             andn ++$02                 ;offset by one byte, otherwise
             beq GetHalfway           ;leave offset alone
             inx
GetHalfway:  ldyx HalfwayPageNybbles,x ;get halfway page number with offset
             lda LevelNumber          ;check area number's LSB
             lsr
             tya                      ;if in area -2 or -4, use lower nybble
             bcs MaskHPNyb
             lsr                      ;move higher nybble to lower if area
             lsr                      ;number is -1 or -3
             lsr
             lsr
MaskHPNyb:   andn ++%00001111           ;mask out all but lower nybble
             cmpi ScreenLeft_PageLoc
              cmpcy
             beq SetHalfway           ;left side of screen must be at the halfway page,
             bcc SetHalfway           ;otherwise player must start at the
             ldan ++$00                 ;beginning of the level
SetHalfway:  sta HalfwayPage          ;store as halfway page for player
             jsr TransposePlayers     ;switch players around if 2-player game
             jmp ContinueGame         ;continue the game

;-------------------------------------------------------------------------------------

GameOverMode:
      lda OperMode_Task
      jsr JumpEngine
      
      .dw SetupGameOver
      .dw ScreenRoutines
      .dw RunGameOver

;-------------------------------------------------------------------------------------

SetupGameOver:
      ldan ++$00                  ;reset screen routine task control for title screen, game,
      sta ScreenRoutineTask     ;and game over modes
      sta Sprite0HitDetectFlag  ;disable sprite 0 check
      ldan ++GameOverMusic
      sta EventMusicQueue       ;put game over music in secondary queue
      inci DisableScreenFlag     ;disable screen output
      inci OperMode_Task         ;set secondary mode to 1
      rts

;-------------------------------------------------------------------------------------

RunGameOver:
      ldan ++$00              ;reenable screen
      sta DisableScreenFlag
      lda SavedJoypad1Bits  ;check controller for start pressed
      andn ++Start_Button
      bne TerminateGame
      lda ScreenTimer       ;if not pressed, wait for
         checka
      bne GameIsOn          ;screen timer to expire
TerminateGame:
      ldan ++Silence          ;silence music
      sta EventMusicQueue
      jsr TransposePlayers  ;check if other player can keep
      bcc ContinueGame      ;going, and do so if possible
      lda WorldNumber       ;otherwise put world number of current
      sta ContinueWorld     ;player into secret continue function variable
      ldan ++$00
      asl                   ;residual ASL instruction
      sta OperMode_Task     ;reset all modes to title screen and
      sta ScreenTimer       ;leave
      sta OperMode
      rts

ContinueGame:
           jsr LoadAreaPointer       ;update level pointer with
           ldan ++$01                  ;actual world and area numbers, then
           sta PlayerSize            ;reset player's size, status, and
           inci FetchNewGameTimerFlag ;set game timer flag to reload
           ldan ++$00                  ;game timer from header
           sta TimerControl          ;also set flag for timers to count again
           sta PlayerStatus
           sta GameEngineSubroutine  ;reset task for game core
           sta OperMode_Task         ;set modes and leave
           ldan ++$01                  ;if in game over mode, switch back to
           sta OperMode              ;game mode, because game is still on
GameIsOn:  rts

TransposePlayers:
           sec                       ;set carry flag by default to end game
           lda NumberOfPlayers       ;if only a 1 player game, leave
         checka
           beq ExTrans
           lda OffScr_NumberofLives  ;does offscreen player have any lives left?
         checka
           bmi ExTrans               ;branch if not
           lda CurrentPlayer         ;invert bit to update
           eorn ++%00000001            ;which player is on the screen
           sta CurrentPlayer
           ldxn ++$06
TransLoop: ldax OnscreenPlayerInfo,x    ;transpose the information
           pha                         ;of the onscreen player
           ldax OffscreenPlayerInfo,x   ;with that of the offscreen player
           stax OnscreenPlayerInfo,x
           pla
           stax OffscreenPlayerInfo,x
           dex
           bpl TransLoop
           clc            ;clear carry flag to get game going
ExTrans:   rts

;-------------------------------------------------------------------------------------

DoNothing1:
      ldan ++$ff       ;this is residual code, this value is
      sta UnusedVariable;$06c9      ;not used anywhere in the program
DoNothing2:
      rts

;-------------------------------------------------------------------------------------

AreaParserTaskHandler:
        ;ret
              ldy AreaParserTaskNum     ;check number of tasks here
         checky
              bne DoAPTasks             ;if already set, go ahead
              ldyn ++$08 ;по новому кругу
              sty AreaParserTaskNum     ;otherwise, set eight by default
DoAPTasks:    dey
              tya
              jsr AreaParserTasks
              deci AreaParserTaskNum     ;if all tasks not complete do not
             if Z80OPT4==0
              bne SkipATRender          ;render attribute table yet
              jsr RenderAttributeTables ;вызывается после RenderAreaGraphics #1 (т.е. 4-го)?
SkipATRender:
             endif
              rts

AreaParserTasks:
      jsr JumpEngine
;всегда выполняются 7..0?
      .dw IncrementColumnPos ;0
      .dw RenderAreaGraphics ;1
      .dw RenderAreaGraphics ;2
      .dw AreaParserCore ;3
      .dw IncrementColumnPos ;4
      .dw RenderAreaGraphics ;5
      .dw RenderAreaGraphics ;6
      .dw AreaParserCore ;7

;-------------------------------------------------------------------------------------

IncrementColumnPos:
           inci CurrentColumnPos     ;increment column where we're at
           lda CurrentColumnPos
           andn ++%00001111           ;mask out higher nybble
           bne NoColWrap
           sta CurrentColumnPos     ;if no bits left set, wrap back to zero (0-f)
           inci CurrentPageLoc       ;and increment page number where we're at
NoColWrap: inci BlockBufferColumnPos ;increment column offset where we're at
           lda BlockBufferColumnPos
           andn ++%00011111           ;mask out all but 5 LSB (0-1f)
           sta BlockBufferColumnPos ;and save
           rts

;-------------------------------------------------------------------------------------
;$00 - used as counter, store for low nybble for background, ceiling byte for terrain
;$01 - used to store floor byte for terrain
;$07 - used to store terrain metatile
;$06-$07 - used to store block buffer address

BSceneDataOffsets:
      .db $00, $30, $60 

BackSceneryData: ;metatiles???
   .db $93, $00, $00, $11, $12, $12, $13, $00 ;clouds (palette 2???)
   .db $00, $51, $52, $53, $00, $00, $00, $00
   .db $00, $00, $01, $02, $02, $03, $00, $00
   .db $00, $00, $00, $00, $91, $92, $93, $00
   .db $00, $00, $00, $51, $52, $53, $41, $42
   .db $43, $00, $00, $00, $00, $00, $91, $92

   .db $97, $87, $88, $89, $99, $00, $00, $00 ;mountains and bushes
   .db $11, $12, $13, $a4, $a5, $a5, $a5, $a6
   .db $97, $98, $99, $01, $02, $03, $00, $a4
   .db $a5, $a6, $00, $11, $12, $12, $12, $13
   .db $00, $00, $00, $00, $01, $02, $02, $03
   .db $00, $a4, $a5, $a5, $a6, $00, $00, $00

   .db $11, $12, $12, $13, $00, $00, $00, $00 ;trees and fences
   .db $00, $00, $00, $9c, $00, $8b, $aa, $aa
   .db $aa, $aa, $11, $12, $13, $8b, $00, $9c
   .db $9c, $00, $00, $01, $02, $03, $11, $12
   .db $12, $13, $00, $00, $00, $00, $aa, $aa
   .db $9c, $aa, $00, $8b, $00, $01, $02, $03

BackSceneryMetatiles:
   .db $80, $83, $00 ;cloud left
   .db $81, $84, $00 ;cloud middle
   .db $82, $85, $00 ;cloud right
   .db $02, $00, $00 ;bush left
   .db $03, $00, $00 ;bush middle
   .db $04, $00, $00 ;bush right
   .db $00, $05, $06 ;mountain left
   .db $07, $06, $0a ;mountain middle
   .db $00, $08, $09 ;mountain right
   .db $4d, $00, $00 ;fence
   .db $0d, $0f, $4e ;tall tree
   .db $0e, $4e, $4e ;short tree

FSceneDataOffsets:
      .db $00, $0d, $1a

ForeSceneryData:
   .db $86, $87, $87, $87, $87, $87, $87   ;in water
   .db $87, $87, $87, $87, $69, $69

   .db $00, $00, $00, $00, $00, $45, $47   ;wall
   .db $47, $47, $47, $47, $00, $00

   .db $00, $00, $00, $00, $00, $00, $00   ;over water
   .db $00, $00, $00, $00, $86, $87

TerrainMetatiles:
      .db $69, $54, $52, $62

TerrainRenderBits:
      .db %00000000, %00000000 ;no ceiling or floor
      .db %00000000, %00011000 ;no ceiling, floor 2
      .db %00000001, %00011000 ;ceiling 1, floor 2
      .db %00000111, %00011000 ;ceiling 3, floor 2
      .db %00001111, %00011000 ;ceiling 4, floor 2
      .db %11111111, %00011000 ;ceiling 8, floor 2
      .db %00000001, %00011111 ;ceiling 1, floor 5
      .db %00000111, %00011111 ;ceiling 3, floor 5
      .db %00001111, %00011111 ;ceiling 4, floor 5
      .db %10000001, %00011111 ;ceiling 1, floor 6
      .db %00000001, %00000000 ;ceiling 1, no floor
      .db %10001111, %00011111 ;ceiling 4, floor 6
      .db %11110001, %00011111 ;ceiling 1, floor 9
      .db %11111001, %00011000 ;ceiling 1, middle 5, floor 2
      .db %11110001, %00011000 ;ceiling 1, middle 4, floor 2
      .db %11111111, %00011111 ;completely solid top to bottom

AreaParserCore:
      lda BackloadingFlag       ;check to see if we are starting right of start
         checka
      beq RenderSceneryTerrain  ;if not, go ahead and render background, foreground and terrain
      jsr ProcessAreaData       ;otherwise skip ahead and load level data

RenderSceneryTerrain:
          ldxn ++$0c
          ldan ++$00
ClrMTBuf: stax MetatileBuffer,x       ;clear out metatile buffer
          dex
          bpl ClrMTBuf
        ;jr $
          ldy BackgroundScenery      ;do we need to render the background scenery?
         checky
          beq RendFore               ;if not, skip to check the foreground
          lda CurrentPageLoc         ;otherwise check for every third page
ThirdP:   cmpn ++$03
          bmi RendBack               ;if less than three we're there
          secsub
          sbcn ++$03                   ;if 3 or more, subtract 3 and 
          bpl ThirdP                 ;do an unconditional branch
RendBack: asl                        ;move results to higher nybble
          asl
          asl
          asl
          adcy BSceneDataOffsets-1,y  ;add to it offset loaded from here
          adci CurrentColumnPos       ;add to the result our current column position
          tax
          ldax BackSceneryData,x      ;load data from sum of offsets
         checka
          beq RendFore               ;if zero, no scenery for that part
         pha
          andn ++$0f                   ;save to stack and clear high nybble
          secsub
          sbcn ++$01                   ;subtract one (because low nybble is $01-$0c)
          sta SCRATCHPAD+$00                    ;save low nybble
          asl                        ;multiply by three (shift to left and add result to old one)
          adci SCRATCHPAD+$00                    ;note that since d7 was nulled, the carry flag is always clear
          tax                        ;save as offset for background scenery metatile data
         pla                        ;get high nybble from stack, move low
          lsr
          lsr
          lsr
          lsr
          tay                        ;use as second offset (used to determine height)
          ldan ++$03                   ;use previously saved memory location for counter
          sta SCRATCHPAD+$00
SceLoop1: ldax BackSceneryMetatiles,x ;load metatile data from offset of (lsb - 1) * 3
          stay MetatileBuffer,y       ;store into buffer from offset of (msb / 16)
          inx
          iny
          cpyn ++$0b                   ;if at this location, leave loop
          beq RendFore
          deci SCRATCHPAD+$00                    ;decrement until counter expires, barring exception
          bne SceLoop1
RendFore: ldx ForegroundScenery      ;check for foreground data needed or not
         checkx
          beq RendTerr               ;if not, skip this part
          ldyx FSceneDataOffsets-1,x  ;load offset from location offset by header value, then
          ldxn ++$00                   ;reinit X
SceLoop2: lday ForeSceneryData,y      ;load data until counter expires
         checka
          beq NoFore                 ;do not store if zero found
          stax MetatileBuffer,x
NoFore:   iny
          inx
          cpxn ++$0d                   ;store up to end of metatile buffer
          bne SceLoop2
RendTerr: ldy AreaType               ;check world type for water level
         checky
          bne TerMTile               ;if not water level, skip this part
          lda WorldNumber            ;check world number, if not world number eight
          cmpn ++World8                ;then skip this part
          bne TerMTile
          ldan ++$62                   ;if set as water level and world number eight,
          jmp StoreMT                ;use castle wall metatile as terrain type
TerMTile: lday TerrainMetatiles,y     ;otherwise get appropriate metatile for area type
          ldy CloudTypeOverride      ;check for cloud type override
         checky
          beq StoreMT                ;if not set, keep value otherwise
          ldan ++$88                   ;use cloud block terrain
StoreMT:  sta SCRATCHPAD+$07                    ;store value here
          ldxn ++$00                   ;initialize X, use as metatile buffer offset
          lda TerrainControl         ;use yet another value from the header
          asl                        ;multiply by 2 and use as yet another offset
          tay
TerrLoop: lday TerrainRenderBits,y    ;get one of the terrain rendering bit data
          sta SCRATCHPAD+$00
          iny                        ;increment Y and use as offset next time around
          sty SCRATCHPAD+$01
          lda CloudTypeOverride      ;skip if value here is zero
         checka
          beq NoCloud2
          cpxn ++$00                   ;otherwise, check if we're doing the ceiling byte
          beq NoCloud2
          lda SCRATCHPAD+$00                    ;if not, mask out all but d3
          andn ++%00001000
          sta SCRATCHPAD+$00
NoCloud2: ldyn ++$00                   ;start at beginning of bitmasks
TerrBChk: lday Bitmasks,y             ;load bitmask, then perform AND on contents of first byte
          biti SCRATCHPAD+$00
          beq NextTBit               ;if not set, skip this part (do not write terrain to buffer)
          lda SCRATCHPAD+$07
          stax MetatileBuffer,x       ;load terrain type metatile number and store into buffer here
NextTBit: inx                        ;continue until end of buffer
          cpxn ++$0d
          beq RendBBuf               ;if we're at the end, break out of this loop
          lda AreaType               ;check world type for underground area
          cmpn ++$02
          bne EndUChk                ;if not underground, skip this part
          cpxn ++$0b
          bne EndUChk                ;if we're at the bottom of the screen, override
          ldan ++$54                   ;old terrain type with ground level terrain type
          sta SCRATCHPAD+$07
EndUChk:  iny                        ;increment bitmasks offset in Y
          cpyn ++$08
          bne TerrBChk               ;if not all bits checked, loop back    
          ldy SCRATCHPAD+$01
         checky
          bne TerrLoop               ;unconditional branch, use Y to load next byte
RendBBuf:

          jsr ProcessAreaData        ;do the area data loading routine now
          
        if Z80OPT
        ld a,(BlockBufferColumnPos)
        ld hl,Block_Buffer_1
        bit 4,a
        jr z,$+5
         ld hl,Block_Buffer_2
        and 0x0f
        ld c,a
        add hl,bc
        ld (SCRATCHPAD+$06),hl
        else
          lda BlockBufferColumnPos
          jsr GetBlockBufferAddr     ;get block buffer address from where we're at
        endif
          
          ldxn ++$00
          ldyn ++$00                   ;init index regs and start at beginning of smaller buffer
ChkMTLow: sty SCRATCHPAD+$00
          ldax MetatileBuffer,x       ;load stored metatile number
          andn ++%11000000             ;mask out all but 2 MSB
          asl
          rol                        ;make %xx000000 into %000000xx
          rol
          tay                        ;use as offset in Y
          ldax MetatileBuffer,x       ;reload original unmasked value here
          cmpy BlockBuffLowBounds,y   ;check for certain values depending on bits set
              cmpcy
          bcs StrBlock               ;if equal or greater, branch
          ldan ++$00                   ;if less, init value before storing
StrBlock: ldy SCRATCHPAD+$00                    ;get offset for block buffer
          stayindirect (SCRATCHPAD+$06),y                ;store value into block buffer ;$06$07 = Block_Buffer_1(2)+BlockBufferColumnPos
           ;jr $
          tya
          clc                        ;add 16 (move down one row) to offset
          adcn ++$10
          tay
          inx                        ;increment column value
          cpxn ++$0d ;13 строк по 16 блоков
              cmpcy
          bcc ChkMTLow               ;continue until we pass last row, then leave
          rts

;numbers lower than these with the same attribute bits
;will not be stored in the block buffer
BlockBuffLowBounds:
      .db $10, $51, $88, $c0

;-------------------------------------------------------------------------------------
;$00 - used to store area object identifier
;$07 - used as adder to find proper area object code

;TODO ускорить

ProcessAreaData:
        if Z80OPT3
            ld c,++$02                 ;start at the end of area object buffer
ProcADLoop: 
         if Z80OPT3ly
            ld ly,c;stx ObjectOffset ;используется в DecodeAreaData
         else
            stx ObjectOffset ;используется в DecodeAreaData
         endif
            xor a                ;reset flag
            ld (BehindAreaParserFlag),a
           ld hl,AreaDataOffset
           ld e,(hl)      ;get offset of area data pointer
	    ld hl,AreaObjectLength
	    add hl,bc
	    bit 7,(hl)   ;check area object buffer flag
            jp z,RdyDecode_AreaObjectLength_positive            ;if buffer not negative, branch, otherwise
           ld ix,(AreaData)
           add ix,de ;TODO hl? если удобно будет в DecodeAreaData
            ld a,(ix)      ;get first byte of area object
            cp ++$fd                 ;if end-of-area, skip all this crap
            jp z,RdyDecode_endofarea
           bit 7,(ix+1)      ;get second byte of area object
            jr z,Chk1Row13 ;check for page select bit (d7), branch if not set
            ld hl,AreaObjectPageSel
            inc (hl)    ;check page select
            dec (hl)
            jr nz,Chk1Row13
            inc (hl)   ;if not already set, set it now
            ld hl,AreaObjectPageLoc
            inc (hl)   ;and increment page location
Chk1Row13:  
           ;ld a,(ix)      ;reread first byte of level object
            and ++$0f                 ;mask out high nybble
            cp ++$0d                 ;row 13?
            jr nz,Chk1Row14
           bit 6,(ix+1) ;if so, reread second byte of level object
            jr nz,CheckRear ;check for d6 set (if not, object is page control)
            ld a,(AreaObjectPageSel)    ;if page select is set, do not reread
            or a
            jr nz,CheckRear
           ld a,(ix+1)                     ;if d6 not set, reread second byte
            and ++%00011111           ;mask out all but 5 LSB and store in page control
            ld (AreaObjectPageLoc),a
            ld hl,AreaObjectPageSel
            inc (hl)    ;increment page select
            jmp NextAObj
Chk1Row14:  cp ++$0e                 ;row 14?
            jr nz,CheckRear
            ld a,(BackloadingFlag)      ;check flag for saved page number and branch if set
            or a
            jr nz,RdyDecode            ;to render the object (otherwise bg might not look right)
CheckRear:  ld a,(AreaObjectPageLoc)    ;check to see if current page of level object is
            ld hl,CurrentPageLoc
            cp (hl)     ;behind current page of renderer
            jr c,SetBehind            ;if so branch
RdyDecode:  
            ;push ix
          ldayindirect (AreaData),y           ;get first byte of level object again
            call DecodeAreaData       ;do sub and do not turn on flag       ;y важен!!!
            ;pop ix
            jp ChkLength
RdyDecode_AreaObjectLength_positive:
          ldyx AreaObjOffsetBuffer,x  ;if not, get offset from buffer
            ;push ix
          ldayindirect (AreaData),y           ;get first byte of level object again
            call DecodeAreaData       ;do sub and do not turn on flag       ;y важен!!!
            ;pop ix
            jp ChkLength
SetBehind:  
            ld hl,BehindAreaParserFlag
            inc (hl) ;turn on flag if object is behind renderer
NextAObj:   
           ld hl,AreaDataOffset
           inc (hl)
           inc (hl) ;по нему рассчитывается адрес объекта на следующем проходе
           xor a
           ld (AreaObjectPageSel),a
           
RdyDecode_endofarea:
ChkLength:  
         if Z80OPT3ly
            ;ld hl,ObjectOffset
            ld c,ly;ld c,(hl)       ;get buffer offset
         else
            ld hl,ObjectOffset
            ld c,(hl)       ;get buffer offset
         endif
            ld hl,AreaObjectLength
            add hl,bc
            ld a,(hl) ;check object length for anything stored here
            rla
            jr c,ProcLoopb            ;if not, branch to handle loopback
            dec (hl)   ;otherwise decrement length or get rid of it
ProcLoopb:  dec c                      ;decrement buffer offset
            jp p,ProcADLoop           ;and loopback unless exceeded buffer
            ld a,(BehindAreaParserFlag) ;check for flag set if objects were behind renderer
            or a
            jp nz,ProcessAreaData      ;branch if true to load more level data, otherwise
            ld a,(BackloadingFlag)      ;check for flag set if starting right of page $00
            or a
            jp nz,ProcessAreaData      ;branch if true to load more level data, otherwise leave
            ret

        else ;~Z80

            ldxn ++$02                 ;start at the end of area object buffer
ProcADLoop: stx ObjectOffset
            ldan ++$00                 ;reset flag
            sta BehindAreaParserFlag
            ldy AreaDataOffset       ;get offset of area data pointer
            ldayindirect (AreaData),y         ;get first byte of area object
            cmpn ++$fd                 ;if end-of-area, skip all this crap
            beq RdyDecode
            ldax AreaObjectLength,x   ;check area object buffer flag
         checka
            bpl RdyDecode            ;if buffer not negative, branch, otherwise
            iny
            ldayindirect (AreaData),y         ;get second byte of area object
            asl                      ;check for page select bit (d7), branch if not set
            bcc Chk1Row13
            lda AreaObjectPageSel    ;check page select
         checka
            bne Chk1Row13
            inci AreaObjectPageSel    ;if not already set, set it now
            inci AreaObjectPageLoc    ;and increment page location
Chk1Row13:  dey
            ldayindirect (AreaData),y         ;reread first byte of level object
            andn ++$0f                 ;mask out high nybble
            cmpn ++$0d                 ;row 13?
            bne Chk1Row14
            iny                      ;if so, reread second byte of level object
            ldayindirect (AreaData),y
            dey                      ;decrement to get ready to read first byte
            andn ++%01000000           ;check for d6 set (if not, object is page control)
            bne CheckRear
            lda AreaObjectPageSel    ;if page select is set, do not reread
           checka
            bne CheckRear
            iny                      ;if d6 not set, reread second byte
            ldayindirect (AreaData),y
            andn ++%00011111           ;mask out all but 5 LSB and store in page control
            sta AreaObjectPageLoc
            inci AreaObjectPageSel    ;increment page select
            jmp NextAObj
Chk1Row14:  cmpn ++$0e                 ;row 14?
            bne CheckRear
            lda BackloadingFlag      ;check flag for saved page number and branch if set
         checka
            bne RdyDecode            ;to render the object (otherwise bg might not look right)
CheckRear:  lda AreaObjectPageLoc    ;check to see if current page of level object is
            cmpi CurrentPageLoc       ;behind current page of renderer
              cmpcy
            bcc SetBehind            ;if so branch
RdyDecode:  jsr DecodeAreaData       ;do sub and do not turn on flag
            jmp ChkLength
SetBehind:  inci BehindAreaParserFlag ;turn on flag if object is behind renderer
NextAObj:   
            jsr IncAreaObjOffset     ;increment buffer offset and move on
ChkLength:  ldx ObjectOffset         ;get buffer offset
            ldax AreaObjectLength,x   ;check object length for anything stored here
         checka
            bmi ProcLoopb            ;if not, branch to handle loopback
            decx AreaObjectLength,x   ;otherwise decrement length or get rid of it
ProcLoopb:  dex                      ;decrement buffer offset
            bpl ProcADLoop           ;and loopback unless exceeded buffer
            lda BehindAreaParserFlag ;check for flag set if objects were behind renderer
         checka
            bne ProcessAreaData      ;branch if true to load more level data, otherwise
            lda BackloadingFlag      ;check for flag set if starting right of page $00
         checka
            bne ProcessAreaData      ;branch if true to load more level data, otherwise leave
EndAParse:  rts

IncAreaObjOffset:
      inci AreaDataOffset    ;increment offset of level pointer
      inci AreaDataOffset
      ldan ++$00              ;reset page select
      sta AreaObjectPageSel
      rts
        endif

;x важен!
;y важен!
DecodeAreaData:
        if Z80OPT3
	if 0
		ld hl,AreaObjectLength
		add hl,bc
		ld a,(hl)    ;check current buffer flag
		or a
		bmi Chk1stB
		ldyx AreaObjOffsetBuffer,x  ;if not, get offset from buffer
Chk1stB:
		ldayindirect (AreaData),y           ;get first byte of level object again
		cp ++$fd
		ret z              ;if end of level, leave this routine
	endif
          and ++$0f                   ;otherwise, mask out low nybble
         sub 15;cp $0f                   ;row 15?
          jr z,ChkRow15ok               ;if so, keep the offset of 16
         inc a;cp $0e                   ;row 14?
          jr nz,ChkRow13
ChkRow14ok
          ld hy,a;0
	ld a,++$2e                   ;and load A with another value
	jp NormObj                ;unconditional branch
ChkRow15ok
	ld hy,16
	jp SpecObj
ChkRow12ok
	ld hy,8
	jp SpecObj
ChkRow13: inc a;cp $0d                   ;row 13?
          jr nz,ChkSRows
ChkRow13ok
	ld hy,34;sta SCRATCHPAD+$07  ;if so, load offset with 34
	iny                        ;get next byte
	ldayindirect (AreaData),y
	bit 6,a;and ++%01000000             ;mask out all but d6 (page control obj bit)
	ret z;jr z,LeavePar               ;if d6 clear, branch to leave (we handled this earlier)
	and ++%01111111             ;mask out d7
	cp ++$4b                   ;check for loop command in low nybble
	jr nz,Mask2MSB               ;(plus d6 set for object other than page control)
	inci LoopCommand            ;if loop command, set loop command flag
Mask2MSB
	and ++%00111111             ;mask out d7 and d6
	jp NormObj                ;and jump
ChkSRows:
         inc a;cp $0c                   ;row 12?
          jr z,ChkRow12ok               ;if so, keep the offset value of 8
          ld hy,0                   ;otherwise nullify value by default
	  
          iny                        ;if not, get second byte of level object
          ldayindirect (AreaData),y
          and ++%01110000             ;mask out all but d6-d4
          jr nz,LrgObj                 ;if any bits set, branch to handle large object
          ld hy,22;sta SCRATCHPAD+$07    ;otherwise set offset of 22 for small object
          ldayindirect (AreaData),y           ;reload second byte of level object
          and ++%00001111             ;mask out higher nybble and jump
          jmp NormObj
LrgObj:    sta SCRATCHPAD+$00                    ;store value here (branch for large objects)
          cp ++$70                   ;check for vertical pipe object
          jr nz,NotWPipe
          ldayindirect (AreaData),y           ;if not, reload second byte
          bit 3,a;and ++%00001000             ;mask out all but d3 (usage control bit)
          jr z,NotWPipe               ;if d3 clear, branch to get original value
          ldan ++$00                   ;otherwise, nullify value for warp pipe
           sta SCRATCHPAD+$00
NotWPipe:  lda SCRATCHPAD+$00                    ;get value and jump ahead
          jmp MoveAOId
SpecObj:  iny                        ;branch here for rows 12-15
       if Z80OPT3hy
       else
        ld a,hy
        ld (SCRATCHPAD+$07),a
       endif
          ldayindirect (AreaData),y
          andn ++%01110000             ;get next byte and mask out all but d6-d4
MoveAOId: lsr                        ;move d6-d4 to lower nybble
          lsr
          lsr
          lsr
NormObj:   sta SCRATCHPAD+$00                    ;store value here (branch for small objects and rows 13 and 14)
       if Z80OPT3hy
       else
        ld a,hy
        ld (SCRATCHPAD+$07),a
       endif
          ldax AreaObjectLength,x     ;is there something stored here already?
          or a
          jp p,RunAObj                ;if so, branch to do its particular sub
          lda AreaObjectPageLoc      ;otherwise check to see if the object we've loaded is on the
          cmpi CurrentPageLoc         ;same page as the renderer, and if so, branch
          beq InitRear
          ldy AreaDataOffset         ;if not, get old offset of level pointer
          ldayindirect (AreaData),y           ;and reload first byte
          andn ++%00001111
          cmpn ++$0e                   ;row 14?
          ret nz
          lda BackloadingFlag        ;if so, check backloading flag
         checka
          bne StrAObj                ;if set, branch to render object, else leave
	  ret
InitRear: lda BackloadingFlag        ;check backloading flag to see if it's been initialized
          or a
          jr z,BackColC               ;branch to column-wise check
          xor a;ldan ++$00                   ;if not, initialize both backloading and 
          sta BackloadingFlag        ;behind-renderer flags and leave
          sta BehindAreaParserFlag
         if Z80OPT3ly
          ld ly,a;0;sta ObjectOffset
         else
          sta ObjectOffset
         endif
LoopCmdE: ret
BackColC: ldy AreaDataOffset         ;get first byte again
          ldayindirect (AreaData),y
          and ++%11110000             ;mask out low nybble and move high to low
          rrca
          rrca
          rrca
          rrca
          cmpi CurrentColumnPos       ;is this where we're at?
          ret nz        ;if not, branch to leave
StrAObj:  
        ld hl,AreaDataOffset
	  ld a,(hl)        ;if so, load area obj offset and store in buffer
        inc (hl)
        inc (hl)
          stax AreaObjOffsetBuffer,x
        xor a
        ld (AreaObjectPageSel),a
RunAObj:
;CY=0
          ld a,(SCRATCHPAD+$00)                    ;get stored value and add offset to it
       if Z80OPT3hy
          add a,hy ;adci SCRATCHPAD+$07
       else
          adci SCRATCHPAD+$07
       endif
          call JumpEngine

        else ;~Z80

          ldax AreaObjectLength,x     ;check current buffer flag
         checka
          bmi Chk1stB
          ldyx AreaObjOffsetBuffer,x  ;if not, get offset from buffer
Chk1stB:  ldxn ++$10                   ;load offset of 16 for special row 15
          ldayindirect (AreaData),y           ;get first byte of level object again
          cmpn ++$fd
          beq EndAParse              ;if end of level, leave this routine (TODO ret z)
          andn ++$0f                   ;otherwise, mask out low nybble
          cmpn ++$0f                   ;row 15?
          beq ChkRow14               ;if so, keep the offset of 16
          ldxn ++$08                   ;otherwise load offset of 8 for special row 12
          cmpn ++$0c                   ;row 12?
          beq ChkRow14               ;if so, keep the offset value of 8
          ldxn ++$00                   ;otherwise nullify value by default
ChkRow14: 
         stx SCRATCHPAD+$07                    ;store whatever value we just loaded here
          ldx ObjectOffset           ;get object offset again
          cmpn ++$0e                   ;row 14?
          bne ChkRow13
          ldan ++$00                   ;if so, load offset with $00
          sta SCRATCHPAD+$07
          ldan ++$2e                   ;and load A with another value
         checka
          bne NormObj                ;unconditional branch
ChkRow13: cmpn ++$0d                   ;row 13?
          bne ChkSRows
          ldan ++$22                   ;if so, load offset with 34
          sta SCRATCHPAD+$07
          iny                        ;get next byte
          ldayindirect (AreaData),y
          andn ++%01000000             ;mask out all but d6 (page control obj bit)
          beq LeavePar               ;if d6 clear, branch to leave (we handled this earlier)
          ldayindirect (AreaData),y           ;otherwise, get byte again
          andn ++%01111111             ;mask out d7
          cmpn ++$4b                   ;check for loop command in low nybble
          bne Mask2MSB               ;(plus d6 set for object other than page control)
          inci LoopCommand            ;if loop command, set loop command flag
Mask2MSB: andn ++%00111111             ;mask out d7 and d6
          jmp NormObj                ;and jump
ChkSRows: cmpn ++$0c                   ;row 12-15?
              cmpcy
          bcs SpecObj

          iny                        ;if not, get second byte of level object
          ldayindirect (AreaData),y
          andn ++%01110000             ;mask out all but d6-d4
          bne LrgObj                 ;if any bits set, branch to handle large object
          ldan ++$16
          sta SCRATCHPAD+$07                    ;otherwise set offset of 24 for small object
          ldayindirect (AreaData),y           ;reload second byte of level object
          andn ++%00001111             ;mask out higher nybble and jump
          jmp NormObj
LrgObj:   sta SCRATCHPAD+$00                    ;store value here (branch for large objects)
          cmpn ++$70                   ;check for vertical pipe object
          bne NotWPipe
          ldayindirect (AreaData),y           ;if not, reload second byte
          andn ++%00001000             ;mask out all but d3 (usage control bit)
          beq NotWPipe               ;if d3 clear, branch to get original value
          ldan ++$00                   ;otherwise, nullify value for warp pipe
          sta SCRATCHPAD+$00
NotWPipe: lda SCRATCHPAD+$00                    ;get value and jump ahead
          jmp MoveAOId
SpecObj:  iny                        ;branch here for rows 12-15
          ldayindirect (AreaData),y
          andn ++%01110000             ;get next byte and mask out all but d6-d4
MoveAOId: lsr                        ;move d6-d4 to lower nybble
          lsr
          lsr
          lsr
NormObj:  sta SCRATCHPAD+$00                    ;store value here (branch for small objects and rows 13 and 14)
          ldax AreaObjectLength,x     ;is there something stored here already?
         checka
          bpl RunAObj                ;if so, branch to do its particular sub
          lda AreaObjectPageLoc      ;otherwise check to see if the object we've loaded is on the
          cmpi CurrentPageLoc         ;same page as the renderer, and if so, branch
          beq InitRear
          ldy AreaDataOffset         ;if not, get old offset of level pointer
          ldayindirect (AreaData),y           ;and reload first byte
          andn ++%00001111
          cmpn ++$0e                   ;row 14?
          bne LeavePar ;TODO ret nz
          lda BackloadingFlag        ;if so, check backloading flag
         checka
          bne StrAObj                ;if set, branch to render object, else leave
LeavePar: rts
InitRear: lda BackloadingFlag        ;check backloading flag to see if it's been initialized
         checka
          beq BackColC               ;branch to column-wise check
          ldan ++$00                   ;if not, initialize both backloading and 
          sta BackloadingFlag        ;behind-renderer flags and leave
          sta BehindAreaParserFlag
          sta ObjectOffset
LoopCmdE: rts
BackColC: ldy AreaDataOffset         ;get first byte again
          ldayindirect (AreaData),y
          andn ++%11110000             ;mask out low nybble and move high to low
          lsr
          lsr
          lsr
          lsr
          cmpi CurrentColumnPos       ;is this where we're at?
          bne LeavePar               ;if not, branch to leave
StrAObj:  lda AreaDataOffset         ;if so, load area obj offset and store in buffer
          stax AreaObjOffsetBuffer,x
          jsr IncAreaObjOffset       ;do sub to increment to next object data
RunAObj:  lda SCRATCHPAD+$00                    ;get stored value and add offset to it
          clc                        ;then use the jump engine with current contents of A
          adci SCRATCHPAD+$07
          jsr JumpEngine
        endif

;y=AreaData offset (для GetLrgObjAttrib)
;x важен в GetLrgObjAttrib
;потом x берётся из hy;SCRATCHPAD+$07

;large objects (rows $00-$0b or 00-11, d6-d4 set)
      .dw VerticalPipe         ;used by warp pipes
      .dw AreaStyleObject
      .dw RowOfBricks
      .dw RowOfSolidBlocks
      .dw RowOfCoins
      .dw ColumnOfBricks
      .dw ColumnOfSolidBlocks
      .dw VerticalPipe         ;used by decoration pipes

;objects for special row $0c or 12
      .dw Hole_Empty
      .dw PulleyRopeObject
      .dw Bridge_High
      .dw Bridge_Middle
      .dw Bridge_Low
      .dw Hole_Water
      .dw QuestionBlockRow_High
      .dw QuestionBlockRow_Low

;objects for special row $0f or 15
      .dw EndlessRope
      .dw BalancePlatRope
      .dw CastleObject
      .dw StaircaseObject
      .dw ExitPipe
      .dw FlagBalls_Residual

;small objects (rows $00-$0b or 00-11, d6-d4 all clear)
      .dw QuestionBlock     ;power-up
      .dw QuestionBlock     ;coin
      .dw QuestionBlock     ;hidden, coin
      .dw Hidden1UpBlock    ;hidden, 1-up
      .dw BrickWithItem     ;brick, power-up
      .dw BrickWithItem     ;brick, vine
      .dw BrickWithItem     ;brick, star
      .dw BrickWithCoins    ;brick, coins
      .dw BrickWithItem     ;brick, 1-up
      .dw WaterPipe
      .dw EmptyBlock
      .dw Jumpspring

;objects for special row $0d or 13 (d6 set)
      .dw IntroPipe
      .dw FlagpoleObject
      .dw AxeObj
      .dw ChainObj
      .dw CastleBridgeObj
      .dw ScrollLockObject_Warp
      .dw ScrollLockObject
      .dw ScrollLockObject
      .dw AreaFrenzy            ;flying cheep-cheeps 
      .dw AreaFrenzy            ;bullet bills or swimming cheep-cheeps
      .dw AreaFrenzy            ;stop frenzy
      .dw LoopCmdE ;ret

;object for special row $0e or 14
      .dw AlterAreaAttributes

;-------------------------------------------------------------------------------------
;(these apply to all area object subroutines in this section unless otherwise stated)
;$00 - used to store offset used to find object code
;$07 - starts with adder from area parser, used to store row offset

AlterAreaAttributes:
         ldyx AreaObjOffsetBuffer,x ;load offset for level object data saved in buffer
         iny                       ;load second byte
         ldayindirect (AreaData),y
         pha                       ;save in stack for now
         andn ++%01000000
         bne Alter2                ;branch if d6 is set
         pla
         pha                       ;pull and push offset to copy to A
         andn ++%00001111            ;mask out high nybble and store as
         sta TerrainControl        ;new terrain height type bits
         pla
         andn ++%00110000            ;pull and mask out all but d5 and d4
         lsr                       ;move bits to lower nybble and store
         lsr                       ;as new background scenery bits
         lsr
         lsr
         sta BackgroundScenery     ;then leave
         rts
Alter2:  pla
         andn ++%00000111            ;mask out all but 3 LSB
         cmpn ++$04                  ;if four or greater, set color control bits
              cmpcy
         bcc SetFore               ;and nullify foreground scenery bits
         sta BackgroundColorCtrl
         ldan ++$00
SetFore: sta ForegroundScenery     ;otherwise set new foreground scenery bits
         rts

;--------------------------------

ScrollLockObject_Warp:
         ldxn ++$04            ;load value of 4 for game text routine as default
         lda WorldNumber     ;warp zone (4-3-2), then check world number
         checka
         beq WarpNum
         inx                 ;if world number HIGH  1, increment for next warp zone (5)
         ldy AreaType        ;check area type
         dey
         bne WarpNum         ;if ground area type, increment for last warp zone
         inx                 ;(8-7-6) and move on
WarpNum: txa
         sta WarpZoneControl ;store number here to be used by warp zone routine
         jsr WriteGameText   ;print text and warp zone numbers
         ldan ++PiranhaPlant
         jsr KillEnemies     ;load identifier for piranha plants and do sub

ScrollLockObject:
      lda ScrollLock      ;invert scroll lock to turn it on
      eorn ++%00000001
      sta ScrollLock
      rts

;--------------------------------
;$00 - used to store enemy identifier in KillEnemies

KillEnemies:
           sta SCRATCHPAD+$00           ;store identifier here
           ldan ++$00
           ldxn ++$04          ;check for identifier in enemy object buffer
KillELoop: ldyx Enemy_ID,x
           cpyi SCRATCHPAD+$00           ;if not found, branch
           bne NoKillE
           stax Enemy_Flag,x  ;if found, deactivate enemy object flag
NoKillE:   dex               ;do this until all slots are checked
           bpl KillELoop
           rts

;--------------------------------

FrenzyIDData:
      .db FlyCheepCheepFrenzy, BBill_CCheep_Frenzy, Stop_Frenzy

AreaFrenzy:  ldx SCRATCHPAD+$00               ;use area object identifier bit as offset
             ldax FrenzyIDData-8,x  ;note that it starts at 8, thus weird address here
             ldyn ++$05
FreCompLoop: dey                   ;check regular slots of enemy object buffer
             bmi ExitAFrenzy       ;if all slots checked and enemy object not found, branch to store
             cmpy Enemy_ID,y    ;check for enemy object in buffer versus frenzy object
             bne FreCompLoop
             ldan ++$00              ;if enemy object already present, nullify queue and leave
ExitAFrenzy: sta EnemyFrenzyQueue  ;store enemy into frenzy queue
             rts

;--------------------------------
;$06 - used by MushroomLedge to store length

AreaStyleObject:
      lda AreaStyle        ;load level object style and jump to the right sub
      jsr JumpEngine 
      .dw TreeLedge        ;also used for cloud type levels
      .dw MushroomLedge
      .dw BulletBillCannon

TreeLedge:
          jsr GetLrgObjAttrib     ;get row and length of green ledge
          ldax AreaObjectLength,x  ;check length counter for expiration
         checka
          beq EndTreeL   
          bpl MidTreeL
          tya
          stax AreaObjectLength,x  ;store lower nybble into buffer flag as length of ledge
          lda CurrentPageLoc
          orai CurrentColumnPos    ;are we at the start of the level?
          beq MidTreeL
          ldan ++$16                ;render start of tree ledge
          jmp NoUnder
MidTreeL: 
        if Z80OPT3hy
          ld c,hy;ldx SCRATCHPAD+$07
        else
          ldx SCRATCHPAD+$07
        endif
          ldan ++$17                ;render middle of tree ledge
          stax MetatileBuffer,x    ;note that this is also used if ledge position is
          ldan ++$4c                ;at the start of level for continuous effect
          jmp AllUnder            ;now render the part underneath
EndTreeL: ldan ++$18                ;render end of tree ledge
          jmp NoUnder

MushroomLedge:
          jsr ChkLrgObjLength        ;get shroom dimensions
          sty SCRATCHPAD+$06                    ;store length here for now
          bcc EndMushL
          ldax AreaObjectLength,x     ;divide length by 2 and store elsewhere
          lsr
          stax MushroomLedgeHalfLen,x
          ldan ++$19                   ;render start of mushroom
          jmp NoUnder
EndMushL: ldan ++$1b                   ;if at the end, render end of mushroom
          ldyx AreaObjectLength,x
         checky
          beq NoUnder
          ldax MushroomLedgeHalfLen,x ;get divided length and store where length
          sta SCRATCHPAD+$06                    ;was stored originally
        if Z80OPT3hy
          ld c,hy;ldx SCRATCHPAD+$07
        else
          ldx SCRATCHPAD+$07
        endif
          ldan ++$1a
          stax MetatileBuffer,x       ;render middle of mushroom
          cpyi SCRATCHPAD+$06                    ;are we smack dab in the center?
          bne MushLExit              ;if not, branch to leave
          inx
          ldan ++$4f
          stax MetatileBuffer,x       ;render stem top of mushroom underneath the middle
          ldan ++$50
AllUnder: inx
          ldyn ++$0f                   ;set $0f to render all way down
          jmp RenderUnderPart       ;now render the stem of mushroom
NoUnder:  
        if Z80OPT3hy
          ld c,hy;ldx SCRATCHPAD+$07     ;load row of ledge
        else
          ldx SCRATCHPAD+$07                    ;load row of ledge
        endif
          ldyn ++$00                   ;set 0 for no bottom on this part
          jmp RenderUnderPart

;--------------------------------

;tiles used by pulleys and rope object
PulleyRopeMetatiles:
      .db $42, $41, $43

PulleyRopeObject:
           jsr ChkLrgObjLength       ;get length of pulley/rope object
           ldyn ++$00                  ;initialize metatile offset
           bcs RenderPul             ;if starting, render left pulley
           iny
           ldax AreaObjectLength,x    ;if not at the end, render rope
         checka
           bne RenderPul
           iny                       ;otherwise render right pulley
RenderPul: lday PulleyRopeMetatiles,y
           sta MetatileBuffer        ;render at the top of the screen
MushLExit: rts                       ;and leave

;--------------------------------
;$06 - used to store upper limit of rows for CastleObject

CastleMetatiles:
      .db $00, $45, $45, $45, $00
      .db $00, $48, $47, $46, $00
      .db $45, $49, $49, $49, $45
      .db $47, $47, $4a, $47, $47
      .db $47, $47, $4b, $47, $47
      .db $49, $49, $49, $49, $49
      .db $47, $4a, $47, $4a, $47
      .db $47, $4b, $47, $4b, $47
      .db $47, $47, $47, $47, $47
      .db $4a, $47, $4a, $47, $4a
      .db $4b, $47, $4b, $47, $4b

CastleObject:
            jsr GetLrgObjAttrib      ;save lower nybble as starting row
        if Z80OPT3hy
          ld hy,e;  sty SCRATCHPAD+$07                  ;if starting row is above $0a, game will crash!!!
        else
            sty SCRATCHPAD+$07                  ;if starting row is above $0a, game will crash!!!
        endif
            ldyn ++$04
            jsr ChkLrgObjFixedLength ;load length of castle if not already loaded
            txa                  
            pha                      ;save obj buffer offset to stack
            ldyx AreaObjectLength,x   ;use current length as offset for castle data
        if Z80OPT3hy
          ld c,hy;ldx SCRATCHPAD+$07     ;begin at starting row
        else
            ldx SCRATCHPAD+$07                  ;begin at starting row
        endif
            ldan ++$0b
            sta SCRATCHPAD+$06                  ;load upper limit of number of rows to print
CRendLoop:  lday CastleMetatiles,y    ;load current byte using offset
            stax MetatileBuffer,x
            inx                      ;store in buffer and increment buffer offset
            lda SCRATCHPAD+$06
         checka
            beq ChkCFloor            ;have we reached upper limit yet?
            iny                      ;if not, increment column-wise
            iny                      ;to byte in next row
            iny
            iny
            iny
            deci SCRATCHPAD+$06                  ;move closer to upper limit
ChkCFloor:  cpxn ++$0b                 ;have we reached the row just before floor?
            bne CRendLoop            ;if not, go back and do another row
            pla
            tax                      ;get obj buffer offset from before
            lda CurrentPageLoc
         checka
            beq ExitCastle           ;if we're at page 0, we do not need to do anything else
            ldax AreaObjectLength,x   ;check length
            cmpn ++$01                 ;if length almost about to expire, put brick at floor
            beq PlayerStop
        if Z80OPT3hy
         if Z80OPT3hybug
           ld c,hy;ldy SCRATCHPAD+$07                  ;check starting row for tall castle ($00) ;в релизе включать не надо!
         else
           ld e,hy;ldy SCRATCHPAD+$07                  ;check starting row for tall castle ($00)
         endif
        else
            ldy SCRATCHPAD+$07                  ;check starting row for tall castle ($00)
        endif
         checky
            bne NotTall
            cmpn ++$03                 ;if found, then check to see if we're at the second column
            beq PlayerStop
NotTall:    cmpn ++$02                 ;if not tall castle, check to see if we're at the third column
            bne ExitCastle           ;if we aren't and the castle is tall, don't create flag yet
            jsr GetAreaObjXPosition  ;otherwise, obtain and save horizontal pixel coordinate
            pha
            jsr FindEmptyEnemySlot   ;find an empty place on the enemy object buffer
            pla
            stax Enemy_X_Position,x   ;then write horizontal coordinate for star flag
            lda CurrentPageLoc
            stax Enemy_PageLoc,x      ;set page location for star flag
            ldan ++$01
            stax Enemy_Y_HighPos,x    ;set vertical high byte
            stax Enemy_Flag,x         ;set flag for buffer
            ldan ++$90
            stax Enemy_Y_Position,x   ;set vertical coordinate
            ldan ++StarFlagObject      ;set star flag value in buffer itself
            stax Enemy_ID,x
            rts
PlayerStop: ldyn ++$52                 ;put brick at floor to stop player at end of level
            sty MetatileBuffer+10    ;this is only done if we're on the second column
ExitCastle: rts

;--------------------------------

WaterPipe:
      jsr GetLrgObjAttrib     ;get row and lower nybble
      ldyx AreaObjectLength,x  ;get length (residual code, water pipe is 1 col thick)
        if Z80OPT3hy
      ld c,hy;ldx SCRATCHPAD+$07                 ;get row
        else
      ldx SCRATCHPAD+$07                 ;get row
        endif
      ldan ++$6b
      stax MetatileBuffer,x    ;draw something here and below it
      ldan ++$6c
      stax MetatileBuffer+1,x
      rts

;--------------------------------
;$05 - used to store length of vertical shaft in RenderSidewaysPipe
;$06 - used to store leftover horizontal length in RenderSidewaysPipe
; and vertical length in VerticalPipe and GetPipeHeight

IntroPipe:
               ldyn ++$03                 ;check if length set, if not set, set it
               jsr ChkLrgObjFixedLength
               ldyn ++$0a                 ;set fixed value and render the sideways part
               jsr RenderSidewaysPipe
               bcs NoBlankP             ;if carry flag set, not time to draw vertical pipe part
               ldxn ++$06                 ;blank everything above the vertical pipe part
VPipeSectLoop: ldan ++$00                 ;all the way to the top of the screen
               stax MetatileBuffer,x     ;because otherwise it will look like exit pipe
               dex
               bpl VPipeSectLoop
               lday VerticalPipeData,y   ;draw the end of the vertical pipe part
               sta MetatileBuffer+7
NoBlankP:      rts

SidePipeShaftData:
      .db $15, $14  ;used to control whether or not vertical pipe shaft
      .db $00, $00  ;is drawn, and if so, controls the metatile number
SidePipeTopPart:
      .db $15, $1e  ;top part of sideways part of pipe
      .db $1d, $1c
SidePipeBottomPart: 
      .db $15, $21  ;bottom part of sideways part of pipe
      .db $20, $1f

ExitPipe:
      ldyn ++$03                 ;check if length set, if not set, set it
      jsr ChkLrgObjFixedLength
      jsr GetLrgObjAttrib      ;get vertical length, then plow on through RenderSidewaysPipe

RenderSidewaysPipe:
              dey                       ;decrement twice to make room for shaft at bottom
              dey                       ;and store here for now as vertical length
              sty SCRATCHPAD+$05
              ldyx AreaObjectLength,x    ;get length left over and store here
              sty SCRATCHPAD+$06
              ldx SCRATCHPAD+$05                   ;get vertical length plus one, use as buffer offset
              inx
              lday SidePipeShaftData,y   ;check for value $00 based on horizontal offset
              cmpn ++$00
	       cmpcy
              beq DrawSidePart          ;if found, do not draw the vertical pipe shaft (CY6502=1)
              ldxn ++$00
              ldy SCRATCHPAD+$05                   ;init buffer offset and get vertical length
              jsr RenderUnderPart       ;and render vertical shaft using tile number in A
              clc                       ;clear carry flag to be used by IntroPipe
DrawSidePart: 
		push af
		ldy SCRATCHPAD+$06                   ;render side pipe part at the bottom
              lday SidePipeTopPart,y
              stax MetatileBuffer,x      ;note that the pipe parts are stored
              lday SidePipeBottomPart,y  ;backwards horizontally
              stax MetatileBuffer+1,x
	       pop af
              rts

VerticalPipeData:
      .db $11, $10 ;used by pipes that lead somewhere
      .db $15, $14
      .db $13, $12 ;used by decoration pipes
      .db $15, $14

VerticalPipe:
          jsr GetPipeHeight
          lda SCRATCHPAD+$00                  ;check to see if value was nullified earlier
         checka
          beq WarpPipe             ;(if d3, the usage control bit of second byte, was set)
          iny
          iny
          iny
          iny                      ;add four if usage control bit was not set
WarpPipe: tya                      ;save value in stack
          pha
          lda AreaNumber
          orai WorldNumber          ;if at world 1-1, do not add piranha plant ever
	if NOPIRANHAPLANT
	xor a
	endif
          beq DrawPipe
          ldyx AreaObjectLength,x   ;if on second column of pipe, branch
         checky
          beq DrawPipe             ;(because we only need to do this once)
          jsr FindEmptyEnemySlot   ;check for an empty moving data buffer space
          bcs DrawPipe             ;if not found, too many enemies, thus skip
          jsr GetAreaObjXPosition  ;get horizontal pixel coordinate
          clc
          adcn ++$08                 ;add eight to put the piranha plant in the center
         push af
          stax Enemy_X_Position,x   ;store as enemy's horizontal coordinate
          lda CurrentPageLoc       ;add carry to current page number
         ld h,a
         pop af
         ld a,h
          adcn ++$00
          stax Enemy_PageLoc,x      ;store as enemy's page coordinate
          ldan ++$01
          stax Enemy_Y_HighPos,x
          stax Enemy_Flag,x         ;activate enemy flag
          jsr GetAreaObjYPosition  ;get piranha plant's vertical coordinate and store here
          stax Enemy_Y_Position,x
          ldan ++PiranhaPlant        ;write piranha plant's value into buffer
          stax Enemy_ID,x
          jsr InitPiranhaPlant
DrawPipe: pla                      ;get value saved earlier and use as Y
          tay
        if Z80OPT3hy
          ld c,hy;ldx SCRATCHPAD+$07                  ;get buffer offset
        else
          ldx SCRATCHPAD+$07                  ;get buffer offset
        endif
          lday VerticalPipeData,y   ;draw the appropriate pipe with the Y we loaded earlier
          stax MetatileBuffer,x     ;render the top of the pipe
          inx
          lday VerticalPipeData+2,y ;render the rest of the pipe
          ldy SCRATCHPAD+$06                  ;subtract one from length and render the part underneath
          dey
          jmp RenderUnderPart
      
GetPipeHeight:
      ldyn ++$01       ;check for length loaded, if not, load
      jsr ChkLrgObjFixedLength ;pipe length of 2 (horizontal)
      jsr GetLrgObjAttrib
      tya            ;get saved lower nybble as height
      andn ++$07       ;save only the three lower bits as
      sta SCRATCHPAD+$06        ;vertical length, then load Y with
      ldyx AreaObjectLength,x    ;length left over
      rts

FindEmptyEnemySlot:
              ldxn ++$00          ;start at first enemy slot
EmptyChkLoop: clc               ;clear carry flag by default
              ldax Enemy_Flag,x  ;check enemy buffer for nonzero
         checka
              beq ExitEmptyChk  ;if zero, leave
              inx
              cpxn ++$05          ;if nonzero, check next value
              bne EmptyChkLoop
ExitEmptyChk: rts               ;if all values nonzero, carry flag is set

;--------------------------------

Hole_Water:
      jsr ChkLrgObjLength   ;get low nybble and save as length
      ldan ++$86              ;render waves
      sta MetatileBuffer+10
      ldxn ++$0b
      ldyn ++$01              ;now render the water underneath
      ldan ++$87
      jmp RenderUnderPart

;--------------------------------

QuestionBlockRow_High:
      ldan ++$03    ;start on the fourth row
      jr QuestionBlockRow_go;.db $2c     ;BIT instruction opcode

QuestionBlockRow_Low:
      ldan ++$07             ;start on the eighth row
QuestionBlockRow_go
      pha                  ;save whatever row to the stack for now
      jsr ChkLrgObjLength  ;get low nybble and save as length
      pla
      tax                  ;render question boxes with coins
      ldan ++$c0
      stax MetatileBuffer,x
      rts

;--------------------------------

Bridge_High:
      ldan ++$06  ;start on the seventh row from top of screen
      jr Bridge_go;.db $2c   ;BIT instruction opcode

Bridge_Middle:
      ldan ++$07  ;start on the eighth row
      jr Bridge_go;.db $2c   ;BIT instruction opcode

Bridge_Low:
      ldan ++$09             ;start on the tenth row
Bridge_go
      pha                  ;save whatever row to the stack for now
      jsr ChkLrgObjLength  ;get low nybble and save as length
      pla
      tax                  ;render bridge railing
      ldan ++$0b
      stax MetatileBuffer,x
      inx
      ldyn ++$00             ;now render the bridge itself
      ldan ++$63
      jmp RenderUnderPart

;--------------------------------

FlagBalls_Residual:
      jsr GetLrgObjAttrib  ;get low nybble from object byte
      ldxn ++$02             ;render flag balls on third row from top
      ldan ++$6d             ;of screen downwards based on low nybble
      jmp RenderUnderPart

;--------------------------------

FlagpoleObject:
      ldan ++$24                 ;render flagpole ball on top
      sta MetatileBuffer
      ldxn ++$01                 ;now render the flagpole shaft
      ldyn ++$08
      ldan ++$25
      jsr RenderUnderPart
      ldan ++$61                 ;render solid block at the bottom
      sta MetatileBuffer+10
      jsr GetAreaObjXPosition
      secsub                      ;get pixel coordinate of where the flagpole is,
      sbcn ++$08                 ;subtract eight pixels and use as horizontal
      sta Enemy_X_Position+5   ;coordinate for the flag
      lda CurrentPageLoc
      sbcn ++$00                 ;subtract borrow from page location and use as
      sta Enemy_PageLoc+5      ;page location for the flag
      ldan ++$30
      sta Enemy_Y_Position+5   ;set vertical coordinate for flag
      ldan ++$b0
      sta FlagpoleFNum_Y_Pos   ;set initial vertical coordinate for flagpole's floatey number
      ldan ++FlagpoleFlagObject
      sta Enemy_ID+5           ;set flag identifier, note that identifier and coordinates
      inci Enemy_Flag+5         ;use last space in enemy object buffer
      rts

;--------------------------------

EndlessRope:
      ldxn ++$00       ;render rope from the top to the bottom of screen
      ldyn ++$0f
      jmp DrawRope

BalancePlatRope:
          txa                 ;save object buffer offset for now
          pha
          ldxn ++$01            ;blank out all from second row to the bottom
          ldyn ++$0f            ;with blank used for balance platform rope
          ldan ++$44
          jsr RenderUnderPart
          pla                 ;get back object buffer offset
          tax
          jsr GetLrgObjAttrib ;get vertical length from lower nybble
          ldxn ++$01
DrawRope: ldan ++$40            ;render the actual rope
          jmp RenderUnderPart

;--------------------------------

CoinMetatileData:
      .db $c3, $c2, $c2, $c2

RowOfCoins:
      ldy AreaType            ;get area type
      lday CoinMetatileData,y  ;load appropriate coin metatile
      jmp GetRow

;--------------------------------

C_ObjectRow:
      .db $06, $07, $08

C_ObjectMetatile:
      .db $c5, $0c, $89

CastleBridgeObj:
      ldyn ++$0c                  ;load length of 13 columns
      jsr ChkLrgObjFixedLength
      jmp ChainObj

AxeObj:
      ldan ++$08                  ;load bowser's palette into sprite portion of palette
      sta VRAM_Buffer_AddrCtrl

ChainObj:
      ldy SCRATCHPAD+$00                   ;get value loaded earlier from decoder
      ldxy C_ObjectRow-2,y       ;get appropriate row and metatile for object
      lday C_ObjectMetatile-2,y
      jmp ColObj

EmptyBlock:
        jsr GetLrgObjAttrib  ;get row location
       if Z80OPT3hy
        ld c,hy;ldx SCRATCHPAD+$07
       else
        ldx SCRATCHPAD+$07
       endif
        ldan ++$c4
ColObj: ldyn ++$00             ;column length of 1
        jmp RenderUnderPart

;--------------------------------

SolidBlockMetatiles:
      .db $69, $61, $61, $62

BrickMetatiles:
      .db $22, $51, $52, $52
      .db $88 ;used only by row of bricks object

RowOfBricks:
            ldy AreaType           ;load area type obtained from area offset pointer
            lda CloudTypeOverride  ;check for cloud type override
         checka
            beq DrawBricks
            ldyn ++$04               ;if cloud type, override area type
DrawBricks: lday BrickMetatiles,y   ;get appropriate metatile
            jmp GetRow             ;and go render it

RowOfSolidBlocks:
         ldy AreaType               ;load area type obtained from area offset pointer
         lday SolidBlockMetatiles,y  ;get metatile
GetRow:  pha                        ;store metatile here
         jsr ChkLrgObjLength        ;get row number, load length
DrawRow: 
       if Z80OPT3hy
         ld c,hy;ldx SCRATCHPAD+$07
       else
         ldx SCRATCHPAD+$07
       endif
         ldyn ++$00                   ;set vertical height of 1
         pla
         jmp RenderUnderPart        ;render object

ColumnOfBricks:
      ldy AreaType          ;load area type obtained from area offset
      lday BrickMetatiles,y  ;get metatile (no cloud override as for row)
      jmp GetRow2

ColumnOfSolidBlocks:
         ldy AreaType               ;load area type obtained from area offset
         lday SolidBlockMetatiles,y  ;get metatile
GetRow2: pha                        ;save metatile to stack for now
         jsr GetLrgObjAttrib        ;get length and row
         pla                        ;restore metatile
       if Z80OPT3hy
         ld c,hy;ldx SCRATCHPAD+$07                    ;get starting row
       else
         ldx SCRATCHPAD+$07                    ;get starting row
       endif
         jmp RenderUnderPart        ;now render the column

;--------------------------------

BulletBillCannon:
             jsr GetLrgObjAttrib      ;get row and length of bullet bill cannon
       if Z80OPT3hy
             ld c,hy;ldx SCRATCHPAD+$07                  ;start at first row
       else
             ldx SCRATCHPAD+$07                  ;start at first row
       endif
             ldan ++$64                 ;render bullet bill cannon
             stax MetatileBuffer,x
             inx
             dey                      ;done yet?
             bmi SetupCannon
             ldan ++$65                 ;if not, render middle part
             stax MetatileBuffer,x
             inx
             dey                      ;done yet?
             bmi SetupCannon
             ldan ++$66                 ;if not, render bottom until length expires
             jsr RenderUnderPart
SetupCannon: ldx Cannon_Offset        ;get offset for data used by cannons and whirlpools
             jsr GetAreaObjYPosition  ;get proper vertical coordinate for cannon
             stax Cannon_Y_Position,x  ;and store it here
             lda CurrentPageLoc
             stax Cannon_PageLoc,x     ;store page number for cannon here
             jsr GetAreaObjXPosition  ;get proper horizontal coordinate for cannon
             stax Cannon_X_Position,x  ;and store it here
             inx
             cpxn ++$06                 ;increment and check offset
              cmpcy
             bcc StrCOffset           ;if not yet reached sixth cannon, branch to save offset
             ldxn ++$00                 ;otherwise initialize it
StrCOffset:  stx Cannon_Offset        ;save new offset and leave
             rts

;--------------------------------

StaircaseHeightData:
      .db $07, $07, $06, $05, $04, $03, $02, $01, $00

StaircaseRowData:
      .db $03, $03, $04, $05, $06, $07, $08, $09, $0a

StaircaseObject:
           jsr ChkLrgObjLength       ;check and load length
           bcc NextStair             ;if length already loaded, skip init part
           ldan ++$09                  ;start past the end for the bottom
           sta StaircaseControl      ;of the staircase
NextStair: deci StaircaseControl      ;move onto next step (or first if starting)
           ldy StaircaseControl
           ldxy StaircaseRowData,y    ;get starting row and height to render
           lday StaircaseHeightData,y
           tay
           ldan ++$61                  ;now render solid block staircase
           jmp RenderUnderPart

;--------------------------------

Jumpspring:
      jsr GetLrgObjAttrib
      jsr FindEmptyEnemySlot      ;find empty space in enemy object buffer
      jsr GetAreaObjXPosition     ;get horizontal coordinate for jumpspring
      stax Enemy_X_Position,x      ;and store
      lda CurrentPageLoc          ;store page location of jumpspring
      stax Enemy_PageLoc,x
      jsr GetAreaObjYPosition     ;get vertical coordinate for jumpspring
      stax Enemy_Y_Position,x      ;and store
      stax Jumpspring_FixedYPos,x  ;store as permanent coordinate here
      ldan ++JumpspringObject
      stax Enemy_ID,x              ;write jumpspring object to enemy object buffer
      ldyn ++$01
      styx Enemy_Y_HighPos,x       ;store vertical high byte
      incx Enemy_Flag,x            ;set flag for enemy object buffer
       if Z80OPT3hy
      ld c,hy;ldx SCRATCHPAD+$07
       else
      ldx SCRATCHPAD+$07
       endif
      ldan ++$67                    ;draw metatiles in two rows where jumpspring is
      stax MetatileBuffer,x
      ldan ++$68
      stax MetatileBuffer+1,x
      rts

;--------------------------------
;$07 - used to save ID of brick object

Hidden1UpBlock:
      lda Hidden1UpFlag  ;if flag not set, do not render object
         checka
      beq ExitDecBlock
      ldan ++$00           ;if set, init for the next one
      sta Hidden1UpFlag
      jmp BrickWithItem  ;jump to code shared with unbreakable bricks

QuestionBlock:
      jsr GetAreaObjectID ;get value from level decoder routine
      jmp DrawQBlk        ;go to render it

BrickWithCoins:
      ldan ++$00                 ;initialize multi-coin timer flag
      sta BrickCoinTimerFlag

BrickWithItem:
          jsr GetAreaObjectID         ;save area object ID
       if Z80OPT3hy
          ld hy,e;sty SCRATCHPAD+$07              
       else
          sty SCRATCHPAD+$07              
       endif
          ldan ++$00                    ;load default adder for bricks with lines
          ldy AreaType                ;check level type for ground level
          dey
          beq BWithL                  ;if ground type, do not start with 5
          ldan ++$05                    ;otherwise use adder for bricks without lines
BWithL:   
       if Z80OPT3hy
          ;clc                         ;add object ID to adder
          add a,hy;adci SCRATCHPAD+$07
       else
          clc                         ;add object ID to adder
          adci SCRATCHPAD+$07
       endif
          tay                         ;use as offset for metatile
DrawQBlk: lday BrickQBlockMetatiles,y  ;get appropriate metatile for brick (question block
          pha                         ;if branched to here from question block routine)
          jsr GetLrgObjAttrib         ;get row from location byte
          jmp DrawRow                 ;now render the object

GetAreaObjectID:
              lda SCRATCHPAD+$00    ;get value saved from area parser routine
              secsub
              sbcn ++$00   ;possibly residual code
              tay        ;save to Y
ExitDecBlock: rts

;--------------------------------

HoleMetatiles:
      .db $87, $00, $00, $00

Hole_Empty:
            jsr ChkLrgObjLength          ;get lower nybble and save as length
            bcc NoWhirlP                 ;skip this part if length already loaded
            lda AreaType                 ;check for water type level
         checka
            bne NoWhirlP                 ;if not water type, skip this part
            ldx Whirlpool_Offset         ;get offset for data used by cannons and whirlpools
            jsr GetAreaObjXPosition      ;get proper vertical coordinate of where we're at
            secsub
            sbcn ++$10                     ;subtract 16 pixels
           push af
            stax Whirlpool_LeftExtent,x   ;store as left extent of whirlpool
           pop af
            lda CurrentPageLoc           ;get page location of where we're at
            sbcn ++$00                     ;subtract borrow
            stax Whirlpool_PageLoc,x      ;save as page location of whirlpool
            iny
            iny                          ;increment length by 2
            tya
            asl                          ;multiply by 16 to get size of whirlpool
            asl                          ;note that whirlpool will always be
            asl                          ;two blocks bigger than actual size of hole
            asl                          ;and extend one block beyond each edge
            stax Whirlpool_Length,x       ;save size of whirlpool here
            inx
            cpxn ++$05                     ;increment and check offset
              cmpcy
            bcc StrWOffset               ;if not yet reached fifth whirlpool, branch to save offset
            ldxn ++$00                     ;otherwise initialize it
StrWOffset: stx Whirlpool_Offset         ;save new offset here
NoWhirlP:   ldx AreaType                 ;get appropriate metatile, then
            ldax HoleMetatiles,x          ;render the hole proper
            ldxn ++$08
            ldyn ++$0f                     ;start at ninth row and go to bottom, run RenderUnderPart

;--------------------------------

RenderUnderPart:
             sty AreaObjectHeight  ;store vertical length to render
             ldyx MetatileBuffer,x  ;check current spot to see if there's something
         checky
             beq DrawThisRow       ;we need to keep, if nothing, go ahead
             cpyn ++$17
             beq WaitOneRow        ;if middle part (tree ledge), wait until next row
             cpyn ++$1a
             beq WaitOneRow        ;if middle part (mushroom ledge), wait until next row
             cpyn ++$c0
             beq DrawThisRow       ;if question block w/ coin, overwrite
             cpyn ++$c0
              cmpcy
             bcs WaitOneRow        ;if any other metatile with palette 3, wait until next row
             cpyn ++$54
             bne DrawThisRow       ;if cracked rock terrain, overwrite
             cmpn ++$50
             beq WaitOneRow        ;if stem top of mushroom, wait until next row
DrawThisRow: stax MetatileBuffer,x  ;render contents of A from routine that called this
WaitOneRow:  inx
             cpxn ++$0d              ;stop rendering if we're at the bottom of the screen
              cmpcy
             bcs ExitUPartR
             ldy AreaObjectHeight  ;decrement, and stop rendering if there is no more length
             dey
             bpl RenderUnderPart
ExitUPartR:  rts

;--------------------------------

ChkLrgObjLength:
        jsr GetLrgObjAttrib     ;get row location and size (length if branched to from here)

ChkLrgObjFixedLength:
        ldax AreaObjectLength,x  ;check for set length counter
        clc                     ;clear carry flag for not just starting
         checka
        bpl LenSet              ;if counter not set, load it, otherwise leave alone
        tya                     ;save length into length counter
        stax AreaObjectLength,x
        sec                     ;set carry flag if just starting
LenSet: rts


GetLrgObjAttrib:
;x=???
;y=AreaData offset
      ldyx AreaObjOffsetBuffer,x ;get offset saved from area obj decoding routine
      ldayindirect (AreaData),y          ;get first byte of level object
      andn ++%00001111
       if Z80OPT3hy
      ld hy,a;sta SCRATCHPAD+$07                   ;save row location
       else
      sta SCRATCHPAD+$07                   ;save row location
       endif
      iny
      ldayindirect (AreaData),y          ;get next byte, save lower nybble (length or height)
      andn ++%00001111            ;as Y, then leave
      tay
      rts

;--------------------------------

GetAreaObjXPosition:
      lda CurrentColumnPos    ;multiply current offset where we're at by 16
      asl                     ;to obtain horizontal pixel coordinate
      asl
      asl
      asl
      rts

;--------------------------------

GetAreaObjYPosition:
       if Z80OPT3hy
      ld a,hy;lda SCRATCHPAD+$07
       else
      lda SCRATCHPAD+$07  
       endif
      asl     ;multiply value by 16
      asl      ;this will give us the proper vertical pixel coordinate
      asl
      asl
      clc
      adcn ++32  ;add 32 pixels for the status bar
      rts

;-------------------------------------------------------------------------------------
;$06-$07 - used to store block buffer address used as indirect

        if Z80OPT
        else
BlockBufferAddr:
      .db LOW Block_Buffer_1, LOW Block_Buffer_2
      .db HIGH Block_Buffer_1, HIGH Block_Buffer_2

;a=%000hllll
;out: $06$07 = BlockBufferAddr[i]+%llll
GetBlockBufferAddr:
     pha                      ;take value of A, save
      lsr                      ;move high nybble to low
      lsr
      lsr
      lsr
      tay                      ;use nybble as pointer to high byte
      lday BlockBufferAddr+2,y  ;of indirect here
      sta SCRATCHPAD+$07
     pla
      andn ++%00001111           ;pull from stack, mask out high nybble
      clc
      adcy BlockBufferAddr,y    ;add to low byte
      sta SCRATCHPAD+$06                  ;store here and leave
      rts
        endif

;-------------------------------------------------------------------------------------

;unused space
      .db $ff, $ff

;-------------------------------------------------------------------------------------

AreaDataOfsLoopback:
      .db $12, $36, $0e, $0e, $0e, $32, $32, $32, $0a, $26, $40

;-------------------------------------------------------------------------------------

LoadAreaPointer:
             jsr FindAreaPointer  ;find it and store it here
             sta AreaPointer
GetAreaType: andn ++%01100000       ;mask out all but d6 and d5
             asl
             rol
             rol
             rol                  ;make %0xx00000 into %000000xx
             sta AreaType         ;save 2 MSB as area type
             rts

FindAreaPointer:
      ldy WorldNumber        ;load offset from world variable
      lday WorldAddrOffsets,y
      clc                    ;add area number used to find data
      adci AreaNumber
      tay
      lday AreaAddrOffsets,y  ;from there we have our area pointer
      rts


GetAreaDataAddrs:
            lda AreaPointer          ;use 2 MSB for Y
            jsr GetAreaType
            tay
            lda AreaPointer          ;mask out all but 5 LSB
            andn ++%00011111
            sta AreaAddrsLOffset     ;save as low offset
            lday EnemyAddrHOffsets,y  ;load base value with 2 altered MSB,
            clc                      ;then add base value to 5 LSB, result
            adci AreaAddrsLOffset     ;becomes offset for level data
            tay
            lday EnemyDataAddrLow,y   ;use offset to load pointer
            sta EnemyDataLow
            lday EnemyDataAddrHigh,y
            sta EnemyDataHigh
            ldy AreaType             ;use area type as offset
            lday AreaDataHOffsets,y   ;do the same thing but with different base value
            clc
            adci AreaAddrsLOffset        
            tay
            lday AreaDataAddrLow,y    ;use this offset to load another pointer
            sta AreaDataLow
            lday AreaDataAddrHigh,y
            sta AreaDataHigh
            ldyn ++$00                 ;load first byte of header
            ldayindirect (AreaData),y     
            pha                      ;save it to the stack for now
            andn ++%00000111           ;save 3 LSB for foreground scenery or bg color control
            cmpn ++$04
              cmpcy
            bcc StoreFore
            sta BackgroundColorCtrl  ;if 4 or greater, save value here as bg color control
            ldan ++$00
StoreFore:  sta ForegroundScenery    ;if less, save value here as foreground scenery
            pla                      ;pull byte from stack and push it back
            pha
            andn ++%00111000           ;save player entrance control bits
            lsr                      ;shift bits over to LSBs
            lsr
            lsr
            sta PlayerEntranceCtrl       ;save value here as player entrance control
            pla                      ;pull byte again but do not push it back
            andn ++%11000000           ;save 2 MSB for game timer setting
            clc
            rol                      ;rotate bits over to LSBs
            rol
            rol
            sta GameTimerSetting     ;save value here as game timer setting
            iny
            ldayindirect (AreaData),y         ;load second byte of header
            pha                      ;save to stack
            andn ++%00001111           ;mask out all but lower nybble
            sta TerrainControl
            pla                      ;pull and push byte to copy it to A
            pha
            andn ++%00110000           ;save 2 MSB for background scenery type
            lsr
            lsr                      ;shift bits to LSBs
            lsr
            lsr
            sta BackgroundScenery    ;save as background scenery
            pla           
            andn ++%11000000
            clc
            rol                      ;rotate bits over to LSBs
            rol
            rol
            cmpn ++%00000011           ;if set to 3, store here
            bne StoreStyle           ;and nullify other value
            sta CloudTypeOverride    ;otherwise store value in other place
            ldan ++$00
StoreStyle: sta AreaStyle
            lda AreaDataLow          ;increment area data address by 2 bytes
            clc
            adcn ++$02
            sta AreaDataLow
            lda AreaDataHigh
            adcn ++$00
            sta AreaDataHigh
            rts

;-------------------------------------------------------------------------------------
;GAME LEVELS DATA

WorldAddrOffsets:
      .db World1Areas-AreaAddrOffsets, World2Areas-AreaAddrOffsets
      .db World3Areas-AreaAddrOffsets, World4Areas-AreaAddrOffsets
      .db World5Areas-AreaAddrOffsets, World6Areas-AreaAddrOffsets
      .db World7Areas-AreaAddrOffsets, World8Areas-AreaAddrOffsets

AreaAddrOffsets:
World1Areas: .db $25, $29, $c0, $26, $60
World2Areas: .db $28, $29, $01, $27, $62
World3Areas: .db $24, $35, $20, $63
World4Areas: .db $22, $29, $41, $2c, $61
World5Areas: .db $2a, $31, $26, $62
World6Areas: .db $2e, $23, $2d, $60
World7Areas: .db $33, $29, $01, $27, $64
World8Areas: .db $30, $32, $21, $65

;bonus area data offsets, included here for comparison purposes
;underground bonus area  - c2
;cloud area 1 (day)      - 2b
;cloud area 2 (night)    - 34
;water area (5-2/6-2)    - 00
;water area (8-4)        - 02
;warp zone area (4-2)    - 2f

EnemyAddrHOffsets:
      .db $1f, $06, $1c, $00

EnemyDataAddrLow:
      .db LOW E_CastleArea1, LOW E_CastleArea2, LOW E_CastleArea3, LOW E_CastleArea4, LOW E_CastleArea5, LOW E_CastleArea6
      .db LOW E_GroundArea1, LOW E_GroundArea2, LOW E_GroundArea3, LOW E_GroundArea4, LOW E_GroundArea5, LOW E_GroundArea6
      .db LOW E_GroundArea7, LOW E_GroundArea8, LOW E_GroundArea9, LOW E_GroundArea10, LOW E_GroundArea11, LOW E_GroundArea12
      .db LOW E_GroundArea13, LOW E_GroundArea14, LOW E_GroundArea15, LOW E_GroundArea16, LOW E_GroundArea17, LOW E_GroundArea18
      .db LOW E_GroundArea19, LOW E_GroundArea20, LOW E_GroundArea21, LOW E_GroundArea22, LOW E_UndergroundArea1
      .db LOW E_UndergroundArea2, LOW E_UndergroundArea3, LOW E_WaterArea1, LOW E_WaterArea2, LOW E_WaterArea3

EnemyDataAddrHigh:
      .db HIGH E_CastleArea1, HIGH E_CastleArea2, HIGH E_CastleArea3, HIGH E_CastleArea4, HIGH E_CastleArea5, HIGH E_CastleArea6
      .db HIGH E_GroundArea1, HIGH E_GroundArea2, HIGH E_GroundArea3, HIGH E_GroundArea4, HIGH E_GroundArea5, HIGH E_GroundArea6
      .db HIGH E_GroundArea7, HIGH E_GroundArea8, HIGH E_GroundArea9, HIGH E_GroundArea10, HIGH E_GroundArea11, HIGH E_GroundArea12
      .db HIGH E_GroundArea13, HIGH E_GroundArea14, HIGH E_GroundArea15, HIGH E_GroundArea16, HIGH E_GroundArea17, HIGH E_GroundArea18
      .db HIGH E_GroundArea19, HIGH E_GroundArea20, HIGH E_GroundArea21, HIGH E_GroundArea22, HIGH E_UndergroundArea1
      .db HIGH E_UndergroundArea2, HIGH E_UndergroundArea3, HIGH E_WaterArea1, HIGH E_WaterArea2, HIGH E_WaterArea3

AreaDataHOffsets:
      .db $00, $03, $19, $1c

AreaDataAddrLow:
      .db LOW L_WaterArea1, LOW L_WaterArea2, LOW L_WaterArea3, LOW L_GroundArea1, LOW L_GroundArea2, LOW L_GroundArea3
      .db LOW L_GroundArea4, LOW L_GroundArea5, LOW L_GroundArea6, LOW L_GroundArea7, LOW L_GroundArea8, LOW L_GroundArea9
      .db LOW L_GroundArea10, LOW L_GroundArea11, LOW L_GroundArea12, LOW L_GroundArea13, LOW L_GroundArea14, LOW L_GroundArea15
      .db LOW L_GroundArea16, LOW L_GroundArea17, LOW L_GroundArea18, LOW L_GroundArea19, LOW L_GroundArea20, LOW L_GroundArea21
      .db LOW L_GroundArea22, LOW L_UndergroundArea1, LOW L_UndergroundArea2, LOW L_UndergroundArea3, LOW L_CastleArea1
      .db LOW L_CastleArea2, LOW L_CastleArea3, LOW L_CastleArea4, LOW L_CastleArea5, LOW L_CastleArea6

AreaDataAddrHigh:
      .db HIGH L_WaterArea1, HIGH L_WaterArea2, HIGH L_WaterArea3, HIGH L_GroundArea1, HIGH L_GroundArea2, HIGH L_GroundArea3
      .db HIGH L_GroundArea4, HIGH L_GroundArea5, HIGH L_GroundArea6, HIGH L_GroundArea7, HIGH L_GroundArea8, HIGH L_GroundArea9
      .db HIGH L_GroundArea10, HIGH L_GroundArea11, HIGH L_GroundArea12, HIGH L_GroundArea13, HIGH L_GroundArea14, HIGH L_GroundArea15
      .db HIGH L_GroundArea16, HIGH L_GroundArea17, HIGH L_GroundArea18, HIGH L_GroundArea19, HIGH L_GroundArea20, HIGH L_GroundArea21
      .db HIGH L_GroundArea22, HIGH L_UndergroundArea1, HIGH L_UndergroundArea2, HIGH L_UndergroundArea3, HIGH L_CastleArea1
      .db HIGH L_CastleArea2, HIGH L_CastleArea3, HIGH L_CastleArea4, HIGH L_CastleArea5, HIGH L_CastleArea6

;ENEMY OBJECT DATA

;level 1-4/6-4
E_CastleArea1:
      .db $76, $dd, $bb, $4c, $ea, $1d, $1b, $cc, $56, $5d
      .db $16, $9d, $c6, $1d, $36, $9d, $c9, $1d, $04, $db
      .db $49, $1d, $84, $1b, $c9, $5d, $88, $95, $0f, $08
      .db $30, $4c, $78, $2d, $a6, $28, $90, $b5
      .db $ff

;level 4-4
E_CastleArea2:
      .db $0f, $03, $56, $1b, $c9, $1b, $0f, $07, $36, $1b
      .db $aa, $1b, $48, $95, $0f, $0a, $2a, $1b, $5b, $0c
      .db $78, $2d, $90, $b5
      .db $ff

;level 2-4/5-4
E_CastleArea3:
      .db $0b, $8c, $4b, $4c, $77, $5f, $eb, $0c, $bd, $db
      .db $19, $9d, $75, $1d, $7d, $5b, $d9, $1d, $3d, $dd
      .db $99, $1d, $26, $9d, $5a, $2b, $8a, $2c, $ca, $1b
      .db $20, $95, $7b, $5c, $db, $4c, $1b, $cc, $3b, $cc
      .db $78, $2d, $a6, $28, $90, $b5
      .db $ff

;level 3-4
E_CastleArea4:
      .db $0b, $8c, $3b, $1d, $8b, $1d, $ab, $0c, $db, $1d
      .db $0f, $03, $65, $1d, $6b, $1b, $05, $9d, $0b, $1b
      .db $05, $9b, $0b, $1d, $8b, $0c, $1b, $8c, $70, $15
      .db $7b, $0c, $db, $0c, $0f, $08, $78, $2d, $a6, $28
      .db $90, $b5
      .db $ff

;level 7-4
E_CastleArea5:
      .db $27, $a9, $4b, $0c, $68, $29, $0f, $06, $77, $1b
      .db $0f, $0b, $60, $15, $4b, $8c, $78, $2d, $90, $b5
      .db $ff

;level 8-4
E_CastleArea6:
      .db $0f, $03, $8e, $65, $e1, $bb, $38, $6d, $a8, $3e, $e5, $e7
      .db $0f, $08, $0b, $02, $2b, $02, $5e, $65, $e1, $bb, $0e
      .db $db, $0e, $bb, $8e, $db, $0e, $fe, $65, $ec, $0f, $0d
      .db $4e, $65, $e1, $0f, $0e, $4e, $02, $e0, $0f, $10, $fe, $e5, $e1
      .db $1b, $85, $7b, $0c, $5b, $95, $78, $2d, $90, $b5
      .db $ff

;level 3-3
E_GroundArea1:
      .db $a5, $86, $e4, $28, $18, $a8, $45, $83, $69, $03
      .db $c6, $29, $9b, $83, $16, $a4, $88, $24, $e9, $28
      .db $05, $a8, $7b, $28, $24, $8f, $c8, $03, $e8, $03
      .db $46, $a8, $85, $24, $c8, $24
      .db $ff

;level 8-3
E_GroundArea2:
      .db $eb, $8e, $0f, $03, $fb, $05, $17, $85, $db, $8e
      .db $0f, $07, $57, $05, $7b, $05, $9b, $80, $2b, $85
      .db $fb, $05, $0f, $0b, $1b, $05, $9b, $05
      .db $ff

;level 4-1
E_GroundArea3:
      .db $2e, $c2, $66, $e2, $11, $0f, $07, $02, $11, $0f, $0c
      .db $12, $11
      .db $ff

;level 6-2
E_GroundArea4:
      .db $0e, $c2, $a8, $ab, $00, $bb, $8e, $6b, $82, $de, $00, $a0
      .db $33, $86, $43, $06, $3e, $b4, $a0, $cb, $02, $0f, $07
      .db $7e, $42, $a6, $83, $02, $0f, $0a, $3b, $02, $cb, $37
      .db $0f, $0c, $e3, $0e
      .db $ff

;level 3-1
E_GroundArea5:
      .db $9b, $8e, $ca, $0e, $ee, $42, $44, $5b, $86, $80, $b8
      .db $1b, $80, $50, $ba, $10, $b7, $5b, $00, $17, $85
      .db $4b, $05, $fe, $34, $40, $b7, $86, $c6, $06, $5b, $80
      .db $83, $00, $d0, $38, $5b, $8e, $8a, $0e, $a6, $00
      .db $bb, $0e, $c5, $80, $f3, $00
      .db $ff

;level 1-1
E_GroundArea6:
      .db $1e, $c2, $00, $6b, $06, $8b, $86, $63, $b7, $0f, $05
      .db $03, $06, $23, $06, $4b, $b7, $bb, $00, $5b, $b7
      .db $fb, $37, $3b, $b7, $0f, $0b, $1b, $37
      .db $ff

;level 1-3/5-3
E_GroundArea7:
      .db $2b, $d7, $e3, $03, $c2, $86, $e2, $06, $76, $a5
      .db $a3, $8f, $03, $86, $2b, $57, $68, $28, $e9, $28
      .db $e5, $83, $24, $8f, $36, $a8, $5b, $03
      .db $ff

;level 2-3/7-3
E_GroundArea8:
      .db $0f, $02, $78, $40, $48, $ce, $f8, $c3, $f8, $c3
      .db $0f, $07, $7b, $43, $c6, $d0, $0f, $8a, $c8, $50
      .db $ff

;level 2-1
E_GroundArea9:
      .db $85, $86, $0b, $80, $1b, $00, $db, $37, $77, $80
      .db $eb, $37, $fe, $2b, $20, $2b, $80, $7b, $38, $ab, $b8
      .db $77, $86, $fe, $42, $20, $49, $86, $8b, $06, $9b, $80
      .db $7b, $8e, $5b, $b7, $9b, $0e, $bb, $0e, $9b, $80
;end of data terminator here is also used by pipe intro area
E_GroundArea10:
      .db $ff

;level 5-1
E_GroundArea11:
      .db $0b, $80, $60, $38, $10, $b8, $c0, $3b, $db, $8e
      .db $40, $b8, $f0, $38, $7b, $8e, $a0, $b8, $c0, $b8
      .db $fb, $00, $a0, $b8, $30, $bb, $ee, $42, $88, $0f, $0b
      .db $2b, $0e, $67, $0e
      .db $ff

;cloud level used in levels 2-1 and 5-2
E_GroundArea12:
      .db $0a, $aa, $0e, $28, $2a, $0e, $31, $88
      .db $ff

;level 4-3
E_GroundArea13:
      .db $c7, $83, $d7, $03, $42, $8f, $7a, $03, $05, $a4
      .db $78, $24, $a6, $25, $e4, $25, $4b, $83, $e3, $03
      .db $05, $a4, $89, $24, $b5, $24, $09, $a4, $65, $24
      .db $c9, $24, $0f, $08, $85, $25
      .db $ff

;level 6-3
E_GroundArea14:
      .db $cd, $a5, $b5, $a8, $07, $a8, $76, $28, $cc, $25
      .db $65, $a4, $a9, $24, $e5, $24, $19, $a4, $0f, $07
      .db $95, $28, $e6, $24, $19, $a4, $d7, $29, $16, $a9
      .db $58, $29, $97, $29
      .db $ff

;level 6-1
E_GroundArea15:
      .db $0f, $02, $02, $11, $0f, $07, $02, $11
      .db $ff

;warp zone area used in level 4-2
E_GroundArea16:
      .db $ff

;level 8-1
E_GroundArea17:
      .db $2b, $82, $ab, $38, $de, $42, $e2, $1b, $b8, $eb
      .db $3b, $db, $80, $8b, $b8, $1b, $82, $fb, $b8, $7b
      .db $80, $fb, $3c, $5b, $bc, $7b, $b8, $1b, $8e, $cb
      .db $0e, $1b, $8e, $0f, $0d, $2b, $3b, $bb, $b8, $eb, $82
      .db $4b, $b8, $bb, $38, $3b, $b7, $bb, $02, $0f, $13
      .db $1b, $00, $cb, $80, $6b, $bc
      .db $ff

;level 5-2
E_GroundArea18:
      .db $7b, $80, $ae, $00, $80, $8b, $8e, $e8, $05, $f9, $86 
      .db $17, $86, $16, $85, $4e, $2b, $80, $ab, $8e, $87, $85
      .db $c3, $05, $8b, $82, $9b, $02, $ab, $02, $bb, $86
      .db $cb, $06, $d3, $03, $3b, $8e, $6b, $0e, $a7, $8e
      .db $ff

;level 8-2
E_GroundArea19:
      .db $29, $8e, $52, $11, $83, $0e, $0f, $03, $9b, $0e
      .db $2b, $8e, $5b, $0e, $cb, $8e, $fb, $0e, $fb, $82
      .db $9b, $82, $bb, $02, $fe, $42, $e8, $bb, $8e, $0f, $0a
      .db $ab, $0e, $cb, $0e, $f9, $0e, $88, $86, $a6, $06
      .db $db, $02, $b6, $8e
      .db $ff

;level 7-1
E_GroundArea20:
      .db $ab, $ce, $de, $42, $c0, $cb, $ce, $5b, $8e, $1b, $ce
      .db $4b, $85, $67, $45, $0f, $07, $2b, $00, $7b, $85
      .db $97, $05, $0f, $0a, $92, $02
      .db $ff

;cloud level used in levels 3-1 and 6-2
E_GroundArea21:
      .db $0a, $aa, $0e, $24, $4a, $1e, $23, $aa
      .db $ff

;level 3-2
E_GroundArea22:
      .db $1b, $80, $bb, $38, $4b, $bc, $eb, $3b, $0f, $04
      .db $2b, $00, $ab, $38, $eb, $00, $cb, $8e, $fb, $80
      .db $ab, $b8, $6b, $80, $fb, $3c, $9b, $bb, $5b, $bc
      .db $fb, $00, $6b, $b8, $fb, $38
      .db $ff

;level 1-2
E_UndergroundArea1:
      .db $0b, $86, $1a, $06, $db, $06, $de, $c2, $02, $f0, $3b
      .db $bb, $80, $eb, $06, $0b, $86, $93, $06, $f0, $39
      .db $0f, $06, $60, $b8, $1b, $86, $a0, $b9, $b7, $27
      .db $bd, $27, $2b, $83, $a1, $26, $a9, $26, $ee, $25, $0b
      .db $27, $b4
      .db $ff

;level 4-2
E_UndergroundArea2:
      .db $0f, $02, $1e, $2f, $60, $e0, $3a, $a5, $a7, $db, $80
      .db $3b, $82, $8b, $02, $fe, $42, $68, $70, $bb, $25, $a7
      .db $2c, $27, $b2, $26, $b9, $26, $9b, $80, $a8, $82
      .db $b5, $27, $bc, $27, $b0, $bb, $3b, $82, $87, $34
      .db $ee, $25, $6b
      .db $ff

;underground bonus rooms area used in many levels
E_UndergroundArea3:
      .db $1e, $a5, $0a, $2e, $28, $27, $2e, $33, $c7, $0f, $03, $1e, $40, $07
      .db $2e, $30, $e7, $0f, $05, $1e, $24, $44, $0f, $07, $1e, $22, $6a
      .db $2e, $23, $ab, $0f, $09, $1e, $41, $68, $1e, $2a, $8a, $2e, $23, $a2
      .db $2e, $32, $ea
      .db $ff

;water area used in levels 5-2 and 6-2
E_WaterArea1:
      .db $3b, $87, $66, $27, $cc, $27, $ee, $31, $87, $ee, $23, $a7
      .db $3b, $87, $db, $07
      .db $ff

;level 2-2/7-2
E_WaterArea2:
      .db $0f, $01, $2e, $25, $2b, $2e, $25, $4b, $4e, $25, $cb, $6b, $07
      .db $97, $47, $e9, $87, $47, $c7, $7a, $07, $d6, $c7
      .db $78, $07, $38, $87, $ab, $47, $e3, $07, $9b, $87
      .db $0f, $09, $68, $47, $db, $c7, $3b, $c7
      .db $ff

;water area used in level 8-4
E_WaterArea3:
      .db $47, $9b, $cb, $07, $fa, $1d, $86, $9b, $3a, $87
      .db $56, $07, $88, $1b, $07, $9d, $2e, $65, $f0
      .db $ff

;AREA OBJECT DATA

;level 1-4/6-4
L_CastleArea1:
      .db $9b, $07
      .db $05, $32, $06, $33, $07, $34, $ce, $03, $dc, $51
      .db $ee, $07, $73, $e0, $74, $0a, $7e, $06, $9e, $0a
      .db $ce, $06, $e4, $00, $e8, $0a, $fe, $0a, $2e, $89
      .db $4e, $0b, $54, $0a, $14, $8a, $c4, $0a, $34, $8a
      .db $7e, $06, $c7, $0a, $01, $e0, $02, $0a, $47, $0a
      .db $81, $60, $82, $0a, $c7, $0a, $0e, $87, $7e, $02
      .db $a7, $02, $b3, $02, $d7, $02, $e3, $02, $07, $82
      .db $13, $02, $3e, $06, $7e, $02, $ae, $07, $fe, $0a
      .db $0d, $c4, $cd, $43, $ce, $09, $de, $0b, $dd, $42
      .db $fe, $02, $5d, $c7
      .db $fd

;level 4-4
L_CastleArea2:
      .db $5b, $07
      .db $05, $32, $06, $33, $07, $34, $5e, $0a, $68, $64
      .db $98, $64, $a8, $64, $ce, $06, $fe, $02, $0d, $01
      .db $1e, $0e, $7e, $02, $94, $63, $b4, $63, $d4, $63
      .db $f4, $63, $14, $e3, $2e, $0e, $5e, $02, $64, $35
      .db $88, $72, $be, $0e, $0d, $04, $ae, $02, $ce, $08
      .db $cd, $4b, $fe, $02, $0d, $05, $68, $31, $7e, $0a
      .db $96, $31, $a9, $63, $a8, $33, $d5, $30, $ee, $02
      .db $e6, $62, $f4, $61, $04, $b1, $08, $3f, $44, $33
      .db $94, $63, $a4, $31, $e4, $31, $04, $bf, $08, $3f
      .db $04, $bf, $08, $3f, $cd, $4b, $03, $e4, $0e, $03
      .db $2e, $01, $7e, $06, $be, $02, $de, $06, $fe, $0a
      .db $0d, $c4, $cd, $43, $ce, $09, $de, $0b, $dd, $42
      .db $fe, $02, $5d, $c7
      .db $fd

;level 2-4/5-4
L_CastleArea3:
      .db $9b, $07
      .db $05, $32, $06, $33, $07, $34, $fe, $00, $27, $b1
      .db $65, $32, $75, $0a, $71, $00, $b7, $31, $08, $e4
      .db $18, $64, $1e, $04, $57, $3b, $bb, $0a, $17, $8a
      .db $27, $3a, $73, $0a, $7b, $0a, $d7, $0a, $e7, $3a
      .db $3b, $8a, $97, $0a, $fe, $08, $24, $8a, $2e, $00
      .db $3e, $40, $38, $64, $6f, $00, $9f, $00, $be, $43
      .db $c8, $0a, $c9, $63, $ce, $07, $fe, $07, $2e, $81
      .db $66, $42, $6a, $42, $79, $0a, $be, $00, $c8, $64
      .db $f8, $64, $08, $e4, $2e, $07, $7e, $03, $9e, $07
      .db $be, $03, $de, $07, $fe, $0a, $03, $a5, $0d, $44
      .db $cd, $43, $ce, $09, $dd, $42, $de, $0b, $fe, $02
      .db $5d, $c7
      .db $fd

;level 3-4
L_CastleArea4:
      .db $9b, $07
      .db $05, $32, $06, $33, $07, $34, $fe, $06, $0c, $81
      .db $39, $0a, $5c, $01, $89, $0a, $ac, $01, $d9, $0a
      .db $fc, $01, $2e, $83, $a7, $01, $b7, $00, $c7, $01
      .db $de, $0a, $fe, $02, $4e, $83, $5a, $32, $63, $0a
      .db $69, $0a, $7e, $02, $ee, $03, $fa, $32, $03, $8a
      .db $09, $0a, $1e, $02, $ee, $03, $fa, $32, $03, $8a
      .db $09, $0a, $14, $42, $1e, $02, $7e, $0a, $9e, $07
      .db $fe, $0a, $2e, $86, $5e, $0a, $8e, $06, $be, $0a
      .db $ee, $07, $3e, $83, $5e, $07, $fe, $0a, $0d, $c4
      .db $41, $52, $51, $52, $cd, $43, $ce, $09, $de, $0b
      .db $dd, $42, $fe, $02, $5d, $c7
      .db $fd

;level 7-4
L_CastleArea5:
      .db $5b, $07
      .db $05, $32, $06, $33, $07, $34, $fe, $0a, $ae, $86
      .db $be, $07, $fe, $02, $0d, $02, $27, $32, $46, $61
      .db $55, $62, $5e, $0e, $1e, $82, $68, $3c, $74, $3a
      .db $7d, $4b, $5e, $8e, $7d, $4b, $7e, $82, $84, $62
      .db $94, $61, $a4, $31, $bd, $4b, $ce, $06, $fe, $02
      .db $0d, $06, $34, $31, $3e, $0a, $64, $32, $75, $0a
      .db $7b, $61, $a4, $33, $ae, $02, $de, $0e, $3e, $82
      .db $64, $32, $78, $32, $b4, $36, $c8, $36, $dd, $4b
      .db $44, $b2, $58, $32, $94, $63, $a4, $3e, $ba, $30
      .db $c9, $61, $ce, $06, $dd, $4b, $ce, $86, $dd, $4b
      .db $fe, $02, $2e, $86, $5e, $02, $7e, $06, $fe, $02
      .db $1e, $86, $3e, $02, $5e, $06, $7e, $02, $9e, $06
      .db $fe, $0a, $0d, $c4, $cd, $43, $ce, $09, $de, $0b
      .db $dd, $42, $fe, $02, $5d, $c7
      .db $fd

;level 8-4
L_CastleArea6:
      .db $5b, $06
      .db $05, $32, $06, $33, $07, $34, $5e, $0a, $ae, $02
      .db $0d, $01, $39, $73, $0d, $03, $39, $7b, $4d, $4b
      .db $de, $06, $1e, $8a, $ae, $06, $c4, $33, $16, $fe
      .db $a5, $77, $fe, $02, $fe, $82, $0d, $07, $39, $73
      .db $a8, $74, $ed, $4b, $49, $fb, $e8, $74, $fe, $0a
      .db $2e, $82, $67, $02, $84, $7a, $87, $31, $0d, $0b
      .db $fe, $02, $0d, $0c, $39, $73, $5e, $06, $c6, $76
      .db $45, $ff, $be, $0a, $dd, $48, $fe, $06, $3d, $cb
      .db $46, $7e, $ad, $4a, $fe, $82, $39, $f3, $a9, $7b
      .db $4e, $8a, $9e, $07, $fe, $0a, $0d, $c4, $cd, $43
      .db $ce, $09, $de, $0b, $dd, $42, $fe, $02, $5d, $c7
      .db $fd

;level 3-3
L_GroundArea1:
      .db $94, $11
      .db $0f, $26, $fe, $10, $28, $94, $65, $15, $eb, $12
      .db $fa, $41, $4a, $96, $54, $40, $a4, $42, $b7, $13
      .db $e9, $19, $f5, $15, $11, $80, $47, $42, $71, $13
      .db $80, $41, $15, $92, $1b, $1f, $24, $40, $55, $12
      .db $64, $40, $95, $12, $a4, $40, $d2, $12, $e1, $40
      .db $13, $c0, $2c, $17, $2f, $12, $49, $13, $83, $40
      .db $9f, $14, $a3, $40, $17, $92, $83, $13, $92, $41
      .db $b9, $14, $c5, $12, $c8, $40, $d4, $40, $4b, $92
      .db $78, $1b, $9c, $94, $9f, $11, $df, $14, $fe, $11
      .db $7d, $c1, $9e, $42, $cf, $20
      .db $fd

;level 8-3
L_GroundArea2:
      .db $90, $b1
      .db $0f, $26, $29, $91, $7e, $42, $fe, $40, $28, $92
      .db $4e, $42, $2e, $c0, $57, $73, $c3, $25, $c7, $27
      .db $23, $84, $33, $20, $5c, $01, $77, $63, $88, $62
      .db $99, $61, $aa, $60, $bc, $01, $ee, $42, $4e, $c0
      .db $69, $11, $7e, $42, $de, $40, $f8, $62, $0e, $c2
      .db $ae, $40, $d7, $63, $e7, $63, $33, $a7, $37, $27
      .db $43, $04, $cc, $01, $e7, $73, $0c, $81, $3e, $42
      .db $0d, $0a, $5e, $40, $88, $72, $be, $42, $e7, $87
      .db $fe, $40, $39, $e1, $4e, $00, $69, $60, $87, $60
      .db $a5, $60, $c3, $31, $fe, $31, $6d, $c1, $be, $42
      .db $ef, $20
      .db $fd

;level 4-1
L_GroundArea3:
      .db $52, $21
      .db $0f, $20, $6e, $40, $58, $f2, $93, $01, $97, $00
      .db $0c, $81, $97, $40, $a6, $41, $c7, $40, $0d, $04
      .db $03, $01, $07, $01, $23, $01, $27, $01, $ec, $03
      .db $ac, $f3, $c3, $03, $78, $e2, $94, $43, $47, $f3
      .db $74, $43, $47, $fb, $74, $43, $2c, $f1, $4c, $63
      .db $47, $00, $57, $21, $5c, $01, $7c, $72, $39, $f1
      .db $ec, $02, $4c, $81, $d8, $62, $ec, $01, $0d, $0d
      .db $0f, $38, $c7, $07, $ed, $4a, $1d, $c1, $5f, $26
      .db $fd

;level 6-2
L_GroundArea4:
      .db $54, $21
      .db $0f, $26, $a7, $22, $37, $fb, $73, $20, $83, $07
      .db $87, $02, $93, $20, $c7, $73, $04, $f1, $06, $31
      .db $39, $71, $59, $71, $e7, $73, $37, $a0, $47, $04
      .db $86, $7c, $e5, $71, $e7, $31, $33, $a4, $39, $71
      .db $a9, $71, $d3, $23, $08, $f2, $13, $05, $27, $02
      .db $49, $71, $75, $75, $e8, $72, $67, $f3, $99, $71
      .db $e7, $20, $f4, $72, $f7, $31, $17, $a0, $33, $20
      .db $39, $71, $73, $28, $bc, $05, $39, $f1, $79, $71
      .db $a6, $21, $c3, $06, $d3, $20, $dc, $00, $fc, $00
      .db $07, $a2, $13, $21, $5f, $32, $8c, $00, $98, $7a
      .db $c7, $63, $d9, $61, $03, $a2, $07, $22, $74, $72
      .db $77, $31, $e7, $73, $39, $f1, $58, $72, $77, $73
      .db $d8, $72, $7f, $b1, $97, $73, $b6, $64, $c5, $65
      .db $d4, $66, $e3, $67, $f3, $67, $8d, $c1, $cf, $26
      .db $fd

;level 3-1
L_GroundArea5:
      .db $52, $31
      .db $0f, $20, $6e, $66, $07, $81, $36, $01, $66, $00
      .db $a7, $22, $08, $f2, $67, $7b, $dc, $02, $98, $f2
      .db $d7, $20, $39, $f1, $9f, $33, $dc, $27, $dc, $57
      .db $23, $83, $57, $63, $6c, $51, $87, $63, $99, $61
      .db $a3, $06, $b3, $21, $77, $f3, $f3, $21, $f7, $2a
      .db $13, $81, $23, $22, $53, $00, $63, $22, $e9, $0b
      .db $0c, $83, $13, $21, $16, $22, $33, $05, $8f, $35
      .db $ec, $01, $63, $a0, $67, $20, $73, $01, $77, $01
      .db $83, $20, $87, $20, $b3, $20, $b7, $20, $c3, $01
      .db $c7, $00, $d3, $20, $d7, $20, $67, $a0, $77, $07
      .db $87, $22, $e8, $62, $f5, $65, $1c, $82, $7f, $38
      .db $8d, $c1, $cf, $26
      .db $fd

;level 1-1
L_GroundArea6:
      .db $50, $21
      .db $07, $81, $47, $24, $57, $00, $63, $01, $77, $01
      .db $c9, $71, $68, $f2, $e7, $73, $97, $fb, $06, $83
      .db $5c, $01, $d7, $22, $e7, $00, $03, $a7, $6c, $02
      .db $b3, $22, $e3, $01, $e7, $07, $47, $a0, $57, $06
      .db $a7, $01, $d3, $00, $d7, $01, $07, $81, $67, $20
      .db $93, $22, $03, $a3, $1c, $61, $17, $21, $6f, $33
      .db $c7, $63, $d8, $62, $e9, $61, $fa, $60, $4f, $b3
      .db $87, $63, $9c, $01, $b7, $63, $c8, $62, $d9, $61
      .db $ea, $60, $39, $f1, $87, $21, $a7, $01, $b7, $20
      .db $39, $f1, $5f, $38, $6d, $c1, $af, $26
      .db $fd

;level 1-3/5-3
L_GroundArea7:
      .db $90, $11
      .db $0f, $26, $fe, $10, $2a, $93, $87, $17, $a3, $14
      .db $b2, $42, $0a, $92, $19, $40, $36, $14, $50, $41
      .db $82, $16, $2b, $93, $24, $41, $bb, $14, $b8, $00
      .db $c2, $43, $c3, $13, $1b, $94, $67, $12, $c4, $15
      .db $53, $c1, $d2, $41, $12, $c1, $29, $13, $85, $17
      .db $1b, $92, $1a, $42, $47, $13, $83, $41, $a7, $13
      .db $0e, $91, $a7, $63, $b7, $63, $c5, $65, $d5, $65
      .db $dd, $4a, $e3, $67, $f3, $67, $8d, $c1, $ae, $42
      .db $df, $20
      .db $fd

;level 2-3/7-3
L_GroundArea8:
      .db $90, $11
      .db $0f, $26, $6e, $10, $8b, $17, $af, $32, $d8, $62
      .db $e8, $62, $fc, $3f, $ad, $c8, $f8, $64, $0c, $be
      .db $43, $43, $f8, $64, $0c, $bf, $73, $40, $84, $40
      .db $93, $40, $a4, $40, $b3, $40, $f8, $64, $48, $e4
      .db $5c, $39, $83, $40, $92, $41, $b3, $40, $f8, $64
      .db $48, $e4, $5c, $39, $f8, $64, $13, $c2, $37, $65
      .db $4c, $24, $63, $00, $97, $65, $c3, $42, $0b, $97
      .db $ac, $32, $f8, $64, $0c, $be, $53, $45, $9d, $48
      .db $f8, $64, $2a, $e2, $3c, $47, $56, $43, $ba, $62
      .db $f8, $64, $0c, $b7, $88, $64, $bc, $31, $d4, $45
      .db $fc, $31, $3c, $b1, $78, $64, $8c, $38, $0b, $9c
      .db $1a, $33, $18, $61, $28, $61, $39, $60, $5d, $4a
      .db $ee, $11, $0f, $b8, $1d, $c1, $3e, $42, $6f, $20
      .db $fd

;level 2-1
L_GroundArea9:
      .db $52, $31
      .db $0f, $20, $6e, $40, $f7, $20, $07, $84, $17, $20
      .db $4f, $34, $c3, $03, $c7, $02, $d3, $22, $27, $e3
      .db $39, $61, $e7, $73, $5c, $e4, $57, $00, $6c, $73
      .db $47, $a0, $53, $06, $63, $22, $a7, $73, $fc, $73
      .db $13, $a1, $33, $05, $43, $21, $5c, $72, $c3, $23
      .db $cc, $03, $77, $fb, $ac, $02, $39, $f1, $a7, $73
      .db $d3, $04, $e8, $72, $e3, $22, $26, $f4, $bc, $02
      .db $8c, $81, $a8, $62, $17, $87, $43, $24, $a7, $01
      .db $c3, $04, $08, $f2, $97, $21, $a3, $02, $c9, $0b
      .db $e1, $69, $f1, $69, $8d, $c1, $cf, $26
      .db $fd

;pipe intro area
L_GroundArea10:
      .db $38, $11
      .db $0f, $26, $ad, $40, $3d, $c7
      .db $fd

;level 5-1
L_GroundArea11:
      .db $95, $b1
      .db $0f, $26, $0d, $02, $c8, $72, $1c, $81, $38, $72
      .db $0d, $05, $97, $34, $98, $62, $a3, $20, $b3, $06
      .db $c3, $20, $cc, $03, $f9, $91, $2c, $81, $48, $62
      .db $0d, $09, $37, $63, $47, $03, $57, $21, $8c, $02
      .db $c5, $79, $c7, $31, $f9, $11, $39, $f1, $a9, $11
      .db $6f, $b4, $d3, $65, $e3, $65, $7d, $c1, $bf, $26
      .db $fd

;cloud level used in levels 2-1 and 5-2
L_GroundArea12:
      .db $00, $c1
      .db $4c, $00, $f4, $4f, $0d, $02, $02, $42, $43, $4f
      .db $52, $c2, $de, $00, $5a, $c2, $4d, $c7
      .db $fd

;level 4-3
L_GroundArea13:
      .db $90, $51
      .db $0f, $26, $ee, $10, $0b, $94, $33, $14, $42, $42
      .db $77, $16, $86, $44, $02, $92, $4a, $16, $69, $42
      .db $73, $14, $b0, $00, $c7, $12, $05, $c0, $1c, $17
      .db $1f, $11, $36, $12, $8f, $14, $91, $40, $1b, $94
      .db $35, $12, $34, $42, $60, $42, $61, $12, $87, $12
      .db $96, $40, $a3, $14, $1c, $98, $1f, $11, $47, $12
      .db $9f, $15, $cc, $15, $cf, $11, $05, $c0, $1f, $15
      .db $39, $12, $7c, $16, $7f, $11, $82, $40, $98, $12
      .db $df, $15, $16, $c4, $17, $14, $54, $12, $9b, $16
      .db $28, $94, $ce, $01, $3d, $c1, $5e, $42, $8f, $20
      .db $fd

;level 6-3
L_GroundArea14:
      .db $97, $11
      .db $0f, $26, $fe, $10, $2b, $92, $57, $12, $8b, $12
      .db $c0, $41, $f7, $13, $5b, $92, $69, $0b, $bb, $12
      .db $b2, $46, $19, $93, $71, $00, $17, $94, $7c, $14
      .db $7f, $11, $93, $41, $bf, $15, $fc, $13, $ff, $11
      .db $2f, $95, $50, $42, $51, $12, $58, $14, $a6, $12
      .db $db, $12, $1b, $93, $46, $43, $7b, $12, $8d, $49
      .db $b7, $14, $1b, $94, $49, $0b, $bb, $12, $fc, $13
      .db $ff, $12, $03, $c1, $2f, $15, $43, $12, $4b, $13
      .db $77, $13, $9d, $4a, $15, $c1, $a1, $41, $c3, $12
      .db $fe, $01, $7d, $c1, $9e, $42, $cf, $20
      .db $fd

;level 6-1
L_GroundArea15:
      .db $52, $21
      .db $0f, $20, $6e, $44, $0c, $f1, $4c, $01, $aa, $35
      .db $d9, $34, $ee, $20, $08, $b3, $37, $32, $43, $04
      .db $4e, $21, $53, $20, $7c, $01, $97, $21, $b7, $07
      .db $9c, $81, $e7, $42, $5f, $b3, $97, $63, $ac, $02
      .db $c5, $41, $49, $e0, $58, $61, $76, $64, $85, $65
      .db $94, $66, $a4, $22, $a6, $03, $c8, $22, $dc, $02
      .db $68, $f2, $96, $42, $13, $82, $17, $02, $af, $34
      .db $f6, $21, $fc, $06, $26, $80, $2a, $24, $36, $01
      .db $8c, $00, $ff, $35, $4e, $a0, $55, $21, $77, $20
      .db $87, $07, $89, $22, $ae, $21, $4c, $82, $9f, $34
      .db $ec, $01, $03, $e7, $13, $67, $8d, $4a, $ad, $41
      .db $0f, $a6
      .db $fd

;warp zone area used in level 4-2
L_GroundArea16:
      .db $10, $51
      .db $4c, $00, $c7, $12, $c6, $42, $03, $92, $02, $42
      .db $29, $12, $63, $12, $62, $42, $69, $14, $a5, $12
      .db $a4, $42, $e2, $14, $e1, $44, $f8, $16, $37, $c1
      .db $8f, $38, $02, $bb, $28, $7a, $68, $7a, $a8, $7a
      .db $e0, $6a, $f0, $6a, $6d, $c5
      .db $fd

;level 8-1
L_GroundArea17:
      .db $92, $31
      .db $0f, $20, $6e, $40, $0d, $02, $37, $73, $ec, $00
      .db $0c, $80, $3c, $00, $6c, $00, $9c, $00, $06, $c0
      .db $c7, $73, $06, $83, $28, $72, $96, $40, $e7, $73
      .db $26, $c0, $87, $7b, $d2, $41, $39, $f1, $c8, $f2
      .db $97, $e3, $a3, $23, $e7, $02, $e3, $07, $f3, $22
      .db $37, $e3, $9c, $00, $bc, $00, $ec, $00, $0c, $80
      .db $3c, $00, $86, $21, $a6, $06, $b6, $24, $5c, $80
      .db $7c, $00, $9c, $00, $29, $e1, $dc, $05, $f6, $41
      .db $dc, $80, $e8, $72, $0c, $81, $27, $73, $4c, $01
      .db $66, $74, $0d, $11, $3f, $35, $b6, $41, $2c, $82
      .db $36, $40, $7c, $02, $86, $40, $f9, $61, $39, $e1
      .db $ac, $04, $c6, $41, $0c, $83, $16, $41, $88, $f2
      .db $39, $f1, $7c, $00, $89, $61, $9c, $00, $a7, $63
      .db $bc, $00, $c5, $65, $dc, $00, $e3, $67, $f3, $67
      .db $8d, $c1, $cf, $26
      .db $fd

;level 5-2
L_GroundArea18:
      .db $55, $b1
      .db $0f, $26, $cf, $33, $07, $b2, $15, $11, $52, $42
      .db $99, $0b, $ac, $02, $d3, $24, $d6, $42, $d7, $25
      .db $23, $84, $cf, $33, $07, $e3, $19, $61, $78, $7a
      .db $ef, $33, $2c, $81, $46, $64, $55, $65, $65, $65
      .db $ec, $74, $47, $82, $53, $05, $63, $21, $62, $41
      .db $96, $22, $9a, $41, $cc, $03, $b9, $91, $39, $f1
      .db $63, $26, $67, $27, $d3, $06, $fc, $01, $18, $e2
      .db $d9, $07, $e9, $04, $0c, $86, $37, $22, $93, $24
      .db $87, $84, $ac, $02, $c2, $41, $c3, $23, $d9, $71
      .db $fc, $01, $7f, $b1, $9c, $00, $a7, $63, $b6, $64
      .db $cc, $00, $d4, $66, $e3, $67, $f3, $67, $8d, $c1
      .db $cf, $26
      .db $fd

;level 8-2
L_GroundArea19:
      .db $50, $b1
      .db $0f, $26, $fc, $00, $1f, $b3, $5c, $00, $65, $65
      .db $74, $66, $83, $67, $93, $67, $dc, $73, $4c, $80
      .db $b3, $20, $c9, $0b, $c3, $08, $d3, $2f, $dc, $00
      .db $2c, $80, $4c, $00, $8c, $00, $d3, $2e, $ed, $4a
      .db $fc, $00, $d7, $a1, $ec, $01, $4c, $80, $59, $11
      .db $d8, $11, $da, $10, $37, $a0, $47, $04, $99, $11
      .db $e7, $21, $3a, $90, $67, $20, $76, $10, $77, $60
      .db $87, $07, $d8, $12, $39, $f1, $ac, $00, $e9, $71
      .db $0c, $80, $2c, $00, $4c, $05, $c7, $7b, $39, $f1
      .db $ec, $00, $f9, $11, $0c, $82, $6f, $34, $f8, $11
      .db $fa, $10, $7f, $b2, $ac, $00, $b6, $64, $cc, $01
      .db $e3, $67, $f3, $67, $8d, $c1, $cf, $26
      .db $fd

;level 7-1
L_GroundArea20:
      .db $52, $b1
      .db $0f, $20, $6e, $45, $39, $91, $b3, $04, $c3, $21
      .db $c8, $11, $ca, $10, $49, $91, $7c, $73, $e8, $12
      .db $88, $91, $8a, $10, $e7, $21, $05, $91, $07, $30
      .db $17, $07, $27, $20, $49, $11, $9c, $01, $c8, $72
      .db $23, $a6, $27, $26, $d3, $03, $d8, $7a, $89, $91
      .db $d8, $72, $39, $f1, $a9, $11, $09, $f1, $63, $24
      .db $67, $24, $d8, $62, $28, $91, $2a, $10, $56, $21
      .db $70, $04, $79, $0b, $8c, $00, $94, $21, $9f, $35
      .db $2f, $b8, $3d, $c1, $7f, $26
      .db $fd

;cloud level used in levels 3-1 and 6-2
L_GroundArea21:
      .db $06, $c1
      .db $4c, $00, $f4, $4f, $0d, $02, $06, $20, $24, $4f
      .db $35, $a0, $36, $20, $53, $46, $d5, $20, $d6, $20
      .db $34, $a1, $73, $49, $74, $20, $94, $20, $b4, $20
      .db $d4, $20, $f4, $20, $2e, $80, $59, $42, $4d, $c7
      .db $fd

;level 3-2
L_GroundArea22:
      .db $96, $31
      .db $0f, $26, $0d, $03, $1a, $60, $77, $42, $c4, $00
      .db $c8, $62, $b9, $e1, $d3, $06, $d7, $07, $f9, $61
      .db $0c, $81, $4e, $b1, $8e, $b1, $bc, $01, $e4, $50
      .db $e9, $61, $0c, $81, $0d, $0a, $84, $43, $98, $72
      .db $0d, $0c, $0f, $38, $1d, $c1, $5f, $26
      .db $fd

;level 1-2
L_UndergroundArea1:
      .db $48, $0f
      .db $0e, $01, $5e, $02, $a7, $00, $bc, $73, $1a, $e0
      .db $39, $61, $58, $62, $77, $63, $97, $63, $b8, $62
      .db $d6, $07, $f8, $62, $19, $e1, $75, $52, $86, $40
      .db $87, $50, $95, $52, $93, $43, $a5, $21, $c5, $52
      .db $d6, $40, $d7, $20, $e5, $06, $e6, $51, $3e, $8d
      .db $5e, $03, $67, $52, $77, $52, $7e, $02, $9e, $03
      .db $a6, $43, $a7, $23, $de, $05, $fe, $02, $1e, $83
      .db $33, $54, $46, $40, $47, $21, $56, $04, $5e, $02
      .db $83, $54, $93, $52, $96, $07, $97, $50, $be, $03
      .db $c7, $23, $fe, $02, $0c, $82, $43, $45, $45, $24
      .db $46, $24, $90, $08, $95, $51, $78, $fa, $d7, $73
      .db $39, $f1, $8c, $01, $a8, $52, $b8, $52, $cc, $01
      .db $5f, $b3, $97, $63, $9e, $00, $0e, $81, $16, $24
      .db $66, $04, $8e, $00, $fe, $01, $08, $d2, $0e, $06
      .db $6f, $47, $9e, $0f, $0e, $82, $2d, $47, $28, $7a
      .db $68, $7a, $a8, $7a, $ae, $01, $de, $0f, $6d, $c5
      .db $fd

;level 4-2
L_UndergroundArea2:
      .db $48, $0f
      .db $0e, $01, $5e, $02, $bc, $01, $fc, $01, $2c, $82
      .db $41, $52, $4e, $04, $67, $25, $68, $24, $69, $24
      .db $ba, $42, $c7, $04, $de, $0b, $b2, $87, $fe, $02
      .db $2c, $e1, $2c, $71, $67, $01, $77, $00, $87, $01
      .db $8e, $00, $ee, $01, $f6, $02, $03, $85, $05, $02
      .db $13, $21, $16, $02, $27, $02, $2e, $02, $88, $72
      .db $c7, $20, $d7, $07, $e4, $76, $07, $a0, $17, $06
      .db $48, $7a, $76, $20, $98, $72, $79, $e1, $88, $62
      .db $9c, $01, $b7, $73, $dc, $01, $f8, $62, $fe, $01
      .db $08, $e2, $0e, $00, $6e, $02, $73, $20, $77, $23
      .db $83, $04, $93, $20, $ae, $00, $fe, $0a, $0e, $82
      .db $39, $71, $a8, $72, $e7, $73, $0c, $81, $8f, $32
      .db $ae, $00, $fe, $04, $04, $d1, $17, $04, $26, $49
      .db $27, $29, $df, $33, $fe, $02, $44, $f6, $7c, $01
      .db $8e, $06, $bf, $47, $ee, $0f, $4d, $c7, $0e, $82
      .db $68, $7a, $ae, $01, $de, $0f, $6d, $c5
      .db $fd

;underground bonus rooms area used in many levels
L_UndergroundArea3:
      .db $48, $01
      .db $0e, $01, $00, $5a, $3e, $06, $45, $46, $47, $46
      .db $53, $44, $ae, $01, $df, $4a, $4d, $c7, $0e, $81
      .db $00, $5a, $2e, $04, $37, $28, $3a, $48, $46, $47
      .db $c7, $07, $ce, $0f, $df, $4a, $4d, $c7, $0e, $81
      .db $00, $5a, $33, $53, $43, $51, $46, $40, $47, $50
      .db $53, $04, $55, $40, $56, $50, $62, $43, $64, $40
      .db $65, $50, $71, $41, $73, $51, $83, $51, $94, $40
      .db $95, $50, $a3, $50, $a5, $40, $a6, $50, $b3, $51
      .db $b6, $40, $b7, $50, $c3, $53, $df, $4a, $4d, $c7
      .db $0e, $81, $00, $5a, $2e, $02, $36, $47, $37, $52
      .db $3a, $49, $47, $25, $a7, $52, $d7, $04, $df, $4a
      .db $4d, $c7, $0e, $81, $00, $5a, $3e, $02, $44, $51
      .db $53, $44, $54, $44, $55, $24, $a1, $54, $ae, $01
      .db $b4, $21, $df, $4a, $e5, $07, $4d, $c7
      .db $fd

;water area used in levels 5-2 and 6-2
L_WaterArea1:
      .db $41, $01
      .db $b4, $34, $c8, $52, $f2, $51, $47, $d3, $6c, $03
      .db $65, $49, $9e, $07, $be, $01, $cc, $03, $fe, $07
      .db $0d, $c9, $1e, $01, $6c, $01, $62, $35, $63, $53
      .db $8a, $41, $ac, $01, $b3, $53, $e9, $51, $26, $c3
      .db $27, $33, $63, $43, $64, $33, $ba, $60, $c9, $61
      .db $ce, $0b, $e5, $09, $ee, $0f, $7d, $ca, $7d, $47
      .db $fd

;level 2-2/7-2
L_WaterArea2:
      .db $41, $01
      .db $b8, $52, $ea, $41, $27, $b2, $b3, $42, $16, $d4
      .db $4a, $42, $a5, $51, $a7, $31, $27, $d3, $08, $e2
      .db $16, $64, $2c, $04, $38, $42, $76, $64, $88, $62
      .db $de, $07, $fe, $01, $0d, $c9, $23, $32, $31, $51
      .db $98, $52, $0d, $c9, $59, $42, $63, $53, $67, $31
      .db $14, $c2, $36, $31, $87, $53, $17, $e3, $29, $61
      .db $30, $62, $3c, $08, $42, $37, $59, $40, $6a, $42
      .db $99, $40, $c9, $61, $d7, $63, $39, $d1, $58, $52
      .db $c3, $67, $d3, $31, $dc, $06, $f7, $42, $fa, $42
      .db $23, $b1, $43, $67, $c3, $34, $c7, $34, $d1, $51
      .db $43, $b3, $47, $33, $9a, $30, $a9, $61, $b8, $62
      .db $be, $0b, $d5, $09, $de, $0f, $0d, $ca, $7d, $47
      .db $fd

;water area used in level 8-4
L_WaterArea3:
      .db $49, $0f
      .db $1e, $01, $39, $73, $5e, $07, $ae, $0b, $1e, $82
      .db $6e, $88, $9e, $02, $0d, $04, $2e, $0b, $45, $09
      .db $4e, $0f, $ed, $47
      .db $fd

;-------------------------------------------------------------------------------------

       if Z80==0
;unused space
      .db $ff
       endif

;-------------------------------------------------------------------------------------

;indirect jump routine called when
;$0770 is set to 1
GameMode:
      lda OperMode_Task
      jsr JumpEngine

      .dw InitializeArea
      .dw ScreenRoutines
      .dw SecondaryGameSetup
      .dw GameCoreRoutine

;-------------------------------------------------------------------------------------

GameCoreRoutine:
      ldx CurrentPlayer          ;get which player is on the screen
      ldax SavedJoypadBits,x      ;use appropriate player's controller bits
       ;or a
       ;jr nz,$
      sta SavedJoypadBits        ;as the master controller bits
      jsr GameRoutines           ;execute one of many possible subs ;9907t (3 Goomba + 2 очки + Марио)
      lda OperMode_Task          ;check major task of operating mode
      cmpn ++$03                   ;if we are supposed to be here,
              cmpcy
      bcs GameEngine             ;branch to the game engine itself
      rts

GameEngine:
              jsr ProcFireball_Bubble    ;process fireballs and air bubbles
              ldxn ++$00
ProcELoop:    stx ObjectOffset           ;put incremented offset in X as enemy object offset
              jsr EnemiesAndLoopsCore    ;process enemy objects  ;8639+8388+9593+999+999+404t (3 Goomba + 2 очки + Марио) ;<------------
              jsr FloateyNumbersRoutine  ;process floatey numbers ;73+941+73+73+73+73t (3 Goomba + 2 очки + Марио)
              inx
              cpxn ++$06                   ;do these two subroutines until the whole buffer is done
              bne ProcELoop
              jsr GetPlayerOffscreenBits ;get offscreen bits for player object ;726t (3 Goomba + 2 очки + Марио)
              jsr RelativePlayerPosition ;get relative coordinates for player object ;228t (3 Goomba + 2 очки + Марио)
           if 0;Z80
            ld hl,(logicframe)
            dec l
            call z,PlayerGfxHandler ;только в последнем кадре логики (непосредственно перед отображением) ;не получается - очень медленно идёт мигание при росте и уменьшении
           else
              jsr PlayerGfxHandler       ;draw the player                               ;3074t (3 Goomba + 2 очки + Марио) ;<--------------
           endif
              jsr BlockObjMT_Updater     ;replace block objects with metatiles if necessary ;250t (3 Goomba + 2 очки + Марио)
              ldxn ++$01
              stx ObjectOffset           ;set offset for second
              jsr BlockObjectsCore       ;process second block object ;101t (3 Goomba + 2 очки + Марио)
              dex
              stx ObjectOffset           ;set offset for first
              jsr BlockObjectsCore       ;process first block object ;101t (3 Goomba + 2 очки + Марио)
              jsr MiscObjectsCore        ;process misc objects (hammer, jumping coins) ;3249t (3 Goomba + 2 очки + Марио) ;<---------------
              jsr ProcessCannons         ;process bullet bill cannons ;431t (3 Goomba + 2 очки + Марио)
              jsr ProcessWhirlpools      ;process whirlpools         ;58t (3 Goomba + 2 очки + Марио)
              jsr FlagpoleRoutine        ;process the flagpole       ;96t (3 Goomba + 2 очки + Марио)
              jsr RunGameTimer           ;count down the game timer ;174t (3 Goomba + 2 очки + Марио)
              jsr ColorRotation          ;cycle one of the background colors ;57t (3 Goomba + 2 очки + Марио)
              lda Player_Y_HighPos
              cmpn ++$02                   ;if player is below the screen, don't bother with the music
              bpl NoChgMus
              lda StarInvincibleTimer    ;if star mario invincibility timer at zero,
         checka
              beq ClrPlrPal              ;skip this part
              cmpn ++$04
              bne NoChgMus               ;if not yet at a certain point, continue
              lda IntervalTimerControl   ;if interval timer not yet expired,
         checka
              bne NoChgMus               ;branch ahead, don't bother with the music
              jsr GetAreaMusic           ;to re-attain appropriate level music
NoChgMus:     ldy StarInvincibleTimer    ;get invincibility timer
              lda FrameCounter           ;get frame counter
              cpyn ++$08                   ;if timer still above certain point,
              cmpcy
              bcs CycleTwo               ;branch to cycle player's palette quickly
              lsr                        ;otherwise, divide by 8 to cycle every eighth frame
              lsr
CycleTwo:     lsr                        ;if branched here, divide by 2 to cycle every other frame
              jsr CyclePlayerPalette     ;do sub to cycle the palette (note: shares fire flower code)
              jmp SaveAB                 ;then skip this sub to finish up the game engine
ClrPlrPal:    jsr ResetPalStar           ;do sub to clear player's palette bits in attributes
SaveAB:       lda A_B_Buttons            ;save current A and B button
              sta PreviousA_B_Buttons    ;into temp variable to be used on next frame
              ldan ++$00
              sta Left_Right_Buttons     ;nullify left and right buttons temp variable
UpdScrollVar: lda VRAM_Buffer_AddrCtrl
              cmpn ++$06                   ;if vram address controller set to 6 (one of two $0341s) (VRAM_Buffer2)
              beq ExitEng                ;then branch to leave
              lda AreaParserTaskNum      ;otherwise check number of tasks
         checka
              bne RunParser
              lda ScrollThirtyTwo        ;get horizontal scroll in 0-31 or $00-$20 range
              cmpn ++$20                   ;check to see if exceeded $21
              bmi ExitEng                ;branch to leave if not
              lda ScrollThirtyTwo
              sbcn ++$20                   ;otherwise subtract $20 to set appropriately
              sta ScrollThirtyTwo        ;and store
              ldan ++$00                   ;reset vram buffer offset used in conjunction with
              sta VRAM_Buffer2_Offset    ;level graphics buffer at $0341-$035f
RunParser:    jsr AreaParserTaskHandler  ;update the name table with more level graphics
ExitEng:      rts                        ;and after all that, we're finally done!

;-------------------------------------------------------------------------------------

ScrollHandler:
            lda Player_X_Scroll       ;load value saved here
            clc
            adci Platform_X_Scroll     ;add value used by left/right platforms
            sta Player_X_Scroll       ;save as new value here to impose force on scroll
            lda ScrollLock            ;check scroll lock flag
         checka
            bne InitScrlAmt           ;skip a bunch of code here if set
            lda Player_Pos_ForScroll
            cmpn ++$50                  ;check player's horizontal screen position
              cmpcy
            bcc InitScrlAmt           ;if less than 80 pixels to the right, branch
            lda SideCollisionTimer    ;if timer related to player's side collision
         checka
            bne InitScrlAmt           ;not expired, branch
            ldy Player_X_Scroll       ;get value and decrement by one
            dey                       ;if value originally set to zero or otherwise
            bmi InitScrlAmt           ;negative for left movement, branch
            iny
            cpyn ++$02                  ;if value $01, branch and do not decrement
              cmpcy
            bcc ChkNearMid
            dey                       ;otherwise decrement by one
ChkNearMid: lda Player_Pos_ForScroll
            cmpn ++$70                  ;check player's horizontal screen position
              cmpcy
            bcc ScrollScreen          ;if less than 112 pixels to the right, branch
            ldy Player_X_Scroll       ;otherwise get original value undecremented

ScrollScreen:
              tya
              sta ScrollAmount          ;save value here
              clc
              adci ScrollThirtyTwo       ;add to value already set here
              sta ScrollThirtyTwo       ;save as new value here
              tya
              clc
              adci ScreenLeft_X_Pos      ;add to left side coordinate
              sta ScreenLeft_X_Pos      ;save as new left side coordinate
              sta HorizontalScroll      ;save here also
              lda ScreenLeft_PageLoc
              adcn ++$00                  ;add carry to page location for left
              sta ScreenLeft_PageLoc    ;side of the screen
              andn ++$01                  ;get LSB of page location
              sta SCRATCHPAD+$00                   ;save as temp variable for PPU register 1 mirror
              lda Mirror_PPU_CTRL_REG1  ;get PPU register 1 mirror
              andn ++%11111110            ;save all bits except d0
              orai SCRATCHPAD+$00                   ;get saved bit here and save in PPU register 1
              sta Mirror_PPU_CTRL_REG1  ;mirror to be used to set name table later
              jsr GetScreenPosition     ;figure out where the right side is
              ldan ++$08
              sta ScrollIntervalTimer   ;set scroll timer (residual, not used elsewhere)
              jmp ChkPOffscr            ;skip this part
InitScrlAmt:  ldan ++$00
              sta ScrollAmount          ;initialize value here
ChkPOffscr:   ldxn ++$00                  ;set X for player offset
              jsr GetXOffscreenBits     ;get horizontal offscreen bits for player
              sta SCRATCHPAD+$00                   ;save them here
              ldyn ++$00                  ;load default offset (left side)
              asl                       ;if d7 of offscreen bits are set, ;TODO >>4 в GetXOffscreenBits
              bcs KeepOnscr             ;branch with default offset
              iny                         ;otherwise use different offset (right side)
              lda SCRATCHPAD+$00
              andn ++%00100000              ;check offscreen bits for d5 set ;TODO >>4 в GetXOffscreenBits
              beq InitPlatScrl            ;if not set, branch ahead of this part
KeepOnscr:    lday ScreenEdge_X_Pos,y      ;get left or right side coordinate based on offset
              secsub
              sbcy X_SubtracterData,y      ;subtract amount based on offset
              sta Player_X_Position       ;store as player position to prevent movement further
              ldaykeepcy ScreenEdge_PageLoc,y    ;get left or right page location based on offset
              sbcn ++$00                    ;subtract borrow
              sta Player_PageLoc          ;save as player's page location
              lda Left_Right_Buttons      ;check saved controller bits
              cmpy OffscrJoypadBitsData,y  ;against bits based on offset
              beq InitPlatScrl            ;if not equal, branch
              ldan ++$00
              sta Player_X_Speed          ;otherwise nullify horizontal speed of player
InitPlatScrl: ldan ++$00                    ;nullify platform force imposed on scroll
              sta Platform_X_Scroll
              rts

X_SubtracterData:
      .db $00, $10

OffscrJoypadBitsData:
      .db $01, $02

;-------------------------------------------------------------------------------------

GetScreenPosition:
      lda ScreenLeft_X_Pos    ;get coordinate of screen's left boundary
      clc
      adcn ++$ff                ;add 255 pixels
      sta ScreenRight_X_Pos   ;store as coordinate of screen's right boundary
      lda ScreenLeft_PageLoc  ;get page number where left boundary is
      adcn ++$00                ;add carry from before
      sta ScreenRight_PageLoc ;store as page number where right boundary is
      rts

;-------------------------------------------------------------------------------------

GameRoutines:
      lda GameEngineSubroutine  ;run routine based on number (a few of these routines are   
      jsr JumpEngine            ;merely placeholders as conditions for other routines)

      .dw Entrance_GameTimerSetup
      .dw Vine_AutoClimb
      .dw SideExitPipeEntry
      .dw VerticalPipeEntry
      .dw FlagpoleSlide
      .dw PlayerEndLevel
      .dw PlayerLoseLife
      .dw PlayerEntrance
      .dw PlayerCtrlRoutine
      .dw PlayerChangeSize
      .dw PlayerInjuryBlink
      .dw PlayerDeath
      .dw PlayerFireFlower

;-------------------------------------------------------------------------------------

PlayerEntrance:
            lda AltEntranceControl    ;check for mode of alternate entry
            cmpn ++$02
            beq EntrMode2             ;if found, branch to enter from pipe or with vine
            ldan ++$00       
            ldy Player_Y_Position     ;if vertical position above a certain
            cpyn ++$30                  ;point, nullify controller bits and continue
              cmpcy
            bcc AutoControlPlayer     ;with player movement code, do not return
            lda PlayerEntranceCtrl    ;check player entry bits from header
            cmpn ++$06
            beq ChkBehPipe            ;if set to 6 or 7, execute pipe intro code
            cmpn ++$07                  ;otherwise branch to normal entry
            bne PlayerRdy
ChkBehPipe: lda Player_SprAttrib      ;check for sprite attributes
         checka
            bne IntroEntr             ;branch if found
            ldan ++$01
            jmp AutoControlPlayer     ;force player to walk to the right
IntroEntr:  jsr EnterSidePipe         ;execute sub to move player to the right
            deci ChangeAreaTimer       ;decrement timer for change of area
            bne ExitEntr              ;branch to exit if not yet expired
            inci DisableIntermediate   ;set flag to skip world and lives display
            jmp NextArea              ;jump to increment to next area and set modes
EntrMode2:  lda JoypadOverride        ;if controller override bits set here,
         checka
            bne VineEntr              ;branch to enter with vine
            ldan ++$ff                  ;otherwise, set value here then execute sub
            jsr MovePlayerYAxis       ;to move player upwards (note $ff = -1)
            lda Player_Y_Position     ;check to see if player is at a specific coordinate
            cmpn ++$91                  ;if player risen to a certain point (this requires pipes
              cmpcy
            bcc PlayerRdy             ;to be at specific height to look/function right) branch
            rts                       ;to the last part, otherwise leave
VineEntr:   lda VineHeight
            cmpn ++$60                  ;check vine height
            bne ExitEntr              ;if vine not yet reached maximum height, branch to leave
            lda Player_Y_Position     ;get player's vertical coordinate
            cmpn ++$99                  ;check player's vertical coordinate against preset value
              cmpcy
            ldyn ++$00                  ;load default values to be written to 
            ldan ++$01                  ;this value moves player to the right off the vine
            bcc OffVine               ;if vertical coordinate LOW  preset value, use defaults
            ldan ++$03
            sta Player_State          ;otherwise set player state to climbing
            iny                       ;increment value in Y
            ldan ++$08                  ;set block in block buffer to cover hole, then 
            sta Block_Buffer_1+$b4    ;use same value to force player to climb
OffVine:    sty DisableCollisionDet   ;set collision detection disable flag
            jsr AutoControlPlayer     ;use contents of A to move player up or right, execute sub
            lda Player_X_Position
            cmpn ++$48                  ;check player's horizontal position
              cmpcy
            bcc ExitEntr              ;if not far enough to the right, branch to leave
PlayerRdy:  ldan ++$08                  ;set routine to be executed by game engine next frame
            sta GameEngineSubroutine
            ldan ++$01                  ;set to face player to the right
            sta PlayerFacingDir
            lsr                       ;init A
            sta AltEntranceControl    ;init mode of entry
            sta DisableCollisionDet   ;init collision detection disable flag
            sta JoypadOverride        ;nullify controller override bits
ExitEntr:   rts                       ;leave!

;-------------------------------------------------------------------------------------
;$07 - used to hold upper limit of high byte when player falls down hole

AutoControlPlayer:
      sta SavedJoypadBits         ;override controller bits with contents of A if executing here

PlayerCtrlRoutine:
            lda GameEngineSubroutine    ;check task here
            cmpn ++$0b                    ;if certain value is set, branch to skip controller bit loading (playerdeath)
            beq SizeChk
            lda AreaType                ;are we in a water type area? у нас сначала 1???
         checka
            bne SaveJoyp                ;if not, branch
            ldy Player_Y_HighPos
            dey                         ;if not in vertical area between
            bne DisJoyp                 ;status bar and bottom, branch
            lda Player_Y_Position
            cmpn ++$d0                    ;if nearing the bottom of the screen or
              cmpcy
            bcc SaveJoyp                ;not in the vertical area between status bar or bottom,
DisJoyp:    ldan ++$00                    ;disable controller bits
            sta SavedJoypadBits
SaveJoyp:   lda SavedJoypadBits         ;otherwise store A and B buttons in $0a
            andn ++%11000000
            sta A_B_Buttons
            lda SavedJoypadBits         ;store left and right buttons in $0c
            andn ++%00000011
            sta Left_Right_Buttons
            lda SavedJoypadBits         ;store up and down buttons in $0b
            andn ++%00001100
            sta Up_Down_Buttons
            andn ++%00000100              ;check for pressing down
            beq SizeChk                 ;if not, branch
            lda Player_State            ;check player's state
         checka
            bne SizeChk                 ;if not on the ground, branch
            ldy Left_Right_Buttons      ;check left and right
         checky
            beq SizeChk                 ;if neither pressed, branch
            ldan ++$00
            sta Left_Right_Buttons      ;if pressing down while on the ground,
            sta Up_Down_Buttons         ;nullify directional bits
SizeChk:    jsr PlayerMovementSubs      ;run movement subroutines
            ldyn ++$01                    ;is player small?
            lda PlayerSize
         checka
            bne ChkMoveDir
            ldyn ++$00                    ;check for if crouching
            lda CrouchingFlag
         checka
            beq ChkMoveDir              ;if not, branch ahead
            ldyn ++$02                    ;if big and crouching, load y with 2
ChkMoveDir: sty Player_BoundBoxCtrl     ;set contents of Y as player's bounding box size control
            ldan ++$01                    ;set moving direction to right by default
            ldy Player_X_Speed          ;check player's horizontal speed
         checky
            beq PlayerSubs              ;if not moving at all horizontally, skip this part
            bpl SetMoveDir              ;if moving to the right, use default moving direction
            asl                         ;otherwise change to move to the left
SetMoveDir: sta Player_MovingDir        ;set moving direction
PlayerSubs: jsr ScrollHandler           ;move the screen if necessary
            jsr GetPlayerOffscreenBits  ;get player's offscreen bits
            jsr RelativePlayerPosition  ;get coordinates relative to the screen
            ldxn ++$00                    ;set offset for player object
            jsr BoundingBoxCore         ;get player's bounding box coordinates
            jsr PlayerBGCollision       ;do collision detection and process
            lda Player_Y_Position
            cmpn ++$40                    ;check to see if player is higher than 64th pixel
              cmpcy
            bcc PlayerHole              ;if so, branch ahead
            lda GameEngineSubroutine
            cmpn ++$05                    ;if running end-of-level routine, branch ahead
            beq PlayerHole
            cmpn ++$07                    ;if running player entrance routine, branch ahead
            beq PlayerHole
            cmpn ++$04                    ;if running routines $00-$03, branch ahead
              cmpcy
            bcc PlayerHole
            lda Player_SprAttrib
            andn ++%11011111              ;otherwise nullify player's
            sta Player_SprAttrib        ;background priority flag
PlayerHole: lda Player_Y_HighPos        ;check player's vertical high byte
            cmpn ++$02                    ;for below the screen
            bmi ExitCtrl                ;branch to leave if not that far down
            ldxn ++$01
            stx ScrollLock              ;set scroll lock
            ldyn ++$04
            sty SCRATCHPAD+$07                     ;set value here
            ldxn ++$00                    ;use X as flag, and clear for cloud level
            ldy GameTimerExpiredFlag    ;check game timer expiration flag
         checky
            bne HoleDie                 ;if set, branch
            ldy CloudTypeOverride       ;check for cloud type override
         checky
            bne ChkHoleX                ;skip to last part if found
HoleDie:    inx                         ;set flag in X for player death
            ldy GameEngineSubroutine
            cpyn ++$0b                    ;check for some other routine running (playerdeath)
            beq ChkHoleX                ;if so, branch ahead
            ldy DeathMusicLoaded        ;check value here
         checky
            bne HoleBottom              ;if already set, branch to next part
            iny
            sty EventMusicQueue         ;otherwise play death music
            sty DeathMusicLoaded        ;and set value here
HoleBottom: ldyn ++$06
            sty SCRATCHPAD+$07                     ;change value here
ChkHoleX:   cmpi SCRATCHPAD+$07                     ;compare vertical high byte with value set here
            bmi ExitCtrl                ;if less, branch to leave
            dex                         ;otherwise decrement flag in X
            bmi CloudExit               ;if flag was clear, branch to set modes and other values
            ldy EventMusicBuffer        ;check to see if music is still playing
         checky
            bne ExitCtrl                ;branch to leave if so
            ldan ++$06                    ;otherwise set to run lose life routine
            sta GameEngineSubroutine    ;on next frame
ExitCtrl:   rts                         ;leave

CloudExit:
      ldan ++$00
      sta JoypadOverride      ;clear controller override bits if any are set
      jsr SetEntr             ;do sub to set secondary mode
      inci AltEntranceControl  ;set mode of entry to 3
      rts

;-------------------------------------------------------------------------------------

Vine_AutoClimb:
           lda Player_Y_HighPos   ;check to see whether player reached position
         checka
           bne AutoClimb          ;above the status bar yet and if so, set modes
           lda Player_Y_Position
           cmpn ++$e4
              cmpcy
           bcc SetEntr
AutoClimb: ldan ++%00001000         ;set controller bits override to up
           sta JoypadOverride
           ldyn ++$03               ;set player state to climbing
           sty Player_State
           jmp AutoControlPlayer
SetEntr:   ldan ++$02               ;set starting position to override
           sta AltEntranceControl
           jmp ChgAreaMode        ;set modes

;-------------------------------------------------------------------------------------

VerticalPipeEntry:
      ldan ++$01             ;set 1 as movement amount
      jsr MovePlayerYAxis  ;do sub to move player downwards
      jsr ScrollHandler    ;do sub to scroll screen with saved force if necessary
      ldyn ++$00             ;load default mode of entry
      lda WarpZoneControl  ;check warp zone control variable/flag
         checka
      bne ChgAreaPipe      ;if set, branch to use mode 0
      iny
      lda AreaType         ;check for castle level type
      cmpn ++$03
      bne ChgAreaPipe      ;if not castle type level, use mode 1
      iny
      jmp ChgAreaPipe      ;otherwise use mode 2

MovePlayerYAxis:
      clc
      adci Player_Y_Position ;add contents of A to player position
      sta Player_Y_Position
      rts

;-------------------------------------------------------------------------------------

SideExitPipeEntry:
             jsr EnterSidePipe         ;execute sub to move player to the right
             ldyn ++$02
ChgAreaPipe: deci ChangeAreaTimer       ;decrement timer for change of area
             bne ExitCAPipe
             sty AltEntranceControl    ;when timer expires set mode of alternate entry
ChgAreaMode: inci DisableScreenFlag     ;set flag to disable screen output
             ldan ++$00
             sta OperMode_Task         ;set secondary mode of operation
             sta Sprite0HitDetectFlag  ;disable sprite 0 check
ExitCAPipe:  rts                       ;leave

EnterSidePipe:
           ldan ++$08               ;set player's horizontal speed
           sta Player_X_Speed
           ldyn ++$01               ;set controller right button by default
           lda Player_X_Position  ;mask out higher nybble of player's
           andn ++%00001111         ;horizontal position
           bne RightPipe
           sta Player_X_Speed     ;if lower nybble = 0, set as horizontal speed
           tay                    ;and nullify controller bit override here
RightPipe: tya                    ;use contents of Y to
           jsr AutoControlPlayer  ;execute player control routine with ctrl bits nulled
           rts

;-------------------------------------------------------------------------------------

PlayerChangeSize:
             lda TimerControl    ;check master timer control
             cmpn ++$f8            ;for specific moment in time
             bne EndChgSize      ;branch if before or after that point
             jmp InitChangeSize  ;otherwise run code to get growing/shrinking going
EndChgSize:  cmpn ++$c4            ;check again for another specific moment
             bne ExitChgSize     ;and branch to leave if before or after that point
             jsr DonePlayerTask  ;otherwise do sub to init timer control and set routine
ExitChgSize: rts                 ;and then leave

;-------------------------------------------------------------------------------------

PlayerInjuryBlink:
           lda TimerControl       ;check master timer control
           cmpn ++$f0               ;for specific moment in time
              cmpcy
           bcs ExitBlink          ;branch if before that point
           cmpn ++$c8               ;check again for another specific point
           beq DonePlayerTask     ;branch if at that point, and not before or after
           jmp PlayerCtrlRoutine  ;otherwise run player control routine
ExitBlink: bne ExitBoth           ;do unconditional branch to leave

InitChangeSize:
          ldy PlayerChangeSizeFlag  ;if growing/shrinking flag already set
         checky
          bne ExitBoth              ;then branch to leave
          sty PlayerAnimCtrl        ;otherwise initialize player's animation frame control
          inci PlayerChangeSizeFlag  ;set growing/shrinking flag
          lda PlayerSize
          eorn ++$01                  ;invert player's size
          sta PlayerSize
ExitBoth: rts                       ;leave

;-------------------------------------------------------------------------------------
;$00 - used in CyclePlayerPalette to store current palette to cycle

PlayerDeath:
      lda TimerControl       ;check master timer control
      cmpn ++$f0               ;for specific moment in time
              cmpcy
      bcs ExitDeath          ;branch to leave if before that point
      jmp PlayerCtrlRoutine  ;otherwise run player control routine

DonePlayerTask:
      ldan ++$00
      sta TimerControl          ;initialize master timer control to continue timers
      ldan ++$08
      sta GameEngineSubroutine  ;set player control routine to run next frame
      rts                       ;leave

PlayerFireFlower: 
      lda TimerControl       ;check master timer control
      cmpn ++$c0               ;for specific moment in time
      beq ResetPalFireFlower ;branch if at moment, not before or after
      lda FrameCounter       ;get frame counter
      lsr
      lsr                    ;divide by four to change every four frames

CyclePlayerPalette:
	if Z80MARIOCYCLECOLOR
	ld hl,(curpalette)
	ld e,12*2
	add hl,de
	ld a,(hl)
	xor 0xf3
	ld (hl),a
	inc hl
	ld (hl),a
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	xor 0xf3
	ld (hl),a
	inc hl
	ld (hl),a
	else
      andn ++$03              ;mask out all but d1-d0 (previously d3-d2)
      sta SCRATCHPAD+$00               ;store result here to use as palette bits
      lda Player_SprAttrib  ;get player attributes
      andn ++%11111100        ;save any other bits but palette bits
      orai SCRATCHPAD+$00               ;add palette bits
      sta Player_SprAttrib  ;store as new player attributes
        endif
      rts                   ;and leave

ResetPalFireFlower:
      jsr DonePlayerTask    ;do sub to init timer control and run player control routine

ResetPalStar:
	if Z80MARIOCYCLECOLOR
	if 1
	jp GetPlayerColors
	else
	ld hl,(curpalette)
	ld e,12*2
	add hl,de
	ld a,(hl)
	xor 0xf3
	ld (hl),a
	inc hl
	ld (hl),a
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	xor 0xf3
	ld (hl),a
	inc hl
	ld (hl),a
	ret
	endif
	else
      lda Player_SprAttrib  ;get player attributes
      andn ++%11111100        ;mask out palette bits to force palette 0
      sta Player_SprAttrib  ;store as new player attributes
      rts                   ;and leave
        endif

ExitDeath:
      rts          ;leave from death routine

;-------------------------------------------------------------------------------------

FlagpoleSlide:
             lda Enemy_ID+5           ;check special use enemy slot
             cmpn ++FlagpoleFlagObject  ;for flagpole flag object
             bne NoFPObj              ;if not found, branch to something residual
             lda FlagpoleSoundQueue   ;load flagpole sound
             sta Square1SoundQueue    ;into square 1's sfx queue
             ldan ++$00
             sta FlagpoleSoundQueue   ;init flagpole sound queue
             ldy Player_Y_Position
             cpyn ++$9e                 ;check to see if player has slid down
              cmpcy
             bcs SlidePlayer          ;far enough, and if so, branch with no controller bits set
             ldan ++$04                 ;otherwise force player to climb down (to slide)
SlidePlayer: jmp AutoControlPlayer    ;jump to player control routine
NoFPObj:     inci GameEngineSubroutine ;increment to next routine (this may
             rts                      ;be residual code)

;-------------------------------------------------------------------------------------

Hidden1UpCoinAmts:
      .db $15, $23, $16, $1b, $17, $18, $23, $63

PlayerEndLevel:
        if MUSICONINT ;костыль: делаем до выхода из уровня режим MUSICONINT=0
     ;YIELD
     ;ld b,0
     ;ld d,b
     halt
        ;ld hl,0xffff
        ;ld (EventMusicQueue_noint),hl
        ld hl,SoundEngine
        ld (soundenginepatch),hl
        ld a,0x21
        ld (soundenginecall),a
        endif
          ldan ++$01                  ;force player to walk to the right
          jsr AutoControlPlayer
          lda Player_Y_Position     ;check player's vertical position
          cmpn ++$ae
              cmpcy
          bcc ChkStop               ;if player is not yet off the flagpole, skip this part
          lda ScrollLock            ;if scroll lock not set, branch ahead to next part
         checka
          beq ChkStop               ;because we only need to do this part once
          ldan ++EndOfLevelMusic
          sta EventMusicQueue       ;load win level music in event music queue
          ldan ++$00
          sta ScrollLock            ;turn off scroll lock to skip this part later
ChkStop:  lda Player_CollisionBits  ;get player collision bits
          lsr                       ;check for d0 set
          bcs RdyNextA              ;if d0 set, skip to next part
          lda StarFlagTaskControl   ;if star flag task control already set,
         checka
          bne InCastle              ;go ahead with the rest of the code
          inci StarFlagTaskControl   ;otherwise set task control now (this gets ball rolling!)
InCastle: ldan ++%00100000            ;set player's background priority bit to
          sta Player_SprAttrib      ;give illusion of being inside the castle
RdyNextA: lda StarFlagTaskControl
          cmpn ++$05                  ;if star flag task control not yet set
          bne ExitNA                ;beyond last valid task number, branch to leave
          inci LevelNumber           ;increment level number used for game logic
          lda LevelNumber
          cmpn ++$03                  ;check to see if we have yet reached level -4
          bne NextArea              ;and skip this last part here if not
          ldy WorldNumber           ;get world number as offset
          lda CoinTallyFor1Ups      ;check third area coin tally for bonus 1-ups
          cmpy Hidden1UpCoinAmts,y   ;against minimum value, if player has not collected
              cmpcy
          bcc NextArea              ;at least this number of coins, leave flag clear
          inci Hidden1UpFlag         ;otherwise set hidden 1-up box control flag
NextArea: inci AreaNumber            ;increment area number used for address loader
          jsr LoadAreaPointer       ;get new level pointer
          inci FetchNewGameTimerFlag ;set flag to load new game timer
          jsr ChgAreaMode           ;do sub to set secondary mode, disable screen and sprite 0
          sta HalfwayPage           ;reset halfway page to 0 (beginning)
          ldan ++Silence
          sta EventMusicQueue       ;silence music and leave
ExitNA:   rts

;-------------------------------------------------------------------------------------

PlayerMovementSubs:
           ldan ++$00                  ;set A to init crouch flag by default
           ldy PlayerSize            ;is player small?
         checky
           bne SetCrouch             ;if so, branch
           lda Player_State          ;check state of player
         checka
           bne ProcMove              ;if not on the ground, branch
           lda Up_Down_Buttons       ;load controller bits for up and down
           andn ++%00000100            ;single out bit for down button
SetCrouch: sta CrouchingFlag         ;store value in crouch flag
ProcMove:  jsr PlayerPhysicsSub      ;run sub related to jumping and swimming
           lda PlayerChangeSizeFlag  ;if growing/shrinking flag set,
         checka
           bne NoMoveSub             ;branch to leave
           lda Player_State
           cmpn ++$03                  ;get player state
           beq MoveSubs              ;if climbing, branch ahead, leave timer unset
           ldyn ++$18
           sty ClimbSideTimer        ;otherwise reset timer now
MoveSubs:  jsr JumpEngine

      .dw OnGroundStateSub
      .dw JumpSwimSub
      .dw FallingSub
      .dw ClimbingSub

NoMoveSub: rts

;-------------------------------------------------------------------------------------
;$00 - used by ClimbingSub to store high vertical adder

OnGroundStateSub:
         jsr GetPlayerAnimSpeed     ;do a sub to set animation frame timing
         lda Left_Right_Buttons
         checka
         beq GndMove                ;if left/right controller bits not set, skip instruction
         ;jr $ ;сюда редко попадаем по кнопкам left,right
         sta PlayerFacingDir        ;otherwise set new facing direction
GndMove: jsr ImposeFriction         ;do a sub to impose friction on player's walk/run
         jsr MovePlayerHorizontally ;do another sub to move player horizontally
         sta Player_X_Scroll        ;set returned value as player's movement speed for scroll
         rts

;--------------------------------

FallingSub:
      lda VerticalForceDown
      sta VerticalForce      ;dump vertical movement force for falling into main one
      jmp LRAir              ;movement force, then skip ahead to process left/right movement

;--------------------------------

JumpSwimSub:
          ldy Player_Y_Speed         ;if player's vertical speed zero
         checky
          bpl DumpFall               ;or moving downwards, branch to falling
          lda A_B_Buttons
          andn ++A_Button              ;check to see if A button is being pressed
          andi PreviousA_B_Buttons    ;and was pressed in previous frame
          bne ProcSwim               ;if so, branch elsewhere
          lda JumpOrigin_Y_Position  ;get vertical position player jumped from
          secsub
          sbci Player_Y_Position      ;subtract current from original vertical coordinate
          cmpi DiffToHaltJump         ;compare to value set here to see if player is in mid-jump
              cmpcy
          bcc ProcSwim               ;or just starting to jump, if just starting, skip ahead
DumpFall: lda VerticalForceDown      ;otherwise dump falling into main fractional
          sta VerticalForce
ProcSwim: lda SwimmingFlag           ;if swimming flag not set, ;у нас сначала 0???
         checka
          beq LRAir                  ;branch ahead to last part
          jsr GetPlayerAnimSpeed     ;do a sub to get animation frame timing
          lda Player_Y_Position
          cmpn ++$14                   ;check vertical position against preset value
              cmpcy
          bcs LRWater                ;if not yet reached a certain position, branch ahead
          ldan ++$18
          sta VerticalForce          ;otherwise set fractional
LRWater:  lda Left_Right_Buttons     ;check left/right controller bits (check for swimming)
         checka
          beq LRAir                  ;if not pressing any, skip
          sta PlayerFacingDir        ;otherwise set facing direction accordingly
;сюда вход ещё из FallingSub
LRAir:    lda Left_Right_Buttons     ;check left/right controller bits (check for jumping/falling)
         checka
          beq JSMove                 ;if not pressing any, skip
          jsr ImposeFriction         ;otherwise process horizontal movement
JSMove:   jsr MovePlayerHorizontally ;do a sub to move player horizontally
          sta Player_X_Scroll        ;set player's speed here, to be used for scroll later
          lda GameEngineSubroutine
          cmpn ++$0b                   ;check for specific routine selected (playerdeath)
          bne ExitMov1               ;branch if not set to run
          ldan ++$28
          sta VerticalForce          ;otherwise set fractional
ExitMov1: jmp MovePlayerVertically   ;jump to move player vertically, then leave

;--------------------------------

ClimbAdderLow:
      .db $0e, $04, $fc, $f2
ClimbAdderHigh:
      .db $00, $00, $ff, $ff

ClimbingSub:
             lda Player_YMF_Dummy
             clc                      ;add movement force to dummy variable
             adci Player_Y_MoveForce   ;save with carry
             sta Player_YMF_Dummy
             ldyn ++$00                 ;set default adder here
             lda Player_Y_Speed       ;get player's vertical speed
         checka
             bpl MoveOnVine           ;if not moving upwards, branch
             dey                      ;otherwise set adder to $ff
MoveOnVine:  sty SCRATCHPAD+$00                  ;store adder here
             adci Player_Y_Position    ;add carry to player's vertical position
             sta Player_Y_Position    ;and store to move player up or down
             lda Player_Y_HighPos
             adci SCRATCHPAD+$00                  ;add carry to player's page location
             sta Player_Y_HighPos     ;and store
             lda Left_Right_Buttons   ;compare left/right controller bits
             andi Player_CollisionBits ;to collision flag
             beq InitCSTimer          ;if not set, skip to end
             ldy ClimbSideTimer       ;otherwise check timer 
         checky
             bne ExitCSub             ;if timer not expired, branch to leave
             ldyn ++$18
             sty ClimbSideTimer       ;otherwise set timer now
             ldxn ++$00                 ;set default offset here
             ldy PlayerFacingDir      ;get facing direction
             lsr                      ;move right button controller bit to carry
             bcs ClimbFD              ;if controller right pressed, branch ahead
             inx
             inx                      ;otherwise increment offset by 2 bytes
ClimbFD:     dey                      ;check to see if facing right
             beq CSetFDir             ;if so, branch, do not increment
             inx                      ;otherwise increment by 1 byte
CSetFDir:    lda Player_X_Position
             clc                      ;add or subtract from player's horizontal position
             adcx ClimbAdderLow,x      ;using value here as adder and X as offset
             sta Player_X_Position
             lda Player_PageLoc       ;add or subtract carry or borrow using value here
             adcx ClimbAdderHigh,x     ;from the player's page location
             sta Player_PageLoc
             lda Left_Right_Buttons   ;get left/right controller bits again
             eorn ++%00000011           ;invert them and store them while player
             sta PlayerFacingDir      ;is on vine to face player in opposite direction
ExitCSub:    rts                      ;then leave
InitCSTimer: sta ClimbSideTimer       ;initialize timer here
             rts

;-------------------------------------------------------------------------------------
;$00 - used to store offset to friction data

JumpMForceData:
      .db $20, $20, $1e, $28, $28, $0d, $04

FallMForceData:
      .db $70, $70, $60, $90, $90, $0a, $09

PlayerYSpdData:
      .db $fc, $fc, $fc, $fb, $fb, $fe, $ff

InitMForceData:
      .db $00, $00, $00, $00, $00, $80, $00

MaxLeftXSpdData:
      .db $d8, $e8, $f0

MaxRightXSpdData:
      .db $28, $18, $10
      .db $0c ;used for pipe intros

FrictionData:
      .db $e4, $98, $d0

Climb_Y_SpeedData:
      .db $00, $ff, $01

Climb_Y_MForceData:
      .db $00, $20, $ff

PlayerPhysicsSub:
           lda Player_State          ;check player state
           cmpn ++$03
           bne CheckForJumping       ;if not climbing, branch
           ldyn ++$00
           lda Up_Down_Buttons       ;get controller bits for up/down
           andi Player_CollisionBits  ;check against player's collision detection bits
           beq ProcClimb             ;if not pressing up or down, branch
           iny
           andn ++%00001000            ;check for pressing up
           bne ProcClimb
           iny
ProcClimb: ldxy Climb_Y_MForceData,y  ;load value here
           stx Player_Y_MoveForce    ;store as vertical movement force
           ldan ++$08                  ;load default animation timing
           ldxy Climb_Y_SpeedData,y   ;load some other value here
           stx Player_Y_Speed        ;store as vertical speed
         checkx
           bmi SetCAnim              ;if climbing down, use default animation timing value
           lsr                       ;otherwise divide timer setting by 2
SetCAnim:  sta PlayerAnimTimerSet    ;store animation timer setting and leave
           rts

CheckForJumping:
        lda JumpspringAnimCtrl    ;if jumpspring animating, 
         checka
        bne NoJump                ;skip ahead to something else
        lda A_B_Buttons           ;check for A button press
        andn ++A_Button
        beq NoJump                ;if not, branch to something else
        andi PreviousA_B_Buttons   ;if button not pressed in previous frame, branch
        beq ProcJumping
NoJump: jmp X_Physics             ;otherwise, jump to something else

ProcJumping:
           lda Player_State           ;check player state
         checka
           beq InitJS                 ;if on the ground, branch
           lda SwimmingFlag           ;if swimming flag not set, jump to do something else
         checka
           beq NoJump                 ;to prevent midair jumping, otherwise continue
           lda JumpSwimTimer          ;if jump/swim timer nonzero, branch
         checka
           bne InitJS
           lda Player_Y_Speed         ;check player's vertical speed
         checka
           bpl InitJS                 ;if player's vertical speed motionless or down, branch
           jmp X_Physics              ;if timer at zero and player still rising, do not swim
InitJS:    ldan ++$20                   ;set jump/swim timer
           sta JumpSwimTimer
           ldyn ++$00                   ;initialize vertical force and dummy variable
           sty Player_YMF_Dummy
           sty Player_Y_MoveForce
           lda Player_Y_HighPos       ;get vertical high and low bytes of jump origin
           sta JumpOrigin_Y_HighPos   ;and store them next to each other here
           lda Player_Y_Position
           sta JumpOrigin_Y_Position
           ldan ++$01                   ;set player state to jumping/swimming
           sta Player_State
           lda Player_XSpeedAbsolute  ;check value related to walking/running speed
           cmpn ++$09
              cmpcy
           bcc ChkWtr                 ;branch if below certain values, increment Y
           iny                        ;for each amount equal or exceeded
           cmpn ++$10
              cmpcy
           bcc ChkWtr
           iny
           cmpn ++$19
              cmpcy
           bcc ChkWtr
           iny
           cmpn ++$1c
              cmpcy
           bcc ChkWtr                 ;note that for jumping, range is 0-4 for Y
           iny
ChkWtr:    ldan ++$01                   ;set value here (apparently always set to 1)
           sta DiffToHaltJump
           lda SwimmingFlag           ;if swimming flag disabled, branch
         checka
           beq GetYPhy
           ldyn ++$05                   ;otherwise set Y to 5, range is 5-6
           lda Whirlpool_Flag         ;if whirlpool flag not set, branch
         checka
           beq GetYPhy
           iny                        ;otherwise increment to 6
GetYPhy:   lday JumpMForceData,y       ;store appropriate jump/swim
           sta VerticalForce          ;data here
           lday FallMForceData,y
           sta VerticalForceDown
           lday InitMForceData,y
           sta Player_Y_MoveForce
           lday PlayerYSpdData,y
           sta Player_Y_Speed
           lda SwimmingFlag           ;if swimming flag disabled, branch
         checka
           beq PJumpSnd
           ldan ++Sfx_EnemyStomp        ;load swim/goomba stomp sound into
           sta Square1SoundQueue      ;square 1's sfx queue
           lda Player_Y_Position
           cmpn ++$14                   ;check vertical low byte of player position
              cmpcy
           bcs X_Physics              ;if below a certain point, branch
           ldan ++$00                   ;otherwise reset player's vertical speed
           sta Player_Y_Speed         ;and jump to something else to keep player
           jmp X_Physics              ;from swimming above water level
PJumpSnd:  ldan ++Sfx_BigJump           ;load big mario's jump sound by default
           ldy PlayerSize             ;is mario big?
         checky
           beq SJumpSnd
           ldan ++Sfx_SmallJump         ;if not, load small mario's jump sound
SJumpSnd:  sta Square1SoundQueue      ;store appropriate jump sound in square 1 sfx queue
X_Physics: ldyn ++$00
           sty SCRATCHPAD+$00                    ;init value here
           lda Player_State           ;if mario is on the ground, branch
         checka
           beq ProcPRun
           lda Player_XSpeedAbsolute  ;check something that seems to be related
           cmpn ++$19                   ;to mario's speed
              cmpcy
           bcs GetXPhy                ;if => $19 branch here
           bcc ChkRFast               ;if not branch elsewhere
ProcPRun:  iny                        ;if mario on the ground, increment Y
           lda AreaType               ;check area type
         checka
           beq ChkRFast               ;if water type, branch
           dey                        ;decrement Y by default for non-water type area
           lda Left_Right_Buttons     ;get left/right controller bits
           cmpi Player_MovingDir       ;check against moving direction
           bne ChkRFast               ;if controller bits <> moving direction, skip this part
           lda A_B_Buttons            ;check for b button pressed
           andn ++B_Button
           bne SetRTmr                ;if pressed, skip ahead to set timer
           lda RunningTimer           ;check for running timer set
         checka
           bne GetXPhy                ;if set, branch
ChkRFast:  iny                        ;if running timer not set or level type is water, 
           inci SCRATCHPAD+$00                    ;increment Y again and temp variable in memory
           lda RunningSpeed
         checka
           bne FastXSp                ;if running speed set here, branch
           lda Player_XSpeedAbsolute
           cmpn ++$21                   ;otherwise check player's walking/running speed
              cmpcy
           bcc GetXPhy                ;if less than a certain amount, branch ahead
FastXSp:   inci SCRATCHPAD+$00                    ;if running speed set or speed => $21 increment $00
           jmp GetXPhy                ;and jump ahead
SetRTmr:   ldan ++$0a                   ;if b button pressed, set running timer
           sta RunningTimer
GetXPhy:   lday MaxLeftXSpdData,y      ;get maximum speed to the left
           sta MaximumLeftSpeed
           lda GameEngineSubroutine   ;check for specific routine running
           cmpn ++$07                   ;(player entrance)
           bne GetXPhy2               ;if not running, skip and use old value of Y
           ldyn ++$03                   ;otherwise set Y to 3
GetXPhy2:  lday MaxRightXSpdData,y     ;get maximum speed to the right
           sta MaximumRightSpeed
           ldy SCRATCHPAD+$00                    ;get other value in memory
           lday FrictionData,y         ;get value using value in memory as offset
           sta FrictionAdderLow
           ldan ++$00
           sta FrictionAdderHigh      ;init something here
           lda PlayerFacingDir
           cmpi Player_MovingDir       ;check facing direction against moving direction
           beq ExitPhy                ;if the same, branch to leave
           asli FrictionAdderLow       ;otherwise shift d7 of friction adder low into carry
           roli FrictionAdderHigh      ;then rotate carry onto d0 of friction adder high
ExitPhy:   rts                        ;and then leave

;-------------------------------------------------------------------------------------

PlayerAnimTmrData:
      .db $02, $04, $07

GetPlayerAnimSpeed:
            ldyn ++$00                   ;initialize offset in Y
            lda Player_XSpeedAbsolute  ;check player's walking/running speed
            cmpn ++$1c                   ;against preset amount
              cmpcy
            bcs SetRunSpd              ;if greater than a certain amount, branch ahead
            iny                        ;otherwise increment Y
            cmpn ++$0e                   ;compare against lower amount
              cmpcy
            bcs ChkSkid                ;if greater than this but not greater than first, skip increment
            iny                        ;otherwise increment Y again
ChkSkid:    lda SavedJoypadBits        ;get controller bits
            andn ++%01111111             ;mask out A button
            beq SetAnimSpd             ;if no other buttons pressed, branch ahead of all this
            andn ++$03                   ;mask out all others except left and right
            cmpi Player_MovingDir       ;check against moving direction
            bne ProcSkid               ;if left/right controller bits <>  moving direction, branch
            ldan ++$00                   ;otherwise set zero value here
SetRunSpd:  sta RunningSpeed           ;store zero or running speed here
            jmp SetAnimSpd
ProcSkid:   lda Player_XSpeedAbsolute  ;check player's walking/running speed
            cmpn ++$0b                   ;against one last amount
              cmpcy
            bcs SetAnimSpd             ;if greater than this amount, branch
            lda PlayerFacingDir
            sta Player_MovingDir       ;otherwise use facing direction to set moving direction
            ldan ++$00
            sta Player_X_Speed         ;nullify player's horizontal speed
            sta Player_X_MoveForce     ;and dummy variable for player (младшая часть X-координаты)
SetAnimSpd: lday PlayerAnimTmrData,y    ;get animation timer setting using Y as offset
            sta PlayerAnimTimerSet
            rts

;-------------------------------------------------------------------------------------

ImposeFriction:
           andi Player_CollisionBits  ;perform AND between left/right controller bits and collision flag
           cmpn ++$00                  ;then compare to zero (this instruction is redundant)
           bne JoypFrict             ;if any bits set, branch to next part
           lda Player_X_Speed
         checka
           beq SetAbsSpd             ;if player has no horizontal speed, branch ahead to last part
           bpl RghtFrict             ;if player moving to the right, branch to slow
           bmi LeftFrict             ;otherwise logic dictates player moving left, branch to slow
JoypFrict: lsr                       ;put right controller bit into carry
           bcc RghtFrict             ;if left button pressed, carry = 0, thus branch
LeftFrict: lda Player_X_MoveForce    ;load value set here (младшая часть X-координаты)
           clc
           adci FrictionAdderLow      ;add to it another value set here (почему??? это же не младшая часть скорости!)
           sta Player_X_MoveForce    ;store here (младшая часть X-координаты)
           lda Player_X_Speed
           adci FrictionAdderHigh     ;add value plus carry to horizontal speed
           sta Player_X_Speed        ;set as new horizontal speed
           cmpi MaximumRightSpeed     ;compare against maximum value for right movement
           bmi XSpdSign              ;if horizontal speed greater negatively, branch
           lda MaximumRightSpeed     ;otherwise set preset value as horizontal speed
           sta Player_X_Speed        ;thus slowing the player's left movement down
           jmp SetAbsSpd             ;skip to the end
RghtFrict: lda Player_X_MoveForce    ;load value set here (младшая часть X-координаты)
           secsub
           sbci FrictionAdderLow      ;subtract from it another value set here (почему??? это же не младшая часть скорости!)
           sta Player_X_MoveForce    ;store here (младшая часть X-координаты)
           lda Player_X_Speed
           sbci FrictionAdderHigh     ;subtract value plus borrow from horizontal speed
           sta Player_X_Speed        ;set as new horizontal speed
           cmpi MaximumLeftSpeed      ;compare against maximum value for left movement
           bpl XSpdSign              ;if horizontal speed greater positively, branch
           lda MaximumLeftSpeed      ;otherwise set preset value as horizontal speed
           sta Player_X_Speed        ;thus slowing the player's right movement down
XSpdSign:  cmpn ++$00                  ;if player not moving or moving to the right,
           bpl SetAbsSpd             ;branch and leave horizontal speed value unmodified
           eorn ++$ff
           clc                       ;otherwise get two's compliment to get absolute
           adcn ++$01                  ;unsigned walking/running speed
SetAbsSpd: sta Player_XSpeedAbsolute ;store walking/running speed here and leave
           rts

;-------------------------------------------------------------------------------------
;$00 - used to store downward movement force in FireballObjCore
;$02 - used to store maximum vertical speed in FireballObjCore
;$07 - used to store pseudorandom bit in BubbleCheck

ProcFireball_Bubble:
      lda PlayerStatus           ;check player's status
      cmpn ++$02
              cmpcy
      bcc ProcAirBubbles         ;if not fiery, branch
      lda A_B_Buttons
      andn ++B_Button              ;check for b button pressed
      beq ProcFireballs          ;branch if not pressed
      andi PreviousA_B_Buttons
      bne ProcFireballs          ;if button pressed in previous frame, branch
      lda FireballCounter        ;load fireball counter
      andn ++%00000001             ;get LSB and use as offset for buffer
      tax
      ldax Fireball_State,x       ;load fireball state
         checka
      bne ProcFireballs          ;if not inactive, branch
      ldy Player_Y_HighPos       ;if player too high or too low, branch
      dey
      bne ProcFireballs
      lda CrouchingFlag          ;if player crouching, branch
         checka
      bne ProcFireballs
      lda Player_State           ;if player's state = climbing, branch
      cmpn ++$03
      beq ProcFireballs
      ldan ++Sfx_Fireball          ;play fireball sound effect
      sta Square1SoundQueue
      ldan ++$02                   ;load state
      stax Fireball_State,x
      ldy PlayerAnimTimerSet     ;copy animation frame timer setting
      sty FireballThrowingTimer  ;into fireball throwing timer
      dey
      sty PlayerAnimTimer        ;decrement and store in player's animation timer
      inci FireballCounter        ;increment fireball counter

ProcFireballs:
      ldxn ++$00
      jsr FireballObjCore  ;process first fireball object
      ldxn ++$01
      jsr FireballObjCore  ;process second fireball object, then do air bubbles

ProcAirBubbles:
          lda AreaType                ;if not water type level, skip the rest of this
         checka
          bne BublExit
          ldxn ++$02                    ;otherwise load counter and use as offset
BublLoop: stx ObjectOffset            ;store offset
          jsr BubbleCheck             ;check timers and coordinates, create air bubble
          jsr RelativeBubblePosition  ;get relative coordinates
          jsr GetBubbleOffscreenBits  ;get offscreen information
          jsr DrawBubble              ;draw the air bubble
          dex
          bpl BublLoop                ;do this until all three are handled
BublExit: rts                         ;then leave

FireballXSpdData:
      .db $40, $c0

FireballObjCore:
         stx ObjectOffset             ;store offset as current object
         ldax Fireball_State,x         ;check for d7 = 1
         asl
         bcs FireballExplosion        ;if so, branch to get relative coordinates and draw explosion
         ldyx Fireball_State,x         ;if fireball inactive, branch to leave
         checky
         beq NoFBall
         dey                          ;if fireball state set to 1, skip this part and just run it
         beq RunFB
         lda Player_X_Position        ;get player's horizontal position
        or a
         adcn ++$04                     ;add four pixels and store as fireball's horizontal position
        push af
         stax Fireball_X_Position,x
        pop af
         lda Player_PageLoc           ;get player's page location
         adcn ++$00                     ;add carry and store as fireball's page location
         stax Fireball_PageLoc,x
         lda Player_Y_Position        ;get player's vertical position and store
         stax Fireball_Y_Position,x
         ldan ++$01                     ;set high byte of vertical position
         stax Fireball_Y_HighPos,x
         ldy PlayerFacingDir          ;get player's facing direction
         dey                          ;decrement to use as offset here
         lday FireballXSpdData,y       ;set horizontal speed of fireball accordingly
         stax Fireball_X_Speed,x
         ldan ++$04                     ;set vertical speed of fireball
         stax Fireball_Y_Speed,x
         ldan ++$07
         stax Fireball_BoundBoxCtrl,x  ;set bounding box size control for fireball
         decx Fireball_State,x         ;decrement state to 1 to skip this part from now on
RunFB:   txa                          ;add 7 to offset to use
         clc                          ;as fireball offset for next routines
         adcn ++$07
         tax
         ldan ++$50                     ;set downward movement force here
         sta SCRATCHPAD+$00
         ldan ++$03                     ;set maximum speed here
         sta SCRATCHPAD+$02
         ldan ++$00
         jsr ImposeGravity            ;do sub here to impose gravity on fireball and move vertically
         jsr MoveObjectHorizontally   ;do another sub to move it horizontally
         ldx ObjectOffset             ;return fireball offset to X
         jsr RelativeFireballPosition ;get relative coordinates
         jsr GetFireballOffscreenBits ;get offscreen information
         jsr GetFireballBoundBox      ;get bounding box coordinates
         jsr FireballBGCollision      ;do fireball to background collision detection
         lda FBall_OffscreenBits      ;get fireball offscreen bits
         andn ++%11001100               ;mask out certain bits
         bne EraseFB                  ;if any bits still set, branch to kill fireball
         jsr FireballEnemyCollision   ;do fireball to enemy collision detection and deal with collisions
         jmp DrawFireball             ;draw fireball appropriately and leave
EraseFB: ldan ++$00                     ;erase fireball state
         stax Fireball_State,x
NoFBall: rts                          ;leave

FireballExplosion:
      jsr RelativeFireballPosition
      jmp DrawExplosion_Fireball

BubbleCheck:
      ldax PseudoRandomBitReg+1,x  ;get part of LSFR
      andn ++$01
      sta SCRATCHPAD+$07                     ;store pseudorandom bit here
      ldax Bubble_Y_Position,x     ;get vertical coordinate for air bubble
      cmpn ++$f8                    ;if offscreen coordinate not set,
      bne MoveBubl                ;branch to move air bubble
      lda AirBubbleTimer          ;if air bubble timer not expired,
         checka
      bne ExitBubl                ;branch to leave, otherwise create new air bubble

SetupBubble:
          ldyn ++$00                 ;load default value here
          lda PlayerFacingDir      ;get player's facing direction
          lsr                      ;move d0 to carry
          bcc PosBubl              ;branch to use default value if facing left
          ldyn ++$08                 ;otherwise load alternate value here
PosBubl:  tya                      ;use value loaded as adder
          adci Player_X_Position    ;add to player's horizontal position
         push af
          stax Bubble_X_Position,x  ;save as horizontal position for airbubble
         pop af
          lda Player_PageLoc
          adcn ++$00                 ;add carry to player's page location
          stax Bubble_PageLoc,x     ;save as page location for airbubble
          lda Player_Y_Position
          clc                      ;add eight pixels to player's vertical position
          adcn ++$08
          stax Bubble_Y_Position,x  ;save as vertical position for air bubble
          ldan ++$01
          stax Bubble_Y_HighPos,x   ;set vertical high byte for air bubble
          ldy SCRATCHPAD+$07                  ;get pseudorandom bit, use as offset
          lday BubbleTimerData,y    ;get data for air bubble timer
          sta AirBubbleTimer       ;set air bubble timer
MoveBubl: ldy SCRATCHPAD+$07                  ;get pseudorandom bit again, use as offset
          ldax Bubble_YMF_Dummy,x
          secsub                      ;subtract pseudorandom amount from dummy variable
          sbcy Bubble_MForceData,y
               push af
          stax Bubble_YMF_Dummy,x   ;save dummy variable
          ldax Bubble_Y_Position,x
               ld h,a
               pop af
               ld a,h
          sbcn ++$00                 ;subtract borrow from airbubble's vertical coordinate
          cmpn ++$20                 ;if below the status bar,
              cmpcy
          bcs Y_Bubl               ;branch to go ahead and use to move air bubble upwards
          ldan ++$f8                 ;otherwise set offscreen coordinate
Y_Bubl:   stax Bubble_Y_Position,x  ;store as new vertical coordinate for air bubble
ExitBubl: rts                      ;leave

Bubble_MForceData:
      .db $ff, $50

BubbleTimerData:
      .db $40, $20

;-------------------------------------------------------------------------------------

RunGameTimer:
           lda OperMode               ;get primary mode of operation
         checka
           beq ExGTimer               ;branch to leave if in title screen mode
           lda GameEngineSubroutine
           cmpn ++$08                   ;if routine number less than eight running,
              cmpcy
           bcc ExGTimer               ;branch to leave
           cmpn ++$0b                   ;if running death routine,
           beq ExGTimer               ;branch to leave
           lda Player_Y_HighPos
           cmpn ++$02                   ;if player below the screen,
              cmpcy
           bcs ExGTimer               ;branch to leave regardless of level type
           lda GameTimerCtrlTimer     ;if game timer control not yet expired,
         checka
           bne ExGTimer               ;branch to leave
           lda GameTimerDisplay
           orai GameTimerDisplay+1     ;otherwise check game timer digits
           orai GameTimerDisplay+2
           beq TimeUpOn               ;if game timer digits at 000, branch to time-up code
           ldy GameTimerDisplay       ;otherwise check first digit
           dey                        ;if first digit not on 1,
           bne ResGTCtrl              ;branch to reset game timer control
           lda GameTimerDisplay+1     ;otherwise check second and third digits
           orai GameTimerDisplay+2
           bne ResGTCtrl              ;if timer not at 100, branch to reset game timer control
           ldan ++TimeRunningOutMusic
           sta EventMusicQueue        ;otherwise load time running out music
ResGTCtrl: ldan ++$18                   ;reset game timer control
           sta GameTimerCtrlTimer
           ldyn ++$23                   ;set offset for last digit
           ldan ++$ff                   ;set value to decrement game timer digit
           sta DigitModifier+5
           jsr DigitsMathRoutine      ;do sub to decrement game timer slowly
           ldan ++$a4                   ;set status nybbles to update game timer display
           jmp PrintStatusBarNumbers  ;do sub to update the display
TimeUpOn:  sta PlayerStatus           ;init player status (note A will always be zero here)
           jsr ForceInjury            ;do sub to kill the player (note player is small here)
           inci GameTimerExpiredFlag   ;set game timer expiration flag
ExGTimer:  rts                        ;leave

;-------------------------------------------------------------------------------------

WarpZoneObject:
      lda ScrollLock         ;check for scroll lock flag
         checka
      beq ExGTimer           ;branch if not set to leave
      lda Player_Y_Position  ;check to see if player's vertical coordinate has
      andi Player_Y_HighPos   ;same bits set as in vertical high byte (why?)
      bne ExGTimer           ;if so, branch to leave
      sta ScrollLock         ;otherwise nullify scroll lock flag
      inci WarpZoneControl    ;increment warp zone flag to make warp pipes for warp zone
      jmp EraseEnemyObject   ;kill this object

;-------------------------------------------------------------------------------------
;$00 - used in WhirlpoolActivate to store whirlpool length / 2, page location of center of whirlpool
;and also to store movement force exerted on player
;$01 - used in ProcessWhirlpools to store page location of right extent of whirlpool
;and in WhirlpoolActivate to store center of whirlpool
;$02 - used in ProcessWhirlpools to store right extent of whirlpool and in
;WhirlpoolActivate to store maximum vertical speed

ProcessWhirlpools:
        lda AreaType                ;check for water type level
         checka
        bne ExitWh                  ;branch to leave if not found
        sta Whirlpool_Flag          ;otherwise initialize whirlpool flag
        lda TimerControl            ;if master timer control set,
         checka
        bne ExitWh                  ;branch to leave
        ldyn ++$04                    ;otherwise start with last whirlpool data
WhLoop: lday Whirlpool_LeftExtent,y  ;get left extent of whirlpool
        clc
        adcy Whirlpool_Length,y      ;add length of whirlpool
        sta SCRATCHPAD+$02                     ;store result as right extent here
        ldaykeepcy Whirlpool_PageLoc,y     ;get page location
         checka
        beq NextWh                  ;if none or page 0, branch to get next data
        adcn ++$00                    ;add carry
        sta SCRATCHPAD+$01                     ;store result as page location of right extent here
        lda Player_X_Position       ;get player's horizontal position
        secsub
        sbcy Whirlpool_LeftExtent,y  ;subtract left extent
        lda Player_PageLoc          ;get player's page location
        sbcy Whirlpool_PageLoc,y     ;subtract borrow
        bmi NextWh                  ;if player too far left, branch to get next data
        lda SCRATCHPAD+$02                     ;otherwise get right extent
        secsub
        sbci Player_X_Position       ;subtract player's horizontal coordinate
        lda SCRATCHPAD+$01                     ;get right extent's page location
        sbci Player_PageLoc          ;subtract borrow
        bpl WhirlpoolActivate       ;if player within right extent, branch to whirlpool code
NextWh: dey                         ;move onto next whirlpool data
        bpl WhLoop                  ;do this until all whirlpools are checked
ExitWh: rts                         ;leave

WhirlpoolActivate:
        lday Whirlpool_Length,y      ;get length of whirlpool
        lsr                         ;divide by 2
        sta SCRATCHPAD+$00                     ;save here
        lday Whirlpool_LeftExtent,y  ;get left extent of whirlpool
        clc
        adci SCRATCHPAD+$00                     ;add length divided by 2
        sta SCRATCHPAD+$01                     ;save as center of whirlpool
        ldaykeepcy Whirlpool_PageLoc,y     ;get page location
        adcn ++$00                    ;add carry
        sta SCRATCHPAD+$00                     ;save as page location of whirlpool center
        lda FrameCounter            ;get frame counter
        lsr                         ;shift d0 into carry (to run on every other frame)
        bcc WhPull                  ;if d0 not set, branch to last part of code
        lda SCRATCHPAD+$01                     ;get center
        secsub
        sbci Player_X_Position       ;subtract player's horizontal coordinate
        lda SCRATCHPAD+$00                     ;get page location of center
        sbci Player_PageLoc          ;subtract borrow
        bpl LeftWh                  ;if player to the left of center, branch
        lda Player_X_Position       ;otherwise slowly pull player left, towards the center
        secsub
        sbcn ++$01                    ;subtract one pixel
        sta Player_X_Position       ;set player's new horizontal coordinate
        lda Player_PageLoc
        sbcn ++$00                    ;subtract borrow
        jmp SetPWh                  ;jump to set player's new page location
LeftWh: lda Player_CollisionBits    ;get player's collision bits
        lsr                         ;shift d0 into carry
        bcc WhPull                  ;if d0 not set, branch
        lda Player_X_Position       ;otherwise slowly pull player right, towards the center
        clc
        adcn ++$01                    ;add one pixel
        sta Player_X_Position       ;set player's new horizontal coordinate
        lda Player_PageLoc
        adcn ++$00                    ;add carry
SetPWh: sta Player_PageLoc          ;set player's new page location
WhPull: ldan ++$10
        sta SCRATCHPAD+$00                     ;set vertical movement force
        ldan ++$01
        sta Whirlpool_Flag          ;set whirlpool flag to be used later
        sta SCRATCHPAD+$02                     ;also set maximum vertical speed
        lsr
        tax                         ;set X for player offset
        jmp ImposeGravity           ;jump to put whirlpool effect on player vertically, do not return

;-------------------------------------------------------------------------------------

FlagpoleScoreMods:
      .db $05, $02, $08, $04, $01

FlagpoleScoreDigits:
      .db $03, $03, $04, $04, $04

FlagpoleRoutine:
           ldxn ++$05                  ;set enemy object offset
           stx ObjectOffset          ;to special use slot
           ldax Enemy_ID,x
           cmpn ++FlagpoleFlagObject   ;if flagpole flag not found,
           bne ExitFlagP             ;branch to leave
           lda GameEngineSubroutine
           cmpn ++$04                  ;if flagpole slide routine not running,
           bne SkipScore             ;branch to near the end of code
           lda Player_State
           cmpn ++$03                  ;if player state not climbing,
           bne SkipScore             ;branch to near the end of code
           ldax Enemy_Y_Position,x    ;check flagpole flag's vertical coordinate
           cmpn ++$aa                  ;if flagpole flag down to a certain point,
              cmpcy
           bcs GiveFPScr             ;branch to end the level
           lda Player_Y_Position     ;check player's vertical coordinate
           cmpn ++$a2                  ;if player down to a certain point,
              cmpcy
           bcs GiveFPScr             ;branch to end the level
           ldax Enemy_YMF_Dummy,x
          or a
           adcn ++$ff                  ;add movement amount to dummy variable
          push af
           stax Enemy_YMF_Dummy,x     ;save dummy variable
           ldax Enemy_Y_Position,x    ;get flag's vertical coordinate
          ld h,a
          pop af
          ld a,h
           adcn ++$01                  ;add 1 plus carry to move flag, and
           stax Enemy_Y_Position,x    ;store vertical coordinate
           lda FlagpoleFNum_YMFDummy
           secsub                       ;subtract movement amount from dummy variable
           sbcn ++$ff
           sta FlagpoleFNum_YMFDummy ;save dummy variable
           lda FlagpoleFNum_Y_Pos
           sbcn ++$01                  ;subtract one plus borrow to move floatey number,
           sta FlagpoleFNum_Y_Pos    ;and store vertical coordinate here
SkipScore: jmp FPGfx                 ;jump to skip ahead and draw flag and floatey number
GiveFPScr: ldy FlagpoleScore         ;get score offset from earlier (when player touched flagpole)
           lday FlagpoleScoreMods,y   ;get amount to award player points
           ldxy FlagpoleScoreDigits,y ;get digit with which to award points
           stax DigitModifier,x       ;store in digit modifier
           jsr AddToScore            ;do sub to award player points depending on height of collision
           ldan ++$05
           sta GameEngineSubroutine  ;set to run end-of-level subroutine on next frame
FPGfx:     jsr GetEnemyOffscreenBits ;get offscreen information
           jsr RelativeEnemyPosition ;get relative coordinates
           jsr FlagpoleGfxHandler    ;draw flagpole flag and floatey number
ExitFlagP: rts

;-------------------------------------------------------------------------------------

Jumpspring_Y_PosData:
      .db $08, $10, $08, $00

JumpspringHandler:
           jsr GetEnemyOffscreenBits   ;get offscreen information
           lda TimerControl            ;check master timer control
         checka
           bne DrawJSpr                ;branch to last section if set
           lda JumpspringAnimCtrl      ;check jumpspring frame control
         checka
           beq DrawJSpr                ;branch to last section if not set
           tay
           dey                         ;subtract one from frame control,
           tya                         ;the only way a poor nmos 6502 can
           andn ++%00000010              ;mask out all but d1, original value still in Y
           bne DownJSpr                ;if set, branch to move player up
           inci Player_Y_Position
           inci Player_Y_Position       ;move player's vertical position down two pixels
           jmp PosJSpr                 ;skip to next part
DownJSpr:  deci Player_Y_Position       ;move player's vertical position up two pixels
           deci Player_Y_Position
PosJSpr:   ldax Jumpspring_FixedYPos,x  ;get permanent vertical position
           clc
           adcy Jumpspring_Y_PosData,y  ;add value using frame control as offset
           stax Enemy_Y_Position,x      ;store as new vertical position
           cpyn ++$01                    ;check frame control offset (second frame is $00)
              cmpcy
           bcc BounceJS                ;if offset not yet at third frame ($01), skip to next part
           lda A_B_Buttons
           andn ++A_Button               ;check saved controller bits for A button press
           beq BounceJS                ;skip to next part if A not pressed
           andi PreviousA_B_Buttons     ;check for A button pressed in previous frame
           bne BounceJS                ;skip to next part if so
           ldan ++$f4
           sta JumpspringForce         ;otherwise write new jumpspring force here
BounceJS:  cpyn ++$03                    ;check frame control offset again
           bne DrawJSpr                ;skip to last part if not yet at fifth frame ($03)
           lda JumpspringForce
           sta Player_Y_Speed          ;store jumpspring force as player's new vertical speed
           ldan ++$00
           sta JumpspringAnimCtrl      ;initialize jumpspring frame control
DrawJSpr:  jsr RelativeEnemyPosition   ;get jumpspring's relative coordinates
           jsr EnemyGfxHandler         ;draw jumpspring
           jsr OffscreenBoundsCheck    ;check to see if we need to kill it
           lda JumpspringAnimCtrl      ;if frame control at zero, don't bother
         checka
           beq ExJSpring               ;trying to animate it, just leave
           lda JumpspringTimer
         checka
           bne ExJSpring               ;if jumpspring timer not expired yet, leave
           ldan ++$04
           sta JumpspringTimer         ;otherwise initialize jumpspring timer
           inci JumpspringAnimCtrl      ;increment frame control to animate jumpspring
ExJSpring: rts                         ;leave

;-------------------------------------------------------------------------------------

Setup_Vine:
        ldan ++VineObject          ;load identifier for vine object
        stax Enemy_ID,x           ;store in buffer
        ldan ++$01
        stax Enemy_Flag,x         ;set flag for enemy object buffer
        lday Block_PageLoc,y
        stax Enemy_PageLoc,x      ;copy page location from previous object
        lday Block_X_Position,y
        stax Enemy_X_Position,x   ;copy horizontal coordinate from previous object
        lday Block_Y_Position,y
        stax Enemy_Y_Position,x   ;copy vertical coordinate from previous object
        ldy VineFlagOffset       ;load vine flag/offset to next available vine slot
         checky
        bne NextVO               ;if set at all, don't bother to store vertical
        sta VineStart_Y_Position ;otherwise store vertical coordinate here
NextVO: txa                      ;store object offset to next available vine slot
        stay VineObjOffset,y      ;using vine flag as offset
        inci VineFlagOffset       ;increment vine flag offset
        ldan ++Sfx_GrowVine
        sta Square2SoundQueue    ;load vine grow sound
        rts

;-------------------------------------------------------------------------------------
;$06-$07 - used as address to block buffer data
;$02 - used as vertical high nybble of block buffer offset

VineHeightData:
      .db $30, $60

VineObjectHandler:
           cpxn ++$05                  ;check enemy offset for special use slot
           bne ExitVH                ;if not in last slot, branch to leave
           ldy VineFlagOffset
           dey                       ;decrement vine flag in Y, use as offset
           lda VineHeight
           cmpy VineHeightData,y      ;if vine has reached certain height,
           beq RunVSubs              ;branch ahead to skip this part
           lda FrameCounter          ;get frame counter
           lsr                       ;shift d1 into carry
           lsr
           bcc RunVSubs              ;if d1 not set (2 frames every 4) skip this part
           lda Enemy_Y_Position+5
          or a
           sbcn ++$01                  ;subtract vertical position of vine
           sta Enemy_Y_Position+5    ;one pixel every frame it's time
           inci VineHeight            ;increment vine height
RunVSubs:  lda VineHeight            ;if vine still very small,
           cmpn ++$08                  ;branch to leave
              cmpcy
           bcc ExitVH
           jsr RelativeEnemyPosition ;get relative coordinates of vine,
           jsr GetEnemyOffscreenBits ;and any offscreen bits
           ldyn ++$00                  ;initialize offset used in draw vine sub
VDrawLoop: jsr DrawVine              ;draw vine
           iny                       ;increment offset
           cpyi VineFlagOffset        ;if offset in Y and offset here
           bne VDrawLoop             ;do not yet match, loop back to draw more vine
           lda Enemy_OffscreenBits
           andn ++%00001100            ;mask offscreen bits
           beq WrCMTile              ;if none of the saved offscreen bits set, skip ahead
           dey                       ;otherwise decrement Y to get proper offset again
KillVine:  ldxy VineObjOffset,y       ;get enemy object offset for this vine object
           jsr EraseEnemyObject      ;kill this vine object
           dey                       ;decrement Y
           bpl KillVine              ;if any vine objects left, loop back to kill it
           sta VineFlagOffset        ;initialize vine flag/offset
           sta VineHeight            ;initialize vine height
WrCMTile:  lda VineHeight            ;check vine height
           cmpn ++$20                  ;if vine small (less than 32 pixels tall)
              cmpcy
           bcc ExitVH                ;then branch ahead to leave
           ldxn ++$06                  ;set offset in X to last enemy slot
           ldan ++$01                  ;set A to obtain horizontal in $04, but we don't care
           ldyn ++$1b                  ;set Y to offset to get block at ($04, $10) of coordinates
           jsr BlockBufferCollision  ;do a sub to get block buffer address set, return contents
           ldy SCRATCHPAD+$02
           cpyn ++$d0                  ;if vertical high nybble offset beyond extent of
              cmpcy
           bcs ExitVH                ;current block buffer, branch to leave, do not write
           ldayindirect (SCRATCHPAD+$06),y               ;otherwise check contents of block buffer at 
         checka
           bne ExitVH                ;current offset, if not empty, branch to leave
           ldan ++$26
           stayindirect (SCRATCHPAD+$06),y               ;otherwise, write climbing metatile to block buffer
ExitVH:    ldx ObjectOffset          ;get enemy object offset and leave
           rts

;-------------------------------------------------------------------------------------

CannonBitmasks:
      .db %00001111, %00000111

ProcessCannons:
           lda AreaType                ;get area type
         checka
           beq ExCannon                ;if water type area, branch to leave
           ldxn ++$02
ThreeSChk: stx ObjectOffset            ;start at third enemy slot
           ldax Enemy_Flag,x            ;check enemy buffer flag
         checka
           bne Chk_BB                  ;if set, branch to check enemy
           ldax PseudoRandomBitReg+1,x  ;otherwise get part of LSFR
           ldy SecondaryHardMode       ;get secondary hard mode flag, use as offset
           andy CannonBitmasks,y        ;mask out bits of LSFR as decided by flag
           cmpn ++$06                    ;check to see if lower nybble is above certain value
              cmpcy
           bcs Chk_BB                  ;if so, branch to check enemy
           tay                         ;transfer masked contents of LSFR to Y as pseudorandom offset
           lday Cannon_PageLoc,y        ;get page location
         checka
           beq Chk_BB                  ;if not set or on page 0, branch to check enemy
           lday Cannon_Timer,y          ;get cannon timer
         checka
           beq FireCannon              ;if expired, branch to fire cannon
          scf
           sbcn ++$00                    ;otherwise subtract borrow (note carry will always be clear here)
           stay Cannon_Timer,y          ;to count timer down
           jmp Chk_BB                  ;then jump ahead to check enemy

FireCannon:
          lda TimerControl           ;if master timer control set,
         checka
          bne Chk_BB                 ;branch to check enemy
          ldan ++$0e                   ;otherwise we start creating one
          stay Cannon_Timer,y         ;first, reset cannon timer
          lday Cannon_PageLoc,y       ;get page location of cannon
          stax Enemy_PageLoc,x        ;save as page location of bullet bill
          lday Cannon_X_Position,y    ;get horizontal coordinate of cannon
          stax Enemy_X_Position,x     ;save as horizontal coordinate of bullet bill
          lday Cannon_Y_Position,y    ;get vertical coordinate of cannon
          secsub
          sbcn ++$08                   ;subtract eight pixels (because enemies are 24 pixels tall)
          stax Enemy_Y_Position,x     ;save as vertical coordinate of bullet bill
          ldan ++$01
          stax Enemy_Y_HighPos,x      ;set vertical high byte of bullet bill
          stax Enemy_Flag,x           ;set buffer flag
          lsr                        ;shift right once to init A
          stax Enemy_State,x          ;then initialize enemy's state
          ldan ++$09
          stax Enemy_BoundBoxCtrl,x   ;set bounding box size control for bullet bill
          ldan ++BulletBill_CannonVar
          stax Enemy_ID,x             ;load identifier for bullet bill (cannon variant)
          jmp Next3Slt               ;move onto next slot
Chk_BB:   ldax Enemy_ID,x             ;check enemy identifier for bullet bill (cannon variant)
          cmpn ++BulletBill_CannonVar
          bne Next3Slt               ;if not found, branch to get next slot
          jsr OffscreenBoundsCheck   ;otherwise, check to see if it went offscreen
          ldax Enemy_Flag,x           ;check enemy buffer flag
         checka
          beq Next3Slt               ;if not set, branch to get next slot
          jsr GetEnemyOffscreenBits  ;otherwise, get offscreen information
          jsr BulletBillHandler      ;then do sub to handle bullet bill
Next3Slt: dex                        ;move onto next slot
          bpl ThreeSChk              ;do this until first three slots are checked
ExCannon: rts                        ;then leave

;--------------------------------

BulletBillXSpdData:
      .db $18, $e8

BulletBillHandler:
           lda TimerControl          ;if master timer control set,
         checka
           bne RunBBSubs             ;branch to run subroutines except movement sub
           ldax Enemy_State,x
         checka
           bne ChkDSte               ;if bullet bill's state set, branch to check defeated state
           lda Enemy_OffscreenBits   ;otherwise load offscreen bits
           andn ++%00001100            ;mask out bits
           cmpn ++%00001100            ;check to see if all bits are set
           beq KillBB                ;if so, branch to kill this object
           ldyn ++$01                  ;set to move right by default
           jsr PlayerEnemyDiff       ;get horizontal difference between player and bullet bill
           bmi SetupBB               ;if enemy to the left of player, branch
           iny                       ;otherwise increment to move left
SetupBB:   
         push af
           styx Enemy_MovingDir,x     ;set bullet bill's moving direction
           dey                       ;decrement to use as offset
           lday BulletBillXSpdData,y  ;get horizontal speed based on moving direction
           stax Enemy_X_Speed,x       ;and store it
           lda SCRATCHPAD+$00                   ;get horizontal difference
         ld h,a
         pop af
         ld a,h
           adcn ++$28                  ;add 40 pixels
           cmpn ++$50                  ;if less than a certain amount, player is too close
              cmpcy
           bcc KillBB                ;to cannon either on left or right side, thus branch
           ldan ++$01
           stax Enemy_State,x         ;otherwise set bullet bill's state
           ldan ++$0a
           stax EnemyFrameTimer,x     ;set enemy frame timer
           ldan ++Sfx_Blast
           sta Square2SoundQueue     ;play fireworks/gunfire sound
ChkDSte:   ldax Enemy_State,x         ;check enemy state for d5 set
           andn ++%00100000
           beq BBFly                 ;if not set, skip to move horizontally
           jsr MoveD_EnemyVertically ;otherwise do sub to move bullet bill vertically
BBFly:     jsr MoveEnemyHorizontally ;do sub to move bullet bill horizontally
RunBBSubs: jsr GetEnemyOffscreenBits ;get offscreen information
           jsr RelativeEnemyPosition ;get relative coordinates
           jsr GetEnemyBoundBox      ;get bounding box coordinates
           jsr PlayerEnemyCollision  ;handle player to enemy collisions
           jmp EnemyGfxHandler       ;draw the bullet bill and leave
KillBB:    jsr EraseEnemyObject      ;kill bullet bill and leave
           rts

;-------------------------------------------------------------------------------------

HammerEnemyOfsData:
      .db $04, $04, $04, $05, $05, $05
      .db $06, $06, $06

HammerXSpdData:
      .db $10, $f0

SpawnHammerObj:
          lda PseudoRandomBitReg+1 ;get pseudorandom bits from
          andn ++%00000111           ;second part of LSFR
          bne SetMOfs              ;if any bits are set, branch and use as offset
          lda PseudoRandomBitReg+1
          andn ++%00001000           ;get d3 from same part of LSFR
SetMOfs:  tay                      ;use either d3 or d2-d0 for offset here
          lday Misc_State,y         ;if any values loaded in
         checka
          bne NoHammer             ;$2a-$32 where offset is then leave with carry clear
          ldxy HammerEnemyOfsData,y ;get offset of enemy slot to check using Y as offset
          ldax Enemy_Flag,x         ;check enemy buffer flag at offset
         checka
          bne NoHammer             ;if buffer flag set, branch to leave with carry clear
          ldx ObjectOffset         ;get original enemy object offset
          txa
          stay HammerEnemyOffset,y  ;save here
          ldan ++$90
          stay Misc_State,y         ;save hammer's state here
          ldan ++$07
          stay Misc_BoundBoxCtrl,y  ;set something else entirely, here
          sec                      ;return with carry set
          rts
NoHammer: ldx ObjectOffset         ;get original enemy object offset
          clc                      ;return with carry clear
          rts

;--------------------------------
;$00 - used to set downward force
;$01 - used to set upward force (residual)
;$02 - used to set maximum speed

ProcHammerObj:
          lda TimerControl           ;if master timer control set
         checka
          bne RunHSubs               ;skip all of this code and go to last subs at the end
          ldax Misc_State,x           ;otherwise get hammer's state
          andn ++%01111111             ;mask out d7
          ldyx HammerEnemyOffset,x    ;get enemy object offset that spawned this hammer
          cmpn ++$02                   ;check hammer's state
              cmpcy
          beq SetHSpd                ;if currently at 2, branch
          bcs SetHPos                ;if greater than 2, branch elsewhere
          txa
          clc                        ;add 13 bytes to use
          adcn ++$0d                   ;proper misc object
          tax                        ;return offset to X
          ldan ++$10
          sta SCRATCHPAD+$00                    ;set downward movement force
          ldan ++$0f
          sta SCRATCHPAD+$01                    ;set upward movement force (not used)
          ldan ++$04
          sta SCRATCHPAD+$02                    ;set maximum vertical speed
          ldan ++$00                   ;set A to impose gravity on hammer
          jsr ImposeGravity          ;do sub to impose gravity on hammer and move vertically
          jsr MoveObjectHorizontally ;do sub to move it horizontally
          ldx ObjectOffset           ;get original misc object offset
          jmp RunAllH                ;branch to essential subroutines
SetHSpd:  ldan ++$fe
          stax Misc_Y_Speed,x         ;set hammer's vertical speed
          lday Enemy_State,y          ;get enemy object state
          andn ++%11110111             ;mask out d3
          stay Enemy_State,y          ;store new state
          ldxy Enemy_MovingDir,y      ;get enemy's moving direction
          dex                        ;decrement to use as offset
          ldax HammerXSpdData,x       ;get proper speed to use based on moving direction
          ldx ObjectOffset           ;reobtain hammer's buffer offset
          stax Misc_X_Speed,x         ;set hammer's horizontal speed
SetHPos:  decx Misc_State,x           ;decrement hammer's state
          lday Enemy_X_Position,y     ;get enemy's horizontal position
          clc
          adcn ++$02                   ;set position 2 pixels to the right
         push af
          stax Misc_X_Position,x      ;store as hammer's horizontal position
          lday Enemy_PageLoc,y        ;get enemy's page location
         ld h,a
         pop af
         ld a,h
          adcn ++$00                   ;add carry
          stax Misc_PageLoc,x         ;store as hammer's page location
          lday Enemy_Y_Position,y     ;get enemy's vertical position
          secsub
          sbcn ++$0a                   ;move position 10 pixels upward
          stax Misc_Y_Position,x      ;store as hammer's vertical position
          ldan ++$01
          stax Misc_Y_HighPos,x       ;set hammer's vertical high byte
         checka
          bne RunHSubs               ;unconditional branch to skip first routine
RunAllH:  jsr PlayerHammerCollision  ;handle collisions
RunHSubs: jsr GetMiscOffscreenBits   ;get offscreen information
          jsr RelativeMiscPosition   ;get relative coordinates
          jsr GetMiscBoundBox        ;get bounding box coordinates
          jsr DrawHammer             ;draw the hammer
          rts                        ;and we are done here

;-------------------------------------------------------------------------------------
;$02 - used to store vertical high nybble offset from block buffer routine
;$06 - used to store low byte of block buffer address

CoinBlock:
      jsr FindEmptyMiscSlot   ;set offset for empty or last misc object buffer slot
;CY = 1(no subtract borrow)???
      ldax Block_PageLoc,x     ;get page location of block object
      stay Misc_PageLoc,y      ;store as page location of misc object
      ldax Block_X_Position,x  ;get horizontal coordinate of block object
      oran ++$05                ;add 5 pixels
      stay Misc_X_Position,y   ;store as horizontal coordinate of misc object
      ldax Block_Y_Position,x  ;get vertical coordinate of block object
     or a ;???
      sbcn ++$10                ;subtract 16 pixels
      stay Misc_Y_Position,y   ;store as vertical coordinate of misc object
      jmp JCoinC              ;jump to rest of code as applies to this misc object

SetupJumpCoin:
        jsr FindEmptyMiscSlot  ;set offset for empty or last misc object buffer slot
        ldax Block_PageLoc2,x   ;get page location saved earlier
        stay Misc_PageLoc,y     ;and save as page location for misc object
        lda SCRATCHPAD+$06                ;get low byte of block buffer offset
        asl
        asl                    ;multiply by 16 to use lower nybble
        asl
        asl
       push af
        oran ++$05               ;add five pixels
        stay Misc_X_Position,y  ;save as horizontal coordinate for misc object
        lda SCRATCHPAD+$02                ;get vertical high nybble offset from earlier
       ld h,a
       pop af
       ld a,h
        adcn ++$20               ;add 32 pixels for the status bar
        stay Misc_Y_Position,y  ;store as vertical coordinate
JCoinC: ldan ++$fb
        stay Misc_Y_Speed,y     ;set vertical speed
        ldan ++$01
        stay Misc_Y_HighPos,y   ;set vertical high byte
        stay Misc_State,y       ;set state for misc object
        sta Square2SoundQueue  ;load coin grab sound
        stx ObjectOffset       ;store current control bit as misc object offset 
        jsr GiveOneCoin        ;update coin tally on the screen and coin amount variable
        inci CoinTallyFor1Ups   ;increment coin tally used to activate 1-up block flag
        rts

FindEmptyMiscSlot:
           ldyn ++$08                ;start at end of misc objects buffer
FMiscLoop: lday Misc_State,y        ;get misc object state
         checka
           beq UseMiscS            ;branch if none found to use current offset
           dey                     ;decrement offset
           cpyn ++$05                ;do this for three slots
           bne FMiscLoop           ;do this until all slots are checked
           ldyn ++$08                ;if no empty slots found, use last slot
UseMiscS:  sty JumpCoinMiscOffset  ;store offset of misc object buffer here (residual)
           rts

;-------------------------------------------------------------------------------------

MiscObjectsCore:
          ldxn ++$08          ;set at end of misc object buffer
MiscLoop: stx ObjectOffset  ;store misc object offset here
          ldax Misc_State,x  ;check misc object state
         checka
          beq MiscLoopBack  ;branch to check next slot
          asl               ;otherwise shift d7 into carry
          bcc ProcJumpCoin  ;if d7 not set, jumping coin, thus skip to rest of code here
          jsr ProcHammerObj ;otherwise go to process hammer,
          jmp MiscLoopBack  ;then check next slot

;--------------------------------
;$00 - used to set downward force
;$01 - used to set upward force (residual)
;$02 - used to set maximum speed

ProcJumpCoin:
           ldyx Misc_State,x          ;check misc object state
           dey                       ;decrement to see if it's set to 1
           beq JCoinRun              ;if so, branch to handle jumping coin
           incx Misc_State,x          ;otherwise increment state to either start off or as timer
           ldax Misc_X_Position,x     ;get horizontal coordinate for misc object
           clc                       ;whether its jumping coin (state 0 only) or floatey number
           adci ScrollAmount          ;add current scroll speed
          push af
           stax Misc_X_Position,x     ;store as new horizontal coordinate
           ldax Misc_PageLoc,x        ;get page location
          ld h,a
          pop af
          ld a,h
           adcn ++$00                  ;add carry
           stax Misc_PageLoc,x        ;store as new page location
           ldax Misc_State,x
           cmpn ++$30                  ;check state of object for preset value
           bne RunJCSubs             ;if not yet reached, branch to subroutines
           ldan ++$00
           stax Misc_State,x          ;otherwise nullify object state
           jmp MiscLoopBack          ;and move onto next slot
JCoinRun:  txa             
           clc                       ;add 13 bytes to offset for next subroutine
           adcn ++$0d
           tax
           ldan ++$50                  ;set downward movement amount
           sta SCRATCHPAD+$00
           ldan ++$06                  ;set maximum vertical speed
           sta SCRATCHPAD+$02
           lsr                       ;divide by 2 and set
           sta SCRATCHPAD+$01                   ;as upward movement amount (apparently residual)
           ldan ++$00                  ;set A to impose gravity on jumping coin
           jsr ImposeGravity         ;do sub to move coin vertically and impose gravity on it
           ldx ObjectOffset          ;get original misc object offset
           ldax Misc_Y_Speed,x        ;check vertical speed
           cmpn ++$05
           bne RunJCSubs             ;if not moving downward fast enough, keep state as-is
           incx Misc_State,x          ;otherwise increment state to change to floatey number
RunJCSubs: jsr RelativeMiscPosition  ;get relative coordinates
           jsr GetMiscOffscreenBits  ;get offscreen information
           jsr GetMiscBoundBox       ;get bounding box coordinates (why?)
           jsr JCoinGfxHandler       ;draw the coin or floatey number

MiscLoopBack: 
           dex                       ;decrement misc object offset
           bpl MiscLoop              ;loop back until all misc objects handled
           rts                       ;then leave

;-------------------------------------------------------------------------------------

CoinTallyOffsets:
      .db $17, $1d

ScoreOffsets:
      .db $0b, $11

StatusBarNybbles:
      .db $02, $13

GiveOneCoin:
      ldan ++$01               ;set digit modifier to add 1 coin
      sta DigitModifier+5    ;to the current player's coin tally
      ldx CurrentPlayer      ;get current player on the screen
      ldyx CoinTallyOffsets,x ;get offset for player's coin tally
      jsr DigitsMathRoutine  ;update the coin tally
      inci CoinTally          ;increment onscreen player's coin amount
      lda CoinTally
      cmpn ++100               ;does player have 100 coins yet?
      bne CoinPoints         ;if not, skip all of this
      ldan ++$00
      sta CoinTally          ;otherwise, reinitialize coin amount
      inci NumberofLives      ;give the player an extra life
      ldan ++Sfx_ExtraLife
      sta Square2SoundQueue  ;play 1-up sound

CoinPoints:
      ldan ++$02               ;set digit modifier to award
      sta DigitModifier+4    ;200 points to the player

AddToScore:
      ldx CurrentPlayer      ;get current player
      ldyx ScoreOffsets,x     ;get offset for player's score
      jsr DigitsMathRoutine  ;update the score internally with value in digit modifier

GetSBNybbles:
      ldy CurrentPlayer      ;get current player
      lday StatusBarNybbles,y ;get nybbles based on player, use to update score and coins

UpdateNumber:
        jsr PrintStatusBarNumbers ;print status bar numbers based on nybbles, whatever they be
        ldy VRAM_Buffer1_Offset   
        lday VRAM_Buffer1-6,y      ;check highest digit of score
         checka
        bne NoZSup                ;if zero, overwrite with space tile for zero suppression
        ldan ++$24
        stay VRAM_Buffer1-6,y
NoZSup: ldx ObjectOffset          ;get enemy object buffer offset
        rts

;-------------------------------------------------------------------------------------

SetupPowerUp:
	   ;jr $
           ldan ++PowerUpObject        ;load power-up identifier into
           sta Enemy_ID+5            ;special use slot of enemy object buffer
           ldax Block_PageLoc,x       ;store page location of block object
           sta Enemy_PageLoc+5       ;as page location of power-up object
           ldax Block_X_Position,x    ;store horizontal coordinate of block object
           sta Enemy_X_Position+5    ;as horizontal coordinate of power-up object
           ldan ++$01
           sta Enemy_Y_HighPos+5     ;set vertical high byte of power-up object
           ldax Block_Y_Position,x    ;get vertical coordinate of block object
           secsub
           sbcn ++$08                  ;subtract 8 pixels
           sta Enemy_Y_Position+5    ;and use as vertical coordinate of power-up object
PwrUpJmp:  ldan ++$01                  ;this is a residual jump point in enemy object jump table
           sta Enemy_State+5         ;set power-up object's state
           sta Enemy_Flag+5          ;set buffer flag
           ldan ++$03
           sta Enemy_BoundBoxCtrl+5  ;set bounding box size control for power-up object
           lda PowerUpType
           cmpn ++$02                  ;check currently loaded power-up type
              cmpcy
           bcs PutBehind             ;if star or 1-up, branch ahead
           lda PlayerStatus          ;otherwise check player's current status
           cmpn ++$02
              cmpcy
           bcc StrType               ;if player not fiery (<2), use status as power-up type
	   ;jr $
           lsr                       ;otherwise shift right to force fire flower type
StrType:   sta PowerUpType           ;store type here
PutBehind: ldan ++%00100000
           sta Enemy_SprAttrib+5     ;set background priority bit
           ldan ++Sfx_GrowPowerUp
           sta Square2SoundQueue     ;load power-up reveal sound and leave
           rts

;-------------------------------------------------------------------------------------

PowerUpObjHandler:
	;jr $
         ldxn ++$05                   ;set object offset for last slot in enemy object buffer
         stx ObjectOffset
         lda Enemy_State+5          ;check power-up object's state
         checka
         beq ExitPUp                ;if not set, branch to leave
         asl                        ;shift to check if d7 was set in object state
         bcc GrowThePowerUp         ;if not set, branch ahead to skip this part
         lda TimerControl           ;if master timer control set,
         checka
         bne RunPUSubs              ;branch ahead to enemy object routines
         lda PowerUpType            ;check power-up type
         checka
         beq ShroomM                ;if normal mushroom, branch ahead to move it
         cmpn ++$03
         beq ShroomM                ;if 1-up mushroom, branch ahead to move it
         cmpn ++$02
         bne RunPUSubs              ;if not star, branch elsewhere to skip movement
         jsr MoveJumpingEnemy       ;otherwise impose gravity on star power-up and make it jump
         jsr EnemyJump              ;note that green paratroopa shares the same code here 
         jmp RunPUSubs              ;then jump to other power-up subroutines
ShroomM: jsr MoveNormalEnemy        ;do sub to make mushrooms move
         jsr EnemyToBGCollisionDet  ;deal with collisions
         jmp RunPUSubs              ;run the other subroutines

GrowThePowerUp:
           lda FrameCounter           ;get frame counter
           andn ++$03                   ;mask out all but 2 LSB
           bne ChkPUSte               ;if any bits set here, branch
           deci Enemy_Y_Position+5     ;otherwise decrement vertical coordinate slowly
           lda Enemy_State+5          ;load power-up object state
           inci Enemy_State+5          ;increment state for next frame (to make power-up rise)
           cmpn ++$11                   ;if power-up object state not yet past 16th pixel,
              cmpcy
           bcc ChkPUSte               ;branch ahead to last part here
           ldan ++$10
           stax Enemy_X_Speed,x        ;otherwise set horizontal speed
           ldan ++%10000000
           sta Enemy_State+5          ;and then set d7 in power-up object's state
           asl                        ;shift once to init A
           sta Enemy_SprAttrib+5      ;initialize background priority bit set here
           rol                        ;rotate A to set right moving direction
           stax Enemy_MovingDir,x      ;set moving direction
ChkPUSte:  lda Enemy_State+5          ;check power-up object's state
           cmpn ++$06                   ;for if power-up has risen enough
              cmpcy
           bcc ExitPUp                ;if not, don't even bother running these routines
RunPUSubs: jsr RelativeEnemyPosition  ;get coordinates relative to screen
           jsr GetEnemyOffscreenBits  ;get offscreen bits
           jsr GetEnemyBoundBox       ;get bounding box coordinates
           jsr DrawPowerUp            ;draw the power-up object
           jsr PlayerEnemyCollision   ;check for collision with player
           jsr OffscreenBoundsCheck   ;check to see if it went offscreen
ExitPUp:   rts                        ;and we're done

;-------------------------------------------------------------------------------------
;These apply to all routines in this section unless otherwise noted:
;$00 - used to store metatile from block buffer routine
;$02 - used to store vertical high nybble offset from block buffer routine
;$05 - used to store metatile stored in A at beginning of PlayerHeadCollision
;$06-$07 - used as block buffer address indirect

BlockYPosAdderData:
      .db $04, $12

PlayerHeadCollision:
           pha                      ;store metatile number to stack
           ldan ++$11                 ;load unbreakable block object state by default
           ldx SprDataOffset_Ctrl   ;load offset control bit here
           ldy PlayerSize           ;check player's size
         checky
           bne DBlockSte            ;if small, branch
           ldan ++$12                 ;otherwise load breakable block object state
DBlockSte: stax Block_State,x        ;store into block object buffer
           jsr DestroyBlockMetatile ;store blank metatile in vram buffer to write to name table
           ldx SprDataOffset_Ctrl   ;load offset control bit
           lda SCRATCHPAD+$02                  ;get vertical high nybble offset used in block buffer routine
           stax Block_Orig_YPos,x    ;set as vertical coordinate for block object
           tay
           lda SCRATCHPAD+$06                  ;get low byte of block buffer address used in same routine
           stax Block_BBuf_Low,x     ;save as offset here to be used later
           ldayindirect (SCRATCHPAD+$06),y              ;get contents of block buffer at old address at $06, $07
           jsr BlockBumpedChk       ;do a sub to check which block player bumped head on
           sta SCRATCHPAD+$00                  ;store metatile here
           ldy PlayerSize           ;check player's size
         checky
           bne ChkBrick             ;if small, use metatile itself as contents of A
           tya                      ;otherwise init A (note: big = 0)
ChkBrick:  bcc PutMTileB            ;if no match was found in previous sub, skip ahead
	;jr $ ;сюда попадаем, если толкнули головой камень
           ldyn ++$11                 ;otherwise load unbreakable state into block object buffer
           styx Block_State,x        ;note this applies to both player sizes
           ldan ++$c4                 ;load empty block metatile into A for now
           ldy SCRATCHPAD+$00                  ;get metatile from before
           cpyn ++$58                 ;is it brick with coins (with line)?
           beq StartBTmr            ;if so, branch
           cpyn ++$5d                 ;is it brick with coins (without line)?
           bne PutMTileB            ;if not, branch ahead to store empty block metatile
StartBTmr: lda BrickCoinTimerFlag   ;check brick coin timer flag
         checka
           bne ContBTmr             ;if set, timer expired or counting down, thus branch
           ldan ++$0b
           sta BrickCoinTimer       ;if not set, set brick coin timer
           inci BrickCoinTimerFlag   ;and set flag linked to it
ContBTmr:  lda BrickCoinTimer       ;check brick coin timer
         checka
           bne PutOldMT             ;if not yet expired, branch to use current metatile
           ldyn ++$c4                 ;otherwise use empty block metatile
PutOldMT:  tya                      ;put metatile into A
PutMTileB: stax Block_Metatile,x     ;store whatever metatile be appropriate here
           jsr InitBlock_XY_Pos     ;get block object horizontal coordinates saved
           ldy SCRATCHPAD+$02                  ;get vertical high nybble offset
           ldan ++$23
           stayindirect (SCRATCHPAD+$06),y              ;write blank metatile $23 to block buffer
           ldan ++$10
           sta BlockBounceTimer     ;set block bounce timer
           pla                      ;pull original metatile from stack
           sta SCRATCHPAD+$05                  ;and save here
           ldyn ++$00                 ;set default offset
           lda CrouchingFlag        ;is player crouching?
         checka
           bne SmallBP              ;if so, branch to increment offset
           lda PlayerSize           ;is player big?
         checka
           beq BigBP                ;if so, branch to use default offset
SmallBP:   iny                      ;increment for small or big and crouching
BigBP:     lda Player_Y_Position    ;get player's vertical coordinate
           clc
           adcy BlockYPosAdderData,y ;add value determined by size
           andn ++$f0                 ;mask out low nybble to get 16-pixel correspondence
           stax Block_Y_Position,x   ;save as vertical coordinate for block object
           ldyx Block_State,x        ;get block object state
           cpyn ++$11
           beq Unbreak              ;if set to value loaded for unbreakable, branch
           jsr BrickShatter         ;execute code for breakable brick
           jmp InvOBit              ;skip subroutine to do last part of code here
Unbreak:   jsr BumpBlock            ;execute code for unbreakable brick or question block
InvOBit:   lda SprDataOffset_Ctrl   ;invert control bit used by block objects
           eorn ++$01                 ;and floatey numbers
           sta SprDataOffset_Ctrl
           rts                      ;leave!

;--------------------------------

InitBlock_XY_Pos:
      lda Player_X_Position   ;get player's horizontal coordinate
      clc
      adcn ++$08                ;add eight pixels
     push af
      andn ++$f0                ;mask out low nybble to give 16-pixel correspondence
      stax Block_X_Position,x  ;save as horizontal coordinate for block object
     pop af
      lda Player_PageLoc
      adcn ++$00                ;add carry to page location of player
      stax Block_PageLoc,x     ;save as page location of block object
      stax Block_PageLoc2,x    ;save elsewhere to be used later
      lda Player_Y_HighPos
      stax Block_Y_HighPos,x   ;save vertical high byte of player into
      rts                     ;vertical high byte of block object and leave

;--------------------------------

BumpBlock:
           jsr CheckTopOfBlock     ;check to see if there's a coin directly above this block
           ldan ++Sfx_Bump
           sta Square1SoundQueue   ;play bump sound
           ldan ++$00
           stax Block_X_Speed,x     ;initialize horizontal speed for block object
           stax Block_Y_MoveForce,x ;init fractional movement force
           sta Player_Y_Speed      ;init player's vertical speed
           ldan ++$fe
           stax Block_Y_Speed,x     ;set vertical speed for block object
           lda SCRATCHPAD+$05                 ;get original metatile from stack
           jsr BlockBumpedChk      ;do a sub to check which block player bumped head on
           bcc ExitBlockChk        ;if no match was found, branch to leave
           tya                     ;move block number to A
           cmpn ++$09                ;if block number was within 0-8 range,
              cmpcy
           bcc BlockCode           ;branch to use current number
              cmpcy
           sbcn ++$05                ;otherwise subtract 5 for second set to get proper number
BlockCode: jsr JumpEngine          ;run appropriate subroutine depending on block number

      .dw MushFlowerBlock
      .dw CoinBlock
      .dw CoinBlock
      .dw ExtraLifeMushBlock
      .dw MushFlowerBlock
      .dw VineBlock
      .dw StarBlock
      .dw CoinBlock
      .dw ExtraLifeMushBlock

;--------------------------------

MushFlowerBlock:
      ldan ++$00       ;load mushroom/fire flower into power-up type
      jr bonusblock_go;.db $2c        ;BIT instruction opcode

StarBlock:
      ldan ++$02       ;load star into power-up type
      jr bonusblock_go;.db $2c        ;BIT instruction opcode

ExtraLifeMushBlock:
      ldan ++$03         ;load 1-up mushroom into power-up type
bonusblock_go
      sta SCRATCHPAD+$39          ;store correct power-up type
      jmp SetupPowerUp

VineBlock:
      ldxn ++$05                ;load last slot for enemy object buffer
      ldy SprDataOffset_Ctrl  ;get control bit
      jsr Setup_Vine          ;set up vine object

ExitBlockChk:
      rts                     ;leave

;--------------------------------

BrickQBlockMetatiles:
      .db $c1, $c0, $5f, $60 ;used by question blocks

      ;these two sets are functionally identical, but look different
      .db $55, $56, $57, $58, $59 ;used by ground level types
      .db $5a, $5b, $5c, $5d, $5e ;used by other level types

BlockBumpedChk:
             ldyn ++$0d                    ;start at end of metatile data
BumpChkLoop: cmpy BrickQBlockMetatiles,y  ;check to see if current metatile matches
             beq MatchBump               ;metatile found in block buffer, branch if so
             dey                         ;otherwise move onto next metatile
             bpl BumpChkLoop             ;do this until all metatiles are checked
             clc                         ;if none match, return with carry clear
            if Z80
             rts
MatchBump:
             scf
             ret
            else
MatchBump:   rts                         ;note carry is set if found match
            endif

;--------------------------------

BrickShatter:
      jsr CheckTopOfBlock    ;check to see if there's a coin directly above this block
      ldan ++Sfx_BrickShatter
      stax Block_RepFlag,x    ;set flag for block object to immediately replace metatile
      sta NoiseSoundQueue    ;load brick shatter sound
      jsr SpawnBrickChunks   ;create brick chunk objects
      ldan ++$fe
      sta Player_Y_Speed     ;set vertical speed for player
      ldan ++$05
      sta DigitModifier+5    ;set digit modifier to give player 50 points
      jsr AddToScore         ;do sub to update the score
      ldx SprDataOffset_Ctrl ;load control bit and leave
      rts

;--------------------------------

CheckTopOfBlock:
       ldx SprDataOffset_Ctrl  ;load control bit
       ldy SCRATCHPAD+$02                 ;get vertical high nybble offset used in block buffer
         checky
       beq TopEx               ;branch to leave if set to zero, because we're at the top
       tya                     ;otherwise set to A
       secsub
       sbcn ++$10                ;subtract $10 to move up one row in the block buffer
       sta SCRATCHPAD+$02                 ;store as new vertical high nybble offset
       tay 
       ldayindirect (SCRATCHPAD+$06),y             ;get contents of block buffer in same column, one row up
       cmpn ++$c2                ;is it a coin? (not underwater)
       bne TopEx               ;if not, branch to leave
       ldan ++$00
       stayindirect (SCRATCHPAD+$06),y             ;otherwise put blank metatile where coin was
       jsr RemoveCoin_Axe      ;write blank metatile to vram buffer
       ldx SprDataOffset_Ctrl  ;get control bit
       jsr SetupJumpCoin       ;create jumping coin object and update coin variables
TopEx: rts                     ;leave!

;--------------------------------

SpawnBrickChunks:
      ldax Block_X_Position,x     ;set horizontal coordinate of block object
      stax Block_Orig_XPos,x      ;as original horizontal coordinate here
      ldan ++$f0
      stax Block_X_Speed,x        ;set horizontal speed for brick chunk objects
      stax Block_X_Speed+2,x
      ldan ++$fa
      stax Block_Y_Speed,x        ;set vertical speed for one
      ldan ++$fc
      stax Block_Y_Speed+2,x      ;set lower vertical speed for the other
      ldan ++$00
      stax Block_Y_MoveForce,x    ;init fractional movement force for both
      stax Block_Y_MoveForce+2,x
      ldax Block_PageLoc,x
      stax Block_PageLoc+2,x      ;copy page location
      ldax Block_X_Position,x
      stax Block_X_Position+2,x   ;copy horizontal coordinate
      ldax Block_Y_Position,x
      clc                        ;add 8 pixels to vertical coordinate
      adcn ++$08                   ;and save as vertical coordinate for one of them
      stax Block_Y_Position+2,x
      ldan ++$fa
      stax Block_Y_Speed,x        ;set vertical speed...again??? (redundant)
      rts

;-------------------------------------------------------------------------------------

BlockObjectsCore:
        ldax Block_State,x           ;get state of block object
         checka
        beq UpdSte                  ;if not set, branch to leave
        andn ++$0f                    ;mask out high nybble
        pha                         ;push to stack
        tay                         ;put in Y for now
        txa
        clc
        adcn ++$09                    ;add 9 bytes to offset (note two block objects are created
        tax                         ;when using brick chunks, but only one offset for both) ;начиная с объекта #9 идут misc objects (что это???)
        dey                         ;decrement Y to check for solid block state
        beq BouncingBlockHandler    ;branch if found, otherwise continue for brick chunks
        jsr ImposeGravityBlock      ;do sub to impose gravity on one block object object
        jsr MoveObjectHorizontally  ;do another sub to move horizontally
        txa
        clc                         ;move onto next block object
        adcn ++$02
        tax
        jsr ImposeGravityBlock      ;do sub to impose gravity on other block object
        jsr MoveObjectHorizontally  ;do another sub to move horizontally
        ldx ObjectOffset            ;get block object offset used for both
        jsr RelativeBlockPosition   ;get relative coordinates
        jsr GetBlockOffscreenBits   ;get offscreen information
        jsr DrawBrickChunks         ;draw the brick chunks
        pla                         ;get lower nybble of saved state
        ldyx Block_Y_HighPos,x       ;check vertical high byte of block object
         checky
        beq UpdSte                  ;if above the screen, branch to kill it
        pha                         ;otherwise save state back into stack
        ldan ++$f0
        cmpx Block_Y_Position+2,x    ;check to see if bottom block object went
              cmpcy
        bcs ChkTop                  ;to the bottom of the screen, and branch if not
        stax Block_Y_Position+2,x    ;otherwise set offscreen coordinate
ChkTop: ldax Block_Y_Position,x      ;get top block object's vertical coordinate
        cmpn ++$f0                    ;see if it went to the bottom of the screen
        plakeepcy                         ;pull block object state from stack
              cmpcy
        bcc UpdSte                  ;if not, branch to save state
        bcs KillBlock               ;otherwise do unconditional branch to kill it

BouncingBlockHandler:
           jsr ImposeGravityBlock     ;do sub to impose gravity on block object
           ldx ObjectOffset           ;get block object offset
           jsr RelativeBlockPosition  ;get relative coordinates
           jsr GetBlockOffscreenBits  ;get offscreen information
           jsr DrawBlock              ;draw the block
           ldax Block_Y_Position,x     ;get vertical coordinate
           andn ++$0f                   ;mask out high nybble
           cmpn ++$05                   ;check to see if low nybble wrapped around
              cmpcy
           plakeepcy                        ;pull state from stack
           bcs UpdSte                 ;if still above amount, not time to kill block yet, thus branch
           ldan ++$01
           stax Block_RepFlag,x        ;otherwise set flag to replace metatile
KillBlock: ldan ++$00                   ;if branched here, nullify object state
UpdSte:    stax Block_State,x          ;store contents of A in block object state
           rts

;-------------------------------------------------------------------------------------
;$02 - used to store offset to block buffer
;$06-$07 - used to store block buffer address

BlockObjMT_Updater:
            ldxn ++$01                  ;set offset to start with second block object
UpdateLoop: stx ObjectOffset          ;set offset here
            lda VRAM_Buffer1          ;if vram buffer already being used here,
         checka
            bne NextBUpd              ;branch to move onto next block object
            ldax Block_RepFlag,x       ;if flag for block object already clear,
         checka
            beq NextBUpd              ;branch to move onto next block object
            ldax Block_BBuf_Low,x      ;get low byte of block buffer
            sta SCRATCHPAD+$06                   ;store into block buffer address
            ldan ++$05
            sta SCRATCHPAD+$07                   ;set high byte of block buffer address
            ldax Block_Orig_YPos,x     ;get original vertical coordinate of block object
            sta SCRATCHPAD+$02                   ;store here and use as offset to block buffer
            tay
            ldax Block_Metatile,x      ;get metatile to be written
            stayindirect (SCRATCHPAD+$06),y               ;write it to the block buffer
            jsr ReplaceBlockMetatile  ;do sub to replace metatile where block object is
            ldan ++$00
            stax Block_RepFlag,x       ;clear block object flag
NextBUpd:   dex                       ;decrement block object offset
            bpl UpdateLoop            ;do this until both block objects are dealt with
            rts                       ;then leave

;-------------------------------------------------------------------------------------
;$00 - used to store high nybble of horizontal speed as adder
;$01 - used to store low nybble of horizontal speed
;$02 - used to store adder to page location

MoveEnemyHorizontally:
      inx                         ;increment offset for enemy offset
      jsr MoveObjectHorizontally  ;position object horizontally according to
      ldx ObjectOffset            ;counters, return with saved value in A,
      rts                         ;put enemy offset back in X and leave

MovePlayerHorizontally:
      lda JumpspringAnimCtrl  ;if jumpspring currently animating,
        if Z80OPT
      or a
      ret nz                ;branch to leave
        else
      checka
      bne ExXMove             ;branch to leave
        endif
      tax                     ;otherwise set zero for offset to use player's stuff

MoveObjectHorizontally:
;PageLoc_XPosition_XMoveforce += 16*Xspeed (signed)
;out: a=смещение X-координаты относительно прошлой позиции (используется только для платформ? непонятно - зачем?)
;CY не важен
;можно портить y
;можно не писать в SCRATCHPAD+0,1,2
        if Z80OPT
          ld ix,SprObject_X_Speed
          add ix,bc
          ld a,(ix)
          add a,a
          ld l,a
          sbc a,a
          ld h,a ;расширение знака
          ld e,a ;сохраняем знак
          add hl,hl
          add hl,hl
          add hl,hl
          ld a,l
          ld d,h
          ld hl,SprObject_X_MoveForce
          add hl,bc
          add a,(hl) ;get whatever number's here (младшая часть X-координаты)  ;add low nybble moved to high
          ld (hl),a ;store result here (младшая часть X-координаты)
          ld a,(ix+SprObject_X_Position-SprObject_X_Speed)
          ld l,a
          adc a,d        ;add carry plus saved value (high nybble moved to low
          ld d,b;0
          ld h,a ;plus $f0 if necessary) to object's horizontal position
          ld a,(ix+SprObject_PageLoc-SprObject_X_Speed)
          adc a,e                                           ;add carry plus other saved value to the
          ld (ix+SprObject_PageLoc-SprObject_X_Speed),a     ;object's page location and save
          ld a,h
          sub l;(ix+SprObject_X_Position-SprObject_X_Speed) ;(получается смещение X-координаты относительно прошлой позиции)
          ld (ix+SprObject_X_Position-SprObject_X_Speed),h
          ret
        else ;~Z80
          ldax SprObject_X_Speed,x     ;get currently saved value (horizontal
          asl                         ;speed, secondary counter, whatever)
          asl                         ;and move low nybble to high
          asl
          asl
          sta SCRATCHPAD+$01                     ;store result here
          ldax SprObject_X_Speed,x     ;get saved value again
          lsr                         ;move high nybble to low
          lsr
          lsr
          lsr
          cmpn ++$08                    ;if < 8, branch, do not change
              cmpcy
          bcc SaveXSpd
          oran ++%11110000              ;otherwise alter high nybble (расширение знака)
SaveXSpd: sta SCRATCHPAD+$00                     ;save result here
          ldyn ++$00                    ;load default Y value here
          cmpn ++$00                    ;if result positive, leave Y alone
          bpl UseAdder
          dey                         ;otherwise decrement Y
UseAdder: sty SCRATCHPAD+$02                     ;save Y here (получился знак скорости 0/-1)
          ldax SprObject_X_MoveForce,x ;get whatever number's here (младшая часть X-координаты)
          clc
          adci SCRATCHPAD+$01                     ;add low nybble moved to high
         push af
          stax SprObject_X_MoveForce,x ;store result here (младшая часть X-координаты)
         pop af
          ldan ++$00                    ;init A
          rol                         ;rotate carry into d0
       pha                         ;push onto stack (сохраняем флаг переноса после сложения младшей части X-координаты)
          ror                         ;rotate d0 back onto carry
          ldaxkeepcy SprObject_X_Position,x
          adci SCRATCHPAD+$00                     ;add carry plus saved value (high nybble moved to low
         push af
          stax SprObject_X_Position,x  ;plus $f0 if necessary) to object's horizontal position
          ldax SprObject_PageLoc,x
         ld h,a
         pop af
         ld a,h
          adci SCRATCHPAD+$02                     ;add carry plus other saved value to the
          stax SprObject_PageLoc,x     ;object's page location and save
       pla
          clc                         ;pull old carry from stack (флаг переноса после сложения младшей части X-координаты) and add
          adci SCRATCHPAD+$00                     ;to high nybble moved to low (получается смещение X-координаты относительно прошлой позиции)
ExXMove:  rts                         ;and leave
        endif

;-------------------------------------------------------------------------------------
;$00 - used for downward force
;$01 - used for upward force
;$02 - used for maximum vertical speed

MovePlayerVertically:
         ldxn ++$00                ;set X for player offset
         lda TimerControl
         checka
         bne NoJSChk             ;if master timer control set, branch ahead
         lda JumpspringAnimCtrl  ;otherwise check to see if jumpspring is animating
        if Z80OPT
         or a
         ret nz ;branch to leave if so
        else
         checka
         bne ExXMove             ;branch to leave if so
        endif
NoJSChk: lda VerticalForce       ;dump vertical force 
         sta SCRATCHPAD+$00
         ldan ++$04                ;set maximum vertical speed here
         jmp ImposeGravitySprObj ;then jump to move player vertically

;--------------------------------

MoveD_EnemyVertically:
      ldyn ++$3d           ;set quick movement amount downwards
      ldax Enemy_State,x  ;then check enemy state
      cmpn ++$05           ;if not set to unique state for spiny's egg, go ahead
      bne ContVMove      ;and use, otherwise set different movement amount, continue on

MoveFallingPlatform:
           ldyn ++$20       ;set movement amount
ContVMove: jmp SetHiMax   ;jump to skip the rest of this

;--------------------------------

MoveRedPTroopaDown:
      ldyn ++$00            ;set Y to move downwards
      jmp MoveRedPTroopa  ;skip to movement routine

MoveRedPTroopaUp:
      ldyn ++$01            ;set Y to move upwards

MoveRedPTroopa:
      inx                 ;increment X for enemy offset
      ldan ++$03
      sta SCRATCHPAD+$00             ;set downward movement amount here
      ldan ++$06
      sta SCRATCHPAD+$01             ;set upward movement amount here
      ldan ++$02
      sta SCRATCHPAD+$02             ;set maximum speed here
      tya                 ;set movement direction in A, and
      jmp RedPTroopaGrav  ;jump to move this thing

;--------------------------------

MoveDropPlatform:
      ldyn ++$7f      ;set movement amount for drop platform
         checky
      bne SetMdMax  ;skip ahead of other value set here

MoveEnemySlowVert:
          ldyn ++$0f         ;set movement amount for bowser/other objects
SetMdMax: ldan ++$02         ;set maximum speed in A
         checka
          bne SetXMoveAmt  ;unconditional branch

;--------------------------------

MoveJ_EnemyVertically:
             ldyn ++$1c                ;set movement amount for podoboo/other objects
SetHiMax:    ldan ++$03                ;set maximum speed in A
SetXMoveAmt: sty SCRATCHPAD+$00                 ;set movement amount here
             inx                     ;increment X for enemy offset
             jsr ImposeGravitySprObj ;do a sub to move enemy object downwards
             ldx ObjectOffset        ;get enemy object buffer offset and leave
             rts

;--------------------------------

MaxSpdBlockData:
      .db $06, $08

ResidualGravityCode:
      ldyn ++$00       ;this part appears to be residual,
      jr ImposeGravityBlock_go;.db $2c        ;no code branches or jumps to it...

ImposeGravityBlock:
      ldyn ++$01       ;set offset for maximum speed
ImposeGravityBlock_go
      ldan ++$50       ;set movement amount here
      sta SCRATCHPAD+$00
      lday MaxSpdBlockData,y    ;get maximum speed

ImposeGravitySprObj:
      sta SCRATCHPAD+$02            ;set maximum speed here
      ldan ++$00           ;set value to move downwards
      jmp ImposeGravity  ;jump to the code that actually moves it

;--------------------------------

MovePlatformDown:
      ldan ++$00    ;save value to stack (if branching here, execute next
      jr MovePlatform_go;.db $2c     ;part as BIT instruction)

MovePlatformUp:
           ldan ++$01        ;save value to stack
MovePlatform_go
           pha
           ldyx Enemy_ID,x  ;get enemy object identifier
           inx             ;increment offset for enemy object
           ldan ++$05        ;load default value here
           cpyn ++$29        ;residual comparison, object ++29 never executes
           bne SetDplSpd   ;this code, thus unconditional branch here
           ldan ++$09        ;residual code
SetDplSpd: sta SCRATCHPAD+$00         ;save downward movement amount here
           ldan ++$0a        ;save upward movement amount here
           sta SCRATCHPAD+$01
           ldan ++$03        ;save maximum vertical speed here
           sta SCRATCHPAD+$02
           pla             ;get value from stack
           tay             ;use as Y, then move onto code shared by red koopa

RedPTroopaGrav:
      jsr ImposeGravity  ;do a sub to move object gradually
      ldx ObjectOffset   ;get enemy object offset and leave
      rts

;-------------------------------------------------------------------------------------
;$00 - used for downward force
;$01 - used for upward force
;$07 - used as adder for vertical position

ImposeGravity:
         pha                          ;push value to stack
         ldax SprObject_YMF_Dummy,x
         clc                          ;add value in movement force to contents of dummy variable
         adcx SprObject_Y_MoveForce,x
          push af
         stax SprObject_YMF_Dummy,x
         ldyn ++$00                     ;set Y to zero by default
         ldax SprObject_Y_Speed,x      ;get current vertical speed
          ld h,a
          pop af
          ld a,h
         checka
         bpl AlterYP                  ;if currently moving downwards, do not decrement Y
         dey                          ;otherwise decrement Y
AlterYP: sty SCRATCHPAD+$07                      ;store Y here
         adcx SprObject_Y_Position,x   ;add vertical position to vertical speed plus carry
          push af
         stax SprObject_Y_Position,x   ;store as new vertical position
         ldax SprObject_Y_HighPos,x
          ld h,a
          pop af
          ld a,h
         adci SCRATCHPAD+$07                      ;add carry plus contents of $07 to vertical high byte
         stax SprObject_Y_HighPos,x    ;store as new vertical high byte
         ldax SprObject_Y_MoveForce,x
         clc
         adci SCRATCHPAD+$00                      ;add downward movement amount to contents of $0433
          push af
         stax SprObject_Y_MoveForce,x
         ldax SprObject_Y_Speed,x      ;add carry to vertical speed and store
          ld h,a
          pop af
          ld a,h
         adcn ++$00
         stax SprObject_Y_Speed,x
         cmpi SCRATCHPAD+$02                      ;compare to maximum speed
         bmi ChkUpM                   ;if less than preset value, skip this part
         ldax SprObject_Y_MoveForce,x
         cmpn ++$80                     ;if less positively than preset maximum, skip this part
              cmpcy
         bcc ChkUpM
         lda SCRATCHPAD+$02
         stax SprObject_Y_Speed,x      ;keep vertical speed within maximum value
         ldan ++$00
         stax SprObject_Y_MoveForce,x  ;clear fractional
ChkUpM:  pla                          ;get value from stack
         checka
         beq ExVMove                  ;if set to zero, branch to leave
         lda SCRATCHPAD+$02
         eorn ++%11111111               ;otherwise get two's compliment of maximum speed
         tay
         iny
         sty SCRATCHPAD+$07                      ;store two's compliment here
         ldax SprObject_Y_MoveForce,x
         secsub                          ;subtract upward movement amount from contents
         sbci SCRATCHPAD+$01                      ;of movement force, note that $01 is twice as large as $00,
          push af
         stax SprObject_Y_MoveForce,x  ;thus it effectively undoes add we did earlier
         ldax SprObject_Y_Speed,x
          ld h,a
          pop af
          ld a,h
         sbcn ++$00                     ;subtract borrow from vertical speed and store
         stax SprObject_Y_Speed,x
         cmpi SCRATCHPAD+$07                      ;compare vertical speed to two's compliment
         bpl ExVMove                  ;if less negatively than preset maximum, skip this part
         ldax SprObject_Y_MoveForce,x
         cmpn ++$80                     ;check if fractional part is above certain amount,
              cmpcy
         bcs ExVMove                  ;and if so, branch to leave
         lda SCRATCHPAD+$07
         stax SprObject_Y_Speed,x      ;keep vertical speed within maximum value
         ldan ++$ff
         stax SprObject_Y_MoveForce,x  ;clear fractional
ExVMove: rts                          ;leave!

;-------------------------------------------------------------------------------------

EnemiesAndLoopsCore:
            ldax Enemy_Flag,x         ;check data here for MSB set
            pha                      ;save in stack
            asl
            bcs ChkBowserF           ;if MSB set in enemy flag, branch ahead of jumps
            pla                      ;get from stack
         checka
            beq ChkAreaTsk           ;if data zero, branch
            jmp RunEnemyObjectsCore  ;otherwise, jump to run enemy subroutines
ChkAreaTsk: lda AreaParserTaskNum    ;check number of tasks to perform
            andn ++$07
            cmpn ++$07                 ;if at a specific task, jump and leave
            beq ExitELCore
            jmp ProcLoopCommand      ;otherwise, jump to process loop command/load enemies
ChkBowserF: pla                      ;get data from stack
            andn ++%00001111           ;mask out high nybble
            tay
            lday Enemy_Flag,y         ;use as pointer and load same place with different offset
         checka
            bne ExitELCore
            stax Enemy_Flag,x         ;if second enemy flag not set, also clear first one
ExitELCore: rts

;--------------------------------

;loop command data
LoopCmdWorldNumber:
      .db $03, $03, $06, $06, $06, $06, $06, $06, $07, $07, $07

LoopCmdPageNumber:
      .db $05, $09, $04, $05, $06, $08, $09, $0a, $06, $0b, $10

LoopCmdYPosition:
      .db $40, $b0, $b0, $80, $40, $40, $80, $40, $f0, $f0, $f0

ExecGameLoopback:
      lda Player_PageLoc        ;send player back four pages
      secsub
      sbcn ++$04
      sta Player_PageLoc
      lda CurrentPageLoc        ;send current page back four pages
      secsub
      sbcn ++$04
      sta CurrentPageLoc
      lda ScreenLeft_PageLoc    ;subtract four from page location
      secsub                       ;of screen's left border
      sbcn ++$04
      sta ScreenLeft_PageLoc
      lda ScreenRight_PageLoc   ;do the same for the page location
      secsub                       ;of screen's right border
      sbcn ++$04
      sta ScreenRight_PageLoc
      lda AreaObjectPageLoc     ;subtract four from page control
      secsub                       ;for area objects
      sbcn ++$04
      sta AreaObjectPageLoc
      ldan ++$00                  ;initialize page select for both
      sta EnemyObjectPageSel    ;area and enemy objects
      sta AreaObjectPageSel
      sta EnemyDataOffset       ;initialize enemy object data offset
      sta EnemyObjectPageLoc    ;and enemy object page control
      lday AreaDataOfsLoopback,y ;adjust area object offset based on
      sta AreaDataOffset        ;which loop command we encountered
      rts

ProcLoopCommand:
          lda LoopCommand           ;check if loop command was found
         checka
          beq ChkEnemyFrenzy
          lda CurrentColumnPos      ;check to see if we're still on the first page
         checka
          bne ChkEnemyFrenzy        ;if not, do not loop yet
          ldyn ++$0b                  ;start at the end of each set of loop data
FindLoop: dey
          bmi ChkEnemyFrenzy        ;if all data is checked and not match, do not loop
          lda WorldNumber           ;check to see if one of the world numbers
          cmpy LoopCmdWorldNumber,y  ;matches our current world number
          bne FindLoop
          lda CurrentPageLoc        ;check to see if one of the page numbers
          cmpy LoopCmdPageNumber,y   ;matches the page we're currently on
          bne FindLoop
          lda Player_Y_Position     ;check to see if the player is at the correct position
          cmpy LoopCmdYPosition,y    ;if not, branch to check for world 7
          bne WrongChk
          lda Player_State          ;check to see if the player is
          cmpn ++$00                  ;on solid ground (i.e. not jumping or falling)
          bne WrongChk              ;if not, player fails to pass loop, and loopback
          lda WorldNumber           ;are we in world 7? (check performed on correct
          cmpn ++World7               ;vertical position and on solid ground)
          bne InitMLp               ;if not, initialize flags used there, otherwise
          inci MultiLoopCorrectCntr  ;increment counter for correct progression
IncMLoop: inci MultiLoopPassCntr     ;increment master multi-part counter
          lda MultiLoopPassCntr     ;have we done all three parts?
          cmpn ++$03
          bne InitLCmd              ;if not, skip this part
          lda MultiLoopCorrectCntr  ;if so, have we done them all correctly?
          cmpn ++$03
          beq InitMLp               ;if so, branch past unnecessary check here
          bne DoLpBack              ;unconditional branch if previous branch fails
WrongChk: lda WorldNumber           ;are we in world 7? (check performed on
          cmpn ++World7               ;incorrect vertical position or not on solid ground)
          beq IncMLoop
DoLpBack: jsr ExecGameLoopback      ;if player is not in right place, loop back
          jsr KillAllEnemies
InitMLp:  ldan ++$00                  ;initialize counters used for multi-part loop commands
          sta MultiLoopPassCntr
          sta MultiLoopCorrectCntr
InitLCmd: ldan ++$00                  ;initialize loop command flag
          sta LoopCommand

;--------------------------------

ChkEnemyFrenzy:
      lda EnemyFrenzyQueue  ;check for enemy object in frenzy queue
         checka
      beq ProcessEnemyData  ;if not, skip this part
      stax Enemy_ID,x        ;store as enemy object identifier here
      ldan ++$01
      stax Enemy_Flag,x      ;activate enemy object flag
      ldan ++$00
      stax Enemy_State,x     ;initialize state and frenzy queue
      sta EnemyFrenzyQueue
      jmp InitEnemyObject   ;and then jump to deal with this enemy

;--------------------------------
;$06 - used to hold page location of extended right boundary
;$07 - used to hold high nybble of position of extended right boundary

ProcessEnemyData:
        ldy EnemyDataOffset      ;get offset of enemy object data
        ldayindirect (EnemyData),y        ;load first byte
        cmpn ++$ff                 ;check for EOD terminator
        bne CheckEndofBuffer
        jmp CheckFrenzyBuffer    ;if found, jump to check frenzy buffer, otherwise

CheckEndofBuffer:
        andn ++%00001111           ;check for special row $0e
        cmpn ++$0e
        beq CheckRightBounds     ;if found, branch, otherwise
        cpxn ++$05                 ;check for end of buffer
              cmpcy
        bcc CheckRightBounds     ;if not at end of buffer, branch
        iny
        ldayindirect (EnemyData),y        ;check for specific value here
        andn ++%00111111           ;not sure what this was intended for, exactly
        cmpn ++$2e                 ;this part is quite possibly residual code
        beq CheckRightBounds     ;but it has the effect of keeping enemies out of
        rts                      ;the sixth slot

CheckRightBounds:
        lda ScreenRight_X_Pos    ;add 48 to pixel coordinate of right boundary
        clc
        adcn ++$30
          push af
        andn ++%11110000           ;store high nybble
        sta SCRATCHPAD+$07
        lda ScreenRight_PageLoc  ;add carry to page location of right boundary
          ld h,a
          pop af
          ld a,h
        adcn ++$00
        sta SCRATCHPAD+$06                  ;store page location + carry
        ldy EnemyDataOffset
        iny
        ldayindirect (EnemyData),y        ;if MSB of enemy object is clear, branch to check for row $0f
        asl
        bcc CheckPageCtrlRow
        lda EnemyObjectPageSel   ;if page select already set, do not set again
         checka
        bne CheckPageCtrlRow
        inci EnemyObjectPageSel   ;otherwise, if MSB is set, set page select 
        inci EnemyObjectPageLoc   ;and increment page control

CheckPageCtrlRow:
        dey
        ldayindirect (EnemyData),y        ;reread first byte
        andn ++$0f
        cmpn ++$0f                 ;check for special row $0f
        bne PositionEnemyObj     ;if not found, branch to position enemy object
        lda EnemyObjectPageSel   ;if page select set,
         checka
        bne PositionEnemyObj     ;branch without reading second byte
        iny
        ldayindirect (EnemyData),y        ;otherwise, get second byte, mask out 2 MSB
        andn ++%00111111
        sta EnemyObjectPageLoc   ;store as page control for enemy object data
        inci EnemyDataOffset      ;increment enemy object data offset 2 bytes
        inci EnemyDataOffset
        inci EnemyObjectPageSel   ;set page select for enemy object data and 
        jmp ProcLoopCommand      ;jump back to process loop commands again

PositionEnemyObj:
        lda EnemyObjectPageLoc   ;store page control as page location
        stax Enemy_PageLoc,x      ;for enemy object
        ldayindirect (EnemyData),y        ;get first byte of enemy object
        andn ++%11110000
        stax Enemy_X_Position,x   ;store column position
        cmpi ScreenRight_X_Pos    ;check column position against right boundary
        ldaxkeepcy Enemy_PageLoc,x      ;without subtracting, then subtract borrow
        sbci ScreenRight_PageLoc  ;from page location
              cmpcy
        bcs CheckRightExtBounds  ;if enemy object beyond or at boundary, branch
        ldayindirect (EnemyData),y
        andn ++%00001111           ;check for special row $0e
        cmpn ++$0e                 ;if found, jump elsewhere
        beq ParseRow0e
        jmp CheckThreeBytes      ;if not found, unconditional jump

CheckRightExtBounds:
        lda SCRATCHPAD+$07                  ;check right boundary + 48 against
        cmpx Enemy_X_Position,x   ;column position without subtracting,
        lda SCRATCHPAD+$06                  ;then subtract borrow from page control temp
        sbcx Enemy_PageLoc,x      ;plus carry
              cmpcy
        bcc CheckFrenzyBuffer    ;if enemy object beyond extended boundary, branch
        ldan ++$01                 ;store value in vertical high byte
        stax Enemy_Y_HighPos,x
        ldayindirect (EnemyData),y        ;get first byte again
        asl                      ;multiply by four to get the vertical
        asl                      ;coordinate
        asl
        asl
        stax Enemy_Y_Position,x
        cmpn ++$e0                 ;do one last check for special row $0e
        beq ParseRow0e           ;(necessary if branched to $c1cb)
        iny
        ldayindirect (EnemyData),y        ;get second byte of object
        andn ++%01000000           ;check to see if hard mode bit is set
        beq CheckForEnemyGroup   ;if not, branch to check for group enemy objects
        lda SecondaryHardMode    ;if set, check to see if secondary hard mode flag
         checka
        beq Inc2B                ;is on, and if not, branch to skip this object completely

CheckForEnemyGroup:
        ldayindirect (EnemyData),y      ;get second byte and mask out 2 MSB
        andn ++%00111111
        cmpn ++$37               ;check for value below $37
              cmpcy
        bcc BuzzyBeetleMutate
        cmpn ++$3f               ;if $37 or greater, check for value
              cmpcy
        bcc DoGroup            ;below $3f, branch if below $3f

BuzzyBeetleMutate:
        cmpn ++Goomba          ;if below $37, check for goomba
        bne StrID            ;value ($3f or more always fails)
        ldy PrimaryHardMode  ;check if primary hard mode flag is set
         checky
        beq StrID            ;and if so, change goomba to buzzy beetle
        ldan ++BuzzyBeetle
StrID:  stax Enemy_ID,x       ;store enemy object number into buffer
        ldan ++$01
        stax Enemy_Flag,x     ;set flag for enemy in buffer
        jsr InitEnemyObject
        ldax Enemy_Flag,x     ;check to see if flag is set
         checka
        bne Inc2B            ;if not, leave, otherwise branch
        rts

CheckFrenzyBuffer:
        lda EnemyFrenzyBuffer    ;if enemy object stored in frenzy buffer
         checka
        bne StrFre               ;then branch ahead to store in enemy object buffer
        lda VineFlagOffset       ;otherwise check vine flag offset
        cmpn ++$01
        bne ExEPar               ;if other value LOW HIGH  1, leave
        ldan ++VineObject          ;otherwise put vine in enemy identifier
StrFre: stax Enemy_ID,x           ;store contents of frenzy buffer into enemy identifier value

InitEnemyObject:
        ldan ++$00                 ;initialize enemy state
        stax Enemy_State,x
        jsr CheckpointEnemyID    ;jump ahead to run jump engine and subroutines
ExEPar: rts                      ;then leave

DoGroup:
        jmp HandleGroupEnemies   ;handle enemy group objects

ParseRow0e:
        iny                      ;increment Y to load third byte of object
        iny
        ldayindirect (EnemyData),y
        lsr                      ;move 3 MSB to the bottom, effectively
        lsr                      ;making %xxx00000 into %00000xxx
        lsr
        lsr
        lsr
        cmpi WorldNumber          ;is it the same world number as we're on?
        bne NotUse               ;if not, do not use (this allows multiple uses
        dey                      ;of the same area, like the underground bonus areas)
        ldayindirect (EnemyData),y        ;otherwise, get second byte and use as offset
        sta AreaPointer          ;to addresses for level and enemy object data
        iny
        ldayindirect (EnemyData),y        ;get third byte again, and this time mask out
        andn ++%00011111           ;the 3 MSB from before, save as page number to be
        sta EntrancePage         ;used upon entry to area, if area is entered
NotUse: jmp Inc3B

CheckThreeBytes:
        ldy EnemyDataOffset      ;load current offset for enemy object data
        ldayindirect (EnemyData),y        ;get first byte
        andn ++%00001111           ;check for special row $0e
        cmpn ++$0e
        bne Inc2B
Inc3B:  inci EnemyDataOffset      ;if row = $0e, increment three bytes
Inc2B:  inci EnemyDataOffset      ;otherwise increment two bytes
        inci EnemyDataOffset
        ldan ++$00                 ;init page select for enemy objects
        sta EnemyObjectPageSel
        ldx ObjectOffset         ;reload current offset in enemy buffers
        rts                      ;and leave

CheckpointEnemyID:
        ldax Enemy_ID,x
        cmpn ++$15                     ;check enemy object identifier for $15 or greater
              cmpcy
        bcs InitEnemyRoutines        ;and branch straight to the jump engine if found
        tay                          ;save identifier in Y register for now
        ldax Enemy_Y_Position,x
         or a
        adcn ++$08                     ;add eight pixels to what will eventually be the
        stax Enemy_Y_Position,x       ;enemy object's vertical coordinate ($00-$14 only)
        ldan ++$01
        stax EnemyOffscrBitsMasked,x  ;set offscreen masked bit
        tya                          ;get identifier back and use as offset for jump engine

InitEnemyRoutines:
        jsr JumpEngine
      
;jump engine table for newly loaded enemy objects

      .dw InitNormalEnemy  ;for objects $00-$0f
      .dw InitNormalEnemy
      .dw InitNormalEnemy
      .dw InitRedKoopa
      .dw NoInitCode
      .dw InitHammerBro
      .dw InitGoomba
      .dw InitBloober
      .dw InitBulletBill
      .dw NoInitCode
      .dw InitCheepCheep
      .dw InitCheepCheep
      .dw InitPodoboo
      .dw InitPiranhaPlant
      .dw InitJumpGPTroopa
      .dw InitRedPTroopa

      .dw InitHorizFlySwimEnemy  ;for objects $10-$1f
      .dw InitLakitu
      .dw InitEnemyFrenzy
      .dw NoInitCode
      .dw InitEnemyFrenzy
      .dw InitEnemyFrenzy
      .dw InitEnemyFrenzy
      .dw InitEnemyFrenzy
      .dw EndFrenzy
      .dw NoInitCode
      .dw NoInitCode
      .dw InitShortFirebar
      .dw InitShortFirebar
      .dw InitShortFirebar
      .dw InitShortFirebar
      .dw InitLongFirebar

      .dw NoInitCode ;for objects $20-$2f
      .dw NoInitCode
      .dw NoInitCode
      .dw NoInitCode
      .dw InitBalPlatform
      .dw InitVertPlatform
      .dw LargeLiftUp
      .dw LargeLiftDown
      .dw InitHoriPlatform
      .dw InitDropPlatform
      .dw InitHoriPlatform
      .dw PlatLiftUp
      .dw PlatLiftDown
      .dw InitBowser
      .dw PwrUpJmp   ;possibly dummy value
      .dw Setup_Vine

      .dw NoInitCode ;for objects $30-$36
      .dw NoInitCode
      .dw NoInitCode
      .dw NoInitCode
      .dw NoInitCode
      .dw InitRetainerObj
      .dw EndOfEnemyInitCode

;-------------------------------------------------------------------------------------

NoInitCode:
      rts               ;this executed when enemy object has no init code

;--------------------------------

InitGoomba:
      jsr InitNormalEnemy  ;set appropriate horizontal speed
      jmp SmallBBox        ;set $09 as bounding box control, set other values

;--------------------------------

InitPodoboo:
      ldan ++$02                  ;set enemy position to below
      stax Enemy_Y_HighPos,x     ;the bottom of the screen
      stax Enemy_Y_Position,x
      lsr
      stax EnemyIntervalTimer,x  ;set timer for enemy
      lsr
      stax Enemy_State,x         ;initialize enemy state, then jump to use
      jmp SmallBBox             ;$09 as bounding box size and set other things

;--------------------------------

InitRetainerObj:
      ldan ++$b8                ;set fixed vertical position for
      stax Enemy_Y_Position,x  ;princess/mushroom retainer object
      rts

;--------------------------------

NormalXSpdData:
      .db $f8, $f4

InitNormalEnemy:
         ldyn ++$01              ;load offset of 1 by default
         lda PrimaryHardMode   ;check for primary hard mode flag set
         checka
         bne GetESpd
         dey                   ;if not set, decrement offset
GetESpd: lday NormalXSpdData,y  ;get appropriate horizontal speed
SetESpd: stax Enemy_X_Speed,x   ;store as speed for enemy object
         jmp TallBBox          ;branch to set bounding box control and other data

;--------------------------------

InitRedKoopa:
      jsr InitNormalEnemy   ;load appropriate horizontal speed
      ldan ++$01              ;set enemy state for red koopa troopa $03
      stax Enemy_State,x
      rts

;--------------------------------

HBroWalkingTimerData:
      .db $80, $50

InitHammerBro:
      ldan ++$00                    ;init horizontal speed and timer used by hammer bro
      stax HammerThrowingTimer,x   ;apparently to time hammer throwing
      stax Enemy_X_Speed,x
      ldy SecondaryHardMode       ;get secondary hard mode flag
      lday HBroWalkingTimerData,y
      stax EnemyIntervalTimer,x    ;set value as delay for hammer bro to walk left
      ldan ++$0b                    ;set specific value for bounding box size control
      jmp SetBBox

;--------------------------------

InitHorizFlySwimEnemy:
      ldan ++$00        ;initialize horizontal speed
      jmp SetESpd

;--------------------------------

InitBloober:
           ldan ++$00               ;initialize horizontal speed
           stax BlooperMoveSpeed,x
SmallBBox: ldan ++$09               ;set specific bounding box size control
         checka
           bne SetBBox            ;unconditional branch

;--------------------------------

InitRedPTroopa:
;CY = 0 after JumpEngine ???
        or a ;???
        push af
          ldyn ++$30                    ;load central position adder for 48 pixels down
          ldax Enemy_Y_Position,x      ;set vertical coordinate into location to
          stax RedPTroopaOrigXPos,x    ;be used as original vertical coordinate
        ld h,a
        pop af
        ld a,h
         checka
          bpl GetCent                 ;if vertical coordinate LOW  $80
          ldyn ++$e0                    ;if =HIGH  $80, load position adder for 32 pixels up
GetCent:  tya                         ;send central position adder to A
          adcx Enemy_Y_Position,x      ;add to current vertical coordinate
          stax RedPTroopaCenterYPos,x  ;store as central vertical coordinate
TallBBox: ldan ++$03                    ;set specific bounding box size control
SetBBox:  stax Enemy_BoundBoxCtrl,x    ;set bounding box control here
          ldan ++$02                    ;set moving direction for left
          stax Enemy_MovingDir,x
InitVStf: ldan ++$00                    ;initialize vertical speed
          stax Enemy_Y_Speed,x         ;and movement force
          stax Enemy_Y_MoveForce,x
          rts

;--------------------------------

InitBulletBill:
      ldan ++$02                  ;set moving direction for left
      stax Enemy_MovingDir,x
      ldan ++$09                  ;set bounding box control for $09
      stax Enemy_BoundBoxCtrl,x
      rts

;--------------------------------

InitCheepCheep:
      jsr SmallBBox              ;set vertical bounding box, speed, init others
      ldax PseudoRandomBitReg,x   ;check one portion of LSFR
      andn ++%00010000             ;get d4 from it
      stax CheepCheepMoveMFlag,x  ;save as movement flag of some sort
      ldax Enemy_Y_Position,x
      stax CheepCheepOrigYPos,x   ;save original vertical coordinate here
      rts

;--------------------------------

InitLakitu:
      lda EnemyFrenzyBuffer      ;check to see if an enemy is already in
         checka
      bne KillLakitu             ;the frenzy buffer, and branch to kill lakitu if so

SetupLakitu:
      ldan ++$00                   ;erase counter for lakitu's reappearance
      sta LakituReappearTimer
      jsr InitHorizFlySwimEnemy  ;set $03 as bounding box, set other attributes
      jmp TallBBox2              ;set $03 as bounding box again (not necessary) and leave

KillLakitu:
      jmp EraseEnemyObject

;--------------------------------
;$01-$03 - used to hold pseudorandom difference adjusters

PRDiffAdjustData:
      .db $26, $2c, $32, $38
      .db $20, $22, $24, $26
      .db $13, $14, $15, $16

LakituAndSpinyHandler:
          lda FrenzyEnemyTimer    ;if timer here not expired, leave
         checka
          bne ExLSHand
          cpxn ++$05                ;if we are on the special use slot, leave
              cmpcy
          bcs ExLSHand
          ldan ++$80                ;set timer
          sta FrenzyEnemyTimer
          ldyn ++$04                ;start with the last enemy slot
ChkLak:   lday Enemy_ID,y          ;check all enemy slots to see
          cmpn ++Lakitu             ;if lakitu is on one of them
          beq CreateSpiny         ;if so, branch out of this loop
          dey                     ;otherwise check another slot
          bpl ChkLak              ;loop until all slots are checked
          inci LakituReappearTimer ;increment reappearance timer
          lda LakituReappearTimer
          cmpn ++$07                ;check to see if we're up to a certain value yet
              cmpcy
          bcc ExLSHand            ;if not, leave
          ldxn ++$04                ;start with the last enemy slot again
ChkNoEn:  ldax Enemy_Flag,x        ;check enemy buffer flag for non-active enemy slot
         checka
          beq CreateL             ;branch out of loop if found
          dex                     ;otherwise check next slot
          bpl ChkNoEn             ;branch until all slots are checked
          bmi RetEOfs             ;if no empty slots were found, branch to leave
CreateL:  ldan ++$00                ;initialize enemy state
          stax Enemy_State,x
          ldan ++Lakitu             ;create lakitu enemy object
          stax Enemy_ID,x
          jsr SetupLakitu         ;do a sub to set up lakitu
          ldan ++$20
          jsr PutAtRightExtent    ;finish setting up lakitu
RetEOfs:  ldx ObjectOffset        ;get enemy object buffer offset again and leave
ExLSHand: rts

;--------------------------------

CreateSpiny:
          lda Player_Y_Position      ;if player above a certain point, branch to leave
          cmpn ++$2c
              cmpcy
          bcc ExLSHand
          lday Enemy_State,y          ;if lakitu is not in normal state, branch to leave
         checka
          bne ExLSHand
          lday Enemy_PageLoc,y        ;store horizontal coordinates (high and low) of lakitu
          stax Enemy_PageLoc,x        ;into the coordinates of the spiny we're going to create
          lday Enemy_X_Position,y
          stax Enemy_X_Position,x
          ldan ++$01                   ;put spiny within vertical screen unit
          stax Enemy_Y_HighPos,x
          lday Enemy_Y_Position,y     ;put spiny eight pixels above where lakitu is
          secsub
          sbcn ++$08
          stax Enemy_Y_Position,x
          ldax PseudoRandomBitReg,x   ;get 2 LSB of LSFR and save to Y
          andn ++%00000011
          tay
          ldxn ++$02
DifLoop:  lday PRDiffAdjustData,y     ;get three values and save them
          stax SCRATCHPAD+$01,x                  ;to $01-$03
          iny
          iny                        ;increment Y four bytes for each value
          iny
          iny
          dex                        ;decrement X for each one
          bpl DifLoop                ;loop until all three are written
          ldx ObjectOffset           ;get enemy object buffer offset
          jsr PlayerLakituDiff       ;move enemy, change direction, get value - difference
          ldy Player_X_Speed         ;check player's horizontal speed
          cpyn ++$08
              cmpcy
          bcs SetSpSpd               ;if moving faster than a certain amount, branch elsewhere
          tay                        ;otherwise save value in A to Y for now
          ldax PseudoRandomBitReg+1,x
          andn ++%00000011             ;get one of the LSFR parts and save the 2 LSB
          beq UsePosv                ;branch if neither bits are set
          tya
          eorn ++%11111111             ;otherwise get two's compliment of Y
          tay
          iny
UsePosv:  tya                        ;put value from A in Y back to A (they will be lost anyway)
SetSpSpd: jsr SmallBBox              ;set bounding box control, init attributes, lose contents of A
          ldyn ++$02
          stax Enemy_X_Speed,x        ;set horizontal speed to zero because previous contents
          cmpn ++$00                   ;of A were lost...branch here will never be taken for
          bmi SpinyRte               ;the same reason
          dey
SpinyRte: styx Enemy_MovingDir,x      ;set moving direction to the right
          ldan ++$fd
          stax Enemy_Y_Speed,x        ;set vertical speed to move upwards
          ldan ++$01
          stax Enemy_Flag,x           ;enable enemy object by setting flag
          ldan ++$05
          stax Enemy_State,x          ;put spiny in egg state and leave
ChpChpEx: rts

;--------------------------------

FirebarSpinSpdData:
      .db $28, $38, $28, $38, $28

FirebarSpinDirData:
      .db $00, $00, $10, $10, $00

InitLongFirebar:
      jsr DuplicateEnemyObj       ;create enemy object for long firebar

InitShortFirebar:
      ldan ++$00                    ;initialize low byte of spin state
      stax FirebarSpinState_Low,x
      ldax Enemy_ID,x              ;subtract $1b from enemy identifier
      secsub                         ;to get proper offset for firebar data
      sbcn ++$1b
      tay
      lday FirebarSpinSpdData,y    ;get spinning speed of firebar
      stax FirebarSpinSpeed,x
      lday FirebarSpinDirData,y    ;get spinning direction of firebar
      stax FirebarSpinDirection,x
      ldax Enemy_Y_Position,x
      clc                         ;add four pixels to vertical coordinate
      adcn ++$04
      stax Enemy_Y_Position,x
      ldax Enemy_X_Position,x
      clc                         ;add four pixels to horizontal coordinate
      adcn ++$04
          push af
      stax Enemy_X_Position,x
      ldax Enemy_PageLoc,x
          ld h,a
          pop af
          ld a,h
      adcn ++$00                    ;add carry to page location
      stax Enemy_PageLoc,x
      jmp TallBBox2               ;set bounding box control (not used) and leave

;--------------------------------
;$00-$01 - used to hold pseudorandom bits

FlyCCXPositionData:
      .db $80, $30, $40, $80
      .db $30, $50, $50, $70
      .db $20, $40, $80, $a0
      .db $70, $40, $90, $68

FlyCCXSpeedData:
      .db $0e, $05, $06, $0e
      .db $1c, $20, $10, $0c
      .db $1e, $22, $18, $14

FlyCCTimerData:
      .db $10, $60, $20, $48

InitFlyingCheepCheep:
         lda FrenzyEnemyTimer       ;if timer here not expired yet, branch to leave
         checka
         bne ChpChpEx
         jsr SmallBBox              ;jump to set bounding box size $09 and init other values
         ldax PseudoRandomBitReg+1,x
         andn ++%00000011             ;set pseudorandom offset here
         tay
         lday FlyCCTimerData,y       ;load timer with pseudorandom offset
         sta FrenzyEnemyTimer
         ldyn ++$03                   ;load Y with default value
         lda SecondaryHardMode
         checka
         beq MaxCC                  ;if secondary hard mode flag not set, do not increment Y
         iny                        ;otherwise, increment Y to allow as many as four onscreen
MaxCC:   sty SCRATCHPAD+$00                    ;store whatever pseudorandom bits are in Y
         cpxi SCRATCHPAD+$00                    ;compare enemy object buffer offset with Y
              cmpcy
         bcs ChpChpEx               ;if X =HIGH  Y, branch to leave
         ldax PseudoRandomBitReg,x
         andn ++%00000011             ;get last two bits of LSFR, first part
         sta SCRATCHPAD+$00                    ;and store in two places
         sta SCRATCHPAD+$01
         ldan ++$fb                   ;set vertical speed for cheep-cheep
         stax Enemy_Y_Speed,x
         ldan ++$00                   ;load default value
         ldy Player_X_Speed         ;check player's horizontal speed
         checky
         beq GSeed                  ;if player not moving left or right, skip this part
         ldan ++$04
         cpyn ++$19                   ;if moving to the right but not very quickly,
              cmpcy
         bcc GSeed                  ;do not change A
         asl                        ;otherwise, multiply A by 2
GSeed:   pha                        ;save to stack
         clc
         adci SCRATCHPAD+$00                    ;add to last two bits of LSFR we saved earlier
         sta SCRATCHPAD+$00                    ;save it there
         ldax PseudoRandomBitReg+1,x
         andn ++%00000011             ;if neither of the last two bits of second LSFR set,
         beq RSeed                  ;skip this part and save contents of $00
         ldax PseudoRandomBitReg+2,x
         andn ++%00001111             ;otherwise overwrite with lower nybble of
         sta SCRATCHPAD+$00                    ;third LSFR part
RSeed:   pla                        ;get value from stack we saved earlier
         clc
         adci SCRATCHPAD+$01                    ;add to last two bits of LSFR we saved in other place
         tay                        ;use as pseudorandom offset here
         lday FlyCCXSpeedData,y      ;get horizontal speed using pseudorandom offset
         stax Enemy_X_Speed,x
         ldan ++$01                   ;set to move towards the right
         stax Enemy_MovingDir,x
         lda Player_X_Speed         ;if player moving left or right, branch ahead of this part
         checka
         bne D2XPos1
         ldy SCRATCHPAD+$00                    ;get first LSFR or third LSFR lower nybble
         tya                        ;and check for d1 set
         andn ++%00000010
         beq D2XPos1                ;if d1 not set, branch
         ldax Enemy_X_Speed,x
         eorn ++$ff                   ;if d1 set, change horizontal speed
         clc                        ;into two's compliment, thus moving in the opposite
         adcn ++$01                   ;direction
         stax Enemy_X_Speed,x
         incx Enemy_MovingDir,x      ;increment to move towards the left
D2XPos1: tya                        ;get first LSFR or third LSFR lower nybble again
         andn ++%00000010
         beq D2XPos2                ;check for d1 set again, branch again if not set
         lda Player_X_Position      ;get player's horizontal position
         clc
         adcy FlyCCXPositionData,y   ;if d1 set, add value obtained from pseudorandom offset
          push af
         stax Enemy_X_Position,x     ;and save as enemy's horizontal position
          pop af
         lda Player_PageLoc         ;get player's page location
         adcn ++$00                   ;add carry and jump past this part
         jmp FinCCSt
D2XPos2: lda Player_X_Position      ;get player's horizontal position
         secsub
         sbcy FlyCCXPositionData,y   ;if d1 not set, subtract value obtained from pseudorandom
          push af
         stax Enemy_X_Position,x     ;offset and save as enemy's horizontal position
          pop af
         lda Player_PageLoc         ;get player's page location
         sbcn ++$00                   ;subtract borrow
FinCCSt: stax Enemy_PageLoc,x        ;save as enemy's page location
         ldan ++$01
         stax Enemy_Flag,x           ;set enemy's buffer flag
         stax Enemy_Y_HighPos,x      ;set enemy's high vertical byte
         ldan ++$f8
         stax Enemy_Y_Position,x     ;put enemy below the screen, and we are done
         rts

;--------------------------------

InitBowser:
      jsr DuplicateEnemyObj     ;jump to create another bowser object
      stx BowserFront_Offset    ;save offset of first here
      ldan ++$00
      sta BowserBodyControls    ;initialize bowser's body controls
      sta BridgeCollapseOffset  ;and bridge collapse offset
      ldax Enemy_X_Position,x
      sta BowserOrigXPos        ;store original horizontal position here
      ldan ++$df
      sta BowserFireBreathTimer ;store something here
      stax Enemy_MovingDir,x     ;and in moving direction
      ldan ++$20
      sta BowserFeetCounter     ;set bowser's feet timer and in enemy timer
      stax EnemyFrameTimer,x
      ldan ++$05
      sta BowserHitPoints       ;give bowser 5 hit points
      lsr
      sta BowserMovementSpeed   ;set default movement speed here
      rts

;--------------------------------

DuplicateEnemyObj:
        ldyn ++$ff                ;start at beginning of enemy slots
FSLoop: iny                     ;increment one slot
        lday Enemy_Flag,y        ;check enemy buffer flag for empty slot
         checka
        bne FSLoop              ;if set, branch and keep checking
        sty DuplicateObj_Offset ;otherwise set offset here
        txa                     ;transfer original enemy buffer offset
        oran ++%10000000          ;store with d7 set as flag in new enemy
        stay Enemy_Flag,y        ;slot as well as enemy offset
        ldax Enemy_PageLoc,x
        stay Enemy_PageLoc,y     ;copy page location and horizontal coordinates
        ldax Enemy_X_Position,x  ;from original enemy to new enemy
        stay Enemy_X_Position,y
        ldan ++$01
        stax Enemy_Flag,x        ;set flag as normal for original enemy
        stay Enemy_Y_HighPos,y   ;set high vertical byte for new enemy
        ldax Enemy_Y_Position,x
        stay Enemy_Y_Position,y  ;copy vertical coordinate from original to new
FlmEx:  rts                     ;and then leave

;--------------------------------

FlameYPosData:
      .db $90, $80, $70, $90

FlameYMFAdderData:
      .db $ff, $01

InitBowserFlame:
        lda FrenzyEnemyTimer        ;if timer not expired yet, branch to leave
         checka
        bne FlmEx
        stax Enemy_Y_MoveForce,x     ;reset something here
        lda NoiseSoundQueue
        oran ++Sfx_BowserFlame        ;load bowser's flame sound into queue
        sta NoiseSoundQueue
        ldy BowserFront_Offset      ;get bowser's buffer offset
        lday Enemy_ID,y              ;check for bowser
        cmpn ++Bowser
        beq SpawnFromMouth          ;branch if found
        jsr SetFlameTimer           ;get timer data based on flame counter
        clc
        adcn ++$20                    ;add 32 frames by default
        ldy SecondaryHardMode
         checky
        beq SetFrT                  ;if secondary mode flag not set, use as timer setting
        secsub
        sbcn ++$10                    ;otherwise subtract 16 frames for secondary hard mode
SetFrT: sta FrenzyEnemyTimer        ;set timer accordingly
        ldax PseudoRandomBitReg,x
        andn ++%00000011              ;get 2 LSB from first part of LSFR
        stax BowserFlamePRandomOfs,x ;set here
        tay                         ;use as offset
        lday FlameYPosData,y         ;load vertical position based on pseudorandom offset

PutAtRightExtent:
      stax Enemy_Y_Position,x    ;set vertical position
      lda ScreenRight_X_Pos
      clc
      adcn ++$20                  ;place enemy 32 pixels beyond right side of screen
       push af
      stax Enemy_X_Position,x
       pop af
      lda ScreenRight_PageLoc
      adcn ++$00                  ;add carry
      stax Enemy_PageLoc,x
      jmp FinishFlame           ;skip this part to finish setting values

SpawnFromMouth:
       lday Enemy_X_Position,y    ;get bowser's horizontal position
       secsub
       sbcn ++$0e                  ;subtract 14 pixels
       stax Enemy_X_Position,x    ;save as flame's horizontal position
       lday Enemy_PageLoc,y
       stax Enemy_PageLoc,x       ;copy page location from bowser to flame
       lday Enemy_Y_Position,y
       clc                       ;add 8 pixels to bowser's vertical position
       adcn ++$08
       stax Enemy_Y_Position,x    ;save as flame's vertical position
       ldax PseudoRandomBitReg,x
       andn ++%00000011            ;get 2 LSB from first part of LSFR
       stax Enemy_YMF_Dummy,x     ;save here
       tay                       ;use as offset
       lday FlameYPosData,y       ;get value here using bits as offset
       ldyn ++$00                  ;load default offset
       cmpx Enemy_Y_Position,x    ;compare value to flame's current vertical position
              cmpcy
       bcc SetMF                 ;if less, do not increment offset
       iny                       ;otherwise increment now
SetMF: lday FlameYMFAdderData,y   ;get value here and save
       stax Enemy_Y_MoveForce,x   ;to vertical movement force
       ldan ++$00
       sta EnemyFrenzyBuffer     ;clear enemy frenzy buffer

FinishFlame:
      ldan ++$08                 ;set $08 for bounding box control
      stax Enemy_BoundBoxCtrl,x
      ldan ++$01                 ;set high byte of vertical and
      stax Enemy_Y_HighPos,x    ;enemy buffer flag
      stax Enemy_Flag,x
      lsr
      stax Enemy_X_MoveForce,x  ;initialize horizontal movement force (младшая часть X-координаты), and
      stax Enemy_State,x        ;enemy state
      rts

;--------------------------------

FireworksXPosData:
      .db $00, $30, $60, $60, $00, $20

FireworksYPosData:
      .db $60, $40, $70, $40, $60, $30

InitFireworks:
          lda FrenzyEnemyTimer         ;if timer not expired yet, branch to leave
         checka
          bne ExitFWk
          ldan ++$20                     ;otherwise reset timer
          sta FrenzyEnemyTimer
          deci FireworksCounter         ;decrement for each explosion
          ldyn ++$06                     ;start at last slot
StarFChk: dey
          lday Enemy_ID,y               ;check for presence of star flag object
          cmpn ++StarFlagObject          ;if there isn't a star flag object,
          bne StarFChk                 ;routine goes into infinite loop = crash
          lday Enemy_X_Position,y
          secsub                          ;get horizontal coordinate of star flag object, then
          sbcn ++$30                     ;subtract 48 pixels from it and save to
          pha                          ;the stack
          ldaykeepcy Enemy_PageLoc,y
          sbcn ++$00                     ;subtract the carry from the page location
          sta SCRATCHPAD+$00                      ;of the star flag object
          lda FireworksCounter         ;get fireworks counter
          clc
          adcy Enemy_State,y            ;add state of star flag object (possibly not necessary)
          tay                          ;use as offset
          pla                          ;get saved horizontal coordinate of star flag - 48 pixels
          clc
          adcy FireworksXPosData,y      ;add number based on offset of fireworks counter
           push af
          stax Enemy_X_Position,x       ;store as the fireworks object horizontal coordinate
           pop af
          lda SCRATCHPAD+$00
          adcn ++$00                     ;add carry and store as page location for
          stax Enemy_PageLoc,x          ;the fireworks object
          lday FireworksYPosData,y      ;get vertical position using same offset
          stax Enemy_Y_Position,x       ;and store as vertical coordinate for fireworks object
          ldan ++$01
          stax Enemy_Y_HighPos,x        ;store in vertical high byte
          stax Enemy_Flag,x             ;and activate enemy buffer flag
          lsr
          stax ExplosionGfxCounter,x    ;initialize explosion counter
          ldan ++$08
          stax ExplosionTimerCounter,x  ;set explosion timing counter
ExitFWk:  rts

;--------------------------------

Bitmasks:
      .db %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

Enemy17YPosData:
      .db $40, $30, $90, $50, $20, $60, $a0, $70

SwimCC_IDData:
      .db $0a, $0b

BulletBillCheepCheep:
         lda FrenzyEnemyTimer      ;if timer not expired yet, branch to leave
         checka
         bne ExF17
         lda AreaType              ;are we in a water-type level?
         checka
         bne DoBulletBills         ;if not, branch elsewhere
         cpxn ++$03                  ;are we past third enemy slot?
              cmpcy
         bcs ExF17                 ;if so, branch to leave
         ldyn ++$00                  ;load default offset
         ldax PseudoRandomBitReg,x
         cmpn ++$aa                  ;check first part of LSFR against preset value
              cmpcy
         bcc ChkW2                 ;if less than preset, do not increment offset
         iny                       ;otherwise increment
ChkW2:   lda WorldNumber           ;check world number
         cmpn ++World2
         beq Get17ID               ;if we're on world 2, do not increment offset
         iny                       ;otherwise increment
Get17ID: tya
         andn ++%00000001            ;mask out all but last bit of offset
         tay
         lday SwimCC_IDData,y       ;load identifier for cheep-cheeps
Set17ID: stax Enemy_ID,x            ;store whatever's in A as enemy identifier
         lda BitMFilter
         cmpn ++$ff                  ;if not all bits set, skip init part and compare bits
         bne GetRBit
         ldan ++$00                  ;initialize vertical position filter
         sta BitMFilter
GetRBit: ldax PseudoRandomBitReg,x  ;get first part of LSFR
         andn ++%00000111            ;mask out all but 3 LSB
ChkRBit: tay                       ;use as offset
         lday Bitmasks,y            ;load bitmask
         biti BitMFilter            ;perform AND on filter without changing it
         beq AddFBit
         iny                       ;increment offset
         tya
         andn ++%00000111            ;mask out all but 3 LSB thus keeping it 0-7
         jmp ChkRBit               ;do another check
AddFBit: orai BitMFilter            ;add bit to already set bits in filter
         sta BitMFilter            ;and store
         lday Enemy17YPosData,y     ;load vertical position using offset
         jsr PutAtRightExtent      ;set vertical position and other values
         stax Enemy_YMF_Dummy,x     ;initialize dummy variable
         ldan ++$20                  ;set timer
         sta FrenzyEnemyTimer
         jmp CheckpointEnemyID     ;process our new enemy object

DoBulletBills:
          ldyn ++$ff                   ;start at beginning of enemy slots
BB_SLoop: iny                        ;move onto the next slot
          cpyn ++$05                   ;branch to play sound if we've done all slots
              cmpcy
          bcs FireBulletBill
          lday Enemy_Flag,y           ;if enemy buffer flag not set,
         checka
          beq BB_SLoop               ;loop back and check another slot
          lday Enemy_ID,y
          cmpn ++BulletBill_FrenzyVar  ;check enemy identifier for
          bne BB_SLoop               ;bullet bill object (frenzy variant)
ExF17:    rts                        ;if found, leave

FireBulletBill:
      lda Square2SoundQueue
      oran ++Sfx_Blast            ;play fireworks/gunfire sound
      sta Square2SoundQueue
      ldan ++BulletBill_FrenzyVar ;load identifier for bullet bill object
         checka
      bne Set17ID               ;unconditional branch

;--------------------------------
;$00 - used to store Y position of group enemies
;$01 - used to store enemy ID
;$02 - used to store page location of right side of screen
;$03 - used to store X position of right side of screen

HandleGroupEnemies:
        ldyn ++$00                  ;load value for green koopa troopa
        secsub
        sbcn ++$37                  ;subtract $37 from second byte read
        pha                       ;save result in stack for now
        cmpn ++$04                  ;was byte in $3b-$3e range?
              cmpcy
        bcs SnglID                ;if so, branch
        pha                       ;save another copy to stack
        ldyn ++Goomba               ;load value for goomba enemy
        lda PrimaryHardMode       ;if primary hard mode flag not set,
         checka
        beq PullID                ;branch, otherwise change to value
        ldyn ++BuzzyBeetle          ;for buzzy beetle
PullID: pla                       ;get second copy from stack
SnglID: sty SCRATCHPAD+$01                   ;save enemy id here
        ldyn ++$b0                  ;load default y coordinate
        andn ++$02                  ;check to see if d1 was set
        beq SetYGp                ;if so, move y coordinate up,
        ldyn ++$70                  ;otherwise branch and use default
SetYGp: sty SCRATCHPAD+$00                   ;save y coordinate here
        lda ScreenRight_PageLoc   ;get page number of right edge of screen
        sta SCRATCHPAD+$02                   ;save here
        lda ScreenRight_X_Pos     ;get pixel coordinate of right edge
        sta SCRATCHPAD+$03                   ;save here
        ldyn ++$02                  ;load two enemies by default
        pla                       ;get first copy from stack
        lsr                       ;check to see if d0 was set
        bcc CntGrp                ;if not, use default value
        iny                       ;otherwise increment to three enemies
CntGrp: sty NumberofGroupEnemies  ;save number of enemies here
GrLoop: ldxn ++$ff                  ;start at beginning of enemy buffers
GSltLp: inx                       ;increment and branch if past
        cpxn ++$05                  ;end of buffers
              cmpcy
        bcs NextED
        ldax Enemy_Flag,x          ;check to see if enemy is already
         checka
        bne GSltLp                ;stored in buffer, and branch if so
        lda SCRATCHPAD+$01
        stax Enemy_ID,x            ;store enemy object identifier
        lda SCRATCHPAD+$02
        stax Enemy_PageLoc,x       ;store page location for enemy object
        lda SCRATCHPAD+$03
        stax Enemy_X_Position,x    ;store x coordinate for enemy object
        clc
        adcn ++$18                  ;add 24 pixels for next enemy
        sta SCRATCHPAD+$03
        lda SCRATCHPAD+$02                   ;add carry to page location for
        adcn ++$00                  ;next enemy
        sta SCRATCHPAD+$02
        lda SCRATCHPAD+$00                   ;store y coordinate for enemy object
        stax Enemy_Y_Position,x
        ldan ++$01                  ;activate flag for buffer, and
        stax Enemy_Y_HighPos,x     ;put enemy within the screen vertically
        stax Enemy_Flag,x
        jsr CheckpointEnemyID     ;process each enemy object separately
        deci NumberofGroupEnemies  ;do this until we run out of enemy objects
        bne GrLoop
NextED: jmp Inc2B                 ;jump to increment data offset and leave

;--------------------------------

InitPiranhaPlant:
      ldan ++$01                     ;set initial speed
      stax PiranhaPlant_Y_Speed,x
      lsr
      stax Enemy_State,x            ;initialize enemy state and what would normally
      stax PiranhaPlant_MoveFlag,x  ;be used as vertical speed, but not in this case
      ldax Enemy_Y_Position,x
      stax PiranhaPlantDownYPos,x   ;save original vertical coordinate here
      secsub
      sbcn ++$18
      stax PiranhaPlantUpYPos,x     ;save original vertical coordinate - 24 pixels here
      ldan ++$09
      jmp SetBBox2                 ;set specific value for bounding box control ;начиная с объекта #9 идут misc objects (что это???)

;--------------------------------

InitEnemyFrenzy:
      ldax Enemy_ID,x        ;load enemy identifier
      sta EnemyFrenzyBuffer ;save in enemy frenzy buffer
      secsub
      sbcn ++$12              ;subtract 12 and use as offset for jump engine
      jsr JumpEngine

;frenzy object jump table
      .dw LakituAndSpinyHandler
      .dw NoFrenzyCode
      .dw InitFlyingCheepCheep
      .dw InitBowserFlame
      .dw InitFireworks
      .dw BulletBillCheepCheep

;--------------------------------

NoFrenzyCode:
      rts

;--------------------------------

EndFrenzy:
           ldyn ++$05               ;start at last slot
LakituChk: lday Enemy_ID,y         ;check enemy identifiers
           cmpn ++Lakitu            ;for lakitu
           bne NextFSlot
           ldan ++$01               ;if found, set state
           stay Enemy_State,y
NextFSlot: dey                    ;move onto the next slot
           bpl LakituChk          ;do this until all slots are checked
           ldan ++$00
           sta EnemyFrenzyBuffer  ;empty enemy frenzy buffer
           stax Enemy_Flag,x       ;disable enemy buffer flag for this object
           rts

;--------------------------------

InitJumpGPTroopa:
           ldan ++$02                  ;set for movement to the left
           stax Enemy_MovingDir,x
           ldan ++$f8                  ;set horizontal speed
           stax Enemy_X_Speed,x
TallBBox2: ldan ++$03                  ;set specific value for bounding box control
SetBBox2:  stax Enemy_BoundBoxCtrl,x  ;set bounding box control then leave
           rts

;--------------------------------

InitBalPlatform:
        decx Enemy_Y_Position,x    ;raise vertical position by two pixels
        decx Enemy_Y_Position,x
        ldy SecondaryHardMode     ;if secondary hard mode flag not set,
         checky
        bne AlignP                ;branch ahead
        ldyn ++$02                  ;otherwise set value here
        jsr PosPlatform           ;do a sub to add or subtract pixels
AlignP: ldyn ++$ff                  ;set default value here for now
        lda BalPlatformAlignment  ;get current balance platform alignment
        stax Enemy_State,x         ;set platform alignment to object state here
         checka
        bpl SetBPA                ;if old alignment $ff, put $ff as alignment for negative
        txa                       ;if old contents already $ff, put
        tay                       ;object offset as alignment to make next positive
SetBPA: sty BalPlatformAlignment  ;store whatever value's in Y here
        ldan ++$00
        stax Enemy_MovingDir,x     ;init moving direction
        tay                       ;init Y
        jsr PosPlatform           ;do a sub to add 8 pixels, then run shared code here

;--------------------------------

InitDropPlatform:
      ldan ++$ff
      stax PlatformCollisionFlag,x  ;set some value here
      jmp CommonPlatCode           ;then jump ahead to execute more code

;--------------------------------

InitHoriPlatform:
      ldan ++$00
      stax XMoveSecondaryCounter,x  ;init one of the moving counters
      jmp CommonPlatCode           ;jump ahead to execute more code

;--------------------------------

InitVertPlatform:
       ldyn ++$40                    ;set default value here
       ldax Enemy_Y_Position,x      ;check vertical position
         checka
       bpl SetYO                   ;if above a certain point, skip this part
       eorn ++$ff
       clc                         ;otherwise get two's compliment
       adcn ++$01
       ldyn ++$c0                    ;get alternate value to add to vertical position
SetYO: stax YPlatformTopYPos,x      ;save as top vertical position
       tya
       clc                         ;load value from earlier, add number of pixels 
       adcx Enemy_Y_Position,x      ;to vertical position
       stax YPlatformCenterYPos,x   ;save result as central vertical position

;--------------------------------

CommonPlatCode: 
        jsr InitVStf              ;do a sub to init certain other values 
SPBBox: ldan ++$05                  ;set default bounding box size control
        ldy AreaType
        cpyn ++$03                  ;check for castle-type level
        beq CasPBB                ;use default value if found
        ldy SecondaryHardMode     ;otherwise check for secondary hard mode flag
         checky
        bne CasPBB                ;if set, use default value
        ldan ++$06                  ;use alternate value if not castle or secondary not set
CasPBB: stax Enemy_BoundBoxCtrl,x  ;set bounding box size control here and leave
        rts

;--------------------------------

LargeLiftUp:
      jsr PlatLiftUp       ;execute code for platforms going up
      jmp LargeLiftBBox    ;overwrite bounding box for large platforms

LargeLiftDown:
      jsr PlatLiftDown     ;execute code for platforms going down

LargeLiftBBox:
      jmp SPBBox           ;jump to overwrite bounding box size control

;--------------------------------

PlatLiftUp:
      ldan ++$10                 ;set movement amount here
      stax Enemy_Y_MoveForce,x
      ldan ++$ff                 ;set moving speed for platforms going up
      stax Enemy_Y_Speed,x
      jmp CommonSmallLift      ;skip ahead to part we should be executing

;--------------------------------

PlatLiftDown:
      ldan ++$f0                 ;set movement amount here
      stax Enemy_Y_MoveForce,x
      ldan ++$00                 ;set moving speed for platforms going down
      stax Enemy_Y_Speed,x

;--------------------------------

CommonSmallLift:
      ldyn ++$01
      jsr PosPlatform           ;do a sub to add 12 pixels due to preset value  
      ldan ++$04
      stax Enemy_BoundBoxCtrl,x  ;set bounding box control for small platforms
      rts

;--------------------------------

PlatPosDataLow:
      .db $08,$0c,$f8

PlatPosDataHigh:
      .db $00,$00,$ff

PosPlatform:
      ldax Enemy_X_Position,x  ;get horizontal coordinate
      clc
      adcy PlatPosDataLow,y    ;add or subtract pixels depending on offset
          push af
      stax Enemy_X_Position,x  ;store as new horizontal coordinate
      ldax Enemy_PageLoc,x
          ld h,a
          pop af
          ld a,h
      adcy PlatPosDataHigh,y   ;add or subtract page location depending on offset
      stax Enemy_PageLoc,x     ;store as new page location
      rts                     ;and go back

;--------------------------------

EndOfEnemyInitCode:
      rts

;-------------------------------------------------------------------------------------

RunEnemyObjectsCore:
	;jr $
       ldx ObjectOffset  ;get offset for enemy object buffer
       ldan ++$00          ;load value 0 for jump engine by default
       ldyx Enemy_ID,x
       cpyn ++$15          ;if enemy object LOW  $15, use default value
              cmpcy
       bcc JmpEO
       tya               ;otherwise subtract $14 from the value and use
              cmpcy
       sbcn ++$14          ;as value for jump engine
JmpEO: jsr JumpEngine
      
      .dw RunNormalEnemies  ;for objects $00-$14

      .dw RunBowserFlame    ;for objects $15-$1f
      .dw RunFireworks
      .dw NoRunCode
      .dw NoRunCode
      .dw NoRunCode
      .dw NoRunCode
      .dw RunFirebarObj
      .dw RunFirebarObj
      .dw RunFirebarObj
      .dw RunFirebarObj
      .dw RunFirebarObj

      .dw RunFirebarObj     ;for objects $20-$2f
      .dw RunFirebarObj
      .dw RunFirebarObj
      .dw NoRunCode
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunSmallPlatform
      .dw RunSmallPlatform
      .dw RunBowser
      .dw PowerUpObjHandler
      .dw VineObjectHandler

      .dw NoRunCode         ;for objects $30-$35
      .dw RunStarFlagObj
      .dw JumpspringHandler
      .dw NoRunCode
      .dw WarpZoneObject
      .dw RunRetainerObj

;--------------------------------

NoRunCode:
      rts

;--------------------------------

RunRetainerObj:
      jsr GetEnemyOffscreenBits
      jsr RelativeEnemyPosition
      jmp EnemyGfxHandler

;--------------------------------

RunNormalEnemies:
;TODO существенно ускорить это
          ldan ++$00                  ;init sprite attributes
          stax Enemy_SprAttrib,x
          ;jr $
          jsr GetEnemyOffscreenBits ;1589t (497 opt)
          jsr RelativeEnemyPosition ;316t (274 opt)
         if Z80
logicframe=$+1
            ld l,0
            dec l
            call z,EnemyGfxHandler ;только в последнем кадре логики (непосредственно перед отображением)
         else
          jsr EnemyGfxHandler ;4939t (внутри 3 вызова по 768t) (3280 opt) <----- TODO не вызывать, если это не последний кадр логики?
         endif
          jsr GetEnemyBoundBox ;631t (452 opt)
          jsr EnemyToBGCollisionDet ;3500t (внутри ChkUnderEnemy (cc46) = 1193t, BlockBufferChk_Enemy (cf18) = 1159t) (2058 opt) <-----
          jsr EnemiesCollision ;45/230t (может быть куда больше) (209 opt)
          jsr PlayerEnemyCollision ;230t (58 opt)
          ldy TimerControl          ;if master timer control set, skip to last routine
         checky
          bne SkipMove
          jsr EnemyMovementSubs ;1408t (833 opt)
SkipMove: jmp OffscreenBoundsCheck

EnemyMovementSubs:
      ldax Enemy_ID,x
      jsr JumpEngine

      .dw MoveNormalEnemy      ;only objects $00-$14 use this table
      .dw MoveNormalEnemy
      .dw MoveNormalEnemy
      .dw MoveNormalEnemy
      .dw MoveNormalEnemy
      .dw ProcHammerBro
      .dw MoveNormalEnemy
      .dw MoveBloober
      .dw MoveBulletBill
      .dw NoMoveCode
      .dw MoveSwimmingCheepCheep
      .dw MoveSwimmingCheepCheep
      .dw MovePodoboo
      .dw MovePiranhaPlant
      .dw MoveJumpingEnemy
      .dw ProcMoveRedPTroopa
      .dw MoveFlyGreenPTroopa
      .dw MoveLakitu
      .dw MoveNormalEnemy
      .dw NoMoveCode   ;dummy
      .dw MoveFlyingCheepCheep

;--------------------------------

NoMoveCode:
      rts

;--------------------------------

RunBowserFlame:
      jsr ProcBowserFlame
      jsr GetEnemyOffscreenBits
      jsr RelativeEnemyPosition
      jsr GetEnemyBoundBox
      jsr PlayerEnemyCollision
      jmp OffscreenBoundsCheck

;--------------------------------

RunFirebarObj:
      jsr ProcFirebar
      jmp OffscreenBoundsCheck

;--------------------------------

RunSmallPlatform:
      jsr GetEnemyOffscreenBits
      jsr RelativeEnemyPosition
      jsr SmallPlatformBoundBox
      jsr SmallPlatformCollision
      jsr RelativeEnemyPosition
      jsr DrawSmallPlatform
      jsr MoveSmallPlatform
      jmp OffscreenBoundsCheck

;--------------------------------

RunLargePlatform:
        jsr GetEnemyOffscreenBits
        jsr RelativeEnemyPosition
        jsr LargePlatformBoundBox
        jsr LargePlatformCollision
        lda TimerControl             ;if master timer control set,
         checka
        bne SkipPT                   ;skip subroutine tree
        jsr LargePlatformSubroutines
SkipPT: jsr RelativeEnemyPosition
        jsr DrawLargePlatform
        jmp OffscreenBoundsCheck

;--------------------------------

LargePlatformSubroutines:
      ldax Enemy_ID,x  ;subtract $24 to get proper offset for jump table
      secsub
      sbcn ++$24
      jsr JumpEngine

      .dw BalancePlatform   ;table used by objects $24-$2a
      .dw YMovingPlatform
      .dw MoveLargeLiftPlat
      .dw MoveLargeLiftPlat
      .dw XMovingPlatform
      .dw DropPlatform
      .dw RightPlatform

;-------------------------------------------------------------------------------------

EraseEnemyObject:
;TODO ix
      ldan ++$00                 ;clear all enemy object variables
      stax Enemy_Flag,x
      stax Enemy_ID,x
      stax Enemy_State,x
      stax FloateyNum_Control,x
      stax EnemyIntervalTimer,x
      stax ShellChainCounter,x
      stax Enemy_SprAttrib,x
      stax EnemyFrameTimer,x
      rts

;-------------------------------------------------------------------------------------

MovePodoboo:
      ldax EnemyIntervalTimer,x   ;check enemy timer
         checka
      bne PdbM                   ;branch to move enemy if not expired
      jsr InitPodoboo            ;otherwise set up podoboo again
      ldax PseudoRandomBitReg+1,x ;get part of LSFR
      oran ++%10000000             ;set d7
      stax Enemy_Y_MoveForce,x    ;store as movement force
      andn ++%00001111             ;mask out high nybble
      oran ++$06                   ;set for at least six intervals
      stax EnemyIntervalTimer,x   ;store as new enemy timer
      ldan ++$f9
      stax Enemy_Y_Speed,x        ;set vertical speed to move podoboo upwards
PdbM: jmp MoveJ_EnemyVertically  ;branch to impose gravity on podoboo

;--------------------------------
;$00 - used in HammerBroJumpCode as bitmask

HammerThrowTmrData:
      .db $30, $1c

XSpeedAdderData:
      .db $00, $e8, $00, $18

RevivedXSpeed:
      .db $08, $f8, $0c, $f4

ProcHammerBro:
       ldax Enemy_State,x          ;check hammer bro's enemy state for d5 set
       andn ++%00100000
       beq ChkJH                  ;if not set, go ahead with code
       jmp MoveDefeatedEnemy      ;otherwise jump to something else
ChkJH: ldax HammerBroJumpTimer,x   ;check jump timer
         checka
       beq HammerBroJumpCode      ;if expired, branch to jump
       decx HammerBroJumpTimer,x   ;otherwise decrement jump timer
       lda Enemy_OffscreenBits
       andn ++%00001100             ;check offscreen bits
       bne MoveHammerBroXDir      ;if hammer bro a little offscreen, skip to movement code
       ldax HammerThrowingTimer,x  ;check hammer throwing timer
         checka
       bne DecHT                  ;if not expired, skip ahead, do not throw hammer
       ldy SecondaryHardMode      ;otherwise get secondary hard mode flag
       lday HammerThrowTmrData,y   ;get timer data using flag as offset
       stax HammerThrowingTimer,x  ;set as new timer
       jsr SpawnHammerObj         ;do a sub here to spawn hammer object
       bcc DecHT                  ;if carry clear, hammer not spawned, skip to decrement timer
       ldax Enemy_State,x
       oran ++%00001000             ;set d3 in enemy state for hammer throw
       stax Enemy_State,x
       jmp MoveHammerBroXDir      ;jump to move hammer bro
DecHT: decx HammerThrowingTimer,x  ;decrement timer
       jmp MoveHammerBroXDir      ;jump to move hammer bro

HammerBroJumpLData:
      .db $20, $37

HammerBroJumpCode:
       ldax Enemy_State,x           ;get hammer bro's enemy state
       andn ++%00000111              ;mask out all but 3 LSB
       cmpn ++$01                    ;check for d0 set (for jumping)
       beq MoveHammerBroXDir       ;if set, branch ahead to moving code
       ldan ++$00                    ;load default value here
       sta SCRATCHPAD+$00                     ;save into temp variable for now
       ldyn ++$fa                    ;set default vertical speed
       ldax Enemy_Y_Position,x      ;check hammer bro's vertical coordinate
         checka
       bmi SetHJ                   ;if on the bottom half of the screen, use current speed
       ldyn ++$fd                    ;otherwise set alternate vertical speed
       cmpn ++$70                    ;check to see if hammer bro is above the middle of screen
              cmpcy
       inci SCRATCHPAD+$00                     ;increment preset value to $01
       bcc SetHJ                   ;if above the middle of the screen, use current speed and $01
       deci SCRATCHPAD+$00                     ;otherwise return value to $00
       ldax PseudoRandomBitReg+1,x  ;get part of LSFR, mask out all but LSB
       andn ++$01
       bne SetHJ                   ;if d0 of LSFR set, branch and use current speed and $00
       ldyn ++$fa                    ;otherwise reset to default vertical speed
SetHJ: styx Enemy_Y_Speed,x         ;set vertical speed for jumping
       ldax Enemy_State,x           ;set d0 in enemy state for jumping
       oran ++$01
       stax Enemy_State,x
       lda SCRATCHPAD+$00                     ;load preset value here to use as bitmask
       andx PseudoRandomBitReg+2,x  ;and do bit-wise comparison with part of LSFR
       tay                         ;then use as offset
       lda SecondaryHardMode       ;check secondary hard mode flag
         checka
       bne HJump
       tay                         ;if secondary hard mode flag clear, set offset to 0
HJump: lday HammerBroJumpLData,y    ;get jump length timer data using offset from before
       stax EnemyFrameTimer,x       ;save in enemy timer
       ldax PseudoRandomBitReg+1,x
       oran ++%11000000              ;get contents of part of LSFR, set d7 and d6, then
       stax HammerBroJumpTimer,x    ;store in jump timer

MoveHammerBroXDir:
         ldyn ++$fc                  ;move hammer bro a little to the left
         lda FrameCounter
         andn ++%01000000            ;change hammer bro's direction every 64 frames
         bne Shimmy
         ldyn ++$04                  ;if d6 set in counter, move him a little to the right
Shimmy:  styx Enemy_X_Speed,x       ;store horizontal speed
         ldyn ++$01                  ;set to face right by default
         jsr PlayerEnemyDiff       ;get horizontal difference between player and hammer bro
         bmi SetShim               ;if enemy to the left of player, skip this part
         iny                       ;set to face left
         ldax EnemyIntervalTimer,x  ;check walking timer
         checka
         bne SetShim               ;if not yet expired, skip to set moving direction
         ldan ++$f8
         stax Enemy_X_Speed,x       ;otherwise, make the hammer bro walk left towards player
SetShim: styx Enemy_MovingDir,x     ;set moving direction

MoveNormalEnemy:
       ldyn ++$00                   ;init Y to leave horizontal movement as-is 
       ldax Enemy_State,x
       andn ++%01000000             ;check enemy state for d6 set, if set skip
       bne FallE                  ;to move enemy vertically, then horizontally if necessary
       ldax Enemy_State,x
       asl                        ;check enemy state for d7 set
       bcs SteadM                 ;if set, branch to move enemy horizontally
       ldax Enemy_State,x
       andn ++%00100000             ;check enemy state for d5 set
       bne MoveDefeatedEnemy      ;if set, branch to move defeated enemy object
       ldax Enemy_State,x
       andn ++%00000111             ;check d2-d0 of enemy state for any set bits
       beq SteadM                 ;if enemy in normal state, branch to move enemy horizontally
       cmpn ++$05
       beq FallE                  ;if enemy in state used by spiny's egg, go ahead here
       cmpn ++$03
              cmpcy
       bcs ReviveStunned          ;if enemy in states $03 or $04, skip ahead to yet another part
FallE: jsr MoveD_EnemyVertically  ;do a sub here to move enemy downwards
       ldyn ++$00
       ldax Enemy_State,x          ;check for enemy state $02
       cmpn ++$02
       beq MEHor                  ;if found, branch to move enemy horizontally
       andn ++%01000000             ;check for d6 set
       beq SteadM                 ;if not set, branch to something else
       ldax Enemy_ID,x
       cmpn ++PowerUpObject         ;check for power-up object
       beq SteadM
       bne SlowM                  ;if any other object where d6 set, jump to set Y
MEHor: jmp MoveEnemyHorizontally  ;jump here to move enemy horizontally for LOW HIGH  $2e and d6 set

SlowM:  ldyn ++$01                  ;if branched here, increment Y to slow horizontal movement
SteadM: ldax Enemy_X_Speed,x       ;get current horizontal speed
      pha                       ;save to stack
         checka
        bpl AddHS                 ;if not moving or moving right, skip, leave Y alone
        iny
        iny                       ;otherwise increment Y to next data
AddHS:  clc
        adcy XSpeedAdderData,y     ;add value here to slow enemy down if necessary
        stax Enemy_X_Speed,x       ;save as horizontal speed temporarily
        jsr MoveEnemyHorizontally ;then do a sub to move horizontally
      pla
        stax Enemy_X_Speed,x       ;get old horizontal speed from stack and return to
        rts                       ;original memory location, then leave

ReviveStunned:
         ldax EnemyIntervalTimer,x  ;if enemy timer not expired yet,
         checka
         bne ChkKillGoomba         ;skip ahead to something else
         stax Enemy_State,x         ;otherwise initialize enemy state to normal
         lda FrameCounter
         andn ++$01                  ;get d0 of frame counter
         tay                       ;use as Y and increment for movement direction
         iny
         styx Enemy_MovingDir,x     ;store as pseudorandom movement direction
         dey                       ;decrement for use as pointer
         lda PrimaryHardMode       ;check primary hard mode flag
         checka
         beq SetRSpd               ;if not set, use pointer as-is
         iny
         iny                       ;otherwise increment 2 bytes to next data
SetRSpd: lday RevivedXSpeed,y       ;load and store new horizontal speed
         stax Enemy_X_Speed,x       ;and leave
         rts

MoveDefeatedEnemy:
      jsr MoveD_EnemyVertically      ;execute sub to move defeated enemy downwards
      jmp MoveEnemyHorizontally      ;now move defeated enemy horizontally

ChkKillGoomba:
        cmpn ++$0e              ;check to see if enemy timer has reached
        bne NKGmba            ;a certain point, and branch to leave if not
        ldax Enemy_ID,x
        cmpn ++Goomba           ;check for goomba object
        bne NKGmba            ;branch if not found
        jsr EraseEnemyObject  ;otherwise, kill this goomba object
NKGmba: rts                   ;leave!

;--------------------------------

MoveJumpingEnemy:
      jsr MoveJ_EnemyVertically  ;do a sub to impose gravity on green paratroopa
      jmp MoveEnemyHorizontally  ;jump to move enemy horizontally

;--------------------------------

ProcMoveRedPTroopa:
          ldax Enemy_Y_Speed,x
          orax Enemy_Y_MoveForce,x     ;check for any vertical force or speed
          bne MoveRedPTUpOrDown       ;branch if any found
          stax Enemy_YMF_Dummy,x       ;initialize something here
          ldax Enemy_Y_Position,x      ;check current vs. original vertical coordinate
          cmpx RedPTroopaOrigXPos,x
              cmpcy
          bcs MoveRedPTUpOrDown       ;if current =HIGH  original, skip ahead to more code
          lda FrameCounter            ;get frame counter
          andn ++%00000111              ;mask out all but 3 LSB
          bne NoIncPT                 ;if any bits set, branch to leave
          incx Enemy_Y_Position,x      ;otherwise increment red paratroopa's vertical position
NoIncPT:  rts                         ;leave

MoveRedPTUpOrDown:
          ldax Enemy_Y_Position,x      ;check current vs. central vertical coordinate
          cmpx RedPTroopaCenterYPos,x
              cmpcy
          bcc MovPTDwn                ;if current LOW  central, jump to move downwards
          jmp MoveRedPTroopaUp        ;otherwise jump to move upwards
MovPTDwn: jmp MoveRedPTroopaDown      ;move downwards

;--------------------------------
;$00 - used to store adder for movement, also used as adder for platform
;$01 - used to store maximum value for secondary counter

MoveFlyGreenPTroopa:
        jsr XMoveCntr_GreenPTroopa ;do sub to increment primary and secondary counters
        jsr MoveWithXMCntrs        ;do sub to move green paratroopa accordingly, and horizontally
        ldyn ++$01                   ;set Y to move green paratroopa down
        lda FrameCounter
        andn ++%00000011             ;check frame counter 2 LSB for any bits set
        bne NoMGPT                 ;branch to leave if set to move up/down every fourth frame
        lda FrameCounter
        andn ++%01000000             ;check frame counter for d6 set
        bne YSway                  ;branch to move green paratroopa down if set
        ldyn ++$ff                   ;otherwise set Y to move green paratroopa up
YSway:  sty SCRATCHPAD+$00                    ;store adder here
        ldax Enemy_Y_Position,x
        clc                        ;add or subtract from vertical position
        adci SCRATCHPAD+$00                    ;to give green paratroopa a wavy flight
        stax Enemy_Y_Position,x
NoMGPT: rts                        ;leave!

XMoveCntr_GreenPTroopa:
         ldan ++$13                    ;load preset maximum value for secondary counter

XMoveCntr_Platform:
         sta SCRATCHPAD+$01                     ;store value here
         lda FrameCounter
         andn ++%00000011              ;branch to leave if not on
         bne NoIncXM                 ;every fourth frame
         ldyx XMoveSecondaryCounter,x ;get secondary counter
         ldax XMovePrimaryCounter,x   ;get primary counter
         lsr
         bcs DecSeXM                 ;if d0 of primary counter set, branch elsewhere
         cpyi SCRATCHPAD+$01                     ;compare secondary counter to preset maximum value
         beq IncPXM                  ;if equal, branch ahead of this part
         incx XMoveSecondaryCounter,x ;increment secondary counter and leave
NoIncXM: rts
IncPXM:  incx XMovePrimaryCounter,x   ;increment primary counter and leave
         rts
DecSeXM: tya                         ;put secondary counter in A
         checka
         beq IncPXM                  ;if secondary counter at zero, branch back
         decx XMoveSecondaryCounter,x ;otherwise decrement secondary counter and leave
         rts

MoveWithXMCntrs:
         ldax XMoveSecondaryCounter,x  ;save secondary counter to stack
         pha
         ldyn ++$01                     ;set value here by default
         ldax XMovePrimaryCounter,x
         andn ++%00000010               ;if d1 of primary counter is
         bne XMRight                  ;set, branch ahead of this part here
         ldax XMoveSecondaryCounter,x
         eorn ++$ff                     ;otherwise change secondary
         clc                          ;counter to two's compliment
         adcn ++$01
         stax XMoveSecondaryCounter,x
         ldyn ++$02                     ;load alternate value here
XMRight: styx Enemy_MovingDir,x        ;store as moving direction
         jsr MoveEnemyHorizontally
         sta SCRATCHPAD+$00                      ;save value obtained from sub here (сохраняем смещение X-координаты по сравнению с прошлым положением)
         pla                          ;get secondary counter from stack
         stax XMoveSecondaryCounter,x  ;and return to original place
         rts

;--------------------------------

BlooberBitmasks:
      .db %00111111, %00000011

MoveBloober:
        ldax Enemy_State,x
        andn ++%00100000             ;check enemy state for d5 set
        bne MoveDefeatedBloober    ;branch if set to move defeated bloober
        ldy SecondaryHardMode      ;use secondary hard mode flag as offset
        ldax PseudoRandomBitReg+1,x ;get LSFR
        andy BlooberBitmasks,y      ;mask out bits in LSFR using bitmask loaded with offset
        bne BlooberSwim            ;if any bits set, skip ahead to make swim
        txa
        lsr                        ;check to see if on second or fourth slot (1 or 3)
        bcc FBLeft                 ;if not, branch to figure out moving direction
        ldy Player_MovingDir       ;otherwise, load player's moving direction and
        bcs SBMDir                 ;do an unconditional branch to set
FBLeft: ldyn ++$02                   ;set left moving direction by default
        jsr PlayerEnemyDiff        ;get horizontal difference between player and bloober
        bpl SBMDir                 ;if enemy to the right of player, keep left
        dey                        ;otherwise decrement to set right moving direction
SBMDir: styx Enemy_MovingDir,x      ;set moving direction of bloober, then continue on here

BlooberSwim:
       jsr ProcSwimmingB        ;execute sub to make bloober swim characteristically
       ldax Enemy_Y_Position,x   ;get vertical coordinate
       secsub
       sbcx Enemy_Y_MoveForce,x  ;subtract movement force
       cmpn ++$20                 ;check to see if position is above edge of status bar
              cmpcy
       bcc SwimX                ;if so, don't do it
       stax Enemy_Y_Position,x   ;otherwise, set new vertical position, make bloober swim
SwimX: ldyx Enemy_MovingDir,x    ;check moving direction
       dey
       bne LeftSwim             ;if moving to the left, branch to second part
       ldax Enemy_X_Position,x
       clc                      ;add movement speed to horizontal coordinate
       adcx BlooperMoveSpeed,x
          push af
       stax Enemy_X_Position,x   ;store result as new horizontal coordinate
       ldax Enemy_PageLoc,x
          ld h,a
          pop af
          ld a,h
       adcn ++$00                 ;add carry to page location
       stax Enemy_PageLoc,x      ;store as new page location and leave
       rts

LeftSwim:
      ldax Enemy_X_Position,x
      secsub                      ;subtract movement speed from horizontal coordinate
      sbcx BlooperMoveSpeed,x
          push af
      stax Enemy_X_Position,x   ;store result as new horizontal coordinate
      ldax Enemy_PageLoc,x
          ld h,a
          pop af
          ld a,h
      sbcn ++$00                 ;subtract borrow from page location
      stax Enemy_PageLoc,x      ;store as new page location and leave
      rts

MoveDefeatedBloober:
      jmp MoveEnemySlowVert    ;jump to move defeated bloober downwards

ProcSwimmingB:
        ldax BlooperMoveCounter,x  ;get enemy's movement counter
        andn ++%00000010            ;check for d1 set
        bne ChkForFloatdown       ;branch if set
        lda FrameCounter
        andn ++%00000111            ;get 3 LSB of frame counter
        pha                       ;and save it to the stack
        ldax BlooperMoveCounter,x  ;get enemy's movement counter
        lsr                       ;check for d0 set
        bcs SlowSwim              ;branch if set
        pla                       ;pull 3 LSB of frame counter from the stack
         checka
        bne BSwimE                ;branch to leave, execute code only every eighth frame
        ldax Enemy_Y_MoveForce,x
        clc                       ;add to movement force to speed up swim
        adcn ++$01
        stax Enemy_Y_MoveForce,x   ;set movement force
        stax BlooperMoveSpeed,x    ;set as movement speed
        cmpn ++$02
        bne BSwimE                ;if certain horizontal speed, branch to leave
        incx BlooperMoveCounter,x  ;otherwise increment movement counter
BSwimE: rts

SlowSwim:
       pla                      ;pull 3 LSB of frame counter from the stack
         checka
       bne NoSSw                ;branch to leave, execute code only every eighth frame
       ldax Enemy_Y_MoveForce,x
       secsub                      ;subtract from movement force to slow swim
       sbcn ++$01
       stax Enemy_Y_MoveForce,x  ;set movement force
       stax BlooperMoveSpeed,x   ;set as movement speed
         checka
       bne NoSSw                ;if any speed, branch to leave
       incx BlooperMoveCounter,x ;otherwise increment movement counter
       ldan ++$02
       stax EnemyIntervalTimer,x ;set enemy's timer
NoSSw: rts                      ;leave

ChkForFloatdown:
      ldax EnemyIntervalTimer,x ;get enemy timer
         checka
      beq ChkNearPlayer        ;branch if expired

Floatdown:
      lda FrameCounter        ;get frame counter
      lsr                     ;check for d0 set
      bcs NoFD                ;branch to leave on every other frame
      incx Enemy_Y_Position,x  ;otherwise increment vertical coordinate
NoFD: rts                     ;leave

ChkNearPlayer:
;CY=0??? after JumpEngine
      ldax Enemy_Y_Position,x    ;get vertical coordinate
     or a ;???
      adcn ++$10                  ;add sixteen pixels
      cmpi Player_Y_Position     ;compare result with player's vertical coordinate
              cmpcy
      bcc Floatdown             ;if modified vertical less than player's, branch
      ldan ++$00
      stax BlooperMoveCounter,x  ;otherwise nullify movement counter
      rts

;--------------------------------

MoveBulletBill:
         ldax Enemy_State,x          ;check bullet bill's enemy object state for d5 set
         andn ++%00100000
         beq NotDefB                ;if not set, continue with movement code
         jmp MoveJ_EnemyVertically  ;otherwise jump to move defeated bullet bill downwards
NotDefB: ldan ++$e8                   ;set bullet bill's horizontal speed
         stax Enemy_X_Speed,x        ;and move it accordingly (note: this bullet bill
         jmp MoveEnemyHorizontally  ;object occurs in frenzy object $17, not from cannons)

;--------------------------------
;$02 - used to hold preset values
;$03 - used to hold enemy state

SwimCCXMoveData:
      .db $40, $80
      .db $04, $04 ;residual data, not used

MoveSwimmingCheepCheep:
        ldax Enemy_State,x         ;check cheep-cheep's enemy object state
        andn ++%00100000            ;for d5 set
        beq CCSwim                ;if not set, continue with movement code
        jmp MoveEnemySlowVert     ;otherwise jump to move defeated cheep-cheep downwards
CCSwim: sta SCRATCHPAD+$03                   ;save enemy state in $03
        ldax Enemy_ID,x            ;get enemy identifier
        secsub
        sbcn ++$0a                  ;subtract ten for cheep-cheep identifiers
        tay                       ;use as offset
        lday SwimCCXMoveData,y     ;load value here
        sta SCRATCHPAD+$02
        ldax Enemy_X_MoveForce,x   ;load horizontal force (младшая часть X-координаты)
        secsub
        sbci SCRATCHPAD+$02                   ;subtract preset value from horizontal force
          push af
        stax Enemy_X_MoveForce,x   ;store as new horizontal force (младшая часть X-координаты)
        ldax Enemy_X_Position,x    ;get horizontal coordinate
          ld h,a
          pop af
          ld a,h
        sbcn ++$00                  ;subtract borrow (thus moving it slowly)
          push af
        stax Enemy_X_Position,x    ;and save as new horizontal coordinate
        ldax Enemy_PageLoc,x
          ld h,a
          pop af
          ld a,h
        sbcn ++$00                  ;subtract borrow again, this time from the
        stax Enemy_PageLoc,x       ;page location, then save
        ldan ++$20
        sta SCRATCHPAD+$02                   ;save new value here
        cpxn ++$02                  ;check enemy object offset
              cmpcy
        bcc ExSwCC                ;if in first or second slot, branch to leave
        ldax CheepCheepMoveMFlag,x ;check movement flag
        cmpn ++$10                  ;if movement speed set to $00,
              cmpcy
        bcc CCSwimUpwards         ;branch to move upwards
        ldax Enemy_YMF_Dummy,x
        clc
        adci SCRATCHPAD+$02                   ;add preset value to dummy variable to get carry
          push af
        stax Enemy_YMF_Dummy,x     ;and save dummy
        ldax Enemy_Y_Position,x    ;get vertical coordinate
          ld h,a
          pop af
          ld a,h
        adci SCRATCHPAD+$03                   ;add carry to it plus enemy state to slowly move it downwards
          push af
        stax Enemy_Y_Position,x    ;save as new vertical coordinate
        ldax Enemy_Y_HighPos,x
          ld h,a
          pop af
          ld a,h
        adcn ++$00                  ;add carry to page location and
        jmp ChkSwimYPos           ;jump to end of movement code

CCSwimUpwards:
        ldax Enemy_YMF_Dummy,x
        secsub
        sbci SCRATCHPAD+$02                   ;subtract preset value to dummy variable to get borrow
          push af
        stax Enemy_YMF_Dummy,x     ;and save dummy
        ldax Enemy_Y_Position,x    ;get vertical coordinate
          ld h,a
          pop af
          ld a,h
        sbci SCRATCHPAD+$03                   ;subtract borrow to it plus enemy state to slowly move it upwards
          push af
        stax Enemy_Y_Position,x    ;save as new vertical coordinate
        ldax Enemy_Y_HighPos,x
          ld h,a
          pop af
          ld a,h
        sbcn ++$00                  ;subtract borrow from page location

ChkSwimYPos:
        stax Enemy_Y_HighPos,x     ;save new page location here
        ldyn ++$00                  ;load movement speed to upwards by default
        ldax Enemy_Y_Position,x    ;get vertical coordinate
        secsub
        sbcx CheepCheepOrigYPos,x  ;subtract original coordinate from current
        bpl YPDiff                ;if result positive, skip to next part
        ldyn ++$10                  ;otherwise load movement speed to downwards
        eorn ++$ff
        clc                       ;get two's compliment of result
        adcn ++$01                  ;to obtain total difference of original vs. current
YPDiff: cmpn ++$0f                  ;if difference between original vs. current vertical
              cmpcy
        bcc ExSwCC                ;coordinates LOW  15 pixels, leave movement speed alone
        tya
        stax CheepCheepMoveMFlag,x ;otherwise change movement speed
ExSwCC: rts                       ;leave

;--------------------------------
;$00 - used as counter for firebar parts
;$01 - used for oscillated high byte of spin state or to hold horizontal adder
;$02 - used for oscillated high byte of spin state or to hold vertical adder
;$03 - used for mirror data
;$04 - used to store player's sprite 1 X coordinate
;$05 - used to evaluate mirror data
;$06 - used to store either screen X coordinate or sprite data offset
;$07 - used to store screen Y coordinate
;$ed - used to hold maximum length of firebar
;$ef - used to hold high byte of spinstate

;horizontal adder is at first byte + high byte of spinstate,
;vertical adder is same + 8 bytes, two's compliment
;if greater than $08 for proper oscillation
FirebarPosLookupTbl:
      .db $00, $01, $03, $04, $05, $06, $07, $07, $08
      .db $00, $03, $06, $09, $0b, $0d, $0e, $0f, $10
      .db $00, $04, $09, $0d, $10, $13, $16, $17, $18
      .db $00, $06, $0c, $12, $16, $1a, $1d, $1f, $20
      .db $00, $07, $0f, $16, $1c, $21, $25, $27, $28
      .db $00, $09, $12, $1b, $21, $27, $2c, $2f, $30
      .db $00, $0b, $15, $1f, $27, $2e, $33, $37, $38
      .db $00, $0c, $18, $24, $2d, $35, $3b, $3e, $40
      .db $00, $0e, $1b, $28, $32, $3b, $42, $46, $48
      .db $00, $0f, $1f, $2d, $38, $42, $4a, $4e, $50
      .db $00, $11, $22, $31, $3e, $49, $51, $56, $58

FirebarMirrorData:
      .db $01, $03, $02, $00

FirebarTblOffsets:
      .db $00, $09, $12, $1b, $24, $2d
      .db $36, $3f, $48, $51, $5a, $63

FirebarYPos:
      .db $0c, $18

ProcFirebar:
          jsr GetEnemyOffscreenBits   ;get offscreen information
          lda Enemy_OffscreenBits     ;check for d3 set
          andn ++%00001000              ;if so, branch to leave
          bne SkipFBar
          lda TimerControl            ;if master timer control set, branch
         checka
          bne SusFbar                 ;ahead of this part
          ldax FirebarSpinSpeed,x      ;load spinning speed of firebar
          jsr FirebarSpin             ;modify current spinstate
          andn ++%00011111              ;mask out all but 5 LSB
          stax FirebarSpinState_High,x ;and store as new high byte of spinstate
SusFbar:  ldax FirebarSpinState_High,x ;get high byte of spinstate
          ldyx Enemy_ID,x              ;check enemy identifier
          cpyn ++$1f
              cmpcy
          bcc SetupGFB                ;if LOW  $1f (long firebar), branch
          cmpn ++$08                    ;check high byte of spinstate
          beq SkpFSte                 ;if eight, branch to change
          cmpn ++$18
          bne SetupGFB                ;if not at twenty-four branch to not change
SkpFSte:  clc
          adcn ++$01                    ;add one to spinning thing to avoid horizontal state
          stax FirebarSpinState_High,x
SetupGFB: sta SCRATCHPAD+$ef                     ;save high byte of spinning thing, modified or otherwise
          jsr RelativeEnemyPosition   ;get relative coordinates to screen
          jsr GetFirebarPosition      ;do a sub here (residual, too early to be used now)
          ldyx Enemy_SprDataOffset,x   ;get OAM data offset
          lda Enemy_Rel_YPos          ;get relative vertical coordinate
          stay Sprite_Y_Position,y     ;store as Y in OAM data
          sta SCRATCHPAD+$07                     ;also save here
          lda Enemy_Rel_XPos          ;get relative horizontal coordinate
          stay Sprite_X_Position,y     ;store as X in OAM data
          sta SCRATCHPAD+$06                     ;also save here
          ldan ++$01
          sta SCRATCHPAD+$00                     ;set $01 value here (not necessary)
          jsr FirebarCollision        ;draw fireball part and do collision detection
          ldyn ++$05                    ;load value for short firebars by default
          ldax Enemy_ID,x
          cmpn ++$1f                    ;are we doing a long firebar?
              cmpcy
          bcc SetMFbar                ;no, branch then
          ldyn ++$0b                    ;otherwise load value for long firebars
SetMFbar: sty SCRATCHPAD+$ed                     ;store maximum value for length of firebars
          ldan ++$00
          sta SCRATCHPAD+$00                     ;initialize counter here
DrawFbar: lda SCRATCHPAD+$ef                     ;load high byte of spinstate
          jsr GetFirebarPosition      ;get fireball position data depending on firebar part
          jsr DrawFirebar_Collision   ;position it properly, draw it and do collision detection
          lda SCRATCHPAD+$00                     ;check which firebar part
          cmpn ++$04
          bne NextFbar
          ldy DuplicateObj_Offset     ;if we arrive at fifth firebar part,
          lday Enemy_SprDataOffset,y   ;get offset from long firebar and load OAM data offset
          sta SCRATCHPAD+$06                     ;using long firebar offset, then store as new one here
NextFbar: inci SCRATCHPAD+$00                     ;move onto the next firebar part
          lda SCRATCHPAD+$00
          cmpi SCRATCHPAD+$ed                     ;if we end up at the maximum part, go on and leave
              cmpcy
          bcc DrawFbar                ;otherwise go back and do another
SkipFBar: rts

DrawFirebar_Collision:
         lda SCRATCHPAD+$03                  ;store mirror data elsewhere
         sta SCRATCHPAD+$05          
         ldy SCRATCHPAD+$06                  ;load OAM data offset for firebar
         lda SCRATCHPAD+$01                  ;load horizontal adder we got from position loader
         lsri SCRATCHPAD+$05                  ;shift LSB of mirror data
         bcs AddHA                ;if carry was set, skip this part
         eorn ++$ff
         adcn ++$01                 ;otherwise get two's compliment of horizontal adder
AddHA:   clc                      ;add horizontal coordinate relative to screen to
         adci Enemy_Rel_XPos       ;horizontal adder, modified or otherwise
         stay Sprite_X_Position,y  ;store as X coordinate here
         sta SCRATCHPAD+$06                  ;store here for now, note offset is saved in Y still
         cmpi Enemy_Rel_XPos       ;compare X coordinate of sprite to original X of firebar
              cmpcy
         bcs SubtR1               ;if sprite coordinate =HIGH  original coordinate, branch
         lda Enemy_Rel_XPos
         secsub                      ;otherwise subtract sprite X from the
         sbci SCRATCHPAD+$06                  ;original one and skip this part
         jmp ChkFOfs
SubtR1:  secsub                      ;subtract original X from the
         sbci Enemy_Rel_XPos       ;current sprite X
ChkFOfs: cmpn ++$59                 ;if difference of coordinates within a certain range,
              cmpcy
         bcc VAHandl              ;continue by handling vertical adder
         ldan ++$f8                 ;otherwise, load offscreen Y coordinate
         checka
         bne SetVFbr              ;and unconditionally branch to move sprite offscreen
VAHandl: lda Enemy_Rel_YPos       ;if vertical relative coordinate offscreen,
         cmpn ++$f8                 ;skip ahead of this part and write into sprite Y coordinate
         beq SetVFbr
         lda SCRATCHPAD+$02                  ;load vertical adder we got from position loader
         lsri SCRATCHPAD+$05                  ;shift LSB of mirror data one more time
         bcs AddVA                ;if carry was set, skip this part
         eorn ++$ff
         adcn ++$01                 ;otherwise get two's compliment of second part
AddVA:   clc                      ;add vertical coordinate relative to screen to 
         adci Enemy_Rel_YPos       ;the second data, modified or otherwise
SetVFbr: stay Sprite_Y_Position,y  ;store as Y coordinate here
         sta SCRATCHPAD+$07                  ;also store here for now

FirebarCollision:
         jsr DrawFirebar          ;run sub here to draw current tile of firebar
         tya                      ;return OAM data offset and save
         pha                      ;to the stack for now
         lda StarInvincibleTimer  ;if star mario invincibility timer
         orai TimerControl         ;or master timer controls set
         bne NoColFB              ;then skip all of this
         sta SCRATCHPAD+$05                  ;otherwise initialize counter
         ldy Player_Y_HighPos
         dey                      ;if player's vertical high byte offscreen,
         bne NoColFB              ;skip all of this
         ldy Player_Y_Position    ;get player's vertical position
         lda PlayerSize           ;get player's size
         checka
         bne AdjSm                ;if player small, branch to alter variables
         lda CrouchingFlag
         checka
         beq BigJp                ;if player big and not crouching, jump ahead
AdjSm:   inci SCRATCHPAD+$05                  ;if small or big but crouching, execute this part
         inci SCRATCHPAD+$05                  ;first increment our counter twice (setting $02 as flag)
         tya
         clc                      ;then add 24 pixels to the player's
         adcn ++$18                 ;vertical coordinate
         tay
BigJp:   tya                      ;get vertical coordinate, altered or otherwise, from Y
FBCLoop: secsub                      ;subtract vertical position of firebar
         sbci SCRATCHPAD+$07                  ;from the vertical coordinate of the player
         bpl ChkVFBD              ;if player lower on the screen than firebar, 
         eorn ++$ff                 ;skip two's compliment part
         clc                      ;otherwise get two's compliment
         adcn ++$01
ChkVFBD: cmpn ++$08                 ;if difference =HIGH  8 pixels, skip ahead of this part
              cmpcy
         bcs Chk2Ofs
         lda SCRATCHPAD+$06                  ;if firebar on far right on the screen, skip this,
         cmpn ++$f0                 ;because, really, what's the point?
              cmpcy
         bcs Chk2Ofs
         lda Sprite_X_Position+4  ;get OAM X coordinate for sprite ++1
         clc
         adcn ++$04                 ;add four pixels
         sta SCRATCHPAD+$04                  ;store here
         secsub                      ;subtract horizontal coordinate of firebar
         sbci SCRATCHPAD+$06                  ;from the X coordinate of player's sprite 1
         bpl ChkFBCl              ;if modded X coordinate to the right of firebar
         eorn ++$ff                 ;skip two's compliment part
         clc                      ;otherwise get two's compliment
         adcn ++$01
ChkFBCl: cmpn ++$08                 ;if difference LOW  8 pixels, collision, thus branch
              cmpcy
         bcc ChgSDir              ;to process
Chk2Ofs: lda SCRATCHPAD+$05                  ;if value of $02 was set earlier for whatever reason,
         cmpn ++$02                 ;branch to increment OAM offset and leave, no collision
         beq NoColFB
         ldy SCRATCHPAD+$05                  ;otherwise get temp here and use as offset
         lda Player_Y_Position
         clc
         adcy FirebarYPos,y        ;add value loaded with offset to player's vertical coordinate
         inci SCRATCHPAD+$05                  ;then increment temp and jump back
         jmp FBCLoop
ChgSDir: ldxn ++$01                 ;set movement direction by default
         lda SCRATCHPAD+$04                  ;if OAM X coordinate of player's sprite 1
         cmpi SCRATCHPAD+$06                  ;is greater than horizontal coordinate of firebar
              cmpcy
         bcs SetSDir              ;then do not alter movement direction
         inx                      ;otherwise increment it
SetSDir: stx Enemy_MovingDir      ;store movement direction here
         ldxn ++$00
         lda SCRATCHPAD+$00                  ;save value written to $00 to stack
         pha
         jsr InjurePlayer         ;perform sub to hurt or kill player
         pla
         sta SCRATCHPAD+$00                  ;get value of $00 from stack
NoColFB: pla                      ;get OAM data offset
         clc                      ;add four to it and save
         adcn ++$04
         sta SCRATCHPAD+$06
         ldx ObjectOffset         ;get enemy object buffer offset and leave
         rts

GetFirebarPosition:
           pha                        ;save high byte of spinstate to the stack
           andn ++%00001111             ;mask out low nybble
           cmpn ++$09
              cmpcy
           bcc GetHAdder              ;if lower than $09, branch ahead
           eorn ++%00001111             ;otherwise get two's compliment to oscillate
           clc
           adcn ++$01
GetHAdder: sta SCRATCHPAD+$01                    ;store result, modified or not, here
           ldy SCRATCHPAD+$00                    ;load number of firebar ball where we're at
           lday FirebarTblOffsets,y    ;load offset to firebar position data
           clc
           adci SCRATCHPAD+$01                    ;add oscillated high byte of spinstate
           tay                        ;to offset here and use as new offset
           lday FirebarPosLookupTbl,y  ;get data here and store as horizontal adder
           sta SCRATCHPAD+$01
           pla                        ;pull whatever was in A from the stack
           pha                        ;save it again because we still need it
           clc
           adcn ++$08                   ;add eight this time, to get vertical adder
           andn ++%00001111             ;mask out high nybble
           cmpn ++$09                   ;if lower than $09, branch ahead
              cmpcy
           bcc GetVAdder
           eorn ++%00001111             ;otherwise get two's compliment
           clc
           adcn ++$01
GetVAdder: sta SCRATCHPAD+$02                    ;store result here
           ldy SCRATCHPAD+$00
           lday FirebarTblOffsets,y    ;load offset to firebar position data again
           clc
           adci SCRATCHPAD+$02                    ;this time add value in $02 to offset here and use as offset
           tay
           lday FirebarPosLookupTbl,y  ;get data here and store as vertica adder
           sta SCRATCHPAD+$02
           pla                        ;pull out whatever was in A one last time
           lsr                        ;divide by eight or shift three to the right
           lsr
           lsr
           tay                        ;use as offset
           lday FirebarMirrorData,y    ;load mirroring data here
           sta SCRATCHPAD+$03                    ;store
           rts

;--------------------------------

PRandomSubtracter:
      .db $f8, $a0, $70, $bd, $00

FlyCCBPriority:
      .db $20, $20, $20, $00, $00

MoveFlyingCheepCheep:
        ldax Enemy_State,x          ;check cheep-cheep's enemy state
        andn ++%00100000             ;for d5 set
        beq FlyCC                  ;branch to continue code if not set
        ldan ++$00
        stax Enemy_SprAttrib,x      ;otherwise clear sprite attributes
        jmp MoveJ_EnemyVertically  ;and jump to move defeated cheep-cheep downwards
FlyCC:  jsr MoveEnemyHorizontally  ;move cheep-cheep horizontally based on speed and force
        ldyn ++$0d                   ;set vertical movement amount
        ldan ++$05                   ;set maximum speed
        jsr SetXMoveAmt            ;branch to impose gravity on flying cheep-cheep
        ldax Enemy_Y_MoveForce,x
        lsr                        ;get vertical movement force and
        lsr                        ;move high nybble to low
        lsr
        lsr
        tay                        ;save as offset (note this tends to go into reach of code)
        ldax Enemy_Y_Position,x     ;get vertical position
        secsub                        ;subtract pseudorandom value based on offset from position
        sbcy PRandomSubtracter,y
        bpl AddCCF                  ;if result within top half of screen, skip this part
        eorn ++$ff
        clc                        ;otherwise get two's compliment
        adcn ++$01
AddCCF: cmpn ++$08                   ;if result or two's compliment greater than eight,
              cmpcy
        bcs BPGet                  ;skip to the end without changing movement force
        ldax Enemy_Y_MoveForce,x
        clc
        adcn ++$10                   ;otherwise add to it
        stax Enemy_Y_MoveForce,x
        lsr                        ;move high nybble to low again
        lsr
        lsr
        lsr
        tay
BPGet:  lday FlyCCBPriority,y       ;load bg priority data and store (this is very likely
        stax Enemy_SprAttrib,x      ;broken or residual code, value is overwritten before
        rts                        ;drawing it next frame), then leave

;--------------------------------
;$00 - used to hold horizontal difference
;$01-$03 - used to hold difference adjusters

LakituDiffAdj:
      .db $15, $30, $40

MoveLakitu:
         ldax Enemy_State,x          ;check lakitu's enemy state
         andn ++%00100000             ;for d5 set
         beq ChkLS                  ;if not set, continue with code
         jmp MoveD_EnemyVertically  ;otherwise jump to move defeated lakitu downwards
ChkLS:   ldax Enemy_State,x          ;if lakitu's enemy state not set at all,
         checka
         beq Fr12S                  ;go ahead and continue with code
         ldan ++$00
         stax LakituMoveDirection,x  ;otherwise initialize moving direction to move to left
         sta EnemyFrenzyBuffer      ;initialize frenzy buffer
         ldan ++$10
         checka
         bne SetLSpd                ;load horizontal speed and do unconditional branch
Fr12S:   ldan ++Spiny
         sta EnemyFrenzyBuffer      ;set spiny identifier in frenzy buffer
         ldyn ++$02
LdLDa:   lday LakituDiffAdj,y        ;load values
         stay SCRATCHPAD+$0001,y                ;store in zero page
         dey
         bpl LdLDa                  ;do this until all values are stired
         jsr PlayerLakituDiff       ;execute sub to set speed and create spinys
SetLSpd: stax LakituMoveSpeed,x      ;set movement speed returned from sub
         ldyn ++$01                   ;set moving direction to right by default
         ldax LakituMoveDirection,x
         andn ++$01                   ;get LSB of moving direction
         bne SetLMov                ;if set, branch to the end to use moving direction
         ldax LakituMoveSpeed,x
         eorn ++$ff                   ;get two's compliment of moving speed
         clc
         adcn ++$01
         stax LakituMoveSpeed,x      ;store as new moving speed
         iny                        ;increment moving direction to left
SetLMov: styx Enemy_MovingDir,x      ;store moving direction
         jmp MoveEnemyHorizontally  ;move lakitu horizontally

PlayerLakituDiff:
           ldyn ++$00                   ;set Y for default value
           jsr PlayerEnemyDiff        ;get horizontal difference between enemy and player
           bpl ChkLakDif              ;branch if enemy is to the right of the player
           iny                        ;increment Y for left of player
           lda SCRATCHPAD+$00
           eorn ++$ff                   ;get two's compliment of low byte of horizontal difference
           clc
           adcn ++$01                   ;store two's compliment as horizontal difference
           sta SCRATCHPAD+$00
ChkLakDif: lda SCRATCHPAD+$00                    ;get low byte of horizontal difference
           cmpn ++$3c                   ;if within a certain distance of player, branch
              cmpcy
           bcc ChkPSpeed
           ldan ++$3c                   ;otherwise set maximum distance
           sta SCRATCHPAD+$00
           ldax Enemy_ID,x             ;check if lakitu is in our current enemy slot
           cmpn ++Lakitu
           bne ChkPSpeed              ;if not, branch elsewhere
           tya                        ;compare contents of Y, now in A
           cmpx LakituMoveDirection,x  ;to what is being used as horizontal movement direction
           beq ChkPSpeed              ;if moving toward the player, branch, do not alter
           ldax LakituMoveDirection,x  ;if moving to the left beyond maximum distance,
         checka
           beq SetLMovD               ;branch and alter without delay
           decx LakituMoveSpeed,x      ;decrement horizontal speed
           ldax LakituMoveSpeed,x      ;if horizontal speed not yet at zero, branch to leave
         checka
           bne ExMoveLak
SetLMovD:  tya                        ;set horizontal direction depending on horizontal
           stax LakituMoveDirection,x  ;difference between enemy and player if necessary
ChkPSpeed: lda SCRATCHPAD+$00
           andn ++%00111100             ;mask out all but four bits in the middle
           lsr                        ;divide masked difference by four
           lsr
           sta SCRATCHPAD+$00                    ;store as new value
           ldyn ++$00                   ;init offset
           lda Player_X_Speed
         checka
           beq SubDifAdj              ;if player not moving horizontally, branch
           lda ScrollAmount
         checka
           beq SubDifAdj              ;if scroll speed not set, branch to same place
           iny                        ;otherwise increment offset
           lda Player_X_Speed
           cmpn ++$19                   ;if player not running, branch
              cmpcy
           bcc ChkSpinyO
           lda ScrollAmount
           cmpn ++$02                   ;if scroll speed below a certain amount, branch
              cmpcy
           bcc ChkSpinyO              ;to same place
           iny                        ;otherwise increment once more
ChkSpinyO: ldax Enemy_ID,x             ;check for spiny object
           cmpn ++Spiny
           bne ChkEmySpd              ;branch if not found
           lda Player_X_Speed         ;if player not moving, skip this part
         checka
           bne SubDifAdj
ChkEmySpd: ldax Enemy_Y_Speed,x        ;check vertical speed
         checka
           bne SubDifAdj              ;branch if nonzero
           ldyn ++$00                   ;otherwise reinit offset
SubDifAdj: lday SCRATCHPAD+$0001,y                ;get one of three saved values from earlier
           ldy SCRATCHPAD+$00                    ;get saved horizontal difference
SPixelLak: secsub                        ;subtract one for each pixel of horizontal difference
           sbcn ++$01                   ;from one of three saved values
           dey
           bpl SPixelLak              ;branch until all pixels are subtracted, to adjust difference
ExMoveLak: rts                        ;leave!!!

;-------------------------------------------------------------------------------------
;$04-$05 - used to store name table address in little endian order

BridgeCollapseData:
      .db $1a ;axe
      .db $58 ;chain
      .db $98, $96, $94, $92, $90, $8e, $8c ;bridge
      .db $8a, $88, $86, $84, $82, $80

BridgeCollapse:
       ldx BowserFront_Offset    ;get enemy offset for bowser
       ldax Enemy_ID,x            ;check enemy object identifier for bowser
       cmpn ++Bowser               ;if not found, branch ahead,
       bne SetM2                 ;metatile removal not necessary
       stx ObjectOffset          ;store as enemy offset here
       ldax Enemy_State,x         ;if bowser in normal state, skip all of this
         checka
       beq RemoveBridge
       andn ++%01000000            ;if bowser's state has d6 clear, skip to silence music
       beq SetM2
       ldax Enemy_Y_Position,x    ;check bowser's vertical coordinate
       cmpn ++$e0                  ;if bowser not yet low enough, skip this part ahead
              cmpcy
       bcc MoveD_Bowser
SetM2: ldan ++Silence              ;silence music
       sta EventMusicQueue
       inci OperMode_Task         ;move onto next secondary mode in autoctrl mode
       jmp KillAllEnemies        ;jump to empty all enemy slots and then leave  

MoveD_Bowser:
       jsr MoveEnemySlowVert     ;do a sub to move bowser downwards
       jmp BowserGfxHandler      ;jump to draw bowser's front and rear, then leave

RemoveBridge:
         deci BowserFeetCounter     ;decrement timer to control bowser's feet
         bne NoBFall               ;if not expired, skip all of this
         ldan ++$04
         sta BowserFeetCounter     ;otherwise, set timer now
         lda BowserBodyControls
         eorn ++$01                  ;invert bit to control bowser's feet
         sta BowserBodyControls
         ldan ++$22                  ;put high byte of name table address here for now
         sta SCRATCHPAD+$05
         ldy BridgeCollapseOffset  ;get bridge collapse offset here
         lday BridgeCollapseData,y  ;load low byte of name table address and store here
         sta SCRATCHPAD+$04
         ldy VRAM_Buffer1_Offset   ;increment vram buffer offset
         iny
         ldxn ++$0c                  ;set offset for tile data for sub to draw blank metatile
         jsr RemBridge             ;do sub here to remove bowser's bridge metatiles
         ldx ObjectOffset          ;get enemy offset
         jsr MoveVOffset           ;set new vram buffer offset
         ldan ++Sfx_Blast            ;load the fireworks/gunfire sound into the square 2 sfx
         sta Square2SoundQueue     ;queue while at the same time loading the brick
         ldan ++Sfx_BrickShatter     ;shatter sound into the noise sfx queue thus
         sta NoiseSoundQueue       ;producing the unique sound of the bridge collapsing 
         inci BridgeCollapseOffset  ;increment bridge collapse offset
         lda BridgeCollapseOffset
         cmpn ++$0f                  ;if bridge collapse offset has not yet reached
         bne NoBFall               ;the end, go ahead and skip this part
         jsr InitVStf              ;initialize whatever vertical speed bowser has
         ldan ++%01000000
         stax Enemy_State,x         ;set bowser's state to one of defeated states (d6 set)
         ldan ++Sfx_BowserFall
         sta Square2SoundQueue     ;play bowser defeat sound
NoBFall: jmp BowserGfxHandler      ;jump to code that draws bowser

;--------------------------------

PRandomRange:
      .db $21, $41, $11, $31

RunBowser:
      ldax Enemy_State,x       ;if d5 in enemy state is not set
      andn ++%00100000          ;then branch elsewhere to run bowser
      beq BowserControl
      ldax Enemy_Y_Position,x  ;otherwise check vertical position
      cmpn ++$e0                ;if above a certain point, branch to move defeated bowser
              cmpcy
      bcc MoveD_Bowser        ;otherwise proceed to KillAllEnemies

KillAllEnemies:
          ldxn ++$04              ;start with last enemy slot
KillLoop: jsr EraseEnemyObject  ;branch to kill enemy objects
          dex                   ;move onto next enemy slot
          bpl KillLoop          ;do this until all slots are emptied
          sta EnemyFrenzyBuffer ;empty frenzy buffer
          ldx ObjectOffset      ;get enemy object offset and leave
          rts

BowserControl:
           ldan ++$00
           sta EnemyFrenzyBuffer      ;empty frenzy buffer
           lda TimerControl           ;if master timer control not set,
         checka
           beq ChkMouth               ;skip jump and execute code here
           jmp SkipToFB               ;otherwise, jump over a bunch of code
ChkMouth:  lda BowserBodyControls     ;check bowser's mouth
         checka
           bpl FeetTmr                ;if bit clear, go ahead with code here
           jmp HammerChk              ;otherwise skip a whole section starting here
FeetTmr:   deci BowserFeetCounter      ;decrement timer to control bowser's feet
           bne ResetMDr               ;if not expired, skip this part
           ldan ++$20                   ;otherwise, reset timer
           sta BowserFeetCounter        
           lda BowserBodyControls     ;and invert bit used
           eorn ++%00000001             ;to control bowser's feet
           sta BowserBodyControls
ResetMDr:  lda FrameCounter           ;check frame counter
           andn ++%00001111             ;if not on every sixteenth frame, skip
           bne B_FaceP                ;ahead to continue code
           ldan ++$02                   ;otherwise reset moving/facing direction every
           stax Enemy_MovingDir,x      ;sixteen frames
B_FaceP:   ldax EnemyFrameTimer,x      ;if timer set here expired,
         checka
           beq GetPRCmp               ;branch to next section
           jsr PlayerEnemyDiff        ;get horizontal difference between player and bowser,
           bpl GetPRCmp               ;and branch if bowser to the right of the player
           ldan ++$01
           stax Enemy_MovingDir,x      ;set bowser to move and face to the right
           ldan ++$02
           sta BowserMovementSpeed    ;set movement speed
           ldan ++$20
           stax EnemyFrameTimer,x      ;set timer here
           sta BowserFireBreathTimer  ;set timer used for bowser's flame
           ldax Enemy_X_Position,x        
           cmpn ++$c8                   ;if bowser to the right past a certain point,
              cmpcy
           bcs HammerChk              ;skip ahead to some other section
GetPRCmp:  lda FrameCounter           ;get frame counter
           andn ++%00000011
           bne HammerChk              ;execute this code every fourth frame, otherwise branch
           ldax Enemy_X_Position,x
           cmpi BowserOrigXPos         ;if bowser not at original horizontal position,
           bne GetDToO                ;branch to skip this part
           ldax PseudoRandomBitReg,x
           andn ++%00000011             ;get pseudorandom offset
           tay
           lday PRandomRange,y         ;load value using pseudorandom offset
           sta MaxRangeFromOrigin     ;and store here
GetDToO:   ldax Enemy_X_Position,x
           clc                        ;add movement speed to bowser's horizontal
           adci BowserMovementSpeed    ;coordinate and save as new horizontal position
           stax Enemy_X_Position,x
           ldyx Enemy_MovingDir,x
           cpyn ++$01                   ;if bowser moving and facing to the right, skip ahead
           beq HammerChk
           ldyn ++$ff                   ;set default movement speed here (move left)
           secsub                        ;get difference of current vs. original
           sbci BowserOrigXPos         ;horizontal position
           bpl CompDToO               ;if current position to the right of original, skip ahead
           eorn ++$ff
           clc                        ;get two's compliment
           adcn ++$01
           ldyn ++$01                   ;set alternate movement speed here (move right)
CompDToO:  cmpi MaxRangeFromOrigin     ;compare difference with pseudorandom value
              cmpcy
           bcc HammerChk              ;if difference LOW  pseudorandom value, leave speed alone
           sty BowserMovementSpeed    ;otherwise change bowser's movement speed
HammerChk: ldax EnemyFrameTimer,x      ;if timer set here not expired yet, skip ahead to
         checka
           bne MakeBJump              ;some other section of code
           jsr MoveEnemySlowVert      ;otherwise start by moving bowser downwards
           lda WorldNumber            ;check world number
           cmpn ++World6
              cmpcy
           bcc SetHmrTmr              ;if world 1-5, skip this part (not time to throw hammers yet)
           lda FrameCounter
           andn ++%00000011             ;check to see if it's time to execute sub
           bne SetHmrTmr              ;if not, skip sub, otherwise
           jsr SpawnHammerObj         ;execute sub on every fourth frame to spawn misc object (hammer)
SetHmrTmr: ldax Enemy_Y_Position,x     ;get current vertical position
           cmpn ++$80                   ;if still above a certain point
              cmpcy
           bcc ChkFireB               ;then skip to world number check for flames
           ldax PseudoRandomBitReg,x
           andn ++%00000011             ;get pseudorandom offset
           tay
           lday PRandomRange,y         ;get value using pseudorandom offset
           stax EnemyFrameTimer,x      ;set for timer here
SkipToFB:  jmp ChkFireB               ;jump to execute flames code
MakeBJump: cmpn ++$01                   ;if timer not yet about to expire,
           bne ChkFireB               ;skip ahead to next part
           decx Enemy_Y_Position,x     ;otherwise decrement vertical coordinate
           jsr InitVStf               ;initialize movement amount
           ldan ++$fe
           stax Enemy_Y_Speed,x        ;set vertical speed to move bowser upwards
ChkFireB:  lda WorldNumber            ;check world number here
           cmpn ++World8                ;world 8?
           beq SpawnFBr               ;if so, execute this part here
           cmpn ++World6                ;world 6-7?
              cmpcy
           bcs BowserGfxHandler       ;if so, skip this part here
SpawnFBr:  lda BowserFireBreathTimer  ;check timer here
         checka
           bne BowserGfxHandler       ;if not expired yet, skip all of this
           ldan ++$20
           sta BowserFireBreathTimer  ;set timer here
           lda BowserBodyControls
           eorn ++%10000000             ;invert bowser's mouth bit to open
           sta BowserBodyControls     ;and close bowser's mouth
           bmi ChkFireB               ;if bowser's mouth open, loop back
           jsr SetFlameTimer          ;get timing for bowser's flame
           ldy SecondaryHardMode
         checky
           beq SetFBTmr               ;if secondary hard mode flag not set, skip this
           secsub
           sbcn ++$10                   ;otherwise subtract from value in A
SetFBTmr:  sta BowserFireBreathTimer  ;set value as timer here
           ldan ++BowserFlame           ;put bowser's flame identifier
           sta EnemyFrenzyBuffer      ;in enemy frenzy buffer

;--------------------------------

BowserGfxHandler:
          jsr ProcessBowserHalf    ;do a sub here to process bowser's front
          ldyn ++$10                 ;load default value here to position bowser's rear
          ldax Enemy_MovingDir,x    ;check moving direction
          lsr
          bcc CopyFToR             ;if moving left, use default
          ldyn ++$f0                 ;otherwise load alternate positioning value here
CopyFToR: tya                      ;move bowser's rear object position value to A
          clc
          adcx Enemy_X_Position,x   ;add to bowser's front object horizontal coordinate
          ldy DuplicateObj_Offset  ;get bowser's rear object offset
          stay Enemy_X_Position,y   ;store A as bowser's rear horizontal coordinate
          ldax Enemy_Y_Position,x
          clc                      ;add eight pixels to bowser's front object
          adcn ++$08                 ;vertical coordinate and store as vertical coordinate
          stay Enemy_Y_Position,y   ;for bowser's rear
          ldax Enemy_State,x
          stay Enemy_State,y        ;copy enemy state directly from front to rear
          ldax Enemy_MovingDir,x
          stay Enemy_MovingDir,y    ;copy moving direction also
          lda ObjectOffset         ;save enemy object offset of front to stack
          pha
          ldx DuplicateObj_Offset  ;put enemy object offset of rear as current
          stx ObjectOffset
          ldan ++Bowser              ;set bowser's enemy identifier
          stax Enemy_ID,x           ;store in bowser's rear object
          jsr ProcessBowserHalf    ;do a sub here to process bowser's rear
          pla
          sta ObjectOffset         ;get original enemy object offset
          tax
          ldan ++$00                 ;nullify bowser's front/rear graphics flag
          sta BowserGfxFlag
ExBGfxH:  rts                      ;leave!

ProcessBowserHalf:
      inci BowserGfxFlag         ;increment bowser's graphics flag, then run subroutines
      jsr RunRetainerObj        ;to get offscreen bits, relative position and draw bowser (finally!)
      ldax Enemy_State,x
         checka
      bne ExBGfxH               ;if either enemy object not in normal state, branch to leave
      ldan ++$0a
      stax Enemy_BoundBoxCtrl,x  ;set bounding box size control
      jsr GetEnemyBoundBox      ;get bounding box coordinates
      jmp PlayerEnemyCollision  ;do player-to-enemy collision detection

;-------------------------------------------------------------------------------------
;$00 - used to hold movement force and tile number
;$01 - used to hold sprite attribute data

FlameTimerData:
      .db $bf, $40, $bf, $bf, $bf, $40, $40, $bf

SetFlameTimer:
      ldy BowserFlameTimerCtrl  ;load counter as offset
      inci BowserFlameTimerCtrl  ;increment
      lda BowserFlameTimerCtrl  ;mask out all but 3 LSB
      andn ++%00000111            ;to keep in range of 0-7
      sta BowserFlameTimerCtrl
      lday FlameTimerData,y      ;load value to be used then leave
ExFl: rts

ProcBowserFlame:
         lda TimerControl            ;if master timer control flag set,
         checka
         bne SetGfxF                 ;skip all of this
         ldan ++$40                    ;load default movement force
         ldy SecondaryHardMode
         checky
         beq SFlmX                   ;if secondary hard mode flag not set, use default
         ldan ++$60                    ;otherwise load alternate movement force to go faster
SFlmX:   sta SCRATCHPAD+$00                     ;store value here
         ldax Enemy_X_MoveForce,x
         secsub                         ;subtract value from movement force (младшая часть X-координаты)
         sbci SCRATCHPAD+$00
          push af
         stax Enemy_X_MoveForce,x     ;save new value (младшая часть X-координаты)
         ldax Enemy_X_Position,x
          ld h,a
          pop af
          ld a,h
         sbcn ++$01                    ;subtract one from horizontal position to move
          push af
         stax Enemy_X_Position,x      ;to the left
         ldax Enemy_PageLoc,x
          ld h,a
          pop af
          ld a,h
         sbcn ++$00                    ;subtract borrow from page location
         stax Enemy_PageLoc,x
         ldyx BowserFlamePRandomOfs,x ;get some value here and use as offset
         ldax Enemy_Y_Position,x      ;load vertical coordinate
         cmpy FlameYPosData,y         ;compare against coordinate data using $0417,x (???) as offset
         beq SetGfxF                 ;if equal, branch and do not modify coordinate
         clc
         adcx Enemy_Y_MoveForce,x     ;otherwise add value here to coordinate and store
         stax Enemy_Y_Position,x      ;as new vertical coordinate
SetGfxF: jsr RelativeEnemyPosition   ;get new relative coordinates
         ldax Enemy_State,x           ;if bowser's flame not in normal state,
         checka
         bne ExFl                    ;branch to leave
         ldan ++$51                    ;otherwise, continue
         sta SCRATCHPAD+$00                     ;write first tile number
         ldyn ++$02                    ;load attributes without vertical flip by default
         lda FrameCounter
         andn ++%00000010              ;invert vertical flip bit every 2 frames
         beq FlmeAt                  ;if d1 not set, write default value
         ldyn ++$82                    ;otherwise write value with vertical flip bit set
FlmeAt:  sty SCRATCHPAD+$01                     ;set bowser's flame sprite attributes here
         ldyx Enemy_SprDataOffset,x   ;get OAM data offset
         ldxn ++$00

DrawFlameLoop:
         lda Enemy_Rel_YPos         ;get Y relative coordinate of current enemy object
         stay Sprite_Y_Position,y    ;write into Y coordinate of OAM data
         lda SCRATCHPAD+$00
         stay Sprite_Tilenumber,y    ;write current tile number into OAM data
         inci SCRATCHPAD+$00                    ;increment tile number to draw more bowser's flame
         lda SCRATCHPAD+$01
         stay Sprite_Attributes,y    ;write saved attributes into OAM data
         lda Enemy_Rel_XPos
         stay Sprite_X_Position,y    ;write X relative coordinate of current enemy object
         clc
         adcn ++$08
         sta Enemy_Rel_XPos         ;then add eight to it and store
         iny
         iny
         iny
         iny                        ;increment Y four times to move onto the next OAM
         inx                        ;move onto the next OAM, and branch if three
         cpxn ++$03                   ;have not yet been done
              cmpcy
         bcc DrawFlameLoop
         ldx ObjectOffset           ;reload original enemy offset
         jsr GetEnemyOffscreenBits  ;get offscreen information
         ldyx Enemy_SprDataOffset,x  ;get OAM data offset
         lda Enemy_OffscreenBits    ;get enemy object offscreen bits
         lsr                        ;move d0 to carry and result to stack
         pha
         bcc M3FOfs                 ;branch if carry not set
         ldan ++$f8                   ;otherwise move sprite offscreen, this part likely
         stay Sprite_Y_Position+12,y ;residual since flame is only made of three sprites
M3FOfs:  pla                        ;get bits from stack
         lsr                        ;move d1 to carry and move bits back to stack
         pha
         bcc M2FOfs                 ;branch if carry not set again
         ldan ++$f8                   ;otherwise move third sprite offscreen
         stay Sprite_Y_Position+8,y
M2FOfs:  pla                        ;get bits from stack again
         lsr                        ;move d2 to carry and move bits back to stack again
         pha
         bcc M1FOfs                 ;branch if carry not set yet again
         ldan ++$f8                   ;otherwise move second sprite offscreen
         stay Sprite_Y_Position+4,y
M1FOfs:  pla                        ;get bits from stack one last time
         lsr                        ;move d3 to carry
         bcc ExFlmeD                ;branch if carry not set one last time
         ldan ++$f8
         stay Sprite_Y_Position,y    ;otherwise move first sprite offscreen
ExFlmeD: rts                        ;leave

;--------------------------------

RunFireworks:
           decx ExplosionTimerCounter,x ;decrement explosion timing counter here
           bne SetupExpl               ;if not expired, skip this part
           ldan ++$08
           stax ExplosionTimerCounter,x ;reset counter
           incx ExplosionGfxCounter,x   ;increment explosion graphics counter
           ldax ExplosionGfxCounter,x
           cmpn ++$03                    ;check explosion graphics counter
              cmpcy
           bcs FireworksSoundScore     ;if at a certain point, branch to kill this object
SetupExpl: jsr RelativeEnemyPosition   ;get relative coordinates of explosion
           lda Enemy_Rel_YPos          ;copy relative coordinates
           sta Fireball_Rel_YPos       ;from the enemy object to the fireball object
           lda Enemy_Rel_XPos          ;first vertical, then horizontal
           sta Fireball_Rel_XPos
           ldyx Enemy_SprDataOffset,x   ;get OAM data offset
           ldax ExplosionGfxCounter,x   ;get explosion graphics counter
           jsr DrawExplosion_Fireworks ;do a sub to draw the explosion then leave
           rts

FireworksSoundScore:
      ldan ++$00               ;disable enemy buffer flag
      stax Enemy_Flag,x
      ldan ++Sfx_Blast         ;play fireworks/gunfire sound
      sta Square2SoundQueue
      ldan ++$05               ;set part of score modifier for 500 points
      sta DigitModifier+4
      jmp EndAreaPoints     ;jump to award points accordingly then leave

;--------------------------------

StarFlagYPosAdder:
      .db $00, $00, $08, $08

StarFlagXPosAdder:
      .db $00, $08, $00, $08

StarFlagTileData:
      .db $54, $55, $56, $57

RunStarFlagObj:
      ldan ++$00                 ;initialize enemy frenzy buffer
      sta EnemyFrenzyBuffer
      lda StarFlagTaskControl  ;check star flag object task number here
      cmpn ++$05                 ;if greater than 5, branch to exit
              cmpcy
      bcs StarFlagExit
      jsr JumpEngine           ;otherwise jump to appropriate sub
      
      .dw StarFlagExit
      .dw GameTimerFireworks
      .dw AwardGameTimerPoints
      .dw RaiseFlagSetoffFWorks
      .dw DelayToAreaEnd

GameTimerFireworks:
        ldyn ++$05               ;set default state for star flag object
        lda GameTimerDisplay+2 ;get game timer's last digit
        cmpn ++$01
        beq SetFWC             ;if last digit of game timer set to 1, skip ahead
        ldyn ++$03               ;otherwise load new value for state
        cmpn ++$03
        beq SetFWC             ;if last digit of game timer set to 3, skip ahead
        ldyn ++$00               ;otherwise load one more potential value for state
        cmpn ++$06
        beq SetFWC             ;if last digit of game timer set to 6, skip ahead
        ldan ++$ff               ;otherwise set value for no fireworks
SetFWC: sta FireworksCounter   ;set fireworks counter here
        styx Enemy_State,x      ;set whatever state we have in star flag object

IncrementSFTask1:
      inci StarFlagTaskControl  ;increment star flag object task number

StarFlagExit:
      rts                      ;leave

AwardGameTimerPoints:
         lda GameTimerDisplay   ;check all game timer digits for any intervals left
         orai GameTimerDisplay+1
         orai GameTimerDisplay+2
         beq IncrementSFTask1   ;if no time left on game timer at all, branch to next task
         lda FrameCounter
         andn ++%00000100         ;check frame counter for d2 set (skip ahead
         beq NoTTick            ;for four frames every four frames) branch if not set
         ldan ++Sfx_TimerTick
         sta Square2SoundQueue  ;load timer tick sound
NoTTick: ldyn ++GameTimerDisplay-DisplayDigits+2;++$23               ;set offset here to subtract from game timer's last digit
         ldan ++$ff               ;set adder here to $ff, or -1, to subtract one
         sta DigitModifier+5    ;from the last digit of the game timer
         jsr DigitsMathRoutine  ;subtract digit
         ldan ++$05               ;set now to add 50 points
         sta DigitModifier+5    ;per game timer interval subtracted

EndAreaPoints:
         ldyn ++$0b               ;load offset for mario's score by default
         lda CurrentPlayer      ;check player on the screen
         checka
         beq ELPGive            ;if mario, do not change
         ldyn ++$11               ;otherwise load offset for luigi's score
ELPGive: jsr DigitsMathRoutine  ;award 50 points per game timer interval
         lda CurrentPlayer      ;get player on the screen (or 500 points per
         asl                    ;fireworks explosion if branched here from there)
         asl                    ;shift to high nybble
         asl
         asl
         oran ++%00000100         ;add four to set nybble for game timer
         jmp UpdateNumber       ;jump to print the new score and game timer

RaiseFlagSetoffFWorks:
         ldax Enemy_Y_Position,x  ;check star flag's vertical position
         cmpn ++$72                ;against preset value
              cmpcy
         bcc SetoffF             ;if star flag higher vertically, branch to other code
         decx Enemy_Y_Position,x  ;otherwise, raise star flag by one pixel
         jmp DrawStarFlag        ;and skip this part here
SetoffF: lda FireworksCounter    ;check fireworks counter
         checka
         beq DrawFlagSetTimer    ;if no fireworks left to go off, skip this part
         bmi DrawFlagSetTimer    ;if no fireworks set to go off, skip this part
         ldan ++Fireworks
         sta EnemyFrenzyBuffer   ;otherwise set fireworks object in frenzy queue

DrawStarFlag:
         jsr RelativeEnemyPosition  ;get relative coordinates of star flag
         ldyx Enemy_SprDataOffset,x  ;get OAM data offset
         ldxn ++$03                   ;do four sprites
DSFLoop: lda Enemy_Rel_YPos         ;get relative vertical coordinate
         clc
         adcx StarFlagYPosAdder,x    ;add Y coordinate adder data
         stay Sprite_Y_Position,y    ;store as Y coordinate
         ldax StarFlagTileData,x     ;get tile number
         stay Sprite_Tilenumber,y    ;store as tile number
         ldan ++$22                   ;set palette and background priority bits
         stay Sprite_Attributes,y    ;store as attributes
         lda Enemy_Rel_XPos         ;get relative horizontal coordinate
         clc
         adcx StarFlagXPosAdder,x    ;add X coordinate adder data
         stay Sprite_X_Position,y    ;store as X coordinate
         iny
         iny                        ;increment OAM data offset four bytes
         iny                        ;for next sprite
         iny
         dex                        ;move onto next sprite
         bpl DSFLoop                ;do this until all sprites are done
         ldx ObjectOffset           ;get enemy object offset and leave
         rts

DrawFlagSetTimer:
      jsr DrawStarFlag          ;do sub to draw star flag
      ldan ++$06
      stax EnemyIntervalTimer,x  ;set interval timer here

IncrementSFTask2:
      inci StarFlagTaskControl   ;move onto next task
      rts

DelayToAreaEnd:
      jsr DrawStarFlag          ;do sub to draw star flag
      ldax EnemyIntervalTimer,x  ;if interval timer set in previous task
         checka
      bne StarFlagExit2         ;not yet expired, branch to leave
      
;костыль: это место мешает предсказуемости при MUSICONINT=1
        if MUSICONINT
      lda EventMusicBuffer      ;if event music buffer empty,
         checka
     ret nz
    ;ld hl,(EventMusicQueue_noint)      ;if event music buffer empty,
    ;jr $ ;hl=fdcb/fdd0/fe2b/ (fdc9/fdce/fe29/fde0)
               ;ld a,(WorldNumber)           ;check world number
               ;cp ++World4;8
               ;jr nc,IncrementSFTask2 ;обычный костыль не помогает на 8-2... этот тоже!
     ld hl,SoundEngine_noint
     ld (soundenginepatch),hl ;возвращаем MUSICONINT=1
     ld a,0xcd
     ld (soundenginecall),a ;возвращаем MUSICONINT=1
     jr IncrementSFTask2      ;branch to increment task
        else
      lda EventMusicBuffer      ;if event music buffer empty,
         checka
      beq IncrementSFTask2      ;branch to increment task
        endif

StarFlagExit2:
      rts                       ;otherwise leave

;--------------------------------
;$00 - used to store horizontal difference between player and piranha plant

MovePiranhaPlant:
      ldax Enemy_State,x           ;check enemy state
         checka
      bne PutinPipe               ;if set at all, branch to leave
      ldax EnemyFrameTimer,x       ;check enemy's timer here
         checka
      bne PutinPipe               ;branch to end if not yet expired
      ldax PiranhaPlant_MoveFlag,x ;check movement flag
         checka
      bne SetupToMovePPlant       ;if moving, skip to part ahead
      ldax PiranhaPlant_Y_Speed,x  ;if currently rising, branch 
         checka
      bmi ReversePlantSpeed       ;to move enemy upwards out of pipe
      jsr PlayerEnemyDiff         ;get horizontal difference between player and
      bpl ChkPlayerNearPipe       ;piranha plant, and branch if enemy to right of player
      lda SCRATCHPAD+$00                     ;otherwise get saved horizontal difference
      eorn ++$ff
      clc                         ;and change to two's compliment
      adcn ++$01
      sta SCRATCHPAD+$00                     ;save as new horizontal difference

ChkPlayerNearPipe:
      lda SCRATCHPAD+$00                     ;get saved horizontal difference
      cmpn ++$21
              cmpcy
      bcc PutinPipe               ;if player within a certain distance, branch to leave

ReversePlantSpeed:
      ldax PiranhaPlant_Y_Speed,x  ;get vertical speed
      eorn ++$ff
      clc                         ;change to two's compliment
      adcn ++$01
      stax PiranhaPlant_Y_Speed,x  ;save as new vertical speed
      incx PiranhaPlant_MoveFlag,x ;increment to set movement flag

SetupToMovePPlant:
      ldax PiranhaPlantDownYPos,x  ;get original vertical coordinate (lowest point)
      ldyx PiranhaPlant_Y_Speed,x  ;get vertical speed
         checky
      bpl RiseFallPiranhaPlant    ;branch if moving downwards
      ldax PiranhaPlantUpYPos,x    ;otherwise get other vertical coordinate (highest point)

RiseFallPiranhaPlant:
      sta SCRATCHPAD+$00                     ;save vertical coordinate here
      lda FrameCounter            ;get frame counter
      lsr
      bcc PutinPipe               ;branch to leave if d0 set (execute code every other frame)
      lda TimerControl            ;get master timer control
         checka
      bne PutinPipe               ;branch to leave if set (likely not necessary)
      ldax Enemy_Y_Position,x      ;get current vertical coordinate
      clc
      adcx PiranhaPlant_Y_Speed,x  ;add vertical speed to move up or down
      stax Enemy_Y_Position,x      ;save as new vertical coordinate
      cmpi SCRATCHPAD+$00                     ;compare against low or high coordinate
      bne PutinPipe               ;branch to leave if not yet reached
      ldan ++$00
      stax PiranhaPlant_MoveFlag,x ;otherwise clear movement flag
      ldan ++$40
      stax EnemyFrameTimer,x       ;set timer to delay piranha plant movement

PutinPipe:
      ldan ++%00100000              ;set background priority bit in sprite
      stax Enemy_SprAttrib,x       ;attributes to give illusion of being inside pipe
      rts                         ;then leave

;-------------------------------------------------------------------------------------
;$07 - spinning speed

FirebarSpin:
      sta SCRATCHPAD+$07                     ;save spinning speed here
      ldax FirebarSpinDirection,x  ;check spinning direction
         checka
      bne SpinCounterClockwise    ;if moving counter-clockwise, branch to other part
      ldyn ++$18                    ;possibly residual ldy
      ldax FirebarSpinState_Low,x
      clc                         ;add spinning speed to what would normally be
      adci SCRATCHPAD+$07                     ;the horizontal speed
          push af
      stax FirebarSpinState_Low,x
      ldax FirebarSpinState_High,x ;add carry to what would normally be the vertical speed
          ld h,a
          pop af
          ld a,h
      adcn ++$00
      rts

SpinCounterClockwise:
      ldyn ++$08                    ;possibly residual ldy
      ldax FirebarSpinState_Low,x
      secsub                         ;subtract spinning speed to what would normally be
      sbci SCRATCHPAD+$07                     ;the horizontal speed
          push af
      stax FirebarSpinState_Low,x
      ldax FirebarSpinState_High,x ;add carry to what would normally be the vertical speed
          ld h,a
          pop af
          ld a,h
      sbcn ++$00
      rts

;-------------------------------------------------------------------------------------
;$00 - used to hold collision flag, Y movement force + 5 or low byte of name table for rope
;$01 - used to hold high byte of name table for rope
;$02 - used to hold page location of rope

BalancePlatform:
       ldax Enemy_Y_HighPos,x       ;check high byte of vertical position
       cmpn ++$03
       bne DoBPl
       jmp EraseEnemyObject        ;if far below screen, kill the object
DoBPl: ldax Enemy_State,x           ;get object's state (set to $ff or other platform offset)
         checka
       bpl CheckBalPlatform        ;if doing other balance platform, branch to leave
       rts

CheckBalPlatform:
       tay                         ;save offset from state as Y
       ldax PlatformCollisionFlag,x ;get collision flag of platform
       sta SCRATCHPAD+$00                     ;store here
       ldax Enemy_MovingDir,x       ;get moving direction
         checka
       beq ChkForFall
       jmp PlatformFall            ;if set, jump here

ChkForFall:
       ldan ++$2d                    ;check if platform is above a certain point
       cmpx Enemy_Y_Position,x
              cmpcy
       bcc ChkOtherForFall         ;if not, branch elsewhere
       cpyi SCRATCHPAD+$00                     ;if collision flag is set to same value as
       beq MakePlatformFall        ;enemy state, branch to make platforms fall
       clc
       adcn ++$02                    ;otherwise add 2 pixels to vertical position
       stax Enemy_Y_Position,x      ;of current platform and branch elsewhere
       jmp StopPlatforms           ;to make platforms stop

MakePlatformFall:
       jmp InitPlatformFall        ;make platforms fall

ChkOtherForFall:
       cmpy Enemy_Y_Position,y      ;check if other platform is above a certain point
              cmpcy
       bcc ChkToMoveBalPlat        ;if not, branch elsewhere
       cpxi SCRATCHPAD+$00                     ;if collision flag is set to same value as
       beq MakePlatformFall        ;enemy state, branch to make platforms fall
       clc
       adcn ++$02                    ;otherwise add 2 pixels to vertical position
       stay Enemy_Y_Position,y      ;of other platform and branch elsewhere
       jmp StopPlatforms           ;jump to stop movement and do not return

ChkToMoveBalPlat:
        ldax Enemy_Y_Position,x      ;save vertical position to stack
        pha
        ldax PlatformCollisionFlag,x ;get collision flag
         checka
        bpl ColFlg                  ;branch if collision
        ldax Enemy_Y_MoveForce,x
        clc                         ;add $05 to contents of moveforce, whatever they be
        adcn ++$05
        sta SCRATCHPAD+$00                     ;store here
        ldaxkeepcy Enemy_Y_Speed,x
        adcn ++$00                    ;add carry to vertical speed
        bmi PlatDn                  ;branch if moving downwards
        bne PlatUp                  ;branch elsewhere if moving upwards
        lda SCRATCHPAD+$00
        cmpn ++$0b                    ;check if there's still a little force left
              cmpcy
        bcc PlatSt                  ;if not enough, branch to stop movement
        bcs PlatUp                  ;otherwise keep branch to move upwards
ColFlg: cmpi ObjectOffset            ;if collision flag matches
        beq PlatDn                  ;current enemy object offset, branch
PlatUp: jsr MovePlatformUp          ;do a sub to move upwards
        jmp DoOtherPlatform         ;jump ahead to remaining code
PlatSt: jsr StopPlatforms           ;do a sub to stop movement
        jmp DoOtherPlatform         ;jump ahead to remaining code
PlatDn: jsr MovePlatformDown        ;do a sub to move downwards

DoOtherPlatform:
       ldyx Enemy_State,x           ;get offset of other platform
       pla                         ;get old vertical coordinate from stack
       secsub
       sbcx Enemy_Y_Position,x      ;get difference of old vs. new coordinate
       clc
       adcy Enemy_Y_Position,y      ;add difference to vertical coordinate of other
       stay Enemy_Y_Position,y      ;platform to move it in the opposite direction
       ldax PlatformCollisionFlag,x ;if no collision, skip this part here
         checka
       bmi DrawEraseRope
       tax                         ;put offset which collision occurred here
       jsr PositionPlayerOnVPlat   ;and use it to position player accordingly

DrawEraseRope:
         ldy ObjectOffset            ;get enemy object offset
         lday Enemy_Y_Speed,y         ;check to see if current platform is
         oray Enemy_Y_MoveForce,y     ;moving at all
         beq ExitRp                  ;if not, skip all of this and branch to leave
         ldx VRAM_Buffer1_Offset     ;get vram buffer offset
         cpxn ++$20                    ;if offset beyond a certain point, go ahead
              cmpcy
         bcs ExitRp                  ;and skip this, branch to leave
         lday Enemy_Y_Speed,y
         pha                         ;save two copies of vertical speed to stack
         pha
         jsr SetupPlatformRope       ;do a sub to figure out where to put new bg tiles
         lda SCRATCHPAD+$01                     ;write name table address to vram buffer
         stax VRAM_Buffer1,x          ;first the high byte, then the low
         lda SCRATCHPAD+$00
         stax VRAM_Buffer1+1,x
         ldan ++$02                    ;set length for 2 bytes
         stax VRAM_Buffer1+2,x
         lday Enemy_Y_Speed,y         ;if platform moving upwards, branch 
         checka
         bmi EraseR1                 ;to do something else
         ldan ++xa2
         stax VRAM_Buffer1+3,x        ;otherwise put tile numbers for left
         ldan ++xa3                    ;and right sides of rope in vram buffer
         stax VRAM_Buffer1+4,x
         jmp OtherRope               ;jump to skip this part
EraseR1: ldan ++$24                    ;put blank tiles in vram buffer
         stax VRAM_Buffer1+3,x        ;to erase rope
         stax VRAM_Buffer1+4,x

OtherRope:
         lday Enemy_State,y           ;get offset of other platform from state
         tay                         ;use as Y here
         pla                         ;pull second copy of vertical speed from stack
         eorn ++$ff                    ;invert bits to reverse speed
         jsr SetupPlatformRope       ;do sub again to figure out where to put bg tiles  
         lda SCRATCHPAD+$01                     ;write name table address to vram buffer
         stax VRAM_Buffer1+5,x        ;this time we're doing putting tiles for
         lda SCRATCHPAD+$00                     ;the other platform
         stax VRAM_Buffer1+6,x
         ldan ++$02
         stax VRAM_Buffer1+7,x        ;set length again for 2 bytes
         pla                         ;pull first copy of vertical speed from stack
         checka
         bpl EraseR2                 ;if moving upwards (note inversion earlier), skip this
         ldan ++xa2
         stax VRAM_Buffer1+8,x        ;otherwise put tile numbers for left
         ldan ++xa3                    ;and right sides of rope in vram
         stax VRAM_Buffer1+9,x        ;transfer buffer
         jmp EndRp                   ;jump to skip this part
EraseR2: ldan ++$24                    ;put blank tiles in vram buffer
         stax VRAM_Buffer1+8,x        ;to erase rope
         stax VRAM_Buffer1+9,x
EndRp:   ldan ++$00                    ;put null terminator at the end
         stax VRAM_Buffer1+10,x
         lda VRAM_Buffer1_Offset     ;add ten bytes to the vram buffer offset
         clc                         ;and store
         adcn ++10
         sta VRAM_Buffer1_Offset
ExitRp:  ldx ObjectOffset            ;get enemy object buffer offset and leave
         rts

SetupPlatformRope:
        pha                     ;save second/third copy to stack
        lday Enemy_X_Position,y  ;get horizontal coordinate
        clc
        adcn ++$08                ;add eight pixels
        ldx SecondaryHardMode   ;if secondary hard mode flag set,
         checkx
        bne GetLRp              ;use coordinate as-is
        clc
        adcn ++$10                ;otherwise add sixteen more pixels
GetLRp: pha                     ;save modified horizontal coordinate to stack
        ldaykeepcy Enemy_PageLoc,y
        adcn ++$00                ;add carry to page location
        sta SCRATCHPAD+$02                 ;and save here
        pla                     ;pull modified horizontal coordinate
        andn ++%11110000          ;from the stack, mask out low nybble
        lsr                     ;and shift three bits to the right
        lsr
        lsr
        sta SCRATCHPAD+$00                 ;store result here as part of name table low byte
        ldxy Enemy_Y_Position,y  ;get vertical coordinate
        pla                     ;get second/third copy of vertical speed from stack
         checka
        bpl GetHRp              ;skip this part if moving downwards or not at all
        txa
        clc
        adcn ++$08                ;add eight to vertical coordinate and
        tax                     ;save as X
GetHRp: txa                     ;move vertical coordinate to A
        ldx VRAM_Buffer1_Offset ;get vram buffer offset
        asl
        rol                     ;rotate d7 to d0 and d6 into carry
        pha                     ;save modified vertical coordinate to stack
        rol                     ;rotate carry to d0, thus d7 and d6 are at 2 LSB
        andn ++%00000011          ;mask out all bits but d7 and d6, then set
        oran ++%00100000          ;d5 to get appropriate high byte of name table
        sta SCRATCHPAD+$01                 ;address, then store
        lda SCRATCHPAD+$02                 ;get saved page location from earlier
        andn ++$01                ;mask out all but LSB
        asl
        asl                     ;shift twice to the left and save with the
        orai SCRATCHPAD+$01                 ;rest of the bits of the high byte, to get
        sta SCRATCHPAD+$01                 ;the proper name table and the right place on it
        pla                     ;get modified vertical coordinate from stack
        andn ++%11100000          ;mask out low nybble and LSB of high nybble
        clc
        adci SCRATCHPAD+$00                 ;add to horizontal part saved here
        sta SCRATCHPAD+$00                 ;save as name table low byte
        lday Enemy_Y_Position,y
        cmpn ++$e8                ;if vertical position not below the
              cmpcy
        bcc ExPRp               ;bottom of the screen, we're done, branch to leave
        lda SCRATCHPAD+$00
        andn ++%10111111          ;mask out d6 of low byte of name table address
        sta SCRATCHPAD+$00
ExPRp:  rts                     ;leave!

InitPlatformFall:
      tya                        ;move offset of other platform from Y to X
      tax
      jsr GetEnemyOffscreenBits  ;get offscreen bits
      ldan ++$06
      jsr SetupFloateyNumber     ;award 1000 points to player
      lda Player_Rel_XPos
      stax FloateyNum_X_Pos,x     ;put floatey number coordinates where player is
      lda Player_Y_Position
      stax FloateyNum_Y_Pos,x
      ldan ++$01                   ;set moving direction as flag for
      stax Enemy_MovingDir,x      ;falling platforms

StopPlatforms:
      jsr InitVStf             ;initialize vertical speed and low byte
      stay Enemy_Y_Speed,y      ;for both platforms and leave
      stay Enemy_Y_MoveForce,y
      rts

PlatformFall:
      tya                         ;save offset for other platform to stack
      pha
      jsr MoveFallingPlatform     ;make current platform fall
      pla
      tax                         ;pull offset from stack and save to X
      jsr MoveFallingPlatform     ;make other platform fall
      ldx ObjectOffset
      ldax PlatformCollisionFlag,x ;if player not standing on either platform,
         checka
      bmi ExPF                    ;skip this part
      tax                         ;transfer collision flag offset as offset to X
      jsr PositionPlayerOnVPlat   ;and position player appropriately
ExPF: ldx ObjectOffset            ;get enemy object buffer offset and leave
      rts

;--------------------------------

YMovingPlatform:
        ldax Enemy_Y_Speed,x          ;if platform moving up or down, skip ahead to
        orax Enemy_Y_MoveForce,x      ;check on other position
        bne ChkYCenterPos
        stax Enemy_YMF_Dummy,x        ;initialize dummy variable
        ldax Enemy_Y_Position,x
        cmpx YPlatformTopYPos,x       ;if current vertical position =HIGH  top position, branch
              cmpcy
        bcs ChkYCenterPos            ;ahead of all this
        lda FrameCounter
        andn ++%00000111               ;check for every eighth frame
        bne SkipIY
        incx Enemy_Y_Position,x       ;increase vertical position every eighth frame
SkipIY: jmp ChkYPCollision           ;skip ahead to last part

ChkYCenterPos:
        ldax Enemy_Y_Position,x       ;if current vertical position LOW  central position, branch
        cmpx YPlatformCenterYPos,x    ;to slow ascent/move downwards
              cmpcy
        bcc YMDown
        jsr MovePlatformUp           ;otherwise start slowing descent/moving upwards
        jmp ChkYPCollision
YMDown: jsr MovePlatformDown         ;start slowing ascent/moving downwards

ChkYPCollision:
       ldax PlatformCollisionFlag,x  ;if collision flag not set here, branch
         checka
       bmi ExYPl                    ;to leave
       jsr PositionPlayerOnVPlat    ;otherwise position player appropriately
ExYPl: rts                          ;leave

;--------------------------------
;$00 - used as adder to position player hotizontally

XMovingPlatform:
      ldan ++$0e                     ;load preset maximum value for secondary counter
      jsr XMoveCntr_Platform       ;do a sub to increment counters for movement
      jsr MoveWithXMCntrs          ;do a sub to move platform accordingly, and return value
      ldax PlatformCollisionFlag,x  ;if no collision with player,
         checka
      bmi ExXMP                    ;branch ahead to leave

PositionPlayerOnHPlat:
         lda Player_X_Position
         clc                       ;add saved value from second subroutine to
         adci SCRATCHPAD+$00                   ;current player's position to position (прибавляем смещение игрока по X относительно прошлого раза)
         sta Player_X_Position     ;player accordingly in horizontal position
         lda Player_PageLoc        ;get player's page location
         ldy SCRATCHPAD+$00                   ;check to see if saved value here is positive or negative
         checky
         bmi PPHSubt               ;if negative, branch to subtract
         adcn ++$00                  ;otherwise add carry to page location
         jmp SetPVar               ;jump to skip subtraction
PPHSubt:
        cmpcy
         sbcn ++$00                  ;subtract borrow from page location
SetPVar: sta Player_PageLoc        ;save result to player's page location
         sty Platform_X_Scroll     ;put saved value from second sub here to be used later
         jsr PositionPlayerOnVPlat ;position player vertically and appropriately
ExXMP:   rts                       ;and we are done here

;--------------------------------

DropPlatform:
       ldax PlatformCollisionFlag,x  ;if no collision between platform and player
         checka
       bmi ExDPl                    ;occurred, just leave without moving anything
       jsr MoveDropPlatform         ;otherwise do a sub to move platform down very quickly
       jsr PositionPlayerOnVPlat    ;do a sub to position player appropriately
ExDPl: rts                          ;leave

;--------------------------------
;$00 - residual value from sub

RightPlatform:
       jsr MoveEnemyHorizontally     ;move platform with current horizontal speed, if any
       sta SCRATCHPAD+$00                       ;store saved value here (residual code)
       ldax PlatformCollisionFlag,x   ;check collision flag, if no collision between player
         checka
       bmi ExRPl                     ;and platform, branch ahead, leave speed unaltered
       ldan ++$10
       stax Enemy_X_Speed,x           ;otherwise set new speed (gets moving if motionless)
       jsr PositionPlayerOnHPlat     ;use saved value from earlier sub to position player
ExRPl: rts                           ;then leave

;--------------------------------

MoveLargeLiftPlat:
      jsr MoveLiftPlatforms  ;execute common to all large and small lift platforms
      jmp ChkYPCollision     ;branch to position player correctly

MoveSmallPlatform:
      jsr MoveLiftPlatforms      ;execute common to all large and small lift platforms
      jmp ChkSmallPlatCollision  ;branch to position player correctly

MoveLiftPlatforms:
      lda TimerControl         ;if master timer control set, skip all of this
         checka
      bne ExLiftP              ;and branch to leave
      ldax Enemy_YMF_Dummy,x
      clc                      ;add contents of movement amount to whatever's here
      adcx Enemy_Y_MoveForce,x
          push af
      stax Enemy_YMF_Dummy,x
      ldax Enemy_Y_Position,x   ;add whatever vertical speed is set to current
          ld h,a
          pop af
          ld a,h
      adcx Enemy_Y_Speed,x      ;vertical position plus carry to move up or down
      stax Enemy_Y_Position,x   ;and then leave
      rts

ChkSmallPlatCollision:
         ldax PlatformCollisionFlag,x ;get bounding box counter saved in collision flag
         checka
         beq ExLiftP                 ;if none found, leave player position alone
         jsr PositionPlayerOnS_Plat  ;use to position player correctly
ExLiftP: rts                         ;then leave

;-------------------------------------------------------------------------------------
;$00 - page location of extended left boundary
;$01 - extended left boundary position
;$02 - page location of extended right boundary
;$03 - extended right boundary position

OffscreenBoundsCheck:
          ldax Enemy_ID,x          ;check for cheep-cheep object
          cmpn ++FlyingCheepCheep   ;branch to leave if found
          beq ExScrnBd
          lda ScreenLeft_X_Pos    ;get horizontal coordinate for left side of screen
          ldyx Enemy_ID,x
          cpyn ++HammerBro          ;check for hammer bro object
          beq LimitB
          cpyn ++PiranhaPlant       ;check for piranha plant object
          bne ExtendLB            ;these two will be erased sooner than others if too far left
LimitB:   
        cmpcy
          adcn ++$38                ;add 56 pixels to coordinate if hammer bro or piranha plant
        cmpcy
ExtendLB: 
          sbcn ++$48                ;subtract 72 pixels regardless of enemy object
          sta SCRATCHPAD+$01                 ;store result here
          lda ScreenLeft_PageLoc
          sbcn ++$00                ;subtract borrow from page location of left side
        cmpcy
          sta SCRATCHPAD+$00                 ;store result here
          lda ScreenRight_X_Pos   ;add 72 pixels to the right side horizontal coordinate
          adcn ++$48
          sta SCRATCHPAD+$03                 ;store result here
          lda ScreenRight_PageLoc     
          adcn ++$00                ;then add the carry to the page location
          sta SCRATCHPAD+$02                 ;and store result here
          ldax Enemy_X_Position,x  ;compare horizontal coordinate of the enemy object
          cmpi SCRATCHPAD+$01                 ;to modified horizontal left edge coordinate to get carry
          ldaxkeepcy Enemy_PageLoc,x
          sbci SCRATCHPAD+$00                 ;then subtract it from the page coordinate of the enemy object
          bmi TooFar              ;if enemy object is too far left, branch to erase it
          ldax Enemy_X_Position,x  ;compare horizontal coordinate of the enemy object
          cmpi SCRATCHPAD+$03                 ;to modified horizontal right edge coordinate to get carry
          ldaxkeepcy Enemy_PageLoc,x
          sbci SCRATCHPAD+$02                 ;then subtract it from the page coordinate of the enemy object
          bmi ExScrnBd            ;if enemy object is on the screen, leave, do not erase enemy
          ldax Enemy_State,x       ;if at this point, enemy is offscreen to the right, so check
          cmpn ++HammerBro          ;if in state used by spiny's egg, do not erase
          beq ExScrnBd
          cpyn ++PiranhaPlant       ;if piranha plant, do not erase
          beq ExScrnBd
          cpyn ++FlagpoleFlagObject ;if flagpole flag, do not erase
          beq ExScrnBd
          cpyn ++StarFlagObject     ;if star flag, do not erase
          beq ExScrnBd
          cpyn ++JumpspringObject   ;if jumpspring, do not erase
          beq ExScrnBd            ;erase all others too far to the right
TooFar:   jsr EraseEnemyObject    ;erase object if necessary
ExScrnBd: rts                     ;leave

;-------------------------------------------------------------------------------------

;some unused space
      .db $ff, $ff, $ff

;-------------------------------------------------------------------------------------
;$01 - enemy buffer offset

FireballEnemyCollision:
      ldax Fireball_State,x  ;check to see if fireball state is set at all
         checka
      beq ExitFBallEnemy    ;branch to leave if not
      asl
      bcs ExitFBallEnemy    ;branch to leave also if d7 in state is set
      lda FrameCounter
      lsr                   ;get LSB of frame counter
      bcs ExitFBallEnemy    ;branch to leave if set (do routine every other frame)
      txa
      asl                   ;multiply fireball offset by four
      asl
      clc
      adcn ++$1c              ;then add $1c or 28 bytes to it
      tay                   ;to use fireball's bounding box coordinates 
      ldxn ++$04

FireballEnemyCDLoop:
           stx SCRATCHPAD+$01                     ;store enemy object offset here
           tya
           pha                         ;push fireball offset to the stack
           ldax Enemy_State,x
           andn ++%00100000              ;check to see if d5 is set in enemy state
           bne NoFToECol               ;if so, skip to next enemy slot
           ldax Enemy_Flag,x            ;check to see if buffer flag is set
         checka
           beq NoFToECol               ;if not, skip to next enemy slot
           ldax Enemy_ID,x              ;check enemy identifier
           cmpn ++$24
              cmpcy
           bcc GoombaDie               ;if LOW  $24, branch to check further
           cmpn ++$2b
              cmpcy
           bcc NoFToECol               ;if in range $24-$2a, skip to next enemy slot
GoombaDie: cmpn ++Goomba                 ;check for goomba identifier
           bne NotGoomba               ;if not found, continue with code
           ldax Enemy_State,x           ;otherwise check for defeated state
           cmpn ++$02                    ;if stomped or otherwise defeated,
              cmpcy
           bcs NoFToECol               ;skip to next enemy slot
NotGoomba: ldax EnemyOffscrBitsMasked,x ;if any masked offscreen bits set,
         checka
           bne NoFToECol               ;skip to next enemy slot
           txa
           asl                         ;otherwise multiply enemy offset by four
           asl
           clc
           adcn ++$04                    ;add 4 bytes to it
           tax                         ;to use enemy's bounding box coordinates
           jsr SprObjectCollisionCore  ;do fireball-to-enemy collision detection
           ldx ObjectOffset            ;return fireball's original offset
           bcc NoFToECol               ;if carry clear, no collision, thus do next enemy slot
           ldan ++%10000000
           stax Fireball_State,x        ;set d7 in enemy state
           ldx SCRATCHPAD+$01                     ;get enemy offset
           jsr HandleEnemyFBallCol     ;jump to handle fireball to enemy collision
NoFToECol: pla                         ;pull fireball offset from stack
           tay                         ;put it in Y
           ldx SCRATCHPAD+$01                     ;get enemy object offset
           dex                         ;decrement it
           bpl FireballEnemyCDLoop     ;loop back until collision detection done on all enemies

ExitFBallEnemy:
      ldx ObjectOffset                 ;get original fireball offset and leave
      rts

BowserIdentities:
      .db Goomba, GreenKoopa, BuzzyBeetle, Spiny, Lakitu, Bloober, HammerBro, Bowser

HandleEnemyFBallCol:
      jsr RelativeEnemyPosition  ;get relative coordinate of enemy
      ldx SCRATCHPAD+$01                    ;get current enemy object offset
      ldax Enemy_Flag,x           ;check buffer flag for d7 set
         checka
      bpl ChkBuzzyBeetle         ;branch if not set to continue
      andn ++%00001111             ;otherwise mask out high nybble and
      tax                        ;use low nybble as enemy offset
      ldax Enemy_ID,x
      cmpn ++Bowser                ;check enemy identifier for bowser
      beq HurtBowser             ;branch if found
      ldx SCRATCHPAD+$01                    ;otherwise retrieve current enemy offset

ChkBuzzyBeetle:
      ldax Enemy_ID,x
      cmpn ++BuzzyBeetle           ;check for buzzy beetle
      beq ExHCF                  ;branch if found to leave (buzzy beetles fireproof)
      cmpn ++Bowser                ;check for bowser one more time (necessary if d7 of flag was clear)
      bne ChkOtherEnemies        ;if not found, branch to check other enemies

HurtBowser:
          deci BowserHitPoints        ;decrement bowser's hit points
          bne ExHCF                  ;if bowser still has hit points, branch to leave
          jsr InitVStf               ;otherwise do sub to init vertical speed and movement force
          stax Enemy_X_Speed,x        ;initialize horizontal speed
          sta EnemyFrenzyBuffer      ;init enemy frenzy buffer
          ldan ++$fe
          stax Enemy_Y_Speed,x        ;set vertical speed to make defeated bowser jump a little
          ldy WorldNumber            ;use world number as offset
          lday BowserIdentities,y     ;get enemy identifier to replace bowser with
          stax Enemy_ID,x             ;set as new enemy identifier
          ldan ++$20                   ;set A to use starting value for state
          cpyn ++$03                   ;check to see if using offset of 3 or more
              cmpcy
          bcs SetDBSte               ;branch if so
          oran ++$03                   ;otherwise add 3 to enemy state
SetDBSte: stax Enemy_State,x          ;set defeated enemy state
          ldan ++Sfx_BowserFall
          sta Square2SoundQueue      ;load bowser defeat sound
          ldx SCRATCHPAD+$01                    ;get enemy offset
          ldan ++$09                   ;award 5000 points to player for defeating bowser
         checka
          bne EnemySmackScore        ;unconditional branch to award points

ChkOtherEnemies:
      cmpn ++BulletBill_FrenzyVar
      beq ExHCF                 ;branch to leave if bullet bill (frenzy variant) 
      cmpn ++Podoboo       
      beq ExHCF                 ;branch to leave if podoboo
      cmpn ++$15       
              cmpcy
      bcs ExHCF                 ;branch to leave if identifier =HIGH  $15

ShellOrBlockDefeat:
      ldax Enemy_ID,x            ;check for piranha plant
      cmpn ++PiranhaPlant
       cmpcy
      bne StnE                  ;branch if not found
      ldaxkeepcy Enemy_Y_Position,x
      adcn ++$18                  ;add 24 pixels to enemy object's vertical position
      stax Enemy_Y_Position,x
StnE: jsr ChkToStunEnemies      ;do yet another sub
      ldax Enemy_State,x
      andn ++%00011111            ;mask out 2 MSB of enemy object's state
      oran ++%00100000            ;set d5 to defeat enemy and save as new state
      stax Enemy_State,x
      ldan ++$02                  ;award 200 points by default
      ldyx Enemy_ID,x            ;check for hammer bro
      cpyn ++HammerBro
      bne GoombaPoints          ;branch if not found
      ldan ++$06                  ;award 1000 points for hammer bro

GoombaPoints:
      cpyn ++Goomba               ;check for goomba
      bne EnemySmackScore       ;branch if not found
      ldan ++$01                  ;award 100 points for goomba

EnemySmackScore:
       jsr SetupFloateyNumber   ;update necessary score variables
       ldan ++Sfx_EnemySmack      ;play smack enemy sound
       sta Square1SoundQueue
ExHCF: rts                      ;and now let's leave

;-------------------------------------------------------------------------------------

PlayerHammerCollision:
        lda FrameCounter          ;get frame counter
        lsr                       ;shift d0 into carry
        bcc ExPHC                 ;branch to leave if d0 not set to execute every other frame
        lda TimerControl          ;if either master timer control
        orai Misc_OffscreenBits    ;or any offscreen bits for hammer are set,
        bne ExPHC                 ;branch to leave
        txa
        asl                       ;multiply misc object offset by four
        asl
        clc
        adcn ++$24                  ;add 36 or $24 bytes to get proper offset
        tay                       ;for misc object bounding box coordinates
        jsr PlayerCollisionCore   ;do player-to-hammer collision detection
        ldx ObjectOffset          ;get misc object offset
        bcc ClHCol                ;if no collision, then branch
        ldax Misc_Collision_Flag,x ;otherwise read collision flag
         checka
        bne ExPHC                 ;if collision flag already set, branch to leave
        ldan ++$01
        stax Misc_Collision_Flag,x ;otherwise set collision flag now
        ldax Misc_X_Speed,x
        eorn ++$ff                  ;get two's compliment of
        clc                       ;hammer's horizontal speed
        adcn ++$01
        stax Misc_X_Speed,x        ;set to send hammer flying the opposite direction
        lda StarInvincibleTimer   ;if star mario invincibility timer set,
         checka
        bne ExPHC                 ;branch to leave
        jmp InjurePlayer          ;otherwise jump to hurt player, do not return
ClHCol: ldan ++$00                  ;clear collision flag
        stax Misc_Collision_Flag,x
ExPHC:  rts

;-------------------------------------------------------------------------------------

HandlePowerUpCollision:
      jsr EraseEnemyObject    ;erase the power-up object
      ldan ++$06
      jsr SetupFloateyNumber  ;award 1000 points to player by default
      ldan ++Sfx_PowerUpGrab
      sta Square2SoundQueue   ;play the power-up sound
      lda PowerUpType         ;check power-up type
      cmpn ++$02
              cmpcy
      bcc Shroom_Flower_PUp   ;if mushroom or fire flower, branch
      cmpn ++$03
      beq SetFor1Up           ;if 1-up mushroom, branch
      ldan ++$23                ;otherwise set star mario invincibility
      sta StarInvincibleTimer ;timer, and load the star mario music
      ldan ++StarPowerMusic     ;into the area music queue, then leave
      sta AreaMusicQueue
      rts

Shroom_Flower_PUp:
      lda PlayerStatus    ;if player status = small, branch
         checka
      beq UpToSuper
      cmpn ++$01            ;if player status not super, leave
      bne NoPUp
      ldx ObjectOffset    ;get enemy offset, not necessary
      ldan ++$02            ;set player status to fiery
      sta PlayerStatus
      jsr GetPlayerColors ;run sub to change colors of player
      ldx ObjectOffset    ;get enemy offset again, and again not necessary
      ldan ++$0c            ;set value to be used by subroutine tree (fiery)
      jmp UpToFiery       ;jump to set values accordingly

SetFor1Up:
      ldan ++$0b                 ;change 1000 points into 1-up instead
      stax FloateyNum_Control,x ;and then leave
      rts

UpToSuper:
       ldan ++$01         ;set player status to super
       sta PlayerStatus
       ldan ++$09         ;set value to be used by subroutine tree (super)

UpToFiery:
       ldyn ++$00         ;set value to be used as new player state
       jsr SetPRout     ;set values to stop certain things in motion
NoPUp: rts

;--------------------------------

ResidualXSpdData:
      .db $18, $e8

KickedShellXSpdData:
      .db $30, $d0

DemotedKoopaXSpdData:
      .db $08, $f8

PlayerEnemyCollision:
         lda FrameCounter            ;check counter for d0 set
         lsr
	;ccf ;не помогает на 1-2 (при фиксах CY тоже не помогает)
	;scf ;без коллизий с монстрами
         bcs NoPUp                   ;if set, branch to leave
         jsr CheckPlayerVertical     ;if player object is completely offscreen or
         bcs NoPECol                 ;if down past 224th pixel row, branch to leave
         ldax EnemyOffscrBitsMasked,x ;if current enemy is offscreen by any amount,
         checka
         bne NoPECol                 ;go ahead and branch to leave
         lda GameEngineSubroutine
         cmpn ++$08                    ;if not set to run player control routine
         bne NoPECol                 ;on next frame, branch to leave
         ldax Enemy_State,x
         andn ++%00100000              ;if enemy state has d5 set, branch to leave
         bne NoPECol
         jsr GetEnemyBoundBoxOfs     ;get bounding box offset for current enemy object
         jsr PlayerCollisionCore     ;do collision detection on player vs. enemy
         ldx ObjectOffset            ;get enemy object buffer offset
         bcs CheckForPUpCollision    ;if collision, branch past this part here
         ldax Enemy_CollisionBits,x
         andn ++%11111110              ;otherwise, clear d0 of current enemy object's
         stax Enemy_CollisionBits,x   ;collision bit
NoPECol: rts

CheckForPUpCollision:
       ldyx Enemy_ID,x
       cpyn ++PowerUpObject            ;check for power-up object
       bne EColl                     ;if not found, branch to next part
       jmp HandlePowerUpCollision    ;otherwise, unconditional jump backwards
EColl: lda StarInvincibleTimer       ;if star mario invincibility timer expired,
         checka
       beq HandlePECollisions        ;perform task here, otherwise kill enemy like
       jmp ShellOrBlockDefeat        ;hit with a shell, or from beneath

KickedShellPtsData:
      .db $0a, $06, $04

HandlePECollisions:
       ldax Enemy_CollisionBits,x    ;check enemy collision bits for d0 set
       andn ++%00000001               ;or for being offscreen at all
       orax EnemyOffscrBitsMasked,x
       bne ExPEC                    ;branch to leave if either is true
       ldan ++$01
       orax Enemy_CollisionBits,x    ;otherwise set d0 now
       stax Enemy_CollisionBits,x
       cpyn ++Spiny                   ;branch if spiny
       beq ChkForPlayerInjury
       cpyn ++PiranhaPlant            ;branch if piranha plant
       beq InjurePlayer_PiranhaPlant
       cpyn ++Podoboo                 ;branch if podoboo
       beq InjurePlayer_PiranhaPlant
       cpyn ++BulletBill_CannonVar    ;branch if bullet bill
       beq ChkForPlayerInjury
       cpyn ++$15                     ;branch if object =>  $15
              cmpcy
       bcs InjurePlayer
       lda AreaType                 ;branch if water type level
         checka
       beq InjurePlayer
       ldax Enemy_State,x            ;branch if d7 of enemy state was set
       asl
       bcs ChkForPlayerInjury
       ldax Enemy_State,x            ;mask out all but 3 LSB of enemy state
       andn ++%00000111
       cmpn ++$02                     ;branch if enemy is in normal or falling state
              cmpcy
       bcc ChkForPlayerInjury
       ldax Enemy_ID,x               ;branch to leave if goomba in defeated state
       cmpn ++Goomba
       beq ExPEC
       ldan ++Sfx_EnemySmack          ;play smack enemy sound
       sta Square1SoundQueue
       ldax Enemy_State,x            ;set d7 in enemy state, thus become moving shell
       oran ++%10000000
       stax Enemy_State,x
       jsr EnemyFacePlayer          ;set moving direction and get offset
       lday KickedShellXSpdData,y    ;load and set horizontal speed data with offset
       stax Enemy_X_Speed,x
       ldan ++$03                     ;add three to whatever the stomp counter contains
       clc                          ;to give points for kicking the shell
       adci StompChainCounter
       ldyx EnemyIntervalTimer,x     ;check shell enemy's timer
       cpyn ++$03                     ;if above a certain point, branch using the points
              cmpcy
       bcs KSPts                    ;data obtained from the stomp counter + 3
       lday KickedShellPtsData,y     ;otherwise, set points based on proximity to timer expiration
KSPts: jsr SetupFloateyNumber       ;set values for floatey number now
ExPEC: rts                          ;leave!!!

ChkForPlayerInjury:
          lda Player_Y_Speed     ;check player's vertical speed
         checka
          bmi ChkInj             ;perform procedure below if player moving upwards
	   ;jr $ ;если здесь поймать столкновение с грибом на 1-2 (yspeed=0!!!) и перенаправить вручную на EnemyStomped (хотя по идее мы не должны его давить), то дальше умираем на кактусе
          bne EnemyStomped       ;or not at all, and branch elsewhere if moving downwards
ChkInj:   ldax Enemy_ID,x         ;branch if enemy object <  $07
      if GOODBULLET
       cp BulletBill_CannonVar
       ret z
      endif
          cmpn ++Bloober
              cmpcy
          bcc ChkETmrs
          lda Player_Y_Position  ;add 12 pixels to player's vertical position
          clc
          adcn ++$0c
          cmpx Enemy_Y_Position,x ;compare modified player's position to enemy's position
              cmpcy
          bcc EnemyStomped       ;branch if this player's position above (less than) enemy's
ChkETmrs: lda StompTimer         ;check stomp timer
         checka
          bne EnemyStomped       ;branch if set
          lda InjuryTimer        ;check to see if injured invincibility timer still
         checka
          bne ExInjColRoutines   ;counting down, and branch elsewhere to leave if so
          lda Player_Rel_XPos
          cmpi Enemy_Rel_XPos     ;if player's relative position to the left of enemy's
              cmpcy
          bcc TInjE              ;relative position, branch here
          jmp ChkEnemyFaceRight  ;otherwise do a jump here
TInjE:    ldax Enemy_MovingDir,x  ;if enemy moving towards the left,
          cmpn ++$01               ;branch, otherwise do a jump here
          bne InjurePlayer       ;to turn the enemy around
          jmp LInj

InjurePlayer_PiranhaPlant:
      if GOODPIRANHAPLANT
       ret
      endif
InjurePlayer:
      lda InjuryTimer          ;check again to see if injured invincibility timer is
         checka
      bne ExInjColRoutines     ;at zero, and branch to leave if so

ForceInjury:
          ldx PlayerStatus          ;check player's status
         checkx
          beq KillPlayer            ;branch if small
          sta PlayerStatus          ;otherwise set player's status to small
          ldan ++$08
          sta InjuryTimer           ;set injured invincibility timer
          asl
          sta Square1SoundQueue     ;play pipedown/injury sound
          jsr GetPlayerColors       ;change player's palette if necessary
          ldan ++$0a                  ;set subroutine to run on next frame
SetKRout: ldyn ++$01                  ;set new player state
SetPRout: sta GameEngineSubroutine  ;load new value to run subroutine on next frame
          sty Player_State          ;store new player state
          ldyn ++$ff
          sty TimerControl          ;set master timer control flag to halt timers
          iny
          sty ScrollAmount          ;initialize scroll speed

ExInjColRoutines:
      ldx ObjectOffset              ;get enemy offset and leave
      rts

KillPlayer:
      stx Player_X_Speed   ;halt player's horizontal movement by initializing speed
      inx
      stx EventMusicQueue  ;set event music queue to death music
      ldan ++$fc
      sta Player_Y_Speed   ;set new vertical speed
      ldan ++$0b             ;set subroutine to run on next frame
         checka
      bne SetKRout         ;branch to set player's state and other things

StompedEnemyPtsData:
      .db $02, $06, $05, $06

EnemyStomped:
      ldax Enemy_ID,x             ;check for spiny, branch to hurt player
      cmpn ++Spiny                 ;if found
      beq InjurePlayer
      ldan ++Sfx_EnemyStomp        ;otherwise play stomp/swim sound
      sta Square1SoundQueue
      ldax Enemy_ID,x
      ldyn ++$00                   ;initialize points data offset for stomped enemies
      cmpn ++FlyingCheepCheep      ;branch for cheep-cheep
      beq EnemyStompedPts
      cmpn ++BulletBill_FrenzyVar  ;branch for either bullet bill object
      beq EnemyStompedPts
      cmpn ++BulletBill_CannonVar
      beq EnemyStompedPts
      cmpn ++Podoboo               ;branch for podoboo (this branch is logically impossible
      beq EnemyStompedPts        ;for cpu to take due to earlier checking of podoboo)
      iny                        ;increment points data offset
      cmpn ++HammerBro             ;branch for hammer bro
      beq EnemyStompedPts
      iny                        ;increment points data offset
      cmpn ++Lakitu                ;branch for lakitu
      beq EnemyStompedPts
      iny                        ;increment points data offset
      cmpn ++Bloober               ;branch if NOT bloober
      bne ChkForDemoteKoopa

EnemyStompedPts:
      lday StompedEnemyPtsData,y  ;load points data using offset in Y
      jsr SetupFloateyNumber     ;run sub to set floatey number controls
      ldax Enemy_MovingDir,x
      pha                        ;save enemy movement direction to stack
      jsr SetStun                ;run sub to kill enemy
      pla
      stax Enemy_MovingDir,x      ;return enemy movement direction from stack
      ldan ++%00100000
      stax Enemy_State,x          ;set d5 in enemy state
      jsr InitVStf               ;nullify vertical speed, physics-related thing,
      stax Enemy_X_Speed,x        ;and horizontal speed
      ldan ++$fd                   ;set player's vertical speed, to give bounce
      sta Player_Y_Speed
      rts

ChkForDemoteKoopa:
      cmpn ++$09                   ;branch elsewhere if enemy object < $09 ;начиная с объекта #9 идут misc objects (что это???)
              cmpcy
      bcc HandleStompedShellE
      andn ++%00000001             ;demote koopa paratroopas to ordinary troopas
      stax Enemy_ID,x
      ldyn ++$00                   ;return enemy to normal state
      styx Enemy_State,x
      ldan ++$03                   ;award 400 points to the player
      jsr SetupFloateyNumber
      jsr InitVStf               ;nullify physics-related thing and vertical speed
      jsr EnemyFacePlayer        ;turn enemy around if necessary
      lday DemotedKoopaXSpdData,y
      stax Enemy_X_Speed,x        ;set appropriate moving speed based on direction
      jmp SBnce                  ;then move onto something else

RevivalRateData:
      .db $10, $0b

HandleStompedShellE:
       ldan ++$04                   ;set defeated state for enemy
       stax Enemy_State,x
       inci StompChainCounter      ;increment the stomp counter
       lda StompChainCounter      ;add whatever is in the stomp counter
       clc                        ;to whatever is in the stomp timer
       adci StompTimer
       jsr SetupFloateyNumber     ;award points accordingly
       inci StompTimer             ;increment stomp timer of some sort
       ldy PrimaryHardMode        ;check primary hard mode flag
       lday RevivalRateData,y      ;load timer setting according to flag
       stax EnemyIntervalTimer,x   ;set as enemy timer to revive stomped enemy
SBnce: ldan ++$fc                   ;set player's vertical speed for bounce
       sta Player_Y_Speed         ;and then leave!!!
       rts

ChkEnemyFaceRight:
       ldax Enemy_MovingDir,x ;check to see if enemy is moving to the right
       cmpn ++$01
       bne LInj              ;if not, branch
       jmp InjurePlayer      ;otherwise go back to hurt player
LInj:  jsr EnemyTurnAround   ;turn the enemy around, if necessary
       jmp InjurePlayer      ;go back to hurt player


EnemyFacePlayer:
       ldyn ++$01               ;set to move right by default
       jsr PlayerEnemyDiff    ;get horizontal difference between player and enemy
       bpl SFcRt              ;if enemy is to the right of player, do not increment
       iny                    ;otherwise, increment to set to move to the left
SFcRt: styx Enemy_MovingDir,x  ;set moving direction here
       dey                    ;then decrement to use as a proper offset
       rts

SetupFloateyNumber:
       stax FloateyNum_Control,x ;set number of points control for floatey numbers
       ldan ++$30
       stax FloateyNum_Timer,x   ;set timer for floatey numbers
       ldax Enemy_Y_Position,x
       stax FloateyNum_Y_Pos,x   ;set vertical coordinate
       lda Enemy_Rel_XPos
       stax FloateyNum_X_Pos,x   ;set horizontal coordinate and leave
ExSFN: rts

;-------------------------------------------------------------------------------------
;$01 - used to hold enemy offset for second enemy

SetBitsMask:
      .db %10000000, %01000000, %00100000, %00010000, %00001000, %00000100, %00000010

ClearBitsMask:
      .db %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101

EnemiesCollision:
;TODO ускорить через ix вместо c
       if Z80OPT2
        ld a,(FrameCounter)            ;check counter for d0 set
        rra
        ret nc;bcc ExSFN                   ;if d0 not set, leave
        ld a,(AreaType)
        or a
        ret z;beq ExSFN                   ;if water area type, leave
        ld hl,Enemy_ID
        add hl,bc
        ld a,(hl)
        cp ++$15                    ;if enemy object =>  $15, branch to leave
        jp nc,ExitECRoutine
        cp ++Lakitu                 ;if lakitu, branch to leave
        jp z,ExitECRoutine
        cp ++PiranhaPlant           ;if piranha plant, branch to leave
        jp z,ExitECRoutine
        ldax EnemyOffscrBitsMasked,x ;if masked offscreen bits nonzero, branch to leave
        or a
        jp nz,ExitECRoutine
        call GetEnemyBoundBoxOfs     ;otherwise, do sub, get appropriate bounding box offset for
        dec c                         ;first enemy we're going to compare, then decrement for second
        jp m,ExitECRoutine           ;branch to leave if there are no other enemies
ECLoop: ;ld ly,c;stx SCRATCHPAD+$01                     ;save enemy object buffer offset for second enemy here
       ;ld hy,e;tya                         ;save first enemy's bounding box offset to stack
       ;pha
        ldax Enemy_Flag,x            ;check enemy object enable flag
        or a
        jr z,ReadyNextEnemy_fast          ;branch if flag not set
        ldax Enemy_ID,x
        cp ++$15                    ;check for enemy object =>  $15
        jr nc,ReadyNextEnemy_fast          ;branch if true
        cp ++Lakitu
        jr z,ReadyNextEnemy_fast          ;branch if enemy object is lakitu
        cp ++PiranhaPlant
        jr z,ReadyNextEnemy_fast          ;branch if enemy object is piranha plant
        ldax EnemyOffscrBitsMasked,x
        or a
        jr nz,ReadyNextEnemy_fast          ;branch if masked offscreen bits set
      ld ly,c
      ;ld hy,e ;не помогает
        ld a,c                         ;get second enemy object's bounding box offset
        inc a
        add a,a                         ;multiply by four, then add four
        add a,a
        ld c,a                         ;use as new contents of X
       push ix
       push iy
       call SprObjectCollisionCore  ;do collision detection using the two enemies here ;не портит y
       pop iy
       pop ix
        ld hy,e
      ld hl,ObjectOffset
      ld e,(hl);ld c,(hl)      ;use first enemy offset for X
      ld c,ly;ld e,ly;ldy SCRATCHPAD+$01                     ;use second enemy offset for Y
        jr nc,NoEnemyCollision        ;if carry clear, no collision, branch ahead of this
        ld hl,Enemy_State
        add hl,de;bc
        ld a,(hl) ;ldax Enemy_State,x
        ld hl,Enemy_State
        add hl,bc;de
        or (hl) ;oray Enemy_State,y           ;check both enemy states for d7 set
        jp m,YesEC                   ;branch if at least one of them is set
        ld ix,Enemy_CollisionBits
        add ix,bc;de
        ld a,(ix);lday Enemy_CollisionBits,y   ;load first enemy's collision-related bits
        ld hl,SetBitsMask
        add hl,de;bc
        and (hl);andx SetBitsMask,x           ;check to see if bit connected to second enemy is
        jr nz,ReadyNextEnemy          ;already set, and move onto next enemy slot if set
        ld a,(ix);lday Enemy_CollisionBits,y
        or (hl);orax SetBitsMask,x           ;if the bit is not set, set it now
        ld (ix),a;stay Enemy_CollisionBits,y
YesEC:  ;push iy ;не помогает
        ;ly заменяет SCRATCHPAD+$01!!!
       if Z80OPT2bug==0
        ld a,c
        ld c,e
        ld e,a ;почему-то порядок влияет! иначе черепахи не сталкиваются друг об друга
       endif
        call ProcEnemyCollisions     ;react according to the nature of collision ;портит x,y
        ;pop iy
        jp ReadyNextEnemy          ;move onto next enemy slot

NoEnemyCollision:
        ld hl,ClearBitsMask
        add hl,de;bc
        ld a,(hl)
        ld hl,Enemy_CollisionBits
        add hl,bc;de
      ;lday Enemy_CollisionBits,y     ;load first enemy's collision-related bits
      and (hl) ;andx ClearBitsMask,x           ;clear bit connected to second enemy
      ld (hl),a ;stay Enemy_CollisionBits,y     ;then move onto next enemy slot

ReadyNextEnemy:
     ;pla              ;get first enemy's bounding box offset from the stack
     ld e,hy ;tay              ;use as Y again
      ld c,ly;ldx SCRATCHPAD+$01          ;get and decrement second enemy's object buffer offset
ReadyNextEnemy_fast:
      dec c
      jp p,ECLoop       ;loop until all enemy slots have been checked

ExitECRoutine:
      ld hl,ObjectOffset
      ld c,(hl) ;get enemy object buffer offset
      ret              ;leave
      
       else ;~Z80

        lda FrameCounter            ;check counter for d0 set
        lsr
        bcc ExSFN                   ;if d0 not set, leave
        lda AreaType
         checka
        beq ExSFN                   ;if water area type, leave
        ldax Enemy_ID,x
        cmpn ++$15                    ;if enemy object =>  $15, branch to leave
              cmpcy
        bcs ExitECRoutine
        cmpn ++Lakitu                 ;if lakitu, branch to leave
        beq ExitECRoutine
        cmpn ++PiranhaPlant           ;if piranha plant, branch to leave
        beq ExitECRoutine
        ldax EnemyOffscrBitsMasked,x ;if masked offscreen bits nonzero, branch to leave
         checka
        bne ExitECRoutine
        jsr GetEnemyBoundBoxOfs     ;otherwise, do sub, get appropriate bounding box offset for
        dex                         ;first enemy we're going to compare, then decrement for second
        bmi ExitECRoutine           ;branch to leave if there are no other enemies
ECLoop: stx SCRATCHPAD+$01                     ;save enemy object buffer offset for second enemy here
        tya                         ;save first enemy's bounding box offset to stack
        pha
        ldax Enemy_Flag,x            ;check enemy object enable flag
         checka
        beq ReadyNextEnemy          ;branch if flag not set
        ldax Enemy_ID,x
        cmpn ++$15                    ;check for enemy object =>  $15
              cmpcy
        bcs ReadyNextEnemy          ;branch if true
        cmpn ++Lakitu
        beq ReadyNextEnemy          ;branch if enemy object is lakitu
        cmpn ++PiranhaPlant
        beq ReadyNextEnemy          ;branch if enemy object is piranha plant
        ldax EnemyOffscrBitsMasked,x
         checka
        bne ReadyNextEnemy          ;branch if masked offscreen bits set
        txa                         ;get second enemy object's bounding box offset
        asl                         ;multiply by four, then add four
        asl
        clc
        adcn ++$04
        tax                         ;use as new contents of X
        jsr SprObjectCollisionCore  ;do collision detection using the two enemies here
        ldx ObjectOffset            ;use first enemy offset for X
        ldy SCRATCHPAD+$01                     ;use second enemy offset for Y
        bcc NoEnemyCollision        ;if carry clear, no collision, branch ahead of this
        ldax Enemy_State,x
        oray Enemy_State,y           ;check both enemy states for d7 set
        andn ++%10000000
        bne YesEC                   ;branch if at least one of them is set
        lday Enemy_CollisionBits,y   ;load first enemy's collision-related bits
        andx SetBitsMask,x           ;check to see if bit connected to second enemy is
        bne ReadyNextEnemy          ;already set, and move onto next enemy slot if set
        lday Enemy_CollisionBits,y
        orax SetBitsMask,x           ;if the bit is not set, set it now
        stay Enemy_CollisionBits,y
YesEC:  jsr ProcEnemyCollisions     ;react according to the nature of collision
        jmp ReadyNextEnemy          ;move onto next enemy slot

NoEnemyCollision:
      lday Enemy_CollisionBits,y     ;load first enemy's collision-related bits
      andx ClearBitsMask,x           ;clear bit connected to second enemy
      stay Enemy_CollisionBits,y     ;then move onto next enemy slot

ReadyNextEnemy:
      pla              ;get first enemy's bounding box offset from the stack
      tay              ;use as Y again
      ldx SCRATCHPAD+$01          ;get and decrement second enemy's object buffer offset
      dex
      bpl ECLoop       ;loop until all enemy slots have been checked

ExitECRoutine:
      ldx ObjectOffset ;get enemy object buffer offset
      rts              ;leave
        endif
      
ProcEnemyCollisions:
;ly заменяет SCRATCHPAD+$01!!!
      lday Enemy_State,y        ;check both enemy states for d5 set
      orax Enemy_State,x
      andn ++%00100000           ;if d5 is set in either state, or both, branch
      bne ExitProcessEColl     ;to leave and do nothing else at this point
      ldax Enemy_State,x
      cmpn ++$06                 ;if second enemy state <  $06, branch elsewhere
              cmpcy
      bcc ProcSecondEnemyColl
      ldax Enemy_ID,x           ;check second enemy identifier for hammer bro
      cmpn ++HammerBro           ;if hammer bro found in alt state, branch to leave
      beq ExitProcessEColl
      lday Enemy_State,y        ;check first enemy state for d7 set
      asl
      bcc ShellCollisions      ;branch if d7 is clear
      ldan ++$06
      jsr SetupFloateyNumber   ;award 1000 points for killing enemy
      jsr ShellOrBlockDefeat   ;then kill enemy, then load
     if Z80OPT2
      ld e,ly;ldy SCRATCHPAD+$01                  ;original offset of second enemy
     else
      ldy SCRATCHPAD+$01                  ;original offset of second enemy
     endif

ShellCollisions:
      tya                      ;move Y to X
      tax
      jsr ShellOrBlockDefeat   ;kill second enemy
      ldx ObjectOffset
      ldax ShellChainCounter,x  ;get chain counter for shell
      clc
      adcn ++$04                 ;add four to get appropriate point offset
     if Z80OPT2
      ld c,ly;ldx SCRATCHPAD+$01
     else
      ldx SCRATCHPAD+$01
     endif
      jsr SetupFloateyNumber   ;award appropriate number of points for second enemy
      ldx ObjectOffset         ;load original offset of first enemy
      incx ShellChainCounter,x  ;increment chain counter for additional enemies

ExitProcessEColl:
      rts                      ;leave!!!

ProcSecondEnemyColl:
      lday Enemy_State,y        ;if first enemy state <  $06, branch elsewhere
      cmpn ++$06
              cmpcy
      bcc MoveEOfs
      lday Enemy_ID,y           ;check first enemy identifier for hammer bro
      cmpn ++HammerBro           ;if hammer bro found in alt state, branch to leave
      beq ExitProcessEColl
      jsr ShellOrBlockDefeat   ;otherwise, kill first enemy
     if Z80OPT2
      ld e,ly;ldy SCRATCHPAD+$01
     else
      ldy SCRATCHPAD+$01
     endif
      lday ShellChainCounter,y  ;get chain counter for shell
      clc
      adcn ++$04                 ;add four to get appropriate point offset
      ldx ObjectOffset
      jsr SetupFloateyNumber   ;award appropriate number of points for first enemy
     if Z80OPT2
      ld c,ly;ldx SCRATCHPAD+$01                  ;load original offset of second enemy
     else
      ldx SCRATCHPAD+$01                  ;load original offset of second enemy
     endif
      incx ShellChainCounter,x  ;increment chain counter for additional enemies
      rts                      ;leave!!!

MoveEOfs:
      tya                      ;move Y ($01) to X
      tax
      jsr EnemyTurnAround      ;do the sub here using value from $01
      ldx ObjectOffset         ;then do it again using value from $08

EnemyTurnAround:
       ldax Enemy_ID,x           ;check for specific enemies
       cmpn ++PiranhaPlant
       beq ExTA                 ;if piranha plant, leave
       cmpn ++Lakitu
       beq ExTA                 ;if lakitu, leave
       cmpn ++HammerBro
       beq ExTA                 ;if hammer bro, leave
       cmpn ++Spiny
       beq RXSpd                ;if spiny, turn it around
       cmpn ++GreenParatroopaJump
       beq RXSpd                ;if green paratroopa, turn it around
       cmpn ++$07
              cmpcy
       bcs ExTA                 ;if any OTHER enemy object =>  $07, leave
RXSpd: ldax Enemy_X_Speed,x      ;load horizontal speed
       eorn ++$ff                 ;get two's compliment for horizontal speed
       tay
       iny
       styx Enemy_X_Speed,x      ;store as new horizontal speed
       ldax Enemy_MovingDir,x
       eorn ++%00000011           ;invert moving direction and store, then leave
       stax Enemy_MovingDir,x    ;thus effectively turning the enemy around
ExTA:  rts                      ;leave!!!

;-------------------------------------------------------------------------------------
;$00 - vertical position of platform

LargePlatformCollision:
       ldan ++$ff                     ;save value here
       stax PlatformCollisionFlag,x
       lda TimerControl             ;check master timer control
         checka
       bne ExLPC                    ;if set, branch to leave
       ldax Enemy_State,x            ;if d7 set in object state,
         checka
       bmi ExLPC                    ;branch to leave
       ldax Enemy_ID,x
       cmpn ++$24                     ;check enemy object identifier for
       bne ChkForPlayerC_LargeP     ;balance platform, branch if not found
       ldax Enemy_State,x
       tax                          ;set state as enemy offset here
       jsr ChkForPlayerC_LargeP     ;perform code with state offset, then original offset, in X

ChkForPlayerC_LargeP:
       jsr CheckPlayerVertical      ;figure out if player is below a certain point
       bcs ExLPC                    ;or offscreen, branch to leave if true
       txa
       jsr GetEnemyBoundBoxOfsArg   ;get bounding box offset in Y
       ldax Enemy_Y_Position,x       ;store vertical coordinate in
       sta SCRATCHPAD+$00                      ;temp variable for now
       txa                          ;send offset we're on to the stack
       pha
       jsr PlayerCollisionCore      ;do player-to-platform collision detection
       plakeepcy                          ;retrieve offset from the stack
       tax
       bcc ExLPC                    ;if no collision, branch to leave
       jsr ProcLPlatCollisions      ;otherwise collision, perform sub
ExLPC: ldx ObjectOffset             ;get enemy object buffer offset and leave
       rts

;--------------------------------
;$00 - counter for bounding boxes

SmallPlatformCollision:
      lda TimerControl             ;if master timer control set,
         checka
      bne ExSPC                    ;branch to leave
      stax PlatformCollisionFlag,x  ;otherwise initialize collision flag
      jsr CheckPlayerVertical      ;do a sub to see if player is below a certain point
      bcs ExSPC                    ;or entirely offscreen, and branch to leave if true
      ldan ++$02
      sta SCRATCHPAD+$00                      ;load counter here for 2 bounding boxes

ChkSmallPlatLoop:
      ldx ObjectOffset           ;get enemy object offset
      jsr GetEnemyBoundBoxOfs    ;get bounding box offset in Y
      andn ++%00000010             ;if d1 of offscreen lower nybble bits was set
      bne ExSPC                  ;then branch to leave
      lday BoundingBox_UL_YPos,y  ;check top of platform's bounding box for being
      cmpn ++$20                   ;above a specific point
              cmpcy
      bcc MoveBoundBox           ;if so, branch, don't do collision detection
      jsr PlayerCollisionCore    ;otherwise, perform player-to-platform collision detection
      bcs ProcSPlatCollisions    ;skip ahead if collision

MoveBoundBox:
       lday BoundingBox_UL_YPos,y  ;move bounding box vertical coordinates
       clc                        ;128 pixels downwards
       adcn ++$80
       stay BoundingBox_UL_YPos,y
       lday BoundingBox_DR_YPos,y
       clc
       adcn ++$80
       stay BoundingBox_DR_YPos,y
       deci SCRATCHPAD+$00                    ;decrement counter we set earlier
       bne ChkSmallPlatLoop       ;loop back until both bounding boxes are checked
ExSPC: ldx ObjectOffset           ;get enemy object buffer offset, then leave
       rts

;--------------------------------

ProcSPlatCollisions:
      ldx ObjectOffset             ;return enemy object buffer offset to X, then continue

ProcLPlatCollisions:
      lday BoundingBox_DR_YPos,y    ;get difference by subtracting the top
      secsub                          ;of the player's bounding box from the bottom
      sbci BoundingBox_UL_YPos      ;of the platform's bounding box
      cmpn ++$04                     ;if difference too large or negative,
              cmpcy
      bcs ChkForTopCollision       ;branch, do not alter vertical speed of player
      lda Player_Y_Speed           ;check to see if player's vertical speed is moving down
         checka
      bpl ChkForTopCollision       ;if so, don't mess with it
      ldan ++$01                     ;otherwise, set vertical
      sta Player_Y_Speed           ;speed of player to kill jump

ChkForTopCollision:
      lda BoundingBox_DR_YPos      ;get difference by subtracting the top
      secsub                          ;of the platform's bounding box from the bottom
      sbcy BoundingBox_UL_YPos,y    ;of the player's bounding box
      cmpn ++$06
              cmpcy
      bcs PlatformSideCollisions   ;if difference not close enough, skip all of this
      lda Player_Y_Speed
         checka
      bmi PlatformSideCollisions   ;if player's vertical speed moving upwards, skip this
      lda SCRATCHPAD+$00                      ;get saved bounding box counter from earlier
      ldyx Enemy_ID,x
      cpyn ++$2b                     ;if either of the two small platform objects are found,
      beq SetCollisionFlag         ;regardless of which one, branch to use bounding box counter
      cpyn ++$2c                     ;as contents of collision flag
      beq SetCollisionFlag
      txa                          ;otherwise use enemy object buffer offset

SetCollisionFlag: ;почему сюда не попадаем???
      ldx ObjectOffset             ;get enemy object buffer offset
      stax PlatformCollisionFlag,x  ;save either bounding box counter or enemy offset here
      ldan ++$00
      sta Player_State             ;set player state to normal then leave
      rts

PlatformSideCollisions:
         ldan ++$01                   ;set value here to indicate possible horizontal
         sta SCRATCHPAD+$00                    ;collision on left side of platform
         lda BoundingBox_DR_XPos    ;get difference by subtracting platform's left edge
         secsub                        ;from player's right edge
         sbcy BoundingBox_UL_XPos,y
         cmpn ++$08                   ;if difference close enough, skip all of this
              cmpcy
         bcc SideC
         inci SCRATCHPAD+$00                    ;otherwise increment value set here for right side collision
         lday BoundingBox_DR_XPos,y  ;get difference by subtracting player's left edge
         clc                        ;from platform's right edge
         sbci BoundingBox_UL_XPos
         cmpn ++$09                   ;if difference not close enough, skip subroutine
              cmpcy
         bcs NoSideC                ;and instead branch to leave (no collision)
SideC:   jsr ImpedePlayerMove       ;deal with horizontal collision
NoSideC: ldx ObjectOffset           ;return with enemy object buffer offset
         rts

;-------------------------------------------------------------------------------------

PlayerPosSPlatData:
      .db $80, $00

PositionPlayerOnS_Plat:
      tay                        ;use bounding box counter saved in collision flag
      ldax Enemy_Y_Position,x     ;for offset
      clc                        ;add positioning data using offset to the vertical
      adcy PlayerPosSPlatData-1,y ;coordinate
      jr PositionPlayerOnVPlat_go;.db $2c                    ;BIT instruction opcode

PositionPlayerOnVPlat:
         ldax Enemy_Y_Position,x    ;get vertical coordinate
PositionPlayerOnVPlat_go
         ldy GameEngineSubroutine
         cpyn ++$0b                  ;if certain routine being executed on this frame,
         beq ExPlPos               ;skip all of this
         ldyx Enemy_Y_HighPos,x
         cpyn ++$01                  ;if vertical high byte offscreen, skip this
         bne ExPlPos
         secsub                       ;subtract 32 pixels from vertical coordinate
         sbcn ++$20                  ;for the player object's height
         sta Player_Y_Position     ;save as player's new vertical coordinate
         tya
         sbcn ++$00                  ;subtract borrow and store as player's
         sta Player_Y_HighPos      ;new vertical high byte
         ldan ++$00
         sta Player_Y_Speed        ;initialize vertical speed and low byte of force
         sta Player_Y_MoveForce    ;and then leave
ExPlPos: rts

;-------------------------------------------------------------------------------------

CheckPlayerVertical:
       lda Player_OffscreenBits  ;if player object is completely offscreen
       cmpn ++$f0                  ;vertically, leave this routine
              cmpcy
       bcs ExCPV
       ldy Player_Y_HighPos      ;if player high vertical byte is not
       dey                       ;within the screen, leave this routine
       bne ExCPV
       lda Player_Y_Position     ;if on the screen, check to see how far down
       cmpn ++$d0                  ;the player is vertically
              cmpcy
ExCPV: rts

;-------------------------------------------------------------------------------------

GetEnemyBoundBoxOfs:
      lda ObjectOffset         ;get enemy object buffer offset

GetEnemyBoundBoxOfsArg:
      asl                      ;multiply A by four, then add four
      asl                      ;to skip player's bounding box
      clc
      adcn ++$04
      tay                      ;send to Y
      lda Enemy_OffscreenBits  ;get offscreen bits for enemy object
      andn ++%00001111           ;save low nybble
      cmpn ++%00001111           ;check for all bits set
              cmpcy
      rts

;-------------------------------------------------------------------------------------
;$00-$01 - used to hold many values, essentially temp variables
;$04 - holds lower nybble of vertical coordinate from block buffer routine
;$eb - used to hold block buffer adder

PlayerBGUpperExtent:
      .db $20, $10

PlayerBGCollision:
          lda DisableCollisionDet   ;if collision detection disabled flag set,
         checka
          bne ExPBGCol              ;branch to leave
          lda GameEngineSubroutine
          cmpn ++$0b                  ;if running routine ++11 or $0b
          beq ExPBGCol              ;branch to leave
          cmpn ++$04
              cmpcy
          bcc ExPBGCol              ;if running routines $00-$03 branch to leave
          ldan ++$01                  ;load default player state for swimming
          ldy SwimmingFlag          ;if swimming flag set,
         checky
          bne SetPSte               ;branch ahead to set default state
          lda Player_State          ;if player in normal state,
         checka
          beq SetFallS              ;branch to set default state for falling
          cmpn ++$03
          bne ChkOnScr              ;if in any other state besides climbing, skip to next part
SetFallS: ldan ++$02                  ;load default player state for falling
SetPSte:  sta Player_State          ;set whatever player state is appropriate
ChkOnScr: lda Player_Y_HighPos
          cmpn ++$01                  ;check player's vertical high byte for still on the screen
          bne ExPBGCol              ;branch to leave if not
          ldan ++$ff
          sta Player_CollisionBits  ;initialize player's collision flag
          lda Player_Y_Position
          cmpn ++$cf                  ;check player's vertical coordinate
              cmpcy
          bcc ChkCollSize           ;if not too close to the bottom of screen, continue
ExPBGCol: rts                       ;otherwise leave

ChkCollSize:
         ldyn ++$02                    ;load default offset
         lda CrouchingFlag
         checka
         bne GBBAdr                  ;if player crouching, skip ahead
         lda PlayerSize
         checka
         bne GBBAdr                  ;if player small, skip ahead
         dey                         ;otherwise decrement offset for big player not crouching
         lda SwimmingFlag
         checka
         bne GBBAdr                  ;if swimming flag set, skip ahead
         dey                         ;otherwise decrement offset
GBBAdr:  lday BlockBufferAdderData,y  ;get value using offset ;0,7,14
         sta SCRATCHPAD+$eb                     ;store value here
         tay                         ;put value into Y, as offset for block buffer routine
         ldx PlayerSize              ;get player's size as offset
         lda CrouchingFlag
         checka
         beq HeadChk                 ;if player not crouching, branch ahead
         inx                         ;otherwise increment size as offset
HeadChk: lda Player_Y_Position       ;get player's vertical coordinate ;у нас сначала $b0???
         cmpx PlayerBGUpperExtent,x   ;compare with upper extent value based on offset ;$20 или $10
              cmpcy
         bcc DoFootCheck             ;if player is too high, skip this part
         jsr BlockBufferColli_Head   ;do player-to-bg collision detection on top of
         beq DoFootCheck             ;player, and branch if nothing above player's head
         jsr CheckForCoinMTiles      ;check to see if player touched coin with their head
         bcs AwardTouchedCoin        ;if so, branch to some other part of code
         ldy Player_Y_Speed          ;check player's vertical speed
         checky
         bpl DoFootCheck             ;if player not moving upwards, branch elsewhere
         ldy SCRATCHPAD+$04                     ;check lower nybble of vertical coordinate returned
         cpyn ++$04                    ;from collision detection routine
              cmpcy
         bcc DoFootCheck             ;if low nybble <  4, branch
         jsr CheckForSolidMTiles     ;check to see what player's head bumped on
         bcs SolidOrClimb            ;if player collided with solid metatile, branch
         ldy AreaType                ;otherwise check area type
         checky
         beq NYSpd                   ;if water level, branch ahead
         ldy BlockBounceTimer        ;if block bounce timer not expired,
         checky
         bne NYSpd                   ;branch ahead, do not process collision
         jsr PlayerHeadCollision     ;otherwise do a sub to process collision
         jmp DoFootCheck             ;jump ahead to skip these other parts here

SolidOrClimb:
       cmpn ++$26               ;if climbing metatile,
       beq NYSpd              ;branch ahead and do not play sound
       ldan ++Sfx_Bump
       sta Square1SoundQueue  ;otherwise load bump sound
NYSpd: ldan ++$01               ;set player's vertical speed to nullify
       sta Player_Y_Speed     ;jump or swim

DoFootCheck:
      ldy SCRATCHPAD+$eb                    ;get block buffer adder offset ;0,7,14?
      lda Player_Y_Position
      cmpn ++$cf                   ;check to see how low player is
              cmpcy
      bcs DoPlayerSideCheck      ;if player is too far down on screen, skip all of this
      jsr BlockBufferColli_Feet  ;do player-to-bg collision detection on bottom left of player
      jsr CheckForCoinMTiles     ;check to see if player touched coin with their left foot
      bcs AwardTouchedCoin       ;if so, branch to some other part of code
      pha                        ;save bottom left metatile to stack
      jsr BlockBufferColli_Feet  ;do player-to-bg collision detection on bottom right of player
      sta SCRATCHPAD+$00                    ;save bottom right metatile here
      pla
      sta SCRATCHPAD+$01                    ;pull bottom left metatile and save here
         checka
      bne ChkFootMTile           ;if anything here, skip this part
      lda SCRATCHPAD+$00                    ;otherwise check for anything in bottom right metatile
         checka
      beq DoPlayerSideCheck      ;and skip ahead if not
      jsr CheckForCoinMTiles     ;check to see if player touched coin with their right foot
      bcc ChkFootMTile           ;if not, skip unconditional jump and continue code

AwardTouchedCoin:
      jmp HandleCoinMetatile     ;follow the code to erase coin and award to player 1 coin

ChkFootMTile:
          jsr CheckForClimbMTiles    ;check to see if player landed on climbable metatiles
          bcs DoPlayerSideCheck      ;if so, branch
          ldy Player_Y_Speed         ;check player's vertical speed
         checky
          bmi DoPlayerSideCheck      ;if player moving upwards, branch
          cmpn ++$c5
          bne ContChk                ;if player did not touch axe, skip ahead
          jmp HandleAxeMetatile      ;otherwise jump to set modes of operation
ContChk:  jsr ChkInvisibleMTiles     ;do sub to check for hidden coin or 1-up blocks
          beq DoPlayerSideCheck      ;if either found, branch
          ldy JumpspringAnimCtrl     ;if jumpspring animating right now,
         checky
          bne InitSteP               ;branch ahead
          ldy SCRATCHPAD+$04                    ;check lower nybble of vertical coordinate returned
          cpyn ++$05                   ;from collision detection routine
              cmpcy
          bcc LandPlyr               ;if lower nybble <  5, branch
          lda Player_MovingDir
          sta SCRATCHPAD+$00                    ;use player's moving direction as temp variable
          jmp ImpedePlayerMove       ;jump to impede player's movement in that direction
LandPlyr: jsr ChkForLandJumpSpring   ;do sub to check for jumpspring metatiles and deal with it
          ldan ++$f0
          andi Player_Y_Position      ;mask out lower nybble of player's vertical position
          sta Player_Y_Position      ;and store as new vertical position to land player properly
          jsr HandlePipeEntry        ;do sub to process potential pipe entry
          ldan ++$00
          sta Player_Y_Speed         ;initialize vertical speed and fractional
          sta Player_Y_MoveForce     ;movement force to stop player's vertical movement
          sta StompChainCounter      ;initialize enemy stomp counter
InitSteP: ldan ++$00
          sta Player_State           ;set player's state to normal

DoPlayerSideCheck:
      ldy SCRATCHPAD+$eb       ;get block buffer adder offset ;какое исходное состояние???0,7,14?
      iny
      iny           ;increment offset 2 bytes to use adders for side collisions ;сначала проверяем справа??? (а в таблицах ббоксов выглядит как левая сторона???)
      ldan ++$02      ;set value here to be used as counter
      sta SCRATCHPAD+$00

SideCheckLoop:
       iny                       ;move onto the next one ;начинаем со смещения 3 в таблицах ббоксов, потом 4,5,6???
       sty SCRATCHPAD+$eb                   ;store it
       lda Player_Y_Position
       cmpn ++$20                  ;check player's vertical position
              cmpcy
       bcc BHalf                 ;if player is in status bar area, branch ahead to skip this part
       cmpn ++$e4
              cmpcy
       bcs ExSCH                 ;branch to leave if player is too far down
       jsr BlockBufferColli_Side ;do player-to-bg collision detection on one half of player
       beq BHalf                 ;branch ahead if nothing found
       cmpn ++$1c                  ;otherwise check for pipe metatiles
       beq BHalf                 ;if collided with sideways pipe (top), branch ahead
       cmpn ++$6b
       beq BHalf                 ;if collided with water pipe (top), branch ahead
       jsr CheckForClimbMTiles   ;do sub to see if player bumped into anything climbable
       bcc CheckSideMTiles       ;if not, branch to alternate section of code
BHalf: ldy SCRATCHPAD+$eb                   ;load block adder offset
       iny                       ;increment it ;???
       lda Player_Y_Position     ;get player's vertical position
       cmpn ++$08
              cmpcy
       bcc ExSCH                 ;if too high, branch to leave
       cmpn ++$d0
              cmpcy
       bcs ExSCH                 ;if too low, branch to leave
       jsr BlockBufferColli_Side ;do player-to-bg collision detection on other half of player
       bne CheckSideMTiles       ;if something found, branch
       deci SCRATCHPAD+$00                   ;otherwise decrement counter ;учитывается в ImpedePlayerMove (левая сторона=1??? или наоборот???)
       bne SideCheckLoop         ;run code until both sides of player are checked ;если закомментировать, то не помогает войти в трубу сразу, но теперь проходит кирпичи вправо насквозь
ExSCH: rts                       ;leave

CheckSideMTiles:
          jsr ChkInvisibleMTiles     ;check for hidden or coin 1-up blocks
          beq ExCSM                  ;branch to leave if either found
          jsr CheckForClimbMTiles    ;check for climbable metatiles
          bcc ContSChk               ;if not found, skip and continue with code
          jmp HandleClimbing         ;otherwise jump to handle climbing
ContSChk: jsr CheckForCoinMTiles     ;check to see if player touched coin
          bcs HandleCoinMetatile     ;if so, execute code to erase coin and award to player 1 coin
          jsr ChkJumpspringMetatiles ;check for jumpspring metatiles
          bcc ChkPBtm                ;if not found, branch ahead to continue cude
          lda JumpspringAnimCtrl     ;otherwise check jumpspring animation control
         checka
          bne ExCSM                  ;branch to leave if set
          jmp StopPlayerMove         ;otherwise jump to impede player's movement
ChkPBtm:  ldy Player_State           ;get player's state
	;jr $ ;столкнулись справа с верхом трубы, идущей вправо ($1c)
          cpyn ++$00                   ;check for player's state set to normal
          bne StopPlayerMove         ;if not, branch to impede player's movement ;не помогает войти в трубу сразу ;чему равен (SCRATCHPAD+$00)? (левая сторона=1???)
          ldy PlayerFacingDir        ;get player's facing direction
          dey
          bne StopPlayerMove         ;if facing left, branch to impede movement
          cmpn ++$6c                   ;otherwise check for pipe metatiles
          beq PipeDwnS               ;if collided with sideways pipe (bottom), branch
          cmpn ++$1f                   ;if collided with water pipe (bottom), continue
          bne StopPlayerMove         ;otherwise branch to impede player's movement
PipeDwnS: lda Player_SprAttrib       ;check player's attributes
	;jr $ ;сюда попадаем не сразу, как только встали снизу у трубы, а после нажатия вправо там - это портит дему
         checka
          bne PlyrPipe               ;if already set, branch, do not play sound again
          ldyn ++Sfx_PipeDown_Injury
          sty Square1SoundQueue      ;otherwise load pipedown/injury sound
PlyrPipe: oran ++%00100000
          sta Player_SprAttrib       ;set background priority bit in player attributes
          lda Player_X_Position
          andn ++%00001111             ;get lower nybble of player's horizontal coordinate
          beq ChkGERtn               ;if at zero, branch ahead to skip this part
          ldyn ++$00                   ;set default offset for timer setting data
          lda ScreenLeft_PageLoc     ;load page location for left side of screen
         checka
          beq SetCATmr               ;if at page zero, use default offset
          iny                        ;otherwise increment offset
SetCATmr: lday AreaChangeTimerData,y  ;set timer for change of area as appropriate
          sta ChangeAreaTimer
ChkGERtn: lda GameEngineSubroutine   ;get number of game engine routine running
          cmpn ++$07
          beq ExCSM                  ;if running player entrance routine or
          cmpn ++$08                   ;player control routine, go ahead and branch to leave
          bne ExCSM
          ldan ++$02
          sta GameEngineSubroutine   ;otherwise set sideways pipe entry routine to run
          rts                        ;and leave

;--------------------------------
;$02 - high nybble of vertical coordinate from block buffer
;$04 - low nybble of horizontal coordinate from block buffer
;$06-$07 - block buffer address

StopPlayerMove:
;если проверяем коллизию справа, то (SCRATCHPAD+$00) != 1!!! или наоборот?
       jsr ImpedePlayerMove      ;stop player's movement
ExCSM: rts                       ;leave
      
AreaChangeTimerData:
      .db $a0, $34

HandleCoinMetatile:
        ;jr $
      jsr ErACM             ;do sub to erase coin metatile from block buffer
      inci CoinTallyFor1Ups  ;increment coin tally used for 1-up blocks
      jmp GiveOneCoin       ;update coin amount and tally on the screen

HandleAxeMetatile:
       ldan ++$00
       sta OperMode_Task   ;reset secondary mode
       ldan ++$02
       sta OperMode        ;set primary mode to autoctrl mode
       ldan ++$18
       sta Player_X_Speed  ;set horizontal speed and continue to erase axe metatile
ErACM: ldy SCRATCHPAD+$02             ;load vertical high nybble offset for block buffer
       ldan ++$00            ;load blank metatile
       stayindirect (SCRATCHPAD+$06),y         ;store to remove old contents from block buffer
       jmp RemoveCoin_Axe  ;update the screen accordingly

;--------------------------------
;$02 - high nybble of vertical coordinate from block buffer
;$04 - low nybble of horizontal coordinate from block buffer
;$06-$07 - block buffer address

ClimbXPosAdder:
      .db $f9, $07

ClimbPLocAdder:
      .db $ff, $00

FlagpoleYPosData:
      .db $18, $22, $50, $68, $90

HandleClimbing:
      ldy SCRATCHPAD+$04            ;check low nybble of horizontal coordinate returned from
      cpyn ++$06           ;collision detection routine against certain values, this
              cmpcy
      bcc ExHC           ;makes actual physical part of vine or flagpole thinner
      cpyn ++$0a           ;than 16 pixels
              cmpcy
      bcc ChkForFlagpole
ExHC: rts                ;leave if too far left or too far right

ChkForFlagpole:
      cmpn ++$24               ;check climbing metatiles
      beq FlagpoleCollision  ;branch if flagpole ball found
      cmpn ++$25
      bne VineCollision      ;branch to alternate code if flagpole shaft not found

FlagpoleCollision:
      lda GameEngineSubroutine
      cmpn ++$05                  ;check for end-of-level routine running
      beq PutPlayerOnVine       ;if running, branch to end of climbing code
      ldan ++$01
      sta PlayerFacingDir       ;set player's facing direction to right
      inci ScrollLock            ;set scroll lock flag
      lda GameEngineSubroutine
      cmpn ++$04                  ;check for flagpole slide routine running
      beq RunFR                 ;if running, branch to end of flagpole code here
      ldan ++BulletBill_CannonVar ;load identifier for bullet bills (cannon variant)
      jsr KillEnemies           ;get rid of them
      ldan ++Silence
      sta EventMusicQueue       ;silence music
      lsr
      sta FlagpoleSoundQueue    ;load flagpole sound into flagpole sound queue
      ldxn ++$04                  ;start at end of vertical coordinate data
      lda Player_Y_Position
      sta FlagpoleCollisionYPos ;store player's vertical coordinate here to be used later

ChkFlagpoleYPosLoop:
       cmpx FlagpoleYPosData,x    ;compare with current vertical coordinate data
              cmpcy
       bcs MtchF                 ;if player's =>  current, branch to use current offset
       dex                       ;otherwise decrement offset to use 
       bne ChkFlagpoleYPosLoop   ;do this until all data is checked (use last one if all checked)
MtchF: stx FlagpoleScore         ;store offset here to be used later
RunFR: ldan ++$04
       sta GameEngineSubroutine  ;set value to run flagpole slide routine
       jmp PutPlayerOnVine       ;jump to end of climbing code

VineCollision:
      cmpn ++$26                  ;check for climbing metatile used on vines
      bne PutPlayerOnVine
      lda Player_Y_Position     ;check player's vertical coordinate
      cmpn ++$20                  ;for being in status bar area
              cmpcy
      bcs PutPlayerOnVine       ;branch if not that far up
      ldan ++$01
      sta GameEngineSubroutine  ;otherwise set to run autoclimb routine next frame

PutPlayerOnVine:
         ldan ++$03                ;set player state to climbing
         sta Player_State
         ldan ++$00                ;nullify player's horizontal speed
         sta Player_X_Speed      ;and fractional horizontal movement force
         sta Player_X_MoveForce ; (младшая часть X-координаты)
         lda Player_X_Position   ;get player's horizontal coordinate
         secsub
         sbci ScreenLeft_X_Pos    ;subtract from left side horizontal coordinate
         cmpn ++$10
              cmpcy
         bcs SetVXPl             ;if 16 or more pixels difference, do not alter facing direction
         ldan ++$02
         sta PlayerFacingDir     ;otherwise force player to face left
SetVXPl: ldy PlayerFacingDir     ;get current facing direction, use as offset
         lda SCRATCHPAD+$06                 ;get low byte of block buffer address
         asl
         asl                     ;move low nybble to high
         asl
         asl
         clc
         adcy ClimbXPosAdder-1,y  ;add pixels depending on facing direction
         sta Player_X_Position   ;store as player's horizontal coordinate
         lda SCRATCHPAD+$06                 ;get low byte of block buffer address again
         checka
         bne ExPVne              ;if not zero, branch
         lda ScreenRight_PageLoc ;load page location of right side of screen
         clc
         adcy ClimbPLocAdder-1,y  ;add depending on facing location
         sta Player_PageLoc      ;store as player's page location
ExPVne:  rts                     ;finally, we're done!

;--------------------------------

ChkInvisibleMTiles:
         cmpn ++$5f       ;check for hidden coin block
         beq ExCInvT    ;branch to leave if found
         cmpn ++$60       ;check for hidden 1-up block
ExCInvT: 
              cmpcy ;???
         rts            ;leave with zero flag set if either found

;--------------------------------
;$00-$01 - used to hold bottom right and bottom left metatiles (in that order)
;$00 - used as flag by ImpedePlayerMove to restrict specific movement

ChkForLandJumpSpring:
        jsr ChkJumpspringMetatiles  ;do sub to check if player landed on jumpspring
        bcc ExCJSp                  ;if carry not set, jumpspring not found, therefore leave
        ldan ++$70
        sta VerticalForce           ;otherwise set vertical movement force for player
        ldan ++$f9
        sta JumpspringForce         ;set default jumpspring force
        ldan ++$03
        sta JumpspringTimer         ;set jumpspring timer to be used later
        lsr
        sta JumpspringAnimCtrl      ;set jumpspring animation control to start animating
ExCJSp: rts                         ;and leave

ChkJumpspringMetatiles:
         cmpn ++$67      ;check for top jumpspring metatile
         beq JSFnd     ;branch to set carry if found
         cmpn ++$68      ;check for bottom jumpspring metatile
         clc           ;clear carry flag
         bne NoJSFnd   ;branch to use cleared carry if not found
JSFnd:   sec           ;set carry if found
NoJSFnd: rts           ;leave

HandlePipeEntry:
         lda Up_Down_Buttons       ;check saved controller bits from earlier
         andn ++%00000100            ;for pressing down
         beq ExPipeE               ;if not pressing down, branch to leave
         lda SCRATCHPAD+$00
         cmpn ++$11                  ;check right foot metatile for warp pipe right metatile
         bne ExPipeE               ;branch to leave if not found
         lda SCRATCHPAD+$01
         cmpn ++$10                  ;check left foot metatile for warp pipe left metatile
         bne ExPipeE               ;branch to leave if not found
         ldan ++$30
         sta ChangeAreaTimer       ;set timer for change of area
         ldan ++$03
         sta GameEngineSubroutine  ;set to run vertical pipe entry routine on next frame
         ldan ++Sfx_PipeDown_Injury
         sta Square1SoundQueue     ;load pipedown/injury sound
         ldan ++%00100000
         sta Player_SprAttrib      ;set background priority bit in player's attributes
         lda WarpZoneControl       ;check warp zone control
         checka
         beq ExPipeE               ;branch to leave if none found
         andn ++%00000011            ;mask out all but 2 LSB
         asl
         asl                       ;multiply by four
         tax                       ;save as offset to warp zone numbers (starts at left pipe)
         lda Player_X_Position     ;get player's horizontal position
         cmpn ++$60      
              cmpcy
         bcc GetWNum               ;if player at left, not near middle, use offset and skip ahead
         inx                       ;otherwise increment for middle pipe
         cmpn ++$a0      
              cmpcy
         bcc GetWNum               ;if player at middle, but not too far right, use offset and skip
         inx                       ;otherwise increment for last pipe
GetWNum: ldyx WarpZoneNumbers,x     ;get warp zone numbers
         dey                       ;decrement for use as world number
         sty WorldNumber           ;store as world number and offset
         ldxy WorldAddrOffsets,y    ;get offset to where this world's area offsets are
         ldax AreaAddrOffsets,x     ;get area offset based on world offset
         sta AreaPointer           ;store area offset here to be used to change areas
         ldan ++Silence
         sta EventMusicQueue       ;silence music
         ldan ++$00
         sta EntrancePage          ;initialize starting page number
         sta AreaNumber            ;initialize area number used for area address offset
         sta LevelNumber           ;initialize level number used for world display
         sta AltEntranceControl    ;initialize mode of entry
         inci Hidden1UpFlag         ;set flag for hidden 1-up blocks
         inci FetchNewGameTimerFlag ;set flag to load new game timer
ExPipeE: rts                       ;leave!!!

ImpedePlayerMove:
;если проверяем коллизию справа, то (SCRATCHPAD+$00) != 1!!! или наоборот??? портит (SCRATCHPAD+$00)
;устанавливает Player_CollisionBits, SideCollisionTimer, двигает X и XSpeed
       ldan ++$00                  ;initialize value here
       ldy Player_X_Speed        ;get player's horizontal speed
       ldx SCRATCHPAD+$00                   ;check value set earlier for
       dex                       ;left side collision
      ;jr RImpd
      bne RImpd                 ;if right side collision, skip this part ;если jr RImpd, то в 53672 проходит в правую трубу правильно, но входит влево в стены и не останавливается на замке!!!???
;проверяли справа???
       inx                       ;return value to X
       cpyn ++$00                  ;if player moving to the left,
       bmi ExIPM                 ;branch to invert bit and leave ;игрок столкнулся справа, но идёт влево - ничего не делаем
       ldan ++$ff                  ;otherwise load A with value to be used later (это сдвинет игрока влево на 1 пикс)
       jmp NXSpd                 ;and jump to affect movement
RImpd: ldxn ++$02                  ;return $02 to X
       cpyn ++$01                  ;if player moving to the right,
       bpl ExIPM                 ;branch to invert bit and leave
       ldan ++$01                  ;otherwise load A with value to be used here
NXSpd: ldyn ++$10
       sty SideCollisionTimer    ;set timer of some sort
       ldyn ++$00
       sty Player_X_Speed        ;nullify player's horizontal speed
       cmpn ++$00                  ;if value set in A not set to $ff,
       bpl PlatF                 ;branch ahead, do not decrement Y
       dey                       ;otherwise decrement Y now
PlatF: sty SCRATCHPAD+$00                   ;store Y as high bits of horizontal adder
       clc
       adci Player_X_Position     ;add contents of A to player's horizontal
       sta Player_X_Position     ;position to move player left or right
       lda Player_PageLoc
       adci SCRATCHPAD+$00                   ;add high bits and carry to
       sta Player_PageLoc        ;page location if necessary
ExIPM: txa                       ;invert contents of X
       eorn ++$ff ;1->fe, 2->fd
       andi Player_CollisionBits  ;mask out bit that was set here
       sta Player_CollisionBits  ;store to clear bit
       rts

;--------------------------------

SolidMTileUpperExt:
      .db $10, $61, $88, $c4

CheckForSolidMTiles:
;a=metatile
;out: CY=???
      jsr GetMTileAttrib        ;find appropriate offset based on metatile's 2 MSB
      cmpx SolidMTileUpperExt,x  ;compare current metatile with solid metatiles
       cmpcy
      rts

ClimbMTileUpperExt:
      .db $24, $6d, $8a, $c6

CheckForClimbMTiles:
;a=metatile
;out: CY=???
      jsr GetMTileAttrib        ;find appropriate offset based on metatile's 2 MSB
      cmpx ClimbMTileUpperExt,x  ;compare current metatile with climbable metatiles
       cmpcy
      rts

CheckForCoinMTiles:
;out: CY=1:touched coin
         cmpn ++$c2              ;check for regular coin
         beq CoinSd            ;branch if found
         cmpn ++$c3              ;check for underwater coin
         beq CoinSd            ;branch if found
         clc                   ;otherwise clear carry and leave
         rts
CoinSd:  ldan ++Sfx_CoinGrab
         sta Square2SoundQueue ;load coin grab sound and leave
        scf
         rts

GetMTileAttrib:
       tay            ;save metatile value into Y
       andn ++%11000000 ;mask out all but 2 MSB
       asl
       rol            ;shift and rotate d7-d6 to d1-d0
       rol
       tax            ;use as offset for metatile data
       tya            ;get original metatile value back
ExEBG: rts            ;leave

;-------------------------------------------------------------------------------------
;$06-$07 - address from block buffer routine

EnemyBGCStateData:
      .db $01, $01, $02, $02, $02, $05

EnemyBGCXSpdData:
      .db $10, $f0

EnemyToBGCollisionDet:
      ldax Enemy_State,x        ;check enemy state for d6 set
      andn ++%00100000
      bne ExEBG                ;if set, branch to leave
      jsr SubtEnemyYPos        ;otherwise, do a subroutine here
      bcc ExEBG                ;if enemy vertical coord + 62 <  68, branch to leave
      ldyx Enemy_ID,x
      cpyn ++Spiny               ;if enemy object is not spiny, branch elsewhere
      bne DoIDCheckBGColl
      ldax Enemy_Y_Position,x
      cmpn ++$25                 ;if enemy vertical coordinate <  36 branch to leave
              cmpcy
      bcc ExEBG

DoIDCheckBGColl:
       cpyn ++GreenParatroopaJump ;check for some other enemy object
       bne HBChk                ;branch if not found
       jmp EnemyJump            ;otherwise jump elsewhere
HBChk: cpyn ++HammerBro           ;check for hammer bro
       bne CInvu                ;branch if not found
       jmp HammerBroBGColl      ;otherwise jump elsewhere
CInvu: cpyn ++Spiny               ;if enemy object is spiny, branch
       beq YesIn
       cpyn ++PowerUpObject       ;if special power-up object, branch
       beq YesIn
       cpyn ++$07                 ;if enemy object => $07, branch to leave
              cmpcy
       bcs ExEBGChk
YesIn: jsr ChkUnderEnemy        ;if enemy object <  $07, or = $12 or $2e, do this sub
       bne HandleEToBGCollision ;if block underneath enemy, branch

NoEToBGCollision:
       jmp ChkForRedKoopa       ;otherwise skip and do something else

;--------------------------------
;$02 - vertical coordinate from block buffer routine

HandleEToBGCollision:
      jsr ChkForNonSolids       ;if something is underneath enemy, find out what
      beq NoEToBGCollision      ;if blank $26, coins, or hidden blocks, jump, enemy falls through
      cmpn ++$23
      bne LandEnemyProperly     ;check for blank metatile $23 and branch if not found
      ldy SCRATCHPAD+$02                   ;get vertical coordinate used to find block
      ldan ++$00                  ;store default blank metatile in that spot so we won't
      stayindirect (SCRATCHPAD+$06),y               ;trigger this routine accidentally again
      ldax Enemy_ID,x
      cmpn ++$15                  ;if enemy object =HIGH  $15, branch ahead
              cmpcy
      bcs ChkToStunEnemies
      cmpn ++Goomba               ;if enemy object not goomba, branch ahead of this routine
      bne GiveOEPoints
      jsr KillEnemyAboveBlock   ;if enemy object IS goomba, do this sub

GiveOEPoints:
      ldan ++$01                  ;award 100 points for hitting block beneath enemy
      jsr SetupFloateyNumber

ChkToStunEnemies:
          cmpn ++$09                   ;perform many comparisons on enemy object identifier
              cmpcy
          bcc SetStun      
          cmpn ++$11                   ;if the enemy object identifier is equal to the values
              cmpcy
          bcs SetStun                ;$09, $0e, $0f or $10, it will be modified, and not
          cmpn ++$0a                   ;modified if not any of those values, note that piranha plant will
              cmpcy
          bcc Demote                 ;always fail this test because A will still have vertical
          cmpn ++PiranhaPlant          ;coordinate from previous addition, also these comparisons
              cmpcy
          bcc SetStun                ;are only necessary if branching from $d7a1
Demote:   andn ++%00000001             ;erase all but LSB, essentially turning enemy object
          stax Enemy_ID,x             ;into green or red koopa troopa to demote them
SetStun:  ldax Enemy_State,x          ;load enemy state
          andn ++%11110000             ;save high nybble
          oran ++%00000010
          stax Enemy_State,x          ;set d1 of enemy state
          decx Enemy_Y_Position,x
          decx Enemy_Y_Position,x     ;subtract two pixels from enemy's vertical position
          ldax Enemy_ID,x
          cmpn ++Bloober               ;check for bloober object
          beq SetWYSpd
          ldan ++$fd                   ;set default vertical speed
          ldy AreaType
         checky
          bne SetNotW                ;if area type not water, set as speed, otherwise
SetWYSpd: ldan ++$ff                   ;change the vertical speed
SetNotW:  stax Enemy_Y_Speed,x        ;set vertical speed now
          ldyn ++$01
          jsr PlayerEnemyDiff        ;get horizontal difference between player and enemy object
          bpl ChkBBill               ;branch if enemy is to the right of player
          iny                        ;increment Y if not
ChkBBill: ldax Enemy_ID,x      
          cmpn ++BulletBill_CannonVar  ;check for bullet bill (cannon variant)
          beq NoCDirF
          cmpn ++BulletBill_FrenzyVar  ;check for bullet bill (frenzy variant)
          beq NoCDirF                ;branch if either found, direction does not change
          styx Enemy_MovingDir,x      ;store as moving direction
NoCDirF:  dey                        ;decrement and use as offset
          lday EnemyBGCXSpdData,y     ;get proper horizontal speed
          stax Enemy_X_Speed,x        ;and store, then leave
ExEBGChk: rts

;--------------------------------
;$04 - low nybble of vertical coordinate from block buffer routine

LandEnemyProperly:
       lda SCRATCHPAD+$04                 ;check lower nybble of vertical coordinate saved earlier
       secsub
       sbcn ++$08                ;subtract eight pixels
       cmpn ++$05                ;used to determine whether enemy landed from falling
              cmpcy
       bcs ChkForRedKoopa      ;branch if lower nybble in range of $0d-$0f before subtract
       ldax Enemy_State,x      
       andn ++%01000000          ;branch if d6 in enemy state is set
       bne LandEnemyInitState
       ldax Enemy_State,x
       asl                     ;branch if d7 in enemy state is not set
       bcc ChkLandedEnemyState
SChkA: jmp DoEnemySideCheck    ;if lower nybble LOW  $0d, d7 set but d6 not set, jump here

ChkLandedEnemyState:
           ldax Enemy_State,x         ;if enemy in normal state, branch back to jump here
         checka
           beq SChkA
           cmpn ++$05                  ;if in state used by spiny's egg
           beq ProcEnemyDirection    ;then branch elsewhere
           cmpn ++$03                  ;if already in state used by koopas and buzzy beetles
              cmpcy
           bcs ExSteChk              ;or in higher numbered state, branch to leave
           ldax Enemy_State,x         ;load enemy state again (why?)
           cmpn ++$02                  ;if not in $02 state (used by koopas and buzzy beetles)
           bne ProcEnemyDirection    ;then branch elsewhere
           ldan ++$10                  ;load default timer here
           ldyx Enemy_ID,x            ;check enemy identifier for spiny
           cpyn ++Spiny
           bne SetForStn             ;branch if not found
           ldan ++$00                  ;set timer for $00 if spiny
SetForStn: stax EnemyIntervalTimer,x  ;set timer here
           ldan ++$03                  ;set state here, apparently used to render
           stax Enemy_State,x         ;upside-down koopas and buzzy beetles
           jsr EnemyLanding          ;then land it properly
ExSteChk:  rts                       ;then leave

ProcEnemyDirection:
         ldax Enemy_ID,x            ;check enemy identifier for goomba
         cmpn ++Goomba               ;branch if found
         beq LandEnemyInitState
         cmpn ++Spiny                ;check for spiny
         bne InvtD                 ;branch if not found
         ldan ++$01
         stax Enemy_MovingDir,x     ;send enemy moving to the right by default
         ldan ++$08
         stax Enemy_X_Speed,x       ;set horizontal speed accordingly
         lda FrameCounter
         andn ++%00000111            ;if timed appropriately, spiny will skip over
         beq LandEnemyInitState    ;trying to face the player
InvtD:   ldyn ++$01                  ;load 1 for enemy to face the left (inverted here)
         jsr PlayerEnemyDiff       ;get horizontal difference between player and enemy
         bpl CNwCDir               ;if enemy to the right of player, branch
         iny                       ;if to the left, increment by one for enemy to face right (inverted)
CNwCDir: tya
         cmpx Enemy_MovingDir,x     ;compare direction in A with current direction in memory
         bne LandEnemyInitState
         jsr ChkForBump_HammerBroJ ;if equal, not facing in correct dir, do sub to turn around

LandEnemyInitState:
      jsr EnemyLanding       ;land enemy properly
      ldax Enemy_State,x
      andn ++%10000000         ;if d7 of enemy state is set, branch
      bne NMovShellFallBit
      ldan ++$00               ;otherwise initialize enemy state and leave
      stax Enemy_State,x      ;note this will also turn spiny's egg into spiny
      rts

NMovShellFallBit:
      ldax Enemy_State,x   ;nullify d6 of enemy state, save other bits
      andn ++%10111111      ;and store, then leave
      stax Enemy_State,x
      rts

;--------------------------------

ChkForRedKoopa:
             ldax Enemy_ID,x            ;check for red koopa troopa $03
             cmpn ++RedKoopa
             bne Chk2MSBSt             ;branch if not found
             ldax Enemy_State,x
         checka
             beq ChkForBump_HammerBroJ ;if enemy found and in normal state, branch
Chk2MSBSt:   ldax Enemy_State,x         ;save enemy state into Y
             tay
             asl                       ;check for d7 set
             bcc GetSteFromD           ;branch if not set
             ldax Enemy_State,x
             oran ++%01000000            ;set d6
             jmp SetD6Ste              ;jump ahead of this part
GetSteFromD: lday EnemyBGCStateData,y   ;load new enemy state with old as offset
SetD6Ste:    stax Enemy_State,x         ;set as new state

;--------------------------------
;$00 - used to store bitmask (not used but initialized here)
;$eb - used in DoEnemySideCheck as counter and to compare moving directions

DoEnemySideCheck:
          ldax Enemy_Y_Position,x     ;if enemy within status bar, branch to leave
          cmpn ++$20                   ;because there's nothing there that impedes movement
              cmpcy
          bcc ExESdeC
          ldyn ++$16                   ;start by finding block to the left of enemy ($00,$14)
          ldan ++$02                   ;set value here in what is also used as
          sta SCRATCHPAD+$eb                    ;OAM data offset
SdeCLoop: lda SCRATCHPAD+$eb                    ;check value
          cmpx Enemy_MovingDir,x      ;compare value against moving direction
          bne NextSdeC               ;branch if different and do not seek block there
          ldan ++$01                   ;set flag in A for save horizontal coordinate 
          jsr BlockBufferChk_Enemy   ;find block to left or right of enemy object
          beq NextSdeC               ;if nothing found, branch
          jsr ChkForNonSolids        ;check for non-solid blocks
          bne ChkForBump_HammerBroJ  ;branch if not found
NextSdeC: deci SCRATCHPAD+$eb                    ;move to the next direction
          iny
          cpyn ++$18                   ;increment Y, loop only if Y <  $18, thus we check
              cmpcy
          bcc SdeCLoop               ;enemy ($00, $14) and ($10, $14) pixel coordinates
ExESdeC:  rts

ChkForBump_HammerBroJ: 
        cpxn ++$05               ;check if we're on the special use slot
        beq NoBump             ;and if so, branch ahead and do not play sound
        ldax Enemy_State,x      ;if enemy state d7 not set, branch
        asl                    ;ahead and do not play sound
        bcc NoBump
        ldan ++Sfx_Bump          ;otherwise, play bump sound
        sta Square1SoundQueue  ;sound will never be played if branching from ChkForRedKoopa
NoBump: ldax Enemy_ID,x         ;check for hammer bro
        cmpn ++$05
        bne InvEnemyDir        ;branch if not found
        ldan ++$00
        sta SCRATCHPAD+$00                ;initialize value here for bitmask  
        ldyn ++$fa               ;load default vertical speed for jumping
        jmp SetHJ              ;jump to code that makes hammer bro jump

InvEnemyDir:
      jmp RXSpd     ;jump to turn the enemy around

;--------------------------------
;$00 - used to hold horizontal difference between player and enemy

PlayerEnemyDiff:
      ldax Enemy_X_Position,x  ;get distance between enemy object's
      secsub                     ;horizontal coordinate and the player's
      sbci Player_X_Position   ;horizontal coordinate
      sta SCRATCHPAD+$00                 ;and store here
      ldaxkeepcy Enemy_PageLoc,x
      sbci Player_PageLoc      ;subtract borrow, then leave
       cmpcy ;используется один раз
      rts

;--------------------------------

EnemyLanding:
      jsr InitVStf            ;do something here to vertical speed and something else
      ldax Enemy_Y_Position,x
      andn ++%11110000          ;save high nybble of vertical coordinate, and
      oran ++%00001000          ;set d3, then store, probably used to set enemy object
      stax Enemy_Y_Position,x  ;neatly on whatever it's landing on
      rts

SubtEnemyYPos:
      ldax Enemy_Y_Position,x  ;add 62 pixels to enemy object's
      clc                     ;vertical coordinate
      adcn ++$3e
      cmpn ++$44                ;compare against a certain range
              cmpcy
      rts                     ;and leave with flags set for conditional branch

EnemyJump:
        jsr SubtEnemyYPos     ;do a sub here
        bcc DoSide            ;if enemy vertical coord + 62 LOW  68, branch to leave
        ldax Enemy_Y_Speed,x
        clc                   ;add two to vertical speed
        adcn ++$02
        cmpn ++$03              ;if green paratroopa not falling, branch ahead
              cmpcy
        bcc DoSide
        jsr ChkUnderEnemy     ;otherwise, check to see if green paratroopa is 
        beq DoSide            ;standing on anything, then branch to same place if not
        jsr ChkForNonSolids   ;check for non-solid blocks
        beq DoSide            ;branch if found
        jsr EnemyLanding      ;change vertical coordinate and speed
        ldan ++$fd
        stax Enemy_Y_Speed,x   ;make the paratroopa jump again
DoSide: jmp DoEnemySideCheck  ;check for horizontal blockage, then leave

;--------------------------------

HammerBroBGColl:
      jsr ChkUnderEnemy    ;check to see if hammer bro is standing on anything
      beq NoUnderHammerBro      
      cmpn ++$23             ;check for blank metatile $23 and branch if not found
      bne UnderHammerBro

KillEnemyAboveBlock:
      jsr ShellOrBlockDefeat  ;do this sub to kill enemy
      ldan ++$fc                ;alter vertical speed of enemy and leave
      stax Enemy_Y_Speed,x
      rts

UnderHammerBro:
      ldax EnemyFrameTimer,x ;check timer used by hammer bro
         checka
      bne NoUnderHammerBro  ;branch if not expired
      ldax Enemy_State,x
      andn ++%10001000        ;save d7 and d3 from enemy state, nullify other bits
      stax Enemy_State,x     ;and store
      jsr EnemyLanding      ;modify vertical coordinate, speed and something else
      jmp DoEnemySideCheck  ;then check for horizontal blockage and leave

NoUnderHammerBro:
      ldax Enemy_State,x  ;if hammer bro is not standing on anything, set d0
      oran ++$01           ;in the enemy state to indicate jumping or falling, then leave
      stax Enemy_State,x
      rts

ChkUnderEnemy:
      ldan ++$00                  ;set flag in A for save vertical coordinate
      ldyn ++$15                  ;set Y to check the bottom middle (8,18) of enemy object
      jmp BlockBufferChk_Enemy  ;hop to it!

ChkForNonSolids:
       cmpn ++$26       ;blank metatile used for vines?
       beq NSFnd
       cmpn ++$c2       ;regular coin?
       beq NSFnd
       cmpn ++$c3       ;underwater coin?
       beq NSFnd
       cmpn ++$5f       ;hidden coin block?
       beq NSFnd
       cmpn ++$60       ;hidden 1-up block?
NSFnd:
              cmpcy ;???
        rts

;-------------------------------------------------------------------------------------

FireballBGCollision:
      ldax Fireball_Y_Position,x   ;check fireball's vertical coordinate
      cmpn ++$18
              cmpcy
      bcc ClearBounceFlag         ;if within the status bar area of the screen, branch ahead
      jsr BlockBufferChk_FBall    ;do fireball to background collision detection on bottom of it
      beq ClearBounceFlag         ;if nothing underneath fireball, branch
      jsr ChkForNonSolids         ;check for non-solid metatiles
      beq ClearBounceFlag         ;branch if any found
      ldax Fireball_Y_Speed,x      ;if fireball's vertical speed set to move upwards,
         checka
      bmi InitFireballExplode     ;branch to set exploding bit in fireball's state
      ldax FireballBouncingFlag,x  ;if bouncing flag already set,
         checka
      bne InitFireballExplode     ;branch to set exploding bit in fireball's state
      ldan ++$fd
      stax Fireball_Y_Speed,x      ;otherwise set vertical speed to move upwards (give it bounce)
      ldan ++$01
      stax FireballBouncingFlag,x  ;set bouncing flag
      ldax Fireball_Y_Position,x
      andn ++$f8                    ;modify vertical coordinate to land it properly
      stax Fireball_Y_Position,x   ;store as new vertical coordinate
      rts                         ;leave

ClearBounceFlag:
      ldan ++$00
      stax FireballBouncingFlag,x  ;clear bouncing flag by default
      rts                         ;leave

InitFireballExplode:
      ldan ++$80
      stax Fireball_State,x        ;set exploding flag in fireball's state
      ldan ++Sfx_Bump
      sta Square1SoundQueue       ;load bump sound
      rts                         ;leave

;-------------------------------------------------------------------------------------
;$00 - used to hold one of bitmasks, or offset
;$01 - used for relative X coordinate, also used to store middle screen page location
;$02 - used for relative Y coordinate, also used to store middle screen coordinate

;this data added to relative coordinates of sprite objects
;stored in order: left edge, top edge, right edge, bottom edge
BoundBoxCtrlData:
      .db $02, $08, $0e, $20 
      .db $03, $14, $0d, $20
      .db $02, $14, $0e, $20
      .db $02, $09, $0e, $15
      .db $00, $00, $18, $06
      .db $00, $00, $20, $0d
      .db $00, $00, $30, $0d
      .db $00, $00, $08, $08
      .db $06, $04, $0a, $08
      .db $03, $0e, $0d, $14
      .db $00, $02, $10, $15
      .db $04, $04, $0c, $1c

GetFireballBoundBox:
      txa         ;add seven bytes to offset
      clc         ;to use in routines as offset for fireball
      adcn ++$07
      tax
      ldyn ++$02    ;set offset for relative coordinates
         checky
      bne FBallB  ;unconditional branch

GetMiscBoundBox:
        txa                       ;add nine bytes to offset
        clc                       ;to use in routines as offset for misc object
        adcn ++$09 ;начиная с объекта #9 идут misc objects (что это???)
        tax
        ldyn ++$06                  ;set offset for relative coordinates
FBallB: jsr BoundingBoxCore       ;get bounding box coordinates
        jmp CheckRightScreenBBox  ;jump to handle any offscreen coordinates

GetEnemyBoundBox:
      ldyn ++$48                 ;store bitmask here for now
      sty SCRATCHPAD+$00
      ldyn ++$44                 ;store another bitmask here for now and jump
      jmp GetMaskedOffScrBits

SmallPlatformBoundBox:
      ldyn ++$08                 ;store bitmask here for now
      sty SCRATCHPAD+$00
      ldyn ++$04                 ;store another bitmask here for now

GetMaskedOffScrBits:
        ldax Enemy_X_Position,x      ;get enemy object position relative
        secsub                         ;to the left side of the screen
        sbci ScreenLeft_X_Pos
        sta SCRATCHPAD+$01                     ;store here
        ldaxkeepcy Enemy_PageLoc,x         ;subtract borrow from current page location
        sbci ScreenLeft_PageLoc      ;of left side
        bmi CMBits                  ;if enemy object is beyond left edge, branch
        orai SCRATCHPAD+$01 ;ставит Z???
        beq CMBits                  ;if precisely at the left edge, branch
        ldy SCRATCHPAD+$00                     ;if to the right of left edge, use value in $00 for A
CMBits: tya                         ;otherwise use contents of Y
        andi Enemy_OffscreenBits     ;preserve bitwise whatever's in here
        stax EnemyOffscrBitsMasked,x ;save masked offscreen bits here
         checka
        bne MoveBoundBoxOffscreen   ;if anything set here, branch
        jmp SetupEOffsetFBBox       ;otherwise, do something else

LargePlatformBoundBox:
        if Z80OPT
        push bc
      inc c                        ;increment X to get the proper offset
      call GetXOffscreenBits      ;then jump directly to the sub for horizontal offscreen bits
        pop bc                   ;decrement to return to original offset
        else
      inx                        ;increment X to get the proper offset
      jsr GetXOffscreenBits      ;then jump directly to the sub for horizontal offscreen bits
      dex                        ;decrement to return to original offset
        endif
      cmpn ++$fe                   ;if completely offscreen, branch to put entire bounding ;TODO >>4 в GetXOffscreenBits
              cmpcy
      bcs MoveBoundBoxOffscreen  ;box offscreen, otherwise start getting coordinates

SetupEOffsetFBBox:
      txa                        ;add 1 to offset to properly address
      clc                        ;the enemy object memory locations
      adcn ++$01
      tax
      ldyn ++$01                   ;load 1 as offset here, same reason
      jsr BoundingBoxCore        ;do a sub to get the coordinates of the bounding box
      jmp CheckRightScreenBBox   ;jump to handle offscreen coordinates of bounding box

MoveBoundBoxOffscreen:
      txa                            ;multiply offset by 4
      asl
      asl
      tay                            ;use as offset here
      ldan ++$ff
      stay EnemyBoundingBoxCoord,y    ;load value into four locations here and leave
      stay EnemyBoundingBoxCoord+1,y
      stay EnemyBoundingBoxCoord+2,y
      stay EnemyBoundingBoxCoord+3,y
      rts

BoundingBoxCore:
;x=obj?
;y=obj2?
;keep x
;out: y=x*4 (для последующего CheckRightScreenBBox, в остальных случаях не нужно)
        if Z80OPT ;???нет разницы в 1-2
        ld iy,SprObject_Rel_YPos
        add iy,de
        ld hl,SprObj_BoundBoxCtrl
        add hl,bc
      ld a,(hl)
      add a,a
      add a,a ;*4
     ld hl,BoundBoxCtrlData ;left edge, top edge, right edge, bottom edge (12 таких элементов)
     add a,l
     ld l,a
     adc a,h
     sub l
     ld h,a
      ld a,c ;txa                         ;multiply offset by four and save to stack
      add a,a
      add a,a ;*4
     ld e,a                        ;use as offset
     ;push de
        ld ix,BoundingBox_UL_Corner
        add ix,de
      ld a,(iy+SprObject_Rel_XPos-SprObject_Rel_YPos) ;object X coordinate relative to screen
      add a,(hl) ;adcx BoundBoxCtrlData,x     ;add the first number in the bounding box data to the
      ld (ix+BoundingBox_UL_Corner-BoundingBox_UL_Corner),a ;stay BoundingBox_UL_Corner,y ;store here
     sub (hl)
     inc hl
     inc hl
      add a,(hl) ;adcx BoundBoxCtrlData+2,x    ;add the third number in the bounding box data to the
      ld (ix+BoundingBox_LR_Corner-BoundingBox_UL_Corner),a ;stay BoundingBox_LR_Corner,y ;relative horizontal coordinate and store
     dec hl
      ld a,(iy+SprObject_Rel_YPos-SprObject_Rel_YPos) ;object Y coordinate relative to screen
      add a,(hl);adcx BoundBoxCtrlData,x      ;add the second number to the relative vertical coordinate
      ld (ix+BoundingBox_UL_Corner-BoundingBox_UL_Corner+1),a ;stay BoundingBox_UL_Corner,y
     sub (hl)
     inc hl
     inc hl
      add a,(hl) ;adcx BoundBoxCtrlData+2,x    ;add the fourth number to the relative vertical coordinate
      ld (ix+BoundingBox_LR_Corner-BoundingBox_UL_Corner+1),a ;stay BoundingBox_LR_Corner,y ;and store
     ;pop de
      ret

CheckRightScreenBBox:
;y = x*4
;ix = BoundingBox_UL_Corner + (x*4)
        ld iy,SprObject_X_Position
        add iy,bc
       lda ScreenLeft_X_Pos       ;add 128 pixels to left side of screen
       add a,0x80
       ld h,a;sta SCRATCHPAD+$02 ;and store as horizontal coordinate of middle
       lda ScreenLeft_PageLoc     ;add carry to page location of left side of screen
       adcn ++$00                   ;and store as page location of middle
       ld l,a;sta SCRATCHPAD+$01
       ld a,(iy+SprObject_X_Position-SprObject_X_Position) ;ldax SprObject_X_Position,x ;get horizontal coordinate
       sub h;cmpi SCRATCHPAD+$02                    ;compare against middle horizontal coordinate
       ld a,(iy+SprObject_PageLoc-SprObject_X_Position) ;ldaxkeepcy SprObject_PageLoc,x    ;get page location
       sbc a,l;sbci SCRATCHPAD+$01                    ;subtract from middle page location
       jr c,CheckLeftScreenBBox    ;if object is on the left side of the screen, branch
       ld a,(ix+BoundingBox_DR_XPos-BoundingBox_UL_Corner) ;lday BoundingBox_DR_XPos,y  ;check right-side edge of bounding box for offscreen
        or a
       bmi NoOfs                  ;coordinates, branch if still on the screen
       ld a,(ix+BoundingBox_UL_XPos-BoundingBox_UL_Corner) ;ldxy BoundingBox_UL_XPos,y  ;check left-side edge of bounding box for offscreen
        or a
       ldan ++$ff                   ;load offscreen value here to use on one or both horizontal sides
       bmi SORte                  ;coordinates, and branch if still on the screen
       ld (ix+BoundingBox_UL_XPos-BoundingBox_UL_Corner),a ;stay BoundingBox_UL_XPos,y  ;store offscreen value for left side
SORte: ld (ix+BoundingBox_DR_XPos-BoundingBox_UL_Corner),a ;stay BoundingBox_DR_XPos,y  ;store offscreen value for right side
NoOfs: ldx ObjectOffset           ;get object offset and leave
       ret

CheckLeftScreenBBox:
        ld a,(ix+BoundingBox_UL_XPos-BoundingBox_UL_Corner) ;lday BoundingBox_UL_XPos,y  ;check left-side edge of bounding box for offscreen
         or a
        bpl NoOfs2                 ;coordinates, and branch if still on the screen
        cmpn ++$a0                   ;check to see if left-side edge is in the middle of the
        jr c,NoOfs2                 ;screen or really offscreen, and branch if still on
        ld a,(ix+BoundingBox_DR_XPos-BoundingBox_UL_Corner) ;ldxy BoundingBox_DR_XPos,y  ;check right-side edge of bounding box for offscreen
         or a
        ldan ++$00
        bpl SOLft                  ;coordinates, branch if still onscreen
        ld (ix+BoundingBox_DR_XPos-BoundingBox_UL_Corner),a ;stay BoundingBox_DR_XPos,y  ;store offscreen value for right side
SOLft:  ld (ix+BoundingBox_UL_XPos-BoundingBox_UL_Corner),a ;stay BoundingBox_UL_XPos,y  ;store offscreen value for left side
NoOfs2: ldx ObjectOffset           ;get object offset and leave
        rts
      
        else ;~Z80
;тут ломалось отображение левой ноги гриба
;дело не в порче SCRATCHPAD (проверено через отдельный буфер)
;дело не в CY на выходе (проверено через plakeepcy)
;дело было в несоздании ix для Z80-версии CheckRightScreenBBox
      stx zSCRATCHPAD+$00                     ;save offset here
      lday SprObject_Rel_YPos,y    ;store object coordinates relative to screen
      sta zSCRATCHPAD+$02                     ;vertically and horizontally, respectively
      lday SprObject_Rel_XPos,y
      sta zSCRATCHPAD+$01
      txa                         ;multiply offset by four and save to stack
      asl
      asl
      pha
      tay                         ;use as offset for Y, X is left alone
      ldax SprObj_BoundBoxCtrl,x   ;load value here to be used as offset for X
      asl                         ;multiply that by four and use as X
      asl
      tax
      lda zSCRATCHPAD+$01                     ;add the first number in the bounding box data to the
      clc                         ;relative horizontal coordinate using enemy object offset
      adcx BoundBoxCtrlData,x      ;and store somewhere using same offset * 4
      stay BoundingBox_UL_Corner,y ;store here
      lda zSCRATCHPAD+$01
      clc
      adcx BoundBoxCtrlData+2,x    ;add the third number in the bounding box data to the
      stay BoundingBox_LR_Corner,y ;relative horizontal coordinate and store
      inx                         ;increment both offsets
      iny
      lda zSCRATCHPAD+$02                     ;add the second number to the relative vertical coordinate
      clc                         ;using incremented offset and store using the other
      adcx BoundBoxCtrlData,x      ;incremented offset
      stay BoundingBox_UL_Corner,y
      lda zSCRATCHPAD+$02
      clc
      adcx BoundBoxCtrlData+2,x    ;add the fourth number to the relative vertical coordinate
      stay BoundingBox_LR_Corner,y ;and store
      plakeepcy;pla                         ;get original offset loaded into $00 * y from stack
      tay                         ;use as Y
      ldx zSCRATCHPAD+$00                     ;get original offset and use as X again
      rts
zSCRATCHPAD=SCRATCHPAD
        ;ds 3

CheckRightScreenBBox:
;y = x*4
       lda ScreenLeft_X_Pos       ;add 128 pixels to left side of screen
       clc                        ;and store as horizontal coordinate of middle
       adcn ++$80
       sta SCRATCHPAD+$02
       lda ScreenLeft_PageLoc     ;add carry to page location of left side of screen
       adcn ++$00                   ;and store as page location of middle
       sta SCRATCHPAD+$01
       ldax SprObject_X_Position,x ;get horizontal coordinate
       cmpi SCRATCHPAD+$02                    ;compare against middle horizontal coordinate
       ldaxkeepcy SprObject_PageLoc,x    ;get page location
       sbci SCRATCHPAD+$01                    ;subtract from middle page location
              cmpcy
       bcc CheckLeftScreenBBox    ;if object is on the left side of the screen, branch
       lday BoundingBox_DR_XPos,y  ;check right-side edge of bounding box for offscreen
         checka
       bmi NoOfs                  ;coordinates, branch if still on the screen
       ldan ++$ff                   ;load offscreen value here to use on one or both horizontal sides
       ldxy BoundingBox_UL_XPos,y  ;check left-side edge of bounding box for offscreen
         checkx
       bmi SORte                  ;coordinates, and branch if still on the screen
       stay BoundingBox_UL_XPos,y  ;store offscreen value for left side
SORte: stay BoundingBox_DR_XPos,y  ;store offscreen value for right side
NoOfs: ldx ObjectOffset           ;get object offset and leave
       rts

CheckLeftScreenBBox:
        lday BoundingBox_UL_XPos,y  ;check left-side edge of bounding box for offscreen
         checka
        bpl NoOfs2                 ;coordinates, and branch if still on the screen
        cmpn ++$a0                   ;check to see if left-side edge is in the middle of the
              cmpcy
        bcc NoOfs2                 ;screen or really offscreen, and branch if still on
        ldan ++$00
        ldxy BoundingBox_DR_XPos,y  ;check right-side edge of bounding box for offscreen
         checkx
        bpl SOLft                  ;coordinates, branch if still onscreen
        stay BoundingBox_DR_XPos,y  ;store offscreen value for right side
SOLft:  stay BoundingBox_UL_XPos,y  ;store offscreen value for left side
NoOfs2: ldx ObjectOffset           ;get object offset and leave
        rts
        endif

;-------------------------------------------------------------------------------------
;$06 - second object's offset
;$07 - counter
;y=second object's offset
;не портит y

;TODO раскрыть цикл

PlayerCollisionCore:
      ldxn ++$00     ;initialize X to use player's bounding box for comparison

SprObjectCollisionCore:

        if Z80OPT2a
        
      push de;sty SCRATCHPAD+$06      ;save contents of Y here
      ld iy,BoundingBox_UL_Corner
      add iy,de
      ld ix,BoundingBox_UL_Corner
      add ix,bc
      ;ldan ++$01
      ld d,1 ;sta SCRATCHPAD+$07      ;save value 1 here as counter, compare horizontal coordinates first
      
CollisionCoreLoop:
      ld e,(ix)
      ld c,(ix+BoundingBox_LR_Corner-BoundingBox_UL_Corner)
      ld a,(iy);lday BoundingBox_UL_Corner,y  ;compare left/top coordinates
      cp e;(ix);icmpx BoundingBox_UL_Corner,x  ;of first and second objects' bounding boxes
      jr nc,FirstBoxGreater          ;if first left/top =>  second, branch
      cp c;(ix+BoundingBox_LR_Corner-BoundingBox_UL_Corner);cmpx BoundingBox_LR_Corner,x  ;otherwise compare to right/bottom of second
      jr c,SecondBoxVerticalChk     ;if first left/top <  second right/bottom, branch elsewhere
      jr z,CollisionFound           ;if somehow equal, collision, thus branch
       ld c,a
      ld a,(iy+BoundingBox_LR_Corner-BoundingBox_UL_Corner);lday BoundingBox_LR_Corner,y  ;if somehow greater, check to see if bottom of
      cp c;(iy);cmpy BoundingBox_UL_Corner,y  ;first object's bounding box is greater than its top
      jr c,CollisionFound           ;if somehow less, vertical wrap collision, thus branch
      cp e;(ix);cmpx BoundingBox_UL_Corner,x  ;otherwise compare bottom of first bounding box to the top
      jr nc,CollisionFound           ;of second box, and if equal or greater, collision, thus branch
      or a
      pop de;ldy SCRATCHPAD+$06                      ;otherwise return with carry clear and Y = $0006
      ret                       ;note horizontal wrapping never occurs

SecondBoxVerticalChk:
      ld a,(ix+BoundingBox_LR_Corner-BoundingBox_UL_Corner);ldax BoundingBox_LR_Corner,x  ;check to see if the vertical bottom of the box
      cp e;(ix);cmpx BoundingBox_UL_Corner,x  ;is greater than the vertical top
      jr c,CollisionFound           ;if somehow less, vertical wrap collision, thus branch
      ld a,(iy+BoundingBox_LR_Corner-BoundingBox_UL_Corner);lday BoundingBox_LR_Corner,y  ;otherwise compare horizontal right or vertical bottom
      cp e;(ix);cmpx BoundingBox_UL_Corner,x  ;of first box with horizontal left or vertical top of second box
      jr nc,CollisionFound           ;if equal or greater, collision, thus branch
      or a
      pop de;ldy SCRATCHPAD+$06                      ;otherwise return with carry clear and Y = $0006
      ret

FirstBoxGreater:
      cp e;(ix);cmpx BoundingBox_UL_Corner,x  ;compare first and second box horizontal left/vertical top again
      jr z,CollisionFound           ;if first coordinate = second, collision, thus branch
      cp c;(ix+BoundingBox_LR_Corner-BoundingBox_UL_Corner);cmpx BoundingBox_LR_Corner,x  ;if not, compare with second object right or bottom edge
      jr c,CollisionFound           ;if left/top of first less than or equal to right/bottom of second
      jr z,CollisionFound           ;then collision, thus branch
      cp (iy+BoundingBox_LR_Corner-BoundingBox_UL_Corner);cmpy BoundingBox_LR_Corner,y  ;otherwise check to see if top of first box is greater than bottom
      jr c,NoCollisionFound         ;if less than or equal, no collision, branch to end
      jr z,NoCollisionFound
      ld a,(iy+BoundingBox_LR_Corner-BoundingBox_UL_Corner);lday BoundingBox_LR_Corner,y  ;otherwise compare bottom of first to top of second
      cp c;(ix+BoundingBox_LR_Corner-BoundingBox_UL_Corner);cmpx BoundingBox_UL_Corner,x  ;if bottom of first is greater than top of second, vertical wrap
      jr nc,CollisionFound           ;collision, and branch, otherwise, proceed onwards here
NoCollisionFound:
      or a          ;clear carry, then load value set earlier, then leave
      pop de;ldy SCRATCHPAD+$06      ;like previous ones, if horizontal coordinates do not collide, we do
      ret          ;not bother checking vertical ones, because what's the point?

CollisionFound:
      inc ix ;inx                    ;increment offsets on both objects to check
      inc iy ;iny                    ;the vertical coordinates
      dec d ;deci SCRATCHPAD+$07                ;decrement counter to reflect this
      jp p,CollisionCoreLoop  ;if counter not expired, branch to loop
      scf                    ;otherwise we already did both sets, therefore collision, so set carry
      pop de;ldy SCRATCHPAD+$06                ;load original value set here earlier, then leave
      ret
        
        else ;~Z80

      sty SCRATCHPAD+$06      ;save contents of Y here
      ldan ++$01
      sta SCRATCHPAD+$07      ;save value 1 here as counter, compare horizontal coordinates first

CollisionCoreLoop:
      lday BoundingBox_UL_Corner,y  ;compare left/top coordinates
      cmpx BoundingBox_UL_Corner,x  ;of first and second objects' bounding boxes
              cmpcy
      bcs FirstBoxGreater          ;if first left/top =>  second, branch
      cmpx BoundingBox_LR_Corner,x  ;otherwise compare to right/bottom of second
              cmpcy
      bcc SecondBoxVerticalChk     ;if first left/top <  second right/bottom, branch elsewhere
      beq CollisionFound           ;if somehow equal, collision, thus branch
      lday BoundingBox_LR_Corner,y  ;if somehow greater, check to see if bottom of
      cmpy BoundingBox_UL_Corner,y  ;first object's bounding box is greater than its top
              cmpcy
      bcc CollisionFound           ;if somehow less, vertical wrap collision, thus branch
      cmpx BoundingBox_UL_Corner,x  ;otherwise compare bottom of first bounding box to the top
              cmpcy
      bcs CollisionFound           ;of second box, and if equal or greater, collision, thus branch
      ldy SCRATCHPAD+$06                      ;otherwise return with carry clear and Y = $0006
      rts                          ;note horizontal wrapping never occurs

SecondBoxVerticalChk:
      ldax BoundingBox_LR_Corner,x  ;check to see if the vertical bottom of the box
      cmpx BoundingBox_UL_Corner,x  ;is greater than the vertical top
              cmpcy
      bcc CollisionFound           ;if somehow less, vertical wrap collision, thus branch
      lday BoundingBox_LR_Corner,y  ;otherwise compare horizontal right or vertical bottom
      cmpx BoundingBox_UL_Corner,x  ;of first box with horizontal left or vertical top of second box
              cmpcy
      bcs CollisionFound           ;if equal or greater, collision, thus branch
      ldy SCRATCHPAD+$06                      ;otherwise return with carry clear and Y = $0006
      rts

FirstBoxGreater:
      cmpx BoundingBox_UL_Corner,x  ;compare first and second box horizontal left/vertical top again
      beq CollisionFound           ;if first coordinate = second, collision, thus branch
      cmpx BoundingBox_LR_Corner,x  ;if not, compare with second object right or bottom edge
              cmpcy
      bcc CollisionFound           ;if left/top of first less than or equal to right/bottom of second
      beq CollisionFound           ;then collision, thus branch
      cmpy BoundingBox_LR_Corner,y  ;otherwise check to see if top of first box is greater than bottom
              cmpcy
      bcc NoCollisionFound         ;if less than or equal, no collision, branch to end
      beq NoCollisionFound
      lday BoundingBox_LR_Corner,y  ;otherwise compare bottom of first to top of second
      cmpx BoundingBox_UL_Corner,x  ;if bottom of first is greater than top of second, vertical wrap
              cmpcy
      bcs CollisionFound           ;collision, and branch, otherwise, proceed onwards here

NoCollisionFound:
      clc          ;clear carry, then load value set earlier, then leave
      ldy SCRATCHPAD+$06      ;like previous ones, if horizontal coordinates do not collide, we do
      rts          ;not bother checking vertical ones, because what's the point?

CollisionFound:
      inx                    ;increment offsets on both objects to check
      iny                    ;the vertical coordinates
      deci SCRATCHPAD+$07                ;decrement counter to reflect this
      bpl CollisionCoreLoop  ;if counter not expired, branch to loop
      sec                    ;otherwise we already did both sets, therefore collision, so set carry
      ldy SCRATCHPAD+$06                ;load original value set here earlier, then leave
      rts

        endif
      
;-------------------------------------------------------------------------------------
;$02 - modified y coordinate
;$03 - stores metatile involved in block buffer collisions
;$04 - comes in with offset to block buffer adder data, goes out with low nybble x/y coordinate
;$05 - modified x coordinate
;$06-$07 - block buffer address

BlockBufferChk_Enemy:
      pha        ;save contents of A to stack
      txa
      clc        ;add 1 to X to run sub with enemy offset in mind
      adcn ++$01
      tax
      pla        ;pull A from stack and jump elsewhere
      jmp BBChk_E

ResidualMiscObjectCode:
      txa
      clc           ;supposedly used once to set offset for
      adcn ++$0d      ;miscellaneous objects
      tax
      ldyn ++$1b      ;supposedly used once to set offset for block buffer data
      jmp ResJmpM   ;probably used in early stages to do misc to bg collision detection

BlockBufferChk_FBall:
         ldyn ++$1a                  ;set offset for block buffer adder data
         txa
         clc
         adcn ++$07                  ;add seven bytes to use
         tax
ResJmpM: ldan ++$00                  ;set A to return vertical coordinate
BBChk_E: jsr BlockBufferCollision  ;do collision detection subroutine for sprite object
         ldx ObjectOffset          ;get object offset
         cmpn ++$00                  ;check to see if object bumped into anything
              cmpcy ;???
         rts

BlockBufferAdderData:
      .db $00, $07, $0e

;описание баундинг боксов для столкновения с картой???
BlockBuffer_X_Adder:
;период 7 (в каждой группе первые 3 числа используются только для монстров, остальные 4 для игрока)
      .db $08, $03, $0c, $02, $02, $0d, $0d
      .db $08, $03, $0c, $02, $02, $0d, $0d
      .db $08, $03, $0c, $02, $02, $0d, $0d
      .db $08, $00, $10, $04, $14, $04, $04 ;как сюда попасть???

BlockBuffer_Y_Adder:
;период 7 (в каждой группе первые 3 числа используются только для монстров, остальные 4 для игрока)
      .db $04, $20, $20, $08, $18, $08, $18
      .db $02, $20, $20, $08, $18, $08, $18
      .db $12, $20, $20, $18, $18, $18, $18
      .db $18, $14, $14, $06, $06, $08, $10 ;как сюда попасть???

BlockBufferColli_Feet:
       iny            ;if branched here, increment to next set of adders

BlockBufferColli_Head:
;out: NZ=collision
       ldan ++$00       ;set flag to return vertical coordinate
       jr BlockBufferColli_Side_go;.db $2c        ;BIT instruction opcode

BlockBufferColli_Side:
       ldan ++$01       ;set flag to return horizontal coordinate
BlockBufferColli_Side_go
       ldxn ++$00       ;set offset for player object

BlockBufferCollision:
;x=obj
;y=??? (нельзя портить!) некий индекс для BlockBuffer_X_Adder, BlockBuffer_Y_Adder
;a=1: return X to ($04)
;a=0: return Y to ($04)
;ещё устанавливает ($02) = (y+yadder)&0xf0 - 32
;ещё устанавливает ($06..07) = blockbuffer+x
        if Z80OPT
       ld hl,BlockBuffer_X_Adder
       add hl,de
       ld ix,SprObject_X_Position
       add ix,bc
         or a
       jr nz,RetXC                   ;if A = 1, branch
       ld a,(ix+SprObject_Y_Position-SprObject_X_Position) ;ldax SprObject_Y_Position,x  ;if A = 0, load vertical coordinate
       jp RetYC                   ;and jump
RetXC: ld a,(ix+SprObject_X_Position-SprObject_X_Position) ;ldax SprObject_X_Position,x  ;otherwise load horizontal coordinate
RetYC: and ++%00001111              ;and mask out high nybble
       ld (SCRATCHPAD+$04),a                     ;store masked out result here

       ld a,(hl) ;lday BlockBuffer_X_Adder,y   ;add horizontal coordinate
       add a,(ix+SprObject_X_Position-SprObject_X_Position) ;adcx SprObject_X_Position,x ;of object to value obtained using Y as offset
       ld l,a ;sta SCRATCHPAD+$05                     ;store here ;у нас пока 3???
       adc a,(ix+SprObject_PageLoc-SprObject_X_Position) ;adcn ++$00                    ;add carry to page location
       sub l
       rra                         ;move to carry ;xHSB
       ld a,l ;orai SCRATCHPAD+$05                     ;get stored value ;xLSB
        ld hl,Block_Buffer_1
        jr nc,$+5
         ld hl,Block_Buffer_2
       rra
       rra
       rra
       rra
        and 0x0f
        add a,l
        ld l,a
        ;adc a,h
        ;sub l
        ;ld h,a
        ld (SCRATCHPAD+$06),hl ;???
       ld hl,BlockBuffer_Y_Adder
       add hl,de
       ld a,(ix+SprObject_Y_Position-SprObject_X_Position) ;ldax SprObject_Y_Position,x  ;get vertical coordinate of object
       add a,(hl);adcy BlockBuffer_Y_Adder,y   ;add it to value obtained using Y as offset       
       and ++%11110000              ;mask out low nybble
       sub 32               ;subtract 32 pixels for the status bar
       ld (SCRATCHPAD+$02),a                     ;store result here ;???
       ;use as offset for block buffer
        ld hl,(SCRATCHPAD+$06)
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
       ;ld a,(hl) ;ldayindirect (SCRATCHPAD+$06),y                 ;check current content of block buffer
       ;sta SCRATCHPAD+$03                     ;and store here
       ld a,(hl) ;lda SCRATCHPAD+$03                     ;get saved content of block buffer
       ;lda SCRATCHPAD+$03                     ;get saved content of block buffer
	or a
       ret                         ;and leave
        
        else ;~Z80
        
       pha                         ;save contents of A to stack
       sty SCRATCHPAD+$04                     ;save contents of Y here
       lday BlockBuffer_X_Adder,y   ;add horizontal coordinate
       clc                         ;of object to value obtained using Y as offset
       adcx SprObject_X_Position,x
       sta SCRATCHPAD+$05                     ;store here ;у нас пока 3???
       ldaxkeepcy SprObject_PageLoc,x
       adcn ++$00                    ;add carry to page location
       andn ++$01                    ;get LSB, mask out all other bits
       lsr                         ;move to carry
      push af
       orai SCRATCHPAD+$05                     ;get stored value
      ld h,a
      pop af
      ld a,h
       ror                         ;rotate carry to MSB of A
       lsr                         ;and effectively move high nybble to
       lsr                         ;lower, LSB which became MSB will be
       lsr                         ;d4 at this point
       jsr GetBlockBufferAddr      ;get address of block buffer into $06, $07
       ldy SCRATCHPAD+$04                     ;get old contents of Y
       ldax SprObject_Y_Position,x  ;get vertical coordinate of object
       clc
       adcy BlockBuffer_Y_Adder,y   ;add it to value obtained using Y as offset
       andn ++%11110000              ;mask out low nybble
       secsub
       sbcn ++$20                    ;subtract 32 pixels for the status bar
       sta SCRATCHPAD+$02                     ;store result here
       tay                         ;use as offset for block buffer
       ldayindirect (SCRATCHPAD+$06),y                 ;check current content of block buffer
       sta SCRATCHPAD+$03                     ;and store here
       ldy SCRATCHPAD+$04                     ;get old contents of Y again
       pla                         ;pull A from stack
         checka
       bne RetXC                   ;if A = 1, branch
       ldax SprObject_Y_Position,x  ;if A = 0, load vertical coordinate
       jmp RetYC                   ;and jump
RetXC: ldax SprObject_X_Position,x  ;otherwise load horizontal coordinate
RetYC: andn ++%00001111              ;and mask out high nybble
       sta SCRATCHPAD+$04                     ;store masked out result here
       lda SCRATCHPAD+$03                     ;get saved content of block buffer
	checka
       rts                         ;and leave
        endif

;-------------------------------------------------------------------------------------

        if Z80==0
;unused byte
      .db $ff
        endif

;-------------------------------------------------------------------------------------
;$00 - offset to vine Y coordinate adder
;$02 - offset to sprite data

VineYPosAdder:
      .db $00, $30

DrawVine:
         sty SCRATCHPAD+$00                    ;save offset here
         lda Enemy_Rel_YPos         ;get relative vertical coordinate
         clc
         adcy VineYPosAdder,y        ;add value using offset in Y to get value
         ldxy VineObjOffset,y        ;get offset to vine
         ldyx Enemy_SprDataOffset,x  ;get sprite data offset
         sty SCRATCHPAD+$02                    ;store sprite data offset here
         jsr SixSpriteStacker       ;stack six sprites on top of each other vertically
         lda Enemy_Rel_XPos         ;get relative horizontal coordinate
         stay Sprite_X_Position,y    ;store in first, third and fifth sprites
         stay Sprite_X_Position+8,y
         stay Sprite_X_Position+16,y
         clc
         adcn ++$06                   ;add six pixels to second, fourth and sixth sprites
         stay Sprite_X_Position+4,y  ;to give characteristic staggered vine shape to
         stay Sprite_X_Position+12,y ;our vertical stack of sprites
         stay Sprite_X_Position+20,y
         ldan ++%00100001             ;set bg priority and palette attribute bits
         stay Sprite_Attributes,y    ;set in first, third and fifth sprites
         stay Sprite_Attributes+8,y
         stay Sprite_Attributes+16,y
         oran ++%01000000             ;additionally, set horizontal flip bit
         stay Sprite_Attributes+4,y  ;for second, fourth and sixth sprites
         stay Sprite_Attributes+12,y
         stay Sprite_Attributes+20,y
         ldxn ++$05                   ;set tiles for six sprites
VineTL:  ldan ++$e1                   ;set tile number for sprite
         stay Sprite_Tilenumber,y
         iny                        ;move offset to next sprite data
         iny
         iny
         iny
         dex                        ;move onto next sprite
         bpl VineTL                 ;loop until all sprites are done
         ldy SCRATCHPAD+$02                    ;get original offset
         lda SCRATCHPAD+$00                    ;get offset to vine adding data
         checka
         bne SkpVTop                ;if offset not zero, skip this part
         ldan ++$e0
         stay Sprite_Tilenumber,y    ;set other tile number for top of vine
SkpVTop: ldxn ++$00                   ;start with the first sprite again
ChkFTop: lda VineStart_Y_Position   ;get original starting vertical coordinate
         secsub
         sbcy Sprite_Y_Position,y    ;subtract top-most sprite's Y coordinate
         cmpn ++$64                   ;if two coordinates are less than 100/$64 pixels
              cmpcy
         bcc NextVSp                ;apart, skip this to leave sprite alone
         ldan ++$f8
         stay Sprite_Y_Position,y    ;otherwise move sprite offscreen
NextVSp: iny                        ;move offset to next OAM data
         iny
         iny
         iny
         inx                        ;move onto next sprite
         cpxn ++$06                   ;do this until all sprites are checked
         bne ChkFTop
         ldy SCRATCHPAD+$00                    ;return offset set earlier
         rts

SixSpriteStacker:
       ldxn ++$06           ;do six sprites
StkLp: stay Sprite_Data,y  ;store X or Y coordinate into OAM data
       clc
       adcn ++$08           ;add eight pixels
       iny
       iny                ;move offset four bytes forward
       iny
       iny
       dex                ;do another sprite
       bne StkLp          ;do this until all sprites are done
       ldy SCRATCHPAD+$02            ;get saved OAM data offset and leave
       rts

;-------------------------------------------------------------------------------------

FirstSprXPos:
      .db $04, $00, $04, $00

FirstSprYPos:
      .db $00, $04, $00, $04

SecondSprXPos:
      .db $00, $08, $00, $08

SecondSprYPos:
      .db $08, $00, $08, $00

FirstSprTilenum:
      .db $80, $82, $81, $83

SecondSprTilenum:
      .db $81, $83, $80, $82

HammerSprAttrib:
      .db $03, $03, $c3, $c3

DrawHammer:
            ldyx Misc_SprDataOffset,x    ;get misc object OAM data offset
            lda TimerControl
         checka
            bne ForceHPose              ;if master timer control set, skip this part
            ldax Misc_State,x            ;otherwise get hammer's state
            andn ++%01111111              ;mask out d7
            cmpn ++$01                    ;check to see if set to 1 yet
            beq GetHPose                ;if so, branch
ForceHPose: ldxn ++$00                    ;reset offset here
         checkx
            beq RenderH                 ;do unconditional branch to rendering part
GetHPose:   lda FrameCounter            ;get frame counter
            lsr                         ;move d3-d2 to d1-d0
            lsr
            andn ++%00000011              ;mask out all but d1-d0 (changes every four frames)
            tax                         ;use as timing offset
RenderH:    lda Misc_Rel_YPos           ;get relative vertical coordinate
            clc
            adcx FirstSprYPos,x          ;add first sprite vertical adder based on offset
            stay Sprite_Y_Position,y     ;store as sprite Y coordinate for first sprite
            clc
            adcx SecondSprYPos,x         ;add second sprite vertical adder based on offset
            stay Sprite_Y_Position+4,y   ;store as sprite Y coordinate for second sprite
            lda Misc_Rel_XPos           ;get relative horizontal coordinate
            clc
            adcx FirstSprXPos,x          ;add first sprite horizontal adder based on offset
            stay Sprite_X_Position,y     ;store as sprite X coordinate for first sprite
            clc
            adcx SecondSprXPos,x         ;add second sprite horizontal adder based on offset
            stay Sprite_X_Position+4,y   ;store as sprite X coordinate for second sprite
            ldax FirstSprTilenum,x
            stay Sprite_Tilenumber,y     ;get and store tile number of first sprite
            ldax SecondSprTilenum,x
            stay Sprite_Tilenumber+4,y   ;get and store tile number of second sprite
            ldax HammerSprAttrib,x
            stay Sprite_Attributes,y     ;get and store attribute bytes for both
            stay Sprite_Attributes+4,y   ;note in this case they use the same data
            ldx ObjectOffset            ;get misc object offset
            lda Misc_OffscreenBits
            andn ++%11111100              ;check offscreen bits
            beq NoHOffscr               ;if all bits clear, leave object alone
            ldan ++$00
            stax Misc_State,x            ;otherwise nullify misc object state
            ldan ++$f8
            jsr DumpTwoSpr              ;do sub to move hammer sprites offscreen
NoHOffscr:  rts                         ;leave

;-------------------------------------------------------------------------------------
;$00-$01 - used to hold tile numbers ($01 addressed in draw floatey number part)
;$02 - used to hold Y coordinate for floatey number
;$03 - residual byte used for flip (but value set here affects nothing)
;$04 - attribute byte for floatey number
;$05 - used as X coordinate for floatey number

FlagpoleScoreNumTiles:
      .db $f9, $50
      .db $f7, $50
      .db $fa, $fb
      .db $f8, $fb
      .db $f6, $fb

FlagpoleGfxHandler:
      ldyx Enemy_SprDataOffset,x      ;get sprite data offset for flagpole flag
      lda Enemy_Rel_XPos             ;get relative horizontal coordinate
      stay Sprite_X_Position,y        ;store as X coordinate for first sprite
      clc
      adcn ++$08                       ;add eight pixels and store
      stay Sprite_X_Position+4,y      ;as X coordinate for second and third sprites
      stay Sprite_X_Position+8,y
      clc
      adcn ++$0c                       ;add twelve more pixels and
          push af
      sta SCRATCHPAD+$05                        ;store here to be used later by floatey number
      ldax Enemy_Y_Position,x         ;get vertical coordinate
      jsr DumpTwoSpr                 ;and do sub to dump into first and second sprites
          ld h,a
          pop af
          ld a,h
      adcn ++$08                       ;add eight pixels
      stay Sprite_Y_Position+8,y      ;and store into third sprite
      lda FlagpoleFNum_Y_Pos         ;get vertical coordinate for floatey number
      sta SCRATCHPAD+$02                        ;store it here
      ldan ++$01
      sta SCRATCHPAD+$03                        ;set value for flip which will not be used, and
      sta SCRATCHPAD+$04                        ;attribute byte for floatey number
      stay Sprite_Attributes,y        ;set attribute bytes for all three sprites
      stay Sprite_Attributes+4,y
      stay Sprite_Attributes+8,y
      ldan ++$7e
      stay Sprite_Tilenumber,y        ;put triangle shaped tile
      stay Sprite_Tilenumber+8,y      ;into first and third sprites
      ldan ++$7f
      stay Sprite_Tilenumber+4,y      ;put skull tile into second sprite
      lda FlagpoleCollisionYPos      ;get vertical coordinate at time of collision
         checka
      beq ChkFlagOffscreen           ;if zero, branch ahead
      tya
      clc                            ;add 12 bytes to sprite data offset
      adcn ++$0c
      tay                            ;put back in Y
      lda FlagpoleScore              ;get offset used to award points for touching flagpole
      asl                            ;multiply by 2 to get proper offset here
      tax
        if Z80OPT
      ld hl,FlagpoleScoreNumTiles
      add hl,bc
      call DrawSpriteObject
        else
      ldax FlagpoleScoreNumTiles,x    ;get appropriate tile data
      sta SCRATCHPAD+$00
      ldax FlagpoleScoreNumTiles+1,x
      jsr DrawOneSpriteRow           ;use it to render floatey number
        endif

ChkFlagOffscreen:
      ldx ObjectOffset               ;get object offset for flag
      ldyx Enemy_SprDataOffset,x      ;get OAM data offset
      lda Enemy_OffscreenBits        ;get offscreen bits
      andn ++%00001110                 ;mask out all but d3-d1
      beq ExitDumpSpr                ;if none of these bits set, branch to leave

;-------------------------------------------------------------------------------------

MoveSixSpritesOffscreen:
      ldan ++$f8                  ;set offscreen coordinate if jumping here

DumpSixSpr:
      stay Sprite_Data+20,y      ;dump A contents
      stay Sprite_Data+16,y      ;into third row sprites

DumpFourSpr:
      stay Sprite_Data+12,y      ;into second row sprites

DumpThreeSpr:
      stay Sprite_Data+8,y

DumpTwoSpr:
      stay Sprite_Data+4,y       ;and into first row sprites
      stay Sprite_Data,y

ExitDumpSpr:
      rts

;-------------------------------------------------------------------------------------

DrawLargePlatform:
      ldyx Enemy_SprDataOffset,x   ;get OAM data offset
      sty SCRATCHPAD+$02                     ;store here
      iny                         ;add 3 to it for offset
      iny                         ;to X coordinate
      iny
      lda Enemy_Rel_XPos          ;get horizontal relative coordinate
      jsr SixSpriteStacker        ;store X coordinates using A as base, stack horizontally
      ldx ObjectOffset
      ldax Enemy_Y_Position,x      ;get vertical coordinate
      jsr DumpFourSpr             ;dump into first four sprites as Y coordinate
      ldy AreaType
      cpyn ++$03                    ;check for castle-type level
      beq ShrinkPlatform
      ldy SecondaryHardMode       ;check for secondary hard mode flag set
         checky
      beq SetLast2Platform        ;branch if not set elsewhere

ShrinkPlatform:
      ldan ++$f8                    ;load offscreen coordinate if flag set or castle-type level

SetLast2Platform:
      ldyx Enemy_SprDataOffset,x   ;get OAM data offset
      stay Sprite_Y_Position+16,y  ;store vertical coordinate or offscreen
      stay Sprite_Y_Position+20,y  ;coordinate into last two sprites as Y coordinate
      ldan ++$5b                    ;load default tile for platform (girder)
      ldx CloudTypeOverride
         checkx
      beq SetPlatformTilenum      ;if cloud level override flag not set, use
      ldan ++$75                    ;otherwise load other tile for platform (puff)

SetPlatformTilenum:
;TODO через rla:jr nc,$+5;ld (ix),L
        ldx ObjectOffset            ;get enemy object buffer offset
        iny                         ;increment Y for tile offset
        jsr DumpSixSpr              ;dump tile number into all six sprites
        ldan ++$02                    ;set palette controls
        iny                         ;increment Y for sprite attributes
        jsr DumpSixSpr              ;dump attributes into all six sprites
        if Z80OPT
        push bc
      inc c                        ;increment X to get the proper offset
      call GetXOffscreenBits      ;then jump directly to the sub for horizontal offscreen bits
        pop bc                   ;decrement to return to original offset
        else
        inx                         ;increment X for enemy objects
        jsr GetXOffscreenBits       ;get offscreen bits again
        dex
        endif
        ldyx Enemy_SprDataOffset,x   ;get OAM data offset
        asl                         ;rotate d7 into carry, save remaining ;TODO >>4 в GetXOffscreenBits
        pha                         ;bits to the stack
        bcc SChk2
        ldan ++$f8                    ;if d7 was set, move first sprite offscreen
        stay Sprite_Y_Position,y
SChk2:  pla                         ;get bits from stack
        asl                         ;rotate d6 into carry ;TODO >>4 в GetXOffscreenBits
        pha                         ;save to stack
        bcc SChk3
        ldan ++$f8                    ;if d6 was set, move second sprite offscreen
        stay Sprite_Y_Position+4,y
SChk3:  pla                         ;get bits from stack
        asl                         ;rotate d5 into carry ;TODO >>4 в GetXOffscreenBits
        pha                         ;save to stack
        bcc SChk4
        ldan ++$f8                    ;if d5 was set, move third sprite offscreen
        stay Sprite_Y_Position+8,y
SChk4:  pla                         ;get bits from stack
        asl                         ;rotate d4 into carry ;TODO >>4 в GetXOffscreenBits
        pha                         ;save to stack
        bcc SChk5
        ldan ++$f8                    ;if d4 was set, move fourth sprite offscreen
        stay Sprite_Y_Position+12,y
SChk5:  pla                         ;get bits from stack
        asl                         ;rotate d3 into carry ;???
        pha                         ;save to stack
        bcc SChk6
        ldan ++$f8                    ;if d3 was set, move fifth sprite offscreen
        stay Sprite_Y_Position+16,y
SChk6:  pla                         ;get bits from stack
        asl                         ;rotate d2 into carry ;???
        bcc SLChk                   ;save to stack
        ldan ++$f8
        stay Sprite_Y_Position+20,y  ;if d2 was set, move sixth sprite offscreen
SLChk:  lda Enemy_OffscreenBits     ;check d7 of offscreen bits
        asl                         ;and if d7 is not set, skip sub
        bcc ExDLPl
        jsr MoveSixSpritesOffscreen ;otherwise branch to move all sprites offscreen
ExDLPl: rts

;-------------------------------------------------------------------------------------

DrawFloateyNumber_Coin:
          lda FrameCounter          ;get frame counter
          lsr                       ;divide by 2
          bcs NotRsNum              ;branch if d0 not set to raise number every other frame
          decx Misc_Y_Position,x     ;otherwise, decrement vertical coordinate
NotRsNum: ldax Misc_Y_Position,x     ;get vertical coordinate
          jsr DumpTwoSpr            ;dump into both sprites
          lda Misc_Rel_XPos         ;get relative horizontal coordinate
          stay Sprite_X_Position,y   ;store as X coordinate for first sprite
          clc
          adcn ++$08                  ;add eight pixels
          stay Sprite_X_Position+4,y ;store as X coordinate for second sprite
          ldan ++$02
          stay Sprite_Attributes,y   ;store attribute byte in both sprites
          stay Sprite_Attributes+4,y
          ldan ++$f7
          stay Sprite_Tilenumber,y   ;put tile numbers into both sprites
          ldan ++$fb                  ;that resemble "200"
          stay Sprite_Tilenumber+4,y
          jmp ExJCGfx               ;then jump to leave (why not an rts here instead?)

JumpingCoinTiles:
      .db $60, $61, $62, $63

JCoinGfxHandler:
         ldyx Misc_SprDataOffset,x    ;get coin/floatey number's OAM data offset
         ldax Misc_State,x            ;get state of misc object
         cmpn ++$02                    ;if 2 or greater, 
              cmpcy
         bcs DrawFloateyNumber_Coin  ;branch to draw floatey number
         ldax Misc_Y_Position,x       ;store vertical coordinate as
         stay Sprite_Y_Position,y     ;Y coordinate for first sprite
         clc
         adcn ++$08                    ;add eight pixels
         stay Sprite_Y_Position+4,y   ;store as Y coordinate for second sprite
         lda Misc_Rel_XPos           ;get relative horizontal coordinate
         stay Sprite_X_Position,y
         stay Sprite_X_Position+4,y   ;store as X coordinate for first and second sprites
         lda FrameCounter            ;get frame counter
         lsr                         ;divide by 2 to alter every other frame
         andn ++%00000011              ;mask out d2-d1
         tax                         ;use as graphical offset
         ldax JumpingCoinTiles,x      ;load tile number
         iny                         ;increment OAM data offset to write tile numbers
         jsr DumpTwoSpr              ;do sub to dump tile number into both sprites
         dey                         ;decrement to get old offset
         ldan ++$02
         stay Sprite_Attributes,y     ;set attribute byte in first sprite
         ldan ++$82
         stay Sprite_Attributes+4,y   ;set attribute byte with vertical flip in second sprite
         ldx ObjectOffset            ;get misc object offset
ExJCGfx: rts                         ;leave

;-------------------------------------------------------------------------------------
;$00-$01 - used to hold tiles for drawing the power-up, $00 also used to hold power-up type
;$02 - used to hold bottom row Y position
;$03 - used to hold flip control (not used here)
;$04 - used to hold sprite attributes
;$05 - used to hold X position
;$07 - counter

;tiles arranged in top left, right, bottom left, right order
PowerUpGfxTable:
      .db $76, $77, $78, $79 ;regular mushroom
      .db $d6, $d6, $d9, $d9 ;fire flower
      .db $8d, $8d, $e4, $e4 ;star
      .db $76, $77, $78, $79 ;1-up mushroom

PowerUpAttributes:
      .db $02, $01, $02, $01

DrawPowerUp:
      ldy Enemy_SprDataOffset+5  ;get power-up's sprite data offset
      lda Enemy_Rel_YPos         ;get relative vertical coordinate
      clc
      adcn ++$08                   ;add eight pixels
      sta SCRATCHPAD+$02                    ;store result here
      lda Enemy_Rel_XPos         ;get relative horizontal coordinate
      sta SCRATCHPAD+$05                    ;store here
      ldx PowerUpType            ;get power-up type
      ldax PowerUpAttributes,x    ;get attribute data for power-up type
      orai Enemy_SprAttrib+5      ;add background priority bit if set
      sta SCRATCHPAD+$04                    ;store attributes here
      txa
      pha                        ;save power-up type to the stack
      asl
      asl                        ;multiply by four to get proper offset
      tax                        ;use as X
      ldan ++$01
        if Z80OPT
      ;ld (SCRATCHPAD+$07),a                    ;set counter here to draw two rows of sprite object
      ld (SCRATCHPAD+$03),a                    ;init d1 of flip control
      ld hl,PowerUpGfxTable
      add hl,bc
      call DrawSpriteObject
      call DrawSpriteObject
        else
      sta SCRATCHPAD+$07                    ;set counter here to draw two rows of sprite object
      sta SCRATCHPAD+$03                    ;init d1 of flip control
PUpDrawLoop0
        ldax PowerUpGfxTable,x      ;load left tile of power-up object
        sta SCRATCHPAD+$00
        ldax PowerUpGfxTable+1,x    ;load right tile
        jsr DrawOneSpriteRow       ;branch to draw one row of our power-up object
        deci SCRATCHPAD+$07                    ;decrement counter
        bpl PUpDrawLoop0            ;branch until two rows are drawn
        endif
        ldy Enemy_SprDataOffset+5  ;get sprite data offset again
        pla                        ;pull saved power-up type from the stack
         checka
        beq PUpOfs                 ;if regular mushroom, branch, do not change colors or flip
        cmpn ++$03
        beq PUpOfs                 ;if 1-up mushroom, branch, do not change colors or flip
        sta SCRATCHPAD+$00                    ;store power-up type here now
        lda FrameCounter           ;get frame counter
        lsr                        ;divide by 2 to change colors every two frames
        andn ++%00000011             ;mask out all but d1 and d0 (previously d2 and d1)
        orai Enemy_SprAttrib+5      ;add background priority bit if any set
        stay Sprite_Attributes,y    ;set as new palette bits for top left and
        stay Sprite_Attributes+4,y  ;top right sprites for fire flower and star
        ldx SCRATCHPAD+$00
        dex                        ;check power-up type for fire flower
        beq FlipPUpRightSide       ;if found, skip this part
        stay Sprite_Attributes+8,y  ;otherwise set new palette bits  for bottom left
        stay Sprite_Attributes+12,y ;and bottom right sprites as well for star only

FlipPUpRightSide:
        lday Sprite_Attributes+4,y
        oran ++%01000000             ;set horizontal flip bit for top right sprite
        stay Sprite_Attributes+4,y
        lday Sprite_Attributes+12,y
        oran ++%01000000             ;set horizontal flip bit for bottom right sprite
        stay Sprite_Attributes+12,y ;note these are only done for fire flower and star power-ups
PUpOfs: jmp SprObjectOffscrChk     ;jump to check to see if power-up is offscreen at all, then leave

;-------------------------------------------------------------------------------------
;$00-$01 - used in DrawEnemyObjRow to hold sprite tile numbers
;$02 - used to store Y position
;$03 - used to store moving direction, used to flip enemies horizontally
;$04 - used to store enemy's sprite attributes
;$05 - used to store X position
;$eb - used to hold sprite data offset
;$ec - used to hold either altered enemy state or special value used in gfx handler as condition
;$ed - used to hold enemy state from buffer 
;$ef - used to hold enemy code used in gfx handler (may or may not resemble Enemy_ID values)

;tiles arranged in top left, right, middle left, right, bottom left, right order
EnemyGraphicsTable:
      .db $fc, $fc, $aa, $ab, $ac, $ad  ;buzzy beetle frame 1
      .db $fc, $fc, $ae, $af, $b0, $b1  ;             frame 2
      .db $fc, $a5, $a6, $a7, $a8, $a9  ;koopa troopa frame 1
      .db $fc, $a0, $a1, $a2, $a3, $a4  ;             frame 2
      .db $69, $a5, $6a, $a7, $a8, $a9  ;koopa paratroopa frame 1
      .db $6b, $a0, $6c, $a2, $a3, $a4  ;                 frame 2
      .db $fc, $fc, $96, $97, $98, $99  ;spiny frame 1
      .db $fc, $fc, $9a, $9b, $9c, $9d  ;      frame 2
      .db $fc, $fc, $8f, $8e, $8e, $8f  ;spiny's egg frame 1
      .db $fc, $fc, $95, $94, $94, $95  ;            frame 2
      .db $fc, $fc, $dc, $dc, $df, $df  ;bloober frame 1
      .db $dc, $dc, $dd, $dd, $de, $de  ;        frame 2
      .db $fc, $fc, $b2, $b3, $b4, $b5  ;cheep-cheep frame 1
      .db $fc, $fc, $b6, $b3, $b7, $b5  ;            frame 2
      .db $fc, $fc, $70, $71, $72, $73  ;goomba
      .db $fc, $fc, $6e, $6e, $6f, $6f  ;koopa shell frame 1 (upside-down)
      .db $fc, $fc, $6d, $6d, $6f, $6f  ;            frame 2
      .db $fc, $fc, $6f, $6f, $6e, $6e  ;koopa shell frame 1 (rightsideup)
      .db $fc, $fc, $6f, $6f, $6d, $6d  ;            frame 2
      .db $fc, $fc, $f4, $f4, $f5, $f5  ;buzzy beetle shell frame 1 (rightsideup)
      .db $fc, $fc, $f4, $f4, $f5, $f5  ;                   frame 2
      .db $fc, $fc, $f5, $f5, $f4, $f4  ;buzzy beetle shell frame 1 (upside-down)
      .db $fc, $fc, $f5, $f5, $f4, $f4  ;                   frame 2
      .db $fc, $fc, $fc, $fc, $ef, $ef  ;defeated goomba
      .db $b9, $b8, $bb, $ba, $bc, $bc  ;lakitu frame 1
      .db $fc, $fc, $bd, $bd, $bc, $bc  ;       frame 2
      .db $7a, $7b, $da, $db, $d8, $d8  ;princess
      .db $cd, $cd, $ce, $ce, $cf, $cf  ;mushroom retainer
      .db $7d, $7c, $d1, $8c, $d3, $d2  ;hammer bro frame 1
      .db $7d, $7c, $89, $88, $8b, $8a  ;           frame 2
      .db $d5, $d4, $e3, $e2, $d3, $d2  ;           frame 3
      .db $d5, $d4, $e3, $e2, $8b, $8a  ;           frame 4
      .db $e5, $e5, $e6, $e6, $eb, $eb  ;piranha plant frame 1
      .db $ec, $ec, $ed, $ed, $ee, $ee  ;              frame 2
      .db $fc, $fc, $d0, $d0, $d7, $d7  ;podoboo
      .db $bf, $be, $c1, $c0, $c2, $fc  ;bowser front frame 1
      .db $c4, $c3, $c6, $c5, $c8, $c7  ;bowser rear frame 1
      .db $bf, $be, $ca, $c9, $c2, $fc  ;       front frame 2
      .db $c4, $c3, $c6, $c5, $cc, $cb  ;       rear frame 2
      .db $fc, $fc, $e8, $e7, $ea, $e9  ;bullet bill
      .db $f2, $f2, $f3, $f3, $f2, $f2  ;jumpspring frame 1
      .db $f1, $f1, $f1, $f1, $fc, $fc  ;           frame 2
      .db $f0, $f0, $fc, $fc, $fc, $fc  ;           frame 3

EnemyGfxTableOffsets:
      .db $0c, $0c, $00, $0c, $0c, $a8, $54, $3c
      .db $ea, $18, $48, $48, $cc, $c0, $18, $18
      .db $18, $90, $24, $ff, $48, $9c, $d2, $d8
      .db $f0, $f6, $fc

EnemyAttributeData:
      .db $01, $02, $03, $02, $01, $01, $03, $03
      .db $03, $01, $01, $02, $02, $21, $01, $02
      .db $01, $01, $02, $ff, $02, $02, $01, $01
      .db $02, $02, $02

EnemyAnimTimingBMask:
      .db $08, $18

JumpspringFrameOffsets:
      .db $18, $19, $1a, $19, $18

EnemyGfxHandler:
;TODO вместо этого дерева ветвлений сделать переход по типу объекта по таблице, дальше ветвить
      ldax Enemy_Y_Position,x      ;get enemy object vertical position
      sta SCRATCHPAD+$02
      lda Enemy_Rel_XPos          ;get enemy object horizontal position
      sta SCRATCHPAD+$05                     ;relative to screen
      ldyx Enemy_SprDataOffset,x
      sty SCRATCHPAD+$eb                     ;get sprite data offset
      ldan ++$00
      sta VerticalFlipFlag        ;initialize vertical flip flag by default
      ldax Enemy_MovingDir,x
      sta SCRATCHPAD+$03                     ;get enemy object moving direction
      ldax Enemy_SprAttrib,x
      sta SCRATCHPAD+$04                     ;get enemy object sprite attributes
      ldax Enemy_ID,x
      
      cmpn ++PiranhaPlant           ;is enemy object piranha plant?
     bne CheckForRetainerObj     ;if not, branch
      ldyx PiranhaPlant_Y_Speed,x
         checky
     bmi CheckForRetainerObj     ;if piranha plant moving upwards, branch
      ldyx EnemyFrameTimer,x
         checky
     beq CheckForRetainerObj     ;if timer for movement expired, branch
      rts                         ;if all conditions fail, leave

CheckForRetainerObj:
      ldax Enemy_State,x           ;store enemy state
      sta SCRATCHPAD+$ed
      andn ++%00011111              ;nullify all but 5 LSB and use as Y
      tay
      ldax Enemy_ID,x              ;check for mushroom retainer/princess object
      cmpn ++RetainerObject
     bne CheckForBulletBillCV    ;if not found, branch
      ldyn ++$00                    ;if found, nullify saved state in Y
      ldan ++$01                    ;set value that will not be used
      sta SCRATCHPAD+$03
      ldan ++$15                    ;set value $15 as code for mushroom retainer/princess object

CheckForBulletBillCV:
       cmpn ++BulletBill_CannonVar   ;otherwise check for bullet bill object
      bne CheckForJumpspring      ;if not found, branch again
       deci SCRATCHPAD+$02                     ;decrement saved vertical position
       ldan ++$03
       ldyx EnemyFrameTimer,x       ;get timer for enemy object
         checky
       beq SBBAt                   ;if expired, do not set priority bit
       oran ++%00100000              ;otherwise do so
SBBAt: sta SCRATCHPAD+$04                     ;set new sprite attributes
       ldyn ++$00                    ;nullify saved enemy state both in Y and in
       sty SCRATCHPAD+$ed                     ;memory location here
       ldan ++$08                    ;set specific value to unconditionally branch once

CheckForJumpspring:
      cmpn ++JumpspringObject        ;check for jumpspring object
     bne CheckForPodoboo
      ldyn ++$03                     ;set enemy state -2 MSB here for jumpspring object
      ldx JumpspringAnimCtrl       ;get current frame number for jumpspring object
      ldax JumpspringFrameOffsets,x ;load data using frame number as offset

CheckForPodoboo:
      sta SCRATCHPAD+$ef                 ;store saved enemy object value here
      sty SCRATCHPAD+$ec                 ;and Y here (enemy state -2 MSB if not changed)
      ldx ObjectOffset        ;get enemy object offset
      cmpn ++$0c                ;check for podoboo object
     bne CheckBowserGfxFlag  ;branch if not found
      ldax Enemy_Y_Speed,x     ;if moving upwards, branch
         checka
     bmi CheckBowserGfxFlag
      inci VerticalFlipFlag    ;otherwise, set flag for vertical flip

CheckBowserGfxFlag:
             lda BowserGfxFlag   ;if not drawing bowser at all, skip to something else
         checka
      beq CheckForGoomba
             ldyn ++$16            ;if set to 1, draw bowser's front
             cmpn ++$01
             beq SBwsrGfxOfs
             iny                 ;otherwise draw bowser's rear
SBwsrGfxOfs: sty SCRATCHPAD+$ef

CheckForGoomba:
;досюда 485t
          ldy SCRATCHPAD+$ef               ;check value for goomba object
          cpyn ++Goomba
       bne CheckBowserFront  ;branch if not found
          ldax Enemy_State,x
          cmpn ++$02              ;check for defeated state
              cmpcy
          bcc GmbaAnim          ;if not defeated, go ahead and animate
          ldxn ++$04              ;if defeated, write new value here
          stx SCRATCHPAD+$ec
GmbaAnim: andn ++%00100000        ;check for d5 set in enemy object state 
          orai TimerControl      ;or timer disable flag set
        bne CheckBowserFront  ;if either condition true, do not animate goomba
          lda FrameCounter
          andn ++%00001000        ;check for every eighth frame
        bne CheckBowserFront
          lda SCRATCHPAD+$03
          eorn ++%00000011        ;invert bits to flip horizontally every eight frames
          sta SCRATCHPAD+$03               ;leave alone otherwise

CheckBowserFront:
             lday EnemyAttributeData,y    ;load sprite attribute using enemy object
             orai SCRATCHPAD+$04                     ;as offset, and add to bits already loaded
             sta SCRATCHPAD+$04
             lday EnemyGfxTableOffsets,y  ;load value based on enemy object as offset
             tax                         ;save as X
             ldy SCRATCHPAD+$ec                     ;get previously saved value
             lda BowserGfxFlag
         checka
       beq CheckForSpiny           ;if not drawing bowser object at all, skip all of this
             cmpn ++$01
             bne CheckBowserRear         ;if not drawing front part, branch to draw the rear part
             lda BowserBodyControls      ;check bowser's body control bits
         checka
             bpl ChkFrontSte             ;branch if d7 not set (control's bowser's mouth)      
             ldxn ++$de                    ;otherwise load offset for second frame
ChkFrontSte: lda SCRATCHPAD+$ed                     ;check saved enemy state
             andn ++%00100000              ;if bowser not defeated, do not set flag
             beq DrawBowser

FlipBowserOver:
      stx VerticalFlipFlag  ;set vertical flip flag to nonzero

DrawBowser:
      jmp DrawEnemyObject   ;draw bowser's graphics now

CheckBowserRear:
            lda BowserBodyControls  ;check bowser's body control bits
            andn ++$01
            beq ChkRearSte          ;branch if d0 not set (control's bowser's feet)
            ldxn ++$e4                ;otherwise load offset for second frame
ChkRearSte: lda SCRATCHPAD+$ed                 ;check saved enemy state
            andn ++%00100000          ;if bowser not defeated, do not set flag
            beq DrawBowser
            lda SCRATCHPAD+$02                 ;subtract 16 pixels from
            secsub                     ;saved vertical coordinate
            sbcn ++$10
            sta SCRATCHPAD+$02
            jmp FlipBowserOver      ;jump to set vertical flip flag

CheckForSpiny:
        cpxn ++$24               ;check if value loaded is for spiny
       bne CheckForLakitu     ;if not found, branch
        cpyn ++$05               ;if enemy state set to $05, do this,
        bne NotEgg             ;otherwise branch
        ldxn ++$30               ;set to spiny egg offset
        ldan ++$02
        sta SCRATCHPAD+$03                ;set enemy direction to reverse sprites horizontally
        ldan ++$05
        sta SCRATCHPAD+$ec                ;set enemy state
NotEgg: jmp CheckForHammerBro  ;skip a big chunk of this if we found spiny but not in egg

CheckForLakitu:
        cpxn ++$90                  ;check value for lakitu's offset loaded
       bne CheckUpsideDownShell  ;branch if not loaded
        lda SCRATCHPAD+$ed
        andn ++%00100000            ;check for d5 set in enemy state
        bne NoLAFr                ;branch if set
        lda FrenzyEnemyTimer
        cmpn ++$10                  ;check timer to see if we've reached a certain range
              cmpcy
        bcs NoLAFr                ;branch if not
        ldxn ++$96                  ;if d6 not set and timer in range, load alt frame for lakitu
NoLAFr: jmp CheckDefeatedState    ;skip this next part if we found lakitu but alt frame not needed

CheckUpsideDownShell:
      lda SCRATCHPAD+$ef                    ;check for enemy object => $04
      cmpn ++$04
              cmpcy
     bcs CheckRightSideUpShell  ;branch if true
      cpyn ++$02
              cmpcy
     bcc CheckRightSideUpShell  ;branch if enemy state < $02
      ldxn ++$5a                   ;set for upside-down koopa shell by default
      ldy SCRATCHPAD+$ef
      cpyn ++BuzzyBeetle           ;check for buzzy beetle object
     bne CheckRightSideUpShell
      ldxn ++$7e                   ;set for upside-down buzzy beetle shell if found
      inci SCRATCHPAD+$02                    ;increment vertical position by one pixel

CheckRightSideUpShell:
      lda SCRATCHPAD+$ec                ;check for value set here
      cmpn ++$04               ;if enemy state < $02, do not change to shell, if
     bne CheckForHammerBro  ;enemy state => $02 but not = $04, leave shell upside-down
      ldxn ++$72               ;set right-side up buzzy beetle shell by default
      inci SCRATCHPAD+$02                ;increment saved vertical position by one pixel
      ldy SCRATCHPAD+$ef
      cpyn ++BuzzyBeetle       ;check for buzzy beetle object
     beq CheckForDefdGoomba ;branch if found
      ldxn ++$66               ;change to right-side up koopa shell if not found
      inci SCRATCHPAD+$02                ;and increment saved vertical position again

CheckForDefdGoomba:
      cpyn ++Goomba            ;check for goomba object (necessary if previously
     bne CheckForHammerBro  ;failed buzzy beetle object test)
      ldxn ++$54               ;load for regular goomba
      lda SCRATCHPAD+$ed                ;note that this only gets performed if enemy state => $02
      andn ++%00100000         ;check saved enemy state for d5 set
     bne CheckForHammerBro  ;branch if set
      ldxn ++$8a               ;load offset for defeated goomba
      deci SCRATCHPAD+$02                ;set different value and decrement saved vertical position

CheckForHammerBro:
      ldy ObjectOffset
      lda SCRATCHPAD+$ef                  ;check for hammer bro object
      cmpn ++HammerBro
     bne CheckForBloober      ;branch if not found
      lda SCRATCHPAD+$ed
         checka
     beq CheckToAnimateEnemy  ;branch if not in normal enemy state
      andn ++%00001000
     beq CheckDefeatedState   ;if d3 not set, branch further away
      ldxn ++$b4                 ;otherwise load offset for different frame
         checkx
     bne CheckToAnimateEnemy  ;unconditional branch

CheckForBloober:
      cpxn ++$48                 ;check for cheep-cheep offset loaded
     beq CheckToAnimateEnemy  ;branch if found
      lday EnemyIntervalTimer,y
      cmpn ++$05
              cmpcy
     bcs CheckDefeatedState   ;branch if some timer is above a certain point
      cpxn ++$3c                 ;check for bloober offset loaded
     bne CheckToAnimateEnemy  ;branch if not found this time
      cmpn ++$01
     beq CheckDefeatedState   ;branch if timer is set to certain point
      inci SCRATCHPAD+$02                  ;increment saved vertical coordinate three pixels
      inci SCRATCHPAD+$02
      inci SCRATCHPAD+$02
      jmp CheckAnimationStop   ;and do something else

CheckToAnimateEnemy:
      lda SCRATCHPAD+$ef                  ;check for specific enemy objects
      cmpn ++Goomba
     beq CheckDefeatedState   ;branch if goomba
      cmpn ++$08
     beq CheckDefeatedState   ;branch if bullet bill (note both variants use $08 here)
      cmpn ++Podoboo
     beq CheckDefeatedState   ;branch if podoboo
      cmpn ++$18                 ;branch if => $18
              cmpcy
      bcs CheckDefeatedState
      ldyn ++$00    
      cmpn ++$15                 ;check for mushroom retainer/princess object
       ;jr $
      bne CheckForSecondFrame  ;which uses different code here, branch if not found
      iny                      ;residual instruction
      lda WorldNumber          ;are we on world 8?
      cmpn ++World8
              cmpcy
	if ALWAYSPRINCESS
	scf
	endif
      bcs CheckDefeatedState   ;if so, leave the offset alone (use princess)
      ldxn ++$a2                 ;otherwise, set for mushroom retainer object instead
      ldan ++$03                 ;set alternate state here
      sta SCRATCHPAD+$ec
         checka
      bne CheckDefeatedState   ;unconditional branch

CheckForSecondFrame:
      lda FrameCounter            ;load frame counter
      andy EnemyAnimTimingBMask,y  ;mask it (partly residual, one byte not ever used)
      bne CheckDefeatedState      ;branch if timing is off

CheckAnimationStop:
      lda SCRATCHPAD+$ed                 ;check saved enemy state
      andn ++%10100000          ;for d7 or d5, or check for timers stopped
      orai TimerControl
      bne CheckDefeatedState  ;if either condition true, branch
      txa
      clc
      adcn ++$06                ;add $06 to current enemy offset
      tax                     ;to animate various enemy objects

CheckDefeatedState:
      lda SCRATCHPAD+$ed               ;check saved enemy state
      andn ++%00100000        ;for d5 set
     beq DrawEnemyObject   ;branch if not set
      lda SCRATCHPAD+$ef
      cmpn ++$04              ;check for saved enemy object => $04
              cmpcy
     bcc DrawEnemyObject   ;branch if less
      ldyn ++$01
      sty VerticalFlipFlag  ;set vertical flip flag
      dey
      sty SCRATCHPAD+$ec               ;init saved value here

DrawEnemyObject:
;досюда 1118t (от начала процедуры)
      ldy SCRATCHPAD+$eb                    ;load sprite data offset
        if Z80OPT
        ld hl,EnemyGraphicsTable
        add hl,bc
        call DrawSpriteObject ;360t
        call DrawSpriteObject ;360t
        call DrawSpriteObject ;360t
        else
      jsr DrawEnemyObjRow        ;draw six tiles of data
      jsr DrawEnemyObjRow        ;into sprite data
      jsr DrawEnemyObjRow
        endif
;до выхода ещё 1030t (невидимый Goomba)/604t (видимый)
      ldx ObjectOffset           ;get enemy object offset
      ldyx Enemy_SprDataOffset,x  ;get sprite data offset
      lda SCRATCHPAD+$ef
      cmpn ++$08                   ;get saved enemy object and check
      bne CheckForVerticalFlip   ;for bullet bill, branch if not found

SkipToOffScrChk:
      jmp SprObjectOffscrChk     ;jump if found

CheckForVerticalFlip:
      lda VerticalFlipFlag       ;check if vertical flip flag is set here
         checka
      beq CheckForESymmetry      ;branch if not
      lday Sprite_Attributes,y    ;get attributes of first sprite we dealt with
      oran ++%10000000             ;set bit for vertical flip
      iny
      iny                        ;increment two bytes so that we store the vertical flip
      jsr DumpSixSpr             ;in attribute bytes of enemy obj sprite data
      dey
      dey                        ;now go back to the Y coordinate offset
      tya
      tax                        ;give offset to X
      lda SCRATCHPAD+$ef
      cmpn ++HammerBro             ;check saved enemy object for hammer bro
      beq FlipEnemyVertically
      cmpn ++Lakitu                ;check saved enemy object for lakitu
      beq FlipEnemyVertically    ;branch for hammer bro or lakitu
      cmpn ++$15
              cmpcy
      bcs FlipEnemyVertically    ;also branch if enemy object => $15
      txa
      clc
      adcn ++$08                   ;if not selected objects or => $15, set
      tax                        ;offset in X for next row

FlipEnemyVertically:
      ldax Sprite_Tilenumber,x     ;load first or second row tiles
      pha                         ;and save tiles to the stack
      ldax Sprite_Tilenumber+4,x
      pha
      lday Sprite_Tilenumber+16,y  ;exchange third row tiles
      stax Sprite_Tilenumber,x     ;with first or second row tiles
      lday Sprite_Tilenumber+20,y
      stax Sprite_Tilenumber+4,x
      pla                         ;pull first or second row tiles from stack
      stay Sprite_Tilenumber+20,y  ;and save in third row
      pla
      stay Sprite_Tilenumber+16,y

CheckForESymmetry:
        lda BowserGfxFlag           ;are we drawing bowser at all?
         checka
        bne SkipToOffScrChk         ;branch if so
        lda SCRATCHPAD+$ef       
        ldx SCRATCHPAD+$ec                     ;get alternate enemy state
        cmpn ++$05                    ;check for hammer bro object
        bne ContES
        jmp SprObjectOffscrChk      ;jump if found
ContES: cmpn ++Bloober                ;check for bloober object
        beq MirrorEnemyGfx
        cmpn ++PiranhaPlant           ;check for piranha plant object
        beq MirrorEnemyGfx
        cmpn ++Podoboo                ;check for podoboo object
        beq MirrorEnemyGfx          ;branch if either of three are found
        cmpn ++Spiny                  ;check for spiny object
        bne ESRtnr                  ;branch closer if not found
        cpxn ++$05                    ;check spiny's state
        bne CheckToMirrorLakitu     ;branch if not an egg, otherwise
ESRtnr: cmpn ++$15                    ;check for princess/mushroom retainer object
        bne SpnySC
        ldan ++$42                    ;set horizontal flip on bottom right sprite
        stay Sprite_Attributes+20,y  ;note that palette bits were already set earlier
SpnySC: cpxn ++$02                    ;if alternate enemy state set to 1 or 0, branch
              cmpcy
        bcc CheckToMirrorLakitu

MirrorEnemyGfx:
        lda BowserGfxFlag           ;if enemy object is bowser, skip all of this
         checka
        bne CheckToMirrorLakitu
        lday Sprite_Attributes,y     ;load attribute bits of first sprite
        andn ++%10100011
        stay Sprite_Attributes,y     ;save vertical flip, priority, and palette bits
        stay Sprite_Attributes+8,y   ;in left sprite column of enemy object OAM data
        stay Sprite_Attributes+16,y
        oran ++%01000000              ;set horizontal flip
        cpxn ++$05                    ;check for state used by spiny's egg
        bne EggExc                  ;if alternate state not set to $05, branch
        oran ++%10000000              ;otherwise set vertical flip
EggExc: stay Sprite_Attributes+4,y   ;set bits of right sprite column
        stay Sprite_Attributes+12,y  ;of enemy object sprite data
        stay Sprite_Attributes+20,y
        cpxn ++$04                    ;check alternate enemy state
        bne CheckToMirrorLakitu     ;branch if not $04
        lday Sprite_Attributes+8,y   ;get second row left sprite attributes
        oran ++%10000000
        stay Sprite_Attributes+8,y   ;store bits with vertical flip in
        stay Sprite_Attributes+16,y  ;second and third row left sprites
        oran ++%01000000
        stay Sprite_Attributes+12,y  ;store with horizontal and vertical flip in
        stay Sprite_Attributes+20,y  ;second and third row right sprites

CheckToMirrorLakitu:
        lda SCRATCHPAD+$ef                     ;check for lakitu enemy object
        cmpn ++Lakitu
        bne CheckToMirrorJSpring    ;branch if not found
        lda VerticalFlipFlag
         checka
        bne NVFLak                  ;branch if vertical flip flag not set
        lday Sprite_Attributes+16,y  ;save vertical flip and palette bits
        andn ++%10000001              ;in third row left sprite
        stay Sprite_Attributes+16,y
        lday Sprite_Attributes+20,y  ;set horizontal flip and palette bits
        oran ++%01000001              ;in third row right sprite
        stay Sprite_Attributes+20,y
        ldx FrenzyEnemyTimer        ;check timer
        cpxn ++$10
              cmpcy
        bcs SprObjectOffscrChk      ;branch if timer has not reached a certain range
        stay Sprite_Attributes+12,y  ;otherwise set same for second row right sprite
        andn ++%10000001
        stay Sprite_Attributes+8,y   ;preserve vertical flip and palette bits for left sprite
       if Z80
       or a
       endif
        bcc SprObjectOffscrChk      ;unconditional branch
NVFLak: lday Sprite_Attributes,y     ;get first row left sprite attributes
        andn ++%10000001
        stay Sprite_Attributes,y     ;save vertical flip and palette bits
        lday Sprite_Attributes+4,y   ;get first row right sprite attributes
        oran ++%01000001              ;set horizontal flip and palette bits
        stay Sprite_Attributes+4,y   ;note that vertical flip is left as-is

CheckToMirrorJSpring:
      lda SCRATCHPAD+$ef                     ;check for jumpspring object (any frame)
      cmpn ++$18
              cmpcy
      bcc SprObjectOffscrChk      ;branch if not jumpspring object at all
      ldan ++$82
      stay Sprite_Attributes+8,y   ;set vertical flip and palette bits of 
      stay Sprite_Attributes+16,y  ;second and third row left sprites
      oran ++%01000000
      stay Sprite_Attributes+12,y  ;set, in addition to those, horizontal flip
      stay Sprite_Attributes+20,y  ;for second and third row right sprites

SprObjectOffscrChk:
;отсюда до выхода ещё 238t (видимый Goomba)
         ldx ObjectOffset          ;get enemy buffer offset
         lda Enemy_OffscreenBits   ;check offscreen information
         lsr
         lsr                       ;shift three times to the right
         lsr                       ;which puts d2 into carry
         pha                       ;save to stack
         bcc LcChk                 ;branch if not set
         ldan ++$04                  ;set for right column sprites
         jsr MoveESprColOffscreen  ;and move them offscreen
LcChk:   pla                       ;get from stack
         lsr                       ;move d3 to carry
         pha                       ;save to stack
         bcc Row3C                 ;branch if not set
         ldan ++$00                  ;set for left column sprites,
         jsr MoveESprColOffscreen  ;move them offscreen
Row3C:   pla                       ;get from stack again
         lsr                       ;move d5 to carry this time
         lsr
         pha                       ;save to stack again
         bcc Row23C                ;branch if carry not set
         ldan ++$10                  ;set for third row of sprites
         jsr MoveESprRowOffscreen  ;and move them offscreen
Row23C:  pla                       ;get from stack
         lsr                       ;move d6 into carry
         pha                       ;save to stack
         bcc AllRowC
         ldan ++$08                  ;set for second and third rows
         jsr MoveESprRowOffscreen  ;move them offscreen
AllRowC: pla                       ;get from stack once more
         lsr                       ;move d7 into carry
         bcc ExEGHandler
         jsr MoveESprRowOffscreen  ;move all sprites offscreen (A should be 0 by now)
         ldax Enemy_ID,x
         cmpn ++Podoboo              ;check enemy identifier for podoboo
         beq ExEGHandler           ;skip this part if found, we do not want to erase podoboo!
         ldax Enemy_Y_HighPos,x     ;check high byte of vertical position
         cmpn ++$02                  ;if not yet past the bottom of the screen, branch
         bne ExEGHandler
         jsr EraseEnemyObject      ;what it says

ExEGHandler:
      rts

        if Z80OPT
        else
DrawEnemyObjRow:
      ldax EnemyGraphicsTable,x    ;load two tiles of enemy graphics
      sta SCRATCHPAD+$00
      ldax EnemyGraphicsTable+1,x
DrawOneSpriteRow:
      sta SCRATCHPAD+$01
      jmp DrawSpriteObject        ;draw them
        endif

MoveESprRowOffscreen:
      clc                         ;add A to enemy object OAM data offset
      adcx Enemy_SprDataOffset,x
      tay                         ;use as offset
      ldan ++$f8
      jmp DumpTwoSpr              ;move first row of sprites offscreen

MoveESprColOffscreen:
      clc                         ;add A to enemy object OAM data offset
      adcx Enemy_SprDataOffset,x
      tay                         ;use as offset
      jsr MoveColOffscreen        ;move first and second row sprites in column offscreen
      stay Sprite_Data+16,y        ;move third row sprite in column offscreen
      rts

;-------------------------------------------------------------------------------------
;$00-$01 - tile numbers
;$02 - relative Y position
;$03 - horizontal flip flag (not used here)
;$04 - attributes
;$05 - relative X position

DefaultBlockObjTiles:
      .db $85, $85, $86, $86             ;brick w/ line (these are sprite tiles, not BG!)

DrawBlock:
           lda Block_Rel_YPos            ;get relative vertical coordinate of block object
           sta SCRATCHPAD+$02                       ;store here
           lda Block_Rel_XPos            ;get relative horizontal coordinate of block object
           sta SCRATCHPAD+$05                       ;store here
           ldan ++$03
           sta SCRATCHPAD+$04                       ;set attribute byte here
           lsr
           sta SCRATCHPAD+$03                       ;set horizontal flip bit here (will not be used) ???
           ldyx Block_SprDataOffset,x     ;get sprite data offset
        if Z80OPT
      ld hl,DefaultBlockObjTiles
      ;add hl,bc
      call DrawSpriteObject
      call DrawSpriteObject
        else
           ldxn ++$00                      ;reset X for use as offset to tile data
DBlkLoop:  
           ldax DefaultBlockObjTiles,x    ;get left tile number
           sta SCRATCHPAD+$00                       ;set here
           ldax DefaultBlockObjTiles+1,x  ;get right tile number
           jsr DrawOneSpriteRow          ;do sub to write tile numbers to first row of sprites
           cpxn ++$04                      ;check incremented offset
           bne DBlkLoop                  ;and loop back until all four sprites are done
        endif
           ldx ObjectOffset              ;get block object offset
           ldyx Block_SprDataOffset,x     ;get sprite data offset
           lda AreaType
           cmpn ++$01                      ;check for ground level type area
           beq ChkRep                    ;if found, branch to next part
           ldan ++$86
           stay Sprite_Tilenumber,y       ;otherwise remove brick tiles with lines
           stay Sprite_Tilenumber+4,y     ;and replace then with lineless brick tiles
ChkRep:    ldax Block_Metatile,x          ;check replacement metatile
           cmpn ++$c4                      ;if not used block metatile, then
           bne BlkOffscr                 ;branch ahead to use current graphics
           ldan ++$87                      ;set A for used block tile
           iny                           ;increment Y to write to tile bytes
           jsr DumpFourSpr               ;do sub to dump into all four sprites
           dey                           ;return Y to original offset
           ldan ++$03                      ;set palette bits
           ldx AreaType
           dex                           ;check for ground level type area again
           beq SetBFlip                  ;if found, use current palette bits
           lsr                           ;otherwise set to $01
SetBFlip:  ldx ObjectOffset              ;put block object offset back in X
           stay Sprite_Attributes,y       ;store attribute byte as-is in first sprite
           oran ++%01000000
           stay Sprite_Attributes+4,y     ;set horizontal flip bit for second sprite
           oran ++%10000000
           stay Sprite_Attributes+12,y    ;set both flip bits for fourth sprite
           andn ++%10000011
           stay Sprite_Attributes+8,y     ;set vertical flip bit for third sprite
BlkOffscr: lda Block_OffscreenBits       ;get offscreen bits for block object
           pha                           ;save to stack
           andn ++%00000100                ;check to see if d2 in offscreen bits are set
           beq PullOfsB                  ;if not set, branch, otherwise move sprites offscreen
           ldan ++$f8                      ;move offscreen two OAMs
           stay Sprite_Y_Position+4,y     ;on the right side
           stay Sprite_Y_Position+12,y
PullOfsB:  pla                           ;pull offscreen bits from stack
ChkLeftCo: andn ++%00001000                ;check to see if d3 in offscreen bits are set
           beq ExDBlk                    ;if not set, branch, otherwise move sprites offscreen

MoveColOffscreen:
        ldan ++$f8                   ;move offscreen two OAMs
        stay Sprite_Y_Position,y    ;on the left side (or two rows of enemy on either side
        stay Sprite_Y_Position+8,y  ;if branched here from enemy graphics handler)
ExDBlk: rts

;-------------------------------------------------------------------------------------
;$00 - used to hold palette bits for attribute byte or relative X position

DrawBrickChunks:
         ldan ++$02                   ;set palette bits here
         sta SCRATCHPAD+$00
         ldan ++$75                   ;set tile number for ball (something residual, likely)
         ldy GameEngineSubroutine
         cpyn ++$05                   ;if end-of-level routine running,
         beq DChunks                ;use palette and tile number assigned
         ldan ++$03                   ;otherwise set different palette bits
         sta SCRATCHPAD+$00
         ldan ++$84                   ;and set tile number for brick chunks
DChunks: ldyx Block_SprDataOffset,x  ;get OAM data offset
         iny                        ;increment to start with tile bytes in OAM
         jsr DumpFourSpr            ;do sub to dump tile number into all four sprites
         lda FrameCounter           ;get frame counter
         asl
         asl
         asl                        ;move low nybble to high
         asl
         andn ++$c0                   ;get what was originally d3-d2 of low nybble
         orai SCRATCHPAD+$00                    ;add palette bits
         iny                        ;increment offset for attribute bytes
         jsr DumpFourSpr            ;do sub to dump attribute data into all four sprites
         dey
         dey                        ;decrement offset to Y coordinate
         lda Block_Rel_YPos         ;get first block object's relative vertical coordinate
         jsr DumpTwoSpr             ;do sub to dump current Y coordinate into two sprites
         lda Block_Rel_XPos         ;get first block object's relative horizontal coordinate
         stay Sprite_X_Position,y    ;save into X coordinate of first sprite
         ldax Block_Orig_XPos,x      ;get original horizontal coordinate
         secsub
         sbci ScreenLeft_X_Pos       ;subtract coordinate of left side from original coordinate
         sta SCRATCHPAD+$00                    ;store result as relative horizontal coordinate of original
         secsub
         sbci Block_Rel_XPos         ;get difference of relative positions of original - current
        cmpcy
         adci SCRATCHPAD+$00                    ;add original relative position to result
         adcn ++$06                   ;plus 6 pixels to position second brick chunk correctly
         stay Sprite_X_Position+4,y  ;save into X coordinate of second sprite
         lda Block_Rel_YPos+1       ;get second block object's relative vertical coordinate
         stay Sprite_Y_Position+8,y
         stay Sprite_Y_Position+12,y ;dump into Y coordinates of third and fourth sprites
         lda Block_Rel_XPos+1       ;get second block object's relative horizontal coordinate
         stay Sprite_X_Position+8,y  ;save into X coordinate of third sprite
         lda SCRATCHPAD+$00                    ;use original relative horizontal position
         secsub
         sbci Block_Rel_XPos+1       ;get difference of relative positions of original - current
        cmpcy
         adci SCRATCHPAD+$00                    ;add original relative position to result
         adcn ++$06                   ;plus 6 pixels to position fourth brick chunk correctly
         stay Sprite_X_Position+12,y ;save into X coordinate of fourth sprite
         lda Block_OffscreenBits    ;get offscreen bits for block object
         jsr ChkLeftCo              ;do sub to move left half of sprites offscreen if necessary
         lda Block_OffscreenBits    ;get offscreen bits again
         asl                        ;shift d7 into carry
         bcc ChnkOfs                ;if d7 not set, branch to last part
         ldan ++$f8
         jsr DumpTwoSpr             ;otherwise move top sprites offscreen
ChnkOfs: lda SCRATCHPAD+$00                    ;if relative position on left side of screen,
         checka
         bpl ExBCDr                 ;go ahead and leave
         lday Sprite_X_Position,y    ;otherwise compare left-side X coordinate
         cmpy Sprite_X_Position+4,y  ;to right-side X coordinate
              cmpcy
         bcc ExBCDr                 ;branch to leave if less
         ldan ++$f8                   ;otherwise move right half of sprites offscreen
         stay Sprite_Y_Position+4,y
         stay Sprite_Y_Position+12,y
ExBCDr:  rts                        ;leave

;-------------------------------------------------------------------------------------

DrawFireball:
      ldyx FBall_SprDataOffset,x  ;get fireball's sprite data offset
      lda Fireball_Rel_YPos      ;get relative vertical coordinate
      stay Sprite_Y_Position,y    ;store as sprite Y coordinate
      lda Fireball_Rel_XPos      ;get relative horizontal coordinate
      stay Sprite_X_Position,y    ;store as sprite X coordinate, then do shared code

DrawFirebar:
       lda FrameCounter         ;get frame counter
       lsr                      ;divide by four
       lsr
       pha                      ;save result to stack
       andn ++$01                 ;mask out all but last bit
       eorn ++$64                 ;set either tile $64 or $65 as fireball tile
       stay Sprite_Tilenumber,y  ;thus tile changes every four frames
       pla                      ;get from stack
       lsr                      ;divide by four again
       lsr
       ldan ++$02                 ;load value $02 to set palette in attrib byte
       bcc FireA                ;if last bit shifted out was not set, skip this
       oran ++%11000000           ;otherwise flip both ways every eight frames
FireA: stay Sprite_Attributes,y  ;store attribute byte and leave
       rts

;-------------------------------------------------------------------------------------

ExplosionTiles:
      .db $68, $67, $66

DrawExplosion_Fireball:
      ldyx Alt_SprDataOffset,x  ;get OAM data offset of alternate sort for fireball's explosion
      ldax Fireball_State,x     ;load fireball state
      incx Fireball_State,x     ;increment state for next frame
      lsr                      ;divide by 2
      andn ++%00000111           ;mask out all but d3-d1
      cmpn ++$03                 ;check to see if time to kill fireball
              cmpcy
      bcs KillFireBall         ;branch if so, otherwise continue to draw explosion

DrawExplosion_Fireworks:
      tax                         ;use whatever's in A for offset
      ldax ExplosionTiles,x        ;get tile number using offset
      iny                         ;increment Y (contains sprite data offset)
      jsr DumpFourSpr             ;and dump into tile number part of sprite data
      dey                         ;decrement Y so we have the proper offset again
      ldx ObjectOffset            ;return enemy object buffer offset to X
      lda Fireball_Rel_YPos       ;get relative vertical coordinate
      secsub                         ;subtract four pixels vertically
      sbcn ++$04                    ;for first and third sprites
      stay Sprite_Y_Position,y
      stay Sprite_Y_Position+8,y
      clc                         ;add eight pixels vertically
      adcn ++$08                    ;for second and fourth sprites
      stay Sprite_Y_Position+4,y
      stay Sprite_Y_Position+12,y
      lda Fireball_Rel_XPos       ;get relative horizontal coordinate
      secsub                         ;subtract four pixels horizontally
      sbcn ++$04                    ;for first and second sprites
      stay Sprite_X_Position,y
      stay Sprite_X_Position+4,y
      clc                         ;add eight pixels horizontally
      adcn ++$08                    ;for third and fourth sprites
      stay Sprite_X_Position+8,y
      stay Sprite_X_Position+12,y
      ldan ++$02                    ;set palette attributes for all sprites, but
      stay Sprite_Attributes,y     ;set no flip at all for first sprite
      ldan ++$82
      stay Sprite_Attributes+4,y   ;set vertical flip for second sprite
      ldan ++$42
      stay Sprite_Attributes+8,y   ;set horizontal flip for third sprite
      ldan ++$c2
      stay Sprite_Attributes+12,y  ;set both flips for fourth sprite
      rts                         ;we are done

KillFireBall:
      ldan ++$00                    ;clear fireball state to kill it
      stax Fireball_State,x
      rts

;-------------------------------------------------------------------------------------

DrawSmallPlatform:
       ldyx Enemy_SprDataOffset,x   ;get OAM data offset
       ldan ++$5b                    ;load tile number for small platforms
       iny                         ;increment offset for tile numbers
       jsr DumpSixSpr              ;dump tile number into all six sprites
       iny                         ;increment offset for attributes
       ldan ++$02                    ;load palette controls
       jsr DumpSixSpr              ;dump attributes into all six sprites
       dey                         ;decrement for original offset
       dey
       lda Enemy_Rel_XPos          ;get relative horizontal coordinate
       stay Sprite_X_Position,y
       stay Sprite_X_Position+12,y  ;dump as X coordinate into first and fourth sprites
       clc
       adcn ++$08                    ;add eight pixels
       stay Sprite_X_Position+4,y   ;dump into second and fifth sprites
       stay Sprite_X_Position+16,y
       clc
       adcn ++$08                    ;add eight more pixels
       stay Sprite_X_Position+8,y   ;dump into third and sixth sprites
       stay Sprite_X_Position+20,y
       ldax Enemy_Y_Position,x      ;get vertical coordinate
       tax
       pha                         ;save to stack
       cpxn ++$20                    ;if vertical coordinate below status bar,
              cmpcy
       bcs TopSP                   ;do not mess with it
       ldan ++$f8                    ;otherwise move first three sprites offscreen
TopSP: jsr DumpThreeSpr            ;dump vertical coordinate into Y coordinates
       pla                         ;pull from stack
       clc
       adcn ++$80                    ;add 128 pixels
       tax
       cpxn ++$20                    ;if below status bar (taking wrap into account)
              cmpcy
       bcs BotSP                   ;then do not change altered coordinate
       ldan ++$f8                    ;otherwise move last three sprites offscreen
BotSP: stay Sprite_Y_Position+12,y  ;dump vertical coordinate + 128 pixels
       stay Sprite_Y_Position+16,y  ;into Y coordinates
       stay Sprite_Y_Position+20,y
       lda Enemy_OffscreenBits     ;get offscreen bits
       pha                         ;save to stack
       andn ++%00001000              ;check d3
       beq SOfs
       ldan ++$f8                    ;if d3 was set, move first and
       stay Sprite_Y_Position,y     ;fourth sprites offscreen
       stay Sprite_Y_Position+12,y
SOfs:  pla                         ;move out and back into stack
       pha
       andn ++%00000100              ;check d2
       beq SOfs2
       ldan ++$f8                    ;if d2 was set, move second and
       stay Sprite_Y_Position+4,y   ;fifth sprites offscreen
       stay Sprite_Y_Position+16,y
SOfs2: pla                         ;get from stack
       andn ++%00000010              ;check d1
       beq ExSPl
       ldan ++$f8                    ;if d1 was set, move third and
       stay Sprite_Y_Position+8,y   ;sixth sprites offscreen
       stay Sprite_Y_Position+20,y
ExSPl: ldx ObjectOffset            ;get enemy object offset and leave
       rts

;-------------------------------------------------------------------------------------

DrawBubble:
        ldy Player_Y_HighPos        ;if player's vertical high position
        dey                         ;not within screen, skip all of this
        bne ExDBub
        lda Bubble_OffscreenBits    ;check air bubble's offscreen bits
        andn ++%00001000
        bne ExDBub                  ;if bit set, branch to leave
        ldyx Bubble_SprDataOffset,x  ;get air bubble's OAM data offset
        lda Bubble_Rel_XPos         ;get relative horizontal coordinate
        stay Sprite_X_Position,y     ;store as X coordinate here
        lda Bubble_Rel_YPos         ;get relative vertical coordinate
        stay Sprite_Y_Position,y     ;store as Y coordinate here
        ldan ++$74
        stay Sprite_Tilenumber,y     ;put air bubble tile into OAM data
        ldan ++$02
        stay Sprite_Attributes,y     ;set attribute byte
ExDBub: rts                         ;leave

;-------------------------------------------------------------------------------------
;$00 - used to store player's vertical offscreen bits

PlayerGfxTblOffsets:
      .db $20, $28, $c8, $18, $00, $40, $50, $58
      .db $80, $88, $b8, $78, $60, $a0, $b0, $b8

;tiles arranged in order, 2 tiles per row, top to bottom

PlayerGraphicsTable:
;big player table
      .db $00, $01, $02, $03, $04, $05, $06, $07 ;walking frame 1
      .db $08, $09, $0a, $0b, $0c, $0d, $0e, $0f ;        frame 2
      .db $10, $11, $12, $13, $14, $15, $16, $17 ;        frame 3
      .db $18, $19, $1a, $1b, $1c, $1d, $1e, $1f ;skidding
      .db $20, $21, $22, $23, $24, $25, $26, $27 ;jumping
      .db $08, $09, $28, $29, $2a, $2b, $2c, $2d ;swimming frame 1
      .db $08, $09, $0a, $0b, $0c, $30, $2c, $2d ;         frame 2
      .db $08, $09, $0a, $0b, $2e, $2f, $2c, $2d ;         frame 3
      .db $08, $09, $28, $29, $2a, $2b, $5c, $5d ;climbing frame 1
      .db $08, $09, $0a, $0b, $0c, $0d, $5e, $5f ;         frame 2
      .db $fc, $fc, $08, $09, $58, $59, $5a, $5a ;crouching
      .db $08, $09, $28, $29, $2a, $2b, $0e, $0f ;fireball throwing

;small player table
      .db $fc, $fc, $fc, $fc, $32, $33, $34, $35 ;walking frame 1
      .db $fc, $fc, $fc, $fc, $36, $37, $38, $39 ;        frame 2
      .db $fc, $fc, $fc, $fc, $3a, $37, $3b, $3c ;        frame 3
      .db $fc, $fc, $fc, $fc, $3d, $3e, $3f, $40 ;skidding
      .db $fc, $fc, $fc, $fc, $32, $41, $42, $43 ;jumping
      .db $fc, $fc, $fc, $fc, $32, $33, $44, $45 ;swimming frame 1
      .db $fc, $fc, $fc, $fc, $32, $33, $44, $47 ;         frame 2
      .db $fc, $fc, $fc, $fc, $32, $33, $48, $49 ;         frame 3
      .db $fc, $fc, $fc, $fc, $32, $33, $90, $91 ;climbing frame 1
      .db $fc, $fc, $fc, $fc, $3a, $37, $92, $93 ;         frame 2
      .db $fc, $fc, $fc, $fc, $9e, $9e, $9f, $9f ;killed

;used by both player sizes
      .db $fc, $fc, $fc, $fc, $3a, $37, $4f, $4f ;small player standing
      .db $fc, $fc, $00, $01, $4c, $4d, $4e, $4e ;intermediate grow frame
      .db $00, $01, $4c, $4d, $4a, $4a, $4b, $4b ;big player standing

SwimKickTileNum:
      .db $31, $46

PlayerGfxHandler:
        lda InjuryTimer             ;if player's injured invincibility timer
         checka
        beq CntPl                   ;not set, skip checkpoint and continue code
        lda FrameCounter
        lsr                         ;otherwise check frame counter and branch
        bcs ExPGH                   ;to leave on every other frame (when d0 is set)
CntPl:  lda GameEngineSubroutine    ;if executing specific game engine routine,
        cmpn ++$0b                    ;branch ahead to some other part
        beq PlayerKilled
        lda PlayerChangeSizeFlag    ;if grow/shrink flag set
         checka
        bne DoChangeSize            ;then branch to some other code
        ldy SwimmingFlag            ;if swimming flag set, branch to
         checky
        beq FindPlayerAction        ;different part, do not return
        lda Player_State
        cmpn ++$00                    ;if player status normal,
        beq FindPlayerAction        ;branch and do not return
        jsr FindPlayerAction        ;otherwise jump and return
        lda FrameCounter
        andn ++%00000100              ;check frame counter for d2 set (8 frames every
        bne ExPGH                   ;eighth frame), and branch if set to leave
        tax                         ;initialize X to zero
        ldy Player_SprDataOffset    ;get player sprite data offset
        lda PlayerFacingDir         ;get player's facing direction
        lsr
        bcs SwimKT                  ;if player facing to the right, use current offset
        iny
        iny                         ;otherwise move to next OAM data
        iny
        iny
SwimKT: lda PlayerSize              ;check player's size
         checka
        beq BigKTS                  ;if big, use first tile
        lday Sprite_Tilenumber+24,y  ;check tile number of seventh/eighth sprite
        cmpi SwimTileRepOffset       ;against tile number in player graphics table
        beq ExPGH                   ;if spr7/spr8 tile number = value, branch to leave
        inx                         ;otherwise increment X for second tile
BigKTS: ldax SwimKickTileNum,x       ;overwrite tile number in sprite 7/8
        stay Sprite_Tilenumber+24,y  ;to animate player's feet when swimming
ExPGH:  rts                         ;then leave

FindPlayerAction:
      jsr ProcessPlayerAction       ;find proper offset to graphics table by player's actions
      jmp PlayerGfxProcessing       ;draw player, then process for fireball throwing

DoChangeSize:
      jsr HandleChangeSize          ;find proper offset to graphics table for grow/shrink
      jmp PlayerGfxProcessing       ;draw player, then process for fireball throwing

PlayerKilled:
      ldyn ++$0e                      ;load offset for player killed
      lday PlayerGfxTblOffsets,y     ;get offset to graphics table

PlayerGfxProcessing:
       sta PlayerGfxOffset           ;store offset to graphics table here
       ldan ++$04
       jsr RenderPlayerSub           ;draw player based on offset loaded
       jsr ChkForPlayerAttrib        ;set horizontal flip bits as necessary
       lda FireballThrowingTimer
         checka
       beq PlayerOffscreenChk        ;if fireball throw timer not set, skip to the end
       ldyn ++$00                      ;set value to initialize by default
       lda PlayerAnimTimer           ;get animation frame timer
       cmpi FireballThrowingTimer     ;compare to fireball throw timer
       sty FireballThrowingTimer     ;initialize fireball throw timer
              cmpcy
       bcs PlayerOffscreenChk        ;if animation frame timer =>  fireball throw timer skip to end
       sta FireballThrowingTimer     ;otherwise store animation timer into fireball throw timer
       ldyn ++$07                      ;load offset for throwing
       lday PlayerGfxTblOffsets,y     ;get offset to graphics table
       sta PlayerGfxOffset           ;store it for use later
       ldyn ++$04                      ;set to update four sprite rows by default
       lda Player_X_Speed
       orai Left_Right_Buttons        ;check for horizontal speed or left/right button press
       beq SUpdR                     ;if no speed or button press, branch using set value in Y
       dey                           ;otherwise set to update only three sprite rows
SUpdR: tya                           ;save in A for use
       jsr RenderPlayerSub           ;in sub, draw player object again

PlayerOffscreenChk:
           lda Player_OffscreenBits      ;get player's offscreen bits
           lsr
           lsr                           ;move vertical bits to low nybble
           lsr
           lsr
           sta SCRATCHPAD+$00                       ;store here
           ldxn ++$03                      ;check all four rows of player sprites
           lda Player_SprDataOffset      ;get player's sprite data offset
           clc
           adcn ++$18                      ;add 24 bytes to start at bottom row
           tay                           ;set as offset here
PROfsLoop: ldan ++$f8                      ;load offscreen Y coordinate just in case
           lsri SCRATCHPAD+$00                       ;shift bit into carry
           bcc NPROffscr                 ;if bit not set, skip, do not move sprites
           jsr DumpTwoSpr                ;otherwise dump offscreen Y coordinate into sprite data
NPROffscr: tya
           secsub                           ;subtract eight bytes to do
           sbcn ++$08                      ;next row up
           tay
           dex                           ;decrement row counter
           bpl PROfsLoop                 ;do this until all sprite rows are checked
           rts                           ;then we are done!

;-------------------------------------------------------------------------------------

IntermediatePlayerData:
        .db $58, $01, $00, $60, $ff, $04

DrawPlayer_Intermediate:
	if Z80OPT
	ld hl,IntermediatePlayerData
	ld de,SCRATCHPAD+$02
	ld c,6
	ldir
	ld d,b;0
          ld e,++$04                       ;load sprite data offset
      ld hl,PlayerGraphicsTable+$b8                       ;load offset for small standing
      ;add hl,bc
          call DrawPlayerLoop             ;draw player accordingly
	else
          ldxn ++$05                       ;store data into zero page memory
PIntLoop: ldax IntermediatePlayerData,x   ;load data to display player as he always
          stax SCRATCHPAD+$02,x                      ;appears on world/lives display
          dex
          bpl PIntLoop                   ;do this until all data is loaded
          ldxn ++$b8                       ;load offset for small standing
          ldyn ++$04                       ;load sprite data offset
          jsr DrawPlayerLoop             ;draw player accordingly
	endif
          lda Sprite_Attributes+36       ;get empty sprite attributes
          oran ++%01000000                 ;set horizontal flip bit for bottom-right sprite
          sta Sprite_Attributes+32       ;store and leave
          rts

;-------------------------------------------------------------------------------------
;$00-$01 - used to hold tile numbers, $00 also used to hold upper extent of animation frames
;$02 - vertical position
;$03 - facing direction, used as horizontal flip control
;$04 - attributes
;$05 - horizontal position
;$07 - number of rows to draw
;these also used in IntermediatePlayerData

RenderPlayerSub:
        sta SCRATCHPAD+$07                      ;store number of rows of sprites to draw
        lda Player_Rel_XPos
        sta Player_Pos_ForScroll     ;store player's relative horizontal position
        sta SCRATCHPAD+$05                      ;store it here also
        lda Player_Rel_YPos
        sta SCRATCHPAD+$02                      ;store player's vertical position
        lda PlayerFacingDir
        sta SCRATCHPAD+$03                      ;store player's facing direction
        lda Player_SprAttrib
        sta SCRATCHPAD+$04                      ;store player's sprite attributes
        ldx PlayerGfxOffset          ;load graphics table offset
        ldy Player_SprDataOffset     ;get player's sprite data offset

        if Z80OPT
      ld hl,PlayerGraphicsTable
      add hl,bc
DrawPlayerLoop:
      ld a,(SCRATCHPAD+$07)
      ld b,a
DrawPlayerLoop0
      call DrawSpriteObject
      djnz DrawPlayerLoop0           ;do this until all rows are drawn
        else
DrawPlayerLoop:
DrawPlayerLoop0
        ldax PlayerGraphicsTable,x    ;load player's left side
        sta SCRATCHPAD+$00
        ldax PlayerGraphicsTable+1,x  ;now load right side
        jsr DrawOneSpriteRow
        deci SCRATCHPAD+$07                      ;decrement rows of sprites to draw
        bne DrawPlayerLoop0           ;do this until all rows are drawn
        endif
        rts

ProcessPlayerAction:
        lda Player_State      ;get player's state
        cmpn ++$03
        beq ActionClimbing    ;if climbing, branch here
        cmpn ++$02
        beq ActionFalling     ;if falling, branch here
        cmpn ++$01
        bne ProcOnGroundActs  ;if not jumping, branch here
        lda SwimmingFlag
         checka
        bne ActionSwimming    ;if swimming flag set, branch elsewhere
        ldyn ++$06              ;load offset for crouching
        lda CrouchingFlag     ;get crouching flag
         checka
        bne NonAnimatedActs   ;if set, branch to get offset for graphics table
        ldyn ++$00              ;otherwise load offset for jumping
        jmp NonAnimatedActs   ;go to get offset to graphics table

ProcOnGroundActs:
        ldyn ++$06                   ;load offset for crouching
        lda CrouchingFlag          ;get crouching flag
         checka
        bne NonAnimatedActs        ;if set, branch to get offset for graphics table
        ldyn ++$02                   ;load offset for standing
        lda Player_X_Speed         ;check player's horizontal speed
        orai Left_Right_Buttons     ;and left/right controller bits
        beq NonAnimatedActs        ;if no speed or buttons pressed, use standing offset
        lda Player_XSpeedAbsolute  ;load walking/running speed
        cmpn ++$09
              cmpcy
        bcc ActionWalkRun          ;if less than a certain amount, branch, too slow to skid
        lda Player_MovingDir       ;otherwise check to see if moving direction
        andi PlayerFacingDir        ;and facing direction are the same
        bne ActionWalkRun          ;if moving direction = facing direction, branch, don't skid
        iny                        ;otherwise increment to skid offset ($03)

NonAnimatedActs:
        jsr GetGfxOffsetAdder      ;do a sub here to get offset adder for graphics table
        ldan ++$00
        sta PlayerAnimCtrl         ;initialize animation frame control
        lday PlayerGfxTblOffsets,y  ;load offset to graphics table using size as offset
        rts

ActionFalling:
        ldyn ++$04                  ;load offset for walking/running
        jsr GetGfxOffsetAdder     ;get offset to graphics table
        jmp GetCurrentAnimOffset  ;execute instructions for falling state

ActionWalkRun:
        ldyn ++$04               ;load offset for walking/running
        jsr GetGfxOffsetAdder  ;get offset to graphics table
        jmp FourFrameExtent    ;execute instructions for normal state

ActionClimbing:
        ldyn ++$05               ;load offset for climbing
        lda Player_Y_Speed     ;check player's vertical speed
         checka
        beq NonAnimatedActs    ;if no speed, branch, use offset as-is
        jsr GetGfxOffsetAdder  ;otherwise get offset for graphics table
        jmp ThreeFrameExtent   ;then skip ahead to more code

ActionSwimming:
        ldyn ++$01               ;load offset for swimming
        jsr GetGfxOffsetAdder
        lda JumpSwimTimer      ;check jump/swim timer
        orai PlayerAnimCtrl     ;and animation frame control
        bne FourFrameExtent    ;if any one of these set, branch ahead
        lda A_B_Buttons
        asl                    ;check for A button pressed
        bcs FourFrameExtent    ;branch to same place if A button pressed

GetCurrentAnimOffset:
        lda PlayerAnimCtrl         ;get animation frame control
        jmp GetOffsetFromAnimCtrl  ;jump to get proper offset to graphics table

FourFrameExtent:
        ldan ++$03              ;load upper extent for frame control
        jmp AnimationControl  ;jump to get offset and animate player object

ThreeFrameExtent:
        ldan ++$02              ;load upper extent for frame control for climbing

AnimationControl:
          sta SCRATCHPAD+$00                   ;store upper extent here
          jsr GetCurrentAnimOffset  ;get proper offset to graphics table
          pha                       ;save offset to stack
          lda PlayerAnimTimer       ;load animation frame timer
         checka
          bne ExAnimC               ;branch if not expired
          lda PlayerAnimTimerSet    ;get animation frame timer amount
          sta PlayerAnimTimer       ;and set timer accordingly
          lda PlayerAnimCtrl
          clc                       ;add one to animation frame control
          adcn ++$01
          cmpi SCRATCHPAD+$00                   ;compare to upper extent
              cmpcy
          bcc SetAnimC              ;if frame control + 1 < upper extent, use as next
          ldan ++$00                  ;otherwise initialize frame control
SetAnimC: sta PlayerAnimCtrl        ;store as new animation frame control
ExAnimC:  pla                       ;get offset to graphics table from stack and leave
          rts

GetGfxOffsetAdder:
        lda PlayerSize  ;get player's size
         checka
        beq SzOfs       ;if player big, use current offset as-is
        tya             ;for big player
        clc             ;otherwise add eight bytes to offset
        adcn ++$08        ;for small player
        tay
SzOfs:  rts             ;go back

ChangeSizeOffsetAdder:
        .db $00, $01, $00, $01, $00, $01, $02, $00, $01, $02
        .db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00

HandleChangeSize:
         ldy PlayerAnimCtrl           ;get animation frame control
         lda FrameCounter
         andn ++%00000011               ;get frame counter and execute this code every
         bne GorSLog                  ;fourth frame, otherwise branch ahead
         iny                          ;increment frame control
         cpyn ++$0a                     ;check for preset upper extent
              cmpcy
         bcc CSzNext                  ;if not there yet, skip ahead to use
         ldyn ++$00                     ;otherwise initialize both grow/shrink flag
         sty PlayerChangeSizeFlag     ;and animation frame control
CSzNext: sty PlayerAnimCtrl           ;store proper frame control
GorSLog: lda PlayerSize               ;get player's size
         checka
         bne ShrinkPlayer             ;if player small, skip ahead to next part
         lday ChangeSizeOffsetAdder,y  ;get offset adder based on frame control as offset
         ldyn ++$0f                     ;load offset for player growing

GetOffsetFromAnimCtrl:
        asl                        ;multiply animation frame control
        asl                        ;by eight to get proper amount
        asl                        ;to add to our offset
        adcy PlayerGfxTblOffsets,y  ;add to offset to graphics table
        rts                        ;and return with result in A

ShrinkPlayer:
        tya                          ;add ten bytes to frame control as offset
        clc
        adcn ++$0a                     ;this thing apparently uses two of the swimming frames
        tax                          ;to draw the player shrinking
        ldyn ++$09                     ;load offset for small player swimming
        ldax ChangeSizeOffsetAdder,x  ;get what would normally be offset adder
         checka
        bne ShrPlF                   ;and branch to use offset if nonzero
        ldyn ++$01                     ;otherwise load offset for big player swimming
ShrPlF: lday PlayerGfxTblOffsets,y    ;get offset to graphics table based on offset loaded
        rts                          ;and leave

ChkForPlayerAttrib:
           ldy Player_SprDataOffset    ;get sprite data offset
           lda GameEngineSubroutine
           cmpn ++$0b                    ;if executing specific game engine routine,
           beq KilledAtt               ;branch to change third and fourth row OAM attributes
           lda PlayerGfxOffset         ;get graphics table offset
           cmpn ++$50
           beq C_S_IGAtt               ;if crouch offset, either standing offset,
           cmpn ++$b8                    ;or intermediate growing offset,
           beq C_S_IGAtt               ;go ahead and execute code to change 
           cmpn ++$c0                    ;fourth row OAM attributes only
           beq C_S_IGAtt
           cmpn ++$c8
           bne ExPlyrAt                ;if none of these, branch to leave
KilledAtt: lday Sprite_Attributes+16,y
           andn ++%00111111              ;mask out horizontal and vertical flip bits
           stay Sprite_Attributes+16,y  ;for third row sprites and save
           lday Sprite_Attributes+20,y
           andn ++%00111111  
           oran ++%01000000              ;set horizontal flip bit for second
           stay Sprite_Attributes+20,y  ;sprite in the third row
C_S_IGAtt: lday Sprite_Attributes+24,y
           andn ++%00111111              ;mask out horizontal and vertical flip bits
           stay Sprite_Attributes+24,y  ;for fourth row sprites and save
           lday Sprite_Attributes+28,y
           andn ++%00111111
           oran ++%01000000              ;set horizontal flip bit for second
           stay Sprite_Attributes+28,y  ;sprite in the fourth row
ExPlyrAt:  rts                         ;leave

;-------------------------------------------------------------------------------------
;$00 - used in adding to get proper offset

RelativePlayerPosition:
        ldxn ++$00      ;set offsets for relative cooordinates
        ldyn ++$00      ;routine to correspond to player object
        jmp RelWOfs   ;get the coordinates

RelativeBubblePosition:
        ldyn ++$01                ;set for air bubble offsets
        jsr GetProperObjOffset  ;modify X to get proper air bubble offset
        ldyn ++$03
        jmp RelWOfs             ;get the coordinates

RelativeFireballPosition:
         ldyn ++$00                    ;set for fireball offsets
         jsr GetProperObjOffset      ;modify X to get proper fireball offset
         ldyn ++$02
RelWOfs: jsr GetObjRelativePosition  ;get the coordinates
         ldx ObjectOffset            ;return original offset
         rts                         ;leave

RelativeMiscPosition:
        ldyn ++$02                ;set for misc object offsets
        jsr GetProperObjOffset  ;modify X to get proper misc object offset
        ldyn ++$06
        jmp RelWOfs             ;get the coordinates

RelativeEnemyPosition:
        ldan ++$01                     ;get coordinates of enemy object 
        ldyn ++$01                     ;relative to the screen
        jmp VariableObjOfsRelPos

RelativeBlockPosition:
        ldan ++$09                     ;get coordinates of one block object
        ldyn ++$04                     ;relative to the screen
        jsr VariableObjOfsRelPos
        inx                          ;adjust offset for other block object if any
        inx
        ldan ++$09
        iny                          ;adjust other and get coordinates for other one

VariableObjOfsRelPos:
        stx SCRATCHPAD+$00                     ;store value to add to A here
        clc
        adci SCRATCHPAD+$00                     ;add A to value stored
        tax                         ;use as enemy offset
        jsr GetObjRelativePosition
        ldx ObjectOffset            ;reload old object offset and leave
        rts

GetObjRelativePosition:
        ldax SprObject_Y_Position,x  ;load vertical coordinate low
        stay SprObject_Rel_YPos,y    ;store here
        ldax SprObject_X_Position,x  ;load horizontal coordinate
        secsub                         ;subtract left edge coordinate
        sbci ScreenLeft_X_Pos
        stay SprObject_Rel_XPos,y    ;store result here
        rts

;-------------------------------------------------------------------------------------
;$00 - used as temp variable to hold offscreen bits

GetPlayerOffscreenBits:
        ldxn ++$00                 ;set offsets for player-specific variables
        ldyn ++$00                 ;and get offscreen information about player
        jmp GetOffScreenBitsSet

GetFireballOffscreenBits:
        ldyn ++$00                 ;set for fireball offsets
        jsr GetProperObjOffset   ;modify X to get proper fireball offset
        ldyn ++$02                 ;set other offset for fireball's offscreen bits
        jmp GetOffScreenBitsSet  ;and get offscreen information about fireball

GetBubbleOffscreenBits:
        ldyn ++$01                 ;set for air bubble offsets
        jsr GetProperObjOffset   ;modify X to get proper air bubble offset
        ldyn ++$03                 ;set other offset for airbubble's offscreen bits
        jmp GetOffScreenBitsSet  ;and get offscreen information about air bubble

GetMiscOffscreenBits:
        ldyn ++$02                 ;set for misc object offsets
        jsr GetProperObjOffset   ;modify X to get proper misc object offset
        ldyn ++$06                 ;set other offset for misc object's offscreen bits
        jmp GetOffScreenBitsSet  ;and get offscreen information about misc object

ObjOffsetData:
        .db $07, $16, $0d

GetProperObjOffset:
        txa                  ;move offset to A
        clc
        adcy ObjOffsetData,y  ;add amount of bytes to offset depending on setting in Y
        tax                  ;put back in X and leave
        rts

GetEnemyOffscreenBits:
	if Z80OPT ;???не помогает в 1-2
        inc c
        call RunOffscrBitsSubs ;a=$00, $08, $0c, $0e, $0f, $07, $03, $01, $00
        add a,a                         ;move low nybble to high nybble
        add a,a
        add a,a
        add a,a
        ld hl,SCRATCHPAD+$00
        or (hl)                    ;mask together with previously saved low nybble
	ld (SprObject_OffscrBits+1),a
        ld hl,ObjectOffset
        ld c,(hl)
	ret
	else
        ldan ++$01                 ;set A to add 1 byte in order to get enemy offset
        ldyn ++$01                 ;set Y to put offscreen bits in Enemy_OffscreenBits
        jmp SetOffscrBitsOffset
	endif

GetBlockOffscreenBits:
        ldan ++$09       ;set A to add 9 bytes in order to get block obj offset
        ldyn ++$04       ;set Y to put offscreen bits in Block_OffscreenBits

SetOffscrBitsOffset:
        stx SCRATCHPAD+$00
        clc           ;add contents of X to A to get
        adci SCRATCHPAD+$00       ;appropriate offset, then give back to X
        tax

GetOffScreenBitsSet:
        tya                         ;save offscreen bits offset to stack for now
        pha
        jsr RunOffscrBitsSubs ;a=$00, $08, $0c, $0e, $0f, $07, $03, $01, $00
        asl                         ;move low nybble to high nybble
        asl
        asl
        asl
        orai SCRATCHPAD+$00                     ;mask together with previously saved low nybble
        sta SCRATCHPAD+$00                     ;store both here
        pla                         ;get offscreen bits offset from stack
        tay
        lda SCRATCHPAD+$00                     ;get value here and store elsewhere
        stay SprObject_OffscrBits,y
        ldx ObjectOffset
        rts

RunOffscrBitsSubs:
;2 calls
;x на выходе не важен, важно SCRATCHPAD+$00 [и +$07(???)]
	if Z80OPT ;???

        call GetXOffscreenBits  ;do subroutine here
        rra                    ;move high nybble to low
        rra
        rra
        rra        ;TODO убрать в GetXOffscreenBits
        and 0x0f
        ld (SCRATCHPAD+$00),a                ;store here
;test top of screen
        ;ld c,0
        xor a ;load coordinate for edge of vertical unit ;.db $ff, $00
	sub (ix+SprObject_Y_Position-SprObject_X_Position)  ;subtract from vertical coordinate of object
          ld l,a;sta SCRATCHPAD+$07                      ;store here
          ld a,++$01                     ;subtract one from vertical high byte of object
	sbc a,(ix+SprObject_Y_HighPos-SprObject_X_Position)
        ;  jp m,YLdBData                 ;if under top of the screen or beyond bottom, branch
        jp m,YLdBbottom ;if under top of the screen or beyond bottom
        ld c,4  ;if not, load alternate offset value here (y+DefaultYOnscreenOfs+1) ;.db $04, $00, $04
          jp nz,YLdBData                 ;if one vertical unit or more above the screen, branch ;тут точно выход
;было dyhigh==0
          ld a,l;lda SCRATCHPAD+$07       ;get pixel difference
          cp 32 ;cmpi SCRATCHPAD+$06       ;compare to preset value
          jr nc,YLdBData  ;if pixel difference HIGH = preset value, branch ;использует c=x=4 ;тут точно выход
          rra           ;divide by eight
          rra
          rra ;в младших битах: 0..3
          and 3 ;andn ++$07      ;mask out all but 3 LSB ;было не 2 бита, потому что это была общая процедура для X и Y
          ld c,a;tax           ;use as offset
YLdBData:
	ld hl,YOffscreenBitsData ;.db $00, $08, $0c, $0e, $0f, $07, $03, $01, $00 ;зачем последний 0?
	add hl,bc
        ld a,(hl) ;get offscreen data bits using offset
          or a
          ret nz                     ;if bits not zero, branch to leave
;test bottom of screen
YLdBbottom:
        ;ld c,4
        ld a,-1 ;load coordinate for edge of vertical unit ;.db $ff, $00
	sub (ix+SprObject_Y_Position-SprObject_X_Position)  ;subtract from vertical coordinate of object
          ld l,a;sta SCRATCHPAD+$07                      ;store here
          ld a,++$01                     ;subtract one from vertical high byte of object
	sbc a,(ix+SprObject_Y_HighPos-SprObject_X_Position)
        ;  jp m,YLdBDatabottom                 ;if under top of the screen or beyond bottom, branch
        ld a,15
        ret m ;if under top of the screen or beyond bottom
        ;ld c,0  ;if not, load alternate offset value here (y+DefaultYOnscreenOfs+1) ;.db $04, $00, $04
        ld c,8-4 ;для ускорения через сдвиг таблицы
          jp nz,YLdBDatabottom                 ;if one vertical unit or more above the screen, branch
;было dyHSB==0
          ld a,l;lda SCRATCHPAD+$07       ;get pixel difference
          cp 32 ;cmpi SCRATCHPAD+$06       ;compare to preset value
          jr nc,YLdBDatabottom  ;if pixel difference HIGH = preset value, branch ;использует c=x=0
          rra           ;divide by eight
          rra
          rra ;в младших битах: 0..3
          and 3 ;andn ++$07      ;mask out all but 3 LSB ;было не 2 бита, потому что это была общая процедура для X и Y
          ;add a,4
          ld c,a;tax           ;use as offset
YLdBDatabottom:
	ld hl,YOffscreenBitsData +4 ;.db $00, $08, $0c, $0e, $0f, $07, $03, $01, $00 ;зачем последний 0? используем его для ускорения
	add hl,bc
        ld a,(hl) ;get offscreen data bits using offset
	  ret

        else ;~Z80

        jsr GetXOffscreenBits  ;do subroutine here
        lsr                    ;move high nybble to low
        lsr
        lsr
        lsr
        sta SCRATCHPAD+$00                ;store here
        jmp GetYOffscreenBits

	endif

;--------------------------------
;(these apply to these three subsections)
;$04 - used to store proper offset
;$05 - used as adder in DividePDiff
;$06 - used to store preset value used to compare to pixel difference in $07
;$07 - used to store difference between coordinates of object and screen edges

;TODO каждое значение 8 раз, чтобы не сдвигать
XOffscreenBitsData:
        .db $7f, $3f, $1f, $0f, $07, $03, $01, $00
        .db $80, $c0, $e0, $f0, $f8, $fc, $fe, $ff

DefaultXOnscreenOfs:
        .db $07, $0f, $07

GetXOffscreenBits:
;TODO >>4?
        if Z80OPT
          ld ix,SprObject_X_Position
          add ix,bc
;right side of screen
          ld a,(ScreenEdge_X_Pos+1) ;get pixel coordinate of edge ;в переменных!!!
        ;ld c,15
        sub (ix) ;get difference between pixel coordinate of edge and pixel coordinate of object position
         ld l,a ;sta SCRATCHPAD+$07                     ;store here
          ld a,(ScreenEdge_PageLoc+1)    ;get page location of edge ;в переменных!!!
        sbc a,(ix+SprObject_PageLoc-SprObject_X_Position) ;subtract from page location of object position
          ;jp m,XLdBData                ;if beyond right edge or in front of left edge, branch ;тут точно выход
         ;ld a,0xff
         ; ret m                ;if beyond right edge or in front of left edge, branch
         jp m,XLdBDataleftq ;if beyond right edge or in front of left edge, branch
         ;ld c,7 ;ldxy DefaultXOnscreenOfs+1,y ;if not, load alternate offset value here ;.db $07, $0f, $07
          jp nz,XLdBleft;XLdBData                ;if one page or more to the left of either edge, branch
;было dxHSB==0
         ld a,l ;lda SCRATCHPAD+$07       ;get pixel difference
          cp 56 ;cmpi SCRATCHPAD+$06       ;compare to preset value
          jr nc,XLdBleft;XLdBData  ;if pixel difference >= preset value, branch
          rra           ;divide by eight
          rra
          rra ;в младших битах: 0..6
          and ++$07      ;mask out all but 3 LSB
          ld c,a;tax           ;use as offset
;XLdBData:
        ld hl,XOffscreenBitsData
        add hl,bc
        ld a,(hl) ;.db $7f, $3f, $1f, $0f, $07, $03, $01, $00, $80, $c0, $e0, $f0, $f8, $fc, $fe, $ff
          or a                    ;if bits not zero, branch to leave
          ret nz
;left side of screen
XLdBleft
        ld a,(ScreenEdge_X_Pos) ;get pixel coordinate of edge ;в переменных!!!
        ld c,7
        sub (ix) ;get difference between pixel coordinate of edge and pixel coordinate of object position
         ld l,a ;sta SCRATCHPAD+$07                     ;store here
          ld a,(ScreenEdge_PageLoc)    ;get page location of edge ;в переменных!!!
        sbc a,(ix+SprObject_PageLoc-SprObject_X_Position) ;subtract from page location of object position
          jp m,XLdBDataleft                ;if beyond right edge or in front of left edge, branch
         ;ld c,15 ;ldxy DefaultXOnscreenOfs+1,y ;if not, load alternate offset value here ;.db $07, $0f, $07
          jp nz,XLdBDataleftq;XLdBDataleft                ;if one page or more to the left of either edge, branch ;тут точно выход
;было dxHSB==0
         ld a,l ;lda SCRATCHPAD+$07       ;get pixel difference
          cp 56 ;cmpi SCRATCHPAD+$06       ;compare to preset value
          jr nc,XLdBDataleftq;XLdBDataleft  ;if pixel difference >= preset value, branch ;использует x=c=15 ;тут точно выход
          rra           ;divide by eight
          rra
          rra ;в младших битах: 0..6
          and ++$07      ;mask out all but 3 LSB
          add a,8
          ld c,a;tax           ;use as offset
XLdBDataleft:
        ld hl,XOffscreenBitsData
        add hl,bc
        ld a,(hl) ;.db $7f, $3f, $1f, $0f, $07, $03, $01, $00, $80, $c0, $e0, $f0, $f8, $fc, $fe, $ff
          ret
XLdBDataleftq
        ld a,0xff
        ret
          
        else ;~Z80
        
;keep x!
          stx SCRATCHPAD+$04                     ;save position in buffer to here
          ldyn ++$01                    ;start with right side of screen
XOfsLoop: lday ScreenEdge_X_Pos,y      ;get pixel coordinate of edge
          secsub                         ;get difference between pixel coordinate of edge
          sbcx SprObject_X_Position,x  ;and pixel coordinate of object position
          sta SCRATCHPAD+$07                     ;store here
          ldaykeepcy ScreenEdge_PageLoc,y    ;get page location of edge
          sbcx SprObject_PageLoc,x     ;subtract from page location of object position
          ldxy DefaultXOnscreenOfs,y   ;load offset value here
          cmpn ++$00      
          bmi XLdBData                ;if beyond right edge or in front of left edge, branch
          ldxy DefaultXOnscreenOfs+1,y ;if not, load alternate offset value here
          cmpn ++$01      
          bpl XLdBData                ;if one page or more to the left of either edge, branch
          ldan ++$38                    ;if no branching, load value here and store
          sta SCRATCHPAD+$06
          ldan ++$08                    ;load some other value and execute subroutine
          jsr DividePDiff
XLdBData: ldax XOffscreenBitsData,x    ;get bits here
          ldx SCRATCHPAD+$04                     ;reobtain position in buffer
          cmpn ++$00                    ;if bits not zero, branch to leave
          bne ExXOfsBS
          dey                         ;otherwise, do left side of screen now
          bpl XOfsLoop                ;branch if not already done with left side ;2 прохода
ExXOfsBS: rts
        endif

;--------------------------------

;TODO каждое значение 8 раз, чтобы не сдвигать
YOffscreenBitsData:
        .db $00, $08, $0c, $0e
        .db $0f, $07, $03, $01
        .db $00 ;зачем он был нужен? (в Z80 теперь нужен)

DefaultYOnscreenOfs:
        .db $04, $00, $04

HighPosUnitData:
        .db $ff, $00

	if Z80OPT
	else
GetYOffscreenBits:
          stx SCRATCHPAD+$04                      ;save position in buffer to here
          ldyn ++$01                     ;start with top of screen
YOfsLoop0: lday HighPosUnitData,y        ;load coordinate for edge of vertical unit
          secsub
          sbcx SprObject_Y_Position,x   ;subtract from vertical coordinate of object
          sta SCRATCHPAD+$07                      ;store here
          ldan ++$01                     ;subtract one from vertical high byte of object
          sbcx SprObject_Y_HighPos,x
          ldxy DefaultYOnscreenOfs,y    ;load offset value here
          cmpn ++$00
          bmi YLdBData                 ;if under top of the screen or beyond bottom, branch
          ldxy DefaultYOnscreenOfs+1,y  ;if not, load alternate offset value here
          cmpn ++$01
          bpl YLdBData                 ;if one vertical unit or more above the screen, branch
          ldan ++$20                     ;if no branching, load value here and store
          sta SCRATCHPAD+$06
          ldan ++$04                     ;load some other value and execute subroutine
          jsr DividePDiff
YLdBData: ldax YOffscreenBitsData,x     ;get offscreen data bits using offset
          ldx SCRATCHPAD+$04                      ;reobtain position in buffer
          cmpn ++$00
          bne ExYOfsBS                 ;if bits not zero, branch to leave
          dey                          ;otherwise, do bottom of the screen now
          bpl YOfsLoop0
ExYOfsBS: rts
	endif

;--------------------------------

DividePDiff:
;a = 4 (Y) / 8 (X)
;y = номер прохода в координате (0 = лево/низ, 1 = право/верх)
;out: x
	if Z80OPT
          ld ly,a;sta SCRATCHPAD+$05       ;store current value in A here
	  ld hl,(SCRATCHPAD+$06)
          ld a,h ;lda SCRATCHPAD+$07       ;get pixel difference
          cp l ;cmpi SCRATCHPAD+$06       ;compare to preset value
          ret nc  ;if pixel difference >= preset value, branch
          rra           ;divide by eight
          rra
          rra
          and ++$07      ;mask out all but 3 LSB
	inc e ;right side of the screen or top?
	dec e
          jr nz,SetOscrO  ;if so, branch, use difference / 8 as offset
          add a,ly; SCRATCHPAD+$05       ;if not, add value to difference / 8
SetOscrO: ld c,a           ;use as offset
	ret
	else
          sta SCRATCHPAD+$05       ;store current value in A here
          lda SCRATCHPAD+$07       ;get pixel difference
          cmpi SCRATCHPAD+$06       ;compare to preset value
              cmpcy
          bcs ExDivPD   ;if pixel difference >= preset value, branch
          lsr           ;divide by eight
          lsr
          lsr
          andn ++$07      ;mask out all but 3 LSB
          cpyn ++$01      ;right side of the screen or top?
              cmpcy
          bcs SetOscrO  ;if so, branch, use difference / 8 as offset
          adci SCRATCHPAD+$05       ;if not, add value to difference / 8
SetOscrO: tax           ;use as offset
ExDivPD:  rts           ;leave
	endif

;-------------------------------------------------------------------------------------
;$00-$01 - tile numbers (hl, out: hl+=2)
;$02 - Y coordinate
;$03 - flip control
;$04 - sprite attributes
;$05 - X coordinate
;y = Sprite_Data offset
;out: [x+=2], y+=8

DrawSpriteObject:
        if Z80OPT
         ld ix,Sprite_Data
         add ix,de
         lda SCRATCHPAD+$03                    ;get saved flip control bits
         rra
         rra                        ;move d1 into carry
         ;ld hl,(SCRATCHPAD+$00)
         ld a,(hl)
         jr nc,NoHFlip                ;if d1 not set, branch
         ld (ix+Sprite_Tilenumber-Sprite_Data+4),a  ;store first tile into second sprite
         inc hl
         ld a,(hl)
         ld (ix+Sprite_Tilenumber-Sprite_Data),a ;and second into first sprite
         ld a,(SCRATCHPAD+$04)
         or 0x40                   ;activate horizontal flip OAM attribute
         jp SetHFAt                ;and unconditionally branch
NoHFlip: ld (ix+Sprite_Tilenumber-Sprite_Data),a    ;store first tile into first sprite
         inc hl
         ld a,(hl)
         ld (ix+Sprite_Tilenumber-Sprite_Data+4),a ;and second into second sprite
         ld a,(SCRATCHPAD+$04)                    ;без +0x40 OAM attribute
SetHFAt:
         ld (ix+Sprite_Attributes-Sprite_Data),a    ;store sprite attributes
         ld (ix+Sprite_Attributes-Sprite_Data+4),a
         ld a,(SCRATCHPAD+$02)                    ;now the y coordinates
         ld (ix+Sprite_Y_Position-Sprite_Data),a   ;note because they are
         ld (ix+Sprite_Y_Position-Sprite_Data+4),a ;side by side, they are the same
         add a,8    ;add eight pixels to the next y coordinate
         ld (SCRATCHPAD+$02),a
         ld a,(SCRATCHPAD+$05)
         ld (ix+Sprite_X_Position-Sprite_Data),a    ;store x coordinate, then
         add a,8                        ;add 8 pixels and store another to
         ld (ix+Sprite_X_Position-Sprite_Data+4),a  ;put them side by side
         ld a,e                        ;add eight to the offset in Y to
         add a,8                      ;move to the next two sprites
         ld e,a
         inc hl
        else
         lda SCRATCHPAD+$03                    ;get saved flip control bits
         lsr
         lsr                        ;move d1 into carry
         lda SCRATCHPAD+$00
         bcc NoHFlip                ;if d1 not set, branch
         stay Sprite_Tilenumber+4,y  ;store first tile into second sprite
         lda SCRATCHPAD+$01                    ;and second into first sprite
         stay Sprite_Tilenumber,y
         ldan ++$40                   ;activate horizontal flip OAM attribute
         checka
         bne SetHFAt                ;and unconditionally branch
NoHFlip: stay Sprite_Tilenumber,y    ;store first tile into first sprite
         lda SCRATCHPAD+$01                    ;and second into second sprite
         stay Sprite_Tilenumber+4,y
         ldan ++$00                   ;clear bit for horizontal flip
SetHFAt: orai SCRATCHPAD+$04                    ;add other OAM attributes if necessary
         stay Sprite_Attributes,y    ;store sprite attributes
         stay Sprite_Attributes+4,y
         lda SCRATCHPAD+$02                    ;now the y coordinates
         stay Sprite_Y_Position,y    ;note because they are
         stay Sprite_Y_Position+4,y  ;side by side, they are the same
         lda SCRATCHPAD+$05       
         stay Sprite_X_Position,y    ;store x coordinate, then
         clc                        ;add 8 pixels and store another to
         adcn ++$08                   ;put them side by side
         stay Sprite_X_Position+4,y
         lda SCRATCHPAD+$02                    ;add eight pixels to the next y
         clc                        ;coordinate
         adcn ++$08
         sta SCRATCHPAD+$02
         tya                        ;add eight to the offset in Y to
         clc                        ;move to the next two sprites
         adcn ++$08
         tay
         inx                        ;increment offset to return it to the
         inx                        ;routine that called this subroutine
        endif
         rts

;-------------------------------------------------------------------------------------

        if Z80==0
;unused space (в версии Super Mario Bros..nes)
;а в версии Super Mario Bros (JU) (PRG 1).nes тут 78, ee, cb, f2, ff, ff - зачем??? других различий между этими версиями нет!!!
        .db $ff, $ff, $ff, $ff, $ff, $ff
        endif

;-------------------------------------------------------------------------------------
	if MUSICONINT==0
	include "smbsound.asm"
        include "smbmusic.asm"
	endif
;-------------------------------------------------------------------------------------
;INTERRUPT VECTORS

       if Z80==0
;в конце памяти программы: 82 80 00 80 f0 ff
      .dw NonMaskableInterrupt
      .dw Start
      .dw $fff0  ;unused (в Xevious тоже в конце ff, остальные значения другие, в Bomberman1 в конце 7 других байт)
       endif
      
SwimTileRepOffset     = PlayerGraphicsTable + $9e
MusicHeaderOffsetData = MusicHeaderData - 1
MHD                   = MusicHeaderData
