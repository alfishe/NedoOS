;4000: 64 канала(H) * 64 позиции(L) = 4096 треков
;8000..ffff: dynamic memory

BIGENDIAN=0 ;0=LSB,HSB

setscrpg
        ld a,(user_scr0_high) ;ok
        SETPG16K
        ret
setpgroots
pgroots=$+1
        ld a,0
        SETPG16K
        ret

pokecurtime_curtrack_c
;c=data
        ld a,(curtrack)
;pokecurtime_tracka_c
;a=track
;c=data
        ld hl,(curtime)
        call tracktime_totrackpartindex
poketrackpartindex_c
;hl=index
;lx=part
;a=track
;c=data
        ex de,hl
        call getroot ;out: hl=root
        call writetopoi_c ;keeps de ;c<->mem
        ex de,hl
;c<->mem
        ret

peekcurtime_tracka
;a=track
        ld hl,(curtime)
        call tracktime_totrackpartindex
peektrackpartindex
;hl=index
;lx=part
;a=track
        ex de,hl
        call getroot ;out: hl=root
        call readfrompoi ;keeps de
        ex de,hl
        ret

getroot
;lx=part
;a=track
        add a,0x40
        ld h,a ;номер канала
        ;ld l,0*4
        ld a,lx ;part
        add a,a
        add a,a
        ld l,a
;hl=root
        ret

getendaddr
;lx=part
;a=track
        call getroot ;out: hl=root
        ld de,0xffff
        call findleft ;out: de=nonempty index (or 0), a=data
;de=addr ;последний байт трека
        ret

tracktime_totrackpartindex
;a=track
;hl=time
;если канал подписан на ордер, то найти на месте или влево цифру ордера, index=(time-digittime)
;иначе index=time
        push af
        push hl
        call gettracktype
        inc hl
        ld a,(hl) ;номер ордера (0=нет)
        pop hl
        or a ;канал подписан на ордер?
        jr z,tracktime_toindexpart_noorder ;part=a=0
        ;push af
         push de
        push hl
        ex de,hl
        xor a ;TODO номер канала ордера
        ld lx,0 ;у ордера всегда берём дефолтную часть (part=0), т.к. ордер не подчиняется ордерам
        call getroot
        call findleft ;out: de=nonempty index (or 0), a=data (1..62 or 0)
        pop hl ;time
        or a
        sbc hl,de ;time-digittime
         pop de
        ;pop af
tracktime_toindexpart_noorder
        ld lx,a
        pop af
;hl=index
;lx=part
;a=track
        ret

;пусть номер трека и смещение в треке - это функция от номера канала и времени (зависит от ордера, если канал привязан к ордеру). всего 64 канала * 64 позиции = 4096 треков (одна страница адресов)
;адрес в треке - функция номера трека и смещения в треке
;для этого каждый трек (длиной 64K) храним как бинарное дерево: адрес левой части, адрес правой части
;и так до минимального элемента (4 байта, которые смотрим непосредственно)
;адрес делится на 4, поэтому 2 байтами можно адресовать 256K (16 страниц)
;но так будет медленно, поэтому выделим 32K для каждого (канал & 7)

        macro BITINC_D nbit
        bit nbit,d
        jr z,$+4
         inc l
         inc l
        endm
        macro BITINC_E nbit
        bit nbit,e
        jr z,$+4
         inc l
         inc l
        endm

        macro HLFROMHL
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        or h
        endm

readfrompoi
;hl=track root (4 bytes: left poi, right poi)
;de=index (kept)
        BITINC_D 7
        HLFROMHL
        ret z ;пусто, возвращает 0=NOTE_SPACE (только для чтения!!!)
        BITINC_D 6
        HLFROMHL
        ret z ;пусто, возвращает 0=NOTE_SPACE (только для чтения!!!)
        BITINC_D 5
        HLFROMHL
        ret z ;пусто, возвращает 0=NOTE_SPACE (только для чтения!!!)
        BITINC_D 4
        HLFROMHL
        ret z ;пусто, возвращает 0=NOTE_SPACE (только для чтения!!!)
        BITINC_D 3
        HLFROMHL
        ret z ;пусто, возвращает 0=NOTE_SPACE (только для чтения!!!)
        BITINC_D 2
        HLFROMHL
        ret z ;пусто, возвращает 0=NOTE_SPACE (только для чтения!!!)
        BITINC_D 1
        HLFROMHL
        ret z ;пусто, возвращает 0=NOTE_SPACE (только для чтения!!!)
        BITINC_D 0
        HLFROMHL
        ret z ;пусто, возвращает 0=NOTE_SPACE (только для чтения!!!)
        BITINC_E 7
        HLFROMHL
        ret z ;пусто, возвращает 0=NOTE_SPACE (только для чтения!!!)
        BITINC_E 6
        HLFROMHL
        ret z ;пусто, возвращает 0=NOTE_SPACE (только для чтения!!!)
        BITINC_E 5
        HLFROMHL
        ret z ;пусто, возвращает 0=NOTE_SPACE (только для чтения!!!)
        BITINC_E 4
        HLFROMHL
        ret z ;пусто, возвращает 0=NOTE_SPACE (только для чтения!!!)
        BITINC_E 3
        HLFROMHL
        ret z ;пусто, возвращает 0=NOTE_SPACE (только для чтения!!!)
        BITINC_E 2
        HLFROMHL
        ret z ;пусто, возвращает 0=NOTE_SPACE (только для чтения!!!)
        ld a,e
        rra
        jr nc,$+3
         inc l
        rra
        jr nc,$+4
         inc l
         inc l
        ld a,(hl)
        ret

        macro WRITETOPOI_D nbit,addr
        BITINC_D nbit
        inc l
        ld a,(hl)
        dec l
        or (hl)
        jp z,addr ;пусто
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        endm

        macro WRITETOPOI_E nbit,addr
        BITINC_E nbit
        inc l
        ld a,(hl)
        dec l
        or (hl)
        jp z,addr ;пусто
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        endm

