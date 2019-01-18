//// машиннозависимые ветки

      case _TOKCOMMA: {/**_oldreg = _reg;*//**не трогаем value! его сдвинет только другое value!*/ goto loop;}
      case _TOKOPENBRACE:
      case _TOKCLOSEBRACE:

        {goto loop;}

      case _ASMNOP: {_base=0xbf; _base2=0x00; goto loop;}
//ещё на 0xbf группа IT...

//      case _ASMADR: //???

      case _ASMADCS:{_base=0x41; _base2=0x40; goto loop;}
      case _ASMADDS:{_base=0x18; _base2=0x00; _baseN=0x30; goto loop;} //baseN adds r0,#N
//      case _ASMADD: {_basepc=0xa0; _basesp=0xa8; _baseisp=0xb0; goto loop;} //basepc add r0,pc,#N*4 TODO //basesp add r0,sp,#N*4 TODO //baseisp add sp,SN7*4 (S - отдельный знак без дополнения до 2) TODO
//cbz r0,#N*2 %1011 00N1 NNNN Nrrr
//cbnz r0,#N*2 %1011 10N1 NNNN Nrrr
      case _ASMSBCS:{_base=0x41; _base2=0x80; goto loop;}
      case _ASMSUBS:{_base=0x1a; _base2=0x00; _baseN=0x38; goto loop;} //baseN subs r0,#N
      case _ASMRSBS:{_base=0x42; _base2=0x40; goto loop;}
      case _ASMCMN: {_base=0x42; _base2=0xc0; goto loop;}
      case _ASMCMP: {_base=0x42; _base2=0x80; _baseN=0x28; goto loop;} //baseN cmp r0,#N
      case _ASMTST: {_base=0x42; _base2=0x00; goto loop;}
//      case _ASMNEG:
      case _ASMMULS:{_base=0x43; _base2=0x40; goto loop;}
      case _ASMBICS:{_base=0x43; _base2=0x80; goto loop;}

      case _ASMANDS:{_base=0x40; _base2=0x00; goto loop;}
      case _ASMORRS:{_base=0x43; _base2=0x00; goto loop;}
      case _ASMEORS:{_base=0x40; _base2=0x40; goto loop;}

      case _ASMASRS:{_base=0x41; _base2=0x00; _baseN=0x10; goto loop;}
      case _ASMLSLS:{_base=0x40; _base2=0x80; _baseN=0x00; goto loop;} //baseN lsls r0,r1,#N
      case _ASMLSRS:{_base=0x40; _base2=0xc0; _baseN=0x08; goto loop;}
      case _ASMRORS:{_base=0x41; _base2=0xc0; goto loop;}

      case _ASMB:   {_base=0xe0; goto loop;} //%1110 0Snn nnnn nnnn (S с дополнением до 2)
//e8 не используется
//e9 не используется
//ea не используется
//eb не используется
//ec не используется
//ed не используется
//ee не используется
//ef не используется
      case _ASMBEQ: {_base=0xd0; goto loop;}
      case _ASMBNE: {_base=0xd1; goto loop;}
      case _ASMBCS: {_base=0xd2; goto loop;} //HS
      case _ASMBCC: {_base=0xd3; goto loop;} //LO
      case _ASMBMI: {_base=0xd4; goto loop;}
      case _ASMBPL: {_base=0xd5; goto loop;}
      case _ASMBVS: {_base=0xd6; goto loop;}
      case _ASMBVC: {_base=0xd7; goto loop;}
      case _ASMBHI: {_base=0xd8; goto loop;}
      case _ASMBLS: {_base=0xd9; goto loop;}
      case _ASMBGE: {_base=0xda; goto loop;}
      case _ASMBLT: {_base=0xdb; goto loop;}
      case _ASMBGT: {_base=0xdc; goto loop;}
      case _ASMBLE: {_base=0xdd; goto loop;}
//de не используется
//      case _ASMBAL:
      case _ASMBL:  {_base=0xf0; goto loop;} //xx f0+ xx f8+ //длинный переход (-400000..+400000)
