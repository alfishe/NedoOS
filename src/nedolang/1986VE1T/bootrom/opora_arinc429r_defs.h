/**
  ******************************************************************************
  * @file    opora_arinc429r_defs.h
  * @author  Phyton Application Team
  * @version V1.0.0
  * @date
  * @brief   This file contains all the Special Function Registers definitions
  *          for the ARINC429R peripheral unit used in the Milandr OPORA
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
  * FILE opora_arinc429r_defs.h
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __OPORA_ARINC429R_DEFS_H
#define __OPORA_ARINC429R_DEFS_H

/** @addtogroup __CMSIS CMSIS
  * @{
  */

/** @addtogroup __OPORA_Peripheral_Units OPORA Peripheral Units
  * @{
  */

/** @defgroup Periph_ARINC429R ARINC429R
  * @{
  */

/** @defgroup Periph_ARINC429R_Data_Structures Data Structures
  * @{
  */

/** @defgroup Periph_ARINC429R_TypeDef ARINC429R_TypeDef
  * @{
  */

typedef struct {
  __IO uint32_t CONTROL1;
  __IO uint32_t CONTROL2;
  __IO uint32_t CONTROL3;
  __IO uint32_t STATUS1;
  __IO uint32_t STATUS2;
  __IO uint32_t CONTROL4;
  __IO uint32_t CONTROL5;
  __IO uint32_t CHANNEL;
  __IO uint32_t LABEL;
  __IO uint32_t DATA_R;
} ARINC429R_TypeDef;

/** @} */ /* End of group Periph_ARINC429R_TypeDef */

/** @} */ /* End of group Periph_ARINC429R_Data_Structures */

/** @defgroup Periph_ARINC429R_Defines Defines
  * @{
  */

/** @defgroup Periph_ARINC429R_ARINC429R_CONTROL1_Bits ARINC429R_CONTROL1
  * @{
  */

#define ARINC429R_CONTROL1_CH_EN1_OFFS          0
#define ARINC429R_CONTROL1_CH_EN1               ((uint32_t)0x00000001)

#define ARINC429R_CONTROL1_CH_EN2_OFFS          1
#define ARINC429R_CONTROL1_CH_EN2               ((uint32_t)0x00000002)

#define ARINC429R_CONTROL1_CH_EN3_OFFS          2
#define ARINC429R_CONTROL1_CH_EN3               ((uint32_t)0x00000004)

#define ARINC429R_CONTROL1_CH_EN4_OFFS          3
#define ARINC429R_CONTROL1_CH_EN4               ((uint32_t)0x00000008)

#define ARINC429R_CONTROL1_CH_EN5_OFFS          4
#define ARINC429R_CONTROL1_CH_EN5               ((uint32_t)0x00000010)

#define ARINC429R_CONTROL1_CH_EN6_OFFS          5
#define ARINC429R_CONTROL1_CH_EN6               ((uint32_t)0x00000020)

#define ARINC429R_CONTROL1_CH_EN7_OFFS          6
#define ARINC429R_CONTROL1_CH_EN7               ((uint32_t)0x00000040)

#define ARINC429R_CONTROL1_CH_EN8_OFFS          7
#define ARINC429R_CONTROL1_CH_EN8               ((uint32_t)0x00000080)

#define ARINC429R_CONTROL1_CLK1_OFFS            14
#define ARINC429R_CONTROL1_CLK1                 ((uint32_t)0x00004000)

#define ARINC429R_CONTROL1_CLK2_OFFS            15
#define ARINC429R_CONTROL1_CLK2                 ((uint32_t)0x00008000)

#define ARINC429R_CONTROL1_CLK3_OFFS            16
#define ARINC429R_CONTROL1_CLK3                 ((uint32_t)0x00010000)

#define ARINC429R_CONTROL1_CLK4_OFFS            17
#define ARINC429R_CONTROL1_CLK4                 ((uint32_t)0x00020000)

#define ARINC429R_CONTROL1_CLK5_OFFS            18
#define ARINC429R_CONTROL1_CLK5                 ((uint32_t)0x00040000)

#define ARINC429R_CONTROL1_CLK6_OFFS            19
#define ARINC429R_CONTROL1_CLK6                 ((uint32_t)0x00080000)

#define ARINC429R_CONTROL1_CLK7_OFFS            20
#define ARINC429R_CONTROL1_CLK7                 ((uint32_t)0x00100000)

#define ARINC429R_CONTROL1_CLK8_OFFS            21
#define ARINC429R_CONTROL1_CLK8                 ((uint32_t)0x00200000)

