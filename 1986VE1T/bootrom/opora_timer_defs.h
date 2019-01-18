/**
  ******************************************************************************
  * @file    opora_timer_defs.h
  * @author  Phyton Application Team
  * @version V1.0.0
  * @date
  * @brief   This file contains all the Special Function Registers definitions
  *          for the TIMER peripheral unit used in the Milandr OPORA
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
  * FILE opora_timer_defs.h
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __OPORA_TIMER_DEFS_H
#define __OPORA_TIMER_DEFS_H

/** @addtogroup __CMSIS CMSIS
  * @{
  */

/** @addtogroup __OPORA_Peripheral_Units OPORA Peripheral Units
  * @{
  */

/** @defgroup Periph_TIMER TIMER
  * @{
  */

/** @defgroup Periph_TIMER_Data_Structures Data Structures
  * @{
  */

/** @defgroup Periph_TIMER_TypeDef TIMER_TypeDef
  * @{
  */

typedef struct {
  __IO uint32_t CNT;
  __IO uint32_t PSG;
  __IO uint32_t ARR;
  __IO uint32_t CNTRL;
  __IO uint32_t CCR1;
  __IO uint32_t CCR2;
  __IO uint32_t CCR3;
  __IO uint32_t CCR4;
  __IO uint32_t CH1_CNTRL;
  __IO uint32_t CH2_CNTRL;
  __IO uint32_t CH3_CNTRL;
  __IO uint32_t CH4_CNTRL;
  __IO uint32_t CH1_CNTRL1;
  __IO uint32_t CH2_CNTRL1;
  __IO uint32_t CH3_CNTRL1;
  __IO uint32_t CH4_CNTRL1;
  __IO uint32_t CH1_DTG;
  __IO uint32_t CH2_DTG;
  __IO uint32_t CH3_DTG;
  __IO uint32_t CH4_DTG;
  __IO uint32_t BRKETR_CNTRL;
  __IO uint32_t STATUS;
  __IO uint32_t IE;
  __IO uint32_t DMA_RE;
  __IO uint32_t CH1_CNTRL2;
  __IO uint32_t CH2_CNTRL2;
  __IO uint32_t CH3_CNTRL2;
  __IO uint32_t CH4_CNTRL2;
  __IO uint32_t CCR11;
  __IO uint32_t CCR21;
  __IO uint32_t CCR31;
  __IO uint32_t CCR41;
} TIMER_TypeDef;

/** @} */ /* End of group Periph_TIMER_TypeDef */

/** @} */ /* End of group Periph_TIMER_Data_Structures */

/** @defgroup Periph_TIMER_Defines Defines
  * @{
  */

/** @defgroup Periph_TIMER_TIMER_CNTRL_Bits TIMER_CNTRL
  * @{
  */

#define TIMER_CNTRL_CNT_EN_OFFS                 0
#define TIMER_CNTRL_CNT_EN                      ((uint32_t)0x00000001)

#define TIMER_CNTRL_ARRB_EN_OFFS                1
#define TIMER_CNTRL_ARRB_EN                     ((uint32_t)0x00000002)

#define TIMER_CNTRL_WR_CMPL_OFFS                2
#define TIMER_CNTRL_WR_CMPL                     ((uint32_t)0x00000004)

#define TIMER_CNTRL_DIR_OFFS                    3
#define TIMER_CNTRL_DIR                         ((uint32_t)0x00000008)

#define TIMER_CNTRL_FDTS_OFFS                   4
#define TIMER_CNTRL_FDTS_MASK                   ((uint32_t)0x00000030)

#define TIMER_CNTRL_CNT_MODE_OFFS               6
#define TIMER_CNTRL_CNT_MODE_MASK               ((uint32_t)0x000000C0)

#define TIMER_CNTRL_EVENT_SEL_OFFS              8
#define TIMER_CNTRL_EVENT_SEL_MASK              ((uint32_t)0x00000F00)


/** @} */ /* End of group Periph_TIMER_TIMER_CNTRL_Bits */

