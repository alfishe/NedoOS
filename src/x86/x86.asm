        DEVICE ZXSPECTRUM1024
        include "../_sdk/sys_h.asm"

STACK=0x4000

        MACRO _Loop_
        JP (IY) ;EMULOOP (нужный marg или нужный обработчик b/p)
        ENDM 

;если вместо стр.команд включили др.стр.
        MACRO _LoopC
        OUTcom
        JP (IY)
        ENDM 

;если резко сменился PC (полный DE)
        MACRO _LoopJP
        CALCiypgcom
        JP (IY)
        ENDM 

;если выключили др.стр. и резко сменился PC (полный DE)
        MACRO _LoopC_JP
        CALCiypgcom
        JP (IY)
        ENDM 

;если IN/OUT (могла измениться конфигурация памяти)
        MACRO _LoopSWI
        CALCpgcom
        JP (IY)
        ENDM 

        org PROGSTART
begin
        ld sp,STACK
        OS_HIDEFROMPARENT
        ld e,6+0x80 ;keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        ld de,path
        OS_CHDIR      

        ld de,diskname
        OS_OPENHANDLE
        ld a,b
        ld (diskhandle),a
       
        OS_NEWPAGE
        ld a,e
        LD (pgrom0),a
        ld de,trom0
        ld hl,0xc000
;de=имя файла
;hl=куда грузим (0xc000)
;a=в какой странице
        call loadfile_in_ahl

        call swapimer

        LD DE,#0000 ;=PC
        EI 


path
        db "z80",0

diskname
        db "SYS.TRD",0
        
trom0
        db "basic.img",0
        ;DB "pc102782.bin",0

        align 256
temulpgs
        ds 256 ;%10765432

_BX     DW 0
_CX     DW 0
_DX     DW 0
_BP     DW 0
_SI     DW 0
_DI     DW 0
_SP     DW 0

swapimer
	di
        ld de,0x0038
        ld hl,oldimer
        ld bc,3
swapimer0
        ld a,(de)
        ldi ;[oldimer] -> [0x0038]
        dec hl
        ld (hl),a ;[0x0038] -> [oldimer]
        inc hl
        jp pe,swapimer0
	ei
        ret
oldimer
        jp on_int
        jp 0x0038+3

end

        align 256 ;for setmem00004000forwrite
secbuf
        ds 256
        display secbuf+256

	savebin "x86.com",begin,end-begin

	LABELSLIST "../../us/user.l"
