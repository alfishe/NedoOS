	module pt3player
; SPECTRUM PSG PLAYER V 3.7 - WYZ 2006

; ENSAMBLAR CON AsMSX 1.1

; CARACTERISTICAS
; 5 OCTAVAS:            O[2-6]=60 NOTAS
; 4 LONGITUDES DE NOTA: L[0-3]+PUNTILLO
; PUNTILLO
; COMANDOS:     T:TEMPO
;               I:INSTRUMENTO
;               S:REPRODUCTOR DE EFECTOS CANAL C


; LOS DATOS QUE HAY QUE VARIAR :

; * Nº DE CANCION.
; * TABLA DE CANCIONES

; POR HACER
; - ELEGIR CANAL DE EFECTOS


; MUSICA DATOS INICIALES
INIT
;HL=song
				;DI
                ;LD      A,0             ;* CANCION N¦ 0
;CARGA UNA CANCION
;IN:[A]=Nº DE CANCION
;CARGA_CANCION:  
				;PUSH AF
                LD A,10111000b
                LD [PSG_REG+7],A
                ;POP AF
			push hl
                LD      HL,INTERR       ;CARGA CANCION
                SET     1,[HL]          ;REPRODUCE CANCION
                ;LD      HL,SONG
                ;LD      [HL],A          ;Nº A
                XOR     A
                LD      [TTEMPO],A

;DECODIFICAR
;IN-> INTERR 0 ON
;     SONG
;CARGA CANCION SI/NO

;DECODE_SONG:   
				;LD      A,[SONG]
;LEE CABECERA DE LA CANCION
;BYTE 0=TEMPO
                ;LD      HL,TABLA_SONG
                ;CALL    EXT_WORD
			pop hl
                LD      A,[HL]
                LD      [TEMPO],A
               
;Nº DE PAUTA DEL CANAL A,B,C   

                LD      IX,PUNTERO_P_A
                CALL    SET_PAUTA
                LD      IX,PUNTERO_P_B
                CALL    SET_PAUTA
                LD      IX,PUNTERO_P_C
                CALL    SET_PAUTA
                               
               
;LEE DATOS DE LAS NOTAS
;[|][|||||] LONGITUD\NOTA

                LD      DE,[CANAL_A]
                LD      [PUNTERO_A],DE
                CALL    DECODE_CANAL    ;CANAL A
                LD      [CANAL_B],DE
                LD      [PUNTERO_B],DE
                CALL    DECODE_CANAL    ;CANAL B
                LD      [CANAL_C],DE
                LD      [PUNTERO_C],DE
                CALL    DECODE_CANAL    ;CANAL C
                LD      [CANAL_P],DE
                LD      [PUNTERO_P],DE
                CALL    DECODE_CANAL    ;CANAL P
                ;EI
                RET


;___________________________________________________________

                DB      "PSG PLAYER BY WYZ'06"

;___________________________________________________________


MUTE
	XOR A
	LD H,A
	LD L,A
	LD (PSG_REG+8),A
	LD (PSG_REG+9),HL
	JP ROUT




;___________________________________________________________

PLAY
;INICIO:
				CALL    PLAY_MUS
                ;CALL    REPRODUCE_SONIDO
                ;CALL    REPRODUCE_EFECTO_A
                ;CALL    REPRODUCE_EFECTO_B
                ;CALL    REPRODUCE_EFECTO_C
                JP   ROUT


;INICIA EL SONIDO Nº [A]

INICIA_SONIDO:  LD      HL,TABLA_SONIDOS
                CALL    EXT_WORD
                LD      [PUNTERO_SONIDO],HL
                LD      HL,INTERR
                SET     2,[HL]
                RET

SILENCIAPLAYER:
                LD HL,PSG_REG
                LD DE,PSG_REG+1
                LD BC,12
                LD [HL],0
                LDIR
                LD A,10111111b
                LD [PSG_REG+7],A
                CALL ROUT
                LD HL,INTERR
                RES 1,[HL]
                RET


;INICIA PAUTA PARA UN CANAL
;IN [A]:  Nº DE PAUTA
;   [IX]: PUNTERO PAUTA

