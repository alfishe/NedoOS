        include SUPER_C.inc
M_START:
MON_11
	CDPLAY		14
	F_O B_NORM,C_KURO
	DB "Я иду к классу музыки. По мере приближение звук пианино становится громче."
	DB	NEXT
	BAK_INIT 'tb_034a',B_NORM
	DB "Я стою перед дверью в класс музыки. Затем я протягиваю к двери руку."
	DB	NEXT
	EVENT_CG 'ti_049',B_NORM,74
	SWAIT
	CDPLAY	13
	DB "Входя, я вижу женщину моей фантазии, Шихо Кашиму, страстно играющую на пианино. Она не заметила, как я вошел."
	DB	T_WAIT, 20
	DB	CLS
	DB "Кенджиру:  ... (Кашима-сан?)"
	DB	T_WAIT, 10
	DB	CLS
	DB "Кенджиру:  ...Интересно, почему я странно себя чувствую? Никогда не слышал эту песню, но она кажется знакомой."
	DB	T_WAIT, 20
	DB	CLS
	DB "Я молча уставился на играющее пианино, неспособный двигаться в ее присутствии."
	DB	T_WAIT, 30
	EWAIT	160
	DB	CLS
	DB "Шихо:   Ах, Кондо-кун..."
	DB	NEXT
	DB "Кашима-сан наконец замечает меня и встает."
	DB	NEXT
	BAK_INIT 'tb_016',B_NORM
	CDPLAY		10
	T_CG	'tt_02_16',SIH_A2,0
	DB "Кенджиру:  Очень милая песня."
	DB	NEXT
	DB "Шихо:   Правда? Ты знаешь эту песню?"
	DB	NEXT
	DB "Кенджиру:  А? Нет, не знаю."
	DB	NEXT
	DB "Шихо:   Неудивительно. Я ее сама написала."
	DB	NEXT
	DB "Она договорила, и в комнате повисла неловкая тишина."
	DB	NEXT
	DB "Я- я сказал что-то не так?"
	DB	NEXT
	DB "Кенджиру:  ...Но почему-то я чувствую, что я ее уже слышал где-то..."
	DB	T_WAIT, 5
	DB " Это странно, но я уверен."
	DB	NEXT
	DB "Шихо:   Да?"
	DB	NEXT
	DB "Она озадаченно смотрит на меня."
	DB	NEXT
	DB "Кенджиру:  Я серьезно."
	DB	NEXT
	DB "После моих слов она сконфужена."
	DB	NEXT
	DB "Сейчас она выглядела настолько похожей на мою Шихо, Шихо из моей фантазии, что я мог только торчать на месте."
	DB	NEXT
	DB "Шихо:   ...Тебе она нравится? Песня."
	DB	NEXT
	DB "Кенджиру:  А? Д- да, она очень хорошая."
	DB	NEXT
	DB "Шихо:   Я рада." 
	DB	NEXT
	DB "Она улыбнулась, глаза горели."
	DB	NEXT
	DB "Шихо:   Ээ, я..."
	DB	NEXT
	DB "Кенджиру:  Да?"
	DB	NEXT
	DB "Шихо:   Я завтра тоже буду играть после школы. Если хочешь, можешь зайти и послушать мою игру."
	DB	NEXT
	DB "Кенджиру:  А?"
	DB	T_WAIT, 5
	DB " Конечно, я зайду."
	DB	NEXT
	DB "Шихо:   Да?" 
	DB	NEXT
	DB "Кенджиру:  Конечно. Обещаю."
	DB	NEXT
	DB "Шихо:   Тогда я буду завтра ждать здесь."
	DB	NEXT
	DB "С этими словами она покинула класс."
	DB	NEXT
	TATI_ERS	;Tt_02
	DB "Мне здесь незачем оставаться. Пожалуй, я пойду."
	DB	NEXT
	FLG_KI	SIHO_PIA,'=',1
	CDPLAY		14
	BAK_INIT 'tb_034b',B_NORM 
	DB "Я покидаю класс музыки. Солнце снаружи начинает заходить."
	DB	NEXT
	DB "Пожалуй, я пойду домой..."
	DB	NEXT
	DB "Я покидаю школу."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
	FLG_KI TEMP08,'=',0
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY		22
	DB "Когда я прихожу домой, солнце полностью зашло, а небо совсем темное."
	DB	NEXT
	DB "Думаю, мне не нужно идти прямо домой..."
	DB	NEXT
