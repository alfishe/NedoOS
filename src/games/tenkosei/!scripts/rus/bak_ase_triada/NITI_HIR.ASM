        include SUPER_C.inc
M_START:
NITI_HIR
	FLG_IF HOK,'=',6,KYOUSITU
	FLG_IF HAND,'=',5,TOIRE
	F_O	B_NORM,C_KURO
	FLG_IF	MOTSUNE,'=',2,TETUKURU
	CDPLAY	14
	DB "Время обедать."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB "Я быстро съедаю свой обед и иду в коридор."
	DB	NEXT
MODO:
	BAK_INIT	'tb_034a',B_NORM
	DB "Кенджиру:  Думаю, надо пойти за каким-то десертом."
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
TETUKURU:
	FLG_KI	MOTSUNE,'=',3
	DB "Тецуя:    Эй, подьем." 
	DB	NEXT
	DB "Кенджиру:  Нн?"
	DB	NEXT
	DB "Тецуя:    Время обеда."
	DB	NEXT
	DB "Кенджиру:  Да, я знаю."
	DB	NEXT
	DB "Когда Тецуя меня разбудила, я приподнял голову с парты, где я проспал."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	T_CG	'tt_08_10',TET_A2,0
	DB "Тецуя:    Я хочу задать тебе вопрос."
	DB	NEXT
	DB "Кенджиру:  Не бойся, я не вижу Шихо или еще что-то."
	DB	NEXT
	DB "Тецуя:    Я знаю. Нет, я хочу спросить тебя про Мотоку."
	DB	NEXT
	DB "Кенджиру:  Когда ты закончил с Шихо, ты хотел выбрать мою сестру? Извини, но я не думаю, "
        DB "что парень, который смотрит порно-видео столько, сколько ты, подойдет моей сестре."
	DB	NEXT
	DB "Тецуя:    Ты послушаешь меня?"
	DB	NEXT
	DB "Кенджиру:  Хорошо?"
	DB	NEXT
	DB "Тецуя:    Я видел по дороге в школу, что Мотока шла вместе с Харой." 
	DB	NEXT
	DB "Кенджиру:  Что?"
	DB	NEXT
	DB "Тецуя:    Она и Хара встречаются или еще что-то?"
	DB	NEXT
	DB "Кенджиру:  Нет, я уверена."
	DB	NEXT
	DB "Тецуя:    У этого парня привычка пользоваться женщин. Поэтому хочу предупредить."
	DB	NEXT
	DB "Кенджиру:  Хмм, я знала, что Хироши ухаживал за ней."
	DB	NEXT
	DB "Тецуя:    Ты не беспокойся?"
	DB	NEXT
	DB "Кенджиру:  Я бы соврал, если б сказал это, Мотоке уже за восемнадцать, и она умна, "
        DB "чтобы избежать Хироши. Я тоже сказал ему отстать."
	DB	NEXT
	DB "Тецуя:    Но они шли в вместе школу."
	DB	NEXT
	DB "Кенджиру:  Дорога, по которой они идут, одна, не так ли? Может, это совпадение."
	DB	NEXT
	DB "Тецуя:    Может..."
	DB	T_WAIT,	3
	DB " Я все-таки немного беспокоюсь."
	DB	NEXT
	DB "Кенджиру:  Я знаю, о чем ты."
	DB	NEXT
	DB "Тецуя:    Да, я собираюсь поиграть в мяч. Ты подойдешь?"
	DB	NEXT
	DB "Кенджиру:  В другой раз."
	DB	NEXT
	DB "Тецуя:    Ладно. Но тебе нужно больше заниматься, знаешь."
	DB	NEXT
	DB "Кенджиру:  Хорошо."
	DB	NEXT
	TATI_ERS
	DB "Тецуя выбегает из класса."
	DB	NEXT
	DB "Кенджиру:  Думаю, надо тоже пойти."
	DB	NEXT
	DB "Я выхожу в холл."
	DB	NEXT
	GO	MODO
