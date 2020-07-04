
islinevisible
;может вызываться два раза за строку cury!!! поэтому при дробном зуме элементы зума должны быть в inccury
;out: NZ=invisible
;keeps hl,de
        ld a,(cury)
islinevisible_patch=$+1
        and 1 ;0 (x2=100%) ;3 (/2=25%)
        ret
inccury
;keeps hl
cury=$+1 ;инициализируется в initframe
        ld de,0
        inc de
        ld (cury),de
        ret
        
initframes_time_scroll
;вызывается перед загрузкой картинки, ничего не знает о картинке
        ld hl,0
        ld (nframes),hl
        ld (xscroll),hl
        ld (yscroll),hl
        ld hl,5
        ld (gifframetime),hl
        ;ret
setzoom
setzoom_patch=$
        scf ;/or a (x1=50%)
        
        ld hl,readchrlomem
        jr nc,$+5
        ld hl,readchrlomemx2
        ld (readchr_patch),hl
        ld a,1
        jr nc,$+4
        ld a,0
        ld (islinevisible_patch),a
        ld a,0xc9
        jr nc,$+4
        ld a,0
        ld (zoomhl),a
        ret

initframe
;вызывать один раз на картинку после setpicwid, setpichgt и после установки gifframetime ;заказывает память под конверченный кадр
;out: ahl=адрес памяти под конверченный кадр
initframe_ditherphase=$+1
        ld hl,dithermcy0-2
        ld (drawscreenline_frombuf_ixaddr),hl
        ex de,hl
        ld hl,0xffff&(dithermcy0-2+dithermcy1-2)
        or a
        sbc hl,de
        ld (initframe_ditherphase),hl
initframe_colorphase=$+1
        ld hl,colorlace0-2
        ld (drawscreenline_frombuf_iyaddr),hl
        ex de,hl
        ld hl,0xffff&(colorlace0-2+colorlace1-2)
        or a
        sbc hl,de
        ld (initframe_colorphase),hl
        ld hl,0x4000;0xc000
        ld (drawscreenline_frombuf_scr),hl
        ld hl,0
        ld (cury),hl

        call initprlinefast ;один раз в начале картинки (потом можно инитить при скролле один раз за всю перерисовку)
        jp reservemem_convertedframe ;заказывает память под конверченный кадр

reservefirstframeaddr
        ld hl,(freemem_hl)
        ld (firstframeaddr),hl
        ld a,(freemem_a)
        ld (firstframeaddrHSB),a
        ret

setpichgt
        LD (curpichgt),HL
         call zoomhl
        inc hl
        srl h
        rr l
        ld (curpichgt_visible),hl
        ret

setpicwid
        LD (curpicwid),HL
         ld d,h
         ld e,l
         add hl,hl
         add hl,de
         ld (curpicwidx3),hl
        ex de,hl
         call zoomhl
        ld b,3
         inc hl
         srl h
         rr l
        djnz $-2-2-1
        ld (keepframe_linesize),hl
        ld a,l
        add hl,hl
        ld (keepframe_linesize_bytes),hl
        ret

zoomhl
        ret ;/nop
        add hl,hl
        ret
        
reservemem_convertedframe
;reserve converted frame with timings:
;+0 (3) pnext
;+3 (2) time
;+5 converted frame
;size = 5 + ((pichgt+1) div 2)*((picwid+7) div 8)*2
        ld hl,(freemem_hl)
        ld a,(freemem_a)
         push af
         push hl
        ld de,(keepframe_linesize_bytes)
        ld bc,(curpichgt_visible)
         ;inc bc
         ;inc bc
        call MULWORD ;hlbc=de*bc
        ld d,b
        ld e,c
        ld bc,5 ;header
        ex de,hl
        add hl,bc
        ex de,hl
        jr nc,$+3
        inc hl
;hlde=size
        call reserve_mem
        ld b,h
        ld c,l ;ld (keepframeaddr),hl
        ld e,a;ld (keepframeaddrHSB),a
         pop hl
         pop af
;ahl=начало кадра
        call writeword ;pnext
        ld c,e
        call writebyte ;pnextHSB
gifframetime=$+1
        ld bc,0 ;time
        call writeword
        ld (keepframeaddr),hl
        ld (keepframeaddrHSB),a        
        ret

