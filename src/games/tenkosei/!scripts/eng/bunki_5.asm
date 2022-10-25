        include SUPER_C.inc
M_START:
BUNKI_5
	BAK_INIT	'tb_002',B_NORM ;,,P
	CDPLAY		6
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Akemi:  Welcome home." 
	DB	NEXT
	DB	"Kenjirou:  Hello. Where's Motoka?"
	DB	NEXT
	DB	"Akemi:  She's not back yet."
	DB	NEXT
	DB	"Kenjirou:  ................"
	DB	NEXT
	DB	"I wonder what happened?"
	DB	NEXT
	DB	"Just then, the phone rang, and Akemi-san picked it up."
	DB	NEXT
	TATI_ERS
	DB	"Akemi:  Kenjirou-kun, Motoka wants to talk to you."
	DB	NEXT
	DB	"Kenjirou:  O- Okay."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"I take the phone from Akemi-san."
	DB	NEXT
	DB	"Kenjirou:  Hello, Motoka?"
	DB	NEXT
	DB	"Motoka:  Yes." 
	DB	NEXT
	DB	"Kenjirou:  What's wrong? Where are you?"
	DB	NEXT
	DB	"Motoka:  Don't worry about any of that..." 
	DB	T_WAIT,	3
	DB	" C- Can I ask you to do something?"
	DB	NEXT
	DB	"Kenjirou:  S- Sure. Anything."
	DB	NEXT
	DB	"Motoka:  Really?" 
	DB	NEXT
	DB	"Kenjirou:  Sure."
	DB	NEXT
	DB	"Motoka:  I...want you to come meet me in the park now." 
	DB	NEXT
	DB	"Kenjirou:  Okay. I'll be right there."
	DB	NEXT
	DB	"Motoka:  Thanks! I'll be waiting." 
	DB	NEXT
	DB	"I hang up the phone, and go back to the dining kitchen."
	DB	NEXT
	BAK_INIT	'tb_002',B_NORM
	CDPLAY		6
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Akemi:  Fufufu... Where are you off to now?" 
	DB	NEXT
	DB	"Kenjirou:  Oh, nowhere."
	DB	NEXT
	DB	"Akemi:  You don't need to hide it. I approve."
	DB	NEXT
	DB	"Kenjirou:  ..........Um, okay."
	DB	T_WAIT,	3
	DB	" I'm going to walk Motoka back here."
	DB	NEXT
	DB	"Akemi:  Okay. Have fun." 
	DB	NEXT
	DB	"I head out the door."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI	MOT_KOKU,'=',0
	BAK_INIT	'tb_032b',B_NORM
	CDPLAY		8
	T_CG	'tt_21_32b',MOT_A2,0
	DB	"Motoka:  Ah, Oniichan." 
	DB	NEXT
	DB	"Kenjirou:  Hi. "
	DB	NEXT
	DB	"Motoka:  I'm sorry for calling you out here like this." 
	DB	NEXT
	DB	"Kenjirou:  Oh, I don't mind."
	DB	T_WAIT,	3
	DB	" Why didn't you come home yourself, though?"
	DB	NEXT
	TATI_ERS
	T_CG	'tt_21_32b',MOT_B2,0
	DB	"Motoka:  Well, I..."
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Motoka:  I wanted to..."
	DB	NEXT
	DB	"Kenjirou:  Yes?"
	DB	NEXT
	DB	"Kenjirou:  I wanted to spend some time alone with you." 
	DB	NEXT
	DB	"Kenjirou:  W- What? What do you mean...?"
	DB	NEXT
	DB	"I felt my face turning read, but inside, I was happier than I could ever let on."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_21_32b',MOT_A2,0
	DB	"Motoka:  Ah! You're blushing, Oniichan!"
	DB	NEXT
	DB	"Kenjirou:  Your face is red, too."
	DB	NEXT
	DB	"Motoka:  I admit it. It's hard to come out and say it like this." 
	DB	NEXT
	DB	"Kenjirou:  ...Yeah."
	DB	NEXT
	DB	"Motoka:  Oniichan."
	DB	NEXT
	TATI_ERS
	T_CG	'tt_21_32b',MOT_B2,0
	DB	"Motoka looks worried, standing it front of me."
	DB	NEXT
	DB	"Kenjirou:  What is it?"
	DB	NEXT
	DB	"Motoka:  Um, I..."
	DB	T_WAIT,	3
	DB	" Well, I... I want to go somewhere, with you."
	DB	NEXT
	DB	"I know what she means, so well do I know it."
	DB	NEXT
	DB	"Kenjirou:  Are you sure...you won't regret it?"
	DB	NEXT
	DB	"Motoka:  Yes, I'm sure. I won't regret it at all." 
	DB	NEXT
	DB	"We walk a while, and find ourselves standing in front of a love hotel."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_025',B_NORM
	CDPLAY		22
	T_CG	'tt_21_25',MOT_B2,0
	DB	"Motoka:  Oniichan... Let's go in quickly. People are watching us."
	DB	NEXT
	DB	"She pulls my sleeve, as I build up my nerve."
	DB	NEXT
	DB	"Kenjirou:  O- Okay..."
	DB	NEXT
	DB	"It was the first time I'd been in a love hotel. Ignoring my uneasiness, I led her in."
	DB	NEXT
	EVENT_CG	'th_088',B_FADE,46
	CDPLAY		16
	DB	"Motoka:  Wow, I didn't know that these places were this nice on the inside." 
	DB	NEXT
	DB	"Motoka is nervous, too. I can tell."
	DB	NEXT
	DB	"Motoka:  Oniichan?"
	DB	NEXT
	DB	"Kenjirou:  Y- Yes?"
	DB	NEXT
	DB	"Motoka:  Do you love me?"
	DB	NEXT
	DB	"Kenjirou:  Sure I do. Of course."
	DB	NEXT
	DB	"Motoka:  Me, too."
	DB	T_WAIT,	3
	DB	" I love you, I mean."
	DB	NEXT
	DB	"Kenjirou:  Motoka."
	DB	NEXT
	DB	"Motoka:  Mm..."
	DB	NEXT
	DB	"I pulled her to me, and put my lips on hers."
	DB	NEXT
	DB	"Motoka:  Oniichan..." 
	DB	NEXT
	DB	"It was her first kiss, I was pretty sure. Her cheeks turned red, and her eyes wavered with emotion."
	DB	NEXT
	DB	"Kenjirou:  Motoka, open your mouth a little."
	DB	NEXT
	DB	"Motoka:  O- Okay..."
	DB	NEXT
	DB	"Doing as she is told, Motoka opens her mouth slightly."
	DB	NEXT
	DB	"Motoka:  Mm? Mmm..." 
	DB	NEXT
	DB	"I slide my tongue between her lips, into her hot mouth."
	DB	NEXT
	DB	"Motoka:  Mmm....." 
	DB	NEXT
	DB	"My tongue searches the inside of her mouth, and our tongues wind around each other."
	DB	NEXT
	DB	"Motoka:  Fuu..." 
	DB	NEXT
	DB	"Motoka's face is tinted sakura-color, and her eyes are moist with emotion."
	DB	NEXT
	DB	"Kenjirou:  I want you to do what I do."
	DB	NEXT
	DB	"Motoka:  ...Okay."
	DB	NEXT
	DB	"I kiss her for the third time. My tongue goes into her mouth again, and our tongues dance with each other."
	DB	NEXT
	DB	"Motoka:  Oniichan..."
	DB	NEXT
	DB	"A warm, wet sensation assaults me as her tongue follows mine into my own mouth, and the taste of her"
    DB  " is inside me as our saliva mixes freely."
	DB	NEXT
	DB	"Motoka:  *pant pant*" 
	DB	NEXT
	DB	"Without saying anything, I begin to undress Motoka."
	DB	NEXT
	DB	"Motoka:  N- No, Oniichan... I'm too embarrassed..." 
	DB	NEXT
	EVENT_CG	'th_089',B_NORM,47
	DB	"I stood back, drinking in everything about Motoka before in."
	DB	NEXT
	DB	"I put my hand to her crotch, finding her fleshy slit through her white cotton panties."
	DB	NEXT
	DB	"Motoka:  N- No! Not there...!" 
	DB	NEXT
	DB	"She closed her thighs, and pushed my hand away."
	DB	NEXT
	DB	"Kenjirou:  Relax, Motoka. Open your legs."
	DB	NEXT
	DB	"Motoka:  B- But I..." 
	DB	NEXT
	DB	"Kenjirou:  ....................."
	DB	NEXT
	DB	"Wordlessly, I looked at Motoka."
	DB	NEXT
	DB	"Motoka:  .....O- Okay."
	DB	NEXT
	DB	"Slowly, she relaxes the muscles holding her legs together, allowing my hand to slide between them."
	DB	NEXT
	DB	"I stare at the whiteness of her panties, drinking in the view. Slowly, a wet stain appears between her legs."
    DB  " I know she is starting to get wet."
	DB	NEXT
	DB	"I softly touch her pussy through the damp panties."
	DB	NEXT
	DB	"Motoka:  A- Ah..." 
	DB	NEXT
	DB	"As my fingers moves over her slit, the damp stain grows in size."
	DB	NEXT
	DB	"Kenjirou:  Motoka, you're wet."
	DB	NEXT
	DB	"Motoka:  Oniichan, you're such a pervert..." 
	DB	NEXT
	DB	"Even though she's feeling embarrassed to be here with me, she doesn't close her legs, but keeps them open to my touch."
	DB	NEXT
	DB	"I find her clitoris, soaked in her honey, and begin to put it with my finger. Her body moves in reaction, involuntarily."
	DB	NEXT
	DB	"Motoka:  Ah! Ahhhnnn...! O- Oniichan...!" 
	DB	NEXT
	DB	"Kenjirou:  Do you like it?"
	DB	NEXT
	DB	"Motoka:  I- It's such a strange feeling. "
	DB	NEXT
	DB	"Kenjirou:  Have you ever touched yourself here?"
	DB	NEXT
	DB	"Motoka:  Ah! N- No, I haven't..."
	DB	NEXT
	DB	"So she's never masturbated. Still touching her clit through her panties, I decide I want more."
	DB	NEXT
	DB	"I start to stimulate her clit harder, squeezing it between two fingers."
	DB	NEXT
	DB	"Motoka:  Kii...!! Uuu...!!" 
	DB	NEXT
	DB	"Slowly, Motoka falls back onto the bed, as if in slow motion."
	DB	NEXT
	DB	"Motoka:  *pant* *pant*" 
	DB	NEXT
	DB	"With short breath, Motoka stares up at the ceiling, her eyes wide."
	DB	NEXT
	DB	"Kenjirou:  You came."
	DB	NEXT
	DB	"Motoka:  Oniichan..." 
	DB	NEXT
	DB	"Happy with being the first man to give her that, I move to take off her blouse."
	DB	NEXT
	EVENT_CG	'th_090',B_NORM,48
	DB	"Her breasts were larger than I had imagined before, a very nice handful."
	DB	NEXT
	DB	"Kenjirou:  Your breasts... They're big."
	DB	NEXT
	DB	"Motoka:  *pant*  Oniichan..." 
	DB	NEXT
	DB	"I touch a nipple, stiff and hard beneath my finger pad."
	DB	NEXT
	DB	"Motoka:  N- No..."
	DB	NEXT
	DB	"Kenjirou:  They're hard. You're excited."
	DB	NEXT
	DB	"Motoka:  Oniichan, please... Don't say things like that." 
	DB	NEXT
	DB	"I stroke little lines around her nipples with my finger. Then, I turn her on her side, and move my fingers down to her ass."
	DB	NEXT
	DB	"Kenjirou:  Do you always wear grown-up panties like this?"
	DB	NEXT
	DB	"On her stomach now, Motoka turned to me."
	DB	NEXT
	DB	"Motoka:  N- No... Today was kind of special." 
	DB	NEXT
	DB	"So she had known we would end up like this today. She had wanted it to be this way."
	DB	NEXT
	DB	"Without saying anything, I kissed her once. "
	DB	NEXT
	DB	"Kenjirou:  So? Can I see?"
	DB	NEXT
	DB	"I moved my hand to her panties, and waited for her answer."
	DB	NEXT
	DB	"Motoka:  N- No! Don't look!" 
	DB	NEXT
	DB	"Kenjirou:  Why not?"
	DB	NEXT
	DB	"Motoka:  I, I'm just too embarrassed..." 
	DB	NEXT
	DB	"Kenjirou:  I want to see it. I want to see your private place."
	DB	NEXT
	DB	"Motoka:  No! If you look at it, I'll hate you forever." 
	DB	NEXT
	DB	"Kenjirou:  I don't mind."
	DB	NEXT
	DB	"Motoka:  What?" 
	DB	NEXT
	DB	"Kenjirou:  Even if you decide you hate me, I'll still love you. Forever..."
	DB	NEXT
	DB	"Motoka:  O- Oniichan..." 
	DB	NEXT
	DB	"Ignoring her warning, I started to pull her panties off."
	DB	NEXT
	DB	"Motoka:  N- No!"
	DB	NEXT
	DB	"Her slit was closed and perfect, covered by a tuft of pubic hair."
	DB	NEXT
	DB	"Kenjirou:  Motoka... This is so..."
	DB	NEXT
	DB	"Motoka:  D- Don't look, please..." 
	DB	NEXT
	DB	"Tears appeared in her eyes, as she pleaded with me."
	DB	NEXT
	DB	"I wondered what made her want to shave her hair off. It must have been a delicate thing for her, I knew."
	DB	NEXT
	DB	"Kenjirou:  Motoka, you're beautiful."
	DB	NEXT
	DB	"Motoka:  No!" 
	DB	NEXT
	DB	"I looked at her pussy, at the pink flesh poking out from her perfect slit, and the smooth flesh around."
	DB	NEXT
	DB	"Motoka:  Don't look, please. Please..." 
	DB	NEXT
	DB	"Kenjirou:  Motoka... You look delicious."
	DB	NEXT
	DB	"Motoka:  Ahh!!" 
	DB	NEXT
	DB	"I opened her legs, and buried my face in her hairless slit."
	DB	NEXT
	DB	"Motoka:  Ah... Don't... Don't do that..." 
	DB	NEXT
	DB	"Kenjirou:  Why not?"
	DB	NEXT
	DB	"Motoka:  I- It's dirty..."
	DB	NEXT
	DB	"Kenjirou:  There's not a single dirty place on your body, Motoka."
	DB	NEXT
	DB	"Saying that, I slid my tongue into her virgin slit."
	DB	NEXT
	DB	"Motoka:  Kyaa!" 
	DB	NEXT
	DB	"My tongue went up into her, as far as I could, tasting her juice inside."
	DB	NEXT
	DB	"Motoka:  Oniichan! Stop, you're... You're..." 
	DB	NEXT
	DB	"Kenjirou:  What's this, anyway?"
	DB	NEXT
	DB	"Motoka:  Oh, I can't believe you!" 
	DB	NEXT
	DB	"She shut up then, but kept moaning as my tongue moved over her pussy."
	DB	NEXT
	DB	"I stopped licking her slit now, and moved up to her clitoris. It was hard beneath my tongue."
	DB	NEXT
	DB	"Motoka:  *pant*  Oniichan, that's... That's so strange..." 
	DB	NEXT
	DB	"I tickled her clitoris lightly with the tip of my tongue, tasting it."
	DB	NEXT
	DB	"Now, Motoka began to move her hips in opposition to my tongue, as her excitement increased."
	DB	NEXT
	DB	"Motoka:  T- That tickles..." 
	DB	NEXT
	DB	"Kenjirou:  Motoka, I love your pussy. It's... It's great."
	DB	NEXT
	DB	"Motoka:  D- Don't say perverted things like that..." 
	DB	NEXT
	DB	"I slid my tongue inside her pussy again, tasting the slightly salty ion taste of her lubricant."
	DB	NEXT
	DB	"Motoka:  Oniichan... I feel... so strange." 
	DB	NEXT
	DB	"Kenjirou:  That's normal."
	DB	T_WAIT,	3
	DB	" Do you want to do it now?"
	DB	NEXT
	DB	"She said nothing, but nodded once."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"I moved her so that she was on her knees, and pulled her panties all the way off."
	DB	NEXT
	DB	"I moved around to her front, and licked her pink slit some more."
	DB	NEXT
	DB	"Motoka:  Ah..." 
	DB	NEXT
	EVENT_CG	'th_091a',B_NORM,49
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_091a","th_091b",0,0,0,EVENT_YSIZE
	SCR_END
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_091a","th_091b",0,EVENT_YSIZE,0,0
	SCR_END
	DB	"Kenjirou:  Motoka, are you sure it's okay?"
	DB	NEXT
	DB	"Motoka:  Y- Yes." 
	DB	NEXT
	DB	"I moved around behind her."
	DB	NEXT
	DB	"Motoka:  Eh? You're going to do it from behind? I don't want to..." 
	DB	NEXT
	DB	"Kenjirou:  This is your first time, right?"
	DB	NEXT
	DB	"Motoka:  Y- Yes, but..."
	DB	NEXT
	DB	"Kenjirou:  They say it's less painful for her girl to do it this way her first time."
	DB	NEXT
	DB	"Motoka:  ...Okay. I'll trust you." 
	DB	NEXT
	DB	"I put my rock-hard cock against the doorway to Motoka's pussy, and pushed it in a centimeter or so."
	DB	NEXT
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET "th_091a","th_091b",0,0,0,EVENT_YSIZE
	SCR_END
	DB	"Wow! This is going to be tight!"
	DB	NEXT
	DB	"Motoka:  ...Ow!" 
	DB	NEXT
	DB	"The tip of my cock was inside her, but I knew from the tension that it would be hard to push in any further."
	DB	NEXT
	DB	"Motoka:  T- That hurts... I feel like I'm going to tear." 
	DB	NEXT
	DB	"As if to underscore her words, her pussy held my cock from going in any further."
	DB	NEXT
	DB	"Kenjirou:  Motoka, you have to relax a little more..."
	DB	NEXT
	DB	"Motoka:  I- I'm sorry..." 
	DB	NEXT
	DB	"She tried to relax, but thee pain kept her from doing s completely."
	DB	NEXT
	DB	"What should I do?"
	DB	T_WAIT,	3
	DB	"I've got to find a way to take her mind off the pain inside her."
	DB	NEXT
	DB	"I put some spit on my finger, then slid it all the way inside her pussy."
	DB	NEXT
	DB	"Motoka:  Oniichan...?"
	DB	NEXT
	DB	"I used my finger to probe the inside of her, finding her internal organs from the inside."
	DB	NEXT
	DB	"Motoka:  S- Stop that! My stomach feels so strange..." 
	DB	NEXT
	DB	"Now I slid two fingers deep inside her pussy, to get her used to the feeling."
	DB	NEXT
	DB	"Quickly, I removed my fingers, and put my cock inside her instead."
	DB	NEXT
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET "th_091a","th_091b",0,EVENT_YSIZE,0,0
	SCR_END
	DB	"Motoka's pussy received my member, although with some difficulty. I broke through the flesh keeping her closed,"
           DB  " and was inside her."
	DB	NEXT
	DB	"Motoka:  Hiii!! Oniichan...!!" 
	DB	NEXT
	DB	"Kenjirou:  It's in."
	DB	NEXT
	DB	"Wanting to calm her, I kissed her on the ear."
	DB	NEXT
	DB	"Motoka:  Ahh...aaahn..." 
	DB	NEXT
	DB	"Motoka was still in a lot of pain. Tears appeared in her eyes."
	DB	NEXT
	DB	"This is pretty hard. I don't think I'll be able to move inside her much."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"Motoka:  Hii!!" 
	DB	NEXT
	DB	"I wanted to move inside her, and satisfy my animal lust, but I knew it would hurt Motoka terribly."
    DB  " I decided I would have to give up."
	DB	NEXT
	DB	"Just then, the beautiful sight of Motoka, enduring such pain so that she could give herself to me,"
    DB  " coupled with my own sexual excitement, and I came. White semen boiled up."
	DB	NEXT
	DB	"Kenjirou:  Uuuu!!"
	DB	NEXT
	MC_FLASH	3,C_SIRO
	B_O	B_FADE,C_SIRO
	FLG_KI	YOKU,'=',0
	FLG_KI	MOT_YATT,'=',1
	F_O	B_NORM,C_KURO
	DB	"Afterwards, we took a shower and left the hotel."
	DB	NEXT
	BAK_INIT	'tb_025',B_FADE
	CDPLAY		19
	T_CG	'tt_10_25',MOT_A2,0
	DB	"Motoka:  I became a woman today." 
	DB	NEXT
	DB	"Kenjirou:  D- Don't say things like that. Someone might overhear."
	DB	NEXT
	DB	"Kenjirou:  Sorry."
	DB	NEXT
	DB	"Kenjirou:  Let's go home. Akemi-san must be worried."
	DB	NEXT
	DB	"Motoka:  Okay."
	DB	NEXT
	DB	"I started to walk, but she didn't follow."
	DB	NEXT
	DB	"Kenjirou:  What's wrong?"
	DB	NEXT
	TATI_ERS
	T_CG	'tt_21_25',MOT_B2,0
	DB	"Motoka:  Oniichan... It kind of hurts to walk." 
	DB	NEXT
	DB	"Kenjirou:  ...Climb on."
	DB	NEXT
	DB	"I got down so that she could climb onto my back."
	DB	NEXT
	DB	"Motoka:  Eh?" 
	DB	NEXT
	DB	"Kenjirou:  I'll carry you. It's the least I could do, since I'm the one who hurt you."
	DB	NEXT
	DB	"Motoka:  Thanks..." 
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"She climbed onto my back, and I hefted her up."
	DB	NEXT
	DB	"Motoka:  Oniichan..." 
	DB	NEXT
	DB	"Kenjirou:  What is it?"
	DB	NEXT
	DB	"Motoka:  ...Your back... It feels so strong..." 
	DB	NEXT
	DB	"Kenjirou:  Really? I think it's a normal back."
	DB	NEXT
	DB	"I carried Motoka home."
	DB	NEXT
	FLG_IF	AKE_YARU,'=',1,OYAKO
	FLG_IF	RISA_SYO,'=',1,KOUKAI
	B_O B_FADE,C_KURO
	BAK_INIT	'tb_001b',B_NORM
	CDPLAY		12
	DB	"Wow, that a wild turn of events..."
	DB	NEXT
	DB	"I'm glad that I lost my virginity with Motoka."
	DB	NEXT
	DB	"*Yawn*  Guess I'll get to sleep."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	SINARIO	'MON_48.OVL'
	DB	EXIT
OYAKO:
	DB	"Wow, what an amazing turn of events. Who would have thought that we would actually do it."
	DB	NEXT
	DB	"I hope that Akemi-san doesn't say anything to us about it."
	DB	NEXT
	DB	"*Yawn* Guess I'll get to sleep..."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	FLG_KI	HIDUKE,'+',1
	SINARIO	'MON_48.OVL'
	DB	EXIT
KOUKAI:
	DB	"I wish I hadn't done what I did with Risa..."
	DB	NEXT
	DB	"Oh well. There's nothing I can do about it now."
	DB	NEXT
	DB	"*Yawn*  Guess I'll get to sleep now..."
	DB	NEXT
	B_O	B_FADE,C_KURO
	CDPLAY		0
	FLG_KI	HIDUKE,'+',1
	SINARIO	'MON_48.OVL'
	DB	EXIT
END