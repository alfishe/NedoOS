        include SUPER_C.inc
M_START:
MON_15
	BAK_INIT 'tb_001a',B_NORM
	CDPLAY		12
	DB	"*Yawn* Well, guess it's time to get up..."
	DB	NEXT
	DB	"I'll get dressed, and get off to school."
	DB	NEXT
	DB	"I finish dressing, and head down to the dining kitchen."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		9
	DB	"Motoka and Akemi-san are here."
	DB	NEXT
	T_CG 'tt_10_02',MOT_A3,0
	T_CG 'tt_20_02',AKE_A1,0
	DB	"Kenjirou:  Good morning."
	DB	NEXT
	DB	"Akemi:  Good morning, Kenjirou-kun."
	DB	NEXT
	DB	"Motoka:  Oniichan, good morning."
	DB	NEXT
	DB	"Motoka:  Well, I'll be off to school now."
	DB	NEXT
	DB	"Akemi:  Have a nice day." 
	DB	NEXT
	DB	"Kenjirou:  You're going already?"
	DB	NEXT
	DB	"Motoka:  Yes. See you later."
	DB	NEXT
	TATI_ERS	;Tt_10
	CDPLAY		6
	T_CG 'tt_20_02',AKE_A2,0
	DB	"I wonder what's wrong with her?"
	DB	NEXT
	DB	"Motoka left for school."
	DB	NEXT
	DB	"Akemi:  She's got to meet a friend from school, she said."
	DB	NEXT
	DB	"Kenjirou:  ...I see."
	DB	NEXT
	DB	"I pretended to be disinterested."
	DB	NEXT
	DB	"Akemi:  Are you wondering what kind of friend it is?"
	DB	NEXT
	DB	"Akemi:  W- What do you mean?"
	DB	NEXT
	DB	"Akemi:  I mean, are you wondering if it's a female friend, or a man?"
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"Akemi:  Ah-ha, I knew you were interested." 
	DB	NEXT
	DB	"Kenjirou:  N- No, I wasn't. I don't care who she..."
	DB	NEXT
	DB	"Akemi:  It's a male friend."
	DB	NEXT
	DB	"Kenjirou:  Eh?!"
	DB	NEXT
	DB	"Akemi:  ...Just kidding." 
	DB	NEXT
	DB	"Akemi-san smiled an evil smile."
	DB	NEXT
	DB	"Kenjirou:  ...Well, I've got to get going now."
	DB	NEXT
	DB	"I took my bag and stood up."
	DB	NEXT
	DB	"Kenjirou:  Well, see you later."
	DB	NEXT
	DB	"Akemi:  Have a nice day."
	DB	NEXT
	BAK_INIT 'tb_006',B_NORM
	CDPLAY		2
	DB	"I'm at the convenience store."
	DB	NEXT
	DB	"Kenjirou:  What'll I get for lunch today?"
	DB	NEXT
	DB	"Talking to myself, I walk through the door."
	DB	NEXT
	BAK_INIT 'tb_007',B_NORM
	DB	"I buy some rice balls and bread to each for lunch."
	DB	NEXT
	CDPLAY		3
	DB	"Voice:  What are you getting?"
	DB	NEXT
	DB	"I turn around at the voice."
	DB	NEXT
	T_CG 'tt_05_07',TER2,0
	DB	"Kenjirou:  Ah, Terumi-senpai. Good morning. "
	DB	NEXT
	DB	"Terumi:  Morning."
	DB	NEXT
	DB	"Terumi:  Buying lunch at the convenience store again? Why don't you ask your mother to make bento for you?"
	DB	NEXT
	DB	"Kenjirou:  Yes, I should. It's kind of hard to come out and say it, though..."
	DB	NEXT
	DB	"Terumi:  Even if you're not related to her, she is your mother. I'm sure she'll agree."
	DB	NEXT
	DB	"Kenjirou:  ...Well, she does a lot for me already."
	DB	NEXT
	DB	"Terumi:  Are you sure you're not thinking of her as a woman, instead of as a mother?" 
	DB	NEXT
	DB	"Kenjirou:  ........... (She's 100% right)"
	DB	NEXT
	DB	"Kenjirou:  No, of course not. "
	DB	NEXT
	DB	"Terumi:  Really?"
	DB	NEXT
	DB	"She looked at me with doubt in her eyes. I feel like I want to run away."
	DB	NEXT
	DB	"Kenjirou:  A- Anyway, why don't we go to school now?"
	DB	NEXT
	DB	"Terumi:  Okay, that's a good idea. I can tease you while we walk."
	DB	NEXT
	DB	"I leave the convenience store with Terumi-senpai."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_009',B_NORM
	T_CG 'tt_05_09',TER2,0
	DB	"Terumi:  Ah, I hate this crowded train..." 
	DB	NEXT
	DB	"Kenjirou:  There's nothing we can do about it. It can't be helped."
	DB	NEXT
	DB	"Terumi:  The train is always really full when I go to school with you."
	DB	NEXT
	DB	"Kenjirou:  Are you saying it's my fault?"
	DB	NEXT
	DB	"Terumi:  I wonder. Maybe you should come a little earlier."
	DB	NEXT
	DB	"Kenjirou:  Almost all the trains at this time are crowded like this. What time is there "
        DB      "a train that's not crowded in the morning?"
	DB	NEXT
	DB	"Terumi:  Around 11 am."
	DB	NEXT
	DB	"Voice:  Ah, Kenjirou-kun."
	DB	NEXT
	DB	"Both Terumi-senpai and I turn around at the same instant."
	DB	NEXT
	TATI_ERS
	T_CG 'tt_02_09',SIH_A3,0
	T_CG 'tt_05_09',TER1,0
	DB	"Kenjirou:  Ah, Shiho. Good morning."
	DB	NEXT
	DB	"Shiho.  Good morning."
	DB	NEXT
	DB	"Terumi:  Kenjirou, I can't turn my back on you for a minute. Look at this pretty girlfriend you've got." 
	DB	NEXT
	DB	"Shiho's cheeks turned red at Terumi-senpai's words, and she looked at her feet."
	DB	NEXT
	DB	"Kenjirou:  T- Terumi-senpai!"
	DB	NEXT
	DB	"Terumi:  Am I wrong? Oh, I guess I must be. She's really too pretty for you." 
	DB	NEXT
	DB	"Kenjirou:  Leave her alone. She just transferred to this school. She's just a classmate of mine, nothing more."
	DB	NEXT
	DB	"Shiho looked up at that, and I thought she looked a little sad."
	DB	NEXT
	DB	"Shiho:  Nice to meet you. My name is Shiho Kashima."
	DB	NEXT
	DB	"Terumi:  Hi, I'm Terumi Kinouchi. Nice to meet you."
	DB	NEXT
	DB	"Terumi:  Well, I'll leave you two alone."
	DB	NEXT
	DB	"Kenjirou:  Are you running away, Terumi-senpai?"
	DB	NEXT
	DB	"Terumi:  I don't want to bother you two lovebirds any longer."
	DB	NEXT
	TATI_ERS	;Tt_05
	T_CG 'tt_02_09',SIH_A2,0
	DB	"She disappeared, leaving Shiho and me alone."
	DB	NEXT
	DB	"Shiho's cheeks were red again. I tried to laugh it off, lamely."
	DB	NEXT
	DB	"Then Shiho and I started walking for school."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"We walked in silence, each too shy to say anything. Then we were at the school."
	DB	NEXT
	SINARIO 'MON_16.OVL'
END