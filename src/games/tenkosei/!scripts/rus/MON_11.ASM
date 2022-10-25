        include SUPER_C.inc
M_START:
MON_11
	CDPLAY		14
	F_O B_NORM,C_KURO
	DB	"Я направляюсь к кабинету музыки. По мере приближения, звук рояля становится громче."
	DB	NEXT
	BAK_INIT 'tb_034a',B_NORM
	DB	"Я стою перед дверью кабинета музыки. Затем открываю её."
	DB	NEXT
	EVENT_CG 'ti_049',B_NORM,74
	SWAIT
	CDPLAY	13
	DB	"Войдя, я вижу девушку из своих фантазий, Сихо Касима, страстно играющую на рояле. Она не заметила, что я вошёл."
	DB	T_WAIT, 20
	DB	CLS
	DB	"Кэндзиро: ... (Касима-сан?)"
	DB	T_WAIT, 10
	DB	CLS
	DB	"Кэндзиро: ...Интересно, откуда у меня такое странное чувство? Я никогда раньше не слышал этой песни, "
        DB "но она мне кажется такой знакомой."
	DB	T_WAIT, 20
	DB	CLS
	DB	"Я молча смотрю как она играет на рояле, не в силах пошевелиться перед её восхитительным выступлением."
	DB	T_WAIT, 30
	EWAIT	160
	DB	CLS
	DB	"Сихо: А, Кондо-кун..."
	DB	NEXT
	DB	"Касима-сан наконец замечает меня и встаёт с места."
	DB	NEXT
	BAK_INIT 'tb_016',B_NORM
	CDPLAY		10
	T_CG	'tt_02_16',SIH_A2,0
	DB	"Кэндзиро: Очень красивая песня."
	DB	NEXT
	DB	"Сихо: Правда? Ты её знаешь?"
	DB	NEXT
	DB	"Кэндзиро: Э? Нет, не знаю."
	DB	NEXT
	DB	"Сихо: Это неудивительно. Я сама её сочинила."
	DB	NEXT
	DB	"Неловкое молчание заполнило комнату."
	DB	NEXT
	DB	"Я с-сказал что-то не то?"
	DB	NEXT
	DB	"Кэндзиро: ...Но почему-то, у меня такое чувство, словно я раньше уже слышал её где-то..."
	DB	T_WAIT, 5
	DB	" Это странно, но я в этом уверен."
	DB	NEXT
	DB	"Сихо: Серьёзно?"
	DB	NEXT
	DB	"Она смотрит на меня с озадаченным выражением лица."
	DB	NEXT
	DB	"Кэндзиро: Серьёзно."
	DB	NEXT
	DB	"От моих слов она выглядит смущённой."
	DB	NEXT
	DB	"Она так похожа на мою Сихо -- Сихо из моих фантазий, что я не могу делать ничего, кроме как просто смотреть."
	DB	NEXT
	DB	"Сихо: ...Тебе понравилась? Моя песня."
	DB	NEXT
	DB	"Кэндзиро: Э? Д-да, очень хорошая."
	DB	NEXT
	DB	"Сихо: Я рада." 
	DB	NEXT
	DB	"Она улыбнулась, её глаза моргают."
	DB	NEXT
	DB	"Сихо: Эм, я..."
	DB	NEXT
	DB	"Да"
	DB	NEXT
	DB	"Сихо: Завтра после уроков я тоже буду играть. Если хочешь, можешь прийти и послушать как я играю."
	DB	NEXT
	DB	"Кэндзиро: Э?"
	DB	T_WAIT, 5
	DB	" Разумеется, я приду."
	DB	NEXT
	DB	"Сихо: Правда?" 
	DB	NEXT
	DB	"Кэндзиро: Конечно. Обещаю."
	DB	NEXT
	DB	"Сихо: Тогда я буду ждать здесь завтра."
	DB	NEXT
	DB	"С этими словами, она вышла из кабинета музыки."
	DB	NEXT
	TATI_ERS	;Tt_02
	DB	"Нет причины тут оставаться. Пойду, пожалуй."
	DB	NEXT
	FLG_KI	SIHO_PIA,'=',1
	CDPLAY		14
	BAK_INIT 'tb_034b',B_NORM 
	DB	"Я выхожу из кабинета музыки. Солнце начинает садиться."
	DB	NEXT
	DB	"Пожалуй, теперь пойду домой..."
	DB	NEXT
	DB	"Я выхожу из школы."
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
	DB	"Пока я иду домой, солнце совсем садится, и небо становится совсем чёрным."
	DB	NEXT
	DB	"Пожалуй, мне незачем сразу идти домой..."
	DB	NEXT
