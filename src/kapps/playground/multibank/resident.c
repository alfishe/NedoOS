#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include "mb_inc.h"
#include "mb_plug.h"
#include "mb_bank.h"

/*
 * CODE_RESIDENT linked at 8000-BFFF.
 * Physical page = g_codePg (normally window_2 from .com load).
 * May use netbuf @ C000 only while g_dataPg is mapped there (mb_init keeps it).
 */

#define MB_R_MOCK_MAGIC 0x524Eu /* 'NR' */

unsigned short r_mock_magic(void)
{
	return MB_R_MOCK_MAGIC;
}

unsigned char r_mock_transform(unsigned char tag)
{
	return (unsigned char)(tag ^ 0xA5u);
}

void r_mock_message(char *buf, unsigned char buf_sz, const char *prefix)
{
	unsigned char i;
	unsigned char j;
	static const char tail[] = " [resident@8000]";

	if (buf == 0 || buf_sz == 0u)
		return;

	i = 0;
	if (prefix != 0)
	{
		while (prefix[i] != 0 && i + 1u < buf_sz)
		{
			buf[i] = prefix[i];
			i++;
		}
	}
	j = 0;
	while (tail[j] != 0 && i + 1u < buf_sz)
	{
		buf[i] = tail[j];
		i++;
		j++;
	}
	buf[i] = 0;
}

unsigned int r_fill_netbuf(unsigned char seed, unsigned int n)
{
	unsigned int i;

	/* netbuf must point into mapped data page @ C000. */
	if (netbuf == 0)
		return 0u;
	if (n > MB_NETBUF_SIZE)
		n = MB_NETBUF_SIZE;

	for (i = 0u; i < n; i++)
		netbuf[i] = (unsigned char)(seed + (unsigned char)i);

	return n;
}
