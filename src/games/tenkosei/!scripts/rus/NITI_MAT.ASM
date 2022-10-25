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
	DB	"Мотока: А..."
	DB	NEXT
	DB	"Кэндзиро: Мотока?"
	DB	NEXT
	TATI_ERS
	DB	"Увидев меня, Мотока и Хироси ускоряют шаг, исчезая среди других людей."
	DB	NEXT
	DB	"Кэндзиро: Мотока....."
	DB	NEXT
	DB	"Я бегу за ней, но останавливаюсь. Она затерялась среди массы народа."
	DB	NEXT
	DB	"Я не могу просто стоять здесь. Надо что-то делать..."
	DB	NEXT
	GO	UU_1
FUTUMATI:
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY	22
	DB	"Когда я вышел из школы, было ещё светло. Теперь уже совсем темно."
	DB	NEXT
	DB	"Куда мне идти?"
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
	DB	"Куда мне идти?"
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
	MENU_SET	AH1,"В КИНОТЕАТР"
	MENU_SET	AH2,"В БАР НИЖНЕГО БЕЛЬЯ"
	MENU_SET	AH3,"В ПАРК"
	MENU_SET	AH4,"В ОТЕЛЬ"
	MENU_SET	AH5,"В БАР"
	MENU_SET	AH6,"В КОФЕЙНЮ"
	MENU_SET	AH7,"В РЕСТОРАН"
	MENU_SET	AH8,"ДОМОЙ"
	MENU_END
	DB	EXIT
AH1:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"Пожалуй, схожу, посмотрю какие есть фильмы."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB	"Ух ты, это место такое убогое."
	DB	NEXT
	DB	"Тут нет ни одного фильма, который мне по-настоящему хотелось бы посмотреть."
	DB	NEXT
	GO MATI
AH2:
	FLG_IF RAYABA,'=',1,YABAI
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI	TET_KAIS,'+',1
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"Пожалуй, пойду к бару нижнего белья."
	DB	NEXT
	BAK_INIT 'tb_027',B_NORM
	DB	"Хорошее местечко. Полностью в моём вкусе."
	DB	NEXT
	T_CG 'tt_07_27',TET_B2,0
	FLG_KI TET_KAIS,'+',1
	DB	"Тэцуя: Что ты здесь делаешь?"
	DB	NEXT
	DB	"Тэцуя появляется передо мной."
	DB	NEXT
	DB	"Кэндзиро: А ты?"
	DB	NEXT
	DB	"Тэцуя: Я? Я, эм... Я просто думал как бы туда зайти... Не правда ли это было бы здорово?" 
	DB	NEXT
	DB	"Кэндзиро: Серьёзно?"
	DB	NEXT
	DB	"Тэцуя: А ты как думаешь?"
	DB	NEXT
	DB	"Кэндзиро: Что?"
	DB	NEXT
	DB	"Тэцуя: Уверен, что ты тоже хочешь туда войти."
	DB	NEXT
	DB	"Кэндзиро: Ну, признаю это."
	DB	NEXT
	DB	"Тэцуя: Видишь? Так что ты собираешься делать?" 
	DB	NEXT
	DB	"Тэцуя смотрит на вывеску бара, со странным выражением лица. Кажется, он в своём собственном мире."
	DB	NEXT
	DB	"Пожалуй, сейчас с ним говорить не стоит..."
	DB	NEXT
	GO MATI
YABAI:
	DB	"Не знаю, смогу ли я..."
	DB	NEXT
	GO MATI
AH3:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"Ночной парк. Есть в этом что-то эротичное..."
	DB	NEXT
	FLG_IF	TERUNASI,'=',1,TERUMICHAN
	BAK_INIT 'tb_032b',B_NORM
	CDPLAY	8
	DB	"Здесь прогуливаются парочки. Здорово наблюдать за ними."
	DB	NEXT
	DB	"Тэруми: Что ты здесь делаешь?"
	DB	NEXT
	DB	"Услышав знакомый голос, я медленно оборачиваюсь и вижу Тэруми-сэмпай."
	DB	NEXT
	T_CG 'tt_05_32b',TER2,0
	DB	"Кэндзиро: А, Тэруми-сэмпай."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AI1,"СМОТРЕТЬ НА ГРУДЬ"
	MENU_SET	AI2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	AI3,"СМОТРЕТЬ НА НОЖКИ"
	MENU_END
	DB	EXIT
