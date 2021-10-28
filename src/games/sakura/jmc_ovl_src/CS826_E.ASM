;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　８２６＿Ｅ
;		DANCE WITH ELVES

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
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'考える',0
VV2:	DB	2,	'THINK',0
;VV3:	DB	3,	'踊る',0
VV3:	DB	3,	'DANCE',0

;NN1:	DB	1,	'瑠璃',0
NN1:	DB	1,	'RURI',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　瑠璃
S2:		DW	VV2, -1,  2, M4		;考える
S3:		DW	VV3, -1,  3, M5, M6, M7, M8, M9		;踊る


;イニシャルメッセージ
M1:
        DB	BGM,24
        BAK_INIT 'AB_27_2'
        DB BUF,B_COPY01
        T_CG "CT05","C",0,10,1
        ;	DB	'あ、あんな所に・・・'
        DB	"....There she is."
        DB	NEXT
        ;	DB	'【%001】：お～い、白水さ～ん。'
        DB	"%001:  Hey, Ruri!"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・'
        DB	"Ruri:  ...................."
        DB	PAUSE
        ;	DB	'・・・・・・なに？'
        DB	".............Yes?"
        DB	NEXT
        ;	DB	'【%001】：あ、あのさ、俺、ダンスなんて全然わかんないから、教えて欲しいんだけど・・・・・・ダンス、できる？'
        DB	"%001:  I was just wondering... I don't know how to dance"
        DB	CR
        DB	"at all, and I was wondering if you'd show me how."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・できないわ。'
        DB	"Ruri:  ....I can't dance."
        DB	NEXT
        ;	DB	'【%001】：そ、そう。'
        DB	"%001:  Oh, I see."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・・・・どうして、私なの・・・？'
        DB	"Ruri:  ..........Why do you ask me?"
        DB	NEXT
        ;	DB	'【%001】：え？・・・ん～・・・・・・・・・'
        DB	"%001:  Mm? Hmmmmm..."
        DB	NEXT
        ;	DB	'【%001】：ん～・・・・・・・・・・・・'
        DB	"%001:  Hmmmmmm....."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・もういいわ・・・'
        DB	"Ruri:  Nevermind."
        DB	NEXT
        ;	DB	'【%001】：あ・・・ごめん。'
        DB	"%001:  Oh. Sorry."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・何故、あやまるの・・・？'
        DB	"Ruri:  Why apologize to me?"
        DB	NEXT
        ;	DB	'【%001】：え・・・なんでって、気を悪くしたかな、と思って。'
        DB	"%001:  Why? Well, because I said something stupid."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・あなたは悪くないわ。'
        DB	"Ruri:  ........You didn't do anything wrong."
        DB	NEXT
        ;	DB	'【%001】：そ、そか。'
        DB	"%001:  I didn't? Okay."
        DB	NEXT
        ;	DB	'【%001】：・・・白水さん、俺といるの、嫌？'
        DB	"%001:  ......Ruri, do you...hate being with me?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・別に・・・'
        DB	"Ruri:  ..........No."
        DB	NEXT
        ;	DB	'【%001】：じゃ、踊りに行こう。'
        DB	"%001:  Well, then, let's dance."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・え？でも、私・・・'
        DB	"Ruri:  What? But I..."
        DB	NEXT
        ;	DB	'【%001】：いいって、俺だって踊れないんだ、どーにかなるよ！'
        DB	"%001:  It'll be okay. I don't know how to dance, either!"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・あ。'
        DB	"Ruri:  .................B-"
        DB	NEXT
        ;	DB	'俺は、白水さんの返事を待たずにその細い腕をひいて走り出した。'
        DB	"Without waiting for Ruri's answer, I pulled her by her"
        DB	CR
        DB	"narrow arm out onto the field."
        DB	NEXT
        ;	DB	'・・・なぜか、そうしなければいけないような気になったからだ。'
        DB	"I don't know why I did it that way. I just got the feeling"
        DB	CR
        DB	"I should."
        DB	NEXT
        ;	DB	'・・・・・・・・・・・・・・・・・・・・・'
        DB	"............................................"
        DB	NEXT
        DB	BGM,8
        E_CG B_FADE,'AE_037'
        ;	DB	'【瑠璃】：・・・なぜこんな隅の方で踊るの。'
        DB	"Ruri:  Why are we dancing away from the others like this?"
        DB	NEXT
        ;	DB	'【%001】：・・・・・・踊りが下手だから、恥ずかしいんだ。'
        DB	"%001:  People who don't know how to dance should"
        DB	CR
        DB	"stay out of everyone else's way."
        DB	NEXT
        ;	DB	'【瑠璃】：ごめんなさい。'
        DB	"Ruri:  I'm sorry."
        DB	NEXT
        ;	DB	'【%001】：いや、白水さんじゃなくて、俺が、だよ。'
        DB	"%001:  No, it's not you I'm worried about. It's me..."
        DB	NEXT
        ;	DB	'【瑠璃】：そう。'
        DB	"Ruri:  Oh."
        DW	0000H
        
