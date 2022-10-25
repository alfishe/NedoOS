        include SUPER_C.inc
M_START:
MON_32
	BAK_INIT	'tb_002',B_NORM
	CDPLAY	6
	DB	"Akemi:  Akemi-san."
	DB	NEXT
	T_CG	'tt_20_02',AKE_A2,0
	DB	"Akemi:  Kenji-kun, dinner's ready." 
	DB	NEXT
	DB	"Kenjirou:  Thanks. Is someone here in the house? I heard some talking coming from the living room."
	DB	NEXT
	DB	"Akemi:  Just Motoka and her friend."
	DB	NEXT
	DB	"Kenjirou:  Motoka's back?"
	DB	NEXT
	DB	"Akemi:  Yes, a while ago. She stayed at a friend's house last night, it seems."
	DB	NEXT
	DB	"Kenjirou:  A friend's house..."
	DB	NEXT
	DB	"Akemi:  Yes, that's right. I just got off the phone with her friend. "
	DB	NEXT
	DB	"Kenjirou:  Is that friend a man?"
	DB	NEXT
	DB	"Akemi:  No, it's not. It's a girl." 
	DB	NEXT
	DB	"Kenjirou:  I see."
	DB	NEXT
	DB	"Akemi:  But a male friend is coming over today."
	DB	NEXT
	DB	"Kenjirou:  A...man?"
	DB	NEXT
	DB	"Akemi:  Yes, and he's supposedly quiet handsome. That's why Motoka was so excited."
	DB	NEXT
	DB	"Handsome? I wonder who it could be?"
	DB	NEXT
	SINARIO	'MON_33.OVL'
	DB	EXIT
END