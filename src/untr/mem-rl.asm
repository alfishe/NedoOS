BIGENDIAN=0 ;0=LSB,HSB

pokeaddr_c_tracka
        ld hl,(curtime)
        call tracktime_toaddr
;hl=addr
pokeaddr
        ;ld a,(hl)
        ;ld (hl),c
        ;ld c,a
        ;ret
        ex de,hl
        ld hl,0x8000 ;root
        call writetopoi
        ex de,hl
        ret

getaddr_tracka
        ld hl,(curtime)
        call tracktime_toaddr
        ret

peekaddr_tracka
        ld hl,(curtime)
;getaddr_tracka_timehl
        call tracktime_toaddr
;hl=addr
peekaddr
        ;ld a,(hl)
        ;ret
        ex de,hl
        ld hl,0x8000 ;root
        call readfrompoi
        ex de,hl
        ret

tracktime_toaddr
        ld d,h
        ld e,l
        add hl,hl
        add hl,de
        add hl,hl ;*6
        add hl,de ;*7
        add hl,hl ;*14
        ld de,tracks
        add hl,de
        ld e,a
        ld d,0
        add hl,de
        ret

getendaddr
        ld hl,tracks+(MAXTIME-1)*NTRACKS
        ld a,(curtrack)
        ld e,a
        ld d,0
        add hl,de
;hl=addr ;последний байт трека
        ret

;пусть номер трека и смещение в треке - это функция от номера канала и времени (зависит от ордера, если канал привязан к ордеру). всего 64 канала * 64 позиции = 4096 треков (одна страница адресов)
;адрес в треке - функция номера трека и смещения в треке
;для этого каждый трек (длиной 64K) храним как бинарное дерево: адрес левой части, адрес правой части
;и так до минимального элемента (4 байта, которые смотрим непосредственно)
;адрес делится на 4, поэтому 2 байтами можно адресовать 256K (16 страниц)
;но так будет медленно, поэтому выделим 32K для каждого (канал & 7)

        macro READFROMPOI_D
        rlc d
        jr nc,$+4
         inc l
         inc l
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        or h
        endm

        macro READFROMPOI_E
        rlc e
        jr nc,$+4
         inc l
         inc l
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        or h
        endm

readfrompoi_ret13
        rrc d
readfrompoi_ret14
        rrc d
readfrompoi_ret15
        rrc d
        ret

readfrompoi_ret12
        rlc d
readfrompoi_ret11
        rlc d
readfrompoi_ret10
        rlc d
readfrompoi_ret9
        rlc d
readfrompoi_ret8
        ret

readfrompoi
;hl=track pointer (4 bytes: left poi, right poi)
;de=timeshift
        READFROMPOI_D
        jr z,readfrompoi_ret15 ;пусто, возвращает 0=NOTE_SPACE
        READFROMPOI_D
        jr z,readfrompoi_ret14 ;пусто, возвращает 0=NOTE_SPACE
        READFROMPOI_D
        jr z,readfrompoi_ret13 ;пусто, возвращает 0=NOTE_SPACE
        READFROMPOI_D
        jr z,readfrompoi_ret12 ;пусто, возвращает 0=NOTE_SPACE
        READFROMPOI_D
        jr z,readfrompoi_ret11 ;пусто, возвращает 0=NOTE_SPACE
        READFROMPOI_D
        jr z,readfrompoi_ret10 ;пусто, возвращает 0=NOTE_SPACE
        READFROMPOI_D
        jr z,readfrompoi_ret9 ;пусто, возвращает 0=NOTE_SPACE
        READFROMPOI_D
        ret z ;jp z,readfrompoi_ret8 ;пусто, возвращает 0=NOTE_SPACE
        READFROMPOI_E
        jr z,readfrompoi_ret7 ;пусто, возвращает 0=NOTE_SPACE
        READFROMPOI_E
        jr z,readfrompoi_ret6 ;пусто, возвращает 0=NOTE_SPACE
        READFROMPOI_E
        jr z,readfrompoi_ret5 ;пусто, возвращает 0=NOTE_SPACE
        READFROMPOI_E
        jr z,readfrompoi_ret4 ;пусто, возвращает 0=NOTE_SPACE
        READFROMPOI_E
        jr z,readfrompoi_ret3 ;пусто, возвращает 0=NOTE_SPACE
        READFROMPOI_E
        jr z,readfrompoi_ret2 ;пусто, возвращает 0=NOTE_SPACE
        rlc e
        jr nc,$+4
         inc l
         inc l
        rlc e
        jr nc,$+3
         inc l
        ld a,(hl)
        ret

readfrompoi_ret5
        rrc e
readfrompoi_ret6
        rrc e
readfrompoi_ret7
        rrc e
        ret

readfrompoi_ret4
        rlc e
readfrompoi_ret3
        rlc e
readfrompoi_ret2
        rlc e
        rlc e
        ret

        macro WRITETOPOI_D addr
        rlc d
        jr nc,$+4
         inc l
         inc l
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

        macro WRITETOPOI_E addr
        rlc e
        jr nc,$+4
         inc l
         inc l
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

