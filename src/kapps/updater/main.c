#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <stdlib.h>
#include <oscalls.h>
#include <terminal.c>
#include <tcp.h>
#include <osfs.h>
#include <intrz80.h>
#include <ctype.h>
#include <math.h>
unsigned char uVer[] = "0.33";
unsigned char curPath[128];
unsigned char curLetter;
unsigned char oldBinExt;
unsigned char is_atm;
unsigned int errn;
unsigned long contLen;
unsigned char saveFlag, saveBak;
unsigned char crlf[2] = {13, 10};
unsigned long bytecount, downloaded;
unsigned char status, key, curFormat;
struct sockaddr_in targetadr;
struct readstructure readStruct;
FILE *fp2;

struct window
{
	unsigned char x;
	unsigned char y;
	unsigned char w;
	unsigned char h;
	unsigned char text;
	unsigned char back;
	unsigned char tittle[80];

} cw;
unsigned char kernelName[32];
unsigned char machineName[32];
unsigned char kernelLink[256];

unsigned int bufSize = 2048; // Some memory corruption at this point, some QnD
unsigned char netbuf[2500];

void clearStatus(void)
{
	AT(1, 24);
	printf("                                                                               \r");
}

void printTable(void)
{
	unsigned int cycle;

	for (cycle = 32; cycle < 256; cycle++)
	{
		printf("%03u:", cycle);
		putchar(cycle);
		printf(" ");
		if (cycle % 10 == 0)
		{
			printf("\r\n");
		}
	}
}

void delay(unsigned long counter)
{
	unsigned long start, finish;
	counter = counter / 20;
	if (counter < 1)
	{
		counter = 1;
	}
	start = time();
	finish = start + counter;

	while (start < finish)
	{
		start = time();
		YIELD();
	}
}

void drawWindow(struct window w)
{
	unsigned char wcount, tempx, tittleStart;

	AT(w.x, w.y - 1);
	tittleStart = w.x + (w.w / 2) - (strlen(w.tittle) / 2) + 1;
	BOX(w.x, w.y, w.w + 1, w.h, w.back, 32);
	AT(w.x, w.y);
	ATRIB(w.text);
	putchar(201);
	for (wcount = 0; wcount < w.w; wcount++)
	{
		putchar(205);
	}
	putchar(187);

	AT(w.x, w.y + w.h);
	putchar(200);
	for (wcount = 0; wcount < w.w; wcount++)
	{
		putchar(205);
	}
	putchar(188);

	tempx = w.x + w.w + 1;
	for (wcount = 1; wcount < w.h; wcount++)
	{
		AT(w.x, w.y + wcount);
		putchar(186);
		AT(tempx, w.y + wcount);
		putchar(186);
	}

	AT(w.x, w.y + 2);
	putchar(199);
	for (wcount = 0; wcount < w.w; wcount++)
	{
		putchar(196);
	}
	putchar(182);

	AT(tittleStart, w.y + 1);
	printf("%s", w.tittle);
}

void fatalError(unsigned char *message)
{
	strcpy(cw.tittle, "FATAL ERROR!");

	if (strlen(message) > strlen(cw.tittle))
	{
		cw.w = strlen(message) + 2;
	}
	else
		cw.w = strlen(cw.tittle) + 2;
	cw.x = 80 / 2 - cw.w / 2;
	cw.y = 11;
	cw.h = 4;
	cw.text = 97;
	cw.back = 41;

	drawWindow(cw);
	AT(cw.x + 2, cw.y + 3);
	printf(message);
	AT(1, 1);
	getchar();
	exit(0);
}

void infoBox(unsigned char *message)
{
	strcpy(cw.tittle, "nedoOS system updater ");
	strcat(cw.tittle, uVer);

	if (strlen(message) > strlen(cw.tittle))
	{
		cw.w = strlen(message) + 2;
	}
	else
		cw.w = strlen(cw.tittle) + 2;
	cw.x = 80 / 2 - cw.w / 2;
	cw.y = 15;
	cw.h = 4;
	cw.text = 97;
	cw.back = 42;

	drawWindow(cw);
	AT(cw.x + 2, cw.y + 3);
	printf(message);
	AT(1, 1);
}

