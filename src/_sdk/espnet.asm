; ESPNET host driver (sjasmplus). Binary UART protocol only, no AT.
; Include once after ORG. Requires sys_h.asm.
;
; DEFINE ESPNET before sys_h.asm to map OS_NETSOCKET / OS_ACCEPT /
; OS_WIZNETREAD / OS_WIZNETWRITE / ... onto these calls (WIZNET regs).
; Call esp_init (or OS_ESPINIT) once at start.
;
; WIZNET register contract (not IAR OS_ESP* packing):
;   SOCKET/ACCEPT success: L=id 0..n-1, A=0
;   SOCKET/ACCEPT/BIND/LISTEN/CONNECT/SHUTDOWN error: L=-1, A=errno
;   READ/WRITE success: HL=count, A=0
;   READ/WRITE error: HL=-1, A=errno (EAGAIN=35 is an error)
;
; comType 0 Kondratyev no AFC, 1 ATM2 COM, 2 Kondratyev AFC, 3 ATM2IOESP.
; Type 3 uses 16550 indices 0..7 (from ini high byte-0xF8, or low byte if <0xF8).

ESPNET_SOF              EQU 0xA5
ESPNET_SOCK_NONE        EQU 0xFF
        ifdef ESPNET_KERNEL
; Firmware UART payload cap. Per-BDOS clip is ram esp_host_max (espcfg pktMax).
ESPNET_HOST_MAX         EQU 2048
ESPNET_HOST_MAX_DEF     EQU 192
ESPNET_RSP_MAX          EQU 64
        else
ESPNET_HOST_MAX         EQU 2048
ESPNET_RSP_MAX          EQU 256
        endif
ESPNET_REQ_HDR          EQU 6
ESPNET_RSP_HDR          EQU 8
ESPNET_SOCKADDR_SIZE    EQU 15
; Host never sets cmd bit7 (ESPNET_F_CRC). Firmware may CRC for other
; hosts; we compare cmd as-is and do not compute or skip a CRC byte.
ESPNET_CMD_SOCKET       EQU 0x01
ESPNET_CMD_SHUTDOWN     EQU 0x02
ESPNET_CMD_CONNECT      EQU 0x03
ESPNET_CMD_ACCEPT       EQU 0x04
ESPNET_CMD_BIND         EQU 0x05
ESPNET_CMD_LISTEN       EQU 0x06
ESPNET_CMD_READ         EQU 0x07
ESPNET_CMD_WRITE        EQU 0x08
ESPNET_CMD_GETDNS       EQU 0x09
ESPNET_CMD_DNSRESOLVE   EQU 0x0A
ESPNET_CMD_INFO         EQU 0x10
ESPNET_CMD_WIFI_SCAN    EQU 0x11
ESPNET_CMD_WIFI_CONNECT EQU 0x12
ESPNET_CMD_WIFI_DISC    EQU 0x13
ESPNET_CMD_WIFI_STATUS  EQU 0x14
ESPNET_CMD_UART         EQU 0x15
ESPNET_CMD_ECHO         EQU 0x7E
ESPNET_ERR_INTR         EQU 4
ESPNET_ERR_EAGAIN       EQU 35
ESPNET_ERR_EMSGSIZE     EQU 40
ESPNET_ERR_NOTCONN      EQU 57
ESPNET_ERR_HOSTUNREACH  EQU 65
; Timeouts (kernel: no YIELD, spin). Tune here:
; SOF_TICKS      - wait for 0xA5: each wrap of idle (256 polls) decrements deadline
; SOF_TICKS_LONG - CONNECT / INFO / TCP WRITE (sndbuf wait)
; SOF_TICKS_UDP  - UDP READ/WRITE: firmware replies at once (EAGAIN or sendto).
;                  500 (~10s) made a missed ATM2 frame look like a DNS hang.
; esp_spin/factor 65000 - per-byte wait in fill (and CTS inner loop)
; CTS kernel cap 20001 - esp_wait_cts
ESPNET_SOF_TICKS        EQU 500
ESPNET_SOF_TICKS_LONG   EQU 3000
ESPNET_SOF_TICKS_UDP    EQU 75
ESPNET_INFO_SIZE        EQU 53
ESPNET_WIFI_STATUS_SIZE EQU 45
ESPNET_WIFI_CONN_SIZE   EQU 98
ESPNET_SSID_SIZE        EQU 33
ESPNET_PASS_SIZE        EQU 65
ESPNET_SCAN_REC         EQU 42
ESPNET_SCAN_MAX         EQU 24
ESPNET_UART_SIZE        EQU 8
ESPNET_DNS_NAME         EQU 64
; Kernel keeps only this machine's UART. Userland (espcfg) keeps all four.
; atm 2/3: ATM2 COM + ATM2IOESP. Evo/Pentagon: Kondratyev 0/2.
ESPNET_UART_ATM2        = 0
ESPNET_UART_KOND        = 0
        ifdef ESPNET_KERNEL
         if atm==2 or atm==3
ESPNET_UART_ATM2        = 1
         else
ESPNET_UART_KOND        = 1
         endif
        else
ESPNET_UART_ATM2        = 1
ESPNET_UART_KOND        = 1
        endif

; ============================================================
; Init: espcom.ini, UART, 0.5s settle
; out: A=0 always (defaults if ini missing), HL=0
; ============================================================
esp_init
        xor a
        ld (esp_inited),a
        ld (esp_seq),a
        ld (esp_armed),a
        ld (esp_qflag),a
        ifdef ESPNET_KERNEL
        ld (esp_busy),a
        endif
        call esp_cfg_default
        ifndef ESPNET_KERNEL
        call esp_load_ini
        endif
        if ESPNET_UART_ATM2
        call esp_ports_ready
        endif
        ld a,(esp_div)
        call esp_uart_init
        xor a
        call esp_setrts
        ld hl,65000
        ld (esp_factor),hl
        ld (esp_spin),hl
        ld a,1
        ld (esp_inited),a
        ifndef ESPNET_KERNEL
        ld bc,25
        call esp_wait_ticks
        endif
        xor a
        ld l,a
        ld h,a
        ret

; ============================================================
; SOCKET  D=family E=proto  out: L=sock or L=-1 A=errno
; ============================================================
esp_socket
        ld a,d
        ld (esp_pay1),a
        ld a,e
        ld (esp_arg),a
        ld a,ESPNET_CMD_SOCKET
        ld c,ESPNET_SOCK_NONE
        ld b,e
        ld de,esp_pay1
        ld hl,1
        call esp_xfer
        ret nz
        ld a,(esp_rsp+1)
        ld c,a
        ld b,0
        ld hl,esp_proto
        add hl,bc
        ld a,(esp_arg)
        ld (hl),a
        ld a,(esp_rsp+1)
        jr esp_ok_sock

; ============================================================
; SHUTDOWN  A=sock E=type
; ============================================================
esp_shutdown
        ld c,a
        ld b,e
        ld a,ESPNET_CMD_SHUTDOWN
        ld de,0
        ld hl,0
        jp esp_xfer

; ============================================================
; CONNECT / BIND  A=sock DE=sockaddr 15
; ============================================================
esp_connect
        ld c,a
        ld a,ESPNET_CMD_CONNECT
        ld b,0
        ld hl,ESPNET_SOCKADDR_SIZE
        jp esp_xfer

esp_bind
        ld c,a
        ld a,ESPNET_CMD_BIND
        ld b,0
        ld hl,ESPNET_SOCKADDR_SIZE
        jp esp_xfer

; ============================================================
; LISTEN / ACCEPT  A=sock
; ACCEPT success: L=new sock (WIZNET, not C high-byte)
; ============================================================
esp_listen
        ld c,a
        ld a,ESPNET_CMD_LISTEN
        ld b,0
        ld de,0
        ld hl,0
        jp esp_xfer

esp_accept
        ld c,a
        ld a,ESPNET_CMD_ACCEPT
        ld b,0
        ld de,0
        ld hl,0
        call esp_xfer
        ret nz
        ld a,(esp_rsp+1)
esp_ok_sock
        ld l,a
        ld h,0
        xor a
        ret

; ============================================================
; READ  A=sock DE=buf HL=size
; Userland pipelines the next CMD_READ (esp_armed) so ESP TXs during
; disk I/O. Kernel must not: armed leaves a frame on the UART after
; BDOS returns (esp_busy=0). Another process's SOCKET then drop_armed
; or READ eats that payload (EMSGSIZE 40, garbage errno, PT3 in zifi).
; ============================================================
esp_read
        ld (esp_rs_sock),a
        ld (esp_rs_dst),de
        ld (esp_rs_want),hl
        ld a,(esp_inited)
        or a
        ld a,ESPNET_ERR_NOTCONN
        jp z,esp_fail
        ld hl,(esp_rs_want)
        ifdef ESPNET_KERNEL
        call esp_ld_hostmax
        else
        ld de,ESPNET_HOST_MAX
        endif
        call esp_umin
        ld (esp_rs_want),hl
        ld a,(esp_rs_want)
        ld (esp_pay2),a
        ld a,(esp_rs_want+1)
        ld (esp_pay2+1),a
        ifndef ESPNET_KERNEL
        ld a,(esp_armed)
        or a
        jr z,esp_rd_send
        xor a
        ld (esp_armed),a
        jr esp_rd_hdr
        endif
