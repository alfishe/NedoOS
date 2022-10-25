        include SUPER_C.inc
M_START:
BUNKI_1
	FLG_IF HAND,'=',1,TOIRE
	FLG_IF HOK,'=',1,KYOUSITU
	FLG_IF JUMP,'=',51,FF_52
	FLG_IF JUMP,'=',50,FF_51
	FLG_IF JUMP,'=',49,FF_50
	FLG_IF JUMP,'=',48,FF_49
	FLG_IF JUMP,'=',47,FF_48
	FLG_IF JUMP,'=',46,FF_47
	FLG_IF JUMP,'=',45,FF_46
	FLG_IF JUMP,'=',44,FF_45
	FLG_IF JUMP,'=',43,FF_44
	FLG_IF JUMP,'=',42,FF_43
	FLG_IF JUMP,'=',41,FF_42
	FLG_IF JUMP,'=',40,FF_41
	FLG_IF JUMP,'=',39,FF_40
	FLG_IF JUMP,'=',38,FF_39
	FLG_IF JUMP,'=',37,FF_38
	FLG_IF JUMP,'=',36,FF_37
	FLG_IF JUMP,'=',35,FF_36
	FLG_IF JUMP,'=',34,FF_35
	FLG_IF JUMP,'=',33,FF_34
	FLG_IF JUMP,'=',32,FF_33
	FLG_IF JUMP,'=',31,FF_32
	FLG_IF JUMP,'=',30,FF_31
	FLG_IF JUMP,'=',29,FF_30
	FLG_IF JUMP,'=',28,FF_29
	FLG_IF JUMP,'=',27,FF_28
	FLG_IF JUMP,'=',26,FF_27
	FLG_IF JUMP,'=',25,FF_26
	FLG_IF JUMP,'=',24,FF_25
	FLG_IF JUMP,'=',23,FF_23
	FLG_IF JUMP,'=',22,FF_22
	FLG_IF JUMP,'=',21,FF_21
	FLG_IF JUMP,'=',20,FF_20
	FLG_IF JUMP,'=',19,FF_19
	FLG_IF JUMP,'=',18,FF_18
	FLG_IF JUMP,'=',17,FF_17
	FLG_IF JUMP,'=',16,FF_16
	FLG_IF JUMP,'=',15,FF_15
	FLG_IF JUMP,'=',14,FF_14
	FLG_IF JUMP,'=',13,FF_13
	FLG_IF JUMP,'=',12,FF_12
	FLG_IF JUMP,'=',11,FF_11
	FLG_IF JUMP,'=',10,FF_10
	FLG_IF JUMP,'=',9,FF_9
	FLG_IF JUMP,'=',8,FF_8
	FLG_IF JUMP,'=',7,FF_7
	FLG_IF JUMP,'=',6,FF_6
	FLG_IF JUMP,'=',5,FF_5
	FLG_IF JUMP,'=',4,FF_4
	FLG_IF JUMP,'=',3,FF_3
	FLG_IF JUMP,'=',2,FF_2
	FLG_IF JUMP,'=',1,FF_1
FF_1:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',2
	SINARIO 'NITI_MAT.OVL'
FF_2:
	FLG_KI	KURI,'=',0
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,JUGO
	FLG_KI JUMP,'=',3
	SINARIO 'NITI_KIT.OVL'
FF_3:
JUGO:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',4
	SINARIO 'NITI_ASA.OVL'
FF_4:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',5
	SINARIO 'NITI_HIR.OVL'
FF_5:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',6
	SINARIO 'NITI_HOK.OVL'
FF_6:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',7
	SINARIO 'NITI_MAT.OVL'
FF_7:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,TUGI_1
	FLG_KI JUMP,'=',8
	SINARIO 'NITI_KIT.OVL'
FF_8:
TUGI_1:
	FLG_KI JUMP,'=',0
	FLG_KI	KURI,'+',1
	FLG_IF	KURI,'>=',3,DD_1
	GO JUGO
DD_1:
	FLG_KI KURI,'=',0
	FLG_KI JUMP,'=',9
	SINARIO 'NITI_ASA.OVL'
FF_9:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',10
	FLG_KI MOTDOYOU,'=',1
	SINARIO 'NITI_HOK.OVL'
FF_10:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',11
	FLG_KI MOTDOYOU,'=',2
	SINARIO 'NITI_MAT.OVL'
FF_11:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,TUGI_2
	FLG_KI JUMP,'=',12
	GO FF_12
FF_12:
TUGI_2:
	FLG_KI HANAJI,'=',0
	FLG_KI JUMP,'=',0
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB "Кэндзиро: ........"
	DB	T_WAIT,	3
	DB "Пожалуй, пора вставать."
	DB	NEXT
	DB "Я смотрю на часы. На них начало первого."
	DB	NEXT
	DB "Кэндзиро: Ух ты, хорошо поспал..."
	DB	NEXT
	DB "Кэндзиро: Но сегодня воскресенье, так что, пожалуй, ещё посплю."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_FADE
	CDPLAY		12
	DB "Уже почти время ужина."
	DB	NEXT
	DB "Пожалуй, поиграю в видеоигры, пока ужин не готов."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB "Завтра понедельник. Перед понедельником нужно хорошо отдохнуть, так что, пожалуй, теперь я ещё посплю."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,DEF_1
	FLG_KI	ONANI,'=',0
