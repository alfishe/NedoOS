unsigned char viewScreen6912(unsigned int bufAdr, unsigned int ints);
// DE = buffer adress BC = time  out: A = key

//unsigned char viewScreen6912NoKeyGraph(unsigned int bufAdr, unsigned char ints, unsigned char border);
unsigned char viewScreen6912NoKeyGraph(unsigned long bufIntBrd);
unsigned char rst0x08(void);
// out a=key
