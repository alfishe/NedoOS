//---------------------------------------------------------------------------

#ifndef guiUnit1H
#define guiUnit1H
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
        TMemo *memoIn;
        TMemo *memoOut;
        TLabel *lbCaretPos;
        TButton *Button1;
        TCheckBox *cbHints;
        TCheckBox *cbComments;
        TCheckBox *cbAuto;
        TMemo *memoErr;
        TRadioGroup *rgTarget;
        void __fastcall memoInChange(TObject *Sender);
        void __fastcall memoInMouseDown(TObject *Sender,
          TMouseButton Button, TShiftState Shift, int X, int Y);
        void __fastcall memoInKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall Button1Click(TObject *Sender);
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
