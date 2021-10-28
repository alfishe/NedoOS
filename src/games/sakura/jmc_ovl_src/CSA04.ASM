;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ａ０４
;		温泉旅行の勧め

                INCLUDE	SUPER_S.INC

START:
                DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
                DW	S1, S2, S3, S4
MSGTBL:
                DW	M1
COMTBL:
                DW	CM1, CM2, CM3, CM4
VNTBL:
                DW	V_FNAME,N_FNAME
ENDTBL:

                INCLUDE	"V_NAME00.INC"			; 0=NoCommand , 1-49=NormalCommand
                INCLUDE	"N_NAME00.INC"			; 50-99=HseenCommand

;	　　　 動詞　　名詞群
CM1:	DW	VV1,	NN1,-1
CM2:	DW	VV2,	NN2,-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	NN3,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'考える',0
VV2:	DB	2,	'THINK',0
;VV3:	DB	3,	'のんびりする',0
VV3:	DB	3,	'RELAX',0
;VV4:	DB	4,	'食べる',0
VV4:	DB	4,	'EAT',0

;NN1:	DB	1,	'テレビ',0
NN1:	DB	1,	'TELEVISION',0
;NN2:	DB	2,	'正月',0
NN2:	DB	2,	'NEW YEARS DAY',0
;NN3:	DB	3,	'ミカン',0
NN3:	DB	3,	'MIKAN',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　テレビ
S2:		DW	VV2, NN2,  2, M4		;考える　正月
S3:		DW	VV3, -1,  3, M5, M6, M7		;のんびりする３
S4:		DW	VV4, NN3,  4, M8, M9, M10		;食べる　ミカン


;イニシャルメッセージ
M1:
        DB	BGM,26
        BAK_INIT 'AB_01_2'
        DB	BUF,B_COPY01
        DB	"Ah, New Year's Day in Japan."
        DB	NEXT
        DB	"New Year's Day is the most important of Japanese holidays."
        DB	CR
        DB	"We go to shinto shrines and pray for good luck in the new"
        DB	CR
        DB	"year, and spend time with our family."
        DB	NEXT
        DB	"Most Japanese do what I am doing now, which is sit at the"
        DB	CR
        DB	"kotatsu (a short table with a heater under it), watch TV,"
        DB	CR
        DB	"and eat mikan oranges."
        DB	NEXT
        DB	"Mikans are small oranges that come into season in Japan in"
        DB	CR
        DB	"the winter. They go with winter as much as Santa Claus does"
        DB	CR
        DB	"in America."
        DB	NEXT
        ;	DB	'【%001】：しかし・・・正月ってロクな番組やってねーよな・・・'
        DB	"%001:  I hate the TV shows they put on on New Year's"
        DB	CR
        DB	"Eve..."
        B_P1 B_SUDA
        DB	NEXT
        ;	DB	'俺はこたつに潜り込んでボーッとテレビを見てた。'
        DB	"I had my feet in the kotatsu. I felt toasty."
        DB	NEXT
        T_CG 'CT09',0,0,20,1
        ;	DB	'【伸幸】：%001、「どきっ☆女だらけの宇宙遊泳大会」に変えていいか？'
        DB	"Nobuyuki:  Do you mind of I change the channel? There's"
        DB	CR
        DB	"a show called The Great Beauty Contest in Space."
        DB	NEXT
        ;	DB	'【%001】：・・・好きにしてよ。'
        DB	"%001:  .....Sure."
        DB	NEXT
        T_CG1 'CT10',0,0,5,2
        DB	ANI,A_ON,1
        ;	DB	'【英美】：しゅうちゃ～ん、おミカンむいてあげようか？'
        DB	"Hidemi:  Shu-chan? Shall I peel some mikan for you?"
        DB	NEXT
        ;	DB	'【%001】：・・・ミカンくらい一人でむけるよ・・・'
        DB	"%001:  I can peel them myself!"
        DW	0000H
        
