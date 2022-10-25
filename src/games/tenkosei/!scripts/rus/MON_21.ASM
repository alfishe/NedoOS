        include SUPER_C.inc
M_START:
MON_21
	FLG_IF JUMP,'=',62,FUFUFU_1
	CDPLAY		12
	BAK_INIT 'tb_001a',B_NORM
	DB	"Я толком не выспался..."
	DB	NEXT
	DB	"Пожалуй, оденусь и пойду завтракать."
	DB	NEXT
	DB	"Я надеваю школьную форму и спускаюсь на кухню."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		20
	T_CG 'tt_21_02',MOT_A3,0
	T_CG 'tt_20_02',AKE_A1,0
	DB	"Мотока: А, доброе утро." 
	DB	NEXT
	DB	"Кэндзиро: Доброе утро..."
	DB	NEXT
	DB	"Акэми: Доброе утро."
	DB	NEXT
	DB	"Мотока: Мама, я пошла..." 
	DB	NEXT
	DB	"Акэми: Хорошего дня."
	DB	NEXT
	TATI_ERS		;Tt_21
	T_CG 'tt_20_02',AKE_A2,0
	CDPLAY		6
	DB	"Акэми: Кэндзиро-кун, не знаю, что между вами происходит, но я бы хотела, что бы ты доверял ей немного больше."
	DB	NEXT
	DB	"Кэндзиро: Вы правы..."
	DB	NEXT
	DB	"После этого, я взял портфель и пошёл в школу."
	DB	NEXT
	BAK_INIT 'tb_006',B_NORM
	CDPLAY	2
	DB	"Магазин."
	DB	NEXT
	DB	"Сейчас я не очень голоден, но, пожалуй, зайду."
	DB	NEXT
	DB	"Я направляюсь внутрь."
	DB	NEXT
	BAK_INIT 'tb_007',B_NORM
	CDPLAY		3
	DB	"Здесь Тэруми-сэмпай."
	DB	NEXT
	DB	"Я довольно часто её здесь встречаю."
	DB	NEXT
	T_CG 'tt_05_07',TER2,0
	DB	"Кэндзиро: А, Тэруми-сэмпай. Доброе утро."
	DB	NEXT
	DB	"Тэруми: Доброе утро. В чём дело? Ты выглядишь подавленным."
	DB	NEXT
	DB	"Кэндзиро: Ни в чём, просто устал."
	DB	NEXT
	DB	"Тэруми: Бьюсь об заклад, ты опять смотрел порнуху." 
	DB	NEXT
	DB	"Кэндзиро: ...Ну, немного."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	R1,"ПРИГЛАСИТЬ ТЭРУМИ-СЭМПАЙ"
	MENU_SET	R2,"ПОЙТИ В ШКОЛУ"
	MENU_END
	DB	EXIT
R1:
	DB	"Кэндзиро: ......"
	DB	T_WAIT, 5
	DB	"Тэруми-сэмпай, не пора ли нам в школу?"
	DB	NEXT
	DB	"Тэруми: Э? О, конечно, но как насчёт твоего обеда?"
	DB	NEXT
	DB	"Кэндзиро: Упс. Сейчас возьму."
	DB	NEXT
	DB	"Я беру рисовый колобок и направляюсь на кассу."
	DB	NEXT
	DB	"Кэндзиро: Спасибо, что подождала. Пошли."
	DB	NEXT
	DB	"Тэруми: Хорошо." 
	DB	NEXT
	DB	"Я кладу в портфель рисовый колобок, и мы выходим из магазина."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO GAKU1
