;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　Ａ０９
;		温泉シーン

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
CM1:	DW	VV1,	-1
CM2:	DW	VV2,	-1

;VV1:	DB	1,	'のぞく',0
VV1:	DB	1,	'PEEK',0
;VV2:	DB	2,	'帰る',0
VV2:	DB	2,	'GO BACK',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, -1,  1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12		;覗く
S2:		DW	VV2, -1,  2, M13		;帰る


;イニシャルメッセージ
M1:
        DB	BGM,23
        ;	DB	'（・・・・・・・・・・・・・・・！！）'
        DB	"............................!!"
        E_CG B_SUDA,'AE_023'
        DB	NEXT
        ;	DB	'６つの白い裸身が月明かりに映え、俺の網膜を直撃する。'
        DB	"The six heavenly angels were before me, their bodies"
        DB	CR
        DB	"shimmering under the lights."
        DW	0000H
        
M2:		;覗く
        ;	DB	'【亜希】：みぃおっ！'
        DB	"Aki:  Mi-oh!!"
        DB	NEXT
        ;	DB	'【美緒】：に゛ゃっ！？'
        DB	"Mio:  What?!"
        DB	NEXT
        ;	DB	'亜希ちゃんが美緒ちゃんの背後から胸をむんずとつかむ。'
        DB	"Aki squeezes Mio's tits from behind, massaging them like"
        DB	CR
        DB	"bread dough."
        DB	NEXT
        ;	DB	'【美緒】：あ・・・亜希ちゃん・・・？'
        DB	"Mio:  ........Aki?"
        DB	NEXT
        ;	DB	'【亜希】：フッ・・・あたしの勝ちね！'
        DB	"Aki:  Ha! I win again!"
        DB	NEXT
        ;	DB	'【美緒】：・・・鈴子先輩、亜希ちゃんがいじめるよぉ！'
        DB	"Mio:  Reiko, Aki's teasing me again!"
        DB	NEXT
        ;	DB	'【鈴子】：ハイハイ、いいこいいこ。'
        DB	"Reiko:  Okay, both of you, be good."
        DB	NEXT
        ;	DB	'（・・・鈴子さんも美緒ちゃんもうらやましい・・・）'
        DB	"..................................."
        DB	FLG,F_COPYI,1,1
        DW	0000H
        
M3:		;覗く
        ;	DB	'【清美】：美緒さんはまだ成長期なんですから、もっと大きくなりますわよ。'
        DB	"Kiyomi:  Mio's still growing, so I'm sure she'll get bigger."
        DB	NEXT
        ;	DB	'【美緒】：・・・ホント？'
        DB	"Mio:  Really?"
        DB	NEXT
        ;	DB	'【亜希】：大きくなるったって、この年でそのサイズじゃ先が見えてるんじゃない？'
        DB	"Aki:  I don't think she can grow any more."
        DB	NEXT
        ;	DB	'【美緒】：・・・う・・・'
        DB	"Mio:  Why you....!"
        DB	NEXT
        ;	DB	'（は・・・鼻血出そう・・・）'
        DB	"......I'm going to get a nose bleed in a minute!"
        DB	FLG,F_COPYI,1,2
        DW	0000H
        
        
M4:		;覗く
        ;	DB	'【今日子】：だけどね～、ムネが大きいからってあんまりいい事ないわよ。'
        DB	"Kyoko:  It's not that good to have big breasts, though."
        DB	NEXT
        ;	DB	'【今日子】：サイズの合うブラ捜すの大変だし・・・'
        DB	"Kyoko:  It's hard to find a bra that fits."
        DB	NEXT
        ;	DB	'【鈴子】：タレないように維持するの、大変なのよ。'
        DB	"Reiko:  Yes, it's hard to support them. You don't want"
        DB	CR
        DB	"them to sag later."
        DB	NEXT
        ;	DB	'【亜希】：男どもがや～らしい目で見るし。'
        DB	"Aki:  Men look at you all the time, too..."
        DB	NEXT
        ;	DB	'（どきっ）'
        DB	"*gulp*"
        DB	NEXT
        ;	DB	'【清美】：走る時に邪魔ですわ。'
        DB	"Kiyomi:  It's also hard to run with them."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・肩が凝るわよ・・・'
        DB	"Ruri:  And your back hurts..."
        DB	NEXT
        ;	DB	'【美緒】：う・・・あたしもそういう風に悩んでみたい・・・'
        DB	"Mio:  Yes, but... I still want them!"
        DB	FLG,F_COPYI,1,3
        DW	0000H
        
        
