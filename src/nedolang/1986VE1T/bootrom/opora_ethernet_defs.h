/**
  ******************************************************************************
  * @file    opora_ethernet_defs.h
  * @author  Phyton Application Team
  * @version V1.0.0
  * @date
  * @brief   This file contains all the Special Function Registers definitions
  *          for the ETHERNET peripheral unit used in the Milandr OPORA
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
  * FILE opora_ethernet_defs.h
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __OPORA_ETHERNET_DEFS_H
#define __OPORA_ETHERNET_DEFS_H

/** @addtogroup __CMSIS CMSIS
  * @{
  */

/** @addtogroup __OPORA_Peripheral_Units OPORA Peripheral Units
  * @{
  */

/** @defgroup Periph_ETHERNET ETHERNET
  * @{
  */

/** @defgroup Periph_ETHERNET_Data_Structures Data Structures
  * @{
  */

/** @defgroup Periph_ETHERNET_TypeDef ETHERNET_TypeDef
  * @{
  */

typedef struct {
  __IO uint16_t Delimiter;	//00 offset
  __IO uint16_t MAC_T;		//02
  __IO uint16_t MAC_M;		//04
  __IO uint16_t MAC_H;		//06
  __IO uint16_t HASH0;		//08
  __IO uint16_t HASH1;		//0A
  __IO uint16_t HASH2;		//0C
  __IO uint16_t HASH3;		//0E
  __IO uint16_t IPG;		//10
  __IO uint16_t PSC;		//12
  __IO uint16_t BAG;		//14
  __IO uint16_t JitterWnd;	//16
  __IO uint16_t R_CFG;		//18
  __IO uint16_t X_CFG;		//1A
  __IO uint32_t G_CFG;		//1C
  __IO uint16_t IMR;		//20
  __IO uint16_t IFR;		//22
  __IO uint16_t MDIO_CTRL;	//24
  __IO uint16_t MDIO_DATA;	//26
  __IO uint16_t R_Head;		//28
  __IO uint16_t X_Tail;		//2A
  __IO uint16_t R_Tail;		//2C
  __IO uint16_t X_Head;		//2E
  __IO uint16_t STAT;		//30
  __IO uint16_t RESERV;		//32
  __IO uint16_t PHY_CTRL;	//34
  __IO uint16_t PHY_STATUS;	//36
} ETHERNET_TypeDef;

/** @} */ /* End of group Periph_ETHERNET_TypeDef */

/** @} */ /* End of group Periph_ETHERNET_Data_Structures */

/** @defgroup Periph_ETHERNET_Defines Defines
  * @{
  */

/** @defgroup Periph_ETHERNET_ETHERNET_ETH_R_CFG_Bits ETHERNET_ETH_R_CFG
  * @{
  */

#define ETHERNET_ETH_R_CFG_MCA_EN_OFFS          0
#define ETHERNET_ETH_R_CFG_MCA_EN               ((uint32_t)0x00000001)

#define ETHERNET_ETH_R_CFG_BCA_EN_OFFS          1
#define ETHERNET_ETH_R_CFG_BCA_EN               ((uint32_t)0x00000002)

#define ETHERNET_ETH_R_CFG_UCA_EN_OFFS          2
#define ETHERNET_ETH_R_CFG_UCA_EN               ((uint32_t)0x00000004)

#define ETHERNET_ETH_R_CFG_AC_EN_OFFS           3
#define ETHERNET_ETH_R_CFG_AC_EN                ((uint32_t)0x00000008)

#define ETHERNET_ETH_R_CFG_EF_EN_OFFS           4
#define ETHERNET_ETH_R_CFG_EF_EN                ((uint32_t)0x00000010)

#define ETHERNET_ETH_R_CFG_CF_EN_OFFS           5
#define ETHERNET_ETH_R_CFG_CF_EN                ((uint32_t)0x00000020)

#define ETHERNET_ETH_R_CFG_LF_EN_OFFS           6
#define ETHERNET_ETH_R_CFG_LF_EN                ((uint32_t)0x00000040)

#define ETHERNET_ETH_R_CFG_SF_EN_OFFS           7
#define ETHERNET_ETH_R_CFG_SF_EN                ((uint32_t)0x00000080)

#define ETHERNET_ETH_R_CFG_EVNT_MODE_OFFS       8
#define ETHERNET_ETH_R_CFG_EVNT_MODE_MASK       ((uint32_t)0x00000700)

#define ETHERNET_ETH_R_CFG_MSB1st_OFFS          12
#define ETHERNET_ETH_R_CFG_MSB1st               ((uint32_t)0x00001000)

#define ETHERNET_ETH_R_CFG_BE_OFFS              13
#define ETHERNET_ETH_R_CFG_BE                   ((uint32_t)0x00002000)

