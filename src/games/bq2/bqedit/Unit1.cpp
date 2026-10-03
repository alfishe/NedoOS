//---------------------------------------------------------------------------

#include <vcl.h>
#include <stdlib.h>
#include <stdio.h>

#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;

#define map_tsize	16
#define map_wdt		128
#define map_hgt		128
#define mview_x		0
#define mview_y		0
#define mview_wdt	32
#define mview_hgt	32

unsigned char wmap[map_wdt*map_hgt];

int whor_rcnt;
int wver_rcnt;
int obj_rcnt;
int whor_sel,wver_sel,obj_sel;
int cam_x,cam_y;
int old_mx,old_my;


void __fastcall TForm1::draw_selobj(void)
{
	Label1->Caption="Object "+IntToStr(obj_sel);
	Label2->Caption="HWall "+IntToStr(whor_sel);
	Label3->Caption="VWall "+IntToStr(wver_sel);
	
	ObjList->Draw(Canvas,560,135,obj_sel);
	HWallList->Draw(Canvas,560,207,whor_sel);
	VWallList->Draw(Canvas,560,260,wver_sel);
}

void __fastcall TForm1::draw_mapfull(void)
{
	int xx,yy;
	int aa,bb,it,cx,cy;
	
	yy=mview_y+(mview_hgt-1)*map_tsize;
	for(aa=mview_hgt-1;aa>=-3;aa--)
	{
		xx=mview_x+(mview_wdt-1)*map_tsize;
		for(bb=mview_wdt-1;bb>=-3;bb--)
		{
                cx=bb+cam_x;
                cy=aa+cam_y;
                if(cy>=0&&cx>=0&&cy<map_hgt&&cx<map_wdt)
                {
			it=wmap[cy*map_wdt+cx];
			if(it==0)
			{
				EmptyList->Draw(Image1->Canvas,xx,yy,0);
			}
			else
			{
				if(it<33)
				{
					ObjList->Draw(Image1->Canvas,xx,yy,it-1);//объекты
				}
				else
				{
					if(it<65)
					{
						HWallList->Draw(Image1->Canvas,xx,yy,it-33);//гор.стенки
					}
					else
					{
						VWallList->Draw(Image1->Canvas,xx,yy,it-65);//вер.стенки
					}
				}
			}
                        }
			xx-=map_tsize;
		}
		yy-=map_tsize;
	}
	Image1->Repaint();
}

void __fastcall TForm1::mouse_click(int x,int y,TShiftState Shift)
{
	bool lk,rk;
	int adr;
	
	lk=false;
	rk=false;
	
	if(Shift.Contains(ssLeft)) lk=true;
	if(Shift.Contains(ssRight)) rk=true;
	
	if(!lk&&!rk) return;
	if(x<mview_x||y<mview_y||x>=mview_x+mview_wdt*map_tsize||y>=mview_y+mview_hgt*map_tsize) return;
	
	adr=((x-mview_x)/map_tsize+cam_x)+((y-mview_y)/map_tsize+cam_y)*map_wdt;
	
	if(lk)
	{
		if(SpeedButton1->Down)
		{
			wmap[adr]=obj_sel+1;//выбранный объект
		}
		if(SpeedButton2->Down)
		{
			wmap[adr]=whor_sel+33;//выбранная гор.стена
		}
		if(SpeedButton3->Down)
		{
			wmap[adr]=wver_sel+65;//выбранная вер.стена
		}
	}
	if(rk)
	{
		wmap[adr]=0;//всегда стирает
	}
	draw_mapfull();
}

void __fastcall TForm1::mcoord_upd(int x,int y)
{
	int tx,ty;
	old_mx=x;
	old_my=y;
	
	if(x<mview_x||y<mview_y||x>=mview_x+mview_wdt*map_tsize||y>=mview_y+mview_hgt*map_tsize)
	{
		tx=-1;
		ty=-1;
	}
	else
	{
		tx=(x-mview_x)/map_tsize+cam_x;
		ty=(y-mview_y)/map_tsize+cam_y;
	}
	
	if(tx>=0&&tx<map_wdt&&ty>=0&&tx<map_hgt)
	{
		Label4->Caption="x:"+IntToStr(tx)+" y:"+IntToStr(ty);
	}
	else
	{
		Label4->Caption="x:--- y:---";
	}
}


