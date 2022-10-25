        include SUPER_C.inc
M_START:
NITI_HIR
	FLG_IF HOK,'=',6,KYOUSITU
	FLG_IF HAND,'=',5,TOIRE
	F_O	B_NORM,C_KURO
	FLG_IF	MOTSUNE,'=',2,TETUKURU
	CDPLAY	14
	DB	"Пора обедать."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB	"Я быстро съедаю свой обед и выхожу в коридор."
	DB	NEXT
MODO:
	BAK_INIT	'tb_034a',B_NORM
	DB	"Кэндзиро: Что ж, пожалуй, посмотрю, что есть на десерт."
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
	DB	"Тэцуя: Эй, проснись." 
	DB	NEXT
	DB	"Кэндзиро: Нн?"
	DB	NEXT
	DB	"Тэцуя: Чувак, пора обедать."
	DB	NEXT
	DB	"Кэндзиро: Ладно, встаю."
	DB	NEXT
	DB	"Отвечая Тэцуе, я поднимаю голову с парты, на которой я спал."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	T_CG	'tt_08_10',TET_A2,0
	DB	"Тэцуя: Я хочу задать тебе вопрос."
	DB	NEXT
	DB	"Кэндзиро: Да не волнуйся ты, не встречаюсь я с Сихо."
	DB	NEXT
	DB	"Тэцуя: Я знаю. Нет, я хочу спросить у тебя про Мотоку."
	DB	NEXT
	DB	"Кэндзиро: Пролетел с Сихо и хочешь встречаться с моей сестрой? Извини, но я не думаю, что парень, "
        DB      "который смотрит столько порнофильмов подойдёт моей сестре."
	DB	NEXT
	DB	"Тэцуя: Ты меня выслушаешь?"
	DB	NEXT
	DB	"Кэндзиро: Ладно, что?"
	DB	NEXT
	DB	"Тэцуя: Я кое-кого видел по дороге в школу. Мотока шла с Харой." 
	DB	NEXT
	DB	"Кэндзиро: Что?"
	DB	NEXT
	DB	"Тэцуя: Они с Харой встречаются что ли?"
	DB	NEXT
	DB	"Кэндзиро: Нет, уверен, что нет."
	DB	NEXT
	DB	"Тэцуя: Знаешь, этот парень привык использовать девушек. Я подумал, что надо тебя предупредить."
	DB	NEXT
	DB	"Кэндзиро: Хмм, конечно, я знал, что этот Хироси положил на неё глаз."
	DB	NEXT
	DB	"Тэцуя: Ты не беспокоишься?"
	DB	NEXT
	DB	"Кэндзиро: Я бы солгал, если бы сказал такое, но Мотока уже большая и достаточно умная, "
        DB      "чтобы избегать Хироси. Ему я тоже говорил держаться подальше."
	DB	NEXT
	DB	"Тэцуя: Но они вместе шли в школу."
	DB	NEXT
	DB	"Кэндзиро: Они ходят по одной и той же дороге, не так ли? Может быть, это всего лишь случайное совпадение."
	DB	NEXT
	DB	"Тэцуя: Может быть..."
	DB	T_WAIT,	3
	DB	" Но я всё ещё немного беспокоюсь."
	DB	NEXT
	DB	"Кэндзиро: Я тебя понимаю."
	DB	NEXT
	DB	"Тэцуя: Ну, пойду в мячик поиграю. Хочешь со мной?"
	DB	NEXT
	DB	"Кэндзиро: В другой раз."
	DB	NEXT
	DB	"Тэцуя: Ладно. Но знаешь, тебе нужно больше двигаться."
	DB	NEXT
	DB	"Кэндзиро: Я знаю."
	DB	NEXT
	TATI_ERS
	DB	"Тэцуя вылетает из класса."
	DB	NEXT
	DB	"Кэндзиро: Пожалуй, тоже пойду."
	DB	NEXT
	DB	"Я выхожу в коридор."
	DB	NEXT
	GO	MODO
ROUKA:
	CDPLAY	14
	BAK_INIT	'tb_034a',B_NORM
	DB	"Куда мне пойти?"
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
	MENU_SET	T4,"В СПОРТЗАЛ"
	MENU_SET	T5,"В КАБИНЕТ ИЗО"
	MENU_SET	T6,"В МУЖСКОЙ ТУАЛЕТ"
	MENU_SET	T7,"В МЕДКАБИНЕТ"
	MENU_END
	DB	EXIT