#define ETHERNET_ETH_R_CFG_RST_OFFS             15
#define ETHERNET_ETH_R_CFG_RST                  ((uint32_t)0x00008000)


/** @} */ /* End of group Periph_ETHERNET_ETHERNET_ETH_R_CFG_Bits */

/** @} */ /* End of group Periph_ETHERNET_Defines */

/** @defgroup Periph_ETHERNET_Defines Defines
  * @{
  */

/** @defgroup Periph_ETHERNET_ETHERNET_ETH_X_CFG_Bits ETHERNET_ETH_X_CFG
  * @{
  */

#define ETHERNET_ETH_X_CFG_RtryCnt_OFFS         0
#define ETHERNET_ETH_X_CFG_RtryCnt_MASK         ((uint32_t)0x0000000F)

#define ETHERNET_ETH_X_CFG_IPG_EN_OFFS          4
#define ETHERNET_ETH_X_CFG_IPG_EN               ((uint32_t)0x00000010)

#define ETHERNET_ETH_X_CFG_CRC_EN_OFFS          5
#define ETHERNET_ETH_X_CFG_CRC_EN               ((uint32_t)0x00000020)

#define ETHERNET_ETH_X_CFG_PRE_EN_OFFS          6
#define ETHERNET_ETH_X_CFG_PRE_EN               ((uint32_t)0x00000040)

#define ETHERNET_ETH_X_CFG_PAD_EN_OFFS          7
#define ETHERNET_ETH_X_CFG_PAD_EN               ((uint32_t)0x00000080)

#define ETHERNET_ETH_X_CFG_EVNT_MODE_OFFS       8
#define ETHERNET_ETH_X_CFG_EVNT_MODE_MASK       ((uint32_t)0x00000700)

#define ETHERNET_ETH_X_CFG_MSB1st_OFFS          12
#define ETHERNET_ETH_X_CFG_MSB1st               ((uint32_t)0x00001000)

#define ETHERNET_ETH_X_CFG_BE_OFFS              13
#define ETHERNET_ETH_X_CFG_BE                   ((uint32_t)0x00002000)

#define ETHERNET_ETH_X_CFG_RST_OFFS             15
#define ETHERNET_ETH_X_CFG_RST                  ((uint32_t)0x00008000)


/** @} */ /* End of group Periph_ETHERNET_ETHERNET_ETH_X_CFG_Bits */

/** @} */ /* End of group Periph_ETHERNET_Defines */

/** @defgroup Periph_ETHERNET_Defines Defines
  * @{
  */

/** @defgroup Periph_ETHERNET_ETHERNET_ETH_G_CFG_Bits ETHERNET_ETH_G_CFG
  * @{
  */

#define ETHERNET_ETH_G_CFG_ColWnd_OFFS          0
#define ETHERNET_ETH_G_CFG_ColWnd_MASK          ((uint32_t)0x000000FF)

#define ETHERNET_ETH_G_CFG_PAUSE_EN_OFFS        8
#define ETHERNET_ETH_G_CFG_PAUSE_EN             ((uint32_t)0x00000100)

#define ETHERNET_ETH_G_CFG_DTRM_EN_OFFS         9
#define ETHERNET_ETH_G_CFG_DTRM_EN              ((uint32_t)0x00000200)

#define ETHERNET_ETH_G_CFG_HD_EN_OFFS           10
#define ETHERNET_ETH_G_CFG_HD_EN                ((uint32_t)0x00000400)

#define ETHERNET_ETH_G_CFG_DLB_OFFS             11
#define ETHERNET_ETH_G_CFG_DLB                  ((uint32_t)0x00000800)

#define ETHERNET_ETH_G_CFG_AB_MODE_OFFS         12
#define ETHERNET_ETH_G_CFG_AB_MODE              ((uint32_t)0x00001000)

#define ETHERNET_ETH_G_CFG_SOFT_OFFS            14
#define ETHERNET_ETH_G_CFG_SOFT                 ((uint32_t)0x00004000)

#define ETHERNET_ETH_G_CFG_FREE_OFFS            15
#define ETHERNET_ETH_G_CFG_FREE                 ((uint32_t)0x00008000)


/** @} */ /* End of group Periph_ETHERNET_ETHERNET_ETH_G_CFG_Bits */

/** @} */ /* End of group Periph_ETHERNET_Defines */

/** @defgroup Periph_ETHERNET_Defines Defines
  * @{
  */

/** @defgroup Periph_ETHERNET_ETHERNET_ETH_IMR_Bits ETHERNET_ETH_IMR
  * @{
  */

#define ETHERNET_ETH_IMR_RF_OK_OFFS             0
#define ETHERNET_ETH_IMR_RF_OK                  ((uint32_t)0x00000001)

