        include SUPER_C.inc
M_START:
MON_14
	FLG_IF HOK,'=',3,KYOUSITU
	FLG_IF HAND,'=',2,TOIRE
	F_O B_NORM,C_KURO
	DB	"Well, guess it's time to wake up. Class is probably over by now."
	DB	NEXT
	DB	"Kenjirou:  *Stretch!*"
	DB	NEXT
	DB	"I stretch like a cat, then open  my eyes."
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	CDPLAY		14
	DB	"Kenjirou:  Huh? There's no one here."
	DB	NEXT
	DB	"That jerk Tetsuya. He should have woken me up."
	DB	NEXT
	DB	"Well, guess I'll wander around a bit."
	DB	NEXT
	DB	"I leave the classroom."
	DB	NEXT
	BAK_INIT 'tb_034a',B_NORM
	DB	"Where should I go?"
	DB	NEXT
	DB	"Oh, I just remembered... I'm supposed to meet Kashima-san in the music room."
	DB	NEXT
	DB	"I'll go there now."
	DB	NEXT
	EVENT_CG 'ti_049',B_NORM,74
	CDPLAY		11
	DB	"I can hear the sound of Kashima-san's piano playing from out here in the hall."
	DB	NEXT
	DB	".....I'm sure I've heard that song before."
	DB	NEXT
	DB	"I wonder why? There's no explanation for it."
	DB	NEXT
	DB	"As I go in, she stops playing, and stands in front of me."
	DB	NEXT
	BAK_INIT 'tb_016',B_NORM
	T_CG 'tt_02_16',SIH_A2,0
	FLG_KI	SIH_KAIS,'+',1
	CDPLAY		23
	DB	"Shiho:  Kondo-kun, you came."
	DB	NEXT
	DB	"Kenjirou:  Eh? Well, yes, I did promise..."
	DB	NEXT
	DB	"As I look into Shiho's eyes, I'm reminded again of my other Shiho."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	I1,"LOOK AT FACE"
	MENU_SET	I2,"LOOK AT TITS"
	MENU_SET	I3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
I1:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"She's beautiful. Her face is just the perfect shape."
	DB	NEXT
	GO BODY_SIHO
I2:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"It's hard to see her breasts through her uniform, but they must be perfect."
	DB	NEXT
	GO BODY_SIHO
I3:
	FLG_KI YOKU,'-',15
	;SUBSINARIO 'YOKUJOU.OVL'
	DB	"Lovely thighs, so soft and white, with just the right amount of flesh on them."
	DB	NEXT
	GO BODY_SIHO
