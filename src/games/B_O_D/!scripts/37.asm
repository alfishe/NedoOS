           include incl.inc
start:
        db 2
        db "bar",0
        db "barm_n",0
        db "БАРМЕН: Вы зря пьете. Это не спасет."
        db wait
        db "ЧАРЛЬЗ: Почем вам знать?"
        db wait
        db "БАРМЕН: Кому, как не мне... Я в этом деле специалист. Вы ведь новенький в этом городе?"
        db wait
        db scenario,"38.ovl",0

