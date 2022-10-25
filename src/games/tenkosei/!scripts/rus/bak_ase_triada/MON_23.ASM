        include SUPER_C.inc
M_START:
MON_23
	FLG_IF JUMP,'=',63,FUFUFU_1
	FLG_IF HOK,'=',5,KYOUSITU1
	FLG_IF HAND,'=',4,TOIRE1
SMK:
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB "Я толком не выспался..."
	DB	NEXT
	DB "Я переодеваюсь и спускаюсь по лестнице."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY		20
	T_CG	'tt_20_02',AKE_A3,0
	T_CG	'tt_21_02',MOT_A1,0
	DB "Кенджиру:  Привет."
	DB	NEXT
	DB "Акеми:  Доброе утро, Кенджиру."
	DB	NEXT
	DB "Мотока:  ................."
	DB	NEXT
	DB "Мотока не здоровается."
	DB	NEXT
	DB "Кенджиру:  Мотока, ты вчера вернулась ужасно поздно."
	DB	NEXT
	DB "Мотока:  ................" 
	DB	NEXT
	DB "Акеми:  Мотока, ты должна сказать доброе утро Кенджиру."
	DB	NEXT
	DB "Мотока:  Я иду в школу."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_20_02',AKE_A2,0
	CDPLAY		6
	DB "Акеми:  Ах, Мотока..."
	DB	NEXT
	DB "Кенджиру:  ...Мотока."
	DB	NEXT
	DB "Акеми:  Прости, Кенджиру-кун." 
	DB	NEXT
	DB "Кенджиру:  Хорошо."
	DB	NEXT
	DB "Акеми:  Она, наверное..." 
	DB	NEXT
	DB "Кенджиру:  Что?"
	DB	NEXT
	DB "Акеми:  Ничего."
	DB	NEXT
	DB "Кенджиру:  .................."
	DB	NEXT
	DB "Кенджиру:  Ну, я тогда тоже пойду в школу."
	DB	NEXT
	DB "Акеми:  Увидимся."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_006',B_NORM
	CDPLAY		2
	DB "Наверное, войду внуррь."
	DB	NEXT
	DB "Я захожу в ночной магазинчик."
	DB	NEXT
	BAK_INIT	'tb_007',B_NORM
	CDPLAY	3
	DB	NEXT
	DB "Я часто встречаю Теруми-сенпай."
	DB	NEXT
	T_CG	'tt_05_07',TER2,0
	DB "Кенджиру:  А, Теруми-сенпай, доброе утро."
	DB	NEXT
	DB "Теруми:  Доброе утро. Ты сегодня невеселый." 
	DB	NEXT
	DB "Кенджиру:  О, я всю ночь не спал."
	DB	NEXT
	DB "Теруми:  Держу пари, опять смотрел фильмы для взрослых, верно?" 
	DB	NEXT
	DB "Кенджиру:  ...Что-то вроде того."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	R1,"ЗВАТЬ ТЕРУМИ-СЕН"
	MENU_SET	R2,"ИДИ В ШКОЛУ ОДИН"
	MENU_END
	DB	EXIT
R1:
	DB "Кенджиру:  ......"
	DB	T_WAIT, 5
	DB "Теруми-сенпай, мы пойдем в школу?"
	DB	NEXT
	DB "Теруми:  А? О да. А как же твой завтрак?"
	DB	NEXT
	DB "Кенджиру:  Я сейчас вернусь."
	DB	NEXT
	DB "Я выбираю несколько рисовых шариков и иду к кассе."
	DB	NEXT
	DB "Кенджиру:  Теруми-сенпай, я готов. Пойдем." 
	DB	NEXT
	DB "Теруми:  Ладно"
	DB	NEXT
	DB "Я кладу рисовые шарики в сумку и покидаю ночной магазинчик."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO	GAKU1
R2:
	DB "Кенджиру:  Ну, увидимся позже."
	DB	NEXT
	DB "Я иду в школу один."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_009',B_NORM
	CDPLAY		23
	DB "Кенджиру:  Полно народу, как обычно."
	DB	NEXT
	DB "Голос:  Кенджиру-кун."
	DB	NEXT
	DB "Я поворачиваюсь посмотреть, кто позвал."
	DB	NEXT
	T_CG	'tt_02_09',SIH_A2,0
	DB "Шихо:   Кенджиру-кун, доброе утро."
	DB	NEXT
	DB "Кенджиру:  Утро."
	DB	NEXT
	DB "Шихо:   Что-то ты сегодня не бодрый?"
	DB	NEXT
	DB "Шихо смотрит на меня ее большими глазами."
	DB	NEXT
	DB "Кенджиру:  Я не выспался ночью."
	DB	NEXT
	DB "Шихо:   Надо ложиться пораньше." 
	DB	NEXT
	DB "Кенджиру:  Ты права."
	DB	NEXT
	DB "Шихо:   Мы пойдем в школу?" 
	DB	T_WAIT, 5
	DB " вместе?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	S1,"ЗА НЕЙ"
	MENU_SET	S2,"САМ"
	MENU_END
	DB	EXIT
