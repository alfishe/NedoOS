;	さくらの季節
;		シーン　Ｅ＿Ｅ＿７
;		瑠璃フィニッシュ
	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5
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
CM4:	DW	VV4,	-1
CM5:	DW	VV5,	NN1,-1

;VV1:	DB	1,	'キス',0
VV1:	DB	1,	'KISS',0
;VV2:	DB	2,	'愛撫する',0
VV2:	DB	2,	'CARESS',0
;VV3:	DB	3,	'挿入する',0
VV3:	DB	3,	'ENTER',0
;VV4:	DB	4,	'動く',0
VV4:	DB	4,	'MOVE',0
;VV5:	DB	5,	'読む',0
VV5:	DB	5,	'READ',0

;NN1:	DB	1,	'手紙',0
NN1:	DB	1,	'LETTER',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2, M3, M4, M5		;キス
S2:		DW	VV2, -1,  2, M6, M7, M8		;愛撫する
S3:		DW	VV3, -1,  3, M9		;挿入する１
S4:		DW	VV4, -1,  4, M10		;動く
S5:		DW	VV5, NN1,  5, M11		;読む　手紙

;イニシャルメッセージ
M1:
	DB	BGM,13
;	DB	'瑠璃は、小刻みに震えていた。'
	DB	"Ruri was shaking."
	DB	NEXT
;	DB	'【瑠璃】：寒いの・・・早く、私を抱いて、暖めて・・・！'
	DB	"Ruri:  I'm cold. Please, hold me...make me warm..."
	DB	NEXT
;	DB	'【%001】：・・・ああ・・・！'
	DB	"%001:  ........Alright."
	DB C_BLD,C_V_ON,3
	DB C_BLD,C_V_ON,4
	DB C_BLD,C_V_ON,5
	DW	0000H

M2:		;キス
;	DB	'瑠璃の唇にキス。'
	DB	"I kiss her lips."
	DB	NEXT
;	DB	'【瑠璃】：んっ・・・'
	DB	"Ruri:  Mmm..."
	DB	NEXT
;	DB	'瑠璃は子猫の甘えるような声でないた。'
	DB	"Ruri make a sound like a kitten getting its head scratched."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;キス
;	DB	'瑠璃の顔に、キスの雨を降らせる。'
	DB	"I kiss Ruri's face all over."
	DB	NEXT
;	DB	'瑠璃も俺の鼻に、頬に、額に、唇を押し付けて来る。'
	DB	".....Her nose, her cheeks, her forehead, then her mouth"
	DB	CR
	DB	"again."
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;キス
;	DB	'瑠璃の胸の先端に軽いキス。'
	DB	"I kiss her nipples lightly."
	DB	NEXT
;	DB	'【瑠璃】：あ・・・'
	DB	"Ruri:  Ah....."
	DB	NEXT
;	DB	'瑠璃の腰がぴくんと跳ねる。'
	DB	"Ruri's body shivers all over, this time not from the cold."
	DB	FLG,F_COPYI,1,3
	DW	0000H

M5:		;キス
;	DB	'瑠璃の胸を、音を立てて吸う。'
	DB	"I suckle Ruri's breasts, making a sound."
	DB	NEXT
;	DB	'【瑠璃】：あ・・・ん'
	DB	"Ruri:  Ahhhhn....."
	DB	NEXT
;	DB	'瑠璃は目を閉じて、恍惚とした顔になる。'
	DB	"Ruri closes her eyes, her face betraying her pleasure."
	DB	FLG,F_COPYI,1,0
	EF_SET 101
	DW	0000H


M6:		;愛撫する
;	DB	'瑠璃の胸を、包み込むように揉みしだく。'
	DB	"I softly rub her breasts."
	DB	NEXT
;	DB	'（やわらかくて・・・手のひらに吸い付いて来るみたいだ・・・）'
	DB	"Her breasts are so soft....I've never felt anything like"
	DB	CR
	DB	"them."
	DB	NEXT
;	DB	'【瑠璃】：は・・・っ'
	DB	"Ruri:  .......Oh...."
	DB	NEXT
;	DB	'頬を上気させて、瑠璃は喘ぎを漏らす。'
	DB	"Ruri lets out a slow, excited sigh."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M7:		;愛撫する
;	DB	'外側から内側に向けて、瑠璃の太股を手のひらで撫でる。'
	DB	"Moving from outside to in, I caress her thighs."
	DB	NEXT
;	DB	'【瑠璃】：ふふ・・・くすぐったい・・・'
	DB	"Ruri:  .....That tickles."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M8:		;愛撫する
