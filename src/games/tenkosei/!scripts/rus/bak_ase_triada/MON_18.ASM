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
	DB "Хорошо, время десерта."
	DB	NEXT
	T_CG 'tt_08_10',TET_A2,0
	DB "Тецуя:    Кенджиру."
	DB	NEXT
	DB "Кенджиру:  Да?"
	DB	NEXT
	DB "Тецуя:    До меня дошла одна интересная сплетня.." 
	DB	NEXT
	DB "Кенджиру:  Хорошо. Больше сплетен."
	DB	NEXT
	DB "Тецуя:    Тут другое. Если это правда, то это относится к тебе."
	DB	NEXT
	DB "Кенджиру:  Ко мне?"
	DB	NEXT
	DB "Тецуя:    Да. Это о твоей младшей сестре, Мотоке."
	DB	NEXT
	DB "Кенджиру:  Мотоке?"
	DB	NEXT
	DB "Тецуя:    Да."
	DB	NEXT
	DB "Кенджиру:  Уверен, ты собираешься сказать что-то типа,что Мотока была на видео, так?"
	DB	NEXT
	DB "Тецуя:    Нет, ничего подобного. ...Знаешь,в последнее время она общалась с довольно нехорошими людьми." 
	DB	NEXT
	DB "Кенджиру:  Я хочу, чтобы ты перкратил эти шуточки."
	DB	NEXT
	DB "Тецуя:    Это не шутка, это слух. У меня нет никаких докозательств, так что ты не должен ни о чем беспокоиться."
	DB	NEXT
	DB "Тецуя:    Я ухожу."
	DB	NEXT
	DB "Кенджиру:  Уймись."
	DB	NEXT
	TATI_ERS		;TT_08
	DB "Проигнорировав меня,Тецуя вышел из класса."
	DB	NEXT
	DB "..Уверен,Мотока никогда не сделает ничего дурного."
	DB	NEXT
	DB "Я пошел в коридор."
	DB	NEXT
	BAK_INIT 'tb_034a',B_NORM
	DB "Ладно, давайте теперь поищем десерт."
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
	DB "Куда бы мне пойти?"
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
	MENU_SET	AB1,"МУЗЫК.КОМН"
	MENU_SET	AB2,"КЛАСС"
	MENU_SET	AB3,"КОМН.МОТОКИ"
	MENU_SET	AB4,"СКЛАД П.Е"
	MENU_SET	AB5,"КОМ.АРТА"
	MENU_SET	AB6,"МУЖ.КОМНАТ"
	MENU_SET	AB7,"ОФФИС НУРСА"
	MENU_END
	DB	EXIT
AB1:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB "Интересно, Шихо играет сегодня?"
	DB	NEXT
	BAK_INIT 'tb_016',B_NORM
	T_CG 'tt_02_16',SIH_A2,0
	FLG_KI	SIH_KAIS,'+',1
	CDPLAY		10
	DB "Шихо здесь."
	DB	NEXT
	DB "Шихо:   А, Кенджиру-кун." 
	DB	T_WAIT,	5
	DB " Ты пришел слушать мою игру на пианино."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AC1,"ОСМОТР ЛИЦА"
	MENU_SET	AC2,"ОСМОТР СИСЕК"
	MENU_SET	AC3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
AC1:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "Для меня Шихо идеальная девушка. Как красивое личико."
	DB	NEXT
	GO SHIHO_BODY
AC2:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "Ее униформа мне сильно мешает, но уверен, что сиськи у нее замечательного размера."
	DB	NEXT
	GO SHIHO_BODY
