        include SUPER_C.inc
M_START:
MON_10
	FLG_IF HOK,'=',2,HUHUHU
	F_O B_NORM,C_KURO
	DB "Кенджиру:  Зззз... (...такой сонный...)"
	DB	NEXT
	DB "Кенджиру:  ........................................................................................................"
	DB	NEXT
	CDPLAY	14
	F_O B_NORM,C_KURO
	DB "Голос:  Эй! Проснись!"
	DB	NEXT
	DB "Кенджиру:  .....Мм?"
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB "Тецуя:    Наконец встаешь."
	DB	NEXT
	DB "Я поднял голову с парты и посмотрел на Тецуя."
	DB	NEXT
	T_CG 'tt_08_10',TET_A2,0
	DB "Тецуя:    Обеденный перерыв. Вставай."
	DB	NEXT
	DB "Кенджиру:  Да, ты прав."
	DB	NEXT
	DB "Тецуя:    Ну, я полетел. Увидимся позже." 
	DB	NEXT
	TATI_ERS
	DB "Кенджиру:  Веселись."
	DB	NEXT
	DB "Наверное, я тоже прогуляюсь."
	DB	NEXT
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
ROUKA:
	BAK_INIT 'tb_034a',B_NORM
	DB "Ну, куда мне пойти?"
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
	FLG_IF TEMP07,'=',0,SA_6
	FLG_KI W,'DOWN',5
SA_6:
	MENU_S 2,W,-1
	MENU_SET	C1,"НАЗАД В КЛАСС"
	MENU_SET	C2,"КРЫШ"
	MENU_SET	C3,"МУЗЫК.КОМН"
	MENU_SET	C4,"КОМН. П.Е"
	MENU_SET	C5,"КОМ.АРТА"
	MENU_SET	C6,"МУЖ.КОМНАТ"
	MENU_END
	DB	EXIT
C1:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB "Я вернулся в аудиторию."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB "Сегодня вокруг Шихо, как и вчера, толпились девчонки. Не было никакой возможности подойти к ней."
	DB	NEXT
	GO ROUKA
C2:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB "Наверное, пойду на крышу."
	DB	NEXT
	BAK_INIT 'tb_012',B_NORM
	DB "На крыше, около ограждения из цепи, стояла Теруми-сенпаи."
	DB	NEXT
	T_CG 'tt_05_12',TER2,0
	DB "Кенджиру:  Теруми-сенпаи."
	DB	NEXT
	DB "Теруми:  A, Кенджиру."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	D1,"ОСМОТР СИСЕК"
	MENU_SET	D2,"ОСМОТР ПОПЫ"
	MENU_SET	D3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
D1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'	;
	DB "У нее хорошие сиськи. Правая немного больше левой."
	DB	NEXT
	GO BODY
D2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "Aх, хорошая задница. Ее бедра были прекрасно очерчены."
	DB	NEXT
	GO BODY
D3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "Красивые бедра. И ноги такие длинные."
	DB	NEXT
	GO BODY
BODY:
	DB "Теруми:  Что не так? Почему ты на меня так уставился?"
	DB	NEXT
	DB "Кенджиру:  Я- я не уставился. А что ты здесь вообще делаешь?"
	DB	NEXT
	DB "Теруми:  Ничего. Просто гуляла вокруг школы. А ты?"
	DB	NEXT
	DB "Кенджиру:  О, тоже ничего. Просто смотрел, что здесь."
	DB	NEXT
	DB "Теруми:  У тебя, наверное, уйма времени."
	DB	NEXT
	DB "Кенджиру:  Как и у тебя."
	DB	NEXT
	DB "Теруми:  Я что? Почему..." 
	DB	NEXT
	DB "Начиная злиться, она подошла ко мне, сжав кулаки."
	DB	NEXT
	DB "Кенджиру:  Хахаха (Хмм, думаю, как раз пора смываться.)"
	DB	NEXT
	DB "Кенджиру:  Ну, пока, Теруми-сенпай!"
	DB	NEXT
	DB "Теруми:  Стой, ты!" 
	DB	NEXT
	DB "Я быстро смылся."
	DB	NEXT
	GO ROUKA
