
#include <stdlib.h>
#include <stdio.h>
#include "aes256.h"
#include <stdio.h>
#include <oscalls.h>

#define DUMP(s, i, buf, sz)          \
    {                                \
        printf(s);                   \
        for (i = 0; i < (sz); i++)   \
            printf("%02x ", buf[i]); \
        printf("\r\n");                \
    }

int main(int argc, char *argv[])
{
    aesctx ctx;
    aesctx ctx1;

    unsigned char key[32] = {060, 061, 062, 063, 064, 065, 066, 067, 070, 071, 060, 061, 062, 063, 064, 065, 060, 061, 062, 063, 064, 065, 066, 067, 070, 071, 060, 061, 062, 063, 064, 065};
    unsigned char buf[16] = {060, 061, 062, 063, 064, 065, 066, 067, 070, 071, 060, 061, 062, 063, 064, 065};

    int i;

    os_initstdio();

    DUMP("txt: ", i, buf, sizeof(buf));
    DUMP("key: ", i, key, sizeof(key));
    printf("---\r\n");

    aesini(&ctx, key);
    aesenc(&ctx, buf);

    DUMP("enc: ", i, buf, sizeof(buf));
    printf("tst: 06 b2 d7 c9 fe f2 45 4c 76 7f 3f 1c 7c b2 a6 77\r\n");

    aesini(&ctx1, key);
    aesdec(&ctx1, buf);
    DUMP("dec: ", i, buf, sizeof(buf));

    aesdon(&ctx);
    aesdon(&ctx1);

    return 0;
}
