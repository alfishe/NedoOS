;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ
;		シーン　ＣＳＥ＿Ｃ＿１　
;		

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
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	-1
CM3:	DW	VV3,	-1

;VV1:	DB	1,	'抱きしめる',0
VV1:	DB	1,	'TAKE HER',0
;VV2:	DB	2,	'のぞく',0
VV2:	DB	2,	'PEEK',0
;VV3:	DB	3,	'待つ',0
VV3:	DB	3,	'WAIT',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2		;抱き締める
S2:		DW	VV2, -1,  2, M3		;覗く
S3:		DW	VV3, -1,  3, M4, M5		;待つ２


;イニシャルメッセージ
M1:
	DB	BGM,19
;	DB	'・・・そして、春休みのある一日。'
	DB	".....Then, one day during Spring Vacation."
	DB	NEXT
;	DB	'俺は美緒ちゃんの家に遊びに来た。'
	DB	"I went to Mio's house."
	DB	NEXT
	BAK_INIT 'AB_32'
	DB BUF,B_COPY01
	T_CG 'CT03','C','K',5,1
;	DB	'【%001】：こんちわ～。'rea
	DB	"%001:  Hello?"
	DB	NEXT
;	DB	'【美緒】：いらっしゃい、%001先輩。'
	DB	"Mio:  Hi, %001! Come on in."
	DB	NEXT
;	DB	'【%001】：・・・あれ？おじさんとおばさんは？'
	DB	"%001:  Where is everyone?"
	DB	NEXT
;	DB	'【美緒】：親戚の家に遊びに行ってる。'
	DB	"Mio:  They're all away, at my grandparents'."
	DB	NEXT
;	DB	'【%001】：それじゃ、今日は俺たち二人っきりってこと？'
	DB	"%001:  You mean we're all alone here?"
	DB	NEXT
	K_CG 'CT03','R',5,2
;	DB	'【美緒】：・・・うん・・・'
	DB	"Mio:  That's right."
	DB	NEXT
;	DB	'【%001】：あ！いやその、決して変な意味じゃねーんだ。'
	DB	"%001:  Wait! Don't worry, I didn't mean anything......"
	DB	NEXT
;	DB	'【%001】：そうだ、はい！これ、誕生プレゼント。'
	DB	"%001:  Oh, I almost forgot. Here's your birthday present."
	DB	CR
	DB	"You're twenty years old now."
	DB	NEXT
	T_CG 'CT03','C','K',5,1
;	DB	'【美緒】：ありがとう、開けてもいい？'
	DB	"Mio:  Thank you, %001!  Can I open it?"
	DB	NEXT
;	DB	'【%001】：もちろん。'
	DB	"%001:  Of course."
	DB	NEXT
;	DB	'【美緒】：・・・あっ・・・テニスシューズだ！'
	DB	"Mio:  Oh! Tennis shoes!"
	DB	NEXT
;	DB	'【%001】：前の靴、もうボロボロだったろ。'
	DB	"%001:  Your old shoes are so worn out, so I thought you'd"
	DB	CR
	DB	"like these."
	DB	NEXT
;	DB	'【%001】：美緒ちゃんが一番喜ぶ物っつったら、テニス用品くらいしか思い付かなくてな。・・・気に入ってくれた？'
	DB	"%001:  Well, do you?"
	DB	NEXT
;	DB	'【美緒】：ありがとう・・・すっごくうれしい・・・'
	DB	"Mio:  Yes, thank you... I'm so happy..."
	DB	NEXT
;	DB	'・・・・・・午後７時・・・・・・'
	DB	"Later that night."
	DB	NEXT
;	DB	'【%001】：お、ビーフシチューか。'
	DB	"%001:  Ah, beef stew. It smells delicious."
	DB	NEXT
;	DB	'【美緒】：慎治君に教えてもらったんだけど・・・おいしい？'
	DB	"Mio:  Shinji taught me how to make it. Do you like it?"
	DB	NEXT
;	DB	'【%001】：・・・うん、うまい！！'
	DB	"%001:  Yes, it's really good!"
	DB	NEXT
;	DB	'【美緒】：本当？'
	DB	"Mio:  Really?"
	DB	NEXT
;	DB	'【%001】：ホントホント、美緒ちゃん、いいお嫁さんになれるよ。'
	DB	"%001:  Yes, it is. You'll make a good wife someday."
	DB	NEXT
	K_CG 'CT03','R',5,2
;	DB	'【美緒】：・・・先輩の？'
	DB	"Mio:  .............Yours?"
	DB	NEXT
;	DB	'【%001】：・・・・・・'
	DB	"%001:  ....................."
	DB	NEXT
;	DB	'・・・冗談なのか？・・・'
	DB	"......How should I answer that?"
	DB	NEXT
;	DB	'・・・こーゆー時は笑えばいいのか？・・・'
	DB	"Should I laugh?..."
	DB	NEXT
