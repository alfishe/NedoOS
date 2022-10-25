        include SUPER_C.inc
M_START:
MON_35
	FLG_IF JUMP,'=',67,FF_4
	FLG_IF JUMP,'=',66,FF_3
	FLG_IF JUMP,'=',65,FF_2
	FLG_IF JUMP,'=',64,FF_1
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB "Кенджиру:  Ах. Это был прекрасный сон."
	DB	NEXT
	DB "Пора одеваться."
	DB	NEXT
	DB "Я быстро оделся и направился вниз, в столовую."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	9
	T_CG	'tt_10_02',MOT_A1,0
	T_CG	'tt_20_02',AKE_A3,0
	DB "Здесь Мотока и Акеми-сан."
	DB	NEXT
	DB "Мотока:  Любимый, доброе утро!" 
	DB	NEXT
	DB "Мотока была не такая как вчером. Она была веселая и счастливая."
	DB	NEXT
	DB "Акеми:  Кенджиру-кун, доброе утро." 
	DB	NEXT
	DB "Кенджиру:  Доброе утро. Акеми-сан, завтрак готов?"
	DB	NEXT
	DB "Акеми:  Это здесь."
	DB	NEXT
	DB "Она ставит передо мной тосты и кофе."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_10_02',MOT_A2,0
	DB "Акеми-сан поставила нам на стол завтрак, а ушла на кухню."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_21_02',MOT_B2,0
	DB "Мотока:  Любимый?"
	DB	NEXT
	DB "Кенджиру:  Да?"
	DB	NEXT
	DB "Мотока:  Ты не будешь против"
	DB	T_WAIT,	3
	DB "пойти вместе в школу?"
	DB	NEXT
	DB "Я почти не разговаривал с ней. Но это была очень неплохая мысль."
	DB	NEXT
	DB "Мотока:  Ты что не хочешь?"
	DB	NEXT
	DB "Кенджиру:  Ладно. Давай пойдем вместе."
	DB	NEXT
	DB "Мотока:  Хорошо, пошли." 
	DB	NEXT
	DB "Она дала мне руку, и мы пошли в школу."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB "Я купил покушать за 500 йен в ближайшем магазине, и мы пошли к станции."
	DB	NEXT
	DB "Мотоко всю дорогу болтала в поезде. Я постоянно кивал, но больше никак не поддерживал беседу. "
        DB "Даже среди обычного утреннего студенческого шума она все равно продолжала что-то рассказывать."
	DB	NEXT
	BAK_INIT	'tb_009',B_NORM
	CDPLAY	23
	T_CG	'tt_10_09',SIH_A2,0
	DB "Шихо:   А, Кенжироу-кун. Доброе утро." 
	DB	NEXT
	TATI_ERS
	T_CG	'tt_21_09',MOT_B3,0
	T_CG	'tt_02_09',SIH_A1,0
	DB "Кенджиру:  Привет."
	DB	NEXT
	DB "Мотока:  Кашима-сенпай..."  
	DB	T_WAIT,	3
	DB " Доброе утро."
	DB	NEXT
	DB "Шихо:   Доброе утро." 
	DB	NEXT
	DB "Мотока схватила мой рукав, притягивая меня ближе."
	DB	NEXT
	DB "Шихо увидев это отодвинулась немного назад."
	DB	NEXT
	DB "Мотока:  ....................." 
	DB	NEXT
	DB "Шихо:   ....................." 
	DB	NEXT
	DB "Так что случилось?"
	DB	NEXT
	DB "Теруми:  Привет."
	DB	NEXT
	DB "Показался Теруми-сенпай и прошел между мной и Мотокой."
	DB	NEXT
	TATI_ERS
	CDPLAY	3
	T_CG	'tt_21_09',MOT_B3,0
	T_CG	'tt_05_09',TER1,0
	DB "Теруми:  Почему вы до сих пор здесь стоите? Пора уже на урок!" 
	DB	NEXT
	DB "Теруми-сенпай подтолкнул меня в спину и пошел к школе."
	DB	NEXT
	TATI_ERS
	CDPLAY	23
	T_CG	'tt_21_09',MOT_B3,0
	T_CG	'tt_02_09',SIH_A1,0
	DB "Кенджиру:  Нам тоже пора идти."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	F_O	B_NORM,C_KURO
	DB "Остаток пути до школы никто из нас ничего не сказал."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	CDPLAY	23
	T_CG	'tt_02_10',SIH_A1,0
	T_CG	'tt_08_10',TET_A3,0
	DB "Тецуя:    Доброе утро, Кашима-сан." 
	DB	NEXT
	DB "Шихо:   Привет." 
	DB	NEXT
	DB "Кенджиру:  Подожди минуту."
	DB	T_WAIT,	3
	DB " Это ко мне?"
	DB	NEXT
	DB "Тецуя:    Oй, Кенджиру. Ты тут."
	DB	NEXT
	DB "Кенджиру:  Уже звонок..."
	DB	NEXT
	;WAV	'Se_ch'
	DB "Шихо:   Мы лучше сядем."
	DB	NEXT
	DB "Тецуя:    Ты права." 
	DB	NEXT
	TATI_ERS
	DB "Кенджиру:  Я тоже бы лучше присел."
	DB	NEXT
	F_O	B_NORM,C_KURO
	;;WAV  'STOP'
	CDPLAY		0
	DB "Я смотрел на доску, непонимая, какова вообще цель образования."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI JUMP,'=',0
	FLG_KI	JUMP,'=',64
	SINARIO	'NITI_HIR.OVL'
FF_1:
	FLG_KI JUMP,'=',0
	FLG_KI	JUMP,'=',65
	SINARIO	'NITI_HOK.OVL'
FF_2:
	FLG_KI JUMP,'=',0
	FLG_KI	JUMP,'=',66
	SINARIO	'NITI_MAT.OVL'
FF_3:
	FLG_KI JUMP,'=',0
	FLG_IF HANAJI,'>=',1,ABC
	FLG_KI	JUMP,'=',67
	SINARIO	'NITI_KIT.OVL'
FF_4:
	FLG_KI JUMP,'=',0
	FLG_IF	ONANI,'>=',5,DEF
	FLG_KI	ONANI,'=',0
DEF:
	SINARIO	'MON_36.OVL'
	DB	EXIT
ABC:
	FLG_IF	ONANI,'>=',5,GHI
	FLG_KI	ONANI,'=',0
GHI:
	SINARIO	'MON_36.OVL'
	DB	EXIT
END
