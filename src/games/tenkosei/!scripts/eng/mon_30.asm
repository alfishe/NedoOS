        include SUPER_C.inc
M_START:
MON_30
	BAK_INIT 'tb_001a',B_NORM
	CDPLAY 12
	DB	"Kenjirou:  ...Mm...mmmm..."
	DB	T_WAIT,	3
	DB	" Ah! I wonder if Motoka's home yet?"
	DB	NEXT
	DB	"I jumped out of bed, and looked at the clock. It reads 10:00 am."
	DB	NEXT
	DB	"I get dressed, and walk over to Motoka's room."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY	0
	DB	"I lightly knock on her door."
	DB	NEXT
	;WAV	'Se_no'
	DB	"But there's no answer."
	DB	NEXT
	DB	"Kenjirou:  Motoka?"
	DB	NEXT
	;WAV	'Se_no'
	DB	"I call her as I knock this time."
	DB	NEXT
	DB	"But still, there's no sound from the other side of the door."
	DB	NEXT
	DB	"Kenjirou:  Motoka?"
	DB	T_WAIT,	3
	DB	" I'm going to open the door."
	DB	NEXT
	DB	"I turn the knob. The door isn't locked."
	DB	NEXT
	BAK_INIT	'tb_003',B_NORM
	DB	"Kenjirou:  Motoka?"
	DB	NEXT
	DB	"She's not in her room. Suddenly, a deep unrest assaults my soul. "
	DB	NEXT
	DB	"I run down to the dining kitchen as fast as I can."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Akemi:  Ah, good morning. You're up early, for a Sunday." 
	DB	NEXT
	DB	"Akemi-san's here like she always is, doing housework."
	DB	NEXT
	DB	"But Motoka is nowhere to be seen."
	DB	NEXT
	DB	"Kenjirou:  ...Akemi-san, is Motoka home?"
	DB	NEXT
	DB	"Akemi:  Not yet."
	DB	NEXT
	DB	"Kenjirou:  ...I see."
	DB	T_WAIT,	3
	DB	" Um, I'm going to look for her."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"Visions of Hiroshi flashing in my head, I ran out of the dining kitchen."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_018a',B_NORM
	CDPLAY	23
	DB	"Not knowing where to go, I headed downtown."
	DB	NEXT
	DB	"Let's look around here, first."
	DB	NEXT
	DB	"Shiho:  Ah, Kenjirou-kun..." 
	DB	NEXT
	DB	"I turned at the voice, and Shiho was there."
	DB	NEXT
	T_CG	'tt_01_18a',SIH_B2,0
	DB	"Kenjirou:  .....Shi"
	DB	T_WAIT,	3
	DB	"ho?"
	DB	NEXT
	DB	"Shiho:  What's wrong? You look like a fox pinched your face or something?" 
	DB	NEXT
	DB	"She was wearing the exact same clothes that the Shiho in my fantasy had been wearing."
	DB	NEXT
	DB	"It couldn't be... No, it's just a coincidence..."
	DB	NEXT
	DB	"Shiho:  Are you okay? You're staring at me as if I were a ghost."
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, I'm okay, sorry. I'd never seen you out of your uniform before."
	DB	NEXT
	DB	"Shiho:  ...I see." 
	DB	NEXT
	DB	"Her face turned red. Just as my fantasy Shiho would have done. It was as if the two girls were the same."
	DB	NEXT
	DB	"Kenjirou:  Anyway, what are you doing out here?"
	DB	NEXT
	DB	"Shiho:  Eh? Me?" 
	DB	T_WAIT,	3
	DB	" I'm just doing some shopping."
	DB	NEXT
	DB	"Hmm, shopping is something my fantasy Shiho wouldn't have been doing."
	DB	NEXT
	DB	"Shiho:  What about you?"
	DB	NEXT
	DB	"Kenjirou:  Oh, I'm...looking for my sister."
	DB	NEXT
	DB	"Shiho:  ...Motoka-chan?"
	DB	T_WAIT,	3
	DB	" Is something wrong?"
	DB	NEXT
	DB	"Kenjirou:  Ah, a little."
	DB	NEXT
	DB	"Shiho:  A little?" 
	DB	NEXT
	DB	"Kenjirou:  ...No, it's really that bad."
	DB	T_WAIT,	3
	DB	" She was out all night last night."
	DB	NEXT
	DB	"Shiho:  ...I see." 
	DB	NEXT
	DB	"She looked worried for a moment."
	DB	NEXT
	DB	"Shiho:  Kenjirou-kun is the kind of person who really takes care of his little sister..."
	DB	T_WAIT,	3
	DB	" That would be nice."
	DB	NEXT
	DB	"Kenjirou:  Eh? Did you say something?"
	DB	NEXT
	DB	"Shiho:  N- Nothing at all. I didn't say anything." 
	DB	NEXT
	DB	"Her face turned red again, and she looked at her feet."
	DB	NEXT
	DB	"I'm sure she said 'that would be nice.' I wonder what she meant by that?"
	DB	NEXT
	DB	"Kenjirou:  Anyway, if you see Motoka, will you call me?"
	DB	NEXT
	DB	"Shiho:  Eh? I don't mind, but how can I contact you?"
	DB	NEXT
	DB	"Kenjirou:  I'll give you my cell-phone number."
	DB	NEXT
	DB	"Shiho:  Eh? O- Okay." 
	DB	NEXT
	DB	"I wrote my phone number on a piece of paper, and handed it to Shiho."
	DB	NEXT
	DB	"Shiho:  I'll call you right away if I see her." 
	DB	NEXT
	DB	"Kenjirou:  Okay, thanks. I really appreciate it."
	DB	T_WAIT,	3
	DB	" Well, I've got to try somewhere else. "
	DB	NEXT
	DB	"Shiho:  Okay, I'll see you later. Good luck." 
	DB	NEXT
	TATI_ERS
	DB	"I left Shiho and went off to look for Motoka."
	DB	NEXT
	BAK_INIT	'tb_018a',B_NORM
	CDPLAY	2
	FLG_KI	TEMP01,'=',0
	FLG_KI	TEMP02,'=',0
	FLG_KI	TEMP03,'=',0
	FLG_KI	TEMP04,'=',0
	FLG_KI	TEMP05,'=',0
	FLG_KI	TEMP06,'=',0
	FLG_KI	TEMP07,'=',0
	FLG_KI	TEMP08,'=',0
