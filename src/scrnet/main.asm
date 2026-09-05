        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

; HTTP remote screen. No SETGFX, does not take the CRT.
; Listen stays open. Port 2324.
; /ini/network.ini currentNetwork: 0=WIZNET, 2=ESPNET; else print and QUIT.
; GET /           -> /bin/scrnet/index.htm
; GET /stream     -> chunked binary frames
;   text 80x25: type1 key 4000 / type2 XOR-RLE
;   6912:       type4 key 6912 / type5 XOR-RLE (skip unchanged)
;   palette:    type6 32-byte DDp (focus OS_GETPAL), on change / connect
;   EGA 320x200: WIZNET raw 32K type12 / ESPNET PackBits type7
;   MC  640x200: WIZNET raw 32K type13 / ESPNET PackBits type9
;   EGA/MC: snapshot 32K under one DI; TX yield when 50Hz tick moves, not per MTU.
; GET  /k/ccff  -> key (cc=code, ff=0 letter / 1 control) into OS_PUTKEY
; POST /input   -> 2-byte body, same (if headers+body fit the read)
; Browser: http://<ip>:2324/
; fps.ini next to the web files: text=/scr=/ega= (1-50). MC uses ega.

PORT=2324
STACK=0x3FFE
NOSOCK EQU 0xff
COLS=80
ROWS=25
TXTSZ=COLS*ROWS
PLANESZ=TXTSZ*2
SCRSZ=6912
REQSZ=128
IOSZ=SCRSZ+80
NETIN_SZ=64
; Max FPS per mode (50 Hz timer). Overridden by /bin/scrnet/fps.ini
FPS_TEXT EQU 7
FPS_SCR  EQU 4
FPS_EGA  EQU 2
FPSSZ EQU 96

curbuf  EQU 0x4000
prevbuf EQU curbuf+SCRSZ
xorbuf  EQU 0x8000
iobuf   EQU xorbuf+SCRSZ

SOCK_STREAM EQU 0x01
AF_INET EQU 2
ERR_EAGAIN EQU 35
ERR_EMSGSIZE EQU 40

FR_KEY EQU 1
FR_XOR EQU 2
FR_GFX EQU 3
FR_SCR EQU 4
FR_SCRXOR EQU 5
FR_PAL EQU 6
FR_EGA EQU 7
FR_EGAXOR EQU 8
FR_MC EQU 9
FR_MCXOR EQU 10
FR_PROF EQU 11
FR_EGARAW EQU 12
FR_MCRAW EQU 13
; 1: skip ival/pace, emit type11 ticks to the browser HUD.
SCRNET_PROF EQU 1
; Text: WIZNET=raw 4000-byte FR_KEY; ESPNET=XOR-RLE (UART ~10 KB/s max).
PALSZ EQU 32
EGASZ EQU 32768
EGAPREV EQU 0x4000
; Real Wiznet TX ~MTU; emulator accepts any size. Keep <=1500.
SENDMAX EQU 1500
RLEBUFSZ EQU SENDMAX

        org PROGSTART
begin
        ld sp,STACK
        OS_SETSYSDRV

        OS_GETMAINPAGES
        ld e,l
        OS_DELPAGE

        ld a,NOSOCK
        ld (soc),a
        ld (soc_client),a
        ld (soc_post),a
        xor a
        ld (is_stream),a
        call load_net
        jr nc,net_ok
        QUIT
net_ok
        call set_poll
        call load_fps
        call listen_now
        jr nc,hideme
        ld hl,t_lisnfail
        call prstr
        QUIT
hideme
        OS_HIDEFROMPARENT
        jp mainloop

gotostart
        ld sp,STACK
        call close_client
        ld a,(soc)
        inc a
        jr z,nul_soc
        ld a,(soc)
        ld e,0
        call net_shutdown
        ld a,NOSOCK
        ld (soc),a
nul_soc
        call listen_now
        jr nc,mainloop
        YIELD
        jp gotostart

mainloop
        YIELD
        ld a,(soc_client)
        inc a
        jr nz,have_cli
        call try_accept
        jr mainloop

have_cli
        ld a,(is_stream)
        or a
        jr nz,do_stream
        call http_serve
        jr mainloop

do_stream
        call try_input
        call stream_rx
        ld a,(soc_client)
        inc a
        jr z,mainloop
        OS_GETTIMER
        ld a,l
        ld (nowtick),a
        if SCRNET_PROF
        jr do_sf
        endif
        ld a,(force)
        or a
        jr nz,do_sf
        ld a,(nowtick)
        ld hl,lastsend
        sub (hl)
        ld hl,ival_poll
        cp (hl)
        jr c,do_stream_end
do_sf
        call stream_frame
do_stream_end
        call try_input
        jr mainloop

; ---- sockets ----

try_accept
        ld a,(soc)
        call net_accept
        bit 7,l
        jr z,got_cli
        cp ERR_EAGAIN
        ret z
        pop hl
        jp gotostart
got_cli
        ld a,l
        ld (soc_client),a
        xor a
        ld (is_stream),a
        ld (hdr_st),a
        ld (line_done),a
        ld hl,0
        ld (req_len),hl
        ret

close_client
        ld a,(soc_post)
        inc a
        jr z,cc_cli
        ld a,(soc_post)
        ld e,0
        call net_shutdown
        ld a,NOSOCK
        ld (soc_post),a
cc_cli
        ld a,(soc_client)
        inc a
        ret z
        ld a,(soc_client)
        ld e,0
        call net_shutdown
        ld a,NOSOCK
        ld (soc_client),a
        xor a
        ld (is_stream),a
        ld (hdr_st),a
        ld (line_done),a
        ld hl,0
        ld (req_len),hl
        ret

; Second TCP client while /stream is up. GET /k/ccff or /f/t/s/e.
; One shot + close (keep-alive desynced the browser and ate Wiznet sockets).
; If ACCEPT wins before the GET arrives, keep soc_post and retry next loop.
try_input
        ld a,(soc_post)
        inc a
        jr nz,ti_read
        ld a,(soc)
        call net_accept
        bit 7,l
        ret nz
        ld a,l
        ld (soc_post),a
        xor a
        ld (ti_age),a
ti_read
        ld a,(soc_post)
        ld de,rlebuf
        ld hl,256
        call net_read
        bit 7,h
        jr z,ti_got
        cp ERR_EAGAIN
        jr nz,ti_drop
        ld a,(ti_age)
        inc a
        ld (ti_age),a
        cp 25
        ret c
        jr ti_drop
ti_got
        ld a,h
        or l
        jr z,ti_drop
        call parse_key_req
        ld a,(soc_client)
        ld (soc_saved),a
        ld a,(soc_post)
        ld (soc_client),a
        ld de,hdr_204
        call send_str
        ld a,(soc_saved)
        ld (soc_client),a
        ld a,1
        ld (is_stream),a
        jr ti_drop
ti_drop
        ld a,(soc_post)
        inc a
        ret z
        ld a,(soc_post)
        ld e,0
        call net_shutdown
        ld a,NOSOCK
        ld (soc_post),a
        xor a
        ld (ti_age),a
        ret

; rlebuf = first TCP payload. Prefer GET /k/ccff in the request line.
parse_key_req
        ld hl,rlebuf
        ld b,80
pkr_lp
        ld a,(hl)
        cp '/'
        jr nz,pkr_n
        push hl
        call is_kpath
        pop hl
        jr nc,pkr_key
        push hl
        call is_fpath
        pop hl
        ret nc