SET_PAUTA:      INC     HL
                LD      A,[HL]
                PUSH    HL
                LD      HL,TABLA_PAUTAS
                CALL    EXT_WORD
                LD      [IX+0],L
                LD      [IX+1],H
                LD      [IX+6],L
                LD      [IX+7],H
                POP     HL
                RET

;DECODIFICA NOTAS DE UN CANAL
;IN [DE]=DIRECCION DESTINO
;NOTA=0 FIN CANAL
;NOTA=1 SILENCIO
;NOTA=2 PUNTILLO
;NOTA=3 COMANDO I

DECODE_CANAL:   INC     HL
                LD      A,[HL]
                AND     A               ;FIN DEL CANAL?
                JR      Z,FIN_DEC_CANAL
                CALL    GETLEN

                CP      00000001B       ;ES SILENCIO?
                JR      NZ,NO_SILENCIO
                SET     6,A
                JR      NO_MODIFICA
               
NO_SILENCIO:    CP      00111110B       ;ES PUNTILLO?
                JR      NZ,NO_PUNTILLO
                OR      A
                RRC     B
                XOR     A
                JR      NO_MODIFICA

NO_PUNTILLO:    CP      00111111B       ;ES COMANDO?
                JR      NZ,NO_MODIFICA
                BIT     0,B             ;COMADO=INSTRUMENTO?
                JR      Z,NO_INSTRUMENTO   
                LD      A,11000001B     ;CODIGO DE INSTRUMENTO     
                LD      [DE],A
                INC     HL
                INC     DE
                LD      A,[HL]          ;Nº DE INSTRUMENTO
                LD      [DE],A
                INC     DE
                JR      DECODE_CANAL

NO_INSTRUMENTO: BIT     2,B
                JR      Z,NO_ENVOLVENTE
                LD      A,11000100B     ;CODIGO ENVOLVENTE
                LD      [DE],A
                INC     DE
                JR      DECODE_CANAL
     
NO_ENVOLVENTE:  BIT     1,B
                JR      Z,NO_MODIFICA
                LD      A,11000010B     ;CODIGO EFECTO
                LD      [DE],A                 
                INC     HL
                INC     DE                     
                LD      A,[HL]
                CALL    GETLEN

NO_MODIFICA:    LD      [DE],A
                INC     DE
                XOR     A
                DJNZ    NO_MODIFICA
                JR      DECODE_CANAL

FIN_DEC_CANAL:  SET     7,A
                LD      [DE],A
                INC     DE
                RET

GETLEN:         LD      B,A
                AND     00111111B
                PUSH    AF
                LD      A,B
                AND     11000000B
                RLCA
                RLCA
                INC     A
                LD      B,A
                LD      A,10000000B
DCBC0:          RLCA
                DJNZ    DCBC0
                LD      B,A
                POP     AF
                RET




;PLAY __________________________________________________


PLAY_MUS:       LD      HL,INTERR       ;PLAY BIT 1 ON?
                BIT     1,[HL]
                RET     Z
;TEMPO
                LD      HL,TTEMPO       ;CONTADOR TEMPO
                INC     [HL]
                LD      A,[TEMPO]
                CP      [HL]
                JR      NZ,PAUTAS
                LD      [HL],0
               
;INTERPRETA     
                LD      IY,PSG_REG
                LD      IX,PUNTERO_A
                LD      BC,PSG_REG+8
                CALL    LOCALIZA_NOTA
                LD      IY,PSG_REG+2
                LD      IX,PUNTERO_B
                LD      BC,PSG_REG+9
                CALL    LOCALIZA_NOTA
                LD      IY,PSG_REG+4
                LD      IX,PUNTERO_C
                LD      BC,PSG_REG+10
                CALL    LOCALIZA_NOTA
                LD      IX,PUNTERO_P    ;EL CANAL DE EFECTOS ENMASCARA OTRO CANAL
                CALL    LOCALIZA_EFECTO             

;PAUTAS
               
