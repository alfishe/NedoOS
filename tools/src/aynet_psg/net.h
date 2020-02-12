#ifdef _WIN32
	int net_init(void);
	int net_dispose(void);
#else
	#define net_init() 0
	#define net_dispose() 0
#endif

int net_test(void);