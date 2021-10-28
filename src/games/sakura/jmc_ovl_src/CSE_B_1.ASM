;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ｅ＿Ｂ＿１
;		清美キス

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	-1
MSGTBL:
	DW	M1
COMTBL:
	DW	-1
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ


;イニシャルメッセージ
M1:
	DB	BGM,13
	E_CG B_FADE,'AE_151'
;	DB	'目をつぶってやや上を向く新藤さん。'
	DB	"She closed her eyes and lifted her face up to mine."
	DB	NEXT
;	DB	'【%001】：・・・じゃ、行くよ・・・'
	DB	"%001:  ....Okay, I'm going to do it..."
	DB	NEXT
;	DB	'【清美】：はい・・・'
	DB	"Kiyomi:  Alright."
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"My heart was beating with nervousness."
	DB	NEXT
;	DB	'（ドキドキドキドキドキドキ・・・）'
	DB	"*DOKI DOKI DOKI DOKI DOKI*"
	DB	NEXT
;	DB	'俺の唇と新藤さんの唇が接近し・・・'
	DB	"My lips were near Kiyomi's now."
	DB	NEXT
;	DB	'（ドッドッドッドッドッドッ・・・）'
	DB	"*DOKI DOKI DOKI DOKI DOKI*"
	DB	NEXT
;	DB	'【%001】：・・・ごくっ・・・'
	DB	"%001:  ........*swallow*"
	DB	NEXT
;	DB	'（あ・・・あと１センチが・・・越えられん。）'
	DB	"Just one more centimeter to go...."
	DB	NEXT
;	DB	'【%001】：！'
	DB	"%001:  !!"
	DB	NEXT
;	DB	'新藤さんの手が俺の顔にのばされ、そして俺達の唇は重なり合った。'
	DB	"Suddenly, Kiyomi reached up with her hand and pulled my"
	DB	CR
	DB	"face to hers, pressing our lips together."
	DB	NEXT
	;清美の部屋
	;ゆでダコ清美
;	DB	'【清美】：・・・申し訳ありません。',CR,'その・・・１８時３分を回っていたので・・・'
	DB	"Kiyomi:  .....I'm sorry. It was 6:03..."
	DB	NEXT
;	DB	'【%001】：・・・・・・じゃあ、次に進もうか。'
	DB	"%001:  .....Okay, let's go to the next step."
	DB	NEXT
;	DB	'【清美】：えっ！？'
	DB	"Kiyomi:  The next step?"
	DB	NEXT
;	DB	'【%001】：次は・・・新藤さんが、ベッドに座る・・・と。'
	DB	"%001:  You go sit down on the bed."
	DB	NEXT
;	DB	'【清美】：あ、あの計画書は途中からただの妄想になってしまいましたので、破棄したものですのよ！'
	DB	"Kiyomi:  What? Oh, that schedule was just a sample I"
	DB	CR
	DB	"made up. It's nothing."
	DB	NEXT
;	DB	'【%001】：そう？俺はいい計画だと思ったけど。'
	DB	"%001:  Really? I thought it was a good schedule."
	DB	NEXT
;	DB	'【清美】：きゃ・・・！'
	DB	"Kiyomi:  What are you...!"
	DB	NEXT
;	DB	'言うが早いか、俺は新藤さんを抱え上げて、ベッドに座らせた。'
	DB	"Before she could do anything about it, I put my arms"
	DB	CR
	DB	"around her and sat her down on the bed."
	DB	NEXT
	DB	SINARIO,'CSE_B_2.OVL',0
	DW	0000H

end
