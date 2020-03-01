#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <signal.h>

#include "psg.h"
#include "net.h"
#include "play.h"
#include "args.h"
#include "global.h"



struct psg_file   * psg; 
struct frame_list * frames;
int sock;
int sock_set;

void signal_handler(int);


int main(int argc, char ** argv)
{
	psg    = NULL; 
	frames = NULL;

	sock     = (-1);
	sock_set =   0;

	



	// parse arguments
	if( argc<3 )
	{
ERRARGS:	fprintf(stderr,"usage: psgplay <ZX host address> <filename.psg> [--prebuf N] [--testsync]\n");
		fprintf(stderr," --prebuf N : how many frames to send ahead of time (default is 100 (2 seconds), 0 means as many as possible)\n");
		fprintf(stderr," --testync  : instructs the program to send SYNCREQ and check SYNCRPLY packets\n");
		exit(1);
	}

	init_global();

	if( argc>3 && !parse_args(3,argc,argv) ) goto ERRARGS;

#ifdef DEBUG
printf("DEBUG: %s, prebuf=%d, testsync=%d\n",__PRETTY_FUNCTION__,g.buf_num,g.test_sync);
#endif



	// load PSG file
	psg = load_psg_file(argv[2]);
	//
	frames = build_psg_frames(psg);



	// init network (required for nedoVindOvS)
	net_init();


	// resolve address
	struct in_addr a = net_resolve(argv[1]);

	// connect to the AY server
	sock = net_connect(a);	
	sock_set = 1;

	// set signal handler that shuts up connection when process is terminated intentionally

#ifndef _WIN32
	signal(SIGHUP,  &signal_handler);
	signal(SIGQUIT, &signal_handler);
#endif
	signal(SIGINT,  &signal_handler);
	signal(SIGABRT, &signal_handler);
	signal(SIGTERM, &signal_handler);


	// play it!
	play_tune(sock,frames);



	net_disconnect(sock);




	free_psg_frames(frames);
	free_psg_file(psg);
	
	net_dispose();

	return 0;
}



void signal_handler(int num)
{
	if( sock_set )
	{ // try shut up remote AY by sending lots of ZX<< SHUTUP
		uint8_t a[100]; // must be greater than any other packet size
		memset(a,0,sizeof(a));
		send(sock, (void*)&a, sizeof(a), 0);

		net_disconnect(sock);
	}

	if( frames ) free_psg_frames(frames);

	if( psg ) free_psg_file(psg);

	net_dispose();
	exit(1);
}

