        if atm
tsprites
;pg,xmid,xleft-1,xright-1
        macro TSPRITES pg,xleft,wid
xright=xleft+wid
xmid=(xleft+xright)/2
        db NTEXPGS+pg
        db xmid/2
        db xleft/2
        db xright/2
        endm
;TODO надо правильно центровать
        TSPRITES 0,44,42  ;0 back
        TSPRITES 0,86,36  ;1 go
        TSPRITES 0,122,56 ;2 go left (attack)
        TSPRITES 0,0,44   ;3 front (wound)
        TSPRITES 0,448,24 ;4 lamp (dead)
        TSPRITES 0,472,26 ;5 health
        TSPRITES 1,472,26 ;6 ammo
        TSPRITES 0,178,40 ;go back
        TSPRITES 0,218,48 ;go right
        TSPRITES 0,302,56 ;go2 left
        TSPRITES 0,358,38 ;go2 back
        TSPRITES 0,396,50 ;go2 right
        TSPRITES 0,396,50 ;go2 right
        TSPRITES 0,396,50 ;go2 right
        TSPRITES 0,396,50 ;go2 right
        TSPRITES 0,396,50 ;go2 right
        TSPRITES 0,266,36 ;16 go2 (костыль для 1+128)
        endif
  ;фазы:
;0=move1
;1=move2
;2=wantattack
;3=attack
;4=ранен
;5=(умирает)
;6=труп
;7=-
MONSTEROR=64 ;чтобы ID!=0, иначе это конец списка
MONSTAB
;ZOMBIEMAN stay back
        db MONSTEROR+0
        db MONSTEROR+0
        db MONSTEROR+0
        db 2
        db 3,0
        db 4,0
;ZOMBIEMAN stay
        db 1
        db 1
        db 1
        db 2
        db 3,0
        db 4,0
;ZOMBIEMAN go
        db 1
        db 1+128
        db 1
        db 2
        db 3,0
        db 4,0
;AMMO
        db 5
        db 5
        db 5
        db 5
        db 5,0
        db 5,0
;HEALTH
        db 6
        db 6
        db 6
        db 6
        db 6,0
        db 6,0
;COLUMN
        db 7
        db 7
        db 7
        db 7
        db 7,0
        db 7,0
;
        db 8
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
;
        db 9
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
;
        db 10
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
;
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
;
        db 12
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
;
        db 13
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
;
        db 14
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
;
        db 15
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
