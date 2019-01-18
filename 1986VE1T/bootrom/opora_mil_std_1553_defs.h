/**
  ******************************************************************************
  * @file    opora_mil_std_1553_defs.h
  * @author  Phyton Application Team
  * @version V1.0.0
  * @date
  * @brief   This file contains all the Special Function Registers definitions
  *          for the MIL_STD_1553 peripheral unit used in the Milandr OPORA
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
  * FILE opora_mil_std_1553_defs.h
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __OPORA_MIL_STD_1553_DEFS_H
#define __OPORA_MIL_STD_1553_DEFS_H

/** @addtogroup __CMSIS CMSIS
  * @{
  */

/** @addtogroup __OPORA_Peripheral_Units OPORA Peripheral Units
  * @{
  */

/** @defgroup Periph_MIL_STD_1553 MIL_STD_1553
  * @{
  */

/** @defgroup Periph_MIL_STD_1553_Data_Structures Data Structures
  * @{
  */

/** @defgroup Periph_MIL_STD_1553_TypeDef MIL_STD_1553_TypeDef
  * @{
  */

typedef struct {
       uint32_t RESERVED0[1024];
  __IO uint32_t CONTROL;
  __IO uint32_t STATUS;
  __IO uint32_t ERROR;
  __IO uint32_t CommandWord1;
  __IO uint32_t CommandWord2;
  __IO uint32_t ModeData;
  __IO uint32_t StatusWord1;
  __IO uint32_t StatusWord2;
  __IO uint32_t INTEN;
  __IO uint32_t MSG;
} MIL_STD_1553_TypeDef;

/** @} */ /* End of group Periph_MIL_STD_1553_TypeDef */

/** @} */ /* End of group Periph_MIL_STD_1553_Data_Structures */

/** @defgroup Periph_MIL_STD_1553_Defines Defines
  * @{
  */

/** @defgroup Periph_MIL_STD_1553_MIL_STD_1553_CONTROL_Bits MIL_STD_1553_CONTROL
  * @{
  */

#define MIL_STD_1553_CONTROL_MR_OFFS            0
#define MIL_STD_1553_CONTROL_MR                 ((uint32_t)0x00000001)

#define MIL_STD_1553_CONTROL_BCSTART_OFFS       1
#define MIL_STD_1553_CONTROL_BCSTART            ((uint32_t)0x00000002)

#define MIL_STD_1553_CONTROL_BCMODE_OFFS        2
#define MIL_STD_1553_CONTROL_BCMODE             ((uint32_t)0x00000004)

#define MIL_STD_1553_CONTROL_RTMODE_OFFS        3
#define MIL_STD_1553_CONTROL_RTMODE             ((uint32_t)0x00000008)

#define MIL_STD_1553_CONTROL_TRA_OFFS           4
#define MIL_STD_1553_CONTROL_TRA                ((uint32_t)0x00000010)

#define MIL_STD_1553_CONTROL_TRB_OFFS           5
#define MIL_STD_1553_CONTROL_TRB                ((uint32_t)0x00000020)

#define MIL_STD_1553_CONTROL_RTA_OFFS           6
#define MIL_STD_1553_CONTROL_RTA_MASK           ((uint32_t)0x000007C0)

#define MIL_STD_1553_CONTROL_DIV_OFFS           11
#define MIL_STD_1553_CONTROL_DIV_MASK           ((uint32_t)0x0003F800)

#define MIL_STD_1553_CONTROL_RERR_OFFS          18
#define MIL_STD_1553_CONTROL_RERR               ((uint32_t)0x00040000)


/** @} */ /* End of group Periph_MIL_STD_1553_MIL_STD_1553_CONTROL_Bits */

/** @} */ /* End of group Periph_MIL_STD_1553_Defines */

/** @defgroup Periph_MIL_STD_1553_Defines Defines
  * @{
  */

/** @defgroup Periph_MIL_STD_1553_MIL_STD_1553_STATUS_Bits MIL_STD_1553_STATUS
  * @{
  */