esp_rd_send
        ld a,(esp_rs_sock)
        ld c,a
        ld b,0
        ld a,ESPNET_CMD_READ
        ld de,esp_pay2
        ld hl,2
        call esp_send_cmd
esp_rd_hdr
        ld a,ESPNET_CMD_READ
        call esp_recv_hdr
        ret nz
        ld hl,(esp_rsp+4)
        ld (esp_rs_n),hl
        ld a,(esp_rsp+2)
        or a
        jr z,esp_rd_okst
        ld hl,(esp_plen)
        ld a,h
        or l
        call nz,esp_skip_or_drain
        ld a,(esp_rsp+2)
        cp ESPNET_ERR_EAGAIN
        jp nz,esp_fail
        call esp_rd_arm
        ld a,ESPNET_ERR_EAGAIN
        jp esp_fail
esp_rd_okst
        ld hl,(esp_rs_n)
        ld a,h
        or l
        jr z,esp_rd_empty
        ld de,(esp_plen)
        ld a,d
        or e
        jr z,esp_rd_empty
        ; n = min(n, plen, want)
        ld hl,(esp_rs_n)
        ld de,(esp_plen)
        call esp_umin
        ld de,(esp_rs_want)
        call esp_umin
        ld (esp_rs_n),hl
        ld de,(esp_rs_dst)
        call esp_recv_fill
        jr nz,esp_rd_bad
        ld hl,(esp_plen)
        ld de,(esp_rs_n)
        or a
        sbc hl,de
        jr z,esp_rd_armok
        call esp_recv_skip
        jr nz,esp_rd_bad
esp_rd_armok
        call esp_rd_arm
        ld hl,(esp_rs_n)
        xor a
        ret
esp_rd_empty
        ld hl,(esp_plen)
        ld a,h
        or l
        call nz,esp_skip_or_drain
        call esp_rd_arm
        ld a,ESPNET_ERR_EAGAIN
        jp esp_fail
esp_rd_bad
        call esp_rx_drain
        ld a,ESPNET_ERR_INTR
esp_fail
        ld (esp_errno),a
        ld l,-1
        ld h,l
        or a
        ret

esp_rd_arm
        ifdef ESPNET_KERNEL
        xor a
        ld (esp_armed),a
        ret
        else
        ld a,(esp_rs_sock)
        ld c,a
        ld b,0
        ld a,ESPNET_CMD_READ
        ld de,esp_pay2
        ld hl,2
        call esp_send_cmd
        ld a,1
        ld (esp_armed),a
        ret
        endif

esp_skip_or_drain
        call esp_recv_skip
        ret z
        jp esp_rx_drain

; HL=a DE=b  out HL=min(a,b)
esp_umin
        ld a,h
        cp d
        ret c
        jr nz,esp_umin_de
        ld a,l
        cp e
        ret c
esp_umin_de
        ex de,hl
        ret

; ============================================================
; WRITE  A=sock DE=buf HL=size  (splits at HOST_MAX)
; Loop only while firmware accepts bytes. Do not spin on EAGAIN
; holding the UART lock (that starves lwIP). Firmware 1.24 waits
; on sndbuf so WIZNET-style apps (3ws send() once per chunk) get
; a full WRITE. Short write / 35 if the wait expires.
; ============================================================
esp_write
        ld (esp_rs_sock),a
        ld (esp_rs_dst),de
        ld (esp_rs_want),hl
        ld hl,0
        ld (esp_sent),hl
esp_wr_lp
        ld hl,(esp_rs_want)
        ld a,h
        or l
        jr z,esp_wr_done
        ifdef ESPNET_KERNEL
        call esp_ld_hostmax
        else
        ld de,ESPNET_HOST_MAX
        endif
        call esp_umin
        ld (esp_chunk),hl
        ld a,(esp_rs_sock)
        ld c,a
        ld b,0
        ld a,ESPNET_CMD_WRITE
        ld de,(esp_rs_dst)
        call esp_xfer
        jr z,esp_wr_ok
        ; EAGAIN/error: short write if some frames went, else errno.
esp_wr_part
        ld hl,(esp_sent)
        ld a,h
        or l
        jr z,esp_wr_err
        xor a
        ret
esp_wr_err
        ld a,(esp_errno)
        jp esp_fail
esp_wr_ok
        ld hl,(esp_rsp+4)
        ld a,h
        or l
        jr nz,esp_wr_got
        ld hl,(esp_sent)
        ld a,h
        or l
        jr z,esp_wr_emsg
        xor a
        ret
esp_wr_emsg
        ld a,ESPNET_ERR_EMSGSIZE
        jp esp_fail
esp_wr_got
        ld (esp_chunk_got),hl
        ld de,(esp_sent)
        add hl,de
        ld (esp_sent),hl
        ld hl,(esp_rs_dst)
        ld de,(esp_chunk_got)
        add hl,de
        ld (esp_rs_dst),hl
        ld hl,(esp_rs_want)
        ld de,(esp_chunk_got)
        or a
        sbc hl,de
        ld (esp_rs_want),hl
        ld hl,(esp_chunk_got)
        ld de,(esp_chunk)
        or a
        sbc hl,de
        jr c,esp_wr_done
        jr esp_wr_lp
esp_wr_done
        ld hl,(esp_sent)
        xor a
        ret

        ifndef ESPNET_KERNEL
; ============================================================
; GETDNS  DE=ip[4]
; ============================================================
esp_getdns
        ld (esp_rs_dst),de
        ld a,ESPNET_CMD_GETDNS
        ld c,ESPNET_SOCK_NONE
        ld b,0
        ld de,0
        ld hl,0
        call esp_xfer
        ret nz
        ld de,(esp_rs_dst)
        ld hl,esp_rsp+ESPNET_RSP_HDR
        ld bc,4
        ldir
        xor a
        ld l,a
        ld h,a
        ret

; ============================================================
; DNSRESOLVE  HL=hostname DE=ip[4]
; ============================================================
esp_dns
        ld (esp_rs_dst),de
        ld (esp_rs_src),hl
        xor a
        ld c,a
esp_dns_len
        ld a,(hl)
        or a
        jr z,esp_dns_n
        inc hl
        inc c
        ld a,c
        cp ESPNET_DNS_NAME-1
        jr c,esp_dns_len
esp_dns_n
        ld a,c
        or a
        ld a,ESPNET_ERR_HOSTUNREACH
        jp z,esp_fail
        ld l,c
        ld h,0
        ld a,ESPNET_CMD_DNSRESOLVE
        ld c,ESPNET_SOCK_NONE
        ld b,0
        ld de,(esp_rs_src)
        call esp_xfer
        ret nz
        ld de,(esp_rs_dst)
        ld hl,esp_rsp+ESPNET_RSP_HDR
        ld bc,4
        ldir
        xor a
        ld l,a
        ld h,a
        ret

; ============================================================
; INFO  DE=buf[53]
; ============================================================
esp_info
        ld (esp_rs_dst),de
        ld a,ESPNET_CMD_INFO
        ld c,ESPNET_SOCK_NONE
        ld b,0
        ld de,0
        ld hl,0
        call esp_xfer
        ret nz
        ld hl,(esp_rsp+6)
        ld de,ESPNET_INFO_SIZE
        call esp_umin
        push hl
        ld hl,(esp_rs_dst)
        ld b,ESPNET_INFO_SIZE
        xor a
esp_info_z
        ld (hl),a
        inc hl
        djnz esp_info_z
        pop bc
        ld a,b
        or c
        jr z,esp_ok0
        ld de,(esp_rs_dst)
        ld hl,esp_rsp+ESPNET_RSP_HDR
        ldir
esp_ok0
        xor a
        ld l,a
        ld h,a
        ret
        endif

; WIFI: kernel BDOS + userland enet. ECHO stays userland-only.
        ifdef ESPNET_KERNEL
esp_ok0
        xor a
        ld l,a
        ld h,a
        ret
        endif

