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
_FMTPUSHPOP

};