#define ARINC429R_CONTROL1_DIV_OFFS             28
#define ARINC429R_CONTROL1_DIV_MASK             ((uint32_t)0xF0000000)


/** @} */ /* End of group Periph_ARINC429R_ARINC429R_CONTROL1_Bits */

/** @} */ /* End of group Periph_ARINC429R_Defines */

/** @defgroup Periph_ARINC429R_Defines Defines
  * @{
  */

/** @defgroup Periph_ARINC429R_ARINC429R_CONTROL2_Bits ARINC429R_CONTROL2
  * @{
  */

#define ARINC429R_CONTROL2_DIV_OFFS             0
#define ARINC429R_CONTROL2_DIV_MASK             ((uint32_t)0x00000007)

#define ARINC429R_CONTROL2_LB_EN1_OFFS          3
#define ARINC429R_CONTROL2_LB_EN1               ((uint32_t)0x00000008)

#define ARINC429R_CONTROL2_LB_EN2_OFFS          4
#define ARINC429R_CONTROL2_LB_EN2               ((uint32_t)0x00000010)

#define ARINC429R_CONTROL2_LB_EN3_OFFS          5
#define ARINC429R_CONTROL2_LB_EN3               ((uint32_t)0x00000020)

#define ARINC429R_CONTROL2_LB_EN4_OFFS          6
#define ARINC429R_CONTROL2_LB_EN4               ((uint32_t)0x00000040)

#define ARINC429R_CONTROL2_LB_EN5_OFFS          7
#define ARINC429R_CONTROL2_LB_EN5               ((uint32_t)0x00000080)

#define ARINC429R_CONTROL2_LB_EN6_OFFS          8
#define ARINC429R_CONTROL2_LB_EN6               ((uint32_t)0x00000100)

#define ARINC429R_CONTROL2_LB_EN7_OFFS          9
#define ARINC429R_CONTROL2_LB_EN7               ((uint32_t)0x00000200)

#define ARINC429R_CONTROL2_LB_EN8_OFFS          10
#define ARINC429R_CONTROL2_LB_EN8               ((uint32_t)0x00000400)

#define ARINC429R_CONTROL2_SD_EN1_OFFS          17
#define ARINC429R_CONTROL2_SD_EN1               ((uint32_t)0x00020000)

#define ARINC429R_CONTROL2_SD_EN2_OFFS          18
#define ARINC429R_CONTROL2_SD_EN2               ((uint32_t)0x00040000)

#define ARINC429R_CONTROL2_SD_EN3_OFFS          19
#define ARINC429R_CONTROL2_SD_EN3               ((uint32_t)0x00080000)

#define ARINC429R_CONTROL2_SD_EN4_OFFS          20
#define ARINC429R_CONTROL2_SD_EN4               ((uint32_t)0x00100000)

#define ARINC429R_CONTROL2_SD_EN5_OFFS          21
#define ARINC429R_CONTROL2_SD_EN5               ((uint32_t)0x00200000)

#define ARINC429R_CONTROL2_SD_EN6_OFFS          22
#define ARINC429R_CONTROL2_SD_EN6               ((uint32_t)0x00400000)

#define ARINC429R_CONTROL2_SD_EN7_OFFS          23
#define ARINC429R_CONTROL2_SD_EN7               ((uint32_t)0x00800000)

#define ARINC429R_CONTROL2_SD_EN8_OFFS          24
#define ARINC429R_CONTROL2_SD_EN8               ((uint32_t)0x01000000)


/** @} */ /* End of group Periph_ARINC429R_ARINC429R_CONTROL2_Bits */

/** @} */ /* End of group Periph_ARINC429R_Defines */

/** @defgroup Periph_ARINC429R_Defines Defines
  * @{
  */

/** @defgroup Periph_ARINC429R_ARINC429R_CONTROL3_Bits ARINC429R_CONTROL3
  * @{
  */

#define ARINC429R_CONTROL3_SDI1_1_OFFS          0
#define ARINC429R_CONTROL3_SDI1_1               ((uint32_t)0x00000001)

#define ARINC429R_CONTROL3_SDI1_2_OFFS          1
#define ARINC429R_CONTROL3_SDI1_2               ((uint32_t)0x00000002)

#define ARINC429R_CONTROL3_SDI1_3_OFFS          2
#define ARINC429R_CONTROL3_SDI1_3               ((uint32_t)0x00000004)

#define ARINC429R_CONTROL3_SDI1_4_OFFS          3
#define ARINC429R_CONTROL3_SDI1_4               ((uint32_t)0x00000008)

