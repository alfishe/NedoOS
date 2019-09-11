;************* не сохраняемые пременные ********
;/H3x2 из XPUT
invBUF			  ;буфер инверсии спрайтов 3х2
;/READ
WX_LEN	EQU invBUF+96	  ;место для табл.ф-лов
;WX_BAD	EQU WX_LEN+111	  ;место для табл.BAD-секторов
;/INTRP
DBL_SP	EQU WX_LEN+numFL+42  ;стек прерываний

        include "w_demo.asm" ;???
       DEFS DBL_SP-$,#77 ;буфер инверсии спрайтов 3Х2


