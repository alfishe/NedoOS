        include SUPER_C.inc
M_START:
NITI_MAT
	FLG_KI	TEMP01,'=',0
	FLG_IF MOTDOYOU,'=',2,FUFUFU_7
	FLG_IF	MOTSUNE,'=',3,MOTOKA
	GO FUTUMATI
MOTOKA:
	CDPLAY	20
	BAK_INIT	'tb_018c',B_NORM
	T_CG	'tt_03_18c',HIR1,0
	T_CG	'tt_21_18c',MOT_B3,0
	DB	"Motoka:  Ah..."
	DB	NEXT
	DB	"Kenjirou:  Motoka?"
	DB	NEXT
	TATI_ERS
	DB	"Seeing me, Motoka and Hiroshi start moving away faster, getting lost among the other people."
	DB	NEXT
	DB	"Kenjirou:  Motoka....."
	DB	NEXT
	DB	"I start to run after her, but stop myself. She's lost in the mass of bodies."
	DB	NEXT
	DB	"I can't just stand here. I've got to do something..."
	DB	NEXT
	GO	UU_1
FUTUMATI:
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY	22
	DB	"When I left the school, it was still light out. Now it's completely dark."
	DB	NEXT
	DB	"Where should I go?"
	DB	NEXT
UU_1:
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
	FLG_KI TEMP08,'=',0
	GO	SENTAKU
MATI:
	BAK_INIT	'tb_018c',B_NORM
	DB	"Where should I go?"
	DB	NEXT
SENTAKU:
	FLG_KI W,'=',-1
	FLG_IF TEMP02,'=',0,SA_1
	FLG_KI W,'DOWN',0
SA_1:
	FLG_IF TEMP03,'=',0,SA_2
	FLG_KI W,'DOWN',1
SA_2:
	FLG_IF TEMP04,'=',0,SA_3
	FLG_KI W,'DOWN',2
SA_3:
	FLG_IF TEMP05,'=',0,SA_4
	FLG_KI W,'DOWN',3
SA_4:
	FLG_IF TEMP06,'=',0,SA_5
	FLG_KI W,'DOWN',4
SA_5:
	FLG_IF TEMP07,'=',0,SA_6
	FLG_KI W,'DOWN',5
SA_6:
	FLG_IF TEMP08,'=',0,SA_7
	FLG_KI W,'DOWN',6
SA_7:
	FLG_IF REN_ATTA,'=',1,SA_8
	FLG_KI W,'DOWN',5
SA_8:
	FLG_IF NAN_ATTA,'=',1,SA_9
	FLG_KI W,'DOWN',6
SA_9:
	MENU_S	2,W,-1
	MENU_SET	AH1,"MOVIE THEATRE"
	MENU_SET	AH2,"LINGERIE PUB"
	MENU_SET	AH3,"PARK"
	MENU_SET	AH4,"HOTEL"
	MENU_SET	AH5,"BAR"
	MENU_SET	AH6,"COFFEE SHOP"
	MENU_SET	AH7,"RESTAURANT"
	MENU_SET	AH8,"GO HOME"
	MENU_END
	DB	EXIT
AH1:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"Guess I'll go check out a movie."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB	"Wow, this area is really run down."
	DB	NEXT
	DB	"There's no movie I really want to see, anyway."
	DB	NEXT
	GO MATI
