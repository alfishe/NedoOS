#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>

#include "psg.h"




struct psg_file * load_psg_file(char * filename)
{
	FILE * f = NULL;
	struct psg_file * file = NULL;

	struct stat file_stat;


	f = fopen(filename,"rb");
	if( !f )
	{
		fprintf(stderr,"Can't open file <%s>!\n",filename);
		goto ERROR;
	}

	if( fstat(fileno(f),&file_stat) )
	{
		fprintf(stderr,"Can't fstat file <%s>!\n",filename);
		goto ERROR;
	}

	if( file_stat.st_size<=16 )
	{
		fprintf(stderr,"File <%s> is too small!\n",filename);
		goto ERROR;
	}


	// allocate psg_file structure
	file = malloc(sizeof(struct psg_file));
	if( !file ) goto MEM_ERROR;
	file->filename = NULL;
	file->size = 0;
	file->bytes = NULL;

	if( !(file->filename = malloc(1+strlen(filename))) ) goto MEM_ERROR;
	strcpy(file->filename, filename);

	file->size = file_stat.st_size;

	if( !(file->bytes = malloc(file->size)) ) goto MEM_ERROR;

	
	// load into allocated area
	if( file->size != fread(file->bytes, 1, file->size, f) )
	{
		fprintf(stderr,"Can't load from file <%s>!\n",filename);
		goto ERROR;
	}


	fclose(f);

	return file;


/////////////////////////////////////////////////////////////////////
MEM_ERROR:
	fprintf(stderr,"%s: memory allocation error!\n",__PRETTY_FUNCTION__);
ERROR:
	free_psg_file(file);

	if( f ) fclose(f);
	exit(1);
}



void free_psg_file(struct psg_file * file)
{
	if( !file ) return;

	if( file->filename ) free(file->filename);
	if( file->bytes )    free(file->bytes);

	free(file);

	return;
}



int update_psg_regs(uint8_t * regs, struct psg_file * psg, size_t * position)
{ // updates regs[14] array with data from next PSG frame, if any.
  // regs could be NULL (nothing is written then)
  // psg_file * psg is a constant structure that contains data from psg file
  // * position is current position into it, gets updated
  //
  // return values:
  //  (-1): end of psg reached
  //     0: run again until non-zero.
  // any>0: regs[14] array is valid for the given amount of frame periods
  //
  // function makes exit(1) if PSG is incorrect
  //
  // always start running with *position=0 !
  //


	if( !position )
	{
		fprintf(stderr,"%s: position pointer given is NULL!\n",__PRETTY_FUNCTION__);
		exit(1);
	}
	if( !psg )
	{
		fprintf(stderr,"%s: struct psg_file pointer given is NULL!\n",__PRETTY_FUNCTION__);
		exit(1);
	}
	if( !psg->bytes )
	{
		fprintf(stderr,"%s: bytes pointer in struct psg_file is NULL!\n",__PRETTY_FUNCTION__);
		exit(1);
	}


	// initialization
	if( *position<16 )
	{
		*position=16;

		// init registers
		if( regs )
		{
			for(int i=0;i<14;i++) regs[i]=0;
		}

		return 0; // rerun
	}

	// EOF check by size
	if( *position >= psg->size )
	{
		return (-1);
	}

	// EOF check by end mark
	if( psg->bytes[*position] == 0xFD )
	{
		return (-1);
	}

	// prepare regs array
	if( regs ) regs[13]=0xFF; // 0xFF means "DON'T WRITE to AY/YM"

	int frames=1;
	int was_delimiter=0;
	for(;;)
	{
		if( !(psg->bytes[*position] & 0xF0) )
		{ // register contents
			if( was_delimiter )
			{ // parse next frame in next iteration
				return frames;
			}

			uint8_t reg_num = psg->bytes[(*position)++];

			if( *position >= psg->size )
			{
				fprintf(stderr,"%s: error in PSG format at the offset 0x%lx!",__PRETTY_FUNCTION__,(*position)-1);
				exit(1);
			}

			uint8_t reg_value = psg->bytes[(*position)++];

			if( regs && reg_num<14 ) regs[reg_num]=reg_value;
			
			if( *position >= psg->size ) return frames;
		}
		else if( psg->bytes[*position]==0xFD )
		{ // end mark -- will be parsed on next iteration. *position is NOT incremented!
			return frames;
		}
		else if( psg->bytes[*position]==0xFF )
		{ // 1-frame delimiter
			if( was_delimiter )
				frames++;
			else
				was_delimiter = 1;
			
			(*position)++;
			if( *position >= psg->size ) return frames;
		}
		else if( psg->bytes[*position]==0xFE )
		{ // pause in 4-frame increments
			(*position)++;
			if( *position >= psg->size )
			{
				fprintf(stderr,"%s: error in PSG format at the offset 0x%lx!",__PRETTY_FUNCTION__,(*position)-1);
				exit(1);
			}

			int num_frames = 4*(psg->bytes[*position]);

			if( !was_delimiter )
			{
				num_frames--;
				was_delimiter=1;
			}

			frames += num_frames;

			(*position)++;
			if( *position >= psg->size ) return frames;
		}
		else
		{
			fprintf(stderr,"%s: error in PSG format at the offset 0x%lx!",__PRETTY_FUNCTION__,*position);
			exit(1);
		}
	}
}




struct frame_list * build_psg_frames(struct psg_file * psg)
{
	struct frame_list * head = NULL;
	
	struct frame_list * local_head = NULL;



	size_t position;
	int frames_spent;

	uint8_t regs[14];



//	// first count number of frames
//	frames = 0;
//	position = 0;
//	//
//	while( (curr_frames=update_psg_regs(NULL,psg,&position)) >= 0 )
//		frames +=curr_frames;
//

	// build frame list
	position = 0;
	while( (frames_spent=update_psg_regs(regs,psg,&position)) >= 0 )
	{
		if( frames_spent==0 ) continue;

		// create frame_ay structure
		struct frame_ay * ay_regs = malloc(sizeof(struct frame_ay));
		if( !ay_regs ) goto MEM_ERROR;

		ay_regs->base.type = FRAME_AY;
		memcpy(ay_regs->regs,regs,14);

		// add frames_spent list elements pointing to this structure to the local list
		//
		for(int i=0;i<frames_spent;i++)
		{
			struct frame_list * element = malloc(sizeof(struct frame_list));
			if( !element ) goto MEM_ERROR;

			element->frame = (struct frame_base *)ay_regs;

			element->next = local_head;
			local_head = element;
		}
	}

	// reverse local_head-based list into global head-pointed list
	if( local_head )
	{
		do
		{
			struct frame_list * old_next = local_head->next;

			local_head->next = head;
			head = local_head;

			local_head = old_next;

		} while( local_head );
	}
	else
	{ // were no frames -- PSG format error
		fprintf(stderr,"%s: error in PSG format: no frames found!",__PRETTY_FUNCTION__);
		goto ERROR;
	}



	return head;



MEM_ERROR:
	fprintf(stderr,"%s: memory allocation error!\n",__PRETTY_FUNCTION__);
ERROR:
	free_psg_frames(local_head);
	free_psg_frames(head);

	exit(1);
}




void free_psg_frames(struct frame_list * head)
{
	struct frame_base * oldframe = NULL;
	struct frame_list * freeme;

	while( head )
	{
		if( head->frame )
		{
			if( oldframe != head->frame )
			{
				oldframe = head->frame;
				free(oldframe);
			}
		}

		freeme = head;
		head = head->next;

		free(freeme);
	}
}

