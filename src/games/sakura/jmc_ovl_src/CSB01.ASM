;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｂ０１
;		教室
	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5
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
CM2:	DW	VV2,	NN2,NN3,NN4,NN5,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'教室',0
NN1:	DB	1,	'CLASSROOM',0
;NN2:	DB	2,	'誠',0
NN2:	DB	2,	'MAKOTO',0
;NN3:	DB	3,	'恵依美',0
NN3:	DB	3,	'MEIMI',0
;NN4:	DB	4,	'星愛',0
NN4:	DB	4,	'SEIA',0
;NN5:	DB	5,	'星愛と恵依美',0
NN5:	DB	5,	'SEIA & MEIMI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4, M5		;見る　教室
S2:		DW	VV2, NN2,  2, M6, M7, M8, M9, M10, M11, M12		;話す　誠
S3:		DW	VV2, NN3,  3, M13		;話す　恵依美
S4:		DW	VV2, NN4,  4, M14		;話す　星愛
S5:		DW	VV2, NN5,  5, M15		;話す　星愛と恵依美


;イニシャルメッセージ
M1:
	DB	BGM,5
	BAK_INIT "AB_36_3"
	DB	BUF,B_COPY01
	T_CG "CT14","W",0,15,1
;	DB	'・・・そして、瞬く間に１月は終わり、寒さが身にしみる２月がやって来た。'
	DB	"...Soon January was over, and cold, unforgiving Febaruary was"
	DB	CR
	DB	"here."
	DB	NEXT
;	DB	'【%001】：すぁ～て、昼メシ昼メシ。'
	DB	"%001:  Well, it's time for lunch..."
	DB	NEXT
;	DB	'【%001】：・・・あれ？'
	DB	"%001:  ......Huh?"
	DB	C_BLD,C_N_ON,2,2		;話す　恵依美　消す
	DB	C_BLD,C_N_ON,2,3		;話す　星愛　消す
	DB	ERASE,E_GFLG,10,100,101,102,103,104,105,106,107,108,109	;巡回クリア
	DW	0000H


M2:		;見る　教室
;	DB	'（新藤さん・・・？）'
	DB	"Where's Kiyomi...?"
	DB	NEXT
;	DB	'いつも一緒に昼メシを食う新藤さんが、今日は見当たらない。'
	DB	"We usually each lunch together, but she's not here today."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　教室
;	DB	'（・・・・・・・・・）'
	DB	"............................."
	DB	NEXT
;	DB	'お昼時には必ず現れる鈴子さんと美緒ちゃんが、今日は５分たっても現われない。'
	DB	"Reiko and Mio also show up about this time, but they're not"
	DB	CR
	DB	"here."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;見る　教室
;	DB	'今俺といるのは誠と吉田と中野。'
	DB	"The only ones here are Makoto, Meimi and Seia."
	DB	NEXT
;	DB	'新藤さんがいない・・・。'
	DB	"Kiyomi's gone..."
	DB	FLG,F_COPYI,1,3
	DW	0000H

M5:		;見る　教室
;	DB	'普段から落ち着きもへったくれもないクラスだが、最近は特にざわざわしてる。'
	DB	"It's usually so loud in here I can't concentrate, but now"
	DB	CR
	DB	"it's too quiet."
	EF_SET 101
	DW	0000H

M6:		;話す　誠
;	DB	'【%001】：誠、新藤さん知らねー？'
	DB	"%001:  Makoto, do you know where Kiyomi is?"
	DB	NEXT
;	DB	'【誠】：新藤？・・・そういやぁいねぇな。'
	DB	"Makoto:  Shinfuji? Nope, I don't know."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M7:		;話す　誠
;	DB	'【誠】：%001、鈴子さん来ねぇな。'
	DB	"Makoto:  You're right, she's not here. "
	DB	NEXT
;	DB	'【%001】：そうだな・・・新藤さんもいないし、美緒ちゃんも来てない。'
	DB	"%001:  Neither are Reiko or Mio."
	DB	NEXT