R2:
	DB	"Кэндзиро: До встречи, Тэруми-сэмпай..."
	DB	NEXT
	DB	"Я пошёл в школу один."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_009',B_NORM
	DB	"Здесь большая толпа."
	DB	NEXT
	DB	"Голос: Кэндзиро-кун."
	DB	NEXT
	DB	"Я поворачиваюсь на звук голоса."
	DB	NEXT
	T_CG 'tt_02_09',SIH_A2,0
	DB	"Сихо: Кэндзиро-кун, доброе утро."
	DB	NEXT
	DB	"Кэндзиро: Доброе утро."
	DB	NEXT
	DB	"Сихо: В чём дело? Ты сегодня не очень радостный." 
	DB	NEXT
	DB	"Взгляд у Сихо стал обеспокоенным."
	DB	NEXT
	DB	"Кэндзиро: ...Я толком не выспался."
	DB	NEXT
	DB	"Сихо: Это плохо. Тебе нужно как следует высыпаться каждый день." 
	DB	NEXT
	DB	"Кэндзиро: Ты права."
	DB	NEXT
	DB	"Сихо: Ну что..."
	DB	T_WAIT, 5
	DB	" Пойдём в школу?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	S1,"ПОЙТИ С НЕЙ"
	MENU_SET	S2,"ПОЙТИ ОДНОМУ"
	MENU_END
	DB	EXIT
S1:
	DB	"Кэндзиро: Ладно, пошли."
	DB	NEXT
	DB	"Сихо: Хорошо." 
	DB	NEXT
	DB	"Я пошёл в школу вместе с Сихо."
	DB	NEXT
	GO GAKU2
S2:
	DB	"Кэндзиро: Извини, я хочу пойти один."
	DB	NEXT
	DB	"Сихо: ...Ладно..." 
	DB	NEXT
	DB	"Я пошёл в школу один."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO GAKU1
GAKU1:
	BAK_INIT 'tb_010',B_NORM
	CDPLAY		14
	T_CG 'tt_08_10',TET_A2,0
	DB	"Тэцуя: Доброе утро."
	DB	NEXT
	DB	"Кэндзиро: Доброе утро."
	DB	NEXT
	DB	"Тэцуя: Как ты сегодня?"
	DB	NEXT
	DB	"Кэндзиро: Нормально..."
	DB	NEXT
	DB	"Тэцуя: Правда? Я этому рад."
	DB	NEXT
	DB	"Кэндзиро: .................."
	DB	NEXT
	DB	"Тэцуя: Тебе бы надо отреагировать, сделай что-нибудь!" 
	DB	NEXT
	;WAV	'Se_ch'
	DB	"И тут прозвенел звонок. Начались уроки."
	DB	NEXT
	DB	"Кэндзиро: Извини, я просто устал."
	DB	NEXT
	DB	"Тэцуя: .................." 
	DB	NEXT
	TATI_ERS		;tt_08
	DB	"Я сел за парту."
	DB	NEXT
	F_O B_NORM,C_KURO
	;WAV  'STOP'
	CDPLAY		0
	DB	"Я смотрел на доску, когда начался урок."
	DB	NEXT
	DB	"Мои мысли возвращались к Мотоке и вчерашнему вечеру, и я не мог сосредоточиться на уроке."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO HIRU_1