#define ETHERNET_ETH_IMR_MISSED_F_OFFS          1
#define ETHERNET_ETH_IMR_MISSED_F               ((uint32_t)0x00000002)

#define ETHERNET_ETH_IMR_OVF_OFFS               2
#define ETHERNET_ETH_IMR_OVF                    ((uint32_t)0x00000004)

#define ETHERNET_ETH_IMR_SMB_ERR_OFFS           3
#define ETHERNET_ETH_IMR_SMB_ERR                ((uint32_t)0x00000008)

#define ETHERNET_ETH_IMR_CRC_ERR_OFFS           4
#define ETHERNET_ETH_IMR_CRC_ERR                ((uint32_t)0x00000010)

#define ETHERNET_ETH_IMR_CF_OFFS                5
#define ETHERNET_ETH_IMR_CF                     ((uint32_t)0x00000020)

#define ETHERNET_ETH_IMR_LF_OFFS                6
#define ETHERNET_ETH_IMR_LF                     ((uint32_t)0x00000040)

#define ETHERNET_ETH_IMR_SF_OFFS                7
#define ETHERNET_ETH_IMR_SF                     ((uint32_t)0x00000080)

#define ETHERNET_ETH_IMR_XF_OK_OFFS             8
#define ETHERNET_ETH_IMR_XF_OK                  ((uint32_t)0x00000100)

#define ETHERNET_ETH_IMR_XF_ERR_OFFS            9
#define ETHERNET_ETH_IMR_XF_ERR                 ((uint32_t)0x00000200)

#define ETHERNET_ETH_IMR_UNDF_OFFS              10
#define ETHERNET_ETH_IMR_UNDF                   ((uint32_t)0x00000400)

#define ETHERNET_ETH_IMR_LC_OFFS                11
#define ETHERNET_ETH_IMR_LC                     ((uint32_t)0x00000800)

#define ETHERNET_ETH_IMR_CRS_LOST_OFFS          12
#define ETHERNET_ETH_IMR_CRS_LOST               ((uint32_t)0x00001000)

#define ETHERNET_ETH_IMR_MII_RDY_OFFS           15
#define ETHERNET_ETH_IMR_MII_RDY                ((uint32_t)0x00008000)


/** @} */ /* End of group Periph_ETHERNET_ETHERNET_ETH_IMR_Bits */

/** @} */ /* End of group Periph_ETHERNET_Defines */

/** @defgroup Periph_ETHERNET_Defines Defines
  * @{
  */

/** @defgroup Periph_ETHERNET_ETHERNET_ETH_IFR_Bits ETHERNET_ETH_IFR
  * @{
  */

#define ETHERNET_ETH_IFR_RF_OK_OFFS             0
#define ETHERNET_ETH_IFR_RF_OK                  ((uint32_t)0x00000001)

#define ETHERNET_ETH_IFR_MISSED_F_OFFS          1
#define ETHERNET_ETH_IFR_MISSED_F               ((uint32_t)0x00000002)

#define ETHERNET_ETH_IFR_OVF_OFFS               2
#define ETHERNET_ETH_IFR_OVF                    ((uint32_t)0x00000004)

#define ETHERNET_ETH_IFR_SMB_ERR_OFFS           3
#define ETHERNET_ETH_IFR_SMB_ERR                ((uint32_t)0x00000008)

#define ETHERNET_ETH_IFR_CRC_ERR_OFFS           4
#define ETHERNET_ETH_IFR_CRC_ERR                ((uint32_t)0x00000010)

#define ETHERNET_ETH_IFR_CF_OFFS                5
#define ETHERNET_ETH_IFR_CF                     ((uint32_t)0x00000020)

#define ETHERNET_ETH_IFR_LF_OFFS                6
#define ETHERNET_ETH_IFR_LF                     ((uint32_t)0x00000040)

#define ETHERNET_ETH_IFR_SF_OFFS                7
#define ETHERNET_ETH_IFR_SF                     ((uint32_t)0x00000080)

#define ETHERNET_ETH_IFR_XF_OK_OFFS             8
#define ETHERNET_ETH_IFR_XF_OK                  ((uint32_t)0x00000100)

#define ETHERNET_ETH_IFR_XF_ERR_OFFS            9
#define ETHERNET_ETH_IFR_XF_ERR                 ((uint32_t)0x00000200)

#define ETHERNET_ETH_IFR_UNDF_OFFS              10
#define ETHERNET_ETH_IFR_UNDF                   ((uint32_t)0x00000400)

#define ETHERNET_ETH_IFR_LC_OFFS                11
#define ETHERNET_ETH_IFR_LC                     ((uint32_t)0x00000800)