AC3:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "Отличные бедра. Белые, с отличным количеством плоти на них."
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
	DB "Это не так. Я не хочу осквернять идеальную для меня девушку."
	DB	NEXT
	DB "Шихо:   Что с тобой?"
	DB	NEXT
	DB "Кенджиру:  Что? О, ничего..."
	DB	NEXT
	DB "Шихо:   Вижу..."
	DB	NEXT
	DB "Кенджиру:  Ты сегодня не играешь?"
	DB	NEXT
	DB "Шихо:   Мне жаль. Сегодня я пораньше иду домой..." 
	DB	NEXT
	DB "Кенджиру:  Ах, да. Это плохо."
	DB	NEXT
	DB "Шихо:   Мне жаль."
	DB	NEXT
	DB "Кенджиру:  Забудь."
	DB	NEXT
	DB "Шихо:   Ну, тогда до завтра." 
	DB	NEXT
	DB "Кенджиру:  Хорошо."
	DB	NEXT
	TATI_ERS		;Tt_02
	DB "Шихо ушла из музыкальной."
	DB	NEXT
	DB "Наверное, я пойду."
	DB	NEXT
	GO ROUKA
AB2:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB "Наверно,надо вернуться."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	CDPLAY		14
	DB "В классе никого."
	DB	NEXT
	DB "Кенджиру:  Я тут один."
	DB	NEXT
	DB "Возвращаюсь в коридор."
	DB	NEXT
	GO ROUKA
AB3:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB "Наверно, я проверю класс Мотоки."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	T_CG 'tt_10_11a',MOT_A2,0
	DB "Увидев меня, Мотока выходит."
	DB	NEXT
	DB "Мотока:  Ах, Любимый." 
	DB	NEXT
	DB "Кенджиру:  A, ты еще здесь."
	DB	NEXT
	DB "Мотока:  Да. Но уже собираюсь домой. А ты?"
	DB	NEXT
	DB "Кенджиру:  Мне надо еще немного задержаться."
	DB	NEXT
	DB "Мотока:  Да? Почему мы не ходим домой вместе?"
	DB	NEXT
	DB "Кенджиру:  Мне жаль, но я еще кое-что должна сделать."
	DB	NEXT
	TATI_ERS
	T_CG 'tt_21_11a',MOT_A2,0
	DB "Мотока:  ...ОК. Тогда я пойду вперед." 
	DB	NEXT
	TATI_ERS		;Tt_10
	DB "Кенджиру:  Ах, Мотока."
	DB	NEXT
	DB "Я окликаю ее,она останавливается."
	DB	NEXT
	T_CG 'tt_21_11a',MOT_A2,0
	DB "Мотока:  Да? Любимый." 
	DB	NEXT
	DB "Кенджиру:  ...Мне жаль."
	DB	NEXT
	DB "Мотока:  Все ОК. Увидимся позже, Любимый." 
	DB	NEXT
	TATI_ERS
	DB "Мотока уходит из класса."
	DB	NEXT
	DB "Все эти дни Мотока не улыбалась."
	DB	NEXT
	DB "Наверно, я тоже пойду."
	DB	NEXT
	DB "Я покидаю класс Мотоки."
	DB	NEXT
	GO ROUKA
AB4:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB "Наверное, я еще проверю кладовку."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB "Здесь нет никого."
	DB	NEXT
	DB "Наверное, вернусь."
	DB	NEXT
	GO ROUKA
AB5:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB "Не было причин идти туда, но я хотел увидеть любимую учительницу."
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	CDPLAY		18
	DB "Mика тут, вытирает статую."
	DB	NEXT
	DB "Кенджиру:  Мика-sensei."
	DB	NEXT
	DB "Мика:  O, Кондо-кун."
	DB	NEXT
	T_CG 'tt_12_13a',MIK2,0
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AD1,"ОСМОТР СИСЕК"
	MENU_SET	AD2,"ОСМОТР ПОПЫ"
	MENU_SET	AD3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
AD1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WQ_1
	FLG_KI MIKA_NET,'=',1
WQ_1:
	DB "Ее руки перекрещиваются,закрывая от взгляда ее сиськи. Я бы хотел засунуть между ними свой член."
	DB	NEXT
	GO BODY_MIKA
AD2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WQ_2
	FLG_KI MIKA_NET,'=',1
WQ_2:
	DB "Мое лицо погружалось в эту задницу. Я не скоро это забуду."
	DB	NEXT
	GO BODY_MIKA