BODY_SIHO:
	FLG_KI AKEM_NET,'=',0
	FLG_KI MIKA_NET,'=',0
	FLG_KI TER_NET,'=',0
	FLG_KI RENA_NET,'=',0
	FLG_KI NANA_NET,'=',0
	FLG_KI SIZU_NET,'=',0
	FLG_KI CHIE_NET,'=',0
	DB	"Kenjirou:  H- Huh?"
	DB	NEXT
	DB	"Shiho:  What's wrong?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, nothing. (This is odd -- when I look at her, rather than get sexually excited, I feel at peace.)"
	DB	NEXT
	DB	"Shiho:  Kondo-kun?" 
	DB	NEXT
	DB	"Kenjirou:  Eh? W- What is it?"
	DB	NEXT
	DB	"Shiho:  Are you alright?" 
	DB	NEXT
	DB	"Kenjirou:  What do you mean?"
	DB	NEXT
	DB	"Shiho:  You got so quiet all of the sudden..."
	DB	NEXT
	DB	"Kenjirou:  I'm sorry. I was just thinking of something."
	DB	NEXT
	DB	"Shiho:  Really?"
	DB	NEXT
	DB	"Kenjirou:  Yes. And also..."
	DB	NEXT
	DB	"Shiho:  What?"
	DB	NEXT
	DB	"Kenjirou:  Would you stop calling me Kondo-kun? You can call me Kenjirou."
	DB	NEXT
	DB	"Shiho:  ...Okay." 
	DB	NEXT
	DB	"Kashima-san looks happy for a moment. Or did I just imagine that?"
	DB	NEXT
	DB	"Shiho:  Well, in that case, please call me Shiho. " 
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	T_WAIT,	3
	DB	" Okay. If it's okay with you."
	DB	NEXT
	DB	"Shiho:  It is."
	DB	NEXT
	DB	"Kashima-san... I mean Shiho, smiles at me."
	DB	NEXT
	DB	"Kenjirou:  Okay, well, I'll be going, then."
	DB	NEXT
	DB	"Shiho:  Ah, Kenjirou-kun?"
	DB	NEXT
	DB	"Kenjirou:  Yes?"
	DB	NEXT
	DB	"Shiho:  I'm usually here after class ends. So if you ever have free time, come on by and listen. Okay?"
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Shiho:  ...I guess I'm not good enough to play for other people yet..." 
	DB	NEXT
	DB	"She looks at her feet, suddenly shy, then turns back towards the piano."
	DB	NEXT
	DB	"Not knowing what to say, I leave the music room."
	DB	NEXT
	BAK_INIT 'tb_034a',B_NORM
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
ROUKA:
	BAK_INIT	'tb_034a',B_NORM
	DB	"Well, where should I go?"
	DB	NEXT
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
	MENU_S 2,W,-1
	MENU_SET	J1,"ROOF"
	MENU_SET	J2,"MEN'S ROOM"
	MENU_SET	J3,"ART ROOM"
	MENU_SET	J4,"P.E. STORAGE ROOM"
	MENU_SET	J5,"MOTOKA'S CLASSROOM"
	MENU_END
	DB	EXIT
J1:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"Guess I'll go up to the roof."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"I put my hand on the door to the roof, but it's locked."
	DB	NEXT
	DB	"Darn, I guess I can't go there now."
	DB	NEXT
	DB	"I'll go back."
	DB	NEXT
	GO ROUKA
J2:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"I head for the men's room."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	DB	"The second stall from the back, that's my office."
	DB	NEXT
	FLG_IF YOKU,'<',45,DERU
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	K1,"ENTER OFFICE"
	MENU_SET	K2,"LEAVE"
	MENU_END
	DB	EXIT
K1:
	DB	"I head into my private room."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Well, who shall I do it with today?"
	DB	NEXT
	FLG_KI W,'=',-1
	FLG_IF REN_ATTA,'=',1,SB_1
	FLG_KI W,'DOWN',3
SB_1:
	FLG_IF NAN_ATTA,'=',1,SB_2
	FLG_KI W,'DOWN',4
SB_2:
	FLG_IF SIZ_ATTA,'=',1,SB_3
	FLG_KI W,'DOWN',5
SB_3:
	FLG_IF CHI_ATTA,'=',1,SB_4
	FLG_KI W,'DOWN',6
SB_4:
	MENU_S 2,W,-1
	MENU_SET	L1,"AKEMI KONDO"
	MENU_SET	L2,"TERUMI KINOUCHI"
	MENU_SET	L3,"MIKA MAEDA"
	MENU_SET	L4,"RENA WATANABE"
	MENU_SET	L5,"NANA HIROSE"
	MENU_SET	L6,"SHIZUKA HASEGAWA"
	MENU_SET	L7,"CHIE UTSUMI"
	MENU_SET	L8,"DON'T BOTHER"
	MENU_END
	DB	EXIT
L1:
	FLG_KI HAND,'=',2
	DB	"Mm, it would be nice to do it with Akemi-san..."
	DB	NEXT
	SINARIO 'AK_H.OVL'
L2:
	FLG_KI HAND,'=',2
	DB	"Let's go with Terumi-senpai."
	DB	NEXT
	SINARIO 'TE_H.OVL'
L3:
	FLG_KI HAND,'=',2
	DB	"I wouldn't mind doing that with Mika-sensei."
	DB	NEXT
	SINARIO 'MI_H.OVL'
