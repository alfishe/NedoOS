                ORG 0x0000
B_NORM  = 0x32
B_GURU  = 0x36

B_GURU3 = 0x38
B_YOKO  = 0x39
B_TATE  = 0x3a
B_FADE  = 0x3b
B_SUDA  = 0x3c
B_WIPE  = 0x3d




NEXT = 0x01  ;//wait for key
EXIT = 0x03  ; return from call
SINARIO = 0x04  ;//load scenario ||name.OVL,0||
BGM = 0x06  ;//load music
CR = 0x0a       ;//carriage return //ENTER//

ENDING = 0x0f   ; xx || good ending xx
GAMEOVER = 0x10 ;   bad ending


FLASH = 0x16 ;//flash
PAUSE = 0x08  ;     || wait for key and continue
T_WAIT = 0x17 ; xx  || wait xx seconds (timed pause)
GATA = 0x18  ;//screenshake


FLG = 0x0b      ;//work with loal flags
F_CALI  = 0x01  ; local_variable[XX]=local_variable[XX]+YY 
F_PLUS  = 0x02  ; local_variable[XX]=local_variable[XX]+local_variable[YY]
;0x03
F_COPYI = 0x05  ;//xx,yy  //set flag xx with yy  //FLG,F_COPYI,3,1  local_variable[3]=1
F_COMP = 0x06   ;//x,y,z local_variable[x]=local_variable[y]-local_variable[z]
F_COMPI = 0x07  ; x,y,z    local_variable[x] = local_variable[y]-z
F_AND    = 0x08  ;x, y, z || if (local_variable[y]>0 AND local_variable[z]>0) then local_variable[x]=1
;0x09
F_EXIT   = 0x0a  ; xx   if local_variable[xx]==0 then exit     ||,255
F_MAND =  0x0b   ; xx ,a,b,c   || AND _xx__ num of operands [a]=[a]&[b]&[c]..&..[x]  [a]=1 if all values of variables> 0  3,255,102,10
F_MOR = 0x0c     ; xx ,a,b,c   || OR  _xx__ num of operands [a]=[a]||[b]||[c]..||..[x]  [a]=1 if any value of variables> 0  3,255,102,10
F_RAND = 0x14    ; [xx],YY     || randomize
F_JGR = 0x32     ; xx , YYYY   || if local_variable[xx]>0 then goto YYYY
F_JEQ = 0x33    ; xx,yyyy ; if (local_variable[xx]==0) then goto yyyy
F_JLW = 0x34    ; xx,yyyy ; IF local_variable[XX]<0 THEN GOTO yyyy
;0x35
F_JR = 0x36     ; yyyy      ; goto YYYY
F_CALLS = 0x39  ; xx, call1,call2,call3....callX, 0xffff  ||  call based on local_variable[xx] value [xx]=0 - call 1, [xx]=1 call2 etc


G_FLG = 0x0c    ;//work with global vars
G_COPYF = 0x01  ;xx,yy  || local_variable[xx]=global_variable[yy]
G_COPYG = 0x02  ;xx,yy  || global_variable[xx]= local_variable[yy]
G_COPYI = 0x03  ;xx,yy  || set value of var with value      //G_FLG,G_COPYI,180,15  global_variable[180]=15


C_BLD = 0x12    ;//set menu      //C_BLD,C_V_ON,3 enable menu 3
C_V_ON = 1      ;//set  menu OFF
C_V_OFF = 2    ;  //set menu ON
C_N_ON = 4      ;//set submenu OFF
C_N_OFF = 5     ;//set submenu ON


BUF = 0x13           ;   //BUF, B_COPY01 - 
B_COPY01 = 0x0f         ; copy image from memory buffer to output buffer
B_COPY10 = 0x10         ;//store background - copy from screen to memory buffer



ERASE = 0x14    ;//clear variables       //ERASE,E_GFLG,count_x,var1,var2,...,varX //clear 'count_x' next variables
E_GFLG = 1      ;//global variables flag
E_VRAM0 = 0x03  ; type || clear screen with clear_type[type]


