        include SUPER_C.inc
M_START:
NITI_HOK
	FLG_IF HOK,'=',7,KYOUSITU
	FLG_IF HAND,'=',6,TOIRE
	F_O	B_NORM,C_KURO
	DB "Голос:  Эй! Проснись!"
	DB	NEXT
	DB "Кенджиру:  .....Мм?"
	DB	NEXT
	BAK_INIT	'tb_011a',B_NORM
	CDPLAY	14
	DB "Тецуя:    Ты уже проснулся." 
	DB	NEXT
	DB "Я поднял голову и посмотрел на своего друга."
	DB	NEXT
	T_CG	'tt_08_11a',TET_A2,0
	DB "Тецуя:    Пора уже вставать!" 
	DB	NEXT
	DB "Кенджиру:  Прости."
	DB	NEXT
	DB "Тецуя:    Ну, я пошел домой."
	DB	NEXT
	TATI_ERS
	DB "Кенджиру:  Спасибо"
	DB	NEXT
	DB "Кенджиру:  Я, наверно, немного прогуляюсь."
	DB	NEXT
	DB "Я пошел в коридор."
	DB	NEXT
	BAK_INIT	'tb_034a',B_NORM
	DB "Пожалуй, поищу красивых девушек."
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
	DB "Куда мне пойти?"
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
	MENU_SET	AB1,"МУЗЫК.КОМН"
	MENU_SET	AB2,"НАЗАД В КЛАСС"
	MENU_SET	AB3,"КЛАСС МОТОКИ"
	MENU_SET	AB4,"СКЛАД"
	MENU_SET	AB5,"КОМ.АРТА"
	MENU_SET	AB6,"МУЖ.КОМНАТ"
	MENU_SET	AB7,"ОФФИС НУРСА"
	MENU_SET	AB8,"КОМНАТА СМЕНЫ"
	MENU_END
	DB	EXIT
AB1:
	FLG_IF	TEMP01,'>=',3,KYOUSITU
	FLG_KI	TEMP01,'+',1
	FLG_KI	TEMP02,'=',1
	DB "Наверно, я пойду в концертный зал. Интересно, Шихо там?"
	DB	NEXT
	BAK_INIT	'tb_016',B_NORM
	CDPLAY	10
	T_CG	'tt_02_16',SIH_A3,0
	FLG_KI	SIH_KAIS,'+',1
	DB "Шино здесь."
	DB	NEXT
	DB "Шихо:   А, Кенджиру-кун."
	DB	T_WAIT,	3
	DB " Ты пришел послушать мою игру?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AC1,"ОСМОТР ЛИЦА"
	MENU_SET	AC2,"ОСМОТР СИСЕК"
	MENU_SET	AC3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
AC1:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "У Шихо такое красивое лицо.Почти совершенное."
	DB	NEXT
	GO	SIHO
AC2:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "Ее форма мешает разглядеть ее грудь, но она великолепна."
	DB	NEXT
	GO	SIHO
AC3:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "классные бедра. Белые и не слишком мускулистые."
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
	DB "Надо остановиться. Я не буду пачкать этот цветок."
	DB	NEXT
	DB "Шихо:   Что с тобой?"
	DB	NEXT
	DB "Кенджиру:  А? Ох, ничего."
	DB	NEXT
	DB "Шихо:   Вижу..."
	DB	NEXT
	DB "Кенджиру:  Ты будешь сегодня играть?"
	DB	NEXT
	DB "Шихо:   Прости... Мне сегодня надо рано идти домой." 
	DB	NEXT
	DB "Кенджиру:  Да ладно."
	DB	NEXT
	DB "Шихо:   Прости" 
	DB	NEXT
	DB "Кенджиру:  Хорошо."
	DB	NEXT
	DB "Шихо:   Ну, позже увидимся."
	DB	NEXT
	DB "Кенджиру:  Увидимся."
	DB	NEXT
	TATI_ERS
	DB "Шихо ушла из музыкальной."
	DB	NEXT
	DB "Наверно, я пойду."
	DB	NEXT
	GO	SENTAKU1
AB2:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP03,'=',1
	DB "Я пойду в свою комнату."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	DB "Здесь нет никого."
	DB	NEXT
	DB "Кенджиру:  Интересно, куда все пошли."
	DB	NEXT
	DB "Я иду в переднюю."
	DB	NEXT
	GO	SENTAKU1
AB3:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP04,'=',1
	DB "Пожалуй, зайду к Мотоке."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	DB "Здесь нет никого. Наверное, она рано пошла домой."
	DB	NEXT
	GO	SENTAKU1
AB4:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP05,'=',1
	DB "Надо заглянуть в чулан."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB "Никого нет."
	DB	NEXT
	DB "Наверное, вернусь."
	DB	NEXT
	GO	SENTAKU1
AB5:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP06,'=',1
	DB "Пойду поищу свою красотку в мастерской."
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
	MENU_SET	AD1,"ОСМОТР СИСЕК"
	MENU_SET	AD2,"ОСМОТР ПОПЫ"
	MENU_SET	AD3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