AH2:
	FLG_IF RAYABA,'=',1,YABAI
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI	TET_KAIS,'+',1
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"I guess I'll go to the lingerie pub."
	DB	NEXT
	BAK_INIT 'tb_027',B_NORM
	DB	"It's a nice place. Really made to my taste."
	DB	NEXT
	T_CG 'tt_07_27',TET_B2,0
	FLG_KI TET_KAIS,'+',1
	DB	"Tetsuya:  What are you doing here?"
	DB	NEXT
	DB	"Tetsuya appears in front of me."
	DB	NEXT
	DB	"Kenjirou:  What about you?"
	DB	NEXT
	DB	"Tetsuya:  Me? I, um... I was just thinking about going in... Wouldn't it be great?" 
	DB	NEXT
	DB	"Kenjirou:  Really?"
	DB	NEXT
	DB	"Tetsuya:  How about you?"
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Tetsuya:  I'm sure you want to go in, too."
	DB	NEXT
	DB	"Kenjirou:  Well, I'll admit it."
	DB	NEXT
	DB	"Tetsuya:  See? So what are you going to do?" 
	DB	NEXT
	DB	"Tetsuya is looking at the lingerie pub sign, with an odd expression on his face. He seems to be in his own world."
	DB	NEXT
	DB	"I guess I shouldn't talk to him now..."
	DB	NEXT
	GO MATI
YABAI:
	DB	"I don't know if I can do it..."
	DB	NEXT
	GO MATI
AH3:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"The park at night. It's kind of erotic..."
	DB	NEXT
	FLG_IF	TERUNASI,'=',1,TERUMICHAN
	BAK_INIT 'tb_032b',B_NORM
	CDPLAY	8
	DB	"Couples are walking together. It's great to watch them."
	DB	NEXT
	DB	"Terumi:  What are you doing out here?"
	DB	NEXT
	DB	"Hearing a voice I know, I turn around slowly to see Terumi-senpai."
	DB	NEXT
	T_CG 'tt_05_32b',TER2,0
	DB	"Kenjirou:  Ah, Terumi-senpai."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AI1,"LOOK AT BREASTS"
	MENU_SET	AI2,"LOOK AT ASS"
	MENU_SET	AI3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
AI1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,HH_1
	FLG_KI TER_NET,'=',1
HH_1:
	DB	"Terumi-senpai's breasts are great. Truly wonderful."
	DB	NEXT
	GO BODY_TERUMI
AI2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,HH_2
	FLG_KI TER_NET,'=',1
HH_2:
	DB	"A wonderful ass, perfectly shaped, with a great line extending out from her hip."
	DB	NEXT
	GO BODY_TERUMI
AI3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,HH_3
	FLG_KI TER_NET,'=',1
HH_3:
	DB	"Her thighs are exceptional, smooth and silky."
	DB	NEXT
	GO BODY_TERUMI
BODY_TERUMI:
	DB	"Terumi:  W- What's wrong? Why did you get quiet like that?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? I was just wondering why you were here..."
	DB	NEXT
	DB	"Terumi:  I'm just out for a walk."
	DB	NEXT
	DB	"Kenjirou:  In the dark, like this?"
	DB	NEXT
	DB	"Terumi:  Are you worried about me?"
	DB	NEXT
	DB	"She seems a little happy at the prospect of this."
	DB	NEXT
	DB	"Kenjirou:  Sure, of course I am. What would I do if someone attacked you?"
	DB	NEXT
	DB	"Terumi:  You're worried about things like that?"
	DB	NEXT
	DB	"Kenjirou:  I- I'm sorry!"
	DB	NEXT
	DB	"I leave that place in a hurry."
	DB	NEXT
	GO MATI
TERUMICHAN:
	BAK_INIT 'tb_032b',B_NORM
	CDPLAY	8
	DB	"Couples are walking together. It's so nice to see true love."
	DB	NEXT
	DB	"I wonder if Terumi-senpai is around..."
	DB	NEXT
	DB	"Kenjirou:  I have to admit, I'm lonely."
	DB	NEXT
	GO	MATI
AH4:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"I can't think of much reason to go there, but I'll check it out."
	DB	NEXT
	BAK_INIT 'tb_025',B_NORM
	DB	"There's a sign here, advertising the room rates."
	DB	NEXT
	DB	"There's no reason for me to be standing around here by myself."
	DB	NEXT
	GO MATI
