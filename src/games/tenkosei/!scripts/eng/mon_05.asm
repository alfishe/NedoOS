        include SUPER_C.inc
M_START:
MON_05
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		6
	DB	"Kenjirou:  Hello, I'm...home..."
	DB	NEXT
	T_CG	'tt_19_02',AKE_B2,0
	DB	"Akemi:  Kenjirou-kun, you're home."
	DB	NEXT
	DB	"Kenjirou:  Ah, yes..."
	DB	NEXT
	DB	"I didn't know what was happening. Akemi-san was standing in the dining kitchen in her underwear."
    DB  " I pinched myself to make sure I wasn't dreaming."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Kenjirou:  Akemi-san! What are you doing, standing there almost naked like that?"
	DB	NEXT
	DB	"Akemi:  I'm sorry, I got some hot oil on my clothes, so I took them off."
	DB	NEXT
	DB	"Kenjirou:  Y- You can do that somewhere else, can't you?"
	DB	NEXT
	DB	"Akemi:  Does it bother you? I'm sorry, just ignore me. I'm not bothered by it at all, since we're family." 
	DB	NEXT
	DB	"Kenjirou:  T- That doesn't have anything to do with it. Oh never mind."
	DB	NEXT
	DB	"I ran out of there, heading for my room."
	DB	NEXT
	DB	"Akemi:  Ah, dinner's almost ready."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM 
	CDPLAY		12
	DB	"Jeez! What a strange woman, cooking in her underwear like that. You'd think there wasn't a young man living in this house."
	DB	NEXT
	DB	"Well, I'm not really mad. I did get to see something nice..."
	DB	NEXT
	DB	"I'm glad she's not bothered by being practically nude in front of me..."
	DB	NEXT
	DB	"But what bothers me most is that she's not seeing me as a man at all. That kind of makes me sad."
	DB	NEXT
	DB	"Since she wasn't bothered by it, I should have stuck around to get a better look."
	DB	NEXT
	DB	"Well, it's just as well. Enough shocking things happened to me today."
	DB	NEXT
	DB	"I guess I'll get some sleep now. I don't really want to go down there and eat dinner with Akemi-san tonight."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"I turned off the light, and closed my eyes. Shiho was dancing in front of me in my mind,"
    DB  " but she quickly turned into Akemi-san in her underwear."
	DB	NEXT
	DB	"Kenjirou: .................................................................."
	DB	NEXT
	FLG_KI	HIDUKE,'+',1
	SINARIO 'MON_06.OVL'
END