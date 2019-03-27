/**
  ******************************************************************************
  * @file    opora_dma_defs.h
  * @author  Phyton Application Team
  * @version V1.0.0
  * @date
  * @brief   This file contains all the Special Function Registers definitions
  *          for the DMA peripheral unit used in the Milandr OPORA
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
  * FILE opora_dma_defs.h
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __OPORA_DMA_DEFS_H
#define __OPORA_DMA_DEFS_H

/** @addtogroup __CMSIS CMSIS
  * @{
  */

/** @addtogroup __OPORA_Peripheral_Units OPORA Peripheral Units
  * @{
  */

/** @defgroup Periph_DMA DMA
  * @{
  */

/** @defgroup Periph_DMA_Data_Structures Data Structures
  * @{
  */

/** @defgroup Periph_DMA_TypeDef DMA_TypeDef
  * @{
  */

typedef struct {
  __IO uint32_t STATUS;
  __IO uint32_t CFG;
  __IO uint32_t CTRL_BASE_PTR;
  __IO uint32_t ALT_CTRL_BASE_PTR;
  __IO uint32_t WAITONREQ_STATUS;
  __IO uint32_t CHNL_SW_REQUEST;
  __IO uint32_t CHNL_USEBURST_SET;
  __IO uint32_t CHNL_USEBURST_CLR;
  __IO uint32_t CHNL_REQ_MASK_SET;
  __IO uint32_t CHNL_REQ_MASK_CLR;
  __IO uint32_t CHNL_ENABLE_SET;
  __IO uint32_t CHNL_ENABLE_CLR;
  __IO uint32_t CHNL_PRI_ALT_SET;
  __IO uint32_t CHNL_PRI_ALT_CLR;
  __IO uint32_t CHNL_PRIORITY_SET;
  __IO uint32_t CHNL_PRIORITY_CLR;
       uint32_t RESERVED0[3];
  __IO uint32_t ERR_CLR;
} DMA_TypeDef;

/** @} */ /* End of group Periph_DMA_TypeDef */

/** @} */ /* End of group Periph_DMA_Data_Structures */

/** @defgroup Periph_DMA_Defines Defines
  * @{
  */

/** @defgroup Periph_DMA_DMA_STATUS_Bits DMA_STATUS
  * @{
  */

#define DMA_STATUS_MASTER_ENABLE_OFFS           0
#define DMA_STATUS_MASTER_ENABLE                ((uint32_t)0x00000001)

#define DMA_STATUS_STATE_OFFS                   4
#define DMA_STATUS_STATE_MASK                   ((uint32_t)0x000000F0)

#define DMA_STATUS_CHNLS_MINUS1_OFFS            16
#define DMA_STATUS_CHNLS_MINUS1_MASK            ((uint32_t)0x001F0000)

#define DMA_STATUS_TEST_STATUS_OFFS             28
#define DMA_STATUS_TEST_STATUS_MASK             ((uint32_t)0xF0000000)


/** @} */ /* End of group Periph_DMA_DMA_STATUS_Bits */

/** @} */ /* End of group Periph_DMA_Defines */

/** @defgroup Periph_DMA_Defines Defines
  * @{
  */

/** @defgroup Periph_DMA_DMA_CFG_Bits DMA_CFG
  * @{
  */

#define DMA_CFG_MASTER_ENABLE_OFFS              0
#define DMA_CFG_MASTER_ENABLE                   ((uint32_t)0x00000001)

#define DMA_CFG_CHNL_PROT_CTRL_OFFS             5
#define DMA_CFG_CHNL_PROT_CTRL_MASK             ((uint32_t)0x000000E0)


/** @} */ /* End of group Periph_DMA_DMA_CFG_Bits */

/** @} */ /* End of group Periph_DMA_Defines */

/** @} */ /* End of group Periph_DMA */

/** @} */ /* End of group __OPORA_Peripheral_Units */

/** @} */ /* End of group __CMSIS */

#endif /* __OPORA_DMA_DEFS_H */

/******************* (C) COPYRIGHT 2010 Phyton *********************************
*
* END OF FILE opora_dma_defs.h */
