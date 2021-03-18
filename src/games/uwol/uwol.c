// Jias jias - Este es como el subaquatic, que lleva en desarrollo tanto
// tiempo que el código de aquí abajo da miedo miedor.

#include "splib.h"

/* Extern pointers for the graphic definitions: */

#include "resources.h"
#include "fases.h"
#include "sprites.h"

#define MAXCURBRIGHT (4*3)

/* Game constants */

#define CANAL_FX        1       // Canal por el que suenan los efectos de sonido

/* masks for joystick functions */

#define sp_START		0x0100
#define sp_FIRE			0x0080
#define sp_RIGHT		0x0008
#define sp_LEFT			0x0004
#define sp_DOWN			0x0002
#define sp_UP			0x0001

i8 play;
u8 curbright;

/* Import sp_ClipStruct */

struct sp_Rect *sp_ClipStruct;

struct sp_Rect spritesClipValues;
struct sp_Rect *spritesClip;

/* Manage keys and joystick at the same time: */
u8 keys[255];

u16 joyfunc(void)
{
    u16 i;
    i16 res;
 
    i=joystick();
	keyboard(keys);
 
    res=0;
    if(i&JOY_LEFT)  res|=sp_LEFT;
    if(i&JOY_RIGHT) res|=sp_RIGHT;
    if(i&JOY_UP)    res|=sp_UP;
    if(i&JOY_DOWN)  res|=sp_DOWN;
    if(i&JOY_FIRE)	res|=sp_FIRE;
    if(keys[KEY_ENTER]==KEY_DOWN)	res|=sp_START;
 
    return res^0xffff;
}

/* Data types */

typedef struct {
    i16 x, y;
    i16 vx, vy;
    i8 g, ax, rx;
    u8 salto, cont_salto;
    u8 saltando;
    u16 frame, subframe, facing;
    u8 estado;
    u8 ct_estado;
    u16 ground,nojump;
} INERCIA;

#define EST_NORMAL       0
#define EST_NUDE         1
#define EST_PARP         2
#define EST_MUR          4
#define EST_EXIT         8
#define EST_EXIT_LEFT   16
#define EST_EXIT_RIGHT  32

INERCIA player;

i8 pantalla;
i8 visitados [55];
i8 lives;


// Estructura de datos para los objetos móviles:
typedef struct {
    u8 x, y;
    i8 vx, vy;
    u8 t1, t2;
    i16 rx, ry;
    u16 current_frame, next_frame;
    i8 tipo;
} MOVILES;

MOVILES moviles[3];
struct sp_SS *sp_moviles [3];

// Almacena las monedas del nivel actual

typedef struct {
    u16 type;
    u16 x,y;
    struct sp_SS *sp;
} MONEDA;

MONEDA monedas[10];
u8 num_monedas;

// Para ahorrar IFs...
const u16 enem_frames [8] = {
    wolfi_1a,       wolfi_1a,
    franki_1a,      franki_1a,
    vampi_1a,       vampi_1a,
    fanti_l_1a,     fanti_r_1a
};

i8 flag1, flag2;
u8 playing;
i8 level;

// Espacio para guardar 12 bloques de fondo.
u8 tile_buffer01 [8];

u8 j, x, y, xx, yy, xt, yt;
i8 i;
i8 fantact;
struct sp_SS *sp_prueba;
i8 *timer;
u8 *wyz_music_flag;
u8 *allpurposepuntero;
u8 maincounter;
u8 n_pant;
u16 total_score;
u16 total_coins;
i8 time8;
u8 xcami, ycami;
struct sp_Rect rectangulo;
u8 prueba[8];
i8 bonus1, bonus2;

i8 vidaextra;

u16 rand_seed;

u16 cheat;
u16 monedas_frame;

const u16 monedas_anim[]={
    coin_1a,coin_1a+DSPR*1,coin_1a+DSPR*2,coin_1a+DSPR*2,coin_1a+DSPR*1,coin_1a,coin_1a+DSPR*3,coin_1a+DSPR*4,coin_1a+DSPR*4,coin_1a+DSPR*3
};
//#define monedas_frames 10
#define monedas_frames (sizeof(monedas_anim)/sizeof(u16))

const u16 monedas_take_anim[]={
    coin_1a,coin_1a+DSPR*1,coin_1a+DSPR*2,coin_1a+DSPR*4,coin_1a+DSPR*5,coin_1a+DSPR*6,coin_1a+DSPR*7,coin_1a+DSPR*8,coin_1a+DSPR*9,coin_1a+DSPR*10
};

const u16 player_anim[]={
    uwol_r_1a,uwol_r_2a,uwol_r_3a,uwol_r_2a,
    uwol_l_1a,uwol_l_2a,uwol_l_3a,uwol_l_2a,
    uwolpelot_r_1a,uwolpelot_r_2a,uwolpelot_r_3a,uwolpelot_r_2a,
    uwolpelot_l_1a,uwolpelot_l_2a,uwolpelot_l_3a,uwolpelot_l_2a
};

const u8 level_number[]={
1,
1,2,
1,2,3,
1,2,3,4,
1,2,3,4,5,
1,2,3,4,5,6,
1,2,3,4,5,6,7,
1,2,3,4,5,6,7,8,
1,2,3,4,5,6,7,8,9,
1,2,3,4,5,6,7,8,9,10
};

struct sp_SS *arrow_l;
struct sp_SS *arrow_r;
 

#define SPTW 4/7//2/3

/*
//packed screens data

extern const u8 mojon_data[];
extern const u8 credits_data[];
extern const u8 title_data[];
extern const u8 gover_data[];
extern const u8 finbad_data[];
extern const u8 fingoo_data[];
extern const u8 finend_data[];
extern u16 warp_palette[];
*/

//music data
#define SONG_MENU MUS_MENU
#define SONG_PIRAMIDE MUS_PIRAMIDE
#define SONG_ZONA1 MUS_ZONA1
#define SONG_ZONA2 MUS_ZONA2
#define SONG_ZONA3 MUS_ZONA3
#define SONG_ZONA4 MUS_ZONA4
#define SONG_FANTASMA MUS_FANTASMA
#define SONG_GAMEOVER MUS_GAMEOVER
#define SONG_ENDINGKO MUS_ENDINGKO
#define SONG_ENDINGOK MUS_ENDINGOK
/*
extern const u8 menu_data[];
extern const u8 piramide_data[];
extern const u8 zona1_data[];
extern const u8 zona2_data[];
extern const u8 zona3_data[];
extern const u8 zona4_data[];
extern const u8 fantasma_data[];
extern const u8 gameover_data[];
extern const u8 endingko_data[];
extern const u8 endingok_data[];
*/

// Pelotingui o vestido:

u8 rand () {
    rand_seed*=31421;
    rand_seed+=6927;
    return (u8)rand_seed;
}

void wyz_play_sound (u8 fx_number, u8 fx_channel)
{
    if (!play)
        return;
 
	//psgfx_play(fx_number);
	sfx_play(fx_number+SFX_NONAME001,5/*volume -7..+7*/);
}

//void wyz_play_music (const u8 *data)
void wyz_play_music (u8 songnum)
{
    if (!play)
        return;

/*    tfc_play(FALSE);
    tfc_init(data);
    tfc_play(TRUE);*/
	music_play(songnum);
}