; ============================================================
; WIFI / UART (caller buffers)
; ============================================================
esp_wifi_scan
        ; DE=buf HL=bufsize  out HL=result count or -1
        ld (esp_rs_dst),de
        ld (esp_rs_want),hl
        ld a,(esp_inited)
        or a
        ld a,ESPNET_ERR_NOTCONN
        jp z,esp_fail
        call esp_drop_armed
        ld hl,ESPNET_SOF_TICKS_LONG
        ld (esp_sof_ticks),hl
        ld a,ESPNET_CMD_WIFI_SCAN
        ld c,ESPNET_SOCK_NONE
        ld b,0
        ld de,0
        ld hl,0
        call esp_send_cmd
        ld a,ESPNET_CMD_WIFI_SCAN
        ld de,(esp_rs_dst)
        ld hl,(esp_rs_want)
        call esp_recv_dst
        push af
        ld hl,ESPNET_SOF_TICKS
        ld (esp_sof_ticks),hl
        pop af
        ret nz
        ld hl,(esp_rsp+4)
        xor a
        ret

esp_wifi_connect
        ; HL=ssid DE=pass (ASCIIZ, may be 0)
        push de
        push hl
        ld hl,esp_wifi_pay
        ld b,ESPNET_WIFI_CONN_SIZE
        xor a
esp_wc_z
        ld (hl),a
        inc hl
        djnz esp_wc_z
        pop hl
        ld a,h
        or l
        jr z,esp_wc_pass
        ld de,esp_wifi_pay
        ld b,ESPNET_SSID_SIZE-1
        call esp_copyz
esp_wc_pass
        pop hl
        ld a,h
        or l
        jr z,esp_wc_go
        ld de,esp_wifi_pay+ESPNET_SSID_SIZE
        ld b,ESPNET_PASS_SIZE-1
        call esp_copyz
esp_wc_go
        ld a,ESPNET_CMD_WIFI_CONNECT
        ld c,ESPNET_SOCK_NONE
        ld b,0
        ld de,esp_wifi_pay
        ld hl,ESPNET_WIFI_CONN_SIZE
        jp esp_xfer

esp_wifi_disc
        ld a,ESPNET_CMD_WIFI_DISC
        ld c,ESPNET_SOCK_NONE
        ld b,0
        ld de,0
        ld hl,0
        jp esp_xfer

esp_wifi_status
        ; DE=buf[45]
        ld (esp_rs_dst),de
        ld a,ESPNET_CMD_WIFI_STATUS
        ld c,ESPNET_SOCK_NONE
        ld b,0
        ld de,0
        ld hl,0
        call esp_xfer
        ret nz
        ld hl,(esp_rsp+6)
        ld de,ESPNET_WIFI_STATUS_SIZE
        call esp_umin
        push hl
        ld hl,(esp_rs_dst)
        ld b,ESPNET_WIFI_STATUS_SIZE
        xor a
esp_ws_z
        ld (hl),a
        inc hl
        djnz esp_ws_z
        pop bc
        ld a,b
        or c
        jp z,esp_ok0
        ld de,(esp_rs_dst)
        ld hl,esp_rsp+ESPNET_RSP_HDR
        ldir
        jp esp_ok0

        ifndef ESPNET_KERNEL
esp_echo
        ; DE=data HL=len  out HL=echoed len
        ld (esp_rs_dst),de
        ld (esp_rs_want),hl
        ld a,(esp_inited)
        or a
        ld a,ESPNET_ERR_NOTCONN
        jp z,esp_fail
        ld de,ESPNET_HOST_MAX
        call esp_umin
        ld (esp_rs_want),hl
        call esp_drop_armed
        ld a,ESPNET_CMD_ECHO
        ld c,ESPNET_SOCK_NONE
        ld b,0
        ld de,(esp_rs_dst)
        ld hl,(esp_rs_want)
        call esp_send_cmd
        ld a,ESPNET_CMD_ECHO
        ld de,(esp_rs_dst)
        ld hl,(esp_rs_want)
        call esp_recv_dst
        ret nz
        ld hl,(esp_rsp+6)
        xor a
        ret
        endif

; UDP READ  A=sock DE=data HL=size BC=sockaddr
esp_read_udp
        ld (esp_rs_sock),a
        ld (esp_rs_dst),de
        ld (esp_rs_want),hl
        ld (esp_udp_sa),bc
        ld a,(esp_inited)
        or a
        ld a,ESPNET_ERR_NOTCONN
        jp z,esp_fail
        ld hl,(esp_rs_want)
        ifdef ESPNET_KERNEL
        call esp_ld_hostmax_udp
        else
        ld de,ESPNET_HOST_MAX-ESPNET_SOCKADDR_SIZE
        endif
        call esp_umin
        ld (esp_rs_want),hl
        ld a,l
        ld (esp_pay2),a
        ld a,h
        ld (esp_pay2+1),a
        call esp_drop_armed
        ld hl,ESPNET_SOF_TICKS_UDP
        ld (esp_sof_ticks),hl
        ld a,(esp_rs_sock)
        ld c,a
        ld b,0
        ld a,ESPNET_CMD_READ
        ld de,esp_pay2
        ld hl,2
        call esp_send_cmd
        ld a,ESPNET_CMD_READ
        call esp_recv_hdr
        push af
        ld hl,ESPNET_SOF_TICKS
        ld (esp_sof_ticks),hl
        pop af
        ret nz
        ld hl,(esp_rsp+4)
        ld (esp_rs_n),hl
        ld a,(esp_rsp+2)
        or a
        jr z,esp_ru_ok
        ld hl,(esp_plen)
        ld a,h
        or l
        call nz,esp_skip_or_drain
        ld a,(esp_rsp+2)
        jp esp_fail
esp_ru_ok
        ld hl,(esp_rs_n)
        ld a,h
        or l
        jr z,esp_ru_eagain
        ld hl,(esp_plen)
        ld de,ESPNET_SOCKADDR_SIZE
        or a
        sbc hl,de
        jr c,esp_ru_eagain
        ld de,(esp_udp_sa)
        ld hl,ESPNET_SOCKADDR_SIZE
        call esp_recv_fill
        jp nz,esp_rd_bad
        ld hl,(esp_rs_n)
        ld de,(esp_rs_want)
        call esp_umin
        ld de,(esp_plen)
        ld a,e
        sub ESPNET_SOCKADDR_SIZE
        ld e,a
        ld a,d
        sbc a,0
        ld d,a
        call esp_umin
        ld (esp_rs_n),hl
        ld a,h
        or l
        jr z,esp_ru_skip
        ld de,(esp_rs_dst)
        call esp_recv_fill
        jp nz,esp_rd_bad
esp_ru_skip
        ld hl,(esp_plen)
        ld de,ESPNET_SOCKADDR_SIZE
        or a
        sbc hl,de
        ld de,(esp_rs_n)
        or a
        sbc hl,de
        jr z,esp_ru_done
        call esp_recv_skip
        jp nz,esp_rd_bad
esp_ru_done
        ld hl,(esp_rs_n)
        xor a
        ret
esp_ru_eagain
        ld hl,(esp_plen)
        ld a,h
        or l
        call nz,esp_skip_or_drain
        ld a,ESPNET_ERR_EAGAIN
        jp esp_fail

; UDP WRITE  A=sock DE=data HL=dlen BC=sockaddr
esp_write_udp
        ld (esp_rs_sock),a
        ld (esp_rs_dst),de
        ld (esp_rs_want),hl
        ld (esp_udp_sa),bc
        ld a,(esp_inited)
        or a
        ld a,ESPNET_ERR_NOTCONN
        jp z,esp_fail
        ld hl,(esp_rs_want)
        ifdef ESPNET_KERNEL
        call esp_ld_hostmax_udp
        else
        ld de,ESPNET_HOST_MAX-ESPNET_SOCKADDR_SIZE
        endif
        ld a,h
        cp d
        jr c,esp_wu_oksz
        jr nz,esp_wu_big
        ld a,l
        cp e
        jr z,esp_wu_oksz
        jr c,esp_wu_oksz
esp_wu_big
        ld a,ESPNET_ERR_EMSGSIZE
        jp esp_fail
esp_wu_oksz
        call esp_drop_armed
        ld hl,ESPNET_SOF_TICKS_UDP
        ld (esp_sof_ticks),hl
        ld de,(esp_udp_sa)
        ld (esp_p2),de
        ld hl,ESPNET_SOCKADDR_SIZE
        ld (esp_n2),hl
        ld de,(esp_rs_dst)
        ld (esp_p3),de
        ld hl,(esp_rs_want)
        ld (esp_n3),hl
        ld a,(esp_rs_sock)
        ld c,a
        ld b,0
        ld a,ESPNET_CMD_WRITE
        call esp_send_cmd2
        call esp_recv_rsp
        push af
        ld hl,ESPNET_SOF_TICKS
        ld (esp_sof_ticks),hl
        pop af
        jr nz,esp_wu_bad
        ld a,(esp_rsp)
        cp ESPNET_CMD_WRITE
        jr nz,esp_wu_bad
        ld a,(esp_rsp+3)
        ld hl,esp_seq
        cp (hl)
        jr nz,esp_wu_bad
        ld a,(esp_rsp+2)
        or a
        jp nz,esp_fail
        ld hl,(esp_rsp+4)
        xor a
        ret
