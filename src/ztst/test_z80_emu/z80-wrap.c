// Z80 ciphers test framework
// (c) 2019 lvd^mhm

/*
    This file is part of Z80 ciphers test framework.

    Z80 ciphers test framework is free software:
    you can redistribute it and/or modify it under the terms of
    the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Z80 ciphers test framework is distributed in the hope that
    it will be useful, but WITHOUT ANY WARRANTY; without even
    the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Z80 ciphers test framework.
    If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "zetaZ80/Z80_lite.h"

#include "z80-wrap.h"



static void z80_finish(void * param)
{
	struct z80_context * z80 = param;

	fprintf(stdout,"\n<<<Finished in %ld clocks!>>>\n",z80->z80.cycles);
	exit(0);
}

static uint8_t z80_filter_fetch_opcode(void * param, uint16_t address)
{
	struct z80_context * z80 = param;
	uint8_t opcode = z80->z80_mem[address];

//	fprintf(stderr,"<<< MP=%04x AF=%04x BC=%04x DE=%04x HL=%04x SP=%04x PC=%04x op=%02x\n",z80->z80.memptr,z80->z80.af,z80->z80.bc,z80->z80.de,z80->z80.hl,z80->z80.sp,z80->z80.pc,opcode);

	return opcode;
}

static uint8_t z80_filter_zx_api(void * param, uint16_t address)
{
	struct z80_context * z80 = param;

	if( address==0 ) // finish?
	{
		z80_finish(param);
	}
	else if( address==0x1601 ) // CHAN-OPEN (ignore)
	{
		return 0xC9;
	}
	else if( address==0x0010 ) // RST 0x10 (print character)
	{
		uint8_t c = ((z80->z80.af)>>8)&0xFF;

		if( z80->was_23 ) // skip 2 bytes after 23
		{
			if( z80->was_23==2 )
			{
				fprintf(stdout,"\033[%dG",c);
			}

			z80->was_23--;
		}
		else if( c==13 )
		{
			fprintf(stdout,"\n");
		}
		else if( c==127 ) // skip
		{
		}
		else if( c==23 ) // skip following 2 bytes
		{
			z80->was_23=2;
		}
		else
		{
			fprintf(stdout,"%c",c);
			fflush(stdout);
		}

		return 0xC9;
	}
	else if( address<0x4000 ) // catch all other ROM accesses
	{
		fprintf(stderr,"Accessed addr %04x! [sp]=%04x\n",address,*((uint16_t *)&z80->z80_mem[z80->z80.sp]));
		exit(1);
	}

	return z80_filter_fetch_opcode(param, address);
}

static uint8_t z80_filter_nedoos_api(void * param, uint16_t address)
{
	struct z80_context * z80 = param;

	if( address==0 )
	{
		z80_finish(param);
	}
	else if( address==5 )
	{
		uint8_t c = (z80->z80.bc)&0xFF;

		if( c==0xD3 // GETSTDINOUT
		 || c==0xFF // YIELDKEEP
		  )
		{
			return 0xC9; // just ignore
		}
		else if( c==0x49 ) // WRITEHANDLE
		{ // in:B  - handle (ignore)
		  // in:DE - buffer
		  // in:HL - bytes to write
		  // out:HL - actually written
		  // out:A  - error if nonzero
			
			uint16_t ptr = z80->z80.de;
			uint16_t ctr = z80->z80.hl;

			while( ctr-- )
			{
				fprintf(stdout,"%c",z80->z80_mem[ptr++]);
			}
			if( z80->z80.hl ) fflush(stdout);

			// HL unchanged
			z80->z80.af &= 0x00FF;
			
			return 0xC9;
		}
		else
		{
			fprintf(stderr,"\n<<unknown BDOS call: c=%02x!>>\n",c);
			exit(1);
		}
	}

	return z80_filter_fetch_opcode(param, address);
}

static uint8_t z80_filter_cpm_api(void * param, uint16_t address)
{
	struct z80_context * z80 = param;

	if( address==0 )
	{
		z80_finish(param);
	}
	else if( address==5 )
	{
		uint8_t c = (z80->z80.bc)&0xFF;

		if( c==2 ) // print char in e
		{
			fprintf(stdout,"%c",(z80->z80.de)&0xFF);
			fflush(stdout);
		}
		else if( c==9 ) // print string pointed to by de
		{
			uint16_t ptr = z80->z80.de;
			uint8_t chr;

			while( (chr=z80->z80_mem[ptr++]) != '$' )
			{
				fprintf(stdout,"%c",chr);
			}
			fflush(stdout);
		}
		else
		{
			fprintf(stderr,"\n<<<Unknown CP/M API call: C=%02x>>>\n", c);
			exit(1);
		}

		return 0xC9;
	}

	return z80_filter_fetch_opcode(param, address);
}

static uint8_t z80_rd(void * param, uint16_t address)
{
	struct z80_context * z80 = param;

	return z80->z80_mem[address];
}

static void    z80_zx_wr(void * param, uint16_t address, uint8_t data)
{
	struct z80_context * z80 = param;

	if( address>=0x4000 ) z80->z80_mem[address] = data;
}

static void    z80_wr(void * param, uint16_t address, uint8_t data)
{
	struct z80_context * z80 = param;

	z80->z80_mem[address] = data;
}

static void    z80_hlt(void * param, uint8_t state)
{
	struct z80_context * z80 = param;

	z80_break(&z80->z80);
}

static void z80_out(void * param, uint16_t addr, uint8_t data)
{
	// ignore
}

static uint8_t z80_in(void * param, uint16_t address)
{
	struct z80_context * z80 = param;

	return (address&1) ? 0xFF : 0xBF;
}



struct z80_context * z80_init(char * filename, int sys_type)
{
	// allocate structure for z80 context and associated data
	//

	struct z80_context * z80 = malloc(sizeof(struct z80_context));
	//
	if( !z80 )
	{
		fprintf(stderr,"%s: %d, %s: can't allocate memory for struct z80_context!\n",__FILE__,__LINE__,__func__);
		exit(1);
	}

	// clear Z80 memory
	memset(z80->z80_mem,0,65536);

	// load Z80 .com binary
	if( filename )
	{
		size_t load_address = (sys_type==SYS_ZX) ? 0x8000 : 0x0100;


		FILE * f = fopen(filename,"rb");
		if( !f )
		{
			fprintf(stderr,"%s: %d, %s: can't open Z80 binary file <%s>!\n",__FILE__,__LINE__,__FUNCTION__,filename);
			exit(1);
		}
		//
		size_t read=fread(z80->z80_mem+load_address,1,65536-load_address,f);
		off_t o=ftello(f);
		int seek=fseeko(f,0,SEEK_END);
		off_t e=ftello(f);
		if( seek || o!=e || read!=e || !(0<o && o<=(65536-load_address)) )
		{
			fprintf(stderr,"%s: %d, %s: can't read Z80 .com file <%s>!\n",__FILE__,__LINE__,__FUNCTION__,filename);
			exit(1);
		}
		fclose(f);
	}

	if( sys_type==SYS_ZX ) // load ROM
	{
		FILE * f = fopen("1982.rom","rb");
		if( !f )
		{
			fprintf(stderr,"%s: %d, %s: can't open <1982.rom>!\n",__FILE__,__LINE__,__FUNCTION__);
			exit(1);
		}
		//
		size_t read=fread(z80->z80_mem,1,16384,f);
		off_t o=ftello(f);
		int seek=fseeko(f,0,SEEK_END);
		off_t e=ftello(f);
		if( seek || o!=e || read!=e || o!=16384 )
		{
			fprintf(stderr,"%s: %d, %s: can't read <1982.rom>!\n",__FILE__,__LINE__,__FUNCTION__);
			exit(1);
		}
		fclose(f);
	}

	z80->z80.i = 0x3F;
	z80->z80.af = 0x3222;

	// init cp/m stack value
	if( sys_type==SYS_CPM )
	{
		z80->z80_mem[6] = 0x00;
		z80->z80_mem[7] = 0x40;
	}
	
	// start address
	z80->start_address = (sys_type==SYS_ZX) ? 0x8000 : 0x0100;

	// start SP
	//z80->start_sp = (sys_type==SYS_ZX) ? 0x7FE8 : 0x4000;
	z80->start_sp = (sys_type==SYS_ZX) ? 0xFFFD : 0x4000;
	// return address (for ZX)
/*	if( sys_type==SYS_ZX )
	{
		z80->z80_mem[0x7FE8] = 0;
		z80->z80_mem[0x7FE9] = 0;
	}
*/
	// init callbacks
	z80->z80.context   = (void *)z80;

	z80->z80.nmia      = NULL;
	z80->z80.inta      = NULL;
	z80->z80.int_fetch = NULL;
	z80->z80.ld_i_a    = NULL;
	z80->z80.ld_r_a    = NULL;
	z80->z80.reti      = NULL;
	z80->z80.retn      = NULL;
	z80->z80.illegal   = NULL;

	z80->z80.fetch_opcode = (sys_type==SYS_ZX    ) ? (&z80_filter_zx_api)     :
	                        (sys_type==SYS_NEDOOS) ? (&z80_filter_nedoos_api) :
	                        (sys_type==SYS_CPM   ) ? (&z80_filter_cpm_api)    : NULL;

	z80->z80.fetch        = &z80_rd;
	z80->z80.read         = &z80_rd;
	z80->z80.nop          = &z80_rd;

	z80->z80.write     = (sys_type==SYS_ZX) ? &z80_zx_wr : &z80_wr;

	z80->z80.hook      = NULL;

	z80->z80.in        = &z80_in;
	z80->z80.out       = &z80_out;

	z80->z80.halt      = &z80_hlt;


	z80->z80.options = Z80_MODEL_ZILOG_NMOS;


	return z80;
}