void wyz_stop_sound ()
{
    if (!play)
        return;
 
    //tfc_play(FALSE);
	music_stop();
}

/* Auxiliary functions */

void todo_a_negro () {
    i16 i,j;
 
    for(i=0;i<24;i++)
    {
        for(j=0;j<32;j++) sp_AttrSet(j,i,0);
    }
}

/* fade into a given palette */

//void fade_into(u16 *palette)
void fade_into()
{
	
	pal_bright(BRIGHT_MIN+(curbright/4));
	//pal_bright(BRIGHT_MIN+3);
	if(curbright<MAXCURBRIGHT) curbright++;
}

void fade_out ()
{
    //fade_screen(TRUE);
	for(i=0;i<4;++i)
	{
		pal_bright(BRIGHT_MID-i);
		for(j=0;j<4;++j) vsync();
	}
    todo_a_negro();
}

//void fade_screen(u16 out)
void fade_screen()
{
    u16 i;

	curbright=0;

	for(i=0;i<16;i++)
	{
		fade_into();
		vsync();
	}
}

//void unpack_RAM3 (const u8 *data)
void view_image (u8 image)
{
	pal_bright(BRIGHT_MIN);
	pal_select(image);

    //unpack_screen(data);
	draw_image(0,0,image);
	swap_screen();
	fade_screen();
}

/* Game functions */

void draw_lives (i8 lives) {
    sp_PrintAtInv (0, 6, 71, 99);
    sp_PrintAtInv (0, 7, vidaextra && (player.estado & EST_PARP) && (player.ct_estado & 1) ? 71 : 69, 89 + (lives / 10));
    sp_PrintAtInv (0, 8, vidaextra && (player.estado & EST_PARP) && (player.ct_estado & 1) ? 71 :69, 89 + (lives % 10));
}

void draw_score (u8 score) {
    sp_PrintAtInv (0, 24, 71, 99);
    sp_PrintAtInv (0, 25, 69, 89 + (score / 100));
    sp_PrintAtInv (0, 26, 69, 89 + (score % 100) / 10);
    sp_PrintAtInv (0, 27, 69, 89 + (score % 10));
}

void draw_total_score (i8 y,i8 x,u16 total_score) {
    sp_PrintAtInv (y, x+0, 4, 106);
    sp_PrintAtInv (y, x+1, 4, 107);
    sp_PrintAtInv (y, x+2, 4, 108);
    sp_PrintAtInv (y, x+3, 4, 109);
    sp_PrintAtInv (y, x+4, 4, 103);
    sp_PrintAtInv (y, x+5, 7, 99);
    sp_PrintAtInv (y, x+6, 5, 89 + total_score / 10000);
    sp_PrintAtInv (y, x+7, 5, 89 + (total_score % 10000) / 1000);
    sp_PrintAtInv (y, x+8, 5, 89 + (total_score % 1000) / 100);
    sp_PrintAtInv (y, x+9, 5, 89 + (total_score % 100) / 10);
    sp_PrintAtInv (y, x+10, 5, 89 + (total_score % 10));
}

void draw_time (i8 time) {
    sp_PrintAtInv (0, 12, 68, 100);
    sp_PrintAtInv (0, 13, 68, 101);
    sp_PrintAtInv (0, 14, 68, 102);
    sp_PrintAtInv (0, 15, 68, 103);
    sp_PrintAtInv (0, 16, 71, 99);
    sp_PrintAtInv (0, 17, 69, 89 + (time / 100));
    sp_PrintAtInv (0, 18, 69, 89 + (time % 100) / 10);
    sp_PrintAtInv (0, 19, 69, 89 + (time % 10));
}

void draw_level (i8 y,i8 x,i8 level,u16 n_pant) {
    sp_PrintAtInv (y,x+0, 4, 104);
    sp_PrintAtInv (y,x+1, 4, 103);
    sp_PrintAtInv (y,x+2, 4, 105);
    sp_PrintAtInv (y,x+3, 4, 103);
    sp_PrintAtInv (y,x+4, 4, 104);
    if(level>=10)
    {
        sp_PrintAtInv (y,x+5, 5, 90);
        x++;
    }
    sp_PrintAtInv (y,x+5, 5, 89 + (level % 10));
    sp_PrintAtInv (y,x+6, 5, 84);
    if(level_number[n_pant]>=10)
    {
        sp_PrintAtInv (y,x+7, 5, 90);
        x++;
    }
    sp_PrintAtInv (y,x+7, 5, 89 + (level_number[n_pant] % 10));
}

u16 collision_v(u16 x,u16 y,u16 h)
{
    u16 i;

    h--;
    h=((y+h)>>3)-(y>>3)+1;
 
    for(i=0;i<h;i++)
    {
        if(sp_AttrGet(x>>3,y>>3)>63) return TRUE;
        y+=8;
    }

    return FALSE;
}

u16 collision_h(u16 x,u16 y,u16 w)
{
    u16 i;

    w--;
    w=((x+w)>>3)-(x>>3)+1;
 
    for(i=0;i<w;i++)
    {
        if(sp_AttrGet(x>>3,y>>3)>63) return TRUE;
        x+=8;
    }

    return FALSE;
}