esp_wu_bad
        call esp_rx_drain
        ld a,ESPNET_ERR_INTR
        jp esp_fail

esp_copyz
        ; HL=src DE=dst B=max
        ld a,(hl)
        or a
        ret z
        ld (de),a
        inc hl
        inc de
        djnz esp_copyz
        ret

; ============================================================
; Framing
; A=cmd C=sock B=arg DE=payload HL=plen
; out: Z+A=0+HL=0 ok; NZ A=errno HL=-1
; ============================================================
esp_xfer
        ld (esp_xcmd),a
        ld a,c
        ld (esp_xsock),a
        ld a,b
        ld (esp_xarg),a
        ld (esp_p2),de
        ld (esp_n2),hl
        ld a,(esp_inited)
        or a
        ld a,ESPNET_ERR_NOTCONN
        jp z,esp_fail
        ld a,h
        cp ESPNET_HOST_MAX/256
        jr c,esp_xf_sz
        jr nz,esp_xf_big
        ld a,l
        or a
        jr z,esp_xf_sz
esp_xf_big
        ld a,ESPNET_ERR_EMSGSIZE
        jp esp_fail
esp_xf_sz
        call esp_drop_armed
        ld a,(esp_xcmd)
        ifndef ESPNET_KERNEL
        cp ESPNET_CMD_DNSRESOLVE
        jr z,esp_xf_long
        cp ESPNET_CMD_WIFI_CONNECT
        jr z,esp_xf_long
        endif
        cp ESPNET_CMD_CONNECT
        jr z,esp_xf_long
        cp ESPNET_CMD_INFO
        jr z,esp_xf_long
        cp ESPNET_CMD_WRITE
        jr nz,esp_xf_short
esp_xf_long
        ld hl,ESPNET_SOF_TICKS_LONG
        ld (esp_sof_ticks),hl
        jr esp_xf_send
esp_xf_short
        ld hl,ESPNET_SOF_TICKS
        ld (esp_sof_ticks),hl
esp_xf_send
        ld a,(esp_xsock)
        ld c,a
        ld a,(esp_xarg)
        ld b,a
        ld de,(esp_p2)
        ld hl,(esp_n2)
        ld a,(esp_xcmd)
        call esp_send_cmd
        call esp_recv_rsp
        push af
        ld hl,ESPNET_SOF_TICKS
        ld (esp_sof_ticks),hl
        pop af
        jr nz,esp_xf_bad
        ld a,(esp_rsp)
        ld hl,esp_xcmd
        cp (hl)
        jr nz,esp_xf_bad
        ld a,(esp_rsp+3)
        ld hl,esp_seq
        cp (hl)
        jr nz,esp_xf_bad
        ld a,(esp_rsp+2)
        or a
        jr z,esp_ok0_x
        ld (esp_errno),a
        jp esp_fail
esp_xf_bad
        call esp_rx_drain
        ld a,ESPNET_ERR_INTR
        ld (esp_errno),a
        jp esp_fail
esp_ok0_x
        xor a
        ld l,a
        ld h,a
        ld (esp_errno),a
        ret

esp_send_cmd
        ld (esp_p2),de
        ld (esp_n2),hl
        ld hl,0
        ld (esp_n3),hl
esp_send_cmd2
        ; A=cmd C=sock B=arg  p2/n2 p3/n3
        ld (esp_req),a
        ld a,c
        ld (esp_req+1),a
        ld a,b
        ld (esp_req+2),a
        ld a,(esp_seq)
        inc a
        ld (esp_seq),a
        ld (esp_req+3),a
        ld hl,(esp_n2)
        ld de,(esp_n3)
        add hl,de
        ld a,l
        ld (esp_req+4),a
        ld a,h
        ld (esp_req+5),a
        if ESPNET_UART_ATM2
        ; AT sendcommand does not touch RTS. Type 1 pulse is in fill/rx only.
        ld a,(esp_comType)
        dec a
        jr nz,esp_sc_rts
        jr esp_sc_tx
        endif
esp_sc_rts
        xor a
        call esp_setrts
esp_sc_tx
        ld a,ESPNET_SOF
        call esp_putb
        ld hl,esp_req
        ld bc,ESPNET_REQ_HDR
        call esp_send_raw
        ld hl,(esp_n2)
        ld a,h
        or l
        jr z,esp_sc_p3
        ld de,(esp_p2)
        ld a,d
        or e
        jr z,esp_sc_p3
        ld hl,(esp_p2)
        ld de,(esp_n2)
        ld b,d
        ld c,e
        call esp_send_raw
esp_sc_p3
        ld hl,(esp_n3)
        ld a,h
        or l
        ret z
        ld hl,(esp_p3)
        ld de,(esp_n3)
        ld b,d
        ld c,e
        jp esp_send_raw

esp_send_raw
        ; HL=src BC=n
        ld a,b
        or c
        ret z
esp_sr_gen
        ld a,(hl)
        push hl
        push bc
        call esp_putb
        pop bc
        pop hl
        inc hl
        dec bc
        jr esp_send_raw

esp_drop_armed
        ifdef ESPNET_KERNEL
        xor a
        ld (esp_armed),a
        ret
        else
        ld a,(esp_armed)
        or a
        ret z
        xor a
        ld (esp_armed),a
        call esp_recv_sof
        jr nz,esp_da_dr
        ld de,esp_rsp
        ld hl,ESPNET_RSP_HDR
        call esp_recv_fill
        jr nz,esp_da_dr
        ld hl,(esp_rsp+6)
        ld a,h
        or l
        ret z
        call esp_recv_skip
        ret z
esp_da_dr
        jp esp_rx_drain
        endif

; recv 8-byte hdr + payload into esp_rsp (plen<=RSP_MAX)
; out Z ok
esp_recv_rsp
        call esp_recv_sof
        jr nz,esp_rr_fail
        ld de,esp_rsp
        ld hl,ESPNET_RSP_HDR
        call esp_recv_fill
        jr nz,esp_rr_fail
        ld hl,(esp_rsp+6)
        ld a,h
        or a
        jr z,esp_rr_lo
        dec a
        jr nz,esp_rr_fail
        ld a,l
        or a
        jr nz,esp_rr_fail
        ld de,esp_rsp+ESPNET_RSP_HDR
        ld hl,ESPNET_RSP_MAX
        jp esp_recv_fill
esp_rr_lo
        ld a,l
        or a
        ret z
        ld h,0
        ld de,esp_rsp+ESPNET_RSP_HDR
        jp esp_recv_fill
esp_rr_fail
        ld a,1
        or a
        ret

; A=expected cmd  out Z ok, esp_plen set. NZ A=errno HL=-1
esp_recv_hdr
        ld (esp_xcmd),a
        call esp_recv_sof
        jr nz,esp_rh_bad
        ld de,esp_rsp
        ld hl,ESPNET_RSP_HDR
        call esp_recv_fill
        jr nz,esp_rh_bad
        ld a,(esp_rsp)
        ld hl,esp_xcmd
        cp (hl)
        jr nz,esp_rh_bad
        ld a,(esp_rsp+3)
        ld hl,esp_seq
        cp (hl)
        jr nz,esp_rh_bad
        ld hl,(esp_rsp+6)
        ld (esp_plen),hl
        ld de,ESPNET_HOST_MAX
        ld a,h
        cp d
        jr c,esp_rh_ok
        jr nz,esp_rh_bad
        ld a,l
        cp e
        jr z,esp_rh_ok
        jr nc,esp_rh_bad
esp_rh_ok
        xor a
        ret
esp_rh_bad
        call esp_rx_drain
        ld a,ESPNET_ERR_INTR
        jp esp_fail

; A=cmd DE=dst HL=dstmax  payload after hdr already? no, calls recv_hdr
esp_recv_dst
        ld (esp_rs_dst),de
        ld (esp_rs_want),hl
        call esp_recv_hdr
        ret nz
        ld a,(esp_rsp+2)
        or a
        jr z,esp_rdst_ok
        ld hl,(esp_plen)
        ld a,h
        or l
        call nz,esp_skip_or_drain
        ld a,(esp_rsp+2)
        jp esp_fail
esp_rdst_ok
        ld hl,(esp_plen)
        ld de,(esp_rs_want)
        call esp_umin
        ld (esp_rs_n),hl
        ld a,h
        or l
        jr z,esp_rdst_skip
        ld de,(esp_rs_dst)
        call esp_recv_fill
        jr nz,esp_rdst_bad
