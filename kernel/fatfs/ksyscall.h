typedef struct {
	char * path;
	unsigned char opt;
} SYS_VARS_MNT;

union UNION_SCALL_VARS {
  SYS_VARS_MNT mnt;
};

extern union UNION_SCALL_VARS scall_v;