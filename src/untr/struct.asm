SMPLINE=7

_O=1+10+26+'O'-'A'
_A=1+10+26+'A'-'A'
_B=1+10+26+'B'-'A'
_C=1+10+26+'C'-'A'
_E=1+10+26+'E'-'A'
_V=1+10+26+'V'-'A'
_a=1+10+'a'-'a'
_b=1+10+'b'-'a'
_c=1+10+'c'-'a'
_d=1+10+'d'-'a'
_e=1+10+'e'-'a'
_f=1+10+'f'-'a'
_g=1+10+'g'-'a'
_n=1+10+'n'-'a'
_o=1+10+'o'-'a'
_p=1+10+'p'-'a'
_t=1+10+'t'-'a'
_v=1+10+'v'-'a'
_0=1+'0'-'0'
_1=1+'1'-'0'
_2=1+'2'-'0'
_3=1+'3'-'0'
_4=1+'4'-'0'
_5=1+'5'-'0'
_6=1+'6'-'0'
_7=1+'7'-'0'
_8=1+'8'-'0'
_9=1+'9'-'0'

        STRUCT chip
retriggers BYTE ;A,B,C
Atonefrq WORD
Btonefrq WORD
Ctonefrq WORD
noisefrq BYTE
masks   BYTE ;!AT,!BT,!CT,!AN,!BN,!CN
Avolume BYTE
Bvolume BYTE
Cvolume BYTE
envfrq  WORD
envtype BYTE ;+retrigenvbit
        ENDS

CHNTYPEMASK=0x7f
CHNTYPE_ORDER=0 ;цифры, которые означают начало i-го фрагмента (для привязанных к ордеру каналов)
CHNTYPE_FILTER=1 ;цифры, между которыми эффект плавно изменяется. эффект влияет на предыдущий канал
CHNTYPE_NOTES=2 ;буквы нот (3 октавы)
CHNTYPE_SAMPLES=3 ;буквы сэмплов

        macro CHNTYPE chntype,usedorder;,addr
        db chntype ;+0x80=надо перерисовать
        db usedorder ;0=не привязан к ордеру
        ;dw addr ;описатель канала
        chn
        endm

;masks (T,N,E,hole,outerenv,retrigtone)
;+-96 semitone shift
;+-96 env semitone shift (fair tone ratio guaranteed for 1:1, 3:4, 1:2, 1:4, 3:1, 5:2, 2:1, 3:2 + 4:1)
;+-4095 tonefrq shift
;16 volume
;32 noisefrq
;16*2 envtype +retrigenvbit
;в этой структуре накопления запрещены!
        STRUCT chn
tonefrq WORD ;0..32767 (cut to 0..4095)
masks   BYTE ;T,N,E,hole,outerenv,retrigtone ;дырка управляется отдельно!!! т.к. уровень для !T!N отличается от T vol 0
keepme  BYTE ;priority for keep on top (bigger is more priority)
volume  BYTE ;volume = +-127 (cut to 0..15)
noisefrq BYTE ;noise = 0..255 (cut to 0..31)
envtype BYTE ;+retrigenvbit
envfrq  WORD
;эти не копировать!!!
channel_in BYTE ;0..2
note_in BYTE
oldnote_in BYTE
keepme_in BYTE ;priority for keep on top (bigger is more priority)
volume_in BYTE ;громкость из параметров трека
par1_in BYTE
par2_in BYTE
par3_in BYTE
smp_in  WORD
smpcuraddr  WORD
curgliss WORD
glissspeed_in WORD
handler WORD ;для фильтра
curvalue BYTE ;для фильтра. рассчитано интерполяцией
        ENDS

MASKBIT_T=0
MASKBIT_N=1
MASKBIT_E=2
MASKBIT_HOLE=3
MASKBIT_OUTERENV=4
MASKBIT_RETRIGTONE=5

retrigenvbit=7

chnsstep=2+chn
