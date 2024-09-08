
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <intrz80.h>
#define COMMANDLINE 0x0080



/* Accuracy of timings and human fatigue controlled by next two lines */
//#define LOOPS	5000		/* Use this for slow or 16 bit machines */
#define LOOPS	50000		/* Use this for slow or 16 bit machines */
//#define LOOPS	500000		/* Use this for faster machines */

/* Compiler dependent options */
//#undef	NOENUM			/* Define if compiler has no enum's */
//#undef	NOSTRUCTASSIGN		/* Define if compiler can't assign structures */

/* define only one of the next three defines */
//#define GETRUSAGE		/* Use getrusage(2) time function */
//#define TIMES			/* Use times(2) time function */
#define TIME			/* Use time(2) time function */
//#define TIME_EVO_IAR			/* Use time(2) time function */


/* define the granularity of your times(2) function (when used) */
//#define HZ	60		/* times(2) returns 1/60 second (most) */
//#define HZ	100		/* times(2) returns 1/100 second (WECo) */
#define HZ	50		/* times(2) returns 1/50 second (ZX-Evo) */
//#define HZ	1		/* for time(2) */

/* for compatibility with goofed up version */
//#define GOOF			/* Define if you want the goofed up version */

#ifdef GOOF
char	Version[] = "1.0";
#else
char	Version[] = "1.1";
#endif

#ifdef	NOSTRUCTASSIGN
#define	structassign(d, s)	memcpy(&(d), &(s), sizeof(d))
#else
#define	structassign(d, s)	d = s
#endif

#ifdef	NOENUM
#define	Ident1	1
#define	Ident2	2
#define	Ident3	3
#define	Ident4	4
#define	Ident5	5
typedef int	Enumeration;
#else
typedef enum	{Ident1, Ident2, Ident3, Ident4, Ident5} Enumeration;
#endif

typedef int	OneToThirty;
typedef int	OneToFifty;
typedef char	CapitalLetter;
typedef char	String30[31];
typedef int	Array1Dim[51];
typedef int	Array2Dim[51][51];

struct	Record
{
	struct Record		*PtrComp;
	Enumeration		Discr;
	Enumeration		EnumComp;
	OneToFifty		IntComp;
	String30		StringComp;
};

typedef struct Record 	RecordType;
typedef RecordType *	RecordPtr;
typedef int		boolean;

//#define	NULL		0
#define	TRUE		1
#define	FALSE		0

#ifndef REG
#define	REG
#endif

#ifdef TIMES
#include <sys/param.h>
#include <sys/types.h>
#include <sys/times.h>
#endif
#ifdef GETRUSAGE
#include <sys/time.h>
#include <sys/resource.h>
#endif
#ifdef TIME_EVO_IAR
#include <string.h>
#include <intrz80.h>
#include <stdio.h>
#include "conio.h"
#endif


/*
 * Package 1
 */
int		IntGlob;
boolean		BoolGlob;
char		Char1Glob;
char		Char2Glob;
Array1Dim	Array1Glob;
Array2Dim	Array2Glob;
RecordPtr	PtrGlb;
RecordPtr	PtrGlbNext;
void Proc4(void );
void Proc5(void );
Enumeration Func1(CapitalLetter	CharPar1,CapitalLetter	CharPar2);
boolean Func2(String30	StrParI1,String30	StrParI2);
void Proc1(REG RecordPtr	PtrParIn);
void Proc2(OneToFifty	*IntParIO);
void Proc3(RecordPtr	*PtrParOut);
void Proc6(REG Enumeration	EnumParIn, REG Enumeration	*EnumParOut);
void Proc7(OneToFifty	IntParI1, OneToFifty	IntParI2, OneToFifty	*IntParOut);
void Proc8(Array1Dim	Array1Par,Array2Dim	Array2Par,OneToFifty	IntParI1,OneToFifty	IntParI2);
boolean Func3(REG Enumeration	EnumParIn);