ROUKA:
	CDPLAY	14
	BAK_INIT	'tb_034a',B_NORM
	DB "Куда бы мне пойти?"
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
	MENU_SET	T1,"НАЗАД В КОМН."
	MENU_SET	T2,"КРЫШ"
	MENU_SET	T3,"КОМН.МОТОКИ"
	MENU_SET	T4,"КОМ.ПЕ"
	MENU_SET	T5,"КОМ.АРТА"
	MENU_SET	T6,"МУЖ.КОМНАТ"
	MENU_SET	T7,"ОФФИС НУРСА"
	MENU_END
	DB	EXIT
T1:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI	SIH_KAIS,'+',1
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP02,'=',1
	DB "Возвращаюсь в свою комнату."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	T_CG 'tt_02_10',SIH_A2,0
	DB "Я уже уходил из комнаты, как вдруг появилась Шихо."
	DB	NEXT
	DB "Шихо:   А, Кенджиру-кун."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	U1,"ОСМОТР ЛИЦА"
	MENU_SET	U2,"ОСМОТР СИСЕК"
	MENU_SET	U3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
U1:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "У Шихо милое личико. Почти безупречное."
	DB	NEXT
	GO BODY_SHIHO
U2:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "Ее форма прячет от меня размер ее груди, но, мне кажется, она большая."
	DB	NEXT
	GO BODY_SHIHO
U3:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "Классные бедра, белоснежные, достаточно полные."
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
	DB "Хмм, я не хочу ее  больше развращать этим."
	DB	NEXT
	DB "Шихо:   Что с тобой?" 
	DB	NEXT
	DB "Кенджиру:  А, ничего."
	DB	NEXT
	DB "Шихо:   Серьозно? Да, увидимся позже. Я ухожу в библиотеку."
	DB	NEXT
	TATI_ERS
	DB "Шихо уходит."
	DB	NEXT
	DB "Наверное, я пойду."
	DB	NEXT
	GO ROUKA
T2:
	FLG_IF	TEMP01,'>=',2,KYOUSITU
	FLG_KI	TEMP01,'+',1
	FLG_KI	TEMP03,'=',1
	DB "Кенджиру:  Нужно сходить на крышу."
	DB	NEXT
	BAK_INIT	'tb_012',B_NORM
	FLG_IF	TERUNASI,'=',1,TERUINAI
	DB "Возле цепного забора я увидел Теруми-сенпай, она была одна."
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
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT1
	FLG_KI	TER_NET,'=',1
TER_TAT1:
	DB "У нее тоже отличная грудь, хотя я не могу хорошо все рассмотреть из-за ее руки."
	DB	NEXT
	GO BODY_TERUMI
V2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT2
	FLG_KI	TER_NET,'=',1
TER_TAT2:
	DB "А какая у нее попочка. У нее большой изгиб, идущий от талии к бедру - очень эротично."
	DB	NEXT
	GO BODY_TERUMI
V3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT3
	FLG_KI	TER_NET,'=',1
TER_TAT3:
	DB "А какие у нее бедра. Ее ноги все время возвышаются."
	DB	NEXT
	GO BODY_TERUMI
BODY_TERUMI:
	DB "Теруми:  В чем дело? Ты что, никогда не видел мою фигуру?"
	DB	NEXT
	DB "Кенджиру:  Я не смотрел! В любом случае, что ты здесь делаешь?"
	DB	NEXT
	DB "Теруми:  Ничего особенного. Просто прохаживаюсь."
	DB	T_WAIT, 5
	DB " А ты?"
	DB	NEXT
	DB "Кенджиру:  О, ничего. Просто прохаживаюсь здесь."
	DB	NEXT
	DB "Теруми:  У нас обоих много времени."
	DB	NEXT
	DB "Кенджиру:  Да, я думаю."
	DB	NEXT
	DB "Вдруг Теруми-сенпай положила свою руку на мою, как будто хотела что-то другое мне сказать."
	DB	NEXT
	DB	NEXT
	DB "Кенджиру:  Ладно, увидимся, Теруми-сенпай. Пока!"
	DB	NEXT
	DB "Теруми:  Стой!" 
	DB	NEXT
	DB "Не понямая, почему бежал, я спустился по лестнице."
	DB	NEXT
	GO	ROUKA