AH5:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"I couldn't go in there. "
	DB	NEXT
	DB	"Well, maybe I can just stand outside."
	DB	NEXT
	DB	"I head for the bar."
	DB	NEXT
	BAK_INIT 'tb_029',B_NORM
	T_CG 'tt_03_29',HIR2,0
	DB	"Hiroshi:  What are you doing here?"
	DB	NEXT
	DB	"Oh no! It's Hiroshi!"
	DB	NEXT
	DB	"Kenjirou:  I'm not doing anything, just walking by. Well, see you later."
	DB	NEXT
	DB	"I leave the bar behind me."
	DB	NEXT
	GO MATI
AH6:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP07,'=',1
	DB	"A coffee shop. I wonder if Rena's there today?"
	DB	NEXT
	BAK_INIT 'tb_021',B_NORM
	T_CG 'tt_17_21',REN_A2,0
	DB	"Rena:  Hello, can I help you?"
	DB	T_WAIT, 5
	DB	" Oh, it's you, Kenjirou."
	DB	NEXT
	DB	"Kenjirou:  Don't sound so disappointed."
	DB	NEXT
	DB	"Rena:  I'm not, it's just that 'Can I help you?' is for customers, but you're more like a friend."
	DB	NEXT
	DB	"Kenjirou:  I see. Aren't you cold, dressed up like that?"
	DB	NEXT
	DB	"Rena:  No, I'm fine." 
	DB	NEXT
	DB	"Kenjirou:  Really? Then it's okay. "
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AJ1,"LOOK AT NECK"
	MENU_SET	AJ2,"LOOK AT SHOULDER"
	MENU_SET	AJ3,"LOOK AT TITS"
	MENU_END
	DB	EXIT
AJ1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_1
	FLG_KI RENA_NET,'=',1
GG_1:
	DB	"Her neck is white and pure. I want to run tiny lines of spit with my tongue on it."
	DB	NEXT
	GO	REN
AJ2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',7
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_2
	FLG_KI RENA_NET,'=',1
GG_2:
	DB	"Her shoulders are the kind that make you want to draw a girl near you, to protect her."
	DB	NEXT
	GO	REN
AJ3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',14
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,GG_3
	FLG_KI RENA_NET,'=',1
GG_3:
	DB	"It must be the apron, but I can't tell for sure how much volume she has. I'll have to find out for sure..."
	DB	NEXT
	GO	REN
REN:
	DB	"Rena:  Hey, you..." 
	DB	T_WAIT, 5
	DB	" You're looking someplace you shouldn't, aren't you?"
	DB	NEXT
	DB	"Kenjirou:  I have to plead guilty to that one."
	DB	NEXT
	DB	"Rena:  You and I aren't going together anymore, remember."
	DB	NEXT
	DB	"Kenjirou:  I know, I know..."
	DB	NEXT
	DB	"Rena:  Then I guess it's okay." 
	DB	NEXT
	DB	"She pats me on the head, like a dog."
	DB	NEXT
	DB	"Rena:  Haha..."
	DB	T_WAIT, 5
	DB	" Thanks."
 	DB	NEXT
	DB	"Mmmm... I wish I were still with Rena..."
	DB	NEXT
	FLG_IF	MOTSUNE,'=',1,REN2
	DB	"I leave the coffee shop."
	DB	NEXT
	GO	MATI
REN2:
	DB	"Kenjirou:  Anyway, I have something to ask. Will you tell me if you see Motoka in here?"
	DB	NEXT
	DB	"Rena:  Eh? Is she late, coming home from school?" 
	DB	NEXT
	DB	"Kenjirou:  No, that's not it."
	DB	NEXT
	DB	"Rena:  Then what is it?"
	DB	NEXT
	DB	"What should I tell her? Um, er..."
	DB	NEXT
	DB	"Kenjirou:  I, I just want to make sure she isn't coming into any dangerous places, like this coffee shop."
	DB	NEXT
	DB	"Master:  Gee, thanks for the vote of confidence."
	DB	NEXT
	DB	"Kenjirou:  Oops! Well, I'll be going now..."
	DB	NEXT
	DB	"Rena:  Wait, come back!" 
	DB	NEXT
	DB	"I leave the coffee shop."
	DB	NEXT
	GO	MATI
