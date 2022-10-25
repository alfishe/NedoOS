        include SUPER_C.inc
M_START:
MON_38
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB "Кенджиру:  ..........."
	DB	T_WAIT,	3
	DB "Время просыпаться."
	DB	NEXT
	DB "Смотрю на часы. Чуть больше 12 дня."
	DB	NEXT
	DB "Кенджиру:  Ого, поздновато даже для меня.."
	DB	NEXT
	DB "Сегодня выходной и мне нужно выспаться."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB "Что? На улице темно."
	DB	NEXT
	DB "Интересно, что на ужин."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB "Завтра в школу. Я подготовлюсь с помощью крепкого сна."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	FLG_KI	HIDUKE,'+',1
	FLG_IF JUMP,'=',26,FF_2
	SINARIO	'MON_39.OVL'
	DB	EXIT
FF_2:
	SINARIO 'JUMP.OVL'
	DB	EXIT
END
