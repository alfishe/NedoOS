;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　５０４＿Ｂ
;		清美と雨宿り

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
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'清美',0
NN1:	DB	1,	'KIYOMI',0
;NN2:	DB	2,	'空',0
NN2:	DB	2,	'SKY',0
;NN3:	DB	3,	'洞窟',0
NN3:	DB	3,	'CAVE',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　清美
S2:		DW	VV1, NN2,  2, M3, M4		;見る　空
S3:		DW	VV1, NN3,  3, M5		;見る　洞窟
S4:		DW	VV2, NN1,  4, M6, M7, M8, M9, M10, M11, M12, M13, M14		;話す　清美


;イニシャルメッセージ
M1:
	DB	BGM,18
;	DB	'【清美】：ふぅ、びしょびしょになってしまいましたわ・・・'
	DB	"Kiyomi:  We're terribly wet, aren't we?"
	DB	NEXT
;	DB	'【%001】：待ってて、今火を起こすから。'
	DB	"%001:  I'll light a fire."
	DB	NEXT
;	DB	'俺はライターで小枝に火を付けて、小さな火を起こした。'
	DB	"I took the firewood and lit it with my lighter."
	E_CG B_FADE,'AE_018'
	DW	0000H

M2:		;見る　清美
;	DB	'雨に濡れて、体操着が透けてる・・・'
	DB	"She's dripping wet. I can see through her P.E. uniform."
	DB	NEXT
;	DB	'【清美】：%001さん・・・あまり見ないで下さい。'
	DB	"Kiyomi:  %001, please don't stare at me."
	DB	NEXT
;	DB	'【%001】：ご、ごめん！'
	DB	"%001:  I'm sorry!"
	DW	0000H

M3:		;見る　空
;	DB	'【%001】：こりゃしばらく止みそうにないな。'
	DB	"%001:  It doesn't look like it's going to stop for a while."
	DB	NEXT
;	DB	'【清美】：困りましたわね・・・。'
	DB	"Kiyomi:  This is terrible..."
	DW	0000H

M4:		;見る　空
;	DB	'ふと見ると、いつのまにか青空がひろがっていた。'
	DB	"Suddenly, the sky above us was clearing."
	DW	0000H

M5:		;見る　洞窟
;	DB	'俺達は入り口のすぐ近くにいるが、まだまだ奥に行けそうだ。'
	DB	"We're near the entrance, but the cave seems to go on for"
	DB	CR
	DB	"quite a ways."
	DW	0000H

M6:		;話す　清美
;	DB	'【清美】：%001さんは、いつもライターを持ち歩いてらっしゃるのですか？'
	DB	"Kiyomi:  Do you carry a lighter with you everywhere?"
	DB	NEXT
;	DB	'【%001】：いや、さっき誠に持たされたんだよ、必需品だからって。'
	DB	"%001:  No, Makoto just gave it to me. He said I might need"
	DB	CR
	DB	"it."
	DB	NEXT
;	DB	'【%001】：あとこんなのも・・・。'
	DB	"%001:  He also gave me this..."
	DB	NEXT
;	DB	'俺は誠に渡されたサバイバル・ツール一式をひろげて見せた。'
	DB	"I showed her the survival kit that Makoto had given me."
	DB	NEXT
;	DB	'【清美】：まあ・・・'
	DB	"Kiyomi:  Incredible."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M7:		;話す　清美
;	DB	'【清美】：この金属板は、何に使うのですか？'
	DB	"Kiyomi:  What's this metal plate used for?"
	DB	NEXT
;	DB	'【%001】：さあ？誠に聞かねーとわからんな。'
	DB	"%001:  I'm not sure. You'd have to ask Makoto."
	DB	FLG,F_COPYI,4,2
	DW	0000H

M8:		;話す　清美
;	DB	'【清美】：きっと皆さん、心配してらっしゃいますわね。'
	DB	"Kiyomi:  They must be worried about us back at camp."
	DB	NEXT
;	DB	'【%001】：雨がやむのを待つしかないよ。'
	DB	"%001:  The only thing we can do is wait for the rain to"
	DB	CR
	DB	"stop."
	DB	FLG,F_COPYI,4,3
	DW	0000H

M9:		;話す　清美
;	DB	'【清美】：・・・そう言えば、わたくしずっと%001さんにお伝え出来ずにいたことがありましたわ。'
	DB	"Kiyomi:  I just remembered. There was something I've"
	DB	CR
	DB	"wanted to tell you for a long time."
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Mm?"
	DB	NEXT
;	DB	'【清美】：わたくしの弟の、慎治のことですわ。'
	DB	"Kiyomi:  It's about my younger brother, Shinji."
	DB	NEXT
;	DB	'【%001】：ああ、慎治君を助けたことか。'
	DB	"%001:  Oh, you mean my saving him. It was nothing."
	DB	NEXT
;	DB	'【清美】：覚えていて下さったのですか！？'
	DB	"Kiyomi:  ....You remembered after all?"
	DB	FLG,F_COPYI,4,4
	DW	0000H

M10:		;話す　清美
;	DB	'【%001】：俺はすっかり忘れてたけど、本人から直接聞いて思い出したよ。'
	DB	"%001:  I forgot, but he reminded me when I talked to him."
	DB	NEXT