DEF_1:
NIJU:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',13
	SINARIO 'NITI_ASA.OVL'
FF_13:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',14
	SINARIO 'NITI_HIR.OVL'
FF_14:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',15
	SINARIO 'NITI_HOK.OVL'
FF_15:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',16
	SINARIO 'NITI_MAT.OVL'
FF_16:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,TUGI_3
	FLG_KI JUMP,'=',17
	SINARIO 'NITI_KIT.OVL'
FF_17:
TUGI_3:
	FLG_KI JUMP,'=',0
	FLG_KI	KURI,'+',1
	FLG_IF	KURI,'>=',5,DD_2
	GO NIJU
DD_2:
	FLG_KI	KURI,'=',0
	FLG_KI JUMP,'=',18
	SINARIO 'NITI_ASA.OVL'
FF_18:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',19
	FLG_KI MOTDOYOU,'=',1
	SINARIO 'NITI_HOK.OVL'
FF_19:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',20
	FLG_KI MOTDOYOU,'=',2
	SINARIO 'NITI_MAT.OVL'
FF_20:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,NIGO
	FLG_KI JUMP,'=',21
	GO FF_21
FF_21:
NIGO:
	FLG_KI HANAJI,'=',0
	FLG_KI JUMP,'=',0
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB "Кэндзиро: ........"
	DB	T_WAIT,	3
	DB "Пожалуй, пора вставать."
	DB	NEXT
	DB "Я смотрю на часы. На них было начало первого."
	DB	NEXT
	DB "Хорошо поспал..."
	DB	NEXT
	DB "Но сегодня воскресенье, так что, пожалуй, посплю ещё."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_FADE
	DB "Уже почти время ужина."
	DB	NEXT
	DB "Пожалуй, поиграю в видеоигры, пока ужин не готов."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB "Завтра понедельник. Теперь мне лучше хорошо выспаться."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,DEF_2
	FLG_KI	ONANI,'=',0
DEF_2:
NIJU_1:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',22
	SINARIO 'NITI_ASA.OVL'
FF_22:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',23
	SINARIO 'NITI_HIR.OVL'
FF_23:
	FLG_KI JUMP,'=',0
	FLG_IF KURI,'=',1,ZZ_1
	F_O	B_NORM,C_KURO
	DB "Голос: Эй! Проснись уже!"
	DB	NEXT
	DB "Кэндзиро: .......Ии?"
	DB	NEXT
	BAK_INIT	'tb_011a',B_NORM
	CDPLAY	14
	DB "Тэцуя: Проснулся наконец." 
	DB	NEXT
	DB "Я поднял голову и увидел Тэцую, стоящего передо мной. Почему-то он показался мне глупее обычного."
	DB	NEXT
	T_CG	'tt_08_11a',TET_A2,0
	DB "Тэцуя: Вставай уже. Уроки уже кончились."
	DB	NEXT
	DB "Кэндзиро: Ох, да."
	DB	NEXT
	DB "Тэцуя: Ну, я домой."
	DB	NEXT
	TATI_ERS
	DB "Кэндзиро: Спасибо."
	DB	NEXT
	DB "Ну, может, мне встать..."
	DB	NEXT
	DB "Я выхожу в коридор."
	DB	NEXT
	BAK_INIT	'tb_034a',B_NORM
	DB "*** БУУМ!! ***"
	DB	NEXT
	DB	GATA,	2
	DB "Кэндзиро: Ч-что это было?"
	DB	NEXT
	DB "Этот звук раздавался со стороны спортзала."
	DB	NEXT
	FLG_KI	W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	IKU,"ПОЙТИ ТУДА"
	MENU_SET	IKANAI,"НЕ ЗАМОРАЧИВАТЬСЯ"
	MENU_END
	DB	EXIT
