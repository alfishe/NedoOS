        include SUPER_C.inc
M_START:
MON_14
	FLG_IF HOK,'=',3,KYOUSITU
	FLG_IF HAND,'=',2,TOIRE
	F_O B_NORM,C_KURO
	DB "Ну, думаю, уже пора просыпаться. Урок, наверное, уже закончился."
	DB	NEXT
	DB "Кенджиру:  *Потягив!*"
	DB	NEXT
	DB "Я потягиваюсь, как кот, открываю глаза."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	CDPLAY		14
	DB "Кенджиру:  А? Здесь никого нет."
	DB	NEXT
	DB "Этот урод Тецуя. Он должен был меня разбудить."
	DB	NEXT
	DB "Ну, наверное, пошатаюсь вокруг."
	DB	NEXT
	DB "Я выхожу из класса."
	DB	NEXT
	BAK_INIT 'tb_034a',B_NORM
	DB "Куда бы мне пойти?"
	DB	NEXT
	DB "О, только что вспомнил... Я должен встретиться с Кашимой-сан в классе."
	DB	NEXT
	DB "Пойду туда."
	DB	NEXT
	EVENT_CG 'ti_049',B_NORM,74
	CDPLAY		11
	DB "Уже отсюда, из холла, я могу слышать звуки игры Кашимы-сан на пианино."
	DB	NEXT
	DB ".....Уверен, что слышал эту песню раньше."
	DB	NEXT
	DB "Интересно, как? Нет никакого объяснения."
	DB	NEXT
	DB "Когда я вхожу,она прекращает играть и встает передо мной."
	DB	NEXT
	BAK_INIT 'tb_016',B_NORM
	T_CG 'tt_02_16',SIH_A2,0
	FLG_KI	SIH_KAIS,'+',1
	CDPLAY		23
	DB "Шихо:   Кондо-кун, пришел."
	DB	NEXT
	DB "Кенджиру:  А? Ну, да, я пообещал..."
	DB	NEXT
	DB "Когда я смотрю в глаза Шихо, я вспоминаю глаза другой моей Шихо."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	I1,"ОСМОТР ЛИЦА"
	MENU_SET	I2,"ОСМОТР СИСЕК"
	MENU_SET	I3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
I1:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "Она прекрасна. Ее лицо совершенно идеальной формы."
	DB	NEXT
	GO BODY_SIHO
I2:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "Тяжело рассмотреть ее груди сквозь форму, но они, наверное, идеальны."
	DB	NEXT
	GO BODY_SIHO
I3:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB "Сладкие бедра, такие мягкие и белые."
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
	DB "Кенджиру:  А-а?"
	DB	NEXT
	DB "Шихо:   Что с тобой?" 
	DB	NEXT
	DB "Кенджиру:  А? О, ничего. (Вот странно - когда я смотрю на нее, я чувствую не возбуждение, а умиротворенность.)"
	DB	NEXT
	DB "Шихо:   Кондо-кун?" 
	DB	NEXT
	DB "Кенджиру:  А? Ч- Что такое?"
	DB	NEXT
	DB "Шихо:   Ты в порядке?" 
	DB	NEXT
	DB "Кенджиру:  В каком смысле?"
	DB	NEXT
	DB "Шихо:   Ты внезапно так замолчал..."
	DB	NEXT
	DB "Кенджиру:  Прости. Я просто думал кое-о чем."
	DB	NEXT
	DB "Шихо:   Да?"
	DB	NEXT
	DB "Кенджиру:  Да. И еще..."
	DB	NEXT
	DB "Шихо:   Что?"
	DB	NEXT
	DB "Кенджиру:  Можешь не называть меня Кондо-кун? Зови меня просто Кенджиру."
	DB	NEXT
	DB "Шихо:   Хорошо." 
	DB	NEXT
	DB "Кашима-сан кажется счастливой. Или я просто вообразил это?"
	DB	NEXT
	DB "Шихо:   Ну, в таком случае зови меня Шихо." 
	DB	NEXT
	DB "Кенджиру:  А?"
	DB	T_WAIT,	3
	DB " Хорошо. Если ты так хочешь."
	DB	NEXT
	DB "Шихо:   Да."
	DB	NEXT
	DB "Кашима-сан... То есть Шихо улыбается мне."
	DB	NEXT
	DB "Кенджиру:  Ну, тогда я, наверное, пойду."
	DB	NEXT
	DB "Шихо:   А, Кенджиру-кун?"
	DB	NEXT
	DB "Кенджиру:  Да?"
	DB	NEXT
	DB "Шихо:   Я обычно всегда здесь после уроков. Так что если есть время, заходи послушать. Хорошо?"
	DB	NEXT
	DB "Кенджиру:  А?"
	DB	NEXT
	DB "Шихо:   ...думаю, я еще плохо играю, чтобы выступать перед людьми..." 
	DB	NEXT
	DB "Она смотрит в пол, вдруг подпрыгивает, затем поворачивается к пианино."
	DB	NEXT
	DB "Не зная, что сказать, я выхожу из класса."
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
	MENU_S 2,W,-1
	MENU_SET	J1,"КРЫШ"
	MENU_SET	J2,"МУЖ.КОМНАТ"
	MENU_SET	J3,"КОМ.АРТА"
	MENU_SET	J4,"СКЛАД П.Е"
	MENU_SET	J5,"КЛАСС МОТОКИ"
	MENU_END
	DB	EXIT