esp_rdst_skip
        ld hl,(esp_plen)
        ld de,(esp_rs_n)
        or a
        sbc hl,de
        jp z,esp_ok0_x
        call esp_recv_skip
        jr nz,esp_rdst_bad
        jp esp_ok0_x
esp_rdst_bad
        call esp_rx_drain
        ld a,ESPNET_ERR_INTR
        jp esp_fail

esp_recv_skip
        ld (esp_left),hl
esp_sk2
        ld hl,(esp_left)
        ld a,h
        or l
        ret z
        ld de,ESPNET_RSP_MAX
        call esp_umin
        ld (esp_chunk),hl
        ld de,esp_rsp+ESPNET_RSP_HDR
        call esp_recv_fill
        ret nz
        ld hl,(esp_left)
        ld de,(esp_chunk)
        or a
        sbc hl,de
        ld (esp_left),hl
        jr esp_sk2

esp_rx_drain
        if ESPNET_UART_ATM2
        call esp_rts_rxlevel
        else
        xor a
        endif
        call esp_setrts
        ld hl,0
        ld (esp_left),hl
        xor a
        ld (esp_silent),a
esp_dr_lp
        ld hl,(esp_left)
        ld de,1000
        or a
        sbc hl,de
        jr nc,esp_dr_done
        ld a,(esp_silent)
        cp 80
        jr nc,esp_dr_done
        call esp_rx_poll
        jr nz,esp_dr_got
        ld a,(esp_silent)
        inc a
        ld (esp_silent),a
        jr esp_dr_inc
esp_dr_got
        xor a
        ld (esp_silent),a
esp_dr_inc
        ld hl,(esp_left)
        inc hl
        ld (esp_left),hl
        jr esp_dr_lp
esp_dr_done
        xor a
        jp esp_setrts

; ============================================================
; SOF wait. Type 0 pulses RTS while empty. YIELD on timer change
; after 256 idle polls (unsigned wrap of idle).
; out: Z=got SOF, NZ=timeout
; ============================================================
esp_recv_sof
        if ESPNET_UART_ATM2
        call esp_rts_rxlevel
        or a
        jr nz,esp_sof_afterrts
        endif
        xor a
        call esp_setrts
esp_sof_afterrts
        ld hl,(esp_factor)
        ld a,h
        or l
        jr nz,esp_sof_sp
        ld hl,20000
esp_sof_sp
        ld (esp_spin),hl
        ifdef ESPNET_KERNEL
        ld hl,(esp_sof_ticks)
        ld (esp_deadline),hl
        else
        OS_GETTIMER
        ld de,(esp_sof_ticks)
        add hl,de
        ld (esp_deadline),hl
        OS_GETTIMER
        ld (esp_last_y),hl
        endif
        xor a
        ld (esp_idle),a
esp_sof_lp
        if ESPNET_UART_KOND
        ld a,(esp_comType)
        or a
        jr z,esp_sof_t0
         if ESPNET_UART_ATM2
        cp 2
        jr z,esp_sof_t2
        call esp_rx_poll
        jr z,esp_sof_idle
        ld a,(esp_rb)
        cp ESPNET_SOF
        ret z
        jr esp_sof_idle
         endif
esp_sof_t2
        ld bc,(esp_LSR)
        in a,(c)
        rrca
        jr nc,esp_sof_idle
        ld bc,(esp_RBR)
        in a,(c)
        ld (esp_rb),a
        cp ESPNET_SOF
        ret z
        jr esp_sof_idle
esp_sof_t0
        ld bc,(esp_LSR)
        in a,(c)
        rrca
        jr nc,esp_sof_t0empty
        ld bc,(esp_RBR)
        in a,(c)
        ld (esp_rb),a
        cp ESPNET_SOF
        ret z
        jr esp_sof_idle
esp_sof_t0empty
        di
        ld bc,(esp_MCR)
        ld a,2
        out (c),a
        xor a
        out (c),a
        ei
        jr esp_sof_idle
        else
        call esp_rx_poll
        jr z,esp_sof_idle
        ld a,(esp_rb)
        cp ESPNET_SOF
        ret z
        jr esp_sof_idle
        endif
esp_sof_idle
        ld a,(esp_idle)
        inc a
        ld (esp_idle),a
        jr nz,esp_sof_lp
        ifdef ESPNET_KERNEL
        ld hl,(esp_deadline)
        dec hl
        ld (esp_deadline),hl
        ld a,h
        or l
        jp nz,esp_sof_lp
        else
        OS_GETKEY
        or a
        jr z,esp_sof_tmr
        cp 'q'
        jr z,esp_sof_q
        cp 'Q'
        jr z,esp_sof_q
esp_sof_tmr
        OS_GETTIMER
        ld de,(esp_last_y)
        ld a,l
        cp e
        jr nz,esp_sof_tick
        ld a,h
        cp d
        jr z,esp_sof_tochk
esp_sof_tick
        ld (esp_last_y),hl
        push hl
        YIELD
        pop hl
esp_sof_tochk
        ld de,(esp_deadline)
        ex de,hl
        or a
        sbc hl,de
        jp nc,esp_sof_lp
        endif
esp_sof_to
        xor a
        call esp_setrts
        ld a,1
        or a
        ret
        ifndef ESPNET_KERNEL
esp_sof_q
        ld a,1
        ld (esp_qflag),a
        jr esp_sof_to
        endif

; DE=dst HL=n  out Z ok
esp_recv_fill
        ld (esp_dst),de
        ld (esp_n),hl
        ld a,(esp_comType)
        if ESPNET_UART_KOND
        if ESPNET_UART_ATM2
        or a
        jp z,esp_fill0
        dec a
        jp z,esp_fill1
        dec a
        jp z,esp_fill2
        jp esp_fill3
        else
        or a
        jp z,esp_fill0
        jp esp_fill2
        endif
        else
        dec a
        jp z,esp_fill1
        jp esp_fill3
        endif

        if ESPNET_UART_KOND
; Type 0 Kondratyev, no AFC: pulse MCR RTS while LSR is empty, then RBR.
; BC = LSR during the wait; MCR only when we actually pulse.
; Hold-RTS (no off between polls) hung: on this path RTS is a byte strobe
; (FPGA/ATmega), not ESP CTS level. ZX-WiFi fill0 is ~15% slower than fill2
; but still far above Kondratyev type 0.
esp_fill0
        di
        ld ix,(esp_dst)
        ld de,(esp_n)
        ld bc,(esp_LSR)
esp_f0_next
        ld a,d
        or e
        jr z,esp_f0_ok
        ld hl,(esp_spin)
esp_f0_wait
        ld a,h
        or l
        jr z,esp_f0to
        in a,(c)
        rrca
        jr c,esp_f0_read
        dec hl
        ld bc,(esp_MCR)
        ld a,2
        out (c),a
        xor a
        out (c),a
        ld bc,(esp_LSR)
        jr esp_f0_wait
esp_f0_read
        ld bc,(esp_RBR)
        in a,(c)
        ld (ix),a
        inc ix
        dec de
        ld bc,(esp_LSR)
        jr esp_f0_next
esp_f0_ok
        ei
        xor a
        ret
        endif
esp_f0to
        ei
esp_fill_to
        ld a,1
        or a
        ret

        if ESPNET_UART_ATM2
; Type 1 = IAR getdataEsp. Whole fill under DI. IN A,(C) not IN D:
; DE is the remaining count (IAR keeps that in statics). Empty path
; matches the listing: ADD HL,-1 then 55/43/03 + 55/43/00. Do not
; tighten the RTS pulse ? short strobes lose bytes on 8952.
esp_fill1
        di
        ld ix,(esp_dst)
        ld de,(esp_n)
esp_f1_next
        ld a,d
        or e
        jr z,esp_f1_ok
        ld hl,(esp_spin)
esp_f1_wait
        ld a,h
        or l
        jr z,esp_f1to
        ld bc,0x55fe
        in a,(c)
        ld bc,0xc2fe
        in a,(c)
        or a
        jr z,esp_f1_empty
        ld bc,0x55fe
        in a,(c)
        ld bc,0x02fe
        in a,(c)
        ld (ix),a
        inc ix
        dec de
        jr esp_f1_next
esp_f1_empty
        ld bc,65535
        add hl,bc
        ld bc,0x55fe
        in a,(c)
        ld bc,0x43fe
        in a,(c)
        ld bc,0x03fe
        in a,(c)
        ld bc,0x55fe
        in a,(c)
        ld bc,0x43fe
        in a,(c)
        ld bc,0x00fe
        in a,(c)
        jr esp_f1_wait
esp_f1_ok
        ei
        xor a
        ret
esp_f1to
        ei
        jr esp_fill_to
; E=0x03 DTR+RTS on, E=0 off. Caller holds DI.
esp_atm2_mcr
        ld bc,0x55fe
        in a,(c)
        ld bc,0x43fe
        in a,(c)
        ld b,e
        ld c,0xfe
        in a,(c)
        ret
        endif

        if ESPNET_UART_KOND