L4:
	FLG_KI HAND,'=',2
	DB	"I'll never forget the memory of spring vacation..."
	DB	NEXT
	SINARIO 'RE_H.OVL'
L5:
	FLG_KI HAND,'=',2
	DB	"I'd love to rip that uniform off her..."
	DB	NEXT
	SINARIO 'NA_H.OVL'
L6:
	FLG_KI HAND,'=',2
	DB	"She's a beautiful human being. I'd be honored to do it with her."
	DB	NEXT
	SINARIO 'SI_H.OVL'
L7:
	FLG_KI HAND,'=',2
	DB	"Ah, that lovely bathing suit..."
	DB	NEXT
	SINARIO 'CH_H.OVL'
L8:
	DB	"Guess I don't need to do it right now."
	DB	NEXT
	GO ROUKA
TOIRE:
	FLG_KI HAND,'=',0
	BAK_INIT 'tb_017a',B_NORM
	DB	"Feeling better, I stand in front of the sink."
	DB	NEXT
	DB	"Kenjirou:  Ahhh..."
	DB	NEXT
	DB	"That hit the spot."
	DB	NEXT
	DB	"I wash my hands and head out into the hall."
	DB	NEXT
	GO ROUKA
DERU:
K2:
	DB	"I've got no reason to be in here. Guess I'll leave."
	DB	NEXT
	GO ROUKA
J3:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"I head for the art room."
	DB	NEXT
	BAK_INIT 'tb_013a',B_NORM
	T_CG 'tt_12_13a',MIK2,0
	DB	"Mika is here."
	DB	NEXT
	DB	"Mika:  Ah, Kondo-kun, you're here."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	M1,"LOOK AT TITS"
	MENU_SET	M2,"LOOK AT ASS"
	MENU_SET	M3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
M1:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_1
	FLG_KI MIKA_NET,'=',1
WW_1:
	DB	"Her arms are crossed, her breasts riding on top of them. I'd love to slide my cock in between those tits."
	DB	NEXT
	GO BODY_MIKA
M2:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',15
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_2
	FLG_KI MIKA_NET,'=',1
WW_2:
	DB	"My face has touched that holy ass. It's not an experience I'll be forgetting soon."
	DB	NEXT
	GO BODY_MIKA
M3:
	FLG_IF YOKU,'>=',100,HOKEN
	FLG_KI YOKU,'+',6
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WW_3
	FLG_KI MIKA_NET,'=',1
WW_3:
	DB	"Soft, supple -- all around excellent thighs."
	DB	NEXT
	GO BODY_MIKA
BODY_MIKA:
	DB	"Mika:  ...Where were you looking just then? Hurry up and get your sketchbook out."
	DB	NEXT
	DB	"Kenjirou:  ........................................."
	DB	NEXT
	DB	"Mika:  What's wrong?"
	DB	NEXT
	DB	"Kenjirou:  ...I'll see you later, Mika-sensei!"
	DB	NEXT
	DB	"Mika:  Ah, wait, you!" 
	DB	NEXT
	DB	"I run out into the hall."
	DB	NEXT
	GO ROUKA
J4:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"The P.E. storage room. I wonder if anyone's in there?"
	DB	NEXT
	BAK_INIT 'tb_015',B_NORM
	DB	"There's no one here. Guess I'll go back."
	DB	NEXT
	GO ROUKA
