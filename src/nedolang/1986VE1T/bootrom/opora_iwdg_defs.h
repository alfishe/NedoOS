/**
  ******************************************************************************
  * @file    opora_iwdg_defs.h
  * @author  Phyton Application Team
  * @version V1.0.0
  * @date
  * @brief   This file contains all the Special Function Registers definitions
  *          for the IWDG peripheral unit used in the Milandr OPORA
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
  * FILE opora_iwdg_defs.h
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __OPORA_IWDG_DEFS_H
#define __OPORA_IWDG_DEFS_H

/** @addtogroup __CMSIS CMSIS
  * @{
  */

/** @addtogroup __OPORA_Peripheral_Units OPORA Peripheral Units
  * @{
  */

/** @defgroup Periph_IWDG IWDG
  * @{
  */

/** @defgroup Periph_IWDG_Data_Structures Data Structures
  * @{
  */

/** @defgroup Periph_IWDG_TypeDef IWDG_TypeDef
  * @{
  */

typedef struct {
  __IO uint32_t KR;
  __IO uint32_t PR;
  __IO uint32_t PRL;
  __IO uint32_t SR;
} IWDG_TypeDef;

/** @} */ /* End of group Periph_IWDG_TypeDef */

/** @} */ /* End of group Periph_IWDG_Data_Structures */

/** @defgroup Periph_IWDG_Defines Defines
  * @{
  */

/** @defgroup Periph_IWDG_IWDG_SR_Bits IWDG_SR
  * @{
  */

#define IWDG_SR_PVU_OFFS                        0
#define IWDG_SR_PVU                             ((uint32_t)0x00000001)

#define IWDG_SR_RVU_OFFS                        1
#define IWDG_SR_RVU                             ((uint32_t)0x00000002)


/** @} */ /* End of group Periph_IWDG_IWDG_SR_Bits */

/** @} */ /* End of group Periph_IWDG_Defines */

/** @} */ /* End of group Periph_IWDG */

/** @} */ /* End of group __OPORA_Peripheral_Units */

/** @} */ /* End of group __CMSIS */

#endif /* __OPORA_IWDG_DEFS_H */

/******************* (C) COPYRIGHT 2010 Phyton *********************************
*
* END OF FILE opora_iwdg_defs.h */
