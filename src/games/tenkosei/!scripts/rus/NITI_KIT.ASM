        include SUPER_C.inc
M_START:
NITI_KIT
	BAK_INIT	'tb_005c',B_NORM
	CDPLAY	22
	DB	"Ах, хорошо быть дома."
	DB	NEXT
	FLG_IF	MOT_KOKU,'=',1,SEX
	FLG_IF	MOTSUNE,'>=',1,MUSI
	BAK_INIT	'tb_002',B_NORM;вЂљcвЂљj
	CDPLAY	9
	DB	"Здесь Акэми-сан и Мотока."
	DB	NEXT
	T_CG	'tt_11_02',MOT_A3,0
	T_CG	'tt_20_02',AKE_A1,0
	DB	"Мотока: Ониитян, с возвращением." 
	DB	NEXT
	DB	"Акэми: Здравствуй, Кэндзиро." 
	DB	NEXT
	DB	"Кэндзиро: Привет."
	DB	NEXT
	GO	TUUJOU
MUSI:
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Акэми: С возвращением." 
	DB	NEXT
	DB	"Кэндзиро: Привет... Э, где Мотока?"
	DB	NEXT
	DB	"Акэми: Она ещё не пришла." 
	DB	NEXT
TUUJOU:
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	H1,"СМОТРЕТЬ НА КЛЮЧИЦУ"
	MENU_SET	H2,"СМОТРЕТЬ НА ГРУДЬ"
	MENU_SET	H3,"СМОТРЕТЬ НА ЧУЛКИ"
	MENU_END
	DB	EXIT
H1:
	FLG_IF	YOKU,'>=',100,HEYA
	FLG_KI	YOKU,'+',5
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'>=',100,AKEM
	DB	"У неё отличная ключица. Хотел бы я провести по ней языком."
	DB	NEXT
	GO	FUTU
H2:
	FLG_IF	YOKU,'>=',100,HEYA
	FLG_KI	YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'>=',100,AKEM
	DB	"У неё замечательная грудь. Я бы очень хотел поцеловать её в ложбину."
	DB	NEXT
	GO	FUTU
H3:
	FLG_IF	YOKU,'>=',100,HEYA
	FLG_KI	YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF	YOKU,'>=',100,AKEM
	DB	"У неё отличные ножки, а нейлон делает их ещё стройнее."
	DB	NEXT
	GO	FUTU
AKEM:
	FLG_KI	AKEM_NET,'=',1
	DB	"Я сейчас взорвусь!"
	DB	NEXT
FUTU:
	FLG_IF	MOTSUNE,'>=',1,KAE
	DB	"Мотока: Ониитян, ты смотрел на мою маму похотливым взглядом, не так ли?" 
	DB	NEXT
	DB	"Кэндзиро: Ч-что за чушь!"
	DB	NEXT
	DB	"Она была права, от этого я покраснел."
	DB	NEXT
	DB	"Акэми: Мотока, не дразни так своего брата." 
	DB	NEXT
	DB	"Кэндзиро: В-вообще, что на ужин?"
	DB	NEXT
	DB	"Акэми: Сюрприз. Скоро будет готово."
	DB	NEXT
	DB	"Мотока: А, ты сменил тему!" 
	DB	NEXT
	DB	"Кэндзиро: Нет, не сменил, просто..."
	DB	NEXT
	DB	"Мотока: Извращенец, извращенец! Ониитян -- извращенец!" 
	DB	NEXT
	DB	"Вот так мы втроём и поужинали этим вечером."
	DB	NEXT
	B_O	B_FADE,C_KURO
	GO TUGI
KAE:
	BAK_INIT	'tb_002',B_NORM
	DB	"Акэми: Хихи... В чём дело?" 
	DB	NEXT
	DB	"Кэндзиро: Э? О, ни в чём."
	DB	NEXT
	DB	"Акэми: Правда?"
	DB	NEXT
	DB	"Кэндзиро: Ага. Кстати, вы не думаете, что Мотока сильно задерживается?"
	DB	NEXT
	DB	"Акэми: Ты слишком сильно волнуешься."
	DB	NEXT
	DB	"Кэндзиро: Вы так думаете?"
	DB	NEXT
	DB	"Мотока: Я пришла..."
	DB	NEXT
	DB	"Голос Мотоки эхом разносится от входной двери, но звучит как-то грустно."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_21_02',MOT_B3,0
	T_CG	'tt_20_02',AKE_A1,0
	DB	"Мотока: А, Ониитян..." 
	DB	NEXT
	DB	"Кэндзиро: С возвращением."
	DB	NEXT
	DB	"Акэми: Ты пришла как раз к ужину."
	DB	NEXT
	DB	"Мотока: Я не голодна..." 
	DB	NEXT
	TATI_ERS
	T_CG	'tt_20_02',AKE_A2,0
	DB	"С этими словами, Мотока пошла к себе в комнату."
	DB	NEXT
	DB	"Акэми: Хотела бы я знать, что с ней?"
	DB	NEXT
	DB	"Так что Акэми-сан и я в этот вечер ужинали вдвоём."
	DB	NEXT
TUGI:
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY	12
	DB	"Кэндзиро: Что ж, я принял ванну. Пожалуй, лягу спать."
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
	DB	"Кэндзиро: Уууу....уммм?.."
	DB	NEXT
	DB	"Мои глаза медленно открылись."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY	12
	DB	"Кэндзиро: Где я?"
	DB	NEXT
	DB	"Всё ещё не понимая, я оглядываюсь по сторонам. Кажется, я у себя в комнате."
	DB	NEXT
	DB	"Но что, чёрт возьми, произошло?"
	DB	NEXT
	DB	"На моей рубашке коричневое пятно."
	DB	NEXT
	DB	"Кровь? Но что случилось? У меня что ли кровь из носа во сне пошла?"
	DB	NEXT
	DB	"Что происходит?.."
	DB	NEXT
	DB	"Должно быть, я вырубился."
	DB	NEXT
	DB	"Кто-то положил меня в кровать, потому что я не помню, чтобы сам сюда пришёл."
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