PAUTAS:         LD      IY,PSG_REG+0
                LD      IX,PUNTERO_P_A
                LD      HL,PSG_REG+8
                CALL    PAUTA           ;PAUTA CANAL A
                LD      IY,PSG_REG+2
                LD      IX,PUNTERO_P_B
                LD      HL,PSG_REG+9
                CALL    PAUTA           ;PAUTA CANAL B
                LD      IY,PSG_REG+4
                LD      IX,PUNTERO_P_C
                LD      HL,PSG_REG+10
                CALL    PAUTA           ;PAUTA CANAL C

                RET
               
;REPRODUCE EFECTOS DE SONIDO

REPRODUCE_SONIDO:

                LD      HL,INTERR   
                BIT     2,[HL]          ;ESTA ACTIVADO EL EFECTO?
                RET     Z
                LD      HL,[PUNTERO_SONIDO]
                LD      A,[HL]
                CP      $FF
                JR      Z,FIN_SONIDO
                LD      [PSG_REG+0],A
                INC     HL
                LD      A,[HL]
                RRCA
                RRCA
                RRCA
                RRCA
                AND     00001111B
                LD      [PSG_REG+1],A
                LD      A,[HL]
                AND     00001111B
                LD      [PSG_REG+8],A
                INC     HL
                LD      A,[HL]
                AND     A
                JR      Z,NO_RUIDO
                LD      [PSG_REG+6],A
                ;         XXCBAXXX
                LD      A,10011000B
                JR      SI_RUIDO
NO_RUIDO:       LD      A,10111000B
SI_RUIDO:       LD      [PSG_REG+7],A
       
                INC     HL
                LD      [PUNTERO_SONIDO],HL
                RET
FIN_SONIDO:     LD      HL,INTERR
                RES     2,[HL]

FIN_NOPLAYER:   XOR     A
                LD      [PSG_REG+0],A
                LD      [PSG_REG+1],A
                LD      A,10111000B
                LD      [PSG_REG+7],A
                RET

;VUELCA BUFFER DE SONIDO AL PSG

ROUT:          ; LD   A,[PSG_REG+0]
               ; XOR   1
               ; LD   [PSG_REG+0],A

                XOR     A
ROUT_A0:        LD      DE,$FFBF
                LD      BC,$FFFD
                LD      HL,PSG_REG
LOUT:           OUT     (C),A
                LD      B,E
                OUTI
                LD      B,D
                INC     A
                CP      13
                JR      NZ,LOUT
                OUT     (C),A
                LD      A,[HL]
                AND     A
                RET     Z
                LD      B,E
                OUT     (C),A
                XOR     A
                LD      [PSG_REG+13],A
                RET


;LOCALIZA NOTA CANAL A
;IN [PUNTERO_A]

LOCALIZA_NOTA:  LD      L,[IX+0]       ;HL=[PUNTERO_A_C_B]
                LD      H,[IX+1]
                LD      A,[HL]
                AND     11000000B      ;COMANDO?
                CP      11000000B
                JR      NZ,LNJP0

;BIT[0]=INSTRUMENTO
               
COMANDOS:       LD      A,[HL]
                BIT     0,A             ;INSTRUMENTO
                JR      Z,COM_EFECTO

                INC     HL
                LD      A,[HL]          ;Nº DE PAUTA
                INC     HL
                LD      [IX+00],L
                LD      [IX+01],H
                LD      HL,TABLA_PAUTAS
                CALL    EXT_WORD
                LD      [IX+18],L
                LD      [IX+19],H
                LD      [IX+12],L
                LD      [IX+13],H
                LD      L,C
                LD      H,B
                RES     4,[HL]        ;APAGA EFECTO ENVOLVENTE ********** TEMPÒRAL
                XOR     A
                LD      [PSG_REG+13],A
                JR      LOCALIZA_NOTA

COM_EFECTO:     BIT     1,A             ;EFECTO DE SONIDO
                JR      Z,COM_ENVOLVENTE

                INC     HL
                LD      A,[HL]
                INC     HL
                LD      [IX+00],L
                LD      [IX+01],H
                CALL    INICIA_SONIDO
                RET