T1:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI	SIH_KAIS,'+',1
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP02,'=',1
	DB	"Я возвращаюсь в свой класс."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	T_CG 'tt_02_10',SIH_A2,0
	DB	"Я собираюсь выйти в коридор, как вдруг появляется Сихо."
	DB	NEXT
	DB	"Сихо: А, Кэндзиро-кун.."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	U1,"СМОТРЕТЬ НА ЛИЦО"
	MENU_SET	U2,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	U3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
U1:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"У Сихо милое личико. Почти идеальное."
	DB	NEXT
	GO BODY_SHIHO
U2:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Её форма не даёт мне разглядеть истинный размер её груди, но выглядит замечательно."
	DB	NEXT
	GO BODY_SHIHO
U3:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Замечательные ляжки, белые, и мясца на них в самый раз."
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
	DB	"Хмм, не хочу больше думать о ней в таком ключе."
	DB	NEXT
	DB	"Сихо: Что такое?" 
	DB	NEXT
	DB	"Кэндзиро: О, ничего."
	DB	NEXT
	DB	"Сихо: Правда? Что ж, увидимся. Я иду в библиотеку."
	DB	NEXT
	TATI_ERS
	DB	"Сихо выходит из класса."
	DB	NEXT
	DB	"Пожалуй, я тоже пойду."
	DB	NEXT
	GO ROUKA
T2:
	FLG_IF	TEMP01,'>=',2,KYOUSITU
	FLG_KI	TEMP01,'+',1
	FLG_KI	TEMP03,'=',1
	DB	"Кэндзиро: Пожалуй, пойду на крышу."
	DB	NEXT
	BAK_INIT	'tb_012',B_NORM
	FLG_IF	TERUNASI,'=',1,TERUINAI
	DB	"Я вижу Тэруми-сэмпай, которая стоит одна около сетчатого заграждения."
	DB	NEXT
	T_CG	'tt_05_12',TER2,0
	DB	"Кэндзиро: Тэруми-сэмпай."
	DB	NEXT
	DB	"Тэруми: А, Кэндзиро." 
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	V1,"СМОТРЕТЬ НА ГРУДЬ"
	MENU_SET	V2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	V3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
V1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT1
	FLG_KI	TER_NET,'=',1
TER_TAT1:
	DB	"У неё прекрасная грудь, хоть я и не вижу её полностью, из-за её правой руки."
	DB	NEXT
	GO BODY_TERUMI
V2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT2
	FLG_KI	TER_NET,'=',1
TER_TAT2:
	DB	"Задница Тэруми-сэмпай. Отличный переход от талии к бёдрам -- очень эротично."
	DB	NEXT
	GO BODY_TERUMI
V3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'<',100,TER_TAT3
	FLG_KI	TER_NET,'=',1
TER_TAT3:
	DB	"Ляжки Тэруми-сэмпай. Дальше идут её ноги."
	DB	NEXT
	GO BODY_TERUMI
BODY_TERUMI:
	DB	"Тэруми: В чём дело? Никогда раньше не видел моего тела?"
	DB	NEXT
	DB	"Кэндзиро: Я-я не смотрел! Эм, а вообще, что ты тут делаешь?"
	DB	NEXT
	DB	"Тэруми: О, ничего особенного. Просто болтаюсь тут."
	DB	T_WAIT, 5
	DB	" А ты?"
	DB	NEXT
	DB	"Кэндзиро: О, ничего. Тоже просто болтаюсь."
	DB	NEXT
	DB	"Тэруми: У нас обоих куча времени, которое можно убить."
	DB	NEXT
	DB	"Кэндзиро: Да, пожалуй."
	DB	NEXT
	DB	"Внезапно, Тэруми-сэмпай кладёт руку на моё предплечье, словно желая перевести беседу в другое русло."
	DB	NEXT
	DB	NEXT
	DB	"Кэндзиро: Ну, счастливо, Тэруми-сэмпай. Пока!"
	DB	NEXT
	DB	"Тэруми: Подожди!" 
	DB	NEXT
	DB	"Сам не знаю почему, я помчался вниз по ступеням."
	DB	NEXT
	GO	ROUKA
TERUINAI:
	DB	"Я оглядываюсь по сторонам, но не вижу Тэруми-сэмпай."
	DB	NEXT
	DB	"Кэндзиро: Тэруми-сэмпай здесь нет..."
	DB	NEXT
	DB	"Пожалуй, мне тут делать нечего."
	DB	NEXT
	DB	"Я спускаюсь вниз."
	DB	NEXT
	GO	ROUKA