void move (u16 i) {
    u8 xx, yy;
    u8 x, y;
    u16 off;

    /* Primera prueba del motor de movimiento de inercia para z88dk/splib2
       Vamos a ver si esto no explota tó */

    /* Por partes. Primero el movimiento vertical. La ecuación de movimien-
       to viene a ser, en cada ciclo:

       1.- vy = vy + g
       2.- y = y + vy

       O sea la velocidad afectada por la gravedad.
       Para no colarnos con los nmeros, ponemos limitadores:
    */

    if (player.vy < 512*SPTW/*256*/)
        player.vy += player.g;
    else
        player.vy = 512*SPTW/*256*/;

    player.y += player.vy;
    if (player.y < 0)
        player.y = 0;
 
    /* El problema es que no es tan fácil... Hay que ver si no nos chocamos.
       Si esto pasa, hay que "recular" hasta el borde del obstáculo.

       Por eso miramos el signo de vy, para que los cálculos sean más sencillos.
       De paso vamos a precalcular un par de cosas para que esto vaya más rápido.
    */

    x = player.x >> 6;              // dividimos entre 64 para pixels, y luego entre 8 para tiles.
    y = player.y >> 6;
    xx = x >> 3;
    yy = y >> 3;

    if (player.vy < 0) {            // estamos ascendiendo
        if (player.y >= 1024)
            if(collision_h(x+2,y+4,16-4)) {
                // paramos y ajustamos:
                player.y = player.y-player.vy;
                player.vy = 0;
            }
        player.ground=FALSE;
    } else if (player.vy > 0) {     // estamos descendiendo
        if(collision_h(x+2,y+16,16-4))
        {
            // paramos y ajustamos:
            player.vy = 0;
            player.y = yy << 9;
            if(!player.ground)
            {
                player.ground=TRUE;
                player.nojump=TRUE;
                wyz_play_sound (0, CANAL_FX);
            }
        }
        else
        {
            player.ground=FALSE;
        }
    }

    /* Salto: El salto se reduce a dar un valor negativo a vy. Esta es la forma más
       sencilla. Sin embargo, para más control, usamos el tipo de salto "mario bros".
       Para ello, en cada pulsación dejaremos decrementar vy hasta un mínimo, y de-
       tectando que no se vuelva a pulsar cuando estemos en el aire. Juego de banderas ;)
    */

    if ( !player.nojump && (i & sp_FIRE) == 0 && player.vy == 0 && player.saltando == 0 && player.ground) {
        player.saltando = 1;
        player.cont_salto = 0;
        wyz_play_sound (7, CANAL_FX);

        // Para que el inicio del salto sea más potente: (a veces conviene):
        // player.vy -= (player.salto << 1);
    }

    if ( (i & sp_FIRE) == 0 && player.saltando ) {
        player.vy -= (player.salto + 48*SPTW/*16*/ - (player.cont_salto>>1));
        if (player.vy < -256/*128*/) player.vy = -256/*128*/;

        player.cont_salto ++;
        if (player.cont_salto == 6/*8*/)
            player.saltando = 0;
    }

    if ( (i & sp_FIRE) != 0)
        {
            player.saltando = 0;
            player.nojump=FALSE;
        }
 
    // ------ ok con el movimiento vertical.

    /* Movimiento horizontal:

       Mientras se pulse una tecla de dirección,
 
       x = x + vx
       vx = vx + ax

       Si no se pulsa nada:

       x = x + vx
       vx = vx - rx
    */

    if ( ! ((i & sp_LEFT) == 0 || (i & sp_RIGHT) == 0))
        {
        if (player.vx > 0) {
            player.vx -= player.rx;
            if (player.vx < 0)
                player.vx = 0;
        } else if (player.vx < 0) {
            player.vx += player.rx;
            if (player.vx > 0)
                player.vx = 0;
        }
        }

    if ((i & sp_LEFT) == 0)
        {
        if (player.vx > -192*SPTW) {
            player.facing = 0;
            player.vx -= player.ax;
        }
        }

    if ((i & sp_RIGHT) == 0)
        {
        if (player.vx < 192*SPTW) {
            player.vx += player.ax;
            player.facing = 1;
        }
        }

    player.x = player.x + player.vx;

    /* Ahora, como antes, vemos si nos chocamos con algo, y en ese caso
       paramos y reculamos */

    y = player.y >> 6;
    x = player.x >> 6;
    yy = y >> 3;
    xx = x >> 3;

    if (player.y >= 512/*1024*/)
        {
        if (player.vx < 0) {
            if(collision_v(x+2,y+4,16-4)) {
                // paramos y ajustamos:
                player.x = player.x-player.vx;
                player.vx = 0;
            }
        } else {
            if(collision_v(x+16-2,y+4,16-4)) {
                // paramos y ajustamos:
                player.x = player.x-player.vx;
                player.vx = 0;
            }
        }
        }

    // Calculamos el frame que hay que poner:

    if(player.vx!=0) player.subframe++;
    off=(player.subframe>>1)&3;
    if(player.facing==0) off+=4;
    if(player.estado&EST_NUDE) off+=8;
    player.frame=player_anim[off];

    // Wrap around
 
    if (player.x <= 1088)
        player.x = 14270;
 
    if (player.x >= 14272)      player.x = 1090;
 
    // Morir en un pit
 
    if (player.y > 10752) {
        player.frame = uwolmuete_1a;
        player.estado |= EST_MUR;
        player.vy = - 7*SPTW * (player.salto);
        player.y = 10750;
        lives --;
        if (lives >= 0) draw_lives (lives);
        wyz_play_sound(11, CANAL_FX);
    }
 
    // Saliendo de la fase
 
    if (!(i & sp_DOWN))
        {
        if ( player.estado & EST_EXIT ) {
            if ( player.x > 2204 && player.x < 2880 )
                player.estado |= EST_EXIT_LEFT;
            if ( player.x > 12480 && player.x < 13120 )
                player.estado |= EST_EXIT_RIGHT;
        }
        }
}

void death_sequence () {
    if (player.vy < 1024*SPTW/*256*/)
        player.vy += player.g;
    else
        player.vy = 1024*SPTW/*256*/;

    player.y += player.vy;
 
    // Esto acaba cuando el jugador sale de la pantalla:
 
    if (player.y > 11264) {
        player.estado = EST_PARP;
        player.x = 32 << 6;
        player.y = 144 << 6;
        player.vx = player.vy = 0;
        player.ct_estado = 32*3/2;                      // Tiempo de inmunidad.
        flag1 = 3;
        playing = 0;
    }
}

void draw_minitile(i8 y, i8 x, u8 c, u8 tile)
{
	if(x<28&&y<22) sp_PrintAtInv (y, x, c, tile);
}

void draw_tile4 (i8 x, i8 y, u8 c, u8 tile, u8 off) {
    draw_minitile( off + y,    off + x,    c, tile);
    draw_minitile( off + y,   (off^1) + x, c, tile + 1);
    draw_minitile((off^1) + y, off + x,    c, tile + 2);
    draw_minitile((off^1) + y,(off^1) + x, c, tile + 3);
}

