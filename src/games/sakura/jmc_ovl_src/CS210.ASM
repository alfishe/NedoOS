	;	さくらの季節	FILENAME:CSas#_##(CS+章+ｼﾅﾘｵ No.(+ｻﾌﾞﾅﾝﾊﾞｰ))
;		シーン　２１０
;		
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
	DB	BGM,6
	BAK_INIT "AB_23"
	DB	BUF,B_COPY01
	T_CG "CT01","M",0,20,1
;	DB	"【鈴子】：さあ、最後は私ね。"
	DB	"Reiko:  So, I am last."
	DB	NEXT
;	DB	"【%001】：・・・"
	DB	"%001:  ........."
	DB	NEXT
;	DB	"【鈴子】：勝負の相手はこの私。私が勝ったら、水泳部に入ってもらうわよ。"
	DB	"Reiko:  Your opponent is me. If I win, you will join the"
	DB	CR
	DB	"swim team."
	DB	NEXT
;	DB	"【%001】：・・・どうしてもやんの？"
	DB	"%001:  Are you sure you want to go ahead with this?"
	DB	NEXT
;	DB	"【鈴子】：何よ、いまさら逃げる気なの！？男らしくないわ、そういうの。"
	DB	"Reiko:  What, you trying to get out of it? Stand up to a"
	DB	CR
	DB	"challenge like a man."
	DB	NEXT
;	DB	"【%001】：だって・・・勝てるわけねーよ。俺・・・"
	DB	"%001:  But there's no way I can win. I...."
	DB	PAUSE
;	DB	"・・・泳げねーもん。"
	DB	"can't swim."
	DB	NEXT
;	DB	"【鈴子】：んなっ？"
	DB	"Reiko:  You what?"
	DB	NEXT
;	DB	"【%001】：だから、水泳部に入っても仕方ないだろ。",CR,"じゃ、そーゆーことで・・・"
	DB	"%001:  Like I said, it would be a waste of time for me to"
	DB	CR
	DB	"join the swim team. So I guess we just have to..."
	DB	NEXT
	K_CG "CT01","D",20,2
;	DB	"【鈴子】：・・・い～え、騙されないわ！"
	DB	"Reiko:  Oh no, you aren't fooling me!"
	DB	NEXT
;	DB	"【%001】：うわ・・・！"
	DB	"%001:  No wait!"
	DB	NEXT
;	DB	"鈴子さんは俺の腕をつかんで、プールに引っ張り込んだ。"
	DB	"Reiko grabbed my arm and pulled me into the pool."
	DB	NEXT
;	DB	"【鈴子】：運動神経抜群の君が泳げないなんてありえないわ！"
	DB	"Reiko:  There is no way that a natural athlete like you"
	DB	CR
	DB	"can't swim!"
	DB	NEXT
;	DB	"【%001】：ごばばぼ、ぐがぶぶぼ！"
	DB	"%001:  Hwaa! Fwagh!"
	DB	NEXT
;	DB	"【鈴子】：そーやって、溺れたフリしてもダメ！",CR,"さあ、私と勝負してもらうわよ！"
	DB	"Reiko:  Stop pretending to drown. You are going to race"
	DB	CR
	DB	"me!"
	DB	NEXT
;	DB	"【%001】：あばばブクブクブク・・・"
	DB	"%001:  *burble burble*"
	DB	NEXT
;	DB	"【鈴子】：%001君・・・見苦しいわよ。この期におよんで逃げ出すなんて・・・"
	DB	"Reiko:  Be a man! Stop trying to get out of a challenge."
	DB	NEXT
;	DB	"【%001】：ブク・・・"
	DB	"%001:  *burb*"
	SUDA_CLS
	DB	NEXT
;	DB	"【鈴子】：私が・・・水泳部がイヤなら、最初にそう言ってくれればいいのに・・・"
	DB	"Reiko:  If you hate me and swimming so much, you should"
	DB	CR
	DB	"have said so from the beginning..."
	DB	NEXT
;	DB	"【%001】："
	DB	"%001:  ............................................"
	DB	NEXT
;	DB	"【鈴子】：%001君？"
	DB	"Reiko:  %001?"
	DB	NEXT
;	DB	"・・・・・・しーん・・・・・・"
	DB	".................................................."
	DB	NEXT
;	DB	"【鈴子】：うそっ！ホントだったの！？"
	DB	"Reiko:  Is it possible... You really can't swim?"
	DB	NEXT
;	DB	"・・・・・・ざばっ・・・・・・"
	DB	"..............................*burb*"
	DB	BUF,B_COPY01
	T_CG "CT01","M","I",0,3
	DB	NEXT