AH7:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP08,'=',1
	DB	"I'm not really hungry, but I guess I could go there..."
	DB	NEXT
	BAK_INIT 'tb_023',B_NORM
	T_CG	'tt_14_23',NAN2,0
	DB	"Nana:  Hello, can I help you?"
	DB	NEXT
	DB	"Kenjirou:  Oh good, you're here."
	DB	NEXT
	DB	"Nana:  What would you like?"
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	AK1,"LOOK AT BREASTS"
	MENU_SET	AK2,"LOOK AT BREASTS"
	MENU_SET	AK3,"LOOK AT BREASTS"
	MENU_END
	DB	EXIT
AK1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,RR_1
	FLG_KI NANA_NET,'=',1
RR_1:
	DB	"They're great. What more can I say?"
	DB	NEXT
	GO	NAN
AK2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,RR_2
	FLG_KI NANA_NET,'=',1
RR_2:
	DB	"Wonderful breasts. Simply wonderful."
	DB	NEXT
	GO	NAN
AK3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,RR_3
	FLG_KI NANA_NET,'=',1
RR_3:
	DB	"Her uniform is practically bursting under the weight of her breasts."
	DB	NEXT
	GO	NAN
NAN:
	DB	"Nana:  What would you like?"
	DB	NEXT
	DB	"Kenjirou:  Your breasts..."
	DB	NEXT
	DB	"Nana:  I'm sorry, we don't have anything like that at this restaurant." 
	DB	NEXT
	DB	"Kenjirou:  Okay, I'll leave then."
	DB	NEXT
	DB	"Nana:  Thank you." 
	DB	NEXT
	DB	"I leave the fast-food restaurant."
	DB	NEXT
	GO	MATI
AH8:
	GO JITAKU
JITAKU:
	BAK_INIT	'tb_018c',B_NORM
	DB	"Well, it's kind of late. Guess I should head home."
	DB	NEXT
	SINARIO 'JUMP.OVL'
	DB	EXIT
HEYA:
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_FADE,C_KURO
	DB	"Kenjirou:  Uuummm?"
	DB	NEXT
	DB	"I slowly open my eyes."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY 12
	DB	"Kenjirou:  Where am I?"
	DB	NEXT
	DB	"My mind swirls with confusion as I slowly look around me. I seem to be in my own room."
	DB	NEXT
	DB	"What the hell...?"
	DB	NEXT
	DB	"There's a brown stain on my clothes."
	DB	NEXT
	DB	"Blood? I must have had a nosebleed..."
	DB	NEXT
	DB	"What happened...?"
	DB	NEXT
	DB	"I must have lost consciousness. "
	DB	NEXT
	DB	"Who carried me to my room?"
	DB	NEXT
	DB	"Hmm. I guess I can find out later. Guess I'll sleep some more now."
	DB	NEXT
	FLG_KI HIDUKE,'+',1
	FLG_KI HANAJI,'=',1
	B_O	B_FADE,C_KURO
	CDPLAY		0
	SINARIO 'JUMP.OVL'
	DB	EXIT
FUFUFU_7:
	FLG_KI MOTDOYOU,'=',0
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
	BAK_INIT 'tb_018a',B_NORM
	CDPLAY		2
	FLG_KI	MOTDOYOU,'=',0
	DB	"I haven't been here during the day for a while."
	DB	NEXT
	GO	RARA
MATI2:
	BAK_INIT	'tb_018a',B_NORM
	DB	"I wonder where I should go?"
	DB	NEXT
RARA:
	FLG_KI W,'=',-1
	FLG_IF TEMP02,'=',0,FF_1
	FLG_KI W,'DOWN',0
FF_1:
	FLG_IF TEMP03,'=',0,FF_2
	FLG_KI W,'DOWN',1
FF_2:
	FLG_IF TEMP04,'=',0,FF_3
	FLG_KI W,'DOWN',2
