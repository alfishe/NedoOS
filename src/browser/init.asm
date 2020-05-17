init
        ld e,2 ;MC hires mode
        OS_SETGFX
        
        ;YIELD ;чтобы cmd мог доделать свои дела на экране

        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,e
        ld (setpgs_scr_low),a
        ld (setpgs_scr_attr),a
        ld a,d
        ld (setpgs_scr_high),a
        ld (setpgs_scr_pixels),a
        
        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,e
        ld (codepg4000),a
        ld a,h
        ld (codepg8000),a ;pgdiv
        ld a,l
        ld (codepg_svg),a
        
        OS_NEWPAGE
        ld a,e
        ld (curpgLZW),a

;for JPEG:
        OS_NEWPAGE
        ld a,e
        ld (tpgs+0),a ;mul
        OS_NEWPAGE
        ld a,e
        ld (tpgs+1),a ;y
        OS_NEWPAGE
        ld a,e
        ld (tpgs+2),a ;cb?
        OS_NEWPAGE
        ld a,e
        ld (tpgs+5),a ;cr?

        OS_NEWPAGE
        ld a,e
        ld (temppg8000),a ;depack data, diskbuf

        OS_NEWPAGE
        ld a,e
        ld (histpg),a
        
        ld e,0;COLOR
        OS_CLS

        ld de,zxpal
        OS_SETPAL

        call yieldgetkeynolang ;get mouse coords

        ;call setpgcode4000
        ;call setpgtemp8000
        
;command line = "browser <file to load>"
        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr nz,$+5
         ld hl,defaultfilename
        ld de,linkbuf
        call strcopy

;recode url in linkbuf to full path:
        ld hl,linkbuf
        ld de,curfulllink
        push de
        call strcopy
        pop hl ;curfulllink
        call isprotocolpresent
        jr z,browser_recodefull_protocolpresent
;protocol absent
;1:/file... => file://1:/file...
;ser.ver... => http://ser.ver...
        ld a,(linkbuf+1)
        cp ':'
        ld a,1
        jr nz,$+3
        xor a
        call adddefaultprotocol
browser_recodefull_protocolpresent
;curfulllink OK
;hl=after "//"
;a=protocol
        jp addslashafterserver ;add / after http://ser.ver

defaultfilename
        ;db "0:/hippiman.bmp",0
        ;db "http://zxevo.ru/nos/",0
        db "file://browser/nos.htm",0
        ;db "https://rgb.yandex",0

zxpal
        incbin "zxpal"

