        include SUPER_C.inc
M_START:
MON_14
	FLG_IF HOK,'=',3,KYOUSITU
	FLG_IF HAND,'=',2,TOIRE
	F_O B_NORM,C_KURO
	DB	"Ну, пожалуй, пора вставать. Уроки уже, наверное, закончились."
	DB	NEXT
	DB	"Кэндзиро: *Потягивается!*"
	DB	NEXT
	DB	"Я потягиваюсь, как кот, затем открываю глаза."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	CDPLAY		14
	DB	"Кэндзиро: А? Тут никого нет."
	DB	NEXT
	DB	"Этот гад, Тэцуя. Он должен был меня разбудить."
	DB	NEXT
	DB	"Ну, пожалуй, прошвырнусь немного."
	DB	NEXT
	DB	"Я выхожу из класса."
	DB	NEXT
	BAK_INIT 'tb_034a',B_NORM
	DB	"Куда мне пойти?"
	DB	NEXT
	DB	"Ой, только что вспомнил... Я должен встретиться с Касима-сан в кабинете музыки."
	DB	NEXT
	DB	"Пойду туда."
	DB	NEXT
	EVENT_CG 'ti_049',B_NORM,74
	CDPLAY		11
	DB	"В коридоре слышно как Касима-сан играет на рояле."
	DB	NEXT
	DB	".....Уверен, что раньше слышал эту песню."
	DB	NEXT
	DB	"Интересно, почему? Этому нет объяснения."
	DB	NEXT
	DB	"Когда я вошёл, она прекратила играть и встала передо мной."
	DB	NEXT
	BAK_INIT 'tb_016',B_NORM
	T_CG 'tt_02_16',SIH_A2,0
	FLG_KI	SIH_KAIS,'+',1
	CDPLAY		23
	DB	"Сихо: Кондо-кун, ты пришёл."
	DB	NEXT
	DB	"Кэндзиро: Э? Ну да, я же обещал..."
	DB	NEXT
	DB	"Глядя в глаза Сихо, я снова вспоминаю о другой Сихо."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	I1,"СМОТРЕТЬ НА ЛИЦОE"
	MENU_SET	I2,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	I3,"СМОТРЕТЬ НА НОГИ"
	MENU_END
	DB	EXIT
I1:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Она красивая. Её лицо просто превосходной формы."
	DB	NEXT
	GO BODY_SIHO
I2:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Трудно разглядеть груди через её форму, но они должны быть превосходны."
	DB	NEXT
	GO BODY_SIHO
I3:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Миленькие ножки, такие мягкие и белые, и мясца на них в меру."
	DB	NEXT
	GO BODY_SIHO