;	DB	'【%001】：あの３人、何かあったんだろーか？'
	DB	"%001:  I wonder what they're doing?"
	DB	NEXT
;	DB	'【誠】：ひょっとして・・・お前があんまり優柔不断だったから、愛想つかしたんじゃねーの？'
	DB	"Makoto:  Maybe they're deciding which one of them you'll"
	DB	CR
	DB	"end up with, since you can't make up your stupid mind?"
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・そうなのか・・・・・・・・？'
	DB	"%001:  ............I doubt that."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M8:		;話す　誠
;	DB	'【誠】：あ～あ、この分じゃ今度のバレンタインも期待出来そうにねぇな～・・・'
	DB	"Makoto:  I guess there won't be anything to look forward to"
	DB	CR
	DB	"this Valentine's Day."
	DB	NEXT
;	DB	'【%001】：・・・バレンタイン・・・'
	DB	"%001:  Valentine's Day?"
	DB	NEXT
;	DB	'【誠】：まさかお前、バレンタインも知らねぇほどお子様じゃねーだろうな？'
	DB	"Makoto:  Don't tell me you don't know what that is? You're"
	DB	CR
	DB	"such an idiot!"
	DB	NEXT
;	DB	'【%001】：今どきそんな日本人がいるか。'
	DB	"%001:  I know what it is!"
	DB	NEXT
	DB	"Valentine's Day is a little different in Japan than it is"
	DB	CR
	DB	"in other countries."
	DB	NEXT
	DB	"In Japan, February 14th is a time for women to give chocolate"
	DB	CR
	DB	"to men. If a woman is in love with someone, they will usually"
	DB	CR
	DB	"confess their feelings on this day."
	DB	NEXT
	DB	"Women sometimes give chocolate to their bosses or other"
	DB	CR
	DB	"people they have an obligation to give it to. This is called"
	DB	CR
	DB	"'giri choco.'"
	DB	NEXT
	DB	"Men who get chocolate have to give a present back to the"
	DB	CR
	DB	"women one month later, on White Day. He usually gives white"
	DB	CR
	DB	"chocolate."
	DB	NEXT
	DB	"Sometimes, I think that both Valentine's Day and White Day"
	DB	CR
	DB	"were invented in Japan by chocolate companies."
	DB	FLG,F_COPYI,2,3
	DW	0000H


M9:		;話す　誠
;	DB	'【誠】：お前のおこぼれで義理チョコもらうの、結構期待してたんだぜ・・・'
	DB	"Makoto:  I'm planning on taking some of the chocolate you"
	DB	CR
	DB	"get from all those women that are in love with you."
	DB	NEXT
;	DB	'【%001】：・・・お前・・・聞いてるこっちが哀しくなってくるぞ、それ。'
	DB	"%001:  That's pathetic!"
	DB	NEXT
;	DB	'【誠】：そーでもなきゃ鈴子さんが俺にチョコくれるわけないだろ。'
	DB	"Makoto:  It's the only way I'll be able to get any"
	DB	CR
	DB	"chocolate from Reiko, though."
	DB	NEXT
;	DB	'【%001】：今から水泳部に入ったらどーだ？'
	DB	"%001:  Why don't you join the swimming team?"
	DB	NEXT
;	DB	'【誠】：ダメだ、サバ研の活動が忙しいからな。'
	DB	"Makoto:  No, I'm too busy with the survival club."
	DB	FLG,F_COPYI,2,4
	DW	0000H

M10:		;話す　誠
;	DB	'【%001】：今日子先生はくれると思うぞ、きっと。'
	DB	"%001:  I'll bet Kyoko-sensei will give you something."
	DB	NEXT
;	DB	'【誠】：ダメダメ、あの先生がくれるのはチョコなしのチョコレートボンボンに決まってるさ。'
	DB	"Makoto:  No, she'd be more likely to give me chocolates"
	DB	CR
	DB	"with bourbon in them."
	DB	NEXT
