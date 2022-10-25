        include SUPER_C.inc
M_START:
MON_06
	F_O B_NORM,C_KURO
	DB	"*BEEP BEEP BEEP*........ (five minutes later) *BEEP BEEP BEEP*........ (five minutes later)"
    DB  " *BEEP BEEP BEEP*........ (five minutes later) *BEEP BEEP BEEP*........ (five minutes later) "
	DB	NEXT
	DB	"Kenjirou:  S- Shut up, you!"
	DB	NEXT
	BAK_INIT 'tb_001a',B_NORM
	CDPLAY	12
	DB	"Kenjirou:  Ah..."
	DB	NEXT
	DB	"I looked at the clock. I had woken up much later than I usually do."
	DB	NEXT
	DB	"Kenjirou:  O- Oh no..."
	DB	NEXT
	DB	"I quickly got dressed and went into the dining kitchen."
	DB	NEXT
	BAK_INIT 'tb_002',B_NORM 
	CDPLAY	6
	T_CG 'tt_20_02',AKE_A2,0 
	DB	"Akemi:  Ah, you're finally up." 
	DB	NEXT
	DB	"Kenjirou:  A- Akemi-san, why didn't you wake me up?"
	DB	NEXT
	DB	"Akemi:  I tried, several times. But you wouldn't get out of bed."
	DB	NEXT
	DB	"Kenjirou:  O- Okay. I'm off to school now."
	DB	NEXT
	DB	"With that, I ran out of the dining kitchen. I didn't have time to stand there talking with Akemi-san."
	DB	NEXT
	DB	"Akemi:  See you later." 
	DB	NEXT
	BAK_INIT 'tb_006',B_NORM
	CDPLAY	2
	DB	"Kenjirou:  Guess I won't have any lunch today."
	DB	NEXT
	DB	"I look at the convenience store, and run past."
	DB	NEXT
	CDPLAY	3
	DB	"Voice:  Kenjirou!"
	DB	NEXT
	DB	"It's a voice I've heard before. I look around to see Terumi-senpai, standing in front of the convenience store."
	DB	NEXT
	
	T_CG 'tt_05_06',TER2,0
	DB	"Kenjirou:  Ah, Terumi-senpai..."
	DB	NEXT
	DB	"Terumi:  Kenjirou, aren't you going to say good morning to me?"
	DB	NEXT
	DB	"Kenjirou:  Eh? Oh, good morning."
	DB	NEXT
	DB	"Terumi:  Good morning. Will you be able to make it to school in time?"
	DB	NEXT
	DB	"Kenjirou:  That's why I'm hurrying to school. Don't I look like I'm in a hurry?"
	DB	NEXT
	DB	"Terumi:  No, you look like you're just walking normally."
	DB	NEXT
	DB	"Kenjirou:  ...Anyway, I am in a hurry. You should hurry, too, or you'll be late."
	DB	NEXT
	DB	"Terumi:  Yes, that's right. Let's go together."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S 1,W,-1
	MENU_SET	B1,"GO WITH HER"
	MENU_SET	B2,"GO ALONE"
	MENU_END
	DB	EXIT
B1:
	DB	"Kenjirou:  Okay, let's get moving."
	DB	NEXT
	DB	"Terumi:  Okay, okay."
	DB	NEXT
	DB	"Terumi-senpai and I hurry off for school."
	DB	NEXT
	SINARIO 'MON_07A.OVL'
B2:
	DB	"If I go to school with her, I'll never get there on time. I doubt if we'll be able to make it to school before lunchtime."
	DB	NEXT
	DB	"Kenjirou:  I'm sorry, I've got to go..."
	DB	NEXT
	DB	"I dash away, heading for the station."
	DB	NEXT
	F_O B_NORM,C_KURO
	DB	"Terumi:  Wait!" 
	DB	NEXT
	DB	"I hear her voice behind me, but run on, without looking back. She doesn't follow me."
	DB	NEXT
	DB	"I'll probably catch hell for this, next time I see her."
	DB	NEXT
	SINARIO 'MON_07B.OVL'
END