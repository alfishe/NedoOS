        include SUPER_C.inc
M_START:
NITI_KIT
	BAK_INIT	'tb_005c',B_NORM
	CDPLAY	22
	DB "А, хорошо быть дома."
	DB	NEXT
	FLG_IF	MOT_KOKU,'=',1,SEX
	FLG_IF	MOTSUNE,'>=',1,MUSI
	BAK_INIT	'tb_002',B_NORM;вЂљcвЂљj
	CDPLAY	9
	DB "Акеми-сан и Мотока здесь."
	DB	NEXT
	T_CG	'tt_11_02',MOT_A3,0
	T_CG	'tt_20_02',AKE_A1,0
	DB "Мотока:  Любимый, привет." 
	DB	NEXT
	DB "Акеми:  Привет,Кенджиру." 
	DB	NEXT
	DB "Кенджиру:  Хай"
	DB	NEXT
	GO	TUUJOU
MUSI:
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	T_CG	'tt_20_02',AKE_A2,0
	DB "Акеми:  Дома." 
	DB	NEXT
	DB "Кенджиру:  Пр... А где Мотока?"
	DB	NEXT
	DB "Акеми:  Она не пришла еще домой." 
	DB	NEXT
TUUJOU:
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	H1,"ОСМОТР ПЛЕЧИ"
	MENU_SET	H2,"ОСМОТР ГРУДИ"
	MENU_SET	H3,"ОСМОТР КОЛГОТОК"
	MENU_END
	DB	EXIT
H1:
	FLG_IF	YOKU,'>=',100,HEYA
	FLG_KI	YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'>=',100,AKEM
	DB "У нее отличная ключица. Я бы полизал ее языком."
	DB	NEXT
	GO	FUTU
H2:
	FLG_IF	YOKU,'>=',100,HEYA
	FLG_KI	YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'>=',100,AKEM
	DB "У нее красивые груди. Я бы хотел поцеловать впадину между ними."
	DB	NEXT
	GO	FUTU
H3:
	FLG_IF	YOKU,'>=',100,HEYA
	FLG_KI	YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'>=',100,AKEM
	DB "У нее классные бедра, а нейлоновые чулки придают им еще лучшую форму."
	DB	NEXT
	GO	FUTU
AKEM:
	FLG_KI	AKEM_NET,'=',1
	DB "Я сейчас обкончаюсь!"
	DB	NEXT
FUTU:
	FLG_IF	MOTSUNE,'>=',1,KAE
	DB "Мотока:  Ониичан, ты с таким пристрастием смотрел на мою маму, не так ли?" 
	DB	NEXT
	DB "Кенджиру:  Какого хера!"
	DB	NEXT
	DB "Она права, и я покраснел, когда меня споймали на этом."
	DB	NEXT
	DB "Акеми:  Мотока, не дразни так своего брата." 
	DB	NEXT
	DB "Кенджиру:  Да ладно, что у нас на обед?"
	DB	NEXT
	DB "Акеми:  Сюрприз. Он будет скоро готов."
	DB	NEXT
	DB "Мотока:  Ты сменил тему!" 
	DB	NEXT
	DB "Кенджиру:  Нет, я просто...."
	DB	NEXT
	DB "Мотока:  Извращенец! Оничан извращенец!" 
	DB	NEXT
	DB "Вот так все трое из нас ужинали в тот вечер."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO TUGI
KAE:
	BAK_INIT	'tb_002',B_NORM
	DB "Акеми:  Фу... Что такое?" 
	DB	NEXT
	DB "Кенджиру:  А? Ох, ничего."
	DB	NEXT
	DB "Акеми:  Правда?"
	DB	NEXT
	DB "Кенджиру:  Да. Кстати, тебе не кажется, что Мотока  опаздывает?"
	DB	NEXT
	DB "Акеми:  Ты сильно волн-ся."
	DB	NEXT
	DB "Кенджиру:  Ты думаешь?"
	DB	NEXT
	DB "Акеми:  Я дома..."
	DB	NEXT
	DB "Раздается голос Мотоки из-за входной двери, но он звучал печально."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_21_02',MOT_B3,0
	T_CG	'tt_20_02',AKE_A1,0
	DB "Мотока:  A, Ониичан..." 
	DB	NEXT
	DB "Кенджиру:  Привет."
	DB	NEXT
	DB "Акеми:  Ты пришла к обеду."
	DB	NEXT
	DB "Мотока:  Я не голодна...." 
	DB	NEXT
	TATI_ERS
	T_CG	'tt_20_02',AKE_A2,0
	DB "Мотока пошла в свою комнату."
	DB	NEXT
	DB "Акеми:  Интересно, что случилось с ней?"
	DB	NEXT
	DB "В тот вечер Акими-сен и я ужинали сами."
	DB	NEXT
TUGI:
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB "Кенджиру:  Я принял ванну. Пожалуй, я буду ложиться."
	DB	NEXT
	FLG_IF	MOTSUNE,'=',1,MODORU
	FLG_IF	TERUNASI,'=',1,MODORU
	FLG_IF	TER_DEN,'=',1,TEL
MODORU:
	B_O	B_FADE,C_KURO
	CDPLAY		0
	FLG_KI	HIDUKE,'+',1
	SINARIO 'JUMP.OVL'
	DB	EXIT
HEYA:
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	CDPLAY		0
	F_O B_NORM,C_KURO
	DB "Кенджиру:  Что...?"
	DB	NEXT
	DB "Я приоткрыл глаза."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY	12
	DB "Кенджиру:  Где я?"
	DB	NEXT
	DB "Я озадаченно осмотрелся. По-моему, я был в своей комнате."
	DB	NEXT
	DB "Что же произошло?"
	DB	NEXT
	DB "На моей рубашке было пятно."
	DB	NEXT
	DB "Кровь? Но что было? Может, у меня ночью пошла кровь с носа?"
	DB	NEXT
	DB "Что происходит...?"
	DB	NEXT
	DB "Наверное, я потерял сознание."
	DB	NEXT
	DB "Скорее всего, кто-то уложил меня в постель, но я не помню, чтобы я сам пришел сюда."
	DB	NEXT
	FLG_IF	TER_DEN,'=',1,TEL
	B_O	B_FADE,C_KURO
	CDPLAY	0
	FLG_KI	HIDUKE,'+',1
	SINARIO 'JUMP.OVL'
	DB	EXIT
TEL:
	FLG_KI	TER_DEN,'=',0
	SINARIO	'MON_40.OVL'
	DB	EXIT
SEX:
	SINARIO	'BUNKI_5.OVL'
END