void save_map_hobeta(AnsiString fname,int time)
{
	FILE *file;
	unsigned char data[4096+2+17];
	char hname[9];
	int aa,bb,pp,xc,yc,it,hsize,ssize,csum,ld;
	bool sfnd;
	AnsiString hnma;
	
	ld=fname.LastDelimiter("\\/")+1;
	hnma=fname.SubString(ld,fname.Length()-2-ld);
	hname[8]=0;
	strcpy(hname,hnma.SubString(1,8).c_str());
	memset(&data[0],32,8);
	memcpy(&data,hname,strlen(hname));
	data[8]='b';
	data[9]='i';
	data[10]='n';
	pp=17;

        data[pp++]=time&255;
        data[pp++]=time>>8;

	sfnd=false;
	
	for(aa=0;aa<map_hgt;aa++) //поиск старта
	{
		for(bb=0;bb<map_wdt;bb++)
		{
			if(wmap[aa*map_wdt+bb]==1)
			{
				xc=bb*16+8;
				yc=aa*16+24;
				data[pp++]=2;
				data[pp++]=0;
				data[pp++]=yc&255;
				data[pp++]=yc>>8;
				data[pp++]=xc&255;
				data[pp++]=xc>>8;
				data[pp++]=0;
				data[pp++]=0;
				data[pp++]=0;
				data[pp++]=0;
				data[pp++]=4;
				sfnd=true;
				break;
			}
		}
		if(sfnd) break;
	}
	
	if(!sfnd)
	{
		Application->MessageBox("Start position is missing!","Error",MB_OK);
	}
	else
	{
		
		for(aa=0;aa<map_hgt;aa++)//объекты
		{
			for(bb=0;bb<map_wdt;bb++)
			{
				it=wmap[aa*map_wdt+bb];
				if(it>1&&it<33)
				{
					xc=bb*16;
					yc=aa*16+16;
					data[pp++]=(it-2)*4+64;
					data[pp++]=0;
					data[pp++]=yc&255;
					data[pp++]=yc>>8;
					data[pp++]=xc&255;
					data[pp++]=xc>>8;
					data[pp++]=0;
					data[pp++]=0;
					data[pp++]=0;
					data[pp++]=0;
					data[pp++]=4;
				}
			}
		}
		
		for(aa=0;aa<map_hgt;aa++)//стенки
		{
			for(bb=0;bb<map_wdt;bb++)
			{
				it=wmap[aa*map_wdt+bb];
				if(it>=33)
				{
					xc=bb*16;
					yc=aa*16;
					if(it>=33&&it<65)//гориз.
					{
						it=(it-33)*4+192;
						xc+=16;
					}
					else //верт.
					{
						it=(it-65)*4+224;
						yc+=48;
						xc-=8;
					}
					data[pp++]=it;
					data[pp++]=0;
					data[pp++]=yc&255;
					data[pp++]=yc>>8;
					data[pp++]=xc&255;
					data[pp++]=xc>>8;
					data[pp++]=0;
					data[pp++]=0;
					data[pp++]=0;
					data[pp++]=0;
					data[pp++]=4;
				}
			}
		}

		data[pp++]=0;
		
		hsize=pp-17;
		ssize=(hsize+255)/256;
		data[0x0b]=hsize&255;
		data[0x0c]=hsize>>8;
		data[0x0d]=ssize>>8;
		data[0x0e]=ssize&255;
		
		csum=0;
		for(aa=0;aa<=14;csum=csum+(data[aa]*257)+aa,aa++);
		
		data[0x0f]=csum&255;
		data[0x10]=csum>>8;

		file=fopen(fname.c_str(),"wb");
		if(file)
		{
                hsize=(hsize+255)/256*256+17;
			fwrite(&data,hsize,1,file);
			fclose(file);
		}
	}
}

void scroll_left(int n)
{
	int nn,aa,bb;
	unsigned char buf[map_hgt];
	for(nn=0;nn<n;nn++)
	{
		for(aa=0;aa<map_hgt;aa++) buf[aa]=wmap[aa*map_wdt+0];
		for(aa=0;aa<map_hgt;aa++) for(bb=0;bb<map_wdt-1;bb++) wmap[aa*map_wdt+bb]=wmap[aa*map_wdt+bb+1];
		for(aa=0;aa<map_hgt;aa++) wmap[aa*map_wdt+map_wdt-1]=buf[aa];
	}
}

void scroll_right(int n)
{
	int nn,aa,bb;
	unsigned char buf[map_hgt];
	for(nn=0;nn<n;nn++)
	{
		for(aa=0;aa<map_hgt;aa++) buf[aa]=wmap[aa*map_wdt+map_wdt-1];
		for(aa=0;aa<map_hgt;aa++) for(bb=map_wdt-1;bb>0;bb--) wmap[aa*map_wdt+bb]=wmap[aa*map_wdt+bb-1];
		for(aa=0;aa<map_hgt;aa++) wmap[aa*map_wdt+0]=buf[aa];
	}
}