;	DB	'・・・真面目に答えるのも変な気がするし・・・'
	DB	"But if she's serious, and I laugh, I'll hurt her feelings..."
	DB	NEXT
;	DB	'【%001】：えと・・・'
	DB	"%001:  ........Um, well..."
	DB	NEXT
;	DB	'【美緒】：やだ、ジョーダン、ジョーダンだってば！冷めないうちに食べて。'
	DB	"Mio:  Don't look so serious, %001! I was only kidding!"
	DB	CR
	DB	"Now eat before it gets cold."
	DB	NEXT
;	DB	'【%001】：あ、そうだな・・・'
	DB	"%001:  Alright..."
	DB	NEXT
;	DB	'・・・・・・・・・・・・'
	DB	"....................."
	DB	NEXT
;	DB	'【%001】：いやぁ、食った食った・・・ごちそうさん。'
	DB	"%001:  That was delicious."
	DB	NEXT
;	DB	'【%001】：それじゃ、そろそろ帰るわ。'
	DB	"%001:  Well, I guess I'll be off, then."
	DB	NEXT
	T_CG 'CT03','C',0,5,1
;	DB	'【美緒】：先輩・・・！'
	DB	"Mio:  %001...!"
	DB	NEXT
;	DB	'【%001】：ん？'
	DB	"%001:  Yes?"
	DB	NEXT
;	DB	'【美緒】：一つだけ・・・あたしのわがまま、聞いてくれる・・・？'
	DB	"Mio:  Will you do something for me?"
	DB	NEXT
;	DB	'【%001】：何だって、美緒ちゃんの言う通りにするよ。今日はそーゆー日だろ？'
	DB	"%001:  Of course. I'd do anything for my Mio."
	DB	NEXT
	K_CG 'CT03','I',5,3
;	DB	'【美緒】：・・・帰らないで。'
	DB	"Mio:  .........Don't go home tonight."
	DB	NEXT
;	DB	'【美緒】：今夜は・・・あたしといて・・・%001先輩・・・'
	DB	"Mio:  Stay with me.... Stay with me, tonight."
	DB	BGM,13
	DB C_BLD,C_V_ON,2
	DB C_BLD,C_V_ON,3
	DW	0000H

M2:		;抱き締める
;	DB	'【%001】：・・・'
	DB	"%001:  ...................."
	DB	NEXT
	E_CG B_FADE,"AE_141"
;	DB	'俺は無言で美緒ちゃんをきつく抱き締めた。'
	DB	"Without saying anything, I pulled Mio to me."
	DB	NEXT
;	DB	'【美緒】：んっ・・・'
	DB	"Mio:  ....%001!"
	DB	NEXT
;	DB	'俺の腕の中で、美緒ちゃんの細い体がしなる。'
	DB	"I crushed Mio's bird-like body against me."
	DB	NEXT
;	DB	'そっと目を閉じた美緒ちゃんに、俺は迷わず唇を合わせた。'
	DB	"She closed her eyes as a signal. Wihout hesitating, I kissed"
	DB	CR
	DB	"her."
	DB	NEXT
;	DB	'【美緒】：・・・ふぅ・・・'
	DB	"Mio:  ..........Mmmmm...."
	DB	NEXT
;	DB	'恍惚とした表情で、そっと俺から離れる美緒ちゃん。'
	DB	"Finally she moved away from me slowly."
	DB	NEXT
;	DB	'【美緒】：あたし・・・お風呂入ってくる・・・'
	DB	"Mio:  I'm going to take a bath. I'll be right back."
	DB	NEXT
;	DB	'【%001】：・・・俺も・・・一緒に入っていいかな？'
	DB	"%001:  Can I...take one with you?"
	DB	NEXT
;	DB	'【美緒】：・・・ダメ・・・お願い、待ってて・・・'
	DB	"Mio:  ....No, please wait here."
	DB	NEXT
	B_P1 B_SUDA
;	DB	'美緒ちゃんはお風呂場に消えた。'
	DB	"Mio heads for the bath."
	DB C_BLD,C_V_ON,1
	DB C_BLD,C_V_OFF,2
	DB C_BLD,C_V_OFF,3
	DW	0000H

M3:		;覗く
;	DB	'・・・それは正月のあれで懲りたぞ・・・'
	DB	".....Did you forget what happened when you did that at the"
	DB	CR
	DB	"hot springs?"
	DB	NEXT
;	DB	'待ってて、って言うんだから、待っててあげるのが男ってもんだろ？'
	DB	"She asked you to wait. Don't you think that's a better idea?"
	DW	0000H

M4:		;待つ
;	DB	'あ～・・・俺も緊張するな・・・'
	DB	"Waiting around is making me nervous, too."
	DB	NEXT
;	DB	'う～・・・'
	DB	"Damn!"
	DB	NEXT