BODY_SIHO:
	FLG_KI AKEM_NET,'=',0
	FLG_KI MIKA_NET,'=',0
	FLG_KI TER_NET,'=',0
	FLG_KI RENA_NET,'=',0
	FLG_KI NANA_NET,'=',0
	FLG_KI SIZU_NET,'=',0
	FLG_KI CHIE_NET,'=',0
	DB	"Кэндзиро: А-а?"
	DB	NEXT
	DB	"Сихо: В чём дело?" 
	DB	NEXT
	DB	"Кэндзиро: Э? О нет. (Странно -- когда я смотрю на неё, то вместо сексуального возбуждения чувствую умиротворение.)"
	DB	NEXT
	DB	"Сихо: Кондо-кун?" 
	DB	NEXT
	DB	"Кэндзиро: Э? Ч-что это?"
	DB	NEXT
	DB	"Сихо: С тобой всё в порядке?" 
	DB	NEXT
	DB	"Кэндзиро: Что ты имеешь в виду?"
	DB	NEXT
	DB	"Сихо: Ты вдруг так затих..."
	DB	NEXT
	DB	"Кэндзиро: Извини. Просто я кое о чём задумался."
	DB	NEXT
	DB	"Сихо: Правда?"
	DB	NEXT
	DB	"Кэндзиро: Да. И ещё..."
	DB	NEXT
	DB	"Сихо: Что?"
	DB	NEXT
	DB	"Кэндзиро: Может, перестанешь называть меня Кондо-кун? Ты можешь звать меня Кэндзиро."
	DB	NEXT
	DB	"Сихо: ...Хорошо." 
	DB	NEXT
	DB	"Сейчас Касима-сан выглядит довольной. Или это только моё воображение?"
	DB	NEXT
	DB	"Сихо: Ну, в таком случае, пожалуйста, зови меня Сихо." 
	DB	NEXT
	DB	"Кэндзиро: Э?"
	DB	T_WAIT,	3
	DB	" Ладно. Если тебя это устраивает"
	DB	NEXT
	DB	"Сихо: Устраивает."
	DB	NEXT
	DB	"Касима-сан... В смысле, Сихо, улыбается мне."
	DB	NEXT
	DB	"Кэндзиро: Ладно, ну, тогда я пойду."
	DB	NEXT
	DB	"Сихо: А, Кэндзиро-кун?"
	DB	NEXT
	DB	"Кэндзиро: Да?"
	DB	NEXT
	DB	"Сихо: После уроков, я обычно здесь. Так что, когда у тебя будет свободное время, приходи послушать. Ладно?"
	DB	NEXT
	DB	"Кэндзиро: Э?"
	DB	NEXT
	DB	"Сихо: ...Думаю, я ещё не очень хорошо играю, чтобы выступать перед другими людьми..." 
	DB	NEXT
	DB	"Она смотрит на свои ступни, внезапно смутившись, затем возвращается за рояль."
	DB	NEXT
	DB	"Не зная что сказать, я выхожу из кабинета музыки."
	DB	NEXT
	BAK_INIT 'tb_034a',B_NORM
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
ROUKA:
	BAK_INIT	'tb_034a',B_NORM
	DB	"Ну, куда мне пойти?"
	DB	NEXT
	FLG_KI W,'=',-1
	FLG_IF TEMP02,'=',0,SA_1
	FLG_KI W,'DOWN',0
SA_1:
	FLG_IF TEMP03,'=',0,SA_2
	FLG_KI W,'DOWN',1
SA_2:
	FLG_IF TEMP04,'=',0,SA_3
	FLG_KI W,'DOWN',2
SA_3:
	FLG_IF TEMP05,'=',0,SA_4
	FLG_KI W,'DOWN',3
SA_4:
	FLG_IF TEMP06,'=',0,SA_5
	FLG_KI W,'DOWN',4
SA_5:
	MENU_S 2,W,-1
	MENU_SET	J1,"НА КРЫШУ"
	MENU_SET	J2,"В МУЖСКОЙ ТУАЛЕТ"
	MENU_SET	J3,"В КАБИНЕТ ИЗО"
	MENU_SET	J4,"В ПОДСОБКУ СПОРТЗАЛА"
	MENU_SET	J5,"В КЛАСС МОТОКИ"
	MENU_END
	DB	EXIT
J1:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"Пожалуй, поднимусь на крышу."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Я дёргаю дверь, ведущую на крышу, но она заперта."
	DB	NEXT
	DB	"Чёрт, похоже, сейчас мне туда не попасть."
	DB	NEXT
	DB	"Пойду назад."
	DB	NEXT
	GO ROUKA
J2:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"Я направляюсь в мужской туалет."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	DB	"Предпоследняя кабинка - это мой кабинет."
	DB	NEXT
	FLG_IF YOKU,'<',45,DERU
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	K1,"ВОЙТИ В КАБИНКУ"
	MENU_SET	K2,"ВЫЙТИ ИЗ ТУАЛЕТА"
	MENU_END
	DB	EXIT
K1:
	DB	"Я иду в свой личный кабинет."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Ну, с кем я сделаю это сегодня?"
	DB	NEXT
	FLG_KI W,'=',-1
	FLG_IF REN_ATTA,'=',1,SB_1
	FLG_KI W,'DOWN',3
SB_1:
	FLG_IF NAN_ATTA,'=',1,SB_2
	FLG_KI W,'DOWN',4
SB_2:
	FLG_IF SIZ_ATTA,'=',1,SB_3
	FLG_KI W,'DOWN',5
SB_3:
	FLG_IF CHI_ATTA,'=',1,SB_4
	FLG_KI W,'DOWN',6
