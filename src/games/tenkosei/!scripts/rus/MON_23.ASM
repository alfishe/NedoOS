        include SUPER_C.inc
M_START:
MON_23
	FLG_IF JUMP,'=',63,FUFUFU_1
	FLG_IF HOK,'=',5,KYOUSITU1
	FLG_IF HAND,'=',4,TOIRE1
SMK:
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB	"Я толком не выспался..."
	DB	NEXT
	DB	"Я переодеваюсь и спускаюсь вниз."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY		20
	T_CG	'tt_20_02',AKE_A3,0
	T_CG	'tt_21_02',MOT_A1,0
	DB	"Кэндзиро: Доброе утро."
	DB	NEXT
	DB	"Акэми: Доброе утро, Кэндзиро."
	DB	NEXT
	DB	"Мотока: ................."
	DB	NEXT
	DB	"Мотока меня не приветствует."
	DB	NEXT
	DB	"Кэндзиро: Мотока, ты вчера пришла ужасно поздно."
	DB	NEXT
	DB	"Мотока: ................" 
	DB	NEXT
	DB	"Акэми: Мотока, надо поздороваться с Кэндзиро."
	DB	NEXT
	DB	"Мотока: Я пошла в школу."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_20_02',AKE_A2,0
	CDPLAY		6
	DB	"Акэми: А, Мотока..."
	DB	NEXT
	DB	"Кэндзиро: ...Мотока."
	DB	NEXT
	DB	"Акэми: Прости, Кэндзиро-кун." 
	DB	NEXT
	DB	"Кэндзиро: Всё нормально."
	DB	NEXT
	DB	"Акэми: Наверное, она..." 
	DB	NEXT
	DB	"Кэндзиро: Что?"
	DB	NEXT
	DB	"Акэми: Ничего."
	DB	NEXT
	DB	"Кэндзиро: .................."
	DB	NEXT
	DB	"Кэндзиро: Что ж, тогда я тоже пойду в школу."
	DB	NEXT
	DB	"Акэми: До скорого."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_006',B_NORM
	CDPLAY		2
	DB	"Зайду, пожалуй..."
	DB	NEXT
	DB	"Я захожу в магазин."
	DB	NEXT
	BAK_INIT	'tb_007',B_NORM
	CDPLAY	3
	DB	NEXT
	DB	"Я часто вижу здесь Тэруми-сэмпай."
	DB	NEXT
	T_CG	'tt_05_07',TER2,0
	DB	"Кэндзиро: А, Тэруми-сэмпай, доброе утро."
	DB	NEXT
	DB	"Тэруми: Доброе утро. Ты сегодня немного подавлен." 
	DB	NEXT
	DB	"Кэндзиро: О, я вчера поздно лёг."
	DB	NEXT
	DB	"Тэруми: Бьюсь об заклад, порнуху смотрел, верно?" 
	DB	NEXT
	DB	"Кэндзиро: ...Что-то в этом роде."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	R1,"ПРИГЛАСИТЬ ТЭРУМИ-СЭМПАЙ"
	MENU_SET	R2,"ПОЙТИ В ШКОЛУ ОДНОМУ"
	MENU_END
	DB	EXIT
R1:
	DB	"Кэндзиро: ......"
	DB	T_WAIT, 5
	DB	"Тэруми-сэмпай, не пора ли нам в школу?"
	DB	NEXT
	DB	"Тэруми: Э? О, да. Как насчёт твоего обеда?"
	DB	NEXT
	DB	"Кэндзиро: Я сейчас."
	DB	NEXT
	DB	"Я беру рисовые колобки и направляюсь на кассу."
	DB	NEXT
	DB	"Кэндзиро: Тэруми-сэмпай, я готов. Пошли." 
	DB	NEXT
	DB	"Тэруми: Ладно."
	DB	NEXT
	DB	"Я кладу рисовые колобки в портфель, и выхожу из магазина."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO	GAKU1
