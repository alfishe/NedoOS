#ifndef _PSG_H_
#define _PSG_H_

struct frame_list
{
	struct frame_base * frame;

	struct frame_list * next;
};



// frame types
#define FRAME_AY (1)
//#define FRAME_DOUBLE_AY (2)
//#define ...


struct frame_base
{
	uint8_t type;
};

struct frame_ay
{
	struct frame_base base;

	uint8_t regs[14];
};


struct psg_file
{
	char * filename;

	size_t size;

	uint8_t * bytes;
};




struct psg_file * load_psg_file(char * filename);

void free_psg_file(struct psg_file * file);

struct frame_list * build_psg_frames(struct psg_file * psg);

void free_psg_frames(struct frame_list * head);




#endif // _PSG_H_