void Proc0(void )
{
	OneToFifty		IntLoc1;
	REG OneToFifty		IntLoc2;
	OneToFifty		IntLoc3;
	REG char		CharLoc;
	REG char		CharIndex;
	Enumeration	 	EnumLoc;
	String30		String1Loc;
	String30		String2Loc;
	RecordType _GlbNext;
	RecordType _Glb;

	register unsigned int	i;
#ifdef TIME
	long			time(void);
	long			starttime;
	long			benchtime;
	long			nulltime;

	starttime = time(/* (long *) 0*/);
	for (i = 0; i < LOOPS; ++i);
	nulltime = time(/* (long *) 0*/) - starttime; /* Computes o'head of loop */
#endif
#ifdef TIMES
	time_t			starttime;
	time_t			benchtime;
	time_t			nulltime;
	struct tms		tms;

	times(&tms); starttime = tms.tms_utime;
	for (i = 0; i < LOOPS; ++i);
	times(&tms);
	nulltime = tms.tms_utime - starttime; /* Computes overhead of looping */
#endif
#ifdef TIME_EVO_IAR
	extern long 	int_timer;
	long			starttime;
	long			benchtime;
	long			nulltime;
	
 	MCU_Init();
 
	textbackground(BLUE);
	clrscr();
	textcolor(BLACK);
	textbackground(CYAN);
  	enable_interrupt();
	halt();
	starttime = int_timer;
	for (i = 0; i < LOOPS; ++i);
	halt();
	nulltime = int_timer - starttime; /* Computes overhead of looping */
#endif
#ifdef GETRUSAGE
	struct rusage starttime;
	struct rusage endtime;
	struct timeval nulltime;

	getrusage(RUSAGE_SELF, &starttime);
	for (i = 0; i < LOOPS; ++i);
	getrusage(RUSAGE_SELF, &endtime);
	nulltime.tv_sec  = endtime.ru_utime.tv_sec  - starttime.ru_utime.tv_sec;
	nulltime.tv_usec = endtime.ru_utime.tv_usec - starttime.ru_utime.tv_usec;
#endif

	PtrGlbNext = &_GlbNext;
	PtrGlb = &_Glb;
	PtrGlb->PtrComp = PtrGlbNext;
	PtrGlb->Discr = Ident1;
	PtrGlb->EnumComp = Ident3;
	PtrGlb->IntComp = 40;
	strcpy(PtrGlb->StringComp, "DHRYSTONE PROGRAM, SOME STRING");
#ifndef	GOOF
	strcpy(String1Loc, "DHRYSTONE PROGRAM, 1'ST STRING");	/*GOOF*/
#endif
	Array2Glob[8][7] = 10;	/* Was missing in published program */

/*****************
-- Start Timer --
*****************/
#ifdef TIME
	starttime = time(/* (long *) 0*/);
#endif
#ifdef TIMES
	times(&tms); starttime = tms.tms_utime;
#endif
#ifdef TIME_EVO_IAR
	halt();
	starttime = int_timer;
#endif
#ifdef GETRUSAGE
	getrusage (RUSAGE_SELF, &starttime);
#endif
	for (i = 0; i < LOOPS; ++i)
	{

		Proc5();
		Proc4();
		IntLoc1 = 2;
		IntLoc2 = 3;
		strcpy(String2Loc, "DHRYSTONE PROGRAM, 2'ND STRING");
		EnumLoc = Ident2;
		BoolGlob = ! Func2(String1Loc, String2Loc);
		while (IntLoc1 < IntLoc2)
		{
			IntLoc3 = 5 * IntLoc1 - IntLoc2;
			Proc7(IntLoc1, IntLoc2, &IntLoc3);
			++IntLoc1;
		}
		Proc8(Array1Glob, Array2Glob, IntLoc1, IntLoc3);
		Proc1(PtrGlb);
		for (CharIndex = 'A'; CharIndex <= Char2Glob; ++CharIndex)
			if (EnumLoc == Func1(CharIndex, 'C'))
				Proc6(Ident1, &EnumLoc);
		IntLoc3 = IntLoc2 * IntLoc1;
		IntLoc2 = IntLoc3 / IntLoc1;
		IntLoc2 = 7 * (IntLoc3 - IntLoc2) - IntLoc1;
		Proc2(&IntLoc1);
	}

/*****************
-- Stop Timer --
*****************/

#ifdef TIME
	benchtime = time(/* (long *) 0*/) - starttime - nulltime;
	printf("Dhrystone(%s) time for %ld passes = %ld\r\n",
		Version,
		(long) LOOPS, benchtime/HZ);
	printf("This machine benchmarks at %ld dhrystones/second\r\n",
		((long) LOOPS) * HZ / benchtime);
#endif
#ifdef TIMES
	times(&tms);
	benchtime = tms.tms_utime - starttime - nulltime;
	printf("Dhrystone(%s) time for %ld passes = %ld\r\n",
		Version,
		(long) LOOPS, benchtime/HZ);
	printf("This machine benchmarks at %ld dhrystones/second\r\n",
		((long) LOOPS) * HZ / benchtime);
#endif
#ifdef TIME_EVO_IAR
	halt();
	benchtime = int_timer - starttime - nulltime;
	printf("Dhrystone(%s) time for %ld passes = %ld\r\n",
		Version,
		(long) LOOPS, benchtime/HZ);
	printf("This machine benchmarks at %ld dhrystones/second\r\n",
		((long) LOOPS) * HZ / benchtime);
#endif
#ifdef GETRUSAGE
	getrusage(RUSAGE_SELF, &endtime);
	{
	    double t = (double)(endtime.ru_utime.tv_sec
				- starttime.ru_utime.tv_sec
				- nulltime.tv_sec)
		     + (double)(endtime.ru_utime.tv_usec
				- starttime.ru_utime.tv_usec
				- nulltime.tv_usec) * 1e-6;
	    printf("Dhrystone(%s) time for %ld passes = %.1f\r\n",
		   Version,
		   (long)LOOPS,
		   t);
	    printf("This machine benchmarks at %.0f dhrystones/second\r\n",
		   (double)LOOPS / t);
	}
#endif

}