R2:
	DB	"Кэндзиро: Ну, счастливо."
	DB	NEXT
	DB	"Я иду в школу один."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_009',B_NORM
	CDPLAY		23
	DB	"Кэндзиро: Как обычно, полно народу."
	DB	NEXT
	DB	"Голос: Кэндзиро-кун."
	DB	NEXT
	DB	"Я поворачиваюсь, чтобы посмотреть, кто меня звал."
	DB	NEXT
	T_CG	'tt_02_09',SIH_A2,0
	DB	"Сихо: Кэндзиро-кун, доброе утро."
	DB	NEXT
	DB	"Кэндзиро: Доброе."
	DB	NEXT
	DB	"Сихо: Ты сегодня не очень бодрый."
	DB	NEXT
	DB	"Сихо смотрит на меня своими большими глазами."
	DB	NEXT
	DB	"Кэндзиро: Я сегодня не выспался."
	DB	NEXT
	DB	"Сихо: Тебе надо ложиться пораньше." 
	DB	NEXT
	DB	"Кэндзиро: Ты права."
	DB	NEXT
	DB	"Сихо: Пойдём в школу?" 
	DB	T_WAIT, 5
	DB	" вместе?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	S1,"ПОЙТИ С НЕЙ"
	MENU_SET	S2,"ПОЙТИ ОДНОМУ"
	MENU_END
	DB	EXIT
S1:
	DB	"Кэндзиро: Ладно, пошли."
	DB	NEXT
	DB	"Сихо: Хорошо."
	DB	NEXT
	DB	"Я иду в школу с Сихо."
	DB	NEXT
	GO	GAKU2
	DB	EXIT
S2:
	DB	"Кэндзиро: Нет, я хочу пойти один."
	DB	NEXT
	DB	"Сихо: Ясно..."
	DB	NEXT
	DB	"Я иду в школу один."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO	GAKU1
	DB	EXIT
GAKU1:
	BAK_INIT	'tb_010',B_NORM
	CDPLAY		14
	T_CG	'tt_08_10',TET_A2,0
	DB	"Тэцуя: Привет."
	DB	NEXT
	DB	"Кэндзиро: Привет."
	DB	NEXT
	DB	"Тэцуя: Как дела?"
	DB	NEXT
	DB	"Кэндзиро: Хмм, так себе."
	DB	NEXT
	DB	"Тэцуя: Правда? А у меня нормально."
	DB	NEXT
	DB	"Кэндзиро: ................"
	DB	NEXT
	DB	"Тэцуя: Эй, отзовись! Сделай что-нибудь!"
	DB	NEXT
	;WAV	'Se_ch'
	DB	"Внезапно прозвенел звонок. Уроки начинаются."
	DB	NEXT
	DB	"Кэндзиро: Извини, я немного устал."
	DB	NEXT
	DB	"Тэцуя: ..............."
	DB	NEXT
	TATI_ERS
	DB	"Я сажусь на своё место."
	DB	NEXT
	;WAV  'STOP'
	CDPLAY	0
	F_O B_NORM,C_KURO
	DB	"Я тупо пялюсь на доску."
	DB	NEXT
	DB	"Не могу перестать думать о Мотоке."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO HIRUYASUMI
	DB	EXIT
GAKU2:
	BAK_INIT	'tb_010',B_NORM
	CDPLAY		23
	T_CG	'tt_02_10',SIH_A1,0
	T_CG	'tt_08_10',TET_A3,0
	DB	"Тэцуя: Доброе утро, Касима-сан."
	DB	NEXT
	DB	"Сихо: Доброе утро."
	DB	NEXT
	DB	"Кэндзиро: ................"
	DB	NEXT
	DB	"Я сажусь на своё место."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		14
	DB	"Я тупо пялюсь на доску."
	DB	NEXT
	DB	"Не могу перестать думать о Мотоке."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO	HIRUYASUMI
HIRUYASUMI:
	F_O B_NORM,C_KURO
	DB	"Вдруг настал обеденный перерыв."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	DB	"Я выхожу в коридор."
	DB	NEXT
	BAK_INIT	'tb_034a',B_NORM
	DB	"Пора пойти полюбоваться на красивых девчонок..."
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
	DB	"Так куда мне пойти?"
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
	MENU_SET	T1,"ВЕРНУТЬСЯ В КЛАСС"
	MENU_SET	T2,"НА КРЫШУ"
	MENU_SET	T3,"В КЛАСС МОТОКИ"
	MENU_SET	T4,"В ПОДСОБКУ СПОРТЗАЛА"
	MENU_SET	T5,"В КАБИНЕТ ИЗО"
	MENU_SET	T6,"В МУЖСКОЙ ТУАЛЕТ"
	MENU_SET	T7,"В МЕДКАБИНЕТ"
	MENU_END
	DB	EXIT
