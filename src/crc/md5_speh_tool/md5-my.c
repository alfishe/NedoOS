// hashplay framework
// (c) 2019 lvd^mhm

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
#include "md5-my.h"


struct my_md5
{
	uint64_t pos;

	uint8_t buf[64];

	uint32_t state[4];
};



static const uint32_t a0 = 0x67452301;
static const uint32_t b0 = 0xefcdab89;
static const uint32_t c0 = 0x98badcfe;
static const uint32_t d0 = 0x10325476;


static inline void md5_compress( const uint32_t * m, uint32_t * state )
{

#define F(b,c,d) ( ( (b) & (c) ) | ( (~(b)) & (d) ) )
#define G(b,c,d) ( ( (b) & (d))  | ( (c) & (~(d)) ) )
#define H(b,c,d) ( (b) ^ (c) ^ (d) )
#define I(b,c,d) ( (c) ^ ( (b) | (~(d)) ) )

#define ROL(x,n) ( ( (x)<<(n) ) | ( (x)>>(32-(n)) ) )

#define ROUND_1(a,b,c,d,msg,add,shift)     \
	do {                               \
		a += F(b,c,d) + msg + add; \
		a = ROL(a,shift);          \
		a += b;                    \
	} while(0)

#define ROUND_2(a,b,c,d,msg,add,shift)     \
	do {                               \
		a += G(b,c,d) + msg + add; \
		a = ROL(a,shift);          \
		a += b;                    \
	} while(0)

#define ROUND_3(a,b,c,d,msg,add,shift)     \
	do {                               \
		a += H(b,c,d) + msg + add; \
		a = ROL(a,shift);          \
		a += b;                    \
	} while(0)

#define ROUND_4(a,b,c,d,msg,add,shift)     \
	do {                               \
		a += I(b,c,d) + msg + add; \
		a = ROL(a,shift);          \
		a += b;                    \
	} while(0)



	uint32_t A = state[0];
	uint32_t B = state[1];
	uint32_t C = state[2];
	uint32_t D = state[3];


	ROUND_1(A,B,C,D, m[ 0], 0xd76aa478,  7);
	ROUND_1(D,A,B,C, m[ 1], 0xe8c7b756, 12);
	ROUND_1(C,D,A,B, m[ 2], 0x242070db, 17);
	ROUND_1(B,C,D,A, m[ 3], 0xc1bdceee, 22);
	ROUND_1(A,B,C,D, m[ 4], 0xf57c0faf,  7);
	ROUND_1(D,A,B,C, m[ 5], 0x4787c62a, 12);
	ROUND_1(C,D,A,B, m[ 6], 0xa8304613, 17);
	ROUND_1(B,C,D,A, m[ 7], 0xfd469501, 22);
	ROUND_1(A,B,C,D, m[ 8], 0x698098d8,  7);
	ROUND_1(D,A,B,C, m[ 9], 0x8b44f7af, 12);
	ROUND_1(C,D,A,B, m[10], 0xffff5bb1, 17);
	ROUND_1(B,C,D,A, m[11], 0x895cd7be, 22);
	ROUND_1(A,B,C,D, m[12], 0x6b901122,  7);
	ROUND_1(D,A,B,C, m[13], 0xfd987193, 12);
	ROUND_1(C,D,A,B, m[14], 0xa679438e, 17);
	ROUND_1(B,C,D,A, m[15], 0x49b40821, 22);

	ROUND_2(A,B,C,D, m[ 1], 0xf61e2562,  5);
	ROUND_2(D,A,B,C, m[ 6], 0xc040b340,  9);
	ROUND_2(C,D,A,B, m[11], 0x265e5a51, 14);
	ROUND_2(B,C,D,A, m[ 0], 0xe9b6c7aa, 20);
	ROUND_2(A,B,C,D, m[ 5], 0xd62f105d,  5);
	ROUND_2(D,A,B,C, m[10], 0x02441453,  9);
	ROUND_2(C,D,A,B, m[15], 0xd8a1e681, 14);
	ROUND_2(B,C,D,A, m[ 4], 0xe7d3fbc8, 20);
	ROUND_2(A,B,C,D, m[ 9], 0x21e1cde6,  5);
	ROUND_2(D,A,B,C, m[14], 0xc33707d6,  9);
	ROUND_2(C,D,A,B, m[ 3], 0xf4d50d87, 14);
	ROUND_2(B,C,D,A, m[ 8], 0x455a14ed, 20);
	ROUND_2(A,B,C,D, m[13], 0xa9e3e905,  5);
	ROUND_2(D,A,B,C, m[ 2], 0xfcefa3f8,  9);
	ROUND_2(C,D,A,B, m[ 7], 0x676f02d9, 14);
	ROUND_2(B,C,D,A, m[12], 0x8d2a4c8a, 20);

	ROUND_3(A,B,C,D, m[ 5], 0xfffa3942,  4);
	ROUND_3(D,A,B,C, m[ 8], 0x8771f681, 11);
	ROUND_3(C,D,A,B, m[11], 0x6d9d6122, 16);
	ROUND_3(B,C,D,A, m[14], 0xfde5380c, 23);
	ROUND_3(A,B,C,D, m[ 1], 0xa4beea44,  4);
	ROUND_3(D,A,B,C, m[ 4], 0x4bdecfa9, 11);
	ROUND_3(C,D,A,B, m[ 7], 0xf6bb4b60, 16);
	ROUND_3(B,C,D,A, m[10], 0xbebfbc70, 23);
	ROUND_3(A,B,C,D, m[13], 0x289b7ec6,  4);
	ROUND_3(D,A,B,C, m[ 0], 0xeaa127fa, 11);
	ROUND_3(C,D,A,B, m[ 3], 0xd4ef3085, 16);
	ROUND_3(B,C,D,A, m[ 6], 0x04881d05, 23);
	ROUND_3(A,B,C,D, m[ 9], 0xd9d4d039,  4);
	ROUND_3(D,A,B,C, m[12], 0xe6db99e5, 11);
	ROUND_3(C,D,A,B, m[15], 0x1fa27cf8, 16);
	ROUND_3(B,C,D,A, m[ 2], 0xc4ac5665, 23);
	
	ROUND_4(A,B,C,D, m[ 0], 0xf4292244,  6);
	ROUND_4(D,A,B,C, m[ 7], 0x432aff97, 10);
	ROUND_4(C,D,A,B, m[14], 0xab9423a7, 15);
	ROUND_4(B,C,D,A, m[ 5], 0xfc93a039, 21);
	ROUND_4(A,B,C,D, m[12], 0x655b59c3,  6);
	ROUND_4(D,A,B,C, m[ 3], 0x8f0ccc92, 10);
	ROUND_4(C,D,A,B, m[10], 0xffeff47d, 15);
	ROUND_4(B,C,D,A, m[ 1], 0x85845dd1, 21);
	ROUND_4(A,B,C,D, m[ 8], 0x6fa87e4f,  6);
	ROUND_4(D,A,B,C, m[15], 0xfe2ce6e0, 10);
	ROUND_4(C,D,A,B, m[ 6], 0xa3014314, 15);
	ROUND_4(B,C,D,A, m[13], 0x4e0811a1, 21);
	ROUND_4(A,B,C,D, m[ 4], 0xf7537e82,  6);
	ROUND_4(D,A,B,C, m[11], 0xbd3af235, 10);
	ROUND_4(C,D,A,B, m[ 2], 0x2ad7d2bb, 15);
	ROUND_4(B,C,D,A, m[ 9], 0xeb86d391, 21);

	state[0] += A;
	state[1] += B;
	state[2] += C;
	state[3] += D;
}

