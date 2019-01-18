/**
  ******************************************************************************
  * @file    opora_arinc429t_defs.h
  * @author  Phyton Application Team
  * @version V1.0.0
  * @date
  * @brief   This file contains all the Special Function Registers definitions
  *          for the ARINC429T peripheral unit used in the Milandr OPORA
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
  * FILE opora_arinc429t_defs.h
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __OPORA_ARINC429T_DEFS_H
#define __OPORA_ARINC429T_DEFS_H

/** @addtogroup __CMSIS CMSIS
  * @{
  */

/** @addtogroup __OPORA_Peripheral_Units OPORA Peripheral Units
  * @{
  */

/** @defgroup Periph_ARINC429T ARINC429T
  * @{
  */

/** @defgroup Periph_ARINC429T_Data_Structures Data Structures
  * @{
  */

/** @defgroup Periph_ARINC429T_TypeDef ARINC429T_TypeDef
  * @{
  */

typedef struct {
  __IO uint32_t CONTROL1;
  __IO uint32_t CONTROL2;
  __IO uint32_t STATUS;
  __IO uint32_t DATA1_T;
  __IO uint32_t DATA2_T;
  __IO uint32_t DATA3_T;
  __IO uint32_t DATA4_T;
  __IO uint32_t CONTROL3;
} ARINC429T_TypeDef;

/** @} */ /* End of group Periph_ARINC429T_TypeDef */

/** @} */ /* End of group Periph_ARINC429T_Data_Structures */

/** @defgroup Periph_ARINC429T_Defines Defines
  * @{
  */

/** @defgroup Periph_ARINC429T_ARINC429T_CONTROL1_Bits ARINC429T_CONTROL1
  * @{
  */

#define ARINC429T_CONTROL1_CH_EN1_OFFS          0
#define ARINC429T_CONTROL1_CH_EN1               ((uint32_t)0x00000001)

#define ARINC429T_CONTROL1_CLK1_OFFS            1
#define ARINC429T_CONTROL1_CLK1                 ((uint32_t)0x00000002)

#define ARINC429T_CONTROL1_EN_PAR1_OFFS         2
#define ARINC429T_CONTROL1_EN_PAR1              ((uint32_t)0x00000004)

#define ARINC429T_CONTROL1_ODD1_OFFS            3
#define ARINC429T_CONTROL1_ODD1                 ((uint32_t)0x00000008)

#define ARINC429T_CONTROL1_CH_EN2_OFFS          4
#define ARINC429T_CONTROL1_CH_EN2               ((uint32_t)0x00000010)

#define ARINC429T_CONTROL1_CLK2_OFFS            5
#define ARINC429T_CONTROL1_CLK2                 ((uint32_t)0x00000020)

#define ARINC429T_CONTROL1_EN_PAR2_OFFS         6
#define ARINC429T_CONTROL1_EN_PAR2              ((uint32_t)0x00000040)

#define ARINC429T_CONTROL1_ODD2_OFFS            7
#define ARINC429T_CONTROL1_ODD2                 ((uint32_t)0x00000080)

#define ARINC429T_CONTROL1_DIV_OFFS             8
#define ARINC429T_CONTROL1_DIV_MASK             ((uint32_t)0x00007F00)

#define ARINC429T_CONTROL1_INTE_FFT1_OFFS       15
#define ARINC429T_CONTROL1_INTE_FFT1            ((uint32_t)0x00008000)

#define ARINC429T_CONTROL1_INTE_TXR1_OFFS       16
#define ARINC429T_CONTROL1_INTE_TXR1            ((uint32_t)0x00010000)

#define ARINC429T_CONTROL1_INTE_HFT1_OFFS       17
#define ARINC429T_CONTROL1_INTE_HFT1            ((uint32_t)0x00020000)

#define ARINC429T_CONTROL1_INTE_FFT2_OFFS       18
#define ARINC429T_CONTROL1_INTE_FFT2            ((uint32_t)0x00040000)

#define ARINC429T_CONTROL1_INTE_TXR2_OFFS       19
#define ARINC429T_CONTROL1_INTE_TXR2            ((uint32_t)0x00080000)

#define ARINC429T_CONTROL1_INTE_HFT2_OFFS       20
#define ARINC429T_CONTROL1_INTE_HFT2            ((uint32_t)0x00100000)


/** @} */ /* End of group Periph_ARINC429T_ARINC429T_CONTROL1_Bits */

/** @} */ /* End of group Periph_ARINC429T_Defines */

/** @defgroup Periph_ARINC429T_Defines Defines
  * @{
  */

/** @defgroup Periph_ARINC429T_ARINC429T_CONTROL2_Bits ARINC429T_CONTROL2
  * @{
  */

#define ARINC429T_CONTROL2_CH_EN3_OFFS          0
#define ARINC429T_CONTROL2_CH_EN3               ((uint32_t)0x00000001)

#define ARINC429T_CONTROL2_CLK3_OFFS            1
#define ARINC429T_CONTROL2_CLK3                 ((uint32_t)0x00000002)