pkr_n
        inc hl
        djnz pkr_lp
        ld a,(rlebuf)
        cp 'P'
        ret nz
        ld hl,rlebuf
        ld b,252
ppb_lp
        ld a,(hl)
        cp 13
        jr nz,ppb_n
        inc hl
        ld a,(hl)
        cp 10
        jr nz,ppb_n
        inc hl
        ld a,(hl)
        cp 13
        jr nz,ppb_n
        inc hl
        ld a,(hl)
        cp 10
        jr nz,ppb_n
        inc hl
        ld e,(hl)
        inc hl
        ld d,(hl)
        jp put_one_key
ppb_n
        inc hl
        djnz ppb_lp
        ret
pkr_key
        jp put_one_key

; HL="/k/ccff...". NC: DE=key. CY: not that path.
is_kpath
        ld a,(hl)
        cp '/'
        scf
        ret nz
        inc hl
        ld a,(hl)
        cp 'k'
        scf
        ret nz
        inc hl
        ld a,(hl)
        cp '/'
        scf
        ret nz
        inc hl
parse4hex
        call hexnib
        ret c
        add a,a
        add a,a
        add a,a
        add a,a
        ld e,a
        call hexnib
        ret c
        or e
        ld e,a
        call hexnib
        ret c
        add a,a
        add a,a
        add a,a
        add a,a
        ld d,a
        call hexnib
        ret c
        or d
        ld d,a
        or a
        ret

; HL="/f/t/s/e" decimal fps 1-50. NC: applied. CY: not that path.
is_fpath
        ld a,(hl)
        cp '/'
        scf
        ret nz
        inc hl
        ld a,(hl)
        cp 'f'
        scf
        ret nz
        inc hl
        ld a,(hl)
        cp '/'
        scf
        ret nz
        inc hl
        call pf_num
        ret c
        call fps_to_ival
        ld (ival_text),a
        ld a,(hl)
        cp '/'
        scf
        ret nz
        inc hl
        call pf_num
        ret c
        call fps_to_ival
        ld (ival_scr),a
        ld a,(hl)
        cp '/'
        scf
        ret nz
        inc hl
        call pf_num
        ret c
        call fps_to_ival
        ld (ival_ega),a
        call set_poll
        xor a
        ret
hexnib
        ld a,(hl)
        inc hl
        cp '0'
        ret c
        cp '9'+1
        jr c,hn_d
        or 0x20
        cp 'a'
        ret c
        cp 'f'+1
        ccf
        ret c
        sub 'a'-10
        or a
        ret
hn_d
        sub '0'
        or a
        ret

; DE=buf HL=size. CY if client died (already closed)
; W5300 TX is 8K; a 6912 write fails with EMSGSIZE whenever FSR < 6912.
; Cap each write at SENDMAX (~Ethernet MTU). Real card will not take more
; than one frame per call; emulator accepts any size. Do not use DE for
; the cap ? it is the buffer pointer. SENDMAX need not be a multiple of 256.
; send_data_yield: same, but YIELDKEEP when the 50Hz timer moves (EGA/MC 32K).
; One YIELDKEEP per MTU was 21 ticks/frame and capped the NIC at ~60 KB/s.
; Text/6912 stay on send_data so radio/nc keep their fps.
send_data
        xor a
        ld (sd_yield),a
send_data_go
        ld a,h
        or l
        ret z
send_data0
        push de
        push hl
        ld a,h
        cp SENDMAX/256
        jr c,sd_now
        jr nz,sd_cap
        ld a,l
        cp (SENDMAX&255)+1
        jr c,sd_now
sd_cap
        ld hl,SENDMAX
sd_now
        ld a,(soc_client)
        call net_write
        bit 7,h
        jr z,sd_wrote
        pop hl
        pop de
        cp ERR_EMSGSIZE
        jr nz,sd_dead
        push de
        push hl
        YIELD
        pop hl
        pop de
        jr send_data0
sd_wrote
        pop bc
        pop de
        push hl
        add hl,de
        ex de,hl
        pop hl
        ld a,c
        sub l
        ld c,a
        ld a,b
        sbc a,h
        ld b,a
        ld h,b
        ld l,c
        ld a,h
        or l
        ret z
        ld a,(sd_yield)
        or a
        jr z,send_data0
        push de
        push hl
        OS_GETTIMER
        ld a,l
        ld hl,sd_tick
        cp (hl)
        jr z,sd_same
        ld (hl),a
        YIELDKEEP
        call try_input
sd_same
        pop hl
        pop de
        jr send_data0
sd_dead
        call close_client
        scf
        ret

send_data_yield
        ld a,1
        ld (sd_yield),a
        push de
        push hl
        OS_GETTIMER
        ld a,l
        ld (sd_tick),a
        pop hl
        pop de
        jr send_data_go

send_str
        push de
        ld hl,0
ss_len
        ld a,(de)
        or a
        jr z,ss_go
        inc de
        inc hl
        jr ss_len
ss_go
        pop de
        jp send_data

; DE=payload HL=size (HTTP chunk)
send_chunk
        ld a,h
        or l
        ret z
        push de
        push hl
        ld de,chead
        call hex4
        ld a,13
        ld (de),a
        inc de
        ld a,10
        ld (de),a
        ld de,chead
        ld hl,6
        call send_data
        pop hl
        pop de
        ret c
        call send_data
        ret c
        ld de,crlf
        ld hl,2
        jp send_data

; ---- HTTP ----
; Keep only the request line. Scan \r\n\r\n so browser headers can be huge.

http_serve
        ld a,(soc_client)
        ld de,iobuf
        ld hl,512
        call net_read
        bit 7,h
        jr z,hr_got
        cp ERR_EAGAIN
        ret z
        jp close_client
hr_got
        ld a,h
        or l
        jp z,close_client
        ld b,h
        ld c,l
        ld hl,iobuf
hr_lp
        ld a,(hl)
        inc hl
        push hl
        push bc
        call hdr_byte
        pop bc
        pop hl
        jr nc,hr_next
        ld a,(hdr_st)
        cp 4
        jr nz,hr_bad
        dec bc
        ld (body_ptr),hl
        ld (body_left),bc
        jp dispatch
hr_bad
        jp send_400
hr_next
        dec bc
        ld a,b
        or c
        jr nz,hr_lp
        ret

; A=byte. CY+hdr_st=4 complete; CY+hdr_st!=4 bad first line.
hdr_byte
        ld (hdr_ch),a
        ld a,(line_done)
        or a
        jr nz,hdr_fsm
        ld a,(hdr_ch)
        cp 13
        jr z,hdr_fsm
        cp 10
        jr z,hdr_fsm
        ld a,(req_len)
        cp REQSZ-1
        jr nc,hdr_too
        ld e,a
        ld d,0
        ld hl,reqbuf
        add hl,de
        ld a,(hdr_ch)
        ld (hl),a
        inc e
        ld a,e
        ld (req_len),a
hdr_fsm
        ld a,(hdr_ch)
        cp 13
        jr z,hdr_cr
        cp 10
        jr z,hdr_lf
        xor a
        ld (hdr_st),a
        ret
hdr_cr
        ld a,(hdr_st)
        cp 2
        ld a,3
        jr z,hdr_set
        ld a,1
hdr_set
        ld (hdr_st),a
        xor a
        ret
hdr_lf
        ld a,(hdr_st)
        cp 1
        jr z,hdr_crlf
        cp 3
        jr z,hb_fin
        xor a
        ld (hdr_st),a
        ret