TERUINAI:
	DB "Я смотрю вокруг, но не вижу Теруми-сенпай."
	DB	NEXT
	DB "Кенджиру:  Теруми-сенпай нет здесь..."
	DB	NEXT
	DB "Наверно мне здесь нечего делать."
	DB	NEXT
	DB "Я спустился вниз."
	DB	NEXT
	GO	ROUKA
T3:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP04,'=',1
	FLG_IF	MOTSUNE,'!=',0,MOTOINAI
	DB "Увидев меня, Мотока выходит."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	T_CG 'tt_10_10',MOT_A2,0
	DB "Мотока:  Любимый!" 
	DB	NEXT
	DB "Мотока:  Что с тобой?"
	DB	NEXT
	DB "Кенджиру:  Ничего..."
	DB	NEXT
	DB "Мотока:  Ничего? Не правильно. Почему ты проходишь мимо?" 
	DB	NEXT
	DB "Кенджиру:  О, нет причин."
	DB	NEXT
	DB "Мотока:  А, знаю! Ты хотел увидеть мое личико!" 
	DB	NEXT
	DB "Кенджиру:  Нет, я только проходил мимо, и..."
	DB	NEXT
	DB "Мотока:  Лгун!" 
	DB	NEXT
	DB "Мотока:  ...Но думаю, это все одно и тоже, так?"
	DB	NEXT
	DB "Лучше мне не подходить так близко. Если бы я шел в шаг, я бы никогда отсюда не вышел."
	DB	NEXT
	DB "Кенджиру:  Ну, пока."
	DB	NEXT
	DB "Мотока: Постой, Ониичан!" 
	DB	NEXT
	DB "Я возвращаюсь в коридор."
	DB	NEXT
	GO	ROUKA
MOTOINAI:
	BAK_INIT	'tb_010',B_NORM
	DB "Кенджиру:  Что? Не знаю, где Мотока."
	DB	NEXT
	GO	ROUKA
T4:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP05,'=',1
	DB "Думаю, гляну, что внутри склада для физснарядов."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB "Тецуя здесь, что-то ищет."
	DB	NEXT
	T_CG 'tt_08_15',TET_A2,0
	FLG_KI TET_KAIS,'+',1
	DB "Кенджиру:  Тецуя, что ты здесь делаешь?"
	DB	NEXT
	DB "Тецуя:    А, Кеньироу. Я пытаюсь найти хороший мяч для игры. А ты что делаешь?"
	DB	NEXT
	DB "Кенджиру:  Я просто гуляю."
	DB	NEXT
	DB "Тецуя:    Почему ты мне не поможешь?"
	DB	NEXT
	DB "Кенджиру:  Прости, не могу..."
	DB	NEXT
	DB "Я покидаю кладовку."
	DB	NEXT
	GO ROUKA
T5:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP06,'=',1
	DB "Нуадо пойти к своей милашке."
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	CDPLAY	18
	DB "Мика-сенсей убирает пыль со статуи."
	DB	NEXT
	DB "Кенджиру:  Мика-sensei."
	DB	NEXT
	DB "Мика:  А, Кондо-кун."
	DB	NEXT
	T_CG 'tt_12_13a',MIK2,0
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	X1,"ОСМОТР СИСЕК"
	MENU_SET	X2,"ОСМОТР ПОПЫ"
	MENU_SET	X3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
X1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_1
	FLG_KI MIKA_NET,'=',1
WW_1:
	DB "Ее руки прячут ее грудь, но мне она кажется отличной."
	DB	NEXT
	GO BODY_MIKA
X2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_2
	FLG_KI MIKA_NET,'=',1
WW_2:
	DB "Попка класс, упругая и красивая"
	DB	NEXT
	GO BODY_MIKA