static inline size_t my_min(size_t a, size_t b)
{
	if( a<=b ) return a; else return b;
}









struct hash_iface * make_md5_my(void)
{
	static const char name[]="my MD5"; 

	struct hash_iface * hash = malloc(sizeof(struct hash_iface));
	if( !hash )
	{
		fprintf(stderr,"%s: %d, %s: can't allocate memory for hash_iface!\n",__FILE__,__LINE__,__func__);
		exit(1);
	}

	hash->hash_specific_data = NULL;

	hash->name = name;

	hash->hash_init     = &md5_my_hash_init;
	hash->hash_start    = &md5_my_hash_start;
	hash->hash_addbytes = &md5_my_hash_addbytes;
	hash->hash_getsize  = &md5_my_hash_getsize;
	hash->hash_result   = &md5_my_hash_result;
	hash->hash_deinit   = &md5_my_hash_deinit;

	return hash;
}


int    md5_my_hash_init    (struct hash_iface * hash)
{
	struct my_md5 * md5 = (struct my_md5 *)malloc(sizeof(struct my_md5));
	
	if( !md5 )
	{
		fprintf(stderr,"%s: %d, %s: can't allocate memory for struct my_md5!\n",__FILE__,__LINE__,__func__);
		exit(1);
	}

	hash->hash_specific_data = (void *)md5;

	return 1;
}

