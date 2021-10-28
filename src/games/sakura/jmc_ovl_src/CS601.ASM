;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　６０１
;		教室　臨海学校一週間前

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5
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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	NN3,NN4,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	"LOOK",0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	"TALK",0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	"THINK",0

;NN1:	DB	1,	'誠',0
NN1:	DB	1,	"MAKOTO",0
;NN2:	DB	2,	'教室',0
NN2:	DB	2,	"CLASSROOM",0
;NN3:	DB	3,	'テスト',0
NN3:	DB	3,	"TEST",0
;NN4:	DB	4,	'臨海学校',0
NN4:	DB	4,	"SEASIDE CAMP",0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M2_A		;見る　誠
S2:		DW	VV1, NN2,  2, M3		;見る　教室
S3:		DW	VV2, -1,  3, M4, M5, M6, M7, M8, M9, M10, M11		;話す
S4:		DW	VV3, NN3,  4, M12		;考える　テスト
S5:		DW	VV3, NN4,  5, M13, M14, M15		;考える　臨海学校


;イニシャルメッセージ
M1:
	DB	BGM,6
	B_O B_SUDA
	BAK_INIT 'AB_36_4'
	B_P1 B_GURU3
;	DB	'・・・７月も終わりに近づいた頃。'
	DB	"....It was near the end of July."
	DB	NEXT
;	DB	'期末テストの最後の科目が帰って来て、俺達はその話題で盛り上がっていた。'
	DB	"The final tests for our last subjects were being given back..."
	DB	CR
	DB	"and the seaside camp was on all of our minds."
	DB C_BLD,C_N_ON,3,2
	DB	ERASE,E_GFLG,10,100,101,102,103,104,105,106,107,108,109	;巡回クリア
	DW	0000H

M2:		;見る　誠
;	DB	'なんか得意げに笑ってるな。'
	DB	"Boy, he sure is laughing pretty smugly."
	DB	NEXT
;	DB	'さっき数学のテストを「あ、しまった」とか言いながら実にわざとらしく取り落として。'
	DB	"When he got his math test he acted worried, and dropped it"
	DB	CR
	DB	"on the floor on purpose."
	DB	NEXT
;	DB	'拾った奴が「げ、こいつ１００点だ」とか言ったとたん、教室がどよめいた・・・'
	DB	"The guy who picked it up said, 'Makoto! You got an A!' and"
	DB	CR
	DB	"the whole class went nuts."
	DB	NEXT
;	DB	'俺ももちろん驚いた。'
	DB	"Of course, I was surprised too."
	DB	FLG,F_COPYI,1,1
	DW	0000H


M2_A:		;見る　誠
;	DB	'・・・結局、自慢できるものは数学だけらしい。'
	DB	"In the end, it seemed that all he had to boast about was"
	DB	CR
	DB	"his math."
;	DB	NEXT
;	DB	'ま、俺よりはマシなんだが。'
;	DB	"Well, he's better at it than me."
	DW	0000H

M3:		;見る　教室
;	DB	'俺の左隣に新藤さん、右隣は誠。後は中野、その左に吉田というのが今の席順だ。'
	DB	"To my left is Kiyomi, and Makoto is on my right. Behind"
	DB	CR
	DB	"me is Meimi, and to her left is Seia."
	DB	NEXT
;	DB	'ちなみに白水さんは、転入した時と同じ窓側最後尾のままだ。'
	DB	"Ruri is still in the same seat as when she transferred"
	DB	CR
	DB	"in, in the last row by the window."
	DW	0000H

M4:		;話す
	DB	BUF,B_COPY01
	T_CG 'CT14','S','K',33,1
;	DB	'【誠】：%001、期末どうだった？'
	DB	"Makoto:  So how did your finals go, %001?"
	DB	NEXT
;	DB	'【%001】：俺に聞かんでくれ。'
	DB	"%001:  Don't ask."
	DB	NEXT
	T_CG1 'CT08','S',0,0,2
	DB	ANI,A_ON,1
;	DB	'【恵依美】：そーゆー誠はどうなの？'
	DB	"Meimi:  How about you, Makoto?"
	DB	NEXT
;	DB	'【誠】：フッ、まあまあってとこかな。'
	DB	"Makoto:  Well, could have been better, I guess."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M5:		;話す
	DB	ANI,A_INIT
	DB	BUF,B_COPY01
	TU_CG 'CT14','S','K',33,1
	T_CG 'CT02','S','K',10,2
	DB	ANI,A_ON,1
;	DB	'【清美】：誠さん、数Ｉは１００点満点でしたわね。'
	DB	"Kiyomi:  But you got an A on your math test, didn't you?"
	DB	NEXT
;	DB	'【誠】：あっれぇ～、知ってたぁ？ナハハハハ・・・'
	DB	"Makoto:  Oh, how did you know? Ha, hahaha."
	DB	NEXT