AD3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',6
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WQ_3
	FLG_KI MIKA_NET,'=',1
WQ_3:
	DB "Красивые бедра отличной формы.Прелестно."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB "Мика:  Ты на меня сейчас смотрел?" 
	DB	NEXT
	DB "Кенджиру:  Э? Смотрел на Вас?"
	DB	NEXT
	DB "Мика:  ...Не важно. Забудь."
	DB	NEXT
	DB "Мика:  Я рада, что ты пришел вовремя."
	DB	NEXT
	DB "Кенджиру:  А?"
	DB	NEXT
	DB "Мика:  ...Не говори, что ты забыл." 
	DB	NEXT
	DB "Уп! Я забыл!"
	DB	NEXT
	DB "Кенджиру:  У- Увидимся позже, Мика-сенсей..."
	DB	NEXT
	DB "Мика:  П- Погоди! Вернись!" 
	DB	NEXT
	DB "Я быстро ушел из мастерской."
	DB	NEXT
	GO ROUKA
AB6:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB "Я иду в мужскую уборную."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	DB "Вторая кабинка с конца,моя личная комната. Пустая, как всегда."
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
	MENU_SET	AF1,"АКЕМИ КОНДО"
	MENU_SET	AF2,"ТЕРУМИ КИНОУШИ"
	MENU_SET	AF3,"МИКА МАЕДА"
	MENU_SET	AF4,"РЕНА ВАТАНАБЕ"
	MENU_SET	AF5,"НАНА ХИРОС"
	MENU_SET	AF6,"ШИЗУКА ХАСЕГАВА"
	MENU_SET	AF7,"ШИЕ УТСУМИ"
	MENU_SET	AF8,"НЕ ВОЛНУЙСЯ"
	MENU_END
	DB	EXIT
AF1:
	DB "Да,Акеми-сан - было б хорошо."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'AK_H.OVL'
AF2:
	DB "Или лучше с Теруми-сенпай."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'TE_H.OVL'
AF3:
	DB "Я б хотел сделать это с Мика-сенсей."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'MI_H.OVL'
AF4:
	DB "Не могу забыть впечатления от весенних каникул."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'RE_H.OVL'
AF5:
	DB "Я бы хотел сорвать с нее форму..."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'NA_H.OVL'
AF6:
	DB "Хорошо бы было быть в ней."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'SI_H.OVL'
AF7:
	DB "Она прекрасно выглядит в купальнике."
	DB	NEXT
	FLG_KI HAND,'=',3
	SINARIO 'CH_H.OVL'
AF8:
	DB "Я не буду беспокоиться."
	DB	NEXT
	GO ROUKA
AE2:
DERU:
	DB "Наверно, надо выходить уже."
	DB	NEXT
	GO ROUKA
TOIRE:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB "Я пошел к умывальнику,чувствуя уже лучше."
	DB	NEXT
	DB "Это было классно."
	DB	NEXT
	DB "Я помыл руки, и вышел в холл."
	DB	NEXT
	GO ROUKA
AB7:
	FLG_IF TEMP01,'>=',3,KYOUSITU
	FLG_KI TEMP01,'=',1
	FLG_KI TEMP08,'=',1
	DB "Офис нянин. Интересно, Шизука у себя?"
	DB	NEXT
	EVENT_CG	'th_072',B_NORM,35
	DB "Шизука:   Ты болен?"
	DB	NEXT
	DB "Кенджиру:  Нет, все ОК."
	DB	NEXT
	DB "Шизука:   Тогда почему ты здесь?"
	DB	NEXT
	DB "Кенджиру:  Хотел тебя видеть."
	DB	NEXT
	DB "Шизука:   O, я счастлив ."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AG_1,"ОСМОТР ЛИЦА"
	MENU_SET	AG_2,"ОСМОТР ПОПЫ"
	MENU_SET	AG_3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
AG_1:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,UR_1
	FLG_KI SIZU_NET,'=',1
