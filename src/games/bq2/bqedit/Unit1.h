//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ImgList.hpp>
#include <ComCtrls.hpp>
#include <Dialogs.hpp>
#include <Buttons.hpp>
#include <ExtCtrls.hpp>
#include <Graphics.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TImageList *HWallList;
	TImageList *ObjList;
	TImageList *EmptyList;
	TUpDown *UpDown1;
	TUpDown *UpDown2;
	TUpDown *UpDown3;
	TLabel *Label1;
	TLabel *Label2;
	TLabel *Label3;
	TImageList *VWallList;
	TOpenDialog *OpenDialog1;
	TSaveDialog *SaveDialog1;
	TSpeedButton *SpeedButton1;
	TSpeedButton *SpeedButton2;
	TSpeedButton *SpeedButton3;
	TSpeedButton *SpeedButton4;
	TSpeedButton *SpeedButton5;
	TSpeedButton *SpeedButton6;
	TSpeedButton *SpeedButton7;
	TSaveDialog *SaveDialog2;
	TLabel *Label4;
	TImage *Image1;
	TSpeedButton *SpeedButton8;
	TUpDown *UpDown4;
	TSpeedButton *SpeedButton9;
	TStaticText *StaticText1;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall UpDown1Click(TObject *Sender, TUDBtnType Button);
	void __fastcall UpDown2Click(TObject *Sender, TUDBtnType Button);
	void __fastcall UpDown3Click(TObject *Sender, TUDBtnType Button);
	void __fastcall SpeedButton4Click(TObject *Sender);
	void __fastcall SpeedButton5Click(TObject *Sender);
	void __fastcall FormKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
	void __fastcall FormMouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
	void __fastcall SpeedButton6Click(TObject *Sender);
	void __fastcall SpeedButton7Click(TObject *Sender);
	void __fastcall SpeedButton1Click(TObject *Sender);
	void __fastcall SpeedButton2Click(TObject *Sender);
	void __fastcall SpeedButton3Click(TObject *Sender);
	void __fastcall FormMouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
	void __fastcall FormShow(TObject *Sender);
	void __fastcall FormPaint(TObject *Sender);
	void __fastcall SpeedButton9Click(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
        __fastcall void draw_selobj(void);
        __fastcall void draw_mapfull(void);
        __fastcall void mouse_click(int,int,TShiftState);
        __fastcall void mcoord_upd(int x,int y);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
