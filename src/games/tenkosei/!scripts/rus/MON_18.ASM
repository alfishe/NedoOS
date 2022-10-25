        include SUPER_C.inc
M_START:
MON_18
	FLG_IF HOK,'=',4,KYOUSITU
	FLG_IF HAND,'=',3,TOIRE
	FLG_IF JUMP,'=',60,FUFUFU_7
	FLG_IF JUMP,'=',59,FUFUFU_6
	FLG_IF JUMP,'=',58,FUFUFU_5
	FLG_IF JUMP,'=',57,FUFUFU_4
	FLG_IF JUMP,'=',56,FUFUFU_3
	FLG_IF JUMP,'=',55,FUFUFU_2
	FLG_IF JUMP,'=',54,FUFUFU_1
	FLG_IF JUMP,'=',53,JITAKU
	BAK_INIT 'tb_010',B_NORM
	CDPLAY		14
	DB	"Ну что ж, время для десерта."
	DB	NEXT
	T_CG 'tt_08_10',TET_A2,0
	DB	"Тэцуя: Кэндзиро."
	DB	NEXT
	DB	"Кэндзиро: Да?"
	DB	NEXT
	DB	"Тэцуя: Я только что слышал интересную сплетню..." 
	DB	NEXT
	DB	"Кэндзиро: Замечательно. Ещё сплетни."
	DB	NEXT
	DB	"Тэцуя: Не торопись. Если это правда, то тебя тоже касается."
	DB	NEXT
	DB	"Кэндзиро: Меня?"
	DB	NEXT
	DB	"Тэцуя: Да. Это по поводу твоей сестрёнки, Мотоки."
	DB	NEXT
	DB	"Кэндзиро: Мотоки?"
	DB	NEXT
	DB	"Тэцуя: Да."
	DB	NEXT
	DB	"Кэндзиро: Уверен, ты хочешь сказать мне, что Мотока снялась в каком-нибудь порнофильме, верно?"
	DB	NEXT
	DB	"Тэцуя: Нет, ничего подобного. ...Знаешь, в последнее время она ошивается в компании довольно подозрительных личностей." 
	DB	NEXT
	DB	"Кэндзиро: Я не хочу, чтобы ты больше так шутил, прекрати сейчас же."
	DB	NEXT
	DB	"Тэцуя: Это не шутка, а слух, но, пока у меня нет никаких доказательств, тебе не о чем волноваться."
	DB	NEXT
	DB	"Тэцуя: Ну, я пошёл."
	DB	NEXT
	DB	"Кэндзиро: Постой."
	DB	NEXT
	TATI_ERS		;TT_08
	DB	"Игнорируя меня, Тэцуя выходит из класса."
	DB	NEXT
	DB	"...Уверен, что Мотока никогда бы не сделала никакой глупости."
	DB	NEXT
	DB	"Я выхожу в коридор."
	DB	NEXT
	BAK_INIT 'tb_034a',B_NORM
	DB	"Что ж, теперь поищем десерта."
	DB	NEXT
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
	FLG_KI TEMP08,'=',0
	FLG_KI TEMP09,'=',0
	GO SENTAKU1
ROUKA:
	BAK_INIT	'tb_034a',B_NORM
	CDPLAY		14
	DB	"Куда мне пойти?"
	DB	NEXT
SENTAKU1:
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
	FLG_IF TEMP07,'=',0,SA_6
	FLG_KI W,'DOWN',5
SA_6:
	FLG_IF TEMP08,'=',0,SA_7
	FLG_KI W,'DOWN',6
SA_7:
	FLG_IF SIZ_ATTA,'=',1,SA_8
	FLG_KI W,'DOWN',6