MATI:
	BAK_INIT	'tb_018c',B_NORM
	DB "Куда бы мне пойти?"
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
	MENU_SET	F1,"КИНОТЕАТР"
	MENU_SET	F2,"СТРИП БАР"
	MENU_SET	F3,"ПАРК"
	MENU_SET	F4,"ОТЕЛЬ"
	MENU_SET	F5,"БАР"
	MENU_SET	F6,"КАФЕ"
	MENU_SET	F7,"ДОМ"
	MENU_END
	DB	EXIT
F1:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB "Наверное, схожу в кино."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB "Кинотеатр совершенно обветшалый."
	DB	NEXT
	DB "Он в таком же переулке, далеко от станции. Ничего удивительного, что он так запущен."
	DB	NEXT
	DB "Нет ни одного фильма, который я хотел бы посмотреть. Нечего здесь торчать."
	DB	NEXT
	GO MATI
F2:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB "Верно, недалеко есть магазин дамского белья. Пожалуй, схожу посмотрю."
	DB	NEXT
	BAK_INIT 'tb_027',B_NORM
	DB "Это отличное место. Здесь действительно понимают людей."
	DB	NEXT
	T_CG 'tt_07_27',TET_B2,0
	FLG_KI TET_KAIS,'+',1 
	DB "Тецуя:    Что ты делаешь здесь?"
	DB	NEXT
	DB "Передо мной появляется Тецуя, с вопросительным выражением лица."
	DB	NEXT
	DB "Кенджиру:  Я могу задать тебе тот же вопрос?"
	DB	NEXT
	DB "Тецуя:    Я? Я, э-э, просто гуляю здесь..."
	DB	NEXT
	DB "Кенджиру:  Правда?"
	DB	NEXT
	DB "Тецуя:    Это место чудесно, ты не находишь?"
	DB	NEXT
	DB "Кенджиру:  Наверно."
	DB	NEXT
	DB "Тецуя:    По-моему, кому угодно понравится зайти сюда." 
	DB	NEXT
	DB "Кенджиру:  Наверно."
	DB	NEXT
	DB "Тецуя:    Хотя бы один раз, больше и не надо... Тогда уже и умереть не жалко." 
	DB	NEXT
	DB "Тецуя уставился на вывеску магазина, с щенячьей жаждой в глазах. Он был в собственном мире."
	DB	NEXT
	DB "Думаю, лучше его оставить."
	DB	NEXT
	GO MATI
F3:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB "Парк, ночью? Звучит довольно эротично."
	DB	NEXT
	BAK_INIT 'tb_032b',B_NORM 
	DB "Здесь гуляет много парочек. В кустах их даже больше, наслаждаются моментами жизни."
	DB	NEXT
	DB "Теруми:  Что ты делаешь здесь?"
	DB	NEXT
	DB "Я слышал этот голос раньше. Я обернулся, увидев Теруми-сенпай."
	DB	NEXT
	T_CG 'tt_05_32b',TER2,0 
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
	FLG_IF YOKU,'>=',100,WW_1
WW_2:
	DB "Ее груди чудесны, несмотря на то, что не полностью видны из-за скрещенных рук."
	DB	NEXT
	GO BODY
WW_1:
	FLG_KI TER_NET,'=',1
	GO WW_2
G2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,WW_3
WW_4:
	DB "Отличная попка. Плавные линии идут от талии."
	DB	NEXT
	GO BODY
WW_3:
	FLG_KI TER_NET,'=',1
	GO WW_4
G3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,WW_5
WW_6:
	DB "Ее бедра мягкие и гибкие."
	DB	NEXT
	GO BODY
WW_5:
	FLG_KI TER_NET,'=',1
	GO WW_6
BODY:
	DB "Теруми:  Что не так? Ты так внезапно затих." 
	DB	NEXT
	DB "Кенджиру:  А? О, ничего. Просто интересно, что ты делала здесь одна."
	DB	NEXT
	DB "Теруми:  Я? Я просто вышла погулять."
	DB	NEXT
	DB "Кенджиру:  Здесь? Ночью?"
	DB	NEXT
	DB "Теруми:  Тебя это беспокоит?" 
	DB	NEXT
	DB "Она улыбается."
	DB	NEXT
	DB "Кенджиру:  Да, на тебя могут напасть..."
	DB	NEXT
	DB "Теруми:  Ч- что? Зачем ты...?"
	DB	NEXT
	DB "Кенджиру:  Мне-Мне жаль!"
	DB	NEXT
	DB "Боясь железных кулаков Теруми-сенпай, я убежал из парка."
	DB	NEXT
	GO MATI
