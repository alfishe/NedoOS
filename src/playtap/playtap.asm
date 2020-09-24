        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

buffer=0x4000

        org PROGSTART
cmd_begin
        ld sp,0x4000
        ld e,6+8 ;textmode +noturbo
        OS_SETGFX
        YIELD
        YIELD
        
        ld de,filename
        OS_OPENHANDLE
        ld a,b
        ld (curhandle),a
taploop0
        ld de,sizer
        ld hl,3
curhandle=$+1
        ld b,0
        push hl
        OS_READHANDLE
        pop bc
        or a
        jr nz,taploop0q ;file error!
        or a
        sbc hl,bc
        ld a,h
        or l
        jr nz,taploop0q ;file too short!
        
        ld de,buffer
        ld hl,(sizer)
        dec hl ;flag byte is already loaded
        ld a,(curhandle)
        ld b,a
        push hl
        OS_READHANDLE
        pop bc
        or a
        jr nz,taploop0q ;file error!
        or a
        sbc hl,bc
        ld a,h
        or l
        jr nz,taploop0q ;file too short!
        
        ld ix,buffer
        ld de,(sizer)
        dec de
        dec de
        ld a,(sizer+2) ;flag
        call L04C2

        LD B,50
        HALT
        DJNZ $-1

        jr taploop0
taploop0q
        ld a,(curhandle)
        ld b,a
        OS_CLOSEHANDLE
quit
        QUIT

filename
        db "tilt.tap",0
        ds filename+MAXPATH_sz-$

sizer
        ds 3 ;2b size, 1b flag


;The .TAP files contain blocks of tape-saved data. All blocks start with two bytes specifying how many bytes will follow (not counting the two length bytes). Then raw tape data follows, including the flag and checksum bytes. The checksum is the bitwise XOR of all bytes including the flag byte. For example, when you execute the line SAVE "ROM" CODE 0,2 this will result:

      ;|------ Spectrum-generated data -------|      |---------|

;13 00 00 03 52 4f 4d 7x20 02 00 00 00 00 80 f1 04 00 ff f3 af a3

;^^^^^...... first block is 19 bytes (17 bytes+flag+checksum)
      ;^^... flag byte (A reg, 00 for headers, ff for data blocks)
         ;^^ first byte of header, indicating a code block

;file name ..^^^^^^^^^^^^^
;header info ..............^^^^^^^^^^^^^^^^^
;checksum of header .........................^^
;length of second block ........................^^^^^
;flag byte ...........................................^^
;first two bytes of rom .................................^^^^^
;checksum (checkbittoggle would be a better name!).............^^

;Note that it is possible to join .TAP files by simply stringing them together; for example, in DOS / Windows: COPY /B FILE1.TAP + FILE2.TAP ALL.TAP ; or in Unix/Linux: cp file1.tap all.tap && cat file2.tap >> all.tap

;For completeness, I'll include the structure of a tape header. A header always consists of 17 bytes:
;Byte Length Description
;0 1 Type (0,1,2 or 3)
;1 10 Filename (padded with blanks)
;11 2 Length of data block
;13 2 Parameter 1
;15 2 Parameter 2

;The type is 0,1,2 or 3 for a Program, Number array, Character array or Code file. A SCREEN$ file is regarded as a Code file with start address 16384 and length 6912 decimal. If the file is a Program file, parameter 1 holds the autostart line number (or a number >=32768 if no LINE parameter was given) and parameter 2 holds the start of the variable area relative to the start of the program. If it's a Code file, parameter 1 holds the start of the code block when saved, and parameter 2 holds 32768. For data files finally, the byte at position 14 decimal holds the variable name. 

;-----------------------------------
; Save header and program/data bytes
;-----------------------------------
;
;

;; SA-BYTES
L04C2   LD      HL,L053F        ; address: SA/LD-RET
        PUSH    HL              ;
        LD      HL,$1F80        ;
        BIT     7,A             ;
        JR      Z,L04D0         ; to SA-FLAG

        LD      HL,$0C98        ;

;; SA-FLAG
L04D0   EX      AF,AF'          ;
        INC     DE              ;
        DEC     IX              ;
        DI                      ; Disable Interrupts
        LD      A,$02           ;
        LD      B,A             ;

;; SA-LEADER
L04D8   DJNZ    L04D8           ; to SA-LEADER

        OUT     ($FE),A         ;
        XOR     $0F             ;
        LD      B,$A4           ;
        DEC     L               ;
        JR      NZ,L04D8        ; to SA-LEADER

        DEC     B               ;
        DEC     H               ;
        JP      P,L04D8         ; to SA-LEADER

        LD       B,$2F          ;

;; SA-SYNC-1
L04EA   DJNZ    L04EA           ; to SA-SYNC-1

        OUT     ($FE),A         ;
        LD      A,$0D           ;
        LD      B,$37           ;

;; SA-SYNC-2
L04F2   DJNZ    L04F2           ; to SA-SYNC-2

        OUT     ($FE),A         ;
        LD      BC,$3B0E        ;
        EX      AF,AF'          ;
        LD      L,A             ;
        JP      L0507           ; to SA-START