COM_ENVOLVENTE: BIT     2,A
                RET     Z               ;IGNORA - ERROR

           
                INC     HL
                LD      [IX+00],L
                LD      [IX+01],H
                LD      L,C
                LD      H,B
                SET     4,[HL]          ;ENCIEN EFECTO ENVOLVENTE ********** TEMPÒRAL
                JR      LOCALIZA_NOTA

             
LNJP0:          LD      A,[HL]
                INC     HL
                BIT     7,A
                JR      Z,NO_FIN_CANAL_A
                LD      L,[IX+6]        ;HL=[CANAL_A_B_C] REINICIA CANAL
                LD      H,[IX+7]
                LD      [IX+00H],L
                LD      [IX+01H],H
                JR      LOCALIZA_NOTA
               
NO_FIN_CANAL_A: LD      [IX+0],L        ;[PUNTERO_A_B_C]=HL GUARDA PUNTERO
                LD      [IX+1],H
                AND     A               ;NO REPRODUCE NOTA SI NOTA=0
                JR      Z,FIN_RUTINA
                BIT     6,A             ;SILENCIO?
                JR      Z,NO_SILENCIO_A
                XOR     A
                LD   [BC],A
                LD   [PSG_REG+13],A   ;ENVOLVENTE OFF
                CALL    NOTA
                RET
NO_SILENCIO_A:
                CALL    NOTA            ;REPRODUCE NOTA

                LD      L,[IX+18]       ; HL=[PUNTERO_P_A0] RESETEA PAUTA
                LD      H,[IX+19]
                LD      [IX+12],L       ;[PUNTERO_P_A]=HL
                LD      [IX+13],H
FIN_RUTINA:     RET

;LOCALIZA EFECTO
;IN HL=[PUNTERO_P]

LOCALIZA_EFECTO:LD      L,[IX+0]       ;HL=[PUNTERO_P]
                LD      H,[IX+1]
                LD      A,[HL]
                CP      11000010B
                JR      NZ,LEJP0

                INC     HL
                LD      A,[HL]
                INC     HL
                LD      [IX+00],L
                LD      [IX+01],H
                CALL    INICIA_SONIDO
                RET
           
             
LEJP0:          INC     HL
                BIT     7,A
                JR      Z,NO_FIN_CANAL_P
                LD      L,[IX+2]        ;HL=[CANAL_P] REINICIA CANAL
                LD      H,[IX+3]
                LD      [IX+00H],L
                LD      [IX+01H],H
                JR      LOCALIZA_EFECTO
               
NO_FIN_CANAL_P: LD      [IX+0],L        ;[PUNTERO_A_B_C]=HL GUARDA PUNTERO
                LD      [IX+1],H
                RET

; PAUTA DE LOS 3 CANALES
; IN:[IX]:PUNTERO DE LA PAUTA
;    [HL]:REGISTRO DE VOLUMEN
;    [IY]:REGISTROS DE FRECUENCIA

PAUTA:         
                BIT     4,[HL]        ;SI LA ENVOLVENTE ESTA ACTIVADA NO ACTUA PAUTA
                RET     NZ
                PUSH   HL
                LD      L,[IX+0]
                LD      H,[IX+1]
                LD      A,[HL]
               
                BIT     7,A      ;LOOP
                JR      Z,PCAJP0
                AND     00001111B       ;LOOP PAUTA [0,15]
                LD      D,0
                LD      E,A
                SBC     HL,DE
                LD      A,[HL]

PCAJP0:         BIT   6,A      ;OCTAVA -1
                JR   Z,PCAJP1
                LD   E,[IY+0]
                LD   D,[IY+1]

                RR   D
                RR   E
                LD   [IY+0],E
                LD   [IY+1],D
                JR   PCAJP2

PCAJP1:         BIT   5,A      ;OCTAVA +1
                JR   Z,PCAJP2
                LD   E,[IY+0]
                LD   D,[IY+1]
            
                RL   E
                RL   D
                LD   [IY+0],E
                LD   [IY+1],D      


PCAJP2:         INC     HL
                LD      [IX+0],L
                LD      [IX+1],H
                POP   HL
                AND   00001111B
                LD      [HL],A
                RET

;NOTA : REPRODUCE UNA NOTA
;IN [A]=CODIGO DE LA NOTA
;   [IY]=REGISTROS DE FRECUENCIA


