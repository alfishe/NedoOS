	DEVICE ZXSPECTRUM48
	
	ORG 0x6000
START: 
	incbin "kernel\code.c"
ENDPROG:
	SAVEHOB  "nedoos.$C","nedoos.C",START,ENDPROG-START