        include SUPER_C.inc
M_START:
MON_08
	BAK_INIT 'tb_009',B_NORM
	DB	"Just as I exit the men's room, a dark shadow washes over me."
	DB	NEXT
	;WAV		'Se_at1'
	EVENT_CG 'ti_108',B_NORM,82
	DB	GATA,	1
	DB	"Kenjirou:  Uu!!"
	DB	NEXT
	DB	"The strange shadow assaults my mind, making me dizzy with fear."
	DB	NEXT
	DB	"Voice:  You're here..."
	DB	NEXT
	CDPLAY	23
	F_O B_NORM,C_KURO
	DB	"My eyes go dark, unseeing, and I start to lose my balance, but I don't fall."
    DB  " I look up and see the transfer student, or the girl from my fantasy world -- Shiho Kashima. "
	DB	NEXT
	EVENT_CG 'ti_006',B_NORM,72
	DB	"Shiho:  You've got to watch where you're going. You should be more careful."  
	DB	NEXT
	DB	"She looked at me, and looked into my soul."
	DB	NEXT
	DB	"Kenjirou:  I- I'm sorry!"
	DB	NEXT
	DB	"Unable to say anything more than that, I just stared dumbly. "
	DB	NEXT
	DB	"Shiho:  Ah... Kondo-kun..."
	DB	NEXT
	DB	"Kenjirou:  Eh?"
	DB	NEXT
	DB	"She started again, shyly."
	DB	NEXT
	DB	"Shiho:  Um... You should be more careful when you walk. You make me worry about you. Well, I'm going to go to school now." 
	DB	NEXT
	BAK_INIT 'tb_009',B_NORM
	DB	"With that, she walked quickly away."
	DB	NEXT
	DB	"Kenjirou:  Why did she know my...?"
	DB	NEXT
	DB	"Well, I'm sure she heard my name from one of the other classmates. It probably means they were gossiping about me."
	DB	NEXT
	DB	"That's why she was in a hurry to get to school like that."
	DB	NEXT
	DB	"I wonder what those girls were saying about me?"
	DB	NEXT
	DB	"I look at the clock. It's almost time for class to start."
	DB	NEXT
	DB	"Kenjirou:  Geh! I was woolgathering again!"
	DB	NEXT
	DB	"I hurriedly rushed off to school."
	DB	NEXT
	SINARIO 'MON_09.OVL'
END