S1:
	DB "Кенджиру:  Хорошо, пошли."
	DB	NEXT
	DB "Шихо:   Ладно"
	DB	NEXT
	DB "Я иду в школу с Шихо."
	DB	NEXT
	GO	GAKU2
	DB	EXIT
S2:
	DB "Кенджиру:  Нет, я хочу пойти один."
	DB	NEXT
	DB "Шихо:   Вижу..."
	DB	NEXT
	DB "Я иду в школу один."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO	GAKU1
	DB	EXIT
GAKU1:
	BAK_INIT	'tb_010',B_NORM
	CDPLAY		14
	T_CG	'tt_08_10',TET_A2,0
	DB "Тецуя:    Утро."
	DB	NEXT
	DB "Кенджиру:  Утро."
	DB	NEXT
	DB "Тецуя:    Как ты?"
	DB	NEXT
	DB "Кенджиру:  Хм, так-сяк"
	DB	NEXT
	DB "Тецуя:    Серьезно? Порядок"
	DB	NEXT
	DB "Кенджиру:  ................"
	DB	NEXT
	DB "Тецуя:    Эй, сделай же что-нибудь!"
	DB	NEXT
	;WAV	'Se_ch'
	DB "Внезапно зазвенел звонок. Время урока."
	DB	NEXT
	DB "Кенджиру:  Прости, я слегка устал."
	DB	NEXT
	DB "Тецуя:    ..............."
	DB	NEXT
	TATI_ERS
	DB "Я сажусь на мое место."
	DB	NEXT
	;;WAV  'STOP'
	CDPLAY	0
	F_O B_NORM,C_KURO
	DB "Я смотрю на доску, думая ни о чем."
	DB	NEXT
	DB "Не могу прекратить думать о Мотоке."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO HIRUYASUMI
	DB	EXIT
GAKU2:
	BAK_INIT	'tb_010',B_NORM
	CDPLAY		23
	T_CG	'tt_02_10',SIH_A1,0
	T_CG	'tt_08_10',TET_A3,0
	DB "Тецуя:    Доброе утро, Кашима-сан."
	DB	NEXT
	DB "Шихо:   Привет."
	DB	NEXT
	DB "Кенджиру:  ................"
	DB	NEXT
	DB "Сижу на на месте."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		14
	DB "Я тупо смотрю на доску."
	DB	NEXT
	DB "Не могу прекратить думать о Мотоке."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO	HIRUYASUMI
HIRUYASUMI:
	F_O B_NORM,C_KURO
	DB "Внезапно пришло время обеда."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	DB "Я пошел в коридор."
	DB	NEXT
	BAK_INIT	'tb_034a',B_NORM
	DB "Пора пойти поискать прекрасных женщин..."
	DB	NEXT
	FLG_KI	TEMP01,'=',0
	FLG_KI	TEMP02,'=',0
	FLG_KI	TEMP03,'=',0
	FLG_KI	TEMP04,'=',0
	FLG_KI	TEMP05,'=',0
	FLG_KI	TEMP06,'=',0
	FLG_KI	TEMP07,'=',0
	FLG_KI	TEMP08,'=',0
	GO	SENTAKU1
ROUKA1:
	CDPLAY		14
	BAK_INIT	'tb_034a',B_NORM
	DB "Так куда же мне идти?"
	DB	NEXT
SENTAKU1:
	FLG_KI W,'=',-1
	FLG_IF	TEMP02,'=',0,SA_1
	FLG_KI W,'DOWN',0
SA_1:
	FLG_IF	TEMP03,'=',0,SA_2
	FLG_KI W,'DOWN',1
SA_2:
	FLG_IF	TEMP04,'=',0,SA_3
	FLG_KI W,'DOWN',2
SA_3:
	FLG_IF	TEMP05,'=',0,SA_4
	FLG_KI W,'DOWN',3
SA_4:
	FLG_IF	TEMP06,'=',0,SA_5
	FLG_KI W,'DOWN',4
SA_5:
	FLG_IF	TEMP07,'=',0,SA_6
	FLG_KI W,'DOWN',5
SA_6:
	FLG_IF	TEMP08,'=',0,SA_7
	FLG_KI W,'DOWN',6
SA_7:
	FLG_IF	SIZ_ATTA,'=',1,SA_8
	FLG_KI W,'DOWN',6
SA_8:
	MENU_S	2,W,-1
	MENU_SET	T1,"НАЗАД В КЛАСС"
	MENU_SET	T2,"КРЫШ"
	MENU_SET	T3,"КЛАСС МОТОКИ"
	MENU_SET	T4,"СЛЕСАРЬ"
	MENU_SET	T5,"КОМ.АРТА"
	MENU_SET	T6,"МУЖ.КОМНАТ"
	MENU_SET	T7,"ОФФИС НУРСА"
	MENU_END
	DB	EXIT
