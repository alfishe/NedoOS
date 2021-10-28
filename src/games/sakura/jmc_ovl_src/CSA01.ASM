;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ａ０１
;		大晦日

	INCLUDE	SUPER_S.INC

START:
	DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
	DW	S1, S2, S3, S4, S5, S6, S7, S8, S9
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
CM1:	DW	VV1,	NN1,NN2,NN3,-1
CM2:	DW	VV2,	NN2,NN3,-1
CM3:	DW	VV3,	NN2,NN3,NN4,-1
CM4:	DW	VV4,	-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0
;VV3:	DB	3,	'考える',0
VV3:	DB	3,	'THINK',0
;VV4:	DB	4,	'掃除する',0
VV4:	DB	4,	'CLEAN',0

;NN1:	DB	1,	'店内',0
NN1:	DB	1,	'THE SHOP',0
;NN2:	DB	2,	'誠',0
NN2:	DB	2,	'MAKOTO',0
;NN3:	DB	3,	'伸幸',0
NN3:	DB	3,	'NOBUYUKI',0
;NN4:	DB	4,	'大掃除',0
NN4:	DB	4,	'BIG CLEANING',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　店内
S2:		DW	VV1, NN2,  2, M3		;見る　誠
S3:		DW	VV1, NN3,  3, M4		;見る　伸幸
S4:		DW	VV2, NN2,  4, M5, M6, M7		;話す　誠
S5:		DW	VV2, NN3,  5, M8		;話す　伸幸
S6:		DW	VV3, NN4,  6, M9		;考える　大掃除
S7:		DW	VV3, NN2,  7, M10		;考える　誠
S8:		DW	VV3, NN3,  8, M11		;考える　伸幸
S9:		DW	VV4, -1,  9, M12, M13, M14		;掃除する

;イニシャルメッセージ
M1:
	DB	BGM,25
	BAK_INIT 'AB_15'
;	DB	'・・・大晦日。'
	DB	"New Years' Eve."
	DB	NEXT
;	DB	'そこは、戦場だった。'
	DB	"Our house was a battlefield."
	DB	NEXT
;	DB	'【%001】：くそっ！次から次ときりがねえぜ！'
	DB	"%001:  I'm so sick of this stupid housework!"
	DB	NEXT
;	DB	'【伸幸】：文句を言っても始まらんぞ、%001。こいつらを片付けないと、わしらには新年が来んのだ！'
	DB	"Nobuyuki:  If we don't get the house thoroughly clean"
	DB	CR
	DB	"today, the new year can't start!"
	DB	NEXT
;	DB	'【伸幸】：しゃべる前に動け！'
	DB	"Nobuyuki:  So get moving, boy!"
	DB	NEXT
;	DB	'【%001】：わーってるよ！'
	DB	"%001:  Yes sir."
	DB	NEXT
	DB	FLASH,3
;	DB	'ドガガガガ！'
	DB	"*BONK!!*"
	DB	NEXT
;	DB	'【伸幸】：ぐはっ！'
	DB	"Nobuyuki:  Ouch!"
	DB	NEXT
;	DB	'【%001】：親父！？大丈夫か？'
	DB	"%001:  Dad! Are you alright!"
	DB	NEXT
;	DB	'【伸幸】：うう・・・父さんはもうダメらしい・・・'
	DB	"Nobuyuki:  .....I think I'm dying, son!"
	DB	NEXT
;	DB	'【%001】：馬鹿言ってんじゃねぇ！俺一人にこの戦場を押し付ける気かよぉ！'
	DB	"%001:  Don't talk like that! Are you planning on leaving"
	DB	CR
	DB	"me on this battlefield all alone!"
	DB	NEXT
;	DB	'【伸幸】：すまん、不甲斐ない父さんを許してくれ、ガクッ'
	DB	"Nobuyuki:  I'm sorry! Forgive your poor father!"
	DB	NEXT
;	DB	'【%001】：おやじぃ～っ！'
	DB	"%001:  Dad!"
	DB	NEXT
;	DB	'【誠】：%001、小隊長殿は名誉の戦死を遂げられた。'
	DB	"Makoto:  %001, your father died a brave death. We will"
	DB	CR
	DB	"never forget his sacrafice."
	DB	NEXT
;	DB	'【%001】：誠！？'
	DB	"%001:  Makoto?"
	DB	NEXT
	DB	BUF,B_COPY01
	T_CG 'CT14','F','D',0,1
;	DB	'【誠】：もうこの戦場で味方は俺達二人だけ。',CR,'生きて帰れる望みもねぇ。'
	DB	"Makoto:  Now we're the only two left on this battlefield."
	DB	NEXT
