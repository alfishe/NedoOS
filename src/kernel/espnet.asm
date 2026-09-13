; Kernel ESPNET: BDOS wiznet_* like w5300.asm. INETDRV==2.
; DEFINE ESPNET_KERNEL: no ini, no YIELD, spin timeouts in _sdk/espnet.asm.
;
; UART cfg 20 bytes (espcfg SET L=9 / GET L=10, like DNS):
;  +0 db comType, +1 db divider, +2 dw RBR,IER,IIR,LCR,MCR,LSR,MSR,SR
;  +18 dw pktMax (64..2048, 0=default 192). GETINFO L=11, 53-byte ESP INFO.
; 16550 is programmed by espcfg.com, not here.

        DEFINE ESPNET_KERNEL
        include "../_sdk/espnet.asm"

ESPNET_CFG_SIZE         EQU 20
ERR_NFILE               EQU 23
ERR_NOTSOCK             EQU 38
ERR_AFNOSUPPORT         EQU 47
ERR_PROTOTYPE           EQU 41
AF_INET                 EQU 2
SOCK_STREAM             EQU 0x01
SOCK_ICMP               EQU 0x02
SOCK_DGRAM              EQU 0x03

espk_dns
        defb 8,8,4,4
espk_owner
        defs 8

espk_ensure
        ld a,(esp_inited)
        or a
        ret nz
        push bc
        push de
        push hl
        call esp_init
        pop hl
        pop de
        pop bc
        ret

; A=sock  out: Z ok A=sock; NZ A=errno
espk_check
        cp 8
        jr nc,espk_check_bad
        push bc
        push hl
        ld c,a
        ld b,0
        ld hl,espk_owner
        add hl,bc
        ld a,(hl)
        or a
        jr z,espk_check_free
        cp (iy+app.id)
        ld a,c
        pop hl
        pop bc
        ret
espk_check_free
        pop hl
        pop bc
espk_check_bad
        ld a,ERR_NOTSOCK
        or a
        ret

; A=sock: store current pid
espk_own
        push bc
        push hl
        ld c,a
        ld b,0
        ld hl,espk_owner
        add hl,bc
        ld a,(iy+app.id)
        ld (hl),a
        ld a,c
        pop hl
        pop bc
        ret

; A=sock: clear owner
espk_free
        push bc
        push hl
        ld c,a
        ld b,0
        ld hl,espk_owner
        add hl,bc
        ld (hl),b
        ld a,c
        pop hl
        pop bc
        ret

espk_err
        ld hl,-1
        ret

espk_mapde
        call BDOS_preparedepage
        jp BDOS_setdepage

w53_drop_socs
        push bc
        push de
        push hl
        ld b,8
        ld hl,espk_owner
w53_drop_lp
        ld a,(hl)
        cp (iy+app.id)
        jr nz,w53_drop_nx
        ld a,(esp_inited)
        or a
        jr z,w53_drop_clr
        ld a,8
        sub b
        push bc
        push hl
        ld e,0
        call esp_shutdown
        pop hl
        pop bc
w53_drop_clr
        ld (hl),0
w53_drop_nx
        inc hl
        djnz w53_drop_lp
        pop hl
        pop de
        pop bc
        ret

wiznet_open
        call espk_ensure
        dec l
        jr z,espk_socket
        dec l
        jp z,espk_shutdown
        dec l
        jp z,espk_connect
        dec l
        jp z,espk_accept
        dec l
        jp z,espk_bind
        dec l
        jp z,espk_listen
        dec l
        jp z,espk_setdns
        dec l
        jp z,espk_getdns
        dec l
        jp z,espk_setuart
        dec l
        jp z,espk_getuart
        dec l
        jp z,espk_getinfo
        ld a,ESPNET_ERR_INTR
        ld hl,-1
        ret