;; SA-LOOP
L04FE   LD      A,D             ;
        OR      E               ;
        JR      Z,L050E         ; to SA-PARITY

        LD      L,(IX+$00)      ;

;; SA-LOOP-P
L0505   LD      A,H             ;
        XOR     L               ;

;; SA-START
L0507   LD      H,A             ;
        LD      A,$01           ;
        SCF                     ; Set Carry Flag
        JP      L0525           ; to SA-8-BITS

;; SA-PARITY
L050E   LD      L,H             ;
        JR      L0505           ; to SA-LOOP-P

;; SA-BIT-2
L0511   LD      A,C             ;
        BIT     7,B             ;

;; SA-BIT-1
L0514   DJNZ    L0514           ; to SA-BIT-1

        JR      NC,L051C        ; to SA-OUT

        LD      B,$42           ;

;; SA-SET
L051A   DJNZ    L051A           ; to SA-SET

;; SA-OUT
L051C   OUT     ($FE),A         ;
        LD      B,$3E           ;
        JR      NZ,L0511        ; to SA-BIT-2

        DEC     B               ;
        XOR     A               ;
        INC     A               ;

;; SA-8-BITS
L0525   RL      L               ;
        JP      NZ,L0514        ; to SA-BIT-1

        DEC     DE              ;
        INC     IX              ;
        LD      B,$31           ;
        LD      A,$7F           ;
        IN      A,($FE)         ;
        RRA                     ;
        RET     NC              ;

        LD      A,D             ;
        INC     A               ;
        JP      NZ,L04FE        ; to SA-LOOP

        LD      B,$3B           ;

;; SA-DELAY
L053C   DJNZ    L053C           ; to SA-DELAY

        RET                     ;

;---------------------------------------------------
; Reset border and check BREAK key for LOAD and SAVE
;---------------------------------------------------
;
;

;; SA/LD-RET
L053F   PUSH    AF              ;
        LD       A,($5C48)      ; BORDCR
        AND     $38             ;
        RRCA                    ;
        RRCA                    ;
        RRCA                    ;
        OUT     ($FE),A         ;
        LD      A,$7F           ;
        IN      A,($FE)         ;
        RRA                     ;
        EI                      ; Enable Interrupts
        JR      C,L0554         ; to SA/LD-END


;; REPORT-Da
;L0552   RST     08H             ; ERROR-1
;        DEFB    $0C             ; Error Report: BREAK - CONT repeats
        jp quit

;; SA/LD-END
L0554   POP     AF              ;
        RET                     ;

        if 1==0
;-------------------------------------
; Load header and block of information
;-------------------------------------
;
;

;; LD-BYTES
L0556   INC     D               ;
        EX      AF,AF'          ;
        DEC     D               ;
        DI                      ; Disable Interrupts
        LD      A,$0F           ;
        OUT     ($FE),A         ;
        LD      HL,L053F        ; Address: SA/LD-RET
        PUSH    HL              ;
        IN      A,($FE)         ;
        RRA                     ;
        AND     $20             ;
        OR      $02             ;
        LD      C,A             ;
        CP      A               ;

;; LD-BREAK
L056B   RET     NZ              ;

;; LD-START
L056C   CALL    L05E7           ; routine LD-EDGE-1
        JR      NC,L056B        ; to LD-BREAK

        LD      HL,$0415        ;

;; LD-WAIT
L0574   DJNZ    L0574           ; to LD-WAIT

        DEC     HL              ;
        LD      A,H             ;
        OR      L               ;
        JR      NZ,L0574        ; to LD-WAIT

        CALL    L05E3           ; routine LD-EDGE-2
        JR      NC,L056B        ; to LD-BREAK

;; LD-LEADER
L0580   LD      B,$9C           ;
        CALL    L05E3           ; routine LD-EDGE-2
        JR      NC,L056B        ; to LD-BREAK

        LD      A,$C6           ;
        CP      B               ;
        JR      NC,L056C        ; to LD-START

        INC     H               ;
        JR      NZ,L0580        ; to LD-LEADER

;; LD-SYNC
L058F   LD      B,$C9           ;
        CALL    L05E7           ; routine LD-EDGE-1
        JR      NC,L056B        ; to LD-BREAK

        LD      A,B             ;
        CP      $D4             ;
        JR       NC,L058F       ; to LD-SYNC

        CALL    L05E7           ; routine LD-EDGE-1
        RET     NC              ;

        LD      A,C             ;
        XOR     $03             ;
        LD      C,A             ;
        LD      H,$00           ;
        LD      B,$B0           ;
        JR      L05C8           ; to LD-MARKER

;; LD-LOOP
L05A9   EX      AF,AF'          ;
        JR      NZ,L05B3        ; to LD-FLAG

        JR      NC,L05BD        ; to LD-VERIFY

        LD      (IX+$00),L      ;
        JR      L05C2           ; to LD-NEXT

;; LD-FLAG
L05B3   RL      C               ;
        XOR     L               ;
        RET     NZ              ;

        LD      A,C             ;
        RRA                     ;
        LD      C,A             ;
        INC     DE              ;
        JR      L05C4           ; to LD-DEC

;; LD-VERIFY
L05BD   LD      A,(IX+$00)      ;
        XOR     L               ;
        RET     NZ              ;

