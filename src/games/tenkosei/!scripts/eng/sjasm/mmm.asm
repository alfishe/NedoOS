        org #c000
        ld a,2




        macro FLG_IF flag,op_code,value,goto
                db 0x0b
                db 0x40
                db flag

                if op_code = '>='
                        db 0xee
                endif

                db value
                dw goto

        endm



        FLG_IF 1,'>=',255,32768