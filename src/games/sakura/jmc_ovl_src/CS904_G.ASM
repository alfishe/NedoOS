;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　９０４＿Ｇ
;		二人だけの夜　星愛編

        INCLUDE	SUPER_S.INC

START:
        DW	SCTBL,MSGTBL,COMTBL,VNTBL,ENDTBL
SCTBL:
        DW	S1, S2, S3
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
CM1:	DW	VV1,	NN1,NN2,-1
CM2:	DW	VV2,	NN1,-1

;VV1:	DB	1,	'見る',0
VV1:	DB	1,	'LOOK',0
;VV2:	DB	2,	'話す',0
VV2:	DB	2,	'TALK',0

;NN1:	DB	1,	'星愛',0
NN1:	DB	1,	'SEIA',0
;NN2:	DB	2,	'教会',0
NN2:	DB	2,	'CHURCH',0

;	　　　 動詞 名詞 ﾌﾗｸﾞ ﾒｯｾｰｼﾞ
S1:		DW	VV1, NN1,  1, M2		;見る　星愛１
S2:		DW	VV1, NN2,  2, M3, M4		;見る　教会２
S3:		DW	VV2, NN1,  3, M5, M6, M7, M8, M9, M10		;話す　星愛６


;イニシャルメッセージ
M1:
        DB	BGM,13
        ;	BAK_INIT "AB_04_3"
        ;	DB	'【%001】：・・・・・・ふ～ん、ここが前に吉田が言ってた教会か・・・・・・'
        DB	"%001:  So is the church you talked about before?"
        DB	NEXT
        ;	DB	'・・・俺は吉田に連れられ・・・吉田が憧れてたシスターがいたという教会までやって来ていた。'
        DB	"Seia has brought me to the church where the Sisters she"
        DB	CR
        DB	"respects so much do God's work."
        DB	NEXT
        ;	DB	'【星愛】：・・・お待たせしました。'
        DB	"Seia:  Here we are."
        DB	NEXT
        ;	DB	'【%001】：・・・おう。'
        DB	"%001:  .....Wow."
        DB	PAUSE
        E_CG B_SUDA,'AE_161'
        ;	DB	'・・・って、吉田？'
        DB	"....Is that you, Seia?"
        DW	0000H
        
M2:		;見る　星愛１
        ;	DB	'シスターの服に身を包み、俺に微笑みかけている。'
        DB	"Dressed in robes, Seia was smiling at me."; what are a nun's clothes called??
        DB	NEXT
        ;	DB	'・・・何だか、別人みたいだ・・・'
        DB	" Wow, I can't believe my eyes."
        DW	0000H
        
M3:		;見る　教会１
        ;	DB	'・・・何だか、随分と寂れたところだ。'
        DB	"It's very quiet in here."
        DB	NEXT
        ;	DB	'俺達の他に、誰もいないせいかも知れないが。'
        DB	"It must be because we're the only ones here."
        DW	0000H
        
M4:		;見る　教会２
        ;	DB	'良く見ると、あちこち埃がたまっている。'
        DB	"Looking closely, I can see a lot of dust inside the"
        DB	CR
        DB	"church."
        DB	NEXT
        ;	DB	'・・・そうか・・・ここ、無くなっちまうんだ・・・'
        DB	"So this church is supposed to be demolished soon..."
        DB	NEXT
        
M5:		;話す　星愛１
        ;	DB	'【星愛】：・・・あの・・・おかしいでしょうか？'
        DB	"Seia:  Do they look funny?"
        DB	NEXT
        ;	DB	'【%001】：・・・何が？'
        DB	"%001:  What?"
        DB	NEXT
        ;	DB	'【星愛】：・・・この格好・・・'
        DB	"Seia:  These robes..."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  .........."
        DB	PAUSE
        ;	DB	'い、いや！似合ってるぜ、すごく。'
        DB	"No! No, they look good on you!"
        DB	NEXT
        ;	DB	'【星愛】：・・・ありがとうございますぽっ'
        DB	"Seia:  Thank you. *blush*"
        DB	FLG,F_COPYI,3,1
        DW	0000H
        
