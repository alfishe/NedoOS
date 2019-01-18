VAR PCHAR _texttoken[+256];

PROC asmfilltokens()
{
//начиная отсюда зависит от таргета
  _texttoken[+_ASMNZ]="nz";
  _texttoken[+_ASMZ]="z";
  _texttoken[+_ASMNC]="nc";
  _texttoken[+_ASMC]="c";
  _texttoken[+_ASMPO]="po";
  _texttoken[+_ASMPE]="pe";
  _texttoken[+_ASMP]="p";
  _texttoken[+_ASMM]="m";

  _texttoken[+_ASMEX]="ex";

  _texttoken[+_ASMRET]="ret";
  _texttoken[+_ASMDJNZ]="djnz";
  _texttoken[+_ASMJR]="jr";
  _texttoken[+_ASMJP]="jp";
  _texttoken[+_ASMCALL]="call";

  _texttoken[+_ASMLD]="ld";

  _texttoken[+_ASMADD]="add";
  _texttoken[+_ASMADC]="adc";
  _texttoken[+_ASMSUB]="sub";
  _texttoken[+_ASMSBC]="sbc";
  _texttoken[+_ASMAND]="and";
  _texttoken[+_ASMXOR]="xor";
  _texttoken[+_ASMOR ]="or";
  _texttoken[+_ASMCP ]="cp";

  _texttoken[+_ASMINC]="inc";
  _texttoken[+_ASMDEC]="dec";

  _texttoken[+_ASMRST]="rst";

  _texttoken[+_ASMOUT]="out";
  _texttoken[+_ASMIN]="in";

  _texttoken[+_ASMPOP]="pop";
  _texttoken[+_ASMPUSH]="push";

  _texttoken[+_ASMRLC]="rlc";
  _texttoken[+_ASMRRC]="rrc";
  _texttoken[+_ASMRL ]="rl";
  _texttoken[+_ASMRR ]="rr";
  _texttoken[+_ASMSLA]="sla";
  _texttoken[+_ASMSRA]="sra";
  _texttoken[+_ASMSLI]="sli";
  _texttoken[+_ASMSRL]="srl";

  _texttoken[+_ASMBIT]="bit";
  _texttoken[+_ASMRES]="res";
  _texttoken[+_ASMSET]="set";

  _texttoken[+_ASMIM]="im";

  _texttoken[+_ASMRLCA]="rlca";
  _texttoken[+_ASMRRCA]="rrca";
  _texttoken[+_ASMRLA ]="rla";
  _texttoken[+_ASMRRA ]="rra";
  _texttoken[+_ASMDAA ]="daa";
  _texttoken[+_ASMCPL ]="cpl";
  _texttoken[+_ASMSCF ]="scf";
  _texttoken[+_ASMCCF ]="ccf";
  _texttoken[+_ASMNOP ]="nop";
  _texttoken[+_ASMHALT]="halt";
  _texttoken[+_ASMDI  ]="di";
  _texttoken[+_ASMEI  ]="ei";
  _texttoken[+_ASMEXX ]="exx";

  _texttoken[+_ASMRETN]="retn";
  _texttoken[+_ASMRETI]="reti";
  _texttoken[+_ASMLDI ]="ldi";
  _texttoken[+_ASMLDD ]="ldd";
  _texttoken[+_ASMLDIR]="ldir";
  _texttoken[+_ASMLDDR]="lddr";
  _texttoken[+_ASMCPI ]="cpi";
  _texttoken[+_ASMCPD ]="cpd";
  _texttoken[+_ASMCPIR]="cpir";
  _texttoken[+_ASMCPDR]="cpdr";
  _texttoken[+_ASMINI ]="ini";
  _texttoken[+_ASMIND ]="ind";
  _texttoken[+_ASMINIR]="inir";
  _texttoken[+_ASMINDR]="indr";
  _texttoken[+_ASMOUTI]="outi";
  _texttoken[+_ASMOUTD]="outd";
  _texttoken[+_ASMOTIR]="otir";
  _texttoken[+_ASMOTDR]="otdr";
  _texttoken[+_ASMINF ]="inf";
  _texttoken[+_ASMNEG ]="neg";

  _texttoken[+_RG_B]="b";
  _texttoken[+_RG_C]="c";
  _texttoken[+_RG_D]="d";
  _texttoken[+_RG_E]="e";
  _texttoken[+_RG_H]="h";
  _texttoken[+_RG_L]="l";
  _texttoken[+_RG_A]="a";
  _texttoken[+_RG_HX]="hx";
  _texttoken[+_RG_LX]="lx";
  _texttoken[+_RG_HY]="hy";
  _texttoken[+_RG_LY]="ly";
  _texttoken[+_RG_I]="i";
  _texttoken[+_RG_R]="r";
  _texttoken[+_RG_RBBYNAME]="rb";

  _texttoken[+_RG_BC]="bc";
  _texttoken[+_RG_DE]="de";
  _texttoken[+_RG_HL]="hl";
  _texttoken[+_RG_SP]="sp";
  _texttoken[+_RG_IX]="ix";
  _texttoken[+_RG_IY]="iy";
  _texttoken[+_RG_AF]="af";
  _texttoken[+_RG_RPBYNAME]="rp";

  //_texttoken[+FMT_ALUCMDRB]="";
  //_texttoken[+FMT_ALUCMDMHL]="";
  //_texttoken[+FMT_ALUCMDINDEX]="";
  //_texttoken[+FMT_INCRP]="";
}