SA_8:
	MENU_S 2,W,-1
	MENU_SET	AB1,"В КАБИНЕТ МУЗЫКИ"
	MENU_SET	AB2,"В СВОЙ КЛАСС"
	MENU_SET	AB3,"В КЛАСС МОТОКИ"
	MENU_SET	AB4,"В ПОДСОБКУ СПОРТЗАЛА"
	MENU_SET	AB5,"В КАБИНЕТ ИЗО"
	MENU_SET	AB6,"В МУЖСКОЙ ТУАЛЕТ"
	MENU_SET	AB7,"В МЕДКАБИНЕТ"
	MENU_END
	DB	EXIT
AB1:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"Хотел бы я знать, Сихо сегодня играет?"
	DB	NEXT
	BAK_INIT 'tb_016',B_NORM
	T_CG 'tt_02_16',SIH_A2,0
	FLG_KI	SIH_KAIS,'+',1
	CDPLAY		10
	DB	"Здесь Сихо."
	DB	NEXT
	DB	"Сихо: А, Кэндзиро-кун." 
	DB	T_WAIT,	5
	DB	" Ты пришёл послушать как я играю на рояле."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AC1,"СМОТРЕТЬ НА ЛИЦО"
	MENU_SET	AC2,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	AC3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
AC1:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"По мне, Сихо -- превосходная девушка. Такое прелестное личико."
	DB	NEXT
	GO SHIHO_BODY
AC2:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Её форма не даёт мне насладиться видом, но я уверен, что её сиськи превосходного размера."
	DB	NEXT
	GO SHIHO_BODY
AC3:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Превосходные ляжки. Белые, с идеальным количеством мясца на них."
	DB	NEXT
	GO SHIHO_BODY
SHIHO_BODY:
	FLG_KI AKEM_NET,'=',0
	FLG_KI MIKA_NET,'=',0
	FLG_KI TER_NET,'=',0
	FLG_KI RENA_NET,'=',0
	FLG_KI NANA_NET,'=',0
	FLG_KI SIZU_NET,'=',0
	FLG_KI CHIE_NET,'=',0
	DB	"Это неправильно. Я не хочу грязно думать об этой превосходной девушке."
	DB	NEXT
	DB	"Сихо: Что случилось?"
	DB	NEXT
	DB	"Кэндзиро: Что? О, ничего..."
	DB	NEXT
	DB	"Сихо: Ясно..."
	DB	NEXT
	DB	"Кэндзиро: Ты не собираешься играть сегодня?"
	DB	NEXT
	DB	"Сихо: Извини, сегодня мне нужно пораньше уйти домой..." 
	DB	NEXT
	DB	"Кэндзиро: О, понятно. Как жаль."
	DB	NEXT
	DB	"Сихо: Извини."
	DB	NEXT
	DB	"Кэндзиро: Всё нормально."
	DB	NEXT
	DB	"Сихо: Ну, до завтра." 
	DB	NEXT
	DB	"Кэндзиро: Ага..."
	DB	NEXT
	TATI_ERS		;Tt_02
	DB	"Сихо выходит из кабинета музыки."
	DB	NEXT
	DB	"Пожалуй, я тоже пойду."
	DB	NEXT
	GO ROUKA
AB2:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"Пожалуй, вернусь в класс."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	CDPLAY		14
	DB	"В классе никого нет."
	DB	NEXT
	DB	"Кэндзиро: Я здесь совсем один."
	DB	NEXT
	DB	"Я выхожу обратно в коридор."
	DB	NEXT
	GO ROUKA