M2:		;見る　テレビ
        ;	DB	'父さんは「どきっ☆女だらけの宇宙遊泳大会」にチャンネルを合わせた。'
        DB	"Dad has changed the channel to The Great Beauty Contest"
        DB	CR
        DB	"in Space."
        DB	NEXT
        ;	DB	'画面には月をバックに宇宙遊泳する女の子たちが映っていた。'
        DB	"As expected, there were a lot of beautiful women. One"
        DB	CR
        DB	"was floating in zero gravity."
        DB	NEXT
        ;	DB	'・・・多分、女の子だと思う。が、こんなごつい宇宙服を着込んでちゃあ分からないし楽しくもない。'
        DB	"There goes one in a spacesuit. Somehow the effect is lost."
        DB	NEXT
        ;	DB	'【伸幸】：・・・なんだこりゃ・・・'
        DB	"Nobuyuki:  What the heck is this show?"
        DB	NEXT
        ;	DB	'【%001】：・・・きったねぇ・・・詐欺だよな・・・'
        DB	"%001:  I know. Look at that one woman. She's wearing a"
        DB	CR
        DB	"spacesuit. You can't see her tits or anything."
        DB	NEXT
        ;	DB	'【伸幸】：んん？%001、今なんて言った？'
        DB	"Nobuyuki:  What did you say, %001?"
        DB	NEXT
        ;	DB	'【%001】：ち、違うよ！俺は・・・'
        DB	"%001:  ...Mm? I just said..."
        DB	NEXT
        ;	DB	'【伸幸】：そーかそーか、いつのまにかお前も女の子に目覚めてたんだな！'
        DB	"Nobuyuki:  I see. So you've finally gotten interested in"
        DB	CR
        DB	"women, have you?"
        DB	NEXT
        ;	DB	'【%001】：違うってば！'
        DB	"%001:  .............Well, of course."
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
M3:		;見る　テレビ
        ;	DB	'（宇宙服の女の子なんか見てても楽しくないし、親父にからかわれるのもやだ。）'
        DB	"I'm not enjoying this stupid show."
        EF_SET 102
        DW	0000H
        
M4:		;考える　正月
        ;	DB	'（しかし・・・正月ってホントにすぐ飽きるな・・・）'
        DB	"This sucks."
        DB	NEXT
        ;	DB	'（せっかくの休みに家でごろごろごろごろ・・・）'
        DB	"I can't believe I don't have anything more interesting "
        DB	CR
        DB	"to do than stay home with my parents."
        DB	NEXT
        ;	DB	'（吉田と中野はスキーに行くとか言ってたよな～・・・）'
        DB	"Seia and Meimi said they were going skiing."
        DB	NEXT
        ;	DB	'（・・・白水さんはどっか行くのかな～・・・）'
        DB	"Ruri's going...somewhere."
        EF_SET 104
        DW	0000H
        
M5:		;のんびりする
        ;	DB	'ぼぉぉぉぉぉぉ・・・'
        DB	"*Yawn!!*"
        DB	NEXT
        ;	DB	'（・・・正月だなぁ・・・）'
        DB	"Ah, I do love New Year's Day.."
        DB	FLG,F_COPYI,3,1
        DW	0000H
        
M6:		;のんびりする２
        ;	DB	'んぼぉぉぉぉぉぉ・・・'
        DB	"*stretch*"
        DB	NEXT
        ;	DB	'（・・・正月だ・・・）'
        DB	"Ah, it's New Year's Day."
        DB	FLG,F_COPYI,3,2
        DW	0000H
        
M7:		;のんびりする３
        ;	DB	'ぬぼぉぉぉぉぉぉ・・・'
        DB	"Ahhhh....."
        DB	NEXT
        ;	DB	'（・・・正月・・・）'
        DB	"New Year's Day."
        EF_SET 101
        DB	FLG,F_COPYI,3,0
        DW	0000H
        
M8:		;食べる　ミカン
        ;	DB	'（・・・ミカンでも食おーっと。）'
        DB	"I guess I'll have a mikan."
        DB	NEXT
        ;	DB	'俺はテーブルの上のミカンに手を伸ばした。'
        DB	"I reach for a mikan from on top of the table."
        DB	NEXT
        ;	DB	'【英美】：しゅうちゃんってばぁ、英美がむいてあげるって言ってるのにぃ。'
        DB	"Hidemi:  Are you sure you don't want me to peel it for you,"
        DB	CR
        DB	"%001?"
        DB	NEXT
        ;	DB	'【%001】：ミカンくらい一人でむけるってば。'
        DB	"%001:  I told you, I can do it myself..."
        DB	FLG,F_COPYI,4,1
        DW	0000H
        