AI1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,HH_1
	FLG_KI TER_NET,'=',1
HH_1:
	DB	"Грудь У Тэруми-сэмпай шикарная. Однозначно великолепная."
	DB	NEXT
	GO BODY_TERUMI
AI2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,HH_2
	FLG_KI TER_NET,'=',1
HH_2:
	DB	"Замечательная задница, превосходной формы, отличным образом переходящая в бёдра."
	DB	NEXT
	GO BODY_TERUMI
AI3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,HH_3
	FLG_KI TER_NET,'=',1
HH_3:
	DB	"У неё исключительные ножки, гладкие и шелковистые."
	DB	NEXT
	GO BODY_TERUMI
BODY_TERUMI:
	DB	"Тэруми: В-в чём дело? Чего это ты вдруг так затих?" 
	DB	NEXT
	DB	"Кэндзиро: Э? Просто мне стало интересно, почему ты здесь..."
	DB	NEXT
	DB	"Тэруми: Я просто гуляю."
	DB	NEXT
	DB	"Кэндзиро: В такой темноте?"
	DB	NEXT
	DB	"Тэруми: Ты за меня беспокоишься?"
	DB	NEXT
	DB	"Кажется, её немного обрадовала эта мысль."
	DB	NEXT
	DB	"Кэндзиро: Да, конечно. Что бы я стал делать, если бы на тебя напали?"
	DB	NEXT
	DB	"Тэруми: Ты беспокоишься о таких вещах?"
	DB	NEXT
	DB	"Кэндзиро: П-прости!"
	DB	NEXT
	DB	"Я быстро покидаю это место."
	DB	NEXT
	GO MATI
TERUMICHAN:
	BAK_INIT 'tb_032b',B_NORM
	CDPLAY	8
	DB	"Здесь гуляют парочки. Так мило видеть настоящую любовь."
	DB	NEXT
	DB	"Интересно, Тэруми-сэмпай где-нибудь тут..."
	DB	NEXT
	DB	"Кэндзиро: Должен признать, мне одиноко."
	DB	NEXT
	GO	MATI
AH4:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"Не думаю, что есть веские причины идти туда, но схожу посмотрю."
	DB	NEXT
	BAK_INIT 'tb_025',B_NORM
	DB	"Здесь вывеска со стоимостью номеров."
	DB	NEXT
	DB	"Нет причины стоять здесь одному."
	DB	NEXT
	GO MATI
AH5:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"Я не могу войти туда."
	DB	NEXT
	DB	"Ну, может быть, я могу просто постоять снаружи?"
	DB	NEXT
	DB	"Я иду в бар."
	DB	NEXT
	BAK_INIT 'tb_029',B_NORM
	T_CG 'tt_03_29',HIR2,0
	DB	"Хироси: Что ты тут делаешь?"
	DB	NEXT
	DB	"О нет! Это Хироси!"
	DB	NEXT
	DB	"Кэндзиро: Ничего, просто шёл мимо. Ну, до свидания."
	DB	NEXT
	DB	"Я оставляю бар позади."
	DB	NEXT
	GO MATI
AH6:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB	"Кофейня. Интересно, Рэна сегодня там?"
	DB	NEXT
	BAK_INIT 'tb_021',B_NORM
	T_CG 'tt_17_21',REN_A2,0
	DB	"Рэна: Здравствуйте, чем могу вам помочь?"
	DB	T_WAIT, 5
	DB	" О, это ты, Кэндзиро."
	DB	NEXT
	DB	"Кэндзиро: Не говори так разочарованно."
	DB	NEXT
	DB	"Рэна: Я и не говорю, просто 'Чем могу вам помочь?' говорят посетителям, но ты, скорее, друг."
	DB	NEXT
	DB	"Кэндзиро: Ясно. Тебе не холодно в такой одежде?"
	DB	NEXT
	DB	"Рэна: Нет, всё нормально." 
	DB	NEXT
	DB	"Кэндзиро: Правда? Тогда ладно."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AJ1,"СМОТРЕТЬ НА ШЕЮ"
	MENU_SET	AJ2,"СМОТРЕТЬ НА ПЛЕЧИ"
	MENU_SET	AJ3,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_END
	DB	EXIT
AJ1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_1
	FLG_KI RENA_NET,'=',1
GG_1:
	DB	"Её шейка белая и чистая. Хочу облизать её языком."
	DB	NEXT
	GO	REN