AB3:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"Пожалуй, пойду погляжу, что там у Мотоки в классе."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	T_CG 'tt_10_11a',MOT_A2,0
	DB	"Увидев меня, Мотока подбегает ко мне."
	DB	NEXT
	DB	"Мотока: А, Ониитян." 
	DB	NEXT
	DB	"Кэндзиро: А, ты ещё здесь."
	DB	NEXT
	DB	"Мотока: Да. Но я уже собралась идти домой. А ты?"
	DB	NEXT
	DB	"Кэндзиро: Я собираюсь ещё тут побродить."
	DB	NEXT
	DB	"Мотока: Правда? Почему бы нам не пойти домой вместе?"
	DB	NEXT
	DB	"Кэндзиро: Извини, но мне ещё надо кое-что сделать."
	DB	NEXT
	TATI_ERS
	T_CG 'tt_21_11a',MOT_A2,0
	DB	"Мотока: ...Ладно. Тогда я пойду." 
	DB	NEXT
	TATI_ERS		;Tt_10
	DB	"Кэндзиро: А, Мотока."
	DB	NEXT
	DB	"Я окликнул её, и она остановилась."
	DB	NEXT
	T_CG 'tt_21_11a',MOT_A2,0
	DB	"Мотока: Да? Ониитян." 
	DB	NEXT
	DB	"Кэндзиро: ...Прости меня."
	DB	NEXT
	DB	"Мотока: Всё нормально. До встречи, Ониитян.." 
	DB	NEXT
	TATI_ERS
	DB	"Мотока выходит из класса."
	DB	NEXT
	DB	"В последние дни Мотока не особо улыбчива."
	DB	NEXT
	DB	"Пожалуй, я тоже пойду."
	DB	NEXT
	DB	"Я выхожу из класса Мотоки."
	DB	NEXT
	GO ROUKA
AB4:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"Пожалуй, посмотрю, что там в подсобке спортзала."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB	"Тут никого нет."
	DB	NEXT
	DB	"Пожалуй, пойду назад."
	DB	NEXT
	GO ROUKA
AB5:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"У меня нет никакой причины идти туда, но я хочу увидеть свою любимую учительницу."
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	CDPLAY		18
	DB	"Мика здесь, вытирает пыль со статуи."
	DB	NEXT
	DB	"Кэндзиро: Мика-сэнсэй."
	DB	NEXT
	DB	"Мика: О, Кондо-кун."
	DB	NEXT
	T_CG 'tt_12_13a',MIK2,0
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AD1,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	AD2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	AD3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
AD1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WQ_1
	FLG_KI MIKA_NET,'=',1
WQ_1:
	DB	"Её руки скрещены, закрывая вид на её сиськи. Хотя, я бы хотел сунуть свой член между ними."
	DB	NEXT
	GO BODY_MIKA
AD2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WQ_2
	FLG_KI MIKA_NET,'=',1
WQ_2:
	DB	"Моё лицо касалось этой задницы. Я ещё не скоро это забуду."
	DB	NEXT
	GO BODY_MIKA
AD3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',6
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WQ_3
	FLG_KI MIKA_NET,'=',1
WQ_3:
	DB	"Милые ляжки, хорошей формы. Аппетитные."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB	"Мика: Ты только что смотрел на меня?" 
	DB	NEXT
	DB	"Кэндзиро: Э? Смотрел на вас?"
	DB	NEXT
	DB	"Мика: ...Неважно. Забудь о том, что я сказала."
	DB	NEXT
	DB	"Мика: Как бы то ни было, я рада, что ты пришёл вовремя."
	DB	NEXT
	DB	"Кэндзиро: Э?"
	DB	NEXT
	DB	"Мика: ...Не говори мне, что забыл." 
	DB	NEXT
	DB	"Уй! Я забыл!"
	DB	NEXT
	DB	"Кэндзиро: Д-до встречи, Мика-сэнсэй..."
	DB	NEXT
	DB	"Мика: С-стой! Вернись!" 
	DB	NEXT
	DB	"Я спешно покинул кабинет ИЗО."
	DB	NEXT
	GO ROUKA
AB6:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB	"Я направляюсь в мужской туалет."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	DB	"Вторая кабинка с конца, мой личный кабинет. Как всегда, пуста."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AE1,"ВОЙТИ"
	MENU_SET	AE2,"УЙТИ"
	MENU_END
	DB	EXIT
