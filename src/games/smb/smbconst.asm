;-------------------------------------------------------------------------------------
;DEFINES

; GAME SPECIFIC DEFINES

MAX_ENEMIES=7
        if COMPACTDATA

AREADATA=$

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;init area up to $074b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UnusedVariable db 0

ObjectOffset          db 0;= $08

FrameCounter          db 0;= $09

SavedJoypadBits       ;= $06fc
SavedJoypad1Bits      db 0;= $06fc
SavedJoypad2Bits      db 0;= $06fd
JoypadBitMask         db 0;= $074a

A_B_Buttons           db 0;= $0a
PreviousA_B_Buttons   db 0;= $0d
Up_Down_Buttons       db 0;= $0b
Left_Right_Buttons    db 0;= $0c

GameEngineSubroutine  db 0;= $0e

ScreenRoutineTask     db 0;= $073c

DemoAction            db 0;= $0717
DemoActionTimer       db 0;= $0718

TimerControl          db 0;= $0747

;Sprite_Data           ;= $0200
;Sprite_Y_Position=Sprite_Data     ;db 0;= $0200
;Sprite_Tilenumber=Sprite_Data+1     ;db 0;= $0201
;Sprite_Attributes=Sprite_Data+2     ;db 0;= $0202
;Sprite_X_Position=Sprite_Data+3     ;db 0;= $0203
;256 bytes

ScreenEdge_PageLoc    ;= $071a
ScreenLeft_PageLoc    db 0;= $071a
ScreenRight_PageLoc   db 0;= $071b
ScreenEdge_X_Pos      ;= $071c
ScreenLeft_X_Pos      db 0;= $071c
ScreenRight_X_Pos     db 0;= $071d

PlayerFacingDir       db 0;= $33
DestinationPageLoc    db 0;= $34
VictoryWalkControl    db 0;= $35
PrimaryMsgCounter     db 0;= $0719
SecondaryMsgCounter   db 0;= $0749

HorizontalScroll      db 0;= $073f
VerticalScroll        db 0;= $0740
ScrollLock            db 0;= $0723
ScrollThirtyTwo       db 0;= $073d
Player_X_Scroll       db 0;= $06ff

AreaData              ;= $e7
AreaDataLow           db 0;= $e7
AreaDataHigh          db 0;= $e8
EnemyData             ;= $e9
EnemyDataLow          db 0;= $e9
EnemyDataHigh         db 0;= $ea

AreaParserTaskNum     db 0;= $071f
ColumnSets            db 0;= $071e
CurrentPageLoc        db 0;= $0725
CurrentColumnPos      db 0;= $0726
BackloadingFlag       db 0;= $0728
BehindAreaParserFlag  db 0;= $0729
AreaObjectPageLoc     db 0;= $072a
AreaObjectPageSel     db 0;= $072b
AreaDataOffset        db 0;= $072c
AreaObjOffsetBuffer   db 0;= $072d
AreaObjectLength      db 0;= $0730
StaircaseControl      db 0;= $0734
AreaObjectHeight      db 0;= $0735
MushroomLedgeHalfLen  db 0;= $0736
EnemyDataOffset       db 0;= $0739
EnemyObjectPageLoc    db 0;= $073a
EnemyObjectPageSel    db 0;= $073b

BlockBufferColumnPos  db 0;= $06a0
MetatileBuffer        ds 0x0d;0xd0;???;= $06a1

CurrentNTAddr_Low     db 0;= $0721
CurrentNTAddr_High    db 0;= $0720
AttributeBuffer       db 0;= $03f9

LoopCommand           db 0;= $0745

DigitModifier         ds 6;???;= $0134

VerticalFlipFlag      db 0;= $0109
FloateyNum_Control    ds MAX_ENEMIES;???;= $0110
ShellChainCounter     ds MAX_ENEMIES;???;= $0125
FloateyNum_Timer      ds MAX_ENEMIES;???;= $012c
FloateyNum_X_Pos      ds MAX_ENEMIES;???;= $0117
FloateyNum_Y_Pos      ds MAX_ENEMIES;???;= $011e
FlagpoleFNum_Y_Pos    db 0;= $010d
FlagpoleFNum_YMFDummy db 0;= $010e
FlagpoleScore         db 0;= $010f
FlagpoleCollisionYPos db 0;= $070f
StompChainCounter     db 0;= $0484

;VRAM_Buffer1_Offset   db 0;= $0300
;VRAM_Buffer1          ds 63;???;= $0301
;VRAM_Buffer2_Offset   db 0;= $0340
;VRAM_Buffer2          ds TitleScreenDataSize-64;63;???;= $0341 ;следующий блок данных в $0363, но нужен буфер до 0x043a

Sprite0HitDetectFlag  db 0;= $0722
ColorRotateOffset     db 0;= $06d4

TerrainControl        db 0;= $0727
AreaStyle             db 0;= $0733
ForegroundScenery     db 0;= $0741
BackgroundScenery     db 0;= $0742
CloudTypeOverride     db 0;= $0743
BackgroundColorCtrl   db 0;= $0744

PlayerEntranceCtrl    db 0;= $0710
GameTimerSetting      db 0;= $0715
WarpZoneControl       db 0;= $06d6
ChangeAreaTimer       db 0;= $06de

MultiLoopCorrectCntr  db 0;= $06d9
MultiLoopPassCntr     db 0;= $06da

SecondaryHardMode     db 0;= $06cc

CoinTallyFor1Ups      db 0;= $0748

BalPlatformAlignment  db 0;= $03a0
Platform_X_Scroll     db 0;= $03a1
PlatformCollisionFlag db 0;= $03a2
YPlatformTopYPos      db 0;= $0401
YPlatformCenterYPos   db 0;= $58

BrickCoinTimerFlag    db 0;= $06bc
StarFlagTaskControl   db 0;= $0746