int    md5_my_hash_start   (struct hash_iface * hash)
{
	struct my_md5 * md5 = (struct my_md5 *)hash->hash_specific_data;
	
	if( !md5 )
	{
		fprintf(stderr,"%s: %d, %s: hash_specific_data was NULL!\n",__FILE__,__LINE__,__func__);
		exit(1);
	}

	md5->pos = 0;

	for(int i=0;i<64;i++)
		md5->buf[i] = 0;

	md5->state[0] = a0;
	md5->state[1] = b0;
	md5->state[2] = c0;
	md5->state[3] = d0;

	return 1;
}

int    md5_my_hash_addbytes(struct hash_iface * hash, const uint8_t * message, size_t size)
{
	struct my_md5 * md5 = (struct my_md5 *)hash->hash_specific_data;
	
	if( !md5 )
	{
		fprintf(stderr,"%s: %d, %s: hash_specific_data was NULL!\n",__FILE__,__LINE__,__func__);
		exit(1);
	}

	const uint8_t * ptr = message;
	size_t remaining_size = size;


	while( remaining_size > 0 )
	{
		// aligned 64-bytes shortcut
		if( !(md5->pos & 63) && remaining_size >= 64 )
		{
			md5_compress( (const uint32_t *)ptr, md5->state );

			md5->pos += 64;
			ptr += 64;
			remaining_size -= 64;

			continue;
		}

		// otherwise fill buffer and perform MD5 update on it
		size_t size_to_add = my_min( (64-(md5->pos & 63)), remaining_size );

		do
		{
			md5->buf[md5->pos & 63] = *ptr;

			ptr++;
			md5->pos++;
			remaining_size--;

		} while( (--size_to_add) );

		if( !(md5->pos & 63) )
			md5_compress( (const uint32_t *)md5->buf, md5->state );
	}

	return 1;
}

size_t md5_my_hash_getsize (struct hash_iface * hash)
{
	return 16;
}

int    md5_my_hash_result  (struct hash_iface * hash, uint8_t * result)
{
	struct my_md5 * md5 = (struct my_md5 *)hash->hash_specific_data;
	
	if( !md5 )
	{
		fprintf(stderr,"%s: %d, %s: hash_specific_data was NULL!\n",__FILE__,__LINE__,__func__);
		exit(1);
	}

	// make padding
	
	uint64_t bits_hashed = md5->pos * 8;

	uint8_t padding[64+8];

	for(int i=0;i<64;i++)
		padding[i]=0;
	
	*(uint64_t *)(&padding[64]) = bits_hashed;


	int num_pad_bytes = 56 - (md5->pos & 63);

	if( num_pad_bytes<=0 ) num_pad_bytes+= 64;

	padding[64-num_pad_bytes] = 0x80;

	md5_my_hash_addbytes(hash, &padding[64-num_pad_bytes], 8+num_pad_bytes);

	assert( !(md5->pos & 63) );


	memcpy(result,md5->state,16);

	return 1;
}


void   md5_my_hash_deinit  (struct hash_iface * hash)
{
	struct my_md5 * md5 = (struct my_md5 *)hash->hash_specific_data;
	
	if( !md5 )
	{
		fprintf(stderr,"%s: %d, %s: hash_specific_data was NULL!\n",__FILE__,__LINE__,__func__);
		exit(1);
	}

	free(md5);
	
	hash->hash_specific_data = NULL;
}