T1:
	FLG_IF	TEMP01,'>=',2,KYOUSITU1
	FLG_KI	TEMP01,'+',1
	FLG_KI	TEMP02,'=',1
	DB "Наверно,надо вернуться."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	CDPLAY		23
	T_CG	'tt_02_10',SIH_A2,0
	DB "Когда я выходил из класса, я столкнулся с Шихо."
	DB	NEXT
	DB "Тецуя:    А, Кенджиру-кун."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	U1,"ОСМОТР ЛИЦА"
	MENU_SET	U2,"ОСМОТР ГРУДИ"
	MENU_SET	U3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
U1:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "У Шихо прекрасное лицо. Почти идеальное."
	DB	NEXT
	GO BODY_SHIHO
U2:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "У нее прекрасные груди, скрытые в униформу."
	DB	NEXT
	GO BODY_SHIHO
U3:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "Прекрасные бедра, мягкие и упругие, как раз то что надо."
	DB	NEXT
	GO BODY_SHIHO
BODY_SHIHO:
	FLG_KI AKEM_NET,'=',0
	FLG_KI MIKA_NET,'=',0
	FLG_KI TER_NET,'=',0
	FLG_KI RENA_NET,'=',0
	FLG_KI NANA_NET,'=',0
	FLG_KI SIZU_NET,'=',0
	FLG_KI CHIE_NET,'=',0
	DB "Хмм, я не хочу осквернять ее такими грязными мыслями о ней."
	DB	NEXT
	DB "Шихо:   Что с тобой?"
	DB	NEXT
	DB "Кенджиру:  О, ничего..."
	DB	NEXT
	DB "Шихо:   Серьезно? Ну, я иду в библиотеку."
	DB	NEXT
	TATI_ERS
	DB "Она выходит из класса."
	DB	NEXT
	DB "Наверное, я пойду."
	DB	NEXT
	GO	ROUKA1
T2:
	FLG_IF	TEMP01,'>=',2,KYOUSITU1
	FLG_KI	TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB "Я иду на крышу."
	DB	NEXT
	BAK_INIT	'tb_012',B_NORM
	DB "Я на крыше. Я вижу Теруми-сенпай, стоящую напротив цепного ограждения."
	DB	NEXT
	T_CG	'tt_05_12',TER2,0
	DB "Кенджиру:  Теруми-сенпаи."
	DB	NEXT
	DB "Теруми:  A, Кенджиру."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	V1,"ОСМОТР ГРУДИ"
	MENU_SET	V2,"ОСМОТР ПОПЫ"
	MENU_SET	V3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
V1:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',3
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT1
	FLG_KI	TER_NET,'=',1
TER_TAT1:
	DB "У нее отличные груди, большие, прекрасной формы. Большого объема."
	DB	NEXT
	GO BODY_TERMI
V2:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT2
	FLG_KI	TER_NET,'=',1
TER_TAT2:
	DB "Ее попка маленькая и хорошая, с отличной талией."
	DB	NEXT
	GO BODY_TERMI
V3:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',4
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT3
	FLG_KI	TER_NET,'=',1
TER_TAT3:
	DB "Ее бедра гладкие и шелковистые, до самого верха."
	DB	NEXT
	GO BODY_TERMI
BODY_TERMI:
	DB "Теруми:  В чем дело? Почему ты уставился на меня?"
	DB	NEXT
	DB "Кенджиру:  О, нет, просто. А, что ты делаешь здесь одна?"
	DB	NEXT
	DB "Теруми:  Вообще-то ничего. Просто думаю." 
	DB	T_WAIT, 5
	DB " А ты?"
	DB	NEXT
	DB "Кенджиру:  Да ничего особенного. Просто брожу по школе."
	DB	NEXT
	DB "Теруми:  У тебя куча свободного времени" 
	DB	NEXT
	DB "Кенджиру:  Как и у тебя."
	DB	NEXT
	DB "Внезапно она придвигается ближе"
	DB	NEXT
	DB "Кенджиру:  Хахаха! (Мне лучше смываться отсюда!)"
	DB	NEXT
	DB "Кенджиру:  Ну, увидимся позже, Теруми-сенпай!"
	DB	NEXT
	DB "Теруми:  Подожди!" 
	DB	NEXT
	DB "Я иду по лестнице."
	DB	NEXT
	GO	ROUKA1
T3:
	FLG_KI TEMP04,'=',1
	DB "Я, наверное, сегодня не должен видеть Мотоку. Просто оставлю ее."
	DB	NEXT
	GO	ROUKA1
T4:
	FLG_IF TEMP01,'>=',2,KYOUSITU1
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB "Наверное, загляну в кладовку."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB "Тецуя здесь, ищет мяч."
	DB	NEXT
	T_CG 'tt_08_15',TET_A2,0
	FLG_KI TET_KAIS,'+',1
	DB "Кенджиру:  Эй, Тецуя. Что ты здесь делаешь?"
	DB	NEXT
	DB "Тецуя:    О, Кенджиру. Я пытаюсь найти хороший мяч."
	DB	NEXT
	DB "Кенджиру:  Я просто гуляю."
	DB	NEXT
	DB "Тецуя:    Ты рад?"
	DB	NEXT
	DB "Кенджиру:  Ага. Ну, увидимся позже."
	DB	NEXT
	DB "Я покидаю кладовку."
	DB	NEXT
	GO	ROUKA1
