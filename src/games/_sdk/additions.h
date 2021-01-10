#ifndef __ADDITIONS
#define __ADDITIONS
#include <put_get_mem_atm.h>
#define dospage				63 

static u8 code_to_char[]={' ','z','x','c','v','a','s','d','f','g','q','w','e','r','t','1','2','3','4','5','0','9','8','7','6','p','o','i','u','y',' ','l','k','j','h',' ',' ','m','n','b'};
static u8 output_x;
static u8 output_y;
static u8 save_output_x;
static u8 pcharmask=0;

//Вычисляет квадратный корень 
unsigned int lsqrt(unsigned long arg)
{
static char count=16;
unsigned long res=0,tmp=0;
	if(arg!=0){ 
		if(!(arg&0xFF000000)){arg<<=8;count-=4;}


		res=1;
		while((tmp<1)&&(count)){
			count--;
			if(arg&0x80000000UL)tmp|=2;
			if(arg&0x40000000UL)tmp|=1;

			arg<<=2;


		};
		tmp--;
		for(count;count;count--){
			tmp<<=2;
			res<<=1;

			if(arg&0x80000000UL)tmp|=2;
			if(arg&0x40000000UL)tmp|=1;
			arg<<=2;

			if( tmp>=((res<<1)|1)){
				tmp-=((res<<1)|1);
				res|=1;
			}
			
		}
	}
	return (unsigned int)res;
}
//Преобразует число в строку
void itoa(i16 val, u8* buf)
{
    static u8 *p;                 
    static  u8 *firstdig;          
    static i8 temp;               
    static i8 digval;         
	static u8 a;
	for(a=0;a<16;a++)buf[a]=0;
	
    p = buf;
    firstdig = p;           
 
    do {
        digval = (unsigned) (val % 10);
        val /= 10;       
 
        
        if (digval > 9)*p++ = (char) (digval - 10 + 'a'); 
        else *p++ = (char) (digval + '0');       
 
    } 
	while (val > 0);
	 
    *p-- = '\0';            
 
    do 
	{
        temp = *p;
        *p = *firstdig;
        *firstdig = temp;   
        --p;
        ++firstdig;         
    } while (firstdig < p); 
}

//Выводит на экран символ N по координатам X,Y
//Должна быть выбрана тайл-карта со шрифтом
//pcharmask - указывает способ рисовки символа.
// если pcharmask=0 то символ рисуется без учета прозрачного цвета
// если pcharmask=1 то символ рисуется с маской
void put_char_xy(u8 n, u8 x,u8 y,u8 pcharmask)
{
 if(n>=' ')
	{
		if(pcharmask==0)draw_tile(x,y,n-' ');
		else draw_tile_key(x,y,n-' ');
	}

}
//Выводит на экран символ N по координатам output_x и output_y
//Должна быть выбрана тайл-карта со шрифтом
//Применяется в функции put_str

void put_char(u8 n)
{
	if(n>=' ')
	{
		if(pcharmask==0)draw_tile(output_x,output_y,n-' ');
		else draw_tile_key(output_x,output_y,n-' ');
	}

	++output_x;

	if(output_x==39||n=='\n')
	{
		output_x=save_output_x;
		++output_y;
        if(output_y==24) output_y=1;
	}
}
//Выводит строку по координатам output_x и output_y
//Вывод ведётся шрифтом fnt, где fnt - номер изображения
void put_str(u8* str,u8 fnt)
{

  static u8 i;
  select_image(fnt);
  save_output_x=output_x;
  while(1)
  {
    i=*str++;
    if(!i) break;
	else if(i=='\0') break;
	else if(i=='^') break;
	else put_char(i);
  }
}

//Возвращает длину строки
u16 strlen (u8 * str)
{
	static u8 a,i;
	a=0;
	while(1)
	{
		i=*str++;
		if(!i) break;
		if(i=='\0') break;
		if(i=='^') break;
		a++;
	}
	return a;
}
//сравнение строк
//Возвращяет 1 если строка 2 > строки 1
//Возвращяет -1 если строка 1 > строки 2
//Возвращяет 0 если строки равны
i8 strcmp(u8 *str1, u8 *str2)
{	
	static u8 a,l1,l2;
	l1=strlen(str1);
	l2=strlen(str2);
	if(l1>l2) return -1;
	else if(l1<l2) return 1;
	else
	{
		for(a=0;a<l1;a++)
		{
			if(*(str1+a)<*(str2+a)) return 1;
			if(*(str1+a)>*(str2+a)) return -1;
		}
	}
	return 0;
}
//Проводит конкатинацию строк.
//Присоединяет buf2 к buf1
void strcat(u8 *buf1,u8 *buf2)
{
	static u16 a;
	static u16 b;
	static u8 *bb,flag;
	static u8 i;
	a=0;
	bb=buf1;

	while(1)
	{
		i=*bb++;
		if(i=='^' || i==0) break;
		else 
		{
			a++;
		}
	}
	bb=buf2;
	b=0;

	while(1)
	{
		i=*bb++;
		if(!i || i=='^'||i=='\0') break;
		else 
		{
			*(buf1+a+b)=i;
			b++;
		}
		
	}
	*(buf1+a+b)=0;
}
//Обвязка функции 3d13
//pg - страница с которой будет вестись обмен данными
//operation - номер операции
//blocks - количество считываемых блоков
//sector - начальный сектор считывания
//track - начальная дорожка считывания
//begin_page - смещение на странице
void DOS(u8 pg, u8 operation,u8 blocks, u8 sector, u8 track, u16 begin_page)  __naked
	{
			__asm
			push ix
			ld	ix,#0
			add	ix,sp
			
			ld a,4 (ix)
			ex af,af
			
			ld c,5 (ix)
			ld b,6 (ix)
			ld e,7 (ix)
			ld d,8 (ix)
			ld l,9 (ix)
			ld h,10 (ix)
			call #_DOS_3D13
			
			pop ix
			ret
			__endasm;
	}
//Загрузка файла с диска в страницу памяти/ выгрузка страницы в файл (Новй файл не создаётся,он уже должен быть на диске).
//filename - имя файла
//page - номер страницы с которой будет всестись обмен
//0 - сохранение на диск
//1 - загрузка с диска
// в функции используется defined значение dospage, которое указывает на страницу в памяти в которую удет временно
// записано значение нулевой дорожки
	void load_file(u8 *filename,u8 page,u8 saveload)
	{
		static u8 buf[16];
		static u8 a;
		static u16 c;
		vsync();
		DOS(#0x7f-dospage,5,7,0,0,32768);//прочтем нулевую дорожку
		vsync();
		buf[8]='^';
		c=0;
		
		while(strcmp(buf,filename)!=0 && c<1792)
		{
			for(a=0;a<16;a++)
			{
				buf[a]=get_mem(dospage,32768+a+c);
			}
			buf[8]='^';
			c+=16;
		}
		vsync();
		if(saveload==1)
		{
			DOS(#0x7f-page,5,buf[13],buf[14],buf[15],32768);
		}
		else
		{
			DOS(#0x7f-page,6,1,buf[14],buf[15],32768);
		}
		vsync();
	}
#endif