hdr_crlf
        ld a,2
        ld (hdr_st),a
        ld a,1
        ld (line_done),a
        ld a,(req_len)
        ld e,a
        ld d,0
        ld hl,reqbuf
        add hl,de
        xor a
        ld (hl),a
        ret
hb_fin
        ld a,4
        ld (hdr_st),a
        scf
        ret
hdr_too
        ld a,0xff
        ld (hdr_st),a
        scf
        ret

dispatch
        ld hl,reqbuf
        ld a,(hl)
        cp 'P'
        jp z,ds_post
        cp 'G'
        jp nz,send_404
        ld b,16
ds_sl
        ld a,(hl)
        cp '/'
        jr z,ds_path
        inc hl
        djnz ds_sl
        jp send_404
ds_path
        ld de,pathbuf
        ld b,30
ds_cp
        ld a,(hl)
        or a
        jr z,ds_z
        cp ' '
        jr z,ds_z
        cp '?'
        jr z,ds_z
        cp 13
        jr z,ds_z
        ld (de),a
        inc hl
        inc de
        djnz ds_cp
ds_z
        xor a
        ld (de),a

        ld hl,pathbuf
        call is_kpath
        jp nc,do_kpath
        ld hl,pathbuf
        call is_fpath
        jp nc,do_fpath
        ld hl,pathbuf
        ld de,p_stream
        call strcmp
        jp z,start_stream
        ld hl,pathbuf
        ld de,p_stream2
        call strcmp
        jp z,start_stream

        ld hl,pathbuf
        ld de,p_root
        call strcmp
        jp z,do_index
        ld hl,pathbuf
        ld de,p_index
        call strcmp
        jp z,do_index
        ld hl,pathbuf
        ld de,p_app
        call strcmp
        jp z,do_app
        ld hl,pathbuf
        ld de,p_atm
        call strcmp
        jp z,do_atm
        ld hl,pathbuf
        ld de,p_866
        call strcmp
        jp z,do_866
        jp send_404

ds_post
        ld b,16
dsp_sl
        ld a,(hl)
        cp '/'
        jr z,dsp_path
        inc hl
        djnz dsp_sl
        jp send_404
dsp_path
        ld de,pathbuf
        ld b,30
dsp_cp
        ld a,(hl)
        or a
        jr z,dsp_z
        cp ' '
        jr z,dsp_z
        cp '?'
        jr z,dsp_z
        cp 13
        jr z,dsp_z
        ld (de),a
        inc hl
        inc de
        djnz dsp_cp
dsp_z
        xor a
        ld (de),a
        ld hl,pathbuf
        ld de,p_input
        call strcmp
        jp nz,send_404
        call input_from_body
        ld de,hdr_204
        call send_str
        jp close_client

; Body at body_ptr/body_left: pairs (code, flags).
input_from_body
        ld hl,(body_left)
        ld a,h
        or l
        ret z
        ld de,(body_ptr)
inb_lp
        ld a,(de)
        ld c,a
        inc de
        dec hl
        ld a,h
        or l
        ld b,0
        jr z,inb_one
        ld a,(de)
        ld b,a
        inc de
        dec hl
inb_one
        push de
        push hl
        ld e,c
        ld d,b
        call put_one_key
        pop hl
        pop de
        ld a,h
        or l
        jr nz,inb_lp
        ret

do_kpath
        call put_one_key
        ld de,hdr_204
        call send_str
        jp close_client

do_fpath
        ld de,hdr_204
        call send_str
        jp close_client

put_one_key
        OS_PUTKEY
        ret

do_index
        ld de,n_index
        ld hl,ct_htm
        jp send_named
do_app
        ld de,n_app
        ld hl,ct_js
        jp send_named
do_atm
        ld de,n_atm
        ld hl,ct_bin
        jp send_named
do_866
        ld de,n_866
        ld hl,ct_bin
        jp send_named

; DE=leaf HL=content-type
send_named
        ld (ctype_ptr),hl
        call make_fname
        call send_file
        ret

make_fname
        ld hl,fname
        ld bc,path_pref
mf1
        ld a,(bc)
        ld (hl),a
        inc bc
        inc hl
        or a
        jr nz,mf1
        dec hl
mf2
        ld a,(de)
        ld (hl),a
        inc de
        inc hl
        or a
        jr nz,mf2
        ret

send_file
        ld de,fname
        OS_OPENHANDLE
        or a
        jp nz,send_404
        ld a,b
        ld (fhan),a
        ld b,a
        OS_GETFILESIZE
        ld (fsize),hl
        call sf_body
        ld a,(fhan)
        ld b,a
        OS_CLOSEHANDLE
        jp close_client

sf_body
        ld de,hdr_ok
        call send_str
        ret c
        ld de,(ctype_ptr)
        call send_str
        ret c
        ld de,hdr_clen
        call send_str
        ret c
        ld hl,(fsize)
        ld de,itoa_buf
        xor a
        ld (itoa_on),a
        call itoa16
        xor a
        ld (de),a
        ld de,itoa_buf
        call send_str
        ret c
        ld de,hdr_end
        call send_str
        ret c
sf_rd
        ld a,(fhan)
        ld b,a
        ld de,iobuf
        ld hl,512
        OS_READHANDLE
        or a
        ret nz
        ld a,h
        or l
        ret z
        ld de,iobuf
        call send_data
        ret c
        jr sf_rd

send_404
        ld de,hdr_404
        call send_str
        jp close_client

send_400
        ld de,hdr_400
        call send_str
        jp close_client

start_stream
        ld de,hdr_stream
        call send_str
        ret c
        ld a,1
        ld (is_stream),a
        ld (force),a
        ld a,0xff
        ld (last_mode),a
        ld (last_id),a
        ld (last_scr),a
        xor a
        ld (lastsend),a
        call load_fps
        jp stream_frame

stream_rx
        ld a,(soc_client)
        ld de,netin
        ld hl,NETIN_SZ
        call net_read
        bit 7,h
        jr z,srx_ok
        cp ERR_EAGAIN
        ret z
        jp close_client
srx_ok
        ld a,h
        or l
        jp z,close_client
        ret

; A = gfxmode&7 -> A = ticks between frames for that mode
ival_for_mode
        ld a,(g_gfxmode)
        and 7
        jr z,im_ega
        cp 2
        jr z,im_ega
        cp 3
        jr z,im_scr
        ld a,(ival_text)
        ret
im_ega
        ld a,(ival_ega)
        ret
im_scr
        ld a,(ival_scr)
        ret

; CY = too soon, NC = capture/send now
pace_ready
        ld a,(force)
        or a
        jr nz,pr_go
        ld a,(g_gfxmode)
        and 7
        ld hl,last_mode
        cp (hl)
        jr nz,pr_go
        ld a,(g_id)
        ld hl,last_id
        cp (hl)
        jr nz,pr_go
        ld a,(g_screen)
        ld hl,last_scr
        cp (hl)
        jr nz,pr_go
        ld a,(nowtick)
        ld hl,lastsend
        sub (hl)
        ld hl,pace_ival
        cp (hl)
        ret
pr_go
        or a
        ret

stamp_lastsend
        push af
        OS_GETTIMER
        ld a,l
        ld (lastsend),a
        pop af
        ret

; A = timer L. GETTIMER spoils all; does not advance while DI.
prof_snap
        push bc
        push de
        push hl
        OS_GETTIMER
        ld a,l
        pop hl
        pop de
        pop bc
        ret