M6:		;話す　星愛２
        ;	DB	'【%001】：・・・ところで、用って何？'
        DB	"%001:  Um, what did you want me to help you with?"
        DB	NEXT
        ;	DB	'【星愛】：・・・・・・'
        DB	"Seia:  ....."
        DB	PAUSE
        ;	DB	'今日は、クリスマスイヴですわよね？'
        DB	"Today is Christmas Eve, right?"
        DB	NEXT
        ;	DB	'【%001】：・・・あ、ああ。'
        DB	"%001:  Yes."
        DB	NEXT
        ;	DB	'【星愛】：キリスト教において、今日と明日はとても重要な日ですわ。'
        DB	"Seia:  For Christians, today and tomorrow are very"
        DB	CR
        DB	"important days."
        DB	NEXT
        ;	DB	'【星愛】：・・・ですが、この教会にはわたくし達以外誰も居ません・・・'
        DB	"Seia:  But we're the only ones in this church."
        DB	PAUSE
        ;	DB	'何故だと思います？'
        DB	" Why do you"
        DB	CR
        DB	"think that is?"
        DB	FLG,F_COPYI,3,2
        DW	0000H
        
M7:		;話す　星愛３
        ;	DB	'【%001】：・・・ここら辺、仏教徒しかいないとか・・・'
        DB	"%001:  Um, because this is a Buddhist neighborhood?"
        DB	NEXT
        ;	DB	'【星愛】：・・・・・・・・・'
        DB	"Seia:  ...................."
        DB	NEXT
        ;	DB	'【星愛】：この教会は、もうすぐ取り壊されます。'
        DB	"Seia:  This church is going to be demolished soon."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ...................."
        DB	NEXT
        ;	DB	'【%001】：なっ、なにぃいぃぃぃっ！？'
        DB	"%001:  What?"
        DB	FLG,F_COPYI,3,3
        DW	0000H
        
M8:		;話す　星愛４
        ;	DB	'【%001】：・・・とっ・・・取り壊されるって、何でまた！'
        DB	"%001:  Demolished? Why?"
        DB	NEXT
        ;	DB	'【星愛】：・・・・・・この教会には、主がおりません・・・・・・'
        DB	"Seia:  Because God doesn't live in this church."
        DB	NEXT
        ;	DB	'そういう吉田の声は・・・確かに震えていた。'
        DB	"While she said that, I could tell she was shaking."
        DB	NEXT
        ;	DB	'【%001】：・・・吉田・・・'
        DB	"%001:  ..........Seia..."
        DB	FLG,F_COPYI,3,4
        DB	FLG,F_COPYI,2,1
        DW	0000H
        
M9:		;話す　星愛５
        ;	DB	'【星愛】：・・・・・・夢、でした。この教会でシスターをする事が・・・・・・'
        DB	"Seia:  It was my dream...to become a nun and work in this"
        DB	CR
        DB	"church..."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・・・・'
        DB	"%001:  ...................."
        DB	NEXT
        ;	DB	'【星愛】：・・・見習いのシスターゴッコでもいい、この姿でここに立ちたかった・・・'
        DB	"Seia:  I wanted to wear these robes and work here, for"
        DB	CR
        DB	"God..."
        DB	NEXT
        ;	DB	'【%001】：・・・・・・'
        DB	"%001:  ............."
        DB	PAUSE
        ;	DB	'どうすればいい？'
        DB	"Please show me what to do."
        DB	NEXT
        ;	DB	'【星愛】：え？'
        DB	"Seia:  What?"
        DB	NEXT
        ;	DB	'【%001】：だから、信者って何をすればいいんだ？'
        DB	"%001:  I don't know anything about what Christians do,"
        DB	CR
        DB	"so you'll have to tell me."
        DB	NEXT
        ;	DB	'・・・俺は今日だけ、敬虔なクリスチャンだ。'
        DB	"%001:  But I'll be a good Christian, even if it's only"
        DB	CR
        DB	"for tonight."
        DB	NEXT
        ;	DB	'【星愛】：・・・%001君・・・！'
        DB	"Seia:  ..........%001."
        DB	FLG,F_COPYI,3,5
        DW	0000H
        