M2:		;見る　瑠璃
        ;	DB	'・・・・・・・・・笑ってる・・・。'
        DB	"She's smiling."
        DB	NEXT
        ;	DB	'・・・・・・笑ってるよな、確かに。'
        DB	"She's really smiling. I'm not hallucinating it."
        DB	NEXT
        ;	DB	'・・・夢でも見てるのか、俺？'
        DB	"She looks like she's dreaming on her feet."
        DB	NEXT
        ;	DB	'ぎゅむっ'
        DB	"*CRUNCH*"
        DB	NEXT
        ;	DB	'【%001】：いでで！'
        DB	"%001:  Ouch!"
        DB	NEXT
        ;	DB	'【瑠璃】：ごめんなさい。'
        DB	"Ruri:  I'm sorry!"
        DB	NEXT
        ;	DB	'・・・この踏まれた足の痛みは、本物だ。'
        DB	"........Having your foot stepped on isn't a fun experience."
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
M3:		;見る　瑠璃
        ;	DB	'・・・俺があんまり下手くそなんで、それで笑ってるのか。'
        DB	"Maybe she's smiling because I'm such a bad dancer."
        DB	NEXT
        ;	DB	'・・・それとも・・・'
        DB	"Or maybe..."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・なに？'
        DB	"Ruri:  .........What?"
        DB	NEXT
        ;	DB	'【%001】：いや、何でも。'
        DB	"%001:  Oh, nothing. Nevermind."
        DW	0000H
        
M4:		;考える
        ;	DB	'・・・考えて見たら、白水さんは俺が無理矢理連れてきたわけで・・・'
        DB	"Now that I think of it, I did force her to come out here"
        DB	CR
        DB	"with me."
        DB	NEXT
        ;	DB	'・・・それってものすごく、悪いことなんじゃないのか？'
        DB	"Am I doing her a disservice?"
        DB	NEXT
        ;	DB	'・・・でもまあ、見た限り怒ってなさそうだし、いいか。'
        DB	"........Well, she doesn't seem to be angry."
        DW	0000H
        