#define MIL_STD_1553_STATUS_IDLE_OFFS           0
#define MIL_STD_1553_STATUS_IDLE                ((uint32_t)0x00000001)

#define MIL_STD_1553_STATUS_RFLAGN_OFFS         1
#define MIL_STD_1553_STATUS_RFLAGN              ((uint32_t)0x00000002)

#define MIL_STD_1553_STATUS_VALMESS_OFFS        2
#define MIL_STD_1553_STATUS_VALMESS             ((uint32_t)0x00000004)

#define MIL_STD_1553_STATUS_ERR_OFFS            3
#define MIL_STD_1553_STATUS_ERR                 ((uint32_t)0x00000008)


/** @} */ /* End of group Periph_MIL_STD_1553_MIL_STD_1553_STATUS_Bits */

/** @} */ /* End of group Periph_MIL_STD_1553_Defines */

/** @defgroup Periph_MIL_STD_1553_Defines Defines
  * @{
  */

/** @defgroup Periph_MIL_STD_1553_MIL_STD_1553_ERROR_Bits MIL_STD_1553_ERROR
  * @{
  */

#define MIL_STD_1553_ERROR_NORCV_OFFS           0
#define MIL_STD_1553_ERROR_NORCV                ((uint32_t)0x00000001)

#define MIL_STD_1553_ERROR_MANERR_OFFS          1
#define MIL_STD_1553_ERROR_MANERR               ((uint32_t)0x00000002)

#define MIL_STD_1553_ERROR_SYNCERR_OFFS         2
#define MIL_STD_1553_ERROR_SYNCERR              ((uint32_t)0x00000004)

#define MIL_STD_1553_ERROR_SEQERR_OFFS          3
#define MIL_STD_1553_ERROR_SEQERR               ((uint32_t)0x00000008)

#define MIL_STD_1553_ERROR_GAPERR_OFFS          4
#define MIL_STD_1553_ERROR_GAPERR               ((uint32_t)0x00000010)

#define MIL_STD_1553_ERROR_CONERR_OFFS          5
#define MIL_STD_1553_ERROR_CONERR               ((uint32_t)0x00000020)

#define MIL_STD_1553_ERROR_PROERR_OFFS          6
#define MIL_STD_1553_ERROR_PROERR               ((uint32_t)0x00000040)


/** @} */ /* End of group Periph_MIL_STD_1553_MIL_STD_1553_ERROR_Bits */

/** @} */ /* End of group Periph_MIL_STD_1553_Defines */

/** @defgroup Periph_MIL_STD_1553_Defines Defines
  * @{
  */

/** @defgroup Periph_MIL_STD_1553_MIL_STD_1553_INTEN_Bits MIL_STD_1553_INTEN
  * @{
  */

#define MIL_STD_1553_INTEN_IDLEIE_OFFS          0
#define MIL_STD_1553_INTEN_IDLEIE               ((uint32_t)0x00000001)

#define MIL_STD_1553_INTEN_RFLAGNIE_OFFS        1
#define MIL_STD_1553_INTEN_RFLAGNIE             ((uint32_t)0x00000002)

#define MIL_STD_1553_INTEN_VALMESSIE_OFFS       2
#define MIL_STD_1553_INTEN_VALMESSIE            ((uint32_t)0x00000004)

#define MIL_STD_1553_INTEN_ERRIE_OFFS           3
#define MIL_STD_1553_INTEN_ERRIE                ((uint32_t)0x00000008)


/** @} */ /* End of group Periph_MIL_STD_1553_MIL_STD_1553_INTEN_Bits */

/** @} */ /* End of group Periph_MIL_STD_1553_Defines */

/** @} */ /* End of group Periph_MIL_STD_1553 */

/** @} */ /* End of group __OPORA_Peripheral_Units */

/** @} */ /* End of group __CMSIS */

#endif /* __OPORA_MIL_STD_1553_DEFS_H */

/******************* (C) COPYRIGHT 2010 Phyton *********************************
*
* END OF FILE opora_mil_std_1553_defs.h */
