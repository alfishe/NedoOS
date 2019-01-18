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

FUNC BOOL matchnzzncc()
{
VAR BOOL ok;
  IF       ((_lentword==2)&&(_c1small=='n')&&(_c2small=='z')) {asmtoken(+_ASMNZ); asmrdword_tokspc(); ok = +TRUE;
  }ELSE IF ((_lentword==1)&&(_c1small=='z')                 ) {asmtoken(+_ASMZ); asmrdword_tokspc(); ok = +TRUE;
  }ELSE IF ((_lentword==2)&&(_c1small=='n')&&(_c2small=='c')) {asmtoken(+_ASMNC); asmrdword_tokspc(); ok = +TRUE;
  }ELSE IF ((_lentword==1)&&(_c1small=='c')                 ) {asmtoken(+_ASMC); asmrdword_tokspc(); ok = +TRUE;
  }ELSE ok = +FALSE;
  RETURN ok;
}

FUNC BOOL matchcc()
{
VAR BOOL ok;
  IF (_lentword==1) {
    IF       (_c1small=='z') {asmtoken(+_ASMZ); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF (_c1small=='c') {asmtoken(+_ASMC); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF (_c1small=='p') {asmtoken(+_ASMP); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF (_c1small=='m') {asmtoken(+_ASMM); asmrdword_tokspc(); ok = +TRUE;
    }ELSE ok = +FALSE;
  }ELSE IF (_lentword==2) {
    IF       ((_c1small=='n')&&(_c2small=='z')) {asmtoken(+_ASMNZ); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='n')&&(_c2small=='c')) {asmtoken(+_ASMNC); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='p')&&(_c2small=='o')) {asmtoken(+_ASMPO); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='p')&&(_c2small=='e')) {asmtoken(+_ASMPE); asmrdword_tokspc(); ok = +TRUE;
    }ELSE ok = +FALSE;
  }ELSE ok = +FALSE;
  RETURN ok;
}

FUNC BOOL matcha()
{
VAR BOOL ok;
  IF ((_c1small=='a')&&(_lentword==1)) {
    asmtoken(+_RG_A);  asmrdword_tokspc(); ok = +TRUE;
  }ELSE ok = +FALSE;
  RETURN ok;
}

FUNC BOOL matchc()
{
VAR BOOL ok;
  IF ((_c1small=='c')&&(_lentword==1)) {
    asmtoken(+_RG_C); asmrdword_tokspc(); ok = +TRUE;
  }ELSE ok = +FALSE;
  RETURN ok;
}
/**
FUNC BOOL matchbc()
{
VAR BOOL ok;
  IF ((_c1small=='b')&&(_c2small=='c')&&(_lentword==2)) {
    asmtoken(+_RG_BC); asmrdword_tokspc(); ok = +TRUE;
  }ELSE ok = +FALSE;
  RETURN ok;
}
*/
FUNC BOOL matchde()
{
VAR BOOL ok;
  IF ((_c1small=='d')&&(_c2small=='e')&&(_lentword==2)) {
    asmtoken(+_RG_DE); asmrdword_tokspc(); ok = +TRUE;
  }ELSE ok = +FALSE;
  RETURN ok;
}

FUNC BOOL matchhl()
{
VAR BOOL ok;
  IF ((_c1small=='h')&&(_c2small=='l')&&(_lentword==2)) {
    asmtoken(+_RG_HL); asmrdword_tokspc(); ok = +TRUE;
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

FUNC BOOL matchaf()
{
VAR BOOL ok;
  IF ((_c1small=='a')&&(_c2small=='f')&&(_lentword==2)) {
    asmtoken(+_RG_AF); asmrdword_tokspc(); ok = +TRUE;
  }ELSE ok = +FALSE;
  RETURN ok;
}

FUNC BOOL matchixiy()
{
VAR BOOL ok;
  IF (_lentword==2) {
    IF       ((_c1small=='i')&&(_c2small=='x')) {
      asmtoken(+_RG_IX); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='i')&&(_c2small=='y')) {
      asmtoken(+_RG_IY); asmrdword_tokspc(); ok = +TRUE;
    }ELSE ok = +FALSE;
  }ELSE ok = +FALSE;
  RETURN ok;
}

FUNC BOOL matchhlixiy()
{
VAR BOOL ok;
  IF (_lentword==2) {
    IF       ((_c1small=='h')&&(_c2small=='l')) {
      asmtoken(+_RG_HL); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='i')&&(_c2small=='x')) {
      asmtoken(+_RG_IX); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='i')&&(_c2small=='y')) {
      asmtoken(+_RG_IY); asmrdword_tokspc(); ok = +TRUE;
    }ELSE ok = +FALSE;
  }ELSE ok = +FALSE;
  RETURN ok;
}