X3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_3
	FLG_KI MIKA_NET,'=',1
WW_3:
	DB "Отличная форма, небольшая и не костлявая."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB "Мика:  ...Ты смотришь туда, куда тебе не следует смотреть?" 
	DB	NEXT
	DB "Кенджиру:  Я не понимаю, о чем ты?"
	DB	NEXT
	DB "Мика:  А, ничего."
	DB	NEXT
	DB "Мика:  Я рада, что ты уложился вовремя."
	DB	NEXT
	DB "Кенджиру:  А?"
	DB	NEXT
	DB "Мика:  ...Не говори, что ты забыл!"
	DB	NEXT
	DB "О нет! Я забыл..!"
	DB	NEXT
	DB "Кенджиру:  У-увидимся попозже, Сенсей..."
	DB	NEXT
	DB "Мика:  Подожди, Кондо!" 
	DB	NEXT
	DB "Я оставил Мика-сенсей и мастерскую сзади."
	DB	NEXT
	GO ROUKA
T6:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP07,'=',1
	DB "Я иду в мужскую уборную."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	T_CG 'tt_03_17a',HIR2,0
	DB "У меня встреча с Хироши на выходе из ларька"
	DB	NEXT
	DB "Хироши:   Кондо. Привет."
	DB	NEXT
	DB "Кенджиру:  Хай."
	DB	NEXT
	DB "Хироши:   Да, увидимся."
	DB	NEXT
	TATI_ERS	;TT_03
	DB "Второй ларек сзади - это мой офис. Он пустой, как обычно."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	Y1,"В ОФФИС"
	MENU_SET	Y2,"НА ВЫХОД"
	MENU_END
	DB	EXIT
Y1:
	FLG_IF YOKU,'<',45,DERU
	FLG_IF YOKU,'<',100,SENTAKU2
	FLG_IF AKEM_NET,'=',0,DD_1
	FLG_KI HAND,'=',5
	SINARIO 'AK_H.OVL'
DD_1:
	FLG_IF MIKA_NET,'=',0,DD_2
	FLG_KI HAND,'=',5
	SINARIO 'MI_H.OVL'
DD_2:
	FLG_IF TER_NET,'=',0,DD_3
	FLG_KI HAND,'=',5
	SINARIO 'TE_H.OVL'
DD_3:
	FLG_IF RENA_NET,'=',0,DD_4
	FLG_KI HAND,'=',5
	SINARIO 'RE_H.OVL'
DD_4:
	FLG_IF NANA_NET,'=',0,DD_5
	FLG_KI HAND,'=',5
	SINARIO 'NA_H.OVL'
DD_5:
	FLG_IF SIZU_NET,'=',0,DD_6
	FLG_KI HAND,'=',5
	SINARIO 'SI_H.OVL'
DD_6:
	FLG_IF CHIE_NET,'=',0,DD_7
	FLG_KI HAND,'=',5
	SINARIO 'CH_H.OVL'
DD_7:
SENTAKU2:
	FLG_KI W,'=',-1
	FLG_IF REN_ATTA,'=',1,LL_1
	FLG_KI W,'DOWN',3
LL_1:
	FLG_IF NAN_ATTA,'=',1,LL_2
	FLG_KI W,'DOWN',4
LL_2:
	FLG_IF SIZ_ATTA,'=',1,LL_3
	FLG_KI W,'DOWN',5
LL_3:
	FLG_IF CHI_ATTA,'=',1,LL_4
	FLG_KI W,'DOWN',6
LL_4:
	MENU_S	2,W,-1
	MENU_SET	Z1,"АКЕМИ КОНДО"
	MENU_SET	Z2,"ТЕРУМИ КИНОУШИ"
	MENU_SET	Z3,"МИКА МАЕДА"
	MENU_SET	Z4,"РЕНА ВАТАНАБЕ"
	MENU_SET	Z5,"НАНА ХИРОС"
	MENU_SET	Z6,"ШИЗУКА ХАСЕГАВА"
	MENU_SET	Z7,"ШИЕ УТСУМИ"
	MENU_SET	Z8,"НЕ ВОЛНУЙСЯ"
	MENU_END
	DB	EXIT