SprShuffleAmtOffset   db 0;= $06e0
SprShuffleAmt         ds 3;= $06e1
SprDataOffset         ;= $06e4
Player_SprDataOffset  db 0;= $06e4
Enemy_SprDataOffset   ds MAX_ENEMIES;???;= $06e5
Block_SprDataOffset   ;= $06ec
Alt_SprDataOffset     ds 2;???;= $06ec
Bubble_SprDataOffset  ds 3;???;= $06ee
FBall_SprDataOffset   ds 2;???;= $06f1
Misc_SprDataOffset    ds 15;???;= $06f3
SprDataOffset_Ctrl    db 0;= $03ee

Player_State          db 0;= $1d ;0=ground, 1=jumping/swimming?, 2=falling, 3=climbing
Enemy_State           ds MAX_ENEMIES-1;???;= $1e ;-1???
Fireball_State        ds 2;???;= $24
Block_State           ds 4;???;= $26
Misc_State            ds 15;???;= $2a

Player_MovingDir      db 0;= $45
Enemy_MovingDir       db 0;= $46

SprObject_X_Speed     ;= $57
Player_X_Speed        db 0;= $57
Enemy_X_Speed         ds MAX_ENEMIES-1;???;= $58 ;-1???
Fireball_X_Speed      ds 2;???;= $5e
Block_X_Speed         ds 4;???;= $60
Misc_X_Speed          ds 9;???;= $64

Jumpspring_FixedYPos  db 0;= $58 ;=Enemy_X_Speed???
JumpspringAnimCtrl    db 0;= $070e
JumpspringForce       db 0;= $06db

SprObject_PageLoc     ;= $6d
Player_PageLoc        db 0;= $6d
Enemy_PageLoc         ds MAX_ENEMIES-1;???;= $6e ;-1???
Fireball_PageLoc      ds 2;???;= $74
Block_PageLoc         ds 4;???;= $76
Misc_PageLoc          ds 9;???;= $7a
Bubble_PageLoc        ds 3;???;= $83

SprObject_X_Position  ;= $86
Player_X_Position     db 0;= $86
Enemy_X_Position      ds MAX_ENEMIES-1;???;= $87 ;-1???
Fireball_X_Position   ds 2;???;= $8d
Block_X_Position      ds 4;???;= $8f
Misc_X_Position       ds 9;???;= $93
Bubble_X_Position     ds 3;???;= $9c

SprObject_Y_Speed     ;= $9f
Player_Y_Speed        db 0;= $9f
Enemy_Y_Speed         ds MAX_ENEMIES-1;???;= $a0 ;-1???
Fireball_Y_Speed      ds 2;???;= $a6
Block_Y_Speed         ds 4;???;= $a8
Misc_Y_Speed          ds 9;???;= $ac

SprObject_Y_HighPos   ;= $b5
Player_Y_HighPos      db 0;= $b5
Enemy_Y_HighPos       ds MAX_ENEMIES-1;???;= $b6 ;-1???
Fireball_Y_HighPos    ds 2;???;= $bc
Block_Y_HighPos       ds 4;???;= $be
Misc_Y_HighPos        ds 9;???;= $c2
Bubble_Y_HighPos      ds 3;???;= $cb

SprObject_Y_Position  ;= $ce
Player_Y_Position     db 0;= $ce
Enemy_Y_Position      ds MAX_ENEMIES-1;???;= $cf ;-1???
Fireball_Y_Position   ds 2;???;= $d5
Block_Y_Position      ds 4;???;= $d7
Misc_Y_Position       ds 9;???;= $db
Bubble_Y_Position     ds 3;???;= $e4

SprObject_Rel_XPos    ;= $03ad
Player_Rel_XPos       db 0;= $03ad
Enemy_Rel_XPos        db 0;= $03ae
Fireball_Rel_XPos     db 0;= $03af
Bubble_Rel_XPos       db 0;= $03b0
Block_Rel_XPos        ds 2;= $03b1
Misc_Rel_XPos         db 0;= $03b3

SprObject_Rel_YPos    ;= $03b8
Player_Rel_YPos       db 0;= $03b8
Enemy_Rel_YPos        db 0;= $03b9
Fireball_Rel_YPos     db 0;= $03ba
Bubble_Rel_YPos       db 0;= $03bb
Block_Rel_YPos        ds 2;= $03bc
Misc_Rel_YPos         db 0;= $03be

SprObject_SprAttrib   ;= $03c4
Player_SprAttrib      db 0;= $03c4
Enemy_SprAttrib       ds MAX_ENEMIES;???;= $03c5

SprObject_X_MoveForce db 0;= $0400
Enemy_X_MoveForce     ds MAX_ENEMIES;???;= $0401

SprObject_YMF_Dummy   ;= $0416
Player_YMF_Dummy      db 0;= $0416
Enemy_YMF_Dummy       ds MAX_ENEMIES;???;= $0417
Bubble_YMF_Dummy      ds 3;???;= $042c

SprObject_Y_MoveForce ;= $0433
Player_Y_MoveForce    db 0;= $0433
Enemy_Y_MoveForce     ds MAX_ENEMIES+1;???;= $0434 ;+1????
Block_Y_MoveForce     db 2*2;???;= $043c

DisableCollisionDet   db 0;= $0716
Player_CollisionBits  db 0;= $0490
Enemy_CollisionBits   ds MAX_ENEMIES;???;= $0491

SprObj_BoundBoxCtrl   ;= $0499
Player_BoundBoxCtrl   db 0;= $0499
Enemy_BoundBoxCtrl    ds MAX_ENEMIES-1;???;= $049a ;-1???
Fireball_BoundBoxCtrl ds 2;???;= $04a0
Misc_BoundBoxCtrl     ds 9;???;= $04a2 ;начиная с объекта #9 идут misc objects (что это???)

EnemyFrenzyBuffer     db 0;= $06cb
EnemyFrenzyQueue      db 0;= $06cd
Enemy_Flag            ds MAX_ENEMIES;???;= $0f
Enemy_ID              ds MAX_ENEMIES;???;= $16