;	DB	'そっと瑠璃の秘処に手をやると、既に熱い雫が溢れていた。'
	DB	"I touch her pussy to find it already moist and yearning"
	DB	CR
	DB	"for me."
	DB	NEXT
;	DB	'【%001】：瑠璃、濡れやすいんだね・・・'
	DB	"%001:  You're really wet, Ruri..."
	DB	NEXT
;	DB	'【瑠璃】：そんなこと・・・わからない・・・'
	DB	"Ruri:  .....I can't help it..."
	EF_SET 102
	DW	0000H


M9:		;挿入する１
;	DB	'【%001】：瑠璃・・・行くよ・・・'
	DB	"%001:  Ruri, I'm coming in."
	DB	NEXT
;	DB	'瑠璃は目をつぶって頷いた。'
	DB	"Ruri just closed nodded to me."
	DB	NEXT
;	DB	'俺は慎重に、瑠璃の中に分け入っていく。固く閉じたそこは俺の侵入を拒み、締め出そうとする。'
	E_CG B_FADE,"AE_186"
	DB	"Slowly I slid inside her. Welcome heat flowed around me,"
	DB	CR
	DB	"covering my cock."
	DB	NEXT
;	DB	'【瑠璃】：・・・！'
	DB	"Ruri:  ....%001!"
	DB	NEXT
;	DB	'【%001】：瑠璃・・・力を抜いて・・・'
	DB	"%001:  Ruri.....I love you..."
	DB	NEXT
;	DB	'瑠璃が息を吸うタイミングに合わせて、俺はさらに奥へ入れる。'
	DB	"I pushed in further, and then I was all the way in her."
	DB	NEXT
;	DB	'【瑠璃】：いいの・・・%001君と、一つになれたから・・・。'
	DB	"Ruri:  I'm joined... I'm joined with %001..."
	DB	NEXT
;	DB	'【%001】：瑠璃・・・好きだ・・・'
	DB	"%001:  Ruri...I love you..."
	DB C_BLD,C_V_ON,3
	DB C_BLD,C_V_OFF,4	;動く
	DW	0000H


M10:		;動く
;	DB	'俺は瑠璃の髪を撫でながら、ゆっくりと出し入れを始めた。'
	DB	"Stroking her hair gently, I started to move."
	DB	NEXT
;	DB	'【瑠璃】：あっ、はぁっ・・・'
	DB	"Ruri:  Ahhhh....!"
	DB	NEXT
;	DB	'瑠璃の悲鳴に甘いものが混ざるにつれて、俺は動きを大きく、速くしていく。'
	DB	"Feeling her all around me, I increased my movements."
	DB	NEXT
;	DB	'瑠璃の中が俺に絡み付き、締め上げる。'
	DB	"My cock was fully erect, moving in and out of her faster"
	DB	CR
	DB	"and faster."
	DB	NEXT
;	DB	'やがて瑠璃の呼吸が浅く、速くなって来た。'
	DB	"Ruri's breath began to get faster, shallow, as she pushed"
	DB	CR
	DB	"against the headboard, matching my movements."
	DB	NEXT
;	DB	'【瑠璃】：・・・私の・・・体が・・・溶けていく感じ・・・'
	DB	"Ruri:  I feel...I feel like my body's...melting..."
	DB	NEXT
;	DB	'【瑠璃】：・・・%001君・・・私・・・どうなっちゃうの？'
	DB	"Ruri:  %001.... Oh, %001..."
	DB	NEXT
;	DB	'【%001】：そのまま・・・身を任せて・・・！'
	DB	"%001:  Ruri...! Ruri...!"
	DB	NEXT
;	DB	'【瑠璃】：・・・あ・・・・・・ぁ・・・'
	DB	"Ruri: ....Ahhh......Ahhhhhhn.....%001!"
	DB	NEXT
;	DB	'【%001】：瑠璃・・・！'
	DB	"%001:  Ruri!"
	DB	NEXT
;	DB	'かすれた悲鳴をあげて、瑠璃は力なくベッドに倒れ込んだ。'
	DB	"Letting out one final desperate gasp, she fell back"
	DB	CR
	DB	"against the bed."
	DB	NEXT
;	DB	'俺も、瑠璃に折り重なるように倒れた。'
	DB	"Myself spent, I allowed myself to come inside her, "
	DB	CR
	DB	"collapsing over her."
	DB	NEXT
	B_O B_FADE
;	DB	'・・・・・・・・・・・・・・・・・・'
	DB	"............................"
	DB	NEXT
	DB BGM,31
	E_CG B_FADE,"AB_20_1"	
;	DB	'【%001】：う・・・'
	DB	"%001:  Huh?"
	DB	NEXT
