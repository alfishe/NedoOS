	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8, S9
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:
	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

CM1:	DW	VV1,	-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	NN1,-1
CM4:	DW	VV4,	NN1,NN2,NN3,NN4,NN5,NN6,-1

VV1:	DB	1,	"AVOID",0
VV2:	DB	2,	"DEFEND YOURSELF",0
VV3:	DB	3,	"TALK",0
VV4:	DB	4,	"THINK",0

NN1:	DB	1,	"NOBUYUKI",0
NN2:	DB	2,	"SELF",0
NN3:	DB	3,	"MOTHER",0
NN4:	DB	4,	"FATHER",0
NN5:	DB	5,	"YAMAGAMI DENKI",0
NN6:	DB	6,	"HIDEMI",0

S1:		DW	VV1, -1,  1, M2		; Les inn VV1=Avoid, enkel meny, nummerering, last inn M2
S2:		DW	VV2, -1,  2, M3		; Les inn VV2=Defend, enkel meny, nummerering, last inn M3
S3:		DW	VV3, NN1, 3, M4, M5, M6, M7, M8, M9 ; Les inn VV3=Talk,Submeny=Nobuyuki, nummerering, last inn M4, M5,M6 , M7, M8 OG M9
S4:		DW	VV4, NN2,  4, M10, M11	; Les inn VV4=Think,Submeny=self, nummerering, last inn M10 og gjenta M11
S5:		DW	VV4, NN3,  5, M12	; Les inn VV4=Think,Submeny=Mother, nummerering, last inn M12
S6:		DW	VV4, NN4,  6, M13	; Les inn VV4=Think,Submeny=Father, nummerering, last inn M13
S7:		DW	VV4, NN1,  7, M14	; Les inn VV4=Think,Submeny=Nobuyuki, nummerering, last inn M14
S8:		DW	VV4, NN5,  8, M15	; Les inn VV4=Think,Submeny=YAMAGAMI DENKI, nummerering, last inn M15
S9:		DW	VV4, NN6,  9, M12B	; Les inn VV4=Think,Submeny=hidemi, nummerering, last inn M12B


M1:
	DB	BGM,4
	B_O B_TATE
	DB	"Aahh..."
	DB	NEXT
	DB	"........Huh?"
	DB	NEXT
	BAK_INIT "AB_38_1"
	B_P1 B_SUDA
	DB	"It's morning already........."
	DB	NEXT
	DB	"I was having a dream..."
	DB	NEXT
	DB	"What was it about?"
	DB	NEXT
	DB	"Hmm..."
	DB	NEXT
	DB	"Somebody I know was in it..."
	DB	NEXT
	DB	"Who could it have been?"
	DB	NEXT
	DB	"I wish I could remember."
	DB	NEXT
	DB	BUF,B_COPY01										;背景コピー
	T_CG "CT10",0,0,10,1
	DB	FLASH,5
	DB	"*WHACK* *WHACK* *WHACK*"
	DB	NEXT
	DB	"Hidemi:  Good morning, Shu-chan!!"
	DB	NEXT
	DB	"%001:  Aaaaah!"
	DB	NEXT
	DB	"As usual, Mom tries to give me a good-morning kiss."
	DB	C_BLD,C_V_ON,3		; Fjern meny 3
	DB	C_BLD,C_V_ON,4		; Fjern meny 4
	DB G_FLG,G_COPYI,110,30		;好感度初期設定
	DB G_FLG,G_COPYI,120,30
	DB G_FLG,G_COPYI,130,30
	DB G_FLG,G_COPYI,140,30
	DB G_FLG,G_COPYI,150,0
	DB G_FLG,G_COPYI,160,20
	DB G_FLG,G_COPYI,170,15
	DB G_FLG,G_COPYI,180,15
	DB	ERASE,E_GFLG,10,100,101,102,103,104,105,106,107,108,109	;巡回クリア
	DW	0000H