prof_and_stamp
        call send_prof
        jp stamp_lastsend

; type11: flags,mode,wait,gfx,cap,xor,send,tot,nskip,ival  (ticks, 20ms)
send_prof
        call prof_snap
        ld (prof_send),a
        ld a,FR_PROF
        ld (frmhdr),a
        ld hl,10
        ld (frmhdr+1),hl
        ld a,(prof_flags)
        ld (frmhdr+3),a
        ld a,(g_gfxmode)
        ld (frmhdr+4),a
        ld a,(prof_wait)
        ld (frmhdr+5),a
        ld a,(prof_gfx)
        ld hl,prof_sf
        sub (hl)
        ld (frmhdr+6),a
        ld a,(prof_cap)
        ld hl,prof_gfx
        sub (hl)
        ld (frmhdr+7),a
        ld a,(prof_xor)
        ld hl,prof_cap
        sub (hl)
        ld (frmhdr+8),a
        ld a,(prof_send)
        ld hl,prof_xor
        sub (hl)
        ld (frmhdr+9),a
        ld a,(prof_send)
        ld hl,prof_sf
        sub (hl)
        ld (frmhdr+10),a
        ld a,(prof_nskip)
        ld (frmhdr+11),a
        xor a
        ld (prof_nskip),a
        ld a,(pace_ival)
        ld (frmhdr+12),a
        ld de,frmhdr
        ld hl,13
        call send_chunk
        ret

set_poll
        ld a,(ival_text)
        ld hl,ival_scr
        cp (hl)
        jr c,sp_e
        ld a,(hl)
sp_e
        ld hl,ival_ega
        cp (hl)
        jr c,sp_ok
        ld a,(hl)
sp_ok
        or a
        jr nz,sp_st
        inc a
sp_st
        ld (ival_poll),a
        ret

; A=fps 1..50 -> A=50/fps (>=1)
fps_to_ival
        ld e,a
        or a
        jr nz,f2i_go
        inc e
f2i_go
        ld a,50
        ld b,0
f2i_lp
        cp e
        jr c,f2i_dn
        sub e
        inc b
        jr f2i_lp
f2i_dn
        ld a,b
        or a
        ret nz
        inc a
        ret

load_fps
        ld de,n_fps
        call make_fname
        ld de,fname
        OS_OPENHANDLE
        or a
        jp nz,set_poll
        ld a,b
        ld (fhan),a
        ld hl,fpsfile
        ld de,fpsfile+1
        ld bc,FPSSZ-1
        ld (hl),0
        ldir
        ld de,fpsfile
        ld hl,FPSSZ-1
        ld a,(fhan)
        ld b,a
        OS_READHANDLE
        ld a,(fhan)
        ld b,a
        OS_CLOSEHANDLE
        ld hl,fpsfile
        call parse_fps
        jp set_poll

parse_fps
pf_loop
        call pf_skip
        ld a,(hl)
        or a
        ret z
        cp ';'
        jr z,pf_com
        ld de,k_text
        call pf_match
        jr nz,pf_s
        call pf_num
        jr c,pf_loop
        call fps_to_ival
        ld (ival_text),a
        jr pf_loop
pf_s
        ld de,k_scr
        call pf_match
        jr nz,pf_e
        call pf_num
        jr c,pf_loop
        call fps_to_ival
        ld (ival_scr),a
        jr pf_loop
pf_e
        ld de,k_ega
        call pf_match
        jr z,pf_eg
        ld de,k_mc
        call pf_match
        jr nz,pf_unk
pf_eg
        call pf_num
        jr c,pf_loop
        call fps_to_ival
        ld (ival_ega),a
        jr pf_loop
pf_unk
        inc hl
        jr pf_loop
pf_com
        call pf_skipline
        jr pf_loop

pf_skip
        ld a,(hl)
        cp 32
        jr z,pf_sk1
        cp 9
        jr z,pf_sk1
        cp 13
        jr z,pf_sk1
        cp 10
        ret nz
pf_sk1
        inc hl
        jr pf_skip

pf_skipline
        ld a,(hl)
        or a
        ret z
        inc hl
        cp 10
        ret z
        jr pf_skipline

; DE=ASCIIZ key, HL=text. Z+HL after key if match, else NZ+HL restored
pf_match
        push hl
pm_lp
        ld a,(de)
        or a
        jr z,pm_ok
        cp (hl)
        jr nz,pm_bad
        inc de
        inc hl
        jr pm_lp
pm_ok
        pop de
        xor a
        ret
pm_bad
        pop hl
        or 1
        ret

; HL at digits. NC, A=1..50, HL after. CY if no number
pf_num
        ld a,(hl)
        sub '0'
        cp 10
        ccf
        ret c
        ld b,a
        inc hl
        ld a,(hl)
        sub '0'
        cp 10
        jr nc,pn_one
        inc hl
        ld c,a
        ld a,b
        add a,a
        ld d,a
        add a,a
        add a,a
        add a,d
        add a,c
        ld b,a
pn_one
        ld a,b
        or a
        scf
        ret z
        cp 51
        jr c,pn_ok
        ld a,50
pn_ok
        or a
        ret

; ---- frames ----

stream_frame
        ld a,(soc_client)
        inc a
        ret z
        call prof_snap
        ld (prof_sf),a
        ld hl,lastsend
        sub (hl)
        ld (prof_wait),a
        OS_GETGFX
        ld (g_gfxmode),a
        ld a,b
        ld (g_id),a
        ld a,c
        ld (g_screen),a
        ld a,d
        ld (g_s0l),a
        ld a,e
        ld (g_s0h),a
        ld a,h
        ld (g_s1l),a
        ld a,l
        ld (g_s1h),a
        call ival_for_mode
        ld (pace_ival),a
        call pace_ready
        if SCRNET_PROF
        jr sf_work
        endif
        jr nc,sf_work
        ld a,(prof_nskip)
        inc a
        jr z,sf_sksat
        ld (prof_nskip),a
sf_sksat
        ret
sf_work
        xor a
        ld (prof_flags),a
        ld a,(force)
        or a
        jr z,sf_nf
        ld a,4
        ld (prof_flags),a
sf_nf
        call prof_snap
        ld (prof_gfx),a
        ld (prof_cap),a
        ld (prof_xor),a
        ld hl,prof_and_stamp
        push hl
        ld de,palbuf
        OS_GETPAL
        call maybe_send_pal
        ret c
        ld a,(g_gfxmode)
        and 7
        jp z,do_ega
        cp 2
        jp z,do_mc
        cp 3
        jp z,do_6912
        cp 6
        ret nz
        ld hl,PLANESZ
        ld (planesize),hl
        ld a,(g_id)
        ld (last_id),a
        ld a,(g_screen)
        ld (last_scr),a
        ld a,(force)
        ld (txt_need),a
        xor a
        ld (force),a
        ld a,6
        ld (last_mode),a
        ld a,(net_drv)
        cp 2
        jr z,txt_esp_cap
        call capture_cmp_planes
        jr txt_got
txt_esp_cap
        ld a,(txt_need)
        or a
        jr nz,txt_esp_full
        call capture_xor_planes
        jr txt_got
txt_esp_full
        call capture_planes
        ld a,1
        ld (xor_any),a
