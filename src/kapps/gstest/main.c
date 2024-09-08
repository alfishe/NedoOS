#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <intrz80.h>
#include <../common/terminal.c>
#define datareg 179
#define cmdreg 187
#include <booter.c>

unsigned char getStat(void)
{
    // Принять данные из регистра статуса
    unsigned char dataread;
    dataread = input(cmdreg);
    return dataread;
}

unsigned char getDat(void)
{
    // Принять данные из регистра данных
    unsigned char dataread;
    dataread = input(datareg);
    return dataread;
}

void sendDat(unsigned char data)
{
    // Послать код команды в регистр команд
    unsigned char dataread2;
    output(datareg, data);
    dataread2 = 128;
    while (dataread2 != 0)
    {
        dataread2 = (input(cmdreg) & 128);
    }
}

void sendDatnv(unsigned char data)
{
    // Послать данные в регистр данных, без ожидания готовности
    output(datareg, data);
}

void sendCmd(unsigned char command)
{
    // Послать код команды в регистр команд
    unsigned char dataread2;
    output(cmdreg, command);
    dataread2 = 1;
    while (dataread2 == 1)
    {
        dataread2 = input(cmdreg) & 1;
    }
}

void resetGS(void)
{
    sendCmd(0xF4);
}

unsigned long getMem(void)
{
    unsigned char ramL, ramM, RamH;
    sendCmd(0x20);
    ramL = getDat();
    ramM = getDat();
    RamH = getDat();
    return (65536 * RamH + 256 * ramM + ramL);
}

/* Convert an int to it's binary representation */
char *int2bin(int num, int pad)
{
 char *str = malloc(sizeof(char) * (pad+1));
  if (str) {
   str[pad]='\0';
   while (--pad>=0) {
    str[pad] = num & 1 ? '1' : '0';
    num >>= 1;
   }
  } else {
   return "";
  }
 return str;
}

C_task main(void)
{
    unsigned char dataread, modHandle, q, qdec;
    unsigned long loadloop;
    os_initstdio();

    getDat();

    BOX(1, 1, 80, 25, 40, ' ');
    AT(23, 1);
    ATRIB(92);
    printf("[GENERAL SOUND LOW LEVEL TESTER]\r\n\r\n");

    printf("Testing  STATUS register 0xBB \r\n\r\n");

    qdec = getStat();
    q = qdec & 129; // 10000001

    switch (q)
    {
    case 0:
        printf("  DATA bit and COMMAND bit are reset [0xxxxxx0][%u][%s]. OK.\r\n\r\n",qdec , int2bin(qdec, 8));
        break;
    case 129:
        printf("  DATA bit and COMMAND bit are set [1xxxxxx1][%u][%s]. FAIL.\r\n\r\n",qdec , int2bin(qdec, 8));
        break;
    case 128:
        printf("  DATA bit are set [1xxxxxx0][%u][%s]. FAIL. \r\n\r\n",qdec , int2bin(qdec, 8));
        break;
    case 1:
        printf("  COMMAND bit are set [0xxxxxx1][%u][%s]. FAIL. \r\n\r\n",qdec , int2bin(qdec, 8));
    default:
        printf("  Error detecting status. [%u][%s]. FAIL.\r\n\r\n",qdec , int2bin(qdec, 8));
    }

    printf("Resetting GS... \r\n");
    resetGS();
    printf("Reset OK. Internal memory test...\r\n\r\n");

    dataread = 0;
    while (dataread == 0)
    {
        dataread = input(datareg);
    }

    printf("Reported by boot : %u pages\r\n", dataread);
    printf("Reported by 0x20 : %lu bytes\r\n\r\n", getMem());

    sendCmd(0xFA);
    printf("sendCmd (0xFA) - Test mode on;\r\n");
    sendCmd(11);
    printf("sendCmd (11)   - Sound in chanel #1;\r\n");
    sendCmd(12);
    printf("sendCmd (12)   - Sound in chanel #2;\r\n");
    sendCmd(13);
    printf("sendCmd (13)   - Sound in chanel #3;\r\n");
    sendCmd(14);
    printf("sendCmd (14)   - Sound in chanel #4;\r\n\r\n");

    printf("Uploading test tune...\r\n");
    sendCmd(0x30);
    modHandle = getDat();
    sendCmd(0xD1);
    for (loadloop = 0; loadloop < sizeof(rawData); loadloop++)
    {
        sendDat(rawData[loadloop]);
    }
    sendCmd(0xD2);
    loadloop = sizeof(rawData);
    printf("%lu bytes uploaded.\r\n", loadloop);
    sendDatnv(modHandle);
    sendCmd(0x31);
    printf("Playing handle %u...\r\n", modHandle);

    do
    {
    } while (_low_level_get() == 0);
    sendCmd(0xf3);
    return 0;
}
