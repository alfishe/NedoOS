        include SUPER_C.inc
M_START:
NITI_MAT
	FLG_KI	TEMP01,'=',0
	FLG_IF MOTDOYOU,'=',2,FUFUFU_7
	FLG_IF	MOTSUNE,'=',3,MOTOKA
	GO FUTUMATI
MOTOKA:
	CDPLAY	20
	BAK_INIT	'tb_018c',B_NORM
	T_CG	'tt_03_18c',HIR1,0
	T_CG	'tt_21_18c',MOT_B3,0
	DB "Мотока:  Ах..."
	DB	NEXT
	DB "Кенджиру:  Мотоке?"
	DB	NEXT
	TATI_ERS
	DB "Увидев меня, Мотока и Хироши начинают быстро удаляться, теряясь среди других людей."
	DB	NEXT
	DB "Кенджиру:  Мотока...."
	DB	NEXT
	DB "Я начинаю за ней бежать, но останавливаюсь. Она пропала из виду в толпе."
	DB	NEXT
	DB "Я не могу здесь стоять. Надо что-то делать..."
	DB	NEXT
	GO	UU_1
FUTUMATI:
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY	22
	DB "Когда я вышел из школы, смеркало. Теперь уже совсем темно."
	DB	NEXT
	DB "Куда бы мне пойти?"
	DB	NEXT
UU_1:
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
	FLG_KI TEMP08,'=',0
	GO	SENTAKU
MATI:
	BAK_INIT	'tb_018c',B_NORM
	DB "Куда бы мне пойти?"
	DB	NEXT
SENTAKU:
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
	FLG_IF REN_ATTA,'=',1,SA_8
	FLG_KI W,'DOWN',5
SA_8:
	FLG_IF NAN_ATTA,'=',1,SA_9
	FLG_KI W,'DOWN',6
SA_9:
	MENU_S	2,W,-1
	MENU_SET	AH1,"КИНОТЕАТР"
	MENU_SET	AH2,"СТРИП БАР"
	MENU_SET	AH3,"ПАРК"
	MENU_SET	AH4,"ОТЕЛЬ"
	MENU_SET	AH5,"БАР"
	MENU_SET	AH6,"КАФЕ"
	MENU_SET	AH7,"РЕСТОРАН"
	MENU_SET	AH8,"ДОМОЙ"
	MENU_END
	DB	EXIT
AH1:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB "Наверно, я пойду посмотрю фильм."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB "Это место очень запущено."
	DB	NEXT
	DB "Нет все равно интересного фильма."
	DB	NEXT
	GO MATI
AH2:
	FLG_IF RAYABA,'=',1,YABAI
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI	TET_KAIS,'+',1
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB "Пойду я в трактир дамского белья."
	DB	NEXT
	BAK_INIT 'tb_027',B_NORM
	DB "Хорошее местечко. Как раз по моему вкусу."
	DB	NEXT
	T_CG 'tt_07_27',TET_B2,0
	FLG_KI TET_KAIS,'+',1
	DB "Тецуя:    Что ты делаешь здесь?"
	DB	NEXT
	DB "Тецуя появляется передо мной."
	DB	NEXT
	DB "Кенджиру:   А ты как тут?"
	DB	NEXT
	DB "Тецуя:    Я? Я, мм... Я как раз думал зайти... Разве это не было бы здорово?" 
	DB	NEXT
	DB "Кенджиру:  Правда?"
	DB	NEXT
	DB "Тецуя:    А ты?"
	DB	NEXT
	DB "Кенджиру:  Что?"
	DB	NEXT
	DB "Тецуя:    Уверен, ты тоже хотел зайти."
	DB	NEXT
	DB "Кенджиру:   По правде, да."
	DB	NEXT
	DB "Тецуя:   Вот видишь? Что ты будешь делать?" 
	DB	NEXT
	DB "Тицуя смотрит на вывеску трактира дамского белья со странным выражением лица. Кажется, он попал в свой мир."
	DB	NEXT
	DB "Думаю, с ним не о чем говорить..."
	DB	NEXT
	GO MATI
YABAI:
	DB "Не знаю, сделаю ли я это..."
	DB	NEXT
	GO MATI
