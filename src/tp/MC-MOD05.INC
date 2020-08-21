{.PA}

        begin { SignedFactor }
          if Ch='-' then
          begin
            NextCh; SignedFactor:=-Factor;
          end else SignedFactor:=Factor;
        end { SignedFactor };

      begin { Term }
        T:=SignedFactor;
        while Ch='^' do
        begin
          NextCh; t:=exp(ln(t)*SignedFactor);
        end;
        Term:=t;
      end { Term };


    begin { SimpleExpression }
      s:=term;
      while Ch in ['*','/'] do
      begin
        Opr:=Ch; NextCh;
        case Opr of
          '*': s:=s*term;
          '/': s:=s/term;
        end;
      end;
      SimpleExpression:=s;
    end { SimpleExpression };

  begin { Expression }
    E:=SimpleExpression;
    while Ch in ['+','-'] do
    begin
      Opr:=Ch; NextCh;
      case Opr of
        '+': e:=e+SimpleExpression;
        '-': e:=e-SimpleExpression;
      end;
    end;
    Expression:=E;
  end { Expression };


begin { procedure Evaluate }
  if Formula[1]='.' then Formula:='0'+Formula;
  if Formula[1]='+' then delete(Formula,1,1);
  IsFormula:=false;
  Pos:=0; NextCh;
  Value:=Expression;
  if Ch=EofLine then ErrPos:=0 else ErrPos:=Pos;
end { Evaluate };

{.PA}

procedure Recalculate;
var
  RFX: ScreenIndex;
  RFY:integer;
  OldValue: real;
  Err: integer;

begin
  NormVideo;
  GotoXY(1,24); ClrEol;
  Write('Calculating..');
  for RFY:=1 to FYMax do
  begin
    for RFX:='A' to FXMax do
    begin
      with Screen[RFX,RFY] do
      begin
        if (Formula in CellStatus) then
        begin
          CellStatus:=CellStatus+[Calculated];
          OldValue:=Value;
          Evaluate(Form,Contents,Value,Err);
          if OldValue<>Value then
          begin
            GotoXY(XPos[RFX],RFY+1);
            if (DEC>=0) then Write(Value:FW:DEC)
            else Write(Value:FW);
          end;
        end;
      end;
    end;
  end;
  GotoCell(FX,FY);
end;