;; LD-NEXT
L05C2   INC     IX              ;

;; LD-DEC
L05C4   DEC     DE              ;
        EX      AF,AF'          ;
        LD      B,$B2           ;

;; LD-MARKER
L05C8   LD      L,$01           ;

;; LD-8-BITS
L05CA   CALL    L05E3           ; routine LD-EDGE-2
        RET     NC              ;

        LD      A,$CB           ;
        CP      B               ;
        RL      L               ;
        LD      B,$B0           ;
        JP      NC,L05CA        ; to LD-8-BITS

        LD      A,H             ;
        XOR     L               ;
        LD      H,A             ;
        LD      A,D             ;
        OR      E               ;
        JR      NZ,L05A9        ; to LD-LOOP

        LD      A,H             ;
        CP      $01             ;
        RET                     ;

;--------------------------
; Check signal being loaded
;--------------------------
;
;

;; LD-EDGE-2
L05E3   CALL    L05E7           ; routine LD-EDGE-1
        RET     NC              ;

;; LD-EDGE-1
L05E7   LD      A,$16           ;

;; LD-DELAY
L05E9   DEC     A               ;
        JR      NZ,L05E9        ; to LD-DELAY

        AND      A              ;

;; LD-SAMPLE
L05ED   INC     B               ;
        RET     Z               ;

        LD      A,$7F           ;
        IN      A,($FE)         ;
        RRA                     ;
        RET     NC              ;

        XOR     C               ;
        AND     $20             ;
        JR      Z,L05ED         ; to LD-SAMPLE

        LD      A,C             ;
        CPL                     ;
        LD      C,A             ;
        AND     $07             ;
        OR      $08             ;
        OUT     ($FE),A         ;
        SCF                     ; Set Carry Flag
        RET                     ;

;----------------------------------
; Entry point for all tape commands
;----------------------------------
; This is the single entry point for the four tape commands.
; The routine first determines in what context it has been called by examaning
; the low byte of the Syntax table entry which was stored in T_ADDR.
; Subtracting $EO (the present arrangement) gives a value of
; $00 - SAVE
; $01 - LOAD
; $02 - VERIFY
; $03 - MERGE
; As with all commands the address STMT-RET is on the stack.

;; SAVE-ETC
L0605   POP     AF              ; discard address STMT-RET.
        LD      A,($5C74)       ; fetch T_ADDR

; Now reduce the low byte of the Syntax table entry to give command.

L0609   SUB     L1ADF + 1 % 256 ; subtract the known offset.
                                ; ( is SUB $E0 in standard ROM )

        LD      ($5C74),A       ; and put back in T_ADDR as 0,1,2, or 3
                                ; for future reference.

        CALL    L1C8C           ; routine EXPT-EXP checks that a string
                                ; expression follows and stacks the
                                ; parameters in run-time.

        CALL    L2530           ; routine SYNTAX-Z
        JR      Z,L0652         ; forward to SA-DATA if checking syntax.

        LD      BC,$0011        ; presume seventeen bytes for a header.
        LD      A,($5C74)       ; fetch command from T_ADDR.
        AND     A               ; test for zero - SAVE.
        JR      Z,L0621         ; forward to SA-SPACE if so.

        LD      C,$22           ; else double length to thirty four.

;; SA-SPACE
L0621   RST     30H             ; BC-SPACES creates 17/34 bytes in workspace.

        PUSH    DE              ; transfer the start of new space to
        POP     IX              ; the available index register.

; ten spaces are required for the default filename but it is simpler to
; overwrite the first file-type indicator byte as well.

        LD      B,$0B           ; set counter to eleven.
        LD      A,$20           ; prepare a space.

;; SA-BLANK
L0629   LD      (DE),A          ; set workspace location to space.
        INC     DE              ; next location.
        DJNZ    L0629           ; loop back to SA-BLANK till all eleven done.

        LD      (IX+$01),$FF    ; invert the first byte of ten character
                                ; filename as a default.

        CALL    L2BF1           ; routine STK-FETCH fetches the filename
                                ; parameters from the calculator stack.
                                ; length of string in BC.

        LD      HL,$FFF6        ; prepare the value minus ten.
        DEC     BC              ; decrement length to range 0 - 9.
        ADD     HL,BC           ; trial addition.
        INC     BC              ; restore length.
        JR      NC,L064B        ; forward to SA-NAME if length is ten or less.

        LD      A,($5C74)       ; fetch command from T_ADDR.
        AND     A               ; test for zero - SAVE.
        JR      NZ,L0644        ; forward to SA-NULL if not the SAVE command.

; but only ten characters are allowed for SAVE.
; The first ten characters of any other command parameter are acceptable.
; Weird, but necessary, if saving to sectors.
; Note. the golden rule that there are no restriction on anything is broken.

;; REPORT-Fa
L0642   RST     08H             ; ERROR-1
        DEFB    $0E             ; Error Report: Invalid file name

; continue with LOAD, MERGE, VERIFY and SAVE within ten character limit.

;; SA-NULL
L0644   LD      A,B             ; test length
        OR      C               ; for zero.
        JR      Z,L0652         ; forward to SA-DATA if so.

        LD      BC,$000A        ; else set/limit length to ten.

