;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８０５
;		体育祭１日前　街

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


;イニシャルメッセージ
M1:
        DB	BGM,4
        BAK_INIT "AB_38_1"
        B_P1 B_SUDA
        ;	DB	'【%001】：ふっ・・・・・・うううううん・・・'
        DB	"%001:  *stretch*"
        DB	NEXT
        ;	DB	'背骨が軋む音を聞きながら大きくのびをして、時計に目をやる。'
        DB	"Listening to my spine snap as I stretch, I look at my"
        DB	CR
        DB	"watch."
        DB	NEXT
        ;	DB	'今日は体育祭の前日。さすがに今日は練習がない。つまり、今日は誰に気兼ねすることもなく爆睡できた、と言うわけだ。'
        DB	"The sports festival is tomorrow, so there's no practice"
        DB	CR
        DB	"today."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・も～２時かあ。中途半端だなあ・・・'
        DB	"%001:  .....I slept in til 2:00 pm today."
        DB	NEXT
        DB BUF,B_COPY01
        T_CG "CT10", 0,0,20,1
        ;	DB	'【英美】：おっはよ～、しゅうちゃん☆'
        DB	"Hidemi:  Hi, Shu-chan!!"
        DB	NEXT
        ;	DB	'【%001】：おわっ！'
        DB	"%001:  Wah!"
        DB	NEXT
        ;	DB	'ばふっ'
        DB	"*CRASH*"
        DB	NEXT
        ;	DB	'【英美】：ひっど～い、なんで避けちゃうのよう、しゅうちゃん！？'
        DB	"Hidemi:  That's terrible! Why did you avoid me like that?"
        DB	NEXT
        ;	DB	'【%001】：誰だって避けるわい！'
        DB	"%001:  Becuase you're my mother and I don't want to kiss"
        DB	CR
        DB	"you!"
        DB	NEXT
        ;	DB	'【英美】：もう、しゅうちゃんったら照れ屋さんなんだから☆'
        DB	"Hidemi:  Oh, you're such a shy boy."
        DB	PAUSE
        ;	DB	'あ、そうだ、英美、伸ちゃんのお手伝いしなきゃ。'
        DB	" Oh, I just remembered, I've"
        DB	CR
        DB	"got to help your father with something."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ........................"
        DB	NEXT
        ;	DB	'【英美】：じゃーねー、しゅうちゃん☆'
        DB	"Hidemi:  Bye, Shu-chan!"
        B_P1 B_SUDA
        DB	NEXT
        ;	DB	'【%001】：・・・なにしに来たんだろ。'
        DB	"%001:  ....I can't figure her out."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ..........................."
        DB	NEXT
        ;	DB	'【%001】：・・・わっかんねえなぁ・・・'
        DB	"%001:  Hmmm."
        DB	NEXT
        ;	DB	'【%001】：・・・ちょっと街ふらついてこよーっと。'
        DB	"%001:  .......I guess I'll go downtown for a while."
        DB	NEXT
        ;	DB	'・・・・・・・・・・・・・・・・・・・・・'
        DB	"........................................"
        DB	BGM,17
        E_CG B_SUDA,'AB_43_1'
        DB	NEXT
        ;	DB	'【%001】：さぁって、街に来たはいいけど、さて、どうしよっかな？'
        DB	"%001:  Well, where should I go, now?"
        DB	NEXT
        ;	DB	'【%001】：・・・ゼロワンデパート・・・には用はないよな・・・'
        DB	"%001:  .....Zero One Department Store? No, I don't have"
        DB	CR
        DB	"anything to do in there."
        DB	NEXT
        ;	DB	'【%001】：・・・中央公園・・・ってセンもあるよな・・・'
        DB	"%001:  The park? Nope."
        DB	NEXT
        ;	DB	'【%001】：・・・川辺・・・に行って、誠に撃たれたらどうする？'
        DB	"%001:  The river bank? Maybe Makoto is down there, doing"
        DB	CR
        DB	"survival training."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・やっぱり、バベルに行こう。'
        DB	"%001:  ....Guess I'll go to Babel."
        DB	NEXT
        DB	SINARIO,'CS806.OVL',0
        DW	0000H
        

end