M2:		;回避
	DB	"I barely avoid mom as she jumps at me and make my retreat "
	DB	CR
	DB	"into a corner of the room. She plants herself on the bed,"
	DB	CR
	DB	"disappointed."	
	DB	NEXT
	DB	"Hidemi:  Shu-chan, why are you running away from me?"
	DB	NEXT
	DB	"%001:  Will you stop that! Mom, you're over forty and you"
	DB	CR
	DB	"still do this every morning "	
	DB	NEXT
	DB	"Hidemi:  Ah, but all of the ladies in the neighborhood"
	DB	CR
	DB	"always say, 'Oh, Hidemi, you look so young!'"
	DB	NEXT
	DB	"%001:  That's not the point!"
	DB	NEXT
	DB	"%001:  Anyway, I start junior college today, so, will you "
	DB	CR
	DB	"please cut it out?"
	DB	NEXT
	DB	"Hidemi:  That's right. Shu-chan, congratulations. Come here, my"
	DB	CR
	DB	"baby...!!"
	DB	NEXT
	DB	"%001:  Waaah!!"
	DB	NEXT
	B_P1 B_SUDA
	DB	"I finally manage to throw my kissing mother out of the"
	DB	CR
	DB	"room."
	DB	NEXT
	DB	"%001:  God, save me from a crazy mother..."
	DB	C_BLD,C_V_ON,1			; Toggler muligens VV1
	DB	C_BLD,C_V_ON,2			; Toggler muligens VV2
	DB	C_BLD,C_V_OFF,4			; Aktiverer muligens VV4 og nullstiller denne
	DB	C_BLD,C_N_ON,4,6		; 
	DB	C_BLD,C_N_ON,4,3		; 
	DB	C_BLD,C_N_ON,4,4		; 
	DB	C_BLD,C_N_ON,4,1		; 
	DB	C_BLD,C_N_ON,4,5		; 
	DW	0000H

M3:		;防御
;	DB	"かーちゃんは部屋に飛び込んで来た勢いのままジャンプして、寝ている俺にムーンサルトプレスでのしかかって来た！"
	DB	"Mom storms into the room and jumps on me. Then the crazy"
	DB	CR
	DB	"woman puts me in a headlock"
	DB	NEXT
	DB	GATA,5
;	DB	"【%001】：ぐはっ！"
	DB	"%001:  Fwaa!"
	DB	NEXT
;	DB	"【英美】：おはようしゅうちゃん、ん～・・・"
	DB	"Hidemi:  Good morning Shu-chan! Oooh!"
	DB	NEXT
	DB	FLASH,1
;	DB	"ちゅっ☆"
	DB	"Mmmwa!"
	DB	NEXT
;	DB	"【%001】：かーちゃん！４０過ぎにもなってやめてくれよ毎朝毎朝！"
	DB	"%001:  Will you stop that! Mom, you're over forty and you"
	DB	CR
	DB	"still do this every morning "	
	DB	NEXT
;	DB	"【英美】：あら、英美町内会じゃ「お若いわね」って言われてるのよ？"
	DB	"Hidemi:  Ah, but all of the ladies in the neighborhood"
	DB	CR
	DB	"always say, 'Oh, Hidemi, you look so young!'"	
	DB	NEXT
;	DB	"【%001】：そ～いう問題じゃねえって。"
	DB	"%001:  That's not the point!"
	DB	NEXT
;	DB	"【%001】：・・・とにかく俺今日から高校生なんだからよ、いいかげんそ～いうのやめてくれよな。"
	DB	"%001:  Anyway, I start junior college. So, will you please"
	DB	CR
	DB	"cut it out."
	DB	NEXT
;	DB	"【英美】：そうそう、しゅうちゃん高校入学おめでとう。ん～・・・"
	DB	"Hidemi:  That's right. Shu-chan, congratulations. Come"
	DB	CR
	DB	"here, my baby!!"
	DB	NEXT
;	DB	"【%001】：だああああ！"
	DB	"%001:  Whaaah!!"
	DB	NEXT
	B_P1 B_SUDA
;	DB	"俺はキスを迫るかーちゃんを部屋から追い出した。"
	DB	"I finally manage to throw my kissing mother out of the"
	DB	CR
	DB	"room."	
	DB	NEXT
;	DB	"【%001】：・・・っったく、いいかげん子離れしてくれよ・・・。"
	DB	"%001:  God, save me from a crazy mother..."
	DB	C_BLD,C_V_ON,1		;回避　消す
	DB	C_BLD,C_V_ON,2		;防御　消す
	DB	C_BLD,C_V_OFF,4		;考える　出し
	DB	C_BLD,C_N_ON,4,3		;考える　母親　消し
	DB	C_BLD,C_N_ON,4,4		;考える　父親　消し
	DB	C_BLD,C_N_ON,4,1		;考える　伸幸　消し
	DB	C_BLD,C_N_ON,4,5		;考える　山神電器　消し
	DB	C_BLD,C_N_ON,4,6		;考える　母親　消し
	DW	0000H