PlayerGfxOffset       db 0;= $06d5
Player_XSpeedAbsolute db 0;= $0700
FrictionAdderHigh     db 0;= $0701
FrictionAdderLow      db 0;= $0702
RunningSpeed          db 0;= $0703
SwimmingFlag          db 0;= $0704
Player_X_MoveForce    db 0;= $0705
DiffToHaltJump        db 0;= $0706
JumpOrigin_Y_HighPos  db 0;= $0707
JumpOrigin_Y_Position db 0;= $0708
VerticalForce         db 0;= $0709
VerticalForceDown     db 0;= $070a
PlayerChangeSizeFlag  db 0;= $070b
PlayerAnimTimerSet    db 0;= $070c
PlayerAnimCtrl        db 0;= $070d
DeathMusicLoaded      db 0;= $0712
FlagpoleSoundQueue    db 0;= $0713
CrouchingFlag         db 0;= $0714
MaximumLeftSpeed      db 0;= $0450
MaximumRightSpeed     db 0;= $0456

SprObject_OffscrBits  ;= $03d0
Player_OffscreenBits  db 0;= $03d0
Enemy_OffscreenBits   db 0;= $03d1
FBall_OffscreenBits   db 0;= $03d2
Bubble_OffscreenBits  db 0;= $03d3
Block_OffscreenBits   db 0;= $03d4
Misc_OffscreenBits    db 0;= $03d6
EnemyOffscrBitsMasked ds MAX_ENEMIES;???;= $03d8

Cannon_Offset         db 0;= $046a
Cannon_PageLoc        ds 6;???;= $046b
Cannon_X_Position     ds 6;???;= $0471
Cannon_Y_Position     ds 6;???;= $0477
Cannon_Timer          ds 6;???;= $047d

Whirlpool_Offset      =Cannon_Offset;= $046a
Whirlpool_PageLoc     =Cannon_PageLoc;= $046b
Whirlpool_LeftExtent  =Cannon_X_Position;= $0471
Whirlpool_Length      =Cannon_Y_Position;= $0477
Whirlpool_Flag        =Cannon_Timer;= $047d

VineFlagOffset        db 0;= $0398
VineHeight            db 0;= $0399
VineObjOffset         ds 3;???;= $039a
VineStart_Y_Position  db 0;= $039d

Block_Orig_YPos       ds 2;???;= $03e4
Block_BBuf_Low        ds 2;???;= $03e6
Block_Metatile        ds 2;???;= $03e8
Block_PageLoc2        ds 2;???;= $03ea
Block_RepFlag         ds 2;???;= $03ec
Block_ResidualCounter db 0;= $03f0
Block_Orig_XPos       ds 2;???;= $03f1

BoundingBox_UL_Corner ;= $04ac
BoundingBox_UL_XPos   db 0;= $04ac
BoundingBox_UL_YPos   db 0;= $04ad
BoundingBox_LR_Corner ;= $04ae
BoundingBox_DR_XPos   db 0;= $04ae
BoundingBox_DR_YPos   db 0;= $04af
EnemyBoundingBoxCoord ds 4*MAX_ENEMIES;???;= $04b0

PowerUpType           db 0;= $39

FireballBouncingFlag  ds MAX_ENEMIES;???;= $3a
FireballCounter       db 0;= $06ce
FireballThrowingTimer db 0;= $0711

HammerEnemyOffset     ds MAX_ENEMIES;???;= $06ae
JumpCoinMiscOffset    db 0;= $06b7

        align 16;256 ;не помогает
Block_Buffer_1        ds 0xd0;= $0500 ;at least +$b4 ;13 строк по 16 блоков
Block_Buffer_2        ds 0xd0;= $05d0

HammerThrowingTimer   ds MAX_ENEMIES;???;= $03a2
HammerBroJumpTimer    ds MAX_ENEMIES;???;= $3c
Misc_Collision_Flag   ds MAX_ENEMIES;???;= $06be

RedPTroopaOrigXPos    ds MAX_ENEMIES;???;= $0401
RedPTroopaCenterYPos  ds MAX_ENEMIES;???;= $58

XMovePrimaryCounter   ds MAX_ENEMIES;???;= $a0
XMoveSecondaryCounter ds MAX_ENEMIES;???;= $58

CheepCheepMoveMFlag   ds MAX_ENEMIES;???;= $58
CheepCheepOrigYPos    ds MAX_ENEMIES;???;= $0434
BitMFilter            db 0;= $06dd

LakituReappearTimer   db 0;= $06d1
LakituMoveSpeed       ds MAX_ENEMIES;???;= $58
LakituMoveDirection   ds MAX_ENEMIES;???;= $a0

FirebarSpinState_Low  ds MAX_ENEMIES;???;= $58
FirebarSpinState_High ds MAX_ENEMIES;???;= $a0
FirebarSpinSpeed      ds MAX_ENEMIES;???;= $0388
FirebarSpinDirection  ds MAX_ENEMIES;???;= $34

DuplicateObj_Offset   db 0;= $06cf
NumberofGroupEnemies  db 0;= $06d3

BlooperMoveCounter    ds MAX_ENEMIES;???;= $a0
BlooperMoveSpeed      ds MAX_ENEMIES;???;= $58

BowserBodyControls    db 0;= $0363
BowserFeetCounter     db 0;= $0364
BowserMovementSpeed   db 0;= $0365
BowserOrigXPos        db 0;= $0366
BowserFlameTimerCtrl  db 0;= $0367
BowserFront_Offset    db 0;= $0368
BridgeCollapseOffset  db 0;= $0369
BowserGfxFlag         db 0;= $036a
BowserHitPoints       db 0;= $0483
MaxRangeFromOrigin    db 0;= $06dc

BowserFlamePRandomOfs ds MAX_ENEMIES;???;= $0417

PiranhaPlantUpYPos    ds MAX_ENEMIES;???;= $0417
PiranhaPlantDownYPos  ds MAX_ENEMIES;???;= $0434
PiranhaPlant_Y_Speed  ds MAX_ENEMIES;???;= $58
PiranhaPlant_MoveFlag ds MAX_ENEMIES;???;= $a0

FireworksCounter      db 0;= $06d7
ExplosionGfxCounter   ds MAX_ENEMIES;???;= $58
ExplosionTimerCounter ds MAX_ENEMIES;???;= $a0

