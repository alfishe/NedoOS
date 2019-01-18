/**
  ******************************************************************************
  * @file    opora_power_defs.h
  * @author  Phyton Application Team
  * @version V1.0.0
  * @date
  * @brief   This file contains all the Special Function Registers definitions
  *          for the POWER peripheral unit used in the Milandr OPORA
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
  * FILE opora_power_defs.h
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __OPORA_POWER_DEFS_H
#define __OPORA_POWER_DEFS_H

/** @addtogroup __CMSIS CMSIS
  * @{
  */

/** @addtogroup __OPORA_Peripheral_Units OPORA Peripheral Units
  * @{
  */

/** @defgroup Periph_POWER POWER
  * @{
  */

/** @defgroup Periph_POWER_Data_Structures Data Structures
  * @{
  */

/** @defgroup Periph_POWER_TypeDef POWER_TypeDef
  * @{
  */

typedef struct {
  __IO uint32_t PVDCS;
} POWER_TypeDef;

/** @} */ /* End of group Periph_POWER_TypeDef */

/** @} */ /* End of group Periph_POWER_Data_Structures */

/** @defgroup Periph_POWER_Defines Defines
  * @{
  */

/** @defgroup Periph_POWER_POWER_PVDCS_Bits POWER_PVDCS
  * @{
  */

#define POWER_PVDCS_PVDEN_OFFS                  0
#define POWER_PVDCS_PVDEN                       ((uint32_t)0x00000001)

#define POWER_PVDCS_PBLS_OFFS                   1
#define POWER_PVDCS_PBLS_MASK                   ((uint32_t)0x00000006)

#define POWER_PVDCS_PLS_OFFS                    3
#define POWER_PVDCS_PLS_MASK                    ((uint32_t)0x00000038)

#define POWER_PVDCS_PVBD_OFFS                   6
#define POWER_PVDCS_PVBD                        ((uint32_t)0x00000040)

#define POWER_PVDCS_PVD_OFFS                    7
#define POWER_PVDCS_PVD                         ((uint32_t)0x00000080)

#define POWER_PVDCS_IEPVBD_OFFS                 8
#define POWER_PVDCS_IEPVBD                      ((uint32_t)0x00000100)

#define POWER_PVDCS_IEPVD_OFFS                  9
#define POWER_PVDCS_IEPVD                       ((uint32_t)0x00000200)

#define POWER_PVDCS_INVB_OFFS                   10
#define POWER_PVDCS_INVB                        ((uint32_t)0x00000400)

#define POWER_PVDCS_INV_OFFS                    11
#define POWER_PVDCS_INV                         ((uint32_t)0x00000800)


/** @} */ /* End of group Periph_POWER_POWER_PVDCS_Bits */

/** @} */ /* End of group Periph_POWER_Defines */

/** @} */ /* End of group Periph_POWER */

/** @} */ /* End of group __OPORA_Peripheral_Units */

/** @} */ /* End of group __CMSIS */

#endif /* __OPORA_POWER_DEFS_H */

/******************* (C) COPYRIGHT 2010 Phyton *********************************
*
* END OF FILE opora_power_defs.h */