;	DB	'【誠】：・・・なら、最後に一花咲かせてやろうぜ！'
	DB	"Makoto:  Let's die bravely...together!"
	DB	NEXT
;	DB	'【%001】：おい。'
	DB	"%001:  Hey, wait a minute. I don't want to die..."
	DB	NEXT
;	DB	'【誠】：行くぞ%001！だだだだだ、どかーん！'
	DB	"Makoto:  I'm going! Cover me!  FOOM! BOOM! RATATATATAT!"
	DB	NEXT
;	DB	'【%001】：何でお前がここにいるんだよ。'
	DB	"%001:  Why are you even here?"
	DB	NEXT
;	DB	'【誠】：ばきゅーん！うぐっ！く、くそっしくじっちまったぜ・・・'
	DB	"Makoto:  FOOM!  RATATATATATAT!"
	DB	NEXT
;	DB	'【%001】：誠、戦争ごっこは他でやってくれ。'
	DB	"%001:  Makoto, please play some other game."
	DB	NEXT
;	DB	'【誠】：うっさいなぁ、感動的なシーンなんだから真面目にやれよ。'
	DB	"Makoto:  Shut up! This is a very touching war drama!"
	DB	NEXT
;	DB	'【%001】：・・・俺達、大掃除してるんだけど。'
	DB	"%001:  We've got a lot of cleaning to do today, because"
	DB	CR
	DB	"it's New Year's Eve."
;	DB	NEXT
	DB	BUF,B_COPY10
	DB	ERASE,E_GFLG,10,100,101,102,103,104,105,106,107,108,109	;巡回クリア
	DB	BGM,4
	B_O B_NORM
	E_CG B_TATE,'T_10'
	DB	NEXT
	B_P1 B_NORM
	BAK_INIT 'AB_15'
	DW	0000H


M2:		;見る　店内
;	DB	'「これでもか」と言わんばかりに散らかってる。'
	DB	"This is my family's electronics shop."
	DB	NEXT
;	DB	'ウチは修理も手掛けてるわけで、俺には何だかよくわからない部品がそこら中に散乱してる。'
	DB	"There are strange electronic parts scattered everywhere."
	DB	CR
	DB	"I'm not even sure what some of them are for."
	DB	NEXT
;	DB	'・・・今日一日で片付くのか？'
	DB	"Can we clean this all in just one day?"
	EF_SET 101
	DW	0000H


M3:		;見る　誠
;	DB	'エアーガンにミリタリールックというサバゲーの時の格好だ。'
	DB	"He's dressed in his full survival outfit, complete with"
	DB	CR
	DB	"realistic looking air gun."
	DB	NEXT
;	DB	'・・・本気で戦争ごっこに来たらしい。'
	DB	"He looks like a real soldier."
	DW	0000H

M4:		;見る　伸幸
;	DB	'棚から落ちて来た機械部品が頭に当たって、目を回して倒れてる・・・ふりをしてる。'
	DB	"He's still dizzy from getting hit on the head. Or else"
	DB	CR
	DB	"he's just pretending..."
	DB	NEXT
;	DB	'このまま俺に掃除を任せようと言うハラらしい。'
	DB	"He might be trying to get me to do all the work..."
	EF_SET 102
	DW	0000H

M5:		;話す　誠
;	DB	'【%001】：全く、どこで聞きつけて来たんだよ。'
	DB	"%001:  How did you hear about what we were doing?"
	DB	NEXT
;	DB	'【誠】：%001の母さんに電話もらったんだよ。',CR,'%001達が戦争ゴッコしてるから、俺もどうかって言われて。'
	DB	"Makoto:  From your mother. She told me you were playing"
	DB	CR
	DB	"wargames, so I thought I'd come over."
	DB	NEXT
;	DB	'【%001】：か・・・かーちゃん・・・'
	DB	"%001:  That mother of mine..."
	DB	FLG,F_COPYI,4,1
	DW	0000H

M6:		;話す　誠
;	DB	'【%001】：せっかくだから、誠も手伝えよ。晩飯くらいは出すから。'
	DB	"%001:  Since you're here, why don't you help out? We'll"
	DB	CR
	DB	"give you dinner."
	DB	NEXT
;	DB	'【誠】：オレがぁ？'
	DB	"Makoto:  Me?"
	DB	FLG,F_COPYI,4,2
	DW	0000H

