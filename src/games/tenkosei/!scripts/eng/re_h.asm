        include SUPER_C.inc
M_START:
RE_H
	CDPLAY	7
	F_O	B_NORM,C_KURO
	DB	"Kenjirou:  I promised to stop at kissing..."
	DB	NEXT
	DB	"Kenjirou:  ......................."
	DB	NEXT
	DB	"Kenjirou:  When a girl kisses a guy, he wants to go all the way, of course."
	DB	NEXT
	EVENT_CG	'th_080',B_NORM,40
	DB	"Kenjirou:  .............................."
	DB	NEXT
	EVENT_CG	'th_081',B_NORM,41
	DB	"Kenjirou:  .............................."
	DB	NEXT
	DB	"Kenjirou:  ...Mmm, I wanted to do more..."
	DB	NEXT
	DB	"............"
	DB	NEXT
	DB	" Damn, that didn't turn out well."
	DB	NEXT
	F_O	B_NORM,C_KURO
	DB	"Rena:  ......" 
	DB	T_WAIT, 3
	DB	"Ah..."
	DB	NEXT
	EVENT_CG	'th_082',B_NORM,42
	DB	"I'm in Rena's room. We're taking up where we left off before."
	DB	NEXT
	DB	"Rena:  Kenjirou, no..." 
	DB	NEXT
	DB	"Kenjirou:  It's too late to say that now."
	DB	NEXT
	DB	"Opening the zipper in her pants, I touch her Mound of Venus through the softness of her panties."
	DB	NEXT
	DB	"Rena:  Ah, I can't believe I'm doing this... Close the curtains, at least." 
	DB	NEXT
	DB	"Kenjirou:  Close them if you want to."
	DB	NEXT
	DB	"With that, I started licking her fleshy slit through her panties."
	DB	NEXT
	DB	"Rena:  ...No! That's too, too..." 
	DB	NEXT
	DB	"Quivering with new pleasure, Rena forgot about the open curtains."
	DB	NEXT
	DB	"Rena:  ...No.... It's too good..." 
	DB	NEXT
	DB	"Her panties were now thoroughly wet with a substance that wasn't my saliva. "
        DB      "I parted them and slid my tongue past her hard clit and into her warm slit."
	DB	NEXT
	DB	"Rena:  Aaaahhhh!!" 
	DB	NEXT
	DB	"Unable to move, Rena lies back on the bed. I reach up and pet her breasts with one hand "
        DB      "as I continue to lap at the warm folds of her most private place."
	DB	NEXT
	DB	"I find her clit, and begin attacking it with my tongue. She was near."
	DB	NEXT
	DB	"Rena:  No...! I'm afraid of... of this...!"
	DB	NEXT
	DB	"Quivering with fear and pleasure, her body leaked more honey."
	DB	NEXT
	DB	"I continue my tongue-lashing, moving as far into her as her maidenhood allows."
	DB	NEXT
	DB	"Rena:  Ahhn! .....Ahhhnnn!" 
	DB	NEXT
	DB	"More and more desperate. I know she is almost there."
	DB	NEXT
	DB	"But not yet..."
	DB	NEXT
	FLG_IF	YOKU,'>=',75,KUSA
	F_O	B_NORM,C_KURO
	DB	"Noo!!!!!!!"
	DB	NEXT
	MC_FLASH	1,C_SIRO
	B_O	B_FADE,C_SIRO
	FLG_KI	YOKU,'=',0
	FLG_KI	ONANI,'+',1
	CDPLAY		0
	BAK_INIT	'tb_017a',B_NORM
	DB	"kenjirou:  ........................................."
	DB	NEXT
	DB	"kenjirou:  .................................................."
	DB	NEXT
	DB	"kenjirou:  .............................................................."
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Kenjirou:  I came."
	DB	NEXT
	DB	"kenjirou:  ........................................."
	DB	NEXT
	DB	"kenjirou:  .................................................."
	DB	NEXT
	DB	"kenjirou:  .............................................................."
	DB	NEXT
	DB	"Kenjirou:  Am I becoming a premature ejaculator?"
	DB	NEXT
	GO SHORI
	DB	EXIT