writetopoi_c
;hl=track root (4 bytes: left poi, right poi)
;de=index (kept)
;c=data
;out: c<->mem
        ld a,c
        or a
        jp z,writetopoi_space
        WRITETOPOI_D 7,writetopoi_create15 ;если надо, создать узел из 32768 байт
        WRITETOPOI_D 6,writetopoi_create14
        WRITETOPOI_D 5,writetopoi_create13
        WRITETOPOI_D 4,writetopoi_create12
        WRITETOPOI_D 3,writetopoi_create11
        WRITETOPOI_D 2,writetopoi_create10
        WRITETOPOI_D 1,writetopoi_create9
        WRITETOPOI_D 0,writetopoi_create8
        WRITETOPOI_E 7,writetopoi_create7
        WRITETOPOI_E 6,writetopoi_create6
        WRITETOPOI_E 5,writetopoi_create5
        WRITETOPOI_E 4,writetopoi_create4
        WRITETOPOI_E 3,writetopoi_create3
        WRITETOPOI_E 2,writetopoi_create2 ;если надо, создать узел из 4 байт
        ld a,e
        rra
        jr nc,$+3
         inc l
        rra
        jr nc,$+4
         inc l
         inc l
        ld a,(hl)
        ld (hl),c
        ld c,a
        ret

        macro WRITETOPOI_CREATE_D nbit
        push de
        ex de,hl
        call newmem ;keep de
        ex de,hl
        ld (hl),e
        inc l
        ld (hl),d
        ex de,hl
        pop de
        BITINC_D nbit
        endm

        macro WRITETOPOI_CREATE_E nbit
        push de
        ex de,hl
        call newmem ;keep de
        ex de,hl
        ld (hl),e
        inc l
        ld (hl),d
        ex de,hl
        pop de
        BITINC_E nbit
        endm

writetopoi_create15 ;создать узел из 32768 байт
        WRITETOPOI_CREATE_D 6
writetopoi_create14 ;создать узел из 16384 байт
        WRITETOPOI_CREATE_D 5
writetopoi_create13 ;создать узел из 8192 байт
        WRITETOPOI_CREATE_D 4
writetopoi_create12 ;создать узел из 4096 байт
        WRITETOPOI_CREATE_D 3
writetopoi_create11 ;создать узел из 2048 байт
        WRITETOPOI_CREATE_D 2
writetopoi_create10 ;создать узел из 1024 байт
        WRITETOPOI_CREATE_D 1
writetopoi_create9 ;создать узел из 512 байт
        WRITETOPOI_CREATE_D 0
writetopoi_create8 ;создать узел из 256 байт
        WRITETOPOI_CREATE_E 7
writetopoi_create7 ;создать узел из 128 байт
        WRITETOPOI_CREATE_E 6
writetopoi_create6 ;создать узел из 64 байт
        WRITETOPOI_CREATE_E 5
writetopoi_create5 ;создать узел из 32 байт
        WRITETOPOI_CREATE_E 4
writetopoi_create4 ;создать узел из 16 байт
        WRITETOPOI_CREATE_E 3
writetopoi_create3 ;создать узел из 8 байт
        WRITETOPOI_CREATE_E 2
writetopoi_create2 ;создать узел из 4 байт
        push de
        ex de,hl
        call newmem ;keep de
        ex de,hl
        ld (hl),e
        inc l
        ld (hl),d
        ex de,hl
        pop de
        ld a,e
        rra
        jr nc,$+3
         inc l
        rra
        jr nc,$+4
         inc l
         inc l
        ld a,(hl)
        ld (hl),c
        ld c,a
        ret

        macro WRITETOPOI_SPACE_D nbit,addr
        BITINC_D nbit
        push hl ;класть в стек адрес указателя, который мы удаляем (всю цепочку)
        HLFROMHL
        jp z,addr ;уже пусто
        endm
        
        macro WRITETOPOI_SPACE_E nbit,addr
        BITINC_E nbit
        push hl ;класть в стек адрес указателя, который мы удаляем (всю цепочку)
        HLFROMHL
        jp z,addr ;уже пусто
        endm
        
writetopoi_space
;hl=track root (4 bytes: left poi, right poi)
;de=index
;умеет удалять пустое поддерево
        WRITETOPOI_SPACE_D 7,writetopoi_space_nodel15
        WRITETOPOI_SPACE_D 6,writetopoi_space_nodel14
        WRITETOPOI_SPACE_D 5,writetopoi_space_nodel13
        WRITETOPOI_SPACE_D 4,writetopoi_space_nodel12
        WRITETOPOI_SPACE_D 3,writetopoi_space_nodel11
        WRITETOPOI_SPACE_D 2,writetopoi_space_nodel10
        WRITETOPOI_SPACE_D 1,writetopoi_space_nodel9
        WRITETOPOI_SPACE_D 0,writetopoi_space_nodel8
        WRITETOPOI_SPACE_E 7,writetopoi_space_nodel7
        WRITETOPOI_SPACE_E 6,writetopoi_space_nodel6
        WRITETOPOI_SPACE_E 5,writetopoi_space_nodel5
        WRITETOPOI_SPACE_E 4,writetopoi_space_nodel4
        WRITETOPOI_SPACE_E 3,writetopoi_space_nodel3
        WRITETOPOI_SPACE_E 2,writetopoi_space_nodel2

        push hl
        ld a,e
        rra
        jr nc,$+3
         inc l
        rra
        jr nc,$+4
         inc l
         inc l
        ld c,(hl)
        ld (hl),0
        pop hl
        ld a,(hl)
        inc l
        or (hl)
        inc l
        or (hl)
        inc l
        or (hl)
        jp nz,writetopoi_space_nodel2 ;непусто - не удаляем

