        include SUPER_C.inc
M_START:
NITI_HOK
	FLG_IF HOK,'=',7,KYOUSITU
	FLG_IF HAND,'=',6,TOIRE
	F_O	B_NORM,C_KURO
	DB	"Голос: Эй! Проснись!"
	DB	NEXT
	DB	"Кэндзиро: .....Мм?"
	DB	NEXT
	BAK_INIT	'tb_011a',B_NORM
	CDPLAY	14
	DB	"Тэцуя: Проснулся наконец." 
	DB	NEXT
	DB	"Я приподнял тяжёлую голову, и посмотрел на друга."
	DB	NEXT
	T_CG	'tt_08_11a',TET_A2,0
	DB	"Тэцуя: Пора вставать уже!" 
	DB	NEXT
	DB	"Кэндзиро: А, извини."
	DB	NEXT
	DB	"Тэцуя: Ну, я домой."
	DB	NEXT
	TATI_ERS
	DB	"Кэндзиро: Спасибо."
	DB	NEXT
	DB	"Кэндзиро: Пожалуй, прошвырнусь немного."
	DB	NEXT
	DB	"Я выхожу в коридор."
	DB	NEXT
	BAK_INIT	'tb_034a',B_NORM
	DB	"Пожалуй, поищу хорошеньких девушек."
	DB	NEXT
	FLG_KI	TEMP01,'=',0
	FLG_KI	TEMP02,'=',0
	FLG_KI	TEMP03,'=',0
	FLG_KI	TEMP04,'=',0
	FLG_KI	TEMP05,'=',0
	FLG_KI	TEMP06,'=',0
	FLG_KI	TEMP07,'=',0
	FLG_KI	TEMP08,'=',0
	FLG_KI TEMP09,'=',0
	GO VV_1
SENTAKU1:
	CDPLAY	14
	BAK_INIT	'tb_034a',B_NORM
	DB	"Пойти"
	DB	NEXT
VV_1:
	FLG_KI	W,'=',-1
	FLG_IF	TEMP02,'=',0,BUNKI_D
	FLG_KI	W,'DOWN',0
BUNKI_D:
	FLG_IF	TEMP03,'=',0,BUNKI_E
	FLG_KI	W,'DOWN',1
BUNKI_E:
	FLG_IF	TEMP04,'=',0,BUNKI_F
	FLG_KI	W,'DOWN',2
BUNKI_F:
	FLG_IF	TEMP05,'=',0,BUNKI_G
	FLG_KI	W,'DOWN',3
BUNKI_G:
	FLG_IF	TEMP06,'=',0,BUNKI_H
	FLG_KI	W,'DOWN',4
BUNKI_H:
	FLG_IF	TEMP07,'=',0,BUNKI_I
	FLG_KI	W,'DOWN',5
BUNKI_I:
	FLG_IF	TEMP08,'=',0,BUNKI_J
	FLG_KI	W,'DOWN',6
BUNKI_J:
	FLG_IF	TEMP09,'=',0,BUNKI_K
	FLG_KI	W,'DOWN',7
BUNKI_K:
	FLG_IF	SIHO_PIA,'=',1,BUNKI_A
	FLG_KI	W,'DOWN',0
BUNKI_A:
	FLG_IF	SIZ_ATTA,'=',1,BUNKI_B
	FLG_KI	W,'DOWN',6
BUNKI_B:
	FLG_IF	CHI_ATTA,'=',1,BUNKI_C
	FLG_KI	W,'DOWN',7
BUNKI_C:
	BAK_INIT	'tb_034a',B_NORM
	MENU_S	2,W,-1
	MENU_SET	AB1,"В КАБИНЕТ МУЗЫКИ"
	MENU_SET	AB2,"ВЕРНУТЬСЯ В КЛАСС"
	MENU_SET	AB3,"В КЛАСС МОТОКИ"
	MENU_SET	AB4,"В ПОДСОБКУ СПОРТЗАЛА"
	MENU_SET	AB5,"В КАБИНЕТ ИЗО"
	MENU_SET	AB6,"В МУЖСКОЙ ТУАЛЕТ"
	MENU_SET	AB7,"В МЕДКАБИНЕТ"
	MENU_SET	AB8,"В РАЗДЕВАЛКУ"
	MENU_END
	DB	EXIT
