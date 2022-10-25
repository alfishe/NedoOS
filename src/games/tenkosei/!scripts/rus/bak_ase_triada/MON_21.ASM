        include SUPER_C.inc
M_START:
MON_21
	FLG_IF JUMP,'=',62,FUFUFU_1
	CDPLAY		12
	BAK_INIT 'tb_001a',B_NORM
	DB "Я толком не выспался..."
	DB	NEXT
	DB "Думаю, я оденусь и пойду позавтракаю."
	DB	NEXT
	DB "Я оделся в форму и спустился в кухню."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		20
	T_CG 'tt_21_02',MOT_A3,0
	T_CG 'tt_20_02',AKE_A1,0
	DB "Мотока:  Ах, доброе утро." 
	DB	NEXT
	DB "Кенджиру:  Доброе утро..."
	DB	NEXT
	DB "Акеми:  Привет."
	DB	NEXT
	DB "Мотока:  Мама, я уже ухожу..." 
	DB	NEXT
	DB "Акеми:  Доброго дня."
	DB	NEXT
	TATI_ERS		;Tt_21
	T_CG 'tt_20_02',AKE_A2,0
	CDPLAY		6
	DB "Акеми:  Кенджиру-кун, я не понимаю, что между вами происходит, но желаю, чтобы ты больше доверял ей."
	DB	NEXT
	DB "Кенджиру:  Ты права..."
	DB	NEXT
	DB "Сказав это, я взял свою сумку и пошел в школу."
	DB	NEXT
	BAK_INIT 'tb_006',B_NORM
	CDPLAY	2
	DB "Ночной магазинчик."
	DB	NEXT
	DB "Вообще-то я не голоден, но все-таки загляну."
	DB	NEXT
	DB "Я захожу."
	DB	NEXT
	BAK_INIT 'tb_007',B_NORM
	CDPLAY		3
	DB "Здесь Теруми-сенпай."
	DB	NEXT
	DB "Я здесь ее часто встречаю."
	DB	NEXT
	T_CG 'tt_05_07',TER2,0
	DB "Кенджиру:  А, Теруми-сенпай. Доброе утро."
	DB	NEXT
	DB "Теруми:  Доброе утро. Что случилось? Ты расстроен."
	DB	NEXT
	DB "Кенджиру:  Ничего. Я просто устал."
	DB	NEXT
	DB "Теруми:  Держу пари, опять смотрел порнуху." 
	DB	NEXT
	DB "Кенджиру:  ...Ну, немного."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	R1,"ЗВАТЬ ТЕРУМИ-СЕН"
	MENU_SET	R2,"В ШКОЛУ"
	MENU_END
	DB	EXIT
R1:
	DB "Кенджиру:  ......"
	DB	T_WAIT, 5
	DB "Теруми-сенпай, мы пойдем в школу?"
	DB	NEXT
	DB "Теруми:  А? Да, но как же твой завтрак?"
	DB	NEXT
	DB "Кенджиру:  Упс. Сейчас куплю."
	DB	NEXT
	DB "Я выбираю один рисовый шарик и иду к кассе."
	DB	NEXT
	DB "Кенджиру:  Спасибо, что подождала. Идем."
	DB	NEXT
	DB "Теруми:  Ладно" 
	DB	NEXT
	DB "Я кладу рисовый шарик в сумку, и мы покидаем магазин."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO GAKU1
R2:
	DB "Кенджиру:  Ну, увидимся позже, Теруми-сенпай..."
	DB	NEXT
	DB "Я ухожу в школу один."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_009',B_NORM
	DB "Тут очень тесно."
	DB	NEXT
	DB "Голос:  Кенджиру-кун."
	DB	NEXT
	DB "Я поворачиваюсь на звук голоса."
	DB	NEXT
	T_CG 'tt_02_09',SIH_A2,0
	DB "Шихо:   Кенджиру-кун, доброе утро."
	DB	NEXT
	DB "Кенджиру:  Привет."
	DB	NEXT
	DB "Шихо:   Что не так? Ты не похож на счастливчика." 
	DB	NEXT
	DB "Глаза Шихо встревожены."
	DB	NEXT
	DB "Кенджиру:  ...Я толком не выспался сегодня ночью."
	DB	NEXT
	DB "Шихо:   Это плохо. Тебе нужно высыпаться каждый день." 
	DB	NEXT
	DB "Кенджиру:  Ты права."
	DB	NEXT
	DB "Шихо:   Ну..."
	DB	T_WAIT, 5
	DB " Мы пойдем в школу?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	S1,"ЗА НЕЙ"
	MENU_SET	S2,"САМ"
	MENU_END
	DB	EXIT