MATI:
	BAK_INIT	'tb_018c',B_NORM
	DB	"Куда мне пойти?"
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
	MENU_SET	F1,"В КИНОТЕАТР"
	MENU_SET	F2,"В БАР НИЖНЕГО БЕЛЬЯ"
	MENU_SET	F3,"В ПАРК"
	MENU_SET	F4,"В ОТЕЛЬ"
	MENU_SET	F5,"В БАР"
	MENU_SET	F6,"В КОФЕЙНЮ"
	MENU_SET	F7,"ДОМОЙ"
	MENU_END
	DB	EXIT
F1:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"Пожалуй, схожу в кино."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB	"Этот кинотеатр -- захудалое местечко."
	DB	NEXT
	DB	"Он находится в переулке, далеко от станции. Неудивительно, что он влачит такое жалкое существование."
	DB	NEXT
	DB	"Ни одного фильма, который я бы действительно хотел посмотреть. Нет нужды заходить."
	DB	NEXT
	GO MATI
F2:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"Точно, где-то здесь есть бар нижнего белья. Пожалуй, схожу посмотрю."
	DB	NEXT
	BAK_INIT 'tb_027',B_NORM
	DB	"Потрясающее место. Здесь в самом деле понимают человеческую природу."
	DB	NEXT
	T_CG 'tt_07_27',TET_B2,0
	FLG_KI TET_KAIS,'+',1 
	DB	"Тэцуя: Что ты тут делаешь?"
	DB	NEXT
	DB	"Передо мной появляется Тэцуя с вопросом на лице."
	DB	NEXT
	DB	"Кэндзиро: Я могу спросить у тебя тоже самое?"
	DB	NEXT
	DB	"Тэцуя: Я? Я, эм, просто проходил мимо, взглянуть..."
	DB	NEXT
	DB	"Кэндзиро: Правда?"
	DB	NEXT
	DB	"Тэцуя: Это место великолепно, ты так не думаешь?"
	DB	NEXT
	DB	"Кэндзиро: Пожалуй."
	DB	NEXT
	DB	"Тэцуя: В смысле, каждый мужчина хотел бы войти туда, хоть разок." 
	DB	NEXT
	DB	"Кэндзиро: Пожалуй."
	DB	NEXT
	DB	"Тэцуя: В смысле, хоть раз, и этого хватит... Тогда я смогу спокойно умереть." 
	DB	NEXT
	DB	"Тэцуя глядел на вывеску бара нижнего белья долгим щенячьим взглядом. Он в своём собственном мире."
	DB	NEXT
	DB	"Лучше оставить его."
	DB	NEXT
	GO MATI
F3:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"В парк ночью? Звучит довольно эротично."
	DB	NEXT
	BAK_INIT 'tb_032b',B_NORM 
	DB	"Здесь гуляет много парочек. Наверное, ещё больше их в кустах, наслаждаются уединением.."
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
	MENU_SET	G1,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	G2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	G3,"СМОТРЕТЬ НА НОГИ"
	MENU_END
	DB	EXIT
G1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,WW_1
WW_2:
	DB	"Её груди великолепны, хотя, я не могу как следует разглядеть их из-за её сложенных рук."
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
	DB	"Миленькая задница. Изящные линии спускаются от талии."
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
	DB	"Её ляжки мягкие и эластичные."
	DB	NEXT
	GO BODY
WW_5:
	FLG_KI TER_NET,'=',1
	GO WW_6
BODY:
	DB	"Тэруми: Что случилось? Ты вдруг затих." 
	DB	NEXT
	DB	"Кэндзиро: Э? О, ничего. Просто мне интересно, что ты тут делаешь совсем одна."
	DB	NEXT
	DB	"Тэруми: Я? Просто гуляю."
	DB	NEXT
	DB	"Кэндзиро: Здесь? Ночью?"
	DB	NEXT
	DB	"Тэруми: Ты за меня волнуешься?" 
	DB	NEXT
	DB	"Она застенчиво улыбается."
	DB	NEXT
	DB	"Кэндзиро: Да, я беспокоился, что на тебя могут напасть..."
	DB	NEXT
	DB	"Тэруми: Тебе-то что?.."
	DB	NEXT
	DB	"Кэндзиро: И-извини!"
	DB	NEXT
	DB	"Опасаясь железного кулака Тэруми-сэмпай, я убежал из парка."
	DB	NEXT
	GO MATI
