MODULE mylib
  PUBLIC tablcall
  PUBLIC LD_CLUST
  PUBLIC drv_calls_struct,dio_par,CurrDir
  PUBLIC CurrVol
  PUBLIC FatFs
  PUBLIC Fsid
  EXTERN f_mount
  EXTERN f_open
  EXTERN f_read
  EXTERN f_lseek
  EXTERN f_close
  EXTERN f_opendir
  EXTERN f_readdir
  EXTERN f_stat
  EXTERN f_write
  EXTERN f_getfree
  EXTERN f_truncate
  EXTERN f_sync
  EXTERN f_unlink
  EXTERN f_mkdir
  EXTERN f_chmod
  EXTERN f_utime
  EXTERN f_rename
  EXTERN f_chdrive
  EXTERN f_chdir,f_getcwd
  EXTERN ?L_MUL_L03
  EXTERN f_getutime
  

  RSEG TRST
  
drv_calls_struct:
		defw 0	;init
		defw 0	;read
		defw 0	;write
		defw 0	;status
		defw 0	;RTC
dio_par:
        DEFB 1        ;DRV
        DEFW 0x4000   ;*BUF
        DEFW 0        ;*sec
        DEFB 32       ;NUM
CurrVol:
        DEFB 0
CurrDir:
		DEFW 0,0
tablcall:  
  DEFW f_mount
  DEFW f_open
  DEFW f_read
  DEFW f_lseek
  DEFW f_close
  DEFW f_opendir
  DEFW f_readdir
  DEFW f_stat
  DEFW f_write
  DEFW f_getfree
  DEFW f_truncate
  DEFW f_sync
  DEFW f_unlink
  DEFW f_mkdir
  DEFW f_chmod
  DEFW f_utime
  DEFW f_rename
  DEFW f_chdrive
  DEFW f_chdir
  DEFW f_getcwd
  DEFW f_getutime
//VolToPart:
//        DEFB 0,0,1,0

FatFs:
        DEFW 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Fsid:
        DEFW 0
		
LD_CLUST:
  LD HL,20
  ADD HL,DE
  LD C,(HL)
  INC HL
  LD B,(HL)
  LD HL,26
  ADD HL,DE
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  ret
  
    
ENDMOD
END

