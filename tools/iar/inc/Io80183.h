/*			-  io80183.h -

	This files defines the internal register addresses
	for z80183
	File version:   $Revision: 1.2 $

*/

#pragma language=extended

/* ==================================== */
/* 					*/
/*	ASCI Channel Control Registers 	*/
/* 					*/
/* ==================================== */

sfr CNTLA0	= 0x00; 		/* ASCI Ctrl Reg A, Ch 0 */
sfr CNTLA1	= 0x01; 		/* ASCI Ctrl Reg A, Ch 1 */
sfr CNTLB0	= 0x02; 	  	/* ASCI Ctrl Reg B, Ch 0 */
sfr CNTLB1	= 0x03; 		/* ASCI Ctrl Reg B, Ch 1 */
/* ------------------------------------------------------------------------- */
sfr STAT0	= 0x04; 		/* ASCI Status Reg, Ch 0 */
sfr STAT1	= 0x05; 		/* ASCI Status Reg, Ch 1 */
/* ------------------------------------------------------------------------- */
sfr TDR0	= 0x06; 		/* ASCI Transmit Data Reg, Ch 0 */
sfr TDR1	= 0x07; 		/* ASCI Transmit Data Reg, Ch 1 */
sfr TSR0	= 0x08; 		/* ASCI Receive Data Reg, Ch 0 */
sfr TSR1	= 0x09; 		/* ASCI Receive Data Reg, Ch 1 */
/* ------------------------------------------------------------------------- */
sfr ASEXT0      = 0x12; 		/* ASCI Extension Control Reg, Ch 0 */
sfr ASEXT1      = 0x13; 		/* ASCI Extension Control Reg, Ch 1 */
sfr ASTC0L      = 0x1A; 		/* ASCI Time Constant Low, Ch0 */
sfr ASTC0H      = 0x1B; 		/* ASCI Time Constant High, Ch0 */
sfr ASTC1L      = 0x1C; 		/* ASCI Time Constant Low, Ch1 */
sfr ASTC1H      = 0x1D; 		/* ASCI Time Constant High, Ch1 */

/* ==================================== */
/* 					*/
/*	CSI/O Registers 		*/
/* 					*/
/* ==================================== */

sfr CNTR	= 0x0A; 		/* CSI/O Ctrl Reg */
sfr TRDR	= 0x0B; 		/* CSI/O Trans/Rec Data Reg */

/* ==================================== */
/* 					*/
/*	Timer Registers 		*/
/* 					*/
/* ==================================== */

sfr TMDR0L	= 0x0C;			/* Timer 0 Data Reg L */
sfr TMDR0H	= 0x0D;			/* Timer 0 Data Reg H */
sfr TMDR1L	= 0x14; 		/* Timer 1 Data Reg L */
sfr TMDR1H	= 0x15; 		/* Timer 1 Data Reg H */
/* ------------------------------------------------------------------------- */
sfr RLDR0L	= 0x0E;			/* Timer 0 Reload Reg L */
sfr RLDR0H	= 0x0F;			/* Timer 0 Reload Reg H */
sfr RLDR1L	= 0x16; 		/* Timer 1 Reload Reg L */
sfr RLDR1H	= 0x17; 		/* Timer 1 Reload Reg H */
/* ------------------------------------------------------------------------- */
sfr TCR		= 0x10; 	 	/* Timer Ctrl Reg */

/* ==================================== */
/* 					*/
/*	Free Running Counter 		*/
/* 					*/
/* ==================================== */

sfr FRC		= 0x18;	        	/* Free Running Counter */

/* ==================================== */
/* 					*/
/*	CPU Control Register 		*/
/* 					*/
/* ==================================== */

sfr CCR		= 0x1F; 		/* CPU Ctrl Reg */
sfr CLKCR       = 0x1E; 		/* Clock Ctrl Reg */
/* ------------------------------------------------------------------------- */
sfr DeviceIDLow = 0x3B; 		/* Device ID Low  */
sfr DeviceIDHigh= 0x3C; 		/* Device ID High */
sfr RevisionID  = 0x3D; 		/* Revision ID    */

