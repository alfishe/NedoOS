        include SUPER_C.inc
M_START:
MON_47
	FLG_IF JUMP,'=',97,FF_4
	FLG_IF JUMP,'=',96,FF_3
	FLG_IF JUMP,'=',95,FF_2
	FLG_IF JUMP,'=',94,FF_1
	FLG_KI	HANAJI,'=',0
	BAK_INIT	'tb_001a',B_NORM
	CDPLAY	12
	DB "Кенджиру:  *Ау*  Я выспался."
	DB	NEXT
	DB "Наверное, спущусь вниз и позавтракаю."
	DB	NEXT
	DB "Я переоделся и пошел в кухню."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	9
	T_CG	'tt_10_02',MOT_A3,0
	T_CG	'tt_20_02',AKE_A1,0
	DB "Мотока и Акеми там ."
	DB	NEXT
	DB "Мотока:  Любимый, доброе утро!" 
	DB	NEXT
	DB "Акеми:  А, Кенжироу-кун. Доброе утро."
	DB	NEXT
	DB "Кенджиру:  Доброе утро. Завтрак готов?"
	DB	NEXT
	DB "Акеми:  Да, прямо там."
	DB	NEXT
	DB "Она поставила румяную булочку и кофе передо мной."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_10_02',MOT_A2,0
	DB "После этого, она начала копошится по дому."
	DB	NEXT
	DB "Мотока:  Любимый?"
	DB	NEXT
	DB "Кенджиру:  Да?"
	DB	NEXT
	DB "Мотока:  Хочешь. Вместе в школу пойдем?"
	DB	NEXT
	DB "Наконец я решил все проблемы с Мотокой и будет лучше, если вместе пойдем."
	DB	NEXT
	DB "Кенджиру:  Конечно, пойдем."
	DB	NEXT
	DB "Мотока:  Класс!" 
	DB	NEXT
	DB "Я пошел с Мотокой в школу."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY	0
	DB "Купил ланч в магазине и сел на поезд."
	DB	NEXT
	DB "Поезд забит, и мы набивали себе шишки всю дорогу."
	DB	NEXT
	BAK_INIT	'tb_009',B_NORM
	CDPLAY	9
	T_CG	'tt_10_09',MOT_A2,0
	DB "Кенджиру:  Мотока, ты в порядке? Вагон был забит. Тебя никто не трогал?"
	DB	NEXT
	DB "Мотока:  Все в порядке,что?" 
	DB	NEXT
	DB "Кенджиру:  О, извращенцев полно в час пик. Будь осторожна."
	DB	NEXT
	DB "Мотока:  Я в порядке. Со мной такого не было." 
	DB	NEXT
	DB "Кенджиру:  Потому то ты и такая наивная."
	DB	NEXT
	DB "Мотока:  Хм! Я не наивная." 
	DB	NEXT
	FLG_IF MOT_YATT,'!=',1,TUJO
	DB "Кенджиру:  ШШ! Не гвори так громко."
	DB	NEXT
	DB "Мотока:  ..................." 
	DB	NEXT
	DB "Она покраснела."
	DB	NEXT
	DB "Мотока:  Любимый,  ты же как извращенец..." 
	DB	T_WAIT,	3
	DB " Я не хотела."
	DB	NEXT
	DB "Кенджиру:  Да конечно."
	DB	NEXT
	DB "Шихо:   Кенджиру-кун, доброе утро." 
	DB	NEXT
	TATI_ERS
	T_CG	'tt_10_09',MOT_A3,0
	T_CG	'tt_02_09',SIH_A1,0
	DB "Мотока:  Ах, доброе утро." 
	DB	NEXT
	DB "Шихо:   Доброе утро." 
	DB	NEXT
	DB "Шино удивилась, когда Мотока поприветсвовала ее."
	DB	NEXT
	GO	TUJO2
