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

#ifndef SPHASH_OPT_H
#define SPHASH_OPT_H



struct hash_iface * make_sphash_opt(void);

int    sphash_opt_hash_init    (struct hash_iface * hash);
int    sphash_opt_hash_start   (struct hash_iface * hash);
int    sphash_opt_hash_addbytes(struct hash_iface * hash, const uint8_t * message, size_t size);
size_t sphash_opt_hash_getsize (struct hash_iface * hash);
int    sphash_opt_hash_result  (struct hash_iface * hash, uint8_t * result);
void   sphash_opt_hash_deinit  (struct hash_iface * hash);


#endif // SPHASH_OPT_H