/* ==================================== */
/* 					*/
/*	DMA Registers 			*/
/* 					*/
/* ==================================== */

sfr SAR0L	= 0x20; 		/* DMA 0 Source Addr Reg */
sfr SAR0H	= 0x21; 		/* DMA 0 Source Addr Reg */
sfr SAR0B	= 0x22; 		/* DMA 0 Source Addr Reg */
/* ------------------------------------------------------------------------- */
sfr DAR0L	= 0x23; 		/* DMA 0 Destination Addr Reg */
sfr DAR0H	= 0x24; 		/* DMA 0 Destination Addr Reg */
sfr DAR0B	= 0x25; 		/* DMA 0 Destination Addr Reg */
/* ------------------------------------------------------------------------- */
sfr BCR0L	= 0x26; 		/* DMA 0 Counter Reg */
sfr BCR0H	= 0x27; 		/* DMA 0 Counter Reg */
/* ------------------------------------------------------------------------- */
sfr MAR1L	= 0x28; 		/* DMA 1 Memory Addr Reg */
sfr MAR1H	= 0x29; 		/* DMA 1 Memory Addr Reg */
sfr MAR1B	= 0x2A; 		/* DMA 1 Memory Addr Reg */
/* ------------------------------------------------------------------------- */
sfr IAR1L	= 0x2B; 		/* DMA I/O Addr Reg */
sfr IAR1H	= 0x2C; 		/* DMA I/O Addr Reg */
sfr IAR1B	= 0x2D; 		/* DMA I/O Addr Reg */
/* ------------------------------------------------------------------------- */
sfr BCR1L	= 0x2E; 		/* DMA 1 Byte Count Reg */
sfr BCR1H	= 0x2F; 		/* DMA 1 Byte Count Reg */
/* ------------------------------------------------------------------------- */
sfr DSTAT	= 0x30; 		/* DMA Status Reg */
sfr DMODE	= 0x31; 		/* DMA Mode Reg */
sfr DCNTL	= 0x32; 		/* DMA/WAIT Ctrl Reg */

/* ==================================== */
/* 					*/
/*	MMU Registers 			*/
/* 					*/
/* ==================================== */

sfr CBR_location     = 0x38; 		/* MMU Common Base Reg */
sfr BBR_location     = 0x39; 		/* MMU Bank Base Reg */
sfr CBAR_location    = 0x3A; 		/* MMU Bank/Common Area Reg */
#define CBR  CBR_location
#define BBR  BBR_location
#define CBAR  CBAR_location

/* ==================================== */
/* 					*/
/*	System Control Registers 	*/
/* 					*/
/* ==================================== */

sfr IL		= 0x33; 		/* Int Vect Low Reg */
sfr ITC		= 0x34; 		/* Int/Trap Ctrl Reg */
sfr RCR		= 0x36; 		/* Refresh Ctrl Reg */
sfr OMCR	= 0x3E; 		/* Operation Mode Ctrl Reg */
sfr ICR		= 0x3F; 		/* I/O Ctrl Reg */
sfr OCR         = 0x7D; 		/* Output Ctrl Reg */
sfr PCR         = 0x7E; 		/* Power Ctrl Reg */
sfr SCR         = 0x7F; 		/* System Configuration Reg  */

/* ==================================== */
/* 					*/
/*	ROM/RAM Chip Select     	*/
/*	And Wait Registers      	*/
/* 					*/
/* ==================================== */

sfr WSGCR       = 0x6B; 		/* Wait State Generator Ctrl Reg */
sfr ROMBR       = 0x6C; 		/* ROM Bound Reg */
sfr RAMLBR      = 0x6D; 		/* RAM Lower Bound Reg */
sfr RAMUBR      = 0x6E; 		/* RAM Upper Bound Reg */