GAKU2:
	CDPLAY		14
	BAK_INIT 'tb_010',B_NORM
	T_CG 'tt_02_10',SIH_A1,0
	T_CG 'tt_08_10',TET_A3,0
	DB	"Тэцуя: Доброе утро, Касима-сан."
	DB	NEXT
	DB	"Сихо: Доброе утро."
	DB	NEXT
	DB	"Кэндзиро: ..............."
	DB	NEXT
	DB	"Я сажусь за парту."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"Я смотрел на доску, когда начался урок."
	DB	NEXT
	DB	"Мотока возникала в моих мыслях, не давая мне сконцентрироваться на уроке."
	DB	NEXT
	B_O B_FADE,C_KURO
	F_O B_NORM,C_KURO
	DB	"Следующее, что я осознал, это наступление обеда."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	CDPLAY		14
	T_CG 'tt_08_10',TET_A2,0
	DB	"Тэцуя: Эм, Кэндзиро?" 
	DB	NEXT
	DB	"Кэндзиро: Что?"
	DB	NEXT
	DB	"Тэцуя: Ну..." 
	DB	NEXT
	DB	"Кэндзиро: Что такое?"
	DB	NEXT
	DB	"Тэцуя: Не сердись, ладно?" 
	DB	NEXT
	DB	"Кэндзиро: Сердиться? С чего это?"
	DB	NEXT
	DB	"Тэцуя: ...Это насчёт Мотоки." 
	DB	NEXT
	DB	"Кэндзиро: .................."
	DB	NEXT
	DB	"Тэцуя: Думаю, что слухи, которые я тебе рассказал - правда."
	DB	NEXT
	DB	"Кэндзиро: ...Почему ты так говоришь?"
	DB	NEXT
	DB	"Тэцуя: Ну, я видел девушку, очень похожую на Мотоку, она гуляла с плохими людьми."
	DB	NEXT
	DB	"Кэндзиро: ...Ты в самом деле это видел?"
	DB	NEXT
	DB	"Тэцуя: Да. Хотя, я был далековато, так что не могу утверждать на сто процентов, что это была она."
	DB	NEXT
	DB	"Кэндзиро: ...Это была не она. Вчера вечером она была дома."
	DB	NEXT
	DB	"Тэцуя: Правда? О, отлично, я рад, что это была не она. Просто камень с души." 
	DB	NEXT
	;WAV	'Se_ch'
	DB	"И тут прозвенел звонок, и Тэцуя сел на место."
	DB	NEXT
	TATI_ERS	;tt_08
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"...Я солгал Тэцуе."
	DB	NEXT
	DB	"Чувствуя себя ужасно от того, что солгал, я опять заснул."
	DB	NEXT
	;WAV  'STOP'
	B_O B_FADE,C_KURO
HIRU_1:
	FLG_KI JUMP,'=',62
	SINARIO 'NITI_HOK.OVL'
FUFUFU_1:
	FLG_KI JUMP,'=',0
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY		22
	DB	"Солнце садится. В это время очень рано темнеет."
	DB	NEXT
	DB	"Пожалуй, пока домой не пойду."
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
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY		22
	DB	"Куда мне пойти?"
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
	MENU_S 2,W,-1
	MENU_SET	AH1,"В КИНОТЕАТР"
	MENU_SET	AH2,"В БАР НИЖНЕГО БЕЛЬЯ"
	MENU_SET	AH3,"В ПАРК"
	MENU_SET	AH4,"В ОТЕЛЬ ЛЮБВИ"
	MENU_SET	AH5,"В БАР"
	MENU_SET	AH6,"В КОФЕЙНЮ"
	MENU_SET	AH7,"В РЕСТОРАН"
	MENU_SET	AH8,"ДОМОЙ"
	MENU_END
	DB EXIT
AH1:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"Пожалуй, схожу в кино."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB	"Этот кинотеатр -- захудалое местечко."
	DB	NEXT
	DB	"Ну, он находится в стороне от оживлённых улиц. Это всё объясняет."
	DB	NEXT
	DB	"Смотреть нечего. Пожалуй, пойду назад."
	DB	NEXT
	GO MATI
AH2:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"Пожалуй, схожу в бар нижнего белья."
	DB	NEXT
	BAK_INIT 'tb_027',B_NORM
	DB	"Боже, тот кто придумал это место -- гений. Озвучить идею, которая есть в душе каждого мужчины."
	DB	NEXT
	T_CG 'tt_07_27',TET_B2,0
	FLG_KI TET_KAIS,'+',1
	DB	"Тэцуя: Что ты здесь делаешь?"
	DB	NEXT
	DB	"Здесь Тэцуя."
	DB	NEXT
	DB	"Кэндзиро: Я? А ты что?"
	DB	NEXT
	DB	"Тэцуя: Я? Просто думаю о том, как было бы здорово войти внутрь..." 
	DB	NEXT
	DB	"Кэндзиро: Что?"
	DB	NEXT
	DB	"Тэцуя: Ты так не считаешь?"
	DB	NEXT
	DB	"Кэндзиро: Что не считаю?"
	DB	NEXT
	DB	"Тэцуя: Ты не хотел бы зайти сюда, чтобы тебя обслужили по полной?" 
	DB	NEXT
	DB	"Кэндзиро: ...Ну, конечно."
	DB	NEXT
	DB	"Тэцуя: Видишь? Ах, хоть разок, это всё, чего я прошу..." 
	DB	NEXT
	DB	"Он пялится на вывеску бара похотливым взглядом."
	DB	NEXT
	DB	"Лучше оставить его в покое."
	DB	NEXT
	GO MATI