T5:
	FLG_IF TEMP01,'>=',2,KYOUSITU1
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB "Интересно, почему прекрасная Мика-сенсей тут."
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	CDPLAY		18
	DB "Мика-сенсей здесь, протирает статуи."
	DB	NEXT
	DB "Кенджиру:  Мика-sensei."
	DB	NEXT
	DB "Мика:  А, Кондо-кун."
	DB	NEXT
	T_CG 'tt_12_13a',MIK2,0
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	X1,"ОСМОТР ГРУДИ"
	MENU_SET	X2,"ОСМОТР ПОПЫ"
	MENU_SET	X3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
X1:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',4
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,MIKA_TAT1
	FLG_KI	MIKA_NET,'=',1
MIKA_TAT1:
	DB "У нее скрещены руки, так что я не вижу ее груди. Но я хотел бы подвигать между них своим членом."
	DB	NEXT
	GO BODY_MIKA
X2:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,MIKA_TAT2
	FLG_KI	MIKA_NET,'=',1
MIKA_TAT2:
	DB "Симпатичный зад. Я никогда не забуду это чувство..."
	DB	NEXT
	GO BODY_MIKA
X3:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,MMM
	FLG_KI	MIKA_NET,'=',1
MMM:
	DB "Мягкие, упругие, красивые бедра"
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB "Мика:  Почему ты на меня похотливо смотришь?" 
	DB	NEXT
	DB "Кенджиру:  А? Что значит похотливо?"
	DB	NEXT
	DB "Мика:  А, ничего."
	DB	NEXT
	DB "Мика:  Я рада, что ты вовремя пришел."
	DB	NEXT
	DB "Кенджиру:  А?"
	DB	NEXT
	DB "Мика:  Не говори мне, что забыл!"
	DB	NEXT
	DB "О нет! Я забыл!"
	DB	NEXT
	DB "Кенджиру:  Увидимся позже, сенсей..."
	DB	NEXT
	DB "Мика:  Подожди, Кондо!"
	DB	NEXT
	DB "Я спешно покидаю кабинет."
	DB	NEXT
	GO ROUKA1
T6:
	FLG_IF TEMP01,'>=',2,KYOUSITU1
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB "Я иду в мужскую уборную."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	T_CG 'tt_03_17a',HIR2,0
	DB "По дороге я врезаюсь в Хироши."
	DB	NEXT
	DB "Хироши:   О, Кондо. Пришел просраться?"
	DB	NEXT
	DB "Кенджиру:  Ага, типа того."
	DB	NEXT
	DB "Хироши:   Ну, увидимся позже."
	DB	NEXT
	TATI_ERS
	DB "Вторая кабинка, моя операционная. Она открывается, как обычно."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	Y1,"ДЕЛАЙ"
	MENU_SET	Y2,"НЕ ВОЛНУЙСЯ"
	MENU_END
	DB	EXIT
Y1:
	F_O	B_NORM,C_KURO
	FLG_IF YOKU,'<',45,DERU
	FLG_IF YOKU,'<',100,SENTAKU2
	FLG_IF AKEM_NET,'!=',1,SS_1
	FLG_KI HAND,'=',4
	SINARIO 'AK_H.OVL'
SS_1:
	FLG_IF MIKA_NET,'!=',1,SS_2
	FLG_KI HAND,'=',4
	SINARIO 'MI_H.OVL'
SS_2:
	FLG_IF TER_NET,'!=',1,SS_3
	FLG_KI HAND,'=',4
	SINARIO 'TE_H.OVL'
SS_3:
	FLG_IF RENA_NET,'!=',1,SS_4
	FLG_KI HAND,'=',4
	SINARIO 'RE_H.OVL'
SS_4:
	FLG_IF NANA_NET,'!=',1,SS_5
	FLG_KI HAND,'=',4
	SINARIO 'NA_H.OVL'
SS_5:
	FLG_IF SIZU_NET,'!=',1,SS_6
	FLG_KI HAND,'=',4
	SINARIO 'SI_H.OVL'
SS_6:
	FLG_IF CHIE_NET,'!=',1,SS_7
	FLG_KI HAND,'=',4
	SINARIO 'CH_H.OVL'
SS_7:
SENTAKU2:
	F_O	B_NORM,C_KURO
	FLG_KI W,'=',-1
	FLG_IF REN_ATTA,'=',1,DD_1
	FLG_KI W,'DOWN',3
DD_1:
	FLG_IF NAN_ATTA,'=',1,DD_2
	FLG_KI W,'DOWN',4
DD_2:
	FLG_IF SIZ_ATTA,'=',1,DD_3
	FLG_KI W,'DOWN',5
DD_3:
	FLG_IF CHI_ATTA,'=',1,DD_4
	FLG_KI W,'DOWN',6