NOTA:           LD      L,C
                LD      H,B
                BIT     4,[HL]
                JR      NZ,EVOLVENTES
                LD      B,A
                LD      HL,DATOS_NOTAS
                RLCA                    ;X2
                LD      D,0
                LD      E,A
                ADD     HL,DE
                LD      A,[HL]
                LD      [IY+0],A
                INC     HL
                LD      A,[HL]
                LD      [IY+1],A
                RET

;IN [A]=CODIGO DE LA ENVOLVENTE
;   [IY]=REGISTRO DE FRECUENCIA

EVOLVENTES:     LD      HL,DATOS_ENV
                LD      E,A
                LD      D,0
                ADD     HL,DE
                LD      A,[HL]
                LD      [PSG_REG+11],A
                LD      A,$0C
                LD      [PSG_REG+13],A
                XOR     A
                LD      [IY+0],A
                LD      [IY+1],A
                LD      [PSG_REG+12],A
                RET




                ;SOUND C,A

;SOUND:          PUSH    AF
;                LD      A,C
;                OUT     [$A0],A
;                POP     AF
;                OUT     [$A1],A
;                RET

;LEE REGISTRO PSG
;IN  [A]=REGISTRO
;OUT [A]=VALOR

;IN_SOUND:       OUT     [$A0],A
;                IN      A,[$A2]
;                RET

;EXTRAE UN WORD DE UNA TABLA
;IN:[HL]=DIRECCION TABLA
;   [A]= POSICION
;OUT[HL]=WORD

EXT_WORD:       LD      D,0
                SLA     A               ;*2
                LD      E,A
                ADD     HL,DE
                LD      E,[HL]
                INC     HL
                LD      D,[HL]
                EX      DE,HL
                RET


; *************************************************************************************************************************

;INICIA EL SONIDO Nº [B] EN EL CANAL [C]

INICIA_EFECTO:  ;LD A,10111000b
                ;LD [PSG_REG+7],A

                LD   A,C
                CP   0
                JP   Z,INICIA_EFECTO_A
                CP   1
                JP   Z,INICIA_EFECTO_B
                CP   2
                JP   Z,INICIA_EFECTO_C
                RET
;________________________________________________________


;REPRODUCE_EFECTO:

;                CALL   REPRODUCE_EFECTO_A
;                CALL   REPRODUCE_EFECTO_B
;                CALL   REPRODUCE_EFECTO_C
;                CALL   ROUT
;                RET

;________________________________________________________

INICIA_EFECTO_A:LD      A,B
                LD      HL,TABLA_EFECTOS
                CALL    EXT_WORD
                LD      [PUNTERO_EFECTO_A],HL
                LD      HL,INTERR
                SET     3,[HL]
                RET


;REPRODUCE EFECTOS CANAL A

REPRODUCE_EFECTO_A:
                LD      HL,INTERR
                BIT     3,[HL]          ;ESTA ACTIVADO EL EFECTO?
                RET     Z
                LD      HL,[PUNTERO_EFECTO_A]
                LD      A,[HL]
                CP      $FF
                JR      Z,FIN_EFECTO_A
                LD      [PSG_REG+0],A
                INC     HL
                LD      A,[HL]
                RRCA
                RRCA
                RRCA
                RRCA
                AND     00001111B
                LD      [PSG_REG+1],A
                LD      A,[HL]
                AND     00001111B
                LD      [PSG_REG+8],A

                INC     HL
                LD      [PUNTERO_EFECTO_A],HL
                RET
FIN_EFECTO_A:   LD      HL,INTERR
                RES     3,[HL]
                XOR     A
                LD      [PSG_REG+0],A
                LD      [PSG_REG+1],A
                LD   [PSG_REG+8],A
                RET

;________________________________________________________

INICIA_EFECTO_B:
                LD   A,B
                LD      HL,TABLA_EFECTOS
                CALL    EXT_WORD
                LD      [PUNTERO_EFECTO_B],HL
                LD      HL,INTERR
                SET     4,[HL]
                RET

;REPRODUCE EFECTOS CANAL B

