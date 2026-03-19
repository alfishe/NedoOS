;------------------------
gfx_modes
        dw  m_ddp
        dw  m_16c
        dw  m_atm

m_ddp   db "ddp/",0
m_16c   db "16c/",0
m_atm   db "atm/",0
;------------------------
loc_modes
        dw l_eng
        dw l_rus

l_eng   db "eng/",0
l_rus   db "rus/",0


mus_modes
        dw s_aym
        dw s_s98

s_aym:  db "aym",0
s_s98:  db "s98",0

;==
plr_ext
        dw e_aym
        dw e_s98

e_aym   db "PT3",0
e_s98   db "s98",0

v_modes
        dw v_df ;/default version
        dw v_dc ;/director's cut
v_df    db "df/",0
v_dc    db "dc/",0

mus_plr_path db "_plr.bin",0
;------------------------