;; SA-NAME
L064B   PUSH    IX              ; push start of file descriptor.
        POP     HL              ; and pop into HL.

        INC     HL              ; HL now addresses first byte of filename.
        EX      DE,HL           ; transfer destination address to DE, start
                                ; of string to HL.
        LDIR                    ; copy ten bytes

; the case for the null string rejoins here.

;; SA-DATA
L0652   RST     18H             ; GET-CHAR
        CP      $E4             ; is character the token 'DATA' ?
        JR      NZ,L06A0        ; forward to SA-SCR$ to consider SCREEN$ if
                                ; not.

; continue to consider DATA.

        LD      A,($5C74)       ; fetch command from T_ADDR
        CP      $03             ; is it 'VERIFY' ?
        JP      Z,L1C8A         ; jump forward to REPORT-C if so.
                                ; 'Nonsense in basic'

; continue with SAVE, LOAD, MERGE of DATA.

        RST     20H             ; NEXT-CHAR
        CALL    L28B2           ; routine LOOK-VARS searches variables area
                                ; returning with carry reset if found or
                                ; checking syntax.
        SET     7,C             ; signal result. ????
        JR      NC,L0672        ; forward to SA-V-OLD if found or syntax path.

        LD      HL,$0000        ;
        LD      A,($5C74)       ; fetch command from T_ADDR
        DEC     A               ; test for 1 - LOAD
        JR      Z,L0685         ; forward to SA-V-NEW with LOAD DATA.
                                ; It is allowable to load a saved array into
                                ; an array of a different name.

; otherwise the variable was not found in run-time with SAVE/MERGE.

;; REPORT-2a
L0670   RST     08H             ; ERROR-1
        DEFB    $01             ; Error Report: Variable not found

; continue with SAVE/LOAD/ DATA

;; SA-V-OLD
L0672   JP      NZ,L1C8A        ; to REPORT-C if not an array variable. ????
                                ; 'Nonsense in basic'


        CALL    L2530           ; routine SYNTAX-Z
        JR      Z,L0692         ; forward to SA-DATA-1 if checking syntax.

        INC     HL              ; step past single character variable name.
        LD      A,(HL)          ; fetch low byte of length.
        LD      (IX+$0B),A      ; place in descriptor.
        INC     HL              ; point to high byte.
        LD      A,(HL)          ; and transfer that
        LD      (IX+$0C),A      ; to descriptor.
        INC     HL              ; increase pointer within variable.

;; SA-V-NEW
L0685   LD      (IX+$0E),C      ; load 
        LD      A,$01           ; default to type ??
        BIT     6,C             ; test result
        JR      Z,L068F         ; forward to SA-V-TYPE if numeric.

        INC     A               ; set type to string.

;; SA-V-TYPE
L068F   LD      (IX+$00),A      ; place type 0, 1 or 2 in descriptor.

;; SA-DATA-1
L0692   EX      DE,HL           ; save var pointer in DE

        RST     20H             ; NEXT-CHAR
        CP      $29             ; is character ')'?
        JR      NZ,L0672        ; back if not to SA-V-OLD to


        RST     20H             ; NEXT-CHAR advances character address.
        CALL    L1BEE           ; routine CHECK-END errors if not end of
                                ; the statement.

        EX      DE,HL           ; bring back variables data pointer.
        JP      L075A           ; jump forward to SA-ALL

; ---
; the branch was here to consider a 'SCREEN$', the display file.

;; SA-SCR$
L06A0   CP      $AA             ; is character the token 'SCREEN$' ?
        JR      NZ,L06C3        ; forward to SA-CODE if not.

        LD      A,($5C74)       ; fetch command from T_ADDR
        CP      $03             ; is it MERGE ?
        JP       Z,L1C8A        ; jump to REPORT-C if so.
                                ; 'Nonsense in basic'

; continue with SAVE/LOAD/VERIFY SCREEN$.

        RST     20H             ; NEXT-CHAR
        CALL    L1BEE           ; routine CHECK-END errors if not end of
                                ; statement.

; continue in runtime.

        LD      (IX+$0B),$00    ; set descriptor length
        LD      (IX+$0C),$1B    ; to $1b00 to include bitmaps and attributes.

        LD      HL,$4000        ; set start to display file start.
        LD      (IX+$0D),L      ; place start in
        LD      (IX+$0E),H      ; the descriptor.
        JR      L0710           ; forward to SA-TYPE-3

; ---
; the branch was here to consider CODE.

;; SA-CODE
L06C3   CP      $AF             ; is character the token 'CODE' ?
        JR      NZ,L0716        ; forward if not to SA-LINE to consider an
                                ; auto-started basic program.

        LD      A,($5C74)       ; fetch command from T_ADDR
        CP      $03             ; is it MERGE ?
        JP      Z,L1C8A         ; jump forward to REPORT-C if so.
                                ; 'Nonsense in basic'


        RST     20H             ; NEXT-CHAR advances character address.
        CALL    L2048           ; routine PR-ST-END checks if a carriage
                                ; return or ':' follows.
        JR      NZ,L06E1        ; forward to SA-CODE-1 if there are parameters.

        LD      A,($5C74)       ; else fetch the command from T_ADDR.
        AND     A               ; test for zero - SAVE without a specification.
        JP      Z,L1C8A         ; jump to REPORT-C if so.
                                ; 'Nonsense in basic'

