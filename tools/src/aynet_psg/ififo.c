#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ififo.h"

// "infinite" fifo for uint32_t values
// NOT thread-safe! (i.e. can't put and get from different threads)

static volatile uint32_t head;
static volatile uint32_t tail;
static volatile uint32_t mask;
static volatile uint32_t size;

static volatile uint32_t * volatile fifo = NULL;

#define IFIFO_INITIAL_SIZE (4096) // must be 2^n


void ififo_init(void)
{
	head = tail = 0;

	mask = (size = IFIFO_INITIAL_SIZE) - 1;

	fifo = malloc(size*sizeof(uint32_t));
	if( !fifo )
	{
		fprintf(stderr,"%s: can't allocate initial memory chunk!\n",__PRETTY_FUNCTION__);
		exit(1);
	}
}

void ififo_free(void)
{
	if(fifo)
	{
		free((void *)fifo);
		fifo=NULL;
	}
}



void ififo_put(uint32_t value)
{
	if( ((head+1)&mask)==(tail&mask) )
	{ // fifo is to be overflown, add more memory to it
printf("ififo overflow: old head=%x, old tail=%x, old mask=%x, old size=%x, old ptr=%p\n",head,tail,mask,size,fifo);
		uint32_t old_size = size;
		uint32_t old_mask = mask;

		size <<= 1;
		if( (size>>1)!=old_size )
		{
			fprintf(stderr,"%s: fifo have to become too large!\n",__PRETTY_FUNCTION__);
			exit(1);	
		}

		mask = (size-1);
printf("ififo overflow: new mask=%x, new size=%x\n",mask,size);	
		fifo = realloc((void *)fifo,size*sizeof(uint32_t));
printf("ififo overflow: new ptr=%p\n",fifo);
		if( !fifo )
		{
			fprintf(stderr,"%s: can't allocate more memory for fifo!\n",__PRETTY_FUNCTION__);
			exit(1);
		}

		// realign and copy contents, if needed
		if( (head&old_mask)<(tail&old_mask) )
		{
			if( (head&old_mask)>0 )
			{
				memcpy( (void *)(fifo+old_size), (void *)fifo, (head&old_mask)*sizeof(uint32_t) );
			}

			head += old_size;
			head &= mask;
		}
printf("ififo overflow: new head=%x\n",head);
	}

	fifo[head&mask] = value;
	head++;
	head &= mask;
}

uint32_t ififo_get(void)
{
	if( (head&mask)!=(tail&mask) )
	{
		uint32_t value = fifo[tail&mask];
		tail++;
		tail &= mask;

		return value;
	}
	else
	{
		fprintf(stderr,"%s: attempted to get from empty ififo!\n",__PRETTY_FUNCTION__);
		exit(1);
	}
}

size_t ififo_used(void)
{ // return how many words are used in fifo (how many times it may supply 'get' without any 'put')

	return mask & (head-tail);
}