AB1:
	FLG_IF	TEMP01,'>=',3,KYOUSITU
	FLG_KI	TEMP01,'+',1
	FLG_KI	TEMP02,'=',1
	DB	"Пожалуй, схожу в кабинет музыки. Интересно, Сихо там?"
	DB	NEXT
	BAK_INIT	'tb_016',B_NORM
	CDPLAY	10
	T_CG	'tt_02_16',SIH_A3,0
	FLG_KI	SIH_KAIS,'+',1
	DB	"Сихо тут."
	DB	NEXT
	DB	"Сихо: А, Кэндзиро-кун."
	DB	T_WAIT,	3
	DB	" Пришёл послушать, как я играю?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AC1,"СМОТРЕТЬ НА ЛИЦО"
	MENU_SET	AC2,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	AC3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
AC1:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"У Сихо такое милое личико. Почти идеальное."
	DB	NEXT
	GO	SIHO
AC2:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Её форма не даёт мне как следует рассмотреть её грудь, но выглядит замечательно."
	DB	NEXT
	GO	SIHO
AC3:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Потрясающие ляжки. Белые, с умеренным количеством мясца."
	DB	NEXT
	GO	SIHO
SIHO:
	FLG_KI	AKEM_NET,'=',0
	FLG_KI	MIKA_NET,'=',0
	FLG_KI	TER_NET,'=',0
	FLG_KI	RENA_NET,'=',0
	FLG_KI	NANA_NET,'=',0
	FLG_KI	SIZU_NET,'=',0
	FLG_KI	CHIE_NET,'=',0
	DB	"Хватит. Не хочу осквернять этот прелестный цветок."
	DB	NEXT
	DB	"Сихо: В чём дело?"
	DB	NEXT
	DB	"Кэндзиро: Э? О, ни в чём."
	DB	NEXT
	DB	"Сихо: Ясно..."
	DB	NEXT
	DB	"Кэндзиро: Ты будешь играть сегодня?"
	DB	NEXT
	DB	"Сихо: Извини... Сегодня мне надо уйти домой пораньше." 
	DB	NEXT
	DB	"Кэндзиро: Ох, ну ладно."
	DB	NEXT
	DB	"Сихо: Прости." 
	DB	NEXT
	DB	"Кэндзиро: Всё в порядке."
	DB	NEXT
	DB	"Сихо: Ну, до скорого."
	DB	NEXT
	DB	"Кэндзиро: Ага, счастливо."
	DB	NEXT
	TATI_ERS
	DB	"Сихо выходит из кабинета музыки."
	DB	NEXT
	DB	"Пожалуй, я тоже пойду."
	DB	NEXT
	GO	SENTAKU1
AB2:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP03,'=',1
	DB	"Пожалуй, вернусь к себе в класс."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	DB	"Тут никого нет."
	DB	NEXT
	DB	"Кэндзиро: Интересно, где все."
	DB	NEXT
	DB	"Я выхожу обратно в коридор."
	DB	NEXT
	GO	SENTAKU1
AB3:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP04,'=',1
	DB	"Пожалуй, схожу проведаю Мотоку."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	DB	"Тут никого нет. Должно быть, она рано ушла домой."
	DB	NEXT
	GO	SENTAKU1
AB4:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP05,'=',1
	DB	"Пожалуй, схожу в подсобку спортзала."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB	"Неа, никого нет."
	DB	NEXT
	DB	"Пожалуй, пойду назад."
	DB	NEXT
	GO	SENTAKU1
AB5:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP06,'=',1
	DB	"Может, сходить, проведать мой сладкий персик в кабинете ИЗО."
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
	MENU_SET	AD1,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	AD2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	AD3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
AD1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_7
	FLG_KI MIKA_NET,'=',1
WW_7:
	DB	"Её руки не дают мне рассмотреть её грудь, но выглядит здорово."
	DB	NEXT
	GO BODY_MIKA
AD2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_8
	FLG_KI MIKA_NET,'=',1