M4:		;話す　伸幸
	DB	"%001:  Why the hell do you always come in the window?"
	DB	NEXT
	DB	"Nobuyuki:  Call it a hobby."
	DB	NEXT
	DB	"%001:  ......................................"
	DB	NEXT
	DB	"I get a cold feeling from my father's laugh."
	DB	NEXT
	DB	"Did he do something to me while I was asleep?"
	DB	FLG,F_COPYI,3,1
	DW	0000H

M5:		;話す　伸幸
	DB	"Nobuyuki:  %001, I got some good footage today. Take a look."
	DB	NEXT
	DB	"Dad pushes the video camera's viewfinder up against my"
	DB	CR
	DB	"eye."
	DB	NEXT
	DB	"%001:  Cut it out!"
		DB	FLG,F_COPYI,3,2
	DW	0000H

M6:		;話す　伸幸
	DB	"Nobuyuki:  So, you start junior college today."
	DB	NEXT
	DB	"Dad laughs, but he seems a little sad."
	DB	NEXT
	DB	"Nobuyuki:  My son... Oh, %001..."
	DB	NEXT
	DB	"%001:  Dad..."
	DB	FLG,F_COPYI,3,3
	DW	0000H

M7:		;話す　伸幸
	DB	"Nobuyuki:  %001. Here's a little something to commemorate"
	DB	CR
	DB	"your getting into the new school."
	DB	NEXT
	DB	"Dad pulls out a duffle bag from somewhere containing a bunch"
	DB	CR
	DB	"of video tapes."
	DB	NEXT
	DB	"Nobuyuki:  Your father's memories of an erotic youth!"
	DB	CR
	DB	"Female dorm, shower room, park. And there's more!"
	DB	NEXT
	DB	"Nobuyuki:  My advice to you is, learn about women,"
	DB	CR
	DB	"and you won't screw up your first time with a woman!"
	DB	NEXT
	DB	"%001:  ....................................."
	DB	NEXT
	DB	"Nobuyuki:  %001, speechless, huh? I'm glad you're so"
	DB	CR
	DB	"happy."
	DB	NEXT
	DB	"%001:  I'm speechless with embarrassment!"
	DB	FLG,F_COPYI,3,4
	DW	0000H

M8:		;話す　伸幸
	DB	"Nobuyuki:  %001, a normal man would be thrilled to get"
	DB	CR
	DB	"this sort of thing."
	DB	NEXT
	DB	"%001:  I don't think so!"
	DB	FLG,F_COPYI,3,5
	DW	0000H

M9:		;話す　伸幸
	DB	"Nobuyuki:  By the way, %001, aren't you late for school?"
	DB	NEXT
	DB	"%001:  Huh?"
	DB	NEXT
	DB	"With dread, I look at the clock... 8:20."
	DB	NEXT
	DB	"%001:  Oh, shit!"
	DB	NEXT
	DB	"I grab my bag and run out the room."
	DB	NEXT
	BAK_INIT "AB_01_1"
	DB	BUF,B_COPY01										;背景コピー
	T_CG "CT10",0,0,0,1
	DB	"Hidemi:  Shu-chan, here's your good bye kiss.  Mmm...."
	DB	NEXT
	DB	"%001:  No thanks!"
	DB	NEXT
	DB	"Hidemi:  Oh, Shu-chan. Don't be shy!"
	DB	NEXT
	DB	"I dodge mom's good bye kiss attack and fly out the door."
	DB	NEXT
	E_CG B_YOKO,"T_01"
	DB	NEXT
	DB SINARIO,"CS102.OVL",0	; Last  inn neste scenario
	DW	0000H

M10:		;考える　自分
	DB	"I'm %001 Yamagami, nineteen years old.  Today, I start"
	DB	CR
	DB	"Kotobuki Junior College."
	DB	NEXT
	DB	"It's a three-year college. Japanese students like me spend"
	DB	CR
	DB	"the time preparing to go on to a full four-year college."
	DB	NEXT
	DB	"I throw off my pajamas and put on my brand-new school"
	DB	CR
	DB	"uniform."
	DB	NEXT
	DB	"It's a great feeling to put on a new uniform."
	DB C_BLD,C_N_OFF,4,3		;考える　母親　出し
	DB	FLG,F_COPYI,4,1
	DW	0000H