unsigned char OS_SHELL(unsigned char *command)
{
	unsigned char fileName[] = "bin/cmd.com";
	unsigned char appCmd[128] = "cmd.com ";
	unsigned int shellSize, loaded, loop, adr;
	unsigned char pgbak;
	union APP_PAGES shell_pg;
	union APP_PAGES main_pg;
	FILE *fp3;
	main_pg.l = OS_GETMAINPAGES();
	pgbak = main_pg.pgs.window_3;
//	printf("OS_GETMAINPAGES()\r\n");
//	printf("main_pg.pgs.window_0=%u\r\nmain_pg.pgs.window_1=%u\r\nmain_pg.pgs.window_2=%u\r\nmain_pg.pgs.window_3=%u\r\n", main_pg.pgs.window_0, main_pg.pgs.window_1, main_pg.pgs.window_2, main_pg.pgs.window_3);
	OS_GETPATH((unsigned int)&curPath);
	strcat(appCmd, command);
	fp3 = OS_OPENHANDLE(fileName, 0x80);
	if (((int)fp3) & 0xff)
	{
		clearStatus();
		AT(1, 24);
		printf(fileName);
		printf(" not found.");
		getchar();
		exit(0);
	}
	shellSize = OS_GETFILESIZE(fp3);

	OS_NEWAPP((unsigned int)&shell_pg);

//	printf("OS_NEWAPP [iD:%u]\r\n", shell_pg.pgs.pId);
//	printf("shell_pg.pgs.window_0=%u\r\nshell_pg.pgs.window_1=%u\r\nshell_pg.pgs.window_2=%u\r\nshell_pg.pgs.window_3=%u\r\n", shell_pg.pgs.window_0, shell_pg.pgs.window_1, shell_pg.pgs.window_2, shell_pg.pgs.window_3);
	shell_pg.l = OS_GETAPPMAINPAGES(shell_pg.pgs.pId);
//	printf("OS_GETAPPMAINPAGES\r\n");
//	printf("shell_pg.pgs.window_0=%u (0000)\r\nshell_pg.pgs.window_1=%u\r\nshell_pg.pgs.window_2=%u\r\nshell_pg.pgs.window_3=%u\r\n", shell_pg.pgs.window_0, shell_pg.pgs.window_1, shell_pg.pgs.window_2, shell_pg.pgs.window_3);

	SETPG32KHIGH(shell_pg.pgs.window_0);
//	printf("memcpy(");
//	printf("%u", (char *)(0xC080));
//	printf(",");
//	printf("%u", (char *)(&appCmd));
//	printf(",");
//	printf("%u)\r\n", sizeof(appCmd));

	memcpy((char *)(0xC080), (char *)(&appCmd), sizeof(appCmd));

	loop = 0;
	while (loop < shellSize)
	{
		loaded = OS_READHANDLE(netbuf, fp3, sizeof(netbuf));
		adr = 0xC100 + loop;
		memcpy((char *)(adr), &netbuf, loaded);
		loop = loop + loaded;
	}
	//OS_DIHALT();
	//printf("shellSize = %u loop(sum)=%u adr=%u\r\n\r\n", shellSize, loop, adr);

	OS_CLOSEHANDLE(fp3);
	SETPG32KHIGH(pgbak);

	clearStatus();
	printf("Running shell [pId:%u][%s][%s]", shell_pg.pgs.pId, curPath, appCmd);
	AT(1, 24);
	delay(300);
	OS_RUNAPP(shell_pg.pgs.pId);
//	printf("\r\nOS_RUNAPP finished\r\n");
	OS_WAITPID(shell_pg.pgs.pId);
//	getchar();
//	exit(0);
	return shell_pg.pgs.pId;
}
//////////////// NETWORK PART //////////////////////
#include <network.c>
////////////////////////////////////////////////////

unsigned char getConfig(void)
{
	is_atm = (unsigned char)OS_GETCONFIG();
	// H=system drive, L= 1-Evo 2-ATM2 3-ATM3 6-p2.666 ;E=pgsys(system page) D= TR-DOS page
	switch ((is_atm))
	{
	case 1:
		strcpy(machineName, "ZX-Evolution");
		strcpy(kernelName, "sd_boot.$C");
		strcpy(kernelLink, "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fsd_boot.%24C");
		break;
	case 2:
		strcpy(machineName, "TURBO 2+");
		strcpy(kernelName, "osatm2hd.$C");
		strcpy(kernelLink, "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fosatm2hd.%24C");

		break;

	case 3: // SD HDD versions
		strcpy(machineName, "TURBO 3 [SD]");
		strcpy(kernelName, "osatm3hd.$C");
		strcpy(kernelLink, "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fosatm3hd.%24C");
		break;
	case 6: // SD HDD versions
		strcpy(machineName, "P2.666 [SD]");
		strcpy(kernelName, "osp26sd.$C");
		strcpy(kernelLink, "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fosp26sd.%24C");
		break;

	default:
		strcpy(machineName, "NOT DETECED (ZX-Evo)");
		strcpy(kernelName, "sd_boot.$C");
		strcpy(kernelLink, "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fsd_boot.%24C");
		break;
	}
	return is_atm;
}
// Downloading minimal tools for updating/boot
void getTools(void)
{
	unsigned char pkunzipLink[] = "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fbin%2Fpkunzip.com";
	unsigned char tarLink[] = "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fbin%2Ftar.com";
	unsigned char cmdLink[] = "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fbin%2Fcmd.com";
	unsigned char termLink[] = "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fbin%2Fterm.com";
	unsigned char updLink[] = "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fbin%2Fupdater.com";

	errn = OS_MKDIR("bin"); // Create if not exist
	ATRIB(cw.text);
	ATRIB(cw.back);
	errn = getFile(pkunzipLink, "bin/pkunzip.com");
	errn = getFile(tarLink, "bin/tar.com");
	errn = getFile(cmdLink, "bin/cmd.com");
	errn = getFile(termLink, "bin/term.com");
	errn = getFile(updLink, "bin/updater.com");
}