void draw_screen (u16 r_pant) {
    /* Esta función lee del array de pantallas y pinta la pantalla que
       se le pasa en el argumento.
    */
 
    struct sp_Rect rectangulo;
    i8 x,y;
    i8 l,n,v,t1,t2,t;
    u16 i,j,n_pant;
    u8 bd_atr, bd_pap, bd_ink;
 
    // Sí, amigos, somos unos trampucheros. No hay 55 pantallas. Hay 45
    // y se repiten 10.
 
    n_pant = r_pant % 45;
 
    // Qué malos somos.
 
    // Calculamos el atributo de fondo correctamente de forma que INK > PAPER
    // si esto no ocurre (puede pasar en las fases repetidas), se cambia.
 
    bd_atr = (level == 10) + (fases[n_pant].descriptor & 63);
    bd_ink = bd_atr & 7;
    bd_pap = bd_atr >> 3;
    if (bd_ink < bd_pap) {
        i = bd_pap;
        bd_pap = bd_ink;
        bd_ink = i;
    }
    bd_atr = bd_ink + (bd_pap << 3);
 
    // Ea, ahora el Anju se queda contento :-P
 
    // Calculamos el tile de fondo según la altura:
    if (level < 4)
        t = 1;
    else if (level < 7)
        t = 5;
    else if (level < 9)
        t = 9;
    else
        t = 13;
 
    // Primero el fondo
    for (y = 0; y < 10; y++)
        for (x = 0; x < 12; x++) {
            draw_tile4 (4 + (x<<1), 2 + (y<<1), bd_atr, t,0);
        }

    // Objetos
    for (i = 0; i < 10; i ++) {
        if (fases[n_pant].obj[i] != 0) {
            x = (u8) (fases[n_pant].obj[i] >> 12) & 15;
            y = (u8) (fases[n_pant].obj[i] >> 8) & 15;
            l = (u8) (fases[n_pant].obj[i] >> 4) & 15;
            n = (u8) (fases[n_pant].obj[i] >> 1) & 7;

            if ( (fases[n_pant].obj[i] & 1) == 0 ) {
                // plataforma horizontal
                for (j = x; j < x + l; j ++)
                    draw_tile4 (5 + (j<<1), 3 + (y<<1), bd_atr, 16 + t,1);
                for (j = x; j < x + l; j ++)
                    draw_tile4 (4 + (j<<1), 2 + (y<<1), 64, 49 + (n<<2),0);
            } else {
                // plataforma vertical
                for (j = y; j < y + l; j ++)
                    draw_tile4 (5 + (x<<1), 3 + (j<<1), bd_atr, 16 + t,1);
                for (j = y; j < y + l; j ++)
                    draw_tile4 (4 + (x<<1), 2 + (j<<1), 64, 49 + (n<<2),0);
            }
        }
    }
 
    // Monedas:
    // Act 20091201 :: Sólo pintamos monedas si la habitación NO ha sido visitada :-)
 
    if (!visitados [r_pant]) {
        num_monedas = 0;
 
        rectangulo.width = rectangulo.height = 2;
 
        for ( i = 0; i < 10; i ++) {
        //fases [n_pant].coin [i] = i;
            // Primero copiamos los valores en nuestra estructura
            monedas [i].type = fases [n_pant].coin [i]?1:0;
 
            if (fases [n_pant].coin [i] != 0) {
                // Y ahora dibujamos
                x = (u8) (fases [n_pant].coin [i] >> 4);
                y = (u8) (fases [n_pant].coin [i] & 15);
                monedas[i].x=(4+(x<<1))<<3;
                monedas[i].y=(2+(y<<1))<<3;
 
                monedas[i].sp=sp_CreateSpr (sp_MASK_SPRITE, 3, 0, 1, TRANSPARENT);
                sp_MoveSprAbs (monedas[i].sp, spritesClip, coin_1a, 2+(y<<1), 4+(x<<1), 0, 0);
 
                num_monedas ++;
            }
        }
    }
 
    // Cargamos ahora los objetos móviles
    for (i = 0; i < 3; i ++) {
        if (fases [n_pant].movil [i] == 0)      // Enemigo desactivado.
            moviles [i].tipo = -1;
        else {
            v = (u8) (fases [n_pant].movil [i] & 1);
            n = (u8) (fases [n_pant].movil [i] >> 1) & 7;
            y = (u8) (fases [n_pant].movil [i] >> 4) & 15;
            t1 = (u8) (fases [n_pant].movil [i] >> 12) & 15;
            t2 = (u8) (fases [n_pant].movil [i] >> 8) & 15;
 
 
            moviles [i].x = moviles [i].t1 = 32 + (t1 << 4);
            moviles [i].t2 = 32 + (t2 << 4);
            moviles [i].y = 16 + (y << 4);
            moviles [i].vx = v*SPTW + 1;
            moviles [i].tipo = n;
 
            if (n != 3)
                moviles [i].next_frame = enem_frames [ 1 + (n << 1) ];
            moviles[i].current_frame=moviles[i].next_frame;

            sp_MoveSprAbs (sp_moviles [i], spritesClip, moviles[i].current_frame, 0,0,0,0);
        }
    }
 
    for(i=0;i<24;i++)
    {
        sp_AttrSet(2,i,sp_AttrGet(26,i));
        sp_AttrSet(3,i,sp_AttrGet(27,i));
        sp_AttrSet(28,i,sp_AttrGet(2,i));
        sp_AttrSet(29,i,sp_AttrGet(3,i));
    }
}

i8 abs8 (i8 x) {
    return x < 0 ? -x : x;
}

void move_moviles () {
    // Esto mueve los tres móviles (en caso de estar definidos, o sea, con tipo != 0
 
    u8 i;
 
    for (i = 0; i < 3; i ++)
        if ( moviles [i].tipo == 3) {
            // Fanty
            if (player.x > moviles [i].rx && moviles [i].vx < 100/*120*/*SPTW) {
                moviles [i].vx +=4*SPTW;
                moviles [i].next_frame = enem_frames [ 1 + (moviles [i].tipo << 1) ];
            } else if (player.x < moviles [i].rx && moviles [i].vx > -100/*120*/*SPTW) {
                moviles [i].vx -=4*SPTW;
                moviles [i].next_frame = enem_frames [ moviles [i].tipo << 1 ];
            }
 
            if (player.y > moviles [i].ry && moviles [i].vy < 100/*120*/*SPTW)
                moviles [i].vy +=4*SPTW;
            else if (player.y < moviles [i].ry && moviles [i].vy > -100/*120*/*SPTW)
                moviles [i].vy -=4*SPTW;
 
            moviles [i].rx += moviles [i].vx;
            moviles [i].ry += moviles [i].vy;
    // Wrap around
 
    if (moviles [i].rx <= 1088) moviles [i].rx = 14270;
    if (moviles [i].rx >= 14272) moviles [i].rx = 1090;
 
            moviles [i].x = (u8) (moviles [i].rx >> 6);
            moviles [i].y = (u8) (moviles [i].ry >> 6);
        } else if ( moviles [i].tipo > -1 && !( player.estado & EST_EXIT )) {
            // Franky o Vampy o Wolfi
            moviles [i].x += moviles [i].vx;
            if ( moviles [i].x <= moviles [i].t1) {
                moviles [i].vx = abs8 (moviles [i].vx);
                moviles [i].next_frame = enem_frames [ 1 + (moviles [i].tipo << 1) ];
            }
 
            if ( moviles [i].x >= moviles [i].t2) {
                moviles [i].vx = -abs8 (moviles [i].vx);
                moviles [i].next_frame = enem_frames [ moviles [i].tipo << 1 ];
            }
        }
}