T1:
	FLG_IF	TEMP01,'>=',2,KYOUSITU1
	FLG_KI	TEMP01,'+',1
	FLG_KI	TEMP02,'=',1
	DB	"Пожалуй, вернусь обратно в класс."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	CDPLAY		23
	T_CG	'tt_02_10',SIH_A2,0
	DB	"Когда я собрался выйти из класса, я налетел на Сихо."
	DB	NEXT
	DB	"Сихо: А, Кэндзиро-кун."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	U1,"СМОТРЕТЬ НА ЛИЦО"
	MENU_SET	U2,"СМОТРЕТЬ НА ГРУДИ"
	MENU_SET	U3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
U1:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"У Сихо замечательное лицо. Практически превосходное."
	DB	NEXT
	GO BODY_SHIHO
U2:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"У неё великолепные груди, скрытые под школьной формой."
	DB	NEXT
	GO BODY_SHIHO
U3:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Чудесные ляжки, мягкие и эластичные, с идеальным количеством мясца."
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
	DB	"Хмм, я не хочу осквернять её своими грязными мыслями."
	DB	NEXT
	DB	"Сихо: В чём дело?"
	DB	NEXT
	DB	"Кэндзиро: О, ни в чём..."
	DB	NEXT
	DB	"Сихо: Правда? Ладно, я пойду в библиотеку."
	DB	NEXT
	TATI_ERS
	DB	"Она выходит из класса."
	DB	NEXT
	DB	"Пожалуй, я тоже пойду."
	DB	NEXT
	GO	ROUKA1
T2:
	FLG_IF	TEMP01,'>=',2,KYOUSITU1
	FLG_KI	TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"Я иду на крышу."
	DB	NEXT
	BAK_INIT	'tb_012',B_NORM
	DB	"Я на крыше. Я вижу Тэруми-сэмпай, стоящую возле заградительной сетки."
	DB	NEXT
	T_CG	'tt_05_12',TER2,0
	DB	"Кэндзиро: Тэруми-сэмпай."
	DB	NEXT
	DB	"Тэруми: А, Кэндзиро."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	V1,"СМОТРЕТЬ НА ГРУДИ"
	MENU_SET	V2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	V3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
V1:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',3
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT1
	FLG_KI	TER_NET,'=',1
TER_TAT1:
	DB	"У неё восхитительные груди, большие, превосходной формы. Такие пышные."
	DB	NEXT
	GO BODY_TERMI
V2:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT2
	FLG_KI	TER_NET,'=',1
TER_TAT2:
	DB	"Её задница небольшая и красивая, с потрясающей талией."
	DB	NEXT
	GO BODY_TERMI
V3:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',4
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT3
	FLG_KI	TER_NET,'=',1
TER_TAT3:
	DB	"Её ляжки гладкие и шелковистые, такие красивые."
	DB	NEXT
	GO BODY_TERMI
BODY_TERMI:
	DB	"Тэруми: В чём дело? Чего ты на меня уставился?"
	DB	NEXT
	DB	"Кэндзиро: О, ничего. Эм, что ты тут делаешь одна?"
	DB	NEXT
	DB	"Тэруми: Ничего, серьёзно. Просто думаю." 
	DB	T_WAIT, 5
	DB	" А ты?"
	DB	NEXT
	DB	"Кэндзиро: Ничего особенного. Просто шатаюсь по школе."
	DB	NEXT
	DB	"Тэруми: У тебя полно свободного времени." 
	DB	NEXT
	DB	"Кэндзиро: Прямо, как у тебя."
	DB	NEXT
	DB	"Внезапно она направилась в мою сторону."
	DB	NEXT
	DB	"Кэндзиро: Хахаха! (Лучше убраться отсюда!)"
	DB	NEXT
	DB	"Кэндзиро: Ну, счастливо, Тэруми-сэмпай!"
	DB	NEXT
	DB	"Тэруми: А, подожди!" 
	DB	NEXT
	DB	"Я спускаюсь по лестнице."
	DB	NEXT
	GO	ROUKA1
T3:
	FLG_KI TEMP04,'=',1
	DB	"Наверное, не стоит сегодня видеться с Мотокой. Я просто оставлю её в покое."
	DB	NEXT
	GO	ROUKA1
T4:
	FLG_IF TEMP01,'>=',2,KYOUSITU1
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"Пожалуй, посмотрю, что там в подсобке спортзала."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB	"Тэцуя здесь ищет мяч."
	DB	NEXT
	T_CG 'tt_08_15',TET_A2,0
	FLG_KI TET_KAIS,'+',1
	DB	"Кэндзиро: Эй, Тэцуя. Что ты тут делаешь?"
	DB	NEXT
	DB	"Тэцуя: О, Кэндзиро. Я пытаюсь найти хороший мячик."
	DB	NEXT
	DB	"Кэндзиро: Я просто шатаюсь вокруг."
	DB	NEXT
	DB	"Тэцуя: Правда?"
	DB	NEXT
	DB	"Кэндзиро: Ага. Ну, до встречи."
	DB	NEXT
	DB	"Я ухожу со склада спортинвентаря."
	DB	NEXT
	GO	ROUKA1
