        include SUPER_C.inc
M_START:
MON_41
	FLG_IF JUMP,'=',76,FF_4
	FLG_IF JUMP,'=',75,FF_3
	FLG_IF JUMP,'=',74,FF_2
	FLG_IF JUMP,'=',73,FF_1
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB "Кенджиру:  ...Я пойду завтракать."
	DB	NEXT
	DB "Я одел форму и пошел на кухню."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	9
	T_CG	'tt_10_02',MOT_A3,0
	T_CG	'tt_20_02',AKE_A1,0
	DB "Здесь Мотока и Акеми-сан."
	DB	NEXT
	DB "Мотока:  Любимый, доброе утро." 
	DB	NEXT
	DB "Акеми:  Привет, Кенджиру-кун." 
	DB	NEXT
	DB "Кенджиру:  Доброе утро. Завтрак готов?"
	DB	NEXT
	DB "Акеми:  Ты не весел сегодня?" 
	DB	NEXT
	DB "Кенджиру:  Серьезно?"
	DB	NEXT
	DB "Акеми:  Не хорошо гулять так поздно."
	DB	NEXT
	DB "Акеми очевидно знала, что я пришел поздно."
	DB	NEXT
	DB "Кенджиру:  Хорошо."
	DB	NEXT
	DB "Акеми:  Завтракай." 
	DB	NEXT
	DB "Акеми-сан ставит передо мной кофе и тост."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_10_02',MOT_A2,0
	DB "Мотока:  Любимый?"
	DB	NEXT
	DB "Кенджиру:  Да?"
	DB	NEXT
	DB "Мотока:  Можно я останусь на ночь у друзей?"
	DB	NEXT
	DB "Кенджиру:  Хм? Хорошо, если Акеми согласна."
	DB	NEXT
	DB "Мотока:  Она согласилась. Но она сказала спросить тебя." 
	DB	NEXT
	DB "Кенджиру:  Ладно, иди."
	DB	NEXT
	DB "Мотока:  Да?" 
	DB	NEXT
	DB "Кенджиру:  Да."
	DB	NEXT
	DB "Мотока:  Спасибо! ...Я пошел в школу." 
	DB	NEXT
	DB "Мотока выбежала из кухни."
	DB	NEXT
	TATI_ERS
	DB "Кенджиру:  Она как обычно счастлива. Мне пора идти тоже."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_006',B_NORM
	CDPLAY	2
	DB "Я зашел в магазин купить ланч за 500 иен."
	DB	NEXT
	FLG_IF	TERUNASI,'=',1,TINAI
	GO	PAPAPA
TINAI:
	BAK_INIT	'tb_007',B_NORM
	DB "Сегодня я не видал Теруми..."
	DB	NEXT
	DB "Понимаю почему."
	DB	NEXT
	DB "Я купил ланч и отправился в школу."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO	EKI
PAPAPA:
	BAK_INIT	'tb_007',B_NORM
	CDPLAY	3
	DB "В магазине меня ждала Теруми."
	DB	NEXT
	DB "Я часто встречаю ее."
	DB	NEXT
	T_CG	'tt_05_07',TER2,0
	DB "Кенджиру:  Привет, Теруми-сенпай."
	DB	NEXT
	DB "Теруми:  Привет." 
	DB	NEXT
	DB "Кенджиру:  Как обычно убиваешь время?"
	DB	NEXT
	DB "Теруми:  Я жду тебя." 
	DB	NEXT
	DB "Кенджиру:  А?"
	DB	NEXT
	DB "Теруми:  Я шучу." 
	DB	NEXT
	DB "Она засмеялась."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	R1,"ПРИГЛАСИТЬ В ШКОЛУ"
	MENU_SET	R2,"САМ"
	MENU_END
	DB	EXIT
R1:
	DB "Кенджиру:  ......"
	DB	T_WAIT,	3
	DB "Пойдем в школу?"
	DB	NEXT
	DB "Теруми:  Неплохая мысль. Как насчет ланча?"
	DB	NEXT
	DB "Кенджиру:  Я забыл. Скоро буду."
	DB	NEXT
	DB "Я быстро купил ланч меньше чем за 500 иен."
	DB	NEXT
	DB "Кенджиру:  Хоршо Теруми, пойдем."
	DB	NEXT
	DB "Теруми:  Пойдем."
	DB	NEXT
	DB "Я положил кошелек в сумку и мы вместе пошли в школу."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO	GAKU1
R2:
	DB "Кенджиру:  ......."
	DB	T_WAIT,	3
	DB "Пока."
	DB	NEXT
	DB "Теруми:  Кениро, а как же ланч?"
	DB	NEXT
	DB "Я не обратил на нее внимания и пошел один."
	DB	NEXT
	B_O	B_FADE,C_KURO