WW_8:
	DB	"Превосходная задница. Всё ещё не могу забыть тот раз, когда коснулся её."
	DB	NEXT
	GO BODY_MIKA
AD3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_9
	FLG_KI MIKA_NET,'=',1
WW_9:
	DB	"Очень милые ляжки. Мягкие и шелковистые."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB	"Мика: Эй, следи куда смотришь." 
	DB	NEXT
	DB	"Кэндзиро: Э? Я никуда не смотрел..."
	DB	NEXT
	DB	"Мика: Ох ладно, неважно."
	DB	NEXT
	DB	"Мика: В любом случае, я рада, что ты пришёл вовремя."
	DB	NEXT
	DB	"Кэндзиро: Э?"
	DB	NEXT
	DB	"Мика: Не говори, что забыл!" 
	DB	NEXT
	DB	"Чёрт! Я забыл!"
	DB	NEXT
	DB	"Кэндзиро: Д-до завтра, сэнсэй..."
	DB	NEXT
	DB	"Мика: Вернись, Кондо-кун!" 
	DB	NEXT
	DB	"Я вылетаю из кабинета ИЗО."
	DB	NEXT
	GO	SENTAKU1
AB6:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP07,'=',1
	DB	"Я иду в мужской туалет."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	DB	"Вторая кабинка с конца -- мой кабинет. Как обычно, свободна."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AE1,"ВОЙТИ В КАБИНКУ"
	MENU_SET	AE2,"НЕ ЗАМОРАЧИВАТЬСЯ"
	MENU_END
	DB	EXIT
AE1:
	FLG_IF YOKU,'<',45,DERU
	FLG_IF YOKU,'<',100,SENTAKU2
	FLG_IF AKEM_NET,'=',0,SS_1
	FLG_KI HAND,'=',6
	SINARIO 'AK_H.OVL'
SS_1:
	FLG_IF MIKA_NET,'=',0,SS_2
	FLG_KI HAND,'=',6
	SINARIO 'MI_H.OVL'
SS_2:
	FLG_IF TER_NET,'=',0,SS_3
	FLG_KI HAND,'=',6
	SINARIO 'TE_H.OVL'
SS_3:
	FLG_IF RENA_NET,'=',0,SS_4
	FLG_KI HAND,'=',6
	SINARIO 'RE_H.OVL'
SS_4:
	FLG_IF NANA_NET,'=',0,SS_5
	FLG_KI HAND,'=',6
	SINARIO 'NA_H.OVL'
SS_5:
	FLG_IF SIZU_NET,'=',0,SS_6
	FLG_KI HAND,'=',6
	SINARIO 'SI_H.OVL'
SS_6:
	FLG_IF CHIE_NET,'=',0,SS_7
	FLG_KI HAND,'=',6
	SINARIO 'CH_H.OVL'
SS_7:
SENTAKU2:
	FLG_KI W,'=',-1
	FLG_IF REN_ATTA,'=',1,JJ_1
	FLG_KI W,'DOWN',3
JJ_1:
	FLG_IF NAN_ATTA,'=',1,JJ_2
	FLG_KI W,'DOWN',4
JJ_2:
	FLG_IF SIZ_ATTA,'=',1,JJ_3
	FLG_KI W,'DOWN',5
JJ_3:
	FLG_IF CHI_ATTA,'=',1,JJ_4
	FLG_KI W,'DOWN',6
JJ_4:
	MENU_S	 2,W,-1
	MENU_SET	AF1,"АКЭМИ КОНДО"
	MENU_SET	AF2,"ТЭРУМИ КИНОУТИ"
	MENU_SET	AF3,"МИКА МАЭДА"
	MENU_SET	AF4,"РЭНА ВАТАНАБЭ"
	MENU_SET	AF5,"НАНА ХИРОСЭ"
	MENU_SET	AF6,"СИДЗУКА ХАСЭГАВА"
	MENU_SET	AF7,"ТИЭ УЦУМИ"
	MENU_SET	AF8,"НЕ ДЕЛАТЬ ЭТО"
	MENU_END
	DB	EXIT
AF1:
	DB	"Займёмся этим с Акэми-сан."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'AK_H.OVL'
AF2:
	DB	"Ммм, Тэруми-сэмпай -- это было бы здорово."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'TE_H.OVL'