AH3:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB "Ночью в парк. Это довольно эротично..."
	DB	NEXT
	FLG_IF	TERUNASI,'=',1,TERUMICHAN
	BAK_INIT 'tb_032b',B_NORM
	CDPLAY	8
	DB "Парочки вместе прогуливаются. На них приятно смотреть."
	DB	NEXT
	DB "Теруми:  Что ты здесь делаешь?"
	DB	NEXT
	DB "Услышав знакомый голос, я поворачиваюсь и вижу Тируми."
	DB	NEXT
	T_CG 'tt_05_32b',TER2,0
	DB "Кенджиру:  Ах, Теруми-сенпай."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AI1,"ОСМОТР ГРУДИ"
	MENU_SET	AI2,"ОСМОТР ПОПЫ"
	MENU_SET	AI3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
AI1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,HH_1
	FLG_KI TER_NET,'=',1
HH_1:
	DB "Грудь Тируми прекрасна. Просто совершенство."
	DB	NEXT
	GO BODY_TERUMI
AI2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,HH_2
	FLG_KI TER_NET,'=',1
HH_2:
	DB "Отличная задница, хорошей формы, с упругими ягодицами."
	DB	NEXT
	GO BODY_TERUMI
AI3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,HH_3
	FLG_KI TER_NET,'=',1
HH_3:
	DB "У нее классные бедра, мягкие и нежные."
	DB	NEXT
	GO BODY_TERUMI
BODY_TERUMI:
	DB "Теруми:  Что случилось? Почемы ты такой тихий?" 
	DB	NEXT
	DB "Кенджиру:  Что? Мне просто интересно, почему ты здесь..."
	DB	NEXT
	DB "Теруми:  Я просто вышла погулять."
	DB	NEXT
	DB "Кенджиру:  Здесь, поздно ночью?"
	DB	NEXT
	DB "Теруми:  Тебя это беспокоит?"
	DB	NEXT
	DB "Ей становится радостнее при мысли об этом."
	DB	NEXT
	DB "Кенджиру:  Ну да, серьозно. Что бы я делал, если бы кто-то напал на тебя?"
	DB	NEXT
	DB "Теруми:  Ты беспокоишься о таких мелочах?"
	DB	NEXT
	DB "Кенджиру:  Мне-Мне жаль!"
	DB	NEXT
	DB "Я в спешке покидаю это место."
	DB	NEXT
	GO MATI
TERUMICHAN:
	BAK_INIT 'tb_032b',B_NORM
	CDPLAY	8
	DB "Парочки вместе гуляют. Приятно видеть истинную любовь."
	DB	NEXT
	DB "Наверно, Тируми где-то рядом..."
	DB	NEXT
	DB "Кенджиру:  Должен признаться, я одинок."
	DB	NEXT
	GO	MATI
AH4:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB "Не вижу смысла идти туда, но я проверю."
	DB	NEXT
	BAK_INIT 'tb_025',B_NORM
	DB "Здесь есть реклама цен на номера."
	DB	NEXT
	DB "Я не вижу смысла здесь стоять самому."
	DB	NEXT
	GO MATI
AH5:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB "Я не мог зайти туда."
	DB	NEXT
	DB "Может я просто постою снаружи."
	DB	NEXT
	DB "Я иду в бар."
	DB	NEXT
	BAK_INIT 'tb_029',B_NORM
	T_CG 'tt_03_29',HIR2,0
	DB "Хироши:   Что ты делаешь здесь?"
	DB	NEXT
	DB "О, нет! Это Хироши!"
	DB	NEXT
	DB "Кенджиру:  Я просто проходил мимо. Да ладно, до скорой встречи."
	DB	NEXT
	DB "Я прохожу мимо бара."
	DB	NEXT
	GO MATI
AH6:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB "Кафе. Интересно, Рена там?"
	DB	NEXT
	BAK_INIT 'tb_021',B_NORM
	T_CG 'tt_17_21',REN_A2,0
	DB "Рена:  Хай, я могу помочь?"
	DB	T_WAIT, 5
	DB " О, это ты, Кенджиру."
	DB	NEXT
	DB "Кенджиру:  Не будь такой грустной."
	DB	NEXT
	DB "Рена:  Я не грустная, просто 'Чем могу помочь?' предназначено для клиентов, а ты больше как друг."
	DB	NEXT
	DB "Кенджиру:  Понятно. Тебе не холодно?"
	DB	NEXT
	DB "Рена:  Нет, все ОК." 
	DB	NEXT
	DB "Кенджиру:  Правда? Тогда все окей."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AJ1,"ОСМОТР ШЕИ"
	MENU_SET	AJ2,"ОСМОТР ПЛЕЧ"
	MENU_SET	AJ3,"ОСМОТР СИСЕК"
	MENU_END
	DB	EXIT