AD1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_7
	FLG_KI MIKA_NET,'=',1
WW_7:
	DB "Ее руки мешают рассмотреть ее грудь, но она отлично выглядит."
	DB	NEXT
	GO BODY_MIKA
AD2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_8
	FLG_KI MIKA_NET,'=',1
WW_8:
	DB "Отличная задница, не могу забыть последний раз, когда я ее трогал."
	DB	NEXT
	GO BODY_MIKA
AD3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_9
	FLG_KI MIKA_NET,'=',1
WW_9:
	DB "Классные бедра. Очень мягкие и нежные."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB "Мика:  Следи, куда смотришь." 
	DB	NEXT
	DB "Кенджиру:  Что? Я никуда не смотрел..."
	DB	NEXT
	DB "Мика:  Да ладно, забудь."
	DB	NEXT
	DB "Мика:  Я рада, что ты пришел вовремя."
	DB	NEXT
	DB "Кенджиру:  А?"
	DB	NEXT
	DB "Мика:  Не говори мне, что забыл!" 
	DB	NEXT
	DB "Ну вот! Я уже забыл!"
	DB	NEXT
	DB "Кенджиру:  Встретимся завтра, учительница..."
	DB	NEXT
	DB "Мика:  Вернись, Кондо-кан!" 
	DB	NEXT
	DB "Я спешно покидаю кабинет."
	DB	NEXT
	GO	SENTAKU1
AB6:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP07,'=',1
	DB "Я иду в мужскую уборную."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	DB "Второе место позади моего офиса. Оно как всегда свободно."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AE1,"В ОФФИС"
	MENU_SET	AE2,"НЕ ВОЛНУЙСЯ"
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
	MENU_SET	AF1,"АКЕМИ КОНДО"
	MENU_SET	AF2,"ТЕРУМИ КИНОУШИ"
	MENU_SET	AF3,"МИКА МАЕДА"
	MENU_SET	AF4,"РЕНА ВАТАНАБЕ"
	MENU_SET	AF5,"НАНА ХИРОС"
	MENU_SET	AF6,"ШИЗУКА ХАСЕГАВА"
	MENU_SET	AF7,"ШИЕ УТСУМИ"
	MENU_SET	AF8,"НЕ НУЖНО"
	MENU_END
	DB	EXIT
AF1:
	DB "Сделаем это с Акеми-сан."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'AK_H.OVL'
AF2:
	DB "Ммм, Теруми-сенпай тоже неплоха."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'TE_H.OVL'
AF3:
	DB "Я не против съездить с Микой."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'MI_H.OVL'
AF4:
	DB "Я хочу вспомнить все события весеннего отдыха..."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'RE_H.OVL'
AF5:
	DB "Хорошо бы сорвать с нее эту форму..."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'NA_H.OVL'
AF6:
	DB "Шизука будет хорошим партнером..."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'SI_H.OVL'
AF7:
	DB "Мне нравится видеть Чи в купальнике."
	DB	NEXT
	FLG_KI HAND,'=',6
	SINARIO 'CH_H.OVL'
AF8:
AE2:
DERU:
	DB "Наверное, я выйду."
	DB	NEXT
	GO SENTAKU1
TOIRE:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB "Отойдя после оргазма, я стою перед зеркалом в ванной комнате."
	DB	NEXT
	DB "Кенджиру:  Это было классно."
	DB	NEXT
	DB "Я помыл руки и ушел."
	DB	NEXT
	GO	SENTAKU1
AB7:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB "Наверно, я зайду к Шизуке."
	DB	NEXT
	EVENT_CG	'th_072',B_NORM,35
	DB "Шизука:   Что случилось?"
	DB	NEXT
	DB "Кенджиру:  Пусто"
	DB	NEXT
	DB "Шизука:   Тогда почему ты здесь?"
	DB	NEXT
	DB "Кенджиру:  Хотел тебя видеть."
	DB	NEXT
	DB "Шизука:   Я так рада."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AG_1,"ОСМОТР ЛИЦА"
	MENU_SET	AG_2,"ОСМОТР РУК"
	MENU_SET	AG_3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
AG_1:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_10
	FLG_KI SIZU_NET,'=',1
WW_10:
	DB "У нее красивое личико."
	DB	NEXT
	GO BODY_SIZUKA
AG_2:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_11
	FLG_KI SIZU_NET,'=',1
WW_11:
	DB "Я хочу, чтобы ее красные ногти двигались вверх и вниз по моему члену."
	DB	NEXT
	GO BODY_SIZUKA
AG_3:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_12
	FLG_KI SIZU_NET,'=',1
WW_12:
	DB "Видно вверх ее чулка. Это так сексуально."
	DB	NEXT
	GO BODY_SIZUKA
