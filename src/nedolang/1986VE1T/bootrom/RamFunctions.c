
#ifndef __RAM_FUNCTIONS_C
#define __RAM_FUNCTIONS_C

#include "opora.h"
#include "RamFunctions.h"

void CallRAM(uint32_t address)
{
        //unsigned char * ptr;
        //ptr=(uint32_t*)address;
        PORTE->CLRTX=0x40;
        ((void(*)(void))(address))();
        PORTE->SETTX=0x40;
}

//Функция для записи одного байта данных в ОЗУ
//Параметры address - адрес, с которого необходимо записывать данные в ОЗУ
//Возвращаемых значений нет
void WriteByteToRAM(uint32_t address, unsigned char b)
{
        unsigned char * ptr = (unsigned char *)address;
        PORTE->CLRTX=0x40;
        *ptr = b;
        PORTE->SETTX=0x40;
}

//Функция для записи данных от 0 до 0x3FFFF в ОЗУ
//Параметры address - адрес, с которого необходимо записывать данные в ОЗУ
//                      inv - флаг записи инверсного значения в память ОЗУ
//Возвращаемых значений нет
void WriteDataToRAM(uint32_t address, uint32_t inv)
{
        uint32_t*       ptr;
        uint32_t        tmp;

        ptr=(uint32_t*)address;

        PORTE->CLRTX=0x40;

        if(!inv)
                for(tmp=0;tmp<0x40000;tmp++)    {
                        *ptr++ =tmp;
                }
        else
                for(tmp=0;tmp<0x40000;tmp++)    {
                        *ptr++ =(~tmp);
                }

        PORTE->SETTX=0x40;
}

//Функция для проверки записанных данных в ОЗУ
//Параметры address - адрес, с которого необходимо тестировать данные в ОЗУ
//                      inv - флаг проверки инверсных значений в памяти ОЗУ
//Возвращаемое значение:        0 - данные в памяти отличаются от записанных
//                                                      1 - все данные в памяти совпадают с записанными
uint32_t TestData(uint32_t address, uint32_t inv)
{
        uint32_t *ptr, tmp, data, res;

        ptr=(uint32_t*)address;

        PORTE->CLRTX=0x40;
        res=1;

        if(!inv)
        {
                for(tmp=0;tmp<0x40000;tmp++)
                {
                        data=*ptr++;
                        if(data!=tmp)
                        {
                                res=0;
                                break;
                        }
                }
        }
        else
        {
                for(tmp=0;tmp<0x40000;tmp++)
                {
                        data=*ptr++;
                        if(data!=(~tmp))
                        {
                                res=0;
                                break;
                        }
                }
        }

        PORTE->SETTX=0x40;
        return res;
}


#endif  //__RAM_FUNCTIONS_C