;	DB	'【%001】：でも、もらえないよりはい～じゃないか。'
	DB	"%001:  But at least it's something."
	DB	FLG,F_COPYI,2,5
	DW	0000H

M11:		;話す　誠
;	DB	'【誠】：その点、お前はいーよな',CR,'・・・何しろ体育祭制覇のヒーローだもんな。'
	DB	"Makoto:  I really envy you, being the class hero and"
	DB	CR
	DB	"everything. "
	DB	NEXT
;	DB	'【誠】：きっとバレンタインデーは大変だぞ、お前。'
	DB	"Makoto:  I think you're going to get chocolate from all the"
	DB	CR
	DB	"women in the school on Valentine's Day."
	DB	NEXT
	T_CG "CT07","W",0,0,2
	DB	ANI,A_ON,1
;	DB	'【星愛】：そうでもないと思いますわ。'
	DB	"Seia:  I'm not so sure about that."
	DB	NEXT
;	DB	'【誠】：何で？'
	DB	"Makoto:  Why?"
	DB	NEXT
;	DB	'【星愛】：%001さんのまわりには、いつも清美さん達がいらっしゃいますもの。'
	DB	"Seia:  Because Kiyomi and the others are always keeping"
	DB	CR
	DB	"%001 to themselves."
	DB	NEXT
	T_CG "CT08","W",0,33,3
	DB	ANI,A_ON,1
	DB	ANI,A_ON,2
;	DB	'【恵依美】：そーいうこと。あれだけ見せ付けられれば、諦めるしかないってもんよ。やってられないわ、ホントに。'
	DB	"Meimi:  Sure. If there were other women who wanted to"
	DB	CR
	DB	"give %001 chocolate, they'd have to get past Reiko, Kiyomi"
	DB	CR
	DB	"and Mio. That'd be pretty difficult..."
	DB	NEXT
;	DB	'【誠】：あれぇ？ひょっとして中野も%001のこと・・・'
	DB	"Makoto:  Hey, you're not in love with %001, too, are you?"
	DB	NEXT
	K_CG "CT08","D",33,4
	DB	ANI,A_ON,1
	DB	ANI,A_ON,2
;	DB	'【恵依美】：なっっっ・・・・・・'
	DB	"Meimi:  What?!"
	DB	PAUSE
;	DB	'何言ってんのよ！あたしは%001の事なんか・・・！'
	DB	" What are you saying? I'm not in love with"
	DB	CR
	DB	"%001!"
	DB	NEXT
;	DB	'【誠】：ムキになるところが怪しいなぁ。'
	DB	"Makoto:  Look at how she jumped with I said it. I'd say"
	DB	CR
	DB	"you can add her to the list, %001."
	DB	NEXT
;	DB	'【恵依美】：・・・男子全員に義理チョコ配るつもりだったけど、誠には絶っっっっ対にあげない！'
	DB	"Meimi:  I was planning on giving some chocolate to all"
	DB	CR
	DB	"the guys in the class, but you're not getting anything, "
	DB	CR
	DB	"Makoto!"
	DB	NEXT
	K_CG "CT14","I",15,5
	DB	ANI,A_ON,4
	DB	ANI,A_ON,2
;	DB	'誠は塩の柱になった。'
	DB	"Makoto became a pillar of salt."
	DB	NEXT
	B_O B_NORM	
	E_CG B_NORM,"T_11"
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG "CT07","W",0,0,2
	T_CG "CT08","W",0,33,3
	DB	ANI,A_ON,2
	DB	FLG,F_COPYI,2,6
	DB	C_BLD,C_N_ON,2,4		;話す　星愛と恵依美　消す
	DB	C_BLD,C_N_OFF,2,2		;話す　恵依美　出し
	DB	C_BLD,C_N_OFF,2,3		;話す　星愛　出し
	DW	0000H


M12:		;話す　誠
;	DB	'【星愛】：主よ、この哀れな仔羊にお慈悲を・・・'
	DB	"Seia:  Lord, please forgive this silly fool..."
	DB	NEXT
