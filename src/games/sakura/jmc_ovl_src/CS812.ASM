;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８１２
;		体育祭表彰式後

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
CM2:	DW	VV2,	-1

;VV1:	DB	1,	'話す',0
VV1:	DB	1,	'TALK',0
;VV2:	DB	2,	'考える',0
VV2:	DB	2,	'THINK',0

;NN1:	DB	1,	'今日子',0
NN1:	DB	1,	'KYOKO',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;話す　今日子
S2:		DW	VV2, -1,  2, M3, M4		;考える


;イニシャルメッセージ
M1:
        DB	BGM,3
        ;	DB	'・・・翌日。'
        DB	"...............The next day."
        DB	NEXT
        ;	BAK_INIT 
        ;	T_CG "CT12","C",0,0
        B_O B_FADE
        E_CG B_FADE,'AE_044'
        ;	DB	'【今日子】：・・・あら、も～こんな時間かぁ。'
        DB	"Kyoko:  Oh, we're running behind schedule!"
        DB	PAUSE
        ;	DB	'んじゃあ今日は、そろそろお開きにしましょ～かね～。'
        DB	" Okay, everyone,"
        DB	CR
        DB	"let's get started."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  .................................................."
        DB	NEXT
        ;	DB	'【%001】：先生、とうとう肝臓でもイカレたんですか？'
        DB	"%001:  Sensei, has your liver finally given out on you or"
        DB	CR
        DB	"something?"
        DB	NEXT
        ;	DB	'【今日子】：・・・どーしてそ～なるのよぉ？'
        DB	"Kyoko:  Why do you say that?"
        DB	NEXT
        ;	DB	'【%001】：だって、まだ６時ですよ？'
        DB	"%001:  It's still six o'clock."
        DB	PAUSE
        ;	DB	'いつもだったら、８時くらいまでやるじゃないですか。'
        DB	" Why are we starting so early?"
        DB	NEXT
        ;	DB	'【今日子】：・・・ふふん、今日はこの後にも控えてるのよん。'
        DB	"Kyoko:  Oh, but there's another party scheduled for later"
        DB	CR
        DB	"tonight."
        DB	NEXT
        ;	DB	'【%001】：あ、そーなんですか。'
        DB	"%001:  Oh, I see..."
        DW	0000H
        
M2:		;話す　今日子
        ;	DB	'【今日子】：・・・な～に言ってんの。この後は、%001君が主役でしょ？'
        DB	"Kyoko:  What are you saying? You're the guest of honor tonight." 
        DB	NEXT
        ;;	DB	%001:  '【%001】：・・・・・・',PAUSE,'はい？'
        DB	"%001:  ......",PAUSE,"What did you say?"
        DB	NEXT
        ;	DB	'【今日子】：ま～たまたトボけちゃってぇ～。'
        DB	"Kyoko:  Did you forget?"
        DB	PAUSE
        ;	DB	'君が最優秀個人賞取ったのよ？そのお祝いしなくっちゃ。'
        DB	" You got the M.V.P. award, so we're"
        DB	CR
        DB	"going to have a party in your honor."
        DB	NEXT
        ;	DB	'【%001】：・・・今やってるじゃないですか。'
        DB	"%001:  Isn't that what this is now?"
        DB	NEXT
        ;	DB	'【今日子】：これはぁ、『Ａ組準優勝おめでとう＆最大の功労者%001君を賛える』'
        DB	"Kyoko:  No, this is the party because A class won second"
        DB	CR
        DB	"place in the whole school. The party after this will be"
        DB	CR
        DB	"for you."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  And where will this party be held?"
        DB	NEXT
        ;	DB	'【今日子】：私の部屋で飲み会。'
        DB	"Kyoko:  At my place."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・今やってるのと、何が違うんですか？'
        DB	"%001:  ....So how is it different from what we're doing"
        DB	CR
        DB	"now?"
        DB	NEXT
        ;	DB	'【今日子】：場所と口実。'
        DB	"Kyoko:  The place and the excuse we're using to drink are"
        DB	CR
        DB	"different."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・・・・・・・・'
        DB	"%001:  ...................................................."
        DB	NEXT
        ;	DB	'【今日子】：だぁ～いじょ～ぶ。ちゃ～んとあの娘達も呼んであるから。'
        DB	"Kyoko:  Don't worry! There'll be lots of women there!"
        DB	NEXT
        ;	DB	'【%001】：・・・あの娘達って？'
        DB	"%001:  Women? What women?"
        DB	NEXT
        ;	DB	'【今日子】：まぁ～たまたまたトボけちゃってぇこのこのこのぉ！'
        DB	"Kyoko:  What women, he asks! You know, all those women"
        DB	CR
        DB	"you're in love with!"
        DB	NEXT
        B_O B_YOKO
        ;	DB	'ぐりぐりぐりぐり。'
        DB	"Suddenly she grabs me and puts me in a headlock."
        DB	NEXT
        ;	DB	'【%001】：・・・わたっ!ちょ・・・ちょっとせんせえ！'
        DB	"%001:  Okay, okay! Let go of me, Sensei!"
        DB	NEXT
        ;	DB	'【今日子】：さ～、行くわよ！'
        DB	"Kyoko:  Let's go."
        DB	NEXT
        ;	DB	'【%001】：・・・わ、わかった！わかりましたから離して・・・！'
        DB	"%001:  Okay, just let go of me!"
        DB	NEXT
        ;	DB	'だが今日子先生は俺の嘆願などおかまいなしに、ヘッドロックを掛けたまま先生の家まで引きずって行った・・・・・・'
        DB	"She refused to let go of me, though, so we walked to her "
        DB	CR
        DB	"house with me in a headlock."
        DB	NEXT
        DB	SINARIO,'CS813.OVL',0
        DW	0000H
        
M3:		;考える
        ;	DB	'なぁるほど、珍しく早めに切り上げたのは、そー言うことか。'
        DB	"Oh, so that's why she ended the first party so early."
        DB	NEXT
        ;	DB	'・・・待てよ・・・ってことは、今夜一晩飲み明かす気か！？'
        DB	".........Wait a minute! Are we all supposed to sleep at"
        DB	CR
        DB	"her house?"
        DB	NEXT
        ;	DB	'【%001】：やっ、やめましょう、先生！'
        DB	"%001:  Let's rethink this, Sensei!"
        DB	NEXT
        ;	DB	'【今日子】：・・・却下！つべこべ言わずにこ～い！'
        DB	"Kyoko:  Silence! That's an order from your educator!"
        DB	FLG,F_COPYI,2,1
        DW	0000H
        
M4:		;考える
        ;	DB	'俺は、あんまり酒は強くない。'
        DB	"To be honest, I can't hold my liquor very well."
        DB	NEXT
        ;	DB	'・・・はっきり言って、先生に付き合って一晩飲める自信はないぞ。'
        DB	"I'm not sure I can keep up with Sensei drinking all night."
        DW	0000H


end
