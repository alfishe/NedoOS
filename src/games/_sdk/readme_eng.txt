Evo SDCC/SDK kit is made to facilitate the development of non-complex graphic games for the baseconf of ZX Evolution (14 ÌÃö CPU, 4 Megabytes RAM, 320x200 in 16 colours out of 64, AY). ATM Turbo 2 (7 MHz CPU, 1 Megabyte RAM) compatibility is kept too. The kit works on a regular PC with MS Windows.

The kit contains SDCC (C cross compiler), a set of utilities to automate the resource conversion and linking, plus a low level library that provides graphics and other operations.

A developer must prepare his resources in standard formats and a C program, then the project can be compiled and linked with one button. The resulting TR-DOS disk image can be run in the ZX Evo emulator included or on a real machine.



Possibilities

About 55 kilobytes of C code. Resources and some library code reside in higher memory and switch automatically.

All the data is loaded from a disk and depacked in RAM with a loader before the run. There was not data loading initially as the disk size is less than RAM size. (But now a TR-DOS wrapper _DOS_3D13 is added to make your own disk operations, see the example.)

The library is capable of background drawing in 8x8 tiles, as well as individual 8x8 tiles. Coordinates or the tiles are multiples of 8. Individual tiles can be drawn with a given 'transparent' colour to print text over a picture.

Palette setting capability - one of 256 palettes imported from BMP, or you can set your palette in program. Virtual brightness of a palette can be changed in 7 steps from completely black to completely bright.

The library draws a list of 64 16x16 sprites with automatic background restoring. Maximum total number of sprite images is 5376 but in fact limited with RAM size. Output Y coordinate is pixel precise, X is 2 pixels precise. Output speed depends of the number of sprites in the list, opaque pixels in them, and your main program time. In a simple test you can draw about 20 ball sprites in one frame, and all the sprites can be drawn in 3 to 4 frames.

Playing three channel music in PT3 format and sound effects in AFX format. If Turbo Sound is present then the music and sound effects are played on different chips, otherwise they overlap (effects over the music).

Playing sampled sound effects with Covox (8 bit DAC). The program is stopped while the playing.

Reading joysticks and cursors on keyboard - arrows and fire. Reading 40-key keyboard.

Note: C standard libraries are not included. Evo SDK has simplified versions of memset() and memcpy(), and a 16 bit rand(). The memory must be allocated statically.



Resource formats

Graphics must be prepared in BMP format without compression, 16 or 256 colours (the first 16 are used). Any regular graphics editors can be used for this. (There are incompatibilities in newer versions of Photoshop and GIMP.)

Background images must have their sizes to be multiples of 8 pixels. Theoretical maximum is 2 Megabytes per image, 2048x2048 pixels for example. In practice, images (if used as images, not as their individual tiles) are screen size or less. There can be up to 256 background images in a project, the total size of the graphics is limited with RAM size.

Sprites are 16x16 pixels and must be prepared as one or many 256-color images with sizes that are multiple of 16 pixels. The first 16 colours can be used in graphics, the rest are transparent. This makes possible to use all the 16 colours in one sprite, plus transparent colour.

Palettes are imported from any 16 or 256 colour BMPs, separately from graphics, to make possible to use one palette with different images. Palettes can be set and changed in a program.

Music is in PT3 format. Pro Tracker 3 or Vortex Tracker II can be used for this. One AY chip is used, Turbo Sound is not supported in music. (You can use 6-channel FM music for Turbo Sound FM format, in compiled TFM Music Maker format, if you recompile the libraries - see below.)

Sound effects must be prepared in AFX format with AYFX Editor.

Sampled sound effects must be prepared as mono 8 or 16 bit uncompressed WAV files, with sampling frequency of 8000, 11025, 16000, 22050, 32000, or 44100 Hz.



Adding resources to a project

All the resources, such as images, sprites, music, sound effects, are added to a project via a batch file (compile.bat in the project directory). File names are converted into identifiers in resources.h header file.



Library functions

All the functions and their parameters are described in evo.h header file that must be included in a project. It resides in /evosdk/.



About SDCC

Evo SDK uses an older version of SDCC normally, for some reasons. Newer version compiles even the small projects for far too long, from tens seconds to sereval minutes. With --oldralloc switch it compiles as fast as the older version, with more compact code that runs slightly slower.

