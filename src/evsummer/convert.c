#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void convertbyte(unsigned char *inputbyte1,unsigned char *inputbyte2,unsigned char *outputbyte);
void convertcolor(unsigned char *inputcolor, unsigned char *outputcolor);
int main(int argc, char *argv[])
{
    FILE *infile,*outfile,*palette;
    long size;
    unsigned char *bitmap,*outbit,*pal,*palname;
    int i,j,palsize;
    if (argc <3) {printf("Use convert <input.raw> <out.16c)\n");return 0; };

    
    if (!(infile=fopen(argv[1],"rb"))){
	printf("Failed to open %s for reading!\n",argv[1]);
	return -1;
    };

    palname=malloc(strlen(argv[1])+5);
    strcpy(palname,argv[1]);
    strcat(palname,".pal");
    if (!(palette=fopen(palname,"rb"))){
	printf("Failed to open %s.pal for reading!\n",argv[1]);
	return -1;
    };

    if (!(outfile=fopen(argv[2],"wb"))){
	printf("Failed to open %s for writing!\n",argv[2]);
	fclose(infile);
	return -1;
    };

    

    fseek(infile, 0, SEEK_END);
    size=ftell(infile);
    fseek(infile, 0, SEEK_SET);
    bitmap=malloc(size);
    fread(bitmap,size,1,infile);
    outbit=malloc(32768+32);
    pal=malloc(48);

    printf("Converting %s... \n",argv[1]);

    j=0;
    for (i=0;i<size;i=i+8)
    {
	convertbyte(bitmap+i,bitmap+i+1,outbit+j);
	convertbyte(bitmap+i+2,bitmap+i+3,outbit+j+0x4000);
	convertbyte(bitmap+i+4,bitmap+i+5,outbit+j+0x2000);
	convertbyte(bitmap+i+6,bitmap+i+7,outbit+j+0x6000);
	j++;
    };

    palsize=fread(pal,1,48,palette);
    for (i=0;i<palsize;i=i+3)
	convertcolor(pal+i,outbit+32768+(i/3)*2);

    for (i=palsize;i<48;i=i+3){
	*(outbit+32768+(i/3)*2)=0b00001100; //zero colors
	*(outbit+32768+(i/3)*2+1)=0b00001100; //zero colors
    }

    fwrite(outbit,32768+32,1,outfile);
    fclose(infile);
    fclose(outfile);
    if (palette) fclose(palette);
    free(bitmap);
    free(outbit);
    free(pal);
    free(palname);
    return 0;
};

void convertbyte(unsigned char *inputbyte1,unsigned char *inputbyte2,unsigned char *outputbyte)
{
	*outputbyte=*inputbyte1&7;
	if (*inputbyte1&8) *outputbyte=*outputbyte|64;
	*outputbyte=*outputbyte|(*inputbyte2&7)<<3;
	if (*inputbyte2&8) *outputbyte=*outputbyte|128;
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
