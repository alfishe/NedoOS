;------------------------
gfx_modes
        dw  m_ddp
        dw  m_atm
        dw  m_ddp2


m_ddp   db "ddp/",0
m_atm   db "atm/",0
m_ddp2  db "ddp2/",0

;--------------
;mode_sprpos
Modes_x:
        dw Mode1_x
        dw Mode2_x
;        dw Mode3_x


;Mode1_x: db 2,20,36 ;ddp_old
Mode2_x: db 0,15,30
Mode1_x: db 0,15,30


box_color_x:
        dw box_color1_x
        dw box_color2_x



box_color1_x: db 0b11000000
;box_color1_x: db 0b00001001 ;ddp_old
box_color2_x: db 0b11000000



pal_mode:
        dw DDp_pal
        dw ATM_pal




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


mus_plr_path db "_plr.bin",0

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
;------------------------
menu_main_eng:
          db 8,2  ;max len in CHR (symbols x2) , num strings in menu - 1
          DB " START GAME",1
          DB " LOAD",1
          DB " QUIT",0
menu_main_rus:
          db 10,2  ;max len, num strings in menu - 1
          DB " НОВАЯ  ИГРА",1
          DB " ЗАГРУЗИТЬ ИГРУ",1
          DB " ВЫЙТИ ИЗ ИГРЫ",0

menu_main_action:
          dw _newgame
          dw _loadgame
          dw _gamequit


menu_load_eng:
          db 6,3  ;max len, num strings in menu - 1
          DB " LOAD 1   ",1
          DB " LOAD 2   ",1
          DB " LOAD 3   ",1
          DB " LOAD 4   ",0

menu_load_rus:
          db 8,3  ;max len, num strings in menu - 1
          DB " ЗАГРУЗИТЬ  1 ",1
          DB " ЗАГРУЗИТЬ  2 ",1
          DB " ЗАГРУЗИТЬ  3 ",1
          DB " ЗАГРУЗИТЬ  4 ",0

menu_load_action:
          dw _load_slot1
          dw _load_slot2
          dw _load_slot3
          dw _load_slot4

         
;---
menu_save_eng:
          DB " SAVE 1",1
          DB " SAVE 2",1
          DB " SAVE 3",1
          DB " SAVE 4",0
menu_save_rus:
          DB " СОХРАНИТЬ  1",1
          DB " СОХРАНИТЬ  2",1
          DB " СОХРАНИТЬ  3",1
          DB " СОХРАНИТЬ  4",0

menu_m1_eng:
          DB "SAVE",1
          DB "LOAD",1
          DB "QUIT",0
menu_m1_rus:          
          DB "СОХРАНИТЬ",1
          DB "ЗАГРУЗИТЬ",1
          DB "ВЫХОД",0

menu_m1_action:
          dw _ram_save
          dw _ram_load
          dw _confirm_quit

menu_m2_eng:
          DB "CONTINUE        ",1
          DB "QUIT            ",0
menu_m2_rus:          
          DB "ВЕРНУТЬСЯ       ",1
          DB "ВЫХОД           ",0
menu_m2_action:
          dw TO_MENU_ESC
          dw begin

loc_save_menu_ingame_action:
          dw _save_slot_1
          dw _save_slot_2
          dw _save_slot_3
          dw _save_slot_4

loc_load_menu_ingame_action:
          dw _load_slot_1
          dw _load_slot_2
          dw _load_slot_3
          dw _load_slot_4



loc_excite:
        dw loc_excite_eng
        dw loc_excite_rus

loc_excite_eng:
        db "Excite: ",0
loc_excite_rus:
        db "Возбуждение: ",0
excite_nums:
        db "000",0

lamps:    db "[OOOO]",0
lamp_def: db "[OOOO]",0       
daylist: 
          dw _day0
          dw _day1
          dw _day2
          dw _day3
          dw _day4
          dw _day5
          dw _day6
          dw _day7
          dw _day8
          dw _day9
          dw _day10
          dw _day11
          dw _day12
          dw _day13
          dw _day14
          dw _day15
          dw _day16
          dw _day17
          dw _day18
          dw _day19
          dw _day20
          dw _day21
          dw _day22
          dw _day23
          dw _day24
          dw _day25
          dw _day26
          dw _day27
          dw _day28
          dw _day29
          dw _day30

_day0:
        dw _day0_eng
        dw _day0_rus
_day1:
        dw _day1_eng
        dw _day1_rus
_day2:
        dw _day2_eng
        dw _day2_rus
_day3:
        dw _day3_eng
        dw _day3_rus
_day4:
        dw _day4_eng
        dw _day4_rus
_day5:
        dw _day5_eng
        dw _day5_rus
_day6:
        dw _day6_eng
        dw _day6_rus
