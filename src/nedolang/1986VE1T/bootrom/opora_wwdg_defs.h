/**
  ******************************************************************************
  * @file    opora_wwdg_defs.h
  * @author  Phyton Application Team
  * @version V1.0.0
  * @date
  * @brief   This file contains all the Special Function Registers definitions
  *          for the WWDG peripheral unit used in the Milandr OPORA
  *          microcontrollers.
  ******************************************************************************
  * @copy
  *
  * THE PRESENT FIRMWARE WHICH IS FOR GUIDANCE ONLY AIMS AT PROVIDING CUSTOMERS
  * WITH CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE
  * TIME. AS A RESULT, PHYTON SHALL NOT BE HELD LIABLE FOR ANY DIRECT, INDIRECT
  * OR CONSEQUENTIAL DAMAGES WITH RESPECT TO ANY CLAIMS ARISING
  * FROM THE CONTENT OF SUCH FIRMWARE AND/OR THE USE MADE BY CUSTOMERS OF THE
  * CODING INFORMATION CONTAINED HEREIN IN CONNECTION WITH THEIR PRODUCTS.
  *
  * <h2><center>&copy; COPYRIGHT 2010 Phyton</center></h2>
  ******************************************************************************
  * FILE opora_wwdg_defs.h
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __OPORA_WWDG_DEFS_H
#define __OPORA_WWDG_DEFS_H

/** @addtogroup __CMSIS CMSIS
  * @{
  */

/** @addtogroup __OPORA_Peripheral_Units OPORA Peripheral Units
  * @{
  */

/** @defgroup Periph_WWDG WWDG
  * @{
  */

/** @defgroup Periph_WWDG_Data_Structures Data Structures
  * @{
  */

/** @defgroup Periph_WWDG_TypeDef WWDG_TypeDef
  * @{
  */

typedef struct {
  __IO uint32_t CR;
  __IO uint32_t CFR;
  __IO uint32_t SR;
} WWDG_TypeDef;

/** @} */ /* End of group Periph_WWDG_TypeDef */

/** @} */ /* End of group Periph_WWDG_Data_Structures */

/** @defgroup Periph_WWDG_Defines Defines
  * @{
  */

/** @defgroup Periph_WWDG_WWDG_CR_Bits WWDG_CR
  * @{
  */

#define WWDG_CR_T_OFFS                          0
#define WWDG_CR_T_MASK                          ((uint32_t)0x0000007F)

#define WWDG_CR_WDGA_OFFS                       7
#define WWDG_CR_WDGA                            ((uint32_t)0x00000080)


/** @} */ /* End of group Periph_WWDG_WWDG_CR_Bits */

/** @} */ /* End of group Periph_WWDG_Defines */

/** @defgroup Periph_WWDG_Defines Defines
  * @{
  */

/** @defgroup Periph_WWDG_WWDG_CFR_Bits WWDG_CFR
  * @{
  */

#define WWDG_CFR_W_OFFS                         0
#define WWDG_CFR_W_MASK                         ((uint32_t)0x0000007F)

#define WWDG_CFR_WGTB_OFFS                      7
#define WWDG_CFR_WGTB_MASK                      ((uint32_t)0x00000180)

#define WWDG_CFR_EWI_OFFS                       9
#define WWDG_CFR_EWI                            ((uint32_t)0x00000200)


/** @} */ /* End of group Periph_WWDG_WWDG_CFR_Bits */

/** @} */ /* End of group Periph_WWDG_Defines */

/** @} */ /* End of group Periph_WWDG */

/** @} */ /* End of group __OPORA_Peripheral_Units */

/** @} */ /* End of group __CMSIS */

#endif /* __OPORA_WWDG_DEFS_H */

/******************* (C) COPYRIGHT 2010 Phyton *********************************
*
* END OF FILE opora_wwdg_defs.h */