T5:
	FLG_IF TEMP01,'>=',2,KYOUSITU1
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"Интересно, моя обожаемая Мика-сэнсэй здесь?"
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	CDPLAY		18
	DB	"Мика-сэнсэй здесь, вытирает пыль со статуй."
	DB	NEXT
	DB	"Кэндзиро: Мика-сэнсэй."
	DB	NEXT
	DB	"Мика: А, Кондо-кун."
	DB	NEXT
	T_CG 'tt_12_13a',MIK2,0
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	X1,"СМОТРЕТЬ НА ГРУДИ"
	MENU_SET	X2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	X3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
X1:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',4
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,MIKA_TAT1
	FLG_KI	MIKA_NET,'=',1
MIKA_TAT1:
	DB	"Она скрестила руки, так что я не вижу её груди. Но я хотел бы засунуть между них свой член."
	DB	NEXT
	GO BODY_MIKA
X2:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,MIKA_TAT2
	FLG_KI	MIKA_NET,'=',1
MIKA_TAT2:
	DB	"Очень милая задница. Никогда не забуду ощущение от неё..."
	DB	NEXT
	GO BODY_MIKA
X3:
	FLG_IF	YOKU,'>=',100,HOKEN1
	FLG_KI	YOKU,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,MMM
	FLG_KI	MIKA_NET,'=',1
MMM:
	DB	"Мягкие, эластичные, очень милые ляжки."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB	"Мика: Ты смотрел на меня с вожделением?" 
	DB	NEXT
	DB	"Кэндзиро: Э? Что значит 'с вожделением'?"
	DB	NEXT
	DB	"Мика: О, неважно."
	DB	NEXT
	DB	"Мика: Я рада, что ты пришёл вовремя."
	DB	NEXT
	DB	"Кэндзиро: Э?"
	DB	NEXT
	DB	"Мика: Не говори, что забыл!"
	DB	NEXT
	DB	"О нет! Я забыл!"
	DB	NEXT
	DB	"Кэндзиро: До встречи, сэнсэй..."
	DB	NEXT
	DB	"Мика: Подожди, Кондо-кун!"
	DB	NEXT
	DB	"Я спешно покидаю кабинет ИЗО."
	DB	NEXT
	GO ROUKA1
T6:
	FLG_IF TEMP01,'>=',2,KYOUSITU1
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB	"Я направляюсь в мужской туалет."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	T_CG 'tt_03_17a',HIR2,0
	DB	"По пути я столкнулся с Хироси."
	DB	NEXT
	DB	"Хироси: О, Кондо. Посрать захотел?"
	DB	NEXT
	DB	"Кэндзиро: Да, типа того."
	DB	NEXT
	DB	"Хироси: Ну, до встречи."
	DB	NEXT
	TATI_ERS
	DB	"Вторая кабинка с конца -- мой кабинет. Как обычно, открыта."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	Y1,"СДЕЛАТЬ ЭТО"
	MENU_SET	Y2,"НЕ ЗАМОРАЧИВАТЬСЯ"
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
	MENU_SET	Z1,"АКЭМИ КОНДО"
	MENU_SET	Z2,"ТЭРУМИ КИНООТИ"
	MENU_SET	Z3,"МИКА МАЭДА"
	MENU_SET	Z4,"РЭНА ВАТАНАБЭ"
	MENU_SET	Z5,"НАНА ХИРОСЭ"
	MENU_SET	Z6,"СИДЗУКА ХАСЭГАВА"
	MENU_SET	Z7,"ТИЭ УЦУМИ"
	MENU_SET	Z8,"НЕ ДЕЛАТЬ ЭТОГО"
	MENU_END
	DB	EXIT
Z1:
        DB	"Ммм, займёмся этим с Акэми-сан."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'AK_H.OVL'
Z2:
	DB	"Ммм, с Тэруми-сэмпай было бы здорово.."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'TE_H.OVL'
Z3:
	DB	"Хотел бы я сделать это с Микой-сэнсэй..."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'MI_H.OVL'
Z4:
	DB	"Хочу оживить в памяти весенние каникулы."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'RE_H.OVL'
Z5:
	DB	"Хотел бы я сорвать с неё эту одежду..."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'NA_H.OVL'