F4:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"Отель любви? Никогда не бывал в нём..."
	DB	NEXT
	BAK_INIT 'tb_025',B_NORM
	DB	"Перед отелем находится яркая вывеска."
	DB	NEXT
	DB	"Пожалуй, нет причины находиться тут одному."
	DB	NEXT
	GO MATI
F5:
	FLG_KI TEMP06,'=',1
	DB	"Уверен, что он ещё не открыт. Ещё слишком рано."
	DB	NEXT
	DB	"Надо возвращаться."
	DB	NEXT
	GO MATI
F6:
	FLG_KI TEMP07,'=',1
	DB	"Кофейня? Припоминаю, где-то здесь была одна."
	DB	NEXT
	GO MATI
F7:
	DB	"Нечего слоняться без дела. Пожалуй, пойду домой."
	DB	NEXT
	DB	"Я направляюсь домой."
	DB	NEXT
	GO JITAKU2
JITAKU:
	BAK_INIT	'tb_018c',B_NORM
	DB	"Пожалуй, теперь пойду домой."
	DB	NEXT
	DB	"Я направляюсь домой."
	DB	NEXT
JITAKU2:
	BAK_INIT 'tb_005c',B_NORM
	DB	"Ах, хорошо быть дома."
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
	DB	"Здесь Акэми-сан и Мотока."
	DB	NEXT
	T_CG 'tt_11_02',MOT_C3,0
	T_CG 'tt_20_02',AKE_A1,0
	DB	"Мотока: Ониитян, с возвращением."
	DB	NEXT
	DB	"Акэми: Здравствуй, Кэндзиро-кун."
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
	FLG_KI YOKU,'+',11
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,SS_1
SS_2:
	DB	"У неё сексуальные ключицы. Крепкие и острые, придают красоту Акэми-сан."
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
	DB	"Её сиськи мягкие, хорошей формы. Я страстно желаю погрузить свой член в эту райскую ложбину..."
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
	DB	"Её ноги в чулках стройные и сексуальные, вызывают мгновенную реакцию моего члена."
	DB	NEXT
	GO BODY_2
SS_5:
	FLG_KI AKEM_NET,'=',1
	GO SS_6
BODY_2:
	DB	"Мотока: А! Ониитян, ты смотришь на мою мать с похотью в глазах." 
	DB	NEXT
	DB	"Кэндзиро: Н-неправда!"
	DB	NEXT
	DB	"Она была права. Но я не мог в этом сознаться."
	DB	NEXT
	DB	"Акэми: Мотока, не надо так дразнить своего брата."
	DB	NEXT
	DB	"Кэндзиро: И-и вообще, что сегодня на ужин?"
	DB	NEXT
	DB	"Акэми: Он скоро будет готов."
	DB	NEXT
	DB	"Мотока: А, Ониитян, ты сменил тему." 
	DB	NEXT
	DB	"Кэндзиро: Неправда. Я-"
	DB	NEXT
	DB	"Мотока: Извращенец! Ониитян -- извращенец!" 
	DB	NEXT
	DB	"Вот так мы трое провели сегодняшний вечер."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"Я принял ванну, так что теперь, пожалуй, пойду в постель."
	DB	NEXT
	DB	"Завтра после школы я схожу проведать Касима-сан. Жду не дождусь."
	DB	NEXT
	DB	"Уверен, что раньше слышал песню, которую она играла, хотя.... Ой ладно. Подумаю об этом завтра."
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
	DB	"Кэндзиро: Ууумм?"
	DB	NEXT
	DB	"Я медленно поднимаю веки."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"Кэндзиро: Где я?"
	DB	NEXT
	DB	"Я осматриваюсь. Я снова у себя в комнате."
	DB	NEXT
	DB	"Интересно, что случилось?"
	DB	NEXT
	DB	"На моей одежде бурое пятно."
	DB	NEXT
	DB	"Кровь? Точно, у меня пошла кровь из носа..."
	DB	NEXT
	DB	"Должно быть, я упал, потерял сознание."
	DB	NEXT
	DB	"А кто-то отнёс меня в мою комнату."
	DB	NEXT
	DB	"Но кто? Хотя, теперь это не важно."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_12.OVL'
END