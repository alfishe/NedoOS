;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６１２
;		夕暮れのシ者

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'美緒',0
NN1:	DB	1,	"MIO",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4		;見る　美緒
S2:		DW	VV2, NN1,  2, M5, M6, M7, M8, M9, M10, M11		;話す　美緒


;イニシャルメッセージ
M1:
	DB	BGM,9
	E_CG B_FADE,'AE_027'
;	DB	'思う存分貝を取った後、俺は美緒ちゃんと並んで夕日の海岸に座った。'
	DB	"Once we had collected all the shellfish we wanted, Mio"
	DB	CR
	DB	"and I sat together on the beach, watching the sunset."
	DW	0000H

M2:		;見る　美緒
;	DB	'美緒ちゃんはそっと目をつぶって名前も知らない貝殻を耳に当ててる。'
	DB	"Mio closed her eyes and held the unknown shell to her ear."
	DB	NEXT
;	DB	'【%001】：何か聞こえる？'
	DB	"%001:  Can you hear anything?"
	DB	NEXT
;	DB	'【美緒】：波の音・・・かな。'
	DB	"Mio:  The sound of the waves..."
	DB	NEXT
;	DB	'【%001】：それなら俺にも聞こえるぞ。'
	DB	"%001:  Well duh, I can hear them too."
	DB	NEXT
;	DB	'【美緒】：ううん、ここじゃない海の波の音が聞こえるの。'
	DB	"Mio:  Yes, but I can hear the sound of some other ocean."
	DB	NEXT
;	DB	'【%001】：ここじゃない海？'
	DB	"%001:  Some other ocean?"
	DB	NEXT
;	DB	'【美緒】：うん・・・。'
	DB	"Mio:  Yes."
	DB	NEXT
;	DB	'【%001】：ふ～ん・・・'
	DB	"%001:  Wow."
	DB	FLG,F_COPYI,1,1
	DW	0000H


M3:		;見る　美緒
;	DB	'【美緒】：こうしてると、何かを思い出しそうになるの。'
	DB	"Mio:  This really reminds me of something..."
	DB	NEXT
;	DB	'【美緒】：とても懐かしいような、少し怖いような、不思議な気持ち・・・'
	DB	"Mio:  I don't quite what it is. A memory... A strange,"
	DB	CR
	DB	"scary memory..."
	DW	0000H

M4:		;見る　美緒
;	DB	'夕日のせいかな・・・美緒ちゃんの顔が赤い。'
	DB	"Mio's face is red...it must be the sunset."
	EF_SET 101
	DW	0000H

M5:		;話す　美緒
;	DB	'【美緒】：貝、いっぱい取ったね。'
	DB	"Mio:  We really got a lot of clams today."
	DB	NEXT
;	DB	'【%001】：あぁ。こんだけあれば相当食いでがあるだろ。'
	DB	"%001:  Yeah. Should be enough for a decent meal."
	DB	NEXT
;	DB	'【美緒】：宿の人に頼んで、お台所貸してもらわなくちゃね。'
	DB	"Mio:  I'll ask the people at the lodge to see if we can"
	DB	CR
	DB	"use the kitchen."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M6:		;話す　美緒
;	DB	'【美緒】：%001先輩・・・'
	DB	"Mio:  %001..."
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Mm?"
	DB	NEXT
;	DB	'【美緒】：慎治君を助けた時のこと、覚えてる？'
	DB	"Mio:  Do you remember the time you saved Shinji?"
	DB	NEXT
;	DB	'【%001】：うろ覚えだけどな。慎治君に会うまで完全に忘れてたが。'
	DB	"%001:  Vaguely. Until I met Shinji again, I had pretty"
	DB	CR
	DB	"much forgotten."
	DB	NEXT
;	DB	'【美緒】：先輩は知らないだろうけど、あたしもあの場にいたんだ・・'
	DB	"Mio:  You probably don't remember this, but I was there"
	DB	CR
	DB	"too..."
	DB	NEXT
;	DB	'【%001】：へぇ・・・世の中って、狭いもんだな。'
	DB	"%001:  Really? It's a small world.."
	DB	FLG,F_COPYI,2,2
	DW	0000H


M7:		;話す　美緒
	E_CG B_FADE,'AE_028'
;	DB	'【美緒】：慎治君がはねられそうになった時、あたしは体がすくんで',CR,'一歩も動けなかった。'
	DB	"Mio:  The truck was about to hit Shinji... I wanted to"
	DB	CR
	DB	"save him,  but my body felt paralyzed, and I couldn't"
	DB	CR
	DB	"move at all."
	DB	NEXT
;	DB	'【美緒】：だけど先輩は・・・'
	DB	"Mio:  But you, %001..."
	DB	NEXT
;	DB	'【%001】：ま、あん時は間に合うと思ったからな。'
	DB	"%001:  Well, it was just one of those things. I was sure"
	DB	CR
	DB	"I could reach him in time."
	DB	NEXT