;удалять пустое поддерево, пока в узле выше вторая ссылка NULL
        macro WRITETOPOI_SPACE_DEL nodeladdr
        pop hl ;адрес указателя на узел уровня N
        ld (hl),a
        inc l
        ld (hl),a
        ld a,l
        xor 2
        ld l,a ;его брат
        ld a,(hl)
        dec l
        or (hl)
        jp nz,nodeladdr
        endm
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel3 ;удалили узел из 4 байт
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel4 ;удалили узел из 8 байт
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel5 ;удалили узел из 16 байт
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel6 ;удалили узел из 32 байт
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel7 ;удалили узел из 64 байт
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel8 ;удалили узел из 128 байт
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel9 ;удалили узел из 256 байт
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel10 ;удалили узел из 512 байт
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel11 ;удалили узел из 1024 байт
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel12 ;удалили узел из 2048 байт
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel13 ;удалили узел из 4096 байт
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel14 ;удалили узел из 8192 байт
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel15 ;удалили узел из 16384 байт
        pop hl ;адрес указателя на узел уровня 15 в корне
        ld (hl),a
        inc l
        ld (hl),a ;удалили узел из 32768 байт
        ret

;снять со стека все уровни
writetopoi_space_nodel2
        pop hl
writetopoi_space_nodel3
        pop hl
writetopoi_space_nodel4
        pop hl
writetopoi_space_nodel5
        pop hl
writetopoi_space_nodel6
        pop hl
writetopoi_space_nodel7
        pop hl
writetopoi_space_nodel8
        pop hl
writetopoi_space_nodel9
        pop hl
writetopoi_space_nodel10
        pop hl
writetopoi_space_nodel11
        pop hl
writetopoi_space_nodel12
        pop hl
writetopoi_space_nodel13
        pop hl
writetopoi_space_nodel14
        pop hl
writetopoi_space_nodel15
        pop hl
        ret

;найти ближайший непустой байт на месте или слева (для ордера)
findleft
;hl=track root (4 bytes: left poi, right poi)
;de=index
;out: de=nonempty index (or 0), a=data
;если на месте непустой байт, то выходим
;иначе (мы на пустом поддереве):
;если мы на правом поддереве, то проверить левое, иначе подняться выше (если мы уже на корне, вернуть 0)
        BITINC_D 7
findleft_findleft15 ;мы в нужном месте узла из 65536 байт ;найти de
        push hl
        HLFROMHL
        jp z,findleft_noleft14 ;мы в пустом узле из 32768 байт, искать левее или выйти (а не выше)
        BITINC_D 6
findleft_findleft14 ;мы в нужном месте узла из 32768 байт ;найти de
        push hl
        HLFROMHL
        jp z,findleft_noleft13 ;мы в пустом узле из 16384 байт, искать левее или выше
        BITINC_D 5
findleft_findleft13 ;мы в нужном месте узла из 16384 байт ;найти de
        push hl
        HLFROMHL
        jp z,findleft_noleft12 ;мы в пустом узле из 8192 байт, искать левее или выше
        BITINC_D 4
findleft_findleft12 ;мы в нужном месте узла из 8192 байт ;найти de
        push hl
        HLFROMHL
        jp z,findleft_noleft11 ;мы в пустом узле из 4096 байт, искать левее или выше
        BITINC_D 3
findleft_findleft11 ;мы в нужном месте узла из 4096 байт ;найти de
        push hl
        HLFROMHL
        jp z,findleft_noleft10 ;мы в пустом узле из 2048 байт, искать левее или выше
        BITINC_D 2
findleft_findleft10 ;мы в нужном месте узла из 2048 байт ;найти de
        push hl
        HLFROMHL
        jp z,findleft_noleft9 ;мы в пустом узле из 1024 байт, искать левее или выше
        BITINC_D 1
findleft_findleft9 ;мы в нужном месте узла из 1024 байт ;найти de
        push hl
        HLFROMHL
        jp z,findleft_noleft8 ;мы в пустом узле из 512 байт, искать левее или выше
        BITINC_D 0
findleft_findleft8 ;мы в нужном месте узла из 512 байт ;найти de
        push hl
        HLFROMHL
        jp z,findleft_noleft7 ;мы в пустом узле из 256 байт, искать левее или выше
        BITINC_E 7
findleft_findleft7 ;мы в нужном месте узла из 256 байт ;найти de
        push hl
        HLFROMHL
        jp z,findleft_noleft6 ;мы в пустом узле из 128 байт, искать левее или выше
        BITINC_E 6
findleft_findleft6 ;мы в нужном месте узла из 128 байт ;найти de
        push hl
        HLFROMHL
        jp z,findleft_noleft5 ;мы в пустом узле из 128 байт, искать левее или выше
        BITINC_E 5