J5:
	FLG_IF TEMP01,'>=',2,KYOUSITU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"I wonder if Motoka's here?"
	DB	NEXT
	BAK_INIT 'tb_011a',B_NORM
	T_CG 'tt_10_11a',MOT_A2,0
	DB	"When I enter her room, Motoka runs over to me."
	DB	NEXT
	DB	"Motoka:  Ah, Oniichan." 
	DB	NEXT
	DB	"Kenjirou:  You're still here. I thought you might have gone home."
	DB	NEXT
	DB	"Motoka:  I was just getting ready to go home. What about you?"
	DB	NEXT
	DB	"Kenjirou:  I'm going to hang around a little longer."
	DB	NEXT
	DB	"Motoka:  Really? Why don't you walk home with me, instead?"
	DB	NEXT
	DB	"Kenjirou:  Sorry, I've still got some stuff to do. "
	DB	NEXT
	TATI_ERS	;Tt_10
	T_CG 'tt_21_11a',MOT_B2,0
	DB	"Motoka:  ...Okay. I'll see you at home, then."
	DB	NEXT
	TATI_ERS	;Tt_10
	DB	"Kenjirou:  Ah, Motoka."
	DB	NEXT
	DB	"I called out to her."
	DB	NEXT
	T_CG 'tt_21_11a',MOT_B2,0
	DB	"Motoka:  Yes?"
	DB	NEXT
	DB	"Kenjirou:  ...Sorry. I'll walk you home some other day."
	DB	NEXT
	DB	"Motoka:  It's okay. Don't worry about it. I'll see you later, Oniichan." 
	DB	NEXT
	DB	"She leaves the classroom."
	DB	NEXT
	DB	"You know, that girl doesn't smile as much as she used to. I wonder if anything's wrong?"
	DB	NEXT
	DB	"Guess I'll leave, too."
	DB	NEXT
	GO ROUKA
HOKEN:
	FLG_KI HOK,'=',3
	SINARIO 'ER.OVL'
KYOUSITU:
	BAK_INIT	'tb_034a',B_NORM
	DB	"Guess I'll go back to my own classroom."
	DB	NEXT
	FLG_KI HOK,'=',0
	BAK_INIT 'tb_011b',B_NORM
	DB	"Time to go home."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_018c',B_NORM
	CDPLAY		22
	DB	"When I leave the school, the sun is setting in the sky. It really gets dark early these days."
	DB	NEXT
	DB	"Guess I don't have to go straight home."
	DB	NEXT
	FLG_KI TEMP01,'=',0
	FLG_KI TEMP02,'=',0
	FLG_KI TEMP03,'=',0
	FLG_KI TEMP04,'=',0
	FLG_KI TEMP05,'=',0
	FLG_KI TEMP06,'=',0
	FLG_KI TEMP07,'=',0
	FLG_KI TEMP08,'=',0
	GO SENTAKU
MATI:
	BAK_INIT	'tb_018c',B_NORM
	DB	"Where shall I go?"
	DB	NEXT
SENTAKU:
	FLG_KI W,'=',-1
	FLG_IF TEMP02,'=',0,SC_1
	FLG_KI W,'DOWN',0
SC_1:
	FLG_IF TEMP03,'=',0,SC_2
	FLG_KI W,'DOWN',1
SC_2:
	FLG_IF TEMP04,'=',0,SC_3
	FLG_KI W,'DOWN',2
SC_3:
	FLG_IF TEMP05,'=',0,SC_4
	FLG_KI W,'DOWN',3
SC_4:
	FLG_IF TEMP06,'=',0,SC_5
	FLG_KI W,'DOWN',4
SC_5:
	FLG_IF TEMP07,'=',0,SC_6
	FLG_KI W,'DOWN',5
SC_6:
	MENU_S 2,W,-1
	MENU_SET	N1,"MOVIE THEATRE"
	MENU_SET	N2,"LINGERIE PUB"
	MENU_SET	N3,"PARK"
	MENU_SET	N4,"LOVE HOTEL"
	MENU_SET	N5,"BAR"
	MENU_SET	N6,"HOME"
	MENU_END
	DB	EXIT
N1:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP02,'=',1
	DB	"Guess I'll see a movie."
	DB	NEXT
	BAK_INIT 'tb_019',B_NORM
	DB	"This movie theatre is really run-down."
	DB	NEXT
	DB	"It's on a back street like this, though. It's not surprising that it would be like this."
	DB	NEXT
	DB	"There's no movie I want to see. There's no need to go inside."
	DB	NEXT
	GO MATI