; for LOAD/VERIFY put zero on stack to signify handle at location saved from.

        CALL    L1CE6           ; routine USE-ZERO
        JR      L06F0           ; forward to SA-CODE-2

; ---
; if there are more characters after CODE expect start and possibly length.

;; SA-CODE-1
L06E1   CALL    L1C82           ; routine EXPT-1NUM checks for numeric
                                ; expression and stacks it in run-time.

        RST     18H             ; GET-CHAR
        CP      $2C             ; does a comma follow ?
        JR      Z,L06F5         ; forward if so to SA-CODE-3

; else allow saved code to be loaded to a specified address.

        LD      A,($5C74)       ; fetch command from T_ADDR.
        AND     A               ; is the command SAVE which requires length ?
        JP      Z,L1C8A         ; jump to REPORT-C if so.
                                ; 'Nonsense in basic'

; the command LOAD code may rejoin here with zero stacked as start.

;; SA-CODE-2
L06F0   CALL    L1CE6           ; routine USE-ZERO stacks zero for length.
        JR      L06F9           ; forward to SA-CODE-4

; ---
; the branch was here with SAVE CODE start, 

;; SA-CODE-3
L06F5   RST     20H             ; NEXT-CHAR advances character address.
        CALL    L1C82           ; routine EXPT-1NUM checks for exprssion
                                ; and stacks in run-time.

; paths converge here and nothing must follow.

;; SA-CODE-4
L06F9   CALL    L1BEE           ; routine CHECK-END errors with extraneous
                                ; characters and quits if checking syntax.

; in run-time there are two 16-bit parameters on the calculator stack.

        CALL    L1E99           ; routine FIND-INT2 gets length.
        LD      (IX+$0B),C      ; place length 
        LD      (IX+$0C),B      ; in descriptor.
        CALL    L1E99           ; routine FIND-INT2 gets start.
        LD      (IX+$0D),C      ; place start
        LD      (IX+$0E),B      ; in descriptor.
        LD      H,B             ; transfer the
        LD      L,C             ; start to HL also.

;; SA-TYPE-3
L0710   LD      (IX+$00),$03    ; place type 3 - code in descriptor. 
        JR      L075A           ; forward to SA-ALL.

; ---
; the branch was here with basic to consider an optional auto-start line
; number.

;; SA-LINE
L0716   CP      $CA             ; is character the token 'LINE' ?
        JR      Z,L0723         ; forward to SA-LINE-1 if so.

; else all possibilities have been considered and nothing must follow.

        CALL    L1BEE           ; routine CHECK-END

; continue in run-time to save basic without auto-start.

        LD      (IX+$0E),$80    ; place high line number in descriptor to
                                ; disable auto-start.
        JR      L073A           ; forward to SA-TYPE-0 to save program.

; ---
; the branch was here to consider auto-start.

;; SA-LINE-1
L0723   LD      A,($5C74)       ; fetch command from T_ADDR
        AND     A               ; test for SAVE.
        JP      NZ,L1C8A        ; to REPORT-C with anything else.
                                ; 'Nonsense in basic'

; 

        RST     20H             ; NEXT-CHAR
        CALL    L1C82           ; routine EXPT-1NUM checks for numeric
                                ; expression and stacks in run-time.
        CALL    L1BEE           ; routine CHECK-END quits if syntax path.
        CALL    L1E99           ; routine FIND-INT2 fetches the numeric
                                ; expression.
        LD      (IX+$0D),C      ; place the auto-start
        LD      (IX+$0E),B      ; line number in the descriptor.

; Note. this isn't checked, but is handled by system.
; If the user typed 40000 instead of 4000 then it won't auto-start
; at line 4000, or indeed, at all.

; continue to save program and any variables.

;; SA-TYPE-0
L073A   LD      (IX+$00),$00    ; place type zero - program in descriptor.
        LD      HL,($5C59)      ; fetch E_LINE to HL.
        LD      DE,($5C53)      ; fetch PROG to DE.
        SCF                     ; set carry flag to calculate from end of
                                ; variables E_LINE -1.
        SBC     HL,DE           ; subtract to give total length.

        LD      (IX+$0B),L      ; place total length
        LD      (IX+$0C),H      ; in descriptor.
        LD      HL,($5C4B)      ; load HL from system variable VARS
        SBC     HL,DE           ; subtract to give program length.
        LD      (IX+$0F),L      ; place length of program
        LD      (IX+$10),H      ; in the descriptor.
        EX      DE,HL           ; start to HL, length to DE.

;; SA-ALL
L075A   LD      A,($5C74)       ; fetch command from T_ADDR
        AND     A               ; test for zero - SAVE.
        JP      Z,L0970         ; jump forward to SA-CONTRL with SAVE  ->

; ---
; continue with LOAD, MERGE and VERIFY.

        PUSH    HL              ; save start.
        LD      BC,$0011        ; prepare to add seventeen
        ADD     IX,BC           ; to point IX at second descriptor.