BODY_SIZUKA:
	DB "Шизука:   Как ты думаешь, куда смотришь ты?"
	DB	NEXT
	DB "Кенджиру:  Э? O, никуда..."
	DB	NEXT
	DB "Шизука:  Ты еще молодой, поэтому с этим ничего не поделаешь, как мне кажется."
	DB	NEXT
	DB "Кенджиру:  Прости!"
	DB	NEXT
	F_O B_NORM,C_KURO
	DB "Нет женщины горячее, чем Шизука-сенсей."
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
	DB "Интересно, Чи моется сегодня?"
	DB	NEXT
	DB "Пойду посмотрю."
	DB	NEXT
	BAK_INIT	'tb_014',B_NORM
	T_CG	'tt_13_14',CHI2,0
	DB "Чи:   Ах, глава Кинджиру..."
	DB	NEXT
	DB "Кенджиру:  Ты сегодня тоже моешься?"
	DB	NEXT
	DB "Чи:    A, мм, ну... Да."
	DB	NEXT
	DB "Она опять в купальнике. Я так рад!"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AG_4,"ОСМОТР ЛИЦА"
	MENU_SET	AG_5,"ОСМОТР РУК"
	MENU_SET	AG_6,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
AG_4:
	FLG_IF	YOKU,'>=',100,HOKEN
	FLG_KI	YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,KK_1
	FLG_KI CHIE_NET,'=',1
KK_1:
	DB "У нее красивое, невинное личико, надо поприставать к ней..."
	DB	NEXT
	DB "Чи:  У меня что-нибудь есть на лице?"
	DB	NEXT
	DB "Кенджиру:  Что? Ничего нет. Что-то не так?"
	DB	NEXT
	DB "Кенджиру:  Что? Нет, ничего."
	DB	NEXT
	GO	HHH
AG_5:
	FLG_IF	YOKU,'>=',100,HOKEN
	FLG_KI	YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,KK_2
	FLG_KI CHIE_NET,'=',1
KK_2:
	DB "Странно видеть великолепные ногти на почти обнаженной девушке."
	DB	NEXT
	DB "Чи:  Что-то не так?"
	DB	NEXT
	DB "Кенджиру:  Например?"
	DB	NEXT
	DB "Чи:    ...Ничего..."
	DB	NEXT
	GO	HHH
AG_6:
	FLG_IF	YOKU,'>=',100,HOKEN
	FLG_KI	YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,KK_3
	FLG_KI CHIE_NET,'=',1
KK_3:
	DB "Я возбуждаюсь, когда вижу ее белые сочные бедра под купальником."
	DB	NEXT
	DB "Чи:    Э, я..."
	DB	NEXT
	DB "Похоже, она увидела мой взгляд."
	DB	NEXT
	DB "Кенджиру: Тебе не холодно?"
	DB	NEXT
	DB "Чи:    Чего?"
	DB	NEXT
	DB "Кенджиру:   Я имею ввиду, ты легко одета..."
	DB	NEXT
	DB "Чи:    Oо... Я привыкла."
	DB	NEXT
	DB "Кенджиру:  Серьозно? Все же смотри не простудись."
	DB	NEXT
	DB "После этого Чи немного расслабилась и уже не отходила от меня."
	DB	NEXT
	DB "Чи:    Мм..."
	DB	NEXT
	DB "Кенджиру:  Да?"
	DB	NEXT
	DB "Чи:    Это мелочь."
	DB	NEXT
HHH:
	DB "Кенджиру:  Ну, Я уже пойду."
	DB	NEXT
	DB "Чи:    Окей."
	DB	NEXT
	DB "Кенджиру:  Знаешь, если не высказывать людям свое мнение, всегда будешь выполнять плохую работу, "
        DB "например убирать за другими девушками."
	DB	NEXT
	DB "Чи:    .............."
	DB	NEXT
	DB "Чи молчит."
	DB	NEXT
	DB "Кенджиру:  Ну, пока."
	DB	NEXT
	DB "Я вышел из комнаты."
	DB	NEXT
	GO	SENTAKU1
KYOUSITU:
	FLG_KI HOK,'=',0
	FLG_IF	MOTDOYOU,'=',1,DOYOUBI
	BAK_INIT	'tb_034b',B_NORM
	DB "Ой, смотри как поздно."
	DB	NEXT
	BAK_INIT 'tb_011b',B_NORM
	DB "Думаю, надо собираться домой."
	DB	NEXT
	B_O	B_FADE,C_KURO
	SINARIO 'JUMP.OVL'
	DB	EXIT
DOYOUBI:
	FLG_KI MOTDOYOU,'=',0
	BAK_INIT	'tb_034a',B_NORM
	DB "Наверно, я вернусь в аудиторию."
	DB	NEXT
	BAK_INIT	'tb_011a',B_NORM
	DB "На улице еще светло, но я уже пойду домой."
	DB	NEXT
	B_O	B_FADE,C_KURO
	SINARIO 'JUMP.OVL'
	DB	EXIT
END
