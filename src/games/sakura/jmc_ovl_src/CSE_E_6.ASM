;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｅ＿Ｅ＿６
;		瑠璃Ｈ２
	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:
	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'キス',0
VV3:	DB	3,	'KISS',0
;VV4:	DB	4,	'愛撫する',0
VV4:	DB	4,	'CARESS',0

;NN1:	DB	1,	'瑠璃',0
NN1:	DB	1,	'RURI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　瑠璃
S2:		DW	VV2, NN1,  2, M3, M4, M5, M6, M7		;話す　瑠璃
S3:		DW	VV3, -1,  3, M8, M9, M10, M11		;キス
S4:		DW	VV4, -1,  4, M12, M13, M14, M15		;愛撫する


;イニシャルメッセージ
M1:
	DB	BGM,13
	E_CG B_FADE,'AE_185'
;	DB	'白水さんの裸身が、月明かりに照らされてる。'
	DB	"And then Ruri was there, her naked body shining in the"
	DB	CR
	DB	"moonlight."
	DB	NEXT
;	DB	'【%001】：・・・とてもきれいだ・・・'
	DB	"%001:  You're beautiful."
	DB	NEXT
;	DB	'【瑠璃】：・・・そう？・・・わからないわ。'
	DB	"Ruri:  .....I am? I don't know what beautiful is."
	DB	NEXT
;	DB	'【%001】：俺が思ってたよりも、ずっと・・・'
	DB	"%001:  You're more beautiful than I dreamed..."
	DB	NEXT
;	DB	'【%001】：・・・あっ、いつもそんな事考えてたわけじゃなくて、その・・・たまにだけど・・・'
	DB	"%001:  .....I mean...I didn't sit around thinking about you"
	DB	CR
	DB	"naked or anything..."
	DB	NEXT
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ................."
	DB C_BLD,C_V_ON,3
	DB C_BLD,C_V_ON,4
	DW	0000H

M2:		;見る　瑠璃
;	DB	'俺の前に全てをさらけ出している・・・'
	DB	"She's lying in front of me, offering herself to me."
	DB	NEXT
;	DB	'【%001】：・・・きれいだ・・・'
	DB	"She's beautiful..."
	DW	0000H

M3:		;話す　瑠璃
;	DB	'【%001】：まるで夢の中にいるみたいだよ・・・'
	DB	"%001:  I...I feel like I'm dreaming or something..."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・私も・・・あなたの夢ばかり見てた・・・'
	DB	"Ruri:  ......Me, too. I dreamed a lot about you, actually,"
	DB	CR
	DB	"for a long time.."
	DB	NEXT
;	DB	'【%001】：俺の夢？'
	DB	"%001:  You did?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・あなたが他の女の子と歩いてる夢・・・'
	DB	"Ruri:  Yes. I dreamed you were walking with another girl..."
	DB	NEXT
;	DB	'【%001】：・・・現実の俺はここにいるよ。'
	DB	"%001:  ...But I'm here, with you."
	DB	NEXT
;	DB	'【瑠璃】：・・・そうかしら。'
	DB	"Ruri:  Are you?"
	DB	FLG,F_COPYI,2,1
	DW	0000H

M4:		;話す　瑠璃
;	DB	'【%001】：・・・そうかしらって、何がさ？'
	DB	"%001:  .....What do you mean by that?"
	DB	NEXT
;	DB	'【瑠璃】：これは全部夢かもしれないわ。私か・・・あなたの。'
	DB	"Ruri:  This could really all be a dream. Mine or...yours."
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  ...................."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M5:		;話す　瑠璃
;	DB	'【瑠璃】：それとも、別の誰かの夢かもしれない。'
	DB	"Ruri:  Maybe it's someone else's dream."
	DB	NEXT
;	DB	'【%001】：・・・白水さん・・・？'
	DB	"%001:  ....Ruri?"
	DB	NEXT
;	DB	'【瑠璃】：私は本当は存在しないかもしれない。',CR,'あるいは、本当はこの世界には、私しかいないのかもしれない。'
	DB	"Ruri:  Maybe I don't even really exist. Or maybe..."
	DB	NEXT
	DB	"Ruri:  Maybe I'm the only one in the world, and everyone else"
	DB	CR
	DB	"is part of my dream."
	DB	NEXT
;	DB	'【瑠璃】：怖いの・・・幸せすぎて。'
	DB	"Ruri:  I'm afraid, %001... I'm not supposed to be this"
	DB	CR
	DB	"happy."
	DB	NEXT
;	DB	'【瑠璃】：今にも誰かがそのドアを開けて、「これは夢だ」って叫ぶんじゃないかって・・・'
	DB	"Ruri:  I'm afraid that someone is going to turn on the "
	DB	CR
	DB	"lights and say, 'Wake up, Ruri. Your dream is over.'"
	DB	NEXT