J1:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB "Думаю, пойду на крышу."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB "Я берусь за дверь на чердак, но она закрыта."
	DB	NEXT
	DB "Черт, наверное, я не смогу пройти."
	DB	NEXT
	DB "Я вернусь."
	DB	NEXT
	GO ROUKA
J2:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB "Я иду в мужскую уборную."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	DB "Вторая кабинка - это мой офис."
	DB	NEXT
	FLG_IF YOKU,'<',45,DERU
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	K1,"В ОФФИС"
	MENU_SET	K2,"УЙТИ"
	MENU_END
	DB	EXIT
K1:
	DB "Я направился в свою комнату."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB "Ну, с кем я сделаю это сегодня?"
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
	MENU_SET	L1,"АКЕМИ КОНДО"
	MENU_SET	L2,"ТЕРУМИ КИНОУШИ"
	MENU_SET	L3,"МИКА МАЕДА"
	MENU_SET	L4,"РЕНА ВАТАНАБЕ"
	MENU_SET	L5,"НАНА ХИРОС"
	MENU_SET	L6,"ШИЗУКА ХАСЕГАВА"
	MENU_SET	L7,"ШИЕ УТСУМИ"
	MENU_SET	L8,"НЕ ВОЛНУЙСЯ"
	MENU_END
	DB	EXIT
L1:
	FLG_KI HAND,'=',2
	DB "Мм, было бы неплохо с Акеми-сан..."
	DB	NEXT
	SINARIO 'AK_H.OVL'
L2:
	FLG_KI HAND,'=',2
	DB "Или лучше с Теруми-сенпай."
	DB	NEXT
	SINARIO 'TE_H.OVL'
L3:
	FLG_KI HAND,'=',2
	DB "Не возражаю сделать это с Микой-сенсей."
	DB	NEXT
	SINARIO 'MI_H.OVL'
L4:
	FLG_KI HAND,'=',2
	DB "Никогда не забуду те весенние каникулы..."
	DB	NEXT
	SINARIO 'RE_H.OVL'
L5:
	FLG_KI HAND,'=',2
	DB "Я бы хотел сорвать с нее форму..."
	DB	NEXT
	SINARIO 'NA_H.OVL'
L6:
	FLG_KI HAND,'=',2
	DB "Она прекрасное создание. Сочту за честь сделать это с ней."
	DB	NEXT
	SINARIO 'SI_H.OVL'
L7:
	FLG_KI HAND,'=',2
	DB "Ах, этот купальник..."
	DB	NEXT
	SINARIO 'CH_H.OVL'
L8:
	DB "Думаю, не нужно делать это сейчас."
	DB	NEXT
	GO ROUKA
TOIRE:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB "Чувствуя себя лучше, я стою перед раковиной."
	DB	NEXT
	DB "Кенджиру:  Аххх..."
	DB	NEXT
	DB "Это здорово."
	DB	NEXT
	DB "Я мою руки и иду в холл."
	DB	NEXT
	GO ROUKA