AH3:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"Парк. Звучит весело."
	DB	NEXT
	BAK_INIT 'tb_032b',B_NORM
	CDPLAY		8
	DB	"Здесь много парочек, гуляющих взявшись за руки. Интересно, а в кустах их сколько?"
	DB	NEXT
	DB	"Тэруми: Что ты здесь делаешь?"
	DB	NEXT
	DB	"Я слышал этот голос раньше. Я поворачиваюсь и вижу Тэруми-сэмпай."
	DB	NEXT
	T_CG 'tt_05_32b',TER2,0
	DB	"Кэндзиро: А, Тэруми-сэмпай."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AI1,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	AI2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	AI3,"СМОТРЕТЬ НА ЛЯЖКИ"
	MENU_END
	DB	EXIT
AI1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_1
	FLG_KI TER_NET,'=',1
LA_1:
	DB	"У неё замечательные сиськи. Такие пышные."
	DB	NEXT
	GO BODY_TERUMI
AI2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_2
	FLG_KI TER_NET,'=',1
LA_2:
	DB	"У неё хорошенькая, мягкая задница, с отличным изгибом бёдер."
	DB	NEXT
	GO BODY_TERUMI
AI3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_3
	FLG_KI TER_NET,'=',1
LA_3:
	DB	"Её ляжки мягкие и гладкие. Мммм."
	DB	NEXT
	GO BODY_TERUMI
BODY_TERUMI:
	DB	"Тэруми: В-в чём дело? Ты вдруг затих." 
	DB	NEXT
	DB	"Кэндзиро: Э? О, н-ни в чём. И вообще, что это ты тут делаешь одна?"
	DB	NEXT
	DB	"Тэруми: Просто вышла погулять."
	DB	NEXT
	DB	"Кэндзиро: Одна? В таких потёмках?"
	DB	NEXT
	DB	"Тэруми: Ты за меня волнуешься?"
	DB	NEXT
	DB	"На мгновение она выглядела довольной."
	DB	NEXT
	DB	"Кэндзиро: Да, я волнуюсь, что на тебя могут напасть..."
	DB	NEXT
	DB	"Тэруми: X-что ты сказал?" 
	DB	NEXT
	DB	"Кэндзиро: И-извини!"
	DB	NEXT
	DB	"Я быстро убрался отсюда."
	DB	NEXT
	GO MATI
AH4:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"Отель любви. Никогда не был внутри."
	DB	NEXT
	BAK_INIT 'tb_025',B_NORM
	DB	"Здесь вывеска со стоимостью номеров."
	DB	NEXT
	DB	"Это не лучшее место, чтобы находиться одному."
	DB	NEXT
	GO MATI
AH5:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"Мне не очень хочется заходить туда."
	DB	NEXT
	DB	"Пожалуй, пойду и посмотрю, что творится перед ним."
	DB	NEXT
	DB	"Я направляюсь к бару."
	DB	NEXT
	BAK_INIT 'tb_029',B_NORM
	T_CG 'tt_03_29',HIR2,0
	DB	"Хироси: Что ты тут делаешь?" 
	DB	NEXT
	DB	"О нет! Это Хироси!"
	DB	NEXT
	DB	"Кэндзиро: О, я просто шёл мимо. Ну, до встречи."
	DB	NEXT
	DB	"Я ухожу от бара."
	DB	NEXT
	GO MATI