IKU:
	DB "Я в коридоре, неподалёку от спортзала."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB "Уверен, что звук раздавался отсюда."
	DB	NEXT
	DB "Голос: Ч-что?!"
	DB	NEXT
	DB "Я слышу девичий голос, а потом громкий звук удара, доносящийся из женской раздевалки бассейна."
	DB	NEXT
	DB "Хмм... Думаю, надо посмотреть."
	DB	NEXT
	DB "Но постойте? Что, если кто-то меня застукает? "
	DB	NEXT
	DB "Хмм, нужно просто убедиться, что никого нет, и всё."
	DB	NEXT
	DB "Убедившись, я медленно толкаю приоткрытую дверь."
	DB	NEXT
	DB "Кэндзиро: Уаа!"
	DB	NEXT
	DB	GATA,	1
	DB "Я поскальзываюсь и по инерции влетаю через дверь в раздевалку."
	DB	NEXT
	DB "Голос: Ийя!!"
	DB	NEXT
	BAK_INIT	'tb_014',B_NORM
	T_CG	'tt_13_14',CHI2,0
	DB "Кэндзиро: А..."
	DB	NEXT
	DB "Прямо перед собой я вижу девушку в купальнике."
	DB	NEXT
	DB "Кэндзиро: Э, эм, я..."
	DB	NEXT
	DB "Девушка: Эм, простите? Что случилось?"
	DB	NEXT
	DB "Кэндзиро: Ну, я услышал звук удара и хотел узнать, что это было. Вот почему я зашёл сюда. Всё в порядке?"
	DB	NEXT
	DB "Девушка: Ну... "
	DB	T_WAIT,	3
	DB " Извините. Я ударилась об один из шкафчиков."
	DB	NEXT
	DB "Кэндзиро: Как такое вышло?"
	DB	NEXT
	DB "Девушка: Ну... Девочки попросили меня убраться в раздевалке, и..."
	DB	NEXT
	DB "Кэндзиро: Они попросили тебя убрать здесь всё самой?"
	DB	NEXT
	DB "Девушка: Да."
	DB	NEXT
	DB "Кэндзиро: Ты, наверное, из первого класса. Где остальные девушки?"
	DB	NEXT
	DB "Девушка: ...Ушли домой."
	DB	NEXT
	DB "А, теперь понятно. Они попросили самую младшую в команде сделать то, чего им самим не хотелось..."
	DB	NEXT
	DB "Кэндзиро: Эм, как тебя зовут?"
	DB	NEXT
	DB "Девушка: Эм, прошу прощения..."
	DB	T_WAIT,	3
	DB " Меня зовут Тиэ Уцуми."
	DB	NEXT
	DB "Бедняжка... Надо ей помочь."
	DB	NEXT
	DB "Кэндзиро: Я позабочусь об этом."
	DB	NEXT
	DB "Тиэ: Ч-что вы хотите сказать?"
	DB	NEXT
	DB "Кэндзиро: Я скажу учителю, что другие девушки заставляют тебя работать за них."
	DB	NEXT
	DB "Тиэ: Н-нет! Пожалуйста, не надо!"
	DB	NEXT
	DB "Кэндзиро: Что?"
	DB	NEXT
	DB "Тиэ: Если вы скажете учителю, я..."
	DB	T_WAIT,	6
	DB " Я..."
	DB	NEXT
	DB "Кэндзиро: Но это неправильно, они заставляют тебя делать их работу."
	DB	NEXT
	DB "Тиэ: В-всё нормально! Мне нравится убираться, и это вовсе не проблема!"
	DB	NEXT
	DB "Кэндзиро: Ты уверена?"
	DB	NEXT
	DB "Тиэ не спеша кивает."
	DB	NEXT
	DB "Кэндзиро: Что ж..."
	DB	T_WAIT,	3
	DB " Тогда я, пожалуй, пойду."
	DB	NEXT
	DB "Тиэ: Спасибо."
	DB	NEXT
	DB "Я выхожу из раздевалки."
	DB	NEXT
;	-- Bryan commented out 4/15/02- should eliminate all Chie options
	FLG_KI	CHI_ATTA,'=',1
	GO	PPP
	DB	EXIT
IKANAI:
	DB "Ну, пожалуй, мне там делать нечего."
	DB	NEXT
	GO PPP
ZZ_1:
	FLG_IF CHI_ATTA,'=',0,PPP
	FLG_KI	TEMP09,'=',1
PPP:
	BAK_INIT	'tb_034a',B_NORM
	DB "Кэндзиро: Что ж, пожалуй, поищу себе десерт..."
	DB	NEXT
	FLG_KI	TEMP01,'=',0
	FLG_KI	TEMP02,'=',0
	FLG_KI	TEMP03,'=',0
	FLG_KI	TEMP04,'=',0
	FLG_KI	TEMP05,'=',0
	FLG_KI	TEMP06,'=',0
	FLG_KI	TEMP07,'=',0
	FLG_KI	TEMP08,'=',0
SENTAKU1:
	BAK_INIT 'tb_034a',B_NORM
	CDPLAY	14
	DB "Куда мне теперь пойти?"
	DB	NEXT
	FLG_KI	W,'=',-1
	FLG_IF	SIHO_PIA,'=',1,BUNKI_A
	FLG_KI	W,'DOWN',0
BUNKI_A:
	FLG_IF	SIZ_ATTA,'=',1,BUNKI_B
	FLG_KI	W,'DOWN',6
BUNKI_B:
	FLG_IF	CHI_ATTA,'=',1,BUNKI_C
	FLG_KI	W,'DOWN',7