;	DB	'【%001】：あれだけ騒げば誰でもわかるっての。'
	DB	"%001:  I think everybody knows that by now."
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT14','S','K',33,1
	T_CG 'CT07','S',0,20,3
	DB	ANI,A_ON,1
;	DB	'【星愛】：そのかわり、現国は１２点、英語Ｉは２６点でしたわよね？誠君。'
	DB	"Seia:  On the other hand, you got a D in Modern Japanese,"
	DB	CR
	DB	"and an F in English, didn't you Makoto?"
	DB	NEXT
;	DB	'【誠】：ナハハ・・・'
	DB	"Makoto:  Hahaha..."
	DB	NEXT
	K_CG 'CT14','I',33,4
	DB	ANI,A_ON,3
;	DB	'【誠】：・・・何で吉田が知ってんだよぉ！？隠蔽工作は完璧だったはずなのにぃ！'
	DB	"Makoto:  How do you know that, Seia? I was careful not to let"
	DB	CR
	DB	"anyone see!"
	DB	NEXT
	K_CG 'CT07','K',20,5
	DB	ANI,A_ON,4
;	DB	'【星愛】：わたくし、クラス委員ですもの。'
	DB	"Seia:  That's because I'm class chairman."
	DB	FLG,F_COPYI,3,2
	DW	0000H

M6:		;話す
	T_CG1 'CT14','S',0,33,6
	DB	ANI,A_ON,5
;	DB	'【誠】：・・・で、吉田はどーだったんだよ。'
	DB	"Makoto:  So, how did you do, Seia?"
	DB	NEXT
;	DB	'【星愛】：主の御加護、と申しておきましょう。'
	DB	"Seia:  By the grace of God..."
	DB	NEXT
	DB	ANI,A_INIT
	DB	BUF,B_COPY01
	TU_CG 'CT14','S',0,33,1
	T_CG 'CT08','S',0,0,2
	DB	ANI,A_ON,1
;	DB	'【恵依美】：星愛は５科目合計４８０点よ！すごいでしょ！'
	DB	"Meimi:  Seia got straight A's!"
	DB	NEXT
;	DB	'【%001】：中野が威張ってどーすんの。'
	DB	"%001:  That's great."
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT02','S','K',10,3
;	DB	'【清美】：さすがですわね。わたくしは４７２点でしたわ。'
	DB	"Kiyomi:  That's to be expected. I was off in my studies this",CR,"month."
	DB	NEXT
;	DB	'【清美】：でも星愛さん、今回の生物は「進化」の単元が問題でしたわよね。クリスチャンの方々は、ダーウィニズムは否定なさってるのではありませんでしたか？'
	DB	"Kiyomi:  But Seia, the biology unit on evolution was a"
	DB	CR
	DB	"problem, wasn't it? Doesn't Darwinism go against the"
	DB	CR
	DB	"Christian teachings?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT07','S','K',20,4
;	DB	'【星愛】：「それはそれ、これはこれ」と主もおっしゃっておられますわ。'
	DB	"Seia:  Well, the Bible says, 'Give to Caeser what is"
	DB	CR
	DB	"Caeser's, and give to God what is God's.'"
	DB	NEXT
;	DB	'一同：「言ってない言ってない」'
	DB	"Kiyomi:  ...Oh."
	DB	FLG,F_COPYI,3,3
	DW	0000H

M7:		;話す
;	DB	'【誠】：どうやら吉田がクラスでトップみたいだな。'
	DB	"Makoto:  Well, it looks like Seia's moved to the top of"
	DB	CR
	DB	"the class."
	DB	NEXT
;	DB	'【星愛】：全ては主の御心のままに・・・。'
	DB	"Seia:  Everything is God's will......"
	DB	NEXT
;	DB	'【%001】：俺も神様信じたら、成績上がるのか？'
	DB	"%001:  So if I believe in God too, my grades will go up?"
	DB	NEXT
;	DB	'【星愛】：ですから、「それはそれ、これはこれ」ですわ。'
	DB	"Seia:  I don't know about that...."
	DB	FLG,F_COPYI,3,4
	DW	0000H

M8:		;話す
;	DB	'【誠】：で、今回も%001と中野でビリ争いか。'
	DB	"Makoto:  Well, I guess the fight for the lowest grade is on"
	DB	CR
	DB	"%001 and Meimi."
	DB	NEXT
	DB	ANI,A_INIT
	DB	BUF,B_COPY01
	T_CG 'CT08','S',0,0,1
;	DB	'【恵依美】：ふ、ふ～んだ！あたしはママみたいなサーカスの花形スターになるんだから、学校の成績なんてカンケーないもん！'
	DB	"Meimi:  I don't care about grades, I'm going to be a circus"
	DB	CR
	DB	"star like my Mom!"
	DB	NEXT