size_t z80_exec(struct z80_context * z80, size_t max_clocks)
{
	z80->was_ed = 0;

	z80_power(&z80->z80,1);

	z80->z80.pc = z80->start_address;
	z80->z80.sp = z80->start_sp;
	
	size_t clocks = z80_execute(&z80->z80, max_clocks);


	if( !z80->z80.halt_line )
		return 0;
	
	return clocks;
}





uint8_t  z80_rdbyte(struct z80_context * z80, uint16_t addr)
{
	return z80->z80_mem[addr];
}

uint16_t z80_rdword_le(struct z80_context * z80, uint16_t addr)
{
	return (((uint16_t)z80_rdbyte(z80,addr+0)) & 0x00FF) |
	       (((uint16_t)z80_rdbyte(z80,addr+1)) << 8    ) ;
}

uint32_t z80_rdlong_le(struct z80_context * z80, uint16_t addr)
{
	return (((uint32_t)z80_rdword_le(z80,addr+0)) & 0x0000FFFF) |
	       (((uint32_t)z80_rdword_le(z80,addr+2)) << 16       ) ;
}

uint64_t z80_rdocta_le(struct z80_context * z80, uint16_t addr)
{
	return (((uint64_t)z80_rdlong_le(z80,addr+0)) & 0xFFFFFFFFull) |
	       (((uint64_t)z80_rdlong_le(z80,addr+4)) << 32          ) ;
}

void z80_wrbyte(struct z80_context * z80, uint16_t addr, uint8_t  data)
{
	z80->z80_mem[addr]=data;
}

void z80_wrword_le(struct z80_context * z80, uint16_t addr, uint16_t data)
{
	z80_wrbyte(z80,addr+0,data & 0x00FF);
	z80_wrbyte(z80,addr+1,data >> 8    );
}

void z80_wrlong_le(struct z80_context * z80, uint16_t addr, uint32_t data)
{
	z80_wrword_le(z80,addr+0,data & 0x0000FFFF);
	z80_wrword_le(z80,addr+2,data >> 16       );
}

void z80_wrocta_le(struct z80_context * z80, uint16_t addr, uint64_t data)
{
	z80_wrlong_le(z80,addr+0,data & 0xFFFFFFFFull);
	z80_wrlong_le(z80,addr+4,data >> 32          );
}