BUNKI_C:
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
	MENU_S	2,W,-1
	MENU_SET	AB1,"В КАБИНЕТ МУЗЫКИ"
	MENU_SET	AB2,"В КЛАСС"
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
	DB "Может быть, Сихо сегодня играет на рояле."
	DB	NEXT
	BAK_INIT	'tb_016',B_NORM
	CDPLAY	10
	T_CG	'tt_02_16',SIH_A3,0
	FLG_KI	SIH_KAIS,'+',1
	DB "Сихо здесь."
	DB	NEXT
	DB "Сихо: А, Кондо-кун." 
	DB	T_WAIT,	3
	DB " Ты пришёл."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AC1,"СМОТРЕТЬ НА ЛИЦО"
	MENU_SET	AC2,"СМОТРЕТЬ НА ГРУДЬ"
	MENU_SET	AC3,"СМОТРЕТЬ НА НОГИ"
	MENU_END
	DB	EXIT
AC1:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "Сихо здесь. Она в самом деле превосходная девушка."
	DB	NEXT
	GO	SIHO
AC2:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "Её школьная форма не даёт мне увидеть то, что мне хочется, но её грудь кажется близкой к моему идеалу."
	DB	NEXT
	GO	SIHO
AC3:
	FLG_KI	YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "Замечательные ножки. Белые, мягкие и такие привлекательные."
	DB	NEXT
	GO	SIHO
SIHO:
	FLG_KI	AKEM_NET,'=',0
	FLG_KI	MIKA_NET,'=',0
	FLG_KI	TER_NET,'=',0
	FLG_KI	RENA_NET,'=',0
	FLG_KI	NANA_NET,'=',0
	FLG_KI	SIZU_NET,'=',0
	DB "Хмм, с другой стороны, это не для меня. Полагаю, я из тех, кто хочет сохранить непорочную красоту своей возлюбленной."
	DB	NEXT
	DB "Сихо: Что случилось?" 
	DB	NEXT
	DB "Кэндзиро: Э? О, ничего."
	DB	NEXT
	DB "Сихо: О."
	DB	NEXT
	DB "Кэндзиро: Ты не собираешься играть?"
	DB	NEXT
	DB "Сихо: Извини. Сегодня мне нужно идти домой..." 
	DB	NEXT
	DB "Кэндзиро: Ох, ладно, Я приду в следующий раз."
	DB	NEXT
	DB "Сихо: Прости." 
	DB	NEXT
	DB "Кэндзиро: Всё нормально."
	DB	NEXT
	DB "Сихо: Ну, мне пора."
	DB	NEXT
	DB "Кэндзиро: Ладно, счастливо."
	DB	NEXT
	TATI_ERS
	DB "Она выходит из кабинета музыки."
	DB	NEXT
	DB ".....Пожалуй, я тоже пойду."
	DB	NEXT
	GO	BUNKI_K
AB2:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP03,'=',1
	DB "Пожалуй, вернусь в свой класс."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	DB "Тут никого нет."
	DB	NEXT
	DB "Кэндзиро: Интересно, где все..."
	DB	NEXT
	DB "Я возвращаюсь в коридор."
	DB	NEXT
	GO	SENTAKU1
AB3:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP04,'=',1
	DB "Пожалуй, загляну в класс Мотоки."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	DB "Кэндзиро: Тут никого нет. Может быть, она ушла домой."
	DB	NEXT
	GO	SENTAKU1
AB4:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP05,'=',1
	DB "Загляну в подсобку спортзала."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB "Неа, никого."
	DB	NEXT
	DB "Кэндзиро: Пожалуй, пойду назад."
	DB	NEXT
	GO	SENTAKU1
AB5:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP06,'=',1
	DB "На самом деле, мне там делать нечего, но какая разница?"
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	CDPLAY	18
	DB "Мика вытирает пыль со статуй."
	DB	NEXT
	DB "Кэндзиро: Мика-сэнсэй."
	DB	NEXT
	DB "Мика: А, Кондо-кун." 
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
	FLG_KI YOKU,'+',4
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_7
	FLG_KI MIKA_NET,'=',1
WW_7:
	DB "Её руки огибают красивую грудь. Представляю, что бы чувствовал мой член, скользя между двумя её достопримечательностями."
	DB	NEXT
	GO BODY_MIKA
AD2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_8
	FLG_KI MIKA_NET,'=',1
WW_8:
	DB "Замечательная задница, почти идеальная. Я всё ещё не могу забыть ощущения от контакта с ней."
	DB	NEXT
	GO BODY_MIKA
AD3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_9
	FLG_KI MIKA_NET,'=',1
WW_9:
	DB "Красивые ножки, очень упругие."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB "Мика: Ты смотришь, куда не следует?" 
	DB	NEXT
	DB "Кэндзиро: Э? Куда это?"
	DB	NEXT
	DB "Мика: Ох, неважно."
	DB	NEXT
	DB "Мика: В любом случае, я рада, что ты пришёл."
	DB	NEXT
	DB "Кэндзиро: Правда?"
	DB	NEXT
	DB "Мика: ...Ты что, забыл?"
	DB	NEXT
	DB "О нет! Я забыл!"
	DB	NEXT
	DB "Кэндзиро: Я-я сейчас вернусь... Пока!" 
	DB	NEXT
	DB "Мика: Подожди, Кондо-кун!" 
	DB	NEXT
	DB "Я спешно покинул кабинет ИЗО."
	DB	NEXT
	GO	SENTAKU1