findleft_findleft5 ;мы в нужном месте узла из 64 байт ;найти de
        push hl
        HLFROMHL
        jp z,findleft_noleft4 ;мы в пустом узле из 128 байт, искать левее или выше
        BITINC_E 4
findleft_findleft4 ;мы в нужном месте узла из 32 байт ;найти de
        push hl
        HLFROMHL
        jr z,findleft_noleft3 ;мы в пустом узле из 16 байт, искать левее или выше
        BITINC_E 3
findleft_findleft3 ;мы в нужном месте узла из 16 байт ;найти de
        push hl
        HLFROMHL
        jr z,findleft_noleft2 ;мы в пустом узле из 8 байт, искать левее или выше
        BITINC_E 2
findleft_findleft2 ;мы в нужном месте узла из 8 байт ;найти de
        push hl
        HLFROMHL
        jr z,findleft_noleft1 ;мы в пустом узле из 4 байт, искать левее или выше
;мы в узле из 4 байт ;найти de
        ld a,e
        rra
        jr nc,$+3
         inc l
        rra
        jr nc,$+4
         inc l
         inc l
;мы в нужном месте узла из 4 байт
        ld a,(hl)
        or a
        jp nz,findleft_ret2 ;return de, a
        bit 0,e
        jr z,findleft_noleft0
;мы в правой половине узла из 2 байт
        dec e ;res 0,e
        dec l
        or (hl)
        jp nz,findleft_ret2 ;return de, a
findleft_noleft0 ;мы уже в левой половине узла из 2 байт ;подняться выше
        bit 1,e
        jr z,findleft_noleft1
;мы в правой половине узла из 4 байт
        dec e
        dec l
        or (hl)
        jp nz,findleft_ret2 ;return de, a
        dec e
        dec l
        or (hl)
        jp nz,findleft_ret2 ;return de, a

;на месте не найдено - поднимаемся и ищем левее и выше

        macro FINDLEFTDECE addr,nbit
;мы в правой половине узла из N байт
        dec e
        dec l
        ld a,(hl)
        dec l
        or (hl)
        jp nz,addr ;поиск de в узле из N байт (левой половине)
        endm
        macro FINDLEFTDECDE addr,nbit
;мы в правой половине узла из N байт
        dec de
        dec l
        ld a,(hl)
        dec l
        or (hl)
        jp nz,addr ;поиск de в узле из N байт (левой половине)
        endm

findleft_noleft1 ;мы уже в левой половине узла из 4 байт ;подняться выше
         ld a,e
         and 0xfc
         ld e,a
        pop hl ;узел из 8 байт ;адрес указателя на пустой узел из 4 байт ;искать левее или выше
        and 4 ;bit 2,e
        jr z,findleft_noleft2
        FINDLEFTDECE findleft_findleft2,2 ;мы в правой половине узла из 8 байт ;поиск de в левой половине, если она есть
findleft_noleft2 ;мы уже в левой половине узла из 8 байт ;подняться выше
         ld a,e
         and 0xf8
         ld e,a
        pop hl ;узел из 16 байт ;адрес указателя на пустой узел из 8 байт ;искать левее или выше
        and 8 ;bit 3,e
        jr z,findleft_noleft3
        FINDLEFTDECE findleft_findleft3,3 ;мы в правой половине узла из 16 байт ;поиск de в левой половине, если она есть
findleft_noleft3 ;мы уже в левой половине узла из 16 байт ;подняться выше
         ld a,e
         and 0xf0
         ld e,a
        pop hl ;узел из 32 байт ;адрес указателя на пустой узел из 16 байт ;искать левее или выше
        and 0x10 ;bit 4,e
        jr z,findleft_noleft4
        FINDLEFTDECE findleft_findleft4,4 ;мы в правой половине узла из 32 байт ;поиск de в левой половине, если она есть
findleft_noleft4 ;мы уже в левой половине узла из 32 байт ;подняться выше
         ld a,e
         and 0xe0
         ld e,a
        pop hl ;узел из 64 байт ;адрес указателя на пустой узел из 32 байт ;искать левее или выше
        and 0x20 ;bit 5,e
        jr z,findleft_noleft5
        FINDLEFTDECE findleft_findleft5,5 ;мы в правой половине узла из 64 байт ;поиск de в левой половине, если она есть
findleft_noleft5 ;мы уже в левой половине узла из 64 байт ;подняться выше
         ld a,e
         and 0xc0
         ld e,a
        pop hl ;узел из 128 байт ;адрес указателя на пустой узел из 64 байт ;искать левее или выше
        and 0x40 ;bit 6,e
        jr z,findleft_noleft6
        FINDLEFTDECE findleft_findleft6,6 ;мы в правой половине узла из 128 байт ;поиск de в левой половине, если она есть
findleft_noleft6 ;мы уже в левой половине узла из 128 байт ;подняться выше
         ld a,e
         and 0x80
         ld e,a
        pop hl ;узел из 256 байт ;адрес указателя на пустой узел из 128 байт ;искать левее или выше
        ;bit 7,e
        jr z,findleft_noleft7
        FINDLEFTDECE findleft_findleft7,7 ;мы в правой половине узла из 256 байт ;поиск de в левой половине, если она есть
