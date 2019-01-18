/**
  ******************************************************************************
  * @file    opora_rst_clk_defs.h
  * @author  Phyton Application Team
  * @version V1.0.0
  * @date
  * @brief   This file contains all the Special Function Registers definitions
  *          for the RST_CLK peripheral unit used in the Milandr OPORA
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
  * FILE opora_rst_clk_defs.h
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __OPORA_RST_CLK_DEFS_H
#define __OPORA_RST_CLK_DEFS_H

/** @addtogroup __CMSIS CMSIS
  * @{
  */

/** @addtogroup __OPORA_Peripheral_Units OPORA Peripheral Units
  * @{
  */

/** @defgroup Periph_RST_CLK RST_CLK
  * @{
  */

/** @defgroup Periph_RST_CLK_Data_Structures Data Structures
  * @{
  */

/** @defgroup Periph_RST_CLK_TypeDef RST_CLK_TypeDef
  * @{
  */

typedef struct {
  __IO uint32_t CLOCK_STATUS;
  __IO uint32_t PLL_CONTROL;
  __IO uint32_t HS_CONTROL;
  __IO uint32_t CPU_CLOCK;
  __IO uint32_t USB_CLOCK;
  __IO uint32_t ADC_MCO_CLOCK;
  __IO uint32_t RTC_CLOCK;
  __IO uint32_t PER_CLOCK;
  __IO uint32_t CAN_CLOCK;
  __IO uint32_t TIM_CLOCK;
  __IO uint32_t UART_CLOCK;
  __IO uint32_t SSP_CLOCK;
       uint32_t RESERVED;
  __IO uint32_t ETH_CLOCK;
} RST_CLK_TypeDef;

/** @} */ /* End of group Periph_RST_CLK_TypeDef */

/** @} */ /* End of group Periph_RST_CLK_Data_Structures */

/** @defgroup Periph_RST_CLK_Defines Defines
  * @{
  */

/** @defgroup Periph_RST_CLK_RST_CLK_CLOCK_STATUS_Bits RST_CLK_CLOCK_STATUS
  * @{
  */

#define RST_CLK_CLOCK_STATUS_PLL_USB_RDY_OFFS   0
#define RST_CLK_CLOCK_STATUS_PLL_USB_RDY        ((uint32_t)0x00000001)

#define RST_CLK_CLOCK_STATUS_PLL_CPU_RDY_OFFS   1
#define RST_CLK_CLOCK_STATUS_PLL_CPU_RDY        ((uint32_t)0x00000002)

#define RST_CLK_CLOCK_STATUS_HSE_RDY_OFFS       2
#define RST_CLK_CLOCK_STATUS_HSE_RDY            ((uint32_t)0x00000004)


/** @} */ /* End of group Periph_RST_CLK_RST_CLK_CLOCK_STATUS_Bits */

/** @} */ /* End of group Periph_RST_CLK_Defines */

/** @defgroup Periph_RST_CLK_Defines Defines
  * @{
  */

/** @defgroup Periph_RST_CLK_RST_CLK_PLL_CONTROL_Bits RST_CLK_PLL_CONTROL
  * @{
  */

#define RST_CLK_PLL_CONTROL_PLL_USB_ON_OFFS     0
#define RST_CLK_PLL_CONTROL_PLL_USB_ON          ((uint32_t)0x00000001)

#define RST_CLK_PLL_CONTROL_PLL_USB_RLD_OFFS    1
#define RST_CLK_PLL_CONTROL_PLL_USB_RLD         ((uint32_t)0x00000002)

#define RST_CLK_PLL_CONTROL_PLL_CPU_ON_OFFS     2
#define RST_CLK_PLL_CONTROL_PLL_CPU_ON          ((uint32_t)0x00000004)

#define RST_CLK_PLL_CONTROL_PLL_CPU_PLD_OFFS    3
#define RST_CLK_PLL_CONTROL_PLL_CPU_PLD         ((uint32_t)0x00000008)

#define RST_CLK_PLL_CONTROL_PLL_USB_MUL_OFFS    4
#define RST_CLK_PLL_CONTROL_PLL_USB_MUL_MASK    ((uint32_t)0x000000F0)

#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_OFFS    8
#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_MASK    ((uint32_t)0x00000F00)

