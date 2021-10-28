;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　４０２
;		昼休み

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4
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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0

;NN1:	DB	1,	'誠',0
NN1:	DB	1,	"MAKOTO",0
;NN2:	DB	2,	'瑠璃',0
NN2:	DB	2,	"RURI",0
;NN3:	DB	3,	'まわり',0
NN3:	DB	3,	"AROUND",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　誠
S2:		DW	VV1, NN2,  2, M4		;見る　瑠璃
S3:		DW	VV1, NN3,  3, M5, M6, M7		;見る　まわり
S4:		DW	VV2, NN1,  4, M8, M9		;話す　誠


;イニシャルメッセージ
M1:
	DB	BGM,31
	BAK_INIT 'AB_36_3'
	E_CG B_SUDA,'AE_012'
;	DB	'【鈴子】：・・・で、あれがウワサの転校生？'
	DB	"Reiko:  Is that the new woman I heard about?"
	DB	NEXT
;	DB	'白水さんを取り巻いていたバリケードは、完全に撤去されていた。'
	DB	"The wall of people surrounding Ruri has finally dissapated."
	DB	NEXT
;	DB	'・・・より正確には、自壊していた。'
	DB	".....Although maybe self-destructed is a better term."
	DB	NEXT
;	DB	'【%001】：彼女、ほとんどしゃべらねーんだ。'
	DB	"%001:  She hardly talks at all."
	DB	NEXT
;	DB	'【清美】：さっきまで皆さん、話し掛けてらっしゃいましたけど・・・諦めてしまわれたのでしょうね。'
	DB	"Kiyomi:  Everyone was trying to talk to her, but it looks"
	DB	CR
	DB	"like they've all given up."
	DB C_BLD,C_N_ON,1,1	
	DB C_BLD,C_V_ON,2	
	DW	0000H

M2:		;見る　誠
;	DB	'あ、机に引っかかって転びそうになった。'
	DB	"He just went barreling into a desk."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　誠
;	DB	'・・・何を急いでるんだ、あいつ？'
	DB	"Wonder what he's in such a hurry about?"
	DW	0000H

M4:		;見る　瑠璃
;	DB	'・・・今は１人で・・・静かに座っている。'
	DB	"She's just sitting there quietly, all by herself."
	DB	NEXT
;	DB	'なんて言うか・・・近づきがたい雰囲気だ。'
	DB	"Funny. I kind of feel like I want to go over to her."
	DW	0000H

M5:		;見る　まわり
;	DB	'幾つかのグループに分かれてそれぞれ話題に花を咲かせている。'
	DB	"Everybody's in little groups, talking about something or"
	DB	CR
	DB	"other."
	DB	NEXT
;	DB	'・・・もう誰も白水さんに話しかけようとはしない・・・'
	DB	"Nobody's even trying to talk to Ruri anymore.."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M6:		;見る　まわり
;	DB	'いつも通り、にぎやかだ。'
	DB	"As usual, everyone is making lots of noise."
	DB	NEXT
;	DB	'・・・白水さん以外は。'
	DB	"All except for her."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M7:		;見る　まわり
;	DB	'あ、誠がこっちに走ってくる。'
	DB	"Oh, here comes Makoto."
	DB C_BLD,C_N_OFF,1,1	
	DB C_BLD,C_V_OFF,2	
	DW	0000H

M8:		;話す　誠
;	DB	'【誠】：%001～。'
	DB	"Makoto:  %001."
	DB	NEXT
;	DB	'【誠】：お前がどーしてもって言うから御所望の姫のデータ、入手して来たぜ。'
	DB	"Makoto:  Well, I found out all I could about Sleeping"
	DB	CR
	DB	"Beauty over there."
	DB	NEXT
;	DB	'【%001】：それは自分だろーが。'
	DB	"%001:  Well it was you who wanted to know, but anyway,"
	DB	CR
	DB	"what did you find out?"
	DB	NEXT
;	DB	'【誠】：彼女の家って元華族なんだってさ。世が世なら、彼女は「お嬢様」だよ。'
	DB	"Makoto:  It seems that she's from a really rich family."
	DB	CR
	DB	"She's really well-bred."
	DB	NEXT
;	DB	'【%001】：へえ・・・言われてみれば、そんな感じだな。'
	DB	"%001:  Really. Yes, that makes sense."
	DB	NEXT
;	DB	'【誠】：でも、家の都合であちこち転校してるらしいんだ。'
	DB	"Makoto:  She transfers school a lot, for some reason."
	DB	CR
	DB	"Something to do with her family's wishes. Even though the"
	DB	CR
	DB	"school year just started, this is her third school already!"
	DB	NEXT