;sound related defines
NoteLenLookupTblOfs   db 0;= $f0

Square1SoundBuffer    db 0;= $f1
Square2SoundBuffer    db 0;= $f2
NoiseSoundBuffer      db 0;= $f3
AreaMusicBuffer       db 0;= $f4
MusicData             db 0;= $f5
MusicDataLow          db 0;= $f5
MusicDataHigh         db 0;= $f6
MusicOffset_Square2   db 0;= $f7
MusicOffset_Square1   db 0;= $f8
MusicOffset_Triangle  db 0;= $f9

PauseSoundQueue       db 0;= $fa
AreaMusicQueue        db 0;= $fb
EventMusicQueue       db 0;= $fc
NoiseSoundQueue       db 0;= $fd
Square2SoundQueue     db 0;= $fe
Square1SoundQueue     db 0;= $ff

AREADATA_end=$

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;init game up to $076f
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AreaType              db 0;= $074e
AreaAddrsLOffset      db 0;= $074f
AreaPointer           db 0;= $0750

FetchNewGameTimerFlag db 0;= $0757
GameTimerExpiredFlag  db 0;= $0759

JoypadOverride        db 0;= $0758

EntrancePage          db 0;= $0751
AltEntranceControl    db 0;= $0752

CurrentPlayer         db 0;= $0753
PlayerSize            db 0;= $0754
PlayerStatus          db 0;= $0756

Player_Pos_ForScroll  db 0;= $0755
ScrollAmount          db 0;= $0775

OnscreenPlayerInfo    ;= $075a
NumberofLives         db 0;= $075a ;used by current player
HalfwayPage           db 0;= $075b
LevelNumber           db 0;= $075c ;the actual dash number
Hidden1UpFlag         db 0;= $075d
CoinTally             db 0;= $075e
WorldNumber           db 0;= $075f
AreaNumber            db 0;= $0760 ;internal number used to find areas

OffscreenPlayerInfo   ;= $0761
OffScr_NumberofLives  db 0;= $0761 ;used by offscreen player
OffScr_HalfwayPage    db 0;= $0762
OffScr_LevelNumber    db 0;= $0763
OffScr_Hidden1UpFlag  db 0;= $0764
OffScr_CoinTally      db 0;= $0765
OffScr_WorldNumber    db 0;= $0766
OffScr_AreaNumber     db 0;= $0767

ScrollFractional      db 0;= $0768
DisableIntermediate   db 0;= $0769
PrimaryHardMode       db 0;= $076a ;secondaryhardmode is below and cleared every time!!!
WorldSelectNumber     db 0;= $076b

GAMEDATA_end=$

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;reinit mem up to $07d6 ;don't clear topscore, continueworld, worldselectenebleflag
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OperMode              db 0;= $0770
OperMode_Task         db 0;= $0772
VRAM_Buffer_AddrCtrl  db 0;= $0773
DisableScreenFlag     db 0;= $0774
GamePauseStatus       db 0;= $0776
GamePauseTimer        db 0;= $0777

Mirror_PPU_CTRL_REG1  db 0;= $0778
Mirror_PPU_CTRL_REG2  db 0;= $0779

NumberOfPlayers       db 0;= $077a

IntervalTimerControl  db 0;= $077f

Timers                ;= $0780
SelectTimer           db 0;= $0780
PlayerAnimTimer       db 0;= $0781
JumpSwimTimer         db 0;= $0782
RunningTimer          db 0;= $0783
BlockBounceTimer      db 0;= $0784
SideCollisionTimer    db 0;= $0785
JumpspringTimer       db 0;= $0786
GameTimerCtrlTimer    db 0;= $0787
                ds 1
ClimbSideTimer        db 0;= $0789
EnemyFrameTimer       db 0;= $078a
                ds 4
FrenzyEnemyTimer      db 0;= $078f
BowserFireBreathTimer db 0;= $0790
StompTimer            db 0;= $0791
AirBubbleTimer        db 0;= $0792
                ds 2
ScrollIntervalTimer   db 0;= $0795
EnemyIntervalTimer    db 0;= $0796
                ds 6
BrickCoinTimer        db 0;= $079d
InjuryTimer           db 0;= $079e
StarInvincibleTimer   db 0;= $079f
ScreenTimer           db 0;= $07a0
WorldEndTimer         db 0;= $07a1
DemoTimer             db 0;= $07a2
	;ds Timers+0x24-$
                ds 4

PseudoRandomBitReg    db 0;= $07a7
        ;display "PseudoRandomBitReg-Timers=",PseudoRandomBitReg-Timers

;sound related defines
MusicOffset_Noise     db 0;= $07b0
EventMusicBuffer      db 0;= $07b1
PauseSoundBuffer      db 0;= $07b2

Squ2_NoteLenBuffer    db 0;= $07b3
Squ2_NoteLenCounter   db 0;= $07b4
Squ2_EnvelopeDataCtrl db 0;= $07b5
Squ1_NoteLenCounter   db 0;= $07b6
Squ1_EnvelopeDataCtrl db 0;= $07b7
Tri_NoteLenBuffer     db 0;= $07b8
Tri_NoteLenCounter    db 0;= $07b9
Noise_BeatLenCounter  db 0;= $07ba
Squ1_SfxLenCounter    db 0;= $07bb
Squ2_SfxLenCounter    db 0;= $07bd
Sfx_SecondaryCounter  db 0;= $07be
Noise_SfxLenCounter   db 0;= $07bf

DAC_Counter           db 0;= $07c0
NoiseDataLoopbackOfs  db 0;= $07c1
NoteLengthTblAdder    db 0;= $07c4
AreaMusicBuffer_Alt   db 0;= $07c5
PauseModeFlag         db 0;= $07c6
GroundMusicHeaderOfs  db 0;= $07c7
AltRegContentFlag     db 0;= $07ca