;	DB	'【清美】：・・・慎治に会ったのですか？'
	DB	"Kiyomi:  You met Shinji?"
	DB	NEXT
;	DB	'【%001】：あぁ。最初は知らない子が話し掛けて来たんで何事かと思ったが。'
	DB	"%001:  Yes. I wondered who he was at first."
	DB	NEXT
;	DB	'【清美】：まあ！あの慎治が・・・'
	DB	"Kiyomi:  Oh! That Shinji..."
	DB	FLG,F_COPYI,4,5
	DW	0000H


M11:		;話す　清美
;	DB	'【清美】：母が亡くなってから、慎治はひどく人見知りする子になってしまいましたの。'
	DB	"Kiyomi:  After our mother died, Shinji became very shy and"
	DB	CR
	DB	"withdrawn, not willing to talk to peole he didn't know well."
	DB	NEXT
;	DB	'【清美】：その慎治が、一度会っただけの%001さんに、自分から話し掛けたなんて・・・。'
	DB	"Kiyomi:  I'm surprised to hear that he spoke to you, since"
	DB	CR
	DB	"you'd only met him once."
	DB	NEXT
;	DB	'【%001】：そか・・・。慎治君にとっちゃ決死の覚悟だったのかもな。'
	DB	"%001:  Hmmm. It must have been difficult for him."
	DB	NEXT
;	DB	'【%001】：それをあんなそっけなくあしらっちまって・・・',CR,'知らねーこととはいえ、悪いことしたな・・・。'
	DB	"%001:  I'm sorry for forgetting about him."
	DB	NEXT
;	DB	'【%001】：今度、謝っといてくれる？'
	DB	"%001:  Will you apologize to him for me next time you see him?"
	DB	NEXT
;	DB	'【清美】：その必要はありませんわ。'
	DB	"Kiyomi:  There's no need for that."
	DB	FLG,F_COPYI,4,6
	DW	0000H

M12:		;話す　清美
;	DB	'【清美】：どうか致しました？面白い顔をなさって・・・'
	DB	"Kiyomi:  What's wrong?" 
	DB	NEXT
;	DB	'【%001】：いやぁ・・・新藤さんの口からそんな台詞が出るとは・・・'
	DB	"%001:  Oh, I was just thinking about you and Shinji, having"

	DB	CR

	DB	"lost your mother and all..."
	DB	NEXT
;	DB	'【清美】：・・・おかしいですか？'
	DB	"Kiyomi:  Oh. Well, we've had to go on."
	DB	FLG,F_COPYI,4,7
	DW	0000H

M13:		;話す　清美1
;	DB	'【%001】：・・・でもまあ、一言お礼を言うためにずっと俺を',CR,'捜してたなんて今時珍しいいい子じゃないか。',CR,'さすが、新藤さんの弟だな。'
	DB	"%001:  I have to say, though, to look for me for so long"
	DB	CR
	DB	"just so he could thank me. He's quite a kid."
	DB	NEXT
;	DB	'【清美】：・・・慎治だけではありませんわ。'
	DB	"Kiyomi:  Shinji isn't the only one."
	DB	NEXT
;	DB	'【清美】：わたくしも、ちゃんとお礼を言いたくてずっとあなたを捜しておりましたのよ。'
	DB	"Kiyomi:  I, too, searched and searched for you, just so"
	DB	CR
	DB	"I could thank you in person."
	DB	NEXT
;	DB	'【清美】：一年前のあの日から、ずっと・・・ずっと！'
	DB	"Kiyomi:  Every since that day a year ago...searching...!"
	DB	NEXT
;	DB	'【%001】：新藤さん・・・'
	DB	"%001:  Kiyomi..."
	DB	FLG,F_COPYI,4,8
	DB	FLG,F_COPYI,2,1
	DW	0000H


M14:		;話す　清美
;	DB	'【%001】：あ。雨、上がってら。'
	DB	"%001:  The rain's stopped."
	DB	NEXT
;	DB	'【清美】：え？'
	DB	"Kiyomi:  Eh?"
	DB	NEXT
;	DB	'【清美】：・・・・・・っくしゅん！'
	DB	"Kiyomi:  .....*ACHOO*!"
	DB	NEXT
;	DB	'【%001】：早く着替えないと風邪ひくぜ。さ、行こう！'
	DB	"%001:  If we don't get you into some dry clothes soon,"
	DB	CR
	DB	"you'll catch a cold. Let's go!"
	DB	NEXT
;	DB	'【清美】：%001さん、わたくし・・・'
	DB	"Kiyomi:  %001, I.....I..."
	DB	NEXT
;	DB	'【%001】：ふが・・・ぶえっくしょい！！'
	DB	"%001:  *A- ACHOO*"
	DB	NEXT
;	DB	'【清美】：・・・そうですわね。急いで参りましょう。'
	DB	"Kiyomi:  ...You're right. We've got to get back. Let's hurry."
	DB	NEXT
;	DB	'俺達は薪を抱えて、早足でキャンプに戻った。'
	DB	"We picked up the firewood and headed back to camp."
	DB	NEXT
	DB SINARIO,'CS505.OVL',0
	DW	0000H


end
