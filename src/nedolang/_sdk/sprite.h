PROC prspr FORWARD(BYTE x, BYTE y, PBYTE data); //draw sprite in scrbuf
PROC respr FORWARD(BYTE x, BYTE y, PBYTE data); //restore scrbuf under sprite from tilemap
PROC prtilebox FORWARD(BYTE x8, BYTE y8, BYTE wid8, BYTE hgt8); //update scrbuf from portion of tilemap
PROC pretile FORWARD(BYTE x8, BYTE y8, BYTE wid8, BYTE hgt8, PBYTE data); //draw tilebox in tilemap (not in scrbuf)
PROC showscr FORWARD(); //copy scrbuf to screen
PROC clearscrbuf FORWARD(BYTE attr); //clear scrbuf
PROC cleartilemap FORWARD(PBYTE tileaddr); //clear tilemap
FUNC BOOL readpix FORWARD(BYTE x, BYTE y); //read pixel from scrbuf
PROC setpixscrbuf FORWARD(BYTE x, BYTE y, BYTE color); //set/reset pixel in scrbuf
PROC setpix FORWARD(BYTE x, BYTE y, BYTE color); //set/reset pixel on screen
PROC invpixscrbuf FORWARD(BYTE x, BYTE y); //invert pixel in scrbuf
PROC onpixscrbuf FORWARD(BYTE x, BYTE y); //set pixel in scrbuf
PROC offpixscrbuf FORWARD(BYTE x, BYTE y); //reset pixel in scrbuf
PROC invpix FORWARD(BYTE x, BYTE y); //invert pixel on screen
PROC onpix FORWARD(BYTE x, BYTE y); //set pixel on screen
PROC offpix FORWARD(BYTE x, BYTE y); //reset pixel on screen

//do define:
//scraddr = 0x4000/6000/c000
//scrtop = scraddr + ...
//scrbuf = divisible by 0x800
//tilemap (size 0xc00)