;	DB	'【%001】：俺はここにいるよ・・・白水さん。'
	DB	"%001:  I'm here, Ruri. I'm really here."
	DB	NEXT
;	DB	'俺はそっと白水さんの手を取った。そのひんやりとした肌が、夢じゃないことを教えてくれる。'
	DB	"I took Ruri's hand. It was physically there, in my hand. It"
	DB	CR
	DB	"wasn't a dream."
	DB	NEXT
;	DB	'その俺の手を自分の頬に押し当てて、白水さんはそっと目を閉じた。'
	DB	"I touched her face, to let her know it. She closed her eyes"
	DB	CR
	DB	"at my touch."
	DB	NEXT
;	DB	'【瑠璃】：・・・あったかい・・・'
	DB	"Ruri:  ......It's warm."
	DB	FLG,F_COPYI,2,3
	DW	0000H

M6:		;話す　瑠璃
;	DB	'じっと俺を見つめる白水さん・・・いや、瑠璃の瞳。'
	DB	"Ruri:  .....%001, thank you for not giving up on me."
	DB	NEXT
	DB	"She looked at me with her deep brown eyes."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・・・・・・・・・・瑠璃。'
	DB	"%001:  .......Ruri."
	DB	NEXT
;	DB	'【瑠璃】：%001君・・・'
	DB	"Ruri:  %001....."
	DB	NEXT
;	DB	'【瑠璃】：・・・私、寒い。'
	DB	"Ruri:  ......I'm cold."
	DB	NEXT
;	DB	'【%001】：おっと・・・それじゃ、今すぐあっためてあげるよ。'
	DB	"%001:  .....Come here. I'll warm you."
	DB	NEXT
;	DB	'俺は瑠璃をそっと胸の中に抱き締めた。'
	DB	"I took her into my arms again, holding her close to me."
	DB	FLG,F_COPYI,2,4
	DB C_BLD,C_V_OFF,3
	DB C_BLD,C_V_OFF,4
	DW	0000H

M7:		;話す　瑠璃
;	DB	'【%001】：瑠璃・・・優しくするから・・・'
	DB	"Ruri:  I'm so happy to be here with you, I can't stand it."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・うん・・・・・・'
	DB	"%001:  .....Oh, Ruri."
	DW	0000H

M8:		;キス
;	DB	'【%001】：るり・・・'
	DB	"%001:  Ruri..."
	DB	NEXT
;	DB	'瑠璃と唇同士を触れさせる。'
	DB	"We kissed."
	DB	NEXT
;	DB	'【瑠璃】：・・・はぁ・・・'
	DB	"Ruri:  Oh, I've wanted to do that for so long..."
	DB	NEXT
;	DB	'はにかむように微笑む瑠璃。俺はもっともっと瑠璃が欲しくなる。'
	DB	"She smiled. I wanted her more and more."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M9:		;キス
;	DB	'瑠璃の白い肩に口づける。'
	DB	"I kissed her again."
	DB	NEXT
;	DB	'俺の唇の触れた場所が、微かに桜色に染まる。'
	DB	"The place where my lips had touched hers was sakura-colored."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M10:		;キス
;	DB	'今度は、もっとディープなキス。'
	DB	"I kissed her a third time, pushing my tongue into her mouth."
	DB	NEXT
;	DB	'瑠璃は突然の侵入者に目を見開いたが、やがてそっと目を閉じ、俺の舌を求めてきた。'
	DB	"Her eyes opened at the unexpected intruder, but then closed"
	DB	CR
	DB	"slowly, as my tongue probed her mouth."
	DB	FLG,F_COPYI,3,3
	DW	0000H

M11:		;キス
;	DB	'【瑠璃】：%001君・・・もう一度・・・'
	DB	"Ruri:  %001, do it again."
	DB	NEXT
;	DB	'目を閉じてキスをねだる瑠璃。'
	DB	"She closed her eyes and waited for me."
	DB	NEXT
;	DB	'俺は瑠璃の唇に、まぶたに、頬に、首筋に、キスの雨を降らせた。'
	DB	"I rained kisses on her lips, her eyelids, her cheeks, and "
	DB	CR
	DB	"her neck."
	DW	0000H


M12:		;愛撫する
;	DB	'白磁の様に滑らかな瑠璃の肌に指を這わす。'
	DB	"I run my fingers along her smooth body."
	DB	NEXT
;	DB	'【瑠璃】：・・・くすぐったい・・・'
	DB	"Ruri:  That tickles..."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M13:		;愛撫する
;	DB	'冷え切った瑠璃の全身を、手のひらでさする。'
	DB	"I rub her with my open hand, lightly."
	DB	NEXT
;	DB	'【瑠璃】：・・・んっ・・・'
	DB	"Ruri:  Mmmm..."
	DB	FLG,F_COPYI,4,2
	DW	0000H