S1:
	DB "Кенджиру:  Хорошо, пошли."
	DB	NEXT
	DB "Шихо:   Ладно" 
	DB	NEXT
	DB "Я направился к школе рядом с Шихо."
	DB	NEXT
	GO GAKU2
S2:
	DB "Кенджиру:  Прости, я хочу пойти один."
	DB	NEXT
	DB "Шихо:   ..Ладно..." 
	DB	NEXT
	DB "Я пошел в школу один."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO GAKU1
GAKU1:
	BAK_INIT 'tb_010',B_NORM
	CDPLAY		14
	T_CG 'tt_08_10',TET_A2,0
	DB "Тецуя:    Привет."
	DB	NEXT
	DB "Кенджиру:  Привет."
	DB	NEXT
	DB "Тецуя:    Как ты сегодня?"
	DB	NEXT
	DB "Кенджиру:  В порядке.."
	DB	NEXT
	DB "Тецуя:    Серьезно? Я просто супер."
	DB	NEXT
	DB "Кенджиру:  .................."
	DB	NEXT
	DB "Тецуя:    Тебе нужно ответить, делай что-нибудь!" 
	DB	NEXT
	;WAV	'Se_ch'
	DB "Как раз зазвенел звонок. Пора начинать урок."
	DB	NEXT
	DB "Кенджиру:  Прости, я просто устал."
	DB	NEXT
	DB "Тецуя:    .................." 
	DB	NEXT
	TATI_ERS		;tt_08
	DB "Я сел за свою парту."
	DB	NEXT
	F_O B_NORM,C_KURO
	;;WAV  'STOP'
	CDPLAY		0
	DB "Я уставился на доску, урок начался."
	DB	NEXT
	DB "Мои мысли все время возвращались к Мотоке и прошлой ночи, и я не мог сконцентрироваться."
	DB	NEXT
	B_O B_FADE,C_KURO
	GO HIRU_1
GAKU2:
	CDPLAY		14
	BAK_INIT 'tb_010',B_NORM
	T_CG 'tt_02_10',SIH_A1,0
	T_CG 'tt_08_10',TET_A3,0
	DB "Тецуя:    Доброе утро, Кашима-сан."
	DB	NEXT
	DB "Шихо:   Привет."
	DB	NEXT
	DB "Кенджиру:  ..............."
	DB	NEXT
	DB "Я сел за свою парту."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB "Я уставился на доску, урок начался."
	DB	NEXT
	DB "Мотока продолжала возвращаться в мои мысли, не давая сконцентрироваться на уроке."
	DB	NEXT
	B_O B_FADE,C_KURO
	F_O B_NORM,C_KURO
	DB "Пока я собрался с мыслями, был уже обед."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	CDPLAY		14
	T_CG 'tt_08_10',TET_A2,0
	DB "Тецуя:    Эй, Кенджиру?" 
	DB	NEXT
	DB "Кенджиру:  Что?"
	DB	NEXT
	DB "Тецуя:    Ну..." 
	DB	NEXT
	DB "Кенджиру:  В чем дело?"
	DB	NEXT
	DB "Тецуя:    Не злись, ладно?" 
	DB	NEXT
	DB "Кенджиру:  Злиться?.."
	DB	NEXT
	DB "Тецуя:    ...Насчет Мотоки." 
	DB	NEXT
	DB "Кенджиру:  .................."
	DB	NEXT
	DB "Тецуя:    Думаю, те слухи, что я тебе говорил, - правда."
	DB	NEXT
	DB "Кенджиру:  ...Почему ты думаешь?"
	DB	NEXT
	DB "Тецуя:    Ну, я видел девушку, похожую на Мотоку, гуляющую с кое-какими плохими людьми."
	DB	NEXT
	DB "Кенджиру:  ...Ты действительно видел?"
	DB	NEXT
	DB "Тецуя:    Да. Впрочем, я был довольно далеко, так что не уверен на сто процентов, что это была она."
	DB	NEXT
	DB "Кенджиру:  ...Это не была она. Ночью она была дома."
	DB	NEXT
	DB "Тецуя:    Серьезно? Отлично, я рад, что это не она. Мне полегчало." 
	DB	NEXT
	;WAV	'Se_ch'
	DB "В это время зазвенел звонок, и Тецуя сел на свое место."
	DB	NEXT
	TATI_ERS	;tt_08
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB "...Я соврал Тецуе."
	DB	NEXT
	DB "Ужасно чувствуя себя из-за вранья другу, я заснул."
	DB	NEXT
	;;WAV  'STOP'
	B_O B_FADE,C_KURO
