// hashplay framework
// (c) 2022 lvd^mhm

/*
    This file is part of hashplay framework.

    hashplay framework is free software:
    you can redistribute it and/or modify it under the terms of
    the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    hashplay framework is distributed in the hope that
    it will be useful, but WITHOUT ANY WARRANTY; without even
    the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with hashplay framework.
    If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "hash-common.h"
#include "sphash-opt.h"


#define DIGEST_SIZE 8

#define BLK_SIZE 32

static const uint32_t x0 = 0x01180011; // hex-encoded numbers 71680, 70908, 69888
static const uint32_t y0 = 0x4fc11100; //


// instantiate speck_uint32_t_8_29




#define ROL(w,n) (((w)<<(n))|((w)>>32-(n)))

#define ROUND(x,y,k)           \
	do {                   \
		x = ROL(x,24); \
		x += y;        \
		x ^= k;        \
		y = ROL(y,3);  \
		y ^= x;        \
	} while(0)




struct my_sphash
{
	uint64_t pos;

	uint8_t buf[BLK_SIZE];

	uint32_t state[2];
};


static void sphash_compress( const uint32_t * m, uint32_t * state)
{
	uint32_t x,y;
	uint32_t k,k1,k2,k3,k4,k5,k6,k7;

	x = state[0];
	y = state[1];

	//speck_encrypt_uint32_t_8_29(tmp,m);
	k = m[0];
	k1 = m[1];
	k2 = m[2];
	k3 = m[3];
	k4 = m[4];
	k5 = m[5];
	k6 = m[6];
	k7 = m[7];

	ROUND(x,y,k); ROUND(k1,k, 0);
	ROUND(x,y,k); ROUND(k2,k, 1);
	ROUND(x,y,k); ROUND(k3,k, 2);
	ROUND(x,y,k); ROUND(k4,k, 3);
	ROUND(x,y,k); ROUND(k5,k, 4);
	ROUND(x,y,k); ROUND(k6,k, 5);
	ROUND(x,y,k); ROUND(k7,k, 6);

	ROUND(x,y,k); ROUND(k1,k, 7);
	ROUND(x,y,k); ROUND(k2,k, 8);
	ROUND(x,y,k); ROUND(k3,k, 9);
	ROUND(x,y,k); ROUND(k4,k,10);
	ROUND(x,y,k); ROUND(k5,k,11);
	ROUND(x,y,k); ROUND(k6,k,12);
	ROUND(x,y,k); ROUND(k7,k,13);
	
	ROUND(x,y,k); ROUND(k1,k,14);
	ROUND(x,y,k); ROUND(k2,k,15);
	ROUND(x,y,k); ROUND(k3,k,16);
	ROUND(x,y,k); ROUND(k4,k,17);
	ROUND(x,y,k); ROUND(k5,k,18);
	ROUND(x,y,k); ROUND(k6,k,19);
	ROUND(x,y,k); ROUND(k7,k,20);
	
	ROUND(x,y,k); ROUND(k1,k,21);
	ROUND(x,y,k); ROUND(k2,k,22);
	ROUND(x,y,k); ROUND(k3,k,23);
	ROUND(x,y,k); ROUND(k4,k,24);
	ROUND(x,y,k); ROUND(k5,k,25);
	ROUND(x,y,k); ROUND(k6,k,26);
	ROUND(x,y,k); ROUND(k7,k,27);
	
	ROUND(x,y,k);

	state[0] += x;
	state[1] += y;
}



static inline size_t my_min(size_t a, size_t b)
{
	if( a<=b ) return a; else return b;
}

struct hash_iface * make_sphash_opt(void)
{
	static const char name[]="speck-based hash: sphash64, optimized impl."; 

	struct hash_iface * hash = malloc(sizeof(struct hash_iface));
	if( !hash )
	{
		fprintf(stderr,"%s: %d, %s: can't allocate memory for hash_iface!\n",__FILE__,__LINE__,__func__);
		exit(1);
	}

	hash->hash_specific_data = NULL;

	hash->name = name;

	hash->hash_init     = &sphash_opt_hash_init;
	hash->hash_start    = &sphash_opt_hash_start;
	hash->hash_addbytes = &sphash_opt_hash_addbytes;
	hash->hash_getsize  = &sphash_opt_hash_getsize;
	hash->hash_result   = &sphash_opt_hash_result;
	hash->hash_deinit   = &sphash_opt_hash_deinit;

	return hash;
}

int    sphash_opt_hash_init    (struct hash_iface * hash)
{
	struct my_sphash * sphash = (struct my_sphash *)malloc(sizeof(struct my_sphash));
	
	if( !sphash )
	{
		fprintf(stderr,"%s: %d, %s: can't allocate memory for struct my_sphash!\n",__FILE__,__LINE__,__func__);
		exit(1);
	}

	hash->hash_specific_data = (void *)sphash;

	return 1;
}

void   sphash_opt_hash_deinit  (struct hash_iface * hash)
{
	struct my_sphash * sphash = (struct my_sphash *)hash->hash_specific_data;
	
	if( !sphash )
	{
		fprintf(stderr,"%s: %d, %s: hash_specific_data was NULL!\n",__FILE__,__LINE__,__func__);
		exit(1);
	}

	free(sphash);
	
	hash->hash_specific_data = NULL;
}

size_t sphash_opt_hash_getsize (struct hash_iface * hash)
{
	return DIGEST_SIZE;
}

int    sphash_opt_hash_start   (struct hash_iface * hash)
{
	struct my_sphash * sphash = (struct my_sphash *)hash->hash_specific_data;
	
	if( !sphash )
	{
		fprintf(stderr,"%s: %d, %s: hash_specific_data was NULL!\n",__FILE__,__LINE__,__func__);
		exit(1);
	}

	sphash->pos = 0;

	for(int i=0;i<BLK_SIZE;i++)
		sphash->buf[i] = 0;

	sphash->state[0] = x0;
	sphash->state[1] = y0;

	return 1;
}

int    sphash_opt_hash_addbytes(struct hash_iface * hash, const uint8_t * message, size_t size)
{
	struct my_sphash * sphash = (struct my_sphash *)hash->hash_specific_data;
	
	if( !sphash )
	{
		fprintf(stderr,"%s: %d, %s: hash_specific_data was NULL!\n",__FILE__,__LINE__,__func__);
		exit(1);
	}

	const uint8_t * ptr = message;
	size_t remaining_size = size;


	while( remaining_size > 0 )
	{
		// do full buffers
		if( !(sphash->pos & (BLK_SIZE-1)) )
		{
			if( remaining_size>=BLK_SIZE )
			{
				sphash_compress( (uint32_t *)ptr, sphash->state );

				sphash->pos += BLK_SIZE;
				ptr += BLK_SIZE;
				remaining_size -= BLK_SIZE;

				continue;
			}
		}


		// otherwise fill with all available data up to the end of buffer, if possible
		size_t size_to_add = my_min( (BLK_SIZE-(sphash->pos & (BLK_SIZE-1))), remaining_size );

		do
		{
			sphash->buf[sphash->pos & (BLK_SIZE-1)] = *ptr;

			ptr++;
			sphash->pos++;
			remaining_size--;

		} while( (--size_to_add) );

		if( !(sphash->pos & (BLK_SIZE-1)) )
			sphash_compress( (uint32_t *)sphash->buf, sphash->state );
	}

	return 1;
}

int    sphash_opt_hash_result  (struct hash_iface * hash, uint8_t * result)
{
	struct my_sphash * sphash = (struct my_sphash *)hash->hash_specific_data;
	
	if( !sphash )
	{
		fprintf(stderr,"%s: %d, %s: hash_specific_data was NULL!\n",__FILE__,__LINE__,__func__);
		exit(1);
	}


	/*
	 * We're gonna using Nandi padding rule, as per following paper:
	 *
	 * ===
	 * Nandi M. (2009) Characterizing Padding Rules of MD Hash Functions Preserving Collision Security.
	 * In: Boyd C., González Nieto J. (eds) Information Security and Privacy. ACISP 2009.
	 * Lecture Notes in Computer Science, vol 5594. Springer, Berlin, Heidelberg.
	 * https://doi.org/10.1007/978-3-642-02620-1_12
	 *
	 * also https://eprint.iacr.org/2009/325.pdf
	 * or use sci-hub.
	 * ===
	 *
	 * Specifically, the padding is as per section 3.2, remark 2, s=16
	 */


	uint8_t padding[BLK_SIZE+8]; // suitable for up to 4 chunks of 16 bits, total 4*15 = 60 bits
	                             // for length IN BLOCKS. Block is BLK_SIZE (min 32 bytes), so
	                             // 2^64 / 32 = 2^59.

	for(int i=0;i<sizeof(padding);i++)
		padding[i]=0;
	
	uint64_t blk_size = (sphash->pos+BLK_SIZE-1)/BLK_SIZE; // number of blocks incl. partially filled last one

	int num_chunks = 1;
	uint64_t t = blk_size;
	while( t>>=15 ) num_chunks++;

	// fill length part of padding
	t = blk_size;
	for(int i=num_chunks-1;i>=0;i--)
	{
		uint16_t chunk = (t & 0x7FFF) | (i ? 0x8000 : 0);

		padding[BLK_SIZE+i*2  ] = chunk>>8;
		padding[BLK_SIZE+i*2+1] = chunk & 0xFF;

		t>>=15;
	}





	int num_pad_bytes = (BLK_SIZE-2*num_chunks) - (sphash->pos & (BLK_SIZE-1));

	if( num_pad_bytes<=0 ) num_pad_bytes += BLK_SIZE;

	padding[BLK_SIZE-num_pad_bytes] = 0x80;

	sphash_opt_hash_addbytes(hash, &padding[BLK_SIZE-num_pad_bytes], 2*num_chunks+num_pad_bytes);

	assert( !(sphash->pos & (BLK_SIZE-1)) );


	for(int i=0;i<DIGEST_SIZE/4;i++)
	{
		*(((uint32_t *)result)+i) = sphash->state[i];
	}

	return 1;
}

