        DEVICE ZXSPECTRUM128
        include "gsports.asm"
        include "common.asm"
        include "vs10xx.asm"

XTALI_FREQ = 14000000 ;14mhz on NGS
CLOCKF_VS1011 = 0x8000|((XTALI_FREQ+1000)/2000) ;28mhz
CLOCKF_VS1033 = ((XTALI_FREQ-8000000+2000)/4000)|SC_MULT_03_35X|SC_ADD_03_00X ;49mhz
CLOCKF_VS1053 = ((XTALI_FREQ-8000000+2000)/4000)|SC_MULT_53_40X|SC_ADD_53_00X ;56mhz

        MACRO WDC
        in a,(SSTAT)
        and M_MCRDY
        jr z,$-4
        ENDM

        MACRO WDD
        in a,(SSTAT)
        rrca
        jr nc,$-3
        ENDM

        MACRO ATOZX
        out (ZXDATWR),a
        in a,(ZXSTAT)
        rlca
        jr c,$-3
        ENDM

        MACRO CALCFREEBUFFERSPACE
        ld a,h
        sub d
        and 0x7f
        ENDM

        MACRO LOAD256 IENABLED
.loadloop
        in a,(ZXSTAT)                         ;check if data or command is pending
        and M_CBIT|M_DBIT
        jr z,.loadloop
        rlca
        jr c,.loaddata
;got command
        IF IENABLED
        di
        ENDIF
        call processcommand
        IF IENABLED
        ei
        ENDIF
        jr .loadloop
.loaddata
        in a,(ZXDATRD)
        ld (de),a
        inc e
        jr nz,.loadloop
        inc d
        ENDM

        org GSPROGSTART
begin   di
        ld sp,GSSTACKADDR
;uploading is done via interrupt handler
        ld hl,interrupthandler
        ld (GSINTERRUPTTABLEENTRYADDR),hl
        ld a,GSINTERRUPTTABLEENTRYADDR>>8
        ld i,a
        im 2
;mute mod player
        xor a
        call setmodvolume
        ld a,%10011100
        out (SCTRL),a
;set ngs to 10mhz
        ld d,C_10MHZ
        call ngssetfreq
;hw decoder reset
        ld a,M_MPXRS
        out (SCTRL),a
        WDC
;clear reset signal
        ld a,M_MPXRS|M_SETNCLR
        out (SCTRL),a
;go to 12mhz
        ld d,C_12MHZ
        call ngssetfreq
;write to a register after reset
        ld l,SCI_DECODE_TIME
        ld de,0
        call vswriteregister
;read chip id
        ld l,SCI_STATUS
        call vsreadregister
        ld a,e
        and SS_VER_MASK
        ld (vsversion),a
;set an arbitrary writable page for the ring buffer in 0x8000...0xffff
        ld a,2
        out (MPAG),a
startnewstream
        call vssoftreset                      ;reset decoder setting SDI to compatibility mode
;start preloading
        ld h,0x70
        ld de,0x8000                          ;de is ring buffer write pointer
preloadloop
        LOAD256 0
        ld a,d
        cp 0xdf
        jr c,preloadloop
;start uploading
        ld hl,0x8000                          ;hl is ring buffer read pointer
        ei
mainloop
        in a,(ZXSTAT)                         ;check if a command is pending
        rrca
        jr nc,checkifcandownload
;handle command
        di
        call processcommand
        ei
        jr mainloop
checkifcandownload
        CALCFREEBUFFERSPACE
        cp 3
        jr c,mainloop                         ;keep read and write addresses of the ring buffer at least 256 bytes apart
        LOAD256 1
        set 7,d
        jr mainloop

interrupthandler
        di
        push af
        push bc
        ld a,d
        sub h
        and 0x7f
        cp 3
        jr c,skipupload                       ;keep read and write addresses of the ring buffer at least 256 bytes apart
        in a,(SSTAT)
        rrca 
        jr nc,skipupload                      ;check if data requested
        ld b,32                               ;upload 32 bytes
uploadloop
        ld a,(hl)
        out (MD_SEND),a
        inc hl
        djnz uploadloop
        set 7,h                               ;make sure the address didn't wrap under 0x8000
;blink LED
;        ld a,h
;        rlca
;        rlca
;        out (LEDCTR),a
skipupload
        pop bc
        pop af
        ei
        ret