Z6:
	DB	"Она меня так возбуждает. Я весь её."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'SI_H.OVL'
Z7:
	DB	"Мне просто нравится этот её купальник."
	DB	NEXT
	FLG_KI HAND,'=',4
	SINARIO 'CH_H.OVL'
Z8:
	DB	"Хмм, пожалуй, не буду заморачиваться."
	DB	NEXT
Y2:
DERU:
	DB	"У меня нет причин находиться здесь, пойду, пожалуй."
	DB	NEXT
	GO ROUKA1
TOIRE1:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB	"Чувствуя себя гораздо лучше после снятия напряжения, я иду к раковине."
	DB	NEXT
	DB	"Ах, это было здорово..."
	DB	NEXT
	DB	"Пожалуй, лучше мне вымыть руки."
	DB	NEXT
	DB	"Я заканчиваю и выхожу в коридор."
	DB	NEXT
	GO ROUKA1
T7:
	FLG_IF TEMP01,'>=',2,KYOUSITU1
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB	"Медицинский кабинет. Интересно, как поживает Сидзука-сэнсэй?"
	DB	NEXT
	EVENT_CG	'th_072',B_NORM,35
	DB	"Сидзука: У тебя что-то болит?"
	DB	NEXT
	DB	"Кэндзиро: Нет, всё в порядке."
	DB	NEXT
	DB	"Сидзука: Тогда зачем ты здесь?"
	DB	NEXT
	DB	"Кэндзиро: Я захотел вас увидеть."
	DB	NEXT
	DB	"Сидзука: Эээ, спасибо."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AA_1,"СМОТРЕТЬ НА ЛИЦО"
	MENU_SET	AA_2,"СМОТРЕТЬ НА РУКИ"
	MENU_SET	AA_3,"СМОТРЕТЬ НА НОЖКИ"
	MENU_END
	DB	EXIT
AA_1:
	FLG_IF	YOKU,'>=',100,HOKEN2
	FLG_KI	YOKU,'+',4
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_1
	FLG_KI SIZU_NET,'=',1
GG_1:
	DB	"У неё великолепное сексуальное личико."
	DB	NEXT
	GO BODY_SIZUKA
AA_2:
	FLG_IF	YOKU,'>=',100,HOKEN2
	FLG_KI	YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_2
	FLG_KI SIZU_NET,'=',1
GG_2:
	DB	"Хотел бы я, чтобы она обхватила этими наманикюренными пальчиками мой ствол."
	DB	NEXT
AA_3:
	FLG_IF	YOKU,'>=',100,HOKEN2
	FLG_KI	YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_3
	FLG_KI SIZU_NET,'=',1
GG_3:
	DB	"Я вижу кружевной краешек её чулок. Это чересчур сексуально."
	DB	NEXT
	GO BODY_SIZUKA
BODY_SIZUKA:
	DB	"Сидзука: Куда это ты только что смотрел?"
	DB	NEXT
	DB	"Кэндзиро: О, никуда."
	DB	NEXT
	DB	"Сидзука: У тебя ещё гормоны буйствуют, так что, полагаю, ничего с этим не поделаешь."
	DB	NEXT
	DB	"Кэндзиро: П-простите."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Нет более горячей женщины, чем Сидзука-сэнсэй."
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
	DB	"Пожалуй, надо возвращаться."
	DB	NEXT
	BAK_INIT	'tb_010',B_FADE
	DB	"Посмотрим, пора вздремнуть."
	DB	NEXT
	;WAV	'Se_ch'
	DB	"Звенит звонок, разбудив меня. Начался урок."
	DB	NEXT
	DB	"Дурацкий звонок."
	DB	NEXT
	B_O B_FADE,C_KURO
	;WAV  'STOP'
	FLG_KI JUMP,'=',63
	SINARIO	'NITI_HOK.OVL'
FUFUFU_1:
	FLG_KI JUMP,'=',0
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY		22
	DB	"Когда я ухожу, уже темно. В это время рано темнеет."
	DB	NEXT
	DB	"Пожалуй, сегодня не пойду сразу домой."
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
	DB	"Куда же мне пойти?"
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
	MENU_SET	AH1,"В КИНОТЕАТР"
	MENU_SET	AH2,"В БАР НИЖНЕГО БЕЛЬЯ"
	MENU_SET	AH3,"В ПАРК"
	MENU_SET	AH4,"В ОТЕЛЬ ЛЮБВИ"
	MENU_SET	AH5,"В БАР"
	MENU_SET	AH6,"В КОФЕЙНЮ"
	MENU_SET	AH7,"В РЕСТОРАН"
	MENU_SET	AH8,"ДОМОЙ"
	MENU_END
	DB	EXIT