M5:		;踊る
        ;	DB	'白水さんも俺も、踊りの類は全く知らない。'
        DB	"Neither of us knows the correct way to dance."
        DB	NEXT
        ;	DB	'とにかく、まわりを参考にしよう。'
        DB	"We're just copying the other people around us."
        DB	NEXT
        ;	DB	'右足まえ・・・'
        DB	"Left..."
        DB	NEXT
        ;	DB	'左足まえ・・・'
        DB	"Right..."
        DB	NEXT
        ;	DB	'左足うしろ・・・'
        DB	"Left..."
        DB	NEXT
        ;	DB	'ぎゅむっ'
        DB	"*CRUNCH*"
        DB	NEXT
        ;	DB	'【%001】：おわっ！'
        DB	"%001:  Ouch!"
        DB	NEXT,GATA,1
        ;	DB	'ズテッ！'
        DB	"*CRASH*"
        DB	NEXT
        ;	DB	'俺は白水さんに足を踏まれてコケた。'
        DB	"Ruri stepped on my foot again, causing me to fall down."
        DB	NEXT
        ;	DB	'【瑠璃】：ごめんなさい・・・踊り、知らないから。'
        DB	"Ruri:  I'm sorry... Are you okay?"
        DB	FLG,F_COPYI,3,1
        DW	0000H
        
M6:		;踊る
        ;	DB	'【瑠璃】：・・・%001君、踊りを知ってる人と踊ったら。'
        DB	"Ruri:  %001, why don't you ask someone who knows how to"
        DB	CR
        DB	"dance to come out here with you?"
        DB	NEXT
        ;	DB	'【%001】：白水さん、俺と踊るのヤなの？'
        DB	"%001:  Do you not want to be here with me?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・別に。'
        DB	"Ruri:  ..........No, that's not it."
        DB	NEXT
        ;	DB	'【%001】：ならいいじゃないか。知らないもの同士、仲良くしよう。'
        DB	"%001:  Then don't worry about it. We'll just be two"
        DB	CR
        DB	"people who don't know what they're doing."
        DB	NEXT
        ;	DB	'右足まえ・・・'
        DB	"Right..."
        DB	NEXT
        ;	DB	'左足まえ・・・'
        DB	"Left..."
        DB	NEXT
        ;	DB	'ぐるっとまわって・・・'
        DB	"Back..."
        DB	NEXT
        ;	DB	'がっ'
        DB	"*TRIP*"
        DB	NEXT
        ;	DB	'【%001】：わっ！'
        DB	"%001:  Wah!"
        DB	NEXT,GATA,1
        ;	DB	'ズテッ！'
        DB	"*CRASH*"
        DB	NEXT
        ;	DB	'俺は白水さんに足を引っ掛けてコケた。'
        DB	"This time her foot tripped me, bringing me down again."
        DB	NEXT
        ;	DB	'【瑠璃】：ごめんなさい・・・。'
        DB	"Ruri:  I'm sorry..."
        DB	NEXT
        ;	DB	'すっ、と白水さんが俺に手を差し伸べる。'
        DB	"Ruri extends her hand out to me to help me up."
        DB	NEXT
        ;	DB	'【%001】：いや、平気だって。'
        DB	"%001:  I'm okay."
        DB	NEXT
        ;	DB	'俺は白水さんの手にすがって立ち上がった。'
        DB	"I take her hand and pull myself up."
        DB	NEXT
        ;	DB	'（手首・・・細いんだな。力を込めたら折れそうなくらい・・・）'
        DB	"Her wrists are so narrow. I could break them in two if I"
        DB	CR
        DB	"tried."
        DB	NEXT
        ;	DB	'（それに・・・白くてきれいで・・・）'
        DB	"Her skin is so white... She's really very pretty."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・'
        DB	"Ruri:  ........."
        DB	NEXT
        ;	DB	'【%001】：あっ、ごめん！'
        DB	"%001:  Oh! I'm sorry!"
        DB	NEXT
        ;	DB	'白水さんが赤くなってるのを見て、俺は慌てて手を離した。'
        DB	"Seeing her red face, I hurriedly pulled my hand away."
        DB	NEXT
        ;	DB	'（怒ったのかな・・・）'
        DB	".............Is she mad?"
        DB	NEXT
        ;	DB	'【瑠璃】：%001君・・・踊らないの？'
        DB	"Ruri:  Aren't you going to dance, %001?"
        DB	NEXT
        ;	DB	'（・・・よかった、怒ってないみたい。）'
        DB	"...........Good, I guess she's not mad."
        DB	NEXT
        ;	DB	'【%001】：いや踊ろう、すぐ踊ろう。'
        DB	"%001:  Yes, let's dance."
        DB	FLG,F_COPYI,3,2
        DW	0000H
        