SB_4:
	MENU_S 2,W,-1
	MENU_SET	L1,"АКЭМИ КОНДО"
	MENU_SET	L2,"ТЭРУМИ КИНОУТИ"
	MENU_SET	L3,"МИКА МАЭДА"
	MENU_SET	L4,"РЭНА ВАТАНАБЭ"
	MENU_SET	L5,"НАНА ХИРОСЭ"
	MENU_SET	L6,"СИДЗУКА ХАСЭГАВА"
	MENU_SET	L7,"ТИЭ УЦУМИ"
	MENU_SET	L8,"НЕ ЗАМОРАЧИВАТЬСЯ"
	MENU_END
	DB	EXIT
L1:
	FLG_KI HAND,'=',2
	DB	"Мм, хорошо было бы сделать это с Акэми-сан..."
	DB	NEXT
	SINARIO 'AK_H.OVL'
L2:
	FLG_KI HAND,'=',2
	DB	"Сделаем это с Тэруми-сэмпай."
	DB	NEXT
	SINARIO 'TE_H.OVL'
L3:
	FLG_KI HAND,'=',2
	DB	"Я не против сделать это с Микой-сэнсэй."
	DB	NEXT
	SINARIO 'MI_H.OVL'
L4:
	FLG_KI HAND,'=',2
	DB	"Никогда не забуду весенние каникулы..."
	DB	NEXT
	SINARIO 'RE_H.OVL'
L5:
	FLG_KI HAND,'=',2
	DB	"Я был бы рад сорвать с неё эту форму..."
	DB	NEXT
	SINARIO 'NA_H.OVL'
L6:
	FLG_KI HAND,'=',2
	DB	"Она -- прекрасное создание. Я бы счёл за честь сделать это с ней."
	DB	NEXT
	SINARIO 'SI_H.OVL'
L7:
	FLG_KI HAND,'=',2
	DB	"Ах, этот прелестный купальник..."
	DB	NEXT
	SINARIO 'CH_H.OVL'
L8:
	DB	"Пожалуй, мне не нужно заниматься этим прямо сейчас."
	DB	NEXT
	GO ROUKA
TOIRE:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB	"Чувствуя себя лучше, я стою перед раковиной."
	DB	NEXT
	DB	"Кэндзиро: Аххх..."
	DB	NEXT
	DB	"То, что надо."
	DB	NEXT
	DB	"Я мою руки и выхожу в коридор."
	DB	NEXT
	GO ROUKA
DERU:
K2:
	DB	"Нет причины находиться здесь. Я, пожалуй, пойду."
	DB	NEXT
	GO ROUKA
J3:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"Я направляюсь в кабинет ИЗО."
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	T_CG 'tt_12_13a',MIK2,0
	DB	"Здесь Мика-сэнсэй."
	DB	NEXT
	DB	"Мика: А, Кондо-кун, ты пришёл."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	M1,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	M2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	M3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
M1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_1
	FLG_KI MIKA_NET,'=',1
WW_1:
	DB	"Её руки скрещены, и грудь лежит на них. Я бы хотел засунуть свой член между этими сиськами."
	DB	NEXT
	GO BODY_MIKA
M2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_2
	FLG_KI MIKA_NET,'=',1
WW_2:
	DB	"Моё лицо коснулось этой блаженной задницы. Этот опыт я не скоро забуду."
	DB	NEXT
	GO BODY_MIKA
M3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',6
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_3
	FLG_KI MIKA_NET,'=',1
WW_3:
	DB	"Мягкие, эластичные -- превосходные во всех отношениях ляжки."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB	"Мика: ...Куда это ты только что смотрел? Скорее доставай свой альбом."
	DB	NEXT
	DB	"Кэндзиро: ........................................."
	DB	NEXT
	DB	"Мика: В чём дело?"
	DB	NEXT
	DB	"Кэндзиро: ...Я зайду попозже, Мика-сэнсэй!"
	DB	NEXT
	DB	"Мика: А, подожди!" 
	DB	NEXT
	DB	"Я выбегаю в коридор."
	DB	NEXT
	GO ROUKA