AJ1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_1
	FLG_KI RENA_NET,'=',1
GG_1:
	DB "У нее белая и чистая шея. Я хочу полизать ее легкими движениями языка."
	DB	NEXT
	GO	REN
AJ2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',7
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_2
	FLG_KI RENA_NET,'=',1
GG_2:
	DB "Ее плечи породжают желание обнять эту девушку, защитить ее."
	DB	NEXT
	GO	REN
AJ3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_3
	FLG_KI RENA_NET,'=',1
GG_3:
	DB "Это, наверно, барменша, но я не могу точно определить ее вес. Я должен узнать..."
	DB	NEXT
	GO	REN
REN:
	DB "Рена:  Эй ..." 
	DB	T_WAIT, 5
	DB " Ты ищешь не там, где следует, не так ли?"
	DB	NEXT
	DB "Кенджиру:  Должен признать себя виноватым."
	DB	NEXT
	DB "Рена:  Ты и я больше не вместе, понял."
	DB	NEXT
	DB "Кенджиру:  Я знаю, знаю..."
	DB	NEXT
	DB "Рена:  Ну тогда все хорошо." 
	DB	NEXT
	DB "Она гладит меня, как собаку."
	DB	NEXT
	DB "Рена:  Хаха..."
	DB	T_WAIT, 5
	DB " Спасибо"
 	DB	NEXT
	DB "Мммм... Я хотел быть сейчас с Реной..."
	DB	NEXT
	FLG_IF	MOTSUNE,'=',1,REN2
	DB "Я покидаю кофейню."
	DB	NEXT
	GO	MATI
REN2:
	DB "Кенджиру:  В любом случае, я хочу кое о чем попросить. Передай, если увидишь Мотоку?"
	DB	NEXT
	DB "Рена:  Что? Она задерживается из школы?" 
	DB	NEXT
	DB "Кенджиру:  Нет, не про это."
	DB	NEXT
	DB "Рена:  Тогда что?"
	DB	NEXT
	DB "Что мне ей сказать? Ээ, мм..."
	DB	NEXT
	DB "Кенджиру:  Я хочу просто убедиться, что она не зашла в какое-нибудь опасное место, как это кафе."
	DB	NEXT
	DB "Хозяин:  Спасибо за доверие."
	DB	NEXT
	DB "Кенджиру:  Ой! Ну, мне пора уже..."
	DB	NEXT
	DB "Рена:  Постой, вернись!" 
	DB	NEXT
	DB "Я покидаю кофейню."
	DB	NEXT
	GO	MATI
AH7:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB "Я не голоден, но я могу зайти..."
	DB	NEXT
	BAK_INIT 'tb_023',B_NORM
	T_CG	'tt_14_23',NAN2,0
	DB "Нана:  Привет, я могу помочь?"
	DB	NEXT
	DB "Кенджиру:  Хорошо, что ты здесь."
	DB	NEXT
	DB "Нана:  Чего Вы желаете?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AK1,"ОСМОТР ГРУДИ"
	MENU_SET	AK2,"ОСМОТР ГРУДИ"
	MENU_SET	AK3,"ОСМОТР ГРУДИ"
	MENU_END
	DB	EXIT
AK1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,RR_1
	FLG_KI NANA_NET,'=',1
RR_1:
	DB "Они прекрасны. Что я могу сказать?"
	DB	NEXT
	GO	NAN
AK2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,RR_2
	FLG_KI NANA_NET,'=',1
RR_2:
	DB "Отличные груди. Просто великолепные."
	DB	NEXT
	GO	NAN
AK3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,RR_3
	FLG_KI NANA_NET,'=',1
RR_3:
	DB "Ее форма чуть ли не рвется от объема ее грудей."
	DB	NEXT
	GO	NAN
NAN:
	DB "Нана:  Чего Вы желаете?"
	DB	NEXT
	DB "Кенджиру:  Твои груди..."
	DB	NEXT
	DB "Нана:  Прости, в нашем ресторане нет ничего подобного." 
	DB	NEXT
	DB "Кенджиру:  Ну тогда я пошел."
	DB	NEXT
	DB "Нана:  Спасибо." 
	DB	NEXT
	DB "Я покидаю ресторан фаст-фуд."
	DB	NEXT
	GO	MATI
