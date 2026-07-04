#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "atelnet_plug.h"

#define AT_LOG_PATH "telnet.log"

void r_at_log_write(const char *logline, const char *place)
{
  FILE *LogFile;
  unsigned long fileSize;
  unsigned char curPath[128];
  char hdr[32];
  unsigned int n;

  OS_GETPATH((unsigned int)curPath);
  OS_SETSYSDRV();
  OS_CHDIR("/");
  LogFile = OS_OPENHANDLE((unsigned char *)AT_LOG_PATH, 0x80u);
  if ((((int)LogFile) & 0xff) != 0)
  {
    LogFile = OS_CREATEHANDLE((unsigned char *)AT_LOG_PATH, 0x80u);
    OS_CLOSEHANDLE(LogFile);
    LogFile = OS_OPENHANDLE((unsigned char *)AT_LOG_PATH, 0x80u);
  }
  if ((((int)LogFile) & 0xff) != 0)
  {
    OS_CHDIR(curPath);
    return;
  }

  fileSize = OS_GETFILESIZE(LogFile);
  OS_SEEKHANDLE(LogFile, fileSize);

  sprintf(hdr, "%7lu : ", time());
  OS_WRITEHANDLE((unsigned char *)hdr, LogFile, (unsigned int)strlen(hdr));
  if (place != 0)
  {
    n = (unsigned int)strlen(place);
    if (n > 8u)
    {
      n = 8u;
    }
    OS_WRITEHANDLE((unsigned char *)place, LogFile, n);
    OS_WRITEHANDLE((unsigned char *)" : ", LogFile, 3u);
  }
  if (logline != 0)
  {
    n = (unsigned int)strlen(logline);
    if (n > 160u)
    {
      n = 160u;
    }
    OS_WRITEHANDLE((unsigned char *)logline, LogFile, n);
  }
  OS_WRITEHANDLE((unsigned char *)"\r\n", LogFile, 2u);
  OS_CLOSEHANDLE(LogFile);
  OS_CHDIR(curPath);
}
