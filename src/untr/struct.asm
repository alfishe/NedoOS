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
channel_in BYTE
note_in BYTE
keepme_in BYTE ;priority for keep on top (bigger is more priority)
smp_in  WORD
smpcuraddr  WORD
        ENDS

MASKBIT_T=0
MASKBIT_N=1
MASKBIT_E=2
MASKBIT_HOLE=3
MASKBIT_OUTERENV=4
MASKBIT_RETRIGTONE=5

retrigenvbit=7