AF3:
	DB	"Хотел бы я сделать это с Микой."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'MI_H.OVL'
AF4:
	DB	"Я бы хотел оживить свои воспоминания о весенних каникулах..."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'RE_H.OVL'
AF5:
	DB	"Ммм, здорово было бы сорвать с неё эту форму..."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'NA_H.OVL'
AF6:
	DB	"Сидзука-сэнсэй -- это здорово..."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'SI_H.OVL'
AF7:
	DB	"Люблю смотреть на Тиэ в купальнике."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'CH_H.OVL'
AF8:
AE2:
DERU:
	DB	"Пожалуй, пойду отсюда."
	DB	NEXT
	GO SENTAKU1
TOIRE:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB	"Ощущая себя восстановившимся, после того, как снял напряжение, я стою у мойки перед зеркалом."
	DB	NEXT
	DB	"Кэндзиро: Ммм, это было здорово."
	DB	NEXT
	DB	"Я мою руки и выхожу."
	DB	NEXT
	GO	SENTAKU1
AB7:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB	"Пожалуй, загляну к Сидзуке."
	DB	NEXT
	EVENT_CG	'th_072',B_NORM,35
	DB	"Сидзука: Что-нибудь случилось?"
	DB	NEXT
	DB	"Кэндзиро: Неа."
	DB	NEXT
	DB	"Сидзука: Тогда зачем ты здесь?"
	DB	NEXT
	DB	"Кэндзиро: Захотел увидеть вас."
	DB	NEXT
	DB	"Сидзука: О, я так рада."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AG_1,"СМОТРЕТЬ НА ЛИЦО"
	MENU_SET	AG_2,"СМОТРЕТЬ НА РУКИ"
	MENU_SET	AG_3,"СМОТРЕТЬ НА НОГИ"
	MENU_END
	DB	EXIT
AG_1:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_10
	FLG_KI SIZU_NET,'=',1
WW_10:
	DB	"У неё прелестное личико."
	DB	NEXT
	GO BODY_SIZUKA
AG_2:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_11
	FLG_KI SIZU_NET,'=',1
WW_11:
	DB	"Я бы хотел, чтобы её красные ноготки погладили мой ствол."
	DB	NEXT
	GO BODY_SIZUKA
AG_3:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_12
	FLG_KI SIZU_NET,'=',1
WW_12:
	DB	"Видно верхний край её чулка. Это так сексуально."
	DB	NEXT
	GO BODY_SIZUKA
BODY_SIZUKA:
	DB	"Сидзука: Как ты думаешь, куда это ты только что смотрел?"
	DB	NEXT
	DB	"Кэндзиро: Э? О, никуда..."
	DB	NEXT
	DB	"Сидзука: Ты ещё юн, так что, полагаю, с этим ничего не поделаешь."
	DB	NEXT
	DB	"Кэндзиро: П-простите!"
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Нет женщины сексуальнее, чем Сидзука-сэнсэй."
	DB	NEXT
	GO	SENTAKU1
HOKEN:
	FLG_KI HOK,'=',7
	SINARIO 'ER.OVL'
HOKEN2:
	FLG_KI HOK,'=',7
	SINARIO 'ER2.OVL'
AB8:
	FLG_IF	TEMP01,'>=',3,KYOUSITU
	FLG_KI	TEMP01,'+',1
	FLG_KI TEMP09,'=',1
	DB	"Интересно, Тиэ сегодня убирается?"
	DB	NEXT
	DB	"Пожалуй, схожу посмотрю."
	DB	NEXT
	BAK_INIT	'tb_014',B_NORM
	T_CG	'tt_13_14',CHI2,0
	DB	"Тиэ: А, Кэндзиро-сэмпай..."
	DB	NEXT
	DB	"Кэндзиро: Ты сегодня опять убираешься?"
	DB	NEXT
	DB	"Тиэ: А, эм, ну... Да.."
	DB	NEXT
	DB	"Она опять в купальнике. Я так рад!"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AG_4,"СМОТРЕТЬ НА ЛИЦО"
	MENU_SET	AG_5,"СМОТРЕТЬ НА РУКИ"
	MENU_SET	AG_6,"СМОТРЕТЬ НА НОГИ"
	MENU_END
	DB	EXIT
