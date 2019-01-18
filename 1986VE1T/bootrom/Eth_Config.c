
#ifndef __CONFIG_C
#define __CONFIG_C

#include "config.h"
#include "opora.h"

//--- Clock configuration ---
void ClkConfig()
{
        uint32_t temp;
        RST_CLK->PER_CLOCK |= (1 << 27);                                //BKP Clock enable
        temp = BKP->REG_0E;
        temp &= 0xFFFFFFC0;
        BKP->REG_0E = temp | (7 << 3) | 7;                              // SelectRI = 0x7, LOW = 0x7; (for core frequency more then 80 MHz);
#ifdef REVISION_2

#ifdef HSE2_OSCILLATOR
        RST_CLK->HS_CONTROL=0x00000005;                                 //HSE On, Oscillator mode; HSE2 On, Oscillator mode
#else
        RST_CLK->HS_CONTROL=0x0000000D;                                 //HSE On, Oscillator mode; HSE2 On, Generator mode
#endif  //HSE2_OSCILLATOR

        while((RST_CLK->CLOCK_STATUS&0x0C)!=0x0C);              //Wait until HSE and HSE2 not ready
        RST_CLK->CPU_CLOCK=0x00000002;                                  //HSE=8 MHz
        RST_CLK->PLL_CONTROL=(15/*11*/<<8)|(1<<2);                    //PLL CPU On, PLL_MULL=15. PLLCPUo = PLLCPUi x (PLLCPUMUL+1), т.е. x16
        while((RST_CLK->CLOCK_STATUS&0x02)!=0x02);              //wait until PLL CPU not ready
        RST_CLK->PER_CLOCK|=0x08;                                               //EEPROM_CNTRL Clock enable
        EEPROM->CMD=3<<3;                                                               //Delay=4
        RST_CLK->PER_CLOCK&=(~0x08);                                    //EEPROM_CNTRL Clock enable
        RST_CLK->CPU_CLOCK|=0x00000106; //HCLK=CPU_C3=CPU_C2, CPU_C2=PLLCPUo, CPU_C1=HSE //CPU Clock = 16*8MHz = 128 MHz
        RST_CLK->ETH_CLOCK=(1<<24)|(3<<28)|(1<<27);             //PHY_CLK_SEL = HSE2, ETH_CLK_EN=1, PHY_CLK_EN=1, ETH_CLK = 25MHz
#else //~REVISION_2
        RST_CLK->HS_CONTROL=0x00000003;                                 //HSE - On; Gen mode On
        while((RST_CLK->CLOCK_STATUS&0x04)!=0x04);              //Wait until HSE not ready
        RST_CLK->CPU_CLOCK=0x00000003;                                  //HSE/2 = 12.5 MHz
        RST_CLK->PLL_CONTROL=(7<<8)|(1<<2);                             //PLL CPU On;
        while((RST_CLK->CLOCK_STATUS&0x02)!=0x02);              //wait until PLL CPU not ready
        RST_CLK->PER_CLOCK|=0x08;                                               //EEPROM Clock enable
        EEPROM->CMD=4<<3;                                                               //Delay = 4
        RST_CLK->CPU_CLOCK|=0x00000107;                                 //CPU Clock = 8*12.5MHz = 100 MHz
        RST_CLK->ETH_CLOCK=(1<<24)|(1<<28)|(1<<27);             //PHY_CLK_SEL = HSE, ETH_CLK_EN=1, PHY_CLK_EN=1, ETH_CLK = 25MHz
#endif //~REVISION_2

        RST_CLK->PER_CLOCK|=(1<<24)|(1<<22);                    //Enable clock for PORTD and PORTB
/*

//        RST_CLK->HS_CONTROL = 0x00000001;                       //HSE - On; Osc mode On (забыли про HSE2)
        while((RST_CLK->CLOCK_STATUS&RST_CLK_CLOCK_STATUS_HSE_RDY)==0); //Wait until HSE not ready
        RST_CLK->PER_CLOCK|=0x08;                                       //EEPROM_CTRL Clock enable
        EEPROM->CMD=0;
        RST_CLK->PER_CLOCK&=(~0x08);                            //EEPROM_CTRL Clock disable
        RST_CLK->CPU_CLOCK=0x00000002;                          //CPU_C1=HSE (8MHz)
//        RST_CLK->PLL_CONTROL=RST_CLK_PLL_CONTROL_PLL_CPU_MUL_2|RST_CLK_PLL_CONTROL_PLL_CPU_ON;  //PLL_CPU_MULL=2, PLL_CPU On
        while((RST_CLK->CLOCK_STATUS&RST_CLK_CLOCK_STATUS_PLL_CPU_RDY)==0);     //Wait until CPU PLL not ready
//        RST_CLK->CPU_CLOCK=0x106; //виснет //HCLK=CPU_C3=CPU_C2, CPU_C2=PLLCPUo, CPU_C1=HSE   //CPU clock=CPUPLL (16MHz)
        RST_CLK->CPU_CLOCK=0x00000107;       //HCLK=CPU_C3=CPU_C2, CPU_C2=PLLCPUo, CPU_C1=HSE/2 //CPU Clock = 8*12.5MHz = 100 MHz
*/
}