/** @} */ /* End of group Periph_TIMER_Defines */

/** @defgroup Periph_TIMER_Defines Defines
  * @{
  */

/** @defgroup Periph_TIMER_TIMER_CH_CNTRL_Bits TIMER_CH_CNTRL
  * @{
  */

#define TIMER_CH_CNTRL_CHFLTR_OFFS              0
#define TIMER_CH_CNTRL_CHFLTR_MASK              ((uint32_t)0x0000000F)

#define TIMER_CH_CNTRL_CHSEL_OFFS               4
#define TIMER_CH_CNTRL_CHSEL_MASK               ((uint32_t)0x00000030)

#define TIMER_CH_CNTRL_CHPSC_OFFS               6
#define TIMER_CH_CNTRL_CHPSC_MASK               ((uint32_t)0x000000C0)

#define TIMER_CH_CNTRL_OCCE_OFFS                8
#define TIMER_CH_CNTRL_OCCE                     ((uint32_t)0x00000100)

#define TIMER_CH_CNTRL_OCCM_OFFS                9
#define TIMER_CH_CNTRL_OCCM_MASK                ((uint32_t)0x00000E00)

#define TIMER_CH_CNTRL_BRKEN_OFFS               12
#define TIMER_CH_CNTRL_BRKEN                    ((uint32_t)0x00001000)

#define TIMER_CH_CNTRL_ETREN_OFFS               13
#define TIMER_CH_CNTRL_ETREN                    ((uint32_t)0x00002000)

#define TIMER_CH_CNTRL_WR_CMPL_OFFS             14
#define TIMER_CH_CNTRL_WR_CMPL                  ((uint32_t)0x00004000)

#define TIMER_CH_CNTRL_CAP_nPWM_OFFS            15
#define TIMER_CH_CNTRL_CAP_nPWM                 ((uint32_t)0x00008000)


/** @} */ /* End of group Periph_TIMER_TIMER_CH_CNTRL_Bits */

/** @} */ /* End of group Periph_TIMER_Defines */

/** @defgroup Periph_TIMER_Defines Defines
  * @{
  */

/** @defgroup Periph_TIMER_TIMER_CH_CNTRL1_Bits TIMER_CH_CNTRL1
  * @{
  */

#define TIMER_CH_CNTRL1_SELOE_OFFS              0
#define TIMER_CH_CNTRL1_SELOE_MASK              ((uint32_t)0x00000003)

#define TIMER_CH_CNTRL1_SELO_OFFS               2
#define TIMER_CH_CNTRL1_SELO_MASK               ((uint32_t)0x0000000C)

#define TIMER_CH_CNTRL1_INV_OFFS                4
#define TIMER_CH_CNTRL1_INV                     ((uint32_t)0x00000010)

#define TIMER_CH_CNTRL1_NSELOE_OFFS             8
#define TIMER_CH_CNTRL1_NSELOE_MASK             ((uint32_t)0x00000300)

#define TIMER_CH_CNTRL1_NSELO_OFFS              10
#define TIMER_CH_CNTRL1_NSELO_MASK              ((uint32_t)0x00000C00)

#define TIMER_CH_CNTRL1_NINV_OFFS               12
#define TIMER_CH_CNTRL1_NINV                    ((uint32_t)0x00001000)


/** @} */ /* End of group Periph_TIMER_TIMER_CH_CNTRL1_Bits */

/** @} */ /* End of group Periph_TIMER_Defines */

/** @defgroup Periph_TIMER_Defines Defines
  * @{
  */

/** @defgroup Periph_TIMER_TIMER_CH_DTG_Bits TIMER_CH_DTG
  * @{
  */

#define TIMER_CH_DTG_DTGx_OFFS                  0
#define TIMER_CH_DTG_DTGx_MASK                  ((uint32_t)0x0000000F)

#define TIMER_CH_DTG_EDTS_OFFS                  4
#define TIMER_CH_DTG_EDTS                       ((uint32_t)0x00000010)