M11:		;考える　自分
;	DB	"・・・今日から高校生か・・・"
	DB	"Today I start junior college. I wonder what it'll be like?"
	DW	0000H

M12:	
	DB	"My mom, Hidemi Yamagami. Forty-one this year."
	DB	NEXT
	DB	"She looks young and acts even younger. Sometimes I don't"
	DB	CR
	DB	"know what to do about her."
	DB	NEXT
	DB	"I especially wish she'd stop trying to kiss me all the"
	DB	CR
	DB	"the time."
	DB	NEXT
	DB	"If Dad would only be more forceful with her..."
	DB C_BLD,C_N_OFF,4,4		;考える　父親　出し
	DB C_BLD,C_N_ON,4,3		;考える　母親　
	DB C_BLD,C_N_OFF,4,6		;考える　母親　
	DW	0000H

M12B:		;考える　英美
;	DB	"俺のかーちゃん、山神　英美。当年とって４１才。"
	DB	"She's my Mom, Hidemi Yamagami. Forty-one this year."
	DB	NEXT
;	DB	"若作りなのをいい事に子供みたいなことばっかりする困った母親だ。"
	DB	"She looks young and acts even younger. Sometimes I"
	DB	CR
	DB	"don't know what to do about her."
	DB	NEXT
;	DB	"あの親父にしてこのかーちゃん・・・真っ当な人間に育った俺って実はすごいんじゃ・・・"
	DB	"It's amazing that with a parents like that I came out such"
	DB	CR
	DB	"a straight person."
	DW	0000H


M13:		;考える　父親
	DB	"He's my Dad, Nobuyuki Yamagami, the pillar of support for "
	DB	CR
	DB	"our family. I guess that you could say he's president of"
	DB	CR
	DB	"Yamagami Electric. But it's such a small store."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT09",0,0,12,2		; Laster inn bilde
	DB	"Nobuyuki:  Hi, %001."
	DB	NEXT
	DB	"%001:  Wah!!"
	DB	NEXT
	DB	"Suddenly dad crawls in the window like an idiot. My room is on"
	DB	CR
	DB	"the second floor."
	DB	NEXT
	DB	"He's an electronics store manager by profession. But he's"
	DB	CR
	DB	"actually a perverted peeping tom."
	DB	NEXT
	DB	"Nobuyuki:  Come on, %001. Don't look at your father that"
	DB	CR
	DB	"way."
	DB	NEXT
	DB	"Dad gives me a sad look."
	DB	C_BLD,C_V_OFF,3		; Toggler VV4
	DB 	C_BLD,C_N_ON,4,4	;
	DB 	C_BLD,C_N_OFF,4,1	;
	DB 	C_BLD,C_N_OFF,4,5	;
	DW	0000H

M14:		;考える　伸幸
;	DB	"親父の趣味は覗き。",CR,"自作のスターライトスコープと赤外線ビデオカメラを手に、夜な夜な公園のアベックを覗きに行く。"
	DB	"Dad's hobby is peeping. Every night, he takes his home-"
	DB	CR
	DB	"made starlight scope and infra-red video camera and"
	DB	CR
	DB	"films couples having sex in the park."
	DB	NEXT
;	DB	"我が親父ながら情けない・・・人間、こーはなりたくないな。"
	DB	"My father is so pitiful. I certainly don't want to end"
	DB	CR
	DB	"up like him."
	DB	NEXT
;	DB	"【伸幸】：そ、そこまでいうか・・・"
	DB	"Nobuyuki:  You injure me, my son."
	DW	0000H

M15:		;考える　山神電器
;	DB	"俺の親父の経営する、街の小さな電器屋さんだ。よーするに、この家の一階が電器屋になってるってわけだ。"
	DB	"My father runs this little electronics store. In other"
	DB	CR
	DB	"words, the first floor of our house is the shop. A lot"
	DB	CR
	DB	"of families in Japan run businesses that way."
	DB	NEXT
;	DB	"経営状態は良好・・・一家三人食うに困らない位の収入はある。"
	DB	"Sales are not bad. At least we make enough to live on."
	DW	0000H


end
