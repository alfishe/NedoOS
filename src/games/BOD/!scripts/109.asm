           include incl.inc
start:
        db 1
        db "bar",0
        db "barm_cn",0
        db "БАРМЕН: Довольно. Едем немедленно! Я запрягу лошадей."
        db wait
        db scenario,"110.ovl",0