/*
//--- Clock configuration ---
void ClkConfig()
{
        uint32_t temp;
        RST_CLK->PER_CLOCK |= (1 << 27);                                //BKP Clock enable
        temp = BKP->REG_0E;
        temp &= 0xFFFFFFC0;
        BKP->REG_0E = temp | (7 << 3) | 7;                              // SelectRI = 0x7, LOW = 0x7; (for core frequency more then 80 MHz);

#ifdef REVISION_2

#ifdef  HSE2_OSCILLATOR
        RST_CLK->HS_CONTROL=0x00000005;                                 //HSE - On, Oscillator mode; HSE2 - On, Oscillator mode
#else
        RST_CLK->HS_CONTROL=0x0000000D;                                 //HSE - On, Oscillator mode; HSE2 - On, Generator mode
#endif  //HSE2_OSCILLATOR
        while((RST_CLK->CLOCK_STATUS&0x0C)!=0x0C);              //Wait until HSE and HSE2 not ready
        RST_CLK->CPU_CLOCK=0x00000002;                                  //CPU_C1 = HSE = 8 MHz
        RST_CLK->PLL_CONTROL=(11<<8)|(1<<2);                    //PLL CPU On, PLL_MULL = 11
#else
        RST_CLK->HS_CONTROL=0x00000003;                                 //HSE - On; Gen mode On
        while((RST_CLK->CLOCK_STATUS&0x04)!=0x04);              //Wait until HSE not ready
        RST_CLK->CPU_CLOCK=0x00000003;                                  //HSE/2 = 12.5 MHz;
        RST_CLK->PLL_CONTROL=(7<<8)|(1<<2);                             //PLL CPU On;
#endif  //REVISION_2

        while((RST_CLK->CLOCK_STATUS&0x02)!=0x02);              //wait until PLL CPU not ready
        RST_CLK->PER_CLOCK|=0x08;                                               //EEPROM_CTRL Clock enable
        EEPROM->CMD=4<<3;                                                               //Delay = 4
        RST_CLK->PER_CLOCK&=(~0x08);                                    //EEPROM_CTRL Clock disable

#ifdef REVISION_2
        RST_CLK->CPU_CLOCK|=0x00000106;                                 //CPU Clock = 12*8 MHz = 96 MHz
        RST_CLK->ETH_CLOCK=(1<<24)|(1<<27)|(3<<28);             //PHY_CLK_SEL = HSE2, ETH_CLK_EN=1, PHY_CLK_EN=1
#else
        RST_CLK->CPU_CLOCK|=0x00000107;                                 //CPU Clock = 8*12.5MHz = 100 MHz
        RST_CLK->ETH_CLOCK=(1<<24)|(1<<28)|(1<<27);             //PHY_CLK_SEL = HSE, ETH_CLK_EN=1, PHY_CLK_EN=1
#endif  //REVISION_2

        RST_CLK->PER_CLOCK|=(1<<24)|(1<<22);                    //Enable clock for PORTD and PORTB
}
*/
//--- Ports configuration ---
void PortConfig()
{
/*        PORTD->FUNC = 0x00000000;
        PORTD->ANALOG=0xFFFF;
        PORTD->RXTX=0;
        PORTD->OE|=0x7F80;
        PORTD->PWR|=0x3FFFC000;

        PORTB->FUNC = 0x00;
        PORTB->ANALOG=0x3<<14;
        PORTB->RXTX=0;
        PORTB->OE|=0x3<<14;
        PORTB->PWR|=0xF<<28;
*/
        RST_CLK->PER_CLOCK|=(0x1F<<21)|(1<<29); //Enable clock of PORTA, PORTB, PORTC, PORTD, PORTE, PORTF

        //Config Data Bus
        PORTA->FUNC=0x55555555;                 //PORTA - DATA bus
        PORTA->ANALOG=0xFFFF;                   //PORTA - digital
        PORTA->PWR=0xFFFFFFFF;                  //PORTA - fast speed

        PORTB->FUNC=0x55555555;                 //PORTB - DATA bus
        PORTB->ANALOG=0xFFFF;                   //PORTB - digital
        PORTB->PWR=0xFFFFFFFF;                  //PORTB - fast speed

        //Config ~OE, ~WE, BE3, BE2, BE1, BE0 (инверсные???)
        PORTC->FUNC=0x02A80005;                 //PORTC[12..9] - BE3, BE2, BE1, BE0 (инверсные???); PORTC[1..0] - ~RD(~OE), ~WR(~WE)
        PORTC->ANALOG=0x1E03;                   //PORTC[12..9], PORTC[1..0] - digital
        PORTC->PWR=0x03FC000F;                  //PORTC - fast speed

        //Config Address Bus and CS
        PORTF->FUNC=0xAAAAA800;                 //PORTF[15..5] - ADDRESS bus
        PORTF->ANALOG=0xFFE0;                   //PORTF[15..5] - digital
        PORTF->PWR=0xFFFFFC00;                  //PORTF - fast speed

        PORTD->FUNC=0x80000000;                 //PORTD_15 - ADDRESS[13]
        PORTD->ANALOG=0x8000;                   //PORTD_15 - digital
        PORTD->PWR=0xC0000000;                  //PORTD - fast speed

        PORTE->FUNC=0x00000AAA;                 //PORTE[5..0] - ADDRESS[19..14], PORTE_7 - ADDRESS[21] (или /CS1???),
        PORTE->RXTX=0x0040;                             //PORTE_6=1 (~CS1=1) (или CS0???)
        PORTE->OE=0x00C0;                               //PORTE_6 - Output (и PORTE_7???)
        PORTE->ANALOG=0x00FF;                   //PORTE[7..0] - digital
        PORTE->PWR=0x0000FFFF;                  //PORTE - fast speed

        PORTE->CLRTX=0x40;
        PORTE->SETTX=0x80;

        //Config LEDS
        PORTD->RXTX=0;
        PORTD->OE|=0x7F80;
        PORTD->ANALOG|=0x7F80;                  //PORTD[14..7] - digital
        PORTD->PWR|=0x3FFFC000;                 //PORTD - fast speed

//ExternalBusConfig
        RST_CLK->PER_CLOCK|=1<<30;              //Enable clock of External Bus
        EXT_BUS_CNTRL->EXT_BUS_CONTROL=(0x0002)|(/*15*/8<<12);        //RAM enable, speed 8
//С проводами при CPU_CLK = 96 МГц (настройка из примера) получился делитель WAIT_STATE минимум "7" (2+4+2), т.е. 12 МГц (>83 нс). Даже при "4" (2+2+1) работает только половина теста памяти (с проводами).
//При CPU_CLK = 128 МГц (как получить 144 МГц из 8 МГц? надо другой осциллятор HSE?) делитель WAIT_STATE минимум "8" (3+4+2), т.е. 14.2 МГц (>70 нс) - видимо, при "6" (2+3+2) и "7" (2+4+2) неудачные растактовки.
//Сама микросхема памяти имеет "Время выборки по адресу и сигналу nСЕ1 и CE2 не более 30 нс", "Время цикла считывания информации мин 30 нс", "Время цикла записи информации мин 30 нс".
//По доке на микросхему ОЗУ и при чтении, и при записи не нужна задержка адреса после снятия управляющих сигналов.
//Попробуем сделать растактовку 3+4+0 (работает):
        //EXT_BUS_CNTRL->RAM_CYCLES3 = (0<<11)+(3<<8)+(4<<1)+1; //WS_HOLD=0, WS_SETUP=3, WS_ACTIVE=4, ENABLE_TUNE=1
//Попробуем сделать растактовку 1+4+0 (не работает):
        //EXT_BUS_CNTRL->RAM_CYCLES3 = (0<<11)+(1<<8)+(4<<1)+1; //WS_HOLD=0, WS_SETUP=1, WS_ACTIVE=4, ENABLE_TUNE=1
//Попробуем сделать растактовку 2+4+0 (работает):
        EXT_BUS_CNTRL->RAM_CYCLES3 = (0<<11)+(2<<8)+(4<<1)+1; //WS_HOLD=0, WS_SETUP=2, WS_ACTIVE=4, ENABLE_TUNE=1

}

#endif  //__CONFIG_C