M7:		;話す　誠
;	DB	'【%001】：この前お前んとこのパソコン修理してやったろ。',CR
;	DB	'手伝ってくれてもバチはあたらねーぞ。'
	DB	"%001:  Remember when we fixed your computer last month? "
	DB	CR
	DB	"You have to help us."
	DB	NEXT
;	DB	'【誠】：へいへい。'
	DB	"Makoto:  Okay, okay."
	EF_SET 104
	DW	0000H

M8:		;話す　伸幸
;	DB	'【%001】：ほら起きろよ父さん。'
	DB	"%001:  Wake up, Dad!"
	DB	NEXT
;	DB	'【伸幸】：%001、父さんは重傷で動けないんだ。'
	DB	"Nobuyuki:  %001, your father is badly wounded... You'll"
	DB	CR
	DB	"have to do the cleaning today."
	DB	NEXT
;	DB	'【%001】：ちょっとこぶになってるだけじゃねーか！'
	DB	"%001:  You were just hit on the head! There isn't even"
	DB	CR
	DB	"any blood!"
	EF_SET 103
	DW	0000H

M9:		;考える　大掃除
;	DB	'毎年大晦日に、「山神電器」は一家総出で大掃除する。'
	DB	"Every year on New Year's Eve, we clean everything in our"
	DB	CR
	DB	"shop, Yamagami Electronics."
	DB	NEXT
;	DB	'・・・と言っても、機械音痴の母さんがいても散らかるばっかりなので、店の片付けは俺と父さんの二人の仕事だ。'
	DB	"My mother doesn't know anything about electronics, of"
	DB	CR
	DB	"course, so she just gets in the way. My father and I do"
	DB	CR
	DB	"most of the work."
	DB	NEXT
	DB	"It's a Japanese custom to clean your house from top to"
	DB	CR
	DB	"bottom on December 31st, to greet the new year with"
	DB	CR
	DB	"everything in order."
	DB	NEXT
	DB	"It's a good custom, but I don't want to do this much work."
	EF_SET 105
	DW	0000H

M10:		;考える　誠
;	DB	'誠の家は大掃除済んだのかな？'
	DB	"I guess Makoto's family finished their cleaning."
	DW	0000H

M11:		;考える　伸幸
;	DB	'親父もこまめに店を片付ければ、毎年こんなに苦労しなくてすむのによぉ。'
	DB	"If my father would clean his shop on a regular basis,"
	DB	CR
	DB	"it wouldn't be so bad today."
	DB	NEXT
;	DB	'まあ、普段店の手伝いなんかしねーから、今日ぐらいはしょーがねぇか。'
	DB	"Well, I can't really complain. I almost never help out"
	DB	CR
	DB	"with the shop."
	EF_SET 106
	DW	0000H

M12:		;掃除する
;	DB	'【%001】：このテレビをこっちに避けて・・・'
	DB	"%001:  Let's move this TV over here..."
	DB	NEXT
;	DB	'ガラガラガラ'
	DB	"*move move*"
	DB	NEXT
;	DB	'【%001】：あっちゃー・・・'
	DB	"%001:  *whew*!"
	DB	FLG,F_COPYI,9,1
	DW	0000H

M13:		;掃除する
;	DB	'【%001】：とにかく、落ちてる部品を一ヶ所に集めるか。'
	DB	"%001:  Let's put all the spare parts in one place."
	DB	NEXT
;	DB	'ごそごそ・・・'
	DB	"*move move*"
	DB	NEXT
;	DB	'【%001】：・・・'
	DB	"%001:  ................"
	DB	FLG,F_COPYI,9,2
	DW	0000H

M14:		;掃除する
;	DB	'【%001】：何か、掃除すればするほど散らかってくよーな気がするぞ・・・'
	DB	"%001:  Hmm, this place is getting more cluttered by being"
	DB	CR
	DB	"cleaned than if it was left alone."
	EF_SET 107
	DW	0000H

M_EXIT:
	DB FLG,F_COPYI,255,1
	DB FLG,F_MAND,8,255,101,102,103,104,105,106,107
	DB FLG,F_EXIT,255
	DB	NEXT
;	DB	'「ごめん下さい」'
	DB	"???:  Excuse me...?"
	DB	NEXT
;	DB	'【%001】：あれ、お客さんか？'
	DB	"%001:  Ah, a customer."
	DB	NEXT
;	DB	'【%001】：すみません、今日は店卸しなんで・・・'
	DB	"%001:  I'm sorry, we're closed today for cleaning, and..."
	DB	NEXT