F4:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB "Отель любви? Никогда не был внутри..."
	DB	NEXT
	BAK_INIT 'tb_025',B_NORM
	DB "Яркая вывеска стоит перед отелем."
	DB	NEXT
	DB "Думаю, мне здесь нечего торчать одному."
	DB	NEXT
	GO MATI
F5:
	FLG_KI TEMP06,'=',1
	DB "Он еще не открылся. Еще слишком рано."
	DB	NEXT
	DB "Я вернусь."
	DB	NEXT
	GO MATI
F6:
	FLG_KI TEMP07,'=',1
	DB "Кофейня? Кажется, я припоминаю, что был здесь раньше."
	DB	NEXT
	GO MATI
F7:
	DB "Я не должен слоняться здесь. Наверное, пойду домой."
	DB	NEXT
	DB "Я иду домой."
	DB	NEXT
	GO JITAKU2
JITAKU:
	BAK_INIT	'tb_018c',B_NORM
	DB "Наверное, пойду домой."
	DB	NEXT
	DB "Я иду домой."
	DB	NEXT
JITAKU2:
	BAK_INIT 'tb_005c',B_NORM
	DB "А, хорошо быть дома."
	DB	NEXT
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
	FLG_KI TEMP08,'=',0
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		9
	DB "Акеми-сан и Мотока здесь."
	DB	NEXT
	T_CG 'tt_11_02',MOT_C3,0
	T_CG 'tt_20_02',AKE_A1,0
	DB "Мотока:  Любимый, привет."
	DB	NEXT
	DB "Акеми:  Привет,Кенджиру-кун."
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
	FLG_KI YOKU,'+',11
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,SS_1
SS_2:
	DB "У нее сексуальная ключица. Она сильная и острая, добавляет Акеми-сан красоты."
	DB	NEXT
	GO BODY_2
SS_1:
	FLG_KI AKEM_NET,'=',1
	GO SS_2
H2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,SS_3
SS_4:
	DB "Ее груди гладкие и хорошо очерчены. Я хотел бы положить между ними свой член..."
	DB	NEXT
	GO BODY_2
SS_3:
	FLG_KI AKEM_NET,'=',1
	GO SS_4
H3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,SS_5
SS_6:
	DB "Ее ноги в чулках так сексуальны, что мой член мгновенно отзывается."
	DB	NEXT
	GO BODY_2
SS_5:
	FLG_KI AKEM_NET,'=',1
	GO SS_6
BODY_2:
	DB "Мотока:  А! Любимый, ты смотришь на мою мать с такой жаждой в глазах." 
	DB	NEXT
	DB "Кенджиру:  Н- нет!"
	DB	NEXT
	DB "Она права. Но я этого не позволю."
	DB	NEXT
	DB "Акеми:  Мотока, не дразни так своего брата."
	DB	NEXT
	DB "Кенджиру:  Л- ладно, Что сегодня на обед?"
	DB	NEXT
	DB "Акеми:  Скоро будет готово."
	DB	NEXT
	DB "Мотока:  А, Любимый, ты переменил тему." 
	DB	NEXT
	DB "Кенджиру:  Нет. Я-"
	DB	NEXT
	DB "Мотока:  Извращенец! Он извращенец!" 
	DB	NEXT
	DB "Вот как трое из нас провели тот вечер."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB "Я принял ванну, так что, наверное, иду спать."
	DB	NEXT
	DB "Я встречусь после школы с Кашимой-сан. Я с нетерпением жду этого."
	DB	NEXT
	DB "Я уверен, что слышал раньше ту песню, что она играла, впрочем.... Ну ладно. Подумаю об этом завтра."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_12.OVL'
HEYA:
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_NORM,C_KURO
	DB "Кенджиру:  Ууу?"
	DB	NEXT
	DB "Я медленно поднял веки."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB "Кенджиру:  Где я?"
	DB	NEXT
	DB "Я озираюсь. Похоже, я снова в своей комнате."
	DB	NEXT
	DB "Что-то  случилось?"
	DB	NEXT
	DB "На моей одежде коричневое пятно."
	DB	NEXT
	DB "Кровь? Верно, у меня шла носом кровь..."
	DB	NEXT
	DB "Я, наверное, упал, потерял сознание."
	DB	NEXT
	DB "Кто-то, наверное, принес меня в мою комнату."
	DB	NEXT
	DB "Но кто? А ладно, думаю, это сейчас неважно."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_12.OVL'
END