AH1:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"Пожалуй, схожу в кино."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB	"Это очень убогое место."
	DB	NEXT
	DB	"Это большая проблема в Японии."
	DB	NEXT
	DB	"Что ж, смотреть нечего, так что, пожалуй, не стоит заморачиваться."
	DB	NEXT
	GO MATI
AH2:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"Пожалуй, схожу посмотрю на бар нижнего белья."
	DB	NEXT
	BAK_INIT 'tb_027',B_NORM
	DB	"Какое прекрасное место."
	DB	NEXT
	T_CG 'tt_07_27',TET_B2,0
	FLG_KI TET_KAIS,'+',1
	DB	"Тэцуя: Кэндзиро, что ты здесь делаешь?"
	DB	NEXT
	DB	"Появляется Тэцуя."
	DB	NEXT
	DB	"Кэндзиро: Я? А ты что?"
	DB	NEXT
	DB	"Тэцуя: Я? О, я просто, просто..."
	DB	NEXT
	DB	"Кэндзиро: Да?"
	DB	NEXT
	DB	"Тэцуя: Ну, ты должен признать, что это место довольно клёвое."
	DB	NEXT
	DB	"Кэндзиро: Пожалуй."
	DB	NEXT
	DB	"Тэцуя: Неужели, тебе бы не хотелось зайти сюда, хотя бы раз?" 
	DB	NEXT
	DB	"Кэндзиро: Ну, немного."
	DB	NEXT
	DB	"Тэцуя: Видишь? Я только хочу разочек попасть сюда." 
	DB	NEXT
	DB	"Тэцуя смотрит на вывеску бара нижнего белья, погрузившись в себя."
	DB	NEXT
	DB	"Пожалуй, надо оставить его в покое."
	DB	NEXT
	GO MATI
AH3:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"Парк. Эротичное место."
	DB	NEXT
	BAK_INIT 'tb_032b',B_NORM
	CDPLAY		8
	DB	"Здесь гуляет много парочек. Интересно, в кустах их тоже много?"
	DB	NEXT
	DB	"Тэруми: Что ты здесь делаешь?"
	DB	NEXT
	DB	"Я поворачиваюсь на звук голоса и вижу перед собой Тэруми-сэмпай."
	DB	NEXT
	T_CG 'tt_05_32b',TER2,0
	DB	"Кэндзиро: А, Тэруми-сэмпай."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AI1,"СМОТРЕТЬ НА ГРУДЬ"
	MENU_SET	AI2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	AI3,"СМОТРЕТЬ НА НОЖКИ"
	MENU_END
	DB	EXIT
AI1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JOJO_1
	FLG_KI TER_NET,'=',1
JOJO_1:
	DB	"У неё потрясающая грудь. Такая объёмная."
	DB	NEXT
	GO BODY_TERMI_2
AI2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',11
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JOJO_2
	FLG_KI TER_NET,'=',1
JOJO_2:
	DB	"Её задница маленькая и крепкая, отличной формы."
	DB	NEXT
	GO BODY_TERMI_2
AI3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JOJO_3
	FLG_KI TER_NET,'=',1
JOJO_3:
	DB	"Её ножки мягкие и эластичные."
	DB	NEXT
	GO BODY_TERMI_2
BODY_TERMI_2:
	DB	"Тэруми: Ч-что это ты так затих?" 
	DB	NEXT
	DB	"Кэндзиро: Э? О, ничего. Что ты тут делаешь?"
	DB	NEXT
	DB	"Тэруми: Просто вышла прогуляться."
	DB	NEXT
	DB	"Кэндзиро: В таком тёмном опасном месте?"
	DB	NEXT
	DB	"Тэруми: Ты за меня беспокоишься?" 
	DB	NEXT
	DB	"Отчего-то она выглядит довольной."
	DB	NEXT
	DB	"Кэндзиро: Да, беспокоюсь о тех, кто может попытаться на тебя напасть..."
	DB	NEXT
	DB	"Тэруми: Что ты сказал?" 
	DB	NEXT
	DB	"Кэндзиро: И-извини!"
	DB	NEXT
	DB	"Я спешно покидаю парк."
	DB	NEXT
	GO MATI
