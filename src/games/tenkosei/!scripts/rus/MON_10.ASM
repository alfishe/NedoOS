        include SUPER_C.inc
M_START:
MON_10
	FLG_IF HOK,'=',2,HUHUHU
	F_O B_NORM,C_KURO
	DB	"Кэндзиро: Хррр... (...Я такой сонный...)"
	DB	NEXT
	DB	"Кэндзиро: ........................................................................................................"
	DB	NEXT
	CDPLAY	14
	F_O B_NORM,C_KURO
	DB	"Голос: Эй! Проснись!"
	DB	NEXT
	DB	"Кэндзиро: .....Мм?"
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB	"Тэцуя: Наконец-то встал."
	DB	NEXT
	DB	"Я поднял голову с парты и посмотрел на Тэцую."
	DB	NEXT
	T_CG 'tt_08_10',TET_A2,0
	DB	"Тэцуя: Уже обед. Пора вставать."
	DB	NEXT
	DB	"Кэндзиро: Ой, ты прав."
	DB	NEXT
	DB	"Тэцуя: Ну, я пошёл. Увидимся." 
	DB	NEXT
	TATI_ERS
	DB	"Кэндзиро: Наслаждайся."
	DB	NEXT
	DB	"Пожалуй, я тоже куда-нибудь прошвырнусь."
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
	DB	"Итак, куда мне пойти?"
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
	MENU_SET	C1,"ВЕРНУТЬСЯ В КЛАСС"
	MENU_SET	C2,"НА КРЫШУ"
	MENU_SET	C3,"В КАБИНЕТ МУЗЫКИ"
	MENU_SET	C4,"В СПОРТЗАЛ"
	MENU_SET	C5,"В КАБИНЕТ ИЗО"
	MENU_SET	C6,"В МУЖСКОЙ ТУАЛЕТ"
	MENU_END
	DB	EXIT
C1:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"Я возвращаюсь назад в класс."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB	"Сегодня, как и вчера, перед Сихо стена из девчонок. Мне к ней никак не подобраться."
	DB	NEXT
	GO ROUKA
C2:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"Пожалуй, пойду на крышу."
	DB	NEXT
	BAK_INIT 'tb_012',B_NORM
	DB	"На крыше, возле сетчатой ограды, стоит Тэруми-сэмпай."
	DB	NEXT
	T_CG 'tt_05_12',TER2,0
	DB	"Кэндзиро: Тэруми-сэмпай."
	DB	NEXT
	DB	"Тэруми: А, Кэндзиро."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	D1,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	D2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	D3,"СМОТЕРТЬ НА НОГИ"
	MENU_END
	DB	EXIT
D1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'	;
	DB	"У неё классные сиськи. Правая, должно быть, чуть больше левой."
	DB	NEXT
	GO BODY
D2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Ах, клёвая задница. Отличная форма бёдер."
	DB	NEXT
	GO BODY
D3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Классные ножки. Такие длинные."
	DB	NEXT
	GO BODY
BODY:
	DB	"Тэруми: В чём дело? Почему ты на меня так смотришь?"
	DB	NEXT
	DB	"Кэндзиро: Я н-не смотрю. А вообще, что ты тут делаешь?"
	DB	NEXT
	DB	"Тэруми: Ничего. Просто слоняюсь по школе. А ты?"
	DB	NEXT
	DB	"Кэндзиро: О, тоже ничего. Просто смотрю, что тут наверху."
	DB	NEXT
	DB	"Тэруми: У тебя определённо полно свободного времени."
	DB	NEXT
	DB	"Кэндзиро: Как и у тебя."
	DB	NEXT
	DB	"Тэруми: У меня? Ну ты..." 
	DB	NEXT
	DB	"Изображая злобу, она подошла ко мне со сжатыми кулаками."
	DB	NEXT
	DB	"Кэндзиро: Хахаха (Хмм, пойду-ка я отсюда, на всякий случай.)"
	DB	NEXT
	DB	"Кэндзиро: Ну, пока, Тэруми-сэмпай!"
	DB	NEXT
	DB	"Тэруми: Эй ты, подожди!" 
	DB	NEXT
	DB	"Я живо смотался с крыши."
	DB	NEXT
	GO ROUKA
