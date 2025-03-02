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

#ifndef _Z80_WRAP_H_
#define _Z80_WRAP_H_

#define SYS_CPM    (1)
#define SYS_NEDOOS (2)
#define SYS_ZX     (3)

struct type_detect
{
	const char * const argument_name;
	const int sys_type;
};

enum z80_max_clocks
{
	Z80_MAX_CLOCKS = 10000000
};


struct z80_context
{
	Z80 z80;
	uint16_t start_address;
	uint16_t start_sp;

	int was_ed;
	int was_23;

	uint8_t z80_mem[65536];
};


struct z80_context * z80_init(char * filename, int sys_type);

size_t z80_exec(struct z80_context * z80, size_t max_clocks);


uint8_t  z80_rdbyte(struct z80_context * z80, uint16_t addr);
uint16_t z80_rdword_le(struct z80_context * z80, uint16_t addr);
uint32_t z80_rdlong_le(struct z80_context * z80, uint16_t addr);
uint64_t z80_rdocta_le(struct z80_context * z80, uint16_t addr);

void z80_wrbyte(struct z80_context * z80, uint16_t addr, uint8_t  data);
void z80_wrword_le(struct z80_context * z80, uint16_t addr, uint16_t data);
void z80_wrlong_le(struct z80_context * z80, uint16_t addr, uint32_t data);
void z80_wrocta_le(struct z80_context * z80, uint16_t addr, uint64_t data);





#endif // _Z80_WRAP_H_