findleft_noleft7 ;мы уже в левой половине узла из 256 байт ;подняться выше
         ld e,a;0
        pop hl ;узел из 512 байт ;адрес указателя на пустой узел из 256 байт ;искать левее или выше
        bit 0,d
        jr z,findleft_noleft8
        FINDLEFTDECDE findleft_findleft8,0 ;мы в правой половине узла из 512 байт ;поиск de в левой половине, если она есть
findleft_noleft8 ;мы уже в левой половине узла из 512 байт ;подняться выше
         ld e,a;0
         res 0,d
        pop hl ;узел из 1024 байт ;адрес указателя на пустой узел из 512 байт ;искать левее или выше
        bit 1,d
        jr z,findleft_noleft9
        FINDLEFTDECDE findleft_findleft9,1 ;мы в правой половине узла из 1024 байт ;поиск de в левой половине, если она есть
findleft_noleft9 ;мы уже в левой половине узла из 1024 байт ;подняться выше
         ld e,a;0
         ld a,d
         and 0xfc
         ld d,a
        pop hl ;узел из 2048 байт ;адрес указателя на пустой узел из 1024 байт ;искать левее или выше
        and 4 ;bit 2,d
        jr z,findleft_noleft10
        FINDLEFTDECDE findleft_findleft10,2 ;мы в правой половине узла из 2048 байт ;поиск de в левой половине, если она есть
findleft_noleft10 ;мы уже в левой половине узла из 2048 байт ;подняться выше
         ld e,a;0
         ld a,d
         and 0xf8
         ld d,a
        pop hl ;узел из 4096 байт ;адрес указателя на пустой узел из 2048 байт ;искать левее или выше
        and 8 ;bit 3,d
        jr z,findleft_noleft11
        FINDLEFTDECDE findleft_findleft11,3 ;мы в правой половине узла из 4096 байт ;поиск de в левой половине, если она есть
findleft_noleft11 ;мы уже в левой половине узла из 4096 байт ;подняться выше
         ld e,a;0
         ld a,d
         and 0xf0
         ld d,a
        pop hl ;узел из 8192 байт ;адрес указателя на пустой узел из 4096 байт ;искать левее или выше
        and 0x10 ;bit 4,d
        jr z,findleft_noleft12
        FINDLEFTDECDE findleft_findleft12,4 ;мы в правой половине узла из 8192 байт ;поиск de в левой половине, если она есть
findleft_noleft12 ;мы уже в левой половине узла из 8192 байт ;подняться выше
         ld e,a;0
         ld a,d
         and 0xe0
         ld d,a
        pop hl ;узел из 16384 байт ;адрес указателя на пустой узел из 8192 байт ;искать левее или выше
        and 0x20 ;bit 5,d
        jr z,findleft_noleft13
        FINDLEFTDECDE findleft_findleft13,5 ;мы в правой половине узла из 16384 байт ;поиск de в левой половине, если она есть
findleft_noleft13 ;мы уже в левой половине узла из 16384 байт ;подняться выше
         ld e,a;0
         ld a,d
         and 0xc0
         ld d,a
        pop hl ;узел из 32768 байт ;адрес указателя на пустой узел из 16384 байт ;искать левее или выше
        and 0x40 ;bit 6,d
        jr z,findleft_noleft14
        FINDLEFTDECDE findleft_findleft14,6 ;мы в правой половине узла из 32768 байт ;поиск de в левой половине, если она есть
findleft_noleft14 ;мы уже в левой половине узла из 32768 байт ;подняться выше
         ;ld e,a;0
         ;ld a,d
         ;and 0x80
         ;ld d,a
        pop hl ;узел из 65536 байт ;адрес указателя на пустой узел из 32768 байт ;искать левее или выйти (а не выше)
        bit 7,d
        jr z,findleft_0 ;ret z ;дальше некуда левее, de=0, a=0
;мы в правой половине узла из 65536 байт
        ld de,0x7fff;dec de
        dec l
        ld a,(hl)
        dec l
        or (hl)
        jp nz,findleft_findleft15 ;поиск de в узле из 65536 байт (левой половине)
findleft_0
        ld d,a
        ld e,a
        ret ;дальше некуда выше, de=0, a=0

findleft_ret2
        ;pop hl ;адрес указателя на узел из 4 байт
        ;pop hl ;адрес указателя на узел из 8 байт
        ;pop hl ;адрес указателя на узел из 16 байт
        ;pop hl ;адрес указателя на узел из 32 байт
        ;pop hl ;адрес указателя на узел из 64 байт
        ;pop hl ;адрес указателя на узел из 128 байт
        ;pop hl ;адрес указателя на узел из 256 байт
        ;pop hl ;адрес указателя на узел из 512 байт
        ;pop hl ;адрес указателя на узел из 1024 байт
        ;pop hl ;адрес указателя на узел из 2048 байт
        ;pop hl ;адрес указателя на узел из 4096 байт
        ;pop hl ;адрес указателя на узел из 8192 байт
        ;pop hl ;адрес указателя на узел из 16384 байт
        ;pop hl ;адрес указателя на узел из 32768 байт
        ld hl,14*2
        add hl,sp
        ld sp,hl
        ret

;найти ближайший непустой байт на месте или справа (для громкости и т.п.)
findright
;hl=track root (4 bytes: left poi, right poi)
;de=index
;out: de=nonempty index (or 0xffff), a=data
;если на месте непустой байт, то выходим
;иначе (мы на пустом поддереве):
;если мы на левом поддереве, то проверить правое, иначе подняться выше (если мы уже на корне, вернуть 0xffff)
        BITINC_D 7
