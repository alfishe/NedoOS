        include SUPER_C.inc
M_START:
MON_31C
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI	 YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O	B_NORM,C_KURO
	DB	"Кэндзиро: ...Ууум?"
	DB	NEXT
	DB	"Я поднимаю тяжёлые веки и осматриваюсь."
	DB	NEXT
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB	"Где я?"
	DB	NEXT
	DB	"Я смотрю по сторонам. Кажется, я у себя в комнате."
	DB	NEXT
	DB	"Что случилось?"
	DB	NEXT
	DB	"На моей одежде бурое пятно."
	DB	NEXT
	DB	"Кровь? Ох да, у меня пошла кровь из носа..."
	DB	NEXT
	DB	"Но что случилось после этого?"
	DB	NEXT
	DB	"Видимо, я потерял сознание."
	DB	NEXT
	DB	"Потом кто-то отнёс меня сюда."
	DB	NEXT
	DB	"Должно быть, это была та девушка. Но постойте, она не знала где я живу? Хмм, ох ладно. Нет смысла беспокоиться об этом."
	DB	NEXT
	DB	"Я наполовину переоделся, когда вдруг услышал шум внизу."
	DB	NEXT
	DB	"Кэндзиро: Что это?"
	DB	NEXT
	DB	"Я закончил переодеваться и направился вниз на кухню."
	DB	NEXT
	SINARIO	'MON_32.OVL'
	DB	EXIT
END