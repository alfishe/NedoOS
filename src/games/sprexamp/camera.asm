usetrackcamera
        if DEBUGPRINT
        ;call prcoords
        endif

        call getmousedelta ;de=delta (d>0: go up) (e>0: go left), l=mousekey
        push hl
trackcamera_addr=$+1
        ;call mousetrackcamera ;de=delta (d>0: go up) (e>0: go left) ;out: d=camera dy, e=camera dx         
        call trackcamera ;de=delta (d>0: go up) (e>0: go left) ;out: d=camera dy, e=camera dx         
        pop hl ;l=mousekey
        
        ld a,l
        bit 1,a
        ret nz;jr nz,nocamoff
        ld bc,notrackcamera
        ld (trackcamera_addr),bc
;nocamoff
        ret
        
mousetrackcamera
;de=delta (d>0: go up) (e>0: go left)
;out: d=camera dy, e=camera dx
        ld hl,(cameraxm)
        ld c,e
        ld a,c
        rla
        sbc a,a
        ld b,a
        add hl,bc
        ld (cameraxm),hl
        ld hl,(cameraym)
        ld c,d
        ld a,c
        rla
        sbc a,a
        ld b,a
        add hl,bc
        ld (cameraym),hl
        ret

notrackcamera
;out: d=camera dy, e=camera dx
        ld de,0
        ret

trackcamera
;de=delta (d>0: go up) (e>0: go left)
;out: d=camera dy, e=camera dx
;двигаем смещение камеры к идеалу (xspeed16;yspeed16), но не быстрее, чем на +-CAMERASHIFTSPEED
;и находим camerax/ymideal
cameraxshift=$+1
        ld hl,0
        ld de,(objects+obj.xspeed16)
        xor a
        sbc hl,de
        or h
        jp m,xshifttoideal_neg
;hl=xshift-xshiftideal >=0
        ld bc,CAMERASHIFTSPEED_X
        sbc hl,bc
        jr c,xshifttoideal_get ;не быстрее, чем на +CAMERASHIFTSPEED_X
        jr xshifttoideal_limit
xshifttoideal_neg
;hl=xshift-xshiftideal <0
        ld bc,-CAMERASHIFTSPEED_X
        sbc hl,bc
        jr nc,xshifttoideal_get ;не быстрее, чем на -CAMERASHIFTSPEED_X
xshifttoideal_limit
        ld hl,(cameraxshift)
        or a
        sbc hl,bc
        ex de,hl
xshifttoideal_get
        ex de,hl
xshifttoideal_negq        
        ld (cameraxshift),hl
        ex de,hl

        ld hl,+80+24
        ld bc,(objects+obj.x16)
         dup 3
         srl b
         rr c
         edup
        or a
        sbc hl,bc
        ;ld de,(objects+obj.xspeed16)
        or a
        sbc hl,de
        ld (cameraxmideal),hl

camerayshift=$+1
        ld hl,0
        ld de,(objects+obj.yspeed16)
        xor a
        sbc hl,de
        or h
        jp m,yshifttoideal_neg
;hl=yshift-yshiftideal >=0
        ld bc,CAMERASHIFTSPEED_Y
        sbc hl,bc
        jr c,yshifttoideal_get ;не быстрее, чем на +CAMERASHIFTSPEED_Y
        jr yshifttoideal_limit
yshifttoideal_neg
;hl=yshift-yshiftideal <0
        ld bc,-CAMERASHIFTSPEED_Y
        sbc hl,bc
        jr nc,yshifttoideal_get ;не быстрее, чем на -CAMERASHIFTSPEED_Y
yshifttoideal_limit
        ld hl,(camerayshift)
        or a
        sbc hl,bc
        ex de,hl
yshifttoideal_get
        ex de,hl
yshifttoideal_negq        
        ld (camerayshift),hl
        ex de,hl

        ld hl,+80+48
        ld bc,(objects+obj.y16)
         dup 3
         srl b
         rr c
         edup
        or a
        sbc hl,bc
        ;ld de,(objects+obj.yspeed16)
        or a
        sbc hl,de
        ld (cameraymideal),hl
        
;двигаем камеру к идеалу, но не быстрее, чем на +-CAMERATRACKINGSPEED
        ld hl,(cameraxm)
cameraxmideal=$+1
        ld de,0;(cameraxmideal)
        xor a
        sbc hl,de
        or h
        jp m,xmtoideal_neg
;hl=xm-xmideal >=0
        ld bc,CAMERATRACKINGSPEED_X
        sbc hl,bc
        jr c,xmtoideal_get ;не быстрее, чем на +CAMERATRACKINGSPEED_X
        jr xmtoideal_limit
xmtoideal_neg
;hl=xm-xmideal <0
        ld bc,-CAMERATRACKINGSPEED_X
        sbc hl,bc
        jr nc,xmtoideal_get ;не быстрее, чем на -CAMERATRACKINGSPEED_X
xmtoideal_limit
        ld hl,(cameraxm)
        or a
        sbc hl,bc
        ex de,hl
xmtoideal_get
        ex de,hl
xmtoideal_negq        
        ld (cameraxm),hl
cameraxmold=$+1
        ld de,0
        ld (cameraxmold),hl
        or a
        sbc hl,de ;camera dx
       push hl

        ld hl,(cameraym)
cameraymideal=$+1
        ld de,0;(cameraymideal)
        xor a
        sbc hl,de
        or h
        jp m,ymtoideal_neg
;hl=ym-ymideal >=0
        ld bc,CAMERATRACKINGSPEED_Y
        sbc hl,bc
        jr c,ymtoideal_get ;не быстрее, чем на +CAMERATRACKINGSPEED_Y
        jr ymtoideal_limit
ymtoideal_neg
;hl=ym-ymideal <0
        ld bc,-CAMERATRACKINGSPEED_Y
        sbc hl,bc
        jr nc,ymtoideal_get ;не быстрее, чем на -CAMERATRACKINGSPEED_Y
ymtoideal_limit
        ld hl,(cameraym)
        or a
        sbc hl,bc
        ex de,hl
ymtoideal_get
        ex de,hl
ymtoideal_negq        
        ld (cameraym),hl
cameraymold=$+1
        ld de,0
        ld (cameraymold),hl
        or a
        sbc hl,de ;camera dy
        
       pop bc ;camera dx
         ld d,l
         ld e,c
        ret
