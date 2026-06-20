#ifndef ATELNET_TELBOOK_H
#define ATELNET_TELBOOK_H

/* Returns 1 to connect (host/port/cp866 filled), 0 if user quit. */
int telbook_run(char *host, unsigned int host_sz, unsigned int *port,
                unsigned char *cp866, unsigned char *debug);

#endif