FUNC BOOL matchir()
{
VAR BOOL ok;
  IF (_lentword==1) {
    IF       (_c1small=='i') {
      asmtoken(+_RG_I); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF (_c1small=='r') {
      asmtoken(+_RG_R); asmrdword_tokspc(); ok = +TRUE;
    }ELSE ok = +FALSE;
  }ELSE ok = +FALSE;
  RETURN ok;
}

FUNC BOOL matchrp()
{
VAR BOOL ok;
  IF (_lentword==2) {
    IF       ((_c1small=='b')&&(_c2small=='c')) {asmtoken(+_RG_BC); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='d')&&(_c2small=='e')) {asmtoken(+_RG_DE); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='h')&&(_c2small=='l')) {asmtoken(+_RG_HL); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='s')&&(_c2small=='p')) {asmtoken(+_RG_SP); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='i')&&(_c2small=='x')) {asmtoken(+_RG_IX); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='i')&&(_c2small=='y')) {asmtoken(+_RG_IY); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='r')&&(_c2small=='p')) { //rp метка
      asmrdword_tokspc();
      asmtoken(+_RG_RPBYNAME);
      toktext(); //генерирует <text>text<endtext>
      asmrdword_tokspc();
      ok = +TRUE;
    }ELSE ok = +FALSE;
  }ELSE ok = +FALSE;
  RETURN ok;
}