TUJO:
	DB "Кенджиру:  Так ты не девственница..."
	DB	NEXT
	DB "Мотока:  Оничан, ты извращенец!" 
	DB	NEXT
	DB "Мотока покраснела.Она вскрикнула последние слова и все посмотрели на нас."
	DB	NEXT
	DB "Мотока:  Я не хотела!" 
	DB	NEXT
	DB "Я хотела сказать, что я взрослею."
	DB	NEXT
	DB "Кенджиру:  Хорошо, извини."
	DB	NEXT
	DB "Шихо:   Кенджиру-кун, доброе утро." 
	DB	NEXT
	CDPLAY	11
	T_CG	'tt_02_09',SIH_A1,0
	DB "О, нет! Сейчас будет драка...!"
	DB	NEXT
	DB "Мотока:  Ах, доброе утро." 
	DB	NEXT
	DB "Возможно из-за того, что Мотока поздоровалась с Шино."
	DB	NEXT
	DB "Шихо:   Доброе утро." 
	DB	NEXT
	DB "Шино удивилась, когда Мотока тепло поприветсвовала ее."
	DB	NEXT
TUJO2:
	DB "Шихо:   Хороший день." 
	DB	NEXT
	DB "Мотока:  Да?"
	DB	NEXT
	DB "Мотока:  Минутку. Кашима, твоя форма, эта форма прошлого года. Они изменили фасон в этом апреле."
	DB	NEXT
	DB "Шихо:   А?" 
	DB	NEXT
	DB "Мотока:  Почему на тебе прошлогодняя форма?"
	DB	NEXT
	DB "Шихо:   ................" 
	DB	NEXT
	DB "Вот что я думаю, у нее такая же форма, как и у остальных, даже если она временный студент, у нее должна быть новая форма."
	DB	NEXT
	DB "Шихо:   О, у них полно старых вещей, я возьму одну из них." 
	DB	NEXT
	DB "Мотока:  Круто. Мне нравится больше старая форма."
	DB	NEXT
	DB "Но я был уверен, что они выбросили старую форму...?"
	DB	NEXT
	DB "Мотока:  Оничан, что не так?" 
	DB	NEXT
	DB "Кенджиру:  Ничего. Я просто мечтал." 
	DB	NEXT
	DB "Мотока:  О, он часто мечтает, да, Кашима?" 
	DB	NEXT
	DB "Шихо:   ...Да." 
	DB	NEXT
	DB "Хм, я даже избегала раньше Шино..."
	DB	T_WAIT,	3
	DB " Хм,не понимаю женщин."
	DB	NEXT
	DB "Шихо:   Ну, пойдем?"
	DB	NEXT
	DB "Кенджиру:  Пойдем."
	DB	NEXT
	DB "Сегодня, Мотока, Шино и я пошли в школу вместе."
	DB	NEXT
	FLG_KI	SEIFUKU,'=',1
	BAK_INIT 'tb_010',B_NORM
	CDPLAY	23
	T_CG 'tt_02_10',SIH_A3,0
	T_CG 'tt_08_10',TET_A1,0
	DB "Тецуя:    Доброе утро, Кашима-сан." 
	DB	NEXT
	DB "Шино, доброе утро."
	DB	NEXT
	DB "Кенджиру:  Подожди минуту."
	DB	T_WAIT, 5
	DB " Это ко мне?"
	DB	NEXT
	DB "Тецуя:    О, Кениро, ты был здесь."
	DB	NEXT
	DB "Кенджиру:  Эй..."
	DB	NEXT
	DB "Как раз зазвенел звонок."
	DB	NEXT
	;WAV		'Se_ch'
	DB "Шихо:   Может здесь сядешь."
	DB	NEXT
	DB "Тецуя:    Ты права."
	DB	NEXT
	TATI_ERS
	DB "Кенджиру:  Присяду."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB "Я уставился на доску, размышляя зачем нужно образование."
	DB	NEXT
	B_O	B_FADE,C_KURO
	B_O	B_FADE,C_KURO
	FLG_KI JUMP,'=',94
	SINARIO 'NITI_HIR.OVL'
FF_1:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',95
	SINARIO 'NITI_HOK.OVL'
FF_2:
	FLG_KI JUMP,'=',0
	FLG_KI JUMP,'=',96
	SINARIO 'NITI_MAT.OVL'
FF_3:
	FLG_KI JUMP,'=',0
	FLG_IF	HANAJI,'=',1,OYASUMI
	FLG_KI JUMP,'=',97
	SINARIO 'NITI_KIT.OVL'
FF_4:
	FLG_KI JUMP,'=',0
	SINARIO	'MON_48.OVL'
	DB	EXIT
OYASUMI:
	FLG_KI JUMP,'=',0
	FLG_KI	HANAJI,'=',0
	SINARIO	'MON_48.OVL'
	DB	EXIT
END
