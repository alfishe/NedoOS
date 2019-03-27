openstream_file
;de=filename
;out: A!=0 => error
        OS_OPENHANDLE
;b=new file handle
	push af
        ld a,b
        ld (filehandle),a
	pop af;
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
