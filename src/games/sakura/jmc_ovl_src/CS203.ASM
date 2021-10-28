;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　２０３
;		

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3, CM4, CM5
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:


	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	NN1,NN2,-1
CM5:	DW	VV5,	NN1,NN2,-1

;VV1:	DB	1,	"さぼってる",0
VV1:	DB	1,	"CUTTING CLASS",0
;VV2:	DB	2,	"昼寝してる",0
VV2:	DB	2,	"TAKING A NAP",0
;VV3:	DB	3,	"瞑想してる",0
VV3:	DB	3,	"MEDITATING",0
;VV4:	DB	4,	"見る",0
VV4:	DB	4,	"LOOK ",0
;VV5:	DB	5,	"話す",0
VV5:	DB	5,	"TALK",0

;NN1:	DB	1,	"女の子",0
NN1:	DB	1,	"WOMAN",0
;NN2:	DB	2,	"美緒",0
NN2:	DB	2,	"MIO",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2		;さぼってる
S2:		DW	VV2, -1,  2, M3		;昼寝してる
S3:		DW	VV3, -1,  3, M4		;瞑想してる
S4:		DW	VV4, NN1,  4, M5		;見る　女の子
S5:		DW	VV4, NN2,  5, M6		;見る　美緒
S6:		DW	VV5, NN1,  6, M7, M8, M9		;話す　女の子
S7:		DW	VV5, NN2,  7, M10		;話す　美緒


;イニシャルメッセージ
M1:
	DB	BGM,19
	BAK_INIT "AB_46"
	E_CG B_TATE,"AE_004"
;	DB	"俺が目を開けると、誰かが寝そべってる俺の顔を覗き込んでいた。"
	DB	"I open my eyes and someone is staring down at me."
	DB	NEXT
;	DB	"満開の桜の花をバックに、俺を不思議そうな顔で見つめてる女の子・・・"
	DB	"A woman is staring at me with a strange expression. The"
	DB	CR
	DB	"fully-blooming cherry blossoms behind her."
	DB	NEXT
;	DB	"・・・桜の精？"
	DB	"Is she some kind of spirit? The spirit of this tree?"
	DB	NEXT
;	DB	"【？】：先輩、何してるの？"
	DB	"???:  What are you doing here?"
	DB C_BLD,C_N_ON,4,2		;見る　美緒　消し
	DB C_BLD,C_N_ON,5,2		;話す　美緒　消し
	DB C_BLD,C_V_ON,5		;話す　消し
	DW	0000H

M2:		;さぼってる
;	DB	"【%001】：さぼってるだけだよ。"
	DB	"%001:  I'm just cutting class."
	DB	NEXT
;	DB	"【？】：ふ～ん・・・"
	DB	"???:  Is that so?"
	DB	NEXT
;	DB	"【%001】：君は？"
	DB	"%001:  What about you?"
	DB	NEXT
;	DB	"【？】：ちょっと・・・気になったから。"
;	DB	"???:  I was just curious...";
;	DB	NEXT
;	DB	"【？】：何でこんな所で寝てるんだろう、って思って・・・。"
	DB	"???:  I was wondering if you were dead or not."
	DB	C_BLD,C_V_ON,1		;さぼってる　消す
	DB	C_BLD,C_V_ON,2		;昼寝してる　消す
	DB	C_BLD,C_V_ON,3		;瞑想してる　消す
	DB C_BLD,C_V_OFF,5		;話す　出し
	DW	0000H

M3:		;昼寝してる
;	DB	"【%001】：昼寝してるだけ。"
	DB	"%001:  I'm just taking a nap."
	DB	NEXT
;	DB	"【？】：ふ～ん・・・"
	DB	"???:  Is that so?"
	DB	NEXT
;	DB	"【%001】：君は？"
	DB	"%001:  And what about you?"
	DB	NEXT
;	DB	"【？】：ちょっと・・・気になったから。"
;	DB	"???:  I was just curious..."
;	DB	NEXT
;	DB	"【？】：何でこんな所で寝てるんだろう、って思って・・・。"
	DB	"???:  I was wondering if you were dead or not."
	DB	C_BLD,C_V_ON,1		;さぼってる　消す
	DB	C_BLD,C_V_ON,2		;昼寝してる　消す
	DB	C_BLD,C_V_ON,3		;瞑想してる　消す
	DB C_BLD,C_V_OFF,5		;話す　出し
	DW	0000H

M4:		;瞑想してる
;	DB	"【%001】：瞑想してる。"
	DB	"%001:  I was meditating."
	DB	NEXT
;	DB	"【？】：・・・あたし、邪魔かな。"
	DB	"???:  Oh. Am I interrupting you?"
	DB	NEXT
;	DB	"【%001】：別に。君は一体何してんの？"
	DB	"%001:  Not really. What are you doing here?"
	DB	NEXT
;	DB	"【？】：ちょっと・・・気になったから。"
;	DB	"???:  I was just curious..."
;	DB	NEXT
;	DB	"【？】：何でこんな所で寝てるんだろう、って思って・・・。"
	DB	"???:  I was wondering if you were dead."
	DB	C_BLD,C_V_ON,1		;さぼってる　消す
	DB	C_BLD,C_V_ON,2		;昼寝してる　消す
	DB	C_BLD,C_V_ON,3		;瞑想してる　消す
	DB C_BLD,C_V_OFF,5		;話す　出し
	DW	0000H