#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_2		((uint32_t)0x00000100)
#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_3		((uint32_t)0x00000200)
#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_4		((uint32_t)0x00000300)
#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_5		((uint32_t)0x00000400)
#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_6		((uint32_t)0x00000500)
#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_7		((uint32_t)0x00000600)
#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_8		((uint32_t)0x00000700)
#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_9		((uint32_t)0x00000800)
#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_10		((uint32_t)0x00000900)
#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_11		((uint32_t)0x00000A00)
#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_12		((uint32_t)0x00000B00)
#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_13		((uint32_t)0x00000C00)
#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_14		((uint32_t)0x00000D00)
#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_15		((uint32_t)0x00000E00)
#define RST_CLK_PLL_CONTROL_PLL_CPU_MUL_16		((uint32_t)0x00000F00)

/** @} */ /* End of group Periph_RST_CLK_RST_CLK_PLL_CONTROL_Bits */

/** @} */ /* End of group Periph_RST_CLK_Defines */

/** @defgroup Periph_RST_CLK_Defines Defines
  * @{
  */

/** @defgroup Periph_RST_CLK_RST_CLK_HS_CONTROL_Bits RST_CLK_HS_CONTROL
  * @{
  */

#define RST_CLK_HS_CONTROL_HSE_ON_OFFS          0
#define RST_CLK_HS_CONTROL_HSE_ON               ((uint32_t)0x00000001)

#define RST_CLK_HS_CONTROL_HSE_BYP_OFFS         1
#define RST_CLK_HS_CONTROL_HSE_BYP              ((uint32_t)0x00000002)


/** @} */ /* End of group Periph_RST_CLK_RST_CLK_HS_CONTROL_Bits */

/** @} */ /* End of group Periph_RST_CLK_Defines */

/** @defgroup Periph_RST_CLK_Defines Defines
  * @{
  */

/** @defgroup Periph_RST_CLK_RST_CLK_CPU_CLOCK_Bits RST_CLK_CPU_CLOCK
  * @{
  */

#define RST_CLK_CPU_CLOCK_CPU_C1_SEL_OFFS       0
#define RST_CLK_CPU_CLOCK_CPU_C1_SEL_MASK       ((uint32_t)0x00000003)

#define RST_CLK_CPU_CLOCK_CPU_C2_SEL_OFFS       2
#define RST_CLK_CPU_CLOCK_CPU_C2_SEL            ((uint32_t)0x00000004)

#define RST_CLK_CPU_CLOCK_CPU_C3_SEL_OFFS       4
#define RST_CLK_CPU_CLOCK_CPU_C3_SEL_MASK       ((uint32_t)0x000000F0)

#define RST_CLK_CPU_CLOCK_HCLK_SEL_OFFS         8
#define RST_CLK_CPU_CLOCK_HCLK_SEL_MASK         ((uint32_t)0x00000300)


/** @} */ /* End of group Periph_RST_CLK_RST_CLK_CPU_CLOCK_Bits */

/** @} */ /* End of group Periph_RST_CLK_Defines */

/** @defgroup Periph_RST_CLK_Defines Defines
  * @{
  */

/** @defgroup Periph_RST_CLK_RST_CLK_USB_CLOCK_Bits RST_CLK_USB_CLOCK
  * @{
  */

#define RST_CLK_USB_CLOCK_USB_C1_SEL_OFFS       0
#define RST_CLK_USB_CLOCK_USB_C1_SEL_MASK       ((uint32_t)0x00000003)

#define RST_CLK_USB_CLOCK_USB_C2_SEL_OFFS       2
#define RST_CLK_USB_CLOCK_USB_C2_SEL            ((uint32_t)0x00000004)

#define RST_CLK_USB_CLOCK_CPU_C3_SEL_OFFS       4
#define RST_CLK_USB_CLOCK_CPU_C3_SEL_MASK       ((uint32_t)0x000000F0)

#define RST_CLK_USB_CLOCK_USB_CL_KEN_OFFS       8
#define RST_CLK_USB_CLOCK_USB_CL_KEN            ((uint32_t)0x00000100)


/** @} */ /* End of group Periph_RST_CLK_RST_CLK_USB_CLOCK_Bits */

/** @} */ /* End of group Periph_RST_CLK_Defines */

/** @defgroup Periph_RST_CLK_Defines Defines
  * @{
  */