UR_1:
	DB "Она прекрасна. Прекрасное лицо."
	DB	NEXT
	GO BODY_SIZUKA
AG_2:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,UR_2
	FLG_KI SIZU_NET,'=',1
UR_2:
	DB "Я б хотел, чтобы эти пальчики захватили мой член."
	DB	NEXT
	GO BODY_SIZUKA
AG_3:
	FLG_IF YOKU,'>=',100,HOKEN2
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,UR_3
	FLG_KI SIZU_NET,'=',1
UR_3:
	DB "Я смог увидеть только кружева наверху ее чулок. Это было так эротично."
	DB	NEXT
	GO BODY_SIZUKA
BODY_SIZUKA:
	DB "Шизука:   Куда, ты думаешь, ты смотрел,  парень?"
	DB	NEXT
	DB "Кенджиру:  Э? O, никуда..."
	DB	NEXT
	DB "Шизука:   Ты еще малыш, так что полагаю, что нечего с этим не поделаешь."
	DB	NEXT
	DB "Кенджиру:  У- Увидимся позже, Шизука-сенсей."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB "Она слишком умна для меня."
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
	DB "Наверное, вернусь в свой класс."
	DB	NEXT
	BAK_INIT 'tb_011b',B_NORM
	DB "Время собираться домой."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI JUMP,'=',53
	SINARIO 'NITI_MAT.OVL'
JITAKU:
	FLG_KI JUMP,'=',0
	BAK_INIT 'tb_005c',B_NORM
	DB "Aх, отлично быть дома."
	DB	NEXT
	DB "Открываю входную дверь и вхожу."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		9
	T_CG 'tt_11_02',MOT_C3,0
	T_CG 'tt_20_02',AKE_A1,0
	DB "Здесь Мотока и Акеми-сан."
	DB	NEXT
	DB "Кенджиру:  Привет,я тут."
	DB	NEXT
	DB "Мотока:  Любимый,хай!"
	DB	NEXT
	DB "Акеми:  Добро пожаловать домой."
	DB	NEXT
	DB "...По некоторым причинам я не мог не думать о том, что Тецуя рассказал про Мотоку."
	DB	NEXT
	DB "Мотока:  Любимый? Что случилось?" 
	DB	NEXT
	DB "Кенджиру:  А? Ох, ничего."
	DB	NEXT
	DB "Акеми:  Ты хорошо себя чувствуешь,Кенджиру-кун? Хочешь полежать?"
	DB	NEXT
	DB "Кенджиру:  Нет, все в порядке."
	DB	NEXT
	DB "Акеми:  В таком случае почему бы тебе не присесть? Обед готов." 
	DB	NEXT
	DB "Кенджиру:  Да.Конечно."
	DB	NEXT
	DB "Я медленно сел в свое кресло."
	DB	NEXT
	DB "Мотока:  Почему бы тебе не положить портфель?"
	DB	NEXT
	DB "Кенджиру:  О, хорошая идея."
	DB	NEXT
	DB "Я не замечал, пока Мотока про это не упомянула, но я прижимал свой портфель к груди. Я торопливо поставил его около ног."
	DB	NEXT
	DB "Мотока:  ...Ты ведешь себя странно, Любимый." 
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB "...Почему Тецуя распространяет слухи о Мотоке? Уверен, что тут ничего нет."
	DB	NEXT
	DB "Я никогда не сомневался в сестре."
	DB	NEXT
	DB "Кенджиру:  Ну, пора в кровать."
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
	DB "Я не был здесь в течении дня."
	DB	NEXT
	GO	RARA
MATI:
	BAK_INIT	'tb_018a',B_NORM
	DB "Интересно, есть что делать?"
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
	MENU_SET	F1,"КИНОТЕАТР"
	MENU_SET	F2,"СТРИП БАР"
	MENU_SET	F3,"ПАРК"
	MENU_SET	F4,"МОЙ ОТЕЛЬ"
	MENU_SET	F5,"БАР"
	MENU_SET	F6,"КАФЕ"
	MENU_SET	F7,"ДОМОЙ"
	MENU_END
	DB	EXIT