findright_findright15 ;мы в нужном месте узла из 65536 байт ;найти de
        push hl
        HLFROMHL
        jp z,findright_noright14 ;мы в пустом узле из 32768 байт, искать правее или выйти (а не выше)
        BITINC_D 6
findright_findright14 ;мы в нужном месте узла из 32768 байт ;найти de
        push hl
        HLFROMHL
        jp z,findright_noright13 ;мы в пустом узле из 16384 байт, искать правее или выше
        BITINC_D 5
findright_findright13 ;мы в нужном месте узла из 16384 байт ;найти de
        push hl
        HLFROMHL
        jp z,findright_noright12 ;мы в пустом узле из 8192 байт, искать правее или выше
        BITINC_D 4
findright_findright12 ;мы в нужном месте узла из 8192 байт ;найти de
        push hl
        HLFROMHL
        jp z,findright_noright11 ;мы в пустом узле из 4096 байт, искать правее или выше
        BITINC_D 3
findright_findright11 ;мы в нужном месте узла из 4096 байт ;найти de
        push hl
        HLFROMHL
        jp z,findright_noright10 ;мы в пустом узле из 2048 байт, искать правее или выше
        BITINC_D 2
findright_findright10 ;мы в нужном месте узла из 2048 байт ;найти de
        push hl
        HLFROMHL
        jp z,findright_noright9 ;мы в пустом узле из 1024 байт, искать правее или выше
        BITINC_D 1
findright_findright9 ;мы в нужном месте узла из 1024 байт ;найти de
        push hl
        HLFROMHL
        jp z,findright_noright8 ;мы в пустом узле из 512 байт, искать правее или выше
        BITINC_D 0
findright_findright8 ;мы в нужном месте узла из 512 байт ;найти de
        push hl
        HLFROMHL
        jp z,findright_noright7 ;мы в пустом узле из 256 байт, искать правее или выше
        BITINC_E 7
findright_findright7 ;мы в нужном месте узла из 256 байт ;найти de
        push hl
        HLFROMHL
        jp z,findright_noright6 ;мы в пустом узле из 128 байт, искать правее или выше
        BITINC_E 6
findright_findright6 ;мы в нужном месте узла из 128 байт ;найти de
        push hl
        HLFROMHL
        jp z,findright_noright5 ;мы в пустом узле из 128 байт, искать правее или выше
        BITINC_E 5
findright_findright5 ;мы в нужном месте узла из 64 байт ;найти de
        push hl
        HLFROMHL
        jp z,findright_noright4 ;мы в пустом узле из 128 байт, искать правее или выше
        BITINC_E 4
findright_findright4 ;мы в нужном месте узла из 32 байт ;найти de
        push hl
        HLFROMHL
        jr z,findright_noright3 ;мы в пустом узле из 16 байт, искать правее или выше
        BITINC_E 3
findright_findright3 ;мы в нужном месте узла из 16 байт ;найти de
        push hl
        HLFROMHL
        jr z,findright_noright2 ;мы в пустом узле из 8 байт, искать правее или выше
        BITINC_E 2
findright_findright2 ;мы в нужном месте узла из 8 байт ;найти de
        push hl
        HLFROMHL
        jr z,findright_noright1 ;мы в пустом узле из 4 байт, искать правее или выше
;мы в узле из 4 байт ;найти de
        ld a,e
        rra
        jr nc,$+3
         inc l
        rra
        jr nc,$+4
         inc l
         inc l
;мы в нужном месте узла из 4 байт
        ld a,(hl)
        or a
        jp nz,findright_ret2 ;return de, a
        bit 0,e
        jr nz,findright_noright0
;мы в левой половине узла из 2 байт
        inc e ;set 0,e
        inc l
        or (hl)
        jp nz,findright_ret2 ;return de, a
findright_noright0 ;мы уже в правой половине узла из 2 байт ;подняться выше
        bit 1,e
        jr nz,findright_noright1
;мы в левой половине узла из 4 байт
        inc e
        inc l
        or (hl)
        jp nz,findright_ret2 ;return de, a
        inc e
        inc l
        or (hl)
        jp nz,findright_ret2 ;return de, a

;на месте не найдено - поднимаемся и ищем правее и выше

        macro FINDRIGHTINCE addr,nbit
;мы в левой половине узла из N байт
        inc e
        inc l
        inc l
        inc l
        ld a,(hl)
        dec l
        or (hl)
        jp nz,addr ;поиск de в узле из N байт (правой половине)
        endm
        macro FINDRIGHTINCDE addr,nbit
;мы в левой половине узла из N байт
        inc de
        inc l
        inc l
        inc l
        ld a,(hl)
        dec l
        or (hl)
        jp nz,addr ;поиск de в узле из N байт (правой половине)
        endm

findright_noright1 ;мы уже в правой половине узла из 4 байт ;подняться выше
         ld a,e
         or 0x03
         ld e,a
        pop hl ;узел из 8 байт ;адрес указателя на пустой узел из 4 байт ;искать правее или выше
        and 4 ;bit 2,e
        jr nz,findright_noright2
        FINDRIGHTINCE findright_findright2,2 ;мы в левой половине узла из 8 байт ;поиск de в правой половине, если она есть
findright_noright2 ;мы уже в правой половине узла из 8 байт ;подняться выше
         ld a,e
         or 0x07
         ld e,a
        pop hl ;узел из 16 байт ;адрес указателя на пустой узел из 8 байт ;искать правее или выше
        and 8 ;bit 3,e
        jr nz,findright_noright3
        FINDRIGHTINCE findright_findright3,3 ;мы в левой половине узла из 16 байт ;поиск de в правой половине, если она есть