REPRODUCE_EFECTO_B:

                LD      HL,INTERR
                BIT     4,[HL]          ;ESTA ACTIVADO EL EFECTO?
                RET     Z
                LD      HL,[PUNTERO_EFECTO_B]
                LD      A,[HL]
                CP      $FF
                JR      Z,FIN_EFECTO_B
                LD      [PSG_REG+2],A
                INC     HL
                LD      A,[HL]
                RRCA
                RRCA
                RRCA
                RRCA
                AND     00001111B
                LD      [PSG_REG+3],A
                LD      A,[HL]
                AND     00001111B
                LD      [PSG_REG+9],A
       
                INC     HL
                LD      [PUNTERO_EFECTO_B],HL
                RET
FIN_EFECTO_B:   LD      HL,INTERR
                RES     4,[HL]
                XOR     A
                LD      [PSG_REG+2],A
                LD      [PSG_REG+3],A
                LD   [PSG_REG+9],A
                RET

;________________________________________________________

INICIA_EFECTO_C:
                LD   A,B
                LD      HL,TABLA_EFECTOS
                CALL    EXT_WORD
                LD      [PUNTERO_EFECTO_C],HL
                LD      HL,INTERR
                SET     5,[HL]
                RET

;REPRODUCE EFECTOS CANAL C

REPRODUCE_EFECTO_C:

                LD      HL,INTERR
                BIT     5,[HL]          ;ESTA ACTIVADO EL EFECTO?
                RET     Z
                LD      HL,[PUNTERO_EFECTO_C]
                LD      A,[HL]
                CP      $FF
                JR      Z,FIN_EFECTO_C
                LD      [PSG_REG+4],A
                INC     HL
                LD      A,[HL]
                RRCA
                RRCA
                RRCA
                RRCA
                AND     00001111B
                LD      [PSG_REG+5],A
                LD      A,[HL]
                AND     00001111B
                LD      [PSG_REG+10],A
       
                INC     HL
                LD      [PUNTERO_EFECTO_C],HL
                RET
FIN_EFECTO_C:   LD      HL,INTERR
                RES     5,[HL]
                XOR     A       
                LD      [PSG_REG+4],A
                LD      [PSG_REG+5],A
                LD      [PSG_REG+10],A
                RET       

;________________________________________________________

;FX Nº:         0   1   2   3   4   5   6   7   8   9           A

TABLA_EFECTOS:  DW  EFECTO0, EFECTO1, EFECTO2, EFECTO3, EFECTO4, EFECTO5, EFECTO6, EFECTO7, EFECTO8

; Y estos son los efectos empleados en el juego:

; [0] Caída del salto
EFECTO0:		DB 	$51,$1A
				DB 	$E8,$1B
				DB 	$80,$2B
				DB 	$FF   
				
; [1] Quitar vida
EFECTO1:		DB 	$25,$1C
				DB 	$30,$2E
				DB	$00,$00
				DB	$A8,$0A
				DB	$C5,$1A
				DB	$00,$00
				DB	$37,$1C
				DB	$C5,$1C
				DB	$00,$00
				DB	$25,$18
				DB	$30,$26
				DB	$FF
				
; [2] Arrastrar en cinta
EFECTO2:		DB	$80,$2E,$00
				DB	$00,$0A,$04
				DB	$FF	
				
; [3] Coger tesoro
EFECTO3:		DB	$1F,$0B
				DB	$1A,$0C
				DB	$1F,$0D
				DB	$16,$0E
				DB	$1F,$0E
				DB	$0D,$0D
				DB	$1F,$0C
				DB	$0D,$0B
				DB	$00,$00
				DB	$00,$00
				DB	$1F,$08
				DB	$1A,$09
				DB	$1F,$0A
				DB	$16,$0B
				DB	$1F,$0B
				DB	$0D,$0A
				DB	$1F,$09
				DB	$0D,$07
				DB	$00,$00
				DB	$00,$00
				DB	$1F,$06
				DB	$1A,$07
				DB	$1F,$08
				DB	$16,$08
				DB	$1F,$07
				DB	$0D,$06
				DB	$1F,$05
				DB	$FF
	
