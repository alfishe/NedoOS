        include SUPER_C.inc
M_START:
MON_35
	FLG_IF JUMP,'=',67,FF_4
	FLG_IF JUMP,'=',66,FF_3
	FLG_IF JUMP,'=',65,FF_2
	FLG_IF JUMP,'=',64,FF_1
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB	"Кэндзиро: Ахх. Хорошо поспал."
	DB	NEXT
	DB	"Пора одеваться."
	DB	NEXT
	DB	"Я одеваюсь и иду на кухню."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	9
	T_CG	'tt_10_02',MOT_A1,0
	T_CG	'tt_20_02',AKE_A3,0
	DB	"Здесь Мотока и Акэми-сан."
	DB	NEXT
	DB	"Мотока: Ониитян, доброе утро!" 
	DB	NEXT
	DB	"Мотока не такая, какой была вчера. Она бодрая и весёлая."
	DB	NEXT
	DB	"Акэми: Кэндзиро-кун, доброе утро." 
	DB	NEXT
	DB	"Кэндзиро: Доброе утро. Акэми-сан, вы уже приготовили завтрак?"
	DB	NEXT
	DB	"Акэми: Только что."
	DB	NEXT
	DB	"Она ставит передо мной тост и кофе."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_10_02',MOT_A2,0
	DB	"Дав мне завтрак, Акэми-сан возвращается к своим делам на кухне."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_21_02',MOT_B2,0
	DB	"Мотока: Ониитян?"
	DB	NEXT
	DB	"Кэндзиро: Да?"
	DB	NEXT
	DB	"Мотока: Ты бы хотел..."
	DB	T_WAIT,	3
	DB	" пойти в школу со мной?"
	DB	NEXT
	DB	"В последнее время я с ней мало разговаривал. Наверное, это хорошая идея."
	DB	NEXT
	DB	"Мотока: Не хочешь?"
	DB	NEXT
	DB	"Кэндзиро: Хорошо. Пошли вместе."
	DB	NEXT
	DB	"Мотока: Ладно, пошли." 
	DB	NEXT
	DB	"По дороге в школу она тянула меня за собой."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"В магазине я покупаю обед за 500 иен, и мы идём на станцию."
	DB	NEXT
	DB	"В поезде Мотока всё время со мной болтает. Я время от времени киваю, но больше никак разговор не поддерживаю. "
        DB      "Она продолжает говорить даже среди утренней трескотни школьников."
	DB	NEXT
	BAK_INIT	'tb_009',B_NORM
	CDPLAY	23
	T_CG	'tt_10_09',SIH_A2,0
	DB	"Сихо: А, Кэндзиро-кун. Доброе утро." 
	DB	NEXT
	TATI_ERS
	T_CG	'tt_21_09',MOT_B3,0
	T_CG	'tt_02_09',SIH_A1,0
	DB	"Кэндзиро: Доброе утро."
	DB	NEXT
	DB	"Мотока: Касима-сэмпай..."  
	DB	T_WAIT,	3
	DB	" Доброе утро."
	DB	NEXT
	DB	"Сихо: А, доброе утро." 
	DB	NEXT
	DB	"Мотока тянет меня к себе за рукав, подтягивая ближе к себе."
	DB	NEXT
	DB	"Сихо видит это и немного отодвигается."
	DB	NEXT
	DB	"Мотока: ....................." 
	DB	NEXT
	DB	"Сихо: ....................." 
	DB	NEXT
	DB	"Ч-что происходит...?"
	DB	NEXT
	DB	"Тэруми: Доброе утро."
	DB	NEXT
	DB	"Появляется Тэруми-сэмпай, проходя между мной и Мотокой."
	DB	NEXT
	TATI_ERS
	CDPLAY	3
	T_CG	'tt_21_09',MOT_B3,0
	T_CG	'tt_05_09',TER1,0
	DB	"Тэруми: Чего это вы тут все встали? В школу пора!" 
	DB	NEXT
	DB	"Тэруми-сэмпай легонько стукнула меня разок по голове, и убежала в школу одна."
	DB	NEXT
	TATI_ERS
	CDPLAY	23
	T_CG	'tt_21_09',MOT_B3,0
	T_CG	'tt_02_09',SIH_A1,0
	DB	"Кэндзиро: Нам тоже надо идти."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	F_O	B_NORM,C_KURO
	DB	"Остаток пути в школу никто ничего не сказал."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	CDPLAY	23
	T_CG	'tt_02_10',SIH_A1,0
	T_CG	'tt_08_10',TET_A3,0
	DB	"Тэцуя: Доброе утро, Касима-сан." 
	DB	NEXT
	DB	"Сихо: Доброе утро." 
	DB	NEXT
	DB	"Кэндзиро: Минутку..."
	DB	T_WAIT,	3
	DB	" А я?"
	DB	NEXT
	DB	"Тэцуя: О, Кэндзиро. И ты здесь."
	DB	NEXT
	DB	"Кэндзиро: Ну держись..."
	DB	NEXT
	;WAV	'Se_ch'
	DB	"Сихо: Нам лучше сесть."
	DB	NEXT
	DB	"Тэцуя: Ты права." 
	DB	NEXT
	TATI_ERS
	DB	"Кэндзиро: Мне тоже лучше сесть."
	DB	NEXT
	F_O	B_NORM,C_KURO
	;WAV  'STOP'
	CDPLAY		0
	DB	"Я уставился на доску, размышляя, для чего вообще нужно учиться."
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