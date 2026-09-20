; ESPNET BSS in pgsys (always at 0000 during BDOS). Code lives on pgtrdosfs.
; Names match _sdk/espnet.asm. Kernel has no ini path/inbuf/wifi_pay.

; 16550 port addresses (SETUART). Type 3 uses *index* copies below.
esp_RBR         dw 0            ; RBR/THR data port
esp_IER         dw 0
esp_IIR         dw 0
esp_LCR         dw 0
esp_MCR         dw 0            ; RTS (type 0)
esp_LSR         dw 0            ; bit0=DR, bit5=THRE
esp_MSR         dw 0            ; bit4=CTS
esp_SR          dw 0
esp_divw        dw 0            ; baud divider
esp_comTypew    dw 0            ; 0 Kondr, 1 ATM2 COM, 2 AFC, 3 ATM2IOESP
esp_espTypew    dw 0
esp_espRetryw   dw 0
esp_div         equ esp_divw
esp_comType     equ esp_comTypew
esp_espType     equ esp_espTypew
esp_espRetry    equ esp_espRetryw

; Type 3: 16550 index 0..7 (out FB, in/out FA)
esp_rRBR        db 0
esp_rIER        db 0
esp_rIIR        db 0
esp_rLCR        db 0
esp_rMCR        db 0
esp_rLSR        db 0
esp_rMSR        db 0

esp_factor      dw 0            ; empty-UART spin (copied to esp_spin)
esp_spin        dw 0            ; per-byte wait in fill0..3
esp_sof_ticks   dw 0            ; SOF wait budget (short / LONG)
esp_deadline    dw 0            ; SOF remaining spins
esp_last_y      dw 0            ; unused in kernel (userland YIELD timer)
esp_inlen       dw 0            ; unused in kernel (userland ini)
esp_plen        dw 0            ; payload LEN from last RSP header
esp_n           dw 0            ; fill: UART bytes still to read this call
esp_dst         dw 0            ; fill: dest pointer
esp_left        dw 0            ; skip/drain: payload left to discard
esp_chunk       dw 0            ; this UART piece size
esp_chunk_got   dw 0            ; bytes this piece actually moved
esp_sent        dw 0            ; write: total sent so far
esp_rs_dst      dw 0            ; user buffer
esp_rs_src      dw 0            ; write source (rarely kernel)
esp_rs_want     dw 0            ; requested size
esp_rs_n        dw 0            ; RSP RESULT count
esp_udp_sa      dw 0            ; ptr to 15-byte sockaddr
esp_p2          dw 0            ; xfer payload #1 ptr
esp_n2          dw 0            ; xfer payload #1 length
esp_p3          dw 0            ; xfer payload #2 ptr
esp_n3          dw 0            ; xfer payload #2 length

esp_req         ds ESPNET_REQ_HDR
esp_rsp         ds ESPNET_RSP_HDR+ESPNET_RSP_MAX
esp_proto       ds 8            ; per-sock STREAM/DGRAM, index=sock id

esp_seq         db 0            ; CMD sequence
esp_inited      db 0            ; UART+SOF ready
esp_armed       db 0            ; kernel: always 0 (no READ pipeline)
esp_qflag       db 0            ; unused in kernel
esp_txb         db 0            ; byte for esp_putb
esp_rb          db 0            ; last rx_poll byte
esp_idle        db 0            ; SOF idle polls
esp_silent      db 0            ; drain empty polls
esp_rtsmode     db 0            ; esp_setrts arg
esp_xcmd        db 0            ; xfer CMD
esp_xsock       db 0            ; xfer sock
esp_xarg        db 0            ; xfer ARG
esp_arg         db 0            ; SOCKET proto
esp_pay1        db 0            ; SOCKET family
esp_pay2        ds 2            ; READ maxlen le16
esp_rs_sock     db 0            ; current READ/WRITE sock
esp_fh          db 0            ; unused in kernel
esp_errno       db 0            ; last fail A
esp_wr_try      db 0            ; WRITE EAGAIN retries in one syscall
espk_sa         ds 15           ; kernel copy of sockaddr (paged user)
espk_sa_user    dw 0            ; user sockaddr ptr
espk_buf_user   dw 0            ; user payload ptr (UDP IX)
esp_host_max    dw 0            ; pktMax from SETUART (0 -> 192)
esp_busy        db 0            ; UART lock (0 free; else this BDOS call, EAGAIN 35)
esp_wifi_pay    ds ESPNET_WIFI_CONN_SIZE
