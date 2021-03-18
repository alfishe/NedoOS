#include <evo.h>







//void uwol_preinit_variables(void);
//void uwol_main(void);
//void sp_Init(void);
//void fases_init(void);

#include "uwol.c"


int main()
{

    //tfc_init(NULL);
    //psgfx_init(uwpsgfx_data);

    sp_Init();
    fases_init();
    uwol_preinit_variables();
    uwolmain();

    return 0;
}