#define ARINC429R_CONTROL3_SDI1_5_OFFS          4
#define ARINC429R_CONTROL3_SDI1_5               ((uint32_t)0x00000010)

#define ARINC429R_CONTROL3_SDI1_6_OFFS          5
#define ARINC429R_CONTROL3_SDI1_6               ((uint32_t)0x00000020)

#define ARINC429R_CONTROL3_SDI1_7_OFFS          6
#define ARINC429R_CONTROL3_SDI1_7               ((uint32_t)0x00000040)

#define ARINC429R_CONTROL3_SDI1_8_OFFS          7
#define ARINC429R_CONTROL3_SDI1_8               ((uint32_t)0x00000080)

#define ARINC429R_CONTROL3_SDI2_1_OFFS          14
#define ARINC429R_CONTROL3_SDI2_1               ((uint32_t)0x00004000)

#define ARINC429R_CONTROL3_SDI2_2_OFFS          15
#define ARINC429R_CONTROL3_SDI2_2               ((uint32_t)0x00008000)

#define ARINC429R_CONTROL3_SDI2_3_OFFS          16
#define ARINC429R_CONTROL3_SDI2_3               ((uint32_t)0x00010000)

#define ARINC429R_CONTROL3_SDI2_4_OFFS          17
#define ARINC429R_CONTROL3_SDI2_4               ((uint32_t)0x00020000)

#define ARINC429R_CONTROL3_SDI2_5_OFFS          18
#define ARINC429R_CONTROL3_SDI2_5               ((uint32_t)0x00040000)

#define ARINC429R_CONTROL3_SDI2_6_OFFS          19
#define ARINC429R_CONTROL3_SDI2_6               ((uint32_t)0x00080000)

#define ARINC429R_CONTROL3_SDI2_7_OFFS          20
#define ARINC429R_CONTROL3_SDI2_7               ((uint32_t)0x00100000)

#define ARINC429R_CONTROL3_SDI2_8_OFFS          21
#define ARINC429R_CONTROL3_SDI2_8               ((uint32_t)0x00200000)

#define ARINC429R_CONTROL3_INTEDR_OFFS          28
#define ARINC429R_CONTROL3_INTEDR               ((uint32_t)0x10000000)

#define ARINC429R_CONTROL3_INTEER_OFFS          29
#define ARINC429R_CONTROL3_INTEER               ((uint32_t)0x20000000)

#define ARINC429R_CONTROL3_INTEFF_OFFS          30
#define ARINC429R_CONTROL3_INTEFF               ((uint32_t)0x40000000)

#define ARINC429R_CONTROL3_INTEHF_OFFS          31
#define ARINC429R_CONTROL3_INTEHF               ((uint32_t)0x80000000)


/** @} */ /* End of group Periph_ARINC429R_ARINC429R_CONTROL3_Bits */

/** @} */ /* End of group Periph_ARINC429R_Defines */

/** @defgroup Periph_ARINC429R_Defines Defines
  * @{
  */

/** @defgroup Periph_ARINC429R_ARINC429R_STATUS1_Bits ARINC429R_STATUS1
  * @{
  */

#define ARINC429R_STATUS1_DR1_OFFS              0
#define ARINC429R_STATUS1_DR1                   ((uint32_t)0x00000001)

#define ARINC429R_STATUS1_DR2_OFFS              1
#define ARINC429R_STATUS1_DR2                   ((uint32_t)0x00000002)

#define ARINC429R_STATUS1_DR3_OFFS              2
#define ARINC429R_STATUS1_DR3                   ((uint32_t)0x00000004)

#define ARINC429R_STATUS1_DR4_OFFS              3
#define ARINC429R_STATUS1_DR4                   ((uint32_t)0x00000008)

#define ARINC429R_STATUS1_DR5_OFFS              4
#define ARINC429R_STATUS1_DR5                   ((uint32_t)0x00000010)

#define ARINC429R_STATUS1_DR6_OFFS              5
#define ARINC429R_STATUS1_DR6                   ((uint32_t)0x00000020)

#define ARINC429R_STATUS1_DR7_OFFS              6
#define ARINC429R_STATUS1_DR7                   ((uint32_t)0x00000040)

#define ARINC429R_STATUS1_DR8_OFFS              7
#define ARINC429R_STATUS1_DR8                   ((uint32_t)0x00000080)

#define ARINC429R_STATUS1_ERR1_OFFS             14
#define ARINC429R_STATUS1_ERR1                  ((uint32_t)0x00004000)