;	DB	'【美緒】：もしも間に合わなかったら、って考えなかったの？'
	DB	"Mio:  Didn't it occur to you that you might not?"
	DB	NEXT
;	DB	'【%001】：・・・考えてられるほど余裕はなかったよーな気がする。'
	DB	"%001:  There wasn't any time to think about it."
	DB	NEXT
;	DB	'【%001】：取り合えず助けてから考えようとか思ってたな。',CR,'ハハ、ほとんど動物だな俺って。'
	DB	"%001:  I probably told myself I'd think about it later."
	DB	CR
	DB	"I guess I act mostly on instinct, ha ha."
	DB	NEXT
;	DB	'美緒ちゃんは笑わなかった。'
	DB	"Mio didn't laugh."
	DB	FLG,F_COPYI,2,3
	DW	0000H


M8:		;話す　美緒
;	DB	'【%001】：ま、俺の運動能力なんぞ、あーゆー時くらいしか',CR,'役に立たんからな。'
	DB	"%001:  Well, I guess all my athletic skills come in"
	DB	CR
	DB	"handy sometimes."
	DB	NEXT
;	DB	'【美緒】：先輩・・・'
	DB	"Mio:  %001..."
	DB	FLG,F_COPYI,2,4
	DW	0000H


M9:		;話す　美緒
;	DB	'【美緒】：先輩！テニス・・・スポーツは、楽しくないの？'
	DB	"Mio:  %001! Don't you like tennis, I mean sports?"
	DB	NEXT
;	DB	'【%001】：・・・そうだな。あんましいい思い出もねーし。'
	DB	"%001:  I do. But I have some bad memories about"
	DB	CR
	DB	"playing sports."
	DB	NEXT
;	DB	'【美緒】：誰にも負けないのに？勝ってもうれしくないの？'
	DB	"Mio:  But doesn't winning make you happy?"
	DB	NEXT
	DB	"%001:  ............................."
	DB	NEXT
;	DB	'【美緒】：先輩・・・前、お花見の前の日に言ってたこと・・・',CR,'本当の事なんでしょ？'
	DB	"Mio:  %001, what you said the day before we went flower-"
	DB	CR
	DB	"viewing back in April, was that true?"
	DB	NEXT
;	DB	'【%001】：・・・まーな。'
	DB	"%001:  Yes."
	DB	NEXT
;	DB	'【美緒】：相手に嫌われるかも知れないから？人にうらやましがられるから？！'
	DB	"Mio:  You don't want to push yourself to your limit..."
	DB	CR
	DB	"because others might hate you? Because they might envy you?"
	DB	NEXT
;	DB	'【美緒】：目立つと敵が出来るから！？'
	DB	"Mio:  Because you can make enemies if you stand out?"
	DB	NEXT
;	DB	'【%001】：・・・どうしても答えなきゃダメか？'
	DB	"%001:  Do I have to answer that?"
	DB	NEXT
;	DB	'【美緒】：！・・・ごめんなさい・・・。'
	DB	"Mio:  Sorry."
	DB	FLG,F_COPYI,2,5
	DW	0000H

M10:		;話す　美緒
;	DB	'【%001】：・・・まー、下手に目立つとロクなことにならねーから。'
	DB	"%001:  ...Well, if you suck at something, at least you'll"
	DB	CR
	DB	"still have friends. At least you don't stand out."
	DB	NEXT
;	DB	'【美緒】：だけど、慎治君を助けた時、先輩は目立ってた。'
	DB	"Mio:  But, that time you saved Shinji, you stood out."
	DB	NEXT
;	DB	'【%001】：！'
	DB	"%001:  !!"
	DB	NEXT
;	DB	'【美緒】：だから、あの日、桜の下で、あたしは先輩に話し掛けたの。一度だけしか見た事のない%001先輩に。'
	DB	"Mio:  That's why I came and talked to you under the"
	DB	CR
	DB	"cherry trees that day. You, who I had seen only once."
	DB	NEXT
;	DB	'【美緒】：あの雨の日に見た%001先輩の姿が、忘れられなかったから・・・。'
	DB	"Mio:  Because I could never forget the way you looked"
	DB	CR
	DB	"on that rainy day, as you raced in between the cars to get ",CR,"to Shinji in time."
	DB	FLG,F_COPYI,1,2
	DB	FLG,F_COPYI,2,6
	DW	0000H

M11:		;話す　美緒
;	DB	'【%001】：美緒ちゃん・・・'
	DB	"%001:  Mio..."
	DB	NEXT
;	DB	'【美緒】：・・・'
	DB	"Mio:  ......................"
	EF_SET 102
	DW	0000H

M_EXIT:
	DB FLG,F_COPYI,255,1
	DB FLG,F_MAND,3,255,101,102
	DB FLG,F_EXIT,255
	DB	NEXT
	DB SINARIO,'CS613.OVL',0
	DW	0000H


end