DD_4:
	MENU_S	2,W,-1
	MENU_SET	Z1,"АКЕМИ КОНДО"
	MENU_SET	Z2,"ТЕРУМИ КИНОУШИ"
	MENU_SET	Z3,"МИКА МАЕДА"
	MENU_SET	Z4,"РЕНА ВАТАНАБЕ"
	MENU_SET	Z5,"НАНА ХИРОС"
	MENU_SET	Z6,"ШИЗУКА ХАСЕГАВА"
	MENU_SET	Z7,"ШИЕ УТСУМИ"
	MENU_SET	Z8,"НЕ НУЖНО"
	MENU_END
	DB	EXIT
Z1:
        DB "Ммм, сделаю это с  Акеми-сан."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'AK_H.OVL'
Z2:
	DB "Ммм, Теруми-сенпай тоже неплоха."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'TE_H.OVL'
Z3:
	DB "Я хотел бы сделать это с Микой-сенсей..."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'MI_H.OVL'
Z4:
	DB "Хочу оживить воспоминания о весенних каникулах."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'RE_H.OVL'
Z5:
	DB "Я бы хотел сорвать с нее одежду..."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'NA_H.OVL'
Z6:
	DB "Она меня так возбуждает..."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'SI_H.OVL'
Z7:
	DB "Она чудесна в своем купальнике."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'CH_H.OVL'
Z8:
	DB "Хмм, не надо волноваться."
	DB	NEXT
Y2:
DERU:
	DB "У меня нет причин находиться здесь, лучше уйду."
	DB	NEXT
	GO ROUKA1
TOIRE1:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB "Чувствуя себя лучше, кончив, я иду к умывальнику."
	DB	NEXT
	DB "Ах, было здорово..."
	DB	NEXT
	DB "Наверное, мне надо вымыть руки."
	DB	NEXT
	DB "Я закончил и вышел в холл."
	DB	NEXT
	GO ROUKA1
T7:
	FLG_IF TEMP01,'>=',2,KYOUSITU1
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB "Медпункт. Интересно, как поживает Шизука-сенсей?"
	DB	NEXT
	EVENT_CG	'th_072',B_NORM,35
	DB "Шизука:   Ты поранился?"
	DB	NEXT
	DB "Кенджиру:  Нет, все ОК."
	DB	NEXT
	DB "Шизука:   Тогда почему ты здесь?"
	DB	NEXT
	DB "Кенджиру:  Хотел тебя видеть."
	DB	NEXT
	DB "Шизука:   Спасибо."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AA_1,"ОСМОТР ЛИЦА"
	MENU_SET	AA_2,"ОСМОТР РУК"
	MENU_SET	AA_3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
AA_1:
	FLG_IF	YOKU,'>=',100,HOKEN2
	FLG_KI	YOKU,'+',4
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_1
	FLG_KI SIZU_NET,'=',1
GG_1:
	DB "У нее сексуальное лицо."
	DB	NEXT
	GO BODY_SIZUKA
AA_2:
	FLG_IF	YOKU,'>=',100,HOKEN2
	FLG_KI	YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_2
	FLG_KI SIZU_NET,'=',1
GG_2:
	DB "Я бы хотел ощутить наманикюренные пальчики вокруг себя."
	DB	NEXT
AA_3:
	FLG_IF	YOKU,'>=',100,HOKEN2
	FLG_KI	YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_3
	FLG_KI SIZU_NET,'=',1
GG_3:
	DB "Я могу видеть тесьму на ее чулках. Это слишком сексуально."
	DB	NEXT
	GO BODY_SIZUKA
BODY_SIZUKA:
	DB "Шизука:   Куда это ты смотришь?"
	DB	NEXT
	DB "Кенджиру:  Да, никуда."
	DB	NEXT
	DB "Шизука:   Ты молод, так что думаю, с этим ничего не поделаешь."
	DB	NEXT
	DB "Кенджиру:  П- Простите."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB "Нет женщины горячее, чем Шизука-сенсей."
	DB	NEXT
	GO ROUKA1
HOKEN1:
	FLG_KI HOK,'=',5
	SINARIO 'ER.OVL'
HOKEN2:
	FLG_KI HOK,'=',5
	SINARIO 'ER2.OVL'
KYOUSITU1:
	FLG_KI HOK,'=',0
	DB "Наверное, я должен вернуться."
	DB	NEXT
	BAK_INIT	'tb_010',B_FADE
	DB "Посмотрим, пора вздремнуть"
	DB	NEXT
	;WAV	'Se_ch'
	DB "Звонок будит меня. Начинается урок."
	DB	NEXT
	DB "Глупый звон."
	DB	NEXT
	B_O B_FADE,C_KURO
	;;WAV  'STOP'
	FLG_KI JUMP,'=',63
	SINARIO	'NITI_HOK.OVL'