KUSA:
	EVENT_CG	'th_083',B_NORM,43
	DB	"Rena:  No! Stop it! This is..." 
	DB	NEXT
	DB	"Rena, half-crying. I put one finger inside her, and start massaging her pink clit. "
	DB	NEXT
	DB	"A great day, and a great time to be alone, with Rena..."
	DB	NEXT
	DB	"Not yet removing her panties, I move the fabric to one side and put two fingers inside her."
	DB	NEXT
	DB	"Rena:  No! No, stop...!" 
	DB	NEXT
	DB	"Rena's girlish yelps are so cute, as I move my fingers slowly in and out of her fleshy slit."
	DB	NEXT
	DB	"It makes a sucking sound, as the walls of her pussy press closely in around my fingers."
	DB	NEXT
	DB	"removing my fingers, I open her pussy lips like flower petals."
	DB	NEXT
	DB	"Rena:  Ahh!" 
	DB	NEXT
	DB	"I find her clit again, and stimulate it with my finger pads."
	DB	NEXT
	DB	"As I do so, her body starts quivering, and she starts moaning softly."
	DB	NEXT
	DB	"Rena:  Ahhn!!" 
	DB	NEXT
	DB	"Her honey pot gets tighter, as her level of sexual excitement increases."
	DB	NEXT
	DB	"Kenjirou:  It's good. I know you like it, so stop trying to deny it..."
	DB	NEXT
	DB	"She's ready now."
	DB	NEXT
	DB	"Rena:  ....ahhn......" 
	DB	NEXT
	DB	"Her tits move slowly up and down, her blood-engorged nipples and pussy blazing bright read. "
	DB	NEXT
	DB	"Rena:  ... Kenjirou, I... I..."
	DB	NEXT
	FLG_IF	YOKU,'>=',100,HANA
	F_O	B_NORM,C_KURO
	DB	"No....!!!"
	DB	NEXT
	MC_FLASH	2,C_SIRO
	B_O	B_FADE,C_SIRO
	FLG_KI	YOKU,'=',0
	FLG_KI	ONANI,'+',1
	CDPLAY		0
	BAK_INIT	'tb_017a',B_NORM
	DB	"kenjirou:  ........................................."
	DB	NEXT
	DB	"kenjirou:  .................................................."
	DB	NEXT
	DB	"kenjirou:  .............................................................."
	DB	NEXT
	DB	"Kenjirou:  What?"
	DB	NEXT
	DB	"Kenjirou:  I came."
	DB	NEXT
	DB	"kenjirou:  ........................................."
	DB	NEXT
	DB	"kenjirou:  .................................................."
	DB	NEXT
	DB	"kenjirou:  .............................................................."
	DB	NEXT
	DB	"Kenjirou:  Hmm, a little too fast..."
	DB	NEXT
	GO SHORI
	DB	EXIT
