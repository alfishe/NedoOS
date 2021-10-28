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
        dw l_eng2
        dw l_rus

l_eng   db "eng/",0
l_eng2   db "eng2/",0
l_rus   db "rus/",0

;----
loc_main_menu:
        dw menu_main_eng
        dw menu_main_eng
        dw menu_main_rus
loc_load_menu:        
        dw menu_load_eng
        dw menu_load_eng
        dw menu_load_rus
loc_m1_menu:        
        dw menu_m1_eng
        dw menu_m1_eng
        dw menu_m1_rus
loc_m2_menu:        
        dw menu_m2_eng
        dw menu_m2_eng
        dw menu_m2_rus
loc_chars1_menu:
        dw menu_chars1_eng
        dw menu_chars1_eng
        dw menu_chars1_rus
loc_chars2_menu:
        dw menu_chars2_eng
        dw menu_chars2_eng
        dw menu_chars2_rus
loc_chars3_menu:
        dw menu_chars3_eng
        dw menu_chars3_eng
        dw menu_chars3_rus
loc_chars4_menu:
        dw menu_chars4_eng
        dw menu_chars4_eng
        dw menu_chars4_rus
loc_lb_menu
        dw menu_lb_eng
        dw menu_lb_eng
        dw menu_lb_rus

loc_load_menu_ingame:        
        dw menu_load_eng+2
        dw menu_load_eng+2
        dw menu_load_rus+2
loc_save_menu_ingame:        
        dw menu_save_eng
        dw menu_save_eng
        dw menu_save_rus
;------------------------
loc_hero_name:
        dw heroname_eng
        dw heroname_eng
        dw heroname_rus

heroname_eng DB "Shuji",0
heroname_rus DB "—˛‰ÁË",0        
;------------------------
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

mus_plr_path db "_plr.bin",0
;------------------------
menu_main_eng:
          db 8,3  ;max len in CHR (symbols x2) , num strings in menu - 1
          DB "   START GAME   ",1
          DB "      LOAD      ",1
          DB " CHARACTER INTRO",1
          DB "      QUIT      ",0
menu_main_rus:
          db 8,3  ;max len, num strings in menu - 1
          DB "   ÕŒ¬¿ﬂ  »√–¿  ",1
          DB " «¿√–”«»“‹ »√–” ",1
          DB "    œ≈–—ŒÕ¿∆»   ",1
          DB "  ¬€…“» »« »√–€ ",0

menu_main_action:
          dw _newgame
          dw _loadgame
          dw _characters
          dw _gamequit


menu_load_eng:
          db 4,4  ;max len, num strings in menu - 1
          DB " LOAD 1 ",1
          DB " LOAD 2 ",1
          DB " LOAD 3 ",1
          DB " LOAD 4 ",1
          DB " LOAD 5 ",0
menu_load_rus:
          db 7,4  ;max len, num strings in menu - 1
          DB " «¿√–”«»“‹  1 ",1
          DB " «¿√–”«»“‹  2 ",1
          DB " «¿√–”«»“‹  3 ",1
          DB " «¿√–”«»“‹  4 ",1
          DB " «¿√–”«»“‹  5 ",0

menu_load_action:
          dw _load_slot1
          dw _load_slot2
          dw _load_slot3
          dw _load_slot4
          dw _load_slot5

menu_chars1_eng:
          db 8,4  ;max len, num strings in menu - 1
          DB " REIKO SAWAMURA ",1
          DB " KIYOMI SHINFUJI",1
          DB " MIO SUZUKI     ",1
          DB " SHOKO NISHINO  ",1
          DB " NEXT PAGE      ",0
menu_chars1_action:
          dw _op1_show
          dw _op2_show
          dw _op3_show
          dw _op4_show
          dw _to_chr_page2

menu_chars2_eng:
          db 8,4  ;max len, num strings in menu - 1    
          DB " RURI SHIROMIZU ",1
          DB " AKI HINAGIKU   ",1
          DB " SEIA YOSHIDA   ",1
          DB " MEIMI NAKANO   ",1
          DB " NEXT PAGE      ",0
menu_chars2_action:
          dw _op8_show
          dw _op5_show
          dw _op6_show
          dw _op7_show
          dw _to_chr_page3