AH4:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"Это отель любви. Я никогда не был внутри."
	DB	NEXT
	BAK_INIT 'tb_025',B_NORM
	DB	"Здесь большая светящаяся вывеска."
	DB	NEXT
	DB	"Нет причины стоять здесь. Пожалуй, я пойду."
	DB	NEXT
	GO MATI
AH5:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"Нет причины заходить внутрь."
	DB	NEXT
	DB	"Хотя, думаю, ничего, если я постою снаружи."
	DB	NEXT
	DB	"Я направляюсь к бару."
	DB	NEXT
	BAK_INIT 'tb_029',B_NORM
	T_CG 'tt_03_29',HIR2,0
	DB	"Хироси: Что ты тут делаешь?"
	DB	NEXT
	DB	"Это Хироси!"
	DB	NEXT
	DB	"Кэндзиро: О, ничего. Я просто шёл мимо. Пока."
	DB	NEXT
	DB	"Я ухожу оттуда."
	DB	NEXT
	GO MATI
AH6:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB	"Кофейня. Интересно, Рэна ещё там?"
	DB	NEXT
	BAK_INIT 'tb_021',B_NORM
	T_CG 'tt_17_21',REN_A2,0
	DB	"Рэна: Здравствуйте, чем могу..."
	DB	T_WAIT, 5
	DB	" О, это ты, Кэндзиро." 
	DB	NEXT
	DB	"Кэндзиро: Не говори так!"
	DB	NEXT
	DB	"Рэна: Но 'Чем могу быть полезна?' мы спрашиваем у посетителей. А ты ведь друг."
	DB	NEXT
	DB	"Кэндзиро: Знаю. Просто я тебя дразнил."
	DB	NEXT
	DB	"Кэндзиро: Тебе не холодно в такой одежде?"
	DB	NEXT
	DB	"Рэна: Нет, всё нормально." 
	DB	NEXT
	DB	"Кэндзиро: Ясно. (По мне, так ей немного холодно.)"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AJ1,"СМОТРЕТЬ НА ШЕЮ"
	MENU_SET	AJ2,"СМОТРЕТЬ НА ПЛЕЧИ"
	MENU_SET	AJ3,"СМОТРЕТЬ НА ГРУДЬ"
	MENU_END
	DB	EXIT
AJ1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JJ_1
	FLG_KI RENA_NET,'=',1
JJ_1:
	DB	"Белая тоненькая шейка... Я хочу облизать её ещё раз."
	DB	NEXT
	GO BODY_RENA_2
AJ2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',7
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JJ_2
	FLG_KI RENA_NET,'=',1
JJ_2:
	DB	"Её плечи выглядят крепкими и эротичными. Хотел бы я прижаться к ней."
	DB	NEXT
	GO BODY_RENA_2
AJ3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,JJ_3
	FLG_KI RENA_NET,'=',1
JJ_3:
	DB	"Не могу судить из-за её фартука, но по мне, выглядят великолепно."
	DB	NEXT
	GO BODY_RENA_2
BODY_RENA_2:
	DB	"Рэна: А, твой взгляд." 
	DB	T_WAIT, 5
	DB	"  Выглядит похотливым."
	DB	NEXT
	DB	"Кэндзиро: Он от природы такой."
	DB	NEXT
	DB	"Рэна: Ну, мы с тобой больше не встречаемся, так что, не строй никаких планов." 
	DB	NEXT
	DB	"Кэндзиро: Я знаю."
	DB	NEXT
	DB	"Рэна: Тогда ладно." 
	DB	NEXT
	DB	"Рэна похлопала меня по голове, как собаку."
	DB	NEXT
	DB	"Кэндзиро: Хаха..."
	DB	T_WAIT, 5
	DB	" Спасибо."
	DB	NEXT
	DB	"Я выхожу из кофейни."
	DB	NEXT
	GO MATI
AH7:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB	"Я не очень голоден, но, пожалуй, можно зайти."
	DB	NEXT
	BAK_INIT 'tb_023',B_NORM
	DB	"Нана: Здравствуйте, чем могу вам помочь?" 
	DB	NEXT
	DB	"Кэндзиро: А, она здесь."
	DB	NEXT
	DB	"Нана: Что бы вы хотели?" 
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AK1,"СМОТРЕТЬ НА ГРУДЬ"
	MENU_SET	AK2,"СМОТРЕТЬ НА ГРУДЬ"
	MENU_SET	AK3,"СМОТРЕТЬ НА ГРУДЬ"
	MENU_END
	DB	EXIT
AK1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,II_1
	FLG_KI NANA_NET,'=',1
