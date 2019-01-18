//---------------------------------------------------------------------------

#include <vcl.h>
#include <stdio.h>
#include <io.h>
#pragma hdrstop

#include "guiUnit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"

TForm1 *Form1;
//FILE *fin;
//FILE *fout;
//FILE *fhint;
//FILE *ferr;
FILE *fmemo;

//#include "compiler.hpp"

//#include "globals.cpp"
/*
int ord(char c)
{
  return (int)c;
}

int Length(AnsiString s)
{
  return s.Length();
}

char read(FILE *file)
{
  char c;
  fread( &c, sizeof(c), 1, fin);
  return c;
}

void write(FILE *file, char c)
{
  //fwrite(&c,sizeof(c),1,file);
  fprintf(file,"%c",c);
}

bool eof(FILE *file)
{
  return curline>50;
}

void write(FILE *file, AnsiString s)
{
  fprintf(file,"%s",s.c_str());
}
*/

//#include "typecodes.cpp"
//#include "emitter.cpp"
//#include "emits.cpp"
//#include "reads.cpp"
//#include "emitdirectives.cpp"
//#include "regs.cpp"
//#include "doasm.cpp"
//#include "emitcommands.cpp"
//#include "compiler.cpp"


//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TForm1::memoInChange(TObject *Sender)
{
  int linr;
  byte digit[6];
  AnsiString caption;
  linr=memoIn->CaretPos.y+1;
  //digit[0]=typeshift[1];
  digit[1]=linr/10000; linr=linr-digit[1]*10000; digit[1]=digit[1]+48; //'0'
  digit[2]=linr/1000;  linr=linr-digit[2]*1000;  digit[2]=digit[2]+48; //'0'
  digit[3]=linr/100;   linr=linr-digit[3]*100;   digit[3]=digit[3]+48; //'0'
  digit[4]=linr/10;    linr=linr-digit[4]*10;    digit[4]=digit[4]+48; //'0'
  digit[5]=linr;                                 digit[5]=digit[5]+48; //'0'
  caption="Line=";
  caption=caption+(char)(digit[1])+(char)(digit[2])+(char)(digit[3])+(char)(digit[4])+(char)(digit[5]); //IntToStr(MemoIn.CaretPos.Y+1);
  lbCaretPos->Caption=caption;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::memoInMouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  memoInChange(Sender);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::memoInKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  memoInChange(Sender);
  if ((Key!=VK_LEFT)&&(Key!=VK_RIGHT)&&(Key!=VK_UP)&&(Key!=VK_DOWN))
    if (cbAuto->Checked) Button1Click(Sender);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button1Click(TObject *Sender)
{
  AnsiString s;
  //char line[100000];
  //setasms(cbAsm->Checked);
  //setcomments(cbComments->Checked);
  //sethints(cbHints->Checked);
  memoIn->Lines->SaveToFile("_test.c");
  //fmemo=fopen("fin","wt");
  //s=memoIn->Lines->Text;
  //fwrite(fmemo,s);
  //fclose(fmemo);
  //memoOut->Clear();
  //memoErr->Clear();
  //fin=fopen("fin","rt");
  //setfout('fout'); //AssignFile(fout,'fout'); Rewrite(fout);
  //setfhint('fouthints'); //AssignFile(fhint,'fouthints'); Rewrite(fhint);
  //setferr('ferr'); //AssignFile(ferr,'ferr'); Rewrite(ferr);
//  if (cbARM->Checked) {
  if (rgTarget->ItemIndex == 1) {
    s="..\\_sdk\\nedolarm.exe";
  }else {
    s="..\\_sdk\\nedolang.exe";
  };
//  if(!cbAsm->Checked) s=s+" -a";
  if(cbComments->Checked) s=s+" -C";
  if(cbHints->Checked) s=s+" -H";
  s=s+" _test.c";
  system(s.c_str()); //compile();
  //closeferr; //CloseFile(ferr);
  //closefhint; //CloseFile(fhint);
  //closefout; //CloseFile(fout);
  //fclose(fin);
  //fmemo=fopen("fout","rt");
  //memoOut->Hide();
    memoOut->Lines->LoadFromFile("_test.asm");
/*  while (fgets(line,sizeof(line),fmemo)!=NULL) {
    line[StrLen(line)-1]='\0';
    memoOut->Lines->Add(line);
  };*/
  //memoOut->Show();
  //fclose(fmemo);
  fmemo=fopen("err.f","rt");
  if (fmemo) {
    fclose(fmemo);
  //memoErr->Hide();
    memoErr->Lines->LoadFromFile("err.f");
  }else {
    fclose(fmemo);
  };
/*  while (fgets(line,sizeof(line),fmemo)!=NULL) {
    line[StrLen(line)-1]='\0';
    memoErr->Lines->Add(line);
  };*/
  //memoErr->Show();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  //AnsiString s;
  //char line[100000];
  //memoIn->Clear();
  //fmemo=fopen("fin","rt");
  //memoIn->Hide();
  system("..\\_sdk\\nedolang.exe _test.c");
  memoIn->Lines->LoadFromFile("_test.c");
/*  while (fgets(line,sizeof(line),fmemo)!=NULL) {
    line[StrLen(line)-1]='\0';
    memoIn->Lines->Add(line);
  };*/
  //memoIn->Show();
  //fclose(fmemo);
  Button1Click(Sender);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormClose(TObject *Sender, TCloseAction &Action)
{
  memoIn->Lines->SaveToFile("_test.c");
}
//---------------------------------------------------------------------------

