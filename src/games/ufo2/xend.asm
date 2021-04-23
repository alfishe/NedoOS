;**** HЛО-2. Дьяволы бездны ****
;      Модуль концовки игры
	ORG #C000

musEND
*B ..\MUSIC\XEND.MUS
scrEND
*B ..\DATA\XEND1.SCR
txtEND
*B ..\DATA\XEND.DAT
	DEFS #F000-$,26
	DEFW musEND
	DEFW scrEND
	DEFW txtEND

