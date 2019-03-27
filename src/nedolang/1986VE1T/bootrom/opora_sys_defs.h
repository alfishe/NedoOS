/**
  ******************************************************************************
  * @file    opora_sys_defs.h
  * @author  Phyton Application Team
  * @version V1.0.0
  * @date
  * @brief   This file contains all the Special Function Registers definitions
  *          for the SYS peripheral unit used in the Milandr OPORA
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
  * FILE opora_sys_defs.h
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __OPORA_SYS_DEFS_H
#define __OPORA_SYS_DEFS_H

/** @addtogroup __CMSIS CMSIS
  * @{
  */

/** @addtogroup __OPORA_Peripheral_Units OPORA Peripheral Units
  * @{
  */

/** @defgroup Periph_SYS SYS
  * @{
  */

/** @defgroup Periph_SYS_Data_Structures Data Structures
  * @{
  */

/** @defgroup Periph_SYS_TypeDef SYS_TypeDef
  * @{
  */

typedef struct {
       uint32_t RESERVED0[2];
  __IO uint32_t ACTLR;
       uint32_t RESERVED1;
  __IO uint32_t STCSR;
  __IO uint32_t STRVR;
  __IO uint32_t STCVR;
  __IO uint32_t STCR;
       uint32_t RESERVED2[56];
  __IO uint32_t ISER;
       uint32_t RESERVED3[31];
  __IO uint32_t ICER;
       uint32_t RESERVED4[31];
  __IO uint32_t ISPR;
       uint32_t RESERVED5[31];
  __IO uint32_t ICPR;
       uint32_t RESERVED6[95];
  __IO uint32_t IPR0;
  __IO uint32_t IPR1;
  __IO uint32_t IPR2;
  __IO uint32_t IPR3;
  __IO uint32_t IPR4;
  __IO uint32_t IPR5;
  __IO uint32_t IPR6;
  __IO uint32_t IPR7;
       uint32_t RESERVED7[568];
  __IO uint32_t CPUID;
  __IO uint32_t ICSR;
       uint32_t RESERVED8;
  __IO uint32_t AIRCR;
       uint32_t RESERVED9;
  __IO uint32_t CCR;
       uint32_t RESERVED10;
  __IO uint32_t SHPR2;
  __IO uint32_t SHPR3;
  __IO uint32_t SHCSR;
} SYS_TypeDef;

/** @} */ /* End of group Periph_SYS_TypeDef */

/** @} */ /* End of group Periph_SYS_Data_Structures */

/** @defgroup Periph_SYS_Defines Defines
  * @{
  */

/** @defgroup Periph_SYS_SYS_ACTLR_Bits SYS_ACTLR
  * @{
  */

#define SYS_ACTLR_ITCMLAEN_OFFS                 0
#define SYS_ACTLR_ITCMLAEN                      ((uint32_t)0x00000001)

#define SYS_ACTLR_ITCMUAEN_OFFS                 1
#define SYS_ACTLR_ITCMUAEN                      ((uint32_t)0x00000002)


/** @} */ /* End of group Periph_SYS_SYS_ACTLR_Bits */

/** @} */ /* End of group Periph_SYS_Defines */

/** @defgroup Periph_SYS_Defines Defines
  * @{
  */

/** @defgroup Periph_SYS_SYS_STCSR_Bits SYS_STCSR
  * @{
  */

#define SYS_STCSR_ENABLE_OFFS                   0
#define SYS_STCSR_ENABLE                        ((uint32_t)0x00000001)

#define SYS_STCSR_TICKINT_OFFS                  1
#define SYS_STCSR_TICKINT                       ((uint32_t)0x00000002)

#define SYS_STCSR_CLKSOURCE_OFFS                2
#define SYS_STCSR_CLKSOURCE                     ((uint32_t)0x00000004)

#define SYS_STCSR_COUNTFLAG_OFFS                16
#define SYS_STCSR_COUNTFLAG                     ((uint32_t)0x00010000)


/** @} */ /* End of group Periph_SYS_SYS_STCSR_Bits */

/** @} */ /* End of group Periph_SYS_Defines */

/** @defgroup Periph_SYS_Defines Defines
  * @{
  */

/** @defgroup Periph_SYS_SYS_STCR_Bits SYS_STCR
  * @{
  */

#define SYS_STCR_TENMS_OFFS                     0
#define SYS_STCR_TENMS_MASK                     ((uint32_t)0x00FFFFFF)

#define SYS_STCR_SKEW_OFFS                      30
#define SYS_STCR_SKEW                           ((uint32_t)0x40000000)

#define SYS_STCR_NOREF_OFFS                     31
#define SYS_STCR_NOREF                          ((uint32_t)0x80000000)


/** @} */ /* End of group Periph_SYS_SYS_STCR_Bits */

/** @} */ /* End of group Periph_SYS_Defines */

/** @defgroup Periph_SYS_Defines Defines
  * @{
  */

/** @defgroup Periph_SYS_SYS_IPR_Bits SYS_IPR
  * @{
  */

#define SYS_IPR_PRI_N_OFFS                      0
#define SYS_IPR_PRI_N_MASK                      ((uint32_t)0x00000003)

#define SYS_IPR_PRI_N1_OFFS                     8
#define SYS_IPR_PRI_N1_MASK                     ((uint32_t)0x00000300)

#define SYS_IPR_PRI_N2_OFFS                     16
#define SYS_IPR_PRI_N2_MASK                     ((uint32_t)0x00030000)

#define SYS_IPR_PRI_N3_OFFS                     24
#define SYS_IPR_PRI_N3_MASK                     ((uint32_t)0x03000000)


