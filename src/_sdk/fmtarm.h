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

//все регистры
_RG_R0,
_RG_R1,
_RG_R2,
_RG_R3,
_RG_R4,
_RG_R5,
_RG_R6,
_RG_R7,
_RG_R8,
_RG_R9,
_RG_R10,
_RG_R11,
_RG_R12,
_RG_SP,
_RG_LR,
_RG_PC,
_RG_RPBYNAME,

_ASMNOP,

_ASMADR, //???

_ASMADCS,
_ASMADDS,
_ASMSBCS,
_ASMSUBS,
_ASMRSBS,
_ASMCMN,
_ASMCMP,
_ASMTST,
_ASMNEG, //???
_ASMMULS,

_ASMANDS,
_ASMORRS,
_ASMEORS,

_ASMASRS,
_ASMLSLS,
_ASMLSRS,
_ASMRORS,

_ASMB,
_ASMBEQ,
_ASMBNE,
_ASMBCS, //HS
_ASMBCC, //LO
_ASMBMI,
_ASMBPL,
_ASMBVS,
_ASMBVC,
_ASMBHI,
_ASMBLS,
_ASMBGE,
_ASMBLT,
_ASMBGT,
_ASMBLE,
_ASMBAL, //???
_ASMBL,
_ASMBLX,
_ASMBX,

_ASMBICS,

_ASMBKPT,

_ASMDMB,
_ASMDSB,
_ASMISB,
_ASMCPSID,
_ASMCPSIE,
_ASMSEV,
_ASMSVC,
_ASMYIELD,

_ASMLDR,
_ASMLDRB,
_ASMLDRH,
_ASMLDRSB,
_ASMLDRSH,
_ASMLDM, //???
_ASMLDMFD, //???
_ASMLDMIA, //???
_ASMSTR,
_ASMSTRB,
_ASMSTRH,
_ASMSTM, //???
_ASMSTMEA, //???
_ASMSTMIA, //???

_ASMMOV,
_ASMMOVS,
_ASMMVNS,
_ASMMRS,
_ASMMSR,
_ASMCPY, //???

_ASMPOP,
_ASMPUSH,

_ASMREV,
_ASMREV16,
_ASMREVSH,
_ASMSXTB,
_ASMSXTH,
_ASMUXTB,
_ASMUXTH,

_TOKOPENBRACE,
_TOKCLOSEBRACE,

   //форматы:
//comma==keepreg: ставится перед вторым регистром/rp в команде (можно сэкономить, если reg хранится в одном месте, а rp в другом, но для add rp,rp надо два rp)

_FMTXX,
_FMTR,
_FMTR0N,
_FMTR0R0,
_FMTR0R0SAME,
_FMTR8R8,
_FMTR0R0NX4,
_FMTR0R0R0,
_FMTR0R0N31,
_FMTR0R0N7,
_FMTR0R0ZERO,
_FMTRADDR,
_FMTBSHORTADDR,
_FMTBADDR,
_FMTBLONGADDR,
_FMTPUSHPOP,

_FMTCMD,
_FMTREEQU /**нельзя в FMT_DIR, потому что переопределение метки тоже с префиксом DIR_LABEL*/

};