N2:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP03,'=',1
	DB	"Guess I'll go check out the lingerie pub."
	DB	NEXT
	BAK_INIT 'tb_027',B_NORM
	DB	"I yearn to go inside this place and check it out."
	DB	NEXT
	T_CG 'tt_07_27',TET_B2,0
	FLG_KI TET_KAIS,'+',1
	DB	"Tetsuya:  What are you doing here?"
	DB	NEXT
	DB	"Tetsuya appears in front of me."
	DB	NEXT
	DB	"Kenjirou:  Me? What about you?"
	DB	NEXT
	DB	"Tetsuya:  Me? I'm just checking this place out. I mean, it's pretty cool, don't you think?"
	DB	NEXT
	DB	"Kenjirou:  Huh?"
	DB	NEXT
	DB	"Tetsuya:  I mean, any guy would love to go in here, just once." 
	DB	NEXT
	DB	"Tetsuya:  ...Well, I guess so."
	DB	NEXT
	DB	"Tetsuya:  See? Ah, just once would be enough. Then I could die happy." 
	DB	NEXT
	DB	"He stares longingly at the sign in front of the lingerie pub. He's in his own world, now."
	DB	NEXT
	DB	"I'd better not talk to him."
	DB	NEXT
	GO MATI
N3:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP04,'=',1
	DB	"The park at night? Sounds kind of erotic."
	DB	NEXT
	BAK_INIT 'tb_032b',B_NORM
	DB	"There are many couples walking here, holding hands. In the bushes, there are probably even more."
	DB	NEXT
	DB	"Terumi:  What are you doing here?"
	DB	NEXT
	DB	"It's a voice I've heard before. I turn to see Terumi-senpai standing there."
	DB	NEXT
	T_CG 'tt_05_32b',TER2,0
	DB	"Kenjirou:  Ah, Terumi-senpai."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	O1,"LOOK AT TITS"
	MENU_SET	O2,"LOOK AT ASS"
	MENU_SET	O3,"LOOK AT THIGHS"
	MENU_END
	DB	EXIT
O1:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',8
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WS_1
	FLG_KI TER_NET,'=',1
WS_1:
	DB	"Her right arm is blocking my view, but I can tell her tits are great, with just the right amount of volume."
	DB	NEXT
	GO	BODY_TERUMI
O2:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',13
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WS_2
	FLG_KI TER_NET,'=',1
WS_2:
	DB	"Her ass is tight and nice. She's got a great hip-line."
	DB	NEXT
	GO BODY_TERUMI
O3:
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',12
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WS_3
	FLG_KI TER_NET,'=',1
WS_3:
	DB	"Her thighs are soft and supple. They go all the way down."
	DB	NEXT
	GO BODY_TERUMI
BODY_TERUMI:
	DB	"Terumi:  W- What's wrong? You got all quiet..." 
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, nothing. I was just wondering why you were out here so late."
	DB	NEXT
	DB	"Terumi:  I'm just out for a walk."
	DB	NEXT
	DB	"Kenjirou:  Out here? In the dark?"
	DB	NEXT
	DB	"Terumi:  Are you worried about me?" 
	DB	NEXT
	DB	"She looks kind of happy, for a moment."
	DB	NEXT
	DB	"Kenjirou:  I was just worried that someone might attack you..."
	DB	NEXT
	DB	"Terumi:  Y- You what?" 
	DB	NEXT
	DB	"Kenjirou:  I- I'm sorry!"
	DB	NEXT
	DB	"I ran away from there as fast as I could."
	DB	NEXT
	GO MATI
N4:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP05,'=',1
	DB	"The love hotel. I've never been inside."
	DB	NEXT
	BAK_INIT 'tb_025',B_NORM
	DB	"It's got a gaudy sign in front of it."
	DB	NEXT
	DB	"Kenjirou:  I guess there's no reason to be standing around in front of this place."
	DB	NEXT
	GO MATI
