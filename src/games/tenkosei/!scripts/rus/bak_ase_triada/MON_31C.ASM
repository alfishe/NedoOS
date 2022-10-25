        include SUPER_C.inc
M_START:
MON_31C
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI	 YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O	B_NORM,C_KURO
	DB "Кенджиру:  ...Аааа?"
	DB	NEXT
	DB "Я поднял свою голову и осмотрелся."
	DB	NEXT
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB "Где я?"
	DB	NEXT
	DB "Я огляделся. Кажется, я в своей комнате."
	DB	NEXT
	DB "Что случилось?"
	DB	NEXT
	DB "На моей одежде коричневое пятно."
	DB	NEXT
	DB "Кровь? Это у меня пошла кровь носом."
	DB	NEXT
	DB "А что было после этого?"
	DB	NEXT
	DB "Я, наверное, потерял сознание."
	DB	NEXT
	DB "Наверно, кто-то меня перенес сюда."
	DB	NEXT
	DB "Это, наверное была та девушка. Но откуда она знает, где я живу? Ну да ладно. Нечего об этом волноваться."
	DB	NEXT
	DB "Я переодевался, когда я услышал шум, доносящийся с нижнего этажа."
	DB	NEXT
	DB "Кенджиру:  Что же это?"
	DB	NEXT
	DB "Я наконец-то оделся и спустился вниз в столовую."
	DB	NEXT
	SINARIO	'MON_32.OVL'
	DB	EXIT
END
