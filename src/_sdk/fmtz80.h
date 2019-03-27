ENUM {
_TOKENDTEXT, //(раньше было нельзя, чтобы совпадал с эскейпнутыми символами)
//#define TOK_ENDTEXT  (TOKBASE+0x0a) /*постфикс любого текста, не может быть равен цифре, т.е. встречаться в числе*/

_TOKOPENSQ,
//#define TOK_OPENSQ '['
_TOKCLOSESQ,
//#define TOK_CLOSESQ ']'

_OPWRVAL,
//#define TOK_WRITEVALUE 0x41 /*после выражения*/
_TOKNUM,
//#define TOK_NUM      (TOKBASE+0x00) /*префикс числа, после него <text>digits<endtext>*/
_ERR,
//#define TOK_ERR   (TOKBASE+0x02)
_TOKENDERR,
//#define TOK_ENDERR   (TOKBASE+0x09)
_TOKLABEL,
//#define TOK_LABEL    (TOKBASE+0x01) /*префикс метки, после него <text>label.sublabel<endtext>*/

_TOKEOF,
//#define TOK_EOF 0x00 /*конец файла*/

//константные выражения:
  //op (сохраняет value и пропускает 1..2 символа):
//#define ASMOPPUSHSKIP1   (ASMOPBASE+0x00)
//#define ASMOPPUSHSKIP2   (ASMOPBASE+0x01)
_OPPUSH0,
//#define ASMOPPUSH0SKIP1  (ASMOPBASE+0x02)

//не команды ассемблера (дают обрыв слова и выражения):
//#define TOK_TAB 0x09 /*между параметрами*/
_TOKEOL,
//#define TOK_EOL 0x0a /*новая строка*/
_TOKPRIME,
//#define TOK_DBLQUOTE '\'' /*префикс и постфикс единичного символа*/
_OPWRSTR,
//#define TOK_WRITESTRING 0x0c /*перед строкой*/
_TOKCR, //NU

_TOKENDCOMMENT,
//#define TOK_ENDCOMMENT (TOKBASE+0x0b) /*токен, который не встречается в текстах, чтобы не ходить по text-endtext*/

  //opfmt:
_OPADD,
//#define OP_ADD     (OPBASE+0x00)
_OPSUB,
//#define OP_SUB     (OPBASE+0x01)
_OPMUL,
//#define OP_MUL     (OPBASE+0x02)
_OPDIV,
//#define OP_DIV     (OPBASE+0x03)
_OPAND,
//#define OP_AND     (OPBASE+0x04)
_OPOR,
//#define OP_OR      (OPBASE+0x05)
_OPXOR,
//#define OP_XOR     (OPBASE+0x06)
_OPSHL,
//#define OP_SHL     (OPBASE+0x07)
_OPSHR,
//#define OP_SHR     (OPBASE+0x08)
_OPEQ,
//#define OP_EQ      (OPBASE+0x09)
_OPNOTEQ,
//#define OP_NOTEQ   (OPBASE+0x0a)
_OPLESS,
//#define OP_LESS    (OPBASE+0x0b)
_OPLESSEQ,
//#define OP_LESSEQ  (OPBASE+0x0c)
_OPMORE,
//#define OP_MORE    (OPBASE+0x0d)
_OPMOREEQ,
//#define OP_MOREEQ  (OPBASE+0x0e)
_OPINV,
//#define OP_INV     (OPBASE+0x0f)
_OPPEEK,
//#define OP_PEEK    (OPBASE+0x10)

//не команды ассемблера (дают обрыв слова и выражения):
_TOKSPC, //NU
//#define TOK_SPC ' ' /*между параметрами, надо набор пробелов разной ширины*/
_TOKEXCL, //used as text
_TOKDBLQUOTESYM,
//#define TOK_TEXT     '\"' /*префикс любого текста*/
_TOKDIRECT, //NU?
//#define TOK_DIRECT '#' /*перед непосредственным операндом*/
_TOKDOLLAR,
//#define TOK_DOLLAR '$'
_TOKPERCENT, //NU
_TOKAND, //used as text
_TOKPRIMESYM,
//#define TOK_DBLQUOTE '\'' /*префикс и постфикс единичного символа*/
_TOKOPEN,
//#define TOK_OPEN '('
_TOKCLOSE,
//#define TOK_CLOSE ')'
_TOKSTAR, //used as text
_TOKPLUS, //used as text
_TOKCOMMA,
//#define TOK_COMMA ',' /*между параметрами*/
_TOKMINUS, //used as text
_TOKDOT, //NU
_TOKSLASH, //used as text
_TOKSPC0,
_TOKSPC1,
_TOKSPC2,
_TOKSPC3,
_TOKSPC4,
_TOKSPC5,
_TOKSPC6,
_TOKSPC7,
_TOKSPC8,
//#define TOK_NOTHING '0' /*неотображаемый токен*/
//#define TOK_SPCBASE '0' /*между параметрами, надо набор пробелов разной ширины*/
_TOKSPC9, //NU
_TOKCOLON,
//#define TOK_COLON ':' /*:*/ /*ничего не делает ни после метки, ни между командами*/
_TOKCOMMENT,
//#define TOK_COMMENT  0x0b /*(используется и для экранирования кавычек) комментарий без текста, после него блоки <text>text<endtext><space><text>text<endtext>... <endcoment>*/
//#define TOK_COMMENTSYM  ';' /*комментарий без текста, после него <comment> и блоки <text>text<endtext><space><text>text<endtext>... <endcoment>*/
_TOKLESS, //used as text
_TOKEQUAL, //used as text
//#define TOK_REEQU '='
_TOKMORE, //used as text
_TOKTEXT,
//#define TOK_TEXT     '\"' /*префикс любого текста*/

//команды ассемблера:
//для них 12 уникальных форматов
_CMDREADSTATE,
//#define _CMDREADSTATE  (DIRBASE+0x00) /*для post labels*/
//#define DIR_MAIN      (DIRBASE+0x00) /*main "filename" - разбирать вручную?*/
_CMDLABEL,
//#define _CMDLABEL      (DIRBASE+0x01) /*определение метки через $+curdisp*/
//#define DIR_REEQU     (DIRBASE+0x02) /*определение метки через = (equ не нужно?) - надо формат writereequ*/
_CMDORG,
//#define _CMDORG        (DIRBASE+0x03) /*org nn - надо формат writeorg, разбирать вручную не получится из-за выражения*/
_CMDALIGN,
//#define _CMDALIGN      (DIRBASE+0x04) /*align nn - надо формат writealign, разбирать вручную не получится из-за выражения*/
_CMDPAGE,
//#define _CMDPAGE       (DIRBASE+0x05) /*page n - надо формат writepage, разбирать вручную не получится из-за выражения*/
_CMDIF,
//#define _CMDIF         (DIRBASE+0x06) /*if nn - надо формат writeif, разбирать вручную не получится из-за выражения*/
_CMDELSE,
//#define _CMDELSE       (DIRBASE+0x07) /*else*/
_CMDENDIF,
//#define _CMDENDIF      (DIRBASE+0x08) /*endif*/
_CMDDUP,
//#define _CMDDUP        (DIRBASE+0x09) /*dup nn - надо формат writedup, разбирать вручную не получится из-за выражения*/
_CMDEDUP,
//#define _CMDEDUP       (DIRBASE+0x0a) /*edup*/
_CMDMACRO,
//#define _CMDMACRO      (DIRBASE+0x0b) /*macro name - разбирать вручную?*/
_CMDENDM,
//#define _CMDENDM       (DIRBASE+0x0c) /*endm*/
_CMDEXPORT,//_CMDUSEMACRO,
//#define _CMDUSEMACRO   (DIRBASE+0x0d) /*usemacro name ... - разбирать вручную?*/
_CMDLOCAL,
//#define _CMDLOCAL      (DIRBASE+0x0e) /*local name - разбирать вручную?*/
_CMDENDL,
//#define _CMDENDL       (DIRBASE+0x0f) /*endl*/
_CMDDISP,
//#define _CMDDISP       (DIRBASE+0x10) /*disp nn - надо формат writedisp*/
_CMDENT,
//#define _CMDENT        (DIRBASE+0x11) /*ent*/
_CMDINCLUDE,
//#define _CMDINCLUDE    (DIRBASE+0x12) /*include "filename" - разбирать вручную?*/
_CMDINCBIN,
//#define _CMDINCBIN     (DIRBASE+0x13) /*incbin "filename" - разбирать вручную?*/
_CMDDB,
//#define _CMDDB         (DIRBASE+0x14) /*db ..., вместо defb - надо после каждого выражения формат writeN, разбирать вручную не получится из-за выражения*/
_CMDDW,
//#define _CMDDW         (DIRBASE+0x15) /*dw ..., вместо defw - надо после каждого выражения формат writeNN*/
_CMDDL,
//#define _CMDDL         (DIRBASE+0x16) /*dl ..., вместо defl - надо после каждого выражения формат writeNNNN*/
_CMDDS,
//#define _CMDDS         (DIRBASE+0x17) /*ds ..., вместо defs - надо формат writeds*/
_CMDDISPLAY,
//#define _CMDDISPLAY    (DIRBASE+0x18) /*display nn - форматы displaynum, displaystring - разбирать вручную не получится из-за выражений*/
_CMDREPEAT,
//#define _CMDREPEAT     (DIRBASE+0x19) /*repeat*/
_CMDUNTIL,
//#define _CMDUNTIL      (DIRBASE+0x1a) /*until nn - надо формат writeuntil*/
_CMDSTRUCT,
//#define _CMDSTRUCT     (DIRBASE+0x1b) /*struct name - разбирать вручную?*/
_CMDENDSTRUCT,
//#define _CMDENDSTRUCT  (DIRBASE+0x1c) /*endstruct*/
//max 0x1c

_TOKPIPE, //лучше не сдвигать!
_TOKCARON, //лучше не сдвигать!
_TOKTILDE, //лучше не сдвигать!

//// начиная отсюда зависит от таргета

//условия:
_ASMNZ,
//#define ASMCC_NZ         (ASMCCBASE+0x00)
_ASMZ,
//#define ASMCC_Z          (ASMCCBASE+0x01)
_ASMNC,
//#define ASMCC_NC         (ASMCCBASE+0x02)
_ASMC,
//#define ASMCC_C          (ASMCCBASE+0x03)
_ASMPO,
//#define ASMCC_PO         (ASMCCBASE+0x04)
_ASMPE,
//#define ASMCC_PE         (ASMCCBASE+0x05)
_ASMP,
//#define ASMCC_P          (ASMCCBASE+0x06)
_ASMM,
//#define ASMCC_M          (ASMCCBASE+0x07)

//b,c,d,e,h,l,a,hx,lx,hy,lx - 11 регистров в первой группе подмена (можно ускорить только ld reg,reg, если запретить подменять индексные половинки)
_RG_B,
//#define ASMREG_B          (ASMREGBASE+0x00)
_RG_C,
//#define ASMREG_C          (ASMREGBASE+0x01)
_RG_D,
//#define ASMREG_D          (ASMREGBASE+0x02)
_RG_E,
//#define ASMREG_E          (ASMREGBASE+0x03)
_RG_H,
//#define ASMREG_H          (ASMREGBASE+0x04)
_RG_L,
//#define ASMREG_L          (ASMREGBASE+0x05)
_RG_A,
//#define ASMREG_A          (ASMREGBASE+0x06)
_RG_HX,
//#define ASMREG_HX         (ASMREGBASE+0x07)
_RG_LX,
//#define ASMREG_LX         (ASMREGBASE+0x08)
_RG_HY,
//#define ASMREG_HY         (ASMREGBASE+0x09)
_RG_LY,
//#define ASMREG_LY         (ASMREGBASE+0x0a)
//i,r - 2 прочих регистра (можно через getregbyname?)
_RG_I,
//#define ASMREG_I          (ASMREGBASE+0x0b)
_RG_R,
//#define ASMREG_R          (ASMREGBASE+0x0c)
//rbbyname
_RG_RBBYNAME,
//#define ASMREG_RBBYNAME   (ASMREGBASE+0x0d)
//bc,de,hl,sp,ix,iy - 6 регистров во второй группе подмена
_RG_BC,
//#define ASMREG_BC         (ASMREGBASE+0x0e)
_RG_DE,
//#define ASMREG_DE         (ASMREGBASE+0x0f)
_RG_HL,
//#define ASMREG_HL         (ASMREGBASE+0x10)
_RG_SP,
//#define ASMREG_SP         (ASMREGBASE+0x11)
_RG_IX,
//#define ASMREG_IX         (ASMREGBASE+0x12)
_RG_IY,
//#define ASMREG_IY         (ASMREGBASE+0x13)
//af,af' - 2 прочих rp (или <af><'>, причём <'> ничего не будет делать - можно через text)
_RG_AF,
//#define ASMREG_AF         (ASMREGBASE+0x14)
//rpbyname
_RG_RPBYNAME,
//#define ASMREG_RPBYNAME   (ASMREGBASE+0x15)
//max 0x15


//<ex><rp><commakeepreg><rp><writeex>
_ASMEX,
//#define ASMCMD_EX         (ASMCMDBASE+0x00)
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

//токен rlc, база 00
//особые форматы writecbcmd, writecbcmdm, writecbcmdindex
_ASMRLC,
//#define ASMCMD_RLC        (ASMCMDBASE+0x16)
//#define ASMCMD_RLCRB      ASMCMD_RLC /*rlc reg (cb 00+)*/
//<rlc><reg><writecbcmd> - формат проверяет reg (индексные половинки - ошибка)
//#define ASMCMD_RLCMHL     ASMCMD_RLC /*rlc (hl) (cb 06)*/
//<rlc><(><rp(==HL)><)><writecbcmdm> - hl неподменяемый!!!
//#define ASMCMD_RLCIDX   ASMCMD_RLC /*rlc (ix+d) (dd cb xx 06)*//*rlc >reg,(ix+d) (dd cb xx 00+) не поддерживается*/
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

//токен bit, база 40
//особый формат addpseudon, который проверяет pseudon (разрешено только 0..7, иначе ошибка), умножает на 8 и прибавляет к базе опкода
_ASMBIT,
//#define ASMCMD_BIT        (ASMCMDBASE+0x1e) /*bit pseudon,reg (cb 40+), в том числе с (hl)*//*bit pseudon,(ix+d) (cb 46+)*/
//<bit><num>LH<addpseudon><comma><reg><writecbcmd> - формат проверяет reg (индексные половинки - ошибка)
//<bit><num>LH<addpseudon><comma><(><rp(==HL)><)><writecbcmdm> - hl неподменяемый!!!
//<bit><num>LH<addpseudon><comma><(><rp(==IX/IY)><num>LH<)><writecbcmdindex> - ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат пишет dd/fd, cb

//далее аналогично, меняется только база
_ASMRES,
//#define ASMCMD_RES        (ASMCMDBASE+0x1f) /*res pseudon,reg (cb 80+), в том числе с (hl)*//*res pseudon,(ix+d) (cb 86+)*/

_ASMSET,
//#define ASMCMD_SET        (ASMCMDBASE+0x20) /*set pseudon,reg (cb c0+), в том числе с (hl)*//*set pseudon,(ix+d) (cb c6+)*/

//тут нужен особый формат writeim, который проверяет 0..2 (иначе ошибка) и пересчитывает в 46, 56, 5e
//или парсить данные вручную?
_ASMIM,
//#define ASMCMD_IM         (ASMCMDBASE+0x21) /*im pseudon (ed 46+)*/

//<textcmd>exx<0> - для всех специфических команд Z80 (без префикса)
_ASMRLCA,
//#define ASMCMD_RLCA       (ASMCMDBASE+0x22) /*rlca (07)*/
_ASMRRCA,
//#define ASMCMD_RRCA       (ASMCMDBASE+0x23) /*rrca (0f)*/
_ASMRLA,
//#define ASMCMD_RLA        (ASMCMDBASE+0x24) /*rla (17)*/
_ASMRRA,
//#define ASMCMD_RRA        (ASMCMDBASE+0x25) /*rra (1f)*/
_ASMDAA,
//#define ASMCMD_DAA        (ASMCMDBASE+0x26) /*daa (27)*/
_ASMCPL,
//#define ASMCMD_CPL        (ASMCMDBASE+0x27) /*cpl (2f)*/
_ASMSCF,
//#define ASMCMD_SCF        (ASMCMDBASE+0x28) /*scf (37)*/
_ASMCCF,
//#define ASMCMD_CCF        (ASMCMDBASE+0x29) /*ccf (3f)*/
_ASMNOP,
//#define ASMCMD_NOP        (ASMCMDBASE+0x2a) /*nop (00)*/
_ASMHALT,
//#define ASMCMD_HALT       (ASMCMDBASE+0x2b) /*halt (76)*/
_ASMDI,
//#define ASMCMD_DI         (ASMCMDBASE+0x2c) /*di (f3)*/
_ASMEI,
//#define ASMCMD_EI         (ASMCMDBASE+0x2d) /*ei (fb)*/
_ASMEXX,
//#define ASMCMD_EXX        (ASMCMDBASE+0x2e) /*exx (d9)*/

//<textcmd>ldir<0> - для всех специфических команд Z80 (с префиксом)
_ASMRETN,
//#define ASMCMD_RETN       (ASMCMDBASE+0x2f) /*retn (ed 45)*/
_ASMRETI,
//#define ASMCMD_RETI       (ASMCMDBASE+0x30) /*reti (ed 4d)*/
_ASMLDI,
//#define ASMCMD_LDI        (ASMCMDBASE+0x31) /*ldi (ed a0)*/
_ASMLDD,
//#define ASMCMD_LDD        (ASMCMDBASE+0x32) /*ldd (ed a8)*/
_ASMLDIR,
//#define ASMCMD_LDIR       (ASMCMDBASE+0x33) /*ldir (ed b0)*/
_ASMLDDR,
//#define ASMCMD_LDDR       (ASMCMDBASE+0x34) /*lddr (ed b8)*/
_ASMCPI,
//#define ASMCMD_CPI        (ASMCMDBASE+0x35) /*cpi (ed a1)*/
_ASMCPD,
//#define ASMCMD_CPD        (ASMCMDBASE+0x36) /*cpd (ed a9)*/
_ASMCPIR,
//#define ASMCMD_CPIR       (ASMCMDBASE+0x37) /*cpir (ed b1)*/
_ASMCPDR,
//#define ASMCMD_CPDR       (ASMCMDBASE+0x38) /*cpdr (ed b9)*/
_ASMINI,
//#define ASMCMD_INI        (ASMCMDBASE+0x39) /*ini (ed a2)*/
_ASMIND,
//#define ASMCMD_IND        (ASMCMDBASE+0x3a) /*ind (ed aa)*/
_ASMINIR,
//#define ASMCMD_INIR       (ASMCMDBASE+0x3b) /*inir (ed b2)*/
_ASMINDR,
//#define ASMCMD_INDR       (ASMCMDBASE+0x3c) /*indr (ed ba)*/
_ASMOUTI,
//#define ASMCMD_OUTI       (ASMCMDBASE+0x3d) /*outi (ed a3)*/
_ASMOUTD,
//#define ASMCMD_OUTD       (ASMCMDBASE+0x3e) /*outd (ed ab)*/
_ASMOTIR,
//#define ASMCMD_OTIR       (ASMCMDBASE+0x3f) /*otir (ed b3)*/
_ASMOTDR,
//#define ASMCMD_OTDR       (ASMCMDBASE+0x40) /*otdr (ed bb)*/
_ASMINF,
//#define ASMCMD_INF        (ASMCMDBASE+0x41) /*inf (ed 70)*/
_ASMNEG,
//max 0x42

   //форматы:
//comma==keepreg: ставится перед вторым регистром/rp в команде (можно сэкономить, если reg хранится в одном месте, а rp в другом, но для add rp,rp надо два rp)

//writemovrbrb: <ld><reg><commakeepreg><reg><writemovrbrb> - формат проверяет ошибку (?x,?y / ?y,?x / ?x/y,h/l / h/l,?x/y), пишет dd/fd и код (пересчитывает индексные половинки в h/l)
_FMTMOVRBRB,
//#define FMT_MOVRBRB    (FMTBASE+0x00)
 //writemovrbir: <ld><regAIR><commakeepreg><regAIR><writemovrbir> - формат проверяет допустимые пары регистров - можно через textcmd?
_FMTMOVAIR,
//#define FMT_MOVAIR     (FMTBASE+0x01)
 //writemovrbir: <ld><regAIR><commakeepreg><regAIR><writemovrbir> - формат проверяет допустимые пары регистров - можно через textcmd?
_FMTMOVIRA,
//#define FMT_MOVIRA     (FMTBASE+0x02)
//writemovrprp: <ld><rp(==SP)><comma><rp><writemovrprp> - в формате вручную проверить rp (ошибка при bc,de,sp) и писать dd/fd (можно реализовать ld bc,de и т.п.)
_FMTMOVRPRP,
//#define FMT_MOVRPRP    (FMTBASE+0x03)
//writeldrbN: <ld><rp><comma><num>LH<writeldrbN> - в формате вручную проверить rb и писать dd/fd
_FMTLDRBN,
//#define FMT_LDRBN      (FMTBASE+0x04)
//writeldrpNN: <ld><rp><comma><num>LH<writeldrpNN> - в формате вручную проверить rp и писать dd/fd
_FMTLDRPNN,
//#define FMT_LDRPNN     (FMTBASE+0x05)
//writegetamrp: <ld><reg(==A)><commakeepreg><(><rp><)><writegetamrp> - аккумулятор неподменяемый!!! ошибка при sp, отдельный опкод для hl
_FMTGETAMRP,
//#define FMT_GETAMRP    (FMTBASE+0x06)
//writegetamNN: <ld><reg(==A)><comma><(><num>LH<)><writegetamNN> - аккумулятор неподменяемый!!!
_FMTGETAMNN,
//#define FMT_GETAMNN    (FMTBASE+0x07)
//writegetrbmhl: <ld><reg><commakeepreg><(><rp(==HL)><)><writegetrbmhl> - ошибка при индексных половинках reg
_FMTGETRBMHL,
//#define FMT_GETRBMHL   (FMTBASE+0x08)
//writegetrbindex: <ld><reg><commakeepreg><(><rp(==IX/IY)><num>LH<)><writegetrbindex>: ix/iy неподменяемый, иначе токенизатор не определит формат! пишет dd/fd,индексные половинки==ошибка
_FMTGETRBIDX,
//#define FMT_GETRBIDX (FMTBASE+0x09)
  //writegetrpmNN(==writegetamNN?): <ld><rp><comma><num>LH<writegetrpmNN> - в формате вручную проверить rp и писать dd/fd
_FMTGETRPMNN,
//#define FMT_GETRPMNN   (FMTBASE+0x0a)
//writeputmhlrb: <ld><(><rp(==HL)><)><comma><reg><writeputmhlrb> - hl неподменяемый!!! индексные половинки==ошибка
_FMTPUTMHLRB,
//#define FMT_PUTMHLRB   (FMTBASE+0x0b)
//writeputmhlN: <ld><(><rp(==HL)><)><comma><num>LH<writeputmhlN> - hl неподменяемый!!!
_FMTPUTMHLN,
//#define FMT_PUTMHLN    (FMTBASE+0x0c)
//writeputindexrb: <ld><(><rp(==IX/IY)><num>LH<)><commakeepreg><reg><writeputindexrb>: ix/iy неподменяемый, иначе токенизатор не определит формат! пишет dd/fd,индексные половинки==ошибка
_FMTPUTIDXRB,
//#define FMT_PUTIDXRB (FMTBASE+0x0d)
//writeputindexN: <ld><(><rp(==IX/IY)><num>LH<)><comma><num>LH<writeputindexN> - ix/iy неподменяемый (иначе токенизатор не определит формат)! формат пишет dd/fd
_FMTPUTIDXN,
//#define FMT_PUTIDXN  (FMTBASE+0x0e)
//writeputmrpa: <ld><(><rp><)><commakeepreg><reg(==A)><writeputmrpa> - аккумулятор неподменяемый!!! ошибка при sp, отдельный опкод для hl
_FMTPUTMRPA,
//#define FMT_PUTMRPA    (FMTBASE+0x0f)
//writeputmNNa: <ld><(><num>LH<)><comma><reg(==A)><writeputmNNa> - аккумулятор неподменяемый!!!
_FMTPUTMNNA,
//#define FMT_PUTMNNA    (FMTBASE+0x10)
  //writeputmNNrp(==writeputmNNa?): <ld><(><num>LH<)><comma><rp><writeputmNNrp> - в формате вручную проверить rp и писать dd/fd
_FMTPUTMNNRP,
//#define FMT_PUTMNNRP   (FMTBASE+0x11)

//writealucmdN: <sbc><reg(==A)><comma><num>LH<writealucmdN> - аккумулятор неподменяемый!!! формат (БАЗА1) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
_FMTALUCMDN,
//#define FMT_ALUCMDN    (FMTBASE+0x12)
//writealucmdrb: <sbc><reg(==A)><comma><rp><writealucmdrb> - аккумулятор неподменяемый!!! формат (БАЗА2) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
_FMTALUCMDRB,
//#define FMT_ALUCMDRB   (FMTBASE+0x13)
//writealucmdmhl: <sbc><reg(==A)><comma><(><rp(==HL)><)><writealucmdmhl> - аккум.неподменяемый! hl тоже
_FMTALUCMDMHL,
//#define FMT_ALUCMDMHL  (FMTBASE+0x14)
//writealucmdindex: <sbc><reg(==A)><comma><(><rp(==IX/IY)><num>LH<)><writealucmdindex> - аккум.неподменяемый! ix/iy тоже (иначе токенизатор не определит формат)! формат пишет dd/fd,БАЗА2
_FMTALUCMDIDX,
//#define FMT_ALUCMDIDX (FMTBASE+0x15) /*ад перфекциониста*/
//writeaddhlrp: <add><rp(==HL/IX/IY)><commakeepreg><rp><writeaddhlrp> - формат проверяет rp1, rp2 и пишет dd/fd (add ix,iy, add iy,ix, add ix/iy,hl, add hl,ix/iy - ошибка)
_FMTADDHLRP,
//#define FMT_ADDHLRP    (FMTBASE+0x16)
//writeadchlrp: <adc><rp(==HL)><comma><rp><writeadchlrp> - формат проверяет rp (при hl ix/iy - ошибка, )
_FMTADCHLRP,
//#define FMT_ADCHLRP    (FMTBASE+0x17)
//writesbchlrp: <sbc><rp(==HL)><comma><rp><writesbchlrp> - формат проверяет rp (ix/iy - ошибка)
_FMTSBCHLRP,
//#define FMT_SBCHLRP    (FMTBASE+0x18)
 //writeincrp - можно через проверку кода регистра в inc (индексные половинки проверяем)
_FMTINCRP,
//#define FMT_INCRP      (FMTBASE+0x19)
 //writeincmhl - формат должен отличаться от writeincrp, чтобы не пересеклось с dec hl - можно через <writecmdindex>, если проверить rp
//_FMTINCMHL,
//#define FMT_INCMHL     FMT_ALUCMDMHL/*(FMTBASE+0x1e)*/
 //writedecrp - можно через проверку кода регистра в dec (индексные половинки проверяем) (или через вторую базу writedecrp==writeincrp?)
_FMTDECRP,
//#define FMT_DECRP      (FMTBASE+0x1a)
 //writedecmhl(==writeincmhl?) - формат должен отличаться от writedecrp, чтобы не пересеклось с dec hl - можно через <writecmdindex>, если проверить rp
//_FMTDECMHL,
//#define FMT_DECMHL     FMT_ALUCMDMHL/*(FMTBASE+0x20)*/
_FMTINCDECRB,
_FMTINCDECMHL,
_FMTINCDECIDX,

 //writeex: <ex><rp><commakeepreg><rp><writeex> - можно через textcmd?
_FMTEXRPRP,
//#define FMT_EXRPRP     (FMTBASE+0x1b)
//writejr: <jr><cc><comma><num>LH<writejr> - пишет смещение от $ и отслеживает ошибку - cc меняет базу1 на базу2+8*cc
_FMTJRDD,
//#define FMT_JRDD       (FMTBASE+0x1c)
//writejp: <call><cc><comma><num>LH<writejp> - cc меняет базу1 на базу2+8*cc
_FMTJPNN,
//#define FMT_JPNN       (FMTBASE+0x1d)
 //writejprp: <jp><rp><writejprp> - можно использовать скобки, они ни на что не будут влиять. Надо проверить rp и выдать ошибку - можно через textcmd?
_FMTJPRP,
//#define FMT_JPRP       (FMTBASE+0x1e)
//writepushrp
_FMTPUSHPOPRP,
//#define FMT_PUSHRP     (FMTBASE+0x1f)
 //writepoprp(==writepushrp?)
//_FMTPOPRP,
//#define FMT_POPRP      FMT_PUSHRP
//writecbcmd: <rlc><reg><writecbcmd> - формат проверяет reg (индексные половинки - ошибка) - сама команда rlc и т.п. не может писать префикс, т.к. иногда надо dd/fd, cb
_FMTCBCMDRB,
//#define FMT_CBCMDRB    (FMTBASE+0x20)
 //writecbcmdmhl: <rlc><(><rp(==HL)><)><writecbcmdmhl> - hl неподменяемый!!! - можно через <writecbcmdindex>, если проверить rp
_FMTCBCMDMHL,
//#define FMT_CBCMDMHL   (FMTBASE+0x21)
//writecbcmdindex: <rlc><(><rp(==IX/IY)><num>LH<)><writecbcmdindex> - ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат пишет dd/fd, cb
_FMTCBCMDIDX,
//#define FMT_CBCMDIDX (FMTBASE+0x22)
 //writerst: <rst><num>LH<writerst> - проверяет pseudon (разрешено только 0/8/16/../56, иначе ошибка) можно через textcmd?
_FMTRST,
//#define FMT_RST        (FMTBASE+0x23)
//writebit или вставка addpseudon для bit/res/set: проверяет pseudon (разрешено только 0..7, иначе ошибка) и reg (индексные половинки - ошибка) умножает на 8 и прибавляет к базе опкода
//#define FMT_BIT        (FMTBASE+0x24)
//для bit/res/set: проверяет pseudon (разрешено только 0..7, иначе ошибка), умножает на 8 и прибавляет к базе опкода
_OPBIT,
//#define TOK_PSEUDON  (FMTBASE+0x24)
  //writeim: проверяет 0..2 (иначе ошибка) и выдаёт 46,56,5e - можно через textcmd? или пропускать пробел вручную и вообще без формата (или writealucmd/writecmd)
_FMTIM,
//#define FMT_IM         (FMTBASE+0x25)
  //writecmd (нужно только для ret/ret cc и команд без параметров) - можно через writealucmd (в <ret> присвоить рег.), ret cc через textcmd или writejp (если в нём встроена запись числа)
_FMTXX,
//#define FMT_XX        (FMTBASE+0x26)
  //writeedcmd (нужно только для команд без параметров) - можно через writeim или writecmd (ed в самой команде)
//#define FMT_EDXX      (FMTBASE+0x27)
//writeoutcrb: out (c),reg (ed 41+) - проверяет reg (индексные половинки - ошибка)
_FMTOUTCRB,
//#define FMT_OUTCRB     (FMTBASE+0x27)
//writeoutcrb: in reg,(c) (ed 40+) - проверяет oldreg (индексные половинки - ошибка)
_FMTINRBC,
//#define FMT_INRBC      (FMTBASE+0x28)

_FMTCMD, //в общей части
//#define FMT_DIR        (FMTBASE+0x29)
_FMTREEQU //в общей части
//#define FMT_REEQU      (FMTBASE+0x2a) /*нельзя в FMT_DIR, потому что переопределение метки тоже с префиксом DIR_LABEL*/
//max 0x2a

};