;	DB	'【%001】：・・・１ヶ月足らずで３回・・・か。大変だな。'
	DB	"%001:  Three times in less than a month?"
	DB	FLG,F_COPYI,4,1
	DB C_BLD,C_N_ON,1,1
	DB C_BLD,C_N_ON,1,3
	DW	0000H

M9:		;話す　誠
	DB	BUF,B_COPY01
	T_CG 'CT14','W',0,0,1
;	DB	'【誠】：と、まあ、俺が仕入れた情報はこんなモンだ。'
	DB	"Makoto:  Well, that's what I was able to find out."
	DB	NEXT
;	DB	'【%001】：ああ、ご苦労。報酬代わりに俺がほめてやる。えらいぞ、誠。'
	DB	"%001:  You've done well, Makoto. Thanks..."
	DB	NEXT
;	DB	'【誠】：それだけかい！'
	DB	"Makoto:  What, no reward?"
	DB	NEXT
;	DB	'【清美】：だから・・・わたくしたちに心を開いて下さらないのでしょうか・・・'
	DB	"Kiyomi:  I guess she doesn't want to open her heart to"
	DB	CR
	DB	"us, knowing that she might have to change schools again"
	DB	CR
	DB	"soon..."
	DB	NEXT
;	DB	'【鈴子】：・・・別れが辛くなるから？'
	DB	"Reiko:  That might be right. It'd be hard for her when she"
	DB	CR
	DB	"leaves, if she makes friends here."
	DB	NEXT
;	DB	'【美緒】：・・・かわいそう・・・'
	DB	"Mio:  The poor woman."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・'
	DB	"%001:  .............."
	DB	NEXT
;	DB	'思わず静まりかえる俺達。'
	DB	"A silence fell over us."
	DB	NEXT
;	DB	'その沈黙に耐えかねたのか、鈴子さんが口を開いた。'
	DB	"Then Reiko spoke."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT01','W',0,35,2
;	DB	'【鈴子】：%001君、５月の３日空いてる？'
	DB	"Reiko:  %001, are you free on the third of May? It's Golden"
	DB	CR
	DB	"Week, so we'll have a week off of school."
	DB	NEXT
;	DB	'【%001】：空いてるけど？'
	DB	"%001:  Sure, why?"
	DB	NEXT
;	DB	'【鈴子】：じゃあ、私に付き合ってくれない？お買物がてら、街に出てみましょうよ。'
	DB	"Reiko:  Well, I was thinking of going into town for some"
	DB	CR
	DB	"shopping... Do you want to come along?"
	DB	NEXT
;	DB	'【%001】：うん、いーよ。どーせヒマだし。'
	DB	"%001:  Sure, why not?"
	DB	NEXT
	T_CG1 'CT03','W',0,10,3
	DB	ANI,A_ON,2
;	DB	'【美緒】：あたしも行っていいよね先輩！'
	DB	"Mio:  Can I come along, too?"
	DB	NEXT
;	DB	'【%001】：うん、みんなで行こう。'
	DB	"%001:  Sure, why don't we all go?"
	DB	NEXT
;	DB	'【鈴子】：・・・'
	DB	"Reiko:  ....................."
	DB	NEXT
	T_CG1 'CT02','W',0,0,4
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
;	DB	'【清美】：そうですわね、大勢の方がきっと楽しいですわ。'
	DB	"Kiyomi:  Great, it should be fun going shopping in a big"
	DB	CR
	DB	"group."
	DB	NEXT
;	DB	'【鈴子】：（ま、いっか。）'
	DB	"Reiko:  ....Oh, well."
	DB	NEXT
;	DB	'【清美】：それで、集合場所と時間は・・・'
	DB	"Kiyomi:  Well, we have to decide when and where to meet,"
	DB	CR
	DB	"where we'll go, and..."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・'
	DB	".................................................."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT14','W',0,0,1
;	DB	'【誠】：・・・何だよ、オレだけカヤの外かよぉ。'
	DB	"Makoto:  Isn't anyone going to invite me?"
	DB	NEXT
;	DB	'【誠】：それにしても・・・、ゴールデンウィーク中どうするんだろ、白水さん。まだ友達もいないだろうし・・・。'
	DB	"Makoto:  In that case, I wonder what Ruri is doing during"
	DB	CR
	DB	"Golden Week."
	DB	NEXT
	E_CG B_SUDA,'AE_012'
;	DB	'【瑠璃】：・・・'
	DB	"Ruri:  ........................."
	DB	NEXT
	B_O B_WIPE
	DB SINARIO,'CS403.OVL',0
	DW	0000H


end