/** @} */ /* End of group Periph_SYS_SYS_IPR_Bits */

/** @} */ /* End of group Periph_SYS_Defines */

/** @defgroup Periph_SYS_Defines Defines
  * @{
  */

/** @defgroup Periph_SYS_SYS_CPUID_Bits SYS_CPUID
  * @{
  */

#define SYS_CPUID_REVISION_OFFS                 0
#define SYS_CPUID_REVISION_MASK                 ((uint32_t)0x0000000F)

#define SYS_CPUID_PARTNO_OFFS                   4
#define SYS_CPUID_PARTNO_MASK                   ((uint32_t)0x0000FFF0)

#define SYS_CPUID_Const_0xF_OFFS                16
#define SYS_CPUID_Const_0xF_MASK                ((uint32_t)0x000F0000)

#define SYS_CPUID_VARIANT_OFFS                  20
#define SYS_CPUID_VARIANT_MASK                  ((uint32_t)0x00F00000)

#define SYS_CPUID_IMPLEMENTER_OFFS              24
#define SYS_CPUID_IMPLEMENTER_MASK              ((uint32_t)0xFF000000)


/** @} */ /* End of group Periph_SYS_SYS_CPUID_Bits */

/** @} */ /* End of group Periph_SYS_Defines */

/** @defgroup Periph_SYS_Defines Defines
  * @{
  */

/** @defgroup Periph_SYS_SYS_ICSR_Bits SYS_ICSR
  * @{
  */

#define SYS_ICSR_VECTACTIVE_OFFS                0
#define SYS_ICSR_VECTACTIVE_MASK                ((uint32_t)0x0000003F)

#define SYS_ICSR_VECTPENDING_OFFS               12
#define SYS_ICSR_VECTPENDING_MASK               ((uint32_t)0x0003F000)

#define SYS_ICSR_ISRPENDING_OFFS                22
#define SYS_ICSR_ISRPENDING                     ((uint32_t)0x00400000)

#define SYS_ICSR_ISRPREEMPT_OFFS                23
#define SYS_ICSR_ISRPREEMPT                     ((uint32_t)0x00800000)

#define SYS_ICSR_PENDSTCLR_OFFS                 25
#define SYS_ICSR_PENDSTCLR                      ((uint32_t)0x02000000)

#define SYS_ICSR_PENDSTSET_OFFS                 26
#define SYS_ICSR_PENDSTSET                      ((uint32_t)0x04000000)

#define SYS_ICSR_PENDSVCLR_OFFS                 27
#define SYS_ICSR_PENDSVCLR                      ((uint32_t)0x08000000)

#define SYS_ICSR_PENDSVSET_OFFS                 28
#define SYS_ICSR_PENDSVSET                      ((uint32_t)0x10000000)

#define SYS_ICSR_NMIPENDSET_OFFS                31
#define SYS_ICSR_NMIPENDSET                     ((uint32_t)0x80000000)


/** @} */ /* End of group Periph_SYS_SYS_ICSR_Bits */

/** @} */ /* End of group Periph_SYS_Defines */

/** @defgroup Periph_SYS_Defines Defines
  * @{
  */

/** @defgroup Periph_SYS_SYS_AIRCR_Bits SYS_AIRCR
  * @{
  */

#define SYS_AIRCR_VECTCLRACTIVE_OFFS            0
#define SYS_AIRCR_VECTCLRACTIVE                 ((uint32_t)0x00000001)

#define SYS_AIRCR_SYSRESETREQ_OFFS              1
#define SYS_AIRCR_SYSRESETREQ                   ((uint32_t)0x00000002)

#define SYS_AIRCR_ENDIANESS_OFFS                14
#define SYS_AIRCR_ENDIANESS                     ((uint32_t)0x00004000)

#define SYS_AIRCR_VECTKEYSTAT_OFFS              15
#define SYS_AIRCR_VECTKEYSTAT_MASK              ((uint32_t)0x7FFF8000)


/** @} */ /* End of group Periph_SYS_SYS_AIRCR_Bits */

/** @} */ /* End of group Periph_SYS_Defines */

/** @defgroup Periph_SYS_Defines Defines
  * @{
  */

/** @defgroup Periph_SYS_SYS_CCR_Bits SYS_CCR
  * @{
  */

#define SYS_CCR_UNALIGN_TRP_OFFS                0
#define SYS_CCR_UNALIGN_TRP                     ((uint32_t)0x00000001)

#define SYS_CCR_STKALIGN_OFFS                   6
#define SYS_CCR_STKALIGN                        ((uint32_t)0x00000040)


/** @} */ /* End of group Periph_SYS_SYS_CCR_Bits */

/** @} */ /* End of group Periph_SYS_Defines */

/** @defgroup Periph_SYS_Defines Defines
  * @{
  */

/** @defgroup Periph_SYS_SYS_SHPR3_Bits SYS_SHPR3
  * @{
  */

#define SYS_SHPR3_PRI_14_OFFS                   0
#define SYS_SHPR3_PRI_14_MASK                   ((uint32_t)0x00000003)

#define SYS_SHPR3_PRI_15_OFFS                   8
#define SYS_SHPR3_PRI_15_MASK                   ((uint32_t)0x00000300)


/** @} */ /* End of group Periph_SYS_SYS_SHPR3_Bits */

/** @} */ /* End of group Periph_SYS_Defines */

/** @} */ /* End of group Periph_SYS */

/** @} */ /* End of group __OPORA_Peripheral_Units */

/** @} */ /* End of group __CMSIS */

#endif /* __OPORA_SYS_DEFS_H */

/******************* (C) COPYRIGHT 2010 Phyton *********************************
*
* END OF FILE opora_sys_defs.h */