writetopoi
;hl=track pointer (4 bytes: left poi, right poi)
;de=timeshift
;c=byte
        ld a,c
        or a
        jp z,writetopoi_space
        WRITETOPOI_D writetopoi_create14
        WRITETOPOI_D writetopoi_create13
        WRITETOPOI_D writetopoi_create12
        WRITETOPOI_D writetopoi_create11
        WRITETOPOI_D writetopoi_create10
        WRITETOPOI_D writetopoi_create9
        WRITETOPOI_D writetopoi_create8
        WRITETOPOI_D writetopoi_create7
        WRITETOPOI_E writetopoi_create6
        WRITETOPOI_E writetopoi_create5
        WRITETOPOI_E writetopoi_create4
        WRITETOPOI_E writetopoi_create3
        WRITETOPOI_E writetopoi_create2
        WRITETOPOI_E writetopoi_create1
        rlc e
        jr nc,$+4
         inc l
         inc l
        rlc e
        jr nc,$+3
         inc l
        ld a,(hl)
        ld (hl),c
        ld c,a
        ret

        macro WRITETOPOI_CREATE_D
        push de
        push hl
        call newmem
        ex de,hl
        pop hl
        ld (hl),e
        inc l
        ld (hl),d
        ex de,hl
        pop de
        rlc d
        jr nc,$+4
         inc l
         inc l
        endm

        macro WRITETOPOI_CREATE_E
        push de
        push hl
        call newmem
        ex de,hl
        pop hl
        ld (hl),e
        inc l
        ld (hl),d
        ex de,hl
        pop de
        rlc e
        jr nc,$+4
         inc l
         inc l
        endm

writetopoi_create14
        WRITETOPOI_CREATE_D
writetopoi_create13
        WRITETOPOI_CREATE_D
writetopoi_create12
        WRITETOPOI_CREATE_D
writetopoi_create11
        WRITETOPOI_CREATE_D
writetopoi_create10
        WRITETOPOI_CREATE_D
writetopoi_create9
        WRITETOPOI_CREATE_D
writetopoi_create8
        WRITETOPOI_CREATE_D
writetopoi_create7
        WRITETOPOI_CREATE_E
writetopoi_create6
        WRITETOPOI_CREATE_E
writetopoi_create5
        WRITETOPOI_CREATE_E
writetopoi_create4
        WRITETOPOI_CREATE_E
writetopoi_create3
        WRITETOPOI_CREATE_E
writetopoi_create2
        WRITETOPOI_CREATE_E
writetopoi_create1
        WRITETOPOI_CREATE_E
        rlc e
        jr nc,$+3
         inc l
        ld a,(hl)
        ld (hl),c
        ld c,a
        ret

        macro WRITETOPOI_SPACE_D addr
        rlc d
        jr nc,$+4
         inc l
         inc l
        push hl ;класть в стек адрес указателя, который мы удаляем (всю цепочку)
        ld a,(hl)
        inc l
        or (hl)
        jp z,addr ;уже пусто
        ld a,(hl)
        dec l
        ld l,(hl)
        ld h,a
        endm
        
        macro WRITETOPOI_SPACE_E addr
        rlc e
        jr nc,$+4
         inc l
         inc l
        push hl ;класть в стек адрес указателя, который мы удаляем (всю цепочку)
        ld a,(hl)
        inc l
        or (hl)
        jp z,addr ;уже пусто
        ld a,(hl)
        dec l
        ld l,(hl)
        ld h,a
        endm
        
writetopoi_space
;hl=track pointer (4 bytes: left poi, right poi)
;de=timeshift
;умеет удалять пустое поддерево
        WRITETOPOI_SPACE_D writetopoi_space_rrnodel15
        WRITETOPOI_SPACE_D writetopoi_space_rrnodel14
        WRITETOPOI_SPACE_D writetopoi_space_rrnodel13
        WRITETOPOI_SPACE_D writetopoi_space_rrnodel12
        WRITETOPOI_SPACE_D writetopoi_space_rrnodel11
        WRITETOPOI_SPACE_D writetopoi_space_rrnodel10
        WRITETOPOI_SPACE_D writetopoi_space_rrnodel9
        WRITETOPOI_SPACE_D writetopoi_space_rrnodel8
        WRITETOPOI_SPACE_E writetopoi_space_rrnodel7
        WRITETOPOI_SPACE_E writetopoi_space_rrnodel6
        WRITETOPOI_SPACE_E writetopoi_space_rrnodel5
        WRITETOPOI_SPACE_E writetopoi_space_rrnodel4
        WRITETOPOI_SPACE_E writetopoi_space_rrnodel3
        WRITETOPOI_SPACE_E writetopoi_space_rrnodel2
        push hl
        rlc e
        jr nc,$+4
         inc l
         inc l
        rlc e
        jr nc,$+3
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
        pop hl ;адрес указателя на узел уровня N (уровень 2 = просто символы)
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
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel3
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel4
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel5
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel6
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel7
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel8
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel9
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel10
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel11
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel12
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel13
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel14
        WRITETOPOI_SPACE_DEL writetopoi_space_nodel15
        pop hl ;адрес указателя на узел уровня 15
        ld (hl),a
        inc l
        ld (hl),a
        ret

;снять со стека все уровни
writetopoi_space_rrnodel2
        rrc e
        pop hl
writetopoi_space_rrnodel3
        rrc e
        pop hl
writetopoi_space_rrnodel4
        rrc e
        pop hl
writetopoi_space_rrnodel5
        rrc e
        pop hl
writetopoi_space_rrnodel6
        rrc e
        pop hl
writetopoi_space_rrnodel7
        rrc e
        pop hl
        dup 8
        pop hl
        edup
        ret

writetopoi_space_rrnodel8
        rrc d
        pop hl
writetopoi_space_rrnodel9
        rrc d
        pop hl
writetopoi_space_rrnodel10
        rrc d
        pop hl
writetopoi_space_rrnodel11
        rrc d
        pop hl
writetopoi_space_rrnodel12
        rrc d
        pop hl
writetopoi_space_rrnodel13
        rrc d
        pop hl
writetopoi_space_rrnodel14
        rrc d
        pop hl
writetopoi_space_rrnodel15
        rrc d
        pop hl
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
