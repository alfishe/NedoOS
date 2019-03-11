IPPROTO_TCP EQU 6
IPPROTO_UDP EQU 17

AF_UNSPEC EQU 0
AF_INET EQU 2
AF_INET6 EQU 23

SOCK_STREAM EQU 0x01	;tcp/ip
SOCK_DGRAM 	EQU 0x03		;udp/ip

SHUT_RDWR 		EQU 2
ERR_INTR 		EQU 4
ERR_NFILE 		EQU 23
ERR_ALREADY 	EQU 37
ERR_NOTSOCK 	EQU 38
ERR_EMSGSIZE 	EQU 40    ;/* Message too long */
ERR_PROTOTYPE 	EQU 41
ERR_AFNOSUPPORT EQU 47
ERR_HOSTUNREACH EQU 65
ERR_CONNRESET 	EQU 54
ERR_NOTCONN 	EQU 57
;struct sockaddr_in {short sin_family;unsigned short sin_port;
;	struct in_addr sin_addr;char sin_zero[8];};

;/***************************************/ 
;/* The bit of Sn_MR regsiter defintion */ 
;/***************************************/ 
Sn_MR_ALIGN         EQU (1 << 8)             ;< Alignment bit of Sn_MR. */
Sn_MR_MULTI         EQU (1 << 7)             ;< Multicasting bit of Sn_MR. */
Sn_MR_MF            EQU (1 << 6)             ;< MAC filter bit of Sn_MR. */
Sn_MR_IGMPv         EQU (1 << 5)             ;< IGMP version bit of Sn_MR. */
Sn_MR_ND            EQU (1 << 5)             ;< No delayed ack bit of Sn_MR. */
Sn_MR_CLOSE         EQU 0x00                 ;< Protocol bits of Sn_MR. */
Sn_MR_TCP           EQU 0x01                 ;< Protocol bits of Sn_MR. */
Sn_MR_UDP           EQU 0x02                 ;< Protocol bits of Sn_MR. */
Sn_MR_IPRAW         EQU 0x03                 ;< Protocol bits of Sn_MR. */
Sn_MR_MACRAW        EQU 0x04                 ;< Protocol bits of Sn_MR. */
Sn_MR_PPPoE         EQU 0x05                 ;< Protocol bits of Sn_MR. */

;/******************************/ 
;/* The values of CR defintion */ 
;/******************************/

Sn_CR_OPEN          EQU 0x01                 ;< OPEN command value of Sn_CR. */
Sn_CR_LISTEN        EQU 0x02                 ;< LISTEN command value of Sn_CR. */
Sn_CR_CONNECT       EQU 0x04                 ;< CONNECT command value of Sn_CR. */
Sn_CR_DISCON        EQU 0x08                 ;< DISCONNECT command value of Sn_CR. */
Sn_CR_CLOSE         EQU 0x10                 ;< CLOSE command value of Sn_CR. */
Sn_CR_SEND          EQU 0x20                 ;< SEND command value of Sn_CR. */
Sn_CR_SEND_MAC      EQU 0x21                 ;< SEND_MAC command value of Sn_CR. */ 
Sn_CR_SEND_KEEP     EQU 0x22                 ;< SEND_KEEP command value of Sn_CR */
Sn_CR_RECV          EQU 0x40                 ;< RECV command value of Sn_CR */
Sn_CR_PCON          EQU 0x23                 ;< PCON command value of Sn_CR */
Sn_CR_PDISCON       EQU 0x24                 ;< PDISCON command value of Sn_CR */ 
Sn_CR_PCR           EQU 0x25                 ;< PCR command value of Sn_CR */
Sn_CR_PCN           EQU 0x26                 ;< PCN command value of Sn_CR */
Sn_CR_PCJ           EQU 0x27                 ;< PCJ command value of Sn_CR */

;/**********************************/ 
;/* The values of Sn_SSR defintion */ 
;/**********************************/
SOCK_CLOSED         EQU 0x00                 ;< SOCKETn is released */
SOCK_ARP            EQU 0x01                 ;< ARP-request is transmitted in order to acquire destination hardware address. */
SOCK_INIT           EQU 0x13                 ;< SOCKETn is open as TCP mode. */
SOCK_LISTEN         EQU 0x14                 ;< SOCKETn operates as "TCP SERVER" and waits for connection-request (SYN packet) from "TCP CLIENT". */
SOCK_SYNSENT        EQU 0x15                 ;< Connect-request(SYN packet) is transmitted to "TCP SERVER". */
SOCK_SYNRECV        EQU 0x16                 ;< Connect-request(SYN packet) is received from "TCP CLIENT". */
SOCK_ESTABLISHED    EQU 0x17                 ;< TCP connection is established. */
SOCK_FIN_WAIT       EQU 0x18                 ;< SOCKETn is closing. */
SOCK_CLOSING        EQU 0x1A                 ;< SOCKETn is closing. */
SOCK_TIME_WAIT      EQU 0x1B                 ;< SOCKETn is closing. */
SOCK_CLOSE_WAIT     EQU 0x1C                 ;< Disconnect-request(FIN packet) is received from the peer. */
SOCK_LAST_ACK       EQU 0x1D                 ;< SOCKETn is closing. */
SOCK_UDP            EQU 0x22                 ;< SOCKETn is open as UDP mode. */
SOCK_IPRAW          EQU 0x32                 ;< SOCKETn is open as IPRAW mode. */
SOCK_MACRAW         EQU 0x42                 ;< SOCKET0 is open as MACRAW mode. */
SOCK_PPPoE          EQU 0x5F                 ;< SOCKET0 is open as PPPoE mode. */
		
