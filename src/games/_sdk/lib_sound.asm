        ;export _music_play
        ;export _music_stop
        ;export _sample_play
        ;export _sfx_play
        ;export _sfx_stop

_sample_play
;проигрывание сэмпла
;l=номер сэмпла
       push ix
	ld a,(curpg32khigh) ;ok
	push af
	ld a,SND_PAGE
        call setpgc000
	ld a,(SMP_COUNT|0xc000)
	ld e,a
	ld a,l
	cp e
	jr nc,.skip

	ld h,high (SMP_LIST|0xc000)
	ld e,(hl)	;lsb
	inc h
	ld a,(hl)	;msb
        or 0xc0
        ld d,a
	inc h
	ld a,(hl)	;page
        cpl
	inc h
	ld h,(hl)	;delay
	ex de,hl ;hl=data
        ld hx,d ;delay
        ld e,a
        ld d,tpages/256
;hl=data (0xc000+, 0x00=end), de=pagetable (0x0000+), hx=delay (18=11kHz, 7=22kHz, 1=44kHz)
        OS_PLAYCOVOX
.skip
        pop af
        SETPG32KHIGH
       pop ix
        ret

;выключение звука на указанном чипе
;a=0 или 1
reset_ay
;используется в _sfx_stop, _music_stop
	ifdef TFM
	push af
	 ;di
	call turbo_off
	ld a,SND_PAGE
	call setpg4000
	ld a,(TURBOFMON)
	or a
	call nz,#400f;tfmshut
	ld a,CC_PAGE1
	call setpg4000
	pop af
	call reset_ay_ay
	;call turbo_on
	 ;ei ;нельзя в прерывании!
	;ret
turbo_on
	ld a,%10101000 ;режим EGA с турбо
	ld bc,#bd77
	out (c),a
	ret
turbo_off
	ld a,%10100000 ;режим EGA без турбо, так как в 14 МГц скорость нестабильна
	ld bc,#bd77
	out (c),a
	ret
	else
	 ;di
	;call reset_ay_ay
	 ;ei ;нельзя в прерывании!
	;ret
	endif

reset_ay_ay
;в TFM нужно для глушения AY перед выводом эффектов
	push af
	ifdef TFM
	or %11111000
	;or %11111010		;no wait sync
	else
	or #fe
	endif
	ld bc,#fffd
	out (c),a

	xor a
	ld l,a
.l0
	ld b,#ff
	ifdef TFM
	call libstartup_waitstatus
	endif
	out (c),a
	ifdef TFM
	call libstartup_waitstatus
	endif
	ld b,#bf
	out (c),l
	inc a
	cp 14
	jr nz,.l0
	pop af
	ret

;запуск звукового эффекта
_sfx_play
	push bc
	ld a,SND_PAGE
	call setpg4000
	pop bc
	ld a,b
	call AFX_PLAY
	ld a,CC_PAGE1
	jp setpg4000

;выключение музыки
_music_stop
	xor a
	ld (musicPage),a
	;jp _di_reset_ay_ei        
;останов звуковых эффектов
_sfx_stop
	xor a
_di_reset_ay_ei
        di
	call reset_ay
        ei
        ret

;запуск музыки
_music_play
	push ix
	push iy
	push af
	ld a,SND_PAGE
	call setpg4000

	ld a,(MUS_COUNT)
	ld l,a
	pop af

	cp l
	jr nc,.skip

	ld h,high MUS_LIST
	ld l,a

	ld e,(hl)
	inc h
	ld d,(hl)
	inc h
	ld a,(hl)
	ex de,hl
	di
	ld (musicPage),a
	call setpg8000
	ifdef TFM
	ld a,(TURBOFMON)
	or a
	call nz,PT3_INIT
	else
	ld bc,#fffd
	ld a,#fe
	out (c),a
	call PT3_INIT
	endif
	ei
	ld a,CC_PAGE2
	call setpg8000

.skip
	pop iy
	pop ix

	ld a,CC_PAGE1
	jp setpg4000

initsfx
	;определение TS
	ld bc,#fffd	;чип 0
	out (c),b
	xor a		;регистр 0
	out (c),a
	ld b,#bf	;значение #bf
	out (c),b
	ld b,#ff	;чип 1
	ld a,#fe
	out (c),a
	xor a		;регистр 0
	out (c),a
	ld b,#bf	;значение 0
	out (c),a
	ld b,#ff	;чип 0
	out (c),b
	xor a		;регистр 0
	out (c),a
	in a,(c)
	ld (turboSound),a
        ld a,SND_PAGE
        call setpg4000
	xor a
	call reset_ay_ay
	inc a
	call reset_ay_ay
        ld hl,SFX_DATA
        jp AFX_INIT