; Type 2 AFC: hardware RTS. One wait on LSR DR, then RBR.
; BC holds the LSR port for the whole wait (address is constant).
; esp_spin is the per-byte timeout; reload it for each byte, not each poll.
esp_fill2
        ;di
        ld ix,(esp_dst)
        ld de,(esp_n)
        ld bc,(esp_LSR)
esp_f2_next
        ld a,d
        or e
        jp z,esp_f2_ok
        ld hl,(esp_spin)
esp_f2_wait
        ld a,h
        or l
        jp z,esp_f0to   ;timeout
        in a,(c)
        rrca
        jp c,esp_f2_read
        dec hl
        jp esp_f2_wait
esp_f2_read
        ld bc,(esp_RBR)
        in a,(c)
        ld (ix),a
        inc ix
        dec de
        ld bc,(esp_LSR)
        jp esp_f2_next
esp_f2_ok
        ;ei
        xor a
        ret
        endif

        if ESPNET_UART_ATM2
; Type 3 ATM2IOESP: 16550 behind FB=index / FA=data. LSR stays selected
; between bytes. Empty: pulse MCR RTS, select LSR again, retry.
esp_fill3
        di
        ld a,(esp_rLSR)
        out (0xfb),a
        ld ix,(esp_dst)
        ld de,(esp_n)
esp_f3_next
        ld a,d
        or e
        jr z,esp_f3_ok
        in a,(0xfa)
        rrca
        jr c,esp_f3_read
        ld hl,(esp_spin)
esp_f3_wait
        dec hl
        ld a,h
        or l
        jp z,esp_f0to
        ld a,(esp_rMCR)
        out (0xfb),a
        ld a,2
        out (0xfa),a
        xor a
        out (0xfa),a
        ld a,(esp_rLSR)
        out (0xfb),a
        in a,(0xfa)
        rrca
        jr nc,esp_f3_wait
esp_f3_read
        ld a,(esp_rRBR)
        out (0xfb),a
        in a,(0xfa)
        ld (ix),a
        inc ix
        dec de
        ld a,(esp_rLSR)
        out (0xfb),a
        jr esp_f3_next
esp_f3_ok
        ei
        xor a
        ret
        endif

; ============================================================
; UART
; ============================================================
; A = byte. Save first: wait_cts always loads comType into A (even the
; type 1/2 early return), so a post-wait store sent garbage. Symptom:
; CMD_INFO SOF never seen, errno 4. C putb() keeps the byte in a local.
esp_putb
        ld (esp_txb),a
        call esp_wait_cts
esp_uart_write
        ld a,(esp_comType)
        if ESPNET_UART_ATM2
        cp 1
        jr z,esp_wr1
         if ESPNET_UART_KOND
        cp 3
        jr z,esp_wr3
         else
        jr esp_wr3
         endif
        endif
        if ESPNET_UART_KOND
esp_wr02
        ld bc,(esp_LSR)
        ld hl,(esp_factor)
esp_wr02w
        in a,(c)
        and 32
        jr nz,esp_wr02g
        dec hl
        ld a,h
        or l
        jr nz,esp_wr02w
esp_wr02g
        ld bc,(esp_RBR)
        ld a,(esp_txb)
        out (c),a
        ret
        endif
        if ESPNET_UART_ATM2
; IAR uart_write case 1 listing (iccz80 -s7). DI one byte, no timeout,
; IN E,(C), BIT 5,E, then the compiler's (data<<8)|0xFE shuffle so 03FE
; to data-strobe is ~50T. Tight IN A / AND 32 / whole-frame DI hung espcfg.
esp_wr1
        ld a,(esp_txb)
        ld d,a
        di
esp_wr1w
        ld bc,0x55fe
        in e,(c)
        ld bc,0x42fe
        in e,(c)
        bit 5,e
        jr z,esp_wr1w
        ld bc,0x55fe
        in e,(c)
        ld bc,0x03fe
        in e,(c)
        ld c,d
        ld b,0
        ld b,c
        ld c,0
        ld a,c
        or 254
        ld c,a
        in e,(c)
        ei
        ret

esp_wr3
        ld hl,(esp_factor)
esp_wr3w
        ld a,(esp_rLSR)
        call esp_in3
        and 32
        jr nz,esp_wr3g
        dec hl
        ld a,h
        or l
        jr nz,esp_wr3w
esp_wr3g
        di
        ld a,(esp_rRBR)
        out (0xfb),a
        ld a,(esp_txb)
        out (0xfa),a
        ei
        ret

esp_in3
        ; A=reg  out A=data
        di
        out (0xfb),a
        in a,(0xfa)
        ei
        ret
        endif

esp_wait_cts
        ld a,(esp_comType)
        if ESPNET_UART_ATM2
        cp 1
        ret z
        endif
        if ESPNET_UART_KOND
        cp 2
        ret z
        endif
        ld hl,0
esp_cts_lp
        if ESPNET_UART_ATM2
        ld a,(esp_comType)
        cp 3
        jr z,esp_cts3
         if ESPNET_UART_KOND=0
        jr esp_cts3
         endif
        endif
        if ESPNET_UART_KOND
        ld bc,(esp_MSR)
        in a,(c)
         if ESPNET_UART_ATM2
        jr esp_cts_chk
         endif
        endif
        if ESPNET_UART_ATM2
esp_cts3
        ld a,(esp_rMSR)
        call esp_in3
        endif
esp_cts_chk
        and 0x10
        ret nz
        inc hl
        ld a,l
        and 0x3f
        jr nz,esp_cts_lp
        ifdef ESPNET_KERNEL
        ld de,20001
        or a
        sbc hl,de
        ret nc
        add hl,de
        jr esp_cts_lp
        else
        push hl
        OS_GETKEY
        or a
        jr z,esp_cts_y
        cp 'q'
        jr z,esp_cts_q
        cp 'Q'
        jr z,esp_cts_q
esp_cts_y
        YIELD
        pop hl
        ld de,20001
        or a
        sbc hl,de
        ret nc
        add hl,de
        jr esp_cts_lp
esp_cts_q
        pop hl
        ld a,1
        ld (esp_qflag),a
        ret
        endif

; A=mode 0=off 1=on else pulse
esp_setrts
        ld (esp_rtsmode),a
        ld a,(esp_comType)
        if ESPNET_UART_KOND
        if ESPNET_UART_ATM2
        or a
        jr z,esp_rts0
        dec a
        jr z,esp_rts1
        dec a
        ret z
        else
        or a
        ret nz
        endif
        endif
        if ESPNET_UART_KOND=0
        dec a
        jr z,esp_rts1
        endif
        if ESPNET_UART_ATM2
esp_rts3
        ld a,(esp_rtsmode)
        cp 1
        jr z,esp_rts3on
        or a
        jr z,esp_rts3off
        di
        ld a,(esp_rMCR)
        out (0xfb),a
        ld a,2
        out (0xfa),a
        xor a
        out (0xfa),a
        ei
        ret
esp_rts3on
        di
        ld a,(esp_rMCR)
        out (0xfb),a
        ld a,2
        out (0xfa),a
        ei
        ret
esp_rts3off
        di
        ld a,(esp_rMCR)
        out (0xfb),a
        xor a
        out (0xfa),a
        ei
        ret
        endif
        if ESPNET_UART_KOND
esp_rts0
        ld a,(esp_rtsmode)
        cp 1
        ld bc,(esp_MCR)
        jr z,esp_rts0on
        or a
        jr z,esp_rts0off
        di
        ld a,2
        out (c),a
        xor a
        out (c),a
        ei
        ret
esp_rts0on
        ld a,2
        out (c),a
        ret
esp_rts0off
        xor a
        out (c),a
        ret
        endif
        if ESPNET_UART_ATM2
esp_rts1
        ld a,(esp_rtsmode)
        cp 1
        jr z,esp_rts1on
        or a
        jr z,esp_rts1off
        di
        ld e,0x03
        call esp_atm2_mcr
        ld e,0
        call esp_atm2_mcr
        ei
        ret
esp_rts1off
        di
        ld e,0
        call esp_atm2_mcr
        ei
        ret
esp_rts1on
        di
        ld e,0x03
        call esp_atm2_mcr
        ei
        ret
        endif