espk_socket
        ld a,d
        cp AF_INET
        ld a,ERR_AFNOSUPPORT
        jp nz,espk_err
        ld a,e
        cp SOCK_ICMP
        ld a,ERR_PROTOTYPE
        jp z,espk_err
        call esp_socket
        bit 7,l
        ret nz
        ld a,l
        call espk_own
        ; UDP: firmware SOCKET already udp.begin(0). A follow-up BIND
        ; was stop+begin(0) and raced lwIP (rapid time2 -i -> NOTSOCK 38).
        xor a
        ret

espk_shutdown
        ex af,af'
        call espk_check
        jp nz,espk_err
        push af
        call esp_shutdown
        pop bc
        push hl
        push af
        ld a,b
        call espk_free
        pop af
        pop hl
        ret

espk_connect
        ex af,af'
        call espk_check
        jp nz,espk_err
        push af
        call espk_mapde
        pop af
        jp espk_connect_sa

espk_bind
        ex af,af'
        call espk_check
        jp nz,espk_err
        push af
        call espk_mapde
        pop af
        jp esp_bind

espk_listen
        ex af,af'
        call espk_check
        jp nz,espk_err
        jp esp_listen

espk_accept
        ex af,af'
        call espk_check
        jp nz,espk_err
        call esp_accept
        bit 7,l
        ret nz
        ld a,l
        call espk_own
        xor a
        ret

espk_setdns
        call espk_mapde
        ld hl,espk_dns
        ex de,hl
        ldi
        ldi
        ldi
        ldi
        xor a
        ld l,a
        ld h,a
        ret

espk_getdns
        call espk_mapde
        ld hl,espk_dns
        ldi
        ldi
        ldi
        ldi
        xor a
        ld l,a
        ld h,a
        ret

; DE -> 20-byte cfg (18 UART + pktMax), then program 16550
espk_setuart
        call espk_mapde
        ld a,(de)
        ld (esp_comType),a
        inc de
        ld a,(de)
        ld (esp_div),a
        inc de
        ld hl,esp_RBR
        ld bc,16
        ex de,hl
        ldir
        call espk_pktmax_fromhl
        call esp_ports_ready
        ld a,(esp_div)
        call esp_uart_init
        xor a
        call esp_setrts
        ld hl,65000
        ld (esp_factor),hl
        ld (esp_spin),hl
        xor a
        ld (esp_busy),a
        inc a
        ld (esp_inited),a
        ; Drop ESP sockets left after a ZX reboot (firmware 1.23: sock=FF).
        ld a,ESPNET_SOCK_NONE
        ld e,0
        call esp_shutdown
        xor a
        ld l,a
        ld h,a
        ret

espk_getuart
        call espk_mapde
        ld a,(esp_comType)
        ld (de),a
        inc de
        ld a,(esp_div)
        ld (de),a
        inc de
        ld hl,esp_RBR
        ld bc,16
        ldir
        call espk_pktmax_tode
        xor a
        ld l,a
        ld h,a
        ret

wiznet_close
        call espk_ensure
        jp espk_shutdown

wiznet_read
        call espk_ensure
        ex af,af'
        call espk_check
        jp nz,espk_err
        push hl
        ld c,a
        ld b,0
        ld hl,esp_proto
        add hl,bc
        ld a,(hl)
        cp SOCK_DGRAM
        ld a,c
        pop hl
        jp nz,esp_read
        ld (espk_sa_user),de
        ld (espk_buf_user),ix
        push af
        push hl
        push ix
        pop de
        call BDOS_preparedepage
        call BDOS_setdepage
        pop hl
        ld bc,espk_sa
        pop af
        call esp_read_udp
        ret nz
        jp espk_sa_load

wiznet_write
        call espk_ensure
        ex af,af'
        call espk_check
        jp nz,espk_err
        push hl
        ld c,a
        ld b,0
        ld hl,esp_proto
        add hl,bc
        ld a,(hl)
        cp SOCK_DGRAM
        ld a,c
        pop hl
        jp nz,esp_write
        push af
        push hl
        push ix
        call espk_sa_save
        pop de
        call BDOS_preparedepage
        call BDOS_setdepage
        pop hl
        pop af
        ld bc,espk_sa
        jp esp_write_udp

        display "espnet kernel end=",$