; [4] ?
EFECTO4:		DB	$00,$0C,$03
				DB	$FF
				
; [5] Coger vida
EFECTO5:		DB	$1A,$0E
				DB	$1A,$0E
				DB	$00,$00
				DB	$1A,$0A
				DB	$1A,$0A
				DB	$00,$00
				DB	$1A,$0C
				DB	$1A,$0C
				DB	$00,$00
				DB	$1A,$08
				DB	$1A,$08
				DB	$FF
				
; [6] ?
EFECTO6:		DB	$00,$2C,$00
				DB	$00,$0A,$04
				DB	$FF	
				
; [7] Salto largo
EFECTO7:		DB	$C3,$0E
				DB	$CC,$0D
				DB	$D5,$0A
				DB	$DE,$06
				DB	$35,$03
				DB	$50,$0B
				DB	$47,$0C
				DB	$3E,$08
				DB	$FF
				
; [8] Salto alto
EFECTO8:		DB	$58,$0D
				DB	$50,$0B
				DB	$47,$0A
				DB	$3E,$06
				DB	$35,$03
				DB	$50,$09
				DB	$47,$0A
				DB	$3E,$07
				DB	$FF	
               
; AQUÍ VAN LOS DATOS DE LOS EFECTOS. HAY QUE ACORDARSE DE AÑADIR LA ETIQUETA A LA TABLA TABLA_EFECTOS QUE 
; HAY JUSTO ARRIBA DE ESTE TEXTO <****>

;EFECTOS

N_EFECTO:        DB      0             ;DB : NUMERO DE SONIDO
PUNTERO_EFECTO_A:DW      0             ;DW : PUNTERO DEL SONIDO QUE SE REPRODUCE
PUNTERO_EFECTO_B:DW      0             ;DW : PUNTERO DEL SONIDO QUE SE REPRODUCE
PUNTERO_EFECTO_C:DW      0             ;DW : PUNTERO DEL SONIDO QUE SE REPRODUCE

;BANCO DE INSTRUMENTOS 2 BYTES POR INT.

;[0][RET 2 OFFSET]
;[1][+-PITCH]

;BANCO DE INSTRUMENTOS 2 BYTES POR INT.

;[0][RET 2 OFFSET]
;[1][+-PITCH]


; A partir de aquí es donde se incluyen los tiestos específicos para 
; cada juego: los datos con los efectos de sonido y las canciones
; generadas del WYZ Tracker de Agus.


;*************************************************************
;** PAUTAS                                                  **
;*************************************************************

TABLA_PAUTAS:   DW  PAUTA_2,PAUTA_3,PAUTA_4,PAUTA_5,PAUTA_6,PAUTA_7,PAUTA_8,PAUTA_9,PAUTA_10 ;,PAUTA_11,PAUTA_12,PAUTA_13

PAUTA_2:	DB	46,13,12,11,129
PAUTA_3:	DB	8,74,11,43,10,72,8,40,8,132
PAUTA_4:	DB	4,71,8,40,8,70,5,37,5,69,132
PAUTA_5:	DB	72,10,11,12,11,10,9,8,129
PAUTA_6:	DB	69,6,7,7,5,5,129
PAUTA_7:	DB	5,70,6,37,4,3,129
PAUTA_8:	DB	43,12,12,12,12,11,11,11,11,10,10,10,10,11,11,11,11,144
PAUTA_9:	DB	78,44,10,8,7,129
PAUTA_10:	DB	75,41,8,7,6,129

;*************************************************************
;** EFECTOS DE SONIDO                                       **
;*************************************************************

TABLA_SONIDOS:  DW      SONIDO1,SONIDO2,SONIDO3,SONIDO4 ;,SONIDO5,SONIDO6,SONIDO7,SONIDO8, SONIDO9,SONIDO10,SONIDO11

; Estos son los sonidos que exporta el Tracker de Augus y que se corresponden con las bateras:

SONIDO1:	DB	209,63,0,209,78,0,69,109,0,255
SONIDO2:	DB	69,47,0,232,44,5,0,57,2,255
SONIDO3:	DB	0,11,1,0,6,1,255
SONIDO4:	DB	186,58,0,0,102,0,162,131,0,255