M9:		;食べる　ミカン
        ;	DB	'（かーちゃんがうっとーしいからやめた。）'
        DB	"I think I hurt Mom's feeling just now."
        DB	NEXT
        ;	DB	'（・・・そういや、新藤さんの家ってお母さんいないんだっけ・・・）'
        DB	"I think of Kiyomi, who doesn't have a mother like me."
        DB	NEXT
        ;	DB	'（俺って、贅沢なのかな・・・）'
        DB	"I'm a terrible son...."
        DB	NEXT
        ;	DB	'【英美】：ほらしゅうちゃん、あ～んして。'
        DB	"Hidemi:  Okay, Shu-chan, say 'Ah...'"
        DB	NEXT
        ;	DB	'（・・・のしつけて新藤さん家に送ってやろーか・・・）'
        DB	"Hmm... Maybe I'll give my mother to Kiyomi's family."
        DB	FLG,F_COPYI,4,2
        EF_SET 103
        DW	0000H
        
M10:		;食べる　ミカン
        ;	DB	'（かーちゃんがうっとーしいからやめた。）'
        DB	"I don't want to hurt her feelings, so I won't bother."
        DW	0000H
        
M_EXIT:		;
        DB FLG,F_COPYI,255,1
        DB FLG,F_MAND,5,255,101,102,103,104
        DB FLG,F_EXIT,255
        DB	NEXT
        ;	DB	'【伸幸】：そうだ、%001。'
        DB	"Nobuyuki:  Oh, I just remembered, %001."
        DB	NEXT
        ;	DB	'【%001】：何？'
        DB	"%001:  What?"
        DB	NEXT
        ;	DB	'【伸幸】：父さん達、３日から町内会の温泉旅行に・・・'
        DB	"Nobuyuki:  There are these wonderful hot springs that I"
        DB	CR
        DB	"was going to go to, and..."
        DB	NEXT
        ;	DB	'【%001】：なぁああにぃいいいいい！'
        DB	"%001:  WHAT?!"
        DB	NEXT
        ;	DB	'【%001】：ずるいぞオヤジ！'
        DB	"%001:  You're going to go to some hot springs, aren't you?"
        DB	CR
        DB	"And leave me?"
        DB	NEXT
        ;	DB	'【伸幸】：は、話は最後まで聞け！'
        DB	"Nobuyuki:  I'm not done talking! Shut up and listen!"
        DB	NEXT
        ;	DB	'【伸幸】：父さん達は３日から町内会の温泉旅行に行く予定だったが、事情があって旅行自体が中止になったんだ。'
        DB	"Nobuyuki:  I was supposed to go with the town friendship"
        DB	CR
        DB	"society, but the trip got cancelled."
        DB	NEXT
        ;	DB	'【伸幸】：Ｍ県の温泉旅館を一泊二日、貸切にしてあってな。もったいないから父さんが格安で買い取ったんだが、父さん達も法事でクニに帰らなきゃならん。'
        DB	"Nobuyuki:  We rented the entire Japanese ryokan inn for two"
        DB	CR
        DB	"days, but now it's all going to go to waste..."
        DB	NEXT
        ;	DB	'【伸幸】：宿泊費は前金で払い込まれてるから、往復の電車賃だけでいい。昨日来た人達でも誘って、行って来たらどうだ？'
        DB	"Nobuyuki:  The rooms are already paid for, so the only"
        DB	CR
        DB	"thing you left is the train fare. Why don't you invite"
        DB	CR
        DB	"the women who were here yesterday?"
        DB	NEXT
        ;	DB	'【%001】：・・・お父さん！'
        DB	"%001:  Dad! I love you!"
        DB	NEXT
        ;	DB	'俺はがっきと父さんの手を握った。'
        DB	"I hugged my father."
        DB	NEXT
        ;	DB	'【%001】：ありがとう、お父さん！'
        DB	"%001:  Thank you, Dad!"
        DB	NEXT
        ;	DB	'【伸幸】：はっはっは、礼には及ばんぞぉ！'
        DB	"Nobuyuki:  Ha ha, well, I hope you enjoy yourself."
        DB	NEXT
        ;	DB	'【%001】：それじゃ、さっそくみんなに電話しよう！'
        DB	"%001:  I've got to call everyone!"
        DB	NEXT
        ;	DB	'俺は階段を駆け上がって自分の部屋に行った。'
        DB	"I ran up the stairs to my own room."
        DB	NEXT
        ;	DB	'・・・・・・・・・・・・'
        DB	".................................................."
        DB	NEXT
        ;	DB	'【伸幸】：よし・・・Ｏ計画のつかみはオッケー。'
        DB	"Nobuyuki:  Okay... The plan is working."
        DB	NEXT
        ;	DB	'【英美】：英美も温泉、行きたいなぁ～・・・'
        DB	"Hidemi:  I want to go to the hot springs..."
        DB	NEXT
        DB SINARIO,'CSA05.OVL',0
        DW	0000H


end