AH6:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB	"Кофейня... Интересно, Рэна там ещё работает."
	DB	NEXT
	BAK_INIT 'tb_21',B_NORM
	T_CG 'tt_17_21',REN_A2,0
	DB	"Рэна: Чем могу быть..." 
	DB	T_WAIT, 5
	DB	" О, это ты, Кэндзиро."
	DB	NEXT
	DB	"Кэндзиро: Ты даже не собираешься меня поприветствовать?"
	DB	NEXT
	DB	"Рэна: Но это для посетителей. Ты другое дело."
	DB	NEXT
	DB	"Кэндзиро: Да, да. Знаю, почему меня здесь так холодно принимают."
	DB	NEXT
	DB	"Рэна: Прости..."
	DB	NEXT
	DB	"Кэндзиро: Кстати, тебе не холодно в такой одежде?"
	DB	NEXT
	DB	"Рэна: Нормально, всё просто замечательно."
	DB	NEXT
	DB	"Кэндзиро: Ладно. (От её взгляда мне самому становится прохладно.)"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AJ1,"СМОТРЕТЬ НА ШЕЮ"
	MENU_SET	AJ2,"СМОТРЕТЬ НА ПЛЕЧИ"
	MENU_SET	AJ3,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_END
	DB	EXIT
AJ1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_1
	FLG_KI RENA_NET,'=',1
LL_1:
	DB	"У неё красивая, белая шейка -- самое то для поцелуев."
	DB	NEXT
	GO BODY_RENA
AJ2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',7
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_2
	FLG_KI RENA_NET,'=',1
LL_2:
	DB	"Мягкие, женственные плечи. Хорошо обнимать девушку за такие."
	DB	NEXT
	GO BODY_RENA
AJ3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_3
	FLG_KI RENA_NET,'=',1
LL_3:
	DB	"Я не вижу грудь под фартуком, но она молочно-белая и такая мягкая..."
	DB	NEXT
BODY_RENA:
	DB	"Рэна: А, твои глаза." 
	DB	T_WAIT, 5
	DB	" У тебя грязные мысли, не так ли?"
	DB	NEXT
	DB	"Кэндзиро: Признаю это."
	DB	NEXT
	DB	"Рэна: Между нами всё кончено, идёт? Это всё в прошлом."
	DB	NEXT
	DB	"Кэндзиро: Я знаю. (Но сожалею об этом)"
	DB	NEXT
	DB	"Рэна: Тогда ладно." 
	DB	NEXT
	DB	"Она гладит меня по голове."
	DB	NEXT
	DB	"Кэндзиро: Хаха..."
	DB	T_WAIT, 5
	DB	" Спасибо."
	DB	NEXT
	DB	"Вот поэтому я и жалею..."
	DB	NEXT
	DB	"Я выхожу из кофейни."
	DB	NEXT
	GO MATI
AH7:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB	"Я не голоден, но, какого хрена? Могу и сходить туда."
	DB	NEXT
	BAK_INIT 'tb_023',B_NORM
	DB	"Нана: Здравствуйте, чем могу быть полезна?"
	DB	NEXT
	DB	"Кэндзиро: А, ты здесь. Здорово."
	DB	NEXT
	DB	"Нана: Что бы вы хотели заказать?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AK1,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	AK2,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	AK3,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_END
	DB	EXIT
AK1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LS_1
	FLG_KI NANA_NET,'=',1
LS_1:
	DB	"Великолепные сиськи."
	DB	NEXT
	GO BODY_NANA
AK2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LS_2
	FLG_KI NANA_NET,'=',1
LS_2:
	DB	"Замечательные сиськи."
	DB	NEXT
	GO BODY_NANA
AK3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LS_3
	FLG_KI NANA_NET,'=',1
LS_3:
	DB	"Выглядят так, словно готовы в любую секунду разорвать её форму."
	DB	NEXT
	GO BODY_NANA
