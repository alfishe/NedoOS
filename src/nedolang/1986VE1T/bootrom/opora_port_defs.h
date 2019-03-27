/**
  ******************************************************************************
  * @file    opora_port_defs.h
  * @author  Phyton Application Team
  * @version V1.0.0
  * @date
  * @brief   This file contains all the Special Function Registers definitions
  *          for the PORT peripheral unit used in the Milandr OPORA
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
  * FILE opora_port_defs.h
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __OPORA_PORT_DEFS_H
#define __OPORA_PORT_DEFS_H

/** @addtogroup __CMSIS CMSIS
  * @{
  */

/** @addtogroup __OPORA_Peripheral_Units OPORA Peripheral Units
  * @{
  */

/** @defgroup Periph_PORT PORT
  * @{
  */

/** @defgroup Periph_PORT_Data_Structures Data Structures
  * @{
  */

/** @defgroup Periph_PORT_TypeDef PORT_TypeDef
  * @{
  */

typedef struct {
  __IO uint32_t RXTX;
  __IO uint32_t OE;
  __IO uint32_t FUNC;
  __IO uint32_t ANALOG;
  __IO uint32_t PULL;
  __IO uint32_t PD;
  __IO uint32_t PWR;
  __IO uint32_t GFEN;
  __IO uint32_t SETTX;
  __IO uint32_t CLRTX;
  __IO uint32_t RDTX;
} PORT_TypeDef;

/** @} */ /* End of group Periph_PORT_TypeDef */

/** @} */ /* End of group Periph_PORT_Data_Structures */

/** @defgroup Periph_PORT_Defines Defines
  * @{
  */

/** @defgroup Periph_PORT_PORT_FUNC_Bits PORT_FUNC
  * @{
  */

#define PORT_FUNC_MODE0_OFFS                    0
#define PORT_FUNC_MODE0_MASK                    ((uint32_t)0x00000003)

#define PORT_FUNC_MODE1_OFFS                    2
#define PORT_FUNC_MODE1_MASK                    ((uint32_t)0x0000000C)

#define PORT_FUNC_MODE2_OFFS                    4
#define PORT_FUNC_MODE2_MASK                    ((uint32_t)0x00000030)

#define PORT_FUNC_MODE3_OFFS                    6
#define PORT_FUNC_MODE3_MASK                    ((uint32_t)0x000000C0)

#define PORT_FUNC_MODE4_OFFS                    8
#define PORT_FUNC_MODE4_MASK                    ((uint32_t)0x00000300)

#define PORT_FUNC_MODE5_OFFS                    10
#define PORT_FUNC_MODE5_MASK                    ((uint32_t)0x00000C00)

#define PORT_FUNC_MODE6_OFFS                    12
#define PORT_FUNC_MODE6_MASK                    ((uint32_t)0x00003000)

#define PORT_FUNC_MODE7_OFFS                    14
#define PORT_FUNC_MODE7_MASK                    ((uint32_t)0x0000C000)

#define PORT_FUNC_MODE8_OFFS                    16
#define PORT_FUNC_MODE8_MASK                    ((uint32_t)0x00030000)

#define PORT_FUNC_MODE9_OFFS                    18
#define PORT_FUNC_MODE9_MASK                    ((uint32_t)0x000C0000)

#define PORT_FUNC_MODE10_OFFS                   20
#define PORT_FUNC_MODE10_MASK                   ((uint32_t)0x00300000)

#define PORT_FUNC_MODE11_OFFS                   22
#define PORT_FUNC_MODE11_MASK                   ((uint32_t)0x00C00000)

#define PORT_FUNC_MODE12_OFFS                   24
#define PORT_FUNC_MODE12_MASK                   ((uint32_t)0x03000000)

#define PORT_FUNC_MODE13_OFFS                   26
#define PORT_FUNC_MODE13_MASK                   ((uint32_t)0x0C000000)

#define PORT_FUNC_MODE14_OFFS                   28
#define PORT_FUNC_MODE14_MASK                   ((uint32_t)0x30000000)

#define PORT_FUNC_MODE15_OFFS                   30
#define PORT_FUNC_MODE15_MASK                   ((uint32_t)0xC0000000)


/** @} */ /* End of group Periph_PORT_PORT_FUNC_Bits */

/** @} */ /* End of group Periph_PORT_Defines */

/** @defgroup Periph_PORT_Defines Defines
  * @{
  */

/** @defgroup Periph_PORT_PORT_PWR_Bits PORT_PWR
  * @{
  */

#define PORT_PWR_PWR0_OFFS                      0
#define PORT_PWR_PWR0_MASK                      ((uint32_t)0x00000003)

#define PORT_PWR_PWR1_OFFS                      2
#define PORT_PWR_PWR1_MASK                      ((uint32_t)0x0000000C)

#define PORT_PWR_PWR2_OFFS                      4
#define PORT_PWR_PWR2_MASK                      ((uint32_t)0x00000030)

#define PORT_PWR_PWR3_OFFS                      6
#define PORT_PWR_PWR3_MASK                      ((uint32_t)0x000000C0)

#define PORT_PWR_PWR4_OFFS                      8
#define PORT_PWR_PWR4_MASK                      ((uint32_t)0x00000300)

#define PORT_PWR_PWR5_OFFS                      10
#define PORT_PWR_PWR5_MASK                      ((uint32_t)0x00000C00)

#define PORT_PWR_PWR6_OFFS                      12
#define PORT_PWR_PWR6_MASK                      ((uint32_t)0x00003000)

#define PORT_PWR_PWR7_OFFS                      14
#define PORT_PWR_PWR7_MASK                      ((uint32_t)0x0000C000)

#define PORT_PWR_PWR8_OFFS                      16
#define PORT_PWR_PWR8_MASK                      ((uint32_t)0x00030000)

#define PORT_PWR_PWR9_OFFS                      18
#define PORT_PWR_PWR9_MASK                      ((uint32_t)0x000C0000)

#define PORT_PWR_PWR10_OFFS                     20
#define PORT_PWR_PWR10_MASK                     ((uint32_t)0x00300000)

#define PORT_PWR_PWR11_OFFS                     22
#define PORT_PWR_PWR11_MASK                     ((uint32_t)0x00C00000)

#define PORT_PWR_PWR12_OFFS                     24
#define PORT_PWR_PWR12_MASK                     ((uint32_t)0x03000000)

#define PORT_PWR_PWR13_OFFS                     26
#define PORT_PWR_PWR13_MASK                     ((uint32_t)0x0C000000)

#define PORT_PWR_PWR14_OFFS                     28
#define PORT_PWR_PWR14_MASK                     ((uint32_t)0x30000000)

#define PORT_PWR_PWR15_OFFS                     30
#define PORT_PWR_PWR15_MASK                     ((uint32_t)0xC0000000)


/** @} */ /* End of group Periph_PORT_PORT_PWR_Bits */

/** @} */ /* End of group Periph_PORT_Defines */

/** @} */ /* End of group Periph_PORT */

/** @} */ /* End of group __OPORA_Peripheral_Units */

/** @} */ /* End of group __CMSIS */

#endif /* __OPORA_PORT_DEFS_H */

/******************* (C) COPYRIGHT 2010 Phyton *********************************
*
* END OF FILE opora_port_defs.h */
