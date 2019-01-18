//// imported
PROC tokaddlbl FORWARD(PCHAR txt, PBYTE proc, BYTE data);

EXTERN PCHAR _tword; //текущее слово
EXTERN UINT _lentword;

EXTERN BYTE _temppar;

PROC asmtoken FORWARD(BYTE token);

PROC tokorg FORWARD();
PROC tokalign FORWARD();
PROC tokpage FORWARD();
PROC tokif FORWARD();
PROC tokelse FORWARD();
PROC tokendif FORWARD();
PROC tokdup FORWARD();
PROC tokedup FORWARD();
PROC tokmacro FORWARD();
PROC tokendm FORWARD();
//PROC tokusemacro FORWARD();
PROC tokexport FORWARD();
PROC toklocal FORWARD();
PROC tokendl FORWARD();
PROC tokdisp FORWARD();
PROC tokent FORWARD();
PROC tokinclude FORWARD();
PROC tokincbin FORWARD();
PROC tokdb FORWARD();
PROC tokdw FORWARD();
PROC tokdl FORWARD();
PROC tokds FORWARD();
PROC tokdisplay FORWARD();
PROC tokrepeat FORWARD();
PROC tokuntil FORWARD();
PROC tokstruct FORWARD();
PROC tokendstruct FORWARD();
PROC tokcomment FORWARD();
PROC tokcolon FORWARD();

EXTERN CHAR _c1small;
EXTERN CHAR _c2small;
EXTERN BOOL _asmwaseof;
EXTERN UINT _asmwaseols;

PROC tokeol FORWARD();
PROC asmrdword_tokspc FORWARD(); //токенизирует пробелы после прошлой команды и читает новую
PROC toktext FORWARD(); //генерирует <text>text<endtext>
PROC tokerr FORWARD(BYTE token);
PROC tokerrcmd FORWARD();
FUNC BOOL matchcomma FORWARD();
FUNC BOOL matchprime FORWARD();
FUNC BOOL matchquote FORWARD();
FUNC BOOL matchreequ FORWARD();
FUNC BOOL matchopen FORWARD();
FUNC BOOL matchclose FORWARD();
FUNC BOOL tokexpr FORWARD(); //должен читать, но не съедать символ конца выражения (скобка, запятая, конец строки)
FUNC BOOL tokexpr_close FORWARD(); //после него ничего больше нельзя проверять, т.к. курсор мог сдвинуться
PROC asm_direct_expr_close_token FORWARD(BYTE token);

////

FUNC BOOL matchopenbrace()
{
VAR BOOL ok;
  IF (*(PCHAR)_tword=='{') {asmtoken(+_TOKOPENBRACE); asmrdword_tokspc(); ok = +TRUE;
  }ELSE ok = +FALSE;
RETURN ok;
}

FUNC BOOL matchclosebrace()
{
VAR BOOL ok;
  IF (*(PCHAR)_tword=='}') {asmtoken(+_TOKCLOSEBRACE); asmrdword_tokspc(); ok = +TRUE;
  }ELSE ok = +FALSE;
RETURN ok;
}

FUNC BOOL matchpc()
{
VAR BOOL ok;
  IF ((_c1small=='p')&&(_c2small=='c')&&(_lentword==2)) {
    asmtoken(+_RG_PC); asmrdword_tokspc(); ok = +TRUE;
  }ELSE ok = +FALSE;
  RETURN ok;
}

FUNC BOOL matchlr()
{
VAR BOOL ok;
  IF ((_c1small=='l')&&(_c2small=='r')&&(_lentword==2)) {
    asmtoken(+_RG_LR); asmrdword_tokspc(); ok = +TRUE;
  }ELSE ok = +FALSE;
  RETURN ok;
}

FUNC BOOL matchsp()
{
VAR BOOL ok;
  IF ((_c1small=='s')&&(_c2small=='p')&&(_lentword==2)) {
    asmtoken(+_RG_SP); asmrdword_tokspc(); ok = +TRUE;
  }ELSE ok = +FALSE;
  RETURN ok;
}

