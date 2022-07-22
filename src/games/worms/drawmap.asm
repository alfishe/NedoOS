;TODO не перерисовывать, если не сменился XY и не сместились объекты (прорисовать только строки под стрелкой для air strike)
DrawMap
        call DrawMapGfx
        call DrawWater
        ret

DrawWater
        LD A,(MOUSEY)
        SUB waterYwin+1;maxYwin-7;61 ;waterYwin - это где высота воды 0
        RET C
        CPL
curwater=$+1
        ld de,WATER
        jp DrawWater_Amhgt_DEgfx
