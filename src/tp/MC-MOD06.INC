{.PA}
{*******************************************************************}
{*  SOURCE CODE MODULE: MC-MOD05                                   *}
{*  PURPOSE:            Read the contents of a cell and update     *}
{*                      associated cells.                          *}
{*******************************************************************}


{ Procedure GetLine will let the user type and/or edit a string of   }
{ maximum length "MAX". The string will start at cursor position:    }
{ ColNO,LineNO. If ErrPos <> 0 then the cursor will jump to position }
{ ErrPos in the string. If the last parameter is "True" then all     }
{ characters entered will be translated to upper case.               }
{ If the user at anytimes types <ESCAPE> then the string returned    }
{ contain $FF to indicate that editing was aborted.                  }


procedure GetLine(var S: AnyString;           { String to edit       }
                         ColNO,LineNO,        { Where start line     }
                         MAX,                 { Max length           }
                         ErrPos: integer;     { Where to begin       }
                         UpperCase:Boolean);  { True if auto Upcase  }
var
  X: integer;
  InsertOn: boolean;
  OkChars: set of Char;


  procedure GotoX;
  begin
    GotoXY(X+ColNo-1,LineNo);
  end;

begin
  OkChars:=[' '..'}'];
  InsertOn:=true;
  X:=1; GotoX;
  Write(S);
  if Length(S)=1 then X:=2;
  if ErrPos<>0 then X:=ErrPos;
  GotoX;
  repeat
    Read(Kbd,Ch);
    if UpperCase then Ch:=UpCase(Ch);
    case Ch of
       ^[: begin
             S:=chr($FF); { abort editing }
             Ch:=^M;
           end;
       #251{^D}: begin { Move cursor right }
             X:=X+1;
             if (X>length(S)+1) or (X>MAX) then X:=X-1;
             GotoX;
           end;
       #252{^G}: begin { Delete right char }
             if X<=Length(S) then
             begin
               Delete(S,X,1);
               Write(copy(S,X,Length(S)-X+1),' ');
               GotoX;
             end;
           end;
    #248{^S,^H}: begin { Move cursor left }
             X:=X-1;
             if X<1 then X:=1;
             GotoX;
           end;
       #30{^F}: begin { Move cursor to end of line }
              X:=Length(S)+1;
              GotoX;
           end;
       #28{^A}: begin { Move cursor to beginning of line }
             X:=1;
             GotoX;
           end;
     #8{#127}: begin { Delete left char }
             X:=X-1;
             if (Length(S)>0) and (X>0)  then
             begin
               Delete(S,X,1);
               Write(copy(S,X,Length(S)-X+1),' ');
               GotoX;
               if X<1 then X:=1;
             end else X:=1;
           end;
       #29{^V}: InsertOn:= not InsertOn;

{.PA}

    else
      begin
        if Ch in OkChars  then
        begin
          if InsertOn then
          begin
            insert(Ch,S,X);
            Write(copy(S,X,Length(S)-X+1),' ');
          end else
          begin
            write(Ch);
            if X=length(S) then S:=S+Ch
              else S[X]:=Ch;
          end;
          if Length(S)+1<=MAX then X:=X+1
          else OkChars:=[]; { Line too Long }
          GotoX;
        end else
        if Length(S)+1<=Max then
          OkChars:= [' '..'}']; { Line ok again }
      end;
    end;
  until CH=^M;
end;


{.PA}


procedure  GetCell(FX: ScreenIndex;FY: Integer);
var
  S:             AnyString;
  NewStat:       Set of Attributes;
  ErrorPosition: Integer;
  I:             ScreenIndex;
  Result:        Real;
  Abort:         Boolean;
  IsForm:        Boolean;

{ Procedure ClearCells clears the current cell and its associated    }
{ cells. An associated cell is a cell overwritten by data from the   }
{ current cell. The data can be text in which case the cell has the  }
{ attribute "OverWritten". If the data is a result from an expression}
{ and the field with is larger tahn 11 then the cell is "Locked"     }

  procedure ClearCells;
  begin
    I:=FX;
    repeat
      with Screen[I,FY] do
      begin
        GotoXY(XPos[I],FY+1);
        write('           '); I:=Succ(I);
      end;
    until ([OverWritten,Locked]*Screen[I,FY].CellStatus=[]);
    { Cell is not OVerWritten not Locked }
  end;

{.CP20}
{ The new type of the cell is flashed at the bottom of the screen    }
{ Notice that a constant of type array is used to indicate the type  }

  procedure FlashType;
  begin
    LowVideo;
    GotoXY(5,23);
    NormVideo;
  end;