M14:		;愛撫する
;	DB	'瑠璃のふくよかな胸を包むように手を重ねる。'
	DB	"I rest my hands on her breasts."
	DB	NEXT
;	DB	'【%001】：瑠璃って、結構着痩せするんだな・・・'
	DB	"%001:  You've got a really beautiful body, Ruri..."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・'
	DB	"Ruri:  ..........."
	DB	NEXT
;	DB	'ぎゅっ'
	DB	"*DIG*"
	DB	NEXT
;	DB	'【%001】：あた！'
	DB	"%001:  Ouch!"
	DB	NEXT
;	DB	'瑠璃が俺の手の甲をつねる。'
	DB	"Suddenly Ruri dug her fingernails into my hand."
	DB	NEXT
;	DB	'【瑠璃】：これは私以外の裸を見た罰・・・'
	DB	"Ruri:  That was your punishment for seeing someone naked"
	DB	CR
	DB	"besides me."
	DB	NEXT
;	DB	'【%001】：もうしません！もうしません！'
	DB	"%001:  I won't do anything like that again, I promise!"
	DB	NEXT
;	DB	'【瑠璃】：見るなら私だけを見てね・・・'
	DB	"Ruri:  If you're going to look at someone, look at me, "
	DB	CR
	DB	"alright?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・見るだけ？'
	DB	"%001:  .....Just look?"
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・・・・触ってもいいわ・・・。'
	DB	"Ruri:  .........You can touch, too..."
	DB	NEXT
;	DB	'【%001】：じゃあ・・・'
	DB	"%001:  Okay, then..."
	DB	FLG,F_COPYI,4,3
	DW	0000H

M15:		;愛撫する
;	DB	'俺は瑠璃の股の付け根に手を忍ばせる。そこは徐々に湿り気を帯びていた。'
	DB	"My hand moves down to Ruri's slit. I touched her, and"
	DB	CR
	DB	"found her wet center."
	DB	NEXT
;	DB	'【瑠璃】：・・・あっ・・・・・・なに？・・・体が変・・・'
	DB	"Ruri:  %001..........Ahhn...."
	DB	NEXT
;	DB	'冷え切っていた瑠璃の体は熱く上気していた。'
	DB	"Ruri's body, cold from the air, began to get warm."
	DB	NEXT
;	DB	'【%001】：大丈夫。恐くないよ・・・'
	DB	"%001:  It's alright, Ruri. I'll be gentle..."
	DB	NEXT
;	DB	'【瑠璃】：%001君・・・・・・・・・'
	DB	"Ruri:  %001, I have to tell you......"
	DB	NEXT
	DB	"%001:  Tell me what?"
	DB	NEXT
	DB	"Ruri:  I'm not.... I mean, I've done this before."
	DB	NEXT
	DB	"%001:  ........................."
	DB	NEXT
	DB	"Ruri:  ......................"
	DB	NEXT
	DB	"%001:  .......I see."
	DB	NEXT
	DB	"Ruri:  There was a guy...at a school I went to last year,"
	DB	CR
	DB	"and..."
	DB	NEXT
	DB	"%001:  ........................................."
	DB	NEXT
	DB	"It wasn't easy for me to hear, of course. I think all men"
	DB	CR
	DB	"are the same."
	DB	NEXT
	DB	"I thought of Kyoko-sensei, and everything that she had"
	DB	CR
	DB	"taught me..."
	DB	NEXT
	DB	"......But her special lessons never prepared me for this."
	DB	NEXT
	DB	"Ruri was watching me intently. Her eyes began to fill"
	DB	CR
	DB	"with tears."
	DB	NEXT
	DB	"Ruri:  Are you.....mad?"
	DB	NEXT
	DB	"%001:  ............................................"
	DB	NEXT
	DB	"Ruri:  I'm not......dirty, am I?"
	DB	NEXT
	DB	"I looked at her lying next to me, then. Her small body..."
	DB	CR
	DB	"so frail...."
	DB	NEXT
	DB	"Ruri was willing to give herself to me now. Because she"
	DB	CR
	DB	"loved me."
	DB	NEXT
	DB	"Suddenly, it was alright."
	DB	NEXT
	DB	"%001:  ............I'm not mad. And there isn't a part of"
	DB	CR
	DB	"you that's dirty."
	DB	NEXT
;	DB	'【瑠璃】：・・・・・・・・・慣れてる・・・'
	DB	"Ruri:  Thank you."
	DB	NEXT
	DB	"Ruri:  Have you.....before?"
	DB	NEXT
	DB	"I nodded."
	DB	NEXT
	DB	"Ruri:  ....Oh."
	DB	NEXT
	DB	SINARIO,'CSE_E_7.OVL',0
	DW	0000H


end
