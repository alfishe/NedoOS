
#ifndef __RAM_FUNCTIONS_H
#define __RAM_FUNCTIONS_H

#define START_ADDR      0x60000000

void WriteDataToRAM(uint32_t, uint32_t);
void WriteByteToRAM(uint32_t, unsigned char);
void CallRAM(uint32_t);
uint32_t TestData(uint32_t, uint32_t);

#endif  //__RAM_FUNCTIONS_H