;	DB	'【誠】：慈悲よりチョコをくれーっ！'
	DB	"Makoto:  And give him some chocolate for Valentine's Day!"
	EF_SET 102
	DW	0000H


M13:		;話す　恵依美
;	DB	'【恵依美】：%001も義理チョコ欲しい？'
	DB	"Meimi:  Do you want chocolate that bad?"
	DB	NEXT
;	DB	'【%001】：義理ならいい。ホワイトデーのお返しも大変だし。'
	DB	"%001:  I don't want 'giri choco.' I don't like having to"
	DB	CR
	DB	"give them back something on White Day."
	DB	NEXT
;	DB	'【恵依美】：・・・そう。'
	DB	"Meimi:  ......Yeah."
	EF_SET 103
	DW	0000H


M14:		;話す　星愛
;	DB	'【星愛】：そう言えば、清美さんはどちらにいらっしゃるのでしょう？'
	DB	"Seia:  Do you know where Kiyomi is, by any chance?"
	DB	NEXT
	DB	"%001:  Not me."
	EF_SET 104
	DW	0000H


M15:		;話す　星愛と恵依美
;	DB	'【%001】：吉田、中野、新藤さんどこ行ったか知らないか？'
	DB	"%001:  Seia or Meimi, do you know where Kiyomi is?"
	DB	NEXT
;	DB	'【恵依美】：・・・それがクラス委員の勤めだと思うのよ。'
	DB	"Meimi:  I think you should ask the class representative"
	DB	CR
	DB	"about that. Seia?"
	DB	NEXT
;	DB	'【星愛】：・・・ですが、皆さん楽しみにしてらっしゃるようですわよ。'
	DB	"Seia:  ....But I don't want to tell you. Sorry."
	DB	NEXT
;	DB	'【%001】：お～い・・・'
	DB	"%001:  Hey!"
	DB	NEXT
;	DB	'吉田と中野は何やら話し込んでて、俺に答えてくれなかった。'
	DB	"They start talking among themselves again, without"
	DB	CR
	DB	"answering my question."
	DW	0000H


M_EXIT:
	DB FLG,F_COPYI,255,1
	DB FLG,F_MAND,5,255,101,102,103,104
	DB FLG,F_EXIT,255
	DB	NEXT
;	DB	'がらっ'
;	DB	NEXT
	DB BUF,B_COPY01
	T_CG 'CT02','W',0,20,8
;	DB	'【清美】：・・・'
	DB	"Kiyomi:  ..............................."
	DB	NEXT
;	DB	'【%001】：あ、新藤さん。どこ行ってたの？'
	DB	"%001:  Ah, Kiyomi. Where were you?"
	DB	NEXT
;	DB	'【清美】：少々用事がありまして・・・'
	DB	"Kiyomi:  Oh, I had an errand to run."
	DB	NEXT
;	DB	'【%001】：ふ～ん？とにかく、お昼食べようぜ。'
	DB	"%001:  You did? Anyway, let's eat lunch."
	DB	NEXT
;	DB	'【清美】：・・・わたくしを待っていて下さったのですか？'
	DB	"Kiyomi:  Did you wait for me? That was so nice of you."
	DB	NEXT
;	DB	'【%001】：まあ・・・そんなとこかな。'
	DB	"%001:  Well, it was nothing."
	DB	NEXT
;	DB	'【%001】：そう言えば、鈴子さんと美緒ちゃん知らないか？'
	DB	"%001:  Do you know where Reiko and Mio are?"
	DB	NEXT
;	DB	'【清美】：・・・お二人とも、お忙しいとおっしゃっていましたわ。。'
	DB	"Kiyomi:  They're both busy."
	DB	NEXT
;	DB	'【%001】：へぇ・・・'
	DB	"%001:  Oh."
	DB	NEXT
	DB SINARIO,'CSB02.OVL',0
	DW	0000H


end