AE1:
	FLG_IF YOKU,'<',45,DERU
	FLG_IF YOKU,'<',100,SENTAKU2
	FLG_IF AKEM_NET,'!=',1,QQ_1
	FLG_KI HAND,'=',3
	SINARIO 'AK_H.OVL'
QQ_1:
	FLG_IF MIKA_NET,'!=',1,QQ_2
	FLG_KI HAND,'=',3
	SINARIO 'MI_H.OVL'
QQ_2:
	FLG_IF TER_NET,'!=',1,QQ_3
	FLG_KI HAND,'=',3
	SINARIO 'TE_H.OVL'
QQ_3:
	FLG_IF RENA_NET,'!=',1,QQ_4
	FLG_KI HAND,'=',3
	SINARIO 'RE_H.OVL'
QQ_4:
	FLG_IF NANA_NET,'!=',1,QQ_5
	FLG_KI HAND,'=',3
	SINARIO 'NA_H.OVL'
QQ_5:
	FLG_IF SIZU_NET,'!=',1,QQ_6
	FLG_KI HAND,'=',3
	SINARIO 'SI_H.OVL'
QQ_6:
	FLG_IF CHIE_NET,'!=',1,QQ_7
	FLG_KI HAND,'=',3
	SINARIO 'CH_H.OVL'
QQ_7:
SENTAKU2:
	FLG_KI W,'=',-1
	FLG_IF RENA_NET,'!=',0,QW_1
	FLG_KI W,'DOWN',3
QW_1:
	FLG_IF NANA_NET,'!=',0,QW_2
	FLG_KI W,'DOWN',4
QW_2:
	FLG_IF SIZU_NET,'!=',0,QW_3
	FLG_KI W,'DOWN',5
QW_3:
	FLG_IF CHIE_NET,'!=',0,QW_4
	FLG_KI W,'DOWN',6
QW_4:
	MENU_S 2,W,-1
	MENU_SET	AF1,"АКЭМИ КОНДО"
	MENU_SET	AF2,"ТЭРУМИ КИНОУТИ"
	MENU_SET	AF3,"МИКА МАЭДА"
	MENU_SET	AF4,"РЭНА ВАТАНАБЭ"
	MENU_SET	AF5,"НАНА ХИРОСЭ"
	MENU_SET	AF6,"СИДЗУКА ХАСЭГАВА"
	MENU_SET	AF7,"ТИЭ УЦУМИ"
	MENU_SET	AF8,"НЕ ЗАМОРАЧИВАТЬСЯ"
	MENU_END
	DB	EXIT
AF1:
	DB	"Да, Акэми-сан это хорошо."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'AK_H.OVL'
AF2:
	DB	"Сделаем это с Тэруми-сэмпай."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'TE_H.OVL'
AF3:
	DB	"Я не против сделать это с Микой-сэнсэй."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'MI_H.OVL'
AF4:
	DB	"Не могу забыть весенние каникулы."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'RE_H.OVL'
AF5:
	DB	"Я был бы рад сорвать с неё эту форму..."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'NA_H.OVL'
AF6:
	DB	"Было бы здорово войти в неё."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'SI_H.OVL'
AF7:
	DB	"Она выглядит великолепно в своём купальнике."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'CH_H.OVL'
AF8:
	DB	"Неа, думаю, лучше не заморачиваться."
	DB	NEXT
	GO ROUKA
AE2:
DERU:
	DB	"Пожалуй, надо идти."
	DB	NEXT
	GO ROUKA
TOIRE:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB	"Чувствуя себя намного лучше, я иду к раковине."
	DB	NEXT
	DB	"Ах, это было здорово."
	DB	NEXT
	DB	"Я мою руки и выхожу в коридор."
	DB	NEXT
	GO ROUKA