F1:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB "Фильм, ух? Может что-то интересное."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB "Время дневное, но в этом месте похоже солнце стало заходить."
	DB	NEXT
	DB "Наверно,это место всегда выглядит так."
	DB	NEXT
	DB "Не было ничего посмотреть."
	DB	T_WAIT, 5
	DB " Наверно, вернусь."
	DB	NEXT
	GO MATI
F2:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB "Это не то место, куда приходишь на протяжении дня."
	DB	NEXT
	GO MATI
F3:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB "Это хорошее место,чтобы убить время..."
	DB	NEXT
	BAK_INIT 'tb_032a',B_NORM
	CDPLAY		8
	DB "День прошел, но я еще вижу пары, которые гуляют, взявшись за руки."
	DB	NEXT
	DB "Теруми:  Что ты делаешь здесь?"
	DB	NEXT
	DB "Я поворачиваюсь, чтобы увидеть там Теруми-сенпаи."
	DB	NEXT
	T_CG 'tt_05_32a',TER2,0
	DB "Кенджиру:  Ах, Теруми-сенпай."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	G1,"ОСМОТР СИСЕК"
	MENU_SET	G2,"ОСМОТР ПОПЫ"
	MENU_SET	G3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
G1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_1
	FLG_KI TER_NET,'=',1
LL_1:
	DB "Сиськи Теруми-сенпаи мягкие и круглые. Полные объема."
	DB	NEXT
	GO BODY_TERUMI
G2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_2
	FLG_KI TER_NET,'=',1
LL_2:
	DB "И несомненно хорошая задница. Прекрасная линия талии."
	DB	NEXT
	GO BODY_TERUMI
G3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_3
	FLG_KI TER_NET,'=',1
LL_3:
	DB "Ее бедра мягкие и гладкие. Они полностью идут вниз."
	DB	NEXT
	GO BODY_TERUMI
BODY_TERUMI:
	DB "Теруми:  Ч- Что случилось? Ты стал внезапно таким тихим." 
	DB	NEXT
	DB "Кенджиру:  Э? А, ничего. Что ты делаешь тут в одиночестве?"
	DB	NEXT
	DB "Теруми:  Просто вышла погулять. А ты?"
	DB	NEXT
	DB "Кенджиру:  Да?"
	DB	T_WAIT, 5
	DB "Я? Ну, я..."
	DB	NEXT
	DB "Я подхожу к Теруми-сенпаи и принюхиваюсь к ней."
	DB	NEXT
	DB "Теруми:  Ты собака?!"
	DB	NEXT
	DB "Кенджиру:  Да, я твоя собака, Теруми-сенпаи."
	DB	NEXT
	DB "Теруми:  ...OК, пошли,песик." 
	DB	NEXT
	DB "Я смотрю на нее. Она улыбается."
	DB	NEXT
	DB "О нет! Держу пари, что Теруми-сенпаи собирается сыграть со мной злую шутку."
	DB	NEXT
	DB "Теруми:  Не собираешься отвечать мне, собака?"
	DB	NEXT
	DB "Кенджиру:  *Гав!*"
	DB	NEXT
	DB "Теруми:  Хороший!" 
	DB	NEXT
	DB "Время сбежать!"
	DB	NEXT
	DB "Кенджиру:  *Гав! Гав! Гав!*"
	DB	NEXT
	DB "Теруми:  А! Вернись!" 
	DB	NEXT
	DB "Оставляя Теруми-сенпаи позади, я покидаю парк."
	DB	NEXT
	GO MATI
F4:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP05,'=',1
	DB "Это не то место,куда приходят днем."
	DB	NEXT
	GO MATI
F5:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP06,'=',1
	DB "Это не то место,куда приходят днем."
	DB	NEXT
	GO MATI
F6:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP07,'=',1
	DB "Кофейный магазин. Я думаю, там был один где-то..."
	DB	NEXT
	GO MATI
