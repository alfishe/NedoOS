        include SUPER_C.inc
M_START:
MON_31B
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	DB	"Кэндзиро: Я дома."
	DB	NEXT
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Акэми: С возвращением."
	DB	NEXT
	DB	"Кэндзиро: Мотока дома?"
	DB	NEXT
	DB	"Акэми: Ещё нет."
	DB	NEXT
	DB	"Кэндзиро: Ясно."
	DB	NEXT
	DB	"Акэми: Хочешь поужинать?"
	DB	NEXT
	DB	"Кэндзиро: Нет. Хотя, я голоден."
	DB	NEXT
	DB	"Акэми: Хорошо, сейчас приготовлю ужин."
	DB	NEXT
	DB	"Кэндзиро: Ладно, спасибо. Я буду у себя в комнате."
	DB	NEXT
	BAK_INIT	'tb_001a',B_NORM
	DB	"Будь проклята эта Мотока. Куда она ушла?"
	DB	NEXT
	DB	"Всё-таки интересно, не была ли она в том отеле?"
	DB	NEXT
	DB	"Нет, не думаю."
	DB	NEXT
	DB	"По крайней мере, не хочу в это верить. Я уже не знаю, во что мне верить."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	F_O	B_NORM,C_KURO
	DB	"А? Похоже, я заснул."
	DB	NEXT
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB	"Что? Из гостиной раздаётся какой-то шум. Лучше сходить проверить."
	DB	NEXT
	SINARIO	'MON_32.OVL'
	DB	EXIT
END