AB7:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'=',1
	FLG_KI TEMP08,'=',1
	DB	"Медицинский кабинет... Интересно, Сидзука-сэнсэй там?"
	DB	NEXT
	EVENT_CG	'th_072',B_NORM,35
	DB	"Сидзука: Ты заболел?"
	DB	NEXT
	DB	"Кэндзиро: Нет, со мной всё хорошо."
	DB	NEXT
	DB	"Сидзука: Тогда зачем ты здесь?"
	DB	NEXT
	DB	"Кэндзиро: Я захотел увидеть вас."
	DB	NEXT
	DB	"Сидзука: О, я так этому рада."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AG_1,"СМОТРЕТЬ НА ЛИЦО"
	MENU_SET	AG_2,"СМОТРЕТЬ НА РУКИ"
	MENU_SET	AG_3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
AG_1:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,UR_1
	FLG_KI SIZU_NET,'=',1
UR_1:
	DB	"Она симпатичная. По-настоящему красивое лицо."
	DB	NEXT
	GO BODY_SIZUKA
AG_2:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,UR_2
	FLG_KI SIZU_NET,'=',1
UR_2:
	DB	"Я бы хотел, чтобы эти пальчики с маникюром помяли мой член."
	DB	NEXT
	GO BODY_SIZUKA
AG_3:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,UR_3
	FLG_KI SIZU_NET,'=',1
UR_3:
	DB	"Я вижу только кружева на верхней части её чулок. Это просто чересчур эротично."
	DB	NEXT
	GO BODY_SIZUKA
BODY_SIZUKA:
	DB	"Сидзука: Как ты думаешь, куда ты смотришь, парень?"
	DB	NEXT
	DB	"Кэндзиро: Э? О, никуда..."
	DB	NEXT
	DB	"Сидзука: Ты юн, так что, полагаю, с этим ничего не поделаешь."
	DB	NEXT
	DB	"Кэндзиро: Д-до встречи, Сидзука-сэнсэй."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Боже, она слишком умна для меня."
	DB	NEXT
	GO ROUKA
HOKEN:
	FLG_KI HOK,'=',4
	SINARIO 'ER.OVL'
HOKEN2:
	FLG_KI HOK,'=',4
	SINARIO 'ER2.OVL'
KYOUSITU:
	FLG_KI HOK,'=',0
	BAK_INIT 'tb_034b',B_NORM
	DB	"Пожалуй, вернусь в свой класс."
	DB	NEXT
	BAK_INIT 'tb_011b',B_NORM
	DB	"Пора собираться домой."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI JUMP,'=',53
	SINARIO 'NITI_MAT.OVL'
JITAKU:
	FLG_KI JUMP,'=',0
	BAK_INIT 'tb_005c',B_NORM
	DB	"АХ, хорошо быть дома."
	DB	NEXT
	DB	"Я открываю дверь и вхожу."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		9
	T_CG 'tt_11_02',MOT_C3,0
	T_CG 'tt_20_02',AKE_A1,0
	DB	"Здесь Мотока и Акэми-сан."
	DB	NEXT
	DB	"Кэндзиро: Привет, я дома."
	DB	NEXT
	DB	"Мотока: Ониитян, привет."
	DB	NEXT
	DB	"Акэми: Кэндзиро-кун, с возвращением."
	DB	NEXT
	DB	"...Господи, по какой-то причине я не могу перестать думать о том, что Тэцуя сказал мне про Мотоку."
	DB	NEXT
	DB	"Мотока: Ониитян? В чём дело?" 
	DB	NEXT
	DB	"Кэндзиро: Э? О, ни в чём."
	DB	NEXT
	DB	"Акэми: Ты хорошо себя чувствуешь, Кэндзиро-кун? Хочешь прилечь?"
	DB	NEXT
	DB	"Кэндзиро: Нет, со мной всё хорошо."
	DB	NEXT
	DB	"Акэми: В таком случае, может, присядешь? Ужин почти готов." 
	DB	NEXT
	DB	"Кэндзиро: Да, конечно."
	DB	NEXT
	DB	"Я медленно сажусь на стул."
	DB	NEXT
	DB	"Мотока: Почему бы тебе сначала портфель не поставить?"
	DB	NEXT
	DB	"Кэндзиро: О, хорошая мысль."
	DB	NEXT
	DB	"Я не заметил, пока Мотока мне не сказала, но я прижимал к груди свой портфель. Я быстро поставил его на пол."
	DB	NEXT
	DB	"Мотока: ...Ты как-то странно себя ведёшь, Ониитян." 
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"Мотока: ...Ты как-то странно себя ведёшь, Ониитян."
	DB	NEXT
	DB	"Я никогда не заподозрю в этом свою сестру."
	DB	NEXT
	DB	"Кэндзиро: Что ж, пора ложиться спать."
	DB	NEXT
	B_O B_FADE,C_KURO	;F.O
	FLG_KI HIDUKE,'+',1
	BAK_INIT 'tb_001a',B_NORM
	FLG_KI JUMP,'=',54
	SINARIO 'NITI_ASA.OVL'