FUNC BOOL matchrp()
{
VAR BOOL ok;
VAR BYTE n;
  ok = +FALSE;
  IF (_c1small=='r') {
      IF ((_c2small=='p') && (_lentword==2)) { //rp метка
        asmrdword_tokspc();
        asmtoken(+_RG_RPBYNAME);
        toktext(); //генерирует <text>text<endtext>
        asmrdword_tokspc();
        ok = +TRUE;
      }ELSE { //r0..r12, rp
        IF (((BYTE)_c2small>=(BYTE)'0') && ((BYTE)_c2small<=(BYTE)'9')) {
          n = (BYTE)_c2small - 0x30;
          IF (_lentword==2) { //r0..r9
            goto rnok;
          }ELSE IF ((_lentword==3) && (n==0x01) && ((BYTE)_tword[2]>=(BYTE)'0') && ((BYTE)_tword[2]<=(BYTE)'2')) {
            n = 0x0a + (BYTE)_tword[2] - 0x30;
            rnok:
            asmtoken(+_RG_R0 + n); asmrdword_tokspc(); ok = +TRUE;
          };
        };
      };
  }ELSE IF (_lentword==2) {
    IF       ((_c1small=='s')&&(_c2small=='p')) {asmtoken(+_RG_SP); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='l')&&(_c2small=='r')) {asmtoken(+_RG_LR); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='p')&&(_c2small=='c')) {asmtoken(+_RG_PC); asmrdword_tokspc(); ok = +TRUE;
    };
  };
RETURN ok;
}

////////////// машиннозависимые группы сравнений для парсинга частых параметров

PROC asm_rp_close_token(BYTE mrtoken)
{
  IF (matchrp()) {
    IF (matchclose()) {asmtoken(mrtoken);
    }ELSE tokerr(+_ERRCLOSE); //no closing bracket
  }ELSE tokerr(+_ERRREG); //wrong register
}

///////////////////////////////////////////////////