FUFUFU_1:
	FLG_KI JUMP,'=',0
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY		22
	DB "Когда я ухожу, уже темно. В эти дни быстро темнеет."
	DB	NEXT
	DB "Думаю, я сразу пойду домой."
	DB	NEXT
	FLG_KI	TEMP01,'=',0
	FLG_KI	TEMP02,'=',0
	FLG_KI	TEMP03,'=',0
	FLG_KI	TEMP04,'=',0
	FLG_KI	TEMP05,'=',0
	FLG_KI	TEMP06,'=',0
	FLG_KI	TEMP07,'=',0
	FLG_KI	TEMP08,'=',0
	GO	SENTAKU
MATI:
	BAK_INIT	'tb_018c',B_NORM
	DB "Так куда же мне идти?"
	DB	NEXT
SENTAKU:
	FLG_KI W,'=',-1
	FLG_IF	TEMP02,'=',0,MM_1
	FLG_KI W,'DOWN',0
MM_1:
	FLG_IF	TEMP03,'=',0,MM_2
	FLG_KI W,'DOWN',1
MM_2:
	FLG_IF	TEMP04,'=',0,MM_3
	FLG_KI W,'DOWN',2
MM_3:
	FLG_IF	TEMP05,'=',0,MM_4
	FLG_KI W,'DOWN',3
MM_4:
	FLG_IF	TEMP06,'=',0,MM_5
	FLG_KI W,'DOWN',4
MM_5:
	FLG_IF	TEMP07,'=',0,MM_6
	FLG_KI W,'DOWN',5
MM_6:
	FLG_IF	TEMP08,'=',0,MM_7
	FLG_KI W,'DOWN',6
MM_7:
	FLG_IF	REN_ATTA,'=',1,MM_8
	FLG_KI W,'DOWN',5
MM_8:
	FLG_IF	NAN_ATTA,'=',1,MM_9
	FLG_KI W,'DOWN',6
MM_9:
	MENU_S	2,W,-1
	MENU_SET	AH1,"КИНОТЕАТР"
	MENU_SET	AH2,"СТРИП БАР"
	MENU_SET	AH3,"ПАРК"
	MENU_SET	AH4,"МОЙ ОТЕЛЬ"
	MENU_SET	AH5,"БАР"
	MENU_SET	AH6,"КАФЕ"
	MENU_SET	AH7,"РЕСТОРАН"
	MENU_SET	AH8,"ДОМОЙ"
	MENU_END
	DB	EXIT
AH1:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB "Наверное, схожу в кино."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB "Здесь все вокруг обветшалое."
	DB	NEXT
	DB "Это большая проблема Японии."
	DB	NEXT
	DB "Ну, нет никаких интересных фильмов, так что не надо суетиться."
	DB	NEXT
	GO MATI
AH2:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB "Думаю, пойду проверю магазин жен. белья."
	DB	NEXT
	BAK_INIT 'tb_027',B_NORM
	DB "Какое чудное место."
	DB	NEXT
	T_CG 'tt_07_27',TET_B2,0
	FLG_KI TET_KAIS,'+',1
	DB "Тецуя:    Кенджиру, что ты здесь делаешь?"
	DB	NEXT
	DB "Возникает Тецуя."
	DB	NEXT
	DB "Кенджиру:  Я? А ты?"
	DB	NEXT
	DB "Тецуя:    Я? О, я просто.. просто.."
	DB	NEXT
	DB "Кенджиру:  Да?"
	DB	NEXT
	DB "Тецуя:    Ты должен признать это место очень круто."
	DB	NEXT
	DB "Кенджиру:  Наверно."
	DB	NEXT
	DB "Тецуя:    Не хотел бы ты войти внутрь, хоть разок?" 
	DB	NEXT
	DB "Кенджиру:  Ну, немного."
	DB	NEXT
	DB "Тецуя:    Видишь? Я хочу однажды попасть туда" 
	DB	NEXT
	DB "Тецуя смотрит на вывеску магазина, потерявшись в своем мире."
	DB	NEXT
	DB "Думаю, нужно оставить его."
	DB	NEXT
	GO MATI
AH3:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB "Парк. Какое эротичное место."
	DB	NEXT
	BAK_INIT 'tb_032b',B_NORM
	CDPLAY		8
	DB "Там много парочек, гуляющих вместе. Интересно, сколько их прячется в кустах?"
	DB	NEXT
	DB "Теруми:  Что ты делаешь здесь?"
	DB	NEXT
	DB "Я поворачиваюсь, чтобы увидеть Теруми-сенпай."
	DB	NEXT
	T_CG 'tt_05_32b',TER2,0
	DB "Кенджиру:  Ах, Теруми-сенпай."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AI1,"ОСМОТР ГРУДИ"
	MENU_SET	AI2,"ОСМОТР ПОПЫ"
	MENU_SET	AI3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
AI1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JOJO_1
	FLG_KI TER_NET,'=',1
JOJO_1:
	DB "У нее отличные груди. Большого объема."
	DB	NEXT
	GO BODY_TERMI_2
AI2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',11
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JOJO_2
	FLG_KI TER_NET,'=',1
JOJO_2:
	DB "Ее попка маленькая и твердая, с отличной талией."
	DB	NEXT
	GO BODY_TERMI_2
AI3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JOJO_3
	FLG_KI TER_NET,'=',1
