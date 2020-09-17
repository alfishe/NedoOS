program MicroCalc;
{
    MICROCALC DEMONSTRATION PROGRAM  Version 1.00A

  This program is Copyrighted by Borland International, Inc.
  1983, 1984, 1985 and is hereby donated to the public domain for
  non-commercial use only.


  INSTRUCTIONS
    1.  Compile this program using the TURBO.COM compiler.
        a.  Use the O command from the main menu to select Options.
        b.  Select the C option to generate a .COM file.
        c.  Select the Q option to Quit the Options menu.
        d.  Select the M option to specify the Main file
        e.  Type "MC" and hit <RETURN>
        f.  Type C to compile the program to disk
        g.  Type R to run the program

    2.  Exit the program by typing: /Q
}

{$R-,U-,V-,X-,A+,C-}


const
  FXMax: Char  = 'G';
  FYMax        = 21;

type
  Anystring   = string[255];
  ScreenIndex = 'A'..'G';
  Attributes  = (Constant,Formula,Txt,OverWritten,Locked,Calculated);


  CellRec    = record
    CellStatus: set of Attributes;
    Contents:   String[70];
    Value:      Real;
    DEC,FW:     0..20;
  end;

  Cells      =  array[ScreenIndex,1..FYMax] of CellRec;

const
  XPOS: array[ScreenIndex] of integer = (3,14,25,36,47,58,68);

var
  Screen:        Cells;
  FX:            ScreenIndex;
  FY:            Integer;
  Ch:            Char;
  MCFile:        file of CellRec;
  AutoCalc:      boolean;


{ The following include files contain procedures used in MicroCalc.  }


 {$I MC-MOD00.INC}
 {$I MC-MOD01.INC}
 {$I MC-MOD02.INC}
 {$I MC-MOD03.INC}
 {$I MC-MOD04.INC}
 {$I MC-MOD05.INC}
 {$I MC-MOD06.INC}
 {$I MC-MOD07.INC}



{.PA}

procedure Commands;
begin
  GotoXY(1,24);
  LowVideo;
  Write('/ restore, Quit, Load, Save, Recalculate, Print,  Format, AutoCalc, Help ');
  Read(Kbd,Ch);
  Ch:=UpCase(Ch);
  case Ch of
    'Q': Begin
           NormVideo;
           Halt;
         End;
    'F': Format;
    'S': Save;
    'L': Load;
    'H': Help;
    'R': Recalculate;
    'A': Auto;
    '/': Update;
    'C': Clear;
    'P': Print;
  end;
  Grid;
  GotoCell(FX,FY);
end;


procedure Wellcome;

  procedure Center(S: AnyString);
  var I: integer;
  begin
    for I:=1 to (80-Length(S)) div 2 do Write(' ');
    writeln(S);
  end;

begin { procedure Wellcome }
  ClrScr; GotoXY(1,9);
  Center('Welcome to MicroCalc.  A Turbo demonstation program');
  Center('Copyright 1983 by Borland International Inc. ');
  Center('Press any key for help or <RETURN> to start');
  GotoXY(40,12);
  Read(Kbd,Ch);
  if Ch<>^M then Help;
end;

{.PA}

begin
  Init;
  Wellcome;
  ClrScr; Grid;
  GotoCell(FX,FY);
  repeat
    Read(Kbd,Ch);
    case Ch of
      #250{^E}:       MoveUp;
      #249{^X,^J}:    MoveDown;
      #251{^D,^M,^F}: MoveRight;
      #248{^S,^A}:    MoveLeft;
      '/':      Commands;
      ^[:       GetCell(FX,FY);
    else
      if Ch in [' '..'~'] then
      GetCell(FX,FY);
    end;
  until true=false;
end.