M7:		;踊る
        ;	DB	'ぎゅっ'
        DB	"*CRUNCH*"
        DB	NEXT
        ;	DB	'【%001】：あ、ごめん。'
        DB	"%001:  Oh, I'm sorry!"
        DB	NEXT
        ;	DB	'ぎゅむっ'
        DB	"*CRUNCH*"
        DB	NEXT
        ;	DB	'【瑠璃】：ごめんなさい。'
        DB	"Ruri:  I'm sorry, I did it again."
        DB	NEXT
        ;	DB	'（・・・踊りっていうより、足の踏みあいみたいだな・・・）'
        DB	".....This isn't dancing. We're just taking turns stepping"
        DB	CR
        DB	"on each other's feet."
        DB	FLG,F_COPYI,3,3
        DW	0000H
        
M8:		;踊る
        ;	DB	'（しかし、まわりの連中はよく踊れるな・・・）'
        DB	"Everyone else seems to be so good at this."
        DB	NEXT
        ;	DB	'（やっぱ、この日のために練習してたのかな・・・）'
        DB	"I wonder if they practiced before today."
        DB	NEXT
        ;	DB	'どん'
        DB	"*BUMP*"
        DB	NEXT
        ;	DB	'【瑠璃】：あっ・・・'
        DB	"Ruri:  Ah..."
        DB	NEXT
        ;	DB	'よそ見してたせいで、俺は白水さんにぶつかった。'
        DB	"I wasn't paying attention, and bumped into Ruri."
        DB	NEXT
        ;	DB	'【%001】：あぶない！'
        DB	"%001:  Watch it!"
        DB	NEXT
        ;	DB	'俺は慌てて白水さんを抱き留めた。'
        DB	"Trying to keep her from falling again, I grabbed onto"
        DB	CR
        DB	"Ruri and held on to her."
        DB	NEXT
        ;	DB	'【瑠璃】：ぁ・・・ありがとぅ・・・'
        DB	"Ruri:  ...........Thanks."
        DB	NEXT
        ;	DB	'白水さんはまた真っ赤になってしまった。'
        DB	"Ruri's face turned red again."
        DB	NEXT
        ;	DB	'【%001】：ごめん、俺がよそ見してたから・・・'
        DB	"%001:  I'm sorry, I didn't mean to do that..."
        DB	NEXT
        ;	DB	'【%001】：そうか、わかったぞ！'
        DB	"%001:  Oh, wait a minute! I think I've got it figured"
        DB	CR
        DB	"out now!"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・なに？'
        DB	"Ruri:  What?"
        DB	NEXT
        ;	DB	'俺は改めてまわりで踊ってるやつらを見た。'
        DB	"I looked at the other dancers around us again."
        DB	NEXT
        ;	DB	'やっぱり、ちゃんと踊れてるペアは、自分の相手だけを見てた。'
        DB	"Couples dancing together were only looking at each other,"
        DB	CR
        DB	"not at other people."
        DB	NEXT
        ;	DB	'【%001】：変にまわりに合わせようとするから、かえって踊れないんだよな。'
        DB	"%001:  We keep falling because we're looking at the other"
        DB	CR
        DB	"dancers, trying to do what they're doing."
        DB	NEXT
        ;	DB	'【%001】：俺は白水さんだけを見るようにするから、白水さんも俺だけを見てくれないか？'
        DB	"%001:  I'll try to only look at you, so you do the same."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・！'
        DB	"Ruri:  ..................!!"
        DB	NEXT
        ;	DB	'【%001】：そうすればうまく踊れると・・・・・・白水さん？'
        DB	"%001:  If we do that, we'll be much better. Trust me,"
        DB	CR
        DB	"okay?"
        DB	NEXT
        ;	DB	'白水さんがまたまた頬を染めてる。'
        DB	"Ruri's cheeks were dyed deep red again."
        DB	NEXT
        ;	DB	'（・・・俺、なんか変なこと言ったのか？）'
        DB	"..........Did I say anything?"
        DB	NEXT
        ;	DB	'【瑠璃】：なんでもないわ・・・踊りましょう。'
        DB	"Ruri:  It's okay. Let's dance."
        DB	FLG,F_COPYI,3,4
        DW	0000H
        