u8 game (u8 n_pant) {
    u8 salida;
    u8 aux;
    u8 fade;
    u16 i,j,idx;
    u16 type;
    u16 pause,pause_cnt;
    u16 arrow_yoff;
	
	u8 curtime,oldtime,logictime,logicframe;
	oldtime = time()-1;
	
    salida=0;
    flag1 = 0;
    idx=0;

    player.x = 32 << 6;
    player.y = 144 << 6;
    player.vy = 0;
    player.g = 32*SPTW; //8;
    player.vx = 0;
    player.ax = 24*SPTW; //8;
    player.rx = 32*SPTW; //8;
    player.salto = 64*SPTW;
    player.cont_salto = 1;
    player.saltando = 0;
    player.frame = 0;
    player.subframe = 0;
    player.facing = 1;
    player.estado = EST_NORMAL;
    player.ct_estado = 0;
    player.ground=TRUE;
    player.nojump=FALSE;
 
    todo_a_negro ();

    //sp_DelAllSpr();
	clear_screen(0);
	swap_screen();
	clear_screen(0);
	swap_screen();
	set_sprite(0/*i*/,0,0,SPRITE_END);
	sprites_start(); //ïðè ðàçðåø¸ííûõ ñïðàéòàõ àâòîìàòè÷åñêè âûïîëíÿåòñÿ êîïèðîâàíèå âûâîäèìîé ãðàôèêè â äâà ýêðàíà
	
	curbright=0;
	pal_bright(BRIGHT_MIN);
	pal_select(PAL_TILES);

    draw_screen (n_pant);
    sp_UpdateNow();
 
    time8 = num_monedas * 8/3;//2;
 
    draw_lives (lives);
    draw_time (time8);
    draw_level (23,4,level,n_pant);
    draw_score (total_coins);
    draw_total_score (23,17,total_score);
 
    sp_PrintAtInv(0,5,71,110);
    sp_PrintAtInv(0,23,71,111);

    maincounter = 0;
    playing = 1;
    fantact = 0;
    vidaextra = 0;
 
    player.frame = uwol_r_2a;

    // Calculamos el tile de fondo según la altura:
    if (level < 4)
        //wyz_play_music (zona1_data);
        wyz_play_music (SONG_ZONA1);
    else if (level < 7)
        //wyz_play_music (zona2_data);
        wyz_play_music (SONG_ZONA2);
    else if (level < 9)
        //wyz_play_music (zona3_data);
        wyz_play_music (SONG_ZONA3);
    else
        //wyz_play_music (zona4_data);
        wyz_play_music (SONG_ZONA4);
 
    // Si la habitación ya fue visitada, mostramos las salidas y al fantasmilla.
    if (visitados [n_pant]) {
        num_monedas = 0;
        time8 = 0;
    }
 
    monedas_frame=0;
 
    //sp_SetSpriteClip(spritesClip);
    fade=0;
    pause=FALSE;
    pause_cnt=25;
    arrow_yoff=0;

	sp_MoveSprAbs(arrow_l,spritesClip,arrow_1a,0,0,0,0);
	sp_MoveSprAbs(arrow_r,spritesClip,arrow_1a,0,0,0,0);

    while (playing) {
        maincounter ++;     // Como es un u8, irá siempre de 0 a 255, con ciclos potencias de 2.
 
        //if(fade==2) fade_screen(FALSE);
        //if(fade<10) fade++;
		if(pause_cnt) pause_cnt--;
 
        //fade_into(needed_pal);
		if(!pause) fade_into();
		if (curbright>MAXCURBRIGHT) curbright = MAXCURBRIGHT; //áåëîòà îò âçÿòèÿ ìîíåòîê òîëüêî íà 1 ôðåéì, ïîòîì óáèðàåòñÿ
		
    	j = joyfunc(); // Leemos del teclado
    	
    	if((j^0xffff)&sp_START)
    	{
    		if(!pause_cnt)
    		{
    			pause^=TRUE;
    			pause_cnt=25;
    			wyz_play_sound( 7, CANAL_FX );
    			if(pause) //âõîäèì â ïàóçó
    			{
					/*for(i=0;i<64;i++)
					{
						j=(((needed_pal[i]&0x0f00)>>8)+((needed_pal[i]&0x00f0)>>4)+((needed_pal[i]&0x000f)))/3;
						needed_pal[i]=j|(j<<4)|(j<<8);
					}*/
					curbright=4;
					pal_bright(BRIGHT_MIN+curbright/4);
    			}
    			else //âûõîäèì èç ïàóçû
    			{
    				//fade_screen(FALSE); //sets target palette to default and fades in
    			}
    		}
    	}
    	
    	if(pause)
    	{
    		vsync();
			//update_palette();
    		continue;
    	}

        if ( !(maincounter & 31)) {
            if (time8 > 0) {
                time8 --;
                draw_time (time8);
            } else {
                // ¡Cuando se acaba el tiempo sale el fanti!
                if (time8 == 0) {
                    wyz_stop_sound ();
					//wyz_play_music (fantasma_data);
					wyz_play_music (SONG_FANTASMA);
 
                    time8 --;
 
                    // Lógica: buscamos el primer enemigo "vacío". De no haberlo,
                    // se sustituye el último enemigo por fanti.
 
                    idx = 2;
 
                    for ( i = 0; i < 3; i ++)
                        if (moviles [i].tipo == -1) {
                            idx = i;
                            moviles [idx].x = 127;
                            moviles [idx].y = 87;
                        }
 
                    // Borramos el sprite:
                    sp_MoveSprAbs (sp_moviles [idx], spritesClip, 0,0,0,0,0);
                    sp_DeleteSpr (sp_moviles [idx]);
                    moviles [idx].rx = moviles[idx].x << 6;
                    moviles [idx].ry = moviles[idx].y << 6;

                    // Creamos a fanti:
                    sp_moviles [idx] = sp_CreateSpr(sp_MASK_SPRITE, 3, fanti_r_1a, 2, TRANSPARENT);

                    fantact = 1;
 
                    //sp_MoveSprAbs (sp_moviles [idx], spritesClip, 0, moviles [idx].y >> 3, moviles [idx].x >> 3, moviles [idx].x & 7, moviles [idx].y & 7);
                    moviles [idx].current_frame = moviles [idx].next_frame = fanti_r_1a;
                    moviles [idx].tipo = 3;
 
                    // ¡listo!
                }
            }
        }
 
        sp_UpdateNow();

        /* Move sprites */
	curtime = time();
	logictime = curtime-oldtime;
	oldtime = curtime;
	for (logicframe = 0 ; logicframe < logictime; logicframe++)
	{
		
        if ( !(player.estado & EST_MUR) )
            move (j);
        else {
            salida = 2;
            death_sequence ();
        }
 
        move_moviles ();

        x = player.x >> 6;
        y = player.y >> 6;

        /* Collisions & game mechanics: */
 
        if ( player.estado & EST_PARP ) {
            // Duración de la inmunidad:
            player.ct_estado --;
            if (player.ct_estado == 0) {
                player.estado = player.estado & (~EST_PARP);
                vidaextra = 0;
            }
        }
 
        if ( !( player.estado & EST_PARP ) && !( player.estado & EST_MUR ) &&!cheat)        // Colisión con enemigos:
            for ( i = 0; i < 3; i ++ )
                if ( moviles [i].tipo > -1 && ( !( player.estado & EST_EXIT ) || (fantact && i == idx) )  ) {
                    if (y >= moviles [i].y - 14 && y <= moviles [i].y + 14 && x >= moviles [i].x - 14 && x <= moviles [i].x + 14) {
                        if ( !(player.estado & EST_NUDE) ) {
                            player.estado |= EST_NUDE;
                            player.estado |= EST_PARP;                  // Parpadeamos inmunes.
                            player.ct_estado = 32*3/2;                      // Tiempo de inmunidad.
 
                            if (time8 >= 0) {
                                do {
                                    xcami = 32 + ((rand () % 12) << 4);
                                    ycami = 16 + ((1 + (rand () % 8)) << 4);
                                } while ( sp_AttrGet ( xcami >> 3, ycami >> 3) > 63 );
 
                                rectangulo.row_coord = ycami >> 3;
                                rectangulo.col_coord = xcami >> 3;
                                sp_GetTiles ( &rectangulo, tile_buffer01 );
                                draw_tile4 (xcami >> 3, ycami >> 3, 22, 85,0);
                            } else {
                                xcami = ycami = 0;
                            }

                            // El jugador "rebota" una poca.
                            player.vy = - 4*SPTW * (player.salto);
                            player.vx = ((player.x >> 6) - moviles [i].x) * (16*SPTW);
                        } else {
                            player.vy = - 7 * (player.salto);
                            lives --;

                            if (lives >= 0)
                                draw_lives (lives);

                            player.estado |= EST_MUR;
                            player.frame = uwolmuete_1a;
                        }
                        wyz_play_sound (1, CANAL_FX);
                        moviles [i].vx =- moviles [i].vx;           // El enemigo se da media vuelta.
                    }
                }

        if ( player.estado & EST_NUDE )     // Colisión con la camiseta
            if (y >= ycami - 14 && y <= ycami + 15 && x >= xcami - 15 && x <= xcami + 15) {
                wyz_play_sound (3, CANAL_FX);
                total_score += 15;
                draw_total_score (23,17,total_score);
 
                player.estado &= (~EST_NUDE);
                player.estado |= EST_PARP;
                player.ct_estado = 32*3/2;
 
                //draw_tile4 (xcami >> 3, ycami >> 3, fases[n_pant].descriptor & 63, 1 + (fases[n_pant].descriptor >> 4));
                rectangulo.row_coord = ycami >> 3;
                rectangulo.col_coord = xcami >> 3;
                sp_PutTiles ( &rectangulo, tile_buffer01 );
            }
 
        // Vemos si colisionamos con alguna moneda.
        for (i = 0; i < 10; i ++)
            if (monedas [i].type != 0) {
                xx=monedas[i].x;
                yy=monedas[i].y;
                type=monedas[i].type==1?monedas_anim[monedas_frame]:monedas_take_anim[(monedas[i].type-2)/2];

                sp_MoveSprAbs(monedas[i].sp,spritesClip,type,yy>>3,xx>>3,xx&7,yy&7);

                if(monedas[i].type>1)
                {
                    monedas[i].type++;
                    if(monedas[i].type<12) monedas[i].y-=2; else monedas[i].y+=2;
                    if(monedas[i].type>20)
                    {
                        monedas [i].type = 0;
                        sp_DeleteSpr(monedas[i].sp);
                        monedas[i].sp=NULL;
                    }
                }
                else
                {
                    if (y >= yy - 10 && y <= yy + 10 && x >= xx - 10 && x <= xx + 10) {
                        wyz_play_sound (5, CANAL_FX);
 
                        monedas [i].type = 2;
                        num_monedas --;
                        total_coins ++;
                        draw_score (total_coins);
                        total_score ++;
                        draw_total_score (23,17,total_score);
                    }
                }
            }

        if(!(maincounter&3))
        {
            monedas_frame=(monedas_frame+1)%monedas_frames;
        }

        if(player.estado&EST_EXIT)
        {
        	if ( sp_AttrGet ( 5, 19) < 64 && sp_AttrGet ( 6, 19) < 64)
        	{
        		sp_MoveSprAbs(arrow_l,spritesClip,arrow_1a,18,5,0,arrow_yoff);
        	}
        	if ( sp_AttrGet (25, 19) < 64 && sp_AttrGet (26, 19) < 64)
        	{
        		sp_MoveSprAbs(arrow_r,spritesClip,arrow_1a,18,25,0,arrow_yoff);
        	}
        	if(!(maincounter&3))
        	{
        		arrow_yoff++;
        		if(arrow_yoff>=3) arrow_yoff=0;
        	}
        }
        
        if(num_monedas==0) {
            // Si se acaban las monedas, presentamos las salidas.
            if ( !(player.estado & EST_EXIT) ) {
                if ( sp_AttrGet ( 5, 19) < 64 && sp_AttrGet ( 6, 19) < 64)
                    draw_tile4 ( 5, 20, 86, level < 10 ? 113 : 123 ,0);
                if ( sp_AttrGet (25, 19) < 64 && sp_AttrGet (26, 19) < 64)
                    draw_tile4 (25, 20, 86, level < 10 ? 117 : 123 ,0);
 
                player.estado |= EST_EXIT;
 
                if(salida!=2)
                {
                    //for(i=0;i<64;i++) screen_pal[i]=0xffff;
					curbright = 6*4; //all white for one frame
                    wyz_play_sound (9, CANAL_FX);
                }

                // ¡Saca a todo el mundo de aquí!
                for ( i = 0; i < 3; i ++ )
                    if (!fantact || i != idx)
                        sp_MoveSprAbs (sp_moviles [i], spritesClip, 0, 0,0,0,0);
            }
        }

        // Retardo para quitar cafeína cuando no hay bishos.
        if ( player.estado & EST_EXIT )
            for (i = 0; i < 126; i ++)
                xt ++;

        // Salir IZQ/DER
        if ( player.estado & EST_EXIT_LEFT ) {
            salida = 0;
            playing = 0;
        } else if ( player.estado & EST_EXIT_RIGHT ) {
            salida = 1;
            playing = 0;
        }
 
        // Vidas extra a los 1000 y a los 2500
        aux = 0;
        if (total_score >= 1000 && !bonus1) {
            aux = 1;
            bonus1 = 1;
        }
        if (total_score >= 2500 && !bonus2) {
            aux = 1;
            bonus2 = 1;
        }
        if (aux) {
            player.estado |= EST_PARP;
            if(lives<99) lives ++;
            vidaextra = 1;
            player.ct_estado = 32*3/2;
            wyz_play_sound (3, CANAL_FX);
        }
        if (vidaextra)
            draw_lives (lives);
	} //logicframe loop
        /* Render */
 
        if ( !(player.estado & EST_PARP) || !(maincounter & 1) )
            sp_MoveSprAbs (sp_prueba, spritesClip, player.frame, y >> 3, x >> 3, x & 7, y & 7);
        else
            sp_MoveSprAbs (sp_prueba, spritesClip, player.frame, 0,0,0,0);  // Parpadeo :o)
 
        if ( !(player.estado & EST_EXIT) )
            for ( i = 0; i < 3; i ++ )
                if ( moviles [i].tipo > -1) {
                    sp_MoveSprAbs (sp_moviles [i], spritesClip, moviles [i].current_frame, moviles
[i].y >> 3, moviles [i].x >> 3, moviles [i].x & 7, moviles [i].y & 7);
                    moviles [i].current_frame = moviles [i].next_frame;
                }
 
        if ( (player.estado & EST_EXIT) && fantact) {
            sp_MoveSprAbs (sp_moviles [idx], spritesClip, moviles [idx].current_frame, moviles
[idx].y >> 3, moviles [idx].x >> 3, moviles [idx].x & 7, moviles [idx].y & 7);
            moviles [idx].current_frame = moviles [idx].next_frame;
        }
    }
 
    wyz_stop_sound ();

    fade_out ();
 
    for(i=0;i<10;i++) sp_DeleteSpr(monedas[i].sp);
 
    //sp_SetSpriteClip(NULL);
    sp_HideAllSpr();
 
    todo_a_negro ();

    if (fantact) {
        // Al carao fanti.
        sp_MoveSprAbs (sp_moviles [idx], spritesClip, 0,0,0,0,0);
        sp_DeleteSpr (sp_moviles [idx]);

        // Creamos sprite normal:
        sp_moviles [idx] = sp_CreateSpr(sp_MASK_SPRITE, 2, wolfi_1a, 2, TRANSPARENT);

        moviles [idx].current_frame = wolfi_1a;
    }
 
    // Tenemos que sacar los sprites del viewport
 
    sp_MoveSprAbs (sp_prueba, spritesClip, 0,0,0,0,0);
    if ( (player.estado & EST_EXIT) && fantact)
        sp_MoveSprAbs (sp_moviles [idx], spritesClip, 0,0,0,0,0);

    if ( flag1 == 0 || flag1 == 1 )
        total_score += (100 + 5 * time8);
 
    for (i = 0; i < 3; i ++)
        sp_MoveSprAbs (sp_moviles [i], spritesClip, 0, 0,0,0,0);
 
    if (lives < 0)
        salida = 3;

	sprites_stop();
 
    return salida;
}

