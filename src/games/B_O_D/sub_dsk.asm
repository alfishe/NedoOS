
;image loaded in load_buf1 and load_buf2;
load_gfx_pre_sub:
        push hl

        call load_gfx_sub ;set path - gfs/ddp
        ld a,(language)
        ld hl,loc_modes
        call sel_word
        call copystr_hlde ;+lang    ( gfx/ddp/eng/ )


        ld a,(censor_mode)
        and a
        jr z,load_gfx_pre_sub_one   
        call load_censor_sub  ;( gfx/ddp/eng/censored/ )

        pop hl
        push hl
        call copy_gfx_name_ext

        ld de,buf
        call openstream_file
        or a
        jp z,load_gfx_to_load_buf_found  ;found localized image

        call load_gfx_sub
        ld a,(language)
        ld hl,loc_modes
        call sel_word
        call copystr_hlde ;+lang    ( gfx/ddp/eng/ )


load_gfx_pre_sub_one:
        pop hl
        push hl
        call copy_gfx_name_ext

        ld de,buf
        call openstream_file
        or a
        jp z,load_gfx_to_load_buf_found  ;found localized image

        call load_gfx_sub       

        ld a,(censor_mode)
        and a
        jr z,load_gfx_pre_sub_two   

        call load_censor_sub  ;( gfx/ddp/censored/ )

        pop hl
        push hl
        call copy_gfx_name_ext

        ld de,buf
        call openstream_file
        or a
        jp z,load_gfx_to_load_buf_found  ;found localized image

        call load_gfx_sub

load_gfx_pre_sub_two:
        pop hl
        push hl
        call copy_gfx_name_ext ;( gfx/ddp/ )


        ld de,buf
        call openstream_file
        or a
        jp nz,fileopenerror  

load_gfx_to_load_buf_found:        
        pop hl
        ret




load_gfx_to_load_buf:
        ld a,1
        jr load_gfx_to_load_buf_nopal+1
load_gfx_to_load_buf_nopal:
        xor a
        and a
        push af
        call load_gfx_pre_sub

        call store8000c000
        call store4000l


        ld a,(load_buf1)
        SETPG8000

        ld a,(load_buf2)
        SETPGC000

        ld a,(zx0_page)
        SETPG4000


         ld hl,0x8000
         ld de,0x4000
         call readstream_file
         or a
        jp nz,filereaderror 

        call closestream_file

        pop af

        ld hl,0x4000
        ld bc,32
        jp z,.no_pal

        ld de,pal
        ldir
        jp ._skp_pal
.no_pal
        add hl,bc

._skp_pal
        inc hl:inc hl  ;offset to unpack 16c screen. always 7ffd
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        add hl,de   ;end of zx0 file
        ld de,0xffff        
        call dzx0_turbo_back
        call restore4000l
        jp restore8000c000


load_gfx_sub:
        ld de,buf
        ld hl,gfx_path1   
        call copystr_hlde ;gfx/

        ld a,(gfx_mode)
        ld hl,gfx_modes
        call sel_word
        jp copystr_hlde ;gfx/ddp/

load_censor_sub:
        ld hl,censor_path   
        jp copystr_hlde ;gfx/



copy_gfx_name_ext:
        call copystr_hlde ;+picture name
        ld hl,gfx_ext
        call copystr_hlde ;+extension
        xor a
        ld (de),a         ;+string terminator
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;image loaded in mem_buf1 and mem_buf2;
load_gfx_to_scr_buf:
        xor a
        jr load_gfx_to_mem_buf+2
load_gfx_to_mem_buf:
        ld a,1
        and a
        push af

        call load_gfx_pre_sub

        call store8000c000
        call store4000l

        ld a,(zx0_page)
        SETPG4000

        pop af
        push af
        jp z,.scr_part1

        ld a,(mem_buf1)
        SETPG8000
        ld a,(mem_buf2)
        jp .sk_s
.scr_part1
        ld a,(scr_buf1)
        SETPG8000
        ld a,(scr_buf2)
.sk_s
        SETPGC000

         ld hl,0x8000
         ld de,0x4000
         call readstream_file
         or a
        jp nz,filereaderror 

        call closestream_file

        pop af

        ld hl,0x4000
        ld bc,32
        jp z,.no_pal

        ld de,mempal
        ldir
        jp ._skp_pal
.no_pal
        add hl,bc

._skp_pal
        inc hl:inc hl  ;offset to unpack 16c screen. always 7ffd
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        add hl,de   ;end of zx0 file
        ld de,0xffff        
        call dzx0_turbo_back
        call restore4000l
        jp restore8000c000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load_ovl_to_script_buf:
        push hl
        call load_ovl_to_script_buf_sub

        ld a,(language)
        ld hl,loc_modes
        call sel_word
        call copystr_hlde ;+lang    ( ovl/eng/ )

        pop hl
        push hl
        call copystr_hlde ;+name

        xor a
        ld (de),a

        ld de,buf
        call openstream_file
        or a
        jr z,load_ovl_to_script_buf_found  ;found localized ovl

        call load_ovl_to_script_buf_sub

        pop hl 
        push hl
        call copystr_hlde
        xor a
        ld (de),a        

        ld de,buf
        call openstream_file
        or a
        jp nz,fileopenerror 
load_ovl_to_script_buf_found:
        pop hl

        ld a,(script_buf1)
        SETPG4000
        ld a,(script_buf2)
        SETPG8000        

        ld hl,0x8000
        ld de,0x4000
        call readstream_file
        or a
        jp nz,filereaderror 

        jp closestream_file


load_ovl_to_script_buf_sub:
        ld de,buf
        ld hl,ovl_path1   
        jp copystr_hlde ;ovl/

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
savestream_file
;de=buf
;hl=size
        ld a,(filehandle)
        ld b,a
        OS_WRITEHANDLE
;hl=actual size
        ret
;============================================ 
showpalz:
        ld a,1
        ld (setpalflag),a
        ret

load_big_img_dark:
        ld hl,showpalz
        push hl

load_big_img_dark2:
        call load_gfx_to_load_buf

        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir

        ld hl,blackpal
        ld de,pal
        ld bc,32 
        ldir

        call _immed_big

        ld de,pal
        ld hl,temppal
        ld bc,32
        ldir    
        ret