/** @defgroup Periph_RST_CLK_RST_CLK_ADC_MCO_CLOCK_Bits RST_CLK_ADC_MCO_CLOCK
  * @{
  */

#define RST_CLK_ADC_MCO_CLOCK_ADC_C1_SEL_OFFS   0
#define RST_CLK_ADC_MCO_CLOCK_ADC_C1_SEL_MASK   ((uint32_t)0x00000003)

#define RST_CLK_ADC_MCO_CLOCK_ADC_C2_SEL_OFFS   4
#define RST_CLK_ADC_MCO_CLOCK_ADC_C2_SEL_MASK   ((uint32_t)0x00000030)

#define RST_CLK_ADC_MCO_CLOCK_ADC_C3_SEL_OFFS   8
#define RST_CLK_ADC_MCO_CLOCK_ADC_C3_SEL_MASK   ((uint32_t)0x00000F00)

#define RST_CLK_ADC_MCO_CLOCK_MCO_EN_OFFS       12
#define RST_CLK_ADC_MCO_CLOCK_MCO_EN            ((uint32_t)0x00001000)

#define RST_CLK_ADC_MCO_CLOCK_ADC_CLK_EN_OFFS   13
#define RST_CLK_ADC_MCO_CLOCK_ADC_CLK_EN        ((uint32_t)0x00002000)


/** @} */ /* End of group Periph_RST_CLK_RST_CLK_ADC_MCO_CLOCK_Bits */

/** @} */ /* End of group Periph_RST_CLK_Defines */

/** @defgroup Periph_RST_CLK_Defines Defines
  * @{
  */

/** @defgroup Periph_RST_CLK_RST_CLK_RTC_CLOCK_Bits RST_CLK_RTC_CLOCK
  * @{
  */

#define RST_CLK_RTC_CLOCK_HSE_SEL_OFFS          0
#define RST_CLK_RTC_CLOCK_HSE_SEL_MASK          ((uint32_t)0x0000000F)

#define RST_CLK_RTC_CLOCK_HSI_SEL_OFFS          4
#define RST_CLK_RTC_CLOCK_HSI_SEL_MASK          ((uint32_t)0x000000F0)

#define RST_CLK_RTC_CLOCK_HSE_RTC_EN_OFFS       8
#define RST_CLK_RTC_CLOCK_HSE_RTC_EN            ((uint32_t)0x00000100)

#define RST_CLK_RTC_CLOCK_HSI_RTC_EN_OFFS       9
#define RST_CLK_RTC_CLOCK_HSI_RTC_EN            ((uint32_t)0x00000200)


/** @} */ /* End of group Periph_RST_CLK_RST_CLK_RTC_CLOCK_Bits */

/** @} */ /* End of group Periph_RST_CLK_Defines */

/** @defgroup Periph_RST_CLK_Defines Defines
  * @{
  */

/** @defgroup Periph_RST_CLK_RST_CLK_CAN_CLOCK_Bits RST_CLK_CAN_CLOCK
  * @{
  */

#define RST_CLK_CAN_CLOCK_CAN1_BRG_OFFS         0
#define RST_CLK_CAN_CLOCK_CAN1_BRG_MASK         ((uint32_t)0x000000FF)

#define RST_CLK_CAN_CLOCK_CAN2_BRG_OFFS         8
#define RST_CLK_CAN_CLOCK_CAN2_BRG_MASK         ((uint32_t)0x0000FF00)

#define RST_CLK_CAN_CLOCK_CAN1_CLK_EN_OFFS      24
#define RST_CLK_CAN_CLOCK_CAN1_CLK_EN           ((uint32_t)0x01000000)

#define RST_CLK_CAN_CLOCK_CAN2_CLK_EN_OFFS      25
#define RST_CLK_CAN_CLOCK_CAN2_CLK_EN           ((uint32_t)0x02000000)


/** @} */ /* End of group Periph_RST_CLK_RST_CLK_CAN_CLOCK_Bits */

/** @} */ /* End of group Periph_RST_CLK_Defines */

/** @defgroup Periph_RST_CLK_Defines Defines
  * @{
  */

/** @defgroup Periph_RST_CLK_RST_CLK_TIM_CLOCK_Bits RST_CLK_TIM_CLOCK
  * @{
  */