txt_got
        call prof_snap
        ld (prof_cap),a
        ld (prof_xor),a
        ld a,(txt_need)
        or a
        jr nz,txt_out
        ld a,(xor_any)
        or a
        jr nz,txt_out
        ld a,(prof_flags)
        or 2
        ld (prof_flags),a
        ret
txt_out
        ld a,(net_drv)
        cp 2
        jr nz,txt_send
        ld a,(txt_need)
        or a
        jr nz,txt_send
        ld a,FR_XOR
        ld (frame_type),a
        jp send_xor_packed
txt_send
        ld a,FR_KEY
        ld hl,PLANESZ
        jp send_keyframe

do_ega
        xor a
        ld (g32_mode),a
        ld a,FR_EGA
        ld (g32_frkey),a
        ld a,FR_EGAXOR
        ld (g32_frxor),a
        jp ega_frame
do_mc
        ld a,2
        ld (g32_mode),a
        ld a,FR_MC
        ld (g32_frkey),a
        ld a,FR_MCXOR
        ld (g32_frxor),a
        jp ega_frame
do_gfx_unused
        ld b,a
        ld a,(last_mode)
        cp b
        ret z
        ld a,b
        ld (last_mode),a
        ld a,1
        ld (force),a
        ld a,FR_GFX
        ld (iobuf),a
        ld hl,1
        ld (iobuf+1),hl
        ld a,b
        ld (iobuf+3),a
        ld de,iobuf
        ld hl,4
        jp send_chunk

do_6912
        call capture_6912
        call prof_snap
        ld (prof_cap),a
        ld (prof_xor),a
        ld hl,SCRSZ
        ld (planesize),hl
        ld a,(force)
        or a
        jr nz,scr_key
        ld a,(last_mode)
        cp 3
        jr nz,scr_key
        ld a,(g_screen)
        ld hl,last_scr
        cp (hl)
        jr nz,scr_key
        ld a,(g_id)
        ld hl,last_id
        cp (hl)
        jr z,scr_delta
scr_key
        ld a,(g_id)
        ld (last_id),a
        ld a,(g_screen)
        ld (last_scr),a
        xor a
        ld (force),a
        ld a,3
        ld (last_mode),a
        ld a,FR_SCR
        ld hl,SCRSZ
        jp send_keyframe
scr_delta
        ld a,3
        ld (last_mode),a
        ld a,FR_SCRXOR
        ld (frame_type),a
        jp send_xor

; A=type HL=payload size. Data in curbuf.
send_keyframe
        push af
        ld a,(prof_flags)
        or 1
        ld (prof_flags),a
        pop af
        ld (iobuf),a
        ld (iobuf+1),hl
        push hl
        ld bc,3
        add hl,bc
        push hl
        ld de,chead
        call hex4
        ld a,13
        ld (de),a
        inc de
        ld a,10
        ld (de),a
        ld de,chead
        ld hl,6
        call send_data
        pop hl
        pop hl
        ret c
        ld de,iobuf
        ld hl,3
        call send_data
        ret c
        ld de,curbuf
        ld hl,(iobuf+1)
        call send_data
        ret c
        ld de,crlf
        ld hl,2
        call send_data
        ret c
        jp store_prev

; A=type. 32K at EGAPREV, no RLE (WIZNET).
send_ega_raw
        push af
        ld a,(prof_flags)
        or 1
        ld (prof_flags),a
        pop af
        ld (frmhdr),a
        ld hl,EGASZ
        ld (frmhdr+1),hl
        push hl
        ld bc,3
        add hl,bc
        ld de,chead
        call hex4
        ld a,13
        ld (de),a
        inc de
        ld a,10
        ld (de),a
        ld de,chead
        ld hl,6
        call send_data
        pop hl
        ret c
        ld de,frmhdr
        ld hl,3
        call send_data
        ret c
        ld de,EGAPREV
        ld hl,EGASZ
        call send_data_yield
        ret c
        ld de,crlf
        ld hl,2
        jp send_data

send_xor
        call xor_make
send_xor_packed
        ld a,(xor_any)
        or a
        jr nz,sx_go
        ld a,(prof_flags)
        or 2
        ld (prof_flags),a
        call prof_snap
        ld (prof_xor),a
        ret
sx_go
        call pack_xor
        call prof_snap
        ld (prof_xor),a
        ld a,(prof_flags)
        or 1
        ld (prof_flags),a
        ld a,(frame_type)
        ld (iobuf),a
        ld hl,(rle_dst)
        ld de,iobuf+3
        or a
        sbc hl,de
        ld (iobuf+1),hl
        ld bc,3
        add hl,bc
        ld de,iobuf
        call send_chunk
        ret c
        jp store_prev

; Focus DDp palette (32 bytes). Send before pixels so the first blit matches the CRT.
maybe_send_pal
        ld a,(force)
        or a
        jr nz,pal_send
        ld hl,palbuf
        ld de,prevpal
        ld b,PALSZ
pal_cmp
        ld a,(de)
        cp (hl)
        jr nz,pal_send
        inc hl
        inc de
        djnz pal_cmp
        ret
pal_send
        ld a,FR_PAL
        ld (rlebuf),a
        ld hl,PALSZ
        ld (rlebuf+1),hl
        ld hl,palbuf
        ld de,rlebuf+3
        ld bc,PALSZ
        ldir
        ld de,rlebuf
        ld hl,PALSZ+3
        call send_chunk
        ret c
        ld hl,palbuf
        ld de,prevpal
        ld bc,PALSZ
        ldir
        xor a
        ret

; ATM 320x200 x16: 32K VRAM (two pages), four interleaved column banks.
; Prev frame lives at 4000-BFFF (our 4000+8000 pages). RLE is counted then
; streamed so a 32K worst-case payload never sits in RAM.

ega_frame
        ld a,(prof_flags)
        or 8
        ld (prof_flags),a
        call ega_selpages
        call ega_copy_vram_to_prev
        call prof_snap
        ld (prof_cap),a
        ld (prof_xor),a
        ld a,(force)
        or a
        jr nz,ega_key
        ld a,(last_mode)
        ld hl,g32_mode
        cp (hl)
        jr nz,ega_key
        ld a,(g_screen)
        ld hl,last_scr
        cp (hl)
        jr nz,ega_key
        ld a,(g_id)
        ld hl,last_id
        cp (hl)
        jr nz,ega_key
        ld a,(xor_any)
        or a
        jr nz,ega_key
        ld a,(prof_flags)
        or 2
        ld (prof_flags),a
        ret
ega_key
        ld a,(g_id)
        ld (last_id),a
        ld a,(g_screen)
        ld (last_scr),a
        xor a
        ld (force),a
        ld a,(g32_mode)
        ld (last_mode),a
        ld a,(net_drv)
        cp 2
        jp z,ega_esp
        ld a,(g32_mode)
        or a
        ld a,FR_EGARAW
        jr z,ega_wraw
        ld a,FR_MCRAW
ega_wraw
        jp send_ega_raw
ega_esp
        ld a,(g32_frkey)
        ld (frame_type),a
        jp ega_send_rle

ega_selpages
        ld a,(g_screen)
        or a
        ld a,(g_s0l)
        ld b,a
        ld a,(g_s0h)
        jr z,ega_pgset
        ld a,(g_s1l)
        ld b,a
        ld a,(g_s1h)
ega_pgset
        ld (ega_pgh),a
        ld a,b
        ld (ega_pgl),a
        ret