keepconvertedline
;запоминаем сконверченную строку из LINEPIXELS
        ld bc,(keepframe_linesize_bytes) ;size (pixels+attr)
        push bc
        ld de,LINEPIXELS;KEEPFRAMELINE
keepframeaddr=$+1
        ld hl,0
keepframeaddrHSB=$+1
        ld a,0
        call puttomem ;запоминаем сконверченную строку
        pop bc ;size
        ld hl,(keepframeaddr)
        ld a,(keepframeaddrHSB)
        add hl,bc
        adc a,0
        ld (keepframeaddr),hl
        ld (keepframeaddrHSB),a
        ret


showframe
;ahl=addr
        push af
        push hl
        call initprlinefast
        pop hl
        pop af

        call readword ;de
        push de ;ld (showframe_nextaddr),de
        call readbyte ;c
        ld b,c
        push bc ;ld (showframe_nextaddrHSB),bc
        call readword
	ld (showframetime),de
        
;skip invisible lines (yscroll):
yscroll=$+1
        ld bc,0
        ld de,(keepframe_linesize_bytes)
        inc bc
        jr showframe_skipyscrollgo
showframe_skipyscroll0
        add hl,de
        adc a,0
showframe_skipyscrollgo
        dec hl
        cpi
        jp pe,showframe_skipyscroll0
xscroll=$+1
        ld bc,0
        add hl,bc
        adc a,0
        ld (keepframeaddr),hl
        ld (keepframeaddrHSB),a        

        ;call setpgtemp4000

        ld hl,(curpichgt_visible)
        ld bc,(yscroll)
        or a
        sbc hl,bc
        jr z,showframelinesq
        jr c,showframelinesq

        ld bc,SCROLLHGT;200 ;TODO в зависимости от scry
        call minhl_bc_tobc        
        ld hy,c
         ;ld hy,100
        ld de,0x4000 ;TODO в зависимости от scry
;рисовать прямо из памяти (окна 2,3), а пиксели/атрибуты переключать в 0x4000:
showframelines0
;de=screen
         ;push de
        ld hl,(keepframeaddr)
        ld a,(keepframeaddrHSB)
        rl h
        rla
        rl h
        rla
        srl h
        scf
        rr h
        ld c,a
        ld b,textpages/256
        ld a,(bc)
         ex af,af'
        inc c
        ld a,(bc)
        SETPG32KHIGH
         ex af,af'
        SETPG32KLOW
         ;pop bc
         ld b,d
         ld c,e
;hl=data
;bc=screen=0x4000+
        call prlinefast ;keeps bc (except bit 5,b), bit 5,b doesn't matter
        ld hl,(keepframeaddr)
        ld a,(keepframeaddrHSB)
keepframe_linesize_bytes=$+1
        ld de,0
        add hl,de
        ld (keepframeaddr),hl
        ld hl,40
        adc a,h;0
        ld (keepframeaddrHSB),a
        add hl,bc
         ex de,hl ;next screen line, bit 5,b doesn't matter
        dec hy
        jp nz,showframelines0

showframelinesq
        pop af
        pop hl ;next
        ret

initprlinefast
stopprlinefast_data=$+1
        ld hl,0
stopprlinefast_patch=$+1
        ld (stopprlinefast_data),hl ;снимаем старый патч

        ld hl,(keepframe_linesize) ;TODO endx (картинка может быть больше экрана)
        ld bc,80
        call minhl_bc_tobc
        
        ld de,0 ;TODO x (картинка может быть не прижата к левому краю)

;e=visible x in chr
;c=visible endx in chr
;(keepframe_linesize)=picwid in chr
        ld a,e ;x
        rra
        sbc a,a
        and 0x2b ;"dec hl"
        ld (prlinefast_datadec),a
        
        ld a,e ;x
        inc a
        rra
        rra ;CY for x=1,2, 5,6, ...
        sbc a,a
        and 0xe8-0xa8
        add a,0xa8;set 5,b(0xe8) for x=1,2, 5,6, ..., or else res 5,b(0xa8)
        ld (prlinefast_scrset5),a
        
;entry = prlinefast_go + 0, 3, 6, 9...:
        ;de=x
        ld hl,prlinefast_go
        add hl,de
        add hl,de
        add hl,de        
        ld (prlinefast_jp),hl
        ld (prlinefast_jp2),hl
        
