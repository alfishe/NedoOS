;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　
;		清美と踊る

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5
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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN1,-1
CM3:	DW	VV3,	-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0
;VV4:	DB	4,	'踊る',0
VV4:	DB	4,	'DANCE',0

;NN1:	DB	1,	'清美',0
NN1:	DB	1,	'KIYOMI',0
;NN2:	DB	2,	'まわり',0
NN2:	DB	2,	'AROUND',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2, M3		;見る　清美
S2:		DW	VV1, NN2,  2, M4		;見る　まわり
S3:		DW	VV2, NN1,  3, M5, M6		;話す　清美
S4:		DW	VV3, -1,  4, M7		;考える
S5:		DW	VV4, -1,  5, M8, M9, M10, M11, M12		;踊る


;イニシャルメッセージ
M1:
	DB	BGM,24
	BAK_INIT 'AB_27_2'
	DB BUF,B_COPY01
	T_CG "CT02","C",0,10,1
;	DB	'【%001】：あ、新藤さん、ちょっといい？'
	DB	"%001:  Um, Kiyomi, can I talk to you?"
	DB	NEXT
;	DB	'【清美】：え？あ、は、はい！な、なんでしょうか？'
	DB	"Kiyomi:  Me? Why, yes! What's the matter?"
	DB	NEXT
;	DB	'【%001】：・・・あのさ、ダンスって、踊れる？'
	DB	"%001:  Um, do you know how to dance?"
	DB	NEXT
;	DB	'【清美】：え？あの、少々・・・ですが。'
	DB	"Kiyomi:  Um.......a little."
	DB	NEXT
;	DB	'【%001】：それで充分だよ・・・俺に、教えてくれないかな？'
	DB	"%001:  That'd be fine. I was wondering if you could"
	DB	CR
	DB	"teach me how."
	DB	NEXT
;	DB	'【清美】：・・・！はい、喜んで！'
	DB	"Kiyomi:  Oh, yes, I'd be happy to!"
	DB	NEXT
;	DB	'【%001】：じ、じゃあ、行こうか？'
	DB	"%001:  Shall we go?"
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・・・・'
	DB	"....................................................."
	DB	NEXT
	DB	BGM,8
	E_CG B_FADE,'AE_034'
;	DB	'俺は、鈴子さんにダンスを教わっている。'
	DB	"Kiyomi's teaching me how to dance."
	DB	NEXT
;	DB	'正直な話、俺はダンスができない。'
	DB	"When I told her I didn't know how to dance, I was telling"
	DB	CR
	DB	"the truth."
	DB	NEXT
;	DB	'・・・単に経験がなかったせいだったりする。'
	DB	"I just never had the chance to learn."
	DB	NEXT
;	DB	'いざ踊ってしまえばどうにかなる、とか思ったのは甘かったらしい。'
	DB	"I always thought it was something you could pick up without"
	DB	CR
	DB	"any special lessons, but I was wrong."
	DB	NEXT
;	DB	'踊れないのにこんな事をしているのは恥ずかしいけど、鈴子さんの方がもっと恥ずかしいだろう。'
	DB	"She's not that good herself, but she's a lot better than"
	DB	CR
	DB	"me."
	DW	0000H

M2:		;見る　清美
;	DB	'なんだか、危なっかしいな・・・'
	DB	"Hmm, this is a little dangerous."
	DB	NEXT
;	DB	'それでもダンスを「知っている」だけ、俺よりマシかな？'
	DB	"I wonder if she really knows as much as she seems to"
	DB	CR
	DB	"think she does."
	DB	NEXT
;	DB	'【清美】：%001さん？どうかなさいましたか？'
	DB	"Kiyomi:  %001? Is anything wrong?"
	DB	NEXT
;	DB	'【%001】：いや、別に・・・'
	DB	"%001:  Oh...no."
	DB	FLG,F_COPYI,1,1
	DW	0000H

M3:		;見る　清美
;	DB	'転びそうだな・・・'
	DB	"She looks like she's going to trip and fall."
	DB	NEXT
;	DB	'転ばないよな？'
	DB	"I wonder if she's okay?"
	DW	0000H

M4:		;見る　まわり
;	DB	'そんな余裕ないぞ。'
	DB	"I don't have time for that!"
	DW	0000H

M5:		;話す　清美
;	DB	'【%001】：ごめんな、新藤さん・・・'
	DB	"%001: I'm sorry, Kiyomi..."
	DB	NEXT
;	DB	'【清美】：え？どうかなさいましたか？'
	DB	"Kiyomi:  Mm? Why are you apologizing?"
	DB	NEXT