AG_4:
	FLG_IF	YOKU,'>=',100,HOKEN
	FLG_KI	YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,KK_1
	FLG_KI CHIE_NET,'=',1
KK_1:
	DB	"У неё милое, невинное личико, от которого мне почему-то хочется её подразнить..."
	DB	NEXT
	DB	"Тиэ: Эм, у меня что-то на лице?"
	DB	NEXT
	DB	"Кэндзиро: Э? Нет, ничего. Что-то не так?"
	DB	NEXT
	DB	"Тиэ: Э? О, эм, ничего. Ничего."
	DB	NEXT
	GO	HHH
AG_5:
	FLG_IF	YOKU,'>=',100,HOKEN
	FLG_KI	YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,KK_2
	FLG_KI CHIE_NET,'=',1
KK_2:
	DB	"Странно видеть такие роскошные ногти у такой простой девушки."
	DB	NEXT
	DB	"Тиэ: Что-то не так?"
	DB	NEXT
	DB	"Кэндзиро: Например?"
	DB	NEXT
	DB	"Тиэ: ...О, ничего..."
	DB	NEXT
	GO	HHH
AG_6:
	FLG_IF	YOKU,'>=',100,HOKEN
	FLG_KI	YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,KK_3
	FLG_KI CHIE_NET,'=',1
KK_3:
	DB	"Вид её белых мясистых ляжек, выпирающих из-под купальника, заводит меня."
	DB	NEXT
	DB	"Тиэ: Эм, я..."
	DB	NEXT
	DB	"Кажется, она заметила мой взгляд."
	DB	NEXT
	DB	"Кэндзиро: Тебе не холодно?"
	DB	NEXT
	DB	"Тиэ: Что?"
	DB	NEXT
	DB	"Кэндзиро: В смысле, ты же почти не одета..."
	DB	NEXT
	DB	"Тиэ: О... Я, эм, привыкла."
	DB	NEXT
	DB	"Кэндзиро: Серьёзно? Но смотри, не простудись.."
	DB	NEXT
	DB	"После этого Тиэ, кажется, немного расслабилась и перестала отходить от меня."
	DB	NEXT
	DB	"Тиэ: Эм..."
	DB	NEXT
	DB	"Кэндзиро: Да?"
	DB	NEXT
	DB	"Тиэ: Н-ничего."
	DB	NEXT
HHH:
	DB	"Кэндзиро: Ну, я пошёл."
	DB	NEXT
	DB	"Тиэ: Ладно."
	DB	NEXT
	DB	"Кэндзиро: Знаешь, если не будешь высказывать другим своё мнение, то тебе всегда будет доставаться "
        DB      "самая тяжёлая работа, вроде уборки за другими девушками."
	DB	NEXT
	DB	"Тиэ: ................"
	DB	NEXT
	DB	"Тиэ ничего не говорит."
	DB	NEXT
	DB	"Кэндзиро: Ну, пока."
	DB	NEXT
	DB	"Я выхожу из раздевалки."
	DB	NEXT
	GO	SENTAKU1
KYOUSITU:
	FLG_KI HOK,'=',0
	FLG_IF	MOTDOYOU,'=',1,DOYOUBI
	BAK_INIT	'tb_034b',B_NORM
	DB	"Ой, смотрите, как поздно."
	DB	NEXT
	BAK_INIT 'tb_011b',B_NORM
	DB	"Пожалуй, буду собираться домой."
	DB	NEXT
	B_O	B_FADE,C_KURO
	SINARIO 'JUMP.OVL'
	DB	EXIT
DOYOUBI:
	FLG_KI MOTDOYOU,'=',0
	BAK_INIT	'tb_034a',B_NORM
	DB	"Пожалуй, вернусь в свой класс."
	DB	NEXT
	BAK_INIT	'tb_011a',B_NORM
	DB	"На улице ещё светло, но я, пожалуй, пойду домой."
	DB	NEXT
	B_O	B_FADE,C_KURO
	SINARIO 'JUMP.OVL'
	DB	EXIT
END