T3:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP04,'=',1
	FLG_IF	MOTSUNE,'!=',0,MOTOINAI
	DB	"Увидев меня, Мотока бежит ко мне."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	T_CG 'tt_10_10',MOT_A2,0
	DB	"Мотока: Ониитян!" 
	DB	NEXT
	DB	"Мотока: Что случилось?"
	DB	NEXT
	DB	"Кэндзиро: Ничего..."
	DB	NEXT
	DB	"Мотока: Ничего? По голосу не похоже. Зачем ты пришёл?" 
	DB	NEXT
	DB	"Кэндзиро: О, просто так."
	DB	NEXT
	DB	"Мотока: А, знаю! Тебе захотелось увидеть моё прелестное личико!" 
	DB	NEXT
	DB	"Кэндзиро: Нет, я просто шёл мимо и..."
	DB	NEXT
	DB	"Мотока: Лжец!" 
	DB	NEXT
	DB	"Мотока: ...Но, думаю, это одно и то же, верно? "
	DB	NEXT
	DB	"Лучше тут не появляться. Если я окажусь тут, то никогда не выберусь."
	DB	NEXT
	DB	"Кэндзиро: Ну, пока."
	DB	NEXT
	DB	"Мотока: Подожди, Ониитян!" 
	DB	NEXT
	DB	"Я возвращаюсь в коридор."
	DB	NEXT
	GO	ROUKA
MOTOINAI:
	BAK_INIT	'tb_010',B_NORM
	DB	"Кэндзиро: Что? Интересно, где Мотока."
	DB	NEXT
	GO	ROUKA
T4:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP05,'=',1
	DB	"Пожалуй, схожу посмотрю, что там в подсобке спортзала."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB	"Здесь Тэцуя, он что-то ищет."
	DB	NEXT
	T_CG 'tt_08_15',TET_A2,0
	FLG_KI TET_KAIS,'+',1
	DB	"Кэндзиро: Тэцуя, что ты тут делаешь?"
	DB	NEXT
	DB	"Тэцуя: А, Кэндзиро. Я пытаюсь найти хороший мячик. А ты?"
	DB	NEXT
	DB	"Кэндзиро: Просто слоняюсь без дела. "
	DB	NEXT
	DB	"Тэцуя: Правда? Почему бы тебе не помочь мне?.."
	DB	NEXT
	DB	"Кэндзиро: Извини, надо идти..."
	DB	NEXT
	DB	"Я ухожу со склада спортинвентаря."
	DB	NEXT
	GO ROUKA
T5:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP06,'=',1
	DB	"Пожалуй, схожу полюбуюсь на мой сладенький персик."
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	CDPLAY	18
	DB	"Мика-сэнсэй вытирает пыль со статуй."
	DB	NEXT
	DB	"Кэндзиро: Мика-сэнсэй."
	DB	NEXT
	DB	"Мика: А, Кондо-кун."
	DB	NEXT
	T_CG 'tt_12_13a',MIK2,0
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	X1,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	X2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	X3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
X1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_1
	FLG_KI MIKA_NET,'=',1
WW_1:
	DB	"Её руки прикрывают грудь, но по мне, выглядит здорово."
	DB	NEXT
	GO BODY_MIKA
X2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_2
	FLG_KI MIKA_NET,'=',1
WW_2:
	DB	"Хорошая задница, крепкая и красивая."
	DB	NEXT
	GO BODY_MIKA
X3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_3
	FLG_KI MIKA_NET,'=',1
WW_3:
	DB	"Хорошая форма, не слишком толстые и не слишком костлявые."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB	"Мика: ...Ты что, смотрел туда, куда не следует?" 
	DB	NEXT
	DB	"Кэндзиро: Э? О чём это вы?"
	DB	NEXT
	DB	"Мика: Ох, неважно."
	DB	NEXT
	DB	"Мика: Рада, что ты пришёл вовремя."
	DB	NEXT
	DB	"Кэндзиро: Э?"
	DB	NEXT
	DB	"Мика: ...Не говори мне, что забыл!"
	DB	NEXT
	DB	"О нет! Я забыл!.."
	DB	NEXT
	DB	"Кэндзиро: Д-до встречи, сэнсэй..."
	DB	NEXT
	DB	"Мика: Подожди, Кондо-кун!" 
	DB	NEXT
	DB	"Я убегаю, оставив позади кабинет ИЗО с Микой-сэнсэй."
	DB	NEXT
	GO ROUKA
