; Jump table @8000 -- bank 05 CDFS/ATAPI (PoC).

	MODULE bank_jt5
	PUBLIC bank_jt5

	EXTERN r_cdfs_present
	EXTERN r_cdfs_opendir
	EXTERN r_cdfs_readdir
	EXTERN r_cdfs_read

	RSEG CODE_RESIDENT
bank_jt5:
	JP	r_cdfs_present
	JP	r_cdfs_opendir
	JP	r_cdfs_readdir
	JP	r_cdfs_read

	END