/* ==================================== */
/* 					*/
/*	I/O Port Registers      	*/
/* 					*/
/* ==================================== */

sfr DRA         = 0x40; 		/* Port A Data Reg */
sfr DDRA        = 0x41; 		/* Port A Data Direction Reg */
sfr AFSA        = 0x42; 		/* Port A Alternate Func. Select Reg */
sfr OCRA        = 0x43; 		/* Port A Output Ctrl Reg */
/* ------------------------------------------------------------------------- */
sfr DRB         = 0x44; 		/* Port B Data Reg */
sfr DDRB        = 0x45; 		/* Port B Data Direction Reg */
sfr AFSB        = 0x46; 		/* Port B Alternate Func. Select Reg */
sfr OCRB        = 0x47; 		/* Port B Output Ctrl Reg */
/* ------------------------------------------------------------------------- */
sfr DRC         = 0x48; 		/* Port C Data Reg */
sfr DDRC        = 0x49; 		/* Port C Data Direction Reg */
sfr AFSC        = 0x4A; 		/* Port C Alternate Func. Select Reg */
sfr OCRC        = 0x4B; 		/* Port C Output Ctrl Reg */
/* ------------------------------------------------------------------------- */
sfr DRD         = 0x4C; 		/* Port D Data Reg */
sfr DDRD        = 0x4D; 		/* Port D Data Direction Reg */
sfr AFSD        = 0x4E; 		/* Port D Alternate Func. Select Reg */
sfr OCRD        = 0x4F; 		/* Port D Output Ctrl Reg */

/* ==================================== */
/* 					*/
/*	Watch-Dog Timer Registers	*/
/* 					*/
/* ==================================== */

sfr WDTMR       = 0x64; 		/* Watch-Dog Timer Master Reg */
sfr WDTCR       = 0x65; 		/* Watch-Dog Timer Command Reg */

/* ==================================== */
/* 					*/
/*	Real Time Clock Registers	*/
/* 					*/
/* ==================================== */

sfr RTCCS       = 0x6F; 		/* RTC Ctrl/Status Reg  */
sfr RTCSEC      = 0x70; 		/* RTC Seconds Reg */
sfr RTCMIN      = 0x71; 		/* RTC Minutes Reg */
sfr RTCHR       = 0x72; 		/* RTC Hours Reg */
sfr RTCDAY      = 0x73; 		/* RTC Day Of The Week Reg */
sfr RTCDAT      = 0x74; 		/* RTC Date Reg */
sfr RTCMO       = 0x75; 		/* RTC Month Reg */
sfr RTCYR       = 0x76; 		/* RTC Year Reg */
sfr RTCC        = 0x77; 		/* RTC Century Reg */
sfr ALARMS      = 0x78; 		/* RTC Alarm Seconds Reg */
sfr ALARMM      = 0x79; 		/* RTC Alarm Minutes Reg */
sfr ALARMH      = 0x7A; 		/* RTC Alarm Hours Reg */

/* ==================================== */
/* 					*/
/*	Digital/Analog Registers 	*/
/* 					*/
/* ==================================== */

sfr ADCC0       = 0x66; 		/* ADC Ctrl Reg 0 */
sfr ADCC1       = 0x67; 		/* ADC Ctrl Reg 1 */
sfr ADC         = 0x68; 		/* ADC Result Reg */
/* ------------------------------------------------------------------------- */
sfr DACCR       = 0x69; 		/* DAC Ctrl Reg */
sfr DAC         = 0x6A; 		/* DAC Data Reg */

/* ==================================== */
/* 					*/
/*	PIOS Registers          	*/
/* 					*/
/* ==================================== */

sfr PIOSCR      = 0x60; 		/* PIOS Ctrl Reg */
sfr PIOSAT      = 0x61; 		/* PIOS Address/Type Reg */
sfr PIOSCL      = 0x62; 		/* PIOS Counter Low */
sfr PIOSCH      = 0x63; 		/* PIOS Counter High */
