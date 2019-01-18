//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TImage *Image1;
        TMemo *Memo1;
        TLabel *lbR;
        TLabel *lbG;
        TLabel *lbB;
        TImage *curColor;
        TImage *changV;
        TImage *curColorChunky;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall Image1MouseMove(TObject *Sender, TShiftState Shift,
          int X, int Y);
        void __fastcall Image1Click(TObject *Sender);
        void __fastcall changVMouseMove(TObject *Sender, TShiftState Shift,
          int X, int Y);
        void __fastcall changVClick(TObject *Sender);
        void __fastcall curColorClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
        float curmouseH;
        float curmouseS;
        float curmouseV;

        float curH;
        float curS;
        float curV;

        __fastcall TForm1(TComponent* Owner);
        void tracepixel(int i,int j);
        void prhex(AnsiString name, int a);
        int calcHSVtoRGB(float h,float s,float v);
        void showcolor();
        void showHSpalette();
        void showVpalette();
        void setColorChunkyR(int x, int y, int n);
        void setColorChunkyG(int x, int y, int n);
        void setColorChunkyB(int x, int y, int n);
        void setHSpaletteR(int x, int y, int n);
        void setHSpaletteG(int x, int y, int n);
        void setHSpaletteB(int x, int y, int n);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
