        include SUPER_C.inc
M_START:
MON_31A
	BAK_INIT	'tb_022',B_NORM
	CDPLAY	2
	DB	"It's right over this bridge..."
	DB	T_WAIT,	3
	DB	"*CRASH*"
	DB	NEXT
	EVENT_CG	'ti_108',B_NORM,82
	DB	GATA,	1
	F_O	B_NORM,C_KURO
	CDPLAY	7
	DB	"Kenjirou:  Ouch..."
	DB	NEXT
	DB	"Voice:  Fufu..."
	DB	NEXT
	DB	"I heard a voice, laughing softly. I opened my eyes, and looked up."
	DB	NEXT
	EVENT_CG	'th_052',B_FADE,21
	FLG_KI	NAN_ATTA,'=',1
	DB	"In front of me was a girl with enormous breasts, wearing an orange skirt. I could see her panties clearly."
	DB	NEXT
	FLG_IF	YOKU,'>=',100,HEYA
	FLG_KI	YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Nana:  Are you okay?" 
	DB	NEXT
	DB	"Kenjirou:  Y- Yes, thanks."
	DB	NEXT
	DB	"Nana:  Can you stand?"
	DB	NEXT
	DB	"(I'd rather sit like this for a while longer...)"
	DB	NEXT
	DB	"Kenjirou:  Yes, I think so..."
	DB	NEXT
	DB	"Nana:  Then I think you should get up."
	DB	NEXT
	DB	"That's a good idea. She might think I'm some kind of pervert if I stay down here too long."
	DB	NEXT
	DB	"I slowly get to my feet."
	DB	NEXT
	BAK_INIT	'tb_022',B_NORM
	CDPLAY	2
	T_CG	'tt_14_22',NAN2,0
	DB	"Nana:  Here you go."
	DB	NEXT
	DB	"The girl Nana handed me a pamphlet she'd been handing out. I got a great look at her breasts."
	DB	NEXT
	DB	"They were so big, her uniform blouse looked like it would burst open any minute. I read her nameplate."
	DB	NEXT
	DB	"T- Those are huge. Her name is Nana Hirose. I'd better remember that name."
	DB	NEXT
	DB	"Nana:  Please come to our shop."
	DB	NEXT
	DB	"Kenjirou:  Um, okay. Thanks."
	DB	NEXT
	DB	"I continued on to the restaurant."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_023',B_NORM
	DB	"Girl:  Hello, can I help you? What would you like to order?"
	DB	NEXT
	DB	"The girl, smiling from ear to ear, waited behind the cash register."
	DB	NEXT
	DB	"I really hate all fast food. What should I get?"
	DB	NEXT
	DB	"I looked at the menu in front of me, and chose a hamburger set."
	DB	NEXT
	DB	"Girl:  That will be 525 yen."
	DB	NEXT
	DB	"I reached around to my back pocket for my wallet."
	DB	NEXT
	DB	"......It's not there!"
	DB	NEXT
	DB	"Girl:  525 yen, please."
	DB	NEXT
	DB	"Kenjirou:  ................................................."
	DB	NEXT
	DB	"Without saying anything, I put the restaurant behind me."
	DB	NEXT
	BAK_INIT	'tb_018a',B_NORM
	DB	"Ah! I can't believe I forgot my wallet!"
	DB	NEXT
	DB	"I guess I'll go home."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_005a',B_NORM
	DB	"I'll go right in..."
	DB	NEXT
	B_O	B_FADE,C_KURO
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	DB	"Entering the house, I immediately noticed a ruckus coming from the living room."
	DB	NEXT
	DB	"What's that noise?"
	DB	NEXT
	DB	"Kenjirou:  I'm home."
	DB	NEXT
	DB	"Akemi:  Ah, welcome back."
	DB	NEXT
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Kenjirou:  What's that noise I heard just now?"
	DB	NEXT
	DB	"Akemi:  Fufu... Motoka's back home."
	DB	NEXT
	DB	"Kenjirou:  ...And?"
	DB	NEXT
	DB	"Akemi:  She brought a friend with her."
	DB	NEXT
	DB	"Kenjirou:  A friend?"
	DB	NEXT
	DB	"Akemi:  She was at her friend's house last night, apparently."
	DB	NEXT
	DB	"Kenjirou:  Eh? Is that right?"
	DB	NEXT
	DB	"Akemi:  Yes, apparently. I just got off the phone with her friend."
	DB	NEXT
	DB	"Kenjirou:  ...Is that friend of hers a man?"
	DB	NEXT
	DB	"Akemi:  No, it's a girl. I checked."
	DB	NEXT
	DB	"Kenjirou:  I see."
	DB	NEXT
	DB	"Akemi:  But a boy is supposedly coming along today."
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Akemi:  He's supposed to be quite handsome. That's why Motoka is excited."
	DB	NEXT
	DB	"Handsome? Who could it be?"
	DB	NEXT
	SINARIO	'MON_33.OVL'
HEYA:
	SINARIO	'MON_31C.OVL'
END