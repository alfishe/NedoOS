                org 0x4000
;//colors                
C_KURO   = 0    ; black background
C_SIRO   = 1    ;white background
C_RED    = 2    ;red

;//fade type
B_NORM  = 0x32
B_GURU  = 0x36

B_GURU3 = 0x38
B_YOKO  = 0x39
B_TATE  = 0x3a
B_FADE  = 0x3b
B_SUDA  = 0x3c
B_WIPE  = 0x3d

;////////////////////
;flags
HANAJI   = 0 ; "0"
HAND     = 1 ; "0"
HIDUKE   = 2 ; 25   ;date handler 0-?
HOK      = 3 ; "0"
JUMP     = 4 ; "48"
KURI     = 5 ; "0"
MOTDOYOU = 6 ; "0"
ONANI    = 7 ;  1 ;lamp handler   1-4 ?

SIHO_PIA = 10 ; "0"

SIZ_ATTA = 20 ; "1"
CHI_ATTA = 21
REN_ATTA = 22
NAN_ATTA = 23

 
AKEM_NET = 50
MIKA_NET = 51
TER_NET = 52
RENA_NET = 53
NANA_NET = 54
SIZU_NET = 55
CHIE_NET = 56

TER_DEN = 57


MOT_YATT = 60
TER_YATT = 61

AKE_YARU = 62
RISA_SYO = 63

GOGATU_6 = 64

MOT_KOKU = 65

MOTSUNE = 66

TERUNASI = 70
RAYABA   = 71
SEIFUKU =  72


TEMP01   = 100 ; 1
TEMP02   = 101 ; "0"
TEMP03   = 102 ; "0"
TEMP04   = 103 ; "0"
TEMP05   = 104 ; "0"
TEMP06   = 105 ; "0"
TEMP07   = 106 ; "0"
TEMP08   = 107 ; "0"
TEMP09   = 108 ; "0"


TET_KAIS = 180 
SIH_KAIS = 181

W        = 0xf0 ; "-1"
YOKU     = 201 ; 23  ;excite meter  0-100


;W = array of dialogue elements
;FLG_KI W,'=',-1 - reset and make awailable all dialogue options (max 8) ;0xf0- 0xf7
;FLG_KI W,'DOWN',xx  disable xx element of the dialogue selector 0xff - enabled 0- disabled



BGM = 0x06      ;//load music

NEXT = 0x01     ;//wait for key
CLS  = 0x10     ; clear text area
EXIT = 0x03     ; return from call
T_WAIT = 0x17 ; xx  || wait xx seconds (timed pause) then line feed. do not clear
GATA = 0x18  ;//screenshake



;//=============================================================================================
; //E_NO	-1  TODO
    macro  E_NO	xx
    endm


;//=============================================================================================
;????
    macro EWAIT xx
    endm
;//============================================================================================
;????
    macro SWAIT
    endm

;//=============================================================================================

    macro GAME_END
        db 0x0f
    endm

;//=============================================================================================
    macro JTBL xx
        db 0x0b,0x39
        db xx
    endm
;//=============================================================================================
    macro MC_FLASH count,color
        db 0x16
        db count
        db color
    endm
;//=============================================================================================
    macro GO where
        db 0x0b,0x36
        dw where
    endm
;//=============================================================================================
;//SINARIO "NAME" 0x04  "name" 0x00 ;load scenario ||name.OVL,0||

    macro SINARIO name
        db 0x04
        db name
        db 0x00
    endm
;//=============================================================================================
;//  F_O xx ||| 14 03 xx yy    //clear cg screen with xx (clear type)

    macro F_O clear_type,color
        db 0x14,0x03
        db clear_type
        db color
    endm
;//=============================================================================================
;//  B_O xx ||| 14 04 xx yy    //clear whole screen . fade to black or fade to white

    macro B_O clear_type,color
        db 0x14,0x04
        db clear_type
        db color
    endm
;//============================================================================================= 
;//EVENT_CG "name",clear_type,id_flag        // load and draw image 'name' with 'cleart_type' style
//EVENT_CG  'th_095',B_FADE,56
        macro EVENT_CG name,clear_type,id
                db 0x13,0x01,0x05,0x07,0x0a,0x0e
                db clear_type
                db id
                db name
                db 0x00
        endm
;/////////////////////////////////////////////////////////////////////////////////////////   
;//BAK_INIT "NAME" 13 04 07 0A "name" //load background 'NAME' to memory buffer

    macro BAK_INIT name,clear_type
        db 0x13,0x04,0x07,0x0a
        db name
        db 0x00
        db 0x13,0x0f
        db 0x13,0x02,0x05,0x07,0xaa,0xee,clear_type,0x03,0x00
    endm
;/////////////////////////////////////////////////////////////////////////////////////////   
;<> 0    =  3  <> 6
;<  1    >= 4  != 7
;<= 2    >  5
;/////////////////////////////////////////////////////////////////////////////////////////   
;//FLG_IF   YOKU,'>=',75,RINNGO   ;0x0b 0x40
    
        macro FLG_IF flag,op_code,value,goto
                db 0x0b
                db 0x40
                if op_code = '='
                    db 0x00
                elseif op_code = '>='
                    db 0x01
                elseif op_code = '<='
                    db 0x02
                elseif op_code = '<'
                    db 0x03
                elseif op_code = '>'
                    db 0x04
                elseif op_code = '!='
                    db 0x05
                elseif op_code = '<>'
                    db 0x06
                endif
                db flag
                db value
                dw goto
        endm