EKI:
	BAK_INIT	'tb_009',B_NORM
	DB "Кенджиру:  Там полно народу."
	DB	NEXT
	DB "Я устал от переполненого транспорта."
	DB	NEXT
	DB "Голос:  Кенжироу-кун..."
	DB	NEXT
	DB "Я повернулся, чтобы увидеть чей это голос."
	DB	NEXT
	T_CG	'tt_02_09',SIH_A2,0
	CDPLAY		23
	DB "Шихо:   Кенджиру-кун, доброе утро." 
	DB	NEXT
	DB "Кенджиру:  Это Шишо. Доброе утро."
	DB	NEXT
	DB "Шихо:   Что ты хочешь сказать 'Это Шихо'?" 
	DB	NEXT
	DB "Она выглядела сердитой."
	DB	NEXT
	DB "Кенджиру:  Извини. Я ничего не имел в виду."
	DB	NEXT
	DB "Шихо:   Пойдем в школу" 
	DB	T_WAIT,	3
	DB " вместе?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	S1,"ЗА НЕЙ"
	MENU_SET	S2,"НЕ ВОЛНУЙСЯ"
	MENU_END
	DB	EXIT
S1:
	DB "Я не хочу идти одна..."
	DB	NEXT
	DB "Кенджиру:  Конечно пойдем вместе."
	DB	NEXT
	DB "Шихо:   Ладно"
	DB	NEXT
	DB "Я иду в школу с Шихо."
	DB	NEXT
	GO	GAKU2
	DB	EXIT
S2:
	DB "Кенджиру:  Не думаю что это хорошая мысль."
	DB	NEXT
	DB "Шихо:   Почему?" 
	DB	NEXT
	DB "Кенджиру:  Люди будут сплетничать."
	DB	NEXT
	DB "Шихо:   ................" 
	DB	NEXT
	DB "Кенджиру:  Ну, я..."
	DB	T_WAIT,	3
	DB "Пойду одна."
	DB	NEXT
	DB "Я пошел в школу один."
	DB	NEXT
	B_O	B_FADE,C_KURO
GAKU1:
	BAK_INIT	'tb_010',B_NORM
	CDPLAY	14
	T_CG	'tt_08_10',TET_A2,0
	DB "Тецуя:    Привет." 
	DB	NEXT
	DB "Кенджиру:  Привет."
	DB	NEXT
	DB "Тецуя:    Как ты?"
	DB	NEXT
	DB "Кенджиру:  Ох?"
	DB	NEXT
	DB "Тецуя:    Порядок."
	DB	NEXT
	DB "Кенджиру:  ..............."
	DB	NEXT
	DB "Тецуя:    Ты должен что то сделать!" 
	DB	NEXT
	DB "Внезапно зазвенел звонок. Время урока."
	DB	NEXT
	DB "Кенджиру:  Лчше сядь."
	DB	NEXT
	DB "Тецуя:    Стой!" 
	DB	T_WAIT,	3
	DB " Вернись и поговори со мной."
	DB	NEXT
	TATI_ERS
	DB "Сижу на на месте."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB "Я уставился на доску, размышляя кому нужно образование."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO	AHO
	DB	EXIT
GAKU2:
	BAK_INIT	'tb_010',B_NORM
	CDPLAY	23
	T_CG	'tt_02_10',SIH_A3,0
	T_CG	'tt_08_10',TET_A1,0
	DB "Тецуя:    Доброе утро, Кашима-сан." 
	DB	NEXT
	DB "Шихо:   Привет." 
	DB	NEXT
	DB "Кенджиру:  Подожди."
	DB	T_WAIT,	3
	DB " Это ко мне?"
	DB	NEXT
	DB "Тецуя:    Кениро здесь."
	DB	NEXT
	DB "Кенджиру:  Подожди минутку..."
	DB	NEXT
	DB "Прозвенел звонок,пора на урок."
	DB	NEXT
	;WAV	'Se_ch'
	DB "Шихо:   Сядем здесь..."
	DB	NEXT
	DB "Тецуя:    Хорошо."
	DB	NEXT
	TATI_ERS
	DB "Кенджиру:  Я тоже сяду."
	DB	NEXT
	F_O	B_NORM,C_KURO
	;;WAV  'STOP'
	CDPLAY		0
	DB "Я тупо смотрю на доску, размышляя зачем образование ."
	DB	NEXT
	B_O	B_FADE,C_KURO
AHO:
	FLG_KI JUMP,'=',73
	SINARIO	'NITI_HIR.OVL'
FF_1:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',74
	SINARIO	'NITI_HOK.OVL'
FF_2:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',75
	SINARIO	'NITI_MAT.OVL'
FF_3:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',76
	SINARIO	'NITI_KIT.OVL'
FF_4:
	FLG_KI JUMP,'=',0
	SINARIO	'MON_42.OVL'
	DB	EXIT
END