;; LD-LOOK-H
L0767   PUSH    IX              ; save IX
        LD      DE,$0011        ; seventeen bytes
        XOR     A               ; reset zero flag
        SCF                     ; set carry flag
        CALL    L0556           ; routine LD-BYTES loads a header from tape
                                ; to second descriptor.
        POP     IX              ; restore IX.
        JR      NC,L0767        ; loop back to LD-LOOK-H until header found.

        LD      A,$FE           ; select system channel 'S'
                                ; user is at liberty to re-attach stream 2.
        CALL    L1601           ; routine CHAN-OPEN opens it.
        LD      (IY+$52),$03    ; set SCR_CT to 3 lines.
        LD      C,$80           ; C has bit 7 set.
        LD      A,(IX+$00)      ; fetch loaded header type to A
        CP      (IX-$11)        ; compare with expected type.
        JR      NZ,L078A        ; forward to LD-TYPE with mis-match.

        LD      C,$F6           ; 11110110  -10

;; LD-TYPE
L078A   CP      $04             ; check if type in acceptable range 0 - 3.
        JR      NC,L0767        ; back to LD-LOOK-H with 4 and over.

; else A indicates type 0-3.

        LD      DE,L09C0        ; base of last 4 tape messages
        PUSH    BC              ; save BC
        CALL    L0C0A           ; routine PO-MSG outputs relevant message.
        POP     BC              ; restore

        PUSH    IX              ; transfer IX,
        POP     DE              ; the 2nd descriptor, to DE.
        LD      HL,$FFF0        ; prepare minus seventeen.
        ADD     HL,DE           ; add to point HL to 1st descriptor.
        LD      B,$0A           ; the count will be ten characters for the
                                ; filename.
        LD      A,(HL)          ;
        INC     A               ;
        JR      NZ,L07A6        ; to LD-NAME

        LD      A,C             ;
        ADD     A,B             ;
        LD      C,A             ;

;; LD-NAME
L07A6   INC     DE              ; address next input name
        LD      A,(DE)          ; fetch character
        CP      (HL)            ; compare to expected
        INC     HL              ; address next expected character
        JR      NZ,L07AD        ; forward to LD-CH-PR with mismatch

        INC     C               ; increment count

;; LD-CH-PR
L07AD   RST     10H             ; PRINT-A-1 prints character
        DJNZ    L07A6           ; loop back to LD-NAME for ten characters.

        BIT     7,C             ; test if all matched
        JR      NZ,L0767        ; back to LD-LOOK-H if not

; else

        LD      A,$0D           ; prepare carriage return.
        RST     10H             ; PRINT-A-1 outputs it.

;

        POP     HL              ; restore xx
        LD      A,(IX+$00)      ; fetch incoming type 
        CP      $03             ; compare with code
        JR      Z,L07CB         ; forward to VR-CONTROL if equal

        LD      A,($5C74)       ; fetch command from T_ADDR
        DEC     A               ; was it LOAD ?
        JP      Z,L0808         ; jump forward to LD-CONTRL if so

        CP      $02             ; was command MERGE ?
        JP      Z,L08B6         ; jump forward to ME-CONTRL if so.

; else continue into VERIFY control routine.

;----------------------
; Handle VERIFY control
;----------------------
;
;

;; VR-CONTROL
L07CB   PUSH    HL              ;
        LD      L,(IX-$06)      ;
        LD      H,(IX-$05)      ;
        LD      E,(IX+$0B)      ;
        LD      D,(IX+$0C)      ;
        LD      A,H             ;
        OR      L               ;
        JR      Z,L07E9         ; to VR-CONT-1

        SBC     HL,DE           ;
        JR      C,L0806         ; to REPORT-R

        JR      Z,L07E9         ; to VR-CONT-1

        LD      A,(IX+$00)      ;
        CP      $03             ;
        JR      NZ,L0806        ; to REPORT-R

;; VR-CONT-1
L07E9   POP     HL              ;
        LD      A,H             ;
        OR      L               ;
        JR      NZ,L07F4        ; to VR-CONT-2

        LD      L,(IX+$0D)      ;
        LD      H,(IX+$0E)      ;

;; VR-CONT-2
L07F4   PUSH    HL              ;
        POP     IX              ;
        LD      A,($5C74)       ; T_ADDR
        CP      $02             ;
        SCF                     ; Set Carry Flag
        JR      NZ,L0800        ; to VR-CONT-3

        AND     A               ;

;; VR-CONT-3
L0800   LD      A,$FF           ;

;------------------
; Load a data block
;------------------
;
;

;; LD-BLOCK
L0802   CALL    L0556           ; routine LD-BYTES
        RET     C               ;


;; REPORT-R
L0806   RST     08H             ; ERROR-1
        DEFB    $1A             ; Error Report: Tape loading error

;--------------------
; Handle LOAD control
;--------------------
;
;

;; LD-CONTRL
L0808   LD      E,(IX+$0B)      ;
        LD      D,(IX+$0C)      ;
        PUSH    HL              ;
        LD      A,H             ;
        OR      L               ;
        JR      NZ,L0819        ; to LD-CONT-1

        INC     DE              ;
        INC     DE              ;
        INC     DE              ;
        EX      DE,HL           ;
        JR      L0825           ; to LD-CONT-2