WARMMEMDATA_end=$

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;init mem up to $07fe
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DisplayDigits         ;= $07d7
TopScoreDisplay       ds 6;= $07d7
ScoreAndCoinDisplay   ;= $07dd
PlayerScoreDisplay    ds 6;= $07dd ;почему тут? это всё блок DisplayDigits
        ds DisplayDigits+($07f8-$07d7)-$ ;TODO убрать
GameTimerDisplay      ds 6;???;= $07f8 ;почему тут? это всё блок DisplayDigits

WorldSelectEnableFlag db 0;= $07fc
ContinueWorld         db 0;= $07fd
WarmBootValidation    db 0;= $07ff

MEMDATA_end=$

        else
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
AREADATA=0x100
AREADATA_end    = $074b
GAMEDATA_end    = $076f
WARMMEMDATA_end        = $07d6;WarmBootOffset
MEMDATA_end        = $07fe;ColdBootOffset
        ;display "MEMDATA_end=",MEMDATA_end
        ;display "AREADATA=",AREADATA
        ;display "MEMDATA_end-AREADATA=",MEMDATA_end-AREADATA

ObjectOffset          = SCRATCHPAD+$08

FrameCounter          = SCRATCHPAD+$09

SavedJoypadBits       = $06fc
SavedJoypad1Bits      = $06fc
SavedJoypad2Bits      = $06fd
JoypadBitMask         = $074a
JoypadOverride        = $0758

A_B_Buttons           = SCRATCHPAD+$0a
PreviousA_B_Buttons   = SCRATCHPAD+$0d
Up_Down_Buttons       = SCRATCHPAD+$0b
Left_Right_Buttons    = SCRATCHPAD+$0c

GameEngineSubroutine  = SCRATCHPAD+$0e

Mirror_PPU_CTRL_REG1  = $0778
Mirror_PPU_CTRL_REG2  = $0779

OperMode              = $0770
OperMode_Task         = $0772
ScreenRoutineTask     = $073c

GamePauseStatus       = $0776
GamePauseTimer        = $0777

DemoAction            = $0717
DemoActionTimer       = $0718

TimerControl          = $0747
IntervalTimerControl  = $077f

Timers                = $0780
SelectTimer           = $0780
PlayerAnimTimer       = $0781
JumpSwimTimer         = $0782
RunningTimer          = $0783
BlockBounceTimer      = $0784
SideCollisionTimer    = $0785
JumpspringTimer       = $0786
GameTimerCtrlTimer    = $0787
ClimbSideTimer        = $0789
EnemyFrameTimer       = $078a
FrenzyEnemyTimer      = $078f
BowserFireBreathTimer = $0790
StompTimer            = $0791
AirBubbleTimer        = $0792
 ;нижеследующие таймеры уменьшаются только раз в 21 фрейм
ScrollIntervalTimer   = $0795
EnemyIntervalTimer    = $0796
BrickCoinTimer        = $079d
InjuryTimer           = $079e
StarInvincibleTimer   = $079f
ScreenTimer           = $07a0
WorldEndTimer         = $07a1
DemoTimer             = $07a2

Sprite_Data           = $0200

Sprite_Y_Position     = $0200
Sprite_Tilenumber     = $0201
Sprite_Attributes     = $0202
Sprite_X_Position     = $0203

ScreenEdge_PageLoc    = $071a
ScreenEdge_X_Pos      = $071c
ScreenLeft_PageLoc    = $071a
ScreenRight_PageLoc   = $071b
ScreenLeft_X_Pos      = $071c
ScreenRight_X_Pos     = $071d

PlayerFacingDir       = SCRATCHPAD+$33
DestinationPageLoc    = SCRATCHPAD+$34
VictoryWalkControl    = SCRATCHPAD+$35
ScrollFractional      = $0768
PrimaryMsgCounter     = $0719
SecondaryMsgCounter   = $0749

HorizontalScroll      = $073f
VerticalScroll        = $0740
ScrollLock            = $0723
ScrollThirtyTwo       = $073d
Player_X_Scroll       = $06ff
Player_Pos_ForScroll  = $0755
ScrollAmount          = $0775

AreaData              = SCRATCHPAD+$e7
AreaDataLow           = SCRATCHPAD+$e7
AreaDataHigh          = SCRATCHPAD+$e8
EnemyData             = SCRATCHPAD+$e9
EnemyDataLow          = SCRATCHPAD+$e9
EnemyDataHigh         = SCRATCHPAD+$ea

AreaParserTaskNum     = $071f
ColumnSets            = $071e
CurrentPageLoc        = $0725
CurrentColumnPos      = $0726
BackloadingFlag       = $0728
BehindAreaParserFlag  = $0729
AreaObjectPageLoc     = $072a
AreaObjectPageSel     = $072b
AreaDataOffset        = $072c
AreaObjOffsetBuffer   = $072d
AreaObjectLength      = $0730
StaircaseControl      = $0734
AreaObjectHeight      = $0735
MushroomLedgeHalfLen  = $0736
EnemyDataOffset       = $0739
EnemyObjectPageLoc    = $073a
EnemyObjectPageSel    = $073b
MetatileBuffer        = $06a1
BlockBufferColumnPos  = $06a0
CurrentNTAddr_Low     = $0721
CurrentNTAddr_High    = $0720
AttributeBuffer       = $03f9

LoopCommand           = $0745

DisplayDigits         = $07d7
TopScoreDisplay       = $07d7
ScoreAndCoinDisplay   = $07dd
PlayerScoreDisplay    = $07dd
GameTimerDisplay      = $07f8
DigitModifier         = SCRATCHPAD2+$0134

VerticalFlipFlag      = SCRATCHPAD2+$0109
FloateyNum_Control    = SCRATCHPAD2+$0110
ShellChainCounter     = SCRATCHPAD2+$0125
FloateyNum_Timer      = SCRATCHPAD2+$012c
FloateyNum_X_Pos      = SCRATCHPAD2+$0117
FloateyNum_Y_Pos      = SCRATCHPAD2+$011e
FlagpoleFNum_Y_Pos    = SCRATCHPAD2+$010d
FlagpoleFNum_YMFDummy = SCRATCHPAD2+$010e
FlagpoleScore         = SCRATCHPAD2+$010f
FlagpoleCollisionYPos = $070f
StompChainCounter     = $0484