AH8:
	GO JITAKU
JITAKU:
	BAK_INIT	'tb_018c',B_NORM
	DB "Ну, уже довольно поздно. Мне уже пора домой."
	DB	NEXT
	SINARIO 'JUMP.OVL'
	DB	EXIT
HEYA:
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_FADE,C_KURO
	DB "Кенджиру:  Уже?"
	DB	NEXT
	DB "Я открыл глаза."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY 12
	DB "Кенджиру:  Где я?"
	DB	NEXT
	DB "Я в полном замешательстве, осматриваясь вокруг. Кажется, я в своей комнате."
	DB	NEXT
	DB "Какого хрена...?"
	DB	NEXT
	DB "На моей одежде коричневое пятно."
	DB	NEXT
	DB "Кровь? наверно, кровотечение с носа."
	DB	NEXT
	DB "Что случилось...?"
	DB	NEXT
	DB "Наверное я потерял сознание."
	DB	NEXT
	DB "Кто меня принес в комнату?"
	DB	NEXT
	DB "Ммм. Думаю, я узнаю это позже. Теперь надо еще немного поспать."
	DB	NEXT
	FLG_KI HIDUKE,'+',1
	FLG_KI HANAJI,'=',1
	B_O	B_FADE,C_KURO
	CDPLAY		0
	SINARIO 'JUMP.OVL'
	DB	EXIT
FUFUFU_7:
	FLG_KI MOTDOYOU,'=',0
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
	DB "Сегодня я весь день был здесь."
	DB	NEXT
	GO	RARA
MATI2:
	BAK_INIT	'tb_018a',B_NORM
	DB "Куда же мне пойти?"
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
	MENU_S	2,W,-1
	MENU_SET	F1,"КИНОТЕАТР"
	MENU_SET	F2,"СТРИП БАР"
	MENU_SET	F3,"ПАРК"
	MENU_SET	F4,"ОТЕЛЬ"
	MENU_SET	F5,"БАР"
	MENU_SET	F6,"КАФЕ"
	MENU_SET	F7,"ДОМОЙ"
	MENU_END
	DB	EXIT
F1:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB "Интересно, будет какой-то хороший фильм."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB "Вечерело."
	DB	NEXT
	DB "Думаю, фильм успею посмотреть."
	DB	NEXT
	DB "Тем более, в афише нет хорошего фильма."
	DB	T_WAIT, 5
	DB " Наверно, вернусь."
	DB	NEXT
	GO MATI2
F2:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB "Это не место для дневных посещений."
	DB	NEXT
	GO MATI2
F3:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB "Наверно это хорошее место, чтобы убить время"
	DB	NEXT
	BAK_INIT 'tb_032a',B_NORM
	CDPLAY		8
	DB "Здесь гуляют парочки."
	DB	NEXT
	DB "Теруми:  Что ты делаешь здесь?"
	DB	NEXT
	DB "Слышу голос сзади - это Тируми."
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
	FLG_IF YOKU,'>=',100,HEYA2
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_1
	FLG_KI TER_NET,'=',1
LL_1:
	DB "Классные сиськи, и какой размер."
	DB	NEXT
	GO BODY_TERUMI2
G2:
	FLG_IF YOKU,'>=',100,HEYA2
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_2
	FLG_KI TER_NET,'=',1
LL_2:
	DB "Мне нравится ее задница. У нее такой разрез прямо от талии."
	DB	NEXT
	GO BODY_TERUMI2
G3:
	FLG_IF YOKU,'>=',100,HEYA2
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_3
	FLG_KI TER_NET,'=',1
LL_3:
	DB "Ее бедра полные и сочные."
	DB	NEXT
	GO BODY_TERUMI2
