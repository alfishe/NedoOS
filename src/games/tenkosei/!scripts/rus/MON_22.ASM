        include SUPER_C.inc
M_START:
MON_22
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"Часы показывают начало одиннадцатого. Мотока ещё не пришла."
	DB	NEXT
	DB	"Кэндзиро: Чтоб тебя, Мотока..."
	DB	NEXT
	DB	"Вдруг я слышу шум в прихожей. Должно быть, это Мотока."
	DB	NEXT
	DB	"Я начинаю вставать, но, вдруг, вспоминаю слова Акэми, сказанные этим утром."
	DB	NEXT
	DB	"Кэндзиро: Она сказала, чтобы я доверял Мотоке..."
	DB	T_WAIT, 3
	DB	" Пожалуй, я так и сделаю."
	DB	NEXT
	DB	"С Мотокой всё будет в порядке. Я просто должен ей доверять."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"Я выключаю свет и засыпаю."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_23.OVL'
END