DERU:
K2:
	DB "Мне нечего здесь быть. Наверное, я пойду."
	DB	NEXT
	GO ROUKA
J3:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB "Я иду в класс рисования."
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	T_CG 'tt_12_13a',MIK2,0
	DB "Мика здесь."
	DB	NEXT
	DB "Мика:  А, Кондо-кун, ты здесь."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	M1,"ОСМОТР СИСЕК"
	MENU_SET	M2,"ОСМОТР ПОПЫ"
	MENU_SET	M3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
M1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_1
	FLG_KI MIKA_NET,'=',1
WW_1:
	DB "Ее руки скрещены, ее груди лежат на них. Я бы хотел поводить членом между ними."
	DB	NEXT
	GO BODY_MIKA
M2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_2
	FLG_KI MIKA_NET,'=',1
WW_2:
	DB "Мое лицо коснулось божественной задницы. Это никогда не забудется."
	DB	NEXT
	GO BODY_MIKA
M3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',6
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_3
	FLG_KI MIKA_NET,'=',1
WW_3:
	DB "Мягкие, податливые - прекрасные бедра."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB "Мика:  ...Чего ты тогда ждешь? Поторопись и захвати свой альбом."
	DB	NEXT
	DB "Кенджиру:  ........................................."
	DB	NEXT
	DB "Мика:  Что с тобой?"
	DB	NEXT
	DB "Кенджиру:  ...Увидимся позже, Мика-сенсей!"
	DB	NEXT
	DB "Мика:  А, стой, ты!" 
	DB	NEXT
	DB "Я вбегаю в холл."
	DB	NEXT
	GO ROUKA
J4:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB "Кладовка. Интересно, если там кто-нибудь?"
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB "Там никого. Думаю, я лучше вернусь."
	DB	NEXT
	GO ROUKA
J5:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB "Интересно,здесь ли Мотока?"
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	T_CG 'tt_10_11a',MOT_A2,0
	DB "Когда я вхожу в комнату,Мотока поворачивается."
	DB	NEXT
	DB "Мотока:  Ах, Любимый." 
	DB	NEXT
	DB "Кенджиру:  Ты еще здесь. Я думал, ты уже ушла домой."
	DB	NEXT
	DB "Мотока:  Я как раз собиралась пойти домой. А ты?"
	DB	NEXT
	DB "Кенджиру:  Я, пожалуй, еще погуляю."
	DB	NEXT
	DB "Мотока:  Серьезно? Почему бы не пойти со мной домой?"
	DB	NEXT
	DB "Кенджиру:  Прости, у меня здесь еще есть дела."
	DB	NEXT
	TATI_ERS	;Tt_10
	T_CG 'tt_21_11a',MOT_B2,0
	DB "Мотока:  ...Ладно. Тогда увидимся дома."
	DB	NEXT
	TATI_ERS	;Tt_10
	DB "Кенджиру:  Ах, Мотока."
	DB	NEXT
	DB "Я позвал ее."
	DB	NEXT
	T_CG 'tt_21_11a',MOT_B2,0
	DB "Мотока:  Да?"
	DB	NEXT
	DB "Кенджиру:  ...Прости. Я отведу тебя домой в другой раз."
	DB	NEXT
	DB "Мотока:  Да ладно. Не волнуйся за это. Увидимся позже, Любимый." 
	DB	NEXT
	DB "Она покидает класс."
	DB	NEXT
	DB "Знаешь, эта девочка не улыбается, как обычно. Интересно, что-нибудь не так?"
	DB	NEXT
	DB "Наверное, я пойду."
	DB	NEXT
	GO ROUKA
HOKEN:
	FLG_KI HOK,'=',3
	SINARIO 'ER.OVL'