C3:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	BAK_INIT	'tb_010',B_NORM
	DB "Когда я захожу в комнату,Мотока оборачивается."
	DB	NEXT
	T_CG 'tt_10_10',MOT_A2,0
	DB "Мотока:  Любимый!"
	DB	NEXT
	DB "Мотока:  Что такое?"
	DB	NEXT
	DB "Кенджиру:  Ничего."
	DB	NEXT
	DB "Мотока:  Ничего? Но ведь ты здесь по какой-то причине, да?"
	DB	NEXT
	DB "Кенджиру:  Нет, никаких."
	DB	NEXT
	DB "Мотока:  Я знаю! Тебе одиноко, и ты хотел увидеть мое личико." 
	DB	NEXT
	DB "Кенджиру:  Нет, я просто проходил мимо класса."
	DB	NEXT
	DB "Мотока:  Не смешно." 
	DB	NEXT
	DB "Мотока:  Но важно то, что ты пришел увидеть меня, верно?"
	DB	NEXT
	DB "Мне лучше уйти, пока я не втянулся в еще одну стеснительную ситуацию..."
	DB	NEXT
	DB "Кенджиру:  Ну, пока."
	DB	NEXT
	DB "Мотока:  Любимый!" 
	DB	NEXT
	DB "Я покидаю класс Мотоки."
	DB	NEXT
	GO ROUKA
C4:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB "Интересно, что в кладовке."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB "Тецуя здесь, ищет мяч."
	DB	NEXT
	T_CG 'tt_08_15',TET_A2,0
	FLG_KI TET_KAIS,'+',1
	DB "Кенджиру:  Тецуя, что ты здесь делаешь?"
	DB	NEXT
	DB "Тецуя:    А, Кенджиру. Мы не смогли найти хороший мяч для игры, так что я ищу здесь подходящий. А ты?"
	DB	NEXT
	DB "Кенджиру:  Я просто брожу по школе."
	DB	NEXT
	DB "Тецуя:    Ты что?"
	DB	NEXT
	DB "Кенджиру:  Увидимся позже, Тецуя."
	DB	NEXT
	DB "Я покидаю кладовку."
	DB	NEXT
	GO ROUKA
C5:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB "Наверное, погляжу, что делает Мика-сенсей."
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	DB "Мика вытирает пыль на одной из ее странных статуй."
	DB	NEXT
	DB "Кенджиру:  Мика-sensei."
	DB	NEXT
	DB "Мика:  А, Кондо-кун."
	DB	NEXT
	T_CG 'tt_12_13a',MIK2,0
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	E1,"ОСМОТР СИСЕК"
	MENU_SET	E2,"ОСМОТР ПОПЫ"
	MENU_SET	E3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
E1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,MIKA_1
;MIKA_NETA
MIKA_2:
	DB "Ее руки сложены на грудях, закрывая мне обзор. Но выглядят они неплохо."
	DB	NEXT
	GO MIKA_7
MIKA_1:
	FLG_KI MIKA_NET,'=',1
	GO MIKA_2
E2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,MIKA_3
;MIKA_NETA
MIKA_4:
	DB "Мое лицо оценило упругость ее задницы. Я никогда не забуду это мгновение."
	DB	NEXT
	GO MIKA_7
MIKA_3:
	FLG_KI MIKA_NET,'=',1
	GO MIKA_4
E3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',6
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,MIKA_5
;MIKA_NETA
MIKA_6:
	DB "Отличные бедра. Ничего лишнего."
	DB	NEXT
	GO MIKA_7
MIKA_5:
	FLG_KI MIKA_NET,'=',1
	GO MIKA_6