_day7:
        dw _day7_eng
        dw _day7_rus
_day8:
        dw _day8_eng
        dw _day8_rus
_day9:
        dw _day9_eng
        dw _day9_rus
_day10:
        dw _day10_eng
        dw _day10_rus
_day11:
        dw _day11_eng
        dw _day11_rus
_day12:
        dw _day12_eng
        dw _day12_rus
_day13:
        dw _day13_eng
        dw _day13_rus
_day14:
        dw _day14_eng
        dw _day14_rus
_day15:
        dw _day15_eng
        dw _day15_rus
_day16:
        dw _day16_eng
        dw _day16_rus
_day17:
        dw _day17_eng
        dw _day17_rus
_day18:
        dw _day18_eng
        dw _day18_rus
_day19:
        dw _day19_eng
        dw _day19_rus
_day20:
        dw _day20_eng
        dw _day20_rus
_day21:
        dw _day21_eng
        dw _day21_rus
_day22:
        dw _day22_eng
        dw _day22_rus
_day23:
        dw _day23_eng
        dw _day23_rus
_day24:
        dw _day24_eng
        dw _day24_rus
_day25:
        dw _day25_eng
        dw _day25_rus
_day26:
        dw _day26_eng
        dw _day26_rus
_day27:
        dw _day27_eng
        dw _day27_rus
_day28:
        dw _day28_eng
        dw _day28_rus
_day29:
        dw _day29_eng
        dw _day29_rus
_day30:
        dw _day30_eng
        dw _day30_rus

_day0_eng: db "Monday April 13",0
_day0_rus: db "Понедельник 13 апреля",0
_day1_eng: db "Tuesday April 14",0
_day1_rus: db "Вторник 14 апреля",0
_day2_eng: db "Wednesday April 15",0
_day2_rus: db "Среда 15 апреля",0
_day3_eng: db "Thursday April 16",0
_day3_rus: db "Четверг 16 апреля",0
_day4_eng: db "Friday April 17",0
_day4_rus: db "Пятница 17 апреля",0
_day5_eng: db "Saturday April 18",0
_day5_rus: db "Суббота 18 апреля",0
_day6_eng: db "Sunday April 19",0
_day6_rus: db "Воскресенье 19 апреля",0
_day7_eng: db "Monday April 20",0
_day7_rus: db "Понедельник 20 апреля",0
_day8_eng: db "Tuesday April 21",0
_day8_rus: db "Вторник 21 апреля",0
_day9_eng: db "Wednesday April 22",0
_day9_rus: db "Среда 22 апреля",0
_day10_eng: db "Thursday April 23",0
_day10_rus: db "Четверг 23 апреля",0
_day11_eng: db "Friday April 24",0
_day11_rus: db "Пятница 24 апреля",0
_day12_eng: db "Saturday April 25",0
_day12_rus: db "Суббота 25 апреля",0
_day13_eng: db "Sunday April 26",0
_day13_rus: db "Воскресенье 26 апреля",0
_day14_eng: db "Monday April 27",0
_day14_rus: db "Понедельник 27 апреля",0
_day15_eng: db "Tuesday April 28",0
_day15_rus: db "Вторник 28 апреля",0
_day16_eng: db "Wednesday April 29",0
_day16_rus: db "Среда 29 апреля",0
_day17_eng: db "Thursday April 30",0
_day17_rus: db "Четверг 30 апреля",0
_day18_eng: db "Friday May 1",0
_day18_rus: db "Пятница 1 мая",0
_day19_eng: db "Saturday May 2",0
_day19_rus: db "Суббота 2 мая",0
_day20_eng: db "Sunday May 3",0
_day20_rus: db "Воскресенье 3 мая",0

_day21_eng: db "Monday May 4",0
_day21_rus: db "Понедельник 4 мая",0
_day22_eng: db "Tuesday May 5",0
_day22_rus: db "Вторник 5 мая",0
_day23_eng: db "Wednesday May 6",0
_day23_rus: db "Среда 6 мая",0
_day24_eng: db "Thursday May 7",0
_day24_rus: db "Четверг 7 мая",0
_day25_eng: db "Friday May 8",0
_day25_rus: db "Пятница 8 мая",0
_day26_eng: db "Saturday May 9",0
_day26_rus: db "Суббота 9 мая",0
_day27_eng: db "Sunday May 10",0
_day27_rus: db "Воскресенье 10 мая",0
_day28_eng: db "Monday May 11",0
_day28_rus: db "Понедельник 11 мая",0
_day29_eng: db "Tuesday May 12",0
_day29_rus: db "Вторник 12 мая",0
_day30_eng: db "Wednesday May 13",0
_day30_rus: db "Среда 13 мая",0