VRAM_Buffer1_Offset   = $0300
VRAM_Buffer1          = $0301
VRAM_Buffer2_Offset   = $0340
VRAM_Buffer2          = $0341
VRAM_Buffer_AddrCtrl  = $0773
Sprite0HitDetectFlag  = $0722
DisableScreenFlag     = $0774
DisableIntermediate   = $0769
ColorRotateOffset     = $06d4

TerrainControl        = $0727
AreaStyle             = $0733
ForegroundScenery     = $0741
BackgroundScenery     = $0742
CloudTypeOverride     = $0743
BackgroundColorCtrl   = $0744
AreaType              = $074e
AreaAddrsLOffset      = $074f
AreaPointer           = $0750

PlayerEntranceCtrl    = $0710
GameTimerSetting      = $0715
AltEntranceControl    = $0752
EntrancePage          = $0751
NumberOfPlayers       = $077a
WarpZoneControl       = $06d6
ChangeAreaTimer       = $06de

MultiLoopCorrectCntr  = $06d9
MultiLoopPassCntr     = $06da

FetchNewGameTimerFlag = $0757
GameTimerExpiredFlag  = $0759

PrimaryHardMode       = $076a
SecondaryHardMode     = $06cc
WorldSelectNumber     = $076b
WorldSelectEnableFlag = $07fc
ContinueWorld         = $07fd

CurrentPlayer         = $0753
PlayerSize            = $0754
PlayerStatus          = $0756

OnscreenPlayerInfo    = $075a
NumberofLives         = $075a ;used by current player
HalfwayPage           = $075b
LevelNumber           = $075c ;the actual dash number
Hidden1UpFlag         = $075d
CoinTally             = $075e
WorldNumber           = $075f
AreaNumber            = $0760 ;internal number used to find areas

CoinTallyFor1Ups      = $0748

OffscreenPlayerInfo   = $0761
OffScr_NumberofLives  = $0761 ;used by offscreen player
OffScr_HalfwayPage    = $0762
OffScr_LevelNumber    = $0763
OffScr_Hidden1UpFlag  = $0764
OffScr_CoinTally      = $0765
OffScr_WorldNumber    = $0766
OffScr_AreaNumber     = $0767

BalPlatformAlignment  = $03a0
Platform_X_Scroll     = $03a1
PlatformCollisionFlag = $03a2
YPlatformTopYPos      = $0401
YPlatformCenterYPos   = SCRATCHPAD+$58

BrickCoinTimerFlag    = $06bc
StarFlagTaskControl   = $0746

PseudoRandomBitReg    = $07a7
WarmBootValidation    = $07ff

SprShuffleAmtOffset   = $06e0
SprShuffleAmt         = $06e1
SprDataOffset         = $06e4
Player_SprDataOffset  = $06e4
Enemy_SprDataOffset   = $06e5
Block_SprDataOffset   = $06ec
Alt_SprDataOffset     = $06ec
Bubble_SprDataOffset  = $06ee
FBall_SprDataOffset   = $06f1
Misc_SprDataOffset    = $06f3
SprDataOffset_Ctrl    = $03ee

Player_State          = SCRATCHPAD+$1d
Enemy_State           = SCRATCHPAD+$1e
Fireball_State        = SCRATCHPAD+$24
Block_State           = SCRATCHPAD+$26
Misc_State            = SCRATCHPAD+$2a

Player_MovingDir      = SCRATCHPAD+$45
Enemy_MovingDir       = SCRATCHPAD+$46

SprObject_X_Speed     = SCRATCHPAD+$57
Player_X_Speed        = SCRATCHPAD+$57
Enemy_X_Speed         = SCRATCHPAD+$58
Fireball_X_Speed      = SCRATCHPAD+$5e
Block_X_Speed         = SCRATCHPAD+$60
Misc_X_Speed          = SCRATCHPAD+$64

Jumpspring_FixedYPos  = SCRATCHPAD+$58
JumpspringAnimCtrl    = $070e
JumpspringForce       = $06db

SprObject_PageLoc     = SCRATCHPAD+$6d
Player_PageLoc        = SCRATCHPAD+$6d
Enemy_PageLoc         = SCRATCHPAD+$6e
Fireball_PageLoc      = SCRATCHPAD+$74
Block_PageLoc         = SCRATCHPAD+$76
Misc_PageLoc          = SCRATCHPAD+$7a
Bubble_PageLoc        = SCRATCHPAD+$83

SprObject_X_Position  = SCRATCHPAD+$86
Player_X_Position     = SCRATCHPAD+$86
Enemy_X_Position      = SCRATCHPAD+$87
Fireball_X_Position   = SCRATCHPAD+$8d
Block_X_Position      = SCRATCHPAD+$8f
Misc_X_Position       = SCRATCHPAD+$93
Bubble_X_Position     = SCRATCHPAD+$9c

SprObject_Y_Speed     = SCRATCHPAD+$9f
Player_Y_Speed        = SCRATCHPAD+$9f
Enemy_Y_Speed         = SCRATCHPAD+$a0
Fireball_Y_Speed      = SCRATCHPAD+$a6
Block_Y_Speed         = SCRATCHPAD+$a8
Misc_Y_Speed          = SCRATCHPAD+$ac

SprObject_Y_HighPos   = SCRATCHPAD+$b5
Player_Y_HighPos      = SCRATCHPAD+$b5
Enemy_Y_HighPos       = SCRATCHPAD+$b6
Fireball_Y_HighPos    = SCRATCHPAD+$bc
Block_Y_HighPos       = SCRATCHPAD+$be
Misc_Y_HighPos        = SCRATCHPAD+$c2
Bubble_Y_HighPos      = SCRATCHPAD+$cb

SprObject_Y_Position  = SCRATCHPAD+$ce
Player_Y_Position     = SCRATCHPAD+$ce
Enemy_Y_Position      = SCRATCHPAD+$cf
Fireball_Y_Position   = SCRATCHPAD+$d5
Block_Y_Position      = SCRATCHPAD+$d7
Misc_Y_Position       = SCRATCHPAD+$db
Bubble_Y_Position     = SCRATCHPAD+$e4

