#include "ff.h"
#include <stdlib.h>
const FATFS* fs=(void*)0;
void fs_init(void){
	fs_mount ((FATFS*)fs, "0:", 1);
	return;
}