; A=divisor
esp_uart_init
        ld (esp_div),a
        ld a,(esp_comType)
        if ESPNET_UART_ATM2
        cp 1
        jr z,esp_ui1
         if ESPNET_UART_KOND
        cp 3
        jr z,esp_ui3
         else
        jr esp_ui3
         endif
        endif
        if ESPNET_UART_KOND
        ld bc,(esp_IIR)
        ld a,0x87
        out (c),a
        ld bc,(esp_LCR)
        ld a,0x83
        out (c),a
        ld bc,(esp_RBR)
        ld a,(esp_div)
        out (c),a
        ld bc,(esp_IER)
        xor a
        out (c),a
        ld bc,(esp_LCR)
        ld a,3
        out (c),a
        ld bc,(esp_IER)
        xor a
        out (c),a
        ld bc,(esp_MCR)
        ld a,0x2f
        out (c),a
        ret
        endif
        if ESPNET_UART_ATM2
esp_ui1
        di
        ld bc,0x55fe
        in a,(c)
        ld bc,0xc3fe
        in a,(c)
        ld a,(esp_div)
        ld b,a
        ld c,0xfe
        in a,(c)
        ld bc,0x55fe
        in a,(c)
        ld bc,0x43fe
        in a,(c)
        ; Keep DTR+RTS on: ESP32 CTS is 8952 RTS (GPIO15). Off => ESP never TXes.
        ld bc,0x03fe
        in a,(c)
        ei
        ret
esp_ui3
        ld e,0x87
        ld a,(esp_rIIR)
        call esp_out3
        ld e,0x83
        ld a,(esp_rLCR)
        call esp_out3
        ld a,(esp_div)
        ld e,a
        ld a,(esp_rRBR)
        call esp_out3
        ld e,0
        ld a,(esp_rIER)
        call esp_out3
        ld e,3
        ld a,(esp_rLCR)
        call esp_out3
        ld e,0
        ld a,(esp_rIER)
        call esp_out3
        ld e,0x22
        ld a,(esp_rMCR)
        call esp_out3
        xor a
        jp esp_setrts

esp_out3
        di
        out (0xfb),a
        ld a,e
        out (0xfa),a
        ei
        ret
        endif

; 1=byte in esp_rb, 0=empty (RTS pulse on 0/3)
esp_rx_poll
        ld a,(esp_comType)
        if ESPNET_UART_KOND
        if ESPNET_UART_ATM2
        or a
        jr z,esp_rp0
        dec a
        jr z,esp_rp1
        dec a
        jr z,esp_rp2
        else
        or a
        jr z,esp_rp0
        jr esp_rp2
        endif
        endif
        if ESPNET_UART_KOND=0
        dec a
        jr z,esp_rp1
        endif
        if ESPNET_UART_ATM2
esp_rp3
        ld a,(esp_rLSR)
        out (0xfb),a
        in a,(0xfa)
        rrca
        jr nc,esp_rp3empty
        ld a,(esp_rRBR)
        out (0xfb),a
        in a,(0xfa)
        ld (esp_rb),a
        ld a,1
        or a
        ret
esp_rp3empty
        di
        ld a,(esp_rMCR)
        out (0xfb),a
        ld a,2
        out (0xfa),a
        xor a
        out (0xfa),a
        ei
        xor a
        ret
        endif
        if ESPNET_UART_KOND
esp_rp0
        ld bc,(esp_LSR)
        in a,(c)
        rrca
        jr nc,esp_rp0empty
        ld bc,(esp_RBR)
        in a,(c)
        ld (esp_rb),a
        ld a,1
        or a
        ret
esp_rp0empty
        di
        ld bc,(esp_MCR)
        ld a,2
        out (c),a
        xor a
        out (c),a
        ei
        xor a
        ret
esp_rp2
        ld bc,(esp_LSR)
        in a,(c)
        rrca
        ret nc
        ld bc,(esp_RBR)
        in a,(c)
        ld (esp_rb),a
        ld a,1
        or a
        ret
        endif
        if ESPNET_UART_ATM2
; ATM2 COM: AT uartReadBlock. Pulse on empty, no hold-RTS.
esp_rp1
        di
        ld bc,0x55fe
        in a,(c)
        ld bc,0xc2fe
        in a,(c)
        or a
        jr z,esp_rp1e
        ld bc,0x55fe
        in a,(c)
        ld bc,0x02fe
        in a,(c)
        ei
        ld (esp_rb),a
        ld a,1
        or a
        ret
esp_rp1e
        ld bc,0x55fe
        in a,(c)
        ld bc,0x43fe
        in a,(c)
        ld bc,0x03fe
        in a,(c)
        ld bc,0x55fe
        in a,(c)
        ld bc,0x43fe
        in a,(c)
        ld bc,0x00fe
        in a,(c)
        ei
        xor a
        ret
; A=1 if comType==1 (ATM2 COM RX level), else 0.
esp_rts_rxlevel
        ld a,(esp_comType)
        dec a
        ld a,0
        ret nz
        inc a
        ret
        endif

; ============================================================
; Ports / ini
; ============================================================
esp_cfg_default
        ld hl,0xF8EF
        ld (esp_RBR),hl
        ld hl,0xF9EF
        ld (esp_IER),hl
        ld hl,0xFAEF
        ld (esp_IIR),hl
        ld hl,0xFBEF
        ld (esp_LCR),hl
        ld hl,0xFCEF
        ld (esp_MCR),hl
        ld hl,0xFDEF
        ld (esp_LSR),hl
        ld hl,0xFEEF
        ld (esp_MSR),hl
        ld hl,0xFFEF
        ld (esp_SR),hl
        ld a,1
        ld (esp_div),a
        ; Kernel ATM2: ATM2 COM (type 1). Evo/userland: Kondratyev (0).
        ; espcfg OS_SETUART overrides this after -S.
        ifdef ESPNET_KERNEL
        if atm==2 or atm==3
        ld a,1
        else
        xor a
        endif
        else
        xor a
        endif
        ld (esp_comType),a
        ld a,32
        ld (esp_espType),a
        ld a,40
        ld (esp_espRetry),a
        ld hl,ESPNET_SOF_TICKS
        ld (esp_sof_ticks),hl
        ret

        if ESPNET_UART_ATM2
esp_ports_ready
        ld hl,(esp_RBR)
        call esp_reg8
        ld (esp_rRBR),a
        ld hl,(esp_IER)
        call esp_reg8
        ld (esp_rIER),a
        ld hl,(esp_IIR)
        call esp_reg8
        ld (esp_rIIR),a
        ld hl,(esp_LCR)
        call esp_reg8
        ld (esp_rLCR),a
        ld hl,(esp_MCR)
        call esp_reg8
        ld (esp_rMCR),a
        ld hl,(esp_LSR)
        call esp_reg8
        ld (esp_rLSR),a
        ld hl,(esp_MSR)
        call esp_reg8
        ld (esp_rMSR),a
        ret

; HL=16-bit ini port -> A=16550 index for ATM2IOESP
esp_reg8
        ld a,h
        cp 0xf8
        jr c,esp_reg8lo
        sub 0xf8
        ret
esp_reg8lo
        ld a,l
        ret
        endif

        ifndef ESPNET_KERNEL
esp_load_ini
        ld de,esp_path
        OS_GETPATH
        OS_SETSYSDRV
        ld de,esp_ini_dir
        OS_CHDIR
        ld de,esp_ini_name
        OS_OPENHANDLE
        or a
        jr z,esp_ini_rd
        ld de,esp_path
        OS_CHDIR
        ld de,esp_ini_name
        OS_OPENHANDLE
        or a
        ret nz
esp_ini_rd
        ld a,b
        ld (esp_fh),a
        ld de,esp_inbuf
        ld hl,ESP_INIBUF
        OS_READHANDLE
        ld (esp_inlen),hl
        ld a,(esp_fh)
        ld b,a
        OS_CLOSEHANDLE
        ld de,esp_path
        OS_CHDIR
        ld hl,esp_inbuf
        ld bc,(esp_inlen)
esp_ini_lp
        ld a,b
        or c
        ret z
        ld a,(hl)
        cp 13
        jr z,esp_ini_nl
        cp 10
        jr z,esp_ini_nl
        cp ';'
        jr z,esp_ini_skip
        cp ' '
        jr z,esp_ini_sp
        cp 9
        jr z,esp_ini_sp
        push bc
        push hl
        call esp_ini_key
        pop hl
        pop bc
esp_ini_skip
        call esp_eol
        jr esp_ini_lp
esp_ini_nl
esp_ini_sp
        inc hl
        dec bc
        jr esp_ini_lp

esp_eol
        ld a,b
        or c
        ret z
        ld a,(hl)
        inc hl
        dec bc
        cp 10
        ret z
        cp 13
        jr nz,esp_eol
        ld a,b
        or c
        ret z
        ld a,(hl)
        cp 10
        ret nz
        inc hl
        dec bc
        ret

esp_ini_key
        ld de,esp_ktab
esp_ik_lp
        push hl
        ld a,(de)
        inc de
        ld c,a
        ld a,(de)
        inc de
        ld b,a
        or c
        jr nz,esp_ik_try
        pop hl
        ret
