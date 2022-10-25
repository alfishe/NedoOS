        include SUPER_C.inc
M_START:
ER
	CDPLAY		14
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	F_O	B_NORM,C_KURO
	FLG_KI	YOKU,'/',2
	FLG_KI	SIZ_ATTA,'=',1
	EVENT_CG	'th_072',B_FADE,35
	DB "Кэндзиро: Мм? Сидзука-сэнсэй?"
	DB	NEXT
	DB "Сидзука: Очнулся?"
	DB	NEXT
	DB "Кэндзиро: Ч-что случилось?"
	DB	NEXT
	DB "Сидзука: У тебя пошла носом кровь, и ты потерял сознание."
	DB	NEXT
	DB "Кэндзиро: .............."
	DB	NEXT
	DB "Шизука:   Ты молод, так что тебе надо выгнать чтото из орнганизма. Тебе нужно пробовать мастурбацию."
	DB	NEXT
	DB "Кенджиру:  Хахаха...да..."
	DB	NEXT
	DB "Сидзука: Ты молод, так что надо освобождать организм от таких вещей. Тебе надо попробовать мастурбацию."
	DB	NEXT
	DB "Кэндзиро: Хахаха...да..."
	DB	NEXT
	DB	"Сидзука: Но ты довольно хорошо отделался. Тебе удалось совсем не запачкать кровью одежду."
	DB	NEXT
	DB	"Кэндзиро: Да, в этом я хорош."
	DB	NEXT
	DB "Кэндзиро: Ну, я пойду."
	DB	NEXT
	DB "Сидзука: Постарайся больше не доводить до кровотечений."
	DB	NEXT
	DB "Кэндзиро: Постараюсь."
	DB	NEXT
	DB "Я выхожу из медицинского кабинета."
	DB	NEXT
	JTBL HOK
	DW	FF_0,FF_1,FF_2,FF_3,FF_4,FF_5,FF_6,FF_7,-1
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