#define TIMER_CH_DTG_OFFS                       8
#define TIMER_CH_DTG_MASK                       ((uint32_t)0x0000FF00)


/** @} */ /* End of group Periph_TIMER_TIMER_CH_DTG_Bits */

/** @} */ /* End of group Periph_TIMER_Defines */

/** @defgroup Periph_TIMER_Defines Defines
  * @{
  */

/** @defgroup Periph_TIMER_TIMER_BRKETR_CNTRL_Bits TIMER_BRKETR_CNTRL
  * @{
  */

#define TIMER_BRKETR_CNTRL_BRK_INV_OFFS         0
#define TIMER_BRKETR_CNTRL_BRK_INV              ((uint32_t)0x00000001)

#define TIMER_BRKETR_CNTRL_ETR_INV_OFFS         1
#define TIMER_BRKETR_CNTRL_ETR_INV              ((uint32_t)0x00000002)

#define TIMER_BRKETR_CNTRL_ETR_PSC_OFFS         2
#define TIMER_BRKETR_CNTRL_ETR_PSC_MASK         ((uint32_t)0x0000000C)

#define TIMER_BRKETR_CNTRL_ETR_FILTER_OFFS      4
#define TIMER_BRKETR_CNTRL_ETR_FILTER_MASK      ((uint32_t)0x000000F0)


/** @} */ /* End of group Periph_TIMER_TIMER_BRKETR_CNTRL_Bits */

/** @} */ /* End of group Periph_TIMER_Defines */

/** @defgroup Periph_TIMER_Defines Defines
  * @{
  */

/** @defgroup Periph_TIMER_TIMER_STATUS_Bits TIMER_STATUS
  * @{
  */

#define TIMER_STATUS_CNT_ZERO_EVENT_OFFS        0
#define TIMER_STATUS_CNT_ZERO_EVENT             ((uint32_t)0x00000001)

#define TIMER_STATUS_CNT_ARR_EVENT_OFFS         1
#define TIMER_STATUS_CNT_ARR_EVENT              ((uint32_t)0x00000002)

#define TIMER_STATUS_ETR_RE_EVENT_OFFS          2
#define TIMER_STATUS_ETR_RE_EVENT               ((uint32_t)0x00000004)

#define TIMER_STATUS_ETR_FE_EVENT_OFFS          3
#define TIMER_STATUS_ETR_FE_EVENT               ((uint32_t)0x00000008)

#define TIMER_STATUS_BRK_EVENT_OFFS             4
#define TIMER_STATUS_BRK_EVENT                  ((uint32_t)0x00000010)

#define TIMER_STATUS_CCR_CAP_EVENT_OFFS         5
#define TIMER_STATUS_CCR_CAP_EVENT_MASK         ((uint32_t)0x000001E0)

#define TIMER_STATUS_CCR_REF_EVENT_OFFS         9
#define TIMER_STATUS_CCR_REF_EVENT_MASK         ((uint32_t)0x00001E00)

#define TIMER_STATUS_CCR1_CAP_EVENT_OFFS        13
#define TIMER_STATUS_CCR1_CAP_EVENT_MASK        ((uint32_t)0x0001E000)


/** @} */ /* End of group Periph_TIMER_TIMER_STATUS_Bits */

/** @} */ /* End of group Periph_TIMER_Defines */

/** @defgroup Periph_TIMER_Defines Defines
  * @{
  */

/** @defgroup Periph_TIMER_TIMER_IE_Bits TIMER_IE
  * @{
  */

#define TIMER_IE_CNT_ZERO_EVENT_IE_OFFS         0
#define TIMER_IE_CNT_ZERO_EVENT_IE              ((uint32_t)0x00000001)

#define TIMER_IE_CNT_ARR_EVENT_IE_OFFS          1
#define TIMER_IE_CNT_ARR_EVENT_IE               ((uint32_t)0x00000002)

#define TIMER_IE_ETR_RE_EVENT_IE_OFFS           2
#define TIMER_IE_ETR_RE_EVENT_IE                ((uint32_t)0x00000004)