C3:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	BAK_INIT	'tb_010',B_NORM
	DB	"Когда я вошёл в кабинет, ко мне подбежала Мотока."
	DB	NEXT
	T_CG 'tt_10_10',MOT_A2,0
	DB	"Мотока: Ониитян!"
	DB	NEXT
	DB	"Мотока: В чём дело?"
	DB	NEXT
	DB	"Кэндзиро: Ни в чём."
	DB	NEXT
	DB	"Мотока: Ни в чём? Но должна быть причина, почему ты здесь, верно?"
	DB	NEXT
	DB	"Кэндзиро: Нет, никакой."
	DB	NEXT
	DB	"Мотока: Знаю! Ты соскучился и пришёл взглянуть на моё милое личико." 
	DB	NEXT
	DB	"Кэндзиро: Нет, я просто проходил мимо твоего класса."
	DB	NEXT
	DB	"Мотока: Это не смешно." 
	DB	NEXT
	DB	"Мотока: Но важно, что ты пришёл повидать меня, верно?"
	DB	NEXT
	DB	"Лучше уйти, пока не я не попал в очередное щекотливое положение..."
	DB	NEXT
	DB	"Кэндзиро: Ну, пока."
	DB	NEXT
	DB	"Мотока: Ониитян!" 
	DB	NEXT
	DB	"Я выхожу из класса Мотоки."
	DB	NEXT
	GO ROUKA
C4:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"Пожалуй, схожу посмотрю, что делается в подсобке спортзала."
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB	"Тэцуя ищет мяч."
	DB	NEXT
	T_CG 'tt_08_15',TET_A2,0
	FLG_KI TET_KAIS,'+',1
	DB	"Кэндзиро: Тэцуя, что ты тут делаешь?"
	DB	NEXT
	DB	"Тэцуя: А, Кэндзиро. Мы не смогли найти подходящий мяч для игры, так что я ищу здесь. А ты?"
	DB	NEXT
	DB	"Кэндзиро: Я просто слоняюсь по школе."
	DB	NEXT
	DB	"Тэцуя: Чего?"
	DB	NEXT
	DB	"Кэндзиро: До встречи, Тэцуя."
	DB	NEXT
	DB	"Я выхожу из подсобки спортзала."
	DB	NEXT
	GO ROUKA
C5:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"Пожалуй, схожу посмотрю, чем занимается Мика-сэнсэй."
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	DB	"Мика протирает одну из странно выглядящих статуй."
	DB	NEXT
	DB	"Кэндзиро: Мика-сэнсэй."
	DB	NEXT
	DB	"Мика: А, Кондо-кун."
	DB	NEXT
	T_CG 'tt_12_13a',MIK2,0
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	E1,"СМОТРЕТЬ НА СИСЬКИ"
	MENU_SET	E2,"СМОТРЕТЬ НА ЗАДНИЦУ"
	MENU_SET	E3,"СМОТРЕТЬ НА НОГИ"
	MENU_END
	DB	EXIT
E1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'>=',100,MIKA_1
;MIKA_NETA
MIKA_2:
	DB	"Её руки закрывают сиськи, загораживая мне вид. Но выглядят хорошо."
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
	DB	"Моё лицо познало мягкое прикосновение её задницы. Я никогда не забуду этот момент."
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
	DB	"Клёвые ножки. Столько мясца."
	DB	NEXT
	GO MIKA_7
MIKA_5:
	FLG_KI MIKA_NET,'=',1
	GO MIKA_6
