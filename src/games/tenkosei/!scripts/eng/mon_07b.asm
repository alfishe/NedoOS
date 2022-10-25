        include SUPER_C.inc
M_START:
MON_07B
	BAK_INIT 'tb_009',B_NORM
	CDPLAY	2
	DB	"I leave where Terumi-senpai is standing, and head for the train. With luck, I should make it to school in plenty of time."
	DB	NEXT
	DB	"I feel sorry for what I did to Terumi-senpai. Well, thanks to my coming along, I've got some extra time to get to school."
	DB	NEXT
	DB	"Kenjirou:  Uu! W- What...?"
	DB	NEXT
	DB	"My stomach... It really hurts!"
	DB	NEXT
	DB	"All of the sudden, an excruciating pain assaulted my stomach area. I doubled over with pain."
	DB	NEXT
	DB	"Kenjirou:  I can't (I can't hold it...!)"
	DB	NEXT
	DB	"Slowly, I head for the station's men's room. "
	DB	NEXT
	F_O B_NORM,C_KURO
	CDPLAY	0
	DB	"Reaching the bathroom just in time, I sit down on the toilet and relax my muscles."
	DB	NEXT
	DB	"Kenjirou:  Ahhh... (This is really bad, sitting in a dirty public toilet like this...)"
	DB	NEXT
	DB	"Kenjirou:  Uuuu... (Well, it's better than wetting my pants in front of everyone.)"
	DB	NEXT
	DB	"Kenjirou:  Fuu... (Well, I'd better get off to school.)"
	DB	NEXT
	DB	"I end my time of relaxation, and leave the stall."
	DB	NEXT
	BAK_INIT 'tb_017a',B_NORM
	CDPLAY	2
	DB	"I turn the handle of the sink, and wash my hands."
	DB	NEXT
	DB	"I'd really better get to school now. I'm going to be late."
	DB	NEXT
	DB	"I wipe my hands on my handkerchief, and exit the men's room."
	DB	NEXT
	SINARIO 'MON_08.OVL'
END