void scroll_up(int n)
{
	int nn,aa,bb;
	unsigned char buf[map_wdt];
	for(nn=0;nn<n;nn++)
	{
		for(aa=0;aa<map_wdt;aa++) buf[aa]=wmap[0*map_wdt+aa];
		for(aa=0;aa<map_wdt;aa++) for(bb=0;bb<map_hgt-1;bb++) wmap[bb*map_wdt+aa]=wmap[(bb+1)*map_wdt+aa];
		for(aa=0;aa<map_wdt;aa++) wmap[(map_hgt-1)*map_wdt+aa]=buf[aa];
	}
}

void scroll_down(int n)
{
	int nn,aa,bb;
	unsigned char buf[map_wdt];
	for(nn=0;nn<n;nn++)
	{
		for(aa=0;aa<map_wdt;aa++) buf[aa]=wmap[(map_hgt-1)*map_wdt+aa];
		for(aa=0;aa<map_wdt;aa++) for(bb=map_hgt-1;bb>0;bb--) wmap[bb*map_wdt+aa]=wmap[(bb-1)*map_wdt+aa];
		for(aa=0;aa<map_wdt;aa++) wmap[0*map_wdt+aa]=buf[aa];
	}
}

//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
: TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
	int aa;
	for(aa=0;aa<map_wdt*map_hgt;aa++) wmap[aa]=0;
	cam_x=map_wdt/2-mview_wdt/2;
	cam_y=map_hgt/2-mview_hgt/2;
	old_mx=-1;
	old_my=-1;
	
	whor_sel=0;
	wver_sel=0;
	obj_sel=0;
	whor_rcnt=HWallList->Count;
	wver_rcnt=VWallList->Count;
	obj_rcnt=ObjList->Count;
	UpDown1->Max=obj_rcnt-1;
	UpDown2->Max=whor_rcnt-1;
	UpDown3->Max=wver_rcnt-1;
	
}
//---------------------------------------------------------------------------
void __fastcall TForm1::UpDown1Click(TObject *Sender, TUDBtnType Button)
{
	obj_sel=UpDown1->Position;
	draw_selobj();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::UpDown2Click(TObject *Sender, TUDBtnType Button)
{
	whor_sel=UpDown2->Position;
	draw_selobj();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::UpDown3Click(TObject *Sender, TUDBtnType Button)
{
	wver_sel=UpDown3->Position;
	draw_selobj();
}
//---------------------------------------------------------------------------


void __fastcall TForm1::SpeedButton4Click(TObject *Sender)
{
	unsigned char tm[2];

	if(OpenDialog1->Execute())
	{
		FILE *file;
		
		file=fopen(OpenDialog1->FileName.c_str(),"rb");
		if(file)
		{
			fread(&wmap,map_hgt*map_wdt,1,file);
                        fread(&tm,2,1,file);
                        UpDown4->Position=tm[0]+tm[1]*256;
			fclose(file);
		}
		draw_mapfull();
	}	
}
//---------------------------------------------------------------------------

void __fastcall TForm1::SpeedButton5Click(TObject *Sender)
{
        unsigned char tm[2];
        int time;
	if(SaveDialog1->Execute())
	{
		FILE *file;
		
		file=fopen(SaveDialog1->FileName.c_str(),"wb");
		if(file)
		{
			fwrite(&wmap,map_hgt*map_wdt,1,file);
			time=UpDown4->Position;
                        tm[0]=time&255;
                        tm[1]=time>>8;
                        fwrite(&tm,2,1,file);
			fclose(file);
		}
		if(SpeedButton8->Down)
		{
			save_map_hobeta((SaveDialog1->FileName.SubString(1,SaveDialog1->FileName.Length()-4)+".$B"),UpDown4->Position);
		}
	}	
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormKeyDown(TObject *Sender, WORD &Key,
									TShiftState Shift)
{
	bool ch;
	int num,step;
	
	ch=false;
	if(Shift.Contains(ssCtrl)) step=10; else step=1;
	if(Shift.Contains(ssShift))
	{
		switch(Key)
		{
		case VK_UP:
			scroll_up(1);
			ch=true;
			break;
		case VK_DOWN:
			scroll_down(1);
			ch=true;
			break;
		case VK_LEFT:
			scroll_left(1);
			ch=true;
			break;
		case VK_RIGHT:
			scroll_right(1);
			ch=true;
			break;
		}
	}
	else
	{
		switch(Key)
		{
		case VK_UP:
			if(cam_y>0)
			{
				cam_y-=step;
				if(cam_y<0) cam_y=0;
				ch=true;
			}
			break;
		case VK_DOWN:
			if(cam_y<map_hgt-mview_hgt-1)
			{
				cam_y+=step;
				if(cam_y>=map_hgt-mview_hgt-1) cam_y=map_hgt-mview_hgt-1;
				ch=true;
			}
			break;
		case VK_LEFT:
			if(cam_x>0)
			{
				cam_x-=step;
				if(cam_x<0) cam_x=0;
				ch=true;
			}
			break;
		case VK_RIGHT:
			if(cam_x<map_wdt-mview_wdt-1)
			{
				cam_x+=step;
				if(cam_x>=map_wdt-mview_wdt-1) cam_x=map_wdt-mview_wdt-1;
				ch=true;
			}
			break;
			
		case VK_DIVIDE:
			SpeedButton1->Down=true;
			break;
			
		case VK_MULTIPLY:
			SpeedButton2->Down=true;
			break;
			
		case VK_SUBTRACT:
			SpeedButton3->Down=true;
			break;
			
		case VK_PRIOR:
			if(SpeedButton1->Down)
			{
				if(obj_sel>0)
				{
					obj_sel--;
					UpDown1->Position=obj_sel;
					draw_selobj();
				}
			}
			if(SpeedButton2->Down)
			{
				if(whor_sel>0)
				{
					whor_sel--;
					UpDown2->Position=whor_sel;
					draw_selobj();
				}
			}
			if(SpeedButton3->Down)
			{
				if(wver_sel>0)
				{
					wver_sel--;
					UpDown3->Position=wver_sel;
					draw_selobj();
				}
			}
			break;
			
		case VK_NEXT:
			if(SpeedButton1->Down)
			{
				if(obj_sel<obj_rcnt-1)
				{
					obj_sel++;
					UpDown1->Position=obj_sel;
					draw_selobj();
				}
			}
			if(SpeedButton2->Down)
			{
				if(whor_sel<whor_rcnt-1)
				{
					whor_sel++;
					UpDown2->Position=whor_sel;
					draw_selobj();
				}
			}
			if(SpeedButton3->Down)
			{
				if(wver_sel<wver_rcnt-1)
				{
					wver_sel++;
					UpDown3->Position=wver_sel;
					draw_selobj();
				}
			}
			break;
		case VK_NUMPAD0:
		case VK_NUMPAD1:
		case VK_NUMPAD2:
		case VK_NUMPAD3:
		case VK_NUMPAD4:
		case VK_NUMPAD5:
		case VK_NUMPAD6:
		case VK_NUMPAD7:
		case VK_NUMPAD8:
		case VK_NUMPAD9:
			num=Key-VK_NUMPAD0;
			if(SpeedButton1->Down)
			{
				if(num<obj_rcnt)
				{
					obj_sel=num;
					UpDown1->Position=obj_sel;
					draw_selobj();
				}
			}
			if(SpeedButton2->Down)
			{
				if(num<whor_rcnt)
				{
					whor_sel=num;
					UpDown2->Position=whor_sel;
					draw_selobj();
				}
			}
			if(SpeedButton3->Down)
			{
				if(num<wver_rcnt)
				{
					wver_sel=num;
					UpDown3->Position=wver_sel;
					draw_selobj();
				}
			}
			break;
	}
        }
		if(ch)
        {
			mcoord_upd(old_mx,old_my);
			draw_mapfull();
        }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormMouseDown(TObject *Sender, TMouseButton Button,
									  TShiftState Shift, int X, int Y)
{
	mouse_click(X,Y,Shift);
}
//---------------------------------------------------------------------------


void __fastcall TForm1::SpeedButton6Click(TObject *Sender)
{
	int aa;
	for(aa=0;aa<map_wdt*map_hgt;aa++) wmap[aa]=0;
	cam_x=map_wdt/2-mview_wdt/2;
	cam_y=map_hgt/2-mview_hgt/2;
	draw_mapfull();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::SpeedButton7Click(TObject *Sender)
{
	if(SaveDialog2->Execute())
	{
		save_map_hobeta(SaveDialog2->FileName,UpDown4->Position);
	}
}
//---------------------------------------------------------------------------


void __fastcall TForm1::SpeedButton1Click(TObject *Sender)
{
	//	
}
//---------------------------------------------------------------------------

void __fastcall TForm1::SpeedButton2Click(TObject *Sender)
{
	//
}
//---------------------------------------------------------------------------

void __fastcall TForm1::SpeedButton3Click(TObject *Sender)
{
	//	
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormMouseMove(TObject *Sender, TShiftState Shift,
									  int X, int Y)
{
	mcoord_upd(X,Y);
}
//---------------------------------------------------------------------------



void __fastcall TForm1::FormShow(TObject *Sender)
{
	draw_selobj();
	draw_mapfull();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormPaint(TObject *Sender)
{
	draw_selobj();	
}
//---------------------------------------------------------------------------



void __fastcall TForm1::SpeedButton9Click(TObject *Sender)
{
 UpDown4->Position=40;
}
//---------------------------------------------------------------------------