; Snapshot both visible pages under one DI. Sanshimai/bq flip SETSCREEN
; in IM1; EI mid-copy mixes two frames and the level geometry falls apart.
; xor_any=1 if the snapshot differs from the last sent frame.
; Forced/mode-change keyframe: LDIR, no per-byte XOR.
ega_copy_vram_to_prev
        ld a,(force)
        or a
        jr nz,ega_copy_fast
        ld a,(last_mode)
        ld hl,g32_mode
        cp (hl)
        jr nz,ega_copy_fast
        ld a,(g_screen)
        ld hl,last_scr
        cp (hl)
        jr nz,ega_copy_fast
        ld a,(g_id)
        ld hl,last_id
        cp (hl)
        jr nz,ega_copy_fast
        xor a
        ld (xor_any),a
        di
        ld a,(ega_pgl)
        SETPGC000
        ld hl,0xC000
        ld de,EGAPREV
        ld bc,16384
        call ega_cp_blk
        ld a,(ega_pgh)
        SETPGC000
        ld hl,0xC000
        ld de,EGAPREV+16384
        ld bc,16384
        call ega_cp_blk
        ei
        ret
ega_copy_fast
        ld a,1
        ld (xor_any),a
        di
        ld a,(ega_pgl)
        SETPGC000
        ld hl,0xC000
        ld de,EGAPREV
        ld bc,16384
        ldir
        ld a,(ega_pgh)
        SETPGC000
        ld hl,0xC000
        ld de,EGAPREV+16384
        ld bc,16384
        ldir
        ei
        ret
ega_cp_blk
        ld a,(de)
        cp (hl)
        jr z,ega_cps
        ld a,1
        ld (xor_any),a
ega_cps
        ld a,(hl)
        ld (de),a
        inc hl
        inc de
        dec bc
        ld a,b
        or c
        jr nz,ega_cp_blk
        ret

; PackBits of 32K at EGAPREV. Count, then HTTP-chunk the RLE without a 32K dest.
ega_send_rle
        xor a
        ld (pack_emit),a
        ld hl,0
        ld (rle_outsz),hl
        ld hl,EGAPREV
        ld (rle_src),hl
        ld hl,EGASZ
        ld (rle_left),hl
        call pk_loop
        call prof_snap
        ld (prof_xor),a
        ld a,(prof_flags)
        or 1
        ld (prof_flags),a
        ld hl,(rle_outsz)
        ld a,h
        or l
        ret z
        push hl
        ld bc,3
        add hl,bc
        ld de,chead
        call hex4
        ld a,13
        ld (de),a
        inc de
        ld a,10
        ld (de),a
        ld de,chead
        ld hl,6
        call send_data
        pop hl
        ret c
        ld a,(frame_type)
        ld (rlebuf),a
        ld (rlebuf+1),hl
        ld de,rlebuf
        ld hl,3
        call send_data
        ret c
        ld a,1
        ld (pack_emit),a
        ld hl,rlebuf
        ld (rle_ptr),hl
        ld hl,EGAPREV
        ld (rle_src),hl
        ld hl,EGASZ
        ld (rle_left),hl
        call pk_loop
        ret c
        call rle_flush
        ret c
        ld de,crlf
        ld hl,2
        jp send_data

; ---- capture / xor / rle ----
; ATM text: countxy once per row, then step_xy (xor 0x20 / inc l).
; Delta: one pass VRAM -> cur + xor vs prev into xorbuf (no IX).

cap_selpages
        ld a,(g_screen)
        or a
        ld a,(g_s0h)
        ld b,a
        ld a,(g_s0l)
        jr z,cap_pg
        ld a,(g_s1h)
        ld b,a
        ld a,(g_s1l)
cap_pg
        ld (cap_attrpg),a
        ld a,b
        SETPGC000
        ret

; HL=vram, DE=dst, B=80.
cap_row
        ld a,(hl)
        ld (de),a
        inc de
        ld a,h
        xor 0x20
        ld h,a
        and 0x20
        jr nz,cap_rs
        inc l
cap_rs
        djnz cap_row
        ret

; HL=vram, DE=cur, B=80. C=y. Compare to prev; set xor_any if different.
cap_cmp_row
        push bc
        ld a,(hl)
        ld (de),a
        inc de
        push hl
        ld hl,(cx_prev)
        cp (hl)
        inc hl
        ld (cx_prev),hl
        pop hl
        jr z,cc_z
        ld a,1
        ld (xor_any),a
cc_z
        pop bc
        ld a,h
        xor 0x20
        ld h,a
        and 0x20
        jr nz,cc_rs
        inc l
cc_rs
        djnz cap_cmp_row
        ret

; HL=vram, DE=cur, B=80. Also fill xorbuf. C=y.
cap_xor_row
        push bc
        ld a,(hl)
        ld (de),a
        inc de
        push de
        ld de,(cx_prev)
        ld a,(de)
        xor (hl)
        inc de
        ld (cx_prev),de
        ld de,(cx_xor)
        ld (de),a
        inc de
        ld (cx_xor),de
        or a
        jr z,cx_z
        ld a,1
        ld (xor_any),a
cx_z
        pop de
        pop bc
        ld a,h
        xor 0x20
        ld h,a
        and 0x20
        jr nz,cx_rs
        inc l
cx_rs
        djnz cap_xor_row
        ret

cap_text_addr
        push de
        ld d,c
        ld e,0
        call countxy
        pop de
        ret

cap_attr_addr
        call cap_text_addr
        ld a,h
        xor 0x20
        ld h,a
        and 0x20
        ret nz
        inc l
        ret

capture_planes
        call cap_selpages
        ld de,curbuf
        ld c,0
cp_ty
        call cap_text_addr
        ld b,COLS
        call cap_row
        inc c
        ld a,c
        cp ROWS
        jr nz,cp_ty
        ld a,(cap_attrpg)
        SETPGC000
        ld c,0
cp_ay
        call cap_attr_addr
        ld b,COLS
        call cap_row
        inc c
        ld a,c
        cp ROWS
        jr nz,cp_ay
        ret

capture_cmp_planes
        xor a
        ld (xor_any),a
        call cap_selpages
        ld de,curbuf
        ld hl,prevbuf
        ld (cx_prev),hl
        ld c,0
cc_ty
        call cap_text_addr
        ld b,COLS
        call cap_cmp_row
        inc c
        ld a,c
        cp ROWS
        jr nz,cc_ty
        ld a,(cap_attrpg)
        SETPGC000
        ld c,0
cc_ay
        call cap_attr_addr
        ld b,COLS
        call cap_cmp_row
        inc c
        ld a,c
        cp ROWS
        jr nz,cc_ay
        ret

capture_xor_planes
        xor a
        ld (xor_any),a
        call cap_selpages
        ld de,curbuf
        ld hl,prevbuf
        ld (cx_prev),hl
        ld hl,xorbuf
        ld (cx_xor),hl
        ld c,0
cx_ty
        call cap_text_addr
        ld b,COLS
        call cap_xor_row
        inc c
        ld a,c
        cp ROWS
        jr nz,cx_ty
        ld a,(cap_attrpg)
        SETPGC000
        ld c,0
cx_ay
        call cap_attr_addr
        ld b,COLS
        call cap_xor_row
        inc c
        ld a,c
        cp ROWS
        jr nz,cx_ay
        ret

;in: de=yx ;out: hl=text VRAM addr (BDOS_countxy)
countxy
        ld a,d
        sub -0x87&0xff
        rra
        ld h,a
        ld a,0
        rra
        sra h
        rra
        ld l,e
        srl l
        jr c,$+4
        res 5,h
        add a,l
        ld l,a
        ret