AJ2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',7
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_2
	FLG_KI RENA_NET,'=',1
GG_2:
	DB	"Её плечи такие, что хочется представить рядом с собой их обладательницу и оберегать её."
	DB	NEXT
	GO	REN
AJ3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_3
	FLG_KI RENA_NET,'=',1
GG_3:
	DB	"Её плечи такие, что хочется представить рядом с собой их обладательницу и оберегать её."
	DB	NEXT
	GO	REN
REN:
	DB	"Рэна: Эй, ты..." 
	DB	T_WAIT, 5
	DB	" Ты ведь смотрел, куда не следует, не так ли?"
	DB	NEXT
	DB	"Кэндзиро: Должен признать, что виноват в этом."
	DB	NEXT
	DB	"Рэна: Запомни, мы с тобой больше не встречаемся."
	DB	NEXT
	DB	"Кэндзиро: Знаю, знаю..."
	DB	NEXT
	DB	"Рэна: Тогда, пожалуй, всё нормально." 
	DB	NEXT
	DB	"Она похлопывает меня по голове, как собаку."
	DB	NEXT
	DB	"Кэндзиро: Хаха..."
	DB	T_WAIT, 5
	DB	" Спасибо."
 	DB	NEXT
	DB	"Мммм... Хотел бы я всё ещё быть с Рэной..."
	DB	NEXT
	FLG_IF	MOTSUNE,'=',1,REN2
	DB	"Я выхожу из кофейни."
	DB	NEXT
	GO	MATI
REN2:
	DB	"Кэндзиро: Вообще, мне нужно у тебя кое-что спросить. Скажешь мне, если увидишь тут Мотоку?"
	DB	NEXT
	DB	"Рэна: Э? Она задерживается по дороге из школы?" 
	DB	NEXT
	DB	"Кэндзиро: Нет, не это."
	DB	NEXT
	DB	"Рэна: Тогда что?"
	DB	NEXT
	DB	"Что же мне ей сказать? Эм, э..."
	DB	NEXT
	DB	"Кэндзиро: Я, я просто хочу удостовериться, что она не приходит в какие-нибудь опасные места, вроде этой кофейни."
	DB	NEXT
	DB	"Хозяин: Эээ, спасибо за лестный отзыв."
	DB	NEXT
	DB	"Кэндзиро: Упс! Ну, я пошёл..."
	DB	NEXT
	DB	"Рэна: Подожди, вернись!" 
	DB	NEXT
	DB	"Я выхожу из кофейни."
	DB	NEXT
	GO	MATI
AH7:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB	"Я не особо голоден, но, пожалуй, можно сходить..."
	DB	NEXT
	BAK_INIT 'tb_023',B_NORM
	T_CG	'tt_14_23',NAN2,0
	DB	"Нана: Здравствуйте, могу я вам помочь?"
	DB	NEXT
	DB	"Кэндзиро: О хорошо, что вы здесь."
	DB	NEXT
	DB	"Нана: Что бы вы хотели?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AK1,"СМОТРЕТЬ НА ГРУДЬ"
	MENU_SET	AK2,"СМОТРЕТЬ НА ГРУДЬ"
	MENU_SET	AK3,"СМОТРЕТЬ НА ГРУДЬ"
	MENU_END
	DB	EXIT
AK1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,RR_1
	FLG_KI NANA_NET,'=',1
RR_1:
	DB	"Великолепная. Что ещё мне сказать?"
	DB	NEXT
	GO	NAN
AK2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,RR_2
	FLG_KI NANA_NET,'=',1
RR_2:
	DB	"Восхитительная грудь. Просто восхитительная."
	DB	NEXT
	GO	NAN
AK3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,RR_3
	FLG_KI NANA_NET,'=',1
RR_3:
	DB	"Её форма практически разрывается под тяжестью её груди."
	DB	NEXT
	GO	NAN
NAN:
	DB	"Нана: Что бы вы хотели?"
	DB	NEXT
	DB	"Кэндзиро: Грудку..."
	DB	NEXT
	DB	"Нана: Извините, в этом ресторане нет ничего подобного." 
	DB	NEXT
	DB	"Кэндзиро: Ладно, тогда я пойду."
	DB	NEXT
	DB	"Нана: Спасибо." 
	DB	NEXT
	DB	"Я выхожу из ресторана быстрого питания."
	DB	NEXT
	GO	MATI