ANI   = 0x15    ;ANI,anim_cmd,anim_num 
A_ON = 0x03     ;enable animation anim_num
A_OFF = 0x04     ;disable animation anim_num
A_INIT = 0x05   ;init animations (stop animations)

;//// macro definitions
;//=============================================================================================
;//  B_O xx |||  15 04 14 03 xx     //disable anims. clear screen with xx (clear type)

    macro B_O clear_type
        db ANI,A_OFF
        db 0x14,0x03
        db clear_type
    endm
;//=============================================================================================
;//BAK_INIT "NAME" 13 04 07 0A "name" //load background 'NAME' to memory buffer

    macro BAK_INIT name
        db 0x13,0x04,0x07,0x0a
        db name
        db 0x00
    endm
;//=============================================================================================
;//B_P1 xx   // disable anim .display image from memory buffer to screen without change output buffer
        macro B_P1 xx

                db ANI,A_OFF
                db 0x13,0x02,0x5,0x07,0x0a,0x0e
                db xx
                db 0x04
                db 0x00
        endm
;//=============================================================================================
        macro K_CG  sprname, sprmod, XX, animnum
                db ANI,A_OFF
                db 0x13,0x03,0x08,0x09  ;//load and draw sprite over output buffer
                db 0x0d,XX
                db 0x00
                db sprname
                if sprmod != 0
                        db sprmod
                endif
                db 0x00


                db 0x13,0x02,0x05,0x08,0x09,0x0e,B_FADE,0x03,0x00 ;//transfer output buffer to screen
                db 0x15,0x01,animnum   ;//load and allow animation number 'anim_num'
                db 0x0d,XX
                db 0x00

                db sprname          ;//animation name = sprite_name + sprite_mod2 + "A0"
                if      sprmod !=0
                                db sprmod
                endif
                db "A0"
                db 0x00                    
        endm


;//=============================================================================================
;//T_CG "CT10",0,0,10,1  15 04 13 03 08 09 0d 0a 00 43 54 31 30 00 13 02 05 07 0a 0e 3c 03 00 15 01 01 0d 0a 00 43 54 31 30 41 30 00

;//      T_CG "CT10",0,0,10,1
;//      15 04 13 03 08 09 0d 0a 00 xx xx xx xx xx 00 13 02 05 07 0a 0e 3c 03 00 15 01 01 0d 0a 00 xx xx xx xx xx xx 00
;//      T_CG "CT01","W",0,15,1
;//      15 04 13 03 08 09 0d 0f 00 xx xx xx xx xx 00 13 02 05 07 0a 0e 3c 03 00 15 01 01 0d 0f 00 xx xx xx xx xx xx 00
;//      T_CG "CT13","F",0,15,1
;//      15 04 13 03 08 09 0d 0f 00 xx xx xx xx xx 00 13 02 05 07 0a 0e 3c 03 00 15 01 01 0d 0f 00 xx xx xx xx xx xx 00

;//      load sprite with animation to output buffer and allow animation

        macro T_CG  sprname, sprmod, sprmod2, XX, animnum
                db ANI,A_OFF        //stop animations
                db 0x13,0x03,0x08,0x09  ;//load and draw sprite over output buffer
                db 0x0d,XX
                db 0x00
                db sprname
                if sprmod != 0
                        db sprmod
                endif
                db 0x00

                if sprmod2 !=0                  ;//load second image
                        db 0x13,0x03,0x08,0x09  ;//load and draw sprite over output buffer
                        db 0x0d,XX
                        db 0x00      
                        db sprname
                        db sprmod2
                        db 0x00
                endif


                db 0x13,0x02,0x05,0x07,0x0a,0x0e,B_SUDA,0x03,0x00 ;//transfer output buffer to screen
                db 0x15,0x01,animnum   ;//load and allow animation number 'anim_num'
                db 0x0d,XX
                db 0x00

                db sprname          ;//animation name = sprite_name + sprite_mod + "A0"
                if      sprmod2 !=0
                                db sprmod2
                endif
                db "A0"
                db 0x00                    
        endm
