params_tank
;obj(16),energy(8),speed(8)
        dw objtank
        db 100
        db tankspeed
        
params_tanke
;obj(16),energy(8),speed(8)
        dw objtanke
        db 60
        db tankspeed
        
params_bullet
;obj(16),energy(8),speed(8)
        dw objbullet
        db bulletenergy
        db bulletspeed
     
tankbulletcoords
        db tanksize/2*coordsfactor,-8*coordsfactor ;u
        db tanksize*coordsfactor+(8*coordsfactor),tanksize/2*coordsfactor ;r
        db tanksize/2*coordsfactor,tanksize*coordsfactor+(8*coordsfactor) ;d
        db -8*coordsfactor,tanksize/2*coordsfactor ;l
        
        macro ANIMLINE t,spraddr
        db t
        dw spraddr
        endm
       
        macro ANIMEND ;после конца анимации переходим к 0-й анимации
        db 0
        dw 0
        endm

        macro ANIMCYCLE ;после конца анимации переходим началу этой анимации
        db 0
        dw 1
        endm
        
        macro ANIMENDDIE
        db 0
        dw 2
        endm

anims_bullet
        dw anim_bullet

anim_bullet
        ANIMLINE 8,views_bullet
        ANIMCYCLE
        
ANIM_STOP=0
ANIM_GO=1
ANIM_SHOOT=2
ANIM_DIE=3
ANIM_APPEAR=4
ANIM_PREPARESHOOT=5
anims_tank
        dw anim_tank_stop
        dw anim_tank_go
        dw anim_tank_shoot
        dw anim_tank_die
        dw anim_tank_appear
        dw anim_tank_stop ;prepareshoot
anims_tanke
        dw anim_tanke_stop
        dw anim_tanke_go
        dw anim_tanke_shoot
        dw anim_tanke_die
        dw anim_tank_appear
        dw anim_tanke_stop ;prepareshoot
        
anim_tank_die
        ANIMLINE 8,views_tank_die1
        ANIMLINE 8,views_tank_die2
        ANIMLINE 8,views_tank_die3
        ANIMLINE 8,views_tank_die4
        ANIMLINE 8,views_tank_die1
        ANIMLINE 8,views_tank_die2
        ANIMLINE 8,views_tank_die3
        ANIMLINE 8,views_tank_die4
        ANIMENDDIE
anim_tanke_die
        ANIMLINE 8,views_tanke_die1
        ANIMLINE 8,views_tanke_die2
        ANIMLINE 8,views_tanke_die3
        ANIMLINE 8,views_tanke_die4
        ANIMLINE 8,views_tanke_die1
        ANIMLINE 8,views_tanke_die2
        ANIMLINE 8,views_tanke_die3
        ANIMLINE 8,views_tanke_die4
        ANIMENDDIE

anim_tank_appear
        ANIMLINE 4,views_tank_die1
        ANIMLINE 4,views_tank_die2
        ANIMLINE 4,views_tank_die3
        ANIMLINE 4,views_tank_die4
        ANIMLINE 4,views_tank_die1
        ANIMLINE 4,views_tank_die2
        ANIMLINE 4,views_tank_die3
        ANIMLINE 4,views_tank_die4
        ANIMEND
anim_tanke_appear
        ANIMLINE 4,views_tanke_die1
        ANIMLINE 4,views_tanke_die2
        ANIMLINE 4,views_tanke_die3
        ANIMLINE 4,views_tanke_die4
        ANIMLINE 4,views_tanke_die1
        ANIMLINE 4,views_tanke_die2
        ANIMLINE 4,views_tanke_die3
        ANIMLINE 4,views_tanke_die4
        ANIMEND

anim_tank_stop
        ANIMLINE 8,views_tank_go1
        ANIMCYCLE
anim_tanke_stop
        ANIMLINE 8,views_tanke_go1
        ANIMCYCLE
        
anim_tank_go
        ANIMLINE 5,views_tank_go1
        ANIMLINE 5,views_tank_go2
        ANIMCYCLE
anim_tanke_go
        ANIMLINE 5,views_tanke_go1
        ANIMLINE 5,views_tanke_go2
        ANIMCYCLE

anim_tank_shoot
        ANIMLINE 10,views_tank_shoot2
        ANIMLINE 8,views_tank_shoot1
        ANIMEND
anim_tanke_shoot
        ANIMLINE 10,views_tanke_shoot2
        ANIMLINE 8,views_tanke_shoot1
        ANIMEND

views_bullet
        dw tank_u_go1
        dw tank_u_go1
        dw tank_u_go1
        dw tank_u_go1
        
views_tank_go1
        dw tank_u_go1
        dw tank_r_go1
        dw tank_d_go1
        dw tank_l_go1
views_tank_go2
        dw tank_u_go2
        dw tank_r_go2
        dw tank_d_go2
        dw tank_l_go2
views_tank_shoot1
        dw tank_u_shoot1
        dw tank_r_shoot1
        dw tank_d_shoot1
        dw tank_l_shoot1
views_tank_shoot2
        dw tank_u_shoot2
        dw tank_r_shoot2
        dw tank_d_shoot2
        dw tank_l_shoot2
views_tank_die1
        dw tank_u_go1
views_tank_die2
        dw tank_r_go1
views_tank_die3
        dw tank_d_go1
views_tank_die4
        dw tank_l_go1
        dw tank_u_go1
        dw tank_r_go1
        dw tank_d_go1
        
views_tanke_go1
        dw tanke_u_go1
        dw tanke_r_go1
        dw tanke_d_go1
        dw tanke_l_go1
views_tanke_go2
        dw tanke_u_go2
        dw tanke_r_go2
        dw tanke_d_go2
        dw tanke_l_go2
views_tanke_shoot1
        dw tanke_u_shoot1
        dw tanke_r_shoot1
        dw tanke_d_shoot1
        dw tanke_l_shoot1
views_tanke_shoot2
        dw tanke_u_shoot2
        dw tanke_r_shoot2
        dw tanke_d_shoot2
        dw tanke_l_shoot2
views_tanke_die1
        dw tanke_u_go1
views_tanke_die2
        dw tanke_r_go1
views_tanke_die3
        dw tanke_d_go1
views_tanke_die4
        dw tanke_l_go1
        dw tanke_u_go1
        dw tanke_r_go1
        dw tanke_d_go1

tile0=0
tilet=1*9
tileb=2*9
tilec=3*9
tilem=4*9
        
blocks
block_empty
        db tile0,tile0,tile0
        db tile0,tile0,tile0
        db tile0,tile0,tile0
block_tree
        db tilet,tilet,tilet
        db tilet,tilet,tilet
        db tilet,tilet,tilet
block_brick
        db tileb,tileb,tileb
        db tileb,tileb,tileb
        db tileb,tileb,tileb
block_concrete
        db tilec,tilec,tilec
        db tilec,tilec,tilec
        db tilec,tilec,tilec
block_metal
        db tilem,tilem,tilem
        db tilem,tilem,tilem
        db tilem,tilem,tilem
nblocks=($-blocks)/9