AB6:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP07,'=',1
	DB "Я иду в туалет."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	DB "Вторая кабинка с конца -- моя. Это мой личный кабинет. И, к тому же, не занята."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AE1,"ВОЙТИ В КАБИНКУ"
	MENU_SET	AE2,"УЙТИ"
	MENU_END
	DB	EXIT
AE1:
	FLG_IF YOKU,'<',45,DERU
	FLG_IF YOKU,'<',100,SENTAKU2
	FLG_IF AKEM_NET,'=',0,SS_1
	FLG_KI HAND,'=',1
	SINARIO 'AK_H.OVL'
SS_1:
	FLG_IF MIKA_NET,'=',0,SS_2
	FLG_KI HAND,'=',1
	SINARIO 'MI_H.OVL'
SS_2:
	FLG_IF TER_NET,'=',0,SS_3
	FLG_KI HAND,'=',1
	SINARIO 'TE_H.OVL'
SS_3:
	FLG_IF RENA_NET,'=',0,SS_4
	FLG_KI HAND,'=',1
	SINARIO 'RE_H.OVL'
SS_4:
	FLG_IF NANA_NET,'=',0,SS_5
	FLG_KI HAND,'=',1
	SINARIO 'NA_H.OVL'
SS_5:
	FLG_IF SIZU_NET,'=',0,SS_6
	FLG_KI HAND,'=',1
	SINARIO 'SI_H.OVL'
SS_6:
;	-- Bryan commented out 12/26/01
;	-- FLG_IF CHIE_NET,'=',0,SS_7
;	-- FLG_KI HAND,'=',1
;	-- SINARIO 'CH_H.OVL'
SS_7:
SENTAKU2:
	FLG_KI W,'=',-1
	FLG_IF REN_ATTA,'=',1,GG_1
	FLG_KI W,'DOWN',3
GG_1:
	FLG_IF NAN_ATTA,'=',1,GG_2
	FLG_KI W,'DOWN',4
GG_2:
	FLG_IF SIZ_ATTA,'=',1,GG_3
	FLG_KI W,'DOWN',5
GG_3:
	FLG_IF CHI_ATTA,'=',1,GG_4
	FLG_KI W,'DOWN',6
GG_4:
	MENU_S	2,W,-1
	MENU_SET	AF1,"АКЭМИ КОНДО"
	MENU_SET	AF2,"ТТЭРУМИ КИНОУТИ"
	MENU_SET	AF3,"МИКА МАЭДА"
	MENU_SET	AF4,"РЭНА ВАТАНАБЭ"
	MENU_SET	AF5,"НАНА ХИРОСЭ"
	MENU_SET	AF6,"СИДЗУКА ХАСЭГАВА"
	MENU_SET	AF7,"ТИЭ УЦУМИ"
	MENU_SET	AF8,"НЕ ДЕЛАТЬ ЭТО"
	MENU_END
	DB	EXIT
AF1:
	DB "Хмм, сделаем это с Акэми-сан."
	DB	NEXT
	FLG_KI HAND,'=',1
	SINARIO 'AK_H.OVL'
AF2:
	DB "Ммм, Тэруми-сэмпай -- будет здорово."
	DB	NEXT
	FLG_KI HAND,'=',1
	SINARIO 'TE_H.OVL'
AF3:
	DB "Хотел бы я заняться этим с Микой-сэнсэй..."
	DB	NEXT
	FLG_KI HAND,'=',1
	SINARIO 'MI_H.OVL'
AF4:
	DB "Ммм, воспоминания о весенних каникулах..."
	DB	NEXT
	FLG_KI HAND,'=',1
	SINARIO 'RE_H.OVL'
AF5:
	DB "Её огромная грудь, прорывающаяся сквозь форму... Мммм..."
	DB	NEXT
	FLG_KI HAND,'=',1
	SINARIO 'NA_H.OVL'
AF6:
	DB "Сидзука -- это было бы здорово..."
	DB	NEXT
	FLG_KI HAND,'=',1
	SINARIO 'SI_H.OVL'
AF7:
;	-- Bryan commented out 12/26/01
        DB "Хотел бы я сделать это с Тиэ..."
        DB	NEXT
        FLG_KI HAND,'=',1
        SINARIO 'CH_H.OVL'
AF8:
	DB "Хмм, не стоит. Я бы не хотел ослепнуть."
	DB	NEXT
AE2:
DERU:
	DB "Нет причины находиться здесь. Пожалуй, пойду отсюда."
	DB	NEXT
	GO SENTAKU1
