#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include "psg.h"
#include "net.h"

int main(int argc, char ** argv)
{
	int nosync = 0;

	struct psg_file   * psg    = NULL; 
	struct frame_list * frames = NULL;

	
	
	// parse arguments
	if( argc!=3 && argc!=4 )
	{
ERRARGS:	fprintf(stderr,"usage: psgplay <ZX host address> <filename.psg> [--nosync]\n");
		fprintf(stderr," --nosync instructs the program not to send SYNCREQ and check SYNCRPLY packets\n");
		exit(1);
	}

	if( argc==4 )
	{
		if( !strcmp(argv[3],"--nosync") )
			nosync=1;
		else
			goto ERRARGS;
	}


	// load PSG file
//	psg = load_psg_file(argv[2]);
	//
//	frames = build_psg_frames(psg);



	// init network (required for NedowindOS)
	net_init();


	// resolve address
	struct in_addr a = net_resolve(argv[1]);

	printf("%08x\n",a.s_addr);



	net_test();





	net_dispose();

	free_psg_frames(frames);
	free_psg_file(psg);

	return 0;
}

