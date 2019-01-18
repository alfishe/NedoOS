#include "stdint.h"

#ifndef __ETHFUNC_H
#define __ETHFUNC_H

void SetPHYReg(uint8_t,uint8_t,uint16_t);
uint16_t GetPHYReg(uint8_t,uint8_t);
void PHYInit(uint8_t,uint8_t);
void EthernetConfig(void);
void MACReset(void);
void ClearMemory(void);
uint32_t ReadPacket(_Rec_Frame*);
int     SendPacket(void*, int);

#endif  //__ETHFUNC_H

