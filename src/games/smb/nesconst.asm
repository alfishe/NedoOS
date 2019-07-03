;NES specific hardware defines

        if 1==1
PPU_CTRL_REG1         db 0;= $2000 ;d0=page (for scroll)
;PPU_CTRL_REG2         db 0;= $2001
PPU_STATUS            db 0;= $2002
PPU_SPR_ADDR          db 0;= $2003
PPU_SPR_DATA          db 0;= $2004
PPU_SCROLL_REG_H        db 0;= $2005
PPU_SCROLL_REG_V        db 0;= $2005
PPU_ADDRESS           db 0;= $2006
PPU_DATA              db 0;= $2007

;PPU_SPRLIST        ds 256
PPU_PALETTES
PPU_BGPAL       ds 16
PPU_SPRPAL       ds 16

        else
PPU_CTRL_REG1         = $2000
PPU_CTRL_REG2         = $2001
PPU_STATUS            = $2002
PPU_SPR_ADDR          = $2003
PPU_SPR_DATA          = $2004
PPU_SCROLL_REG        = $2005
PPU_SCROLL_REG_H=PPU_SCROLL_REG
PPU_SCROLL_REG_V=PPU_SCROLL_REG
PPU_ADDRESS           = $2006
PPU_DATA              = $2007

PPU_BGPAL=$3f00
PPU_SPRPAL=$3f10
        endif

        if 1==1
SND_REGISTER          ;= $4000
SND_SQUARE1_REG       ds 4;= $4000
SND_SQUARE2_REG       ds 4;= $4004
SND_TRIANGLE_REG      ds 4;= $4008
SND_NOISE_REG         ds 4;= $400c
SND_DELTA_REG         ds 4;= $4010
                      db 0
SND_MASTERCTRL_REG    db 0;= $4015
        else
SND_REGISTER          = $4000
SND_SQUARE1_REG       = $4000
SND_SQUARE2_REG       = $4004
SND_TRIANGLE_REG      = $4008
SND_NOISE_REG         = $400c
SND_DELTA_REG         = $4010
SND_MASTERCTRL_REG    = $4015
        endif

        if 1==1
SPR_DMA               db 0;= $4014
JOYPAD_PORT           ;= $4016
JOYPAD_PORT1          db 0;= $4016
JOYPAD_PORT2          db 0;= $4017
        else
SPR_DMA               = $4014
JOYPAD_PORT           = $4016
JOYPAD_PORT1          = $4016
JOYPAD_PORT2          = $4017
        endif