MIKA_7:
	DB	"Мика: ...Ты только что смотрел на меня с похотью в глазах." 
	DB	NEXT
	DB	"Кэндзиро: Э? Что я?"
	DB	NEXT
	DB	"Мика: ...О, неважно. "
	DB	NEXT
	DB	"Мика: В любом случае, зачем ты здесь? Дополнительные занятия начнутся только завтра."
	DB	NEXT
	DB	"Кэндзиро: Э?"
	DB	NEXT
	DB	"Мика: ...Ты что, уже забыл?"
	DB	NEXT
	DB	"О нет! Я забыл!"
	DB	NEXT
	DB	"Кэндзиро: Ну, я пойду..."
	DB	NEXT
	DB	"Мика: С-стой! Вернись сюда!" 
	DB	NEXT
	DB	"Я выхожу из кабинета ИЗО."
	DB	NEXT
	GO ROUKA
C6:
	FLG_IF TEMP01,'=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB	"Я направляюсь в мужской туалет."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	DB	"Вторая кабинка с конца, это мой кабинет."
	DB	NEXT
	DB	"Мне тут делать нечего. Пойду, пожалуй..."
	DB	NEXT
	GO ROUKA
KYOUSITU:
	BAK_INIT 'tb_034a',B_NORM
	DB	"Скоро опять начнётся урок. Пожалуй, пойду назад."
	DB	NEXT
	BAK_INIT 'tb_010',B_NORM
	DB	"Ученики всё ещё болтают друг с другом. Девушки, как обычно, окружают Касима-сан."
	DB	NEXT
	DB	"Неужели новая ученица им всем так интересна?"
	DB	NEXT
	DB	"Я кладу голову на парту и снова готовлюсь ко сну."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Кэндзиро: Спокойной ночи..."
	DB	NEXT
	DB	"Кэндзиро: ......................................................................................................."
	DB	NEXT
	DB	"Голос: Эй, проснись!"
	DB	NEXT
	DB	"Кэндзиро: ...Мм?"
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	DB	"Кэндзиро: Что?"
	DB	NEXT
	DB	"Тэцуя: Наконец-то проснулся."
	DB	NEXT
	DB	"Я поднимаю тяжёлую голову с парты и смотрю на него."
	DB	NEXT
	T_CG 'tt_08_11a',TET_A2,0
	DB	"Тэцуя: Здоров ты спать."
	DB	NEXT
	DB	"Кэндзиро: Не хвали меня так. Я краснею."
	DB	NEXT
	DB	"Тэцуя: Это не похвала!" 
	DB	NEXT
	DB	"Тэцуя: И вообще, я иду домой. И тебе пора."
	DB	NEXT
	DB	"Кэндзиро: А."
	DB	NEXT
	DB	"Тэцуя: Ну, счастливо."
	DB	NEXT
	TATI_ERS 
	DB	"Тэцуя выходит из класса. Я беру сумку и готовлюсь сделать тоже самое."
	DB	NEXT
	DB	"Ну, пора домой."
	DB	NEXT
	GO HUHUHU
HOKEN:
	FLG_KI HOK,'=',2
	SINARIO 'ER.OVL'
HUHUHU:
	FLG_KI HOK,'=',0
	BAK_INIT 'tb_034a',B_NORM
	DB	"Тишина. Ни звука не слышно. Должно быть, все остальные уже ушли домой.  "
	DB	NEXT
	DB	"А? Я что-то слышу..."
	DB	NEXT
	DB	"Приятные звуки музыки, доносящиеся из комнаты неподалёку."
	DB	NEXT
	CDPLAY	11
	DB	"Рояль? Кто-то играет. Я уже слышал эту песню раньше..."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	F1,"ИДТИ В КАБИНЕТ МУЗЫКИ" 
	MENU_SET	F2,"ИДТИ ДОМОЙ"
	MENU_END
	DB	EXIT
F1: 
	DB	"Клянусь, я слышал эту песню раньше. Пожалуй, схожу посмотрю..."
	DB	NEXT
	SINARIO 'MON_11.OVL'
F2:
	FLG_KI SIHO_PIA,'=',0
	DB	"Мне это без разницы. Просто пойду домой."
	DB	NEXT
	DB	"Я выхожу из школы."
	DB	NEXT
	SINARIO 'BUNKI_1.OVL'
END