MIKA_7:
	DB "Мика:  ...Ты только что на меня жадно пялился." 
	DB	NEXT
	DB "Кенджиру:  Я пялился?"
	DB	NEXT
	DB "Мика:  ...О, забудь."
	DB	NEXT
	DB "Мика:  И вообще, почему ты здесь? До завтра никаких дополнительных уроков не будет."
	DB	NEXT
	DB "Кенджиру:  А?"
	DB	NEXT
	DB "Мика:  ...Или ты уже забыл?"
	DB	NEXT
	DB "Нет! Я забыла!"
	DB	NEXT
	DB "Кенджиру:  Ну, я уже пойду..."
	DB	NEXT
	DB "Мика:  С-стой! Вернись сюда!" 
	DB	NEXT
	DB "Я покидаю арт-студию."
	DB	NEXT
	GO ROUKA
C6:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB "Я иду в мужскую уборную."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	DB "Вторая кабинка - это мой офис."
	DB	NEXT
	DB "Мне здесь нечего делать. Наверное, я пойду..."
	DB	NEXT
	GO ROUKA
KYOUSITU:
	BAK_INIT 'tb_034a',B_NORM
	DB "Скоро начинается урок. Думаю, мне пора возвращаться."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB "Студенты все еще разговаривают между собой. Девушки окружили Кашиму-сан, как обычно."
	DB	NEXT
	DB "Неужели новенькая всем им так интересна?"
	DB	NEXT
	DB "Я положил голову на парту и снова приготовился спать."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB "Кенджиру:  Доброй ночи.."
	DB	NEXT
	DB "Кенджиру:  ......................................................................................................."
	DB	NEXT
	DB "Голос:  Эй, проснись!"
	DB	NEXT
	DB "Кенджиру:  ...Мм?"
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	DB "Кенджиру:  Что?"
	DB	NEXT
	DB "Тецуя:    Ты наконец проснулся."
	DB	NEXT
	DB "Я поднимаю тяжелую голову с парты и гляжу на него."
	DB	NEXT
	T_CG 'tt_08_11a',TET_A2,0
	DB "Тецуя:    Ты много спишь."
	DB	NEXT
	DB "Кенджиру:  Не надо меня так хвалить. Я застенчивый."
	DB	NEXT
	DB "Тецуя:    Это не похвала!" 
	DB	NEXT
	DB "Тецуя:    Ладно, я иду домой. Тебе тоже следовало бы."
	DB	NEXT
	DB "Кенджиру:  Ах."
	DB	NEXT
	DB "Тецуя:    Ну, бывай."
	DB	NEXT
	TATI_ERS 
	DB "Тецуя выходит из класса. Я поднимаю свою сумку и собираюсь сделать то же."
	DB	NEXT
	DB "Ну, пора направляться домой."
	DB	NEXT
	GO HUHUHU
HOKEN:
	FLG_KI HOK,'=',2
	SINARIO 'ER.OVL'
HUHUHU:
	FLG_KI HOK,'=',0
	BAK_INIT 'tb_034a',B_NORM
	DB "Как тихо. Я не слышу ни звука. Все уже, наверное, разошлись по домам."
	DB	NEXT
	DB "А? Я что-то слышу..."
	DB	NEXT
	DB "Мягкая музыка, льющаяся из одной из комнат неподалеку."
	DB	NEXT
	CDPLAY	11
	DB "Пианино? Кто-то играет. Я уже слышал эту песню..."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	F1,"НАЗАД В МУЗ.КОМН" 
	MENU_SET	F2,"ДОМОЙ"
	MENU_END
	DB	EXIT
F1: 
	DB "Клянусь, я раньше слышал эту песню. Наверное, схожу посмотрю..."
	DB	NEXT
	SINARIO 'MON_11.OVL'
F2:
	FLG_KI SIHO_PIA,'=',0
	DB "Мне до этого никакого дела. Я лучше пойду домой."
	DB	NEXT
	DB "Я покидаю школу."
	DB	NEXT
	SINARIO 'BUNKI_1.OVL'
END