FF_1:
	BAK_INIT	'tb_018a',B_NORM
	DB	"Well, where should I look now?"
	DB	NEXT
	FLG_KI	W,'=',-1
	FLG_IF	REN_ATTA,'=',1,BUNKI_A
	FLG_KI	W,'DOWN',5
BUNKI_A:
	FLG_IF	TEMP02,'=',0,BUNKI_C
	FLG_KI	W,'DOWN',0
BUNKI_C:
	FLG_IF	TEMP03,'=',0,BUNKI_D
	FLG_KI	W,'DOWN',1
BUNKI_D:
	FLG_IF	TEMP04,'=',0,BUNKI_E
	FLG_KI	W,'DOWN',2
BUNKI_E:
	FLG_IF	TEMP05,'=',0,BUNKI_F
	FLG_KI	W,'DOWN',3
BUNKI_F:
	FLG_IF	TEMP06,'=',0,BUNKI_G
	FLG_KI	W,'DOWN',4
BUNKI_G:
	FLG_IF	TEMP07,'=',0,BUNKI_H
	FLG_KI	W,'DOWN',5
BUNKI_H:
	MENU_S	2,W,-1
	MENU_SET	AH1,"MOVIE THEATER"
	MENU_SET	AH2,"LINGERIE PUB"
	MENU_SET	AH3,"PARK"
	MENU_SET	AH4,"LOVE HOTEL"
	MENU_SET	AH5,"BAR"
	MENU_SET	AH6,"COFFEE SHOP"
	MENU_END
	DB	EXIT
AH1:
	FLG_KI	TEMP02,'=',1
	FLG_IF	TEMP01,'>=',4,MATI02
	FLG_KI	TEMP01,'+',1
	DB	"A movie theatre, huh? I don't think Motoka would be there, but it's possible."
	DB	NEXT
	BAK_INIT	'tb_019',B_NORM
	DB	"This place is so run down. Motoka's not here."
	DB	NEXT
	DB	"I'd better go back..."
	DB	NEXT
	GO	FF_1
AH2:
	FLG_KI	TEMP03,'=',1
	FLG_IF	TEMP01,'>=',4,MATI02
	FLG_KI	TEMP01,'+',1
	DB	"There's no way she'd be there."
	DB	NEXT
	GO	FF_1
AH3:
	DB	"The park. I doubt it, but it's a possibility."
	DB	NEXT
	FLG_KI	TEMP04,'=',1
	FLG_IF	TEMP01,'>=',4,MATI02
	FLG_KI	TEMP01,'+',1
	BAK_INIT	'tb_031a',B_NORM
	DB	"It's pointless to stand around here like this."
	DB	NEXT
	DB	"I'd better go in."
	DB	NEXT
	BAK_INIT	'tb_032a',B_NORM
	DB	"There are lots of people here, holding hands and kissing."
	DB	NEXT
	DB	"Motoka is..."
	DB	T_WAIT,	3
	DB	"not here."
	DB	NEXT
	DB	"Guess I'll go back."
	DB	NEXT
	GO	FF_1
