        include SUPER_C.inc
M_START:
MON_20
	CDPLAY	2
	BAK_INIT 'tb_005c',B_NORM
	DB	"Ah, it's good to be home..."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		6
	T_CG 'tt_20_02',AKE_A2,0
	DB	"Kenjirou:  I'm home."
	DB	NEXT
	DB	"Akemi:  Welcome home."
	DB	NEXT
	DB	"Kenjirou:  Huh? Where's Motoka?"
	DB	NEXT
	DB	"Akemi:  She's not home yet." 
	DB	NEXT
	DB	"Kenjirou:  I see. (That's odd of her to be this late.)"
	DB	NEXT
	DB	"Akemi:  Are you ready for dinner?"
	DB	NEXT
	DB	"Kenjirou:  Let's wait a little while longer, for Motoka to come home."
	DB	NEXT
	DB	"Akemi:  Okay."
	DB	NEXT
	B_O B_FADE,C_KURO
	DB	"Two hours later..."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	T_CG 'tt_20_02',AKE_A2,0
	DB	"*Growl*"
	DB	NEXT
	DB	"My stomach is growling, like a monster's living inside."
	DB	NEXT
	DB	"Akemi:  Let's eat dinner already."
	DB	NEXT
	DB	"Kenjirou:  Let's wait just a little longer."
	DB	NEXT
	DB	"*Growl! Growl!*"
	DB	NEXT
	DB	"The monster in my stomach roars again."
	DB	NEXT
	DB	"Akemi:  You're a stubborn one." 
	DB	NEXT
	DB	"Kenjirou:  I am?"
	DB	NEXT
	DB	"Akemi:  Well I'm starving..."
	DB	NEXT
	DB	"Kenjirou:  Me, too."
	DB	NEXT
	DB	"Akemi:  So let's eat!" 
	DB	NEXT
	DB	"Kenjirou:  ...Okay."
	DB	NEXT
	DB	"The two of us enjoy a quiet dinner. Not having Motoka with us makes me kind of sad."
	DB	NEXT
	B_O B_FADE,C_KURO
	BAK_INIT 'tb_001b',B_NORM
	CDPLAY		12
	DB	"The clock told us it was past eleven. Motoka still wasn't home."
	DB	NEXT
	DB	"Kenjirou:  That girl..."
	DB	NEXT
	DB	"I turned out the light, and got under the blankets."
	DB	NEXT
	F_O	B_NORM,C_KURO
	CDPLAY		0
	DB	"For some reason, the sound of the second hand on the clock seemed louder than it had ever been."
	DB	NEXT
	DB	"Tetsuya:  It's about your sister..." 
	DB	NEXT
	DB	"Kenjirou:  ................................."
	DB	NEXT
	DB	"Tetsuya:  I hear she's been running around with some bad friends, these days." 
	DB	NEXT
	DB	"Kenjirou:  ................................."
	DB	NEXT
	DB	"I know that's not what this is about. Not Motoka."
	DB	NEXT
	DB	"Just then, I heard a sound coming from the foyer. I dashed out of the bed and flew downstairs."
	DB	NEXT
	DB	"Kenjirou:  Motoka?"
	DB	NEXT
	DB	"On my way downstairs, I noticed there was a light on in the dining kitchen. I strained to look inside."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	CDPLAY		20
	T_CG 'tt_21_02',MOT_A2,0
	DB	"Kenjirou:  Motoka."
	DB	NEXT
	DB	"Motoka:  ...I'm home."
	DB	NEXT
	DB	"Kenjirou:  .........."
	DB	T_WAIT, 3
	DB	"Is that all you have to say?"
	DB	NEXT
	DB	"Motoka:  ................................." 
	DB	NEXT
	DB	"Kenjirou:  Just what time do you think it is?"
	DB	NEXT
	DB	"I pointed to a clock on the wall. It showed half past twelve."
	DB	NEXT
	DB	"Kenjirou:  Where were you?"
	DB	NEXT
	DB	"Motoka:  ...It's nothing you need to worry about..." 
	DB	NEXT
	DB	"Kenjirou:  What...?"
	DB	NEXT
	DB	"Motoka:  I said, it's no concern of yours!" 
	DB	NEXT
	DB	"Her voice was loud and high-pitched, almost hysteric."
	DB	NEXT
	DB	"Motoka:  I can go wherever I want, see whoever I want. It has nothing to do with you." 
	DB	NEXT
	DB	"Kenjirou:  That's not true. We're brother and sister."
	DB	NEXT
	DB	"I put a hand on her shoulder."
	DB	NEXT
	DB	"Motoka:  ...We're not even, even related by blood..." 
	DB	NEXT
	DB	"With that, she ran away from me, darting upstairs to her room."
	DB	NEXT
	DB	"Kenjirou:  What the hell...?"
	DB	T_WAIT, 5
	DB	" I can't figure that girl out."
	DB	NEXT
	TATI_ERS
	T_CG 'tt_20_02',AKE_A2,0
	CDPLAY		6
	DB	"Akemi:  What's wrong?"
	DB	NEXT
	DB	"Kenjirou:  It's nothing."
	DB	NEXT
	DB	"Akemi:  Okay, then."
	DB	T_WAIT, 3
	DB	" Motoka came home after all."
	DB	NEXT
	DB	"Kenjirou:  Yes, she did."
	DB	T_WAIT, 3
	DB	" Well, I'll see you in the morning. I'm going to bed."
	DB	NEXT
	DB	"Akemi:  Good night." 
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY		0
	DB	"I went back to my room, and somehow managed to go to sleep."
	DB	NEXT
	B_O B_FADE,C_KURO
	FLG_KI	HIDUKE,'+',1
	SINARIO 'MON_21.OVL'
END