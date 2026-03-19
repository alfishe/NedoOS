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

;----
loc_main_menu:
        dw menu_main_eng
        dw menu_main_rus
loc_load_menu:        
        dw menu_load_eng
        dw menu_load_rus
loc_m1_menu:        
        dw menu_m1_eng
        dw menu_m1_rus
loc_m2_menu:        
        dw menu_m2_eng
        dw menu_m2_rus

loc_load_menu_ingame:        
        dw menu_load_eng+2
        dw menu_load_rus+2
loc_save_menu_ingame:        
        dw menu_save_eng
        dw menu_save_rus
;------------------------
loc_hero_name:
        dw heroname_eng
        dw heroname_rus

heroname_eng DB "Shuji",0
heroname_rus DB "—˛‰ÁË",0        
;------------------------
mus_modes
        dw s_aym
        dw s_s98
        dw s_msnd
        dw s_midi

s_aym:  db "aym",0
s_s98:  db "s98",0
s_msnd: db "vgm",0
s_midi: db "rcp",0

;==
plr_ext
        dw e_aym
        dw e_s98
        dw e_msnd
        dw e_midi
    

e_aym   db "PT3",0
e_s98   db "s98",0
e_msnd  db "vgm",0
e_midi  db "rcp",0

mus_plr_path db "_plr.bin",0
;------------------------
menu_main_eng:
          db 8,2  ;max len in CHR (symbols x2) , num strings in menu - 1
          DB "   START GAME   ",1
          DB "      LOAD      ",1
          DB "      QUIT      ",0
menu_main_rus:
          db 8,2  ;max len, num strings in menu - 1
          DB "   ÕŒ¬¿ﬂ  »√–¿  ",1
          DB " «¿√–”«»“‹ »√–” ",1
          DB "  ¬€…“» »« »√–€ ",0

menu_main_action:
          dw _newgame
          dw _loadgame
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