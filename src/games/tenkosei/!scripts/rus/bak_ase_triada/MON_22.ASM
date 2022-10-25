        include SUPER_C.inc
M_START:
MON_22
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB "Часы показывают за десять часов. Мотоки еще нет дома."
	DB	NEXT
	DB "Кенджиру:  Черт, Мотока..."
	DB	NEXT
	DB "Внезапно я слышу в фойе шум. Это, наверное, Мотока."
	DB	NEXT
	DB "Я начинаю подниматься, но внезапно вспоминаю утренние слова Акеми."
	DB	NEXT
	DB "Кенджиру:  Она сказала доверять Мотоке..."
	DB	T_WAIT, 3
	DB " Так я и сделаю."
	DB	NEXT
	DB "С Мотокой все будет хорошо. Я должен верить ей."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB "Я выключаю свет и сплю."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_23.OVL'
END
