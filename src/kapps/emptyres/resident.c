#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include "emptyres_inc.h"
#include "emptyres_plug.h"

/*
 * CODE_RESIDENT linked at C000; physical copy lives in window_3 (residentPg).
 * No own globals ? only stack and args in 0100-BFFF.
 */

unsigned short r_mock_magic(void)
{
	return ER_R_MOCK_MAGIC;
}

unsigned char r_mock_transform(unsigned char tag)
{
	/* XOR proves we ran code from the mapped resident page, not main. */
	return (unsigned char)(tag ^ 0xA5u);
}

void r_mock_message(char *buf, unsigned char buf_sz, const char *prefix)
{
	unsigned char i;
	unsigned char j;

	if (buf == NULL || buf_sz == 0u)
		return;

	i = 0;
	if (prefix != NULL)
	{
		while (prefix[i] != 0 && i + 1u < buf_sz)
		{
			buf[i] = prefix[i];
			i++;
		}
	}
	j = 0;
	while (" [resident@C000]"[j] != 0 && i + 1u < buf_sz)
	{
		buf[i] = " [resident@C000]"[j];
		i++;
		j++;
	}
	buf[i] = 0;
}