FF_3:
	FLG_IF TEMP05,'=',0,FF_4
	FLG_KI W,'DOWN',3
FF_4:
	FLG_IF TEMP06,'=',0,FF_5
	FLG_KI W,'DOWN',4
FF_5:
	FLG_IF TEMP07,'=',0,FF_6
	FLG_KI W,'DOWN',5
FF_6:
	MENU_S	2,W,-1
	MENU_SET	F1,"MOVIE THEATRE"
	MENU_SET	F2,"LINGERIE PUB"
	MENU_SET	F3,"PARK"
	MENU_SET	F4,"HOTEL"
	MENU_SET	F5,"BAR"
	MENU_SET	F6,"COFFEE SHOP"
	MENU_SET	F7,"GO HOME"
	MENU_END
	DB	EXIT
F1:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"I wonder if there's a good movie playing."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB	"It's kind of bright out."
	DB	NEXT
	DB	"I guess I can see a movie anytime."
	DB	NEXT
	DB	"Plus, there's no good movie playing now."
	DB	T_WAIT, 5
	DB	" Guess I'll go back."
	DB	NEXT
	GO MATI2
F2:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"That isn't a place to go during the day."
	DB	NEXT
	GO MATI2
F3:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"I guess it's a good place to kill some time."
	DB	NEXT
	BAK_INIT 'tb_032a',B_NORM
	CDPLAY		8
	DB	"There are couples here, walking together."
	DB	NEXT
	DB	"Terumi:  What are you doing here?"
	DB	NEXT
	DB	"I hear a voice behind me -- Terumi-senpai."
	DB	NEXT
	T_CG 'tt_05_32a',TER2,0
	DB	"Kenjirou:  Ah, Terumi-senpai."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	G1,"LOOK AT TITS"
	MENU_SET	G2,"LOOK AT ASS"
	MENU_SET	G3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
G1:
	FLG_IF YOKU,'>=',100,HEYA2
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_1
	FLG_KI TER_NET,'=',1
LL_1:
	DB	"Great tits, with lots of volume."
	DB	NEXT
	GO BODY_TERUMI2
G2:
	FLG_IF YOKU,'>=',100,HEYA2
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_2
	FLG_KI TER_NET,'=',1
LL_2:
	DB	"I love Terumi-senpai's ass. A great line, extending from her waist."
	DB	NEXT
	GO BODY_TERUMI2
G3:
	FLG_IF YOKU,'>=',100,HEYA2
	FLG_KI YOKU,'+',9
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LL_3
	FLG_KI TER_NET,'=',1
LL_3:
	DB	"Her thighs are plump and juicy."
	DB	NEXT
	GO BODY_TERUMI2
BODY_TERUMI2:
	DB	"Terumi:  What's the matter?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, nothing. I was just wondering why you were here."
	DB	NEXT
	DB	"Terumi:  I'm just out for a walk. What about you?"
	DB	NEXT
	DB	"Kenjirou:  Me?"
	DB	NEXT
	DB	" Me? Well, I..."
	DB	T_WAIT, 5
	DB	" I wanted to smell you..."
	DB	NEXT
	DB	"Terumi:  Are you a dog?" 
	DB	NEXT
	DB	"Kenjirou:  Yes, if I can be your dog."
	DB	NEXT
	DB	"Terumi:  ...Okay, dog." 
	DB	NEXT
	DB	"She smiles, looking at me."
	DB	NEXT
	DB	"Oh no! She's thinking dangerous things again..."
	DB	NEXT
	DB	"Terumi:  Well? Aren't you going to answer me, dog?"
	DB	NEXT
	DB	"Kenjirou:  Woof!"
	DB	NEXT
	DB	"Terumi:  Good dog..." 
	DB	NEXT
	DB	"Time for me to run away."
	DB	NEXT
	DB	"Kenjirou:  Woof! Woof! "
	DB	NEXT
	DB	"Terumi:  Hey, come back!" 
	DB	NEXT
	DB	"I got out of there in a hurry."
	DB	NEXT
	GO MATI2