findright_noright3 ;мы уже в правой половине узла из 16 байт ;подняться выше
         ld a,e
         or 0x0f
         ld e,a
        pop hl ;узел из 32 байт ;адрес указателя на пустой узел из 16 байт ;искать правее или выше
        and 0x10 ;bit 4,e
        jr nz,findright_noright4
        FINDRIGHTINCE findright_findright4,4 ;мы в левой половине узла из 32 байт ;поиск de в правой половине, если она есть
findright_noright4 ;мы уже в правой половине узла из 32 байт ;подняться выше
         ld a,e
         or 0x1f
         ld e,a
        pop hl ;узел из 64 байт ;адрес указателя на пустой узел из 32 байт ;искать правее или выше
        and 0x20 ;bit 5,e
        jr nz,findright_noright5
        FINDRIGHTINCE findright_findright5,5 ;мы в левой половине узла из 64 байт ;поиск de в правой половине, если она есть
findright_noright5 ;мы уже в правой половине узла из 64 байт ;подняться выше
         ld a,e
         or 0x3f
         ld e,a
        pop hl ;узел из 128 байт ;адрес указателя на пустой узел из 64 байт ;искать правее или выше
        and 0x40 ;bit 6,e
        jr nz,findright_noright6
        FINDRIGHTINCE findright_findright6,6 ;мы в левой половине узла из 128 байт ;поиск de в правой половине, если она есть
findright_noright6 ;мы уже в правой половине узла из 128 байт ;подняться выше
         ld a,e
         or 0x7f
         ld e,a
        pop hl ;узел из 256 байт ;адрес указателя на пустой узел из 128 байт ;искать правее или выше
        ;bit 7,e
        jp m,findright_noright7
        FINDRIGHTINCE findright_findright7,7 ;мы в левой половине узла из 256 байт ;поиск de в правой половине, если она есть
findright_noright7 ;мы уже в правой половине узла из 256 байт ;подняться выше
         ld e,0xff
        pop hl ;узел из 512 байт ;адрес указателя на пустой узел из 256 байт ;искать правее или выше
        bit 0,d
        jr nz,findright_noright8
        FINDRIGHTINCDE findright_findright8,0 ;мы в левой половине узла из 512 байт ;поиск de в правой половине, если она есть
findright_noright8 ;мы уже в правой половине узла из 512 байт ;подняться выше
         ld e,0xff
         set 0,d
        pop hl ;узел из 1024 байт ;адрес указателя на пустой узел из 512 байт ;искать правее или выше
        bit 1,d
        jr nz,findright_noright9
        FINDRIGHTINCDE findright_findright9,1 ;мы в левой половине узла из 1024 байт ;поиск de в правой половине, если она есть
findright_noright9 ;мы уже в правой половине узла из 1024 байт ;подняться выше
         ld e,0xff
         ld a,d
         or 0x03
         ld d,a
        pop hl ;узел из 2048 байт ;адрес указателя на пустой узел из 1024 байт ;искать правее или выше
        and 4 ;bit 2,d
        jr nz,findright_noright10
        FINDRIGHTINCDE findright_findright10,2 ;мы в левой половине узла из 2048 байт ;поиск de в правой половине, если она есть
findright_noright10 ;мы уже в правой половине узла из 2048 байт ;подняться выше
         ld e,0xff
         ld a,d
         or 0x07
         ld d,a
        pop hl ;узел из 4096 байт ;адрес указателя на пустой узел из 2048 байт ;искать правее или выше
        and 8 ;bit 3,d
        jr nz,findright_noright11
        FINDRIGHTINCDE findright_findright11,3 ;мы в левой половине узла из 4096 байт ;поиск de в правой половине, если она есть
findright_noright11 ;мы уже в правой половине узла из 4096 байт ;подняться выше
         ld e,0xff
         ld a,d
         or 0x0f
         ld d,a
        pop hl ;узел из 8192 байт ;адрес указателя на пустой узел из 4096 байт ;искать правее или выше
        and 0x10 ;bit 4,d
        jr nz,findright_noright12
        FINDRIGHTINCDE findright_findright12,4 ;мы в левой половине узла из 8192 байт ;поиск de в правой половине, если она есть
findright_noright12 ;мы уже в правой половине узла из 8192 байт ;подняться выше
         ld e,0xff
         ld a,d
         or 0x1f
         ld d,a
        pop hl ;узел из 16384 байт ;адрес указателя на пустой узел из 8192 байт ;искать правее или выше
        and 0x20 ;bit 5,d
        jr nz,findright_noright13
        FINDRIGHTINCDE findright_findright13,5 ;мы в левой половине узла из 16384 байт ;поиск de в правой половине, если она есть
findright_noright13 ;мы уже в правой половине узла из 16384 байт ;подняться выше
         ld e,0xff
         ld a,d
         or 0x3f
         ld d,a
        pop hl ;узел из 32768 байт ;адрес указателя на пустой узел из 16384 байт ;искать правее или выше
        and 0x40 ;bit 6,d
        jr nz,findright_noright14
        FINDRIGHTINCDE findright_findright14,6 ;мы в левой половине узла из 32768 байт ;поиск de в правой половине, если она есть