;	DB	"【鈴子】：%001君、しっかりして%001君！",CR,"・・・大変、息してないわ！"
	DB	"Reiko:  %001, are you okay?! Oh no, he's not breathing!"
	DB	NEXT
;	DB	"【鈴子】：じ、人工呼吸を・・・"
	DB	"Reiko:  I'd better give him mouth-to-mouth!"
	DB	NEXT
;	DB	"【鈴子】：・・・（ぽっ）・・・"
	DB	"Reiko:  .........Oh, but..."
	DB	NEXT
;	DB	"【鈴子】：なんて、照れてる場合じゃないわよね。"
	DB	"Reiko:  Oh, this is no time to be embarrassed."
	DB	NEXT
;	DB	"【鈴子】：じゃ、じゃあ・・・いくわよ・・・"
	DB	"Reiko:  I've got to try something..."
	DB	NEXT
	T_CG "CT13","F",0,25,4		;校長
;	DB	"【校長】：やあ鈴子君、調子はどうだね？"
	DB	"Dean:  Ho, Reiko. How have you been?"
	DB	NEXT
;	DB	"【鈴子】：あ、校長先生！"
	DB	"Reiko:  Ah, the dean..."
	DB	NEXT
;	DB	"【校長】：ん？その子は一体・・・？"
	DB	"Dean:  What's wrong with this lad?"
	DB	NEXT
;	DB	"【鈴子】：あの・・・溺れてしまって・・・"
	DB	"Reiko:  Um, he.... He drowned, sir."
	DB	NEXT
;	DB	"【校長】：それはいかん！よし、私に任せなさい！"
	DB	"Dean:  We can't have that! Leave it to me!"
	DB	NEXT
;	DB	"がばっ"
	DB	"*GHA*"
	DB	NEXT
;	DB	"【鈴子】：ああっ！"
	DB	"Reiko:  Ah!"
	DB	NEXT
;	DB	"ぶちゅううううううううう"
	DB	"*FWOOOO*"
	DB	NEXT
;	DB	"【%001】：ご・・・ごばっ・・・！"
	DB	"%001:  *cough* *cough*"
	DB	NEXT
;	DB	"【校長】：よし・・・呼吸が再開したぞ。"
	DB	"Dean:  Alright, that's better. He'll be alrigt."
	DB	NEXT
;	DB	"【校長】：これでもう大丈夫だ。一応保健室に運んでおくから、君は安心して練習を続けたまえ。"
	DB	"Dean:  He'll be okay. I'll just take him to the nurse"
	DB	CR
	DB	"to be sure. You continue your practice."
	DB	NEXT
;	DB	"【鈴子】：あの・・・"
	DB	"Dean:  ........................................."
	DB	NEXT
;	DB	"【校長】：そうだ鈴子君、君に大事な話があったんだ。"
	DB	"Dean:  Oh, I almost forgot. I have something important "
	DB	CR
	DB	"to tell you."
	DB	NEXT
;	DB	"【鈴子】：はい？"
	DB	"Reiko:  What?"
	DB	NEXT
;	DB	"【校長】：たった今、本鮪（ほんまぐろ）大学から、君を推薦入学させたいという連絡があった。"
	DB	"Dean:  I just got word that Honmaguro University"
	DB	CR
	DB	"accepted your application"
	DB	NEXT
	K_CG "CT01","K",0,5
	DB ANI,A_ON,4
;	DB	"【鈴子】：えっ！本鮪大学が、私を？！"
	DB	"Reiko:  What? Honmaguro accepted me?"
	DB	NEXT
;	DB	"【校長】：うむ。どうやら次のオリンピックで、君の勇姿を見られそうだな、鈴子君。"
	DB	"Dean:  That's right. It looks like I will be seeing"
	DB	CR
	DB	"you in the next Olympics."
	DB	NEXT
;	DB	"【鈴子】：私が・・・本鮪大学に・・・"
	DB	"Reiko:  Wow, Honmaguro University..." 
	DB	NEXT
;	DB	"【鈴子】：・・・やった・・・やったわ！"
	DB	"Reiko:  Alright! I made it!"
	DB	NEXT
;	DB	"【鈴子】：・・・あ、%001君！校長先生！"
	DB	"Reiko:  Ah, sir, don't forget about about %001!"
	DB	NEXT
;	DB	"・・・・・・・・・・・・・・・"
	DB	"............................................"
	DB	NEXT
	DB SINARIO,"CS211.OVL",0
	DW	0000H


end