HANA:
	F_O	B_NORM,C_KURO
	DB	"*SLURP*"
	DB	NEXT
	DB	"Rena:  No! No... it's too good..." 
	DB	NEXT
	DB	"I open the glass door, and bring Rena out onto the veranda with me."
	DB	NEXT
	EVENT_CG	'th_084',B_NORM,44
	DB	"Rena:  No, not out here...!!" 
	DB	NEXT
	DB	"I put her hands on the handrail, and move around behind her. "
	DB	NEXT
	DB	"Rena:  Hmmm... Fuuu..." 
	DB	NEXT
	DB	"Slowly my cock sinks inside her pussy, as I watch from above. "
	DB	NEXT
	DB	"Slowly, I sink inside her. I'm doing okay."
	DB	NEXT
	DB	"Deeper and deeper I slide, until my cock is fully encased between the walls of her."
	DB	NEXT
	DB	"Rena:  ......haaah..." 
	DB	NEXT
	DB	"I slide my cock out again, making a great sucking noise."
	DB	NEXT
	DB	"Trying to keep her voice from escaping to the outside, Rena nevertheless lets out a tiny yelp when I leave her."
	DB	NEXT
	DB	"My fully hard cock reemerges below, covered with her honey."
	DB	NEXT
	DB	NEXT
	DB	"Suddenly, I thrust inside her again, with full force this time."
	DB	NEXT
	EVENT_CG	'th_085b',B_NORM,45
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_085a","th_085b",0,EVENT_YSIZE,0,0
	SCR_END
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_085a","th_085b",0,0,0,EVENT_YSIZE
	SCR_END
	DB	"Rena:  Ahhhhhh!!!" 
	DB	NEXT
	DB	"Bumping against the limits of her pussy, my cock enters her fully again."
	DB	NEXT
	DB	"Rena:  Ahhh! Ahhhhhh!!" 
	DB	NEXT
	DB	"Unable to stop her own voice from escaping, she starts moaning in half-pain, half-pleasure as I start to pump in and out of her."
	DB	NEXT
	DB	"Getting the rhythm, I start to fuck her with more and more confidence."
	DB	NEXT
	DB	"Unsure of herself, she starts to move against my thrusts."
	DB	NEXT
	DB	"In addition to my own cock, now I add one finger inside her."
	DB	NEXT
	DB	"Rena:  Noo!  That hurts...!!" 
	DB	NEXT
	DB	"She suddenly moves her body forward, involuntarily. The motion catches me off guard, and I lose my balance."
	DB	NEXT
	DB	"Kenjirou:  Wahhh..."
	DB	NEXT
	DB	"I catch myself at the last minute, glad to have saved myself from embarrassment."
	DB	NEXT
	DB	"Looking down again at my cock, moving in and out of her hot pussy. "
        DB      "I reach around with one hand to pet her hard clit with one finger. "
	DB	NEXT
	DB	"....Mmm, this is pretty good."
	DB	NEXT
	DB	"Her honey throne is fully wet, as I continue my stroking of her"
	DB	NEXT
	DB	"...Mmm, I should try it..."
	DB	NEXT
	DB	"Pulling myself out again, I move up a few centimeters, to the tight muscle of her rectum."
	DB	NEXT
	DB	"Rena:  ...!?!?" 
	DB	NEXT
	DB	"With incredible tightness, my cock slowly moves past the tight flesh of her asshole."
	DB	NEXT
	DB	"Rena:  No! Stop, what are you...!!?" 
	DB	NEXT
	DB	"I turn to her pussy now, and move to put a finger inside her. I reconsider, and put in four."
	DB	NEXT
	DB	"With my forefinger, still free, I stimulate her clit some more."
	DB	NEXT
	DB	"Feeling the presence of my fingers in her pussy through my cock, in her ass, was an odd feeling."
	DB	NEXT
	DB	"Rena:  ....Ahhh!" 
	DB	NEXT
	DB	"Suddenly, I felt an even tighter gripping around my cock, as she orgasms."
	DB	NEXT
	SCR_START	EVENT_X,EVENT_Y,EVENT_XSIZE,EVENT_YSIZE,300
	SCR_SET	"th_085a","th_085b",0,EVENT_YSIZE,0,0
	SCR_END
	DB	"Rena:  Ahhhhh!!!" 
	DB	NEXT
	DB	"Kenjirou:  !!"
	DB	NEXT
	MC_FLASH	3,C_SIRO
	B_O	B_FADE,C_SIRO
	FLG_KI YOKU,'=',0
	;SUBSINARIO 'YOKUJOU.OVL'
	FLG_KI ONANI,'+',1
	FLG_KI RENA_NET,'=',0
	CDPLAY		0
	F_O	B_NORM,C_KURO
	DB	"kenjirou:  ........................................."
	DB	NEXT
	DB	".......Ah, that was good."
	DB	NEXT
	DB	"kenjirou:  ..........................................................."
	DB	NEXT
	DB	"Kenjirou:  But what the hell am I thinking, anyway?"
	DB	NEXT
	DB	"kenjirou:  ...................................................................."
	DB	NEXT
	DB	"Kenjirou:  Oh well. It's just a fantasy, anyway."
	DB	NEXT
SHORI:
	JTBL HAND
	DW	FF_0,FF_1,FF_2,FF_3,FF_4,FF_5,FF_6,-1
FF_0:
FF_1:
	SINARIO 'BUNKI_1.OVL'
	DB	EXIT
FF_2:
	SINARIO 'MON_14.OVL'
	DB	EXIT
FF_3:
	SINARIO 'MON_18.OVL'
	DB	EXIT
FF_4:
	SINARIO 'MON_23.OVL'
	DB	EXIT
FF_5:
	SINARIO 'NITI_HIR.OVL'
	DB	EXIT
FF_6:
	SINARIO 'NITI_HOK.OVL'
	DB	EXIT
END