TOIRE:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB "Чувствуя себя гораздо лучше, я стою перед зеркалом."
	DB	NEXT
	DB "Кэндзиро: Хмм, здорово."
	DB	NEXT
	DB "Пожалуй, вымою руки."
	DB	NEXT
	DB "Руки чистые, я выхожу в коридор."
	DB	NEXT
	GO	SENTAKU1
AB7:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB "Медицинский кабинет... Интересно, Сиздука-сэнсэй там?"
	DB	NEXT
	EVENT_CG	'th_072',B_NORM,35
	DB "Сидзука: Что случилось на этот раз?"
	DB	NEXT
	DB "Кэндзиро: Ничего."
	DB	NEXT
	DB "Сидзука: Тогда зачем ты здесь?"
	DB	NEXT
	DB "Кэндзиро: Я захотел увидеть вас." 
	DB	NEXT
	DB "Сидзука: Ах, я так рада."
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
	FLG_KI YOKU,'+',4
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_10
	FLG_KI SIZU_NET,'=',1
WW_10:
	DB "Она красавица..."
	DB	NEXT
	GO BODY_SIZUKA
AG_2:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_11
	FLG_KI SIZU_NET,'=',1
WW_11:
	DB "У неё ярко-красные отполированные ногти. Хотел бы я, чтобы эти руки взялись за мой член."
	DB	NEXT
	GO BODY_SIZUKA
AG_3:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_12
	FLG_KI SIZU_NET,'=',1
WW_12:
	DB "Я вижу самый верхний край её чулок. Крайне сексуально."
	DB	NEXT
	GO BODY_SIZUKA
BODY_SIZUKA:
	DB "Сидзука: Так ты что, заболел?"
	DB	NEXT
	DB "Кэндзиро: Э? О, нет, ничего подобного..."
	DB	NEXT
	DB "Сидзука: Ну, ты ещё юн. Пожалуй, я ничего не могу поделать с твоей сексуальной озабоченностью."
	DB	NEXT
	DB "Кэндзиро: П-простите!"
	DB	NEXT
	F_O B_NORM,C_KURO
	DB "Хмм... Она меня прямо насквозь видит, не так ли?"
	DB	NEXT
	GO	SENTAKU1
HOKEN:
	FLG_KI HOK,'=',1
	SINARIO 'ER.OVL'
HOKEN2:
	FLG_KI HOK,'=',1
	SINARIO 'ER2.OVL'
AB8:
	DB "Я только что там был. На сегодня достаточно."
	DB	NEXT
	FLG_KI TEMP01,'+',1
	FLG_KI	TEMP09,'=',1
	GO	SENTAKU1
KYOUSITU:
	FLG_KI HOK,'=',0
	FLG_IF	MOTDOYOU,'=',1,DOYOUBI
	BAK_INIT 'tb_034b',B_NORM
	DB "Пожалуй, вернусь в свой класс."
	DB	NEXT
	BAK_INIT 'tb_011b',B_NORM
	DB "Думаю, пора собираться домой."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO FF_24
	DB	EXIT
DOYOUBI:
	BAK_INIT	'tb_034a',B_NORM
	DB "Пожалуй, вернусь в класс."
	DB	NEXT
	BAK_INIT	'tb_011a',B_NORM
	DB "На улице ещё светло, но, думаю, я пойду домой."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO FF_24
	DB	EXIT
FF_24:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',24
	SINARIO 'NITI_MAT.OVL'
FF_25:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,TUGI_4
	FLG_KI JUMP,'=',25
	SINARIO 'NITI_KIT.OVL'
FF_26:
TUGI_4:
	FLG_KI JUMP,'=',0
	FLG_KI	KURI,'+',1
	FLG_IF	KURI,'>=',2,GG_10
	GO NIJU_1
GG_10:
	FLG_KI KURI,'=',0
	FLG_KI JUMP,'=',26
	SINARIO 'MON_38.OVL'
FF_27:
NIJU_2:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',27
	SINARIO 'NITI_ASA.OVL'
FF_28:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',28
	SINARIO 'NITI_HIR.OVL'
FF_29:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',29
	SINARIO 'NITI_HOK.OVL'
FF_30:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',30
	SINARIO 'NITI_MAT.OVL'
FF_31:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,TUGI_5
	FLG_KI JUMP,'=',31
	SINARIO 'NITI_KIT.OVL'
FF_32:
TUGI_5:
	FLG_KI JUMP,'=',0
	FLG_KI	KURI,'+',1
	FLG_IF	KURI,'>=',2,TT_1
	GO NIJU_2
TT_1:
	FLG_KI KURI,'=',0
	FLG_KI JUMP,'=',32
	SINARIO 'NITI_ASA.OVL'
FF_33:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',33
	FLG_KI MOTDOYOU,'=',1
	SINARIO 'NITI_HOK.OVL'
FF_34:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',34
	FLG_KI MOTDOYOU,'=',2
	SINARIO 'NITI_MAT.OVL'
