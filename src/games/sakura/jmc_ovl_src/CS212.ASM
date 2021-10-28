;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　２１２
;		祥子の色仕掛け

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3
MSGTBL:
	DW	M1
COMTBL:
	DW	CM1, CM2, CM3
VNTBL:
	DW	V_FNAME,N_FNAME
ENDTBL:

	INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
	INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	"見る",0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	"話す",0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	"考える",0
VV3:	DB	3,	"THINK",0

;NN1:	DB	1,	"女の子",0
NN1:	DB	1,	"WOMAN",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3, M4		;見る　女の子３
S2:		DW	VV2, NN1,  2, M5, M6, M7, M8, M9, M10		;話す　女の子６
S3:		DW	VV3, NN1,  3, M11, M12, M13		;考える　女の子３


;イニシャルメッセージ
M1:
	DB	ERASE,E_VRAM0,B_WIPE					;ブラックアウト
	DB	BGM,30
	BAK_INIT "AB_26"
	B_P1 B_SUDA
;	DB	"【%001】：・・・ここは・・・？"
	DB	"%001:  Where is this?"
	DB	NEXT
;	DB	"【？】：体育準備室。"
	DB	"???:  The gymnastics training room."
	DB	NEXT
;	DB	"【%001】：ふ～ん・・・・・・"
	DB	"%001:  It is...?"
	E_CG B_NORM,"AE_005"
;	DB	"って、どわぁあぁぁぁっ！？"
	DB	" So, what are...Whah!?"
	DW	0000H

M2:		;見る　女の子１
;	DB	"制服の上衣をはだけ、俺の上衣もはだけさせようとしている。"
	DB	"She took off her top and was working on getting my shirt"
	DB	CR
	DB	"off."
	DB	NEXT
;	DB	"・・・・・・何てれ～せ～に観察している場合か！？何なんだこの娘はっ！？"
	DB	"Who the hell is this woman?"
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　女の子２
;	DB	"年の頃は、俺と同じくらい。"
	DB	"She seemed to be about my age."
	DB	NEXT
;	DB	"胸は・・・結構あるのかな？じっくり見比べた事無いから、良く解んないが。"
	DB	"Her breasts are huge. I've never really seen anything"
	DB	CR
	DB	"like them before."
	DB	NEXT
;	DB	"・・・どこを見てるんだ俺は！？そんな場合じゃね～ぞっ！？"
	DB	"...I shouldn't be thinking of her that way!"
	DB	FLG,F_COPYI,1,2
	DW	0000H

M4:		;見る　女の子３
;	DB	"青い柄のブラジャーをしている。"
	DB	"She's wearing a blue, patterned bra."
	DB	NEXT
;	DB	"こーゆー奴もあるんだな。テレビじゃあ白いのしか宣伝しないから、"
	DB	"So they make them like this too. They only advertise the"
	DB	CR
	DB	"white ones on TV. ",NEXT
;	DB	"色付きのなんて無いと思ってた。"
	DB	"I didn't think they made colored ones."
	DB	NEXT
;	DB	"・・・・・・・・・"
	DB	"................................................."
	DB	NEXT
;	DB	"どーして俺って奴は非常時になればなるほど、よけ～な事に頭が回るんだ？"
	DB	"Why do I think of the strangest things when in a situation"
	DB	CR
	DB	"like this?"
	DB	FLG,F_COPYI,102,1
	DW	0000H

M5:		;話す　女の子１
;	DB	"【%001】：な、な、な、な、な、な、な、な、",CR
	DB	"%001:  Wha, wha, what..."
	DB	NEXT
;	DB	"【？】：んふふふふ・・・・・・"
	DB	"???:  You're so cute."
	DB	FLG,F_COPYI,2,1
	DW	0000H

M6:		;話す　女の子２
;	DB	"【%001】：ち、ち、ち、ち、ち、ち、ち、ち、",CR
	DB	"%001:  Ho, ho, hold on... Stop!",NEXT
;	DB	"【？】：・・・やっぱりぃ、思った通りだわぁ・・・"
	DB	"???:  Just as I thought. You're a virgin."
	DB	FLG,F_COPYI,2,2
	DW	0000H

M7:		;話す　女の子３
;	DB	"【%001】：あ、あ、あ、あ、あ、あ、あ、あ、",CR
	DB	"%001:  Uh, uh, uh...",NEXT