FUFUFU_1:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',55
	SINARIO 'NITI_HIR.OVL'
FUFUFU_2:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',56
	SINARIO 'NITI_HOK.OVL'
FUFUFU_3:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',57
	SINARIO 'NITI_MAT.OVL'
FUFUFU_4:
	FLG_IF HANAJI,'=',1,ASA1
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',58
	SINARIO 'NITI_KIT.OVL'
FUFUFU_5:
	FLG_KI JUMP,'=',0
ASA1:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',59
	SINARIO 'NITI_ASA.OVL'
FUFUFU_6:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',60
	FLG_KI	MOTDOYOU,'=',1
	SINARIO 'NITI_HOK.OVL'
FUFUFU_7:
	FLG_KI JUMP,'=',0
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
	BAK_INIT 'tb_018a',B_NORM
	CDPLAY		2
	FLG_KI	MOTDOYOU,'=',0
	DB	"Днём я здесь ещё не бывал."
	DB	NEXT
	GO	RARA
MATI:
	BAK_INIT	'tb_018a',B_NORM
	DB	"Хотел бы я знать, чем заняться?"
	DB	NEXT
RARA:
	FLG_KI W,'=',-1
	FLG_IF TEMP02,'=',0,FF_1
	FLG_KI W,'DOWN',0
FF_1:
	FLG_IF TEMP03,'=',0,FF_2
	FLG_KI W,'DOWN',1
FF_2:
	FLG_IF TEMP04,'=',0,FF_3
	FLG_KI W,'DOWN',2
FF_3:
	FLG_IF TEMP05,'=',0,FF_4
	FLG_KI W,'DOWN',3
FF_4:
	FLG_IF TEMP06,'=',0,FF_5
	FLG_KI W,'DOWN',4
FF_5:
	FLG_IF TEMP07,'=',0,FF_6
	FLG_KI W,'DOWN',5
FF_6:
	MENU_S 2,W,-1
	MENU_SET	F1,"В КИНОТЕАТР"
	MENU_SET	F2,"В БАР НИЖНЕГО БЕЛЬЯ"
	MENU_SET	F3,"В ПАРК"
	MENU_SET	F4,"В ОТЕЛЬ ЛЮБВИ"
	MENU_SET	F5,"В БАР"
	MENU_SET	F6,"В КОФЕЙНЮ"
	MENU_SET	F7,"ДОМОЙ"
	MENU_END
	DB	EXIT
F1:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"В кино, да? Может быть, показывают что-нибудь интересное."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB	"Сейчас день, но здесь такое ощущение, будто солнце начало садиться."
	DB	NEXT
	DB	"Думаю, это место всегда выглядит одинаково."
	DB	NEXT
	DB	"Нет ничего, что бы я хотел посмотреть."
	DB	T_WAIT, 5
	DB	" Пожалуй, пойду назад."
	DB	NEXT
	GO MATI