;какое в конце получается смещение sp относительно начального data
        ;прибавим 2*сколько раз сделали pop (включая pseudo-pop в начале)
        ;((endx-1)/2 - x/2)+1 = ((endx+1)/2 - x/2) раз сделали pop
        ld a,c ;endx
        inc a
         srl a
         srl e ;x
         sub e ;((endx+1)/2 - x/2)
         add a,a ;NC ;TODO протестировать or 0x01:sub e:and 0xfe
        ld e,a
        ;ld d,0 ;de=смещение sp относительно начального data
;какое нам надо получить начальное смещение data для paper:
keepframe_linesize=$+1
        ld hl,0;(keepframe_linesize)
        ;or a
        sbc hl,de
        ld (prlinefast_sizeadd),hl ;картинка может быть больше экрана, нельзя просто обойтись чётной шириной и не переставлять sp

;exitpatch = prlinefast_go + endx*3 - 2
;но при x mod 4 = 3 надо на 1 байт раньше
        ;bc=endx
        ld hl,prlinefast_go-2
        add hl,bc
        add hl,bc
        add hl,bc
        
        ld a,c ;endx
        cpl
        and 3

        jr nz,$+3
        dec hl       
        ld (stopprlinefast_patch),hl
        ld e,(hl)
        ld (hl),0xdd
        inc hl
        ld d,(hl)
        ld (hl),0xe9 ;"jp (ix)"
        ld (stopprlinefast_data),de
        
        ld hl,prlinefastq
        jr nz,$+5
        ld hl,prlinefastqres5h
        ld (prlinefast_ix),hl
        ld de,prlinefastq2-prlinefastq
        add hl,de
        ld (prlinefast_ix2),hl

        ret
        
;interrupt handler keeps de in (sp) to restore data
prlinefast
;hl=data
;bc=screen (kept except bit 5,b)
        ld (prlinefastsp),sp ;TODO один раз
prlinefast_datadec=$
        nop ;/dec hl for odd x
        ld e,(hl)
        inc hl
        ld d,(hl) ;берём вручную, чтобы стек не запорол область перед данными
        inc hl
         exx
;setpgs_scr_pixels=$+1
;         ld a,0
        ld a,(user_scr0_high)
         SETPG16K
         exx
        ld sp,hl
prlinefast_scrset5=$+1
        res 5,b ;/set 5,b for x=1,2, 5,6, ...
        ld h,b
        ld l,c
prlinefast_ix=$+2
        ld ix,prlinefastq
prlinefast_jp=$+1
        jp prlinefast_go+1 ;может быть другая точка ;draw pixels
prlinefastqres5h ;endx mod 4 = 3
        res 5,h
        ld (hl),e
prlinefastq ;endx mod 4 = 0, 1, 2
;нельзя выходить сразу после pop de:ld (hl),d, надо после pop de
prlinefast_sizeadd=$+1
        ld hl,0
        add hl,sp ;attr data
        ld sp,SPOIL4B ;можно портить (дальше de станет неактуальным и не сможет исправлять стек)
         exx
;setpgs_scr_attr=$+1
;         ld a,0
        ld a,(user_scr0_low)
         SETPG16K
         exx
        ld e,(hl)
        inc hl
        ld d,(hl) ;берём вручную, чтобы стек не запорол область перед данными
        inc hl
        ld sp,hl
        ld h,b
        ld l,c        
prlinefast_ix2=$+2
        ld ix,prlinefastq2
prlinefast_jp2=$+1
        jp prlinefast_go ;может быть другая точка ;draw attr
prlinefastq2res5h ;endx mod 4 = 3
        res 5,h
        ld (hl),e
prlinefastq2 ;endx mod 4 = 0, 1, 2
;нельзя выходить сразу после pop de:ld (hl),d, надо после pop de
prlinefastsp=$+1
        ld sp,0
        ret
prlinefast_go
        dup 80/4-1
        ld (hl),e
        set 5,h
        ld (hl),d
        inc hl
        pop de
        ld (hl),d
        res 5,h
        ld (hl),e
        inc hl
        pop de
        edup
        ld (hl),e
        set 5,h
        ld (hl),d
        inc hl
        pop de
        ld (hl),d
        res 5,h
        ld (hl),e
        jp (ix)