F4:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP05,'=',1
	DB	"It's not a place to go during the day."
	DB	NEXT
	GO MATI2
F5:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP06,'=',1
	DB	"It's not a place to go during the day."
	DB	NEXT
	GO MATI2
F6:
	FLG_IF TEMP01,'>=',3,JITAKU2
	FLG_KI TEMP01,'+',1
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI TEMP07,'=',1
	DB	"A coffee shop? I think there was one around here somewhere."
	DB	NEXT
	GO MATI2
F7:
	FLG_IF	TEMP01,'>=',3,JITAKU2
	DB	"Hmm, it's a little too early to go home yet."
	DB	NEXT
	GO MATI2
JITAKU2:
	BAK_INIT	'tb_018b',B_NORM
	DB	"I guess I'll go home now."
	DB	NEXT
	BAK_INIT 'tb_005b',B_NORM
	DB	"The setting sun is painting my house orange and yellow."
	DB	NEXT
	DB	"It's good to go home early for a change."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		6
	DB	"Akemi-san is here, but I don't see Motoka."
	DB	NEXT
	T_CG 'tt_20_02',AKE_A2,0
	DB	"Akemi:  Ah, Kenjirou. Welcome home."
	DB	NEXT
	DB	"Kenjirou:  Thanks."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	H1,"LOOK AT COLLARBONE"
	MENU_SET	H2,"LOOK AT TITS"
	MENU_SET	H3,"LOOK AT STOCKINGS"
	MENU_END
	DB	EXIT
H1:
	FLG_IF YOKU,'>=',100,HEYA2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL
	FLG_IF YOKU,'<',100,LA_1
	FLG_KI AKEM_NET,'=',1
LA_1:
	DB	"A sexy collarbone, with a good straight edge. I'd love to taste it."
	DB	NEXT
	GO BODY_AKEMI
H2:
	DB	"Her breasts are wonderful. I'd love to rest my head between those hills."
	DB	NEXT
	GO BODY_AKEMI
H3:
	FLG_IF YOKU,'>=',100,HEYA2
	FLG_KI YOKU,'+',10
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,LA_3
	FLG_KI AKEM_NET,'=',1
LA_3:
	DB	"Her stockings go all the way up to the glory of her crotch. Silky smooth."
	DB	NEXT
	GO BODY_AKEMI
BODY_AKEMI:
	DB	"Akemi:  What's the matter?"
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, nothing."
	DB	NEXT
	DB	"Akemi:  You're such a strange boy." 
	DB	NEXT
	DB	"Kenjirou:  Um, have you seen Motoka?"
	DB	NEXT
	DB	"Akemi:  She's in her room."
	DB	NEXT
	DB	"Kenjirou:  Oh."
	DB	NEXT
	B_O B_FADE,C_KURO	;F.O
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"Hmm, guess I'll go to sleep."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'JUMP.OVL'
HEYA2:
	FLG_KI HANAJI,'=',1
	MC_FLASH	3,C_RED
	B_O	B_FADE,C_KURO
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_NORM,C_KURO
	DB	"Kenjirou:  Uuuuummmm?"
	DB	NEXT
	DB	"I slowly open my eyes."
	DB	NEXT
	BAK_INIT 'tb_001b',B_FADE
	DB	"Kenjirou:"
	DB	NEXT
	DB	"I wake up with my head swirling. I seem to be in my room."
	DB	NEXT
	DB	"I wonder what happened?"
	DB	NEXT
	DB	"There's a brown stain on my clothes."
	DB	NEXT
	DB	"Blood? I must have had a nosebleed."
	DB	NEXT
	DB	"I probably fell collapsed. But what happened after that?"
	DB	NEXT
	DB	"I must have lost consciousness."
	DB	NEXT
	DB	"But who carried me back here?"
	DB	NEXT
	DB	"Hmmm. Well, I guess I'll find out later. Better sleep now."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'JUMP.OVL'
	DB	EXIT
END