There is a limitation to local variables memory. If you use too much local memory, the program just fails to run, without any warnings from the compiler. Better declare them as static, at least for arrays.

You can't change SDCC version just with changing files, because of changes in assembler name, keywords for inlined assembly and library format. You must edit your sources and linker scripts. (Version of Evo SDK with SDCC 3.4.0 is now provided.)



Emulator notes

The emulator doesn't support change of CPU speed, 14 MHz is selected. As the real machine speed varies in this mode, Evo SDK uses 3.5 MHz to play samples, so they sound a lot higher than on actual machine. (You can press F1 in emulator, select ULA and load ATM1_2_3.5MHz preset to test.)



ATM Turbo 2 compatibility

To switch between ZX Evo (ATM3) and ATM Turbo 2 (or ATM Turbo 2 + TurboSound FM) recompile the libraries with one of the batch files in /evosdk/. (The default is ATM Turbo 2. ZX Evo compilation is reserved for projects that require over 1 Megabyte of RAM, because ZX Evo runs ATM Turbo 2 compilations well, without any loss in speed or anything.)



(Joystick usage notes

Please use vsync() before calling joystick() or else the music will play wrong. This is because accessing Kempston joystick requires switching off DOS signal, but interrupt handler needs it, so it's blocked.)



(Games made with Evo SDK include XNX, Innsmouth, Project R.O.B.O., 2048, Space Mercenary series, and Billiard.)


evo.h:

#pragma disable_warning 85

//declaring the types

typedef unsigned char u8;
typedef   signed char i8;
typedef unsigned  int u16;
typedef   signed  int i16;
typedef unsigned long u32;
typedef   signed long i32;

#define TRUE	1
#define FALSE	0

//masks for Kempston joystick (or cursor keys+Space) directions and buttons

#define JOY_RIGHT	0x01
#define JOY_LEFT	0x02
#define JOY_DOWN	0x04
#define JOY_UP		0x08
#define JOY_FIRE	0x10

//displacements in keyboard array, to read the keyboard

#define KEY_SPACE	0x23
#define KEY_ENTER	0x1e
#define KEY_SYMBOL	0x24
#define KEY_CAPS	0x00

#define KEY_0		0x14
#define KEY_1		0x0f
#define KEY_2		0x10
#define KEY_3		0x11
#define KEY_4		0x12
#define KEY_5		0x13
#define KEY_6		0x18
#define KEY_7		0x17
#define KEY_8		0x16
#define KEY_9		0x15

#define KEY_A		0x05
#define KEY_B		0x27
#define KEY_C		0x03
#define KEY_D		0x07
#define KEY_E		0x0c
#define KEY_F		0x08
#define KEY_G		0x09
#define KEY_H		0x22
#define KEY_I		0x1b
#define KEY_J		0x21
#define KEY_K		0x20
#define KEY_L		0x1f
#define KEY_M		0x25
#define KEY_N		0x26
#define KEY_O		0x1a
#define KEY_P		0x19
#define KEY_Q		0x0a
#define KEY_R		0x0d
#define KEY_S		0x06
#define KEY_T		0x0e
#define KEY_U		0x1c
#define KEY_V		0x04
#define KEY_W		0x0b
#define KEY_X		0x02
#define KEY_Y		0x1d
#define KEY_Z		0x01

//key flag masks

#define KEY_DOWN	0x01	//the key is held
#define KEY_PRESS	0x02	//the key was pressed, this flag is reset after you call keyboard()

//mouse button masks

#define MOUSE_LBTN	0x01
#define MOUSE_RBTN	0x02
#define MOUSE_MBTN	0x04

//a macro to get a colour code from RGB 2-bit values

#define RGB222(r,g,b)	(((b)&3)|(((g)&3)<<2)|(((r)&3)<<4))

//bright levels: lowest, highest, and medium (as specified in palette)

#define BRIGHT_MIN	0
#define BRIGHT_MID	3
#define BRIGHT_MAX	6

//this sprite image number marks the end of sprite list

#define SPRITE_END	0xff00



//fill memory with a value

void memset(void* m,u8 b,u16 len) _naked;

//copy memory, the areas can't collide

void memcpy(void* d,void* s,u16 len) _naked;

//generate a 16-bit pseudo-random number

u16 rand16(void) _naked;

//set border colour, 0..15

void border(u8 n) _naked;

//wait for the next TV frame

void vsync(void) _naked;

//read Kempston joystick and cursor keys+Space
//use vsync() before calling joystick() or else the music will play wrong
//see JOY_ constants above to mask the directions and buttons

u8 joystick(void) _naked;

//read the keyboard, returns 40-byte array of key states
//see KEY_ constants above to mask the states of the keys

void keyboard(u8* keys) _naked;

//read the current mouse position. X resolution is low (2 pixels as in sprites)
//mouse moves in a given clipping zone, see below

u8 mouse_pos(u8* x,u8* y) _naked;

//set the current position for mouse

void mouse_set(u8 x,u8 y) _naked;

//set the clipping zone for mouse, 0..160, 0..200 by default

void mouse_clip(u8 xmin,u8 ymin,u8 xmax,u8 ymax) _naked;

//get mouse move deltas, without lowering X resolution

u8 mouse_delta(i8* x,i8* y) _naked;

//play a given sound effect with given relative volume -8..8

void sfx_play(u8 sfx,i8 vol) _naked;

//stop all the sound effects that are playing

void sfx_stop(void) _naked;

//play a given music track (or resume after stopping)

void music_play(u8 mus) _naked;

//stop the music

void music_stop(void) _naked;

//play sample via Covox
//while playing, the program is stopped and interrupts are off

void sample_play(u8 sample) _naked;

//set all the values in the palette to 0 (black)

void pal_clear(void) _naked;

//set screen brightness BRIGHT_MIN..BRIGHT_MID..BRIGHT_MAX (0..3..6)
//from completely black, to specified in the palette, to completely white

void pal_bright(u8 bright) _naked;

//select a predefined palette

void pal_select(u8 id) _naked;

//copy a predefined palette into an array (16 bytes)

void pal_copy(u8 id,u8* pal) _naked;

//set a colour in the palette, id 0..15, col in R2G2B2 format

void pal_col(u8 id,u8 col) _naked;

//set all the 16 colours in the palette with R2G2B2 values from an array

void pal_custom(u8* pal) _naked;

//select an image for draw_tile()

void select_image(u8 id) _naked;

//select a transparent colour 0..15 for draw_tile_key()

void color_key(u8 col) _naked;

//draw tile from the current image
//one image can hold up to 65536 tiles (in reality, less, see above)

void draw_tile(u8 x,u8 y,u16 tile) _naked;

//draw tile with a mask (transparent colour)

void draw_tile_key(u8 x,u8 y,u16 tile) _naked;

//draw full image

void draw_image(u8 x,u8 y,u8 id) _naked;

//clear shadow (currently invisible) screen with colour 0..15

void clear_screen(u8 color) _naked;

//swap screens, the shadow screen becomes visible
//automatically waits for the next TV frame, doesn't need vsync() before the call
//this functions renews the sprites on screen, if they are on

void swap_screen(void) _naked;

//start the sprite drawing system
//visible screen must contain image where the sprites will be drawn
//this function is slow because of copying a lot of data
//when the sprites are on, they will be drawn automatically with swap_screen()

void sprites_start(void) _naked;

//stop the sprite drawing system

void sprites_stop(void) _naked;

//set sprite position
//id is a number in sprite list (0..63)
//x is X coordinate 0..152 (2 pixels precision)
//y is Y coordinate 0..184
//spr is sprite image number, or SPRITE_END to mark the end of list
//warning: there is no clipping, so sprite can't cross screen border

void set_sprite(u8 id,u8 x,u8 y,u16 spr) _naked;

//returns time passed since the start of the program

u32 time(void) _naked;

//wait a nomber of frames (one frame is 1/50 second)

void delay(u16 time) _naked;



(Translated and commented by Alone Coder. This translation and its descendants are not for use outside of this Evo SDK package unless I permit this. That's because of a certain immoral person who uses a patched Evo SDK and others' games to advertize his FPGA hardware. Ask any questions at dmitry (dot) alonecoder (at) gmail (dot) com.)