FF_35:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,GONI
	FLG_KI JUMP,'=',35
	GO FF_36
FF_36:
GONI:
	FLG_KI HANAJI,'=',0
	FLG_KI JUMP,'=',0
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB "Кэндзиро: ............"
	DB	T_WAIT,	3
	DB "Пора вставать."
	DB	NEXT
	DB "Я смотрю на часы. Начало первого."
	DB	NEXT
	DB "Кэндзиро: Ух ты, долго же я спал..."
	DB	NEXT
	DB "Ну, сегодня воскресенье, а в этот день можно поспать."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_FADE
	DB "Ух ты, уже почти пора ужинать..."
	DB	NEXT
	DB "Пожалуй, поиграю."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB "Кэндзиро: Завтра понедельник. Сейчас лучше выспаться, пока есть возможность."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,DEF_3
	FLG_KI	ONANI,'=',0
DEF_3:
	F_O	B_NORM,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,DEF_4
	FLG_KI	ONANI,'=',0
DEF_4:
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB "Завтра в школу. Отстой."
	DB	NEXT
	DB "Ох ладно. По крайней мере, увижу всех своих подружек."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
GORO:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',36
	SINARIO 'NITI_ASA.OVL'
FF_37:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',37
	SINARIO 'NITI_HIR.OVL'
FF_38:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',38
	SINARIO 'NITI_HOK.OVL'
FF_39:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',39
	SINARIO 'NITI_MAT.OVL'
FF_40:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,TUGI_6
	FLG_KI JUMP,'=',40
	SINARIO 'NITI_KIT.OVL'
FF_41:
TUGI_6:
	FLG_KI JUMP,'=',0
	FLG_KI	KURI,'+',1
	FLG_IF	KURI,'>=',3,NN_1
	GO GORO
NN_1:
	FLG_KI KURI,'=',0
	FLG_KI JUMP,'=',41
	SINARIO 'NITI_ASA.OVL'
FF_42:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',42
	FLG_KI MOTDOYOU,'=',1
	SINARIO 'NITI_HOK.OVL'
FF_43:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',43
	FLG_KI MOTDOYOU,'=',2
	SINARIO 'NITI_MAT.OVL'
FF_44:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,GOKU
	FLG_KI JUMP,'=',44
	GO FF_45
FF_45:
GOKU:
	FLG_KI HANAJI,'=',0
	FLG_KI JUMP,'=',0
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB "Кэндзиро: ............"
	DB	T_WAIT,	3
	DB "Пожалуй, пора вставать."
	DB	NEXT
	DB "Часы показывают начало первого."
	DB	NEXT
	DB "Кэндзиро: Ух ты, я переспал..."
	DB	NEXT
	DB "Ну, сегодня воскресенье, а в этот день можно поспать..."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_FADE
	DB "Ух ты, уже почти время ужина..."
	DB	NEXT
	DB "Сыграть во что-нибудь что ли."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB "Завтра понедельник, так что сейчас лучше выспаться, пока есть возможность.."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,DEF_6
	FLG_KI	ONANI,'=',0
DEF_6:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',45
	SINARIO 'NITI_ASA.OVL'
FF_46:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',46
	SINARIO 'NITI_HIR.OVL'
FF_47:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',47
	SINARIO 'NITI_HOK.OVL'
FF_48:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',48
	SINARIO 'NITI_MAT.OVL'
FF_49:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,TUGI_7
	FLG_KI JUMP,'=',49
	SINARIO 'NITI_KIT.OVL'
FF_50:
TUGI_7:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',50
	SINARIO 'NITI_ASA.OVL'
FF_51:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',51
	SINARIO 'NITI_HIR.OVL'