;	DB	'俺は動物園の虎みたいに、うろうろと歩き回った。'
	DB	"I started pacing like a caged tiger."
	DB	FLG,F_COPYI,3,1
	DW	0000H

M5:		;待つ２
;	DB	'【美緒】：お待たせ・・・'
	DB	"Mio:  Sorry to keep you waiting..."
	DB	NEXT
;	DB	'【%001】：あ、う、は、早かったね・・・'
	DB	"%001:  That was fast."
	DB	NEXT
;	DB	'【美緒】：う、うん、あはは・・・'
	DB	"Mio:  Yes, well..."
	DB	NEXT
;	DB	'【美緒】：せ、先輩もお風呂入ったら？'
	DB	"Mio:  Do...you want to take a bath, too?"
	DB	NEXT
;	DB	'【%001】：お、おう、そうするよ。'
	DB	"%001:  .......I'll do that."
	DB	NEXT
	B_O B_SUDA
;	DB	'・・・俺は自分でも神経質だって思うくらい、念入りに全身を洗った。'
	DB	"In the shower, I washed my body thoroughly."
	DB	NEXT
;	DB	'熱いシャワーで泡を流してる間にも、早くも俺の・・いわゆるアレは準備ＯＫになってしまってる。'
	DB	"My cock stayed hard the whole time I was washing myself."
	DB	NEXT
;	DB	'ええい、がっつくなみっともない！静まれ、落ち着け・・・'
	DB	"This is bad...I've got to calm down!"
	DB	NEXT
;	DB	'うう、緊張するなぁ・・・今日子先生にやられた時は、準備もクソも無かったが・・・'
	DB	"Taking time before you do it is terrible for your nerves..."
	DB	CR
	DB	"This is a lot different from when I was with Kyoko-"
	DB	CR
	DB	"sensei."
	DB	NEXT
;	DB	'あ・・・なんか頭がくらくらしてきた・・・'
	DB	"What do I do? I'm too nervous!"
	DB	NEXT
;	DB	'あ～～～・・・ほえほえ・・・'
	DB	"........Shit....!"
	DB	NEXT
	DB	"..........................."
	DB	NEXT
	DB	"Mio:  %001?"
	DB	NEXT
	DB	"Mio:  .....%001, wake up!"
	DB	NEXT
	B_P1 B_SUDA
;	DB	'【%001】：あ・・・れ？'
	DB	"%001:  What?"
	DB	NEXT
;	DB	'【美緒】：%001先輩・・・気がついた？'
	DB	"Mio:  %001, you're awake!"
	DB	NEXT
;	DB	'・・・気がつくと、俺は布団で寝てた。そんな俺を、美緒ちゃんが心配そうに見つめている。'
	DB	"When I woke up, I was lying in a futon. Mio was looking"
	DB	CR
	DB	"at me with worry in her eyes."
	DB	NEXT
;	DB	'【%001】：・・・俺・・・風呂に入ってて・・・'
	DB	"%001:  Did I......pass out?"
	DB	NEXT
;	DB	'【美緒】：のぼせてたから・・・'
	DB	"Mio:  ..........Yes."
	DB	NEXT
;	DB	'【%001】：んっ！？'
	DB	"%001:  What?!"
	DB	NEXT
;	DB	'俺ははたと気がついて、布団の中をのぞきこんだ。'
	DB	"Suddenly I sat up and looked under the blanked that"
	DB	CR
	DB	"covered me."
	DB	NEXT
;	DB	'・・・案の定、何も着てなかった。'
	DB	"......As I suspected, I wasn't wearing anything down"
	DB	CR
	DB	"there."
	DB	NEXT
;	DB	'【%001】：・・・・・・・・・・・・'
	DB	"%001:  ..........................."
	DB	NEXT
;	DB	'【%001】：・・・・・・美緒ちゃん・・・見た？'
	DB	"%001:  ..........Mio, did you look at it?"
	DB	NEXT
;	DB	'【美緒】：だって・・・！'
	DB	"Mio:  I couldn't help it!"
	DB	NEXT
;	DB	'【%001】：ずるいぞ。'
	DB	"%001:  That's not fair."
	DB	NEXT
;	DB	'【美緒】：えっ？'
	DB	"Mio:  What?"
	DB	NEXT
;	DB	'【%001】：美緒ちゃんばっかり俺の裸見てずるい！'
	DB	"%001:  It's not fair that you got to see mine, but I"
	DB	CR
	DB	"didn't get to see yours...!"
	DB	NEXT
;	DB	'【美緒】：・・・'
	DB	"Mio:  ...................."
	DB	NEXT
;	DB	'【%001】：俺にも・・・見せてよ。'
	DB	"%001:  Show me, Mio. Show me yours."
	DB	NEXT
;	DB	'【美緒】：・・・'
	DB	"Mio:  .............."
	DB	NEXT
	DB	SINARIO,'CSE_C_2.OVL',0
	DW	0000H


end