;	DB	'【%001】：ん・・・なんか、迷惑なんじゃないかと思ったから。'
	DB	"%001:  Oh, for asking you to do this for me."
	DB	NEXT
;	DB	'【清美】：あら、そんなことございませんわ。とても、楽しいですわよ？'
	DB	"Kiyomi:  No, I don't mind at all. I'm having fun!"
	DB	FLG,F_COPYI,3,1
	DW	0000H

M6:		;話す　清美
;	DB	'【%001】：ありがと、新藤さん・・・'
	DB	"%001:  Thanks, Kiyomi..."
	DB	NEXT
;	DB	'【清美】：あら、どうなさいましたの？急に。'
	DB	"Kiyomi:  Now you're thanking me. Why?"
	DB	NEXT
;	DB	'【%001】：へ、変かな？'
	DB	"%001:  For teaching me."
	DB	NEXT
;	DB	'【清美】：ですが、その言葉にはまだすこし早いですわよ？'
	DB	"Kiyomi:  But I'm not finished yet. Why thank me now?"
	DB	NEXT
;	DB	'【%001】：ああ・・・そうだな。'
	DB	"%001:  Oh, you're right."
	DW	0000H

M7:		;考える
;	DB	'そ、そんな余裕はないと思うぞ？'
	DB	"I don't have time for that!"
	DW	0000H

M8:		;踊る
;	DB	'【清美】：え～と、こうでしょうか？'
	DB	"Kiyomi:  Um, shall we try this?"
	DB	NEXT
;	DB	'【%001】：・・・大丈夫だよね？'
	DB	"%001:  Are you okay?"
	DB	NEXT
;	DB	'【清美】：ええ、もちろんですわ。・・・右、左・・・あら？'
	DB	"Kiyomi:  Yes, I'm fine. Left, right...Whoops!"
	DB	NEXT,GATA,1
;	DB	'ずでで～ん。'
	DB	"*CRASH*"
	DB	NEXT
;	DB	'新藤さんはバランスを崩し、見事に転んでしまった。'
	DB	"Kiyomi lost her balance and came crashing down."
	DB	NEXT
;	DB	'・・・・・・・・・俺を巻き込んで・・・・・・・・・'
	DB	"Taking me with her, of course."
	DB	NEXT
;	DB	'【清美】：・・・%001さん、大丈夫ですか？'
	DB	"Kiyomi:  %001, are you alright?"
	DB	NEXT
;	DB	'【%001】：ああ、大丈夫だから・・・どいてくんない？'
	DB	"%001:  I'm fine. Um, will you get off me?"
	DB	NEXT
;	DB	'【清美】：まあ！すみません。'
	DB	"Kiyomi:  Oh, I'm sorry!"
	DB	NEXT
;	DB	'・・・・・・一体どうやったら、俺を下敷きにして転べるんだろ？'
	DB	"How did she managed to fall on top of me like that?"
	DB	FLG,F_COPYI,5,1
	DW	0000H

M9:		;踊る
;	DB	'【%001】：・・・あのさ、ムリなんだったら、もーやめようか？'
	DB	"%001:  Maybe we should give up."
	DB	NEXT
;	DB	'【清美】：そうは参りませんわ！'
	DB	"Kiyomi:  No! We can't give up yet!"
	DB	NEXT
;	DB	'【%001】：あ・・・そう・・・'
	DB	"%001:  ....Oh, okay."
	DB	NEXT
;	DB	'【清美】：さ、%001さん、はりきって参りましょう！'
	DB	"Kiyomi:  Shall we dance some more?"
	DB	NEXT
;	DB	'【%001】：ああ。'
	DB	"%001:  Okay..."
	DB	NEXT
;	DB	'・・・右、左、右・・・'
	DB	"....Right, left, right..."
	DB	NEXT
;	DB	'【%001】：うわっ！？'
	DB	"%001:  Whoops!"
	DB	NEXT,GATA,1
;	DB	'ずでで～ん。'
	DB	"*CRASH*"
	DB	NEXT
;	DB	'【%001】：いてててて・・・'
	DB	"%001:  Ouch!"
	DB	NEXT
;	DB	'【清美】：だ、大丈夫ですか？'
	DB	"Kiyomi:  Are you alright?"
	DB	NEXT
;	DB	'【%001】：あ、ああ、大丈夫・・・だけど・・・どいてくれる？'
	DB	"%001:  I'm fine, but will you get off me again?"
	DB	NEXT