//%1111 0sHH HHHH HHHH
//%1111 1LLL LLLL LLLL
//HL домножается до 2 и прибавляется к PC после конца команды, т.е. PC+4 (без округления до 4)
      case _ASMBLX: {_base=0x47; _base2=0x80; goto loop;}
      case _ASMBX:  {_base=0x47; _base2=0x00; goto loop;}

      case _ASMBKPT:{_base=0xbe; goto loop;}

//      case _ASMDMB: //???
//      case _ASMDSB: //???
//      case _ASMISB: //???
//      case _ASMCPSID: //нет в Phyton
//      case _ASMCPSIE: //операнды?
//      case _ASMSEV:
      case _ASMSVC: {_base=0xdf; goto loop;} //svc #N
//      case _ASMYIELD:

      case _ASMLDR: {_base=0x68; _base2=0x00; _baseN=0x48; /**_base3=0x50; _basesp=0x98;*/ goto loop;} //baseN ldr r0,[pc,#n] //base3 ldr r0,[r1,r2] TODO //basesp ldr r0,[sp,#N*4] TODO
      case _ASMLDRB:{_base=0x78; _base2=0x00; goto loop;}
      case _ASMLDRH:{_base=0x88; _base2=0x00; goto loop;}
//      case _ASMLDRSB:
//      case _ASMLDRSH:
//      case _ASMLDM: //???
//      case _ASMLDMFD: //???
      case _ASMLDMIA:{_base=0xcf; goto loop;} //ldmia r0!,{reglist}
      case _ASMSTR: {_base=0x60; _base2=0x00; /**_base3=0x50; _basesp=0x90;*/ goto loop;} //base3 str r0,[r1,r2] TODO //basesp str r0,[sp,#N*4] TODO
      case _ASMSTRB:{_base=0x70; _base2=0x00; goto loop;}
      case _ASMSTRH:{_base=0x80; _base2=0x00; goto loop;}
//      case _ASMSTM: //???
//      case _ASMSTMEA: //???
      case _ASMSTMIA:{_base=0xc7; goto loop;} //stmia r0!,{reglist}

      case _ASMMOV: {_base=0x46; goto loop;}
      case _ASMMOVS:{_base=0x00; _base2=0x00; _baseN=0x20; goto loop;} //baseN movs r0,#n
      case _ASMMVNS:{_base=0x43; _base2=0xc0; goto loop;}
//      case _ASMMRS:
//      case _ASMMSR:
//      case _ASMCPY: //???

      case _ASMPOP: {_base=0xbc; _reglist=0; goto loop;}
//в POP можно указать список регистров (только R0..R7 и PC):
//POP {R0,R2,R7,PC}
//%1011 110P 7654 3210
      case _ASMPUSH:{_base=0xb4; _reglist=0; goto loop;}
//в PUSH можно указать список регистров (только R0..R7 и LR):
//PUSH {R0,R2,R7,LR}
//%1011 010L 7654 3210

      case _ASMREV:  {_base=0xba; _base2=0x00; goto loop;}
      case _ASMREV16:{_base=0xba; _base2=0x40; goto loop;}
      case _ASMREVSH:{_base=0xba; _base2=0xc0; goto loop;}
//80 ba не используется
      case _ASMSXTH: {_base=0xb2; _base2=0x00; goto loop;}
      case _ASMSXTB: {_base=0xb2; _base2=0x40; goto loop;}
      case _ASMUXTH: {_base=0xb2; _base2=0x80; goto loop;}
      case _ASMUXTB: {_base=0xb2; _base2=0xc0; goto loop;}

        {goto loop;}
//b6 не используется

   //форматы:
