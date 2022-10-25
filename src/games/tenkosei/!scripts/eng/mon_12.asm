        include SUPER_C.inc
M_START:
MON_12
	FLG_KI	MOTSUNE,'=',1
	BAK_INIT 'tb_001a',B_NORM
	CDPLAY		12
	DB	"*Yawn*  Ah, I got a lot of sleep..."
	DB	NEXT
	DB	"Guess I'll go downstairs and have breakfast."
	DB	NEXT
	DB	"I get dressed and head down to the dining kitchen."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		9
	T_CG 'tt_10_02',MOT_A3,0
	T_CG 'tt_20_02',AKE_A1,0
	DB	"Motoka and Akemi-san are here."
	DB	NEXT
	DB	"Motoka:  Oniichan, good morning."
	DB	NEXT
	DB	"Akemi:  Good morning, Kenjirou-kun."
	DB	NEXT
	DB	"Kenjirou:  Good morning. Is breakfast ready?"
	DB	NEXT
	DB	"Akemi:  It's here."
	DB	NEXT
	DB	"Akemi-san puts toast and coffee in front of me."
	DB	NEXT
	TATI_ERS	;Tt_20
	T_CG 'tt_10_02',MOT_A2,0
	DB	"After giving me my breakfast, Akemi-san starts her housework."
	DB	NEXT
	DB	"Motoka:  Oniichan, let's go to school together."
	DB	NEXT
	DB	"Kenjirou:  Why?"
	DB	NEXT
	DB	"Motoka:  Why? I just want to. Will you go with me?"
	DB	NEXT
	DB	"Kenjirou:  .................."
	DB	NEXT
	DB	"Motoka:  Why did you get quiet like that? It's okay, isn't it?" 
	DB	NEXT
	DB	"Motoka:  ...You'd better listen to me, young man!" 
	DB	NEXT
	DB	"She brought her face close to mine, so that her long hair was just touching my cheek."
	DB	NEXT
	DB	"Kenjirou:  W- What are you doing?"
	DB	NEXT
	DB	"Motoka:  ...Punishment." 
	DB	NEXT
	DB	"Kenjirou:  What...?"
	DB	NEXT
	DB	"Motoka:  Hey hey hey hey hey!"
	DB	NEXT
	DB	"Letting out a loud kiai, she swung her head from left to right violently, causing her hair to whip around and lash my face."
	DB	NEXT
	DB	"I- I didn't know she had a special attack like this. I'd better be more careful not to anger her in the future."
	DB	NEXT
	DB	"Motoka:  Hey hey hey!"
	DB	NEXT
	DB	"Kenjirou:  O- Okay, okay. I understand. I'll go to school with you."
	DB	NEXT
	DB	"Motoka:  Really?" 
	DB	NEXT
	DB	"She stopped her special attack and smiled."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"We left the house together. We then headed for the convenience store that was on the way."
	DB	NEXT
	BAK_INIT 'tb_006',B_NORM
	CDPLAY		23
	T_CG 'tt_10_06',MOT_A2,0
	DB	"Shiho:  Kondo-kun, good morning."
	DB	NEXT
	DB	"I turn around to see Kashima-san standing there, smiling."
	DB	NEXT
	TATI_ERS		;Tt_10
	T_CG 'tt_02_06',SIH_A3,0
	T_CG 'tt_21_06',MOT_B1,0
	DB	"Motoka:  Oniichan, who is she?" 
	DB	NEXT
	DB	"Kenjirou:  Ah, she's the transfer student, Kashima-san. Motoka, say good morning to her."
	DB	NEXT
	DB	"Motoka:  ...Good morning."
	DB	NEXT
	DB	"Motoka greets Shiho in a flat tone of voice."
	DB	NEXT
	DB	"Shiho:  Good morning. Are you Kondo-kun's sister?"
	DB	NEXT
	DB	"Kenjirou:  That's right. We're not really related, though."
	DB	NEXT
	DB	"Shiho:  I...see."
	DB	NEXT
	DB	"Motoka:  My name is Motoka Kondo."
	DB	NEXT
	DB	"Shiho:  I'm Shiho Kashima. Nice to meet you."
	DB	NEXT
	DB	"Motoka:  ...Same here."
	DB	NEXT
	DB	"Kenjirou:  What's wrong? Motoka, you should be more cheerful when you talk."
	DB	NEXT
	DB	"Motoka:  ...I'm cheerful." 
	DB	NEXT
	DB	"Embarrassed, Motoka turns the other way."
	DB	NEXT
	DB	"Shiho:  ...Ah, well, I'll be going on to school now."
	DB	NEXT
	DB	"With that, she left Motoka and me alone."
	DB	NEXT
	TATI_ERS	;Tt_02
	CDPLAY		20
	T_CG 'tt_21_06',MOT_B2,0
	DB	"Kenjirou:  ...Motoka, what's wrong with you? You were pretty rude."
	DB	NEXT
	DB	"Motoka:  In what way?"
	DB	NEXT
	DB	"Kenjirou:  In what way? You came off sounding rude. "
	DB	NEXT
	DB	"Motoka:  ...Is it my fault? Am I to blame?" 
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Motoka:  I didn't do anything wrong. Why..." 
	DB	NEXT
	DB	"She stood there looking more and more hurt and upset."
	DB	NEXT
	DB	"Kenjirou:  C- Come on, it's not that bad. I just..."
	DB	NEXT
	DB	"Motoka:  ...Oniichan..."
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Motoka:  ...Let's go to school."
	DB	NEXT
	DB	"Kenjirou:  Ah, okay. Let's go."
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"Motoka and I headed for school. We didn't speak during the time at all."
	DB	NEXT
	SINARIO 'MON_13.OVL'
END