;	DB	'【%001】：あ。'
	DB	"%001:  Ah!"
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT03','C',0,20,2
	TU_CG 'CT02','C',0,0,3
	T_CG 'CT01','C',0,12,4
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
;	DB	'そこにいたのは、見知った３人だった。'
	DB	"Reiko, Kiyomi and Mio were standing there."
	DB	NEXT
;	DB	'【鈴子】：お掃除、はかどってる？'
	DB	"Reiko:  How's the cleaning going?"
	DB	NEXT
;	DB	'【%001】：見ての通りさ。'
	DB	"%001:  Not very well."
	DB	NEXT
;	DB	'【清美】：まるで、大魔神が悪代官をこらしめて暴れた後みたいですわね・・・。'
	DB	"Kiyomi:  It looks like a tornado passed through here!"
	DB	NEXT
;	DB	'【美緒】：そう思って、あたし達お手伝いに来たんだ！'
	DB	"Mio:  We figured that would be the case, and came over"
	DB	CR
	DB	"to help!"
	DB	NEXT
;	DB	'【%001】：え・・・'
	DB	"%001:  What?"
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT14','F',0,0,7
	T_CG 'CT09',0,0,20,5
	DB	ANI,A_ON,7
;	DB	'【伸幸】：いやそれは願ってもない！'
	DB	"Nobuyuki:  Well, is that so!"
	DB	NEXT
;	DB	'【%001】：親父、重傷じゃなかったのかよ・・・。'
	DB	"%001:  What happened do your injury? You sure got better"
	DB	CR
	DB	"all of the sudden."
	DB	NEXT
;	DB	'【%001】：気持ちはありがたいけどさ、やっぱり申し訳ないよ。'
	DB	"%001:  Thanks for offering, but we'll do it ourselves."
	DB	NEXT
;	DB	'【誠】：%001、俺の時とずいぶん対応が違わねぇか？'
	DB	"Makoto:  Your attitude is quite a bit different from when "
	DB	CR
	DB	"ou were talking with me."
	DB	NEXT
;	DB	'【%001】：このクソ忙しい時に戦争ゴッコしに来た奴にはあれで十分だっての。'
	DB	"%001:  That's because you came to play wargames when"
	DB	CR
	DB	"we were busy!"
	DB	NEXT
;	DB	'【伸幸】：じゃあこうしよう。みんなにバイト料として三千円ずつだそうじゃないか。'
	DB	"Nobuyuki:  Let's do this. I'll pay each of you $30 if"
	DB	CR
	DB	"you help us clean."
	DB	NEXT
	DB	BUF,B_COPY01
	TU_CG 'CT03','C',0,20,2
	TU_CG 'CT02','C',0,0,3
	T_CG 'CT01','C',0,12,4
	DB	ANI,A_ON,2
	DB	ANI,A_ON,3
;	DB	'【鈴子】：そんな、私達お金なんて・・・'
	DB	"Reiko:  Oh, we didn't come here for money."
	DB	NEXT
;	DB	'【伸幸】：そうでもしないと%001が納得しないんだよ。どうだ、これなら文句ないだろう%001？'
	DB	"Nobuyuki:  But if I don't pay you something, %001 won't"
	DB	CR
	DB	"agree. Isn't that right, %001?"
	DB	NEXT
;	DB	'【%001】：それって、俺にも出るんだろうな？'
	DB	"%001:  Are you going to pay me, too?"
	DB	NEXT
;	DB	'【鈴子】：・・・それじゃ、始めましょうか。'
	DB	"Reiko:  Well, let's get started, then."
	DB	NEXT
;	DB	'【鈴子】：まず%001君と誠君とおじさまは、その床に落ちてる機械を全部外に出して。'
	DB	"Reiko:  First, let's pick up the things scattered on"
	DB	CR
	DB	"the floor."
	DB	NEXT
;	DB	'【伸幸】：いや、この中にはまだ使える部品もあるんだよ。'
	DB	"Nobuyuki:  But there are things that can still be used"
	DB	CR
	DB	"scattered in with the junk."
	DB	NEXT
;	DB	'【鈴子】：それは後回し！まずお店の中をすっきりさせます！'
	DB	"Reiko:  We'll sort that out later! First we have to"
	DB	CR
	DB	"clean everything!"
	DB	NEXT
;	DB	'【伸幸】：は、はい！'
	DB	"Nobuyuki:  Okay!"
	DB	NEXT
;	DB	'・・・こうして鈴子さんの陣頭指揮で、非常に能率良く大掃除は進められた。'
	DB	"This is how our shop got cleaned from top to bottom."
	DB	NEXT
	DB SINARIO,'CSA02.OVL',0
	DW	0000H


end