JOJO_3:
	DB "Ее бедра мягкие и гибкие."
	DB	NEXT
	GO BODY_TERMI_2
BODY_TERMI_2:
	DB "Теруми:  П- Почему ты так притих?" 
	DB	NEXT
	DB "Кенджиру:  А? О, ничего. Почему ты здесь?"
	DB	NEXT
	DB "Теруми:  Я просто вышла погулять."
	DB	NEXT
	DB "Кенджиру:  В таком темном, опасном месте?"
	DB	NEXT
	DB "Теруми:  Тебя это беспокоит?" 
	DB	NEXT
	DB "Она выглядит счастливой."
	DB	NEXT
	DB "Кенджиру:  Да, боюсь, кто-нибудь попытается напасть на тебя..."
	DB	NEXT
	DB "Теруми:  Что ты сказал?" 
	DB	NEXT
	DB "Кенджиру:  Мне-Мне жаль!"
	DB	NEXT
	DB "Я спешно покидаю парк."
	DB	NEXT
	GO MATI
AH4:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB "Это отель любви. Я никогда не был внутри."
	DB	NEXT
	BAK_INIT 'tb_025',B_NORM
	DB "Здесь большая ярка вывеска."
	DB	NEXT
	DB "Нет причин торчать здесь. Наверное, я лучше пойду."
	DB	NEXT
	GO MATI
AH5:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB "Нет причин входить внутрь."
	DB	NEXT
	DB "Думаю, не проблема постоять снаружи."
	DB	NEXT
	DB "Я иду в бар."
	DB	NEXT
	BAK_INIT 'tb_029',B_NORM
	T_CG 'tt_03_29',HIR2,0
	DB "Хироши:   Что ты делаешь здесь?"
	DB	NEXT
	DB "Это Хироши!"
	DB	NEXT
	DB "Кенджиру:  О, ничего. Просто проходил мимо. Увидимся позже."
	DB	NEXT
	DB "Я покидаю бар."
	DB	NEXT
	GO MATI
AH6:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB "Кофейня. Интересно, Рена все еще здесь?"
	DB	NEXT
	BAK_INIT 'tb_021',B_NORM
	T_CG 'tt_17_21',REN_A2,0
	DB "Рена:  Привет, могу ли я..."
	DB	T_WAIT, 5
	DB " О, это ты, Кенджиру." 
	DB	NEXT
	DB "Кенджиру:  Ты не должна так говорить!"
	DB	NEXT
	DB "Рена:  Но 'Чем я могу помочь?' мы говорим клиентам. А ты друг."
	DB	NEXT
	DB "Кенджиру:  Я знаю. Я просто."
	DB	NEXT
	DB "Кенджиру:  Тебе не холодно в этой одежде?"
	DB	NEXT
	DB "Рена:  Нет, все ОК." 
	DB	NEXT
	DB "Кенджиру:  Ясно. (Мне на нее холодно смотреть.)"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AJ1,"ОСМОТР ШЕИ"
	MENU_SET	AJ2,"ОСМОТР ПЛЕЧ"
	MENU_SET	AJ3,"ОСМОТР ГРУДИ"
	MENU_END
	DB	EXIT
AJ1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JJ_1
	FLG_KI RENA_NET,'=',1
JJ_1:
	DB "Белая, тонкая шея... Я хочу лизнуть ее."
	DB	NEXT
	GO BODY_RENA_2
AJ2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',7
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JJ_2
	FLG_KI RENA_NET,'=',1
JJ_2:
	DB "Ее плечи выглядят крепкими и эротичными. Я бы хотел обнять ее."
	DB	NEXT
	GO BODY_RENA_2
AJ3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JJ_3
	FLG_KI RENA_NET,'=',1
JJ_3:
	DB "Я не могу много увидеть через фартук, но выглядит прекрасно."
	DB	NEXT
	GO BODY_RENA_2
BODY_RENA_2:
	DB "Рена:  А, твои глаза." 
	DB	T_WAIT, 5
	DB " Они ищут грязные места."
	DB	NEXT
	DB "Кенджиру:  Я так был рожден."
	DB	NEXT
	DB "Рена:  Ну, мы с тобой больше не встречаемся, так что никаких идей." 
	DB	NEXT
	DB "Кенджиру:  Ясно."
	DB	NEXT
	DB "Рена:  Ну, ладно." 
	DB	NEXT
	DB "Рена взъерошила мои волосы."
	DB	NEXT
	DB "Кенджиру:  Хаха..."
	DB	T_WAIT, 5
	DB " Спасибо"
	DB	NEXT
	DB "Я покидаю кофейню."
	DB	NEXT
	GO MATI
AH7:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB "Я совсем не голоден, но, наверное, загляну внутрь."
	DB	NEXT
	BAK_INIT 'tb_023',B_NORM
	DB "Нана:  Привет, я могу помочь?" 
	DB	NEXT
	DB "Кенджиру:  А, она здесь."
	DB	NEXT
	DB "Нана:  Чего желаете, сэр?" 
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AK1,"ОСМОТР ГРУДИ"
	MENU_SET	AK2,"ОСМОТР ГРУДИ"
	MENU_SET	AK3,"ОСМОТР ГРУДИ"
	MENU_END
	DB	EXIT