;/////////////////////////////////////////////////////////////////////////////////////////   
;FLG_KI  YOKU,'=',0    FLG_KI   ONANI,'+',1
; =  5     - 0x0d                'down' - menu items displayed 0x0f
; + 1      '/' 0e (division)

        macro FLG_KI flag,op_code,value
                db 0x0b

                if op_code = '='
                    db 0x05
                elseif op_code = '+'
                    db 0x01
                elseif op_code = '-'
                    db 0x0d
                elseif op_code = '/'
                    db 0x0e
                elseif op_code = 'DOWN'
                    db 0x0f
                endif 

                db flag
                db value
        endm


;/////////////////////////////////////////////////////////////////////////////////////////   
;T_CG T_CG  'tt_10_02',MOT_A2,0
MOT_A1 = 1
MOT_A2 = 2
MOT_A3 = 3
MOT_B1 = 1
MOT_B2 = 2
MOT_B3 = 3
MOT_C1 = 1
MOT_C2 = 2
MOT_C3 = 3
AKE_A1 = 1
AKE_A2 = 2
AKE_A3 = 3
AKE_B1 = 1
AKE_B2 = 2
AKE_B3 = 3
AKE_C1 = 1
AKE_C2 = 2
AKE_C3 = 3
TET_A1 = 1
TET_A2 = 2
TET_A3 = 3
TET_B1 = 1
TET_B2 = 2
TET_B3 = 3
TET_C1 = 1
TET_C2 = 2
TET_C3 = 3
CHI1 = 1
CHI2 = 2
CHI3 = 3
SIH_A1 = 1
SIH_A2 = 2
SIH_A3 = 3
SIH_B1 = 1
SIH_B2 = 2
SIH_B3 = 3
SIH_C1 = 1
SIH_C2 = 2
SIH_C3 = 3
MIK1 = 1
MIK2 = 2
MIK3 = 3
TER1 = 1
TER2 = 2
TER3 = 3
RIS1 = 1
RIS2 = 2
RIS3 = 3
HIR1 = 1
HIR2 = 2
HIR3 = 3
REN_A1 = 1
REN_A2 = 2
REN_A3 = 3
REN_B1 = 1
REN_B2 = 2
REN_B3 = 3
REN_C1 = 1
REN_C2 = 2
REN_C3 = 3
NAN1 = 1
NAN2 = 2
NAN3 = 3
        macro T_CG t_name,t_pos,t_id
                db 0x13,0x03,0x08,0x09  ;//load and draw sprite over output buffer
                db 0x0d,t_pos
                db 0x00      
                db t_name
                db 0x00
        endm
;/////////////////////////////////////////////////////////////////////////////////////////   
;TATI_ERS remove sprites
        macro TATI_ERS
            db 0x13,0x0f  ;copy memory buffer to output buffer
                db 0x13,0x02,0x05,0x07,0x0a,0x0E,B_SUDA,0x03   ;draw memory buffer
                db 0x00
        endm

;/////////////////////////////////////////////////////////////////////////////////////////   
    ;TODO

    ;MENU_S  1,W,-1
    ;MENU_SET    IKU,"Let's go"
    ;MENU_SET    IKANAI,"Nevermind"
    ;MENU_END


;start menu section
    macro MENU_S a,b,c 
        db 0x19,0x01
    endm
;add options to menu
    macro MENU_SET goto,text
        dw goto
        db text
        db 0x00
    endm

;end menu section. goto selector
    macro MENU_END
        dw 0xffff
    endm
;/////////////////////////////////////////////////////////////////////////////////////////   
    macro CDPLAY track
        db 0x06
        db track
    endm
;/////////////////////////////////////////////////////////////////////////////////////////   
    ;TODO 

EVENT_XSIZE   = 628
EVENT_YSIZE    = 148;

    ;SCR_START   EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
    ;SCR_SET "TH_127",0,EVENT_YSIZE,0,0
    ;SCR_END

    macro SCR_START x,y,xs,ys,l
    endm

    macro SCR_SET file1,file2,toleft_x,toup_y,toright_x,todown_y
        db 0x14,0x08
        db file1
        db 0x00
        db file2
        db 0x00
        db toleft_x
        db toup_y
        db toright_x
        db todown_y
    endm

    macro SCR_END
    endm

;/////////////////////////////////////////////////////////////////////////////////////////   
;  C_KURO   black background
;  C_SIRO   white background
;
;  B_NORM,B_FADE тип проявления;
;
;    B_O B_NORM,C_KURO
;    B_O B_FADE,C_KURO
;    затемнение всего экрана
;    уст. переменную pBOcolor в которой хранится цвет.
;
;
;    F_O B_NORM,C_KURO
;    затухание только картинки;
;
;
; ;       EVENT_CG    'Op_01',B_FADE,80
;        показ картинки с проявлением от чёрного. Весь экран
;
;        EVENT_CG    'Op_02',B_NORM,81
;        затухание к чёрному, проявление от черного. только картинка
;