J4:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"Хранилище спортинвентаря. Интересно, есть тут кто-нибудь?"
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB	"Здесь никого нет. Пожалуй, пойду назад.."
	DB	NEXT
	GO ROUKA
J5:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"Интересно, Мотока здесь?"
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	T_CG 'tt_10_11a',MOT_A2,0
	DB	"Когда я вхожу в её класс, Мотока подбегает ко мне."
	DB	NEXT
	DB	"Мотока: А, Ониитян." 
	DB	NEXT
	DB	"Кэндзиро: Ты ещё здесь. Я думал, ты уже домой пошла."
	DB	NEXT
	DB	"Мотока: Я только что собиралась идти. А ты?"
	DB	NEXT
	DB	"Кэндзиро: Я ещё немного тут поброжу."
	DB	NEXT
	DB	"Мотока: Правда? Почему бы тебе вместо этого не пойти домой вместе со мной?"
	DB	NEXT
	DB	"Кэндзиро: Извини, Мне ещё надо кое-что сделать."
	DB	NEXT
	TATI_ERS	;Tt_10
	T_CG 'tt_21_11a',MOT_B2,0
	DB	"Мотока: ...Ладно. Тогда, до встречи дома."
	DB	NEXT
	TATI_ERS	;Tt_10
	DB	"Кэндзиро: А, Мотока."
	DB	NEXT
	DB	"Окликнул я её."
	DB	NEXT
	T_CG 'tt_21_11a',MOT_B2,0
	DB	"Мотока: Да?"
	DB	NEXT
	DB	"Кэндзиро: ...Извини, я провожу тебя домой в другой раз."
	DB	NEXT
	DB	"Мотока: Ничего страшного, не волнуйся об этом. До скорого, Ониитян." 
	DB	NEXT
	DB	"Она выходит из класса."
	DB	NEXT
	DB	"Знаешь, сейчас эта девчонка улыбается не так часто как раньше. Хотел бы я знать, не случилось ли чего?"
	DB	NEXT
	DB	"Пожалуй, я тоже пойду."
	DB	NEXT
	GO ROUKA
HOKEN:
	FLG_KI HOK,'=',3
	SINARIO 'ER.OVL'
KYOUSITU:
	BAK_INIT	'tb_034a',B_NORM
	DB	"Пожалуй, вернусь в свой класс."
	DB	NEXT
	FLG_KI HOK,'=',0
	BAK_INIT 'tb_011b',B_NORM
	DB	"Пора идти домой."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY		22
	DB	"Когда я выхожу из школы, солнце клонится к закату. Сейчас темнеет очень рано."
	DB	NEXT
	DB	"Думаю, не обязательно сразу идти домой."
	DB	NEXT
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
	FLG_KI TEMP08,'=',0
	GO SENTAKU
MATI:
	BAK_INIT	'tb_018c',B_NORM
	DB	"Куда мне пойти?"
	DB	NEXT
SENTAKU:
	FLG_KI W,'=',-1
	FLG_IF TEMP02,'=',0,SC_1
	FLG_KI W,'DOWN',0
SC_1:
	FLG_IF TEMP03,'=',0,SC_2
	FLG_KI W,'DOWN',1
SC_2:
	FLG_IF TEMP04,'=',0,SC_3
	FLG_KI W,'DOWN',2
SC_3:
	FLG_IF TEMP05,'=',0,SC_4
	FLG_KI W,'DOWN',3
SC_4:
	FLG_IF TEMP06,'=',0,SC_5
	FLG_KI W,'DOWN',4
SC_5:
	FLG_IF TEMP07,'=',0,SC_6
	FLG_KI W,'DOWN',5
SC_6:
	MENU_S 2,W,-1
	MENU_SET	N1,"В КИНОТЕАТР"
	MENU_SET	N2,"В БАР НИЖНЕГО БЕЛЬЯ"
	MENU_SET	N3,"В ПАРК"
	MENU_SET	N4,"В ОТЕЛЬ ЛЮБВИ"
	MENU_SET	N5,"В БАР"
	MENU_SET	N6,"ДОМОЙ"
	MENU_END
	DB	EXIT