capture_6912
        ld a,(g_screen)
        or a
        ld a,(g_s0h)
        jr z,c69_pg
        ld a,(g_s1h)
c69_pg
        SETPGC000
        ld hl,0xC000
        ld de,curbuf
        ld bc,SCRSZ
        ldir
        ret

store_prev
        ld hl,curbuf
        ld de,prevbuf
        ld bc,(planesize)
        ldir
        ret

xor_make
        ld hl,xorbuf
        ld (cx_xor),hl
        ld hl,curbuf
        ld de,prevbuf
        ld bc,(planesize)
        xor a
        ld (xor_any),a
xm_lp
        ld a,(de)
        xor (hl)
        inc hl
        inc de
        push de
        ld de,(cx_xor)
        ld (de),a
        inc de
        ld (cx_xor),de
        pop de
        or a
        jr z,xm_z
        ld a,1
        ld (xor_any),a
xm_z
        dec bc
        ld a,b
        or c
        jr nz,xm_lp
        ret

pack_xor
        ld a,2
        ld (pack_emit),a
        ld hl,xorbuf
        ld (rle_src),hl
        ld hl,(planesize)
        ld (rle_left),hl
        ld hl,iobuf+3
        ld (rle_dst),hl
pk_loop
        ld hl,(rle_left)
        ld a,h
        or l
        ret z
        call count_run
        ld a,(rle_run)
        cp 2
        jr nc,pk_rep
        ld hl,(rle_src)
        ld (rle_litptr),hl
        xor a
        ld (rle_lit),a
pk_lit
        ld hl,(rle_left)
        ld a,h
        or l
        jr z,pk_litout
        call count_run
        ld a,(rle_run)
        cp 2
        jr nc,pk_litout
        ld a,(rle_lit)
        cp 128
        jr z,pk_litout
        inc a
        ld (rle_lit),a
        ld a,1
        call advance_a
        jr pk_lit
pk_litout
        ld a,(rle_lit)
        or a
        jr z,pk_loop
        dec a
        call rle_out_byte
        ret c
        ld hl,(rle_litptr)
        ld a,(rle_lit)
        ld b,a
pk_litb
        ld a,(hl)
        inc hl
        push hl
        push bc
        call rle_out_byte
        pop bc
        pop hl
        ret c
        djnz pk_litb
        jr pk_loop
pk_rep
        ld a,(rle_run)
        add a,127
        call rle_out_byte
        ret c
        ld a,(rle_val)
        call rle_out_byte
        ret c
        ld a,(rle_run)
        call advance_a
        jr pk_loop

; A=byte. pack_emit: 0=count size, 1=net (rlebuf), 2=mem (rle_dst). CY if send died.
rle_out_byte
        ld c,a
        ld a,(pack_emit)
        or a
        jr z,rob_cnt
        dec a
        jr z,rob_net
        ld hl,(rle_dst)
        ld (hl),c
        inc hl
        ld (rle_dst),hl
        or a
        ret
rob_cnt
        ld hl,(rle_outsz)
        inc hl
        ld (rle_outsz),hl
        or a
        ret
rob_net
        ld hl,(rle_ptr)
        ld (hl),c
        inc hl
        ld (rle_ptr),hl
        ld de,rlebuf_end
        or a
        sbc hl,de
        jr z,rle_flush_full
        xor a
        ret
rle_flush_full
        ld de,rlebuf
        ld hl,RLEBUFSZ
        call send_data
        ret c
        YIELDKEEP
        ld hl,rlebuf
        ld (rle_ptr),hl
        xor a
        ret
rle_flush
        ld hl,(rle_ptr)
        ld de,rlebuf
        or a
        sbc hl,de
        ret z
        jp send_data

count_run
        ld hl,(rle_src)
        ld a,(hl)
        ld (rle_val),a
        ld c,a
        ld b,1
cr_lp
        ld a,b
        cp 128
        jr z,cr_done
        ld a,(rle_left)
        sub b
        ld a,(rle_left+1)
        sbc a,0
        jr c,cr_done
        jr z,cr_done
        inc hl
        ld a,c
        cp (hl)
        jr nz,cr_done
        inc b
        jr cr_lp
cr_done
        ld a,b
        ld (rle_run),a
        ret

advance_a
        ld c,a
        ld b,0
        ld hl,(rle_src)
        add hl,bc
        ld (rle_src),hl
        ld hl,(rle_left)
        or a
        sbc hl,bc
        ld (rle_left),hl
        ret

; HL=s1 DE=s2  Z if equal
strcmp
        ld a,(de)
        cp (hl)
        ret nz
        or a
        ret z
        inc hl
        inc de
        jr strcmp

; HL in, DE dest; DE after 4 hex digits
hex4
        ld a,h
        call hex2
        ld a,l
hex2
        push af
        rrca
        rrca
        rrca
        rrca
        call hex1
        pop af
hex1
        and 15
        add a,'0'
        cp '9'+1
        jr c,hex1o
        add a,7
hex1o
        ld (de),a
        inc de
        ret

; HL=value DE=dest. Always writes at least one digit. DE after last.
itoa16
        ld bc,-10000
        call it_dgt
        ld bc,-1000
        call it_dgt
        ld bc,-100
        call it_dgt
        ld bc,-10
        call it_dgt
        ld a,l
        add a,'0'
        ld (de),a
        inc de
        ret
it_dgt
        ld a,'0'-1
it_d1
        inc a
        add hl,bc
        jr c,it_d1
        sbc hl,bc
        ld (it_tmp),a
        ld a,(itoa_on)
        or a
        ld a,(it_tmp)
        jr nz,it_put
        cp '0'
        ret z
it_put
        ld (de),a
        inc de
        ld a,1
        ld (itoa_on),a
        ret

g_gfxmode       db 0
g_screen        db 0
g_s0l           db 0
g_s0h           db 0
g_s1l           db 0
g_s1h           db 0
g_id            db 0
cap_attrpg      db 0
force           db 0
last_mode       db 0xff
last_id         db 0xff
last_scr        db 0xff
lastsend        db 0
nowtick         db 0
prof_sf         db 0
prof_gfx        db 0
prof_cap        db 0
prof_xor        db 0
prof_send       db 0
prof_wait       db 0
prof_flags      db 0
prof_nskip      db 0
cx_prev         dw 0
cx_xor          dw 0
pace_ival       db 50/FPS_TEXT
ival_text       db 50/FPS_TEXT
ival_scr        db 50/FPS_SCR
ival_ega        db 50/FPS_EGA
ival_poll       db 50/FPS_TEXT
soc             db NOSOCK
soc_client      db NOSOCK
soc_post        db NOSOCK
soc_saved       db 0
net_drv         db 0
txt_need        db 0
net_a           db 0
net_fh          db 0
ti_age          db 0
is_stream       db 0
hdr_st          db 0
line_done       db 0
hdr_ch          db 0
xor_any         db 0
fhan            db 0
itoa_on         db 0
it_tmp          db 0
rle_val         db 0
rle_run         db 0
rle_lit         db 0
req_len         dw 0
body_ptr        dw 0
body_left       dw 0
fsize           dw 0
ctype_ptr       dw 0
rle_src         dw 0
rle_left        dw 0
rle_dst         dw 0
rle_litptr      dw 0
planesize       dw PLANESZ
frame_type      db FR_XOR
g32_mode        db 0
g32_frkey       db FR_EGA
g32_frxor       db FR_EGAXOR
ega_pgl         db 0
ega_pgh         db 0
sd_yield        db 0
sd_tick         db 0
pack_emit       db 2
rle_outsz       dw 0
rle_ptr         dw 0