;; LD-CONT-1
L0819   LD      L,(IX-$06)      ;
        LD      H,(IX-$05)      ;
        EX      DE,HL           ;
        SCF                     ; Set Carry Flag
        SBC     HL,DE           ;
        JR      C,L082E         ; to LD-DATA

;; LD-CONT-2
L0825   LD      DE,$0005        ;
        ADD     HL,DE           ;
        LD      B,H             ;
        LD      C,L             ;
        CALL    L1F05           ; routine TEST-ROOM

;; LD-DATA
L082E   POP     HL              ;
        LD      A,(IX+$00)      ;
        AND     A               ;
        JR      Z,L0873         ; to LD-PROG

        LD      A,H             ;
        OR      L               ;
        JR      Z,L084C         ; to LD-DATA-1

        DEC     HL              ;
        LD      B,(HL)          ;
        DEC     HL              ;
        LD      C,(HL)          ;
        DEC     HL              ;
        INC     BC              ;
        INC     BC              ;
        INC     BC              ;
        LD      ($5C5F),IX      ; X_PTR
        CALL    L19E8           ; routine RECLAIM-2
        LD      IX,($5C5F)      ; X_PTR

;; LD-DATA-1
L084C   LD      HL,($5C59)      ; E_LINE
        DEC     HL              ;
        LD      C,(IX+$0B)      ;
        LD      B,(IX+$0C)      ;
        PUSH    BC              ;
        INC     BC              ;
        INC     BC              ;
        INC     BC              ;
        LD      A,(IX-$03)      ;
        PUSH    AF              ;
        CALL    L1655           ; routine MAKE-ROOM
        INC     HL              ;
        POP     AF              ;
        LD      (HL),A          ;
        POP     DE              ;
        INC     HL              ;
        LD      (HL),E          ;
        INC     HL              ;
        LD      (HL),D          ;
        INC     HL              ;
        PUSH    HL              ;
        POP     IX              ;
        SCF                     ; Set Carry Flag
        LD      A,$FF           ;
        JP      L0802           ; to LD-BLOCK

;; LD-PROG
L0873   EX      DE,HL           ;
        LD      HL,($5C59)      ; E_LINE
        DEC     HL              ;
        LD      ($5C5F),IX      ; X_PTR
        LD      C,(IX+$0B)      ;
        LD      B,(IX+$0C)      ;
        PUSH    BC              ;
        CALL    L19E5           ; routine RECLAIM-1
        POP     BC              ;
        PUSH    HL              ;
        PUSH    BC              ;
        CALL    L1655           ; routine MAKE-ROOM
        LD      IX,($5C5F)      ; X_PTR
        INC     HL              ;
        LD      C,(IX+$0F)      ;
        LD      B,(IX+$10)      ;
        ADD     HL,BC           ;
        LD      ($5C4B),HL      ; VARS
        LD      H,(IX+$0E)      ;
        LD      A,H             ;
        AND     $C0             ;
        JR      NZ,L08AD        ; to LD-PROG-1

        LD      L,(IX+$0D)      ;
        LD      ($5C42),HL      ; NEWPPC
        LD      (IY+$0A),$00    ; NSPPC

;; LD-PROG-1
L08AD   POP     DE              ;
        POP     IX              ;
        SCF                     ; Set Carry Flag
        LD      A,$FF           ;
        JP      L0802           ; to LD-BLOCK

;---------------------
; Handle MERGE control
;---------------------
;
;

;; ME-CONTRL
L08B6   LD      C,(IX+$0B)      ;
        LD      B,(IX+$0C)      ;
        PUSH    BC              ;
        INC     BC              ;

        RST     30H             ; BC-SPACES
        LD      (HL),$80        ;
        EX      DE,HL           ;
        POP     DE              ;
        PUSH    HL              ;
        PUSH    HL              ;
        POP     IX              ;
        SCF                     ; Set Carry Flag
        LD      A,$FF           ;
        CALL    L0802           ; routine LD-BLOCK
        POP     HL              ;
        LD      DE,($5C53)      ; PROG

;; ME-NEW-LP
L08D2   LD      A,(HL)          ;
        AND     $C0             ;
        JR      NZ,L08F0        ; to ME-VAR-LP

;; ME-OLD-LP
L08D7   LD      A,(DE)          ;
        INC     DE              ;
        CP      (HL)            ;
        INC     HL              ;
        JR      NZ,L08DF        ; to ME-OLD-L1

        LD      A,(DE)          ;
        CP      (HL)            ;

;; ME-OLD-L1
L08DF   DEC     DE              ;
        DEC     HL              ;
        JR      NC,L08EB        ; to ME-NEW-L2

        PUSH    HL              ;
        EX      DE,HL           ;
        CALL    L19B8           ; routine NEXT-ONE
        POP     HL              ;
        JR      L08D7           ; to ME-OLD-LP

;; ME-NEW-L2
L08EB   CALL    L092C           ; routine ME-ENTER
        JR      L08D2           ; to ME-NEW-LP

;; ME-VAR-LP
L08F0   LD      A,(HL)          ;
        LD      C,A             ;
        CP      $80             ;
        RET     Z               ;

        PUSH    HL              ;
        LD      HL,($5C4B)      ; VARS