SprObject_Rel_XPos    = $03ad
Player_Rel_XPos       = $03ad
Enemy_Rel_XPos        = $03ae
Fireball_Rel_XPos     = $03af
Bubble_Rel_XPos       = $03b0
Block_Rel_XPos        = $03b1
Misc_Rel_XPos         = $03b3

SprObject_Rel_YPos    = $03b8
Player_Rel_YPos       = $03b8
Enemy_Rel_YPos        = $03b9
Fireball_Rel_YPos     = $03ba
Bubble_Rel_YPos       = $03bb
Block_Rel_YPos        = $03bc
Misc_Rel_YPos         = $03be

SprObject_SprAttrib   = $03c4
Player_SprAttrib      = $03c4
Enemy_SprAttrib       = $03c5

SprObject_X_MoveForce = $0400
Enemy_X_MoveForce     = $0401

SprObject_YMF_Dummy   = $0416
Player_YMF_Dummy      = $0416
Enemy_YMF_Dummy       = $0417
Bubble_YMF_Dummy      = $042c

SprObject_Y_MoveForce = $0433
Player_Y_MoveForce    = $0433
Enemy_Y_MoveForce     = $0434
Block_Y_MoveForce     = $043c

DisableCollisionDet   = $0716
Player_CollisionBits  = $0490
Enemy_CollisionBits   = $0491

SprObj_BoundBoxCtrl   = $0499
Player_BoundBoxCtrl   = $0499
Enemy_BoundBoxCtrl    = $049a
Fireball_BoundBoxCtrl = $04a0
Misc_BoundBoxCtrl     = $04a2

EnemyFrenzyBuffer     = $06cb
EnemyFrenzyQueue      = $06cd
Enemy_Flag            = SCRATCHPAD+$0f
Enemy_ID              = SCRATCHPAD+$16

PlayerGfxOffset       = $06d5
Player_XSpeedAbsolute = $0700
FrictionAdderHigh     = $0701
FrictionAdderLow      = $0702
RunningSpeed          = $0703
SwimmingFlag          = $0704
Player_X_MoveForce    = $0705
DiffToHaltJump        = $0706
JumpOrigin_Y_HighPos  = $0707
JumpOrigin_Y_Position = $0708
VerticalForce         = $0709
VerticalForceDown     = $070a
PlayerChangeSizeFlag  = $070b
PlayerAnimTimerSet    = $070c
PlayerAnimCtrl        = $070d
DeathMusicLoaded      = $0712
FlagpoleSoundQueue    = $0713
CrouchingFlag         = $0714
MaximumLeftSpeed      = $0450
MaximumRightSpeed     = $0456

SprObject_OffscrBits  = $03d0
Player_OffscreenBits  = $03d0
Enemy_OffscreenBits   = $03d1
FBall_OffscreenBits   = $03d2
Bubble_OffscreenBits  = $03d3
Block_OffscreenBits   = $03d4
Misc_OffscreenBits    = $03d6
EnemyOffscrBitsMasked = $03d8

Cannon_Offset         = $046a
Cannon_PageLoc        = $046b
Cannon_X_Position     = $0471
Cannon_Y_Position     = $0477
Cannon_Timer          = $047d

Whirlpool_Offset      = $046a
Whirlpool_PageLoc     = $046b
Whirlpool_LeftExtent  = $0471
Whirlpool_Length      = $0477
Whirlpool_Flag        = $047d

VineFlagOffset        = $0398
VineHeight            = $0399
VineObjOffset         = $039a
VineStart_Y_Position  = $039d

Block_Orig_YPos       = $03e4
Block_BBuf_Low        = $03e6
Block_Metatile        = $03e8
Block_PageLoc2        = $03ea
Block_RepFlag         = $03ec
Block_ResidualCounter = $03f0
Block_Orig_XPos       = $03f1

BoundingBox_UL_XPos   = $04ac
BoundingBox_UL_YPos   = $04ad
BoundingBox_DR_XPos   = $04ae
BoundingBox_DR_YPos   = $04af
BoundingBox_UL_Corner = $04ac
BoundingBox_LR_Corner = $04ae
EnemyBoundingBoxCoord = $04b0

PowerUpType           = SCRATCHPAD+$39

FireballBouncingFlag  = SCRATCHPAD+$3a
FireballCounter       = $06ce
FireballThrowingTimer = $0711

HammerEnemyOffset     = $06ae
JumpCoinMiscOffset    = $06b7

Block_Buffer_1        = $0500
Block_Buffer_2        = $05d0

HammerThrowingTimer   = $03a2
HammerBroJumpTimer    = SCRATCHPAD+$3c
Misc_Collision_Flag   = $06be

RedPTroopaOrigXPos    = $0401
RedPTroopaCenterYPos  = SCRATCHPAD+$58

XMovePrimaryCounter   = SCRATCHPAD+$a0
XMoveSecondaryCounter = SCRATCHPAD+$58

CheepCheepMoveMFlag   = SCRATCHPAD+$58
CheepCheepOrigYPos    = $0434
BitMFilter            = $06dd

LakituReappearTimer   = $06d1
LakituMoveSpeed       = SCRATCHPAD+$58
LakituMoveDirection   = SCRATCHPAD+$a0

FirebarSpinState_Low  = SCRATCHPAD+$58
FirebarSpinState_High = SCRATCHPAD+$a0
FirebarSpinSpeed      = $0388
FirebarSpinDirection  = SCRATCHPAD+$34

DuplicateObj_Offset   = $06cf
NumberofGroupEnemies  = $06d3

BlooperMoveCounter    = SCRATCHPAD+$a0
BlooperMoveSpeed      = SCRATCHPAD+$58