esp_ik_try
        push de
        ld d,b
        ld e,c
        call esp_streq
        pop de
        jr z,esp_ik_got
        inc de
        inc de
        pop hl
        jr esp_ik_lp
esp_ik_got
        ld a,(de)
        inc de
        ld c,a
        ld a,(de)
        ld b,a
        pop hl
        ; HL at key start, skip to '='
esp_ik_eq
        ld a,(hl)
        or a
        ret z
        cp 13
        ret z
        cp 10
        ret z
        inc hl
        cp '='
        jr nz,esp_ik_eq
esp_ik_sp2
        ld a,(hl)
        cp ' '
        jr z,esp_ik_sk
        cp 9
        jr nz,esp_ik_num
esp_ik_sk
        inc hl
        jr esp_ik_sp2
esp_ik_num
        call esp_parsenum
        ld a,l
        ld (bc),a
        inc bc
        ld a,h
        ld (bc),a
        ret

; DE=asciiz key, HL=text  Z=match, HL after key
esp_streq
esp_sq
        ld a,(de)
        or a
        ret z
        cp (hl)
        ret nz
        inc de
        inc hl
        jr esp_sq

esp_parsenum
        ld a,(hl)
        cp '0'
        jr nz,esp_dec
        inc hl
        ld a,(hl)
        or 0x20
        cp 'x'
        jr z,esp_hex
        dec hl
esp_dec
        ld de,0
esp_dec_lp
        ld a,(hl)
        sub '0'
        cp 10
        jr nc,esp_num_done
        inc hl
        push hl
        ld h,d
        ld l,e
        add hl,hl
        add hl,hl
        add hl,de
        add hl,hl
        ld e,a
        ld d,0
        add hl,de
        ex de,hl
        pop hl
        jr esp_dec_lp
esp_hex
        inc hl
        ld de,0
esp_hex_lp
        ld a,(hl)
        sub '0'
        cp 10
        jr c,esp_hex_d
        or 0x20
        sub 'a'-'0'
        cp 6
        jr nc,esp_num_done
        add a,10
esp_hex_d
        inc hl
        push hl
        ex de,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        ld e,a
        ld d,0
        add hl,de
        ex de,hl
        pop hl
        jr esp_hex_lp
esp_num_done
        ex de,hl
        ret

; BC=ticks (~20ms)
esp_wait_ticks
        OS_GETTIMER
        add hl,bc
        ld (esp_deadline),hl
esp_wt_lp
        YIELD
        OS_GETTIMER
        ld de,(esp_deadline)
        ex de,hl
        or a
        sbc hl,de
        jr nc,esp_wt_lp
        ret

esp_ini_dir
        db "../ini",0
esp_ini_name
        db "espcom.ini",0
esp_ktab
        dw esp_k_rbr
        dw esp_RBR
        dw esp_k_ier
        dw esp_IER
        dw esp_k_iir
        dw esp_IIR
        dw esp_k_lcr
        dw esp_LCR
        dw esp_k_mcr
        dw esp_MCR
        dw esp_k_lsr
        dw esp_LSR
        dw esp_k_msr
        dw esp_MSR
        dw esp_k_sr
        dw esp_SR
        dw esp_k_div
        dw esp_divw
        dw esp_k_ct
        dw esp_comTypew
        dw esp_k_et
        dw esp_espTypew
        dw esp_k_er
        dw esp_espRetryw
        dw 0
esp_k_rbr db "RBR_THR",0
esp_k_ier db "IER",0
esp_k_iir db "IIR_FCR",0
esp_k_lcr db "LCR",0
esp_k_mcr db "MCR",0
esp_k_lsr db "LSR",0
esp_k_msr db "MSR",0
esp_k_sr  db "SR",0
esp_k_div db "divider",0
esp_k_ct  db "comType",0
esp_k_et  db "espType",0
esp_k_er  db "espRetry",0

; ============================================================
; BSS
; Kernel copy (same names, no ini buffers): kernel/espnet_bss.asm
; ============================================================
ESP_INIBUF EQU 384

; 16550 port addresses from ini (type 0/2: full 16-bit; type 3: high byte)
esp_RBR         dw 0            ; RBR/THR data port
esp_IER         dw 0
esp_IIR         dw 0
esp_LCR         dw 0
esp_MCR         dw 0            ; RTS lives here (type 0)
esp_LSR         dw 0            ; bit0=DR, bit5=THRE
esp_MSR         dw 0            ; bit4=CTS
esp_SR          dw 0
esp_divw        dw 0            ; baud divider (uart_init)
esp_comTypew    dw 0            ; 0 Kondr, 1 ATM2 COM, 2 AFC, 3 ATM2IOESP
esp_espTypew    dw 0            ; unused by this driver (ini leftover)
esp_espRetryw   dw 0            ; unused by this driver (ini leftover)
esp_div         equ esp_divw
esp_comType     equ esp_comTypew
esp_espType     equ esp_espTypew
esp_espRetry    equ esp_espRetryw

; Type 3: 16550 register index 0..7 (out FB, in/out FA)
esp_rRBR        db 0
esp_rIER        db 0
esp_rIIR        db 0
esp_rLCR        db 0
esp_rMCR        db 0
esp_rLSR        db 0
esp_rMSR        db 0

; Timeouts (kernel: spin loops; userland: timer + YIELD)
esp_factor      dw 0            ; empty-UART spin (also copied to esp_spin)
esp_spin        dw 0            ; per-byte wait in fill0..3 / CTS inner
esp_sof_ticks   dw 0            ; SOF wait budget (short vs LONG for INFO/DNS)
esp_deadline    dw 0            ; SOF: remaining spins (kernel) or timer (user)
esp_last_y      dw 0            ; userland: last timer for YIELD in SOF wait

; RX framing
esp_inlen       dw 0            ; bytes already in esp_inbuf (userland ini)
esp_plen        dw 0            ; payload LEN from last 8-byte RSP header
esp_n           dw 0            ; fill: how many UART bytes still to read
esp_dst         dw 0            ; fill: destination pointer (DE into fill)
esp_left        dw 0            ; skip/drain: payload bytes still to discard
esp_chunk       dw 0            ; write/skip: this piece size (clipped)
esp_chunk_got   dw 0            ; write: bytes this UART piece actually sent
esp_sent        dw 0            ; write: total payload bytes sent so far

; Current OS_READ/WRITE (rs = readstructure)
esp_rs_dst      dw 0            ; user buffer ptr
esp_rs_src      dw 0            ; write: source ptr (userland copy path)
esp_rs_want     dw 0            ; requested size (clipped to host_max)
esp_rs_n        dw 0            ; result count from RSP RESULT field
esp_udp_sa      dw 0            ; ptr to 15-byte sockaddr for UDP
esp_p2          dw 0            ; xfer payload #1 ptr (or UDP sockaddr)
esp_n2          dw 0            ; xfer payload #1 length
esp_p3          dw 0            ; xfer payload #2 ptr (UDP data after sa)
esp_n3          dw 0            ; xfer payload #2 length

esp_req         ds ESPNET_REQ_HDR              ; 6-byte CMD header TX
esp_rsp         ds ESPNET_RSP_HDR+ESPNET_RSP_MAX ; RSP header + body
esp_wifi_pay    ds ESPNET_WIFI_CONN_SIZE       ; WIFI_CONNECT ssid+pass
esp_path        ds 128          ; userland: GETPATH / ini path
esp_inbuf       ds ESP_INIBUF   ; userland: espcom.ini load buffer
esp_proto       ds 8            ; per-sock proto (STREAM/DGRAM), index=id

esp_seq         db 0            ; request sequence (match RSP)
esp_inited      db 0            ; uart programmed, SOF path live
esp_armed       db 0            ; 1 = CMD_READ already on the wire
esp_qflag       db 0            ; userland: Q pressed during wait
esp_txb         db 0            ; byte staged for esp_putb (A clobbered)
esp_rb          db 0            ; last polled RX byte (SOF / rx_poll)
esp_idle        db 0            ; SOF: idle poll counter (YIELD wrap)
esp_silent      db 0            ; drain: consecutive empty polls
esp_rtsmode     db 0            ; arg to esp_setrts (0/1/pulse)
esp_xcmd        db 0            ; xfer: CMD
esp_xsock       db 0            ; xfer: sock id (or 0xFF)
esp_xarg        db 0            ; xfer: ARG byte
esp_arg         db 0            ; SOCKET: proto saved for esp_proto[]
esp_pay1        db 0            ; SOCKET: family byte on the wire
esp_pay2        ds 2            ; READ: le16 maxlen in CMD payload
esp_rs_sock     db 0            ; current sock for READ/WRITE
esp_fh          db 0            ; userland: ini file handle
esp_errno       db 0            ; last errno (A on fail)
        endif
