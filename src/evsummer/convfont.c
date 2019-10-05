#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int getssize(unsigned char *pixels,unsigned char *tail);
void convertbyte(unsigned char *inputbyte,unsigned char *outputbyte);
void convertcolor(unsigned char *inputcolor, unsigned char *outputcolor);
int main(int argc, char *argv[])
{
    FILE *infile,*outfile;
    unsigned long insize;
    unsigned long *width, *height, *pixoffset,*headsize,*colors;
    unsigned int *bpp,code;
    unsigned char *bitmap,*pixels,byte,correction;
    int i,j,w,swidth,bpl;

    if (argc <3) {printf("Use convfont <input.bmp> <out.asm)\n");return 0; };

    
    if (!(infile=fopen(argv[1],"rb"))){
	printf("Failed to open %s for reading!\n",argv[1]);
	return 255;
    };

    if (!(outfile=fopen(argv[2],"wb"))){
	printf("Failed to open %s for writing!\n",argv[2]);
	fclose(infile);
	return 255;
    };


    fseek(infile, 0, SEEK_END);
    insize=ftell(infile);
    fseek(infile, 0, SEEK_SET);
    bitmap=malloc(insize);
    fread(bitmap,insize,1,infile);
    fclose(infile);

    pixoffset=(unsigned long*)(bitmap+10);
    headsize=(unsigned long*)(bitmap+14);
    width=(unsigned long*)(bitmap+18);
    height=(unsigned long*)(bitmap+22);
    colors=(unsigned long*)(bitmap+46);
    bpp=(unsigned int*)(bitmap+28);
    pixels=(unsigned char*)(bitmap+*pixoffset);


    bpl=*width/2;
    i=bpl/4;		//Дополняем до полных 4х байт на строку растра
    j=bpl-i*4;
    correction=(4-j);
    if (bpl!=i*4)
	bpl=bpl+correction; 


    printf("Converting font %s to %s\n filesize=%u\n image=%ux%u\n pixeloffset=%u\n colors=%u\n headsize=%u\n bpp=%u\n",argv[1],argv[2], insize, *width,*height,*pixoffset,*colors,*headsize,*bpp);

    fprintf(outfile,"font_table\n");
    for (i=0;i<=0xFF;i++)
	fprintf(outfile,"\t\tdw s_%X\n",i);
    for (i=0x0;i<=0x1F;i++)
	fprintf(outfile,"s_%X\n",i);
    for (i=0xF2;i<=0xFF;i++)
	fprintf(outfile,"s_%X\n",i);


    code=0x20;

    for (w=0;w<bpl;w=w+swidth){
	swidth=getssize(pixels+bpl*(*height-1)+w,bitmap+insize-correction);
	if (!swidth) break;
	fprintf(outfile,"s_%X\t\tdb %u,%u\n",code++,*height-1,swidth);
        for (j=0;j<swidth;j++){
	    fprintf(outfile,"\t\tdb ");
	    for (i=2;i<=*height;i++)
            {
		convertbyte(pixels+bpl*(*height-i)+j+w,&byte);
		fprintf(outfile,"%u",byte);
		if (i<*height) fprintf(outfile,",");
	    };
	    fprintf(outfile,"\n");
        };
    };

    fclose(outfile);
    free(bitmap);
    return 0;
};

int getssize(unsigned char *pixels,unsigned char *tail)
{
    unsigned char x;
    char col,oldcol;
    oldcol=col=*pixels;
    for (x=0;(col==oldcol)&&((pixels+x)<=tail);x++)
	col=*(pixels+x);
    return x-1;
}

void convertbyte(unsigned char *inputbyte,unsigned char *outputbyte)
{
/*	*outputbyte=*inputbyte&0b00000111;
	if (*inputbyte&0b00001000) *outputbyte=*outputbyte|0b01000000;
	*outputbyte=*outputbyte|(*inputbyte&0b01110000)>>1;
	*outputbyte=*outputbyte|(*inputbyte&0b10000000);*/
	*outputbyte=(*inputbyte&0b00000111)<<3;
	if (*inputbyte&0b00001000) *outputbyte=*outputbyte|0b10000000;
	*outputbyte=*outputbyte|(*inputbyte&0b01110000)>>4;
	if (*inputbyte&0b10000000) *outputbyte=*outputbyte|0b010000000;
};

void convertcolor(unsigned char *inputcolor, unsigned char *outputcolor)
{
    unsigned char color;
    color=*inputcolor/75;
    *outputcolor=((color&1)<<6)|(color&2);
    inputcolor++;
    color=*inputcolor/75;
    *outputcolor=*outputcolor|((color&1)<<7)|((color&2)<<3);
    inputcolor++;
    color=*inputcolor/75;
    *outputcolor=*outputcolor|((color&1)<<5)|((color&2)>>1);
    *outputcolor=*outputcolor|12;
    *outputcolor=~*outputcolor;
    *(outputcolor+1)=*outputcolor;

};