;///////////////////////////////////////////////////////////////////////////////////
;load sprite. not display it.
        macro TU_CG  sprname, sprmod, sprmod2, XX, animnum
                db 0x13,0x03,0x08,0x09  ;//load and draw sprite over output buffer
                db 0x0d,XX
                db 0x00
                db sprname
                if sprmod != 0
                        db sprmod
                endif
                db 0x00

                if sprmod2 !=0                  ;//load second image
                        db 0x13,0x03,0x08,0x09  ;//load and draw sprite over output buffer
                        db 0x0d,XX      
                        db 0x00
                        db sprname
                        db sprmod2
                        db 0x00
                endif

                db 0x15,0x01,animnum   ;//load and allow animation number 'anim_num'
                db 0x0d,XX
                db 0x00

                db sprname          ;//animation name = sprite_name + sprite_mod + "A0"
                if      sprmod2 !=0
                                db sprmod2
                endif
                db "A0"
                db 0x00     
                db ANI,A_OFF
        endm
;///////////////////////////////////////////////////////////////////////////////////
//load TB_008 before sprite

        macro T_CG1  sprname, sprmod, sprmod2, XX, animnum
                db ANI,A_OFF

                db 0x13,0x03,0x07,0x0a  //load 'mask' image
                db "TB_008"
                db 0x00

                db 0x13,0x03,0x08,0x0a  ;//load and draw sprite over output buffer
                db 0x0d,XX
                db 0x00
                db sprname
                if sprmod != 0
                        db sprmod
                endif
                db 0x00

                if sprmod2 !=0                  ;//load second image
                        db 0x13,0x03,0x08,0x09  ;//load and draw sprite over output buffer
                        db 0x0d,XX
                        db 0x00      
                        db sprname
                        db sprmod2
                        db 0x00
                endif


                db 0x13,0x02,0x05,0x08,0x09,0x0e,B_SUDA,0x03,0x00 ;//transfer output buffer to screen
                db 0x15,0x01,animnum   ;//load and allow animation number 'anim_num'
                db 0x0d,XX
                db 0x00

                db sprname          ;//animation name = sprite_name + sprite_mod + "A0"
                if      sprmod2 !=0
                                db sprmod2
                endif
                db "A0"
                db 0x00                    
        endm

/////////////////////////////////////////////////////////////////////////////////////////
;//E_CG clear_type,"name"        // load and draw image 'name' with 'cleart_type' style      //E_CG B_YOKO,"T_01"
        macro E_CG clear_type, name
                db ANI,A_OFF
                db 0x13,0x01,0x05,0x07,0x0a,0x0e,clear_type
                db name
                db 0x00
        endm
/////////////////////////////////////////////////////////////////////////////////////////
        macro SUDA_CLS
                db ANI,A_OFF
                db 0x14,0x03,B_SUDA
        endm
/////////////////////////////////////////////////////////////////////////////////////////
        macro EF_SET num
                db FLG,F_COPYI,num,1
                db FLG,F_JR
                dw M_EXIT
        endm
/////////////////////////////////////////////////////////////////////////////////////////
        macro B_P0 clear_type   //draw image from output buffer with 'clear_type'
                db ANI,A_OFF
                db 0x13,0x02,0x05,0x07,0x0a,0x0E,clear_type,0x03
                db 0x00

        endm
/////////////////////////////////////////////////////////////////////////////////////////
        macro BN_P1 clear_type   //draw image from output buffer with 'clear_type'
                db ANI,A_OFF
                db 0x13,0x02,0x05,0x08,0x0a,0x0E,clear_type,0x03
                db 0x00
        endm
/////////////////////////////////////////////////////////////////////////////////////////