AK1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,II_1
	FLG_KI NANA_NET,'=',1
II_1:
	DB "Они прекрасны. Что я могу сказать?"
	DB	NEXT
	GO BODY_NANA_2
AK2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,II_2
	FLG_KI NANA_NET,'=',1
II_2:
	DB "Прекрасные груди."
	DB	NEXT
	GO BODY_NANA_2
AK3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,II_3
	FLG_KI NANA_NET,'=',1
II_3:
	DB "Я хочу сорвать с нее эту униформу."
	DB	NEXT
	GO BODY_NANA_2
BODY_NANA_2:
	DB "Нана:  Чего Вы желаете?"
	DB	NEXT
	DB "Кенджиру:  Груди..."
	DB	NEXT
	DB "Нана:  Простите, у нас в ресторане этого нет." 
	DB	NEXT
	DB "Кенджиру:  О, тогда я пойду."
	DB	NEXT
	DB "Нана:  Большое спасибо." 
	DB	NEXT
	DB "Я покидаю ресторан фаст-фуд."
	DB	NEXT
	GO MATI
AH8:
	DB "Наверное, пойду домой."
	DB	NEXT
	GO	JITAKU
JITAKU:
	BAK_INIT	'tb_018c',B_NORM
	DB "Я голоден."
	DB	T_WAIT,	3
	DB " Пора идти домой."
	DB	NEXT
	BAK_INIT 'tb_005c',B_NORM
	DB "А, хорошо быть дома."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		6
	T_CG 'tt_20_02',AKE_A2,0
	DB "Кенджиру:  Я дома."
	DB	NEXT
	DB "Акеми:  Привет"
	DB	NEXT
	DB "Кенджиру:  Где Мотока?"
	DB	NEXT
	DB "Акеми:  Она не вернулась." 
	DB	NEXT
	DB "Кенджиру:  Да."
	DB	NEXT
	DB "Акеми:  Можно пообедать?"
	DB	NEXT
	DB "Кенджиру:  ...Да, спасибо."
	DB	NEXT
	DB "Акеми:  Ладно"
	DB	NEXT
	DB "Я обедаю с Акеми-сан. Она отложила порцию Мотоки напотом."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY		12
	DB "Уже 10 вечера, а Мотока еще не вернулась"
	DB	NEXT
	DB "Кенджиру:  Где эта девчонка...?"
	DB	NEXT
	DB "Я как раз услышал маленькие шаги в фойе."
	DB	NEXT
	DB "Я, наверное, должен оставить ее ненадолго."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB "Я выключаю свет и готовлюсь ко сну."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_KI	KURI,'+',1
	FLG_IF	KURI,'>=',3,NUKE
	GO	SMK
HEYA:
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI	YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_NORM,C_KURO
	DB "Кенджиру:  Ууууннн..."
	DB	NEXT
	DB "Я открыл глаза."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB "Кенджиру:  Где я?"
	DB	NEXT
	DB "Я сбит с толку, но постепенно пришел в себя. Я был в своей комнате."
	DB	NEXT
	DB "Как я вернулся сюда?"
	DB	NEXT
	DB "На моей одежде коричневое пятно."
	DB	NEXT
	DB "Кровь? У меня шла кровь."
	DB	NEXT
	DB "Что случилось после того?"
	DB	NEXT
	DB "Я, наверное, потерял сознание."
	DB	NEXT
	DB "Кто-то, наверное, принес меня в мою комнату."
	DB	NEXT
	DB "Я смотрю на часы. Показывают 9:30."
	DB	NEXT
	DB "Мотока уже дома?"
	DB	NEXT
	DB "Я одеваюсь и выхожу из комнаты."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB "Я постучал в дверь Мотоки, но ответа не последовало"
	DB	NEXT
	DB "Кенджиру:  Может, она на кухне..."
	DB	NEXT
	DB "Я направляюсь в кухню."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	DB "Ее обед все еще на столе, по-прежнему накрыт, как раньше. Похоже, она не вернулась ночью домой."
	DB	NEXT
	DB "Кенджиру:  Она не пришла домой."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB "Я возвращаюсь в комнату и ложусь на постель. Я знал, что слышал шаги в 10 часов в фойе, и я уверен, что это была она."
	DB	NEXT
	DB "Я пытаюсь подняться с кровати, но вспоминаю слова Акеми."
	DB	NEXT
	DB "Верь Мотоке..."
	DB	T_WAIT, 3
	DB " Думаю, она права."
	DB	NEXT
	DB "Я не должен так беспокоиться о ней. С ней все в порядке."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB "Я выключаю свет и готовлюсь ко сну."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_KI	KURI,'+',1
	FLG_IF	KURI,'>=',3,NUKE
	GO	SMK
NUKE:
	FLG_KI	KURI,'=',0
	SINARIO 'MON_24.OVL'
END