N1:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"Пожалуй, схожу в кино."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB	"Этот кинотеатр -- захудалое местечко."
	DB	NEXT
	DB	"Хотя, он находится в переулке. Неудивительно, что он такой."
	DB	NEXT
	DB	"Ни одного фильма, который я бы действительно хотел посмотреть. Нет нужды заходить внутрь."
	DB	NEXT
	GO MATI
N2:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"Пожалуй, схожу посмотрю на бар нижнего белья."
	DB	NEXT
	BAK_INIT 'tb_027',B_NORM
	DB	"Я страстно желаю попасть внутрь и посмотреть, что там."
	DB	NEXT
	T_CG 'tt_07_27',TET_B2,0
	FLG_KI TET_KAIS,'+',1
	DB	"Тэцуя: Что ты тут делаешь?"
	DB	NEXT
	DB	"Передо мной появляется Тэцуя."
	DB	NEXT
	DB	"Кэндзиро: Я? А ты что?"
	DB	NEXT
	DB	"Тэцуя: Я? Просто осматриваю это место. В смысле, тут очень клёво, ты так не думаешь?"
	DB	NEXT
	DB	"Кэндзиро: А?"
	DB	NEXT
	DB	"Тэцуя: В смысле, каждый парень хотел бы туда войти, хоть разок." 
	DB	NEXT
	DB	"Кэндзиро: ...Ну, пожалуй."
	DB	NEXT
	DB	"Тэцуя: Видишь? Ах, разочка бы хватило. Потом я мог бы умереть счастливым." 
	DB	NEXT
	DB	"Он неотрывно пялится на вывеску перед баром нижнего белья. Сейчас он в своём собственном мире."
	DB	NEXT
	DB	"Лучше с ним не разговаривать."
	DB	NEXT
	GO MATI
N3:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"В парк ночью? Звучит довольно эротично."
	DB	NEXT
	BAK_INIT 'tb_032b',B_NORM
	DB	"Множество парочек гуляет здесь, взявшись за руки. В кустах их, наверное, ещё больше."
	DB	NEXT
	DB	"Тэруми: Что ты здесь делаешь?"
	DB	NEXT
	DB	"Я уже слышал этот голос раньше. Я поворачиваюсь и вижу там Тэруми-сэмпай."
	DB	NEXT
	T_CG 'tt_05_32b',TER2,0
	DB	"Кэндзиро: А, Тэруми-сэмпай."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	O1,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	O2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	O3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
O1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WS_1
	FLG_KI TER_NET,'=',1
WS_1:
	DB	"Её правая рука закрывает мне вид, но могу сказать, что её сиськи великолепны, идеального объёма."
	DB	NEXT
	GO	BODY_TERUMI
O2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WS_2
	FLG_KI TER_NET,'=',1
WS_2:
	DB	"Её задница упругая и красивая. У неё отличная форма бёдер."
	DB	NEXT
	GO BODY_TERUMI
O3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WS_3
	FLG_KI TER_NET,'=',1
WS_3:
	DB	"Её ляжки мягкие и эластичные. И очень стройные."
	DB	NEXT
	GO BODY_TERUMI
BODY_TERUMI:
	DB	"Тэруми: Ч-что случилось? Ты вдруг затих..." 
	DB	NEXT
	DB	"Кэндзиро: Э? О, ничего. Просто мне интересно, почему ты здесь так поздно."
	DB	NEXT
	DB	"Тэруми: Я просто вышла погулять."
	DB	NEXT
	DB	"Кэндзиро: Здесь? В темноте?"
	DB	NEXT
	DB	"Тэруми: Ты за меня волнуешься?" 
	DB	NEXT
	DB	"На мгновение она стала радостной."
	DB	NEXT
	DB	"Кэндзиро: Я просто беспокоился, что кто-то может напасть на тебя..."
	DB	NEXT
	DB	"Тэруми: Ч-чего?" 
	DB	NEXT
	DB	"Кэндзиро: И-извини!"
	DB	NEXT
	DB	"Я убежал так быстро, как только мог."
	DB	NEXT
	GO MATI