F2:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"Это не то место, куда ходят днём."
	DB	NEXT
	GO MATI
F3:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"Пожалуй, хорошее место, чтобы убить время..."
	DB	NEXT
	BAK_INIT 'tb_032a',B_NORM
	CDPLAY		8
	DB	"Сейчас день, но мне всё равно попадаются парочки, гуляющие взявшись за руки."
	DB	NEXT
	DB	"Тэруми: Что ты здесь делаешь?"
	DB	NEXT
	DB	"Я повернулся и увидел перед собой Тэруми-сэмпай."
	DB	NEXT
	T_CG 'tt_05_32a',TER2,0
	DB	"Кэндзиро: А, Тэруми-сэмпай.."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	G1,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	G2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	G3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
G1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_1
	FLG_KI TER_NET,'=',1
LL_1:
	DB	"Сиськи Тэруми-сэмпай мягкие и округлые. И к тому же, большого размера."
	DB	NEXT
	GO BODY_TERUMI
G2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_2
	FLG_KI TER_NET,'=',1
LL_2:
	DB	"Однозначно, хорошая задница. Красивый изгиб спускается от талии."
	DB	NEXT
	GO BODY_TERUMI
G3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_3
	FLG_KI TER_NET,'=',1
LL_3:
	DB	"Её ляжки мягкие и гладкие. Ни прибавить, ни отнять."
	DB	NEXT
	GO BODY_TERUMI
BODY_TERUMI:
	DB	"Тэруми: Ч-что такое? Ты вдруг затих." 
	DB	NEXT
	DB	"Кэндзиро: Э? О, ничего. Что ты тут делаешь одна?"
	DB	NEXT
	DB	"Тэруми: Просто вышла погулять. А ты?"
	DB	NEXT
	DB	"Кэндзиро: Я?"
	DB	T_WAIT, 5
	DB	" Я? Ну, я..."
	DB	NEXT
	DB	"Я подхожу к Тэруми-сэмпай и принюхиваюсь к ней."
	DB	NEXT
	DB	"Тэруми: Ты что, собака?!"
	DB	NEXT
	DB	"Кэндзиро: Да, я твоя собака, Тэруми-сэмпай."
	DB	NEXT
	DB	"Тэруми: ...Ладно, пошли, пёсик." 
	DB	NEXT
	DB	"Я посмотрел на неё. Она улыбалась."
	DB	NEXT
	DB	"О нет! Готов поспорить, что Тэруми-сэмпай собирается сыграть со мной какую-нибудь злую шутку."
	DB	NEXT
	DB	"Тэруми: Ты не собираешься мне отвечать, пёсик?"
	DB	NEXT
	DB	"Кэндзиро: *Гав!*"
	DB	NEXT
	DB	"Тэруми: Хороший пёсик!" 
	DB	NEXT
	DB	"Пора сматываться!"
	DB	NEXT
	DB	"Кэндзиро: *Гав! Гав! Гав!*"
	DB	NEXT
	DB	"Тэруми: А! Вернись!" 
	DB	NEXT
	DB	"Оставив позади Тэруми-сэмпай, я покидаю парк."
	DB	NEXT
	GO MATI
F4:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP05,'=',1
	DB	"В такое место днём не ходят."
	DB	NEXT
	GO MATI
F5:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP06,'=',1
	DB	"В такое место днём не ходят."
	DB	NEXT
	GO MATI
F6:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP07,'=',1
	DB	"Кофейня. Думаю, где-то поблизости была одна..."
	DB	NEXT
	GO MATI
F7:
	DB	"Слишком рано, чтобы идти домой."
	DB	NEXT
	GO MATI