menu_chars3_eng:
          db 9,3    
          DB " KYOKO KOBAYASHI  ",1
          DB " MAKOTO SHIMAZAKI ",1
          DB " NOBUYUKI YAMAGAMI",1
          DB " NEXT PAGE        ",0
menu_chars3_action:
          dw _op9_show
          dw _op10_show
          dw _op11_show
          dw _to_chr_page4

menu_chars4_eng:
          db 8,3
          DB " EMI YAMAGAMI   ",1
          DB " SHINJI SHINFUJI",1
          DB " TATSUHIKO SAITO",1
          DB " FIRST PAGE     ",0
menu_chars4_action:
          dw _op12_show
          dw _op13_show
          dw _op14_show
          dw _to_chr_page1

menu_lb_eng:
          db 8,1
          DB "    LOOK BACK   ",1
          DB " DON'T LOOK BACK",0
menu_lb_action:          
          dw _mem_look_back
          dw _mem_decline

menu_chars1_rus:
          db 8,4
          DB " –›… Œ —¿¬¿Ã”–¿ ",1
          DB "  »®Ã» —»Õ‘”ƒ«» ",1
          DB " Ã»Œ —”ƒ«” »    ",1
          DB " —® Œ Õ»—»ÕŒ    ",1
          DB " ƒ¿À≈≈          ",0          
menu_chars2_rus:
          db 8,4
          DB " –”–» —»–ŒÃ»ƒ«” ",1
          DB " ¿ » ’»Õ¿√» ”   ",1
          DB " —›…ﬂ ®—»ƒ¿     ",1
          DB " Ã›…Ã» Õ¿ ¿ÕŒ   ",1
          DB " ƒ¿À≈≈          ",0
menu_chars3_rus:
          db 9,3
          DB "  ® Œ  Œ¡¿ﬂ—»     ",1
          DB " Ã¿ Œ“Œ —»Ã¿ƒ«¿ » ",1
          DB " ÕŒ¡”ﬁ » ﬂÃ¿√¿Ã»  ",1
          DB " ƒ¿À≈≈            ",0
menu_chars4_rus:
          db 8,3
          DB " ›Ã» ﬂÃ¿√¿Ã»    ",1
          DB " —»Õƒ«» —»Õ‘”ƒ«»",1
          DB " “¿÷”’» Œ —¿…“Œ ",1
          DB " ¬ Õ¿◊¿ÀŒ       ",0          
menu_lb_rus:
          db 8,1
          DB " œŒ¬“Œ–»“‹ —÷≈Õ”",1
          DB "  Õ≈ œŒ¬“Œ–ﬂ“‹  ",0


          
;---
menu_save_eng:
          DB " SAVE 1",1
          DB " SAVE 2",1
          DB " SAVE 3",1
          DB " SAVE 4",1
          DB " SAVE 5",0
menu_save_rus:
          DB " —Œ’–¿Õ»“‹  1",1
          DB " —Œ’–¿Õ»“‹  2",1
          DB " —Œ’–¿Õ»“‹  3",1
          DB " —Œ’–¿Õ»“‹  4",1
          DB " —Œ’–¿Õ»“‹  5",0
menu_m1_eng:
          DB "SAVE",1
          DB "LOAD",1
          DB "QUIT",0
menu_m1_rus:          
          DB "—Œ’–¿Õ»“‹",1
          DB "«¿√–”«»“‹",1
          DB "¬€’Œƒ",0

menu_m1_action:
          dw _ram_save
          dw _ram_load
          dw _confirm_quit

menu_m2_eng:
          DB "CONTINUE        ",1
          DB "QUIT            ",0
menu_m2_rus:          
          DB "¬≈–Õ”“‹—ﬂ       ",1
          DB "¬€’Œƒ           ",0
menu_m2_action:
          dw TO_MENU_ESC
          dw begin

loc_save_menu_ingame_action:
          dw _save_slot_1
          dw _save_slot_2
          dw _save_slot_3
          dw _save_slot_4
          dw _save_slot_5
loc_load_menu_ingame_action:
          dw _load_slot_1
          dw _load_slot_2
          dw _load_slot_3
          dw _load_slot_4
          dw _load_slot_5