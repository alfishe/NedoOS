getpath_file
;de=buffer to get path
        OS_GETPATH
        ret

rootdir_file
        ld de,tdot
chdir_file
;de=path
        OS_CHDIR
        ret

openstream_file
;de=filename (without / in the end)
        OS_OPENHANDLE
;b=new file handle
        ld a,b
        ld (filehandle),a
        ret

readstream_file
;de=buf
;hl=size
filehandle=$+1
        ld b,0
        OS_READHANDLE
;hl=actual size
        ret

closestream_file
;close current stream
        ld a,(filehandle)
        ld b,a
        OS_CLOSEHANDLE
        ret

tdot
        db ".",0