II_1:
	DB	"Она великолепна. Что мне ещё сказать?"
	DB	NEXT
	GO BODY_NANA_2
AK2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,II_2
	FLG_KI NANA_NET,'=',1
II_2:
	DB	"Замечательная грудь."
	DB	NEXT
	GO BODY_NANA_2
AK3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,II_3
	FLG_KI NANA_NET,'=',1
II_3:
	DB	"Я хочу сорвать с неё эту форму."
	DB	NEXT
	GO BODY_NANA_2
BODY_NANA_2:
	DB	"Нана: Что бы вы хотели?"
	DB	NEXT
	DB	"Кэндзиро: Грудку..."
	DB	NEXT
	DB	"Нана: Извините, в нашем ресторане этого не подают." 
	DB	NEXT
	DB	"Кэндзиро: О, тогда я пойду."
	DB	NEXT
	DB	"Нана: Большое спасибо." 
	DB	NEXT
	DB	"Я выхожу из ресторана быстрого питания."
	DB	NEXT
	GO MATI
AH8:
	DB	"Пожалуй, надо идти домой."
	DB	NEXT
	GO	JITAKU
JITAKU:
	BAK_INIT	'tb_018c',B_NORM
	DB	"Я голоден."
	DB	T_WAIT,	3
	DB	" Пора домой."
	DB	NEXT
	BAK_INIT 'tb_005c',B_NORM
	DB	"Ах, хорошо быть дома."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		6
	T_CG 'tt_20_02',AKE_A2,0
	DB	"Кэндзиро: Я вернулся."
	DB	NEXT
	DB	"Акэми: Здравствуй."
	DB	NEXT
	DB	"Кэндзиро: Где Мотока?"
	DB	NEXT
	DB	"Акэми: Она ещё не вернулась." 
	DB	NEXT
	DB	"Кэндзиро: Ясно."
	DB	NEXT
	DB	"Акэми: Подавать ужин?"
	DB	NEXT
	DB	"Кэндзиро: ...Да, спасибо."
	DB	NEXT
	DB	"Акэми: Ладно."
	DB	NEXT
	DB	"Я тихо поужинал с Акэми-сан. Она завернула порцию Мотоки в плёнку."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY		12
	DB	"Сейчас 10 вечера, а Мотока всё ещё не пришла."
	DB	NEXT
	DB	"Кэндзиро: Где же эта девчонка?.."
	DB	NEXT
	DB	"И тут я слышу тихие шаги в прихожей."
	DB	NEXT
	DB	"Наверное, нужно пока оставить её в покое."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Я выключаю свет и готовлюсь уснуть."
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
	DB	"Кэндзиро: Ууууммм..."
	DB	NEXT
	DB	"Я медленно открываю глаза."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"Кэндзиро: Где я?"
	DB	NEXT
	DB	"Я был в замешательстве, но постепенно приходил в себя. Я был у себя в комнате."
	DB	NEXT
	DB	"Как я сюда попал?"
	DB	NEXT
	DB	"На моей одежде бурое пятно."
	DB	NEXT
	DB	"Кровь? У меня пошла кровь из носа."
	DB	NEXT
	DB	"Что случилось после этого?"
	DB	NEXT
	DB	"Должно быть, я потерял сознание."
	DB	NEXT
	DB	"А кто-то, видимо, отнёс меня сюда."
	DB	NEXT
	DB	"Я смотрю на часы. На них 21:30.."
	DB	NEXT
	DB	"Мотока уже дома?"
	DB	NEXT
	DB	"Я одеваюсь и выхожу из комнаты."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"Я стучусь в комнату Мотоки, но ответа нет."
	DB	NEXT
	DB	"Кэндзиро: Может быть, она на кухне..."
	DB	NEXT
	DB	"Я иду на кухню."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	DB	"Её обед всё ещё на столе, завёрнутый в плёнку, как и вчера вечером. Как будто она не пришла домой прошлым вечером."
	DB	NEXT
	DB	"Кэндзиро: Она не пришла домой."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"Я возвращаюсь в свою комнату и ложусь на кровать. Я услышал шаги в прихожей около 10 вечера, уверен, что это была она."
	DB	NEXT
	DB	"Я пытаюсь встать с кровати, но вспоминаю слова Акэми."
	DB	NEXT
	DB	"Доверяй Мотоке..."
	DB	T_WAIT, 3
	DB	" Думаю, она права."
	DB	NEXT
	DB	"Не стоит так сильно за неё волноваться. Уверен, с ней всё нормально."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"Я выключаю свет и готовлюсь уснуть."
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