;	DB	'【恵依美】：要は赤点さえとらなきゃい～のよ。ね、%001。'
	DB	"Meimi:  It doesn't matter even if we get negative points,"
	DB	CR
	DB	"right, %001?"
	DB	NEXT
;	DB	'【%001】：そーそー。人生何とかなるもんさ。'
	DB	"%001:  That's right. We'll make something of our lives"
	DB	CR
	DB	"somehow."
	DB	FLG,F_COPYI,3,5
	DW	0000H

M9:		;話す
	DB	ANI,A_INIT
	DB	BUF,B_COPY01
	TU_CG 'CT03','S','K',8,1
	T_CG 'CT01','S','K',33,2
	DB	ANI,A_ON,1
;	DB	'【鈴子】：%001く～ん。'
	DB	"Reiko:  %001!"
	DB	CR
;	DB	'【美緒】：せんぱ～い！'
	DB	"Mio:  %001!"
	DB	NEXT
;	DB	'鈴子さんと美緒ちゃんが入って来た。'
	DB	"Reiko and Mio came in the room."
	DB	NEXT
;	DB	'【鈴子】：何話してたの？臨海学校の話？'
	DB	"Reiko:  What are you talking about? Seaside school?"
	DB	NEXT
;	DB	'【%001】：いや・・・テストの話だけど・・・'
	DB	"%001:  No...we were talking about the tests..."
	DB	NEXT
;	DB	'【恵依美】：そ～よ、テストの話なんてやめて臨海学校の話しようよ！'
	DB	"Meimi:  Well, let's stop talking about tests and talk"
	DB	CR
	DB	"about the sea."
	DB	FLG,F_COPYI,3,6
	DB C_BLD,C_N_OFF,3,2
	DW	0000H

M10:		;話す
;	DB	'【%001】：・・・俺、臨海学校休むよーな気がする。',CR,'毎年あの時期って夏風邪ひくんだ、俺。'
	DB	"%001:  ...I think I'll be absent seaside camp. I always"
	DB	CR
	DB	"seem to get a cold that time of the summer."
	DB	NEXT
;	DB	'【鈴子】：泳げないからって、ずる休みは良くないわよ。'
	DB	"Reiko:  You mean you don't want to go because you can't"
	DB	CR
	DB	"swim."
	DB	NEXT
;	DB	'（・・・釘を刺されてしまった・・・）'
	DB	"...Ouch, that hurt!"
	DB	FLG,F_COPYI,3,7
	DW	0000H


M11:		;話す
;	DB	'【恵依美】：しっかし、%001が泳げないなんてね～。'
	DB	"Meimi:  What's this about %001 not being able to swim?"
	DB	NEXT
;	DB	'【誠】：ま、人間誰しも弱点の一つや二つはあるって事だろ。'
	DB	"Makoto:  Well, everybody has one or two weak points."
	DB	NEXT
;	DB	'【鈴子】：大丈夫よ、%001君。この臨海学校で私が泳げるようにしてあげるから。'
	DB	"Reiko:  It's alright, %001. I'll teach you how to swim"
	DB	CR
	DB	"this year."
	DB	NEXT
;	DB	'【%001】：ホント？'
	DB	"%001:  .....Really?"
	DB	NEXT
;	DB	'【鈴子】：まかせて！'
	DB	"Reiko:  Leave it to me!"
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・'
	DB	"....................................."
	B_O B_NORM
	E_CG B_WIPE,'T_06'
	DB	NEXT
	DB SINARIO,'CS602.OVL',0
	DW	0000H

M12:		;考える　テスト
;	DB	'（何しろロクに勉強なんかしねーから、俺のテストはいつだって赤点ぎりぎり。）'
	DB	"I don't study at all anyway, so my grades really suck."
	DW	0000H

M13:		;考える　臨海学校
;	DB	'（もうすぐ夏休みなんだけど、うちの学校は毎年、８月の第一週に全校生徒＆教職員参加の臨海学校を行うらしい。）'
	DB	"It's almost summer vacation, but it seems that the whole"
	DB	CR
	DB	"school, as well as some faculty members, go on a seaside"
	DB	CR
	DB	"camp for the first week of August every year."
	DB	NEXT
;	DB	'（・・・何も全校生徒で行かなくたって・・・。）'
	DB	"...It's odd that all the students in the school are"
	DB	CR
	DB	"going..."
	DB	FLG,F_COPYI,5,1
	DW	0000H

M14:		;考える　臨海学校
;	DB	'（この前全校生徒で林間学校に行って、今度は全校生徒で臨海学校か。）'
	DB	"We all went camping in the woods, and I guess we're all"
	DB	CR
	DB	"going to go to the seaside."
	DB	FLG,F_COPYI,5,2
	DW	0000H

M15:		;考える　臨海学校
;	DB	'（泳げねー俺にとってはユーウツな行事だ。）'
	DB	"It sucks for me, since I can't swim."
	DW	0000H


end