HIRU_1:
	FLG_KI JUMP,'=',62
	SINARIO 'NITI_HOK.OVL'
FUFUFU_1:
	FLG_KI JUMP,'=',0
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY		22
	DB "Солнце уже зашло. В эти дни рано темнеет."
	DB	NEXT
	DB "Наверное, я пойду прямо домой."
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
	MENU_S 2,W,-1
	MENU_SET	AH1,"КИНОТЕАТР"
	MENU_SET	AH2,"СТРИП БАР"
	MENU_SET	AH3,"ПАРК"
	MENU_SET	AH4,"МОЙ ОТЕЛЬ"
	MENU_SET	AH5,"БАР"
	MENU_SET	AH6,"КАФЕ"
	MENU_SET	AH7,"РЕСТОРАН"
	MENU_SET	AH8,"ДОМОЙ"
	MENU_END
	DB EXIT
AH1:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB "Думаю, проверю кинотеатр."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB "Это место совсем заброшено."
	DB	NEXT
	DB "Ну, это далеко от места, где гуляют все люди. Этого следовало ожидать."
	DB	NEXT
	DB "Больше не на что смотреть. Наверное, я вернусь."
	DB	NEXT
	GO MATI
AH2:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB "Наверное, схожу к магазину белья."
	DB	NEXT
	BAK_INIT 'tb_027',B_NORM
	DB "Человек, который это придумал, гений. Идея, которая проникает прямо в сердце."
	DB	NEXT
	T_CG 'tt_07_27',TET_B2,0
	FLG_KI TET_KAIS,'+',1
	DB "Тецуя:    Что ты делаешь здесь?"
	DB	NEXT
	DB "Тецуя здесь."
	DB	NEXT
	DB "Кенджиру:  Я? А ты?"
	DB	NEXT
	DB "Тецуя:    Я? Я просто думаю, как здорово было бы забраться внутрь..." 
	DB	NEXT
	DB "Кенджиру:  Что?"
	DB	NEXT
	DB "Тецуя:    Ты так не считаешь?"
	DB	NEXT
	DB "Кенджиру:  Ты о чем?"
	DB	NEXT
	DB "Тецуя:    Тебе не хочется войти и получить полный сервис?" 
	DB	NEXT
	DB "Кенджиру:  ...Ну,конечно."
	DB	NEXT
	DB "Тецуя:    Видишь? Ах, всего разок, вот чего хочу." 
	DB	NEXT
	DB "Он пялится на вывеску магазина с жадным выражением глаз."
	DB	NEXT
	DB "Мне лучше оставить его."
	DB	NEXT
	GO MATI
AH3:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB "Парк. Звучит весело."
	DB	NEXT
	BAK_INIT 'tb_032b',B_NORM
	CDPLAY		8
	DB "Здесь гуляет под ручку множество парочек. Интересно, сколько их в куста?"
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
	MENU_SET	AI1,"ОСМОТР СИСЕК"
	MENU_SET	AI2,"ОСМОТР ПОПЫ"
	MENU_SET	AI3,"ОСМОТР БЕДЕР"
	MENU_END
	DB	EXIT
AI1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_1
	FLG_KI TER_NET,'=',1
LA_1:
	DB "Ее сиськи прекрасны. Большого объема."
	DB	NEXT
	GO BODY_TERUMI
AI2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_2
	FLG_KI TER_NET,'=',1
LA_2:
	DB "У нее прекрасная мягкая попка, отличная линия от талии."
	DB	NEXT
	GO BODY_TERUMI
AI3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_3
	FLG_KI TER_NET,'=',1
LA_3:
	DB "Ее бедра мягкие и плавные. Мммм."
	DB	NEXT
	GO BODY_TERUMI