;; ME-OLD-VP
L08F9   LD      A,(HL)          ;
        CP      $80             ;
        JR      Z,L0923         ; to ME-VAR-L2

        CP      C               ;
        JR      Z,L0909         ; to ME-OLD-V2

;; ME-OLD-V1
L0901   PUSH    BC              ;
        CALL    L19B8           ; routine NEXT-ONE
        POP     BC              ;
        EX      DE,HL           ;
        JR      L08F9           ; to ME-OLD-VP

;; ME-OLD-V2
L0909   AND     $E0             ;
        CP      $A0             ;
        JR      NZ,L0921        ; to ME-VAR-L1

        POP     DE              ;
        PUSH    DE              ;
        PUSH    HL              ;

;; ME-OLD-V3
L0912   INC     HL              ;
        INC     DE              ;
        LD      A,(DE)          ;
        CP      (HL)            ;
        JR      NZ,L091E        ; to ME-OLD-V4

        RLA                     ;
        JR      NC,L0912        ; to ME-OLD-V3

        POP     HL              ;
        JR      L0921           ; to ME-VAR-L1

;; ME-OLD-V4
L091E   POP     HL              ;
        JR      L0901           ; to ME-OLD-V1

;; ME-VAR-L1
L0921   LD      A,$FF           ;

;; ME-VAR-L2
L0923   POP     DE              ;
        EX      DE,HL           ;
        INC     A               ;
        SCF                     ; Set Carry Flag
        CALL    L092C           ; routine ME-ENTER
        JR      L08F0           ; to ME-VAR-LP

;-------------------------
; Merge a Line or Variable
;-------------------------
;
;

;; ME-ENTER
L092C   JR      NZ,L093E        ; to ME-ENT-1

        EX      AF,AF'          ;
        LD      ($5C5F),HL      ; X_PTR
        EX      DE,HL           ;
        CALL    L19B8           ; routine NEXT-ONE
        CALL    L19E8           ; routine RECLAIM-2
        EX      DE,HL           ;
        LD      HL,($5C5F)      ; X_PTR
        EX      AF,AF'          ;

;; ME-ENT-1
L093E   EX      AF,AF'          ;
        PUSH    DE              ;
        CALL    L19B8           ; routine NEXT-ONE
        LD      ($5C5F),HL      ; X_PTR
        LD      HL,($5C53)      ; PROG
        EX      (SP),HL         ;
        PUSH    BC              ;
        EX      AF,AF'          ;
        JR      C,L0955         ; to ME-ENT-2

        DEC     HL              ;
        CALL    L1655           ; routine MAKE-ROOM
        INC     HL              ;
        JR      L0958           ; to ME-ENT-3

;; ME-ENT-2
L0955   CALL    L1655           ; routine MAKE-ROOM

;; ME-ENT-3
L0958   INC     HL              ;
        POP     BC              ;
        POP     DE              ;
        LD      ($5C53),DE      ; PROG
        LD      DE,($5C5F)      ; X_PTR
        PUSH    BC              ;
        PUSH    DE              ;
        EX      DE,HL           ;
        LDIR                    ; Copy Bytes
        POP     HL              ;
        POP     BC              ;
        PUSH    DE              ;
        CALL    L19E8           ; routine RECLAIM-2
        POP     DE              ;
        RET                     ;

        endif


;--------------------
; Handle SAVE control
;--------------------
;
;hl=addr
;ix=header

;; SA-CONTRL
L0970   PUSH    HL              ;
        ;LD      A,$FD           ;
        ;CALL    L1601           ; routine CHAN-OPEN
        ;XOR     A               ; clear to address table directly
        ;LD      DE,L09A1        ; address: tape-msgs
        ;CALL    L0C0A           ; routine PO-MSG -
                                ; 'Start tape then press any key.'

        ;SET     5,(IY+$02)      ; TV_FLAG  - Signal lower screen requires
                                ; clearing
        ;CALL    L15D4           ; routine WAIT-KEY
        PUSH    IX              ;
        LD      DE,$0011        ;
        XOR     A               ;
        CALL    L04C2           ; routine SA-BYTES
        POP     IX              ;
        LD      B,$32           ;

;; SA-1-SEC
L0991   HALT                    ; Wait for Interrupt
        DJNZ    L0991           ; to SA-1-SEC

        LD      E,(IX+$0B)      ;
        LD      D,(IX+$0C)      ;
        LD      A,$FF           ;
        POP     IX              ;
        JP      L04C2           ; to SA-BYTES


        if 1==0
;-------------------------
; Canned cassette messages
;-------------------------
; The last-character-inverted Cassette messages.
; Start with normal initial step-over byte.

;; tape-msgs
L09A1   DEFB    $80
        DEFB    "Start tape, then press any key"
L09C0   DEFB    '.'+$80
        DEFB    $0D
        DEFB    "Program:",' '+$80
        DEFB    $0D
        DEFB    "Number array:",' '+$80
        DEFB    $0D
        DEFB    "Character array:",' '+$80
        DEFB    $0D
        DEFB    "Bytes:",' '+$80
        endif

cmd_end
	savebin "playtap.com",cmd_begin,cmd_end-cmd_begin

	LABELSLIST "../../us/user.l"