PROC tokmov()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (matchrp()) {
    IF (matchcomma()) {
      IF (matchrp()) {
        asmtoken(+_FMTR8R8);
//      }ELSE IF (tokexpr()) {
//        asmtoken(+_FMTRN);
      }ELSE tokerr(+_ERREXPR); //wrong expr
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE tokerr(+_ERRREG); //wrong register
}

PROC tokmovs()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (matchrp()) {
    IF (matchcomma()) {
      IF (matchrp()) {
        asmtoken(+_FMTR0R0);
      }ELSE IF (tokexpr()) {
        asmtoken(+_FMTR0N);
      }ELSE tokerr(+_ERREXPR); //wrong expr
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE tokerr(+_ERRREG); //wrong register
}

PROC tokmvns()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (matchrp()) {
    IF (matchcomma()) {
      IF (matchrp()) {
        asmtoken(+_FMTR0R0);
      }ELSE IF (tokexpr()) {
        asmtoken(+_FMTR0N);
      }ELSE tokerr(+_ERREXPR); //wrong expr
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE tokerr(+_ERRREG); //wrong register
}

PROC tokaddsubN()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (matchrp()) {
    IF (matchcomma()) {
      IF (matchrp()) {
        IF (matchcomma()) { //adds r0,r1,r2/N
          IF (matchrp()) {
            asmtoken(+_FMTR0R0R0);
          }ELSE IF (tokexpr()) {
            asmtoken(+_FMTR0R0N7);
          }ELSE tokerr(+_ERREXPR); //wrong expr
        }ELSE asmtoken(+_FMTR0R0SAME);
      }ELSE IF (tokexpr()) {
        asmtoken(+_FMTR0N);
      }ELSE tokerr(+_ERREXPR); //wrong expr
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE tokerr(+_ERRREG); //wrong register
}

PROC tokcmp()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (matchrp()) {
    IF (matchcomma()) {
      IF (matchrp()) {
        asmtoken(+_FMTR0R0);
      }ELSE IF (tokexpr()) {
        asmtoken(+_FMTR0N);
      }ELSE tokerr(+_ERREXPR); //wrong expr
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE tokerr(+_ERRREG); //wrong register
}

PROC tokalucmdN()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (matchrp()) {
    IF (matchcomma()) {
      IF (matchrp()) {
        asmtoken(+_FMTR0R0);
      }ELSE tokerr(+_ERRREG); //wrong register
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE tokerr(+_ERRREG); //wrong register
}

PROC tokrsbs()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (matchrp()) {
    IF (matchcomma()) {
      IF (matchrp()) {
        IF (matchcomma()) {
          IF (tokexpr()) {
            asmtoken(+_FMTR0R0ZERO);
          }ELSE tokerr(+_ERREXPR); //wrong expr
        }ELSE tokerr(+_ERRCOMMA); //no comma
      }ELSE tokerr(+_ERRREG); //wrong register
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE tokerr(+_ERRREG); //wrong register
}

PROC tokshiftN()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (matchrp()) {
    IF (matchcomma()) {
      IF (matchrp()) {
        IF (matchcomma()) {
          IF (tokexpr()) {
            asmtoken(+_FMTR0R0N31);
          }ELSE tokerr(+_ERREXPR); //wrong expr
        }ELSE asmtoken(+_FMTR0R0);
      }ELSE tokerr(+_ERRREG); //wrong register
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE tokerr(+_ERRREG); //wrong register
}

PROC tokrors()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (matchrp()) {
    IF (matchcomma()) {
      IF (matchrp()) {
        asmtoken(+_FMTR0R0);
      }ELSE tokerr(+_ERRREG); //wrong register
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE tokerr(+_ERRREG); //wrong register
}

PROC tokpushpop()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (matchopenbrace()) {
    rloop:
    IF (matchrp()) {
      IF (matchcomma()) goto rloop; //список регистров
      IF (matchclosebrace()) {
        asmtoken(+_FMTPUSHPOP);
      }ELSE tokerr(+_ERRCLOSE); //no closing bracket
    }ELSE tokerr(+_ERRREG); //wrong register
  }ELSE tokerr(+_ERROPEN); //no opening bracket
}

PROC tokldr()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (matchrp()) {
    IF (matchcomma()) {
      IF (matchopen()) {
        IF (matchrp()) {
          IF (matchclose()) { //ldr r0,[r1]
            asmtoken(+_FMTR0R0);
          }ELSE IF (matchcomma()) { //ldr r0,[r1,N*4]
            asmtoken(+_FMTR0R0NX4);
          }ELSE tokerr(+_ERRCLOSE); //no closing bracket
        }ELSE tokerr(+_ERRREG); //wrong register
      }ELSE IF (tokexpr()) { //ldr r0,mem
        asmtoken(+_FMTRADDR);
      }ELSE tokerr(+_ERREXPR); //wrong expr
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE tokerr(+_ERRREG); //wrong register
}

PROC tokstr() //todo = tokldr
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (matchrp()) {
    IF (matchcomma()) {
      IF (matchopen()) {
        IF (matchrp()) {
          IF (matchclose()) { //str r0,[r1]
            asmtoken(+_FMTR0R0);
          }ELSE IF (matchcomma()) { //str r0,[r1,N*4]
            asmtoken(+_FMTR0R0NX4);
          }ELSE tokerr(+_ERRCLOSE); //no closing bracket
        }ELSE tokerr(+_ERRREG); //wrong register
      }ELSE IF (tokexpr()) { //str r0,mem
        asmtoken(+_FMTRADDR);
      }ELSE tokerr(+_ERREXPR); //wrong expr
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE tokerr(+_ERRREG); //wrong register
}

PROC tokjp()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (tokexpr()) {asmtoken(+_FMTBADDR);
  }ELSE tokerr(+_ERREXPR); //wrong expr
}

PROC tokjpccN()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (tokexpr()) {asmtoken(+_FMTBSHORTADDR);
  }ELSE tokerr(+_ERREXPR); //wrong expr
}

PROC tokbl()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (tokexpr()) {asmtoken(+_FMTBLONGADDR);
  }ELSE tokerr(+_ERREXPR); //wrong expr
}

PROC tokbx()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (matchrp()) {asmtoken(+_FMTR);
  }ELSE tokerr(+_ERREXPR); //wrong expr
}

PROC tokblx()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  IF (matchrp()) {asmtoken(+_FMTR);
  }ELSE tokerr(+_ERREXPR); //wrong expr
}

PROC tokxxN()
{
  asmtoken(_temppar);
  asmrdword_tokspc(); //съедаем команду
  asmtoken(+_FMTXX);
}

PROC tokend()
{
  asmrdword_tokspc(); //съедаем команду
}

PROC tokpre()
{
  tokaddlbl("NOP"  , (PBYTE)&tokxxN    , +_ASMNOP);
//_ASMADR, //???

  tokaddlbl("ADCS" , (PBYTE)&tokalucmdN, +_ASMADCS);
  tokaddlbl("ADDS" , (PBYTE)&tokaddsubN, +_ASMADDS);
  tokaddlbl("SBCS" , (PBYTE)&tokalucmdN, +_ASMSBCS);
  tokaddlbl("SUBS" , (PBYTE)&tokaddsubN, +_ASMSUBS);
  tokaddlbl("RSBS" , (PBYTE)&tokrsbs,    +_ASMRSBS);
  tokaddlbl("CMN"  , (PBYTE)&tokalucmdN, +_ASMCMN);
  tokaddlbl("CMP"  , (PBYTE)&tokcmp    , +_ASMCMP);
  tokaddlbl("TST"  , (PBYTE)&tokalucmdN, +_ASMTST);
  tokaddlbl("MULS" , (PBYTE)&tokalucmdN, +_ASMMULS);
  tokaddlbl("BICS" , (PBYTE)&tokalucmdN, +_ASMBICS);
//_ASMNEG,

  tokaddlbl("ANDS" , (PBYTE)&tokalucmdN, +_ASMANDS);
  tokaddlbl("ORRS" , (PBYTE)&tokalucmdN, +_ASMORRS);
  tokaddlbl("EORS" , (PBYTE)&tokalucmdN, +_ASMEORS);

  tokaddlbl("ASRS" , (PBYTE)&tokshiftN , +_ASMASRS);
  tokaddlbl("LSLS" , (PBYTE)&tokshiftN , +_ASMLSLS);
  tokaddlbl("LSRS" , (PBYTE)&tokshiftN , +_ASMLSRS);
  tokaddlbl("RORS" , (PBYTE)&tokrors   , +_ASMRORS);

  tokaddlbl("B"    , (PBYTE)&tokjp     , +_ASMB);
  tokaddlbl("BEQ"  , (PBYTE)&tokjpccN  , +_ASMBEQ);
  tokaddlbl("BNE"  , (PBYTE)&tokjpccN  , +_ASMBNE);
  tokaddlbl("BCS"  , (PBYTE)&tokjpccN  , +_ASMBCS); //HS?
  tokaddlbl("BCC"  , (PBYTE)&tokjpccN  , +_ASMBCC); //LO?
  tokaddlbl("BMI"  , (PBYTE)&tokjpccN  , +_ASMBMI);
  tokaddlbl("BPL"  , (PBYTE)&tokjpccN  , +_ASMBPL);
  tokaddlbl("BVS"  , (PBYTE)&tokjpccN  , +_ASMBVS);
  tokaddlbl("BVC"  , (PBYTE)&tokjpccN  , +_ASMBVC);
  tokaddlbl("BHI"  , (PBYTE)&tokjpccN  , +_ASMBHI);
  tokaddlbl("BLS"  , (PBYTE)&tokjpccN  , +_ASMBLS);
  tokaddlbl("BGE"  , (PBYTE)&tokjpccN  , +_ASMBGE);
  tokaddlbl("BLT"  , (PBYTE)&tokjpccN  , +_ASMBLT);
  tokaddlbl("BGT"  , (PBYTE)&tokjpccN  , +_ASMBGT);
  tokaddlbl("BLE"  , (PBYTE)&tokjpccN  , +_ASMBLE);
  tokaddlbl("BAL"  , (PBYTE)&tokjpccN  , +_ASMBAL);

  tokaddlbl("BL"   , (PBYTE)&tokbl     , +_ASMBL);
  tokaddlbl("BLX"  , (PBYTE)&tokblx    , +_ASMBLX);
  tokaddlbl("BX"   , (PBYTE)&tokbx     , +_ASMBX);

//_ASMBKPT, //???

//_ASMDMB,
//_ASMDSB,
//_ASMISB,
//_ASMCPSID,
//_ASMCPSIE,
//_ASMSEV,
//_ASMSVC,
//_ASMYIELD,

  tokaddlbl("LDR"  , (PBYTE)&tokldr    , +_ASMLDR);
  tokaddlbl("LDRB" , (PBYTE)&tokldr    , +_ASMLDRB);
  tokaddlbl("LDRH" , (PBYTE)&tokldr    , +_ASMLDRH);
  tokaddlbl("LDRSB", (PBYTE)&tokldr    , +_ASMLDRSB);
  tokaddlbl("LDRSH", (PBYTE)&tokldr    , +_ASMLDRSH);
//_ASMLDM, //???
//_ASMLDMFD, //???
//_ASMLDMIA, //???
  tokaddlbl("STR"  , (PBYTE)&tokstr    , +_ASMSTR);
  tokaddlbl("STRB" , (PBYTE)&tokstr    , +_ASMSTRB);
  tokaddlbl("STRH" , (PBYTE)&tokstr    , +_ASMSTRH);
//_ASMSTM, //???
//_ASMSTMEA, //???
//_ASMSTMIA, //???

  tokaddlbl("MOV"  , (PBYTE)&tokmov    , +_ASMMOV);
  tokaddlbl("MOVS" , (PBYTE)&tokmovs   , +_ASMMOVS);
  tokaddlbl("MVNS" , (PBYTE)&tokmvns   , +_ASMMVNS);
//_ASMMRS,
//_ASMMSR,
//_ASMCPY, //???

  tokaddlbl("POP"  , (PBYTE)&tokpushpop, +_ASMPOP);
  tokaddlbl("PUSH" , (PBYTE)&tokpushpop, +_ASMPUSH);

//_ASMREV,
//_ASMREV16,
//_ASMREVSH,
//_ASMSXTB,
//_ASMSXTH,
//_ASMUXTB,
//_ASMUXTH,

  tokaddlbl("DCB"  , (PBYTE)&tokdb  , 0x00); //db ..., вместо defb - надо после каждого выражения формат writeN, разбирать вручную не получится из-за выражения
  tokaddlbl("DCD"  , (PBYTE)&tokdw  , 0x00); //dw ..., вместо defw - надо после каждого выражения формат writeNN
  tokaddlbl("DCQ"  , (PBYTE)&tokdl  , 0x00); //dl ..., вместо defl - надо после каждого выражения формат writeNNNN
  tokaddlbl("SPACE", (PBYTE)&tokds  , 0x00); //ds ..., вместо defs - надо формат writeds

  tokaddlbl("ORG"  , (PBYTE)&tokorg , 0x00); /**org nn - надо формат writeorg, разбирать вручную не получится из-за выражения*/

  tokaddlbl("ALIGN",(PBYTE)&tokalign,0x00); /**align nn - надо формат writealign, разбирать вручную не получится из-за выражения*/
//  tokaddlbl("PAGE", (PBYTE)&tokpage, 0x00); /**page n - надо формат writepage, разбирать вручную не получится из-за выражения*/
//  tokaddlbl("IF"  , (PBYTE)&tokif  , 0x00); /**if nn - надо формат writeif, разбирать вручную не получится из-за выражения*/
//  tokaddlbl("ELSE", (PBYTE)&tokelse, 0x00); /**else*/
//  tokaddlbl("ENDIF",(PBYTE)&tokendif,0x00); /**endif*/
//  tokaddlbl("DUP" , (PBYTE)&tokdup , 0x00); /**dup nn - надо формат writedup, разбирать вручную не получится из-за выражения*/
//  tokaddlbl("EDUP", (PBYTE)&tokedup, 0x00); /**edup*/
//  tokaddlbl("MACRO",(PBYTE)&tokmacro,0x00); /**macro name - разбирать вручную?*/
//  tokaddlbl("ENDM", (PBYTE)&tokendm, 0x00); /**endm*/
  //tokaddlbl("USEMACRO",(PBYTE)&tokusemacro, 0x00); /**usemacro name ... - разбирать вручную?*/
  tokaddlbl("EXPORT",(PBYTE)&tokexport, 0x00); /**export name - разбирать вручную?*/
//  tokaddlbl("LOCAL",(PBYTE)&toklocal,0x00); /**local name - разбирать вручную?*/
//  tokaddlbl("ENDL", (PBYTE)&tokendl, 0x00); /**endl*/
//  tokaddlbl("DISP", (PBYTE)&tokdisp, 0x00); /**disp nn - надо формат writedisp*/
//  tokaddlbl("ENT" , (PBYTE)&tokent , 0x00); /**ent*/
  tokaddlbl("INCLUDE",(PBYTE)&tokinclude, 0x00); /**include "filename" - разбирать вручную?*/
  tokaddlbl("INCBIN",(PBYTE)&tokincbin, 0x00); /**incbin "filename" - разбирать вручную?*/
//  tokaddlbl("DISPLAY",(PBYTE)&tokdisplay, 0x00); /**display nn - форматы displaynum, displaystring - разбирать вручную не получится из-за выражений*/
//  tokaddlbl("REPEAT",(PBYTE)&tokrepeat, 0x00); /**repeat*/
//  tokaddlbl("UNTIL",(PBYTE)&tokuntil, 0x00); /**until nn - надо формат writeuntil*/
//  tokaddlbl("STRUCT",(PBYTE)&tokstruct, 0x00); /**struct name - разбирать вручную?*/
//  tokaddlbl("ENDSTRUCT",(PBYTE)&tokendstruct, 0x00); /**endstruct*/

  tokaddlbl("END"  , (PBYTE)&tokend  , 0x00); //ds ..., вместо defs - надо формат writeds

  tokaddlbl(":",(PBYTE)&tokcolon, 0x00);
//  tokaddlbl(";",(PBYTE)&tokcomment, 0x00); //проверяется отдельно
}