F7:
	DB "Еще рано идти домой."
	DB	NEXT
	GO MATI
JITAKU2:
	BAK_INIT	'tb_018b',B_NORM
	DB "Наверно, уже надо идти домой. К тому же я голоден."
	DB	NEXT
	BAK_INIT 'tb_005b',B_NORM
	DB "Когда я добрался до дома, солнце уже стало заходить."
	DB	NEXT
	DB "Aх, хорошо быть дома..."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		6
	DB "Акеми-сан тут, но Мотоки нигде не видно."
	DB	NEXT
	T_CG 'tt_20_02',AKE_A2,0
	DB "Акеми:  А, Кенджиру-кун. Уже вернулся."
	DB	NEXT
	DB "Кенджиру:  Спасибо"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	H1,"ОСМОТР ПЛЕЧИ"
	MENU_SET	H2,"ОСМОТР СИСЕК"
	MENU_SET	H3,"ОСМОТР КОЛГОТОК"
	MENU_END
	DB	EXIT
H1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_1
	FLG_KI AKEM_NET,'=',1
LA_1:
	DB "Сильная, сексуальная. Образец прекрасной женщины."
	DB	NEXT
	GO BODY_AKEMI
H2:
	DB "Ее груди - мягкие холмики, образующие посередине прекрасную долину. На них можно смотреть до изнеможения."
	DB	NEXT
	GO BODY_AKEMI
H3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_3
	FLG_KI AKEM_NET,'=',1
LA_3:
	DB "Ее длинные , стройные ноги выглядят намного лучше в черных нейлоновых чулках."
	DB	NEXT
	GO BODY_AKEMI
BODY_AKEMI:
	DB "Акеми:  Что с тобой?"
	DB	NEXT
	DB "Кенджиру:  А? Ох, ничего."
	DB	NEXT
	DB "Акеми:  Ведешь себя немного странно, не так ли?"
	DB	NEXT
	DB "Кенджиру:  ...Ум, Акеми-сан, где Мотока?"
	DB	NEXT
	DB "Акеми:  В своей комнате."
	DB	NEXT
	DB "Кенджиру:  ...Ох."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB "Устал. Наверно, пора в кровать."
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
	DB "Уууунн??"
	DB	NEXT
	DB "Веки приподнимаются."
	DB	NEXT
	BAK_INIT 'tb_001b',B_FADE
	DB "Где я?"
	DB	NEXT
	DB "Я оглядываюсь вокруг. Кажется, я в моей комнате."
	DB	NEXT
	DB "Но что случилось?"
	DB	NEXT
	DB "Смотрю на одежду. Там коричневое пятно."
	DB	NEXT
	DB "Кровь? Теперь вспомнил -- кровь из носа."
	DB	NEXT
	DB "Я должно быть ослабел. Но что случилось потом?"
	DB	NEXT
	DB "Я потерял сознание..."
	DB	NEXT
	DB "Но кто-то меня сюда принес."
	DB	NEXT
	DB "Кто это мог быть?  ...Ну, об этом позже подумаю. Теперь в постель."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
KEKEKE:
	BAK_INIT 'tb_001a',B_FADE
	CDPLAY		12
	DB "Кенджиру:  ..........."
	DB	NEXT
	DB	T_WAIT, 5
	DB " Время вставать."
	DB	NEXT
	DB "Смотрю на часы. Они показывают прошлый день."
	DB	NEXT
	DB "Кенджиру:  Ой, я точно проспал..."
	DB	NEXT
	DB "А, сегодня воскресенье. Думаю, что еще можно поспать."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_FADE
	DB "Кенджиру:  Время обедать..."
	DB	NEXT
	DB "Пока жду, можно поиграть в видео игры."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_FADE
	DB "Завтра понедельник. Надо выспаться, подготовиться к школе."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	FLG_IF	ONANI,'>=',5,UIUI
	FLG_KI	ONANI,'=',0
UIUI:
	SINARIO 'MON_19.OVL'
END