KYOUSITU:
	BAK_INIT	'tb_034a',B_NORM
	DB "Наверное, я вернусь в свой класс."
	DB	NEXT
	FLG_KI HOK,'=',0
	BAK_INIT 'tb_011b',B_NORM
	DB "Пора идти домой."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY		22
	DB "Когда я выхожу из школы, солнце уже садится. В это время уже рано темнеет."
	DB	NEXT
	DB "Думаю, я не должен идти сразу домой."
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
	DB "Куда бы пойти?"
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
	MENU_SET	N1,"КИНОТЕАТР"
	MENU_SET	N2,"СТРИП БАР"
	MENU_SET	N3,"ПАРК"
	MENU_SET	N4,"МОЙ ОТЕЛЬ"
	MENU_SET	N5,"БАР"
	MENU_SET	N6,"ДОМ"
	MENU_END
	DB	EXIT
N1:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB "Наверное, схожу в кино."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB "Кинотеатр совершенно обветшалый."
	DB	NEXT
	DB "Это в таком же переулке. Неудивительно, что он в таком же состоянии."
	DB	NEXT
	DB "Нет никаких интересных фильмов. Незачем входить внутрь."
	DB	NEXT
	GO MATI
N2:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB "Думаю, пойду проверю магазин жен. белья."
	DB	NEXT
	BAK_INIT 'tb_027',B_NORM
	DB "Я жажду войти туда и проверить."
	DB	NEXT
	T_CG 'tt_07_27',TET_B2,0
	FLG_KI TET_KAIS,'+',1
	DB "Тецуя:    Что ты делаешь здесь?"
	DB	NEXT
	DB "Тецуя появляется передо мной."
	DB	NEXT
	DB "Кенджиру:  Я? А ты?"
	DB	NEXT
	DB "Тецуя:    Я? Я просто осматриваю это место. По-моему, довольно круто, как думаешь?"
	DB	NEXT
	DB "Кенджиру:  Ох?"
	DB	NEXT
	DB "Тецуя:    Я думаю, любому парню хочется войти туда, хоть раз." 
	DB	NEXT
	DB "Тецуя:    ...Ну, наверное."
	DB	NEXT
	DB "Тецуя:    Видигт? Ах, всего раза хватило бы. Тогда и помереть можно." 
	DB	NEXT
	DB "Он жадно пялится на вывеску перед магазином белья. Он сейчас в своем собственном мире."
	DB	NEXT
	DB "Лучше с ним не говорить."
	DB	NEXT
	GO MATI
N3:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB "Парк ночью? Звучит довольно эротично."
	DB	NEXT
	BAK_INIT 'tb_032b',B_NORM
	DB "Здесь гуляет множество парочек, держась за руки. В кустах их, наверное, даже больше."
	DB	NEXT
	DB "Теруми:  Что ты делаешь здесь?"
	DB	NEXT
	DB "Это голос, который я раньше слышал. Я поворачиваюсь и вижу Теруми-сенпай."
	DB	NEXT
	T_CG 'tt_05_32b',TER2,0
	DB "Кенджиру:  Ах, Теруми-сенпай."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	O1,"ОСМОТР СИСЕК"
	MENU_SET	O2,"ОСМОТР ПОПЫ"
	MENU_SET	O3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
O1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WS_1
	FLG_KI TER_NET,'=',1
WS_1:
	DB "Ее правая рука закрывает мне обзор, но могу сказать, что ее груди прекрасны, как раз нужного объема."
	DB	NEXT
	GO	BODY_TERUMI
O2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WS_2
	FLG_KI TER_NET,'=',1
WS_2:
	DB "Ее задница крепкая и красивая. Отличная линия бедер."
	DB	NEXT
	GO BODY_TERUMI
O3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WS_3
	FLG_KI TER_NET,'=',1
WS_3:
	DB "Ее бедра мягкие и податливые."
	DB	NEXT
	GO BODY_TERUMI
BODY_TERUMI:
	DB "Теруми:  Ч- Что не так? Ты так притих..." 
	DB	NEXT
	DB "Кенджиру:  А? О, ничего. Просто интересно, что ты здесь делаешь так поздно."
	DB	NEXT
	DB "Теруми:  Я просто вышла погулять."
	DB	NEXT
	DB "Кенджиру:  Сюда? В темноте?"
	DB	NEXT
	DB "Теруми:  Тебя это беспокоит?" 
	DB	NEXT
	DB "На мгновение она кажется счастливой."
	DB	NEXT
	DB "Кенджиру:  Просто на тебя ведь кто-нибудь может напасть..."
	DB	NEXT
	DB "Теруми:  Т- Ты что?" 
	DB	NEXT
	DB "Кенджиру:  Мне-Мне жаль!"
	DB	NEXT
	DB "Я убегаю так быстро, как только могу."
	DB	NEXT
	GO MATI