BODY_TERUMI:
	DB "Теруми:  Ч- Что не так? Ты внезапно умолк." 
	DB	NEXT
	DB "Кенджиру:  А? О- О, ничего. А что ты делаешь здесь одна?"
	DB	NEXT
	DB "Теруми:  Я просто вышла погулять."
	DB	NEXT
	DB "Кенджиру:  Одна? В такой темноте?"
	DB	NEXT
	DB "Теруми:  Ты беспокоишься обо мне?"
	DB	NEXT
	DB "Мгновение она кажется радой."
	DB	NEXT
	DB "Кенджиру:  Да, на тебя ведь могут напасть..."
	DB	NEXT
	DB "Теруми:  Ч- Что ты сказал?" 
	DB	NEXT
	DB "Кенджиру:  Мне-Мне жаль!"
	DB	NEXT
	DB "Я быстро смылся оттуда."
	DB	NEXT
	GO MATI
AH4:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB "Отель любви. Никогда не был внутри."
	DB	NEXT
	BAK_INIT 'tb_025',B_NORM
	DB "Висит вывеска, рекламируя расценки отеля."
	DB	NEXT
	DB "Это не лучшее место для одиночества."
	DB	NEXT
	GO MATI
AH5:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB "Я не слишком хочу войти внутрь."
	DB	NEXT
	DB "Думаю, я выйду и посмотрю, в чем дело."
	DB	NEXT
	DB "Я иду в бар."
	DB	NEXT
	BAK_INIT 'tb_029',B_NORM
	T_CG 'tt_03_29',HIR2,0
	DB "Хироши:   Что ты делаешь здесь?" 
	DB	NEXT
	DB "О, нет! Это Хироши!"
	DB	NEXT
	DB "Кенджиру:  О, я просто проходил мимо. Ну, увидимся позже."
	DB	NEXT
	DB "Я покидаю бар."
	DB	NEXT
	GO MATI
AH6:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB "Кофейня... Интересно, Рена там еще работает?"
	DB	NEXT
	BAK_INIT 'tb_21',B_NORM
	T_CG 'tt_17_21',REN_A2,0
	DB "Рена:  Я могу..." 
	DB	T_WAIT, 5
	DB " О, это просто ты, Кенджиру."
	DB	NEXT
	DB "Кенджиру:  Ты даже не поприветствуешь меня в магазине?"
	DB	NEXT
	DB "Рена:  Но это для клиентов. А ты другой."
	DB	NEXT
	DB "Кенджиру:  Да, да. Я знаю, почему меня холодно встречают."
	DB	NEXT
	DB "Рена:  Прости.."
	DB	NEXT
	DB "Кенджиру:  Между прочим, тебе не холодно, в такой одежде?"
	DB	NEXT
	DB "Рена:  Да вообще-то нормально."
	DB	NEXT
	DB "Кенджиру:  Ясно. (Мне холодно смотреть.)"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AJ1,"ОСМОТР ШЕИ"
	MENU_SET	AJ2,"ОСМОТР ПЛЕЧ"
	MENU_SET	AJ3,"ОСМОТР СИСЕК"
	MENU_END
	DB	EXIT
AJ1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_1
	FLG_KI RENA_NET,'=',1
LL_1:
	DB "У нее красивая белая шея, как раз для поцелуев."
	DB	NEXT
	GO BODY_RENA
AJ2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',7
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_2
	FLG_KI RENA_NET,'=',1
LL_2:
	DB "Мягкие, женственные плечи. Такие приятно обнимать."
	DB	NEXT
	GO BODY_RENA
AJ3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_3
	FLG_KI RENA_NET,'=',1
LL_3:
	DB "Я не могу видеть ее груди через фартук. Но они молочно-белые и такие мягкие..."
	DB	NEXT
BODY_RENA:
	DB "Рена:  А, твои глаза." 
	DB	T_WAIT, 5
	DB " У тебя грязные мысли, не так ли?"
	DB	NEXT
	DB "Кенджиру:  Возможно."
	DB	NEXT
	DB "Рена:  Между нами больше ничего нет, ладно? Это все в прошлом."
	DB	NEXT
	DB "Кенджиру:  Знаю. (Но сожалею об этом)"
	DB	NEXT
	DB "Рена:  Ну, ладно." 
	DB	NEXT
	DB "Она хлопает меня по голове."
	DB	NEXT
	DB "Кенджиру:  Хаха..."
	DB	T_WAIT, 5
	DB " Спасибо"
	DB	NEXT
	DB "Вот почему я сожалею..."
	DB	NEXT
	DB "Я покидаю кофейню."
	DB	NEXT
	GO MATI