;	DB	"【？】：この引き締まった胸板・・・もぅん、うずうずしちゃぅん！"
	DB	"???:  You're such a strong man. It makes me so excited!"
	DB	FLG,F_COPYI,2,3
	DW	0000H

M8:		;話す　女の子４
;	DB	"【%001】：い、い、い、い、い、い、い、い、",CR
	DB	"%001:  Ya, ya, ya, ya...",NEXT
;	DB	"【？】：ん～、腕もすっご～くス・テ・キ。"
	DB	"???:  Look these these arms of yours. Wonderful!"
	DB	FLG,F_COPYI,2,4
	DW	0000H

M9:		;話す　女の子５
;	DB	"【%001】：ど、ど、ど、ど、ど、ど、ど、ど、",CR
	DB	"%001:  Eh, ah, um...",NEXT
;	DB	"【？】：この太股・・・贅肉なんてナッシングゥ。"
	DB	"???:  And these leg muscles. So perfect."
;	DB	NEXT
;	DB	"さわわっ。"
;	DB	"Whoah."
;	DB	NEXT
;	DB	"【%001】：う・・・うわわわわわわわわわっ！？"
;	DB	"%001:  Eyaaaa."
	DB	FLG,F_COPYI,255,1
	DB	FLG,F_MAND,3,255,102,103
	DB	FLG,F_EXIT,255
	DB	FLG,F_COPYI,2,5
	DW	0000H

M10:		;話す　女の子６
;	DB	"【%001】：・・・ちょっとちょっとちょっとちょっとぉっ！？",CR
	DB	"%001:  ....Ho, ho, ho, hold on!!",NEXT
;	DB	"【？】：んふ・・・何から何まで、あたしにぴったんこぉ！"
	DB	"???:  It's all just the way I like it!"
	DB	NEXT
;	DB	"【？】：さ、しゅ～君・・・"
	DB	"???:  Oh my Shu-kun..."
	DB	NEXT
;	DB	"さわわわわっ。"
	DB	"Whaaa."
	DB	NEXT
;	DB	"【%001】：・・・わーっ！ちょっとまてぇーっ！？"
	DB	"%001:  ...Hey, hold on!!"
	DB	NEXT
;	DB	"【？】：んふふふふ・・・だぁめ。"
;	DB	"???:  Not on your life."
;	DB	NEXT
;	DB	"【？】：ま・",PAUSE,"て・",PAUSE,"な・",PAUSE,"い☆"
	DB	"Reiko:  Hold ",PAUSE,"it ",PAUSE,"right ",PAUSE,"there!!!!"
	DB	NEXT
;	DB	"【%001】：わわわわわわ、わーーーーーーっ！"
	DB	"%001:  Whaaaaaaaa!!!!!"
	DB	NEXT
;	DB	"【？？？】：「待ちなさいっ！！」"
	DB	"Reiko:  We said STOP!!"
	DB	NEXT
	DB	SINARIO,"CS213.OVL",0
	DW	0000H

M11:		;考える　女の子１
;	DB	"一体全体何なんだっ！？"
	DB	"Who in the hell is this woman?"
	DB	FLG,F_COPYI,3,1
	DW	0000H

M12:		;考える　女の子２
;	DB	"何で俺をこんな所に連れて来たんだ！？"
	DB	"Why did she take me here?"
	DB	PAUSE,CR
;	DB	"これから何をしようと言うんだ！？"
	DB	"What does she want to do?"
	DB	PAUSE,CR
;	DB	"そもそも、あんた一体誰だ！？"
	DB	"Well, that seems pretty clear, actually."
	DB	NEXT
;	DB	"・・・・・・"
	DB	"..................................."
	DB	NEXT
;	DB	"いや・・・言えばいいのは分ってるんだけどね。"
	DB	"I should say something."
	DB	NEXT
;	DB	"・・・・・・"
	DB	"....................................."
	DB	NEXT
;	DB	"目の前に・・・・・・あーゆーものがあると・・・・・・ちょっとその・・・・・・"
	DB	"But when there is.....something like that...right in front"
	DB	CR
	DB	"of your face..."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M13:		;考える　女の子３
;	DB	"こ・・・コレはやっぱり、世に聞く"
	DB	"I think she wants to have sex."
	DB	FLG,F_COPYI,103,1
	DW	0000H


end