//comma==keepreg: ставится перед вторым регистром/rp в команде (можно сэкономить, если reg хранится в одном месте, а rp в другом, но для add rp,rp надо два rp)

      case _FMTXX:        {asmbyte(_base2); asmbyte(_base); goto loop;}
      case _FMTR:         {asmbyte(_base2+(_reg<<0x03)); asmbyte(_base); goto loop;} //bx r
      case _FMTR0N:       {IF (_reg>=0x08) errwrongreg(); asmbytepopvalue(); asmbyte(_baseN+_reg); goto loop;} //adds r0,#N (baseN!!!)
      case _FMTR0R0:      {err_onlylowregs(); asmbyte(_base2+(_reg<<0x03)+_oldreg); asmbyte(_base); goto loop;} //alucmd r0,r1
      case _FMTR0R0SAME:  {err_onlylowregs(); asmbyte((_reg<<0x06)+(_oldreg<<0x03)+_oldreg); asmbyte(_base+(_reg>>0x02)); goto loop;} //adds r0,r1 = adds r0,r0,r1
      case _FMTR8R8:      {err_onlylowregs_forbidden(); asmbyte(((_oldreg&0x08)<<0x04)+(_reg<<0x03)+(_oldreg&0x07)); asmbyte(_base); goto loop;} //mov
      case _FMTR0R0NX4:   {err_onlylowregs(); i = asmpopvalue()>>2; asmbyte((BYTE)(i<<6)+(_reg<<0x03)+_oldreg); asmbyte(_base + (BYTE)(i>>2)); goto loop;}
      case _FMTR0R0R0:    {IF ((_reg>=0x08) || (_oldreg>=0x08) || (_veryoldreg>=0x08)) errwrongreg(); asmbyte((_veryoldreg<<0x06)+(_reg<<0x03)+_oldreg); asmbyte(_base+(_veryoldreg>>0x02)); goto loop;}
      case _FMTR0R0N7:    {err_onlylowregs(); i = asmpopvalue(); asmbyte((BYTE)(i<<6)+(_reg<<0x03)+_oldreg); asmbyte(_base + (BYTE)(i>>2)); goto loop;} //alu
      case _FMTR0R0N31:   {err_onlylowregs(); i = asmpopvalue(); asmbyte((BYTE)(i<<6)+(_reg<<0x03)+_oldreg); asmbyte(_baseN + (BYTE)(i>>2)); goto loop;} //shifts
      case _FMTR0R0ZERO:  {err_onlylowregs(); i = asmpopvalue(); asmbyte(_base2+(_reg<<0x03)+_oldreg); asmbyte(_base); goto loop;} //rsbs r0,r1,#0
      case _FMTRADDR:     {IF (_reg>=0x08) errwrongreg(); asmdispconst((UINT)asmpopvalue()-(((_curaddr+_curshift-_BIAS/**bias (thumb)*/)+4)&0xfffffffc)); asmbyte(_baseN+_reg); goto loop;}
      case _FMTBSHORTADDR:{asmdispbshort((INT)((UINT)asmpopvalue()-((_curaddr+_curshift-_BIAS/**bias (thumb)*/)+4))); goto loop;}
      case _FMTBADDR:     {asmdispb((INT)((UINT)asmpopvalue()-((_curaddr+_curshift-_BIAS/**bias (thumb)*/)+4))); goto loop;}
      case _FMTBLONGADDR: {asmdispbl((INT)(asmpopvalue()-(LONG)((_curaddr+_curshift-_BIAS/**bias (thumb)*/)+4))); goto loop;}
      case _FMTPUSHPOP:   {
        IF ((_reglist&0x3f00)!=0) errwrongreg();
        asmbyte((BYTE)_reglist);
        IF (_reglist>=0x4000) {
          IF ( ((_reglist&0x8000)!=0) && (_base==0xb4) ) errwrongreg(); //no push {pc}
          IF ( ((_reglist&0x4000)!=0) && (_base==0xbc) ) errwrongreg(); //no pop {lr}
          asmbyte(_base+0x01);
        }ELSE asmbyte(_base);
      }

      case _RG_R0:
      case _RG_R1:
      case _RG_R2:
      case _RG_R3:
      case _RG_R4:
      case _RG_R5:
      case _RG_R6:
      case _RG_R7:
      case _RG_R8:
      case _RG_R9:
      case _RG_R10:
      case _RG_R11:
      case _RG_R12:
      case _RG_SP:
      case _RG_LR:
      case _RG_PC:
//      case _RG_RPBYNAME:

        {
        _veryoldreg = _oldreg;
        _oldreg = _reg;
        _reg = _token-_RG_R0;
        _reglist = _reglist | (1<<(UINT)_reg);
        goto loop;
        }