path_pref       db "/bin/scrnet/",0
n_index         db "index.htm",0
n_app           db "app.js",0
n_atm           db "atmucode.fnt",0
n_866           db "866_code.fnt",0
n_fps           db "fps.ini",0
k_text          db "text=",0
k_scr           db "scr=",0
k_ega           db "ega=",0
k_mc            db "mc=",0
p_root          db "/",0
p_ini           db "ini",0
n_netini        db "network.ini",0
k_curNet        db "currentNetwork",0
t_badnet        db "scrnet: currentNetwork must be 0 (WIZNET) or 2 (ESPNET)",13,10,0
t_lisnfail      db "scrnet: listen :2324 failed",13,10,0
p_index         db "/index.htm",0
p_app           db "/app.js",0
p_atm           db "/atmucode.fnt",0
p_866           db "/866_code.fnt",0
p_stream        db "/stream",0
p_stream2       db "/stream/",0
p_input         db "/input",0

ct_htm          db "text/html; charset=utf-8",0
ct_js           db "text/javascript; charset=utf-8",0
ct_bin          db "application/octet-stream",0

hdr_ok          db "HTTP/1.1 200 OK",13,10,"Content-Type: ",0
hdr_clen        db 13,10,"Content-Length: ",0
hdr_end         db 13,10,"Connection: close",13,10,13,10,0
hdr_404         db "HTTP/1.1 404 Not Found",13,10,"Content-Length: 0",13,10,"Connection: close",13,10,13,10,0
hdr_400         db "HTTP/1.1 400 Bad Request",13,10,"Content-Length: 0",13,10,"Connection: close",13,10,13,10,0
hdr_204         db "HTTP/1.1 204 No Content",13,10,"Connection: close",13,10,13,10,0
hdr_stream      db "HTTP/1.1 200 OK",13,10
                db "Content-Type: application/octet-stream",13,10
                db "Cache-Control: no-store",13,10
                db "Transfer-Encoding: chunked",13,10,13,10,0
crlf            db 13,10

bind_addr
        db AF_INET
        db PORT/256,PORT&0xff
        db 0,0,0,0
        db 0,0,0,0,0,0,0,0

; ---- net: 0 WIZNET, 2 ESPNET. Print errors before HIDEFROMPARENT. ----

prstr
        ld a,(hl)
        or a
        ret z
        push hl
        OS_PRCHAR
        pop hl
        inc hl
        jr prstr

load_net
        xor a
        ld (net_drv),a
        ld de,net_path
        OS_GETPATH
        OS_SETSYSDRV
        ld de,p_root
        OS_CHDIR
        ld de,p_ini
        OS_CHDIR
        ld de,n_netini
        OS_OPENHANDLE
        or a
        jr z,ln_rd
        ld de,net_path
        OS_CHDIR
        xor a
        ret
ln_rd
        ld a,b
        ld (net_fh),a
        ld b,a
        ld de,net_inibuf
        ld hl,255
        OS_READHANDLE
        ld a,(net_fh)
        ld b,a
        OS_CLOSEHANDLE
        ld de,net_path
        OS_CHDIR
        xor a
        ld (net_inibuf+255),a
        ld hl,net_inibuf
        call find_curnet
        ld (net_drv),a
        or a
        ret z
        cp 2
        jr z,ln_esp
        ld hl,t_badnet
        call prstr
        scf
        ret
ln_esp
        call esp_init
        call net_reap
        xor a
        ret

find_curnet
        ld de,k_curNet
fn_lp
        ld a,(hl)
        or a
        ret z
        push hl
        push de
        call streq_at
        pop de
        jr z,fn_got
        pop hl
        inc hl
        jr fn_lp
fn_got
        pop hl
fn_eq
        ld a,(hl)
        or a
        ret z
        cp '='
        jr z,fn_val
        inc hl
        jr fn_eq
fn_val
        inc hl
fn_sp
        ld a,(hl)
        cp ' '
        jr z,fn_sk
        cp 9
        jr z,fn_sk
        jr fn_num
fn_sk
        inc hl
        jr fn_sp
fn_num
        ld b,0
fn_d
        ld a,(hl)
        sub '0'
        cp 10
        jr nc,fn_done
        ld c,a
        ld a,b
        add a,a
        ld b,a
        add a,a
        add a,a
        add a,b
        add a,c
        ld b,a
        inc hl
        jr fn_d
fn_done
        ld a,b
        ret

streq_at
        ld a,(de)
        or a
        ret z
        cp (hl)
        ret nz
        inc de
        inc hl
        jr streq_at

listen_now
        ld d,AF_INET
        ld e,SOCK_STREAM
        call net_socket
        bit 7,l
        jr nz,ln_fail
        ld a,l
        ld (soc),a
        ld de,bind_addr
        call net_bind
        bit 7,l
        jr nz,ln_fail
        ld a,(soc)
        call net_listen
        bit 7,l
        jr nz,ln_fail
        or a
        ret
ln_fail
        push af
        ld a,(soc)
        inc a
        jr z,ln_fail2
        ld a,(soc)
        ld e,0
        call net_shutdown
        ld a,NOSOCK
        ld (soc),a
ln_fail2
        pop af
        scf
        ret

net_reap
        ld a,(net_drv)
        cp 2
        ret nz
        xor a
reap_lp
        ld (net_a),a
        ld e,0
        call esp_shutdown
        ld a,(net_a)
        inc a
        cp 8
        jr c,reap_lp
        ret

; Save A (socket) before reading net_drv.
net_socket
        ld a,(net_drv)
        cp 2
        jp z,esp_socket
        OS_NETSOCKET
        ret

net_shutdown
        ld (net_a),a
        ld a,(net_drv)
        cp 2
        ld a,(net_a)
        jp z,esp_shutdown
        OS_NETSHUTDOWN
        ret

net_bind
        ld (net_a),a
        ld a,(net_drv)
        cp 2
        ld a,(net_a)
        jp z,esp_bind
        OS_BIND
        ret

net_listen
        ld (net_a),a
        ld a,(net_drv)
        cp 2
        ld a,(net_a)
        jp z,esp_listen
        OS_LISTEN
        ret

net_accept
        ld (net_a),a
        ld a,(net_drv)
        cp 2
        ld a,(net_a)
        jp z,esp_accept
        OS_ACCEPT
        ret

net_read
        ld (net_a),a
        ld a,(net_drv)
        cp 2
        ld a,(net_a)
        jp z,esp_read
        OS_WIZNETREAD
        ret

net_write
        ld (net_a),a
        ld a,(net_drv)
        cp 2
        ld a,(net_a)
        jp z,esp_write
        OS_WIZNETWRITE
        ret

        include "../_sdk/espnet.asm"

end
        savebin "scrnet.com",begin,end-begin
        LABELSLIST "../../us/user.l",1

reqbuf          ds REQSZ
netin           ds NETIN_SZ
net_path        ds 256
net_inibuf      ds 256
pathbuf         ds 32
fname           ds 32
chead           ds 8
frmhdr          ds 16
itoa_buf        ds 8
palbuf          ds PALSZ
prevpal         ds PALSZ
rlebuf          ds RLEBUFSZ
rlebuf_end
fpsfile         ds FPSSZ