N5:
	FLG_IF TEMP01,'>=',3,JITAKU
	FLG_KI TEMP01,'+',1
	FLG_KI TEMP06,'=',1
	DB	"I don't really want to go inside that place."
	DB	NEXT
	DB	"I guess there's no problem with standing in front, though."
	DB	NEXT
	DB	"I head for the bar."
	DB	NEXT
	BAK_INIT 'tb_029',B_NORM
	T_CG 'tt_03_29',HIR2,0
	DB	"Hiroshi:  What are you doing here?"
	DB	NEXT
	DB	"Oh no! It's Hiroshi!"
	DB	NEXT
	DB	"Kenjirou:  Oh, nothing. I was just passing by. I'll see you later."
	DB	NEXT
	DB	"I leave the bar area in a hurry."
	DB	NEXT
	GO MATI
N6:
	DB	"Guess I'll go home now..."
	DB	NEXT
	GO JITAKU
JITAKU:
	BAK_INIT 'tb_005c',B_NORM
	DB	"Ah, it's good to be home."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	DB	"Huh? No one's home."
	DB	NEXT
	DB	"Kenjirou:  Akemi-san?"
	DB	NEXT
	DB	"I call out to Akemi-san, but there's no answer."
	DB	NEXT
	DB	"I wonder where they went? "
	DB	NEXT
	DB	"I head for Akemi-san's room, to see if she's in there."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"I knock on the door to Akemi-san's room."
	;WAV	'SE_NO'
	DB	NEXT
	DB	"Kenjirou:  Akemi-san?"
	DB	NEXT
	DB	"There's no answer. I knock again."
	;WAV	'SE_NO'
	DB	NEXT
	DB	"Kenjirou:  Akemi-san? Are you in there?"
	DB	NEXT
	DB	"I slowly open the door to Akemi-san's room."
	DB	NEXT
	BAK_INIT 'tb_004',B_NORM
	CDPLAY		6
	T_CG 'tt_19_04',AKE_B2,0
	FLG_IF YOKU,'>=',100,HEYA
	FLG_KI YOKU,'+',20
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_IF YOKU,'<',100,WD_1
	FLG_KI AKEM_NET,'=',1
WD_1:
	DB	"Akemi:  Ah, Kenjirou-kun. Welcome home."
	DB	NEXT
	DB	"Akemi-san is here, in her underwear."
	DB	NEXT
	DB	"Kenjirou:  A- Akemi-san!"
	DB	NEXT
	DB	"My face red, I turn around to avoid looking at her."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Kenjirou:  If you're in here, why didn't you answer when I knocked?"
	DB	NEXT
	DB	"Akemi:  I'm sorry, I was lost in thought, and couldn't hear you." 
	DB	NEXT
	DB	"Akemi:  But you don't have to worry about me being here in my underwear. We're mother and son, aren't we?"
	DB	NEXT
	DB	"Kenjirou:  ...I'm going to bed."
	DB	NEXT
	DB	"I headed for my own room."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"My heart still thumping in my chest, I get ready for bed."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_15.OVL'
HEYA:
	FLG_KI YOKU,'/',2
	;SUBSINARIO 'YOKUJOU.OVL'
	F_O B_NORM,C_KURO
	DB	"Kenjirou:  Mmmm?"
	DB	NEXT
	DB	"I slowly open my eyelids."
	DB	NEXT
	BAK_INIT 'tb_001b',B_NORM
	DB	"Where am I?"
	DB	NEXT
	DB	"I look around me. I appear to be in my own room."
	DB	NEXT
	DB	"Huh? What happened?"
	DB	NEXT
	DB	"There's a brown stain on my clothes."
	DB	NEXT
	DB	"Blood? Oh, I had a nosebleed."
	DB	NEXT
	DB	"What happened after that?"
	DB	NEXT
	DB	"I must have lost consciousness."
	DB	NEXT
	DB	"Someone must have brought me up here."
	DB	NEXT
	DB	"But who? Well, guess I'll worry about it later."
	DB	NEXT
	FLG_KI HIDUKE,'+',1
	SINARIO 'MON_15.OVL'
END