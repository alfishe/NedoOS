        include SUPER_C.inc
M_START:
MON_38
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB	"Кэндзиро: ..........."
	DB	T_WAIT,	3
	DB	"Пожалуй, пора вставать."
	DB	NEXT
	DB	"Я посмотрел на часы. Начало первого."
	DB	NEXT
	DB	"Кэндзиро: Ух ты, даже для меня поздно..."
	DB	NEXT
	DB	"Сегодня свободный день, так что, пожалуй, посплю ещё."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB	"Что? На улице темно."
	DB	NEXT
	DB	"Интересно, что на ужин."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB	"Завтра в школу. Лучше ещё поспать."
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