;	DB	'新藤さんは俺の背中で正座していた。'
	DB	"This time she was kneeling on my back."
	DB	NEXT
;	DB	'【清美】：まあ！わたくしったら！ほほほほほ！'
	DB	"Kiyomi:  Oh, I'm such a foolish person! Ho ho ho!"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ........................"
	DB	NEXT
;	DB	'（おいおい、ホントに大丈夫だろうな？）'
	DB	"I wonder if she's not doing that on purpose..."
	DB	FLG,F_COPYI,5,2
	DW	0000H

M10:		;踊る
;	DB	'【清美】：・・・左、右・・・そう、その調子ですわ。'
	DB	"Kiyomi:  Left, right, yes, that's good."
	DB	NEXT
;	DB	'【%001】：ホントに？'
	DB	"%001:  Really?"
	DB	NEXT
;	DB	'（な～んかアヤしいな・・・？）'
	DB	"........Is she in a position to be judging how I'm doing?"
	DB	NEXT
;	DB	'ずるっ。'
	DB	"*SLIP*"
	DB	NEXT
;	DB	'【%001】：ゑ！？'
	DB	"%001:  Whoops!"
	DB	NEXT,GATA,1
;	DB	'ずで～ん。'
	DB	"*CRASH*"
	DB	NEXT
;	DB	'【%001】：いてててて・・・'
	DB	"%001:  Ouch!"
	DB	NEXT
;	DB	'今度は俺一人でコケた。'
	DB	"This time it was my fault."
	DB	NEXT
;	DB	'【清美】：まあ、どうなさったのですか？'
	DB	"Kiyomi:  Are you alright, Kiyomi?"
	DB	NEXT
;	DB	'【%001】：ああ、頭の中・・・いや、足元がお留守になってたらしい。'
	DB	"%001:  I'm fine. I just lost sight of my feet for a"
	DB	CR
	DB	"moment."
	DB	NEXT
;	DB	'【清美】：まあ！%001さんって、以外とお茶目さんでしたのね！'
	DB	"Kiyomi:  You're quite a klutz, aren't you!"
	DB	NEXT
;	DB	'【%001】：・・・はぁ？'
	DB	"%001:  .......Huh?"
	DB	NEXT
;	DB	'（・・・どう反応したらいいんだろう？）'
	DB	"I guess I'll just leave that one alone."
	DB	FLG,F_COPYI,5,3
	DW	0000H

M11:		;踊る
;	DB	'【%001】：えと、ここでこう・・・だよな。'
	DB	"%001:  Is this right?"
	DB	NEXT
;	DB	'【清美】：ええ、お上手ですわ。'
	DB	"Kiyomi:  Yes, that's very good."
	DB	NEXT
;	DB	'【%001】：そ、そう？なんか照れるな。'
	DB	"%001:  Really? You're going to make me blush."
	DB	NEXT
;	DB	'【清美】：いえ、%001さんなら当然ですわ。'
	DB	"Kiyomi:  No, you're really good. You're good at everything"
	DB	CR
	DB	"you do, %001."
	DB	NEXT
;	DB	'【%001】：・・・・・・・そうか？'
	DB	"%001:  ........Thanks."
	DB	NEXT,GATA,1
;	DB	'ずで～ん。'
	DB	"*SLIP*"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ............."
	DB	NEXT
;	DB	'【清美】：だ、大丈夫ですか？'
	DB	"Kiyomi:  Are you alright?"
	DB	NEXT
;	DB	'【%001】：・・・ああ。今度こそ頭ン中がお留守になってたらしい・・・'
	DB	"%001:  Sure. I'm getting the hang of this finally."
	DB	NEXT
;	DB	'【清美】：まあ！%001さんって本当にお茶目さんですのね！'
	DB	"Kiyomi:  You're rather clumsy!"
	DB	NEXT
;	DB	'【%001】：は？'
;	DB	"%001:  .............Huh?"
;	DB	NEXT
;	DB	'（・・・解らない・・・）'
	DB	"I can't figure her out..."
	DB	FLG,F_COPYI,5,4
	DW	0000H

M12:		;踊る
;	DB	'【清美】：すごいですわ、%001さん！もう、こんなに上手に・・・'
	DB	"Kiyomi:  You're really a lot better, %001!"
	DB	NEXT
;	DB	'【%001】：え・・・？そ、そーかな？'
	DB	"%001:  Thanks... I guess."
	DB	NEXT
;	DB	'【%001】：・・・新藤さんのおかげだよ。'
	DB	"%001:  It's all thanks to you, Kiyomi."
	DB	NEXT