#define ETHERNET_ETH_IFR_CRS_LOST_OFFS          12
#define ETHERNET_ETH_IFR_CRS_LOST               ((uint32_t)0x00001000)

#define ETHERNET_ETH_IFR_MII_RDY_OFFS           15
#define ETHERNET_ETH_IFR_MII_RDY                ((uint32_t)0x00008000)


/** @} */ /* End of group Periph_ETHERNET_ETHERNET_ETH_IFR_Bits */

/** @} */ /* End of group Periph_ETHERNET_Defines */

/** @defgroup Periph_ETHERNET_Defines Defines
  * @{
  */

/** @defgroup Periph_ETHERNET_ETHERNET_ETH_MDIO_CTRL_Bits ETHERNET_ETH_MDIO_CTRL
  * @{
  */

#define ETHERNET_ETH_MDIO_CTRL_RG_A_OFFS        0
#define ETHERNET_ETH_MDIO_CTRL_RG_A_MASK        ((uint32_t)0x0000001F)

#define ETHERNET_ETH_MDIO_CTRL_DIV_OFFS         5
#define ETHERNET_ETH_MDIO_CTRL_DIV_MASK         ((uint32_t)0x000000E0)

#define ETHERNET_ETH_MDIO_CTRL_PHY_A_OFFS       8
#define ETHERNET_ETH_MDIO_CTRL_PHY_A_MASK       ((uint32_t)0x00001F00)

#define ETHERNET_ETH_MDIO_CTRL_OP_OFFS          13
#define ETHERNET_ETH_MDIO_CTRL_OP               ((uint32_t)0x00002000)

#define ETHERNET_ETH_MDIO_CTRL_PRE_EN_OFFS      14
#define ETHERNET_ETH_MDIO_CTRL_PRE_EN           ((uint32_t)0x00004000)


/** @} */ /* End of group Periph_ETHERNET_ETHERNET_ETH_MDIO_CTRL_Bits */

/** @} */ /* End of group Periph_ETHERNET_Defines */

/** @defgroup Periph_ETHERNET_Defines Defines
  * @{
  */

/** @defgroup Periph_ETHERNET_ETHERNET_ETH_BUFF_STAT_Bits ETHERNET_ETH_BUFF_STAT
  * @{
  */

#define ETHERNET_ETH_Buff_Stat_R_EMPTY_OFFS     0
#define ETHERNET_ETH_Buff_Stat_R_EMPTY          ((uint32_t)0x00000001)

#define ETHERNET_ETH_Buff_Stat_R_AEMPTY_OFFS    1
#define ETHERNET_ETH_Buff_Stat_R_AEMPTY         ((uint32_t)0x00000002)

#define ETHERNET_ETH_Buff_Stat_R_HALF_OFFS      2
#define ETHERNET_ETH_Buff_Stat_R_HALF           ((uint32_t)0x00000004)

#define ETHERNET_ETH_Buff_Stat_R_AFULL_OFFS     3
#define ETHERNET_ETH_Buff_Stat_R_AFULL          ((uint32_t)0x00000008)

#define ETHERNET_ETH_Buff_Stat_R_FULL_OFFS      4
#define ETHERNET_ETH_Buff_Stat_R_FULL           ((uint32_t)0x00000010)

#define ETHERNET_ETH_Buff_Stat_X_EMPTY_OFFS     8
#define ETHERNET_ETH_Buff_Stat_X_EMPTY          ((uint32_t)0x00000100)

#define ETHERNET_ETH_Buff_Stat_X_AEMPTY_OFFS    9
#define ETHERNET_ETH_Buff_Stat_X_AEMPTY         ((uint32_t)0x00000200)

#define ETHERNET_ETH_Buff_Stat_X_HALF_OFFS      10
#define ETHERNET_ETH_Buff_Stat_X_HALF           ((uint32_t)0x00000400)

#define ETHERNET_ETH_Buff_Stat_X_AFULL_OFFS     11
#define ETHERNET_ETH_Buff_Stat_X_AFULL          ((uint32_t)0x00000800)

#define ETHERNET_ETH_Buff_Stat_X_FULL_OFFS      12
#define ETHERNET_ETH_Buff_Stat_X_FULL           ((uint32_t)0x00001000)


/** @} */ /* End of group Periph_ETHERNET_ETHERNET_ETH_BUFF_STAT_Bits */

/** @} */ /* End of group Periph_ETHERNET_Defines */

/** @} */ /* End of group Periph_ETHERNET */

/** @} */ /* End of group __OPORA_Peripheral_Units */

/** @} */ /* End of group __CMSIS */

#endif /* __OPORA_ETHERNET_DEFS_H */

/******************* (C) COPYRIGHT 2010 Phyton *********************************
*
* END OF FILE opora_ethernet_defs.h */