FF_52:
	FLG_KI JUMP,'=',0
	F_O	B_NORM,C_KURO
	DB "Пожалуй, пора вставать."
	DB	NEXT
	DB "Я медленно открываю глаза, и вижу только лицо Сихо, глядящей на меня."
	DB	NEXT
	BAK_INIT	'tb_010',B_FADE
	CDPLAY		14
	T_CG	'tt_02_10',SIH_A2,0
	DB "Сихо: Кэндзиро-кун, могу я с тобой поговорить?"
	DB	NEXT
	DB "Кэндзиро: Э, конечно. В чём дело?"
	DB	NEXT
	DB "Готовясь услышать, что мне скажет Сихо, я сажусь."
	DB	NEXT
	DB "Кэндзиро: Что это?"
	DB	NEXT
	DB "Сихо: ..............."
	DB	NEXT
	EVENT_CG	'ti_121',B_NORM,75
	DB "Кэндзиро: !!"
	DB	NEXT
	DB "Сихо без предупреждения нежно меня целует. Не в силах никак отреагировать, я гляжу на неё."
	DB	NEXT
	BAK_INIT	'tb_010',B_FADE
	T_CG	'tt_02_10',SIH_A2,0
	DB "Сихо: Саёнара..."
	DB	NEXT
	DB "Слово повисло в воздухе, а Сихо быстро выбежала из класса."
	DB	NEXT
	TATI_ERS
	DB "Кэндзиро: .....Сихо?"
	DB	NEXT
	DB "Ощущая тепло и умиротворение, я иду домой."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	DB "Не в силах понять значение слов Сихо, я иду в свою комнату и позволяю себе погрузиться в тревожный сон."
	DB	NEXT
	B_O	B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY		12
	DB "На следующее утро, когда я иду в школу, моё тело скрипит от усталости и недостатка сна."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_010',B_NORM
	CDPLAY		14
	DB "В классе я ищу Сихо, но её нигде не видно. Даже парта, за которой она сидела, исчезла."
	DB	NEXT
	T_CG	'tt_08_10',TET_A2,0
	DB "Тэцуя: Доброе утро, Кэндзиро."
	DB	NEXT
	DB "Тэцуя кивком приветствует меня."
	DB	NEXT
	DB "Кэндзиро: Доброе..."
	DB	NEXT
	DB "Тэцуя: В чём дело?"
	DB	NEXT
	DB "Кэндзиро: Хмм, ни в чём."
	DB	NEXT
	DB "Тэцуя: Что-то случилось?" 
	DB	NEXT
	DB "Кэндзиро: Нет, всё в порядке. Кстати, ты сегодня видел Сихо?"
	DB	NEXT
	DB "Тэцуя: Кого?"
	DB	NEXT
	DB "Кэндзиро: Ну знаешь, нашу одноклассницу, Сихо Касима."
	DB	NEXT
	DB "Тэцуя: Сихо? В нашем классе никого нет с таким именем, Кэндзиро."
	DB	NEXT
	DB "Кэндзиро: Что? Но этого не может..."
	DB	NEXT
	DB "Тэцуя: Ты уверен, что не слишком много спал прошлой ночью? Ты как-то странно себя ведёшь." 
	DB	NEXT
	;WAV	'Se_ch'
	DB "Тут прозвенел звонок, и мне пришлось сесть на место."
	DB	NEXT
	TATI_ERS
	;;WAV  'STOP'
	F_O	B_NORM,C_KURO
	DB "Дверь открывается, и класс затихает. Сейчас в класс должен войти учитель."
	DB	NEXT
	DB "Однако, во время урока всё о чём я мог думать -- это как могла Сихо полностью исчезнуть из нашей жизни."
	DB	NEXT
	DB "Позднее, Тэцуя подошёл, чтобы разбудить меня."
	DB	NEXT
	DB "Тэцуя: Просыпайся, чувак. Пора обедать."
	DB	NEXT
	DB "Не будучи уверенным в том, спал ли я на самом деле, я кивнул."
	DB	NEXT
	BAK_INIT	'tb_010',B_NORM
	T_CG	'tt_08_10',TET_A2,0
	DB "Тэцуя: О, проснулся. Я в шоке."
	DB	NEXT
	DB "Кэндзиро: Серьёзно?"
	DB	NEXT
	DB "Тэцуя: ...Вообще, что случилось сегодня утром? Ты от меня что-то скрываешь. Ты странно себя ведёшь." 
	DB	NEXT
	DB "Кэндзиро: Знаю..."
	DB	NEXT
	DB "Тэцуя: Думаю, ты слишком много спал прошлой ночью." 
	DB	NEXT
	DB "Кэндзиро: Постараюсь в будущем так не делать."
	DB	NEXT
	DB "Я медленно встал на ноги."
	DB	NEXT
	DB "Тэцуя: Ты куда?"
	DB	NEXT
	DB "Кэндзиро: Извини... Прямо сейчас мне как бы нужно побыть одному."
	DB	NEXT
	DB "Тэцуя: ...Чувак, с тобой всё в порядке? В чём дело?"
	DB	NEXT
	DB "Кэндзиро: Всё нормально. Мне просто надо проветрить голову." 
	DB	NEXT
	DB "Я оставил Тэцую, и пошёл на крышу."
	DB	NEXT
	BAK_INIT	'tb_012',B_NORM
	DB "Как всегда на крыше немного народа во время обеда."
	DB	NEXT
	DB "Глядя в небо, я вспоминаю Сихо, так таинственно исчезнувшую."
	DB	NEXT
	EVENT_CG	'ti_135',B_NORM,77
	CDPLAY		21
	DB "Кэндзиро: Сихо, ты была здесь, я знаю. Ты мне не привиделась, я в этом уверен!"
	DB	NEXT
	DB "Сихо: Это правда, я не была твоей фантазией..." 
	DB	NEXT
	DB "Кэндзиро: Сихо..."
	DB	NEXT
	DB "Сихо: Кэндзиро-кун, я хочу снова тебя увидеть, в твоих мечтах." 
	DB	NEXT
	DB "Улыбаясь, Сихо парит надо мной в небе."
	DB	NEXT
	GAME_END
	DB	EXIT
END