httphostname=DISKBUF+0x200

getpath_http
;de=buffer to get path
        ld hl,httpcurdir ;server/path (without / in the end)
        jp strcopy

rootdir_http
        xor a
        ld (httpcurdir),a ;server/path (without / in the end)
        ret
        
chdir_http_dot
        inc de ;skip dot
        inc de ;skip another dot supposed
        ld a,(de)
        or a
        jr z,$+3
        inc de ;skip / supposed
;hl=end of curdir (slash or terminator)
;remove last element of curdir = move hl to previous slash or =httpcurdir:
        ld a,'/'
        dec hl
        ld b,-1
        cpdr
        inc hl ;at slash (might be httpcurdir-1)
        ld bc,httpcurdir
        or a
        sbc hl,bc
        ;add hl,bc
        ;jr nc,$+3 ;< httpcurdir?
        ;inc hl ;if so, hl=httpcurdir
         adc hl,bc ;if (hl<httpcurdir) hl=httpcurdir
        ;jr chdir_http

chdir_http
;de=server/path (without / in the end)
        ld hl,httpcurdir
        xor a
        ld b,-1
        cpir
        dec hl
;hl=end of curdir
        ld a,(de)
        cp '.'
        jr z,chdir_http_dot

        ld (hl),'/'
        inc hl
        ex de,hl
        call strcopy ;TODO check overflow
        ret


openstream_http
;de=filename
	;jr $
         push de ;filename
;httphostname=server name (httpcurdir before slash), curdir=httpcurdir after slash:
        ld hl,httpcurdir+1 ;server/path (without / in the end)
        ld de,httphostname
        push de
        call strcopy
        pop hl
        ld a,'/'
        ld bc,128
        cpir ;TODO what if no slash?
        ld (openstream_http_curdir),hl
        dec hl
        ld (hl),0 ;end of httphostname
        
;create socket:
	ld de,SOCK_STREAM+(AF_INET<<8)
	OS_NETSOCKET
	ld a,l
	or a
	;jp m,CONNECTIONERROR;?C_EXIT
	ld (soc1),a

        ld hl,httphostname
        call findlastdot ;de = after last dot or start
;TODO DNS resolve (de)
        

;TODO connect to server

;form GET message in DISKBUF (will be deleted in readstream)
        ld hl,tGET
        ld de,DISKBUF
        call strcopy
         dec de
	
openstream_http_curdir=$+1
        ld hl,0 ;httpcurdir+N
        call strcopy
         dec de
        ld a,'/'
        ld (de),a
        inc de
         pop hl ;filename
        call strcopy
         dec de
        ld hl,tHTTP_host
        call strcopy
         dec de
        ld hl,httphostname
        call strcopy
         dec de
        ld hl,tGETend
        call strcopy
         dec de
	 ex de,hl
        ld de,DISKBUF;0xffff&(-DISKBUF)
        or a
        sbc hl,de
;de=message
;hl=message size       
;TODO send message to server
	jr $
        
        ret
        
;hl = poi to filename in string
;out: de = after last dot or start
findlastdot
	ld d,h
	ld e,l ;de = after last dot
findlastdot0
	ld a,[hl]
	inc hl
	or a
	ret z
	cp '.'
	jr nz,findlastdot0
	jr findlastdot


readstream_http
;de=buf
;hl=size
;TODO skip header

;TODO read to buf

;TODO count actual size

;hl=actual size
        ret

closestream_http
;TODO close current connection 

;free current socket (это точно оно???):
closestream_http_free0
	ld a,(soc1)
	OS_NETSHUTDOWN
	cp SHUT_RDWR
	jr z,closestream_http_free0
        ret

;httpslashcurdir
        db '/'
httpcurdir
;server/path (without / in the end)
        ds 128

soc1
        db 0 ;current socket

tGET
        db "GET /",0
tHTTP_host
        db " HTTP/1.1",13,10
	db "Host: ",0
tGETend
        db 13,10,13,10,0

;httpgetstr
	;defb 'GET /cspr/index.htm HTTP/1.1',13,10
	;defb 'Host: dimkam.ru',13,10
	;defb 13,10