#define ARINC429R_STATUS1_ERR2_OFFS             15
#define ARINC429R_STATUS1_ERR2                  ((uint32_t)0x00008000)

#define ARINC429R_STATUS1_ERR3_OFFS             16
#define ARINC429R_STATUS1_ERR3                  ((uint32_t)0x00010000)

#define ARINC429R_STATUS1_ERR4_OFFS             17
#define ARINC429R_STATUS1_ERR4                  ((uint32_t)0x00020000)

#define ARINC429R_STATUS1_ERR5_OFFS             18
#define ARINC429R_STATUS1_ERR5                  ((uint32_t)0x00040000)

#define ARINC429R_STATUS1_ERR6_OFFS             19
#define ARINC429R_STATUS1_ERR6                  ((uint32_t)0x00080000)

#define ARINC429R_STATUS1_ERR7_OFFS             20
#define ARINC429R_STATUS1_ERR7                  ((uint32_t)0x00100000)

#define ARINC429R_STATUS1_ERR8_OFFS             21
#define ARINC429R_STATUS1_ERR8                  ((uint32_t)0x00200000)


/** @} */ /* End of group Periph_ARINC429R_ARINC429R_STATUS1_Bits */

/** @} */ /* End of group Periph_ARINC429R_Defines */

/** @defgroup Periph_ARINC429R_Defines Defines
  * @{
  */

/** @defgroup Periph_ARINC429R_ARINC429R_STATUS2_Bits ARINC429R_STATUS2
  * @{
  */

#define ARINC429R_STATUS2_FF1_OFFS              0
#define ARINC429R_STATUS2_FF1                   ((uint32_t)0x00000001)

#define ARINC429R_STATUS2_FF2_OFFS              1
#define ARINC429R_STATUS2_FF2                   ((uint32_t)0x00000002)

#define ARINC429R_STATUS2_FF3_OFFS              2
#define ARINC429R_STATUS2_FF3                   ((uint32_t)0x00000004)

#define ARINC429R_STATUS2_FF4_OFFS              3
#define ARINC429R_STATUS2_FF4                   ((uint32_t)0x00000008)

#define ARINC429R_STATUS2_FF5_OFFS              4
#define ARINC429R_STATUS2_FF5                   ((uint32_t)0x00000010)

#define ARINC429R_STATUS2_FF6_OFFS              5
#define ARINC429R_STATUS2_FF6                   ((uint32_t)0x00000020)

#define ARINC429R_STATUS2_FF7_OFFS              6
#define ARINC429R_STATUS2_FF7                   ((uint32_t)0x00000040)

#define ARINC429R_STATUS2_FF8_OFFS              7
#define ARINC429R_STATUS2_FF8                   ((uint32_t)0x00000080)

#define ARINC429R_STATUS2_HF1_OFFS              14
#define ARINC429R_STATUS2_HF1                   ((uint32_t)0x00004000)

#define ARINC429R_STATUS2_HF2_OFFS              15
#define ARINC429R_STATUS2_HF2                   ((uint32_t)0x00008000)

#define ARINC429R_STATUS2_HF3_OFFS              16
#define ARINC429R_STATUS2_HF3                   ((uint32_t)0x00010000)

#define ARINC429R_STATUS2_HF4_OFFS              17
#define ARINC429R_STATUS2_HF4                   ((uint32_t)0x00020000)

#define ARINC429R_STATUS2_HF5_OFFS              18
#define ARINC429R_STATUS2_HF5                   ((uint32_t)0x00040000)

#define ARINC429R_STATUS2_HF6_OFFS              19
#define ARINC429R_STATUS2_HF6                   ((uint32_t)0x00080000)

#define ARINC429R_STATUS2_HF7_OFFS              20
#define ARINC429R_STATUS2_HF7                   ((uint32_t)0x00100000)

#define ARINC429R_STATUS2_HF8_OFFS              21
#define ARINC429R_STATUS2_HF8                   ((uint32_t)0x00200000)


/** @} */ /* End of group Periph_ARINC429R_ARINC429R_STATUS2_Bits */

/** @} */ /* End of group Periph_ARINC429R_Defines */

/** @} */ /* End of group Periph_ARINC429R */

/** @} */ /* End of group __OPORA_Peripheral_Units */

/** @} */ /* End of group __CMSIS */

#endif /* __OPORA_ARINC429R_DEFS_H */

/******************* (C) COPYRIGHT 2010 Phyton *********************************
*
* END OF FILE opora_arinc429r_defs.h */
