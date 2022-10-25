        include SUPER_C.inc
M_START:
MON_41
	FLG_IF JUMP,'=',76,FF_4
	FLG_IF JUMP,'=',75,FF_3
	FLG_IF JUMP,'=',74,FF_2
	FLG_IF JUMP,'=',73,FF_1
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB	"Кэндзиро: ...Что ж, пожалуй, пойду завтракать."
	DB	NEXT
	DB	"Я натягиваю школьную форму и иду на кухню."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	9
	T_CG	'tt_10_02',MOT_A3,0
	T_CG	'tt_20_02',AKE_A1,0
	DB	"Здесь Мотока и Акэми-сан."
	DB	NEXT
	DB	"Мотока: Ониитян, доброе утро." 
	DB	NEXT
	DB	"Акэми: Доброе утро, Кэндзиро-кун." 
	DB	NEXT
	DB	"Кэндзиро: Доброе утро. Завтрак готов?"
	DB	NEXT
	DB	"Акэми: Ты сегодня не очень-то радостный?" 
	DB	NEXT
	DB	"Кэндзиро: П-правда?"
	DB	NEXT
	DB	"Акэми: Гулять допоздна -- плохая идея."
	DB	NEXT
	DB	"Акэми-сан, по-видимому, знала, что я уходил вчера вечером."
	DB	NEXT
	DB	"Кэндзиро: Ладно..."
	DB	NEXT
	DB	"Акэми: Кушай завтрак." 
	DB	NEXT
	DB	"Акэми-сан ставит передо мной тост и кофе."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_10_02',MOT_A2,0
	DB	"Мотока: Ониитян?"
	DB	NEXT
	DB	"Кэндзиро: Да?"
	DB	NEXT
	DB	"Мотока: Могу я сегодня переночевать у друзей?"
	DB	NEXT
	DB	"Кэндзиро: Мм? Да, пожалуй, если Акэми-сан разрешит."
	DB	NEXT
	DB	"Мотока: Она сказала, что можно. Но ещё сказала, что я должна спросить у тебя." 
	DB	NEXT
	DB	"Кэндзиро: Хорошо, ночуй."
	DB	NEXT
	DB	"Мотока: Правда?" 
	DB	NEXT
	DB	"Кэндзиро: Конечно."
	DB	NEXT
	DB	"Мотока: Спасибо! ...Ну, пойду в школу." 
	DB	NEXT
	DB	"Мотока убегает из кухни."
	DB	NEXT
	TATI_ERS
	DB	"Кэндзиро: Она как всегда довольна. Пожалуй, мне тоже лучше пойти."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_006',B_NORM
	CDPLAY	2
	DB	"Я останавливаюсь у магазина, чтобы купить себе обед за 500 иен."
	DB	NEXT
	FLG_IF	TERUNASI,'=',1,TINAI
	GO	PAPAPA
TINAI:
	BAK_INIT	'tb_007',B_NORM
	DB	"Сегодня я не вижу здесь Тэруми-сэмпай..."
	DB	NEXT
	DB	"Понятно почему."
	DB	NEXT
	DB	"Я покупаю обед за 500 иен и иду в школу."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO	EKI
PAPAPA:
	BAK_INIT	'tb_007',B_NORM
	CDPLAY	3
	DB	"В магазине меня дожидается Тэруми."
	DB	NEXT
	DB	"Я часто её здесь встречаю."
	DB	NEXT
	T_CG	'tt_05_07',TER2,0
	DB	"Кэндзиро: Доброе утро, Тэруми-сэмпай."
	DB	NEXT
	DB	"Тэруми: Доброе утро." 
	DB	NEXT
	DB	"Кэндзиро: Убиваешь тут время, как обычно?"
	DB	NEXT
	DB	"Тэруми: Я тебя жду." 
	DB	NEXT
	DB	"Кэндзиро: Э?"
	DB	NEXT
	DB	"Тэруми: Шучу." 
	DB	NEXT
	DB	"Она смеётся над моей неловкостью."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	R1,"ПРЕДЛОЖИТЬ ПОЙТИ В ШКОЛУ"
	MENU_SET	R2,"ИДТИ ОДНОМУ"
	MENU_END
	DB	EXIT
R1:
	DB	"Кэндзиро: ......"
	DB	T_WAIT,	3
	DB	"Не хотела бы ты сейчас пойти в школу?"
	DB	NEXT
	DB	"Тэруми: Э? О, да, хорошая идея. А как насчёт твоего обеда?"
	DB	NEXT
	DB	"Кэндзиро: Забыл. Сейчас вернусь."
	DB	NEXT
	DB	"Я покупаю обед (уложившись в 500 иен) так быстро, как только могу."
	DB	NEXT
	DB	"Кэндзиро: Ладно, Тэруми-сэмпай, пошли."
	DB	NEXT
	DB	"Тэруми: Хорошо, идём."
	DB	NEXT
	DB	"Я кладу купленное в портфель, и мы вместе идём в школу."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO	GAKU1
