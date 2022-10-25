        include SUPER_C.inc
M_START:
MON_02
	F_O	B_NORM,C_KURO
	;WAV	'Se_no'
	DB	"I hear a wet sound in my ear."
	DB	NEXT
	DB	"Motoka:  Oniichan, good morning!" 
	DB	NEXT
	DB	"Kenjirou:  Uu!!"
	DB	NEXT
	DB	"I turn my body towards the wall, as white come pumps out of my cock and leaks, slowly touching the wall."
	DB	NEXT
	CDPLAY		12
	BAK_INIT 'tb_001a',B_NORM
	T_CG 'tt_10_01',MOT_A2,0
	DB	"Motoka:  Huh?"
	DB	NEXT
	DB	"Kenjirou:  (Oh no! This is terrible!) Mmm..."
	DB	NEXT
	DB	"Motoka:  Oniichan, wake up!"
	DB	NEXT
	DB	"Motoka:  If you don't wake up, I'll pull that blanket off of you!" 
	DB	NEXT
	DB	"She moved closer to me, ready to pull the blanket off and expose my morning secret. I've got to do something!"
	DB	NEXT
	DB	"Kenjirou:  Huh? Motoka? Oh, good morning."
	DB	NEXT
	DB	"I slowly start to get out of bed."
	DB	NEXT
	DB	"Motoka:  You've got to hurry! We'll both be late!" 
	DB	NEXT
	DB	"She stood up, and started pulling on the blanket."
	DB	NEXT
	DB	"Kenjirou:  I know, I know. I'm getting up, so get out of here."
	DB	NEXT
	DB	"Motoka:  You always say that, but you just go back to sleep."
	DB	NEXT
	DB	"She pulled harder on the blanket. My secret was about to be found out!"
	DB	NEXT
	DB	"Kenjirou:  Motoka, I'll get up, I promise. Please give me some privacy."
	DB	NEXT
	DB	"Motoka:  Why? I'm worried that you won't get up." 
	DB	NEXT
	DB	"Kenjirou:  Trust me on this, please!"
	DB	NEXT
	DB	"Motoka:  Eh?"
	DB	NEXT
	DB	"Motoka:  ...Anyway, come down soon, okay?"
	DB	NEXT
	TATI_ERS
	DB	"She says that shyly, then leaves."
	DB	NEXT
	DB	"I've got to clean this up quickly... Damn Motoka for coming in here like that."
	DB	NEXT
	DB	"I'll get dressed, then go down for breakfast."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM
	T_CG 'tt_10_02',MOT_A3,0
	T_CG 'tt_20_02',AKE_A1,0
	CDPLAY		9
	DB	"Akemi:  Good morning, Kenjirou-kun."
	DB	NEXT
	DB	"Kenjirou:  Good morning, Akemi-san."
	DB	NEXT
	DB	"Motoka's here, next to Akemi-san. She's my father's new wife, my step-mother."
    DB  " Motoka is Akemi-san's daughter, so she's not related to me directly."
	DB	NEXT
	DB	"I was a little worried about becoming brother and sister with Motoka, when I first met her."
    DB  " She's got a very friendly personality, but she comes on a little strong. "
	DB	NEXT
	DB	"I've never thought of her while beating off. I've wanted to, but it's always been something I couldn't bring myself to do."
	DB	NEXT
	DB	"However, I can't think of Akemi-san as my mother, and can never call her 'mother.' She's just too sexy for that."
	DB	NEXT
	DB	"She calls me Kenjirou-kun, which makes me feel like her son, somewhat."
	DB	NEXT
	DB	"Motoka:  Oniichan, what are you woolgathering like that for? Hurry up and eat."
	DB	NEXT
	DB	"Akemi:  Motoka made breakfast today. It's just fried eggs, though."
	DB	NEXT
	DB	"Motoka:  Hehe, how's it taste?"
	DB	NEXT
	DB	"She eagerly watches me as I start to eat the eggs."
	DB	NEXT
	DB	"Motoka:  Is it good?"
	DB	NEXT
	DB	"Kenjirou:  Mm, very good."
	DB	NEXT
	DB	"She smiles brightly. Just the fact of being told that her eggs taste good is enough to make her happy"
    DB  " -- what a cheerful person. "
	DB	NEXT
	DB	"After breakfast, I have a cup of coffee. Motoka moves closer to me, as if she's got something to say."
	DB	NEXT
	TATI_ERS	;Tt_10 
	T_CG 'tt_10_02',MOT_B2,0
	DB	"Motoka:  Oniichan? Let's walk to school together, okay?" 
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	A1,"GO WITH HER"
	MENU_SET	A2,"GO ALONE"
	MENU_END
	DB	EXIT
A1:
	DB	"Kenjirou:  Okay, let's go together."
	DB	NEXT
	;REM TATI_ERS
	;REM T_CG 'tt_10',MOT_A2,0
	DB	"Motoka:  Really?" 
	DB	NEXT
	DB	"She beams, happy again. She pulls on my sleeve and heads for the door. I feel like her real brother."
	DB	NEXT
	SINARIO 'MON_03A.OVL'
A2:
	DB	"Kenjirou:  Sorry, but I want to go alone." 
	DB	NEXT
	T_CG 'tt_21_02',MOT_B2,0
	DB	"Motoka:  Hrmph! Why?" 
	DB	NEXT
	DB	"Kenjirou:  Walking to school with my sister? It's not very cool. Don't you think so?"
	DB	NEXT
	CDPLAY		20
	DB	"Motoka:  ...I guess so." 
	DB	NEXT
	DB	"She looks sad. I wonder if I hadn't said too much. "
	DB	NEXT
	DB	"Kenjirou:  Motoka, I'm sorry."
	DB	NEXT
	DB	"Motoka:  Eh? Oh, it's okay. I'll be off to school, then."
	DB	NEXT
	TATI_ERS
	DB	"She leaves the house."
	DB	NEXT
	SINARIO 'MON_03B.OVL'
END