T6:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP07,'=',1
	DB	"Я иду в мужской туалет."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	T_CG 'tt_03_17a',HIR2,0
	DB	"Я встречаю Хироси, выходящего из кабинки."
	DB	NEXT
	DB	"Хироси: О, Кондо. Здравствуй."
	DB	NEXT
	DB	"Кэндзиро: Эм, привет."
	DB	NEXT
	DB	"Хироси: Ну, счастливо."
	DB	NEXT
	TATI_ERS	;TT_03
	DB	"Вторая кабинка с конца -- мой кабинет. Как обычно, свободна."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	Y1,"ВОЙТИ В КАБИНКУ"
	MENU_SET	Y2,"ВЫЙТИ"
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
	MENU_SET	Z1,"АКЭМИ КОНДО"
	MENU_SET	Z2,"ТЭРУМИ КИНОУТИ"
	MENU_SET	Z3,"МИКА МАЭДА"
	MENU_SET	Z4,"РЭНА ВАТАНАБЭ"
	MENU_SET	Z5,"НАНА ХИРОСЭ"
	MENU_SET	Z6,"СИДЗУКА ХАСЭГАВА"
	MENU_SET	Z7,"ТИЭ УЦУМИ"
	MENU_SET	Z8,"НЕ ЗАМОРАЧИВАТЬСЯ"
	MENU_END
	DB	EXIT
Z1:
	DB	"Акэми-сан -- это было бы хорошо."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'AK_H.OVL'
Z2:
	DB	"Займёмся этим с Тэруми-сэмпай."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'TE_H.OVL'
Z3:
	DB	"Мм, я просто люблю Мику..."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'MI_H.OVL'
Z4:
	DB	"Я бы хотел оживить воспоминания о весенних каникулах..."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'RE_H.OVL'
Z5:
	DB	"Хотел бы я быть с Наной..."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'NA_H.OVL'
Z6:
	DB	"У неё потрясное тело."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'SI_H.OVL'
Z7:
	DB	"Мне просто нравится этот её купальник."
	DB	NEXT
	FLG_KI HAND,'=',5
	SINARIO 'CH_H.OVL'
Z8:
	DB	"Пожалуй, сегодня не стоит заморачиваться."
	DB	NEXT
Y2:
DERU:
	DB	"Мне тут делать нечего, так что, пожалуй, пойду."
	DB	NEXT
	GO ROUKA
TOIRE:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB	"Разрядившись, я стою перед зеркалом."
	DB	NEXT
	DB	"Ммм, было здорово."
	DB	NEXT
	DB	"Я мою руки и выхожу в коридор."
	DB	NEXT
	GO ROUKA
T7:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP08,'=',1
	DB	"Пожалуй, схожу посмотрю, как там Сидзука-сэнсэй."
	DB	NEXT
	EVENT_CG 'th_072',B_NORM,35
	DB	"Сидзука: Что-то случилось?"
	DB	NEXT
	DB	"Кэндзиро: О, нет."
	DB	NEXT
	DB	"Сидзука: Тогда зачем ты здесь?" 
	DB	NEXT
	DB	"Кэндзиро: Просто захотел вас увидеть."
	DB	NEXT
	DB	"Сидзука: О, я так рада."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AA_1,"СМОТРЕТЬ НА ЛИЦО"
	MENU_SET	AA_2,"СМОТРЕТЬ НА РУКИ"
	MENU_SET	AA_3,"СМОТРЕТЬ НА НОГИ"
	MENU_END
	DB	EXIT
AA_1:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_4
	FLG_KI SIZU_NET,'=',1
WW_4:
	DB	"У неё потрясающие глаза."
	DB	NEXT
	GO BODY_SIZUKA
AA_2:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_5
	FLG_KI SIZU_NET,'=',1
WW_5:
	DB	"Хотел бы я, чтобы эти красные ноготки потрогали мой член."
	DB	NEXT
	GO BODY_SIZUKA
AA_3:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_6
	FLG_KI SIZU_NET,'=',1
WW_6:
	DB	"Я вижу самый краешек верха её чулок. Это чересчур сексуально."
	DB	NEXT
	GO BODY_SIZUKA
BODY_SIZUKA:
	DB	"Сидзука: Как думаешь, куда это ты смотришь?"
	DB	NEXT
	DB	"Кэндзиро: А, никуда..."
	DB	NEXT
	DB	"Сидзука: Ты ещё юн, так что, пожалуй, ничего с этим не поделать."
	DB	NEXT
	DB	"Кэндзиро: Ч-что ж, до встречи..."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Нет женщины сексуальнее, чем Сидзука-сэнсэй."
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
	DB	"Кэндзиро: А, смотрите, который час. Пожалуй, пойду назад."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB	"Звонок на урок прозвенел едва я вошёл в класс."
	DB	NEXT
	;WAV	'Se_ch'
	DB	"И снова скучные уроки..."
	DB	NEXT
	DB	"Вздремну, пожалуй."
	DB	NEXT
	DB	"Кэндзиро: ................................."
	DB	NEXT
	B_O	B_FADE,C_KURO
	;WAV  'STOP'
	CDPLAY		0
	SINARIO 'JUMP.OVL'
	DB	EXIT
END