void deleteWorkFiles(void)
{
	OS_DELETE("bin.zip");
	OS_DELETE("bin.tar");
	OS_DELETE("bin.old"); // deleting not empty folders not supported
	OS_DELETE("bin.r17");
	OS_DELETE("bin.r18");
	OS_DELETE("bin.r19");
	OS_DELETE("bin.r20");
}

unsigned char ren2old(unsigned char *name)
{
	unsigned char *oldName = "0000000000000000000000000000000000";
	unsigned char counter = 255;
	OS_MKDIR((void *)name);
	sprintf(oldName, "%s.old", name);
	while (OS_RENAME((void *)name, (void *)oldName) != 0)
	{
		counter++;
		if (counter == 255)
		{
			fatalError("Unable to rename old folder");
		}

		sprintf(oldName, "%s.%u", name, counter);
	}
	return counter;
}

void ren2tar(void)
{
	unsigned char *name = "0000000000000000000000000000000000";
	unsigned char counter = 17;
	errn = 255;
	sprintf(name, "bin.r%u", counter);
	AT(1, 1);
	while (errn != 0)
	{
		errn = OS_RENAME((void *)name, "bin.tar");
		counter++;
		sprintf(name, "bin.r%u", counter);
		if (counter > 99)
		{
			fatalError("Unable to rename TAR file");
		}
	}
}

void ren2bin(void)
{
	unsigned char *name = "0000000000000000000000000000000000";
	unsigned char counter = 17;
	errn = 255;
	sprintf(name, "bin.r%u", counter);
	AT(1, 1);
	while (errn != 0)
	{
		errn = OS_RENAME((void *)name, "bin");
		counter++;
		sprintf(name, "bin.r%u", counter);
		if (counter > 99)
		{
			fatalError("Unable to rename BIN folder");
		}
	}
}

void restoreConfig(unsigned char oldBinExt)
{
	unsigned char *name = "0000000000000000000000000000000000";
	errn = OS_CHDIR("/");
	errn = OS_RENAME("bin/autoexec.bat", "bin/autoexec.new");
	errn = OS_RENAME("bin/net.ini", "bin/net.new");
	errn = OS_RENAME("bin/nv.ext", "bin/nv.new");

	errn = OS_CHDIR("/");

	if (oldBinExt == 255)
	{
		errn = OS_SHELL("copy bin.old/autoexec.bat bin/autoexec.bat");

		errn = OS_SHELL("copy bin.old/net.ini bin/net.ini");

		errn = OS_SHELL("copy bin.old/nv.ext bin/nv.ext");

		errn = OS_SHELL("copy bin.old/nv.pth bin/nv.pth");
	}
	else
	{
		sprintf(name, "copy bin.%u/autoexec.bat bin/autoexec.bat", oldBinExt);
		OS_SHELL((void *)name);

		sprintf(name, "copy bin.%u/net.ini bin/net.ini", oldBinExt);
		OS_SHELL((void *)name);

		sprintf(name, "copy bin.%u/nv.ext bin/nv.ext", oldBinExt);
		OS_SHELL((void *)name);

		sprintf(name, "copy bin.%u/nv.pth bin/nv.pth", oldBinExt);
		OS_SHELL((void *)name);
	}

	errn = OS_RENAME("bin/autoexec.new", "bin/autoexec.bat");
	errn = OS_RENAME("bin/net.new", "bin/net.ini");
	errn = OS_RENAME("bin/nv.new", "bin/nv.ext");
}