;	DB	'【清美】：・・・・・・え？'
	DB	"Kiyomi:  ......Eh?"
	DB	NEXT
;	DB	'ずるっ。'
	DB	"*SLIP*"
	DB	NEXT
;	DB	'【清美】：きゃ！？'
	DB	"Kiyomi:  Oh no!!"
	DB	NEXT
;	DB	'【%001】：・・・おっと！',PAUSE,CR,'・・・あれ！？'
	DB	"%001:  .........Careful! Oh! ",PAUSE,".....Not again!"
	DB	NEXT,GATA,1
;	DB	'ずで～ん。'
	DB	"*CRASH*"
	DB	NEXT
;	DB	'またまた倒れそうになった新藤さんを支えようとした俺は、バランスを失って一緒にコケた。'
	DB	"Losing her balance, Kiyomi grabbed a hold of me. We both"
	DB	CR
	DB	"went down."
	DB	NEXT
;	DB	'【%001】：いてててて・・・'
	DB	"%001:  Ouch!"
	DB	NEXT
;	DB	'【清美】：あっ・・・！'
	DB	"Kiyomi:  Oh, my...!"
	DB	NEXT
;	DB	'【%001】：あ、ご、ごめん！'
	DB	"%001:  I'm sorry..."
	DB	NEXT
;	DB	'転んだ拍子に、俺の手は新藤さんの胸の辺りに触れていた。'
	DB	"When we fell, I accidentally grabbed her breast."
	DB	NEXT
;	DB	'【清美】：い、いえ・・・わたくしの不注意ですから・・・'
	DB	"Kiyomi:  Oh, it's my fault..."
	DB	NEXT
;	DB	'【%001】：・・・いや、俺の方こそ下手に手なんか出したから・・・'
	DB	"%001:  No, I'm sorry. I shouldn't have put my hand"
	DB	CR
	DB	"there..."
	DB	NEXT
;	DB	'【清美】：・・・そんな、%001さんは悪くありませんわ！'
	DB	"Kiyomi:  No! You didn't do anything wrong, %001!"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ......................"
	DB	NEXT
;	DB	'【清美】：・・・・・・'
	DB	"Kiyomi:  ......................"
	DB	NEXT
;	DB	'【%001】：・・・踊ろうか、新藤さん。'
	DB	"%001:  ...Let's dance some more, Kiyomi."
	DB	NEXT
;	DB	'【清美】：そうですわね。'
	DB	"Kiyomi:  Okay, let's."
	DB	NEXT
;	DB	'・・・・・・・・・・・・・・・・・・・・・'
	DB	"........................................................"
	DB	NEXT
;	DB	'ダンスパーティも終盤に近づいて、ようやく俺達は転ばないで踊れるようになった。'
	DB	"By the time the dance party drew to a close, we had learned"
	DB	CR
	DB	"to dance without falling."
	DB	NEXT
;	DB	'俺の前には、夢見るように微笑む新藤さんがいる。'
	DB	"Kiyomi stood in front of me, a dream-like smile fixed to"
	DB	CR
	DB	"her face."
	DB	NEXT
;	DB	'【清美】：・・・今夜は、月がきれいですわね・・・'
	DB	"Kiyomi:  The moon is beautiful tonight..."
	DB	NEXT
;	DB	'【%001】：・・・うん・・・とてもきれいだ・・・'
	DB	"%001:  Yes, it is."
	DB	NEXT
;	DB	'言ってから、俺は新藤さんに見愡れてる自分に気が付いた。'
	DB	"I realized I couldn't stop looking into Kiyomi's eyes."
	DB	NEXT
;	DB	'なぜだか頬の辺りが熱くなった俺は、空を見上げた。',CR,'月の光が、俺と新藤さん専用の照明のように、俺達を優しく照らしていた。'
	DB	"I looked up at that moon, and it seemed as if it was"
	DB	CR
	DB	"shining just for Kiyomi and I, and there was no one else"
	DB	CR
	DB	"in the world."
	DB	NEXT
;	DB	'今夜の月を、俺はずっと忘れないだろう。'
	DB	"I'll never forget that night."
	DB	NEXT
	DB	"...................................................."
	DB	NEXT
	DB G_FLG,G_COPYI,124,1
	DB G_FLG,G_COPYF,120,120
	DB	FLG,F_CALI,120,20
	DB G_FLG,G_COPYG,120,120
	B_O B_FADE
	DB	SINARIO,'CS901.OVL',0
	DW	0000H


end
