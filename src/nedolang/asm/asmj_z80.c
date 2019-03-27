//// машиннозависимые ветки
      case _TOKCOMMA: {_oldreg = _reg;/**не трогаем value! его сдвинет только другое value!*/ goto loop;}

      case _ASMNZ: {_base=_base2/**+0x00*/; goto loop;}
      case _ASMZ:  {_base=_base2+0x08; goto loop;}
      case _ASMNC: {_base=_base2+0x10; goto loop;}
      case _ASMC:  {_base=_base2+0x18; goto loop;}
      case _ASMPO: {_base=_base2+0x20; goto loop;}
      case _ASMPE: {_base=_base2+0x28; goto loop;}
      case _ASMP:  {_base=_base2+0x30; goto loop;}
      case _ASMM:  {_base=_base2+0x38; goto loop;}

      case _ASMEX:
      case _ASMLD:
      case _ASMRST:
      case _ASMIM:

        {_isaddr = 0x00; goto loop;}

      case _ASMRET: {_base=0xc9; _base2=0xc0;/**cc меняет базу1 на базу2+8*cc*/ goto loop;}
      case _ASMDJNZ:{_base=0x10; goto loop;}
      case _ASMJR:  {_base=0x18; _base2=0x20;/**cc меняет базу1 на базу2+8*cc*/ goto loop;}
      case _ASMJP:  {_isaddr = 0x00; _base=0xc3; _base2=0xc2;/**cc меняет базу1 на базу2+8*cc*/ goto loop;}
      case _ASMCALL:{_isaddr = 0x00; _base=0xcd; _base2=0xc4;/**cc меняет базу1 на базу2+8*cc*/ goto loop;}

      case _ASMADD: {_base=0x80;/**+0x46 для N*/ goto loop;}
      case _ASMADC: {_base=0x88;/**+0x46 для N*/ goto loop;}
      case _ASMSUB: {_base=0x90;/**+0x46 для N*/ goto loop;}
      case _ASMSBC: {_base=0x98;/**+0x46 для N*/ goto loop;}
      case _ASMAND: {_base=0xa0;/**+0x46 для N*/ goto loop;}
      case _ASMXOR: {_base=0xa8;/**+0x46 для N*/ goto loop;}
      case _ASMOR:  {_base=0xb0;/**+0x46 для N*/ goto loop;}
      case _ASMCP:  {_base=0xb8;/**+0x46 для N*/ goto loop;}

      case _ASMINC: {_base=0x04; goto loop;}
      case _ASMDEC: {_base=0x05; goto loop;}

      case _ASMOUT: {_base=0x8d/**0xd3-0x46*/;/**чтобы через alucmdn*/ goto loop;}
      case _ASMIN:  {_base=0x95/**0xdb-0x46*/;/**чтобы через alucmdn*/ goto loop;}

      case _ASMPOP: {_base=0xc1; goto loop;}
      case _ASMPUSH:{_base=0xc5; goto loop;}

      case _ASMRLC: {_base=0x00; goto loop;}
      case _ASMRRC: {_base=0x08; goto loop;}
      case _ASMRL:  {_base=0x10; goto loop;}
      case _ASMRR:  {_base=0x18; goto loop;}
      case _ASMSLA: {_base=0x20; goto loop;}
      case _ASMSRA: {_base=0x28; goto loop;}
      case _ASMSLI: {_base=0x30; goto loop;}
      case _ASMSRL: {_base=0x38; goto loop;}

      case _ASMBIT: {_base=0x40; goto loop;}
      case _ASMRES: {_base=0x80; goto loop;}
      case _ASMSET: {_base=0xc0; goto loop;}

      case _ASMRLCA:{_base=0x07; goto loop;}
      case _ASMRRCA:{_base=0x0f; goto loop;}
      case _ASMRLA: {_base=0x17; goto loop;}
      case _ASMRRA: {_base=0x1f; goto loop;}
      case _ASMDAA: {_base=0x27; goto loop;}
      case _ASMCPL: {_base=0x2f; goto loop;}
      case _ASMSCF: {_base=0x37; goto loop;}
      case _ASMCCF: {_base=0x3f; goto loop;}
      case _ASMNOP: {_base=0x00; goto loop;}
      case _ASMHALT:{_base=0x76; goto loop;}
      case _ASMDI:  {_base=0xf3; goto loop;}
      case _ASMEI:  {_base=0xfb; goto loop;}
      case _ASMEXX: {_base=0xd9; goto loop;}

      case _ASMRETN:{asmbyte_ed(); _base=0x45; goto loop;}
      case _ASMRETI:{asmbyte_ed(); _base=0x4d; goto loop;}
      case _ASMLDI: {asmbyte_ed(); _base=0xa0; goto loop;}
      case _ASMLDD: {asmbyte_ed(); _base=0xa8; goto loop;}
      case _ASMLDIR:{asmbyte_ed(); _base=0xb0; goto loop;}
      case _ASMLDDR:{asmbyte_ed(); _base=0xb8; goto loop;}
      case _ASMCPI: {asmbyte_ed(); _base=0xa1; goto loop;}
      case _ASMCPD: {asmbyte_ed(); _base=0xa9; goto loop;}
      case _ASMCPIR:{asmbyte_ed(); _base=0xb1; goto loop;}
      case _ASMCPDR:{asmbyte_ed(); _base=0xb9; goto loop;}
      case _ASMINI: {asmbyte_ed(); _base=0xa2; goto loop;}
      case _ASMIND: {asmbyte_ed(); _base=0xaa; goto loop;}
      case _ASMINIR:{asmbyte_ed(); _base=0xb2; goto loop;}
      case _ASMINDR:{asmbyte_ed(); _base=0xba; goto loop;}
      case _ASMOUTI:{asmbyte_ed(); _base=0xa3; goto loop;}
      case _ASMOUTD:{asmbyte_ed(); _base=0xab; goto loop;}
      case _ASMOTIR:{asmbyte_ed(); _base=0xb3; goto loop;}
      case _ASMOTDR:{asmbyte_ed(); _base=0xbb; goto loop;}
      case _ASMINF: {asmbyte_ed(); _base=0x70; goto loop;}
      case _ASMNEG: {asmbyte_ed(); _base=0x44; goto loop;}

      case _FMTMOVRBRB:   {IF ((_reg|_oldreg)>=+_ASMRBIXADD)asmrbrb_ixiyprefix(); asmbyte((_reg>>0x03)+_oldreg+0x40); goto loop;} //<ld><_reg><commakeepreg><_reg><writemovrbrb> - формат проверяет ошибку (?x,?y / ?y,?x / ?x/y,h/l / h/l,?x/y), пишет dd/fd и код (пересчитывает индексные половинки в h/l)
      case _FMTMOVAIR:    {asmbyte_ed(); asmbyte(_reg+0x57); goto loop;} //<ld><_reg(==A)><commakeepreg><regIR><writemovair>
      case _FMTMOVIRA:    {asmbyte_ed(); asmbyte(_oldreg+0x47); goto loop;} //<ld><regIR><commakeepreg><_reg(==A)><writemovira>
      case _FMTMOVRPRP:   {asmcheckrp_ixiyprefix(); IF ((_oldreg!=_ASMRPCODE_SP)||(_reg!=_ASMRPCODE_HL))errwrongreg(); asmbyte(0xf9); goto loop;} //<ld><rp(==SP)><comma><rp><writemovrprp> - в формате вручную проверить rp (ошибка при bc,de,sp) и писать dd/fd (можно реализовать ld bc,de и т.п.)
      case _FMTLDRBN:     {IF (_oldreg>=_ASMRBIXADD)asmoldrb_ixiyprefix(); asmbyte(_oldreg+0x06); asmbytepopvalue(); goto loop;} //<ld><rp><comma><num>LH<writeldrbN> - в формате вручную проверить rp и писать dd/fd
      case _FMTLDRPNN:    {asmcheckoldrp_ixiyprefix(); asmbyte(_oldreg+0x01); asmwordpopvalue(); goto loop;} //<ld><rp><comma><num>LH<writeldrpNN> - в формате вручную проверить rp и писать dd/fd
      case _FMTGETAMRP:   {asmcheckrp_ixiyprefix(); IF (_reg==_ASMRPCODE_HL){asmbyte(0x7e);}ELSE IF (_reg==_ASMRPCODE_SP){errwrongreg();}ELSE asmbyte(_reg+0x0a); goto loop;} //<ld><_reg(==A)><commakeepreg><(><rp><)><writegetamrp> - аккумулятор неподменяемый!!! ошибка при sp, отдельный опкод для hl
      case _FMTGETAMNN:   {asmbyte(0x3a); asmwordpopvalue(); goto loop;} //<ld><_reg(==A)><comma><(><num>LH<)><writegetamNN> - аккумулятор неподменяемый!!!
      case _FMTGETRBMHL:  {err_oldrbix(); asmbyte(_oldreg+0x46); goto loop;} //<ld><_reg><commakeepreg><(><rp(==HL)><)><writegetrbmhl> - ошибка при индексных половинках _reg
      case _FMTGETRBIDX:  {err_oldrbix(); asmrp_ixiyprefix(); asmbyte(_oldreg+0x46); asmdisppopvalue(); goto loop;} //writegetrbindex: <ld><_reg><commakeepreg><(><rp(==IX/IY)><num>LH<)><writegetrbindex>: ix/iy неподменяемый, иначе токенизатор не определит формат! пишет dd/fd,индексные половинки==ошибка
      case _FMTGETRPMNN:  {asmcheckoldrp_ixiyprefix(); IF (_oldreg==_ASMRPCODE_HL){asmbyte(0x2a);}ELSE {asmbyte_ed();asmbyte(_oldreg+0x4b);}; asmwordpopvalue(); goto loop;} //<ld><rp><comma><num>LH<writegetrpmNN> - в формате вручную проверить rp и писать dd/fd
      case _FMTPUTMHLRB:  {err_rbix(); asmbyte((_reg>>0x03)+0x70); goto loop;} //<ld><(><rp(==HL)><)><comma><_reg><writeputmhlrb> - hl неподменяемый!!! индексные половинки==ошибка
      case _FMTPUTMHLN:   {asmbyte(0x36); asmbytepopvalue(); goto loop;} //<ld><(><rp(==HL)><)><comma><num>LH<writeputmhlN> - hl неподменяемый!!!
      case _FMTPUTIDXRB:  {err_rbix(); asmoldrp_ixiyprefix(); asmbyte((_reg>>0x03)+0x70); asmdisppopvalue(); goto loop;} //<ld><(><rp(==IX/IY)><num>LH<)><commakeepreg><_reg><writeputindexrb>: ix/iy неподменяемый, иначе токенизатор не определит формат! пишет dd/fd,индексные половинки==ошибка
      case _FMTPUTIDXN:   {asmrp_ixiyprefix(); asmbyte(0x36); tempvalue=asmpopvalue(); asmdisppopvalue(); asmbyte(+(BYTE)tempvalue); goto loop;} //<ld><(><rp(==IX/IY)><num>LH<)><comma><num>LH<writeputindexN> - ix/iy неподменяемый (иначе токенизатор не определит формат)! формат пишет dd/fd
      case _FMTPUTMRPA:   {asmcheckoldrp_ixiyprefix(); IF (_oldreg==_ASMRPCODE_HL){asmbyte(0x77);}ELSE IF (_oldreg==_ASMRPCODE_SP){errwrongreg();}ELSE asmbyte(_oldreg+0x02); goto loop;} //<ld><(><rp><)><commakeepreg><_reg(==A)><writeputmrpa> - аккумулятор неподменяемый!!! ошибка при sp, отдельный опкод для hl
      case _FMTPUTMNNA:   {asmbyte(0x32); asmwordpopvalue(); goto loop;} //<ld><(><num>LH<)><comma><_reg(==A)><writeputmNNa> - аккумулятор неподменяемый!!!
      case _FMTPUTMNNRP:  {asmcheckrp_ixiyprefix(); IF (_reg==_ASMRPCODE_HL){asmbyte(0x22);}ELSE {asmbyte_ed();asmbyte(_reg+0x43);}; asmwordpopvalue(); goto loop;} //writeputmNNrp(==writeputmNNa?): <ld><(><num>LH<)><comma><rp><writeputmNNrp> - в формате вручную проверить rp и писать dd/fd

      case _FMTALUCMDN:   {asmbyte(_base+0x46); asmbytepopvalue(); goto loop;} //<sbc><_reg(==A)><comma><num>LH<writealucmdN> - аккумулятор неподменяемый!!! формат (БАЗА1) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
      case _FMTALUCMDRB:  {asmcheckrb_ixiyprefix();/**IF (_reg>=_ASMRBIXADD)asmrb_ixiyprefix();*/ asmbyte((_reg>>0x03)+_base); goto loop;} //<sbc><_reg(==A)><comma><rp><writealucmdrb> - аккумулятор неподменяемый!!! формат (БАЗА2) пишет dd/fd при использовании индексной половинки и пересчитывает её в h/l
      case _FMTALUCMDMHL: {asmbyte(_base+0x06); goto loop;} //<sbc><_reg(==A)><comma><(><rp(==HL)><)><writealucmdmhl> - аккум.неподменяемый! hl тоже
      case _FMTALUCMDIDX: {asmrp_ixiyprefix(); asmbyte(_base+0x06); asmdisppopvalue(); goto loop;} //<sbc><_reg(==A)><comma><(><rp(==IX/IY)><num>LH<)><writealucmdindex> - аккум.неподменяемый! ix/iy тоже (иначе токенизатор не определит формат)! формат пишет dd/fd,БАЗА2
      case _FMTADDHLRP:   {/**IF ((_reg|_oldreg)>=_ASMRPIXADD)*/asmrprp_ixiyprefix(); asmbyte(_reg+0x09); goto loop;} //<add><rp(==HL/IX/IY)><commakeepreg><rp><writeaddhlrp> - формат проверяет rp1, rp2 и пишет dd/fd (add ix,iy, add iy,ix, add ix/iy,hl, add hl,ix/iy - ошибка)
      case _FMTADCHLRP:   {err_rpix(); asmbyte_ed(); asmbyte(_reg+0x4a); goto loop;} //<adc><rp(==HL)><comma><rp><writeadchlrp> - формат проверяет rp (ix/iy - ошибка)
      case _FMTSBCHLRP:   {err_rpix(); asmbyte_ed(); asmbyte(_reg+0x42); goto loop;} //<sbc><rp(==HL)><comma><rp><writesbchlrp> - формат проверяет rp (ix/iy - ошибка)
      case _FMTINCRP:     {asmcheckrp_ixiyprefix(); asmbyte(_reg+0x03); goto loop;} //можно через проверку кода регистра в inc (индексные половинки проверяем)
      case _FMTDECRP:     {asmcheckrp_ixiyprefix(); asmbyte(_reg+0x0b); goto loop;} //можно через проверку кода регистра в dec (индексные половинки проверяем) (или через вторую базу writedecrp==writeincrp?)
      case _FMTINCDECRB:  {asmcheckrb_ixiyprefix();/**IF (_reg>=_ASMRBIXADD)asmrb_ixiyprefix();*/ asmbyte(_base+_reg); goto loop;}
      case _FMTINCDECMHL: {asmbyte(_base+0x30); goto loop;}
      case _FMTINCDECIDX: {asmrp_ixiyprefix(); asmbyte(_base+0x30); asmdisppopvalue(); goto loop;}

      case _FMTEXRPRP:    {IF (_oldreg==_ASMRPCODE_DE){asmbyte(0xeb);}ELSE IF (_reg==_ASMRPCODE_AF){asmbyte(0x08);}ELSE /**IF (_oldreg==_ASMRPCODE_SP)*/{IF (_reg>=_ASMRPIXADD){asmrp_ixiyprefix();}; asmbyte(0xe3);}; goto loop;} //<ex><rp><commakeepreg><rp><writeexrprp>
      case _FMTJRDD:      {asmbyte(_base); asmdisp(+(INT)(+(UINT)asmpopvalue()-((_curaddr+_curshift)+1))); goto loop;} //<jr><cc><comma><num>LH<writejr> - пишет смещение от $ и отслеживает ошибку - cc меняет базу1 на базу2+8*cc
      case _FMTJPNN:      {asmbyte(_base); asmwordpopvalue(); goto loop;} //<call><cc><comma><num>LH<writejp> - cc меняет базу1 на базу2+8*cc
      case _FMTJPRP:      {asmcheckrp_ixiyprefix(); IF (_reg!=_ASMRPCODE_HL)errwrongreg(); asmbyte(0xe9); goto loop;}  //<jp><rp><writejprp> - можно использовать скобки, они ни на что не будут влиять. Надо проверить rp и выдать ошибку - можно через textcmd?
      case _FMTPUSHPOPRP: {asmcheckrp_ixiyprefix(); asmbyte(_base+_reg); goto loop;}
      case _FMTCBCMDRB:   {err_rbix(); asmbyte(0xcb); asmbyte((_reg>>0x03)+_base); goto loop;} //<rlc><_reg><writecbcmd> - формат проверяет _reg (индексные половинки - ошибка) - сама команда rlc и т.п. не может писать префикс, т.к. иногда надо dd/fd, cb
      case _FMTCBCMDMHL:  {asmbyte(0xcb); asmbyte(_base+0x06); goto loop;} //<rlc><(><rp(==HL)><)><writecbcmdmhl> - hl неподменяемый!!! - можно через <writecbcmdindex>, если проверить rp
      case _FMTCBCMDIDX:  {asmrp_ixiyprefix(); asmbyte(0xcb); asmdisppopvalue(); asmbyte(_base+0x06); goto loop;} //<rlc><(><rp(==IX/IY)><num>LH<)><writecbcmdindex> - ix/iy неподменяемый (иначе токенизатор не определит формат)!!! формат пишет dd/fd, cb
      case _FMTRST:       {tempvalue=asmpopvalue(); /**IF ((+(UINT)tempvalue&0xffc7)!=0)errwrongpar();*/ asmbyte(+(BYTE)tempvalue+0xc7); goto loop;} //<rst><num>LH<writerst> - проверяет pseudon (разрешено только 0/8/16/../56, иначе ошибка) можно через textcmd?
      case _OPBIT:        {tempvalue=asmpopvalue(); /**IF ((+(UINT)tempvalue&0xfff8)!=0)errwrongpar();*/ _base=((+(BYTE)tempvalue&0x07)<<0x03)+_base; goto loop;} //для bit/res/set: проверяет pseudon (разрешено только 0..7, иначе ошибка), умножает на 8 и прибавляет к базе опкода
      case _FMTIM:        {asmbyte_ed(); _token=(BYTE)asmpopvalue(); IF (_token==0x00){asmbyte(0x46);}ELSE IF (_token==0x01){asmbyte(0x56);}ELSE /**IF (_token==0x02)*/{asmbyte(0x5e);}/**ELSE errwrongpar()*/; goto loop;} //writeim: проверяет 0..2 (иначе ошибка) и пересчитывает в 46, 56, 5e - можно через textcmd? или пропускать пробел вручную и вообще без формата (или writealucmd, или writecmd)
      case _FMTXX:        {asmbyte(_base); goto loop;} //(нужно только для ret/ret cc и команд без параметров) - можно через writealucmd (в <ret> присвоить регистр), можно ret cc через textcmd или через writejp (если в нём не будет встроена запись числа)
      case _FMTOUTCRB:    {err_rbix(); asmbyte_ed(); asmbyte(_reg+0x41); goto loop;} //out (c),_reg (ed 41+) - проверяет _reg (индексные половинки - ошибка)
      case _FMTINRBC:     {err_oldrbix(); asmbyte_ed(); asmbyte(_oldreg+0x40); goto loop;} //in _reg,(c) (ed 40+) - проверяет _oldreg (индексные половинки - ошибка)

      case _RG_B: {_reg = _ASMRBCODE_B; goto loop;}
      case _RG_C: {_reg = _ASMRBCODE_C; goto loop;}
      case _RG_D: {_reg = _ASMRBCODE_D; goto loop;}
      case _RG_E: {_reg = _ASMRBCODE_E; goto loop;}
      case _RG_H: {_reg = _ASMRBCODE_H; goto loop;}
      case _RG_L: {_reg = _ASMRBCODE_L; goto loop;}
      case _RG_A: {_reg = _ASMRBCODE_A; goto loop;}
      case _RG_HX:{_reg = _ASMRBCODE_HX; goto loop;}
      case _RG_LX:{_reg = _ASMRBCODE_LX; goto loop;}
      case _RG_HY:{_reg = _ASMRBCODE_HY; goto loop;}
      case _RG_LY:{_reg = _ASMRBCODE_LY; goto loop;}
      case _RG_I: {_reg = _ASMRBCODE_I; goto loop;}
      case _RG_R: {_reg = _ASMRBCODE_R; goto loop;}

      case _RG_BC: {_reg = _ASMRPCODE_BC; goto loop;}
      case _RG_DE: {_reg = _ASMRPCODE_DE; goto loop;}
      case _RG_HL: {_reg = _ASMRPCODE_HL; goto loop;}
      case _RG_SP: {_reg = _ASMRPCODE_SP; goto loop;}
      case _RG_AF: {_reg = _ASMRPCODE_AF; goto loop;}
      case _RG_IX: {_reg = _ASMRPCODE_IX; goto loop;}
      case _RG_IY: {_reg = _ASMRPCODE_IY; goto loop;}