void piramide (i8 npant) {
    u8 l;
    i8 c;
    u8 sx,sy;
    u16 i,fade;
 
    //wyz_play_music (piramide_data);
    wyz_play_music (SONG_PIRAMIDE);
 
    // Pintamos todo:
    //sp_ClearRect(sp_ClipStruct, 0, ' ', sp_CR_TILES);
    //sp_DelAllSpr();
	clear_screen(0);
	swap_screen();
	clear_screen(0);
	swap_screen();
	set_sprite(0/*i*/,0,0,SPRITE_END);
	sprites_start(); //ïðè ðàçðåø¸ííûõ ñïðàéòàõ àâòîìàòè÷åñêè âûïîëíÿåòñÿ êîïèðîâàíèå âûâîäèìîé ãðàôèêè â äâà ýêðàíà
	
	curbright=0;
	pal_bright(BRIGHT_MIN);
	pal_select(PAL_TILES);
	
    draw_level(2,level<10?12:11,level,n_pant);

 
    // Pirámide
    j = 16;
    y = 5;
    l = 0;
    sx=0;
    sy=0;
 
    for (i = 0; i < 55; i ++) {
        if (i == l * (l + 1) / 2) {
            j --;
            x = j;
            y ++;
            l ++;
        }
 
        if (n_pant == i)
            {
                c = 121+6;
                sx=x;
                sy=y;
            }
        else
            {
                if (visitados [i])
                    c = 121+6;
                else
                    c = 121;
            }
 
        sp_PrintAtInv (y,   x,   0,c);
        sp_PrintAtInv (y,   x+1, 0,c+1);
        sp_PrintAtInv (y,   x+2, 0,83);
        sp_PrintAtInv (y+1, x,   0,81);
        sp_PrintAtInv (y+1, x+1, 0,81);
        sp_PrintAtInv (y+1, x+2, 0,82);
 
        x += 2;
    }
 
    // Info stats
    sp_PrintAtInv (19, 10, 4, 106);
    sp_PrintAtInv (19, 11, 4, 107);
    sp_PrintAtInv (19, 12, 4, 108);
    sp_PrintAtInv (19, 13, 4, 109);
    sp_PrintAtInv (19, 14, 4, 103);
    sp_PrintAtInv (19, 15, 7, 99);
    sp_PrintAtInv (19, 16, 5, 89 + total_score / 10000);
    sp_PrintAtInv (19, 17, 5, 89 + (total_score % 10000) / 1000);
    sp_PrintAtInv (19, 18, 5, 89 + (total_score % 1000) / 100);
    sp_PrintAtInv (19, 19, 5, 89 + (total_score % 100) / 10);
    sp_PrintAtInv (19, 20, 5, 89 + (total_score % 10));
 
    sp_PrintAtInv (19, 4, 71, 110);
    sp_PrintAtInv (19, 5, 71, 99);
    sp_PrintAtInv (19, 6, 69, 89 + (lives / 10));
    sp_PrintAtInv (19, 7, 69, 89 + (lives % 10));
 
    sp_PrintAtInv (19, 24, 71, 111);
    sp_PrintAtInv (19, 25, 71, 99);
    sp_PrintAtInv (19, 26, 69, 89 + (total_coins / 100));
    sp_PrintAtInv (19, 27, 69, 89 + (total_coins % 100) / 10);
    sp_PrintAtInv (19, 28, 69, 89 + (total_coins % 10));
 
    j=0;
    fade=TRUE;
	
	swap_screen();
 
    // Esperamos a que se pulse alguna tecla de control
    do {
        sp_MoveSprAbs (sp_prueba, spritesClip, arrow_1a, sy-2, sx, 0, 4+(j>>2));
        sp_UpdateNow();
        if(fade)
        {
            //fade_screen(FALSE); //sets target palette to default and fades in
            fade_screen(); //palette is already default
            fade=FALSE;
        }
        j=(j+1)%12;
        i = joyfunc()^0xffff;
    } while ( !(i & (sp_FIRE|sp_START)));
 
    wyz_stop_sound ();
    wyz_play_sound(7, CANAL_FX);
 
    // Bonito
    fade_out ();

	sprites_stop();
}