// Download, backup, unpack release.bin
void fullUpdate(void)
{
	unsigned char relLink[] = "http://nedoos.ru/images/release.zip";

	BOX(1, 1, 80, 25, 40, 176);
	cw.x = 20;
	cw.y = 5;
	cw.w = 40;
	cw.h = 7;
	cw.text = 97;
	cw.back = 45;
	strcpy(cw.tittle, "nedoOS FULL updater ");
	strcat(cw.tittle, uVer);

	getConfig();

	OS_GETPATH((unsigned int)&curPath);
	curLetter = curPath[0];
	errn = OS_CHDIR("/");

	strcat(cw.tittle, " (");
	strcat(cw.tittle, machineName);
	strcat(cw.tittle, ")");
	drawWindow(cw);

	OS_DELETE("release.zip");
	OS_DELETE("bin.old");
	OS_DELETE("doc.old");
	OS_DELETE("nedodemo.old");
	OS_DELETE("nedogame.old");

	clearStatus();
	AT(cw.x + 2, cw.y + 3);
	printf("Downloading release.zip...");

	errn = getFile(relLink, "release.zip"); //  Downloading the file

	clearStatus();
	AT(cw.x + 2, cw.y + 4);
	printf("Backuping old system...\r\n");

	oldBinExt = ren2old("bin");
	ren2old("doc");
	ren2old("nedodemo");
	ren2old("nedogame");

	clearStatus();
	AT(cw.x + 2, cw.y + 5);
	printf("Downloading tools...\r\n");

	getTools();

	BOX(1, 1, 80, 25, 40, 32);
	AT(1, 1);
	printf("Depacking release. Its take about 10 hours. Please wait.\r\n");
	YIELD();
	OS_SHELL("pkunzip.com release.zip");
	drawWindow(cw);
	AT(cw.x + 2, cw.y + 3);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("Restoring configs...");
	OS_DELETE("release.zip");
}
// Updating only BIN folders, where is OS lives.
void binUpdate(void)
{
	unsigned char binLink[] = "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fbin%2F&isdir=1";
	BOX(1, 1, 80, 25, 40, 176);
	cw.x = 20;
	cw.y = 5;
	cw.w = 40;
	cw.h = 10;
	cw.text = 97;
	cw.back = 44;
	strcpy(cw.tittle, "nedoOS BIN updater ");
	strcat(cw.tittle, uVer);
	getConfig();
	strcat(cw.tittle, " (");
	strcat(cw.tittle, machineName);
	strcat(cw.tittle, ")");
	drawWindow(cw);

	errn = OS_CHDIR("/");
	OS_GETPATH((unsigned int)&curPath);
	curLetter = curPath[0];

	deleteWorkFiles();

	clearStatus();
	AT(cw.x + 2, cw.y + 3);
	printf("Downloading bin.zip...");

	errn = getFile(binLink, "bin.zip"); //  Downloading the file

	clearStatus();
	AT(cw.x + 2, cw.y + 4);
	printf("Downloading tools...");

	getTools();

	BOX(1, 1, 80, 25, 40, 32);
	AT(1, 1);
	printf("Depacking release. Its take about 10 minutes. Please wait...\r\n");
	YIELD();

	OS_SHELL("pkunzip.com bin.zip");
	BOX(1, 1, 80, 25, 40, 176);
	drawWindow(cw);

	AT(cw.x + 2, cw.y + 3);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("Renaming bin.r?? to bin.tar...");

	ren2tar();

	AT(cw.x + 2, cw.y + 4);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("Untaring bin.tar, please wait...");

	OS_SHELL("tar.com bin.tar");

	AT(cw.x + 2, cw.y + 5);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("Backuping old bin to bin.old...");

	oldBinExt = ren2old("bin");

	AT(cw.x + 2, cw.y + 6);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("Renaming NEW BIN...");

	ren2bin();

	AT(cw.x + 2, cw.y + 7);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("Deleting zip & tar...");

	AT(cw.x + 2, cw.y + 8);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("Downloading kernel [%s]...", machineName);
	errn = OS_CHDIR("/");
	errn = getFile(kernelLink, kernelName); //  Downloading the file
	AT(cw.x + 2, cw.y + 9);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("Restoring configs...");
}

C_task main(int argc, char *argv[])
{
	os_initstdio();

	if (argc > 1)
	{
		if (argv[1][0] == 'F')
		{
			fullUpdate();
		}
		else
		{
			AT(1, 1);
			fatalError("Use 'F' key to FULL update");
		}
	}
	else
	{
		binUpdate();
	}
	restoreConfig(oldBinExt);
	deleteWorkFiles();
	clearStatus();
	infoBox("System Updated successfully!");
	getchar();
	ATRIB(40);
	ATRIB(32);
	exit(0);
}
