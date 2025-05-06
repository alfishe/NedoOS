unsigned char viewScreen6912(unsigned int bufAdr, unsigned int ints);
// DE = buffer adress BC = time  out: A = key

//unsigned char viewScreen6912NoKeyGraph(unsigned int bufAdr, unsigned char ints, unsigned char border);
unsigned char viewScreen6912NoKeyGraph(unsigned long bufIntBrd);
unsigned char rst0x08(void);
void CLEARC000(void);
//void CLEARC000FAST(void);
// out a=key