R2:
	DB	"Кэндзиро: ......."
	DB	T_WAIT,	3
	DB	"Ну, пока."
	DB	NEXT
	DB	"Тэруми: Кэндзиро, как же твой обед?"
	DB	NEXT
	DB	"Проигнорировав её, я иду в школу один."
	DB	NEXT
	B_O	B_FADE,C_KURO
EKI:
	BAK_INIT	'tb_009',B_NORM
	DB	"Кэндзиро: Определённо, много народа."
	DB	NEXT
	DB	"Я очень устал от таких переполненных поездов."
	DB	NEXT
	DB	"Голос: Кэндзиро-кун..."
	DB	NEXT
	DB	"Я оборачиваюсь, чтобы увидеть, чей это голос."
	DB	NEXT
	T_CG	'tt_02_09',SIH_A2,0
	CDPLAY		23
	DB	"Сихо: Кэндзиро-кун, доброе утро." 
	DB	NEXT
	DB	"Кэндзиро: Ой, это Сихо. Доброе утро."
	DB	NEXT
	DB	"Сихо: Что значит, 'Ой, это Сихо'?" 
	DB	NEXT
	DB	"Она выглядит сердитой, но я знаю, что это не так."
	DB	NEXT
	DB	"Кэндзиро: Прости, прости. Я ничего такого не имел в виду."
	DB	NEXT
	DB	"Сихо: Пойдём в школу" 
	DB	T_WAIT,	3
	DB	" вместе?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	S1,"ПОЙТИ С НЕЙ"
	MENU_SET	S2,"НЕ ИДТИ С НЕЙ"
	MENU_END
	DB	EXIT
S1:
	DB	"Я не хочу идти один..."
	DB	NEXT
	DB	"Кэндзиро: Конечно, пошли вместе."
	DB	NEXT
	DB	"Сихо: Ладно."
	DB	NEXT
	DB	"Я иду в школу вместе с Сихо."
	DB	NEXT
	GO	GAKU2
	DB	EXIT
S2:
	DB	"Кэндзиро: Не думаю, что это хорошая идея."
	DB	NEXT
	DB	"Сихо: Почему нет?" 
	DB	NEXT
	DB	"Кэндзиро: Люди могут начать сплетничать, понимаешь?"
	DB	NEXT
	DB	"Сихо: ................" 
	DB	NEXT
	DB	"Кэндзиро: Что ж, я..."
	DB	T_WAIT,	3
	DB	" пойду один."
	DB	NEXT
	DB	"Я пошёл в школу один."
	DB	NEXT
	B_O	B_FADE,C_KURO
GAKU1:
	BAK_INIT	'tb_010',B_NORM
	CDPLAY	14
	T_CG	'tt_08_10',TET_A2,0
	DB	"Тэцуя: Доброе утро." 
	DB	NEXT
	DB	"Кэндзиро: Доброе утро."
	DB	NEXT
	DB	"Тэцуя: Как дела?"
	DB	NEXT
	DB	"Кэндзиро: А?"
	DB	NEXT
	DB	"Тэцуя: У меня хорошо."
	DB	NEXT
	DB	"Кэндзиро: ..............."
	DB	NEXT
	DB	"Тэцуя: Отреагируй! Сделай что-нибудь!" 
	DB	NEXT
	DB	"Вдруг прозвенел звонок. Начинается урок."
	DB	NEXT
	DB	"Кэндзиро: Оо, лучше сесть на место."
	DB	NEXT
	DB	"Тэцуя: Подожди!" 
	DB	T_WAIT,	3
	DB	" Вернись и поговори со мной..."
	DB	NEXT
	TATI_ERS
	DB	"Я сажусь на место."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"Я вяло пялюсь на доску, размышляя о том, какая вообще польза от образования."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO	AHO
	DB	EXIT
GAKU2:
	BAK_INIT	'tb_010',B_NORM
	CDPLAY	23
	T_CG	'tt_02_10',SIH_A3,0
	T_CG	'tt_08_10',TET_A1,0
	DB	"Тэцуя: Доброе утро, Касима-сан." 
	DB	NEXT
	DB	"Сихо: Доброе утро." 
	DB	NEXT
	DB	"Кэндзиро: Минуточку."
	DB	T_WAIT,	3
	DB	" А я?"
	DB	NEXT
	DB	"Тэцуя: О, Кэндзиро пришёл."
	DB	NEXT
	DB	"Кэндзиро: Так, минутку..."
	DB	NEXT
	DB	"Прозвенел звонок. Начинается урок."
	DB	NEXT
	;WAV	'Se_ch'
	DB	"Сихо: Пора садиться..."
	DB	NEXT
	DB	"Тэцуя: Хорошая идея."
	DB	NEXT
	TATI_ERS
	DB	"Кэндзиро: Пойду тоже сяду."
	DB	NEXT
	F_O	B_NORM,C_KURO
	;WAV  'STOP'
	CDPLAY		0
	DB	"Я вяло пялюсь на доску, размышляя о том, какая вообще польза от образования."
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