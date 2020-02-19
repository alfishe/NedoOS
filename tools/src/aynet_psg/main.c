#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <signal.h>

#include "psg.h"
#include "net.h"
#include "play.h"



struct psg_file   * psg; 
struct frame_list * frames;
int sock;
int sock_set;

void signal_handler(int);

BOOL WINAPI HandlerRoutine(
  DWORD dwCtrlType   //  control signal type
)
{
  //if (!g_hEvent)
    //return FALSE;

  switch (dwCtrlType)
  {
    case CTRL_C_EVENT:
      printf ("Ctrl+C pressed");
      //SetEvent (g_hEvent);
      break;
    case CTRL_BREAK_EVENT:
      printf ("Ctrl+Break pressed");
      //SetEvent (g_hEvent);
      break;
    case CTRL_CLOSE_EVENT:
      printf ("Close pressed");
      //SetEvent (g_hEvent);
      break;
    case CTRL_LOGOFF_EVENT:
      printf ("User logoff");
      //SetEvent (g_hEvent);
      break;
    case CTRL_SHUTDOWN_EVENT:
      printf ("System shutdown");
      //SetEvent (g_hEvent);
      break;
  }

  return TRUE; // as we handle the event
}


int main(int argc, char ** argv)
{
	int nosync = 0;

	psg    = NULL; 
	frames = NULL;

	sock     = (-1);
	sock_set =   0;

	
#ifdef DEBUG
printf("DEBUG: %s\n",__PRETTY_FUNCTION__);
printf("DEBUG: sizeof(struct packet             )=%ld\n",sizeof(struct packet             ));
printf("DEBUG: sizeof(struct rx_packet_framesync)=%ld\n",sizeof(struct rx_packet_framesync));
printf("DEBUG: sizeof(struct rx_packet_syncrply )=%ld\n",sizeof(struct rx_packet_syncrply ));
printf("DEBUG: sizeof(struct rx_packet_hello    )=%ld\n",sizeof(struct rx_packet_hello    ));
printf("DEBUG: sizeof(struct tx_packet_shutup   )=%ld\n",sizeof(struct tx_packet_shutup   ));
printf("DEBUG: sizeof(struct tx_packet_dump     )=%ld\n",sizeof(struct tx_packet_dump     ));
printf("DEBUG: sizeof(struct tx_packet_syncreq  )=%ld\n",sizeof(struct tx_packet_syncreq  ));
#endif



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
  SetConsoleCtrlHandler (HandlerRoutine, TRUE);


	signal(SIGHUP,  &signal_handler);
	signal(SIGQUIT, &signal_handler);
#endif
	signal(SIGINT,  &signal_handler);
	signal(SIGABRT, &signal_handler);
	signal(SIGTERM, &signal_handler);


	// play it!
	play_tune(sock,frames);



	net_disconnect(sock);



//	net_test();





	net_dispose();

	free_psg_frames(frames);
	free_psg_file(psg);

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

