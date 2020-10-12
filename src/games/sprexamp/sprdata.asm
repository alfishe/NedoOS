testspr=$+4
_hgt=16
_wid=8 ;width/2
        db _wid
        db _hgt
_=_wid
        dup _wid
        dup _hgt*2
        db (0xaa+$)&0xff
        edup
_=_-1
        if _ != 0
        dw 0x4000 - ((_hgt-1)*40)
        else
        dw 0xffff
        endif
        edup
        dw prsprqwid

BULLETRIGHT=0xc000+(16*2)
BULLETLEFT=0xc000+(17*2)

HEROSTANDRIGHT0=0xc000+(22*2)
HEROSTANDRIGHT1=0xc000+(23*2)
HEROSTANDLEFT0=0xc000+(24*2)
HEROSTANDLEFT1=0xc000+(25*2)
HERORUNRIGHT0=0xc000+(26*2)
HERORUNRIGHT1=0xc000+(27*2)
HERORUNRIGHT2=0xc000+(28*2)
HERORUNLEFT0=0xc000+(29*2)
HERORUNLEFT1=0xc000+(30*2)
HERORUNLEFT2=0xc000+(31*2)

heroanim_runright
        dw HERORUNRIGHT0
        db 4
        dw HERORUNRIGHT1
        db 4
        dw HERORUNRIGHT2
        db 4
        dw heroanim_runright
heroanim_runleft
        dw HERORUNLEFT0
        db 4
        dw HERORUNLEFT1
        db 4
        dw HERORUNLEFT2
        db 4
        dw heroanim_runleft
heroanim_standright;=heroanim_runright
        dw HEROSTANDRIGHT0
        db 25
        dw HEROSTANDRIGHT1
        db 25
        dw heroanim_standright
heroanim_standleft;=heroanim_runleft
        dw HEROSTANDLEFT0
        db 25
        dw HEROSTANDLEFT1
        db 25
        dw heroanim_standleft

bulletanim_right
        dw BULLETRIGHT
        db 50
        dw bulletanim_right

bulletanim_left
        dw BULLETLEFT
        db 50
        dw bulletanim_left

        STRUCT obj
y16     WORD
x16     WORD
;sprite16 WORD
animtime BYTE
animaddr16 WORD
xspeed16 WORD
yspeed16 WORD
health  BYTE
flags   BYTE ;b0=on ground, b1=jump not released, b2=blinking, b4=провалиться, b7=dead
sz
        ENDS

MAXOBJECTS=42
MAXBULLETS=8
TYPE_HERO=254
OBJSIZE=obj.sz

objects
;y16 (*8)
;x16 (*8) (in double pixels)
;animtime
;animaddr16
;xspeed16
;yspeed16
;health
_=0
_x=10
        dup 1
_y=100
        dup 1;  3
        
        dw 8*_y ;y
        dw 8*(_x+(sprmaxwid-1)) ;x
        ;dw HERO0
        db 1
        dw heroanim_standright
        dw 1
        dw 0
        db 100
        db 0 ;flags
_=_+1
_y=_y+40
        edup
_x=_x+20
        edup
        dw -1
        
        ds MAXOBJECTS*OBJSIZE
endobjects

bullets
        ds MAXBULLETS*OBJSIZE
bulletlistend
        dw -1
