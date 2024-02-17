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
        ;TSPRITES 0,0,0 ;ID 0 not used
        TSPRITES 0,0,44 ;ID 1
        TSPRITES 0,44,42
        TSPRITES 0,86,36
        TSPRITES 0,122,56
        TSPRITES 0,178,40
        TSPRITES 0,218,48
        TSPRITES 0,266,36
        TSPRITES 0,302,56
        TSPRITES 0,358,38
        TSPRITES 0,396,50 ;10
        TSPRITES 0,448,24
        TSPRITES 1,472,26

MONSTAB
;ZOMBIEMAN stay
        db 1
        db 2
        db 1
        db 2
        db 1
        db 2
        db 0,0
;ZOMBIEMAN go1
        db 3
        db 4
        db 5
        db 6
        db 3
        db 4
        db 0,0
;ZOMBIEMAN go2
        db 2;7
        db 8
        db 9
        db 10
        db 7
        db 8
        db 0,0
;AMMO
        db 4;12 ;G
        db 12 ;R
        db 12 ;MEGAHEALTH
        db 12 ;RL
        db 12 ;AMMO
        db 12
        db 0,0
;STOLB
        db 5;11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
;STOLB2
        db 6;11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
;STOLB3
        db 7;11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
;STOLB4
        db 8;11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