AH8:
	GO JITAKU
JITAKU:
	BAK_INIT	'tb_018c',B_NORM
	DB	"Что ж, уже довольно поздно. Пожалуй, пора идти домой."
	DB	NEXT
	SINARIO 'JUMP.OVL'
	DB	EXIT
HEYA:
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_FADE,C_KURO
	DB	"Кэндзиро: Уууммм?"
	DB	NEXT
	DB	"Я медленно открываю глаза."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY 12
	DB	"Кэндзиро: Где я?"
	DB	NEXT
	DB	"Моя голова кружится, пока я медленно осматриваюсь по сторонам. Кажется, я у себя в комнате."
	DB	NEXT
	DB	"Что за чёрт?.."
	DB	NEXT
	DB	"На моей одежде бурое пятно."
	DB	NEXT
	DB	"Кровь? Должно быть, у меня пошла кровь из носа..."
	DB	NEXT
	DB	"Что произошло?.."
	DB	NEXT
	DB	"Должно быть, я потерял сознание. "
	DB	NEXT
	DB	"Кто отнёс меня в комнату?"
	DB	NEXT
	DB	"Хмм. Пожалуй, можно и потом над этим подумать, а сейчас пора спать."
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
	DB	"Я давно не был здесь в дневное время."
	DB	NEXT
	GO	RARA
MATI2:
	BAK_INIT	'tb_018a',B_NORM
	DB	"Интересно, куда мне идти?"
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
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"Интересно, показывают ли сейчас хорошие фильмы."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB	"На улице довольно светло."
	DB	NEXT
	DB	"Пожалуй, я могу сходить в кино в любое время."
	DB	NEXT
	DB	"Плюс, сейчас ничего интересного не показывают."
	DB	T_WAIT, 5
	DB	" Пожалуй, пойду назад."
	DB	NEXT
	GO MATI2
F2:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"В таком месте днём делать нечего."
	DB	NEXT
	GO MATI2
F3:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"Пожалуй, это хорошее место, чтобы убить время."
	DB	NEXT
	BAK_INIT 'tb_032a',B_NORM
	CDPLAY		8
	DB	"Здесь гуляют парочки."
	DB	NEXT
	DB	"Тэруми: Что ты здесь делаешь?"
	DB	NEXT
	DB	"Я слышу голос за спиной -- Тэруми-сэмпай."
	DB	NEXT
	T_CG 'tt_05_32a',TER2,0
	DB	"Кэндзиро: А, Тэруми-сэмпай."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	G1,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	G2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	G3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
G1:
	FLG_IF YOKU,'>=',100,HEYA2
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_1
	FLG_KI TER_NET,'=',1
LL_1:
	DB	"Замечательные сиськи, такие большие."
	DB	NEXT
	GO BODY_TERUMI2
G2:
	FLG_IF YOKU,'>=',100,HEYA2
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_2
	FLG_KI TER_NET,'=',1
LL_2:
	DB	"Мне нравится задница Тэруми-сэмпай. Отличная форма, продолжающая её бёдра."
	DB	NEXT
	GO BODY_TERUMI2
G3:
	FLG_IF YOKU,'>=',100,HEYA2
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_3
	FLG_KI TER_NET,'=',1
LL_3:
	DB	"Её ляжки округлые и сочные."
	DB	NEXT
	GO BODY_TERUMI2
BODY_TERUMI2:
	DB	"Тэруми: В чём дело?" 
	DB	NEXT
	DB	"Кэндзиро: Э? О, ни в чём. Я просто задумался, почему ты здесь."
	DB	NEXT
	DB	"Тэруми: Просто гуляю. А ты?"
	DB	NEXT
	DB	"Кэндзиро: Я?"
	DB	NEXT
	DB	" Я? Ну, я..."
	DB	T_WAIT, 5
	DB	" Я хотел понюхать тебя..."
	DB	NEXT
	DB	"Тэруми: Ты что, собака?" 
	DB	NEXT
	DB	"Кэндзиро: Да, если, конечно, я могу быть твоей собакой."
	DB	NEXT
	DB	"Тэруми: ...Ладно, пёсик." 
	DB	NEXT
	DB	"Она улыбается, глядя на меня.."
	DB	NEXT
	DB	"О нет! Она опять замышляет что-то опасное..."
	DB	NEXT
	DB	"Тэруми: Ну? Ты не отзовёшься, пёсик?"
	DB	NEXT
	DB	"Кэндзиро: Гав!"
	DB	NEXT
	DB	"Тэруми: Хороший пёсик..." 
	DB	NEXT
	DB	"Пора сматываться."
	DB	NEXT
	DB	"Кэндзиро: Гав! Гав!"
	DB	NEXT
	DB	"Тэруми: Эй, ко мне!" 
	DB	NEXT
	DB	"Я спешно свалил оттуда."
	DB	NEXT
	GO MATI2
