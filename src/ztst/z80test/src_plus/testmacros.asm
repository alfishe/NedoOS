; Macros for defining the test vectors.
;
; Copyright (C) 2012-2023 Patrik Rak (patrik@raxoft.cz)
;
; This source code is released under the MIT license, see included license.txt.

            macro   db8 b7,b6,b5,b4,b3,b2,b1,b0
            db      (b7<<7)|(b6<<6)|(b5<<5)|(b4<<4)|(b3<<3)|(b2<<2)|(b1<<1)|b0
            endm
            
            macro   ddbe n
            db      (n>>24)&0xff
            db      (n>>16)&0xff
            db      (n>>8)&0xff
            db      n&0xff
            endm

            macro   inst op1,op2,op3,op4,taila
            ; Unfortunately, elseifidn doesn't seem to work properly.
            if   op4==stop
            db      op1,op2,op3,taila,0
            elseif   op3==stop
            db      op1,op2,taila,op4,0
            elseif   op2==stop
            db      op1,taila,op3,op4,0
            else
            db      op1,op2,op3,op4,taila
            endif
            endm

            macro   flags sn,s,zn,z,f5n,f5,hcn,hc,f3n,f3,pvn,pv,nn,n,cn,c
            if      maskflags
            db8     s,z,f5,hc,f3,pv,n,c
            else
            db      0xff
            endif
            endm

            macro   vec op1,op2,op3,op4,memn,mema,an,aa,fn,f,bcn,bca,den,dea,hln,hla,ixn,ixa,iyn,iya,spn,spa

            if      postccf

            if      ( @veccount % 3 ) == 0
            inst    op1,op2,op3,op4,tail
!areg      =      0
            else
            db      op1,op2,op3,op4,0
!areg      =      @areg | aa
            endif

            else
            db      op1,op2,op3,op4
            endif

            db      f

            if      postccf & ( ( @veccount % 3 ) == 2 )
            db      aa | ( ( ~ @areg ) & 0x28 )
            else
            db      aa
            endif

            dw      bca,dea,hla,ixa,iya
            dw      mema
            dw      spa

!veccount = @veccount+1

            endm

            macro   crcs allflagsn,allflags,alln,all,docflagsn,docflags,docn,doc,ccfn,ccf,mptrn,mptr
            if      postccf
            ddbe    ccf
            elseif  memptr
            ddbe    mptr
            else
            if      maskflags
            if      onlyflags
            ddbe    docflags
            else
            ddbe    doc
            endif
            else
            if      onlyflags
            ddbe    allflags
            else
            ddbe    all
            endif
            endif
            endif
            endm
            
            macro   name n
            dz      n
            endm

; EOF ;
