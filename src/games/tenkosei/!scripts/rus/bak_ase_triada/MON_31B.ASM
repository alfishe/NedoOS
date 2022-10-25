        include SUPER_C.inc
M_START:
MON_31B
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	DB "Кенджиру:  Я дома."
	DB	NEXT
	T_CG	'tt_20_02',AKE_A2,0
	DB "Акеми:  А, вот и ты."
	DB	NEXT
	DB "Кенджиру:  Мотока дома?"
	DB	NEXT
	DB "Акеми:  Нет еще."
	DB	NEXT
	DB "Кенджиру:  Да."
	DB	NEXT
	DB "Акеми:  Ты будешь сейчас обедать?"
	DB	NEXT
	DB "Кенджиру:  Нет. Хотя я очень голоден."
	DB	NEXT
	DB "Акеми:  Ладно, я приготовлю обед."
	DB	NEXT
	DB "Кенджиру:  Хорошо, я буду в своей комнате."
	DB	NEXT
	BAK_INIT	'tb_001a',B_NORM
	DB "Чертовка Мотока. Где же тебя носит?"
	DB	NEXT
	DB "Интересно, а может, она все-таки в отеле?"
	DB	NEXT
	DB "Нет, я так не думаю."
	DB	NEXT
	DB "И вообще, я в это не буду верить. Я не знаю, во что еще мне верить."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	F_O	B_NORM,C_KURO
	DB "А? Я, по моему, засыпаю."
	DB	NEXT
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB "Что? Что там за шум слышится из комнаты. Я пойду и посмотрю, что там."
	DB	NEXT
	SINARIO	'MON_32.OVL'
	DB	EXIT
END