;*************************************************************
;** CANCIONES                                               **
;*************************************************************

;TABLA_SONG:     DW      SONG_0, SONG_1, SONG_2 , SONG_3, SONG_4, SONG_5, SONG_6, SONG_7, SONG_8, SONG_9          

;*************************************************************
;** NOTAS Y ENVOLVENTES                                     **
;*************************************************************

DATOS_NOTAS:    INCBIN "NOTAS.DAT"        ;DATOS DE LAS NOTAS
DATOS_ENV:      INCBIN "ENV.DAT"          ;DATOS DE LAS ENVOLVENTES

; INCLUIR AQUÍ LOS FICHEROS DE LAS CANCIONES. ACORDÁNDOSE DE PONER LAS ETIQUETAS 
; EN LA TABLA TABLA_SONG UNAS LINEAS MÁS ARRIBA DE ESTE TEXTO <****>



; VARIABLES__________________________

INTERR:         DB     00               ;INTERRUPTORES 1=ON 0=OFF
                                        ;BIT 0=CARGA CANCION ON/OFF
                                        ;BIT 1=PLAYER ON/OFF
                                        ;BIT 2=SONIDOS ON/OFF
                                        ;BIT 3=EFECTOS ON/OFF

;MUSICA **** EL ORDEN DE LAS VARIABLES ES FIJO ******



;SONG:           DB     00               ;DBNº DE CANCION
TEMPO:          DB     00               ;DB TEMPO
TTEMPO:         DB     00               ;DB CONTADOR TEMPO
PUNTERO_A:      DW     00               ;DW PUNTERO DEL CANAL A
PUNTERO_B:      DW     00               ;DW PUNTERO DEL CANAL B
PUNTERO_C:      DW     00               ;DW PUNTERO DEL CANAL C

CANAL_A:        DW     BUFFER_DEC       ;DW DIRECION DE INICIO DE LA MUSICA A
CANAL_B:        DW     00               ;DW DIRECION DE INICIO DE LA MUSICA B
CANAL_C:        DW     00               ;DW DIRECION DE INICIO DE LA MUSICA C

PUNTERO_P_A:    DW     00               ;DW PUNTERO PAUTA CANAL A
PUNTERO_P_B:    DW     00               ;DW PUNTERO PAUTA CANAL B
PUNTERO_P_C:    DW     00               ;DW PUNTERO PAUTA CANAL C

PUNTERO_P_A0:   DW     00               ;DW INI PUNTERO PAUTA CANAL A
PUNTERO_P_B0:   DW     00               ;DW INI PUNTERO PAUTA CANAL B
PUNTERO_P_C0:   DW     00               ;DW INI PUNTERO PAUTA CANAL C

;CANAL DE EFECTOS - ENMASCARA OTRO CANAL

PUNTERO_P:      DW     00              ;DW PUNTERO DEL CANAL EFECTOS
CANAL_P:        DW     00              ;DW DIRECION DE INICIO DE LOS EFECTOS

PSG_REG:        DB     00,00,00,00,00,00,00,10111000B,00,00,00,00,00,00,00    ;DB [11] BUFFER DE REGISTROS DEL PSG

;ENVOLVENTE_A    EQU     $D033           ;DB
;ENVOLVENTE_B    EQU     $D034           ;DB
;ENVOLVENTE_C    EQU     $D035           ;DB

;EFECTOS DE SONIDO

N_SONIDO:       DB      0               ;DB : NUMERO DE SONIDO
PUNTERO_SONIDO: DW      0               ;DW : PUNTERO DEL SONIDO QUE SE REPRODUCE

;EFECTOS

PUNTERO_EFECTO: DW      0               ;DW : PUNTERO DEL SONIDO QUE SE REPRODUCE

;BUFFER_DEC:     DB      $00      

;************************* mucha atencion!!!!
; aqui se decodifica la cancion hay que dejar suficiente espacio libre.
;*************************

; Esto va en su propia página, asín que queda hasta el final de la RAM :P
MDLADDR EQU $
	endmodule