BODY_TERUMI2:
	DB "Теруми:  Что-то случилось?" 
	DB	NEXT
	DB "Кенджиру:  Что? Нет, ничего. Просто интересно, почему ты здесь."
	DB	NEXT
	DB "Теруми:  Просто вышла погулять. А ты?"
	DB	NEXT
	DB "Кенджиру:  Да?"
	DB	NEXT
	DB " Я? Ну, я..."
	DB	T_WAIT, 5
	DB " Я хочу понюхать тебя..."
	DB	NEXT
	DB "Теруми:  Ты что,собака?" 
	DB	NEXT
	DB "Кенджиру:  Да, если я твоя собака."
	DB	NEXT
	DB "Теруми:  Ок, собачка." 
	DB	NEXT
	DB "Она мне улыбается."
	DB	NEXT
	DB "О нет! Она снова задумывает что-то опасное..."
	DB	NEXT
	DB "Теруми:  Ну? Ты собираешься мне отвечать, собачка?"
	DB	NEXT
	DB "Кенджиру:  Гав!"
	DB	NEXT
	DB "Теруми:  Молодец..." 
	DB	NEXT
	DB "Мне пора убегать."
	DB	NEXT
	DB "Кенджиру:  Гав! Гав!"
	DB	NEXT
	DB "Теруми:  Эй, вернись!" 
	DB	NEXT
	DB "Я в спешке убежал оттуда."
	DB	NEXT
	GO MATI2
F4:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP05,'=',1
	DB "Это не место для дневных встреч."
	DB	NEXT
	GO MATI2
F5:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP06,'=',1
	DB "Это не место для дневных встреч."
	DB	NEXT
	GO MATI2
F6:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP07,'=',1
	DB "Кафе? По-моему, здесь было одно где-то поблизости."
	DB	NEXT
	GO MATI2
F7:
	FLG_IF	TEMP01,'>=',3,JITAKU2
	DB "Гмм, еще рановато идти домой."
	DB	NEXT
	GO MATI2
JITAKU2:
	BAK_INIT	'tb_018b',B_NORM
	DB "Думаю, я уже пойду."
	DB	NEXT
	BAK_INIT 'tb_005b',B_NORM
	DB "Заходящее солнце делает мой дом оранжево-желтым."
	DB	NEXT
	DB "Для разнообразия можно пойти домой рано."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		6
	DB "Акеми здесь, но Мотоки не видно."
	DB	NEXT
	T_CG 'tt_20_02',AKE_A2,0
	DB "Акеми:  Ах, Кинджиру. Как я рад."
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
	FLG_IF YOKU,'>=',100,HEYA2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL
	FLG_IF YOKU,'<',100,LA_1
	FLG_KI AKEM_NET,'=',1
LA_1:
	DB "Сексуальная ключица, с прямым концом. Я бы хотел насладиться ею."
	DB	NEXT
	GO BODY_AKEMI
H2:
	DB "Ее груди прекрасны. Я бы хотел положить голову между этими холмами."
	DB	NEXT
	GO BODY_AKEMI
H3:
	FLG_IF YOKU,'>=',100,HEYA2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_3
	FLG_KI AKEM_NET,'=',1
LA_3:
	DB "Ее чулки доходят прямо до самой промежности. Такие нежные и гладкие."
	DB	NEXT
	GO BODY_AKEMI
BODY_AKEMI:
	DB "Акеми:  Что случилось?"
	DB	NEXT
	DB "Кенджиру:  А? Ох, ничего."
	DB	NEXT
	DB "Акеми:  Ты такой странный." 
	DB	NEXT
	DB "Кенджиру:  Эй, ты видела Мотоку?"
	DB	NEXT
	DB "Акеми:  В своей комнате."
	DB	NEXT
	DB "Кенджиру:  Oх."
	DB	NEXT
	B_O B_FADE,C_KURO	;F.O
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB "Гмм, пожалуй, я пойду спать."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'JUMP.OVL'
HEYA2:
	FLG_KI HANAJI,'=',1
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_NORM,C_KURO
	DB "Кенджиру:  Уже?"
	DB	NEXT
	DB "Я открыл глаза."
	DB	NEXT
	BAK_INIT 'tb_001b',B_FADE
	DB "Кенджиру:"
	DB	NEXT
	DB "Я просыпаюсь с головокружением. Похоже, я у себя."
	DB	NEXT
	DB "Что-то  случилось?"
	DB	NEXT
	DB "На моей одежде коричневое пятно."
	DB	NEXT
	DB "Кровь? Думаю, кровотечение с носа."
	DB	NEXT
	DB "Наверное, я потерял сознание. Но что случилось потом?"
	DB	NEXT
	DB "Я, наверное, потерял сознание."
	DB	NEXT
	DB "Но кто принес меня сюда?"
	DB	NEXT
	DB "Гммм. Ну, думаю, я узнаю это позже. Теперь лучше поспать."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'JUMP.OVL'
	DB	EXIT
END
