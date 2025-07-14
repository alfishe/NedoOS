ENUM {
_TOKENDTEXT, //постфикс любого текста
_TOKOPENSQ, //[
_TOKCLOSESQ, //]
_TOKnu,//_TOKENDCOMMENT, //токен, который не встречается в текстах, чтобы не ходить по text-endtext (которых может быть много в одном комментарии?)
_TOKNUM, //префикс числа, после него <text>digits<endtext>
_ERR,
_TOKENDERR,
_TOKLABEL, //префикс метки, после него <text>label.sublabel<endtext>
_TOKEOF, //конец файла
_OPWRVAL, //после выражения в db...

//не команды ассемблера (дают обрыв слова и выражения):
_TOKEOL, //новая строка = 0x0a
_TOKEXPR,
_TOKENDEXPR,
_TOKCR, //NU = 0x0d

_OPWRSTR, //перед строковой константой в db
_FMTCMD,
_FMTREEQU,
_TOKTEXT, //TODO " как префикс любого текста

_TOKSPC1,
_TOKSPC2,
_TOKSPC3,
_TOKSPC4,
_TOKSPC5,
_TOKSPC6,
_TOKSPC7,
_TOKSPC8,

//не команды ассемблера (дают обрыв слова и выражения):
_TOKDBLQUOTE = 0x22, //"
_TOKDIRECT = 0x23, //#
_TOKPRIME = 0x27, //'
_TOKOPEN, //(
_TOKCLOSE, //)

_TOKCOMMA = 0x2c, //,

_TOKCOLON = 0x3a, //: //ничего не делает ни после метки, ни между командами
_TOKCOMMENT, //; //(используется и для экранирования кавычек?) комментарий без текста, после него блоки <text>text<endtext><space><text>text<endtext>... конец по EOL/EOF

_TOKEQUAL = 0x3d, //=

//директивы и команды ассемблера могут встречаться в том же контексте, что и метки
//условия тоже (jp nn/jp nz,nn)
//регистры тоже (sub n/sub r)

//директивы ассемблера:
_CMDREADSTATE = 0x40, //для post labels
_CMDLABEL, //определение метки через $+curdisp //TODO = _TOKLABEL
_CMDORG, //org nn - надо формат writeorg? разбирать вручную?
_CMDALIGN, //align nn - надо формат writealign? разбирать вручную?
_CMDPAGE, //page n - надо формат writepage? разбирать вручную?
_CMDIF, //if nn - надо формат writeif? разбирать вручную?
_CMDELSE,
_CMDENDIF,
_CMDDUP, //dup nn - надо формат writedup? разбирать вручную?
_CMDEDUP,
_CMDMACRO, //macro name - разбирать вручную?
_CMDENDM,
_CMDEXPORT,
_CMDLOCAL, //local name - разбирать вручную?
_CMDENDL,
_CMDDISP, //disp nn - надо формат writedisp? разбирать вручную?
_CMDENT,
_CMDINCLUDE, //include "filename" - разбирать вручную?
_CMDINCBIN, //incbin "filename" - разбирать вручную?
_CMDDB, //db ..., вместо defb - надо после каждого выражения формат writeN, разбирать вручную?
_CMDDW, //dw ..., вместо defw - надо после каждого выражения формат writeNN, разбирать вручную?
_CMDDL, //dl ..., вместо defl - надо после каждого выражения формат writeNNNN, разбирать вручную?
_CMDDS, //ds ..., вместо defs - надо формат writeds?
_CMDDISPLAY, //display nn - форматы displaynum, displaystring - разбирать вручную?
_CMDREPEAT,
_CMDUNTIL, //until nn - надо формат writeuntil
_CMDSTRUCT, //struct name - разбирать вручную?
_CMDENDSTRUCT,
//max 28

//// начиная отсюда зависит от таргета

//условия (8):
_ASMNZ,
_ASMZ,
_ASMNC,
_ASMC,
_ASMPO,
_ASMPE,
_ASMP,
_ASMM,

//b,c,d,e,h,l,a,hx,lx,hy,lx - 11 регистров в первой группе подмена (можно ускорить только ld reg,reg, если запретить подменять индексные половинки)
_RG_B,
_RG_C,
_RG_D,
_RG_E,
_RG_H,
_RG_L,
_RG_A,
_RG_HX,
_RG_LX,
_RG_HY,
_RG_LY,
_RG_I, //i,r - 2 прочих регистра (можно через getregbyname?)
_RG_R,
_RG_RBBYNAME,
//bc,de,hl,sp,ix,iy - 6 регистров во второй группе подмена
_RG_BC,
_RG_DE,
_RG_HL,
_RG_SP,
_RG_IX,
_RG_IY,
_RG_AF, //неподменяемый (af' как <af><'>, причём <'> ничего не будет делать - можно через text)
_RG_RPBYNAME,
//max 22

//(ASMCMDBASE+0x00)
//<ex><rp><commakeepreg><rp><writeex>
_ASMEX,
//#define ASMCMD_EXRPRP     ASMCMD_EX /*ex af,af' (08), ex (sp),hl/ix/iy (e3 / dd+20*ri e3), ex de,hl (eb)*/
//#define ASMCMD_EXA       0x?? /*exa (08)*/
//#define ASMCMD_EXD       0x?? /*exd (eb)*/

//<ret><writecmd>
_ASMRET,
//#define ASMCMD_RET        (ASMCMDBASE+0x01) /*ret (c9)*/
//<ret><cc><writecmd> - cc меняет базу1 на базу2+8*cc
//#define ASMCMD_RETCC      ASMCMD_RET /*ret cc (c0+)*/

_ASMDJNZ,
//#define ASMCMD_DJNZ       (ASMCMDBASE+0x02)
//<djnz><num>LH<writejr> - пишет смещение от $ и отслеживает ошибку
//#define ASMCMD_DJNZDD     ASMCMD_DJNZ /*djnz dd (10)*/

_ASMJR,
//#define ASMCMD_JR         (ASMCMDBASE+0x03)
//<jr><num>LH<writejr> - пишет смещение от $ и отслеживает ошибку
//#define ASMCMD_JRDD       ASMCMD_JR /*jr dd (18)*/
//<jr><cc><comma><num>LH<writejr> - cc меняет базу1 на базу2+8*cc
//#define ASMCMD_JRCCDD     ASMCMD_JR /*jr cc,dd (20)*/
//#define ASMCMD_JZ        0x?? /*jz nn (20+)*/
//#define ASMCMD_JNZ       0x?? /*jnz nn (20+)*/
//#define ASMCMD_JC        0x?? /*jc nn (20+)*/
//#define ASMCMD_JNC       0x?? /*jnc (20+)*/

_ASMJP,
//#define ASMCMD_JP         (ASMCMDBASE+0x04)
//<jp><num>LH<writejp>
//#define ASMCMD_JPNN       ASMCMD_JP /*jp nn (c3)*/
//<jp><cc><comma><num>LH<writejp> - cc меняет базу1 на базу2+8*cc
//#define ASMCMD_JPCCNN     ASMCMD_JP /*jp cc,nn (c2)*/
//<jp><rp><writejprp> - можно использовать скобки, они ни на что не будут влиять. Надо проверить rp и выдать ошибку
//#define ASMCMD_JPHL       ASMCMD_JP /*jp hl/ix/iy (e9)*/

_ASMCALL,
//#define ASMCMD_CALL       (ASMCMDBASE+0x05)
//<call><num>LH<writejp>
//#define ASMCMD_CALLNN     ASMCMD_CALL /*call nn (cd)*/
//<call><cc><comma><num>LH<writejpcc> - cc меняет базу1 на базу2+8*cc
//#define ASMCMD_CALLCCNN   ASMCMD_CALL /*call cc,nn (c4)*/

//единый токен ld, одна база (06), вторая может быть любая (только для ld a,i/r, ld i/r,a, чтобы не создавать новый формат)
//форматы (15..16 шт) commakeepreg, writemov88, writeputm, writealucmdN (БАЗА1, такой же формат в арифметике), writeget8index, writeget8rp, writeputrp8, writegeta, writeputa, writeputrp(==writeputa?), writeldrp, writegetrp, writemovrprp, [writealucmd (БАЗА2, только для ld a,i/r, ld i/r,a),] writeputindex8, writeputindex:
_ASMLD,
//#define ASMCMD_LD         (ASMCMDBASE+0x06)
//#define ASMCMD_MOVRBRB    ASMCMD_LD /*ld reg,reg (40), ld regx,reg, ld reg,regx, ld regx,regx*/
//<ld><reg><commakeepreg><reg><writemov88> - формат проверяет ошибку (ld ?x,?y, ld ?y,?x, ld ?x/y,h/l, ld h/l,?x/y), потом пишет dd/fd и код (пересчитывает индексные половинки в h/l)
//#define ASMCMD_MOVRBRBIR  ASMCMD_LD /*ld a/i/r/lx..,a/i/r/lx.. (?? ??)*/
//<ld><regAIRX><commakeepreg><regAIRX><writemov88rare> - формат проверяет допустимые пары регистров
//#define ASMCMD_PUTMHLN    ASMCMD_LD /*ld (hl),n (36 nn)*/
//#define ASMCMD_PUTMHLRB   ASMCMD_LD /*ld (hl),r (70+)*/
//#define ASMCMD_GETRBMHL   ASMCMD_LD /*ld r,(hl) (46+)*/
//<ld><(><rp(==HL)><)><comma><num>LH<writeputm> - hl неподменяемый!!! если нет токена (hl), то надо отдельный формат writeputm
//#define ASMCMD_LDRBN      ASMCMD_LD /*ld reg,n (06+ nn), ld regx,n*/
//<ld><reg><comma><num>LH<writealucmdN> - формат (БАЗА1) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_LDRPNN     ASMCMD_LD /*ld bc/de/hl/sp,nn (01+ nn nn), ld ix/iy,nn (dd 21 nn nn)*/
//<ld><rp><comma><num>LH<writeldrp> - отдельный формат writeldrp. в формате вручную проверить rp и писать dd/fd
//#define ASMCMD_GETRBIDX ASMCMD_LD /*ld reg,(ix/iy+) (dd 46 xx)*/
//<ld><reg><commakeepreg><(><rp(==IX/IY)><num>LH<)><writeget8index> - ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат пишет dd/fd (индексные половинки - ошибка)
//#define ASMCMD_GETAMRP    ASMCMD_LD /*ld a,(bc/de) (0a+), ld a,(hl) (7e), ld a,(ix)*/
//<ld><reg(==A)><commakeepreg><(><rp><)><writeget8rp> - при bc/de аккумулятор неподменяемый!!! ошибка при sp или индексных половинках reg, отдельный опкод для hl, иначе a
//#define ASMCMD_PUTMRPA    ASMCMD_LD /*ld (bc/de),a (02+), ld (hl),a (77), ld (ix),a*/
//<ld><(><rp><)><commakeepreg><reg(==A)><writeputrp8> - при bc/de аккумулятор неподменяемый!!! ошибка при sp или индексных половинках reg, отдельный опкод для hl, иначе a
//#define ASMCMD_GETAMNN    ASMCMD_LD /*ld a,(nn) (3a nn nn)*/
//<ld><reg(==A)><comma><(><num>LH<)><writegeta> - аккумулятор неподменяемый!!! отдельный формат writegeta
//#define ASMCMD_GETRPMNN   ASMCMD_LD /*ld hl,(nn) (2a nn nn), ld bc/de,(nn) (ed 4b nn nn), ld ix/iy,(nn) (dd 2a nn nn)*/
//<ld><rp><comma><num>LH<writegetrp> (==writegeta?) - в формате вручную проверить rp и писать dd/fd
//#define ASMCMD_PUTMNNA    ASMCMD_LD /*ld (nn),a (32 nn nn)*/
//<ld><(><num>LH<)><comma><reg(==A)><writeputa> - аккумулятор неподменяемый!!! отдельный формат writeputa
//#define ASMCMD_PUTMNNRP   ASMCMD_LD /*ld (nn),hl (22 nn nn), ld (nn),ix/iy (dd 22 nn nn), ld (nn),bc/de (ed 43+ nn nn)*/
//<ld><(><num>LH<)><comma><rp><writeputrp> (==writeputa?) - в формате вручную проверить rp и писать dd/fd
//#define ASMCMD_LDSPRP     ASMCMD_LD /*ld sp,hl (f9), ld sp,ix/iy (dd f9)*/
//<ld><rp(==SP)><comma><rp><writemovrprp> - в формате вручную проверить rp (ошибка при bc,de,sp) и писать dd/fd (можно реализовать ld bc,de и т.п.)
//#define ASMCMD_PUTIDXRB ASMCMD_LD /*ld (ix/iy+),reg (dd 70 xx)*/
//<ld><(><rp(==IX/IY)><num>LH<)><commakeepreg><reg><writeputindex8> - ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат пишет dd/fd (индексные половинки - ошибка)
//#define ASMCMD_PUTIDXN  ASMCMD_LD /*ld (ix/iy+),n (dd 36 xx nn)*/
//<ld><(><rp(==IX/IY)><num>LH<)><comma><num>LH<writeputindex> - ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат пишет dd/fd
//<commakeepreg> ставится перед вторым регистром/rp в команде. Можно сэкономить, если reg хранится в одном месте, а rp в другом, но для add rp,rp надо два rp

//в математике новый формат writecmdindex
//единый токен add, две базы (c6, 80) - можно одну базу (БАЗА2==БАЗА1-46)
_ASMADD,
//#define ASMCMD_ADD        (ASMCMDBASE+0x07)
//#define ASMCMD_ADDAN      ASMCMD_ADD /*add a,n (c6+)*/
//<add><reg(==A)><comma><num>LH<writeddcmdN> - аккумулятор неподменяемый!!! формат (БАЗА1) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_ADDARB     ASMCMD_ADD /*add a,reg (80+), add a,regx*/
//<add><reg(==A)><comma><rp><writeddcmd> - аккумулятор неподменяемый!!! формат (БАЗА2) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_ADDAIDX  ASMCMD_ADD /*add a,(ix+) (dd 86)*/
//<add><reg(==A)><comma><(><rp(==IX/IY)><num>LH<)><writecmdindex> - аккумулятор неподменяемый!!! ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат (БАЗА2) пишет dd/fd
//#define ASMCMD_ADDHLRP    ASMCMD_ADD /*add hl,bc/de/hl/sp (09), add ix/iy,bc/de/ix/iy/sp (dd 09)*/
//<add><rp(==HL/IX/IY)><commakeepreg><rp><writeaddhlrp> - формат проверяет rp1, rp2 и пишет dd/fd (add ix,iy, add iy,ix, add ix/iy,hl, add hl,ix/iy - ошибка)

//единый токен adc, две базы (ce, 88) - можно одну базу (БАЗА2==БАЗА1-46)
_ASMADC,
//#define ASMCMD_ADC        (ASMCMDBASE+0x08)
//#define ASMCMD_ADCAN      ASMCMD_ADC /*adc a,n (ce)*/
//<adc><reg(==A)><comma><num>LH<writeddcmdN> - аккумулятор неподменяемый!!! формат (БАЗА1) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_ADCARB     ASMCMD_ADC /*adc a,reg (88+), adc a,regx*/
//<adc><reg(==A)><comma><rp><writeddcmd> - аккумулятор неподменяемый!!! формат (БАЗА2) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_ADCAIDX  ASMCMD_ADC /*adc a,(ix+) (dd 8e)*/
//<adc><reg(==A)><comma><(><rp(==IX/IY)><num>LH<)><writecmdindex> - аккумулятор неподменяемый! ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат (БАЗА2) пишет dd/fd
//#define ASMCMD_ADCHLRP    ASMCMD_ADC /*adc hl,bc/de/hl/sp (ed 4a+)*/
//<adc><rp(==HL)><comma><rp><writeadchlrp> - формат проверяет rp (ix/iy - ошибка)

//единый токен sub, две базы (d6, 90) - можно одну базу (БАЗА2==БАЗА1-46)
_ASMSUB,
//#define ASMCMD_SUB        (ASMCMDBASE+0x09)
//#define ASMCMD_SUBAN      ASMCMD_SUB /*sub n (d6)*/
//<sub><num>LH<writeddcmdN> - формат (БАЗА1) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_SUBARB     ASMCMD_SUB /*sub reg (90+), sub regx*/
//<sub><rp><writeddcmd> - формат (БАЗА2) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_SUBAIDX  ASMCMD_SUB /*sub (ix+) (dd 96)*/
//<sub><(><rp(==IX/IY)><num>LH<)><writecmdindex> - ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат (БАЗА2) пишет dd/fd

//единый токен sbc, две базы (de, 98) - можно одну базу (БАЗА2==БАЗА1-46)
_ASMSBC,
//#define ASMCMD_SBC        (ASMCMDBASE+0x0a)
//#define ASMCMD_SBCAN      ASMCMD_SBC /*sbc a,n (de)*/
//<sbc><reg(==A)><comma><num>LH<writeddcmdN> - аккумулятор неподменяемый!!! формат (БАЗА1) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_SBCARB     ASMCMD_SBC /*sbc a,reg (98+), sbc a,regx*/
//<sbc><reg(==A)><comma><rp><writeddcmd> - аккумулятор неподменяемый!!! формат (БАЗА2) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_SBCAIDX  ASMCMD_SBC /*sbc a,(ix+) (dd 9e)*/
//<sbc><reg(==A)><comma><(><rp(==IX/IY)><num>LH<)><writecmdindex> - аккумулятор неподменяемый! ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат (БАЗА2) пишет dd/fd
//#define ASMCMD_SBCHLRP    ASMCMD_SBC /*sbc hl,bc/de/hl/sp (ed 42+)*/
//<sbc><rp(==HL)><comma><rp><writesbchlrp> - формат проверяет rp (ix/iy - ошибка)

//единый токен and, две базы (e6, a0) - можно одну базу (БАЗА2==БАЗА1-46)
_ASMAND,
//#define ASMCMD_AND        (ASMCMDBASE+0x0b)
//#define ASMCMD_ANDAN      ASMCMD_AND /*and n (e6)*/
//<and><num>LH<writeddcmdN> - формат (БАЗА1) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_ANDARB     ASMCMD_AND /*and reg (a0+), and regx*/
//<and><rp><writeddcmd> - формат (БАЗА2) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_ANDAIDX  ASMCMD_AND /*and (ix+) (dd a6)*/
//<and><(><rp(==IX/IY)><num>LH<)><writecmdindex> - ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат (БАЗА2) пишет dd/fd

//единый токен xor, две базы (ee, a8) - можно одну базу (БАЗА2==БАЗА1-46)
_ASMXOR,
//#define ASMCMD_XOR        (ASMCMDBASE+0x0c)
//#define ASMCMD_XORAN      ASMCMD_XOR /*xor n (ee)*/
//<xor><num>LH<writeddcmdN> - формат (БАЗА1) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_XORARB     ASMCMD_XOR /*xor reg (a8+), xor regx*/
//<xor><rp><writeddcmd> - формат (БАЗА2) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_XORAIDX  ASMCMD_XOR /*xor (ix+) (dd ae)*/
//<xor><(><rp(==IX/IY)><num>LH<)><writecmdindex> - ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат (БАЗА2) пишет dd/fd

//единый токен or, две базы (f6, b0) - можно одну базу (БАЗА2==БАЗА1-46)
_ASMOR,
//#define ASMCMD_OR         (ASMCMDBASE+0x0d)
//#define ASMCMD_ORAN       ASMCMD_OR /*or n (f6)*/
//<or><num>LH<writeddcmdN> - формат (БАЗА1) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_ORARB      ASMCMD_OR /*or reg (b0+), or regx*/
//<or><rp><writeddcmd> - формат (БАЗА2) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_ORAIDX   ASMCMD_OR /*or (ix+) (dd b6)*/
//<or><(><rp(==IX/IY)><num>LH<)><writecmdindex> - ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат (БАЗА2) пишет dd/fd

//единый токен cp, две базы (fe, b8) - можно одну базу (БАЗА2==БАЗА1-46)
_ASMCP,
//#define ASMCMD_CP         (ASMCMDBASE+0x0e)
//#define ASMCMD_CPAN       ASMCMD_CP /*cp n (fe)*/
//<cp><num>LH<writeddcmdN> - формат (БАЗА1) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_CPARB      ASMCMD_CP /*cp reg (b8+), cp regx*/
//<cp><rp><writeddcmd> - формат (БАЗА2) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
//#define ASMCMD_CPAIDX   ASMCMD_CP /*cp (ix+) (dd be)*/
//<cp><(><rp(==IX/IY)><num>LH<)><writecmdindex> - ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат (БАЗА2) пишет dd/fd

//особый формат writeincrp, writeincm, остальные форматы как в математике (с общей базой для операций с регистром), две базы (вторая для rp?)
_ASMINC,
//#define ASMCMD_INC        (ASMCMDBASE+0x0f)
//#define ASMCMD_INCRP      ASMCMD_INC /*inc bc/de/hl/sp (03+10*rp)*/
//#define ASMCMD_INCRB      ASMCMD_INC /*inc reg (04+8*reg), в том числе (hl), inc regx*/
//#define ASMCMD_INCMHL     ASMCMD_INC /*inc (hl) (34)*/
//#define ASMCMD_INCIDX   ASMCMD_INC /*inc (ix/iy+) (dd+20*ri 34 xx)*/

//особый формат writedecrp(==writedecrp?), writedecm, остальные форматы как в математике, две базы (вторая для rp?)
_ASMDEC,
//#define ASMCMD_DEC        (ASMCMDBASE+0x10)
//#define ASMCMD_DECRP      ASMCMD_DEC /*dec bc/de/hl/sp (0b+10*rp)*/
//#define ASMCMD_DECRB      ASMCMD_DEC /*dec reg (05+8*reg), в том числе (hl), dec regx*/
//#define ASMCMD_DECMHL     ASMCMD_DEC /*dec (hl) (35)*/
//#define ASMCMD_DECIDX   ASMCMD_DEC /*dec (ix/iy+) (dd+20*ri 35 xx)*/

//токен rst
//особый формат writerst
_ASMRST,
//#define ASMCMD_RST        (ASMCMDBASE+0x11) /*rst pseudon (c7+)*/
//<rst><num>LH<writerst>

_ASMOUT,
//#define ASMCMD_OUT        (ASMCMDBASE+0x12) /*out (n),a (d3)*/ /*out (c),reg (ed 41+)*/

_ASMIN,
//#define ASMCMD_IN         (ASMCMDBASE+0x13) /*in a,(n) (db)*/ /*in reg,(c) (ed 40+)*/

_ASMPOP,
//#define ASMCMD_POP        (ASMCMDBASE+0x14) /*pop bc/de/hl/af (c1), pop ix/iy (dd e1)*/

_ASMPUSH,
//#define ASMCMD_PUSH       (ASMCMDBASE+0x15) /*push bc/de/hl/af (c5), push ix/iy (dd e5)*/

//особые форматы writecbcmd, writecbcmdm, writecbcmdindex
_ASMRLC, //rlc reg (cb 00+) //<rlc><reg><writecbcmd> - формат проверяет reg (индексные половинки - ошибка)
//rlc (hl) (cb 06) //<rlc><(><rp(==HL)><)><writecbcmdm> - hl неподменяемый!!!
//rlc (ix+d) (dd cb xx 06) //rlc >reg,(ix+d) (dd cb xx 00+) не поддерживается
//<rlc><(><rp(==IX/IY)><num>LH<)><writecbcmdindex> - ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат пишет dd/fd, cb

//далее аналогично, меняется только база
_ASMRRC,
//#define ASMCMD_RRC        (ASMCMDBASE+0x17) /*rrc reg (cb 08+), в том числе с (hl)*//*rrc (ix+d) (cb 0e)*//*rrc >reg,(ix+d) (cb 08+) не поддерживается*/

_ASMRL,
//#define ASMCMD_RL         (ASMCMDBASE+0x18) /*rl reg (cb 10+), в том числе с (hl)*//*rl (ix+d) (cb 16)*//*rl >reg,(ix+d) (cb 10+) не поддерживается*/

_ASMRR,
//#define ASMCMD_RR         (ASMCMDBASE+0x19) /*rr reg (cb 18+), в том числе с (hl)*//*rr (ix+d) (cb 1e)*//*rr >reg,(ix+d) (cb 18+) не поддерживается*/

_ASMSLA,
//#define ASMCMD_SLA        (ASMCMDBASE+0x1a) /*sla reg (cb 20+), в том числе с (hl)*//*sla (ix+d) (cb 26)*//*sla >reg,(ix+d) (cb 20+) не поддерживается*/

_ASMSRA,
//#define ASMCMD_SRA        (ASMCMDBASE+0x1b) /*sra reg (cb 28+), в том числе с (hl)*//*sra (ix+d) (cb 2e)*//*sra >reg,(ix+d) (cb 28+) не поддерживается*/

_ASMSLI,
//#define ASMCMD_SLI        (ASMCMDBASE+0x1c) /*sli reg (cb 30+), в том числе с (hl)*//*sli (ix+d) (cb 36)*//*sli >reg,(ix+d) (cb 30+) не поддерживается*/

_ASMSRL,
//#define ASMCMD_SRL        (ASMCMDBASE+0x1d) /*srl reg (cb 38+), в том числе с (hl)*//*srl (ix+d) (cb 3e)*//*srl >reg,(ix+d) (cb 38+) не поддерживается*/

//особый формат addpseudon, который проверяет pseudon (разрешено только 0..7, иначе ошибка), умножает на 8 и прибавляет к базе опкода
//<bit><num>LH<addpseudon><comma><reg><writecbcmd> - формат проверяет reg (индексные половинки - ошибка)
//<bit><num>LH<addpseudon><comma><(><rp(==HL)><)><writecbcmdm> - hl неподменяемый!!!
//<bit><num>LH<addpseudon><comma><(><rp(==IX/IY)><num>LH<)><writecbcmdindex> - ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат пишет dd/fd, cb
_ASMBIT, //bit pseudon,reg (cb 40+), в том числе с (hl) //bit pseudon,(ix+d) (cb 46+)
_ASMRES, //res pseudon,reg (cb 80+), в том числе с (hl) //res pseudon,(ix+d) (cb 86+)
_ASMSET, //set pseudon,reg (cb c0+), в том числе с (hl) //set pseudon,(ix+d) (cb c6+)
_ASMIM, //особый формат writeim, который проверяет 0..2 (иначе ошибка) и пересчитывает в 46, 56, 5e //или парсить данные вручную?

//TODO <textcmd>exx<0> - для всех специфических команд Z80 (без префикса)
_ASMRLCA,
_ASMRRCA,
_ASMRLA,
_ASMRRA,
_ASMDAA,
_ASMCPL,
_ASMSCF,
_ASMCCF,
_ASMNOP,
_ASMHALT,
_ASMDI,
_ASMEI,
_ASMEXX,

//TODO <textcmd>ldir<0> - для всех специфических команд Z80 (с префиксом)
_ASMRETN,
_ASMRETI,
_ASMLDI,
_ASMLDD,
_ASMLDIR,
_ASMLDDR,
_ASMCPI,
_ASMCPD,
_ASMCPIR,
_ASMCPDR,
_ASMINI,
_ASMIND,
_ASMINIR,
_ASMINDR,
_ASMOUTI,
_ASMOUTD,
_ASMOTIR,
_ASMOTDR,
_ASMINF,
_ASMNEG,
//66

   //форматы:
//comma==keepreg: ставится перед вторым регистром/rp в команде (можно сэкономить, если reg хранится в одном месте, а rp в другом, но для add rp,rp надо два rp)

_FMTMOVRBRB, //writemovrbrb: <ld><reg><commakeepreg><reg><writemovrbrb> - формат проверяет ошибку (?x,?y / ?y,?x / ?x/y,h/l / h/l,?x/y), пишет dd/fd и код (пересчитывает индексные половинки в h/l)
_FMTMOVAIR, //writemovrbir: <ld><regAIR><commakeepreg><regAIR><writemovrbir> - формат проверяет допустимые пары регистров - можно через textcmd?
_FMTMOVIRA, //writemovirrb: <ld><regAIR><commakeepreg><regAIR><writemovrbir> - формат проверяет допустимые пары регистров - можно через textcmd?
_FMTMOVRPRP, //writemovrprp: <ld><rp(==SP)><comma><rp><writemovrprp> - в формате вручную проверить rp (ошибка при bc,de,sp) и писать dd/fd (можно реализовать ld bc,de и т.п.)
_FMTLDRBN, //writeldrbN: <ld><rp><comma><num>LH<writeldrbN> - в формате вручную проверить rb и писать dd/fd
_FMTLDRPNN, //writeldrpNN: <ld><rp><comma><num>LH<writeldrpNN> - в формате вручную проверить rp и писать dd/fd
_FMTGETAMRP, //writegetamrp: <ld><reg(==A)><commakeepreg><(><rp><)><writegetamrp> - аккумулятор неподменяемый!!! ошибка при sp, отдельный опкод для hl
_FMTGETAMNN, //writegetamNN: <ld><reg(==A)><comma><(><num>LH<)><writegetamNN> - аккумулятор неподменяемый!!!
_FMTGETRBMHL, //writegetrbmhl: <ld><reg><commakeepreg><(><rp(==HL)><)><writegetrbmhl> - ошибка при индексных половинках reg
_FMTGETRBIDX, //writegetrbindex: <ld><reg><commakeepreg><(><rp(==IX/IY)><num>LH<)><writegetrbindex>: ix/iy неподменяемый, иначе токенизатор не определит формат! пишет dd/fd,индексные половинки==ошибка
_FMTGETRPMNN, //writegetrpmNN(==writegetamNN?): <ld><rp><comma><num>LH<writegetrpmNN> - в формате вручную проверить rp и писать dd/fd
_FMTPUTMHLRB, //writeputmhlrb: <ld><(><rp(==HL)><)><comma><reg><writeputmhlrb> - hl неподменяемый!!! индексные половинки==ошибка
_FMTPUTMHLN, //writeputmhlN: <ld><(><rp(==HL)><)><comma><num>LH<writeputmhlN> - hl неподменяемый!!!
_FMTPUTIDXRB, //writeputindexrb: <ld><(><rp(==IX/IY)><num>LH<)><commakeepreg><reg><writeputindexrb>: ix/iy неподменяемый, иначе токенизатор не определит формат! пишет dd/fd,индексные половинки==ошибка
_FMTPUTIDXN, //writeputindexN: <ld><(><rp(==IX/IY)><num>LH<)><comma><num>LH<writeputindexN> - ix/iy неподменяемый (иначе токенизатор не определит формат)! формат пишет dd/fd
_FMTPUTMRPA, //writeputmrpa: <ld><(><rp><)><commakeepreg><reg(==A)><writeputmrpa> - аккумулятор неподменяемый!!! ошибка при sp, отдельный опкод для hl
_FMTPUTMNNA, //writeputmNNa: <ld><(><num>LH<)><comma><reg(==A)><writeputmNNa> - аккумулятор неподменяемый!!!
_FMTPUTMNNRP, //writeputmNNrp(==writeputmNNa?): <ld><(><num>LH<)><comma><rp><writeputmNNrp> - в формате вручную проверить rp и писать dd/fd
_FMTALUCMDN, //writealucmdN: <sbc><reg(==A)><comma><num>LH<writealucmdN> - аккумулятор неподменяемый!!! формат (БАЗА1) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
_FMTALUCMDRB, //writealucmdrb: <sbc><reg(==A)><comma><rp><writealucmdrb> - аккумулятор неподменяемый!!! формат (БАЗА2) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
_FMTALUCMDMHL, //writealucmdmhl: <sbc><reg(==A)><comma><(><rp(==HL)><)><writealucmdmhl> - аккум.неподменяемый! hl тоже
_FMTALUCMDIDX, //writealucmdindex: <sbc><reg(==A)><comma><(><rp(==IX/IY)><num>LH<)><writealucmdindex> - аккум.неподменяемый! ix/iy тоже (иначе токенизатор не определит формат)! формат пишет dd/fd,БАЗА2
_FMTADDHLRP, //writeaddhlrp: <add><rp(==HL/IX/IY)><commakeepreg><rp><writeaddhlrp> - формат проверяет rp1, rp2 и пишет dd/fd (add ix,iy, add iy,ix, add ix/iy,hl, add hl,ix/iy - ошибка)
_FMTADCHLRP, //writeadchlrp: <adc><rp(==HL)><comma><rp><writeadchlrp> - формат проверяет rp (при hl будет ix/iy - ошибка)
_FMTSBCHLRP, //writesbchlrp: <sbc><rp(==HL)><comma><rp><writesbchlrp> - формат проверяет rp (ix/iy - ошибка)
_FMTINCRP, //writeincrp - можно через проверку кода регистра в inc (индексные половинки проверяем)
_FMTDECRP, //writedecrp - можно через проверку кода регистра в dec (индексные половинки проверяем) (или через вторую базу writedecrp==writeincrp?)
_FMTINCDECRB,
_FMTINCDECMHL,
_FMTINCDECIDX,
_FMTEXRPRP, //writeex: <ex><rp><commakeepreg><rp><writeex> - можно через textcmd?
_FMTJRDD, //writejr: <jr><cc><comma><num>LH<writejr> - пишет смещение от $ и отслеживает ошибку - cc меняет базу1 на базу2+8*cc
_FMTJPNN, //writejp: <call><cc><comma><num>LH<writejp> - cc меняет базу1 на базу2+8*cc
_FMTJPRP, //writejprp: <jp><rp><writejprp> - можно использовать скобки, они ни на что не будут влиять. Надо проверить rp и выдать ошибку - можно через textcmd?
_FMTPUSHPOPRP,
_FMTCBCMDRB, //writecbcmd: <rlc><reg><writecbcmd> - формат проверяет reg (индексные половинки - ошибка) - сама команда rlc и т.п. не может писать префикс, т.к. иногда надо dd/fd, cb
_FMTCBCMDMHL, //writecbcmdmhl: <rlc><(><rp(==HL)><)><writecbcmdmhl> - hl неподменяемый!!! - можно через <writecbcmdindex>, если проверить rp
_FMTCBCMDIDX, //writecbcmdindex: <rlc><(><rp(==IX/IY)><num>LH<)><writecbcmdindex> - ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат пишет dd/fd, cb
_FMTRST, //writerst: <rst><num>LH<writerst> - проверяет pseudon (разрешено только 0/8/16/../56, иначе ошибка) можно через textcmd?
_OPBIT, //writebit или вставка addpseudon для bit/res/set: проверяет pseudon (разрешено только 0..7, иначе ошибка) и reg (индексные половинки - ошибка) умножает на 8 и прибавляет к базе опкода
_FMTIM, //writeim: проверяет 0..2 (иначе ошибка) и выдаёт 46,56,5e - можно через textcmd? или пропускать пробел вручную и вообще без формата (или writealucmd/writecmd)
_FMTXX, //writecmd (нужно только для ret/ret cc и команд без параметров) - можно через writealucmd (в <ret> присвоить рег.), ret cc через textcmd или writejp (если в нём встроена запись числа)
_FMTOUTCRB, //writeoutcrb: out (c),reg (ed 41+) - проверяет reg (индексные половинки - ошибка)
_FMTINRBC //writeinrbc: in reg,(c) (ed 40+) - проверяет oldreg (индексные половинки - ошибка)
//44

};
