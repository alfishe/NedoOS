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
	DB	"Kenjirou:  *Yawn*  I slept well."
	DB	NEXT
	DB	"Guess I'll go downstairs and have breakfast."
	DB	NEXT
	DB	"I changed my clothes, and headed for the dining kitchen."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	9
	T_CG	'tt_10_02',MOT_A3,0
	T_CG	'tt_20_02',AKE_A1,0
	DB	"Motoka and Akemi are here."
	DB	NEXT
	DB	"Motoka:  Oniichan, good morning!" 
	DB	NEXT
	DB	"Akemi:  Ah, Kenjirou-kun. Good morning."
	DB	NEXT
	DB	"Kenjirou:  Good morning. Is breakfast ready?"
	DB	NEXT
	DB	"Akemi:  Yes, right here."
	DB	NEXT
	DB	"She places fresh-baked bread and hot coffee in front of me."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_10_02',MOT_A2,0
	DB	"Afterwards, she starts bustling around the house."
	DB	NEXT
	DB	"Motoka:  Oniichan?"
	DB	NEXT
	DB	"Kenjirou:  Yes?"
	DB	NEXT
	DB	"Motoka:  Do you want to go to school together?"
	DB	NEXT
	DB	"I finally made up with Motoka, so it'd be best if I went to school with her."
	DB	NEXT
	DB	"Kenjirou:  Sure. Let's go together."
	DB	NEXT
	DB	"Motoka:  Great!" 
	DB	NEXT
	DB	"I head for school with Motoka at my side."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY	0
	DB	"I buy my lunch at the convenience store, and get on the train."
	DB	NEXT
	DB	"The train is quite full, forcing us to bump up against each other as we ride."
	DB	NEXT
	BAK_INIT	'tb_009',B_NORM
	CDPLAY	9
	T_CG	'tt_10_09',MOT_A2,0
	DB	"Kenjirou:  Motoka, are you okay? The train was pretty crowded. Did anyone try to touch you?"
	DB	NEXT
	DB	"Motoka:  No, I'm fine. Why?" 
	DB	NEXT
	DB	"Kenjirou:  Oh, you hear that there are a lot of them during rush hour. Be careful."
	DB	NEXT
	DB	"Motoka:  I'll be fine. I've never had that happen to me." 
	DB	NEXT
	DB	"Kenjirou:  That's because you're so innocent."
	DB	NEXT
	DB	"Motoka:  Hmrph! I'm not that innocent." 
	DB	NEXT
	FLG_IF MOT_YATT,'!=',1,TUJO
	DB	"Kenjirou:  Shh! Don't talk too loudly."
	DB	NEXT
	DB	"Motoka:  ..................." 
	DB	NEXT
	DB	"Her face turned bright red."
	DB	NEXT
	DB	"Motoka:  Oniichan, you're such a pervert..." 
	DB	T_WAIT,	3
	DB	" I didn't mean it that way."
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, sure."
	DB	NEXT
	DB	"Shiho:  Kenjirou-kun, good morning." 
	DB	NEXT
	TATI_ERS
	T_CG	'tt_10_09',MOT_A3,0
	T_CG	'tt_02_09',SIH_A1,0
	DB	"Motoka:  Ah, good morning." 
	DB	NEXT
	DB	"Shiho:  Eh? Good morning." 
	DB	NEXT
	DB	"Shiho couldn't hide her surprised at Motoka's greeting."
	DB	NEXT
	GO	TUJO2
TUJO:
	DB	"Kenjirou:  Eh? So you're not a virgin..."
	DB	NEXT
	DB	"Motoka:  O- Oniichan, you pervert!" 
	DB	NEXT
	DB	"Motoka's face turned bright read. She had shouted the last words, causing everyone to look at us."
	DB	NEXT
	DB	"Motoka:  I didn't mean it that way!" 
	DB	NEXT
	DB	"I just... I meant that I was more... more grown up."
	DB	NEXT
	DB	"Kenjirou:  T- That's right. Sorry."
	DB	NEXT
	DB	"Shiho:  Kenjirou-kun, good morning." 
	DB	NEXT
	CDPLAY	11
	T_CG	'tt_02_09',SIH_A1,0
	DB	"Oh no! It's going to be another scene of bloodshed...!"
	DB	NEXT
	DB	"Motoka:  Ah, good morning." 
	DB	NEXT
	DB	"Perhaps because of her discomfort, Motoka greeted Shiho normally."
	DB	NEXT
	DB	"Shiho:  Ah, good morning." 
	DB	NEXT
	DB	"Shiho couldn't hide her surprise at Motoka's kind greeting."
	DB	NEXT
TUJO2:
	DB	"Shiho:  It's a nice day today." 
	DB	NEXT
	DB	"Motoka:  Really?"
	DB	NEXT
	DB	"Motoka:  Wait a minute. Kashima-senpai, your uniform, it's last year's uniform. "
        DB      "They changed to a new style this April."
	DB	NEXT
	DB	"Shiho:  Eh?" 
	DB	NEXT
	DB	"Motoka:  Why do you have last year's uniform?"
	DB	NEXT
	DB	"Shiho:  ................" 
	DB	NEXT
	DB	"Now that I think about it, she does have the same uniform as the rest of us, "
        DB      "even though she's a transfer student, and should have had a new one."
	DB	NEXT
	DB	"Shiho:  Oh, they still had stock of the old kind, so I got one of these." 
	DB	NEXT
	DB	"Motoka:  That's cool. I like the old uniforms better."
	DB	NEXT
	DB	"But I was sure they had gotten rid of all the old uniforms last year...?"
	DB	NEXT
	DB	"Motoka:  Oniichan, what's wrong?" 
	DB	NEXT
	DB	"Kenjirou:  It's nothing. I was just woolgathering." 
	DB	NEXT
	DB	"Motoka:  Oh. He does that a lot, doesn't he, Kashima-senpai?" 
	DB	NEXT
	DB	"Shiho:  ...Yes, he does." 
	DB	NEXT
	DB	"Hmm, I was even avoiding Shiho before..."
	DB	T_WAIT,	3
	DB	" Hmm, I just don't understand women."
	DB	NEXT
	DB	"Shiho:  Well, shall we get going?"
	DB	NEXT
	DB	"Kenjirou:  Yeah, let's go."
	DB	NEXT
	DB	"Today, Motoka, Shiho and I all went to school together."
	DB	NEXT
	FLG_KI	SEIFUKU,'=',1
	BAK_INIT 'tb_010',B_NORM
	CDPLAY	23
	T_CG 'tt_02_10',SIH_A3,0
	T_CG 'tt_08_10',TET_A1,0
	DB	"Tetsuya:  Good morning, Kashima-san." 
	DB	NEXT
	DB	"Shiho, Good morning."
	DB	NEXT
	DB	"Kenjirou:  Wait a minute..."
	DB	T_WAIT, 5
	DB	" What about me?"
	DB	NEXT
	DB	"Tetsuya:  Oh, Kenjirou, you were here."
	DB	NEXT
	DB	"Kenjirou:  Hey..."
	DB	NEXT
	DB	"Just then, the bell rang."
	DB	NEXT
	;WAV		'Se_ch'
	DB	"Shiho:  You should probably sit down now."
	DB	NEXT
	DB	"Tetsuya:  You're right."
	DB	NEXT
	TATI_ERS
	DB	"Kenjirou:  I'll sit down, too."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"I stare at the blackboard listlessly, wondering at the use of an education."
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