findright_noright14 ;мы уже в правой половине узла из 32768 байт ;подняться выше
         ;ld e,0xff
         ;ld a,d
         ;or 0x7f
         ;ld d,a
        pop hl ;узел из 65536 байт ;адрес указателя на пустой узел из 32768 байт ;искать правее или выйти (а не выше)
        bit 7,d
        jr nz,findright_0 ;ret z ;дальше некуда правее, de=0xffff, a=0
;мы в правой половине узла из 65536 байт
        ld de,0x8000;inc de
        inc l
        inc l
        inc l
        ld a,(hl)
        dec l
        or (hl)
        jp nz,findright_findright15 ;поиск de в узле из 65536 байт (правой половине)
findright_0
        ld de,0xffff
        ret ;дальше некуда выше, de=0xffff, a=0

findright_ret2
        ;pop hl ;адрес указателя на узел из 4 байт
        ;pop hl ;адрес указателя на узел из 8 байт
        ;pop hl ;адрес указателя на узел из 16 байт
        ;pop hl ;адрес указателя на узел из 32 байт
        ;pop hl ;адрес указателя на узел из 64 байт
        ;pop hl ;адрес указателя на узел из 128 байт
        ;pop hl ;адрес указателя на узел из 256 байт
        ;pop hl ;адрес указателя на узел из 512 байт
        ;pop hl ;адрес указателя на узел из 1024 байт
        ;pop hl ;адрес указателя на узел из 2048 байт
        ;pop hl ;адрес указателя на узел из 4096 байт
        ;pop hl ;адрес указателя на узел из 8192 байт
        ;pop hl ;адрес указателя на узел из 16384 байт
        ;pop hl ;адрес указателя на узел из 32768 байт
        ld hl,14*2
        add hl,sp
        ld sp,hl
        ret

newmem
;взять первый элемент списка свободных
;вернуть его в hl
;сдвинуть указатель на первый элемент списка свободных (если NIL, то повиснуть)
;out: hl=адрес 4 байт свободных
firstfree=$+1
        ld hl,freemem_start
        push hl
        inc l
        inc l
       if BIGENDIAN
        ld a,(hl)
        inc l
        ld l,(hl)
        ld h,a ;новый указатель на первый элемент списка свободных
         or l
         jr z,$ ;если NIL, то повиснуть (TODO заказать новый 256-байтный блок)
       else
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a ;новый указатель на первый элемент списка свободных
         or h
         jr z,$ ;если NIL, то повиснуть (TODO заказать новый 256-байтный блок)
       endif
        ld (firstfree),hl
;в value этого элемента записать NIL (чтобы был двусвязный список свободных - в будущем можно будет освобождать 256-байтные блоки)
         xor a
         ld (hl),a
         inc l
         ld (hl),a ;NIL
       if BIGENDIAN
        ld hl,FreeMem_value
        ld a,(hl)
        inc l
        ld l,(hl)
        ld h,a
       else
        ld hl,(FreeMem_value)
       endif
        dec hl
        dec hl
        dec hl
        dec hl
       if BIGENDIAN
        ld a,h
        ld h,l
        ld l,a
        ld (FreeMem_value),hl
       else
        ld (FreeMem_value),hl
       endif
        pop hl
        xor a
        ld (hl),a
        inc l
        ld (hl),a
        inc l
        ld (hl),a
        inc l
        ld (hl),a
        dec l
        dec l
        dec l
        ret

delmem
;de=адрес 4 байт, которые освободить
;добавить в список свободных (value бывшего первого элемента пусть указывает на него, а у него на NIL, чтобы был двусвязный список свободных - в будущем можно будет освобождать 256-байтные блоки)
        ld hl,(firstfree) ;TODO проверить, что это последний занятый в 256-байтном блоке и освободить блок
       if BIGENDIAN
         ld (hl),d
         inc l
         ld (hl),e ;value бывшего первого элемента
       else
         ld (hl),e
         inc l
         ld (hl),d ;value бывшего первого элемента
        endif
         dec l
        ex de,hl
        ld (firstfree),hl
         xor a
         ld (hl),a
        inc l
         ld (hl),a ;NIL
        inc l
       if BIGENDIAN
        ld (hl),d
        inc l
        ld (hl),e ;next = бывший первый элемент
       else
        ld (hl),e
        inc l
        ld (hl),d ;next = бывший первый элемент
       endif
       if BIGENDIAN
        ld hl,FreeMem_value
        ld a,(hl)
        inc l
        ld l,(hl)
        ld h,a
       else
        ld hl,(FreeMem_value)
       endif
        ld de,4
        add hl,de
       if BIGENDIAN
        ld a,h
        ld h,l
        ld l,a
        ld (FreeMem_value),hl
       else
        ld (FreeMem_value),hl
       endif
        ret

initmem
;инит одного блока 32K
;4-байтные блоки prev.next, у первого prev=0, у последнего next=0
        ld hl,freemem_start
        ld b,h
        ld c,l
        ld de,0
initmem0
;de=prev
        inc bc
        inc bc
        inc bc
        inc bc
;bc=next
        push hl
        ld (hl),e
        inc l
        ld (hl),d ;prev
        inc l
        ld (hl),c
        inc l
        ld (hl),b ;next
        inc hl
        pop de ;de=prev
        ld a,h
        or a
        jr nz,initmem0
        ld (0xfffe),hl ;у последнего next=0

        call newmem
        xor a
        ld (hl),a
        inc l
        ld (hl),a
        inc l
        ld (hl),a
        inc l
        ld (hl),a ;root
        ret

FreeMem_value
        dw 32768