M5:		;覗く
        ;	DB	'【亜希】：ムネって人に揉まれると大きくなるって言うけど、ホントかな？'
        DB	"Aki:  Is it true that your breasts get bigger when"
        DB	CR
        DB	"someone massages them?"
        DB	NEXT
        ;	DB	'【清美】：試してみましょうか？'
        DB	"Kiyomi:  We should try it on Mio."
        DB	NEXT
        ;	DB	'亜希ちゃんと新藤さんが、手をわきわきさせながら美緒ちゃんに迫る。'
        DB	"Aki and Kiyomi spend a few minutes chasing Mio around"
        DB	CR
        DB	"the bath."
        DB	NEXT
        ;	DB	'【美緒】：・・・ぅ・・・'
        DB	"Mio:  Get away from me!"
        DB	NEXT
        ;	DB	'【鈴子】：やめなさいよ、美緒ちゃん怯えてるじゃない。'
        DB	"Reiko:  Cut it out, you two. Can't you see she's scared?"
        DB	NEXT
        ;	DB	'【清美】：大丈夫ですわ、美緒さん。怖いのは最初だけですのよ。'
        DB	"Kiyomi:  It's okay, Mio. It's only scary for the first"
        DB	CR
        DB	"few seconds."
        DB	NEXT
        ;	DB	'【亜希】：す～ぐ気持ちよくしてあげるわよ、美緒！'
        DB	"Aki:  That's right. Then it feels good."
        DB	NEXT
        ;	DB	'（あ、亜希ちゃん・・・目が普通じゃないぞ・・・）'
        DB	"Aki...I've never seen this side of you before..."
        DB	FLG,F_COPYI,1,4
        DW	0000H
        
        
M6:		;覗く
        ;	DB	'【今日子】：ほらほら、美緒ちゃんからかうのはやめにして、一杯やらない？'
        DB	"Kyoko:  Why don't you stop teasing Mio and have a drink?"
        DB	NEXT
        ;	DB	'【亜希】：そうこなくっちゃ！'
        DB	"Aki:  Sensei is starting again."
        DB	NEXT
        ;	DB	'【鈴子】：それにしても、今日子先生ってスタイルいいですよね。そんなに暴飲暴食してるのに・・・どんなダイエットしてるんですか？'
        DB	"Reiko:  You're very slender, Kyoko-sensei, even with all"
        DB	CR
        DB	"the drinking you do. What do you eat?"
        DB	NEXT
        ;	DB	'【今日子】：べっつに～。ストレスためないように気を付けてるだけよ。'
        DB	"Kyoko:  .......Eat? Who says I eat?"
        DB	NEXT
        ;	DB	'（いやまったく。）'
        DB	"....I always suspected that..."
        DB	FLG,F_COPYI,1,5
        DW	0000H
        
        
M7:		;覗く
        ;	DB	'【亜希】：ぷぁ～っっ！温泉で飲むお酒って、また格別ね！'
        DB	"Aki:  Sake tastes so good when you drink it in a hot"
        DB	CR
        DB	"springs!"
        DB	PAUSE
        ;	DB	'・・・ってなに逃げてんのよ美緒！'
        DB	"...........What's wrong, Mio?"
        DB	NEXT
        ;	DB	'【美緒】：・・・だって・・・'
        DB	"Mio:  You know..."
        DB	NEXT
        ;	DB	'【亜希】：あのことならさんざん謝ったじゃない！',CR,'まだ怒ってるの？'
        DB	"Aki:  I said I was sorry, already. Are you still upset?"
        DB	NEXT
        ;	DB	'【清美】：あれは怒りたくもなりますわね・・・'
        DB	"Kiyomi:  I understand how Mio feels, being kissed like"
        DB	CR
        DB	"that by you."
        DB	NEXT
        ;	DB	'【亜希】：言っとくけど、アメリカじゃキスなんてほんの挨拶代りなんだから！'
        DB	"Aki:  Did you know that in America people kiss as a way"
        DB	CR
        DB	"of saying hello?"
        DB	NEXT
        ;	DB	'【鈴子】：あれはそーゆーキスじゃなかったよーな・・・'
        DB	"Reiko:  Don't you mean France? Anyway, they don't put whisky"
        DB	CR
        DB	"they've been drinking into other people's mouths."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・不潔・・・'
        DB	"Ruri:  ..............Yuck!"
        DB	FLG,F_COPYI,1,6
        DW	0000H
        