M5:		;見る　女の子
;	DB	"落ち着いてよく見れば、どうやらこの学校の中等部の生徒らしい。"
	DB	"She goes to this Junior College."
	DB	NEXT
;	DB	"きれいな目をした女の子だ。"
	DB	"She has such pretty eyes."
	DW	0000H

M6:		;見る　美緒
;	DB	"俺の隣に腰を降ろして、俺を覗き込むように話している。"
	DB	"She sits down beside me."
	DB	NEXT
;	DB	"バックの桜に映えて、どこか現実離れして見える。"
	DB	"With the cherry blossoms behind her, it all seems like"
	DB	CR
	DB	"a dream."
	DW	0000H

M7:		;話す　女の子
;	DB	"【？】：先輩・・・となり座っていい？"
	DB	"???:  Do you mind if I sit here?"
	DB	NEXT
;	DB	"【%001】：別に俺に断わらなくたってい～って。この桜は学校の備品なんだからさ。"
	DB	"%001:  You don't have to ask my permission to sit here. The"
	DB	CR
	DB	"cherry tree is the school's property."
	DB	NEXT
;	DB	"【？】：備品？"
	DB	"???:  Property?"
	DB	NEXT
;	DB	"【%001】：生き物を備品っていうのは変か。"
	DB	"%001:  I guess it's strange to call a living thing that."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG "CT03","W",0,10,1
;	DB	"彼女は寝ている俺の隣にちょこんと腰を降ろした。"
	DB	"She sits down beside me."
	DB	FLG,F_COPYI,6,1
	DW	0000H

M8:		;話す　女の子
;	DB	"【？】：・・・どこに入るか、決めた？"
	DB	"???:  So, have you decided what club you want to join?"
	DB	NEXT
;	DB	"【%001】：まあ、入学する前から決めてたところがあるから。"
	DB	"%001:  I decided what club to join before school started."
	DB	NEXT
;	DB	"【？】：何部？"
	DB	"???:  Which one?"
	DB	NEXT
;	DB	"【%001】：帰宅部。"
	DB	"%001:  The 'going home after school club.'"
	DB	NEXT
;	DB	"【？】：え・・・"
	DB	"???:  Huh?"
	DB	NEXT
;	DB	"【？】：先輩、面白そうなクラブ見つからなかったの？"
	DB	"???:  You didn't find any interesting clubs?"
	DB	NEXT
;	DB	"【%001】：・・・面白そうなクラブは沢山あったけど、自分が入りたいとは思わなかったな。"
	DB	"%001:  Oh, there are a lot of interesting clubs. Just none"
	DB	CR
	DB	"that I want to join."
	DB	NEXT
;	DB	"【？】：たくわん同好会とか？"
	DB	"???:  What, like the 'Friends of Pickled Radishes'?"
	DB	NEXT
;	DB	"（・・・そんなのまであるのかこの学校は・・・）"
	DB	"...I didn't see that one."
	DB	FLG,F_COPYI,6,2
	DW	0000H

M9:		;話す　女の子
;	DB	"【？】：先輩・・・テニス、興味ない？"
	DB	"???:  Do you like tennis?"
	DB	NEXT
;	DB	"【%001】：テニスねぇ・・・"
	DB	"%001:  Tennis?"
	DB	PAUSE
;	DB	"君はテニス部なのか？・・・えっと・・・"
	DB	" Are you in the tennis club? Um, what's"
	DB	CR
	DB	"your name...?"
	DB	NEXT
;	DB	"【美緒】：美緒、鈴木　美緒（みお）。中等部の３－Ａ。"
	DB	"Mio:  Mio. Mio Suzuki. Class 1-E."
	DB	NEXT
;	DB	"【%001】：俺は高等部の１－Ａ、山神　%001。"
	DB	"%001:  I'm %001 Yamagami. I'm in 1-A."
	DB C_BLD,C_N_OFF,4,2		;見る　美緒　消し
	DB C_BLD,C_N_OFF,5,2		;話す　美緒　消し
	DB C_BLD,C_N_ON,4,1		;見る　女の子　消し
	DB C_BLD,C_N_ON,5,1		;見る　女の子　消し
	DW	0000H

M10:		;話す　美緒
;	DB	"【%001】：俺、テニスってよくわかんねーし。"
	DB	"%001:  I'm not very good at tennis, though."
	DB	NEXT
;	DB	"【美緒】：大丈夫、すぐ覚えられるよ！"
	DB	"Mio:  It's okay. You can pick it up in no time."
	DB	NEXT
;	DB	"【美緒】：あたし、先輩って絶対テニスに向いてると思うな！"
	DB	"Mio:  I just have this feeling that you were made for tennis."
	DB	NEXT
;	DB	"【%001】：そうかぁ？"
	DB	"%001:  Really?"
	DB	NEXT
;	DB	"・・・美緒ちゃんが身を乗り出して、テニスの楽しさについて熱心に語るのを、俺は半分聞き流していた。"
	DB	".....I listen half-heartedly as Mio extolls the merits of"
	DB	CR
	DB	"tennis."
	DB	NEXT
;	DB	"俺は、自分がスポーツに向いてないのを知ってるから。"
	DB	"I don't tell her the reason why I want to avoid sports"
	DB	CR
	DB	"altogether."
	DB	NEXT
;	DB	"「あ、こんなところにいたのね。」"
	DB	"???:  Oh, here you are."
	DB	NEXT
	DB SINARIO,"CS204.OVL",0
	DW	0000H


end
