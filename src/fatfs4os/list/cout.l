################################################################################
#                                                                              #
#      IAR Universal Linker V5.0.0.2/W32                                       #
#                                                                              #
#           Link time     =  01/May/2022  22:50:55                             #
#           Target CPU    =  Z80/64180                                         #
#           List file     =  list\cout.l                                       #
#           Output file 1 =  H:\nos\nedoos\src\fatfs4os\fatfs.raw              #
#                            Format: raw-binary                                #
#           Command line  =  ff ccsbcs mylib -f link.lnk (-S -cZ80 -Ilist      #
#                            -FRAW-BINARY -C ..\..\iar\lib\\clz80 -o           #
#                            fatfs.raw -l list/cout.l -xe                      #
#                            -Z(CODE)TRST,RCODE,CODE,CDATA0,CONST,CSTR,CCSTR,D #
#                            ATA0,IDATA0,UDATA0,ECSTR,NO_INIT,TEMP=4000-7FFF)  #
#                                                                              #
#                           Copyright (C) 1987-2010 IAR Systems AB.            #
################################################################################





                ****************************************
                *                                      *
                *           CROSS REFERENCE            *
                *                                      *
                ****************************************

                  There are no program entries.


                ****************************************
                *                                      *
                *              ENTRY LIST              *
                *                                      *
                ****************************************

Module  Entry                   Address
------  -----                   -------
?FILLER_BYTES
ff ( H:\nos\nedoos\src\fatfs4os\list\ff.r01 )
        clust2sect               4569
        f_chdir                  6FB9
        f_chdrive                6FB5
        f_close                  6F9E
        f_getcwd                 7011
        f_getutime               7A47
        f_lseek                  71A3
        f_mkdir                  77D2
        f_mount                  65F2
        f_open                   6618
        f_opendir                7543
        f_read                   684A
        f_readdir                75DD
        f_rename                 7AAE
        f_stat                   7669
        f_sync                   6ED8
        f_unlink                 76B3
        f_utime                  79E8
        f_write                  6B65
        gen_numname              521B
        get_fat                  45E6
        put_fat                  46EC
        fno_rddir                7F05
ccsbcs ( H:\nos\nedoos\src\fatfs4os\list\ccsbcs.r01 )
        ff_convert               7C2B
mylib ( H:\nos\nedoos\src\fatfs4os\list\mylib.r01 )
        tablcall                 4026
        LD_CLUST                 4072
        drv_calls                4000
        dio_par                  401A
        FatFs                    4050
        Fsid                     4070
?LIB_VERSION_L00 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?CLZ80L_4_06_L00         0000
?US_RSH_L02 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?US_RSH_L02              4082
?US_DIV_L02 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?US_DIV_L02              408C
?S_DIVMOD_L02 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?S_DIVMOD_L02            409A
?S_MUL_L02 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?S_MUL_L02               40B0
?L_LSH_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?L_LSH_L03               40D2
?UL_RSH_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?UL_RSH_L03              40EA
?L_MUL_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?L_MUL_L03               4105
?UL_DIV_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?UL_DIV_L03              416D
?L_DIVMOD_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?L_DIVMOD_L03            4195
?L_AND_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?L_AND_L03               41ED
?L_INC_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?L_INC_L03               420B
?L_DEC_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?L_DEC_L03               4213
?L_NOT_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?L_NOT_L03               421C
?L_MULASG_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?L_MULASG_L03            422B
?L_END_MULDIVASG_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?L_END_MULDIVASG_L03     423B
?L_ADDASG_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?L_ADDASG_L03            4244
?L_SUBASG_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?L_SUBASG_L03            425D
?L_ORASG_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?L_ORASG_L03             4276
?L_INCASG_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?L_INCASG_L03            428F
?L_END_ASG_L03 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?L_END_ASG_L03           429D
?ENT_PARM_DIRECT_L09 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?ENT_PARM_DIRECT_L09     42A6
?ENT_AUTO_DIRECT_L09 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?ENT_AUTO_DIRECT_L09     42B2
?LEAVE_DIRECT_L09 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?LEAVE_DIRECT_L09        42C6
?LEAVE_32_L09 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?LEAVE_32_L09            42CD
?CALL_IND_L09 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?CALL_IND_L09            42D5
?MEMSET_L11 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?MEMSET_L11              42D6
?MEMCMP_L11 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?MEMCMP_L11              42ED
?STRCHR_L11 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?STRCHR_L11              430B
?US_RSHASG_BC_prim_L12 ( H:\nos\nedoos\iar\lib\clz80.r01 )
        ?US_RSHASG_BC_prim_L12   4316

                ****************************************
                *                                      *
                *        END OF CROSS REFERENCE        *
                *                                      *
                ****************************************

 16 272 bytes of CODE memory

Errors: none
Warnings: none