M8:		;覗く
        ;	DB	'【今日子】：瑠璃ちゃ～ん、楽しんでる？'
        DB	"Kyoko:  Ruri, are you having fun?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・私・・・他の人と一緒にお風呂入ったこと、ないから・・・'
        DB	"Ruri:  I...I've never taken a bath with other people like this."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・でも・・・楽しいわ。'
        DB	"Ruri:  But it's fun."
        DB	NEXT
        ;	DB	'（・・・笑ってる？）'
        DB	"Is she smiling?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・私・・・今日のこと、きっと忘れない・・・'
        DB	"Ruri:  I don't think I'll ever forget today."
        DB	NEXT
        ;	DB	'【清美】：瑠璃さん・・・やはりお母様のところに、お帰りにならなければならないのですか？'
        DB	"Kiyomi:  Ruri, do you really have to go live with your"
        DB	CR
        DB	"mother, and leave our school?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・ごめんなさい・・・'
        DB	"Ruri:  ......I'm sorry."
        DB	NEXT
        ;	DB	'【今日子】：別に謝ることはないのよ。瑠璃ちゃんが自分で決めたことだったら、誰にも止める権利はないもの。'
        DB	"Kyoko:  There's nothing to apologize for. It's your"
        DB	CR
        DB	"decision, and no one can stop you from making it."
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・・・・'
        DB	"Ruri:  ................................"
        DB	FLG,F_COPYI,1,7
        DW	0000H
        
M9:		;覗く
        ;	DB	'【今日子】：瑠璃ちゃんも、一杯どう？'
        DB	"Kyoko:  Ruri, would you like some sake?"
        DB	NEXT
        ;	DB	'【瑠璃】：いただきます・・・'
        DB	"Ruri:  Thank you."
        DB	NEXT
        ;	DB	'こくっ・・・'
        DB	"*swallow*"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・・・・ふぅ・・・・・・'
        DB	"Ruri:  .........................It's good."
        DB	FLG,F_COPYI,1,8
        DW	0000H
        
        
M10:		;覗く
        ;	DB	'【瑠璃】：・・・美緒さん・・・'
        DB	"Ruri:  .......Mio?"
        DB	NEXT
        ;	DB	'【美緒】：え？'
        DB	"Mio:  Eh?"
        DB	NEXT
        ;	DB	'むにっ'
        DB	"*squoogle*"
        DB	NEXT
        ;	DB	'【美緒】：はにゃっ！？'
        DB	"Mio:  Hey!"
        DB	NEXT
        ;	DB	'白水さんは美緒ちゃんの背後に忍び寄ると、突然美緒ちゃんのムネを揉み始めた。'
        DB	"Ruri reached around and started squeezing Mio's breasts."
        DB	NEXT
        ;	DB	'（な、なんだぁ？）'
        DB	"What the hell...??"
        DB	NEXT
        ;	DB	'【美緒】：しっ・・・白水せんぱい？'
        DB	"Mio:  Ruri? What are you doing?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・ムネ・・・大きくなりたいんでしょ？'
        DB	"Ruri:  You want your breasts to get bigger, don't you?"
        DB	NEXT
        ;	DB	'白水さんは真剣な表情で、美緒ちゃんの胸を揉みしだいてる。'
        DB	"Ruri continued to massage Mio's breasts, a serious"
        DB	CR
        DB	"expression on her face."
        DB	NEXT
        ;	DB	'【今日子】：この子・・・こーゆー酔い方するのね・・・。'
        DB	"Kyoko:  People always change when they get drunk..."
        DB	NEXT
        ;	DB	'【美緒】：みっ見てないで助けてよぉ！'
        DB	"Mio:  Don't just sit there, save me!"
        DB	FLG,F_COPYI,1,9
        DW	0000H
        