#define TIMER_IE_ETR_FE_EVENT_IE_OFFS           3
#define TIMER_IE_ETR_FE_EVENT_IE                ((uint32_t)0x00000008)

#define TIMER_IE_BRK_EVENT_IE_OFFS              4
#define TIMER_IE_BRK_EVENT_IE                   ((uint32_t)0x00000010)

#define TIMER_IE_CCR_CAP_EVENT_IE_OFFS          5
#define TIMER_IE_CCR_CAP_EVENT_IE_MASK          ((uint32_t)0x000001E0)

#define TIMER_IE_CCR_REF_EVENT_IE_OFFS          9
#define TIMER_IE_CCR_REF_EVENT_IE_MASK          ((uint32_t)0x00001E00)


/** @} */ /* End of group Periph_TIMER_TIMER_IE_Bits */

/** @} */ /* End of group Periph_TIMER_Defines */

/** @defgroup Periph_TIMER_Defines Defines
  * @{
  */

/** @defgroup Periph_TIMER_TIMER_DMA_RE_Bits TIMER_DMA_RE
  * @{
  */

#define TIMER_DMA_RE_CNT_ZERO_EVENT_RE_OFFS     0
#define TIMER_DMA_RE_CNT_ZERO_EVENT_RE          ((uint32_t)0x00000001)

#define TIMER_DMA_RE_CNT_ARR_EVENT_RE_OFFS      1
#define TIMER_DMA_RE_CNT_ARR_EVENT_RE           ((uint32_t)0x00000002)

#define TIMER_DMA_RE_ETR_RE_EVENT_RE_OFFS       2
#define TIMER_DMA_RE_ETR_RE_EVENT_RE            ((uint32_t)0x00000004)

#define TIMER_DMA_RE_ETR_FE_EVENT_RE_OFFS       3
#define TIMER_DMA_RE_ETR_FE_EVENT_RE            ((uint32_t)0x00000008)

#define TIMER_DMA_RE_BRK_EVENT_RE_OFFS          4
#define TIMER_DMA_RE_BRK_EVENT_RE               ((uint32_t)0x00000010)

#define TIMER_DMA_RE_CCR_CAP_EVENT_RE_OFFS      5
#define TIMER_DMA_RE_CCR_CAP_EVENT_RE_MASK      ((uint32_t)0x000001E0)

#define TIMER_DMA_RE_CCR_REF_EVENT_RE_OFFS      9
#define TIMER_DMA_RE_CCR_REF_EVENT_RE_MASK      ((uint32_t)0x00001E00)


/** @} */ /* End of group Periph_TIMER_TIMER_DMA_RE_Bits */

/** @} */ /* End of group Periph_TIMER_Defines */

/** @defgroup Periph_TIMER_Defines Defines
  * @{
  */

/** @defgroup Periph_TIMER_TIMER_CH_CNTRL2_Bits TIMER_CH_CNTRL2
  * @{
  */

#define TIMER_CH_CNTRL2_CHSEL1_OFFS             0
#define TIMER_CH_CNTRL2_CHSEL1_MASK             ((uint32_t)0x00000003)

#define TIMER_CH_CNTRL2_CCR1_EN_OFFS            2
#define TIMER_CH_CNTRL2_CCR1_EN                 ((uint32_t)0x00000004)

#define TIMER_CH_CNTRL2_CCRRLD_OFFS             3
#define TIMER_CH_CNTRL2_CCRRLD                  ((uint32_t)0x00000008)


/** @} */ /* End of group Periph_TIMER_TIMER_CH_CNTRL2_Bits */

/** @} */ /* End of group Periph_TIMER_Defines */

/** @} */ /* End of group Periph_TIMER */

/** @} */ /* End of group __OPORA_Peripheral_Units */

/** @} */ /* End of group __CMSIS */

#endif /* __OPORA_TIMER_DEFS_H */

/******************* (C) COPYRIGHT 2010 Phyton *********************************
*
* END OF FILE opora_timer_defs.h */