N4:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"Отель любви? Никогда в нём не бывал."
	DB	NEXT
	BAK_INIT 'tb_025',B_NORM
	DB	"Перед ним находится яркая вывеска."
	DB	NEXT
	DB	"Кэндзиро: Пожалуй, нет причины торчать перед этим местом."
	DB	NEXT
	GO MATI
N5:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"Мне не очень хочется заходить в такое место."
	DB	NEXT
	DB	"Хотя, пожалуй, ничего не будет, если я просто постою рядом."
	DB	NEXT
	DB	"Я направляюсь к бару."
	DB	NEXT
	BAK_INIT 'tb_029',B_NORM
	T_CG 'tt_03_29',HIR2,0
	DB	"Хироси: Что-ты тут делаешь?"
	DB	NEXT
	DB	"О нет! Это Хироси!"
	DB	NEXT
	DB	"Кэндзиро: О, ничего. Просто шёл мимо. До встречи."
	DB	NEXT
	DB	"Я в спешке покинул это место."
	DB	NEXT
	GO MATI
N6:
	DB	"Пожалуй, теперь пойду домой..."
	DB	NEXT
	GO JITAKU
JITAKU:
	BAK_INIT 'tb_005c',B_NORM
	DB	"Ах, хорошо быть дома."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	DB	"А? Никого нет."
	DB	NEXT
	DB	"Кэндзиро: Акэми-сан?"
	DB	NEXT
	DB	"Я зову Акэми-сан, но она не отзывается."
	DB	NEXT
	DB	"Хотел бы я знать, куда они ушли?"
	DB	NEXT
	DB	"Я иду в комнату Акэми-сан, посмотреть, нет ли её там."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Я стучусь в дверь комнаты Акэми-сан."
	;WAV	'SE_NO'
	DB	NEXT
	DB	"Кэндзиро: Акэми-сан?"
	DB	NEXT
	DB	"Не отвечает. Я снова стучусь."
	;WAV	'SE_NO'
	DB	NEXT
	DB	"Кэндзиро: Акэми-сан? Вы здесь?"
	DB	NEXT
	DB	"Я медленно открываю дверь комнаты Акэми-сан."
	DB	NEXT
	BAK_INIT 'tb_004',B_NORM
	CDPLAY		6
	T_CG 'tt_19_04',AKE_B2,0
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',20
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WD_1
	FLG_KI AKEM_NET,'=',1
WD_1:
	DB	"Акэми: Кэндзиро-кун, с возвращением."
	DB	NEXT
	DB	"Акэми-сан в одном нижнем белье."
	DB	NEXT
	DB	"Кэндзиро: А-акэми-сан!"
	DB	NEXT
	DB	"Моё лицо покраснело, я отворачиваюсь, чтобы не смотреть на неё."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Кэндзиро: Если вы были здесь, то почему не ответили, когда я стучал?"
	DB	NEXT
	DB	"Акэми: Извини, я задумалась и не услышала." 
	DB	NEXT
	DB	"Акэми: Но тебя не должно беспокоить, что я в нижнем белье. Мы же мать и сын, не так ли?"
	DB	NEXT
	DB	"Кэндзиро: ...Я иду спать."
	DB	NEXT
	DB	"Я направился в свою комнату."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"Моё сердце всё ещё стучит в груди, я готовлюсь ко сну."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_15.OVL'
HEYA:
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_NORM,C_KURO
	DB	"Кэндзиро: Мммм?"
	DB	NEXT
	DB	"Я медленно поднимаю веки."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	DB	"Где я?"
	DB	NEXT
	DB	"Я осматриваюсь. Я у себя в комнате."
	DB	NEXT
	DB	"А? Что случилось?"
	DB	NEXT
	DB	"На моей одежде бурое пятно."
	DB	NEXT
	DB	"Кровь? О, у меня пошла кровь из носа."
	DB	NEXT
	DB	"Что случилось после этого?"
	DB	NEXT
	DB	"Должно быть, я упал, потерял сознание."
	DB	NEXT
	DB	"Кто-то отнёс меня в мою комнату."
	DB	NEXT
	DB	"Но кто? Впрочем, подумаю об этом позже."
	DB	NEXT
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_15.OVL'
END