M9:		;踊る
        ;	DB	'俺達二人は相変わらずぎこちなく踊ってる。ま、さっきよりはマシに',CR,'なっただろうか。'
        DB	"We start dancing again, this time better than before."
        DB	NEXT
        ;	DB	'もうまわりは見えない。',CR,'俺の前には、ただ月明かりに映える白水さんの笑顔だけがあった。'
        DB	"I can't see anyone else around us. The only thing I can"
        DB	CR
        DB	"see is Ruri looking into my eyes."
        DB	NEXT
        ;	DB	'そう・・・まぎれもなく、笑顔が。'
        DB	"........She's smiling at me."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・%001君。'
        DB	"Ruri:  %001..."
        DB	NEXT
        ;	DB	'【%001】：・・・何？'
        DB	"%001:  Yes?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・もう、終わりみたい。'
        DB	"Ruri:  ............I think the dance is over."
        DB	NEXT
        ;	DB	'【%001】：え？'
        DB	"%001:  Eh?"
        DB	NEXT
        ;	DB	'いつのまにか、音楽が止まっていた。踊っていた連中は、ぞろぞろと',CR,'校舎の方に引き返して行く。'
        DB	"She was right. The music had stopped some time ago, and"
        DB	CR
        DB	"people were going back into the school."
        DB	NEXT
        ;	DB	'・・・よく見ると、別の方向に消えて行くペアもいた。'
        DB	".....Some couples, I could see, were going off together."
        DB	NEXT
        ;	DB	'【%001】：俺達も戻ろうか、白水さん。'
        DB	"%001:  Shall we go back?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・'
        DB	"Ruri:  ............."
        DB	NEXT
        ;	DB	'【%001】：白水さん？'
        DB	"%001:  Ruri?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・月夜ばかりと思わないでね。'
        DB	"Ruri:  ......Don't think that it was just because of the"
        DB	CR
        DB	"moon."
        DB	NEXT
        ;	DB	'【%001】：・・・え？'
        DB	"%001:  .............What?"
        DB	NEXT
        ;	DB	'【瑠璃】：さよなら。'
        DB	"Ruri:  Good night."
        DB	NEXT
        DB	"%001:  What, what do you mean?"
        DB	NEXT
        B_O B_WIPE
        ;	DB	'白水さんは意味不明のつぶやきを残して、小走りに校舎の方に駆けていった。'
        DB	"With that, Ruri hurried towards the school."
        DB	NEXT
        ;	DB	'【%001】：「月夜ばかりと思わないでね」・・・'
        DB	"%001:  Don't think that it was just because of the moon...?" 
        DB	NEXT
        ;	DB	'【%001】：どーゆー意味なんだろう・・・'
        DB	"%001:  What did she mean by that?"
        DB	NEXT
        ;	DB	'お月様は何も教えてはくれず、ただ大地を照らしていた。'
        DB	"I looked up at the moon, but it was just shining."
        DB	NEXT
        DB	"...................................................."
        DB	NEXT
        DB G_FLG,G_COPYI,156,1
        DB G_FLG,G_COPYF,150,150
        DB	FLG,F_CALI,150,20
        DB G_FLG,G_COPYG,150,150
        DB SINARIO,'CS901.OVL',0
        DW	0000H


end