AH4:
	FLG_KI	TEMP05,'=',1
	FLG_IF	TEMP01,'>=',4,MATI02
	FLG_KI	TEMP01,'+',1
	DB	"Tetsuya was saying Motoka was with some girls. I doubt if girls would go into a hotel together."
	DB	NEXT
	DB	"But Hiroshi was also looking for her. But I'm sure Motoka's not that stupid..."
	DB	NEXT
	DB	"I'd better look somewhere else."
	DB	NEXT
	GO	FF_1
AH5:
	FLG_KI	TEMP06,'=',1
	FLG_IF	TEMP01,'>=',4,MATI02
	FLG_KI	TEMP01,'+',1
	DB	"It's not open at this hour."
	DB	NEXT
	GO	FF_1
AH6:
	FLG_KI	TEMP07,'=',1
	FLG_IF	TEMP01,'>=',4,MATI02
	FLG_KI	TEMP01,'+',1
	DB	"Rena didn't call me yesterday. I guess she didn't see Motoka after all."
	DB	NEXT
	BAK_INIT	'tb_021',B_NORM
	DB	"Master:  Hello, can I help you? Ah..."
	DB	T_WAIT,	3
	DB	" It's you, Kondo."
	DB	NEXT
	DB	"Kenjirou:  Hi, is Rena here?"
	DB	NEXT
	DB	"Master:  Ah, are you still chasing after that girl?"
	DB	NEXT
	DB	"Kenjirou:  No, I'm not!"
	DB	NEXT
	DB	"Master:  Really?"
	DB	NEXT
	DB	"Kenjirou:  Yes!"
	DB	NEXT
	DB	"Master:  Rena's not here right now."
	DB	NEXT
	DB	"Kenjirou:  Is she off today?"
	DB	NEXT
	DB	"Master:  No, we ran out of milk for the coffee, and she's out buying some more."
	DB	NEXT
	DB	"Kenjirou:  ...I see."
	DB	T_WAIT,	3
	DB	" Can I wait here for her to come back?"
	DB	NEXT
	DB	"Master:  No, you can't."
	DB	NEXT
	DB	"Kenjirou:  W- Why not?"
	DB	NEXT
	DB	"Master:  She brings in a lot of customers. I don't want you talking with her."
	DB	NEXT
	DB	"Kenjirou:  What? Why?"
	DB	NEXT
	DB	"Master:  If it appears that you're dating her, the other customers will stop coming in here. Understand?"
	DB	NEXT
	DB	"Kenjirou:  ..............."
	DB	NEXT
	DB	"Master:  Please understand. It could bankrupt this shop."
	DB	NEXT
	DB	"Kenjirou:  I don't think so."
	DB	NEXT
	DB	"Master:  I do! Everyone, young and old, loves Rena, and comes here just to see her. "
        DB      "You think they're coming for this horrible coffee?"
	DB	NEXT
	DB	"Wow, I didn't know he knew how bad his coffee was..."
	DB	NEXT
	DB	"Master:  I'm glad you understand. Besides, you had your chance with Rena back in Spring."
	DB	NEXT
	T_CG	'tt_17_21',REN_A2,0
	DB	"Rena:  I'm back. Oh, Kenjirou-kun, you're here." 
	DB	NEXT
	DB	"Just as I was being thrown out by the Master, Rena returned, holding bags full of milk."
	DB	NEXT
	DB	"Rena:  Who had what chance? What were you talking about?"
	DB	NEXT
	DB	"Master:  Oh, nothing. Will you put the milk in the refrigerator like a good girl?"
	DB	NEXT
	DB	"Rena:  Okay."
	DB	T_WAIT,	3
	DB	" Oh, by the way, Kenjirou, Motoka didn't come in yesterday."
	DB	NEXT
	DB	"Kenjirou:  I see..."
	DB	NEXT
	DB	"Rena:  Well, bye."
	DB	NEXT
	TATI_ERS
	DB	"Master:  Well, you talked to her, so will you please leave now?"
	DB	NEXT
	DB	"Kenjirou:  But wait..."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"But he wouldn't listen. He pushed me out the door into the street."
	DB	NEXT
	GO	FF_1
MATI02:
	BAK_INIT	'tb_018a',B_NORM
	DB	"Ah, I'm starved. I didn't eat anything since breakfast."
	DB	NEXT
	DB	"I've got to get something to eat. "
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	DOKU,"EAT FAST FOOD"
	MENU_SET	IE,"GO HOME AND EAT"
	MENU_END
	DB	EXIT
DOKU:
	DB	"I don't like fast food usually, but it does save time."
	DB	NEXT
	B_O	B_FADE,C_KURO
	SINARIO	'MON_31A.OVL'
	DB	EXIT
IE:
	DB	"Motoka might be home, waiting for me."
	DB	NEXT
	B_O	B_FADE,C_KURO
	SINARIO	'MON_31B.OVL'
	DB	EXIT
END