#define RST_CLK_TIM_CLOCK_TIM1_BRG_OFFS         0
#define RST_CLK_TIM_CLOCK_TIM1_BRG_MASK         ((uint32_t)0x000000FF)

#define RST_CLK_TIM_CLOCK_TIM2_BRG_OFFS         8
#define RST_CLK_TIM_CLOCK_TIM2_BRG_MASK         ((uint32_t)0x0000FF00)

#define RST_CLK_TIM_CLOCK_TIM3_BRG_OFFS         16
#define RST_CLK_TIM_CLOCK_TIM3_BRG_MASK         ((uint32_t)0x00FF0000)

#define RST_CLK_TIM_CLOCK_TIM1_CLK_EN_OFFS      24
#define RST_CLK_TIM_CLOCK_TIM1_CLK_EN           ((uint32_t)0x01000000)

#define RST_CLK_TIM_CLOCK_TIM2_CLK_EN_OFFS      25
#define RST_CLK_TIM_CLOCK_TIM2_CLK_EN           ((uint32_t)0x02000000)

#define RST_CLK_TIM_CLOCK_TIM3_CLK_EN_OFFS      26
#define RST_CLK_TIM_CLOCK_TIM3_CLK_EN           ((uint32_t)0x04000000)


/** @} */ /* End of group Periph_RST_CLK_RST_CLK_TIM_CLOCK_Bits */

/** @} */ /* End of group Periph_RST_CLK_Defines */

/** @defgroup Periph_RST_CLK_Defines Defines
  * @{
  */

/** @defgroup Periph_RST_CLK_RST_CLK_UART_CLOCK_Bits RST_CLK_UART_CLOCK
  * @{
  */

#define RST_CLK_UART_CLOCK_UART1_BRG_OFFS       0
#define RST_CLK_UART_CLOCK_UART1_BRG_MASK       ((uint32_t)0x000000FF)

#define RST_CLK_UART_CLOCK_UART2_BRG_OFFS       8
#define RST_CLK_UART_CLOCK_UART2_BRG_MASK       ((uint32_t)0x0000FF00)

#define RST_CLK_UART_CLOCK_UART1_CLK_EN_OFFS    24
#define RST_CLK_UART_CLOCK_UART1_CLK_EN         ((uint32_t)0x01000000)

#define RST_CLK_UART_CLOCK_UART2_CLK_EN_OFFS    25
#define RST_CLK_UART_CLOCK_UART2_CLK_EN         ((uint32_t)0x02000000)


/** @} */ /* End of group Periph_RST_CLK_RST_CLK_UART_CLOCK_Bits */

/** @} */ /* End of group Periph_RST_CLK_Defines */

/** @defgroup Periph_RST_CLK_Defines Defines
  * @{
  */

/** @defgroup Periph_RST_CLK_RST_CLK_SSP_CLOCK_Bits RST_CLK_SSP_CLOCK
  * @{
  */

#define RST_CLK_SSP_CLOCK_SSP1_BRG_OFFS         0
#define RST_CLK_SSP_CLOCK_SSP1_BRG_MASK         ((uint32_t)0x000000FF)

#define RST_CLK_SSP_CLOCK_SSP2_BRG_OFFS         8
#define RST_CLK_SSP_CLOCK_SSP2_BRG_MASK         ((uint32_t)0x0000FF00)

#define RST_CLK_SSP_CLOCK_SSP1_CLK_EN_OFFS      24
#define RST_CLK_SSP_CLOCK_SSP1_CLK_EN           ((uint32_t)0x01000000)

#define RST_CLK_SSP_CLOCK_SSP2_CLK_EN_OFFS      25
#define RST_CLK_SSP_CLOCK_SSP2_CLK_EN           ((uint32_t)0x02000000)


/** @} */ /* End of group Periph_RST_CLK_RST_CLK_SSP_CLOCK_Bits */

/** @} */ /* End of group Periph_RST_CLK_Defines */

/** @} */ /* End of group Periph_RST_CLK */

/** @} */ /* End of group __OPORA_Peripheral_Units */

/** @} */ /* End of group __CMSIS */

#endif /* __OPORA_RST_CLK_DEFS_H */

/******************* (C) COPYRIGHT 2010 Phyton *********************************
*
* END OF FILE opora_rst_clk_defs.h */