N4:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB "Отель любви. Никогда не был внутри."
	DB	NEXT
	BAK_INIT 'tb_025',B_NORM
	DB "Перед ним яркая кричащая вывеска."
	DB	NEXT
	DB "Кенджиру:  Думаю, нет смысла стоять здесь."
	DB	NEXT
	GO MATI
N5:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB "Я совсем не хочу туда заходить."
	DB	NEXT
	DB "Думаю, стоять здесь - не проблема."
	DB	NEXT
	DB "Я иду в бар."
	DB	NEXT
	BAK_INIT 'tb_029',B_NORM
	T_CG 'tt_03_29',HIR2,0
	DB "Хироши:   Что ты делаешь здесь?"
	DB	NEXT
	DB "О, нет! Это Хироши!"
	DB	NEXT
	DB "Кенджиру:  О, ничего. Я просто проходил мимо. Увидимся позже."
	DB	NEXT
	DB "Я быстро покидаю бар."
	DB	NEXT
	GO MATI
N6:
	DB "Пожалуй, я пойду домой..."
	DB	NEXT
	GO JITAKU
JITAKU:
	BAK_INIT 'tb_005c',B_NORM
	DB "А, хорошо быть дома."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	DB "А? Никого нет дома."
	DB	NEXT
	DB "Кенджиру:  Акеми-сан?"
	DB	NEXT
	DB "Я зову Акеми-сан, но никто не отвечает."
	DB	NEXT
	DB "Интересно, куда они ушли?"
	DB	NEXT
	DB "Я иду в комнату Акеми-сан, посмотреть, там ли она."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB "Я стучу в дверь комнаты Акеми-сан."
	;WAV	'SE_NO'
	DB	NEXT
	DB "Кенджиру:  Акеми-сан?"
	DB	NEXT
	DB "Никакого ответа. Я стучу еще раз."
	;WAV	'SE_NO'
	DB	NEXT
	DB "Кенджиру:  Акеми-сан? Вы здесь?"
	DB	NEXT
	DB "Я открываю дверь в комнату Акеми-сан."
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
	DB "Акеми:  А, Кенджиру-кун. Уже вернулся."
	DB	NEXT
	DB "Акеми-сан здесь, в одном белье."
	DB	NEXT
	DB "Кенджиру:  А- Акеми-сан!"
	DB	NEXT
	DB "Мое лицо краснеет, я отворачиваюсь."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB "Кенджиру:  Если Вы здесь, почему не ответили, когда я постучал?"
	DB	NEXT
	DB "Акеми:  Извини, я задумалась и не слышала тебя." 
	DB	NEXT
	DB "Акеми:  Но ты не должен смущаться, что я в нижнем белье. Мы ведь мать и сын, не так ли?"
	DB	NEXT
	DB "Кенджиру:  ...Я иду в постель."
	DB	NEXT
	DB "Я пошел в свою комнату."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB "Мое сердце еще стучит в груди, я готовлюсь ко сну."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_15.OVL'
HEYA:
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_NORM,C_KURO
	DB "Кенджиру:  Мммм?"
	DB	NEXT
	DB "Я приподнимаю веки."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	DB "Где я?"
	DB	NEXT
	DB "Я оглядываюсь вокруг. Кажется, я в моей комнате."
	DB	NEXT
	DB "А? Что случилось?"
	DB	NEXT
	DB "На моей одежде коричневое пятно."
	DB	NEXT
	DB "Кровь? О, у меня шла кровь."
	DB	NEXT
	DB "Что случилось после того?"
	DB	NEXT
	DB "Я, наверное, потерял сознание."
	DB	NEXT
	DB "Кто-то, наверное, принес меня сюда."
	DB	NEXT
	DB "Но кто? Ну, наверное, позже выясню."
	DB	NEXT
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_15.OVL'
END
