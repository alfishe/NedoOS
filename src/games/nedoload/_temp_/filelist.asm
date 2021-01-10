messageStr 
	db " NOTHING IS LOADING",0 
fileList 
	db high (2530+255),16 
	db high (2508+255),17 
	db high (235+255),4 
	db high (1920+255),0 
	db high (345+255),18 
	db high (239+255),6 
	db high (1263+255),12 
	db high (2633+255),15 
	db 0,15 
	dw 57344 
progressStep 
	dw 512 
