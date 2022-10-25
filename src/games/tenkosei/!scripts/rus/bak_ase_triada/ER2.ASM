        include SUPER_C.inc
M_START:
ER2
	CDPLAY		14
	EVENT_CG	'th_072',B_FADE,35
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	F_O	B_NORM,C_KURO
	DB "Я вижу красную вспышку, потом в глазах темнеет."
	DB	NEXT
	DB "Кэндзиро: Ууу..."
	DB	NEXT
	DB "Сидзука: Ийя!!"
	DB	NEXT
	B_O	B_FADE,C_KURO
	F_O	B_NORM,C_KURO
	FLG_KI	YOKU,'/',2
	DB "Кэндзиро: Где...где я?"
	DB	NEXT
	DB "Кэндзиро: Что случилось?"
	DB	NEXT
	DB "Я медленно открываю глаза."
	DB	NEXT
	EVENT_CG	'th_072',B_FADE,35
	DB "Кэндзиро: А? Сидзука-сэнсэй?"
	DB	NEXT
	DB "Сидзука: Очнулся?"
	DB	NEXT
	DB "Кэндзиро: Д-да. Эм, что случилось?"
	DB	NEXT
	DB "Сидзука: У тебя пошла кровь из носа, и ты потерял сознание." 
	DB	NEXT
	DB "Кэндзиро: Кровь из носа?"
	DB	NEXT
	DB "Сидзука: Да. Ты меня удивил. Это был настоящий фонтан. Пришлось долго всё отмывать."
	DB	NEXT
	DB "Кэндзиро: П-простите..."
	DB	NEXT
	DB "Сидзука: Ну, я тебя прощаю, раз уж ты возбудился, глядя на меня. Но тебе нужно мастурбировать "
        DB "каждый день -- для твоей же пользы."
	DB	NEXT
	DB "Кэндзиро: Л-ладно, спасибо. Ну, теперь я, пожалуй, пойду."
	DB	NEXT
	DB "Я выхожу из медицинского кабинета."
	DB	NEXT
	JTBL HOK
	DW	FF_0,FF_1,FF_1,FF_3,FF_4,FF_5,FF_6,FF_7,-1
	DB	EXIT
FF_0:
FF_1:
	SINARIO 'BUNKI_1.OVL'
FF_2:
	SINARIO 'MON_10.OVL'
FF_3:
	SINARIO 'MON_14.OVL'
FF_4:
	SINARIO 'MON_18.OVL'
FF_5:
	SINARIO 'MON_23.OVL'
FF_6:
	SINARIO 'NITI_HIR.OVL'
FF_7:
	SINARIO 'NITI_HOK.OVL'
END