;	DB	'【%001】：ここは・・・？'
	DB	"%001:  Where am I...?"
	DB	NEXT
;	DB	'【%001】：そうだ、俺は白水さんを追いかけて来て・・・'
	DB	"%001:  Oh, I remember now. I chased after Ruri, and found"
	DB	CR
	DB	"her..."
	DB	NEXT
;	DB	'【%001】：白水さ・・・瑠璃は？'
	DB	"%001:  Where is she?"
	DB	NEXT
;	DB	'部屋の中を見回す。瑠璃の姿はなかった。'
	DB	"I looked around the room, but she wasn't here."
	DB	NEXT
;	DB	'【%001】：・・・・・・どこにいったんだ・・・？'
	DB	"%001:  Where did she go?"
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Mm?"
	DB	NEXT
;	DB	'俺は枕元に、手紙を見つけた。'
	DB	"I found a letter on the pillow next to me."
	DB C_BLD,C_V_ON,1
	DB C_BLD,C_V_ON,2
	DB C_BLD,C_V_ON,3
	DB C_BLD,C_V_ON,4
	DB C_BLD,C_V_OFF,5
	DW	0000H

M11:		;読む　手紙
;	DB	'二つ折りの手紙を開く。それは瑠璃の筆跡だった・・・たぶん。'
	DB	"I opened the letter. It was Ruri's writing...had to be."
	DB	NEXT
;	DB	'「お別れの挨拶もなしに出て行って、ごめんなさい。'
	DB	"'I'm sorry for leaving without saying goodbye."
	DB	NEXT
;	DB	'あなたを起こしてしまうと決心が鈍ってしまうので・・・'
	DB	"But if you wake up, then I won't be able to do what I've"
	DB	CR
	DB	"got to do."
	DB	NEXT
;	DB	'私は、お母様のところに帰ります。'
	DB	"I'm going home to mother."
	DB	NEXT
;	DB	'だけど、悲しまないで。私の心はいつもあなたと一緒だから。'
	DB	"Please don't be sad. I want you to know that you'll"
	DB	CR
	DB	"always be in my heart."
	DB	NEXT
;	DB	'またいつか、必ず会える日が来るから・・・'
	DB	"I know that we'll meet again, someday."
	DB	NEXT
;	DB	'あなたのことは決して忘れません。'
	DB	"I'll never forget you. I promise."
	DB	NEXT
;	DB	'　　　　　　　　　　　ありがとう'
	DB	"                              Thank you."
	DB	CR
;	DB	'　　　　　　　　　　　　　　　　　　　　　　白水　瑠璃」'
	DB	"                                  Ruri Shiromizu.'"
	DB	NEXT
;	DB	'【%001】：そんな・・・'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【%001】：そんなのって、ねーだろ・・・・・・！'
	DB	"%001:  You can't mean this....can you?"
	DB	NEXT
;	DB	'【%001】：・・・瑠璃！'
	DB	"%001:  Ruri!"
	DB	NEXT
	B_O B_WIPE
;	DB	'・・・こうして、白水　瑠璃は俺の前から姿を消した。'
	DB	"She was gone, gone far away from me, where I couldn't"
	DB	CR
	DB	"reach her this time."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・・・'
	DB	".................................."
	DB	NEXT
;	DB	'・・・俺が落ち込んでる間にも時は流れて行き・・・'
	DB	"Time passed. My misery didn't."
	DB	NEXT
;	DB	'そして・・・ふたたびさくらの季節が来た。'
	DB	"And then, the season of the sakura came again."
	DB	NEXT
;	DB	'【%001】：・・・・・・今年も、桜が満開か・・・'
	DB	"%001:  ........The sakura are in full bloom again."
	DB	NEXT
;	DB	'【%001】：俺達が初めて会った時も、桜が咲いてたっけ・・・'
	DB	"%001:  When I first met you, the sakura were in bloom..."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・・・・・・・瑠璃・・・'
	DB	"%001:  Ruri..."
	DB	NEXT
;	DB	'「・・・そうね」'
	DB	"Ruri:  Yes, they were."
	DB	NEXT
;	DB	'【%001】：！'
	DB	"%001:  !!"
	DB	NEXT
	DB	BGM,33
	DB ENDING,5
	DW	0000H

M_EXIT:
	DB FLG,F_AND,255,101,102
	DB FLG,F_EXIT,255
	DB	NEXT
;	DB	'（そろそろ、入れても大丈夫だと思う・・・）'
	DB	"She's ready for me. It's time."
	DB C_BLD,C_V_OFF,3	;入れる
	DW	0000H


end
