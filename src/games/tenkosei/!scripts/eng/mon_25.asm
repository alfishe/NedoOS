        include SUPER_C.inc
M_START:
MON_25
	BAK_INIT	'tb_018a',B_NORM
	CDPLAY	2
	DB	"Well, I'm here, but..."
	DB	NEXT
	DB	"I have no idea how to go about finding Motoka."
	DB	NEXT
	T_CG	'tt_03_18a',HIR2,0
	DB	"Hiroshi:  Huh?"
	DB	T_WAIT,	2
	DB	" Oh, it's you, Kondo. What are you doing out here?"
	DB	NEXT
	DB	"Ugh, it's Hiroshi!"
	DB	NEXT
	DB	"Kenjirou:  I'm just hanging around. How about you?"
	DB	NEXT
	DB	"Hiroshi:  Me? I'm looking for your little sister. "
	DB	T_WAIT,	3
	DB	" Do you know where she is?"
	DB	NEXT
	DB	"He's looking for her too!"
	DB	NEXT
	DB	"Kenjirou:  No, no idea. "
	DB	NEXT
	DB	"Hiroshi:  Oh."
	DB	NEXT
	DB	"Even if I knew, I wouldn't tell you!"
	DB	NEXT
	DB	"Kenjirou:  Why are you looking for her, anyway?"
	DB	NEXT
	DB	"Hiroshi:  Eh? Oh, I just wanted to talk to her, maybe ask her out or something."
	DB	NEXT
	DB	"Kenjirou:  That's nice. But why don't you ask some other girl out instead?"
	DB	NEXT
	DB	"Hiroshi:  Well, I could..."
	DB	T_WAIT,	3
	DB	" But you know, Motoka is just so damned cute."
	DB	NEXT
	DB	"Kenjirou:  ................."
	DB	NEXT
	DB	"Hiroshi:  I mean, I just can't keep my hands off her."
	DB	NEXT
	DB	"Kenjirou:  Aren't you going out with Tachikawa?"
	DB	NEXT
	DB	"Hiroshi:  Oh, Risa?"
	DB	T_WAIT,	2
	DB	" Well, yes, but it's really just for fun."
	DB	NEXT
	DB	"Kenjirou:  For fun...?"
	DB	NEXT
	DB	"Hiroshi:  Well, I'll see you later. Let me know if you see Motoka."
	DB	NEXT
	TATI_ERS
	DB	"That fucking jerk! He's going for Motoka, trying to add her to his collection of women. I've got to find her."
	DB	NEXT
	DB	"However, I still don't know where she could be."
	DB	NEXT
	DB	"Tetsuya said he saw her hanging out with some bad people, street punks or something."
	DB	NEXT
	DB	"Kenjirou:  Street punks...?"
	DB	NEXT
	DB	"I remember now. Last spring I saw some people like that at the coffee shop quite a bit."
	DB	NEXT
	DB	"Maybe I should go check it out..."
	DB	NEXT
	FLG_KI W,'=',-1
	MENU_S	1,W,-1
	MENU_SET	IKU,"GO THERE NOW"
	MENU_SET	IKANAI,"DON'T GO"
	MENU_END
	DB	EXIT
IKU:
	DB	"It's something, at least. Maybe I'll get lucky and find out something."
	DB	NEXT
	SINARIO	'MON_26.OVL'
	DB	EXIT
IKANAI:
	DB	"Naw, it's a waste of time. The owner of the shop told me those kids are only there during vacation, for the most part. "
	DB	NEXT
	SINARIO	'MON_27.OVL'
	DB	EXIT
END