BODY_NANA:
	DB	"Нана: Что бы вы хотели заказать?"
	DB	NEXT
	DB	"Кэндзиро: Грудку..."
	DB	NEXT
	DB	"Нана: Извините, в этом ресторане такого нет."
	DB	NEXT
	DB	"Кэндзиро: Тогда ничего."
	DB	NEXT
	DB	"Нана: Большое спасибо. Приходите ещё."
	DB	NEXT
	DB	"Я выхожу из ресторана."
	DB	NEXT
	GO MATI
AH8:
	DB	"Пожалуй, пойду домой..."
	DB	NEXT
	GO JITAKU
JITAKU:
	BAK_INIT	'tb_018c',B_NORM
	DB	"Ну, пора идти домой."
	DB	NEXT
	BAK_INIT 'tb_005c',B_NORM
	DB	"Ах, нет ничего приятнее, чем увидеть дом после долгого дня."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		6
	T_CG 'tt_20_02',AKE_A2,0
	DB	"Кэндзиро: Я вернулся."
	DB	NEXT
	DB	"Акэми: Добро пожаловать домой."
	DB	NEXT
	DB	"Кэндзиро: Где Мотока?"
	DB	NEXT
	DB	"Акэми: Она ещё не пришла." 
	DB	NEXT
	DB	"Кэндзиро: Ясно. (Опять?..)"
	DB	NEXT
	DB	"Акэми: Будем ужинать?" 
	DB	NEXT
	DB	"Кэндзиро: ...Конечно, звучит хорошо."
	DB	NEXT
	DB	"Акэми: Ладно."
	DB	NEXT
	DB	"Мы тихо поужинали вдвоём. Акэми оставила порцию Мотоки на потом."
	DB	NEXT
	B_O B_FADE,C_KURO
	SINARIO 'MON_22.OVL'
HEYA:
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_NORM,C_KURO
	DB	"Кэндзиро: Умммгх?.."
	DB	NEXT
	DB	"Я медленно поднимаю тяжёлые веки."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"Где я?"
	DB	NEXT
	DB	"Я осматриваюсь. Кажется, я у себя в комнате."
	DB	NEXT
	DB	"Но как я сюда попал?"
	DB	NEXT
	DB	"Я наклоняюсь и вижу бурое пятно на одежде."
	DB	NEXT
	DB	"Кровь? О, у меня полила кровь из носа..."
	DB	NEXT
	DB	"Что случилось после этого?"
	DB	NEXT
	DB	"Должно быть, я потерял сознание."
	DB	NEXT
	DB	"Кто-то, должно быть, отнёс меня сюда. Но кто?"
	DB	NEXT
	DB	"Я смотрю на часы. Они показывают полдесятого."
	DB	NEXT
	DB	"Интересно, Мотока дома?"
	DB	NEXT
	DB	"Я переодеваюсь и иду к комнате Мотоки."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"Я несколько раз стучу в дверь. Ответа нет."
	DB	NEXT
	DB	"Может быть, она на кухне?"
	DB	NEXT
	DB	"Я спускаюсь вниз."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	DB	"Обед Мотоки всё ещё на столе, завёрнутый в целлофан."
	DB	NEXT
	DB	"Значит, она ещё не пришла."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"Я возвращаюсь к себе в комнату и ложусь, ожидая, когда вернётся Мотока. Около десяти я слышу звуки, доносящиеся из прихожей."
	DB	NEXT
	DB	"Я начинаю вставать, но вспоминаю слова Акэми, сказанные этим утром."
	DB	NEXT
	DB	"Она сказала, чтобы я доверял Мотоке..."
	DB	T_WAIT, 3
	DB	" Ну, пожалуй, можно так и сделать."
	DB	NEXT
	DB	"С Мотокой всё будет хорошо. Я должен ей доверять."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"Я гашу свет и засыпаю."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_22.OVL'
END