#define ARINC429T_CONTROL2_EN_PAR3_OFFS         2
#define ARINC429T_CONTROL2_EN_PAR3              ((uint32_t)0x00000004)

#define ARINC429T_CONTROL2_ODD3_OFFS            3
#define ARINC429T_CONTROL2_ODD3                 ((uint32_t)0x00000008)

#define ARINC429T_CONTROL2_CH_EN4_OFFS          4
#define ARINC429T_CONTROL2_CH_EN4               ((uint32_t)0x00000010)

#define ARINC429T_CONTROL2_CLK4_OFFS            5
#define ARINC429T_CONTROL2_CLK4                 ((uint32_t)0x00000020)

#define ARINC429T_CONTROL2_EN_PAR4_OFFS         6
#define ARINC429T_CONTROL2_EN_PAR4              ((uint32_t)0x00000040)

#define ARINC429T_CONTROL2_ODD4_OFFS            7
#define ARINC429T_CONTROL2_ODD4                 ((uint32_t)0x00000080)

#define ARINC429T_CONTROL2_INTE_FFT3_OFFS       15
#define ARINC429T_CONTROL2_INTE_FFT3            ((uint32_t)0x00008000)

#define ARINC429T_CONTROL2_INTE_TXR3_OFFS       16
#define ARINC429T_CONTROL2_INTE_TXR3            ((uint32_t)0x00010000)

#define ARINC429T_CONTROL2_INTE_HFT3_OFFS       17
#define ARINC429T_CONTROL2_INTE_HFT3            ((uint32_t)0x00020000)

#define ARINC429T_CONTROL2_INTE_FFT4_OFFS       18
#define ARINC429T_CONTROL2_INTE_FFT4            ((uint32_t)0x00040000)

#define ARINC429T_CONTROL2_INTE_TXR4_OFFS       19
#define ARINC429T_CONTROL2_INTE_TXR4            ((uint32_t)0x00080000)

#define ARINC429T_CONTROL2_INTE_HFT4_OFFS       20
#define ARINC429T_CONTROL2_INTE_HFT4            ((uint32_t)0x00100000)


/** @} */ /* End of group Periph_ARINC429T_ARINC429T_CONTROL2_Bits */

/** @} */ /* End of group Periph_ARINC429T_Defines */

/** @defgroup Periph_ARINC429T_Defines Defines
  * @{
  */

/** @defgroup Periph_ARINC429T_ARINC429T_STATUS_Bits ARINC429T_STATUS
  * @{
  */

#define ARINC429T_STATUS_TX_R1_OFFS             0
#define ARINC429T_STATUS_TX_R1                  ((uint32_t)0x00000001)

#define ARINC429T_STATUS_FFT1_OFFS              1
#define ARINC429T_STATUS_FFT1                   ((uint32_t)0x00000002)

#define ARINC429T_STATUS_HFT1_OFFS              2
#define ARINC429T_STATUS_HFT1                   ((uint32_t)0x00000004)

#define ARINC429T_STATUS_TX_R2_OFFS             3
#define ARINC429T_STATUS_TX_R2                  ((uint32_t)0x00000008)

#define ARINC429T_STATUS_FFT2_OFFS              4
#define ARINC429T_STATUS_FFT2                   ((uint32_t)0x00000010)

#define ARINC429T_STATUS_HFT2_OFFS              5
#define ARINC429T_STATUS_HFT2                   ((uint32_t)0x00000020)

#define ARINC429T_STATUS_TX_R3_OFFS             8
#define ARINC429T_STATUS_TX_R3                  ((uint32_t)0x00000100)

#define ARINC429T_STATUS_FFT3_OFFS              9
#define ARINC429T_STATUS_FFT3                   ((uint32_t)0x00000200)

#define ARINC429T_STATUS_HFT3_OFFS              10
#define ARINC429T_STATUS_HFT3                   ((uint32_t)0x00000400)

#define ARINC429T_STATUS_TX_R4_OFFS             11
#define ARINC429T_STATUS_TX_R4                  ((uint32_t)0x00000800)

#define ARINC429T_STATUS_FFT4_OFFS              12
#define ARINC429T_STATUS_FFT4                   ((uint32_t)0x00001000)

#define ARINC429T_STATUS_HFT4_OFFS              13
#define ARINC429T_STATUS_HFT4                   ((uint32_t)0x00002000)


/** @} */ /* End of group Periph_ARINC429T_ARINC429T_STATUS_Bits */

/** @} */ /* End of group Periph_ARINC429T_Defines */

/** @} */ /* End of group Periph_ARINC429T */

/** @} */ /* End of group __OPORA_Peripheral_Units */

/** @} */ /* End of group __CMSIS */

#endif /* __OPORA_ARINC429T_DEFS_H */

/******************* (C) COPYRIGHT 2010 Phyton *********************************
*
* END OF FILE opora_arinc429t_defs.h */