AH7:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB "Я не голоден, но что за черт. Я могу войти."
	DB	NEXT
	BAK_INIT 'tb_023',B_NORM
	DB "Нана:  Привет, я могу помочь?"
	DB	NEXT
	DB "Кенджиру:  А, ты здесь. Отлично."
	DB	NEXT
	DB "Нана:  Что бы ты хотел заказать?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	AK1,"ОСМОТР СИСЕК"
	MENU_SET	AK2,"ОСМОТР СИСЕК"
	MENU_SET	AK3,"ОСМОТР СИСЕК"
	MENU_END
	DB	EXIT
AK1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LS_1
	FLG_KI NANA_NET,'=',1
LS_1:
	DB "Отличные груди"
	DB	NEXT
	GO BODY_NANA
AK2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LS_2
	FLG_KI NANA_NET,'=',1
LS_2:
	DB "Прекрасные груди."
	DB	NEXT
	GO BODY_NANA
AK3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LS_3
	FLG_KI NANA_NET,'=',1
LS_3:
	DB "Они будто бы готовы прорвать ее униформу."
	DB	NEXT
	GO BODY_NANA
BODY_NANA:
	DB "Нана:  Что бы ты хотел заказать?"
	DB	NEXT
	DB "Кенджиру:  Груди..."
	DB	NEXT
	DB "Нана:  Простите, у нас нет этого в меню."
	DB	NEXT
	DB "Кенджиру:  Тогда забудьте."
	DB	NEXT
	DB "Нана:  Большое спасибо. Пожалуйста, заходите."
	DB	NEXT
	DB "Я покидаю ресторан."
	DB	NEXT
	GO MATI
AH8:
	DB "Пожалуй, я пойду домой..."
	DB	NEXT
	GO JITAKU
JITAKU:
	BAK_INIT	'tb_018c',B_NORM
	DB "Ну, пора идти домой."
	DB	NEXT
	BAK_INIT 'tb_005c',B_NORM
	DB "Ах, нет ничего прекраснее чем прийти домой после долгого дня"
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		6
	T_CG 'tt_20_02',AKE_A2,0
	DB "Кенджиру:  Я дома."
	DB	NEXT
	DB "Акеми:  Дома."
	DB	NEXT
	DB "Кенджиру:  Где Мотока?"
	DB	NEXT
	DB "Акеми:  Ее еще нет дома." 
	DB	NEXT
	DB "Кенджиру:  Ясно. (Опять...?)"
	DB	NEXT
	DB "Акеми:  Мы пообедаем?" 
	DB	NEXT
	DB "Кенджиру:  ...Конечно, отлично."
	DB	NEXT
	DB "Акеми:  Ладно"
	DB	NEXT
	DB "Мы вдвоем молча едим. Акеми откладывает порцию Мотоки."
	DB	NEXT
	B_O B_FADE,C_KURO
	SINARIO 'MON_22.OVL'
HEYA:
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_NORM,C_KURO
	DB "Кенджиру:  Ууннн...?"
	DB	NEXT
	DB "Я медленно подымаю тяжелые веки"
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB "Где я?"
	DB	NEXT
	DB "Я оглядываюсь. Кажется, я в своей комнате."
	DB	NEXT
	DB "Но как я попал сюда?"
	DB	NEXT
	DB "Я смотрю вниз и вижу коричневое пятно на одежде"
	DB	NEXT
	DB "Кровь? О, она пошла из носа..."
	DB	NEXT
	DB "Что случилось после того?"
	DB	NEXT
	DB "Я, наверное, потерял сознание."
	DB	NEXT
	DB "Кто-то, наверное, принес меня сюда. Но кто?"
	DB	NEXT
	DB "Я смотрю на часы. Половина десятого."
	DB	NEXT
	DB "Интересно, Мотока дома?"
	DB	NEXT
	DB "Я одеваюсь и иду к комнате Мотоки."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB "Я стучу несколько раз. Никакого ответа."
	DB	NEXT
	DB "Может, она на кухне."
	DB	NEXT
	DB "Я спускаюсь вниз."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	DB "На столе по-прежнему обед Мотоки, накрытый пластиковой крышкой."
	DB	NEXT
	DB "Так, она еще не дома."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB "Я возвращаюсь в свою комнату и ложусь, ожидая Мотоку. Около 10 часов я слышу какие-то звуки в фойе."
	DB	NEXT
	DB "Я встаю, но помню слова Акеми этим утром."
	DB	NEXT
	DB "Она сказала мне верить Мотоке."
	DB	T_WAIT, 3
	DB " Ну, я так и сделаю."
	DB	NEXT
	DB "С Мотокой все будет хорошо. Я должен верить"
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB "Я выключаю свет и сплю."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_22.OVL'
END
