

{.CP20}
{ Procedure GetFormula repeats calling the procedure GetLine and     }
{ Evaluate until the line read by GetLine contains a valid formula.  }
{ Evaluate returns an error position in the string evaluated. If     }
{ this position is non zero GetLine is called. If the user types     }
{ ESC in GetLine to abort the editing then the string returned from  }
{ Getline will contain $FF and te original value of the cell will    }
{ be restored later.                                                 }

  procedure GetFormula;
  begin
    FlashType;
    repeat
      GetLine(S,1,24,70,ErrorPosition,True);
      if S<>Chr($FF) then
      begin
        Evaluate(IsForm,S,Result,ErrorPosition);
        if ErrorPosition<>0 then
          Flash(15,'Error at cursor'+^G,false)
        else Flash(15,'               ',false);
      end;
    until (ErrorPosition=0) or (S=Chr($FF));
    if IsForm then NewStat:=NewStat+[Formula];
  end;

{.CP20}
{ Procedure GetText calls the procedure GetLine with the current     }
{ cells X,Y position as parameters. This means that text entering    }
{ takes place direcly at the cells posion on the screen.             }

  procedure GetText;
  begin
    FlashType;
    with Screen[FX,FY] do GetLine(S,XPos[FX],FY+1,70,ErrorPosition,False);
  end;

{.CP20}
{ Procedure EditCell loads a copy of the current cells contents in   }
{ in the variable S before calling either GetText or GetFormula. In  }
{ this way no changes are made to the current cell.                  }

  procedure EditCell;
  begin
    with Screen[FX,FY] do
    begin
      S:=Contents;
      if Txt in CellStatus then GetText else GetFormula;
    end;
  end;

{.PA}
{ Procedure UpdateCells is a little more complicated. Basically it   }
{ makes sure to tag and untag cells which has been overwritten or    }
{ cleared from data from  another cell. It also updates the current  }
{ with the new type and the contents which still is in the temporaly }
{ variable "S".                                                      }


  procedure UpdateCells;
  var
    Flength: Integer;
  begin
    Screen[FX,FY].Contents:=S;
    if Txt in NewStat {Screen[FX,FY].CellStatus} then
    begin
      I:=FX; FLength:=Length(S);
      repeat
        I:=Succ(I);
        with Screen[I,FY] do
        begin
          FLength:=Flength-11;
          if (Flength>0) then
          begin
            CellStatus:=[Overwritten,Txt];
            Contents:='';
          end else
          begin
            if OverWritten in CellStatus then
            begin
              CellStatus:=[Txt];
              GotoCell(I,FY);LeaveCell(I,FY);
            end;
          end;
        end;
      until (I=FXMax)  or (Screen[I,FY].Contents<>'');
      Screen[FX,FY].CellStatus:=[Txt];
    end else { string changed to formula or constant }
    begin { Event number two }
      I:=FX;
      repeat
        with Screen[I,FY] do
        begin
          if OverWritten in CellStatus then
          begin
            CellStatus:=[Txt];
            Contents:='';
          end;
          I:=Succ(I);
        end;
      until not (OverWritten in Screen[I,FY].CellStatus);
      with Screen[FX,FY] do
      begin
        CellStatus:=[Constant];
        if IsForm then CellStatus:=CellStatus+[Formula];
        Value:=Result;
      end;
    end;
  end;


{.PA}
{ Procedure GetCell finnaly starts here. This procedure uses all     }
{ all the above local procedures. First it initializes the temporaly }
{ variable "S" with the last read character. It then depending on    }
{ this character calls GetFormula, GetText, or EditCell.             }

begin { procedure GetCell }
  S:=Ch; ErrorPosition:=0; Abort:=false;
  NewStat:=[];
  if Ch in ['0'..'9','+','-','.','(',')'] then
  begin
    NewStat:=[Constant];
    if not (Formula in Screen[FX,FY].CellStatus) then
    begin
      GotoXY(11,24); ClrEol;
      ClearCells;
      GetFormula;
    end else
    begin
      Flash(15,'Edit formula Y/N?',true);
      repeat read(Kbd,Ch) until UpCase(CH) in ['Y','N'];
      Flash(15,'                 ',false);
      if UpCase(Ch)='Y' then EditCell Else Abort:=true;
    end;
  end else
  begin
    if Ch=^[ then
    begin
      NewStat:=(Screen[FX,FY].CellStatus)*[Txt,Constant];
      EditCell;
    end else
    begin
      if formula in Screen[FX,FY].CellStatus then
      begin
        Flash(15,'Edit formula Y/N?',true);
        repeat read(Kbd,Ch) until UpCase(CH) in ['Y','N'];
        Flash(15,'                 ',false);
        if UpCase(Ch)='Y' then EditCell Else Abort:=true;
      end else
      begin
        NewStat:=[Txt];
        ClearCells;
        GetText;
      end;
    end;
  end;
  if not Abort then
  begin
    if S<>Chr($FF) then UpDateCells;
    GotoCell(FX,FY);
    if AutoCalc and (Constant in Screen[FX,FY].CellStatus) then Recalculate;
    if Txt in NewStat then
    begin
      GotoXY(3,FY+1); Clreol;
      For I:='A' to FXMax do
      LeaveCell(I,FY);
    end;
  end;
  Flash(15,'                ',False);
  GotoCell(FX,FY);
end;

{.PA}
{ Procedure Format is used to }


procedure Format;
var
  J,FW,DEC,
  FromLine,ToLine: integer;
  Lock:            Boolean;


  procedure GetInt(var I: integer; Max: Integer);
  var
    S: string[8];
    Err: Integer;
    Ch: Char;
  begin
    S:='';
    repeat
      repeat Read(Kbd,Ch) until Ch in ['0'..'9','-',^M];
      if Ch<>^M then
      begin
        Write(Ch); S:=S+Ch;
        Val(S,I,Err);
      end;
    until (I>=Max) or (Ch=^M);
    if I>Max then I:=Max;
  end;

begin
  LowVideo;
  Msg('Format: Enter number of decimals (Max 11):  ');
  GetInt(DEC,11);
  Msg('Enter Cell whith remember if larger than 10 next column will lock: ');
  GetInt(FW,20);
  Msg('From which line in column '+FX+': ');
  GetInt(FromLine,FYMax);
  Msg('To which line in column '+FX+': ');
  GetInt(ToLine,FYMax);
  if FW>10 then Lock:=true else Lock:=False;
  for J:=FromLine to ToLine do
  begin
    Screen[FX,J].DEC:=DEC;
    Screen[FX,J].FW:=FW;
    with Screen[Succ(FX),J] do
    begin
      if Lock then
      begin
        CellStatus:=CellStatus+[Locked,Txt];
        Contents:='';
      end else CellStatus:=CellStatus-[Locked];
    end;
  end;
  LowVideo;
  UpDate;
  GotoCell(FX,FY);
end;