void Proc1(REG RecordPtr	PtrParIn)
{
#define	NextRecord	(*(PtrParIn->PtrComp))

	structassign(NextRecord, *PtrGlb);
	PtrParIn->IntComp = 5;
	NextRecord.IntComp = PtrParIn->IntComp;
	NextRecord.PtrComp = PtrParIn->PtrComp;
	Proc3(&NextRecord.PtrComp);
	if (NextRecord.Discr == Ident1)
	{
		NextRecord.IntComp = 6;
		Proc6(PtrParIn->EnumComp, &NextRecord.EnumComp);
		NextRecord.PtrComp = PtrGlb->PtrComp;
		Proc7(NextRecord.IntComp, 10, &NextRecord.IntComp);
	}
	else
		structassign(*PtrParIn, NextRecord);

#undef	NextRecord
}

void Proc2(OneToFifty	*IntParIO)
{
	REG OneToFifty		IntLoc;
	REG Enumeration		EnumLoc;

	IntLoc = *IntParIO + 10;
	for(;;)
	{
		if (Char1Glob == 'A')
		{
			--IntLoc;
			*IntParIO = IntLoc - IntGlob;
			EnumLoc = Ident1;
		}
		if (EnumLoc == Ident1)
			break;
	}
}

void Proc3(RecordPtr	*PtrParOut)
{
	if (PtrGlb != NULL)
		*PtrParOut = PtrGlb->PtrComp;
	else
		IntGlob = 100;
	Proc7(10, IntGlob, &PtrGlb->IntComp);
}

void Proc4(void )
{
	REG boolean	BoolLoc;

	BoolLoc = Char1Glob == 'A';
	BoolLoc |= BoolGlob;
	Char2Glob = 'B';
}

void Proc5(void )
{
	Char1Glob = 'A';
	BoolGlob = FALSE;
}

void Proc6(REG Enumeration	EnumParIn, REG Enumeration	*EnumParOut)
{
	*EnumParOut = EnumParIn;
	if (! Func3(EnumParIn) )
		*EnumParOut = Ident4;
	switch (EnumParIn)
	{
	case Ident1:	*EnumParOut = Ident1; break;
	case Ident2:	if (IntGlob > 100) *EnumParOut = Ident1;
			else *EnumParOut = Ident4;
			break;
	case Ident3:	*EnumParOut = Ident2; break;
	case Ident4:	break;
	case Ident5:	*EnumParOut = Ident3;
	}
}

void Proc7(OneToFifty	IntParI1, OneToFifty	IntParI2, OneToFifty	*IntParOut)
{
	REG OneToFifty	IntLoc;

	IntLoc = IntParI1 + 2;
	*IntParOut = IntParI2 + IntLoc;
}

void Proc8(Array1Dim	Array1Par,Array2Dim	Array2Par,OneToFifty	IntParI1,OneToFifty	IntParI2)
{
	REG OneToFifty	IntLoc;
	REG OneToFifty	IntIndex;

	IntLoc = IntParI1 + 5;
	Array1Par[IntLoc] = IntParI2;
	Array1Par[IntLoc+1] = Array1Par[IntLoc];
	Array1Par[IntLoc+30] = IntLoc;
	for (IntIndex = IntLoc; IntIndex <= (IntLoc+1); ++IntIndex)
		Array2Par[IntLoc][IntIndex] = IntLoc;
	++Array2Par[IntLoc][IntLoc-1];
	Array2Par[IntLoc+20][IntLoc] = Array1Par[IntLoc];
	IntGlob = 5;
}

Enumeration Func1(CapitalLetter	CharPar1,CapitalLetter	CharPar2)
{
	REG CapitalLetter	CharLoc1;
	REG CapitalLetter	CharLoc2;

	CharLoc1 = CharPar1;
	CharLoc2 = CharLoc1;
	if (CharLoc2 != CharPar2)
		return (Ident1);
	else
		return (Ident2);
}

boolean Func2(String30	StrParI1,String30	StrParI2)
{
	REG OneToThirty		IntLoc;
	REG CapitalLetter	CharLoc;

	IntLoc = 1;
	while (IntLoc <= 1)
		if (Func1(StrParI1[IntLoc], StrParI2[IntLoc+1]) == Ident1)
		{
			CharLoc = 'A';
			++IntLoc;
		}
	if (CharLoc >= 'W' && CharLoc <= 'Z')
		IntLoc = 7;
	if (CharLoc == 'X')
		return(TRUE);
	else
	{
		if (strcmp(StrParI1, StrParI2) > 0)
		{
			IntLoc += 7;
			return (TRUE);
		}
		else
			return (FALSE);
	}
}

boolean Func3(REG Enumeration	EnumParIn)
{
	REG Enumeration	EnumLoc;

	EnumLoc = EnumParIn;
	if (EnumLoc == Ident3) return (TRUE);
	return (FALSE);
}

int main(void)
{
	
    os_initstdio(); //Alone Coder
	Proc0();
	return 0; //while(1); //Alone Coder
}
#ifdef	NOSTRUCTASSIGN
memcpy(d, s, l)
register char	*d;
register char	*s;
register int	l;
{
	while (l--) *d++ = *s++;
}
#endif
/* ---------- */