Z1:
	DB "Акеми-сан было бы хорошо"
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'AK_H.OVL'
Z2:
	DB "Или лучше с Теруми-сенпай."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'TE_H.OVL'
Z3:
	DB "Мм, vyt yhfdbncz Мика."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'MI_H.OVL'
Z4:
	DB "Я как будто вспомнил весенние каникулы..."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'RE_H.OVL'
Z5:
	DB "Я хочу быть с Наной..."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'NA_H.OVL'
Z6:
	DB "У нее клевая фигура."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'SI_H.OVL'
Z7:
	DB "Она чудесна в своем купальнике."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'CH_H.OVL'
Z8:
	DB "Знаю что не буду волноваться."
	DB	NEXT
Y2:
DERU:
	DB "Мне здесь делать нечего, думаю, мне надо уходить."
	DB	NEXT
	GO ROUKA
TOIRE:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB "После того, как я разделся, я посмотрел в зеркало."
	DB	NEXT
	DB "Мм, было клево."
	DB	NEXT
	DB "Я помыл руки и возвращаюсь в зал."
	DB	NEXT
	GO ROUKA
T7:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP08,'=',1
	DB "Я пойду посмотрю на Шизука-сенсей."
	DB	NEXT
	EVENT_CG 'th_072',B_NORM,35
	DB "Шизука:   Что случилось?"
	DB	NEXT
	DB "Кенджиру:  Ничего."
	DB	NEXT
	DB "Шизука:   Тогда почему ты здесь?" 
	DB	NEXT
	DB "Кенджиру:  Я хотел увидеть тебя."
	DB	NEXT
	DB "Шизука:   Я так рада."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AA_1,"ОСМОТР ЛИЦА"
	MENU_SET	AA_2,"ОСМОТР РУК"
	MENU_SET	AA_3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
AA_1:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_4
	FLG_KI SIZU_NET,'=',1
WW_4:
	DB "У нее классные глаза."
	DB	NEXT
	GO BODY_SIZUKA
AA_2:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_5
	FLG_KI SIZU_NET,'=',1
WW_5:
	DB "Я хотел бы, чтобы эти красные ногти поглаживали мой член."
	DB	NEXT
	GO BODY_SIZUKA
AA_3:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_6
	FLG_KI SIZU_NET,'=',1
WW_6:
	DB "Я вижу тесьму на ее колготах. Это даже слишком сексуально."
	DB	NEXT
	GO BODY_SIZUKA
BODY_SIZUKA:
	DB "Шизука:   Как ты думаешь, куда смотришь ты?"
	DB	NEXT
	DB "Кенджиру:  Никуда..."
	DB	NEXT
	DB "Шизука:   Ты еще малыш, так что полагаю, что нечего с этим не поделаешь."
	DB	NEXT
	DB "Кенджиру:  Х-хорошо, увидимся позже..."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB "Нет женщины горячее, чем Шизука-сенсей."
	DB	NEXT
	GO ROUKA
HOKEN:
	FLG_KI HOK,'=',6
	SINARIO 'ER.OVL'
HOKEN2:
	FLG_KI HOK,'=',6
	SINARIO 'ER2.OVL'
KYOUSITU:
	FLG_KI HOK,'=',0
	BAK_INIT	'tb_034a',B_NORM
	DB "Кенджиру:  Посмотри на время. Думаю, пора назад."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB "Прозвенел звонок на урок, когда я зашел в класс."
	DB	NEXT
	;WAV	'Se_ch'
	DB "Еще пара нудных уроков"
	DB	NEXT
	DB "Думаю, надо поспать."
	DB	NEXT
	DB "Кенджиру: ................................."
	DB	NEXT
	B_O	B_FADE,C_KURO
	;;WAV  'STOP'
	CDPLAY		0
	SINARIO 'JUMP.OVL'
	DB	EXIT
END
