;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　４０４
;		デパート

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0

;NN1:	DB	1,	'３人',0
NN1:	DB	1,	"GIRLS",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　３人


;イニシャルメッセージ
M1:
	DB	BGM,17
	BAK_INIT 'AB_37'
	B_P1 B_SUDA
;	DB	'【美緒】：鈴子先輩、このカーディガンどうかな？'
	DB	"Mio:  Reiko, how about this sweater?"
	DB	NEXT
;	DB	'【鈴子】：う～ん・・・ちょっと地味すぎない？'
	DB	"Reiko:  Hmmm... Maybe a little too dark for your eyes?"
	DB	NEXT
;	DB	'【美緒】：そうかなぁ・・・'
	DB	"Mio:  Oh. I thought it'd look good on me."
	DB	NEXT
;	DB	'【清美】：あら、わたくしはよくお似合いだと思いますわ。'
	DB	"Kiyomi:  I think it suits you really well."
	DB	NEXT
;	DB	'【鈴子】：私は美緒には暖色系の色の方が似合うと思うけど。'
	DB	"Reiko:  I don't know. I think she needs something brighter."
	DB	NEXT
;	DB	'【清美】：まあ、このブラウス６割引ですわ！',CR,'とてもお買得ですわね！'
	DB	"Kiyomi:  Goodness, this blouse has been reduced sixty percent!"
	DB	CR
	DB	"That's very affordable!"
	DB	NEXT
;	DB	'【美緒】：鈴子先輩は何も買わないの？'
	DB	"Mio:  Aren't you going to buy anything, Reiko?"
	DB	NEXT
;	DB	'【鈴子】：イマイチ気に入るのが無いのよ・・・。',CR,'在庫処分市だから仕方ないけどね。'
	DB	"Reiko:  I don't see anything I like right now."
	DB	NEXT
;	DB	'【美緒】：あ！鈴子先輩、これなんかどう？'
	DB	"Mio:  Reiko, how about this?"
	DB	NEXT
;	DB	'【鈴子】：色はいいんだけど、デザインがね・・・'
	DB	"Reiko:  I like the color, but the design..."
	DB	NEXT
;	DB	'・・・ヒマだ。'
	DB	"I'm bored."
	DW	0000H

M2:		;見る　３人
;	DB	'お互いに服を見立てたりしてる。'
	DB	"They're holding clothes up to each other."
	DB	NEXT
;	DB	'こうなると、俺の出る幕は全くない。'
	DB	"At this rate, we'll never get out of here."
	DB	NEXT
;	DB	'ああ、ヒマだ。'
	DB	"Time for a break."
	DB	NEXT
;	DB	'少し休むか・・・。'
	DB	"I'll just take a little rest."
	DB	NEXT
;	DB	'【%001】：ちょっと、その辺にいるから。'
	DB	"%001:  Um, I'll be over there if you need me."
	DB	NEXT
;	DB	'・・・返事は帰って来なかった。'
	DB	"There was no answer. They were too busy shopping."
	DB	NEXT
;	DB	'俺は売り場から少し離れた階段に腰掛けた。'
	DB	"I left the sales floor and sat down on some stairs."
	DB	NEXT
;	DB	'「そこのあなた。」'
	DB	"???:  Hey you."
	DB	NEXT
;	DB	'「こっち向きなさいよ。」'
	DB	"???:  Turn around."
	DB	NEXT
;	DB	'【%001】：・・・俺？'
	DB	"%001:  ...Me?"
	DB	NEXT
;	DB	'背後から声をかけられて、俺は振り返った。'
	DB	"I turned around to see who was talking to me."
	DB	NEXT
	DB SINARIO,'CS405.OVL',0
	DW	0000H


end