F4:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP05,'=',1
	DB	"В такие места днём не ходят."
	DB	NEXT
	GO MATI2
F5:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP06,'=',1
	DB	"В такие места днём не ходят."
	DB	NEXT
	GO MATI2
F6:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP07,'=',1
	DB	"Кофейня? Думаю, где-то поблизости была одна."
	DB	NEXT
	GO MATI2
F7:
	FLG_IF	TEMP01,'>=',3,JITAKU2
	DB	"Хмм, рановато домой идти."
	DB	NEXT
	GO MATI2
JITAKU2:
	BAK_INIT	'tb_018b',B_NORM
	DB	"Пожалуй, теперь пойду домой."
	DB	NEXT
	BAK_INIT 'tb_005b',B_NORM
	DB	"Заходящее солнце окрашивает мой дом в жёлтый и оранжевый цвета."
	DB	NEXT
	DB	"Хорошо для разнообразия приходить домой пораньше."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		6
	DB	"Акэми-сан здесь, но я не вижу Мотоку."
	DB	NEXT
	T_CG 'tt_20_02',AKE_A2,0
	DB	"Акэми: А, Кэндзиро. С возвращением."
	DB	NEXT
	DB	"Кэндзиро: Спасибо."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	H1,"СМОТРЕТЬ НА КЛЮЧИЦУ"
	MENU_SET	H2,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	H3,"СМОТРЕТЬ НА ЧУЛКИ"
	MENU_END
	DB	EXIT
H1:
	FLG_IF YOKU,'>=',100,HEYA2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL
	FLG_IF YOKU,'<',100,LA_1
	FLG_KI AKEM_NET,'=',1
LA_1:
	DB	"Сексуальная ключица, с хорошим ровным краем. Хотел бы я её попробовать."
	DB	NEXT
	GO BODY_AKEMI
H2:
	DB	"Её груди замечательны. Хотел бы я положить свою голову меж этих холмов."
	DB	NEXT
	GO BODY_AKEMI
H3:
	FLG_IF YOKU,'>=',100,HEYA2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_3
	FLG_KI AKEM_NET,'=',1
LA_3:
	DB	"Её чулки поднимаются к её славной промежности. Мягкие и шелковистые."
	DB	NEXT
	GO BODY_AKEMI
BODY_AKEMI:
	DB	"Акэми: Что такое?"
	DB	NEXT
	DB	"Кэндзиро: Э? О, ничего."
	DB	NEXT
	DB	"Акэми: Ты такой странный мальчик." 
	DB	NEXT
	DB	"Кэндзиро: Эм, вы не видели Мотоку?"
	DB	NEXT
	DB	"Акэми: Она у себя в комнате."
	DB	NEXT
	DB	"Кэндзиро: О."
	DB	NEXT
	B_O B_FADE,C_KURO	;F.O
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"Хмм, пожалуй, пойду спать."
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
	DB	"Кэндзиро: Ууууумммм?"
	DB	NEXT
	DB	"Я медленно открываю глаза."
	DB	NEXT
	BAK_INIT 'tb_001b',B_FADE
	DB	"Я очнулся, голова кружится. Кажется, я у себя в комнате."
	DB	NEXT
	DB	"Хотел бы я знать, что произошло?"
	DB	NEXT
	DB	"На моей одежде бурое пятно."
	DB	NEXT
	DB	"Кровь? Должно быть, у меня пошла кровь из носа."
	DB	NEXT
	DB	"Наверное, я упал. Но что случилось после этого?"
	DB	NEXT
	DB	"Должно быть, я потерял сознание."
	DB	NEXT
	DB	"Но кто отнёс меня сюда?"
	DB	NEXT
	DB	"Хммм. Ну, пожалуй, подумаю об этом после, а сейчас лучше поспать."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'JUMP.OVL'
	DB	EXIT
END