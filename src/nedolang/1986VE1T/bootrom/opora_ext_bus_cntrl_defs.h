/**
  ******************************************************************************
  * @file    opora_ext_bus_cntrl_defs.h
  * @author  Phyton Application Team
  * @version V1.0.0
  * @date
  * @brief   This file contains all the Special Function Registers definitions
  *          for the EXT_BUS_CNTRL peripheral unit used in the Milandr OPORA
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
  * FILE opora_ext_bus_cntrl_defs.h
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __OPORA_EXT_BUS_CNTRL_DEFS_H
#define __OPORA_EXT_BUS_CNTRL_DEFS_H

/** @addtogroup __CMSIS CMSIS
  * @{
  */

/** @addtogroup __OPORA_Peripheral_Units OPORA Peripheral Units
  * @{
  */

/** @defgroup Periph_EXT_BUS_CNTRL EXT_BUS_CNTRL
  * @{
  */

/** @defgroup Periph_EXT_BUS_CNTRL_Data_Structures Data Structures
  * @{
  */

/** @defgroup Periph_EXT_BUS_CNTRL_TypeDef EXT_BUS_CNTRL_TypeDef
  * @{
  */

typedef struct {
       uint32_t RESERVED0[20];
  __IO uint32_t NAND_CYCLES;
  __IO uint32_t EXT_BUS_CONTROL;
  __IO uint32_t RAM_CYCLES1;
  __IO uint32_t RAM_CYCLES2;
  __IO uint32_t RAM_CYCLES3;
  __IO uint32_t RAM_CYCLES4;	
} EXT_BUS_CNTRL_TypeDef;

/** @} */ /* End of group Periph_EXT_BUS_CNTRL_TypeDef */

/** @} */ /* End of group Periph_EXT_BUS_CNTRL_Data_Structures */

/** @defgroup Periph_EXT_BUS_CNTRL_Defines Defines
  * @{
  */

/** @defgroup Periph_EXT_BUS_CNTRL_EXT_BUS_CNTRL_NAND_CYCLES_Bits EXT_BUS_CNTRL_NAND_CYCLES
  * @{
  */

#define EXT_BUS_CNTRL_NAND_CYCLES_t_rc_OFFS     0
#define EXT_BUS_CNTRL_NAND_CYCLES_t_rc_MASK     ((uint32_t)0x0000000F)

#define EXT_BUS_CNTRL_NAND_CYCLES_t_wc_OFFS     4
#define EXT_BUS_CNTRL_NAND_CYCLES_t_wc_MASK     ((uint32_t)0x000000F0)

#define EXT_BUS_CNTRL_NAND_CYCLES_t_rea_OFFS    8
#define EXT_BUS_CNTRL_NAND_CYCLES_t_rea_MASK    ((uint32_t)0x00000F00)

#define EXT_BUS_CNTRL_NAND_CYCLES_t_wp_OFFS     12
#define EXT_BUS_CNTRL_NAND_CYCLES_t_wp_MASK     ((uint32_t)0x0000F000)

#define EXT_BUS_CNTRL_NAND_CYCLES_t_whr_OFFS    16
#define EXT_BUS_CNTRL_NAND_CYCLES_t_whr_MASK    ((uint32_t)0x000F0000)

#define EXT_BUS_CNTRL_NAND_CYCLES_t_alea_OFFS   20
#define EXT_BUS_CNTRL_NAND_CYCLES_t_alea_MASK   ((uint32_t)0x00F00000)

#define EXT_BUS_CNTRL_NAND_CYCLES_t_rr_OFFS     24
#define EXT_BUS_CNTRL_NAND_CYCLES_t_rr_MASK     ((uint32_t)0x0F000000)


/** @} */ /* End of group Periph_EXT_BUS_CNTRL_EXT_BUS_CNTRL_NAND_CYCLES_Bits */

/** @} */ /* End of group Periph_EXT_BUS_CNTRL_Defines */

/** @defgroup Periph_EXT_BUS_CNTRL_Defines Defines
  * @{
  */

/** @defgroup Periph_EXT_BUS_CNTRL_EXT_BUS_CNTRL_EXT_BUS_CONTROL_Bits EXT_BUS_CNTRL_EXT_BUS_CONTROL
  * @{
  */

#define EXT_BUS_CNTRL_EXT_BUS_CONTROL_ROM_OFFS  0
#define EXT_BUS_CNTRL_EXT_BUS_CONTROL_ROM       ((uint32_t)0x00000001)

#define EXT_BUS_CNTRL_EXT_BUS_CONTROL_RAM_OFFS  1
#define EXT_BUS_CNTRL_EXT_BUS_CONTROL_RAM       ((uint32_t)0x00000002)

#define EXT_BUS_CNTRL_EXT_BUS_CONTROL_NAND_OFFS 2
#define EXT_BUS_CNTRL_EXT_BUS_CONTROL_NAND      ((uint32_t)0x00000004)

#define EXT_BUS_CNTRL_EXT_BUS_CONTROL_CPOL_OFFS 3
#define EXT_BUS_CNTRL_EXT_BUS_CONTROL_CPOL      ((uint32_t)0x00000008)

#define EXT_BUS_CNTRL_EXT_BUS_CONTROL_BUSY_OFFS 7
#define EXT_BUS_CNTRL_EXT_BUS_CONTROL_BUSY      ((uint32_t)0x00000080)

#define EXT_BUS_CNTRL_EXT_BUS_CONTROL_WAIT_STATE_OFFS 12
#define EXT_BUS_CNTRL_EXT_BUS_CONTROL_WAIT_STATE_MASK ((uint32_t)0x0000F000)


/** @} */ /* End of group Periph_EXT_BUS_CNTRL_EXT_BUS_CNTRL_EXT_BUS_CONTROL_Bits */

/** @} */ /* End of group Periph_EXT_BUS_CNTRL_Defines */

/** @} */ /* End of group Periph_EXT_BUS_CNTRL */

/** @} */ /* End of group __OPORA_Peripheral_Units */

/** @} */ /* End of group __CMSIS */

#endif /* __OPORA_EXT_BUS_CNTRL_DEFS_H */

/******************* (C) COPYRIGHT 2010 Phyton *********************************
*
* END OF FILE opora_ext_bus_cntrl_defs.h */