vssoftreset
        ld l,SCI_VOL
        ld de,SV_SILENCE
        call vswriteregister                  ;set volume to minimum
        ld l,SCI_MODE
        call vsreadregister
        ld a,e
        xor SM_RESET
        ld e,a
        ld a,d
        and ~(SM_SDINEW>>8)                   ;NGS implements compatibility mode only
        ld d,a
        call vswriteregister                  ;reset
        ld a,e
        xor SM_RESET
        ld e,a
        call vswriteregister                  ;clear reset
volumevalue=$+1
        ld de,0
        ld l,SCI_VOL
        call vswriteregister                  ;restore volume
        call vsclockvalue
        ld l,SCI_CLOCKF
        call vswriteregister                  ;set internal clock
vsversion=$+1
        ld a,255
        cp SS_VER_VS1001
        ret nz
        ld l,0x02                             ;Force the clock-doubler on by writing 0x8008 to SCI_INT_FCTLH.
        ld de,0x8008                          ;The datasheet states that you should never write to this register.
        jr vswriteregister                    ;This is, however, an exception.

;l = register
;de = value
vswriteregister
        WDD
        WDC
        ld a,M_MCNCS
        out (SCTRL),a                         ;SCI start
        WDC
        ld bc,MC_SEND
        ld a,2
        out (c),a                             ;write op
        WDC
        out (c),l                             ;which register
        WDC
        out (c),d                             ;high byte
        WDC
        out (c),e                             ;low byte
        WDC
        ld a,M_MCNCS|M_SETNCLR
        out (SCTRL),a                         ;SCI end
        WDC
        ret

;l = register
;out: de = value
vsreadregister
        WDD
        WDC
        ld a,M_MCNCS
        out (SCTRL),a                         ;SCI start
        WDC
        ld bc,MC_SEND
        ld a,3
        out (c),a                             ;read op
        WDC
        out (c),l                             ;which register
        WDC
        ld a,0xff
        out (c),a
        WDC
        ld bc,MC_READ
        in d,(c)                              ;high byte
        WDC
        ld a,0xff
        out (MC_SEND),a
        WDC
        in e,(c)                              ;low byte
        WDC
        ld a,M_MCNCS|M_SETNCLR
        out (SCTRL),a                         ;SCI end
        WDC
        ret

vsclockvalue
;out: de = CLOCKF value
        ld a,(vsversion)
        ld de,CLOCKF_VS1011
        cp SS_VER_VS1001
        ret z
        cp SS_VER_VS1002
        ret z
        cp SS_VER_VS1011
        ret z
        ld de,CLOCKF_VS1033
        cp SS_VER_VS1003
        ret z
        cp SS_VER_VS1033
        ret z
        ld de,CLOCKF_VS1053
        ret

ngssetfreq
;d = frequency constant
        in a,(GSCFG0)
        and %11001111
        or d
        out (GSCFG0),a
        ret

setmodvolume
        out (VOL1),a
        out (VOL2),a
        out (VOL3),a
        out (VOL4),a
        out (VOL5),a
        out (VOL6),a
        out (VOL7),a
        out (VOL8),a
        ret

processcommand
        in a,(ZXCMD)
        rlca
        ld (commandtable+1),a
        out (CLRCBIT),a
commandtable
        jr $
        jr cmdrestart : ASSERT CMDRESTART==0
        jr cmdgetfreebufferspace : ASSERT CMDGETFREEBUFFERSPACE==1
        jr cmdgetchipid : ASSERT CMDGETCHIPID==2
        jr cmdrestartstream : ASSERT CMDRESTARTSTREAM==3
        jr cmdvolumeup : ASSERT CMDVOLUMEUP==4
        jr cmdvolumedown : ASSERT CMDVOLUMEDOWN==5

cmdrestart
        call vssoftreset
        ld d,C_20MHZ
        call ngssetfreq
        jp 0

cmdgetfreebufferspace
        CALCFREEBUFFERSPACE
        ATOZX
        ret

cmdgetchipid
        ld a,(vsversion)
        ATOZX
        ret

cmdrestartstream
        ld sp,GSSTACKADDR
        jp startnewstream

cmdvolumeup
        ld a,(volumevalue)
        or a
        ret z
        dec a
setvolume
        push hl
        push de
        push bc
        ld e,a
        ld d,a
        ld (volumevalue),de
        ld l,SCI_VOL
        call vswriteregister
        pop bc
        pop de
        pop hl
        ret

cmdvolumedown
        ld a,(volumevalue)
        cp SV_SILENCE>>8
        ret nc
        inc a
        jr setvolume

end
        savebin "gscode.bin",begin,end-begin