FUNC BOOL matchrb()
{
VAR BOOL ok;
  IF (_lentword==1) {
    IF       (_c1small=='b') {asmtoken(+_RG_B); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF (_c1small=='c') {asmtoken(+_RG_C); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF (_c1small=='d') {asmtoken(+_RG_D); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF (_c1small=='e') {asmtoken(+_RG_E); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF (_c1small=='h') {asmtoken(+_RG_H); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF (_c1small=='l') {asmtoken(+_RG_L); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF (_c1small=='a') {asmtoken(+_RG_A); asmrdword_tokspc(); ok = +TRUE;
    }ELSE ok = +FALSE;
  }ELSE IF (_lentword==2) {
    IF       ((_c1small=='h')&&(_c2small=='x')) {asmtoken(+_RG_HX); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='l')&&(_c2small=='x')) {asmtoken(+_RG_LX); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='h')&&(_c2small=='y')) {asmtoken(+_RG_HY); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='l')&&(_c2small=='y')) {asmtoken(+_RG_LY); asmrdword_tokspc(); ok = +TRUE;
    }ELSE IF ((_c1small=='r')&&(_c2small=='b')) { //rb метка
      asmrdword_tokspc();
      asmtoken(+_RG_RBBYNAME);
      toktext(); //генерирует <text>text<endtext>
      asmrdword_tokspc();
      ok = +TRUE;
    }ELSE ok = +FALSE;
  }ELSE ok = +FALSE;
  RETURN ok;
}

////////////// машиннозависимые группы сравнений для парсинга частых параметров

PROC asm_hlix_close_token(BYTE hltoken, BYTE ixtoken)
{
  IF (matchhl()) {
    IF (matchclose()) {asmtoken(hltoken);
    }ELSE tokerr(+_ERRCLOSE); //no closing bracket
  }ELSE IF (matchixiy()) {
    IF (tokexpr_close()) {asmtoken(ixtoken);
    }ELSE tokerr(+_ERREXPR); //wrong expr / no closing bracket
  }ELSE tokerr(+_ERRREG); //wrong register
}

PROC asm_directhlixrp_close_token(BYTE directtoken, BYTE hltoken, BYTE ixtoken, BYTE rptoken)
{
  IF (matchhl()){
    IF (matchclose()) {asmtoken(hltoken);
    }ELSE tokerr(+_ERRCLOSE); //no closing bracket
  }ELSE IF (matchixiy()) {
    IF (tokexpr_close()) {asmtoken(ixtoken);
    }ELSE tokerr(+_ERREXPR); //wrong expr / no closing bracket
  }ELSE IF (matchrp()) {
    IF (matchclose()) {asmtoken(rptoken);
    }ELSE tokerr(+_ERRCLOSE); //no closing bracket
  }ELSE //if(matchdirect()) {
    IF (tokexpr_close()) {asmtoken(directtoken);
    }ELSE tokerr(+_ERREXPR); //wrong expr / no closing bracket
  //}else tokerr(+_ERRPAR); //wrong register
}

PROC asm_directrb_token(BYTE directtoken, BYTE rbtoken)
{
  IF (matchrb()) { //<cmd> rb
    asmtoken(rbtoken);
  }ELSE //if(matchdirect()) { //<cmd> #N
    IF (tokexpr()) {asmtoken(directtoken);
    }ELSE tokerr(+_ERREXPR); //wrong expr
  //}else tokerr(+_ERRPAR); //wrong register or direct expr
}

///////////////////////////////////////////////////

PROC tokex()
{
//  _ignoreprime = +TRUE;
  asmtoken(+_ASMEX);
  asmrdword_tokspc(); //команда может быть: a, <rp>/rp метка
  IF (matchopen()) { //ex (sp),hl/ix/iy
    IF (matchsp()) {
      IF (matchclose()) {
        IF (matchcomma()) { //дальше может быть: hl, ix, iy
          IF (matchhlixiy()) {asmtoken(+_FMTEXRPRP);
          }ELSE tokerr(+_ERRREG); //wrong register
        }ELSE tokerr(+_ERRCOMMA); //no comma
      }ELSE tokerr(+_ERRCLOSE); //no closing bracket
    }ELSE tokerr(+_ERRREG); //wrong register
  }ELSE IF (matchde()) { //ex de,hl
    IF (matchcomma()) { //дальше может быть: hl
      IF (matchhl()) {asmtoken(+_FMTEXRPRP);
      }ELSE tokerr(+_ERRREG); //wrong register
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE IF (matchaf()) { //ex af,af'
    IF (matchcomma()) { //дальше может быть: af'
      IF (matchaf()) {
        IF (matchprime()) {asmtoken(+_FMTEXRPRP);
        }ELSE tokerr(+_ERRREG); //wrong register
      }ELSE tokerr(+_ERRREG); //wrong register
    }ELSE tokerr(+_ERRCOMMA); //no comma
  };
//  _ignoreprime = +FALSE;
}

PROC tokinc()
{
  asmtoken(+_ASMINC);
  asmrdword_tokspc(); //команда может быть: <rb>, <rp>, '(' для (hl), '(' для (ix/iy[+-d]), rp метка (генерировать rpbyname), rb метка (генерировать rbbyname)
  IF (matchopen()) { //inc (hl) или inc(ix/iy[+-d])
    asm_hlix_close_token(+_FMTINCDECMHL/**_FMTALUCMDMHL*/, +_FMTINCDECIDX/**_FMTALUCMDIDX*/);
  }ELSE { //не скобки
    IF (matchrp()) {asmtoken(+_FMTINCRP); //bc,de,hl,sp,ix,iy,rp метка
    }ELSE IF (matchrb()) {asmtoken(+_FMTINCDECRB/**_FMTALUCMDRB*/); //b,c,d,e,h,l,a,hx,lx,hy,ly,rb метка
    }ELSE tokerr(+_ERRREG); //wrong register
  };
}

PROC tokdec()
{
  asmtoken(+_ASMDEC);
  asmrdword_tokspc(); //команда может быть: <rb>, <rp>, '(' для (hl), '(' для (ix/iy[+-d]), rp метка (генерировать rpbyname), rb метка (генерировать rbbyname)
  IF (matchopen()) { //inc (hl) или inc(ix/iy[+-d])
    asm_hlix_close_token(+_FMTINCDECMHL/**_FMTALUCMDMHL*/, +_FMTINCDECIDX/**_FMTALUCMDIDX*/);
  }ELSE { //не скобки
    IF (matchrp()) {asmtoken(+_FMTDECRP); //bc,de,hl,sp,ix,iy,rp метка
    }ELSE IF (matchrb()) {asmtoken(+_FMTINCDECRB/**_FMTALUCMDRB*/); //b,c,d,e,h,l,a,hx,lx,hy,ly,rb метка
    }ELSE tokerr(+_ERRREG); //wrong register
  };
}

PROC tokadd()
{
  asmtoken(+_ASMADD);
  asmrdword_tokspc(); //команда может быть: a, <rp>/rp метка
  IF (matcha()) {
    IF (matchcomma()) { //дальше может быть: N, '(' для hl, '(' для (ix/iy[+-d]), <rb>/rb метка
      IF (matchopen()) {asm_hlix_close_token(+_FMTALUCMDMHL, +_FMTALUCMDIDX); //add a,(hl) или add a,(ix/iy[+-d])
      }ELSE asm_directrb_token(+_FMTALUCMDN, +_FMTALUCMDRB); //add a,#N или add a,rb
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE IF (matchhlixiy()) { //add hl/ix/iy,rp
    IF (matchcomma()) { //дальше может быть: <rp>/rp метка
      IF (matchrp()) {asmtoken(+_FMTADDHLRP);
      }ELSE tokerr(+_ERRREG); //wrong register
    }ELSE tokerr(+_ERRCOMMA); //no comma
  };
}

PROC tokadc()
{
  asmtoken(+_ASMADC);
  asmrdword_tokspc(); //команда может быть: a, hl
  IF (matcha()) {
    IF (matchcomma()) { //дальше может быть: N, '(' для hl, '(' для (ix/iy[+-d]), <rb>/rb метка
      IF (matchopen()) {asm_hlix_close_token(+_FMTALUCMDMHL, +_FMTALUCMDIDX); //adc a,(hl) или adc a,(ix/iy[+-d])
      }ELSE asm_directrb_token(+_FMTALUCMDN, +_FMTALUCMDRB); //adc a,#N или adc a,rb
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE IF (matchhl()) { //adc hl,rp
    IF (matchcomma()) { //дальше может быть: <rp>/rp метка
      IF (matchrp()) {asmtoken(+_FMTADCHLRP);
      }ELSE tokerr(+_ERRREG); //wrong register
    }ELSE tokerr(+_ERRCOMMA); //no comma
  };
}

PROC toksbc()
{
  asmtoken(+_ASMSBC);
  asmrdword_tokspc(); //команда может быть: a, hl
  IF (matcha()) {
    IF (matchcomma()) { //дальше может быть: N, '(' для hl, '(' для (ix/iy[+-d]), <rb>/rb метка
      IF (matchopen()) {asm_hlix_close_token(+_FMTALUCMDMHL, +_FMTALUCMDIDX); //adc a,(hl) или adc a,(ix/iy[+-d])
      }ELSE asm_directrb_token(+_FMTALUCMDN, +_FMTALUCMDRB); //adc a,#N или adc a,rb
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE IF (matchhl()) { //sbc hl,rp
    IF (matchcomma()) { //дальше может быть: <rp>/rp метка
      IF (matchrp()) {asmtoken(+_FMTSBCHLRP);
      }ELSE tokerr(+_ERRREG); //wrong register
    }ELSE tokerr(+_ERRCOMMA); //no comma
  };
}

PROC tokalucmd(BYTE token)
{
  asmtoken(token);
  asmrdword_tokspc(); //съедаем команду //дальше может быть: N, '(' для hl, '(' для (ix/iy[+-d]), <rb>/rb метка
  IF (matchopen()) {asm_hlix_close_token(+_FMTALUCMDMHL, +_FMTALUCMDIDX); //<cmd> (hl) или <cmd> (ix/iy[+-d])
  }ELSE asm_directrb_token(+_FMTALUCMDN, +_FMTALUCMDRB); //<cmd> #N или <cmd> rb
}

PROC tokcbxx(BYTE token)
{
  asmtoken(token);
  asmrdword_tokspc(); //съедаем команду //дальше может быть: '(' для hl, '(' для (ix/iy[+-d]), <rb>/rb метка
  IF (matchopen()) {asm_hlix_close_token(+_FMTCBCMDMHL, +_FMTCBCMDIDX); //<cmd> (hl) или <cmd> (ix/iy[+-d])
  }ELSE { //<cmd> rb
    IF (matchrb()) {asmtoken(+_FMTCBCMDRB);
    }ELSE tokerr(+_ERRREG); //wrong register
  };
}

PROC tokbit(BYTE token)
{
  asmtoken(token);
  asmrdword_tokspc(); //съедаем команду
  IF (tokexpr()) {
    asmtoken(+_OPBIT); //для bit/res/set: проверяет pseudon (разрешено только 0..7, иначе ошибка), умножает на 8 и прибавляет к базе опкода
    IF (matchcomma()) { //дальше может быть: '(' для hl, '(' для (ix/iy[+-d]), <rb>/rb метка
      IF (matchopen()) {asm_hlix_close_token(+_FMTCBCMDMHL, +_FMTCBCMDIDX); //<cmd> N,(hl) или <cmd> N,(ix/iy[+-d])
      }ELSE { //<cmd> N,rb
        IF (matchrb()) {asmtoken(+_FMTCBCMDRB);
        }ELSE tokerr(+_ERRREG); //wrong register
      };
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE tokerr(+_ERREXPR); //wrong expr
}

PROC tokout()
{
  asmtoken(+_ASMOUT);
  asmrdword_tokspc(); //съедаем команду //дальше может быть: '(' для c, '(' для #N
  IF (matchopen()) {
    IF (matchc()) {
      IF (matchclose()) {
        IF (matchcomma()) { //дальше может быть: <rb>/rb метка
          IF (matchrb()) {asmtoken(+_FMTOUTCRB);
          }ELSE tokerr(+_ERRREG); //wrong register
        }ELSE tokerr(+_ERRCOMMA); //no comma
      }ELSE tokerr(+_ERRCLOSE); //no closing bracket
    }ELSE IF (tokexpr_close()) { //out (#N),a
      IF (matchcomma()) { //дальше может быть: a
        IF (matcha()) {asmtoken(+_FMTALUCMDN);
        }ELSE tokerr(+_ERRREG); //wrong register
      }ELSE tokerr(+_ERRCOMMA); //no comma
    }ELSE tokerr(+_ERRPAR); //wrong parameter / no closing bracket
  }ELSE tokerr(+_ERROPEN); //no opening bracket
}

PROC tokin()
{
  asmtoken(+_ASMIN);
  asmrdword_tokspc(); //съедаем команду //дальше может быть: a, <rb>/rb метка
  IF (matcha()) {
    IF (matchcomma()) { //дальше может быть: '(' для c, '(' для #N
      IF (matchopen()) {
        IF (matchc()) {
          IF (matchclose()) {asmtoken(+_FMTINRBC);
          }ELSE tokerr(+_ERRCLOSE); //no closing bracket
        }ELSE IF (tokexpr_close()) {
          asmtoken(+_FMTALUCMDN); //in a,(#N)
        }ELSE tokerr(+_ERRPAR); //wrong parameter / no closing bracket
      }ELSE tokerr(+_ERROPEN); //no opening bracket
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE IF (matchrb()) {
    IF (matchcomma()) { //дальше может быть: '(' для c
      IF (matchopen()) {
        IF (matchc()) {
          IF (matchclose()) {asmtoken(+_FMTINRBC);
          }ELSE tokerr(+_ERRCLOSE); //no closing bracket
        }ELSE tokerr(+_ERRPAR); //wrong parameter
      }ELSE tokerr(+_ERROPEN); //no opening bracket
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE tokerr(+_ERRREG); //wrong register
}

PROC tokpush()
{
  asmtoken(+_ASMPUSH);
  asmrdword_tokspc();
  IF (matchaf()) {asmtoken(+_FMTPUSHPOPRP);
  }ELSE IF (matchrp()) {asmtoken(+_FMTPUSHPOPRP);
  }ELSE tokerr(+_ERRREG); //wrong register
}

PROC tokpop()
{
  asmtoken(+_ASMPOP);
  asmrdword_tokspc();
  IF (matchaf()) {asmtoken(+_FMTPUSHPOPRP);
  }ELSE IF (matchrp()) {asmtoken(+_FMTPUSHPOPRP);
  }ELSE tokerr(+_ERRREG); //wrong register
}

PROC tokld() //(ix) без +d не поддерживается, т.к. для этого нужны дополнительные форматы или вручную вставлять push0 - TODO
{
  asmtoken(+_ASMLD);
  asmrdword_tokspc(); //команда может быть: 'I', 'R', <rb>, <rp>, '(' для NN, '(' для (hl), '(' для (ix/iy[+-d]), rp метка (генерировать rpbyname), rb метка (генерировать rbbyname)
  IF (matchopen()) { //скобки в первом параметре
    IF (matchhl()) { //ld (hl),rb или ld (hl),N
      IF (matchclose()) {
        IF (matchcomma()) {asm_directrb_token(+_FMTPUTMHLN, +_FMTPUTMHLRB);
        }ELSE tokerr(+_ERRCOMMA); //no comma
      }ELSE tokerr(+_ERRCLOSE); //no closing bracket
    }ELSE IF (matchixiy()) { //ld (ix/iy[+-d]),rb или ld (ix/iy[+-d]),N
      IF (tokexpr_close()) { //после него при ошибке ничего больше нельзя проверять, т.к. курсор мог сдвинуться
        IF (matchcomma()) {asm_directrb_token(+_FMTPUTIDXN, +_FMTPUTIDXRB);
        }ELSE tokerr(+_ERRCOMMA); //no comma
      }ELSE tokerr(+_ERREXPR); //wrong expr / no closing bracket
    }ELSE IF (matchrp()) { //ld (rp),a
      IF (matchclose()) {
        IF (matchcomma()) {
          IF (matcha()) {asmtoken(+_FMTPUTMRPA);
          }ELSE tokerr(+_ERRREG); //wrong register
        }ELSE tokerr(+_ERRCOMMA); //no comma
      }ELSE tokerr(+_ERRCLOSE); //no closing bracket
    }ELSE //if(matchdirect()) { //ld (#NN),a или ld (#NN),rp
      IF (tokexpr_close()) { //после него при ошибке ничего больше нельзя проверять, т.к. курсор мог сдвинуться
        IF (matchcomma()) { //дальше может быть: 'a', <rp>/rp метка
          IF (matcha()) {asmtoken(+_FMTPUTMNNA);
          }ELSE IF (matchrp()) {asmtoken(+_FMTPUTMNNRP);
          }ELSE tokerr(+_ERRREG); //wrong register
        }ELSE tokerr(+_ERRCOMMA); //no comma
      }ELSE tokerr(+_ERREXPR); //wrong expr
    //}else tokerr(+_ERRPAR); //wrong register (todo попробовать тут тоже expr)

  }ELSE { //не скобки //команда может быть: 'I', 'R', <rb>, <rp>, rp метка (генерировать rpbyname), rb метка (генерировать rbyname)
    IF (matchrp()) {
      IF (matchcomma()) { //дальше может быть: NN, '(' для NN
        IF (matchopen()) {asm_direct_expr_close_token(+_FMTGETRPMNN); //ld rp,(#NN)
        }ELSE IF (matchrp()) {asmtoken(+_FMTMOVRPRP); //ld rp,rp
        }ELSE //if(matchdirect()) { //ld rp,#NN
          IF (tokexpr()) {asmtoken(+_FMTLDRPNN);
          }ELSE tokerr(+_ERREXPR); //wrong expr
        //}else tokerr(+_ERRPAR); //wrong parameter
      }ELSE tokerr(+_ERRCOMMA); //no comma
    }ELSE IF (matcha()) {
      IF (matchcomma()) { //дальше может быть: 'I', 'R', N, '(' для NN, '(' для rp, '(' для (ix/iy[+-d]), <rb>/rb метка
        IF (matchopen()) {asm_directhlixrp_close_token(+_FMTGETAMNN, +_FMTGETRBMHL, +_FMTGETRBIDX, +_FMTGETAMRP); //ld a,(#NN) или ld a,(hl) или ld a,(ix/iy[+-d]) или ld a,(rp)
        }ELSE IF (matchir()) {asmtoken(+_FMTMOVAIR); //ld a,i/r
        }ELSE asm_directrb_token(+_FMTLDRBN, +_FMTMOVRBRB); //ld a,#N или ld a,rb
      }ELSE tokerr(+_ERRCOMMA); //no comma
    }ELSE IF (matchrb()) {
      IF (matchcomma()) { //дальше может быть: N, '(' для hl, '(' для (ix/iy[+-d]), <rb>/rb метка
        IF (matchopen()) {asm_hlix_close_token(+_FMTGETRBMHL, +_FMTGETRBIDX); //ld rb,(hl) или ld rb,(ix/iy[+-d])
        }ELSE asm_directrb_token(+_FMTLDRBN, +_FMTMOVRBRB); //ld rb,#N или ld rb,rb
      }ELSE tokerr(+_ERRCOMMA); //no comma
    }ELSE IF (matchir()) { //ld i/r,a
      IF (matchcomma()) { //дальше может быть: 'a'
        IF (matcha()) {asmtoken(+_FMTMOVIRA);
        }ELSE tokerr(+_ERRREG); //wrong register
      }ELSE tokerr(+_ERRCOMMA); //no comma
    }ELSE tokerr(+_ERRREG); //wrong register
  };
}

PROC tokret()
{
  asmtoken(+_ASMRET);
  asmrdword_tokspc(); //съедаем ret
  IF ((_asmwaseols!=0)||(_asmwaseof)||(*(PCHAR)_tword==':')||(*(PCHAR)_tword==';')) { //ret
    asmtoken(+_FMTXX);
  }ELSE { //ret cc
    IF (matchcc()) {asmtoken(+_FMTXX);
    }ELSE tokerrcmd();
  };
}

PROC tokdjnz()
{
  asmtoken(+_ASMDJNZ);
  asmrdword_tokspc(); //съедаем djnz
  IF (tokexpr()) {asmtoken(+_FMTJRDD);
  }ELSE tokerr(+_ERREXPR); //wrong expr
}

PROC tokjr()
{
  asmtoken(+_ASMJR);
  asmrdword_tokspc(); //съедаем jr
  IF (matchnzzncc()) { //jr cc,NN
    IF (matchcomma()) {
      IF (tokexpr()) {asmtoken(+_FMTJRDD);
      }ELSE tokerr(+_ERREXPR); //wrong expr
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE { //jr NN
    IF (tokexpr()) {asmtoken(+_FMTJRDD);
    }ELSE tokerr(+_ERREXPR); //wrong expr
  };
}

PROC tokjp()
{
  asmtoken(+_ASMJP);
  asmrdword_tokspc(); //съедаем jp
  IF (matchcc()) { //jp cc,NN
    IF (matchcomma()) {
      IF (tokexpr()) {asmtoken(+_FMTJPNN);
      }ELSE tokerr(+_ERREXPR); //wrong expr
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE { //jp NN
    IF (matchopen()) { //скобка
      IF (matchhlixiy()) { //jp (hl)/(ix)/(iy)
        IF (matchclose()) {asmtoken(+_FMTJPRP);
        }ELSE tokerr(+_ERRCLOSE); //no closing bracket
      }ELSE IF (tokexpr_close()) {asmtoken(+_FMTJPNN);
      }ELSE tokerr(+_ERREXPR); //wrong expr
    }ELSE IF (tokexpr()) {asmtoken(+_FMTJPNN);
    }ELSE tokerr(+_ERREXPR); //wrong expr
  };
}

PROC tokcall()
{
  asmtoken(+_ASMCALL);
  asmrdword_tokspc(); //съедаем call
  IF (matchcc()) { //call cc,NN
    IF (matchcomma()) {
      IF (tokexpr()) {asmtoken(+_FMTJPNN);
      }ELSE tokerr(+_ERREXPR); //wrong expr
    }ELSE tokerr(+_ERRCOMMA); //no comma
  }ELSE { //call NN
    IF (tokexpr()) {asmtoken(+_FMTJPNN);
    }ELSE tokerr(+_ERREXPR); //wrong expr
  };
}

PROC tokrst()
{
  asmtoken(+_ASMRST);
  asmrdword_tokspc(); //съедаем rst
  IF (tokexpr()) {asmtoken(+_FMTRST);
  }ELSE tokerr(+_ERREXPR); //wrong expr
}

PROC tokim()
{
  asmtoken(+_ASMIM);
  asmrdword_tokspc(); //съедаем im
  IF (tokexpr()) {asmtoken(+_FMTIM);
  }ELSE tokerr(+_ERREXPR); //wrong expr
}

PROC tokxx(BYTE token) //команда без параметров
{
  asmtoken(token);
  asmrdword_tokspc(); //съедаем команду
  asmtoken(+_FMTXX);
}

PROC tokalucmdN()
{
  tokalucmd(_temppar);
}

PROC tokxxN()
{
  tokxx(_temppar);
}

PROC tokcbxxN()
{
  tokcbxx(_temppar);
}

PROC tokbitN()
{
  tokbit(_temppar);
}

PROC tokpre()
{
  tokaddlbl("LD"  , (PBYTE)&tokld  , 0x00);
  tokaddlbl("CALL", (PBYTE)&tokcall, 0x00);
  tokaddlbl("JP"  , (PBYTE)&tokjp  , 0x00);
  tokaddlbl("RET" , (PBYTE)&tokret , 0x00);
  tokaddlbl("JR"  , (PBYTE)&tokjr  , 0x00);

  tokaddlbl("DB"  , (PBYTE)&tokdb  , 0x00); //db ..., вместо defb - надо после каждого выражения формат writeN, разбирать вручную не получится из-за выражения
  tokaddlbl("DW"  , (PBYTE)&tokdw  , 0x00); //dw ..., вместо defw - надо после каждого выражения формат writeNN
  tokaddlbl("DL"  , (PBYTE)&tokdl  , 0x00); //dl ..., вместо defl - надо после каждого выражения формат writeNNNN
  tokaddlbl("DS"  , (PBYTE)&tokds  , 0x00); //ds ..., вместо defs - надо формат writeds

  tokaddlbl("POP" , (PBYTE)&tokpop , 0x00);
  tokaddlbl("PUSH", (PBYTE)&tokpush, 0x00);

  tokaddlbl("ADD" , (PBYTE)&tokadd , 0x00);
  tokaddlbl("ADC" , (PBYTE)&tokadc , 0x00);
  tokaddlbl("SUB" , (PBYTE)&tokalucmdN, +_ASMSUB);
  tokaddlbl("SBC" , (PBYTE)&toksbc , 0x00);
  tokaddlbl("AND" , (PBYTE)&tokalucmdN, +_ASMAND);
  tokaddlbl("OR"  , (PBYTE)&tokalucmdN, +_ASMOR);
  tokaddlbl("XOR" , (PBYTE)&tokalucmdN, +_ASMXOR);
  tokaddlbl("CP"  , (PBYTE)&tokalucmdN, +_ASMCP);
  tokaddlbl("INC" , (PBYTE)&tokinc , 0x00);
  tokaddlbl("DEC" , (PBYTE)&tokdec , 0x00);

  tokaddlbl("EX"  , (PBYTE)&tokex  , 0x00);

  tokaddlbl("RLC" , (PBYTE)&tokcbxxN, +_ASMRLC);
  tokaddlbl("RRC" , (PBYTE)&tokcbxxN, +_ASMRRC);
  tokaddlbl("RL"  , (PBYTE)&tokcbxxN, +_ASMRL);
  tokaddlbl("RR"  , (PBYTE)&tokcbxxN, +_ASMRR);
  tokaddlbl("SLA" , (PBYTE)&tokcbxxN, +_ASMSLA);
  tokaddlbl("SRA" , (PBYTE)&tokcbxxN, +_ASMSRA);
  tokaddlbl("SLI" , (PBYTE)&tokcbxxN, +_ASMSLI);
  tokaddlbl("SRL" , (PBYTE)&tokcbxxN, +_ASMSRL);

  tokaddlbl("DJNZ", (PBYTE)&tokdjnz, 0x00);

  tokaddlbl("RST" , (PBYTE)&tokrst , 0x00);

  tokaddlbl("OUT" , (PBYTE)&tokout , 0x00);
  tokaddlbl("IN"  , (PBYTE)&tokin  , 0x00);

  tokaddlbl("BIT" , (PBYTE)&tokbitN, +_ASMBIT);
  tokaddlbl("RES" , (PBYTE)&tokbitN, +_ASMRES);
  tokaddlbl("SET" , (PBYTE)&tokbitN, +_ASMSET);

  tokaddlbl("IM"  , (PBYTE)&tokim  , 0x00);

  tokaddlbl("RLCA", (PBYTE)&tokxxN, +_ASMRLCA);
  tokaddlbl("RRCA", (PBYTE)&tokxxN, +_ASMRRCA);
  tokaddlbl("RLA" , (PBYTE)&tokxxN, +_ASMRLA);
  tokaddlbl("RRA" , (PBYTE)&tokxxN, +_ASMRRA);
  tokaddlbl("DAA" , (PBYTE)&tokxxN, +_ASMDAA);
  tokaddlbl("CPL" , (PBYTE)&tokxxN, +_ASMCPL);
  tokaddlbl("SCF" , (PBYTE)&tokxxN, +_ASMSCF);
  tokaddlbl("CCF" , (PBYTE)&tokxxN, +_ASMCCF);
  tokaddlbl("NOP" , (PBYTE)&tokxxN, +_ASMNOP);
  tokaddlbl("HALT", (PBYTE)&tokxxN, +_ASMHALT);
  tokaddlbl("DI"  , (PBYTE)&tokxxN, +_ASMDI);
  tokaddlbl("EI"  , (PBYTE)&tokxxN, +_ASMEI);
  tokaddlbl("EXX" , (PBYTE)&tokxxN, +_ASMEXX);

  tokaddlbl("RETN", (PBYTE)&tokxxN, +_ASMRETN);
  tokaddlbl("RETI", (PBYTE)&tokxxN, +_ASMRETI);

  tokaddlbl("LDI" , (PBYTE)&tokxxN, +_ASMLDI);
  tokaddlbl("LDD" , (PBYTE)&tokxxN, +_ASMLDD);
  tokaddlbl("LDIR", (PBYTE)&tokxxN, +_ASMLDIR);
  tokaddlbl("LDDR", (PBYTE)&tokxxN, +_ASMLDDR);
  tokaddlbl("CPI" , (PBYTE)&tokxxN, +_ASMCPI);
  tokaddlbl("CPD" , (PBYTE)&tokxxN, +_ASMCPD);
  tokaddlbl("CPIR", (PBYTE)&tokxxN, +_ASMCPIR);
  
  tokaddlbl("CPDR", (PBYTE)&tokxxN, +_ASMCPDR);
  tokaddlbl("INI" , (PBYTE)&tokxxN, +_ASMINI);
  tokaddlbl("IND" , (PBYTE)&tokxxN, +_ASMIND);
  tokaddlbl("INIR", (PBYTE)&tokxxN, +_ASMINIR);
  tokaddlbl("INDR", (PBYTE)&tokxxN, +_ASMINDR);
  tokaddlbl("OUTI", (PBYTE)&tokxxN, +_ASMOUTI);
  tokaddlbl("OUTD", (PBYTE)&tokxxN, +_ASMOUTD);
  tokaddlbl("OTIR", (PBYTE)&tokxxN, +_ASMOTIR);
  tokaddlbl("OTDR", (PBYTE)&tokxxN, +_ASMOTDR);
  tokaddlbl("INF" , (PBYTE)&tokxxN, +_ASMINF);

  tokaddlbl("NEG" , (PBYTE)&tokxxN, +_ASMNEG);

  tokaddlbl("ORG" , (PBYTE)&tokorg , 0x00); /**org nn - надо формат writeorg, разбирать вручную не получится из-за выражения*/

//  tokaddlbl("ALIGN",(PBYTE)&tokalign,0x00); /**align nn - надо формат writealign, разбирать вручную не получится из-за выражения*/
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

  tokaddlbl(":",(PBYTE)&tokcolon, 0x00);
//  tokaddlbl(";",(PBYTE)&tokcomment, 0x00); //проверяется отдельно
}