BowserBodyControls    = $0363
BowserFeetCounter     = $0364
BowserMovementSpeed   = $0365
BowserOrigXPos        = $0366
BowserFlameTimerCtrl  = $0367
BowserFront_Offset    = $0368
BridgeCollapseOffset  = $0369
BowserGfxFlag         = $036a
BowserHitPoints       = $0483
MaxRangeFromOrigin    = $06dc

BowserFlamePRandomOfs = $0417

PiranhaPlantUpYPos    = $0417
PiranhaPlantDownYPos  = $0434
PiranhaPlant_Y_Speed  = SCRATCHPAD+$58
PiranhaPlant_MoveFlag = SCRATCHPAD+$a0

FireworksCounter      = $06d7
ExplosionGfxCounter   = SCRATCHPAD+$58
ExplosionTimerCounter = SCRATCHPAD+$a0

;sound related defines
Squ2_NoteLenBuffer    = $07b3
Squ2_NoteLenCounter   = $07b4
Squ2_EnvelopeDataCtrl = $07b5
Squ1_NoteLenCounter   = $07b6
Squ1_EnvelopeDataCtrl = $07b7
Tri_NoteLenBuffer     = $07b8
Tri_NoteLenCounter    = $07b9
Noise_BeatLenCounter  = $07ba
Squ1_SfxLenCounter    = $07bb
Squ2_SfxLenCounter    = $07bd
Sfx_SecondaryCounter  = $07be
Noise_SfxLenCounter   = $07bf

PauseSoundQueue       = SCRATCHPAD+$fa
Square1SoundQueue     = SCRATCHPAD+$ff
Square2SoundQueue     = SCRATCHPAD+$fe
NoiseSoundQueue       = SCRATCHPAD+$fd
AreaMusicQueue        = SCRATCHPAD+$fb
EventMusicQueue       = SCRATCHPAD+$fc

Square1SoundBuffer    = SCRATCHPAD+$f1
Square2SoundBuffer    = SCRATCHPAD+$f2
NoiseSoundBuffer      = SCRATCHPAD+$f3
AreaMusicBuffer       = SCRATCHPAD+$f4
EventMusicBuffer      = $07b1
PauseSoundBuffer      = $07b2

MusicData             = SCRATCHPAD+$f5
MusicDataLow          = SCRATCHPAD+$f5
MusicDataHigh         = SCRATCHPAD+$f6
MusicOffset_Square2   = SCRATCHPAD+$f7
MusicOffset_Square1   = SCRATCHPAD+$f8
MusicOffset_Triangle  = SCRATCHPAD+$f9
MusicOffset_Noise     = $07b0

NoteLenLookupTblOfs   = SCRATCHPAD+$f0
DAC_Counter           = $07c0
NoiseDataLoopbackOfs  = $07c1
NoteLengthTblAdder    = $07c4
AreaMusicBuffer_Alt   = $07c5
PauseModeFlag         = $07c6
GroundMusicHeaderOfs  = $07c7
AltRegContentFlag     = $07ca

UnusedVariable = $06c9
        endif

;-------------------------------------------------------------------------------------
;CONSTANTS

;sound effects constants
Sfx_SmallJump         = %10000000
Sfx_Flagpole          = %01000000
Sfx_Fireball          = %00100000
Sfx_PipeDown_Injury   = %00010000
Sfx_EnemySmack        = %00001000
Sfx_EnemyStomp        = %00000100
Sfx_Bump              = %00000010
Sfx_BigJump           = %00000001

Sfx_BowserFall        = %10000000
Sfx_ExtraLife         = %01000000
Sfx_PowerUpGrab       = %00100000
Sfx_TimerTick         = %00010000
Sfx_Blast             = %00001000
Sfx_GrowVine          = %00000100
Sfx_GrowPowerUp       = %00000010
Sfx_CoinGrab          = %00000001

Sfx_BowserFlame       = %00000010
Sfx_BrickShatter      = %00000001

;music constants
Silence               = %10000000

StarPowerMusic        = %01000000
PipeIntroMusic        = %00100000
CloudMusic            = %00010000
CastleMusic           = %00001000
UndergroundMusic      = %00000100
WaterMusic            = %00000010
GroundMusic           = %00000001

TimeRunningOutMusic   = %01000000
EndOfLevelMusic       = %00100000
AltGameOverMusic      = %00010000
EndOfCastleMusic      = %00001000
VictoryMusic          = %00000100
GameOverMusic         = %00000010
DeathMusic            = %00000001

;enemy object constants 
GreenKoopa            = $00
BuzzyBeetle           = $02
RedKoopa              = $03
HammerBro             = $05
Goomba                = $06
Bloober               = $07
BulletBill_FrenzyVar  = $08
GreyCheepCheep        = $0a
RedCheepCheep         = $0b
Podoboo               = $0c
PiranhaPlant          = $0d
GreenParatroopaJump   = $0e
RedParatroopa         = $0f
GreenParatroopaFly    = $10
Lakitu                = $11
Spiny                 = $12
FlyCheepCheepFrenzy   = $14
FlyingCheepCheep      = $14
BowserFlame           = $15
Fireworks             = $16
BBill_CCheep_Frenzy   = $17
Stop_Frenzy           = $18
Bowser                = $2d
PowerUpObject         = $2e
VineObject            = $2f
FlagpoleFlagObject    = $30
StarFlagObject        = $31
JumpspringObject      = $32
BulletBill_CannonVar  = $33
RetainerObject        = $35
TallEnemy             = $09

;other constants
World1 = 0
World2 = 1
World3 = 2
World4 = 3
World5 = 4
World6 = 5
World7 = 6
World8 = 7
Level1 = 0
Level2 = 1
Level3 = 2
Level4 = 3

TitleScreenDataOffset = $1ec0 ;in chr ROM
TitleScreenDataSize = 0x140
SoundMemory           = $07b0

A_Button              = %10000000
B_Button              = %01000000
Select_Button         = %00100000
Start_Button          = %00010000
Up_Dir                = %00001000
Down_Dir              = %00000100
Left_Dir              = %00000010
Right_Dir             = %00000001

TitleScreenModeValue  = 0
GameModeValue         = 1
VictoryModeValue      = 2
GameOverModeValue     = 3