JITAKU2:
	BAK_INIT	'tb_018b',B_NORM
	DB	"Пожалуй, теперь можно пойти домой. К тому же, я, типа, проголодался."
	DB	NEXT
	BAK_INIT 'tb_005b',B_NORM
	DB	"К тому времени, как я вернулся домой, солнце начало садиться."
	DB	NEXT
	DB	"Ах, хорошо быть дома..."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		6
	DB	"Акэми-сан здесь, но Мотоки нигде не видно."
	DB	NEXT
	T_CG 'tt_20_02',AKE_A2,0
	DB	"Акэми: А, Кэндзиро-кун, с возвращением!"
	DB	NEXT
	DB	"Кэндзиро: Спасибо."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	H1,"СМОТРЕТЬ НА КЛЮЧИЦЫ"
	MENU_SET	H2,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	H3,"СМОТРЕТЬ НА ЧУЛКИ"
	MENU_END
	DB	EXIT
H1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_1
	FLG_KI AKEM_NET,'=',1
LA_1:
	DB	"Крепкие сексуальные ключицы. Символ красивой женщины."
	DB	NEXT
	GO BODY_AKEMI
H2:
	DB	"Её груди -- это мягкие холмы, с миленькой ложбиной посредине. Хотя, я устаю от их созерцания."
	DB	NEXT
	GO BODY_AKEMI
H3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_3
	FLG_KI AKEM_NET,'=',1
LA_3:
	DB	"Её длинные, стройные ноги выглядят гораздо лучше под чёрной нейлоновой тканью чулок."
	DB	NEXT
	GO BODY_AKEMI
BODY_AKEMI:
	DB	"Акэми: В чём дело?"
	DB	NEXT
	DB	"Кэндзиро: Э? О, ни в чём."
	DB	NEXT
	DB	"Акэми: Ты ведёшь себя немного странно, не так ли?"
	DB	NEXT
	DB	"Кэндзиро: ...Эм, Акэми-сан, а где Мотока?"
	DB	NEXT
	DB	"Акэми: Она у себя в комнате."
	DB	NEXT
	DB	"Кэндзиро: ...О."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"Мне скучно. Пожалуй, пойду спать."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	GO	KEKEKE
HEYA:
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_NORM,C_KURO
	DB	"Уууммм??"
	DB	NEXT
	DB	"Мои веки медленно раскрываются."
	DB	NEXT
	BAK_INIT 'tb_001b',B_FADE
	DB	"Где я?"
	DB	NEXT
	DB	"Я осматриваюсь. Я у себя в комнате."
	DB	NEXT
	DB	"Но что случилось?"
	DB	NEXT
	DB	"Я смотрю на свою одежду. На ней бурое пятно."
	DB	NEXT
	DB	"Кровь? Теперь вспоминаю -- у меня пошла кровь из носа."
	DB	NEXT
	DB	"Должно быть, я упал в обморок. Но что случилось потом?"
	DB	NEXT
	DB	"Я потерял сознание..."
	DB	NEXT
	DB	"И кто-то, должно быть, отнёс меня сюда."
	DB	NEXT
	DB	"Кто бы это мог быть? ...Ладно, подумаю об этом позже. Сейчас пора спать."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
KEKEKE:
	BAK_INIT 'tb_001a',B_FADE
	CDPLAY		12
	DB	"Кэндзиро: ............"
	DB	NEXT
	DB	T_WAIT, 5
	DB	" Пора вставать."
	DB	NEXT
	DB	"Я смотрю на часы. Они показывают начало первого."
	DB	NEXT
	DB	"Кэндзиро: Ух ты, я реально долго спал..."
	DB	NEXT
	DB	"Ну, сегодня воскресенье. Пожалуй, можно ещё немного поспать."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_FADE
	DB	"Кэндзиро: Пора ужинать..."
	DB	NEXT
	DB	"Можно поиграть в видеоигры, пока я жду."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_FADE
	DB	"Завтра понедельник. Мне надо хорошо выспаться, чтобы подготовиться к школе."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,UIUI
	FLG_KI	ONANI,'=',0
UIUI:
	SINARIO 'MON_19.OVL'
END