M10:		;話す　星愛６
        ;	DB	'【星愛】：・・・そうですわね、まずは・・・'
        DB	"Seia:  Okay, well. First..."
        DB	NEXT
        B_O B_SUDA
        ;	DB	'・・・・・・・・・'
        DB	"..................."
        DB	NEXT
        ;	DB	'それから俺達は・・・一緒に賛美歌を唄ったり、何だか良く分からない儀式'
        ;	DB	'をして・・・'
        DB	"Then the two of us sang hymns together, then performed some"
        DB	CR
        DB	"ceremony I didn't understand very well..."
        DB	NEXT
        ;	DB	'最後に俺達は向かい合って跪き、頭を垂れて祈りを捧げる。'
        DB	"Finally we kneeled down, bowed our heads, and prayed."
        DB	NEXT
        ;	DB	'・・・・・・'
        DB	"................."
        DB	NEXT
        ;	DB	'・・・いつまでこ～やってるんだ？'
        DB	"How long does this go on for?"
        DB	NEXT
        ;	DB	'薄目を開けてみると・・・すぐ間近に吉田の顔があった。'
        DB	"I snuck a glance...and there was Seia's face."
        DB	NEXT
        ;	DB	'・・・う・・・！'
        DB	"......Woah!"
        DB	NEXT
        ;	DB	'吉田の長い睫毛・・・'
        DB	"Her hair......."
        DB	PAUSE
        ;	DB	'高くはないが、ほっそりとした鼻・・・'
        DB	"Her pretty nose...."
        DB	NEXT
        ;	DB	'・・・そして、桜色の吉田の唇・・・'
        DB	"..........Her sakura-colored lips."
        DB	NEXT
        ;	DB	'・・・・・・吉田・・・・・・'
        DB	"Seia............"
        DB	NEXT
        ;	DB	'俺は吸い寄せられるように顔を近付けて行き・・・'
        DB	"My face moved close to hers, as if drawn by some unseen"
        DB	CR
        DB	"force."
        DB	NEXT
        ;	DB	'・・・ま、待てっ！俺は今、いったい何をしようとしてたんだっ！？'
        DB	"Wait! What are you doing?"
        DB	NEXT
        ;	DB	'ギリギリのところで理性を回復した俺は、ゆっくり吉田から離れようとした。'
        DB	"Recovering some of my senses somewhat, I moved away from"
        DB	CR
        DB	"her."
        DB	NEXT
        ;	DB	'が。'
        DB	"But then..."
        DB	NEXT
        ;	DB	'・・・・・・涙・・・・・・？'
        DB	"She's crying...!"
        DB	NEXT
        ;	DB	'息が掛かりそうなほど間近で見た吉田の目尻には・・・確かに涙が光っていた。'
        DB	"Out of the corner of her eye I could see the tears clearly."
        DB	NEXT
        ;	DB	'・・・吉田・・・お前・・・'
        DB	"...Seia, you poor woman..."
        DB	NEXT
        ;	DB	'この瞬間、俺は吉田がたまらなく愛しくなって。'
        DB	"At that moment, I fell in love with Seia."
        DB	NEXT
        ;	DB	'俺は勢い良く、吉田の唇を奪った。'
        DB	"With surprising force, I kissed her."
        DB	NEXT
        DB	SINARIO,'CSE_G_1.OVL',0
        DW	0000H


end
