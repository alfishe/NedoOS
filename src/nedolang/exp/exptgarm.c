VAR PCHAR _texttoken[+256];

PROC asmfilltokens()
{
//начиная отсюда зависит от таргета
  _texttoken[+_RG_R0]="r0";
  _texttoken[+_RG_R1]="r1";
  _texttoken[+_RG_R2]="r2";
  _texttoken[+_RG_R3]="r3";
  _texttoken[+_RG_R4]="r4";
  _texttoken[+_RG_R5]="r5";
  _texttoken[+_RG_R6]="r6";
  _texttoken[+_RG_R7]="r7";
  _texttoken[+_RG_R8]="r8";
  _texttoken[+_RG_R9]="r9";
  _texttoken[+_RG_R10]="r10";
  _texttoken[+_RG_R11]="r11";
  _texttoken[+_RG_R12]="r12";
  _texttoken[+_RG_SP]="sp";
  _texttoken[+_RG_LR]="lr";
  _texttoken[+_RG_PC]="pc";
  _texttoken[+_RG_RPBYNAME]="rp";

  _texttoken[+_ASMNOP ]="nop";

  _texttoken[+_ASMADR]="adr";

  _texttoken[+_ASMADCS]="adcs";
  _texttoken[+_ASMADDS]="adds";
  _texttoken[+_ASMSBCS]="sbcs";
  _texttoken[+_ASMSUBS]="subs";
  _texttoken[+_ASMRSBS]="rsbs";
  _texttoken[+_ASMCMN]="cmn";
  _texttoken[+_ASMCMP]="cmp";
  _texttoken[+_ASMTST]="tst";
  _texttoken[+_ASMNEG]="neg";
  _texttoken[+_ASMMULS]="muls";

  _texttoken[+_ASMANDS]="ands";
  _texttoken[+_ASMORRS]="orrs";
  _texttoken[+_ASMEORS]="eors";

  _texttoken[+_ASMASRS]="asrs";
  _texttoken[+_ASMLSLS]="lsls";
  _texttoken[+_ASMLSRS]="lsrs";
  _texttoken[+_ASMRORS]="rors";

  _texttoken[+_ASMB]="b";
  _texttoken[+_ASMBEQ]="beq";
  _texttoken[+_ASMBNE]="bne";
  _texttoken[+_ASMBCS]="bcs";
  _texttoken[+_ASMBCC]="bcc";
  _texttoken[+_ASMBMI]="bmi";
  _texttoken[+_ASMBPL]="bpl";
  _texttoken[+_ASMBVS]="bvs";
  _texttoken[+_ASMBVC]="bvc";
  _texttoken[+_ASMBHI]="bhi";
  _texttoken[+_ASMBLS]="bls";
  _texttoken[+_ASMBGE]="bge";
  _texttoken[+_ASMBLT]="blt";
  _texttoken[+_ASMBGT]="bgt";
  _texttoken[+_ASMBLE]="ble";
  _texttoken[+_ASMBAL]="bal";
  _texttoken[+_ASMBL]="bl";
  _texttoken[+_ASMBLX]="blx";
  _texttoken[+_ASMBX]="bx";

  _texttoken[+_ASMBICS]="bics";

  _texttoken[+_ASMBKPT]="bkpt";

  _texttoken[+_ASMDMB]="dmb";
  _texttoken[+_ASMDSB]="dsb";
  _texttoken[+_ASMISB]="isb";
  _texttoken[+_ASMCPSID]="cpsid";
  _texttoken[+_ASMCPSIE]="cpsie";
  _texttoken[+_ASMSEV]="sev";
  _texttoken[+_ASMSVC]="svc";
  _texttoken[+_ASMYIELD]="yield";

  _texttoken[+_ASMLDR]="ldr";
  _texttoken[+_ASMLDRB]="ldrb";
  _texttoken[+_ASMLDRH]="ldrh";
  _texttoken[+_ASMLDRSB]="ldrsb";
  _texttoken[+_ASMLDRSH]="ldrsh";
  _texttoken[+_ASMLDM]="ldm";
  _texttoken[+_ASMLDMFD]="ldmfd";
  _texttoken[+_ASMLDMIA]="ldmia";
  _texttoken[+_ASMSTR]="str";
  _texttoken[+_ASMSTRB]="strb";
  _texttoken[+_ASMSTRH]="strh";
  _texttoken[+_ASMSTM]="stm";
  _texttoken[+_ASMSTMEA]="stmea";
  _texttoken[+_ASMSTMIA]="stmia";

  _texttoken[+_ASMMOV]="mov";
  _texttoken[+_ASMMOVS]="movs";
  _texttoken[+_ASMMVNS]="mvns";
  _texttoken[+_ASMMRS]="mrs";
  _texttoken[+_ASMMSR]="msr";
  _texttoken[+_ASMCPY]="cpy";

  _texttoken[+_ASMPOP]="pop";
  _texttoken[+_ASMPUSH]="push";

  _texttoken[+_ASMREV]="rev";
  _texttoken[+_ASMREV16]="rev16";
  _texttoken[+_ASMREVSH]="revsh";
  _texttoken[+_ASMSXTB]="sxtb";
  _texttoken[+_ASMSXTH]="sxth";
  _texttoken[+_ASMUXTB]="uxtb";
  _texttoken[+_ASMUXTH]="uxth";

  _texttoken[+_TOKOPENBRACE]="{";
  _texttoken[+_TOKCLOSEBRACE]="}";

}