i8 espera_activa (i16 espera) {
 
    // jL
 
    // Esta función espera un rato o hasta que se pulse una tecla.
    // Si se pulsa una tecla, devuelve 0
 
    // Esta función sólo funciona en Spectrum.
    // en CPC no hay una interrupción cada 20ms, asín que esto no
    // sirve "pa ná".
 
    i8 res = 1;
    if(espera<0)
    {
        espera=-espera;
        res=2;
    }

 
    while(espera>0)
    {
        vsync();
		//update_palette();
		
        if ( ((joyfunc()^0xffff) & (sp_FIRE|sp_START)) && (res==1))
            {
                res = 0;
                break;
            }
        espera--;
    }
 
    return res;
}

/* Main */

void uwol_preinit_variables(void)
{
    play=0;
    playing=1;
    maincounter=0;
}

void uwolmain (void) {
    u16 i,j;
    i8 fl, show;
    //const u8 *scraddrr3;
	u8 scrnum;
    //const u8 *song;
	u8 songnum;
    u16 prevkey;
	u16 keycnt;
    const u16 seq[]={sp_UP,sp_UP,sp_DOWN,sp_DOWN,sp_LEFT,sp_RIGHT,sp_LEFT,sp_RIGHT};
    //const u8 *mus[]={menu_data,piramide_data,zona1_data,zona2_data,zona3_data,zona4_data,fantasma_data,gameover_data,endingko_data,endingok_data};
    u8 mus[]={SONG_MENU,SONG_PIRAMIDE,SONG_ZONA1,SONG_ZONA2,SONG_ZONA3,SONG_ZONA4,SONG_FANTASMA,SONG_GAMEOVER,SONG_ENDINGKO,SONG_ENDINGOK};
    u16 m,s;

    rectangulo.width = 2;
	rectangulo.height = 2;

    //scraddrr3=NULL;
	scrnum=0;
    //song=NULL;
	songnum=0;
 
    play = 1;
 
    /* Clip structure -- define it as small as possible! */

    spritesClipValues.row_coord = 2;
    spritesClipValues.col_coord = 4;
    spritesClipValues.height = 20;
    spritesClipValues.width = 24;
    spritesClip = &spritesClipValues;

    /* Create sprites */

    sp_prueba = sp_CreateSpr (sp_MASK_SPRITE, 3, uwol_r_2a, 1, TRANSPARENT);
 
    for ( i = 0; i < 3; i ++) {
        sp_moviles [i] = sp_CreateSpr(sp_MASK_SPRITE, 2, wolfi_1a, 2, TRANSPARENT);
        moviles [i].current_frame = wolfi_1a;
    }

	arrow_l=sp_CreateSpr(sp_MASK_SPRITE, 3, arrow_1a, 2, TRANSPARENT);
	arrow_r=sp_CreateSpr(sp_MASK_SPRITE, 3, arrow_1a, 2, TRANSPARENT);

    // Pochintro:
 
    //unpack_RAM3 (mojon_data);
	view_image(IMG_MOJON);

    wyz_play_sound (7, CANAL_FX);
    espera_activa (200);
    fade_out ();

    //unpack_RAM3 (credits_data);
	view_image(IMG_CREDITS);
    wyz_play_sound (7, CANAL_FX);
    espera_activa (500);
    fade_out ();
 
    cheat=FALSE;
 
    while (1) {
 
        // Aquí título
 
        //unpack_RAM3 (title_data);
		pal_bright(BRIGHT_MIN);
		//pal_select(IMG_TITLE4WARP0);
		draw_image(0,0,IMG_TITLE4WARP);
		swap_screen();
		view_image(IMG_TITLE4WARP_);
        //wyz_play_music (menu_data);
        wyz_play_music (SONG_MENU);
        j=0;
        prevkey=0;
        keycnt=0;

        while(1) //title warp and entering cheat code, fire or start to continue
        {
			/*for(i=0;i<15;i++)
			{
				screen_pal[i+49]=warp_palette[((i+j)%15)+1];
				needed_pal[i+49]=screen_pal[i+49];
			}*/
			
            //fade_into(needed_pal);

			pal_select(PAL_TITLE4WARP0+((j>>1)&3));
            //vsync();
			swap_screen();
			//update_palette();
		
            j++;
            /*if((j%48)==0||(j%48)==24)
			{
				vram_fill(PLANE_A_ADR+25*32*2,256+23*32+PALETTE_NUM(2),32,(j%48)==0?1:0);
			}*/

            rand();
 
            i=joyfunc()^0xffff;
            if(!i) prevkey=0;
            if(prevkey) i=0;
            if(i&&!prevkey) prevkey=1;
 
            if(i)
            {
                if(i&seq[keycnt]) keycnt++; else keycnt=0;
                if(keycnt>=8)
                {
                    cheat^=TRUE;
                    wyz_play_sound(5, CANAL_FX);
                    keycnt=0;
                }
            }
            if(i&(sp_FIRE|sp_START)) break;
        }
        wyz_play_sound(10, CANAL_FX);
        wyz_stop_sound ();
        fade_out ();
        //vram_fill(PLANE_B_ADR,0,32*28,0);
		//sp_ClearRect(sp_ClipStruct, 0, ' ', sp_CR_TILES);
		clear_screen(0);
		swap_screen();
		clear_screen(0);
		swap_screen();

		select_image(IMG_TILES);
		
        if(!(joyfunc()&(sp_UP|sp_FIRE)))
        {
            //vram_fill(PLANE_A_ADR,0,32*28,0);
            //fade_screen(FALSE);
			pal_bright(BRIGHT_MIN);
			pal_select(PAL_TILES);
			fade_screen();
 
            m=0;
            s=0;
            j=0;
            prevkey=0;
 
            while(1)
            {
                vsync();
				
                //draw_tile(13,13,1);
				
                sp_PrintAtInv(11,12,0,!j?111:112);
                sp_PrintAtInv(11,14,0,106);
                sp_PrintAtInv(11,16,0,89+(s/10));
                sp_PrintAtInv(11,17,0,89+(s%10));
                sp_PrintAtInv(12,12,0,j==1?111:112);
                sp_PrintAtInv(12,14,0,102);
                sp_PrintAtInv(12,16,0,89+(m/10));
                sp_PrintAtInv(12,17,0,89+(m%10));
 
                i=joyfunc()^0xffff;
                if(!i) prevkey=0;
                if(prevkey) i=0;
                if(i&&!prevkey) prevkey=1;
 
                if(i&sp_LEFT)
                {
                    if(!j&&s>0) s--;
                    if( j&&m>0) m--;
                }
                if(i&sp_RIGHT)
                {
                    if(!j&&s<11) s++;
                    if( j&&m<10)  m++;
                }
                if(i&sp_UP)   j=0;
                if(i&sp_DOWN) j=1;
                if(i&sp_FIRE)
                {
                    if(!j)
                    {
                        wyz_play_sound(s, CANAL_FX);
                    }
                    else
                    {
                        if(!m) wyz_stop_sound(); else wyz_play_music(mus[m-1]);
                    }
                }
				swap_screen();
            }
        }
 
        // Empezamos
        n_pant = 0;
        level = 1;
        total_score = 0;
        total_coins = 0;
        lives = cheat?99:3;
        flag1 = 0;
        fl = 0;
        bonus1 = 0;
        bonus2 = 0;
 
        // player.estado = 0;
 
        for (i = 0; i < 55; i ++ )
            visitados [i] = 0;
 
        while (fl < 3) {
            piramide (n_pant);
            fl = game (n_pant);
 
            show = 0;
 
            if (fl == 0) {
                visitados [n_pant] = 1;     // Marcamos como visitada la pantalla act.
                n_pant = n_pant + level;
                level ++;
            } else if (fl == 1) {
                visitados [n_pant] = 1;     // Marcamos como visitada la pantalla act.
                n_pant = n_pant + level + 1;
                level ++;
            } else if (fl == 3) {
                //scraddrr3 = gover_data; // Game over.
				scrnum = IMG_GOVER;
                show = 1;
                //song = gameover_data;
				songnum = SONG_GAMEOVER;
            }
 
            if (level == 11) {
                // Salimos de la pirámide, vamos a calcular si salimos de verdad o no.
                if (total_coins < 256) {
                    //scraddrr3 = finbad_data; // Fin bad
					scrnum = IMG_FINBAD;
                    n_pant = 0;
                    level = 1;
                    show = 1;
                    //song = endingko_data;
					songnum = SONG_ENDINGKO;
                } else {
                    fl = 4;
                    //scraddrr3 = fingoo_data; // Fin good
					scrnum = IMG_FINGOO;
                    show = 1;
                    //song = endingok_data;
					songnum = SONG_ENDINGOK;
                }
            }
 
			curbright = 0;
			pal_bright(BRIGHT_MIN);
			pal_select(PAL_TILES);
			
            if (show) {
                //unpack_RAM3 (scraddrr3);
                view_image(scrnum);
				//wyz_play_music (song);
				wyz_play_music (songnum);
 
                if(fl==3)
                {
                    draw_total_score(15,10,total_score);
                    for(i=0;i<16;i++)
                    {
						//fade_into(needed_pal);
						fade_into();
						vsync();
						//update_palette();
                    }
                }

                espera_activa (fl == 3 ? -250 : 1500);
                if (fl != 4) wyz_stop_sound ();
 
                fade_out ();
                //vram_fill(PLANE_B_ADR,0,32*28,0);
            }
        }
 
        if (fl == 4) {
            // The end!
            //unpack_RAM3 (finend_data);
			view_image(IMG_FINEND);
            wyz_play_sound (7, CANAL_FX);
            espera_activa (1500);
            wyz_stop_sound ();
            fade_out ();
        }
    }
}

/*

Scary Monsters (And Super Creeps)
David Bowie

She had an horror of rooms
she was tired - you can't hide beat
When I looked in her eyes they were blue but nobody home

She could've been a killer
if she didn't walk the way she do, and she do
She opened strange doors that we'd never close again

She began to wail
jealousies scream
Waiting at the light - know what I mean

[CHORUS (twice)]
Scary monsters, super creeps
Keep me running, running scared

She asked me to stay
and I stole her room
She asked for my love
and I gave her a dangerous mind
Now she's stupid in the street
and she can't socialise
Well I love the little girl
and I'll love her till the day she dies

She wails
Jimmy's guitar sound
jealousies scream
Waiting at the light know what I mean

[CHORUS (twice)]

[CHORUS (twice)]

Run, Run, Run [ad lib]

*/