M11:		;覗く
        ;	DB	'【瑠璃】：・・・'
        DB	"Ruri:  ....................................."
        DB	NEXT
        ;	DB	'白水さんは亜希ちゃんの方を振り返った。'
        DB	"Ruri started looking at Aki now."
        DB	NEXT
        ;	DB	'【亜希】：な、なによ！？あたしはムネには満足してるわ！'
        DB	"Aki:  W- What? I'm perfectly happy with my breasts?"
        DB	NEXT
        ;	DB	'【瑠璃】：・・・ごめんなさい・・・',CR,'私、あなたのことよく知らないの・・・'
        DB	"Ruri:  I'm sorry, I don't know you very well..."
        DB	NEXT
        DB	"Ruri:  So..... This is a greeting."
        DB	NEXT
        ;	DB	'【亜希】：挨拶って・・・え！？'
        DB	"Aki:  Greeting? Wait!"
        DB	NEXT
        ;	DB	'ぶちゅううううううぅぅぅ'
        DB	"*SMOOOCH*"
        DB	NEXT
        DB	"Ruri planted her mouth on Aki's in a full kiss."
        DB	NEXT
        ;	DB	'【亜希】：んん！んんーっ！'
        DB	"Aki:  *spit spit*"
        DB	NEXT
        ;	DB	'・・・亜希ちゃんは温泉に沈んでいった・・・。'
        DB	"Trying to get Ruri's taste out of her mouth, Aki sunk"
        DB	CR
        DB	"herself under the water."
        DB	NEXT
        ;	DB	'【鈴子】：あらー・・・因果応報ね・・・。'
        DB	"Reiko:  I'd say she deserved that..."
        DB	NEXT
        ;	DB	'（確かにアメリカじゃキスが挨拶代りだって言ってたけど・・・）'
        DB	"That's right... She was the one saying that they kiss in"
        DB	CR
        DB	"America when they greet someone..."
        DB	FLG,F_COPYI,1,10
        DW	0000H
        
M12:		;覗く
        ;	DB	'【瑠璃】：・・・・・・'
        DB	"Ruri:  ................................"
        DB	NEXT
        ;	DB	'【%001】：！'
        DB	"%001:  !!"
        DB	NEXT
        ;	DB	'突然振り返った白水さんと目が合ってしまった。'
        DB	"Suddenly my eyes met with Ruri's."
        DB	NEXT
        ;	DB	'【瑠璃】：誰かのぞいてるわ。'
        DB	"Ruri:  We're being watched."
        DB	NEXT
        ;	DB	'【鈴子】：えっ！？'
        DB	"Reiko:  What?"
        DB	NEXT
        ;	DB	'【瑠璃】：ほら、あそこ。'
        DB	"Ruri:  Look, over there."
        DB	NEXT
        ;	DB	'【鈴子】：きっ・・・・・・'
        DB	"Reiko:  Kya!!!!!!"
        DB	NEXT
        ;	DB	'悲鳴を上げながら、女の子たちは俺を目掛けて石をぶつけて来た！'
        DB	"Screaming bloody murder, the girls start hurling rocks at me."
        DB	NEXT
        ;	DB	'【%001】：お、俺はけっしてそんなつもりじゃ・・・！'
        DB	"%001:  No wait! I didn't mean to...!"
        DB	NEXT
        ;	DB	'（じゃあどんなつもりだったんだ、俺？）'
        DB	"What am I saying? I'm guilty as charged!"
        DB	NEXT
        ;	DB	'ひゅっ・・・'
        DB	"Oh no!"
        DB	NEXT,FLASH,1,GATA,2
        ;	DB	'ゴツッ'
        DB	"*CRACK*"
        B_O B_FADE
        DB	NEXT
        ;	DB	'【%001】：ぐぁ！'
        DB	"%001:  Ugh!!"
        DB	NEXT
        ;	DB	'普段ならかる～くよけられそうな石を、うろたえてる俺は避け切れず、思いっきり顔面に食らってしまった。'
        DB	"A large rock hit me smack in the face."
        DB	NEXT
        ;	DB	'【%001】：うーん・・・'
        DB	"%001:  Mnnngh..."
        DB	NEXT
        ;	DB	'俺の意識は遠退いていった。'
        DB	"Slowly I lose consciousness and fall down."
        DB	NEXT
        ;	DB	'・・・・・・・・・・・・・・・・・・'
        DB	"..........................................."
        DB	NEXT
        DB G_FLG,G_COPYF,159,159
        DB FLG,F_JEQ,159
        DW	REI
        DB SINARIO,'CSA11.OVL',0
        DW	0000H
        
M13:		;帰る
        ;	DB	'（・・・・・・ダメだ・・・）'
        DB	"It's no use..."
        DB	NEXT
        ;	DB	'（体が・・・動かん）'
        DB	"My body won't move."
        DW	0000H
        
REI:
        DB SINARIO,'CSA10.OVL',0
        DW	0000H



end
