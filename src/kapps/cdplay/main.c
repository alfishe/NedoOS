#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <intrz80.h>
#define true 1
#define false 0
#define master 0xa0
#define slave 0xb0
#define VIEW_HEIGHT 12       /* Сколько треков одновременно видно в окне */
#define MAX_READ_ATTEMPTS 10 // Опционально: защита от бесконечного цикла, если диск поврежден

struct params
{
    unsigned char current_track;
    unsigned char is_playing;
    unsigned char is_paused;
    unsigned char is_foreground;

} set;

struct coordinates
{
    unsigned char winX;
    unsigned char winY;
    unsigned char winW;
    unsigned char winH;
    unsigned char color;
} winPos;

struct coordinates statPos;

struct idedrives
{
    unsigned char mst;
    unsigned char mModel[42];
    unsigned char slv;
    unsigned char sModel[42];
} drives;

/* Структура описания одного трека в TOC */
typedef struct
{
    unsigned char reserved1;
    unsigned char control_adr;  /* Биты 4-7: тип трека (аудио/данные). Бит 4 == 0 - аудио */
    unsigned char track_number; /* Номер трека */
    unsigned char reserved2;
    unsigned char reserved3; /* Зарезервировано */
    unsigned char m;         /* Минуты */
    unsigned char s;         /* Секунды */
    unsigned char f;         /* Фреймы (кадры) */
} ATAPI_TOC_TRACK;

/* Буфер для хранения оглавления (максимум 99 треков + Lead-Out трек) */
typedef struct
{
    unsigned char toc_length_hi; /* Длина оставшихся данных TOC */
    unsigned char toc_length_lo;
    unsigned char first_track;  /* Первый доступный трек (обычно 1) */
    unsigned char last_track;   /* Последний доступный трек */
    ATAPI_TOC_TRACK tracks[66]; /* Массив треков */
} ATAPI_TOC;

/* Структура ответа на команду READ SUB-CHANNEL */
typedef struct
{
    unsigned char reserved;
    unsigned char audio_status; /* 0x11 - играет, 0x12 - пауза, 0x13 - готово/стоп */
    unsigned char data_len_hi;  /* Длина оставшихся данных */
    unsigned char data_len_lo;

    /* sub-channel data format 0x01 */
    unsigned char data_format;
    unsigned char control_adr;
    unsigned char track_number; /* Номер текущего играющего трека! */
    unsigned char index_number;

    /* Absolute MSF (от начала диска) */
    unsigned char abs_rsv;
    unsigned char abs_m;
    unsigned char abs_s;
    unsigned char abs_f;

    /* Relative MSF (от начала ТРЕКА) */
    unsigned char rel_rsv;
    unsigned char rel_m; /* Минуты трека */
    unsigned char rel_s; /* Секунды трека */
    unsigned char rel_f; /* Фреймы трека */
} ATAPI_SUB_CHANNEL;

/* Глобальная переменная для хранения текущей позиции */
ATAPI_SUB_CHANNEL cd_pos;
/* Выделяем глобальный буфер для оглавления */
ATAPI_TOC cd_toc;

/* Команда Eject (Выбросить лоток): 1B 00 00 00 02 00 ... */
/* 5-й байт: 0x02 означает LOAD/EJECT (биты: 00000010) */
const unsigned char cmd_atapi_eject[12] = {0x1B, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

/* Команда Close (Закрыть лоток): 1B 00 00 00 03 00 ... */
/* 5-й байт: 0x03 означает CLOSE (биты: 00000011) */
const unsigned char cmd_atapi_close[12] = {0x1B, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

/* Команда Stop Audio (Остановить воспроизведение) */
const unsigned char cmd_atapi_stop[12] = {0x4E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

unsigned int hddstat, hddcmd, hddhead, hddcylhi, hddcyllo, hddsec, hddcount, hdderr, hdddatlo, hdddathi, hddupr, hdduprON, hddupr1, hddupr0;

unsigned char buffer[3096];
unsigned char uVer[] = "1.2";

/* Глобальные переменные для управления интерфейсом */
unsigned char ui_selected_idx = 0;  /* Подсвеченный курсором трек (индекс в массиве, 0-based) */
unsigned char ui_scroll_offset = 0; /* Смещение скроллинга списка */

void spaces(unsigned char number)
{
    while (number > 0)
    {
        putchar(' ');
        number--;
    }
}

void clearStatus(void)
{
    OS_SETCOLOR(5);
    OS_SETXY(0, 24);
    spaces(79);
    OS_SETXY(0, 24);
}

void quit(void)
{
    OS_SETGFX(0x86);
    exit(0);
}

unsigned char delayLongKey(unsigned long counter)
{
    unsigned long start, finish, key;
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
        key = OS_GETKEY();
        if (key != 0)
        {
            return key;
        }
        YIELD();
    }
    return 0;
}

void delayInt(unsigned char counter)
{
    unsigned long finish;
    finish = time() + counter;
    do
    {
        YIELD();
    } while (time() < finish);
}

char waitKey(void)
{
    char key;
    do
    {
        key = OS_GETKEY();
    } while (key == 0);
    return key;
}

char detectHdd(unsigned char channel)
{
    char retry = 10, data;
    unsigned int datahl;
    int counter;

    switch (channel)
    {
    case master:
        puts("Detecting master HDD...");
        break;
    case slave:
        puts("Detecting slave HDD...");
        break;
    default:
        break;
    }
    output(hddhead, channel);
    do
    {
        data = input(hddstat);

        retry = retry - 1;
        if (retry == 0 || data == 0x00 || data == 0xff)
        {
            return false;
        }
        //        delayInt(10);
    } while (data & 0x80);

    output(hddcylhi, 0x00);
    output(hddcyllo, 0x00);

    output(hddcmd, 0xec); // send ident command
    do
    {
        data = input(hddstat);
    } while (data & 0x80); // BSY NOT SET AND DRQ SET (DRIVE READY)

    datahl = input(hddcyllo) + input(hddcylhi) * 256;
    if (datahl != 0x00)
    {

        return false;
    }

    counter = 0;
    do
    {
        buffer[counter + 1] = input(hdddatlo); // d
        buffer[counter] = input(hdddathi);     // w
        counter++;
        counter++;
    } while (counter < 512);

    switch (channel)
    {
    case master:
        for (counter = 54; counter < 94; counter++)
        {
            drives.mModel[counter - 54] = buffer[counter];
        }
        // printf("Model: %s\r\n", drives.mModel);
        break;
    case slave:
        for (counter = 54; counter < 94; counter++)
        {
            drives.sModel[counter - 54] = buffer[counter];
        }
        // printf("Model: %s\r\n", drives.sModel);
    default:
        break;
    }
    return true;
}

char detectCd(unsigned char channel)
{
    char retry = 10, data;
    unsigned int counter, datahl;

    switch (channel)
    {
    case master:
        puts("Detecting master CD...");
        break;
    case slave:
        puts("Detecting slave CD...");
        break;
    default:
        break;
    }
    output(hddhead, channel);

    retry = 10;
    do
    {
        data = input(hddstat);

        retry = retry - 1;
        if (retry == 0 || data == 0xff)
        {
            return false;
        }
    } while (data & 0x80);

    output(hddcylhi, 0x00);
    output(hddcyllo, 0x00);
    output(hddhead, channel);
    output(hddcmd, 0xec); // send ident command
    do
    {
        data = input(hddstat);
    } while ((data & 0x80)); //  NOT realy? data & 0x88 = 0x08 BSY NOT SET AND DRQ SET (DRIVE READY)

    output(hddhead, channel);
    datahl = input(hddcyllo) + input(hddcylhi) * 256;
    if (datahl != 0xeb14)
    {
        return false;
    }

    output(hddhead, channel);
    output(hddcmd, 0xa1); // send atapi ident command
    delayInt(2);
    counter = 0;
    do
    {
        buffer[counter + 1] = input(hdddatlo);
        buffer[counter] = input(hdddathi);
        counter++;
        counter++;
    } while (counter < 2048);

    switch (channel)
    {
    case master:
        for (counter = 54; counter < 94; counter++)
        {
            drives.mModel[counter - 54] = buffer[counter];
        }
        break;
    case slave:
        for (counter = 54; counter < 94; counter++)
        {
            drives.sModel[counter - 54] = buffer[counter];
        }
    default:
        break;
    }
    return 2;
}

/* Функция ожидания готовности привода (освобождения от BSY) */
unsigned char waitBsy(char channel)
{
    unsigned char status;
    unsigned int timeout = 0xFFFF;

    output(hddhead, channel);
    do
    {
        status = input(hddstat);
        if ((status & 0x80) == 0)
        {
            return status; /* Готов */
        }
    } while (--timeout > 0);

    return 0xFF; /* Таймаут */
}

/* Функция ожидания готовности к передаче данных (DRQ) */
unsigned char waitDrq(char channel)
{
    unsigned char status;
    unsigned int timeout = 0xFFFF;

    output(hddhead, channel);
    do
    {
        status = input(hddstat);
        /* BSY должен быть 0, а DRQ должен быть 1 */
        if ((status & 0x80) == 0 && (status & 0x08) != 0)
        {
            return status; /* Готов принимать пакет */
        }
    } while (--timeout > 0);

    return 0xFF; /* Таймаут */
}

/* Универсальная и правильная функция отправки ATAPI-пакета */
char sendAtapiPacket(const unsigned char *packet, char channel)
{
    unsigned char counter;

    disable_interrupt();

    /* 1. Ждем, пока освободится шина */

    if (waitBsy(channel) == 0xFF)
    {
        enable_interrupt();
        return false;
    }
    /* 2. Посылаем ATA-команду "Принять ATAPI-пакет" (0xA0) */
    output(hddhead, channel);
    output(hddcmd, 0xA0);

    /* 3. Ждем, пока привод выставит DRQ (запросит пакет) */
    if (waitDrq(channel) == 0xFF)
    {
        enable_interrupt();
        return false;
    }

    /* 4. Отправляем 12 байт пакета как 6 16-битных слов */
    /* В Nemo IDE критически важно писать сначала в старший порт, затем в младший, */
    /* так как запись в младший инициирует физический цикл на IDE-шине */
    for (counter = 0; counter < 12; counter += 2)
    {
        output(hdddathi, packet[counter + 1]); /* Нечетный байт (младший на шине) */
        output(hdddatlo, packet[counter]);     /* Четный байт (старший на шине) */
    }
    enable_interrupt();

    return true;
}

void init(void)
// 1-Evo 2-ATM2 3-ATM3 6-p2.666
{
    unsigned char isAtm;

    printf("Initialising. ");
    isAtm = OS_GETCONFIG();
    switch (isAtm)
    {
    case 2: // ATM2 IDE
    case 3: // ATM3 IDE
        hddstat = 0xFEEF;
        hddcmd = 0xFEEF;
        hddhead = 0xFECF;
        hddcylhi = 0xFEAF;
        hddcyllo = 0xFE8F;
        hddsec = 0xFE6F;
        hddcount = 0xFE4F;
        hdderr = 0xFE2F;
        hdddatlo = 0xFE0F;
        hdddathi = 0xFF0F;
        hddupr = 0xFEBE; //   при установленном b7 FFBA
        hdduprON = 0xFFBA;
        hddupr1 = 0xF7;
        hddupr0 = 0x77;
        puts("ATM IDE selected.");
        break;
    case 1:              // NEMO IDE
    case 6:              // P2666 IDE
        hddstat = 0xF0;  // Регистр состояния
        hddcmd = 0xF0;   // Регистр команд
        hddhead = 0xD0;  // Регистр накопителя/головки
        hddcylhi = 0xB0; // Регистр цилиндра (старшая часть)
        hddcyllo = 0x90; // Регистр цилиндра (младшая часть)
        hddsec = 0x70;   // Регистр номера сектора
        hddcount = 0x50; // Регистр счетчика секторов
        hdderr = 0x30;   // Чтенеие - Регистр ошибки; Запись - Регистр доп. возможностей
        hdddatlo = 0x10; // Регистр данных (младшая часть)
        hdddathi = 0x11; // Регистр данных  (старшая часть)
        hddupr = 0xC8;   // Digital Output
        hdduprON = 0;
        puts("NEMO IDE selected.");
        break;
    default:
        puts("THIS IDE Not IMPLEMENTED");
        waitKey();
        break;
    }

    winPos.winH = 8;
    winPos.winW = 47;
    winPos.winX = 10;
    winPos.winY = 4;
    winPos.color = 103;

    statPos.winH = 3;
    statPos.winW = 47;
    statPos.winX = 25;
    statPos.winY = 16;
    statPos.color = 223;

    set.current_track = 1;
    set.is_playing = 0;
    set.is_paused = 0;
    set.is_foreground = 1;
}

/* Функция чтения TOC с CD-ROM */
char readCdToc(char channel)
{
    unsigned char cmd_read_toc[] = {
        0x43, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x24, 0x00, 0x00, 0x00};

    unsigned char *ptr;
    unsigned int i;
    unsigned int words_to_read = 402;
    unsigned int total_bytes = 0;

    if (!sendAtapiPacket(cmd_read_toc, channel))
    {
        return false;
    }

    if (waitDrq(channel) == 0xFF)
    {
        return false;
    }

    memset(&cd_toc, 0, sizeof(ATAPI_TOC));
    ptr = (unsigned char *)&cd_toc;
    disable_interrupt();
    for (i = 0; i < words_to_read; i++)
    {
        unsigned char low = input(hdddatlo);
        unsigned char high = input(hdddathi);

        /* ИСПРАВЛЕНО: Если структура заполнена ? НЕМЕДЛЕННО выходим из цикла! */
        /* Больше никакого холостого опроса портов, который ломает регистры Z80 */
        if (total_bytes >= sizeof(ATAPI_TOC))
        {
            break;
        }

        *ptr++ = low;
        total_bytes++;

        if (total_bytes < sizeof(ATAPI_TOC))
        {
            *ptr++ = high;
            total_bytes++;
        }

        if ((input(hddstat) & 0x08) == 0)
        {
            break;
        }
    }
    enable_interrupt();
    return true;
}

void displayToc(void)
{
    unsigned char i;
    unsigned char total;

    if (cd_toc.first_track == 0 && cd_toc.last_track == 0)
    {
        printf("TOC is empty or no disc.\n");
        return;
    }

    total = (cd_toc.last_track - cd_toc.first_track) + 1;
    printf("\n--- CD TRACK LIST (Tracks: %u - %u) ---\n", cd_toc.first_track, cd_toc.last_track);
    printf("Num  Type   Start Time (MSF)\n");
    printf("----------------------------\n");

    for (i = 0; i <= total; i++)
    {
        ATAPI_TOC_TRACK *tr = &cd_toc.tracks[i];

        /* Если это последний служебный трек (Lead-Out), он хранит общую длину диска */
        if (tr->track_number == 0xAA)
        {
            printf("Lead-Out:   %02u:%02u:%02u (Total Length)\n", tr->m, tr->s, tr->f);
            break;
        }

        /* Проверяем тип трека: бит 6 в control_adr равен 1 для DATA, 0 для AUDIO */
        if (tr->track_number != 0)
        {
            char *type_str = (tr->control_adr & 0x40) ? "DATA " : "AUDIO";
            printf("Tr %02u [%s]  %02u:%02u:%02u\n", tr->track_number, type_str, tr->m, tr->s, tr->f);
        }
    }
    printf("----------------------------\n");
}

/* Функция запуска воспроизведения трека по его индексу в массиве cd_toc */
char playTrack(unsigned char track_num)
{
    /* ATAPI-команда 0x47 (PLAY AUDIO MSF) */
    unsigned char cmd_play[12] = {0x47, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    unsigned char idx;

    /* Корректируем индекс (в массиве треки идут с нуля) */
    if (track_num < cd_toc.first_track || track_num > cd_toc.last_track)
    {
        return false;
    }
    idx = track_num - cd_toc.first_track;

    /* Задаем стартовую позицию (MSF) */
    cmd_play[3] = cd_toc.tracks[idx].m;
    cmd_play[4] = cd_toc.tracks[idx].s;
    cmd_play[5] = cd_toc.tracks[idx].f;

    /* Задаем конечную позицию (MSF) ? берем начало следующего трека */
    /* Массив гарантированно содержит Lead-Out (0xAA) в конце, так что idx + 1 безопасен */
    cmd_play[6] = cd_toc.tracks[idx + 1].m;
    cmd_play[7] = cd_toc.tracks[idx + 1].s;
    cmd_play[8] = cd_toc.tracks[idx + 1].f;

    /* Шлем пакет на slave-привод */
    return sendAtapiPacket(cmd_play, slave);
}

/* Функция Паузы / Возобновления */
/* mode == 0 -> Pause, mode == 1 -> Resume */
char pauseAudio(unsigned char mode)
{
    /* ATAPI-команда 0x4B (PAUSE/RESUME) */
    /* 8-й байт: 0x00 ? пауза, 0x01 ? продолжить */
    unsigned char cmd_pause[12] = {0x4B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

    cmd_pause[8] = mode ? 0x01 : 0x00;

    return sendAtapiPacket(cmd_pause, slave);
}

char readCdPosition(char channel)
{
    unsigned char cmd_read_sub[] = {
        0x42, 0x02, 0x40, 0x01, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00};

    unsigned char *ptr;
    unsigned int i;
    unsigned int words_to_read = 8; /* 16 байт = 8 слов */
    unsigned int total_bytes = 0;

    /* ИСПРАВЛЕНО: Теперь типы аргументов полностью совместимы */
    if (!sendAtapiPacket(cmd_read_sub, channel))
        return false;
    if (waitDrq(channel) == 0xFF)
        return false;

    memset(&cd_pos, 0, sizeof(ATAPI_SUB_CHANNEL));
    ptr = (unsigned char *)&cd_pos;

    for (i = 0; i < words_to_read; i++)
    {
        unsigned char low = input(hdddatlo);
        unsigned char high = input(hdddathi);

        if (total_bytes < sizeof(ATAPI_SUB_CHANNEL))
        {
            *ptr++ = low;
            total_bytes++;
        }
        if (total_bytes < sizeof(ATAPI_SUB_CHANNEL))
        {
            *ptr++ = high;
            total_bytes++;
        }

        if ((input(hddstat) & 0x08) == 0)
            break;
    }

    return true;
}

void clearWindowBackground(struct coordinates win)
{
    unsigned char q;
    OS_SETCOLOR(win.color);
    for (q = 0; q < win.winH; q++)
    {
        OS_SETXY(win.winX, win.winY + q);
        spaces(win.winW);
    }
}

void drawPlayerFrame(struct coordinates win)
{
    unsigned char q;
    unsigned char sym_tl = 201;
    unsigned char sym_tr = 187;
    unsigned char sym_bl = 200;
    unsigned char sym_br = 188;
    unsigned char sym_h = 205;
    unsigned char sym_v = 186;

    OS_SETCOLOR(win.color);

    /* 1. Верхняя линия рамки */
    OS_SETXY(win.winX - 1, win.winY - 1);
    putchar(sym_tl);
    for (q = 0; q < win.winW; q++)
        putchar(sym_h);
    putchar(sym_tr);

    /* 2. Только боковые вертикальные грани */
    for (q = 0; q < win.winH; q++)
    {
        OS_SETXY(win.winX - 1, win.winY + q);
        putchar(sym_v);
        OS_SETXY(win.winX + win.winW, win.winY + q);
        putchar(sym_v);
    }

    /* 3. Нижняя линия рамки */
    OS_SETXY(win.winX - 1, win.winY + win.winH);
    putchar(sym_bl);
    for (q = 0; q < win.winW; q++)
        putchar(sym_h);
    putchar(sym_br);
}

void drawPlayerStatus(struct coordinates statusWin, unsigned char current_track, unsigned char is_playing, unsigned char is_paused)
{
    unsigned long total_seconds = 0;
    unsigned long current_seconds = 0;
    unsigned char width;
    unsigned char filled;
    unsigned char i;
    unsigned char idx = current_track - cd_toc.first_track;

    if (statusWin.winW > 11)
    {
        width = statusWin.winW - 11;
    }
    else
    {
        width = 10;
    }

    /* РАСЧЕТ ТАЙМИНГОВ (Строго 32-битный) */
    if (cd_toc.first_track != 0 && current_track <= cd_toc.last_track)
    {
        unsigned long start = ((unsigned long)cd_toc.tracks[idx].m * 60) + cd_toc.tracks[idx].s;
        unsigned long end = ((unsigned long)cd_toc.tracks[idx + 1].m * 60) + cd_toc.tracks[idx + 1].s;
        if (end >= start)
        {
            total_seconds = end - start;
        }
    }
    current_seconds = ((unsigned long)cd_pos.rel_m * 60) + cd_pos.rel_s;

    if (total_seconds > 0 && current_seconds <= total_seconds)
    {
        filled = (unsigned char)((current_seconds * width) / total_seconds);
    }
    else
    {
        filled = 0;
    }
    if (filled > width)
        filled = width;

    /* ВЫВОД КОНТЕНТА: Цвета рамок больше не трогаем, пишем поверх фона */
    OS_SETCOLOR(statusWin.color);

    /* Строка 1: Состояние */
    OS_SETXY(statusWin.winX + 2, statusWin.winY);
    printf("Status: %s Track: %02u / %02u",
           is_paused ? "[PAUSE]  " : (is_playing ? "[PLAYING]" : "[STOPPED]"),
           current_track, cd_toc.last_track);

    /* Строка 2: Таймер проигрывания */
    OS_SETXY(statusWin.winX + 2, statusWin.winY + 1);
    printf("Time:   %02u:%02u / %02u:%02u",
           cd_pos.rel_m, cd_pos.rel_s,
           (unsigned int)(total_seconds / 60),
           (unsigned int)(total_seconds % 60));

    /* Строка 3: Шкала воспроизведения блоками 219 */
    OS_SETXY(statusWin.winX + 2, statusWin.winY + 2);
    putchar('[');
    for (i = 0; i < filled; i++)
        putchar(219);
    for (i = filled; i < width; i++)
        putchar('.');
    putchar(']');

    /* Вывод процентов */
    if (total_seconds > 0)
    {
        unsigned int percent = (unsigned int)((current_seconds * 100) / total_seconds);
        if (percent > 100)
            percent = 100;
        printf(" %3u%%", percent);
    }
    else
    {
        printf("   0%%");
    }
}

void printStaticStr(const char *str)
{
    while (*str)
    {
        putchar(*str++);
    }
}

/* Функция запуска воспроизведения с конкретной секунды текущего трека */
char playTrackFromTime(unsigned char track_num, unsigned long current_seconds)
{
    unsigned char cmd_play[12] = {0x47, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    unsigned char idx;
    unsigned long start_abs_sec;
    unsigned long target_abs_sec;

    if (track_num < cd_toc.first_track || track_num > cd_toc.last_track)
    {
        return false;
    }
    idx = track_num - cd_toc.first_track;

    /* Переводим абсолютное время старта трека в секунды */
    start_abs_sec = ((unsigned long)cd_toc.tracks[idx].m * 60) + cd_toc.tracks[idx].s;

    /* Вычисляем целевую абсолютную позицию на диске */
    target_abs_sec = start_abs_sec + current_seconds;

    /* Задаем стартовую точку для привода (MSF) */
    cmd_play[3] = (unsigned char)(target_abs_sec / 60);
    cmd_play[4] = (unsigned char)(target_abs_sec % 60);
    cmd_play[5] = 0; /* Фреймы сбрасываем в 0 */

    /* Конечная точка ? всегда начало следующего трека */
    cmd_play[6] = cd_toc.tracks[idx + 1].m;
    cmd_play[7] = cd_toc.tracks[idx + 1].s;
    cmd_play[8] = cd_toc.tracks[idx + 1].f;

    return sendAtapiPacket(cmd_play, slave);
}

void drawStaticScreen(void)
{
    /* ТЕПЕРЬ ОЧИЩАЕМ ЭКРАН И РИСУЕМ НАЧИСТО ВСЕ СТАТИЧЕСКИЕ ЭЛЕМЕНТЫ */
    OS_CLS(0);

    /* 1. Очищаем фон внутри обоих окон нужными цветами */
    clearWindowBackground(winPos);  /* Цвет 103 */
    clearWindowBackground(statPos); /* Цвет 223 */

    /* 2. Переиспользуем ОДНУ процедуру для отрисовки обоих каркасов рамок! */
    drawPlayerFrame(winPos);
    drawPlayerFrame(statPos);

    OS_SETCOLOR(223);
    OS_SETXY(0, 0);
    spaces(80);
    OS_SETXY(0, 0);
    printf("   Audio CD Player %s", uVer);

    /* Подсказка по кнопкам на самой нижней строке экрана */
    OS_SETCOLOR(223);
    OS_SETXY(0, 23);
    spaces(80);
    OS_SETXY(0, 23);
    printf(" [Space] Pause [S] Stop [T] Reread TOC [1-9] Track [<-][->] FFD/FBD [Q] Quit ");

    /* Первоначальный вывод статуса, чтобы окно не было пустым до старта */
    drawPlayerStatus(statPos, set.current_track, set.is_playing, set.is_paused);
}

/* Главная функция плеера */
void runVisualPlayer(void)
{
    unsigned char start_m = 0;
    unsigned char start_s = 0;
    unsigned char key;
    unsigned char needRedraw = 1;

    unsigned int position_timer = 0;
    unsigned char total_tracks = 0;
    int anim_counter = 0;
    int attempts = 0;

    drawStaticScreen();

    while (!readCdToc(slave))
    {
        int dots, i;
        clearStatus();
        printf("Reading TOC");
        dots = (anim_counter % 3) + 1;
        for (i = 0; i < dots; i++)
        {
            printf(".");
        }

        anim_counter++;

        if (delayLongKey(500) == 27)
        {
            quit();
        }
    }
    clearStatus();
    set.current_track = cd_toc.first_track;
    ui_selected_idx = 0;
    total_tracks = (cd_toc.last_track - cd_toc.first_track) + 1;

    while (42)
    {
        /* 1. ОБРАБОТКА ИНТЕРФЕЙСА */
        if (needRedraw)
        {
            unsigned char q;
            for (q = 0; q < winPos.winH; q++)
            {
                unsigned char current_view_idx = q + ui_scroll_offset;

                /* Встаем строго внутрь рамки */
                OS_SETXY(winPos.winX, winPos.winY + q);

                if (current_view_idx == ui_selected_idx)
                {
                    OS_SETCOLOR(188); /* Инверсия курсора */
                }
                else
                {
                    OS_SETCOLOR(103); /* Обычный цвет */
                }

                if (current_view_idx < total_tracks)
                {
                    ATAPI_TOC_TRACK *tr = &cd_toc.tracks[current_view_idx];

                    /* Локальные переменные для расчета длительности (C89 строго в начале блока) */
                    unsigned long start_sec;
                    unsigned long end_sec;
                    unsigned int duration;
                    unsigned char dur_m;
                    unsigned char dur_s;

                    /* Вычисляем длительность текущего трека в секундах, глядя на время старта следующего */
                    start_sec = ((unsigned long)tr->m * 60) + tr->s;
                    end_sec = ((unsigned long)cd_toc.tracks[current_view_idx + 1].m * 60) + cd_toc.tracks[current_view_idx + 1].s;

                    if (end_sec >= start_sec)
                    {
                        duration = (unsigned int)(end_sec - start_sec);
                    }
                    else
                    {
                        duration = 0;
                    }
                    dur_m = duration / 60;
                    dur_s = duration % 60;

                    /* 1. Печатаем фиксированный префикс */
                    printStaticStr("  Track ");

                    /* Выводим номер трека */
                    putchar((tr->track_number / 10) + '0');
                    putchar((tr->track_number % 10) + '0');

                    /* 2. Печатаем тип трека и компактную метку "Start" вместо "Start Time" */
                    if (tr->control_adr & 0x40)
                    {
                        printStaticStr(" [DATA ]  Start ");
                    }
                    else
                    {
                        printStaticStr(" [AUDIO]  Start ");
                    }

                    /* 3. Выводим таймкод MSF */
                    putchar((tr->m / 10) + '0');
                    putchar((tr->m % 10) + '0');
                    putchar(':');
                    putchar((tr->s / 10) + '0');
                    putchar((tr->s % 10) + '0');
                    putchar(':');
                    putchar((tr->f / 10) + '0');
                    putchar((tr->f % 10) + '0');

                    /* 4. Выводим новую колонку длительности трека */
                    printStaticStr("  Dur ");
                    putchar((dur_m / 10) + '0');
                    putchar((dur_m % 10) + '0');
                    putchar(':');
                    putchar((dur_s / 10) + '0');
                    putchar((dur_s % 10) + '0');

                    /* Суммарная длина текста теперь 48 символов. */
                    /* Добиваем строку пробелами ровно до правой границы winPos.winW */
                    if (winPos.winW > 46)
                    {
                        spaces(winPos.winW - 45);
                    }
                }
                else
                {
                    /* Очищаем пустую строку шириной ровно в winPos.winW */
                    spaces(winPos.winW);
                }

                /* ВОССТАНОВЛЕНИЕ ПРАВОЙ РАМКИ */
                OS_SETCOLOR(103);
                OS_SETXY(winPos.winX + winPos.winW, winPos.winY + q);
                putchar(186); /* sym_v */
            }

            /* Обновляем инфо-панель */
            drawPlayerStatus(statPos, set.current_track, set.is_playing, set.is_paused);
            needRedraw = 0;
        }

        /* 2. НЕБЛОКИРУЮЩИЙ ОПРОС КЛАВИАТУРЫ */
        key = OS_GETKEY();

        if (key != 0)
        {
            if (key == 250 || key == 'A' || key == 'a')
            {
                if (ui_selected_idx > 0)
                {
                    ui_selected_idx--;
                    if (ui_selected_idx < ui_scroll_offset)
                    {
                        ui_scroll_offset--;
                    }
                    needRedraw = 1;
                }
            }
            else if (key == 249 || key == 'B' || key == 'b')
            {
                if (ui_selected_idx < total_tracks - 1)
                {
                    ui_selected_idx++;
                    if (ui_selected_idx >= ui_scroll_offset + winPos.winH)
                    {
                        ui_scroll_offset++;
                    }
                    needRedraw = 1;
                }
            }
            else if (key == 13)
            {
                set.current_track = cd_toc.tracks[ui_selected_idx].track_number;
                if (playTrack(set.current_track))
                {
                    set.is_playing = 1;
                    set.is_paused = 0;
                }
                needRedraw = 1;
            }
            else if (key >= '1' && key <= '9')
            {
                unsigned char selected = key - '0';
                if (selected >= cd_toc.first_track && selected <= cd_toc.last_track)
                {
                    set.current_track = selected;
                    ui_selected_idx = selected - cd_toc.first_track;

                    if (ui_selected_idx < ui_scroll_offset || ui_selected_idx >= ui_scroll_offset + winPos.winH)
                    {
                        ui_scroll_offset = (ui_selected_idx >= winPos.winH) ? (ui_selected_idx - winPos.winH + 1) : 0;
                    }

                    if (playTrack(set.current_track))
                    {
                        set.is_playing = 1;
                        set.is_paused = 0;
                    }
                    needRedraw = 1;
                }
            }
            else if (key == 's' || key == 'S')
            {
                if (sendAtapiPacket(cmd_atapi_stop, slave))
                {
                    set.is_playing = 0;
                    set.is_paused = 0;
                    needRedraw = 1;
                }
            }
            else if (key == ' ')
            {
                if (set.is_playing)
                {
                    if (!set.is_paused)
                    {
                        if (pauseAudio(0))
                            set.is_paused = 1;
                    }
                    else
                    {
                        if (pauseAudio(1))
                            set.is_paused = 0;
                    }
                    needRedraw = 1;
                }
            }
            else if (key == 't' || key == 'T')
            {
                if (readCdToc(slave))
                {
                    set.current_track = cd_toc.first_track;
                    ui_selected_idx = 0;
                    ui_scroll_offset = 0;
                    total_tracks = (cd_toc.last_track - cd_toc.first_track) + 1;
                }
                needRedraw = 1;
            }
            else if (key == 'q' || key == 'Q' || key == 27)
            {
                sendAtapiPacket(cmd_atapi_stop, slave);
                break;
            }
            else if (key == '>' || key == 251)
            {
                /* Перемотка ВПЕРЕД на 15 секунд */
                if (set.is_playing)
                {
                    unsigned long cur_sec;
                    unsigned long total_sec;
                    unsigned char idx = set.current_track - cd_toc.first_track;

                    /* Считаем текущую и максимальную длину трека */
                    cur_sec = ((unsigned long)cd_pos.rel_m * 60) + cd_pos.rel_s;
                    total_sec = (((unsigned long)cd_toc.tracks[idx + 1].m * 60) + cd_toc.tracks[idx + 1].s) -
                                (((unsigned long)cd_toc.tracks[idx].m * 60) + cd_toc.tracks[idx].s);

                    /* Мотаем вперед, если не вылетаем за границы трека */
                    if (cur_sec + 15 < total_sec)
                    {
                        if (playTrackFromTime(set.current_track, cur_sec + 15))
                        {
                            cd_pos.rel_m = (unsigned char)((cur_sec + 15) / 60);
                            cd_pos.rel_s = (unsigned char)((cur_sec + 15) % 60);
                        }
                    }
                    needRedraw = 1;
                }
            }
            else if (key == '<' || key == 248)
            {
                /* Перемотка НАЗАД на 15 секунд */
                if (set.is_playing)
                {
                    unsigned long cur_sec;
                    cur_sec = ((unsigned long)cd_pos.rel_m * 60) + cd_pos.rel_s;

                    if (cur_sec > 15)
                    {
                        if (playTrackFromTime(set.current_track, cur_sec - 15))
                        {
                            cd_pos.rel_m = (unsigned char)((cur_sec - 15) / 60);
                            cd_pos.rel_s = (unsigned char)((cur_sec - 15) % 60);
                        }
                    }
                    else
                    {
                        /* Если от начала трека прошло меньше 15 сек ? прыгаем в самый старт */
                        if (playTrackFromTime(set.current_track, 0))
                        {
                            cd_pos.rel_m = 0;
                            cd_pos.rel_s = 0;
                        }
                    }
                    needRedraw = 1;
                }
            }
            else if (key == 31)
            {
                drawStaticScreen();
                needRedraw = 1;
                set.is_foreground = 1;
            }
        }

        /* 3. ДИНАМИЧЕСКИЙ ОПРОС СОСТОЯНИЯ ПРИВОДА */
        if (set.is_playing && !set.is_paused)
        {
            position_timer++;
            if (position_timer >= 50)
            {
                position_timer = 0;
                if (readCdPosition(slave))
                {
                    if (cd_pos.track_number >= cd_toc.first_track && cd_pos.track_number <= cd_toc.last_track)
                    {
                        /* 1. ОТСЛЕЖИВАНИЕ АВТОМАТИЧЕСКОЙ СМЕНЫ ТРЕКА */
                        if (set.current_track != cd_pos.track_number)
                        {
                            /* Проверяем: если привод ушел в Lead-Out (0xAA) или за предел треков, диск кончился */
                            if (cd_pos.track_number == 0xAA || (cd_pos.track_number - cd_toc.first_track) >= total_tracks)
                            {
                                set.is_playing = 0;
                                set.is_paused = 0;
                                set.current_track = cd_toc.first_track;
                                ui_selected_idx = 0;
                                ui_scroll_offset = 0;
                            }
                            else
                            {
                                /* На диске есть следующий трек ? переключаемся на него */
                                set.current_track = cd_pos.track_number;
                                ui_selected_idx = set.current_track - cd_toc.first_track;

                                /* Автоскроллинг списка */
                                if (ui_selected_idx < ui_scroll_offset || ui_selected_idx >= ui_scroll_offset + winPos.winH)
                                {
                                    if (ui_selected_idx >= winPos.winH)
                                    {
                                        ui_scroll_offset = ui_selected_idx - winPos.winH + 1;
                                    }
                                    else
                                    {
                                        ui_scroll_offset = 0;
                                    }
                                }

                                /* Запускаем законный следующий трек */
                                if (playTrack(set.current_track))
                                {
                                    set.is_playing = 1;
                                    set.is_paused = 0;
                                }
                                else
                                {
                                    set.is_playing = 0;
                                }
                            }

                            needRedraw = 1;
                        }

                        /* 2. ОБРАБОТКА ФИЗИЧЕСКОЙ ОСТАНОВКИ ПРИВОДА */
                        if (cd_pos.audio_status == 0x13 || cd_pos.audio_status == 0x00)
                        {
                            /* Если мы ДО ЭТОГО считали, что плеер играет, но статус стал СТОП */
                            if (set.is_playing)
                            {
                                /* Проверяем, не доиграл ли самый последний трек */
                                if (set.current_track == cd_toc.last_track || cd_pos.track_number == 0xAA)
                                {
                                    /* Диск полностью завершен: сбрасываем статус в STOPPED и выбираем 1-й трек */
                                    set.is_playing = 0;
                                    set.is_paused = 0;
                                    set.current_track = cd_toc.first_track;
                                    ui_selected_idx = 0;
                                    ui_scroll_offset = 0;
                                }
                                else
                                {
                                    /* Если это был промежуточный трек, но привод почему-то встал ?
                                       подстраховываемся и пинаем его играть дальше */
                                    if (playTrack(set.current_track))
                                    {
                                        set.is_playing = 1;
                                        set.is_paused = 0;
                                    }
                                    else
                                    {
                                        set.is_playing = 0;
                                    }
                                }
                                needRedraw = 1;
                            }
                        }
                    }

                    if (cd_pos.audio_status == 0x13 || cd_pos.audio_status == 0x00)
                    {
                        /* Если это последний служебный трек Lead-Out, значит диск кончился */
                        if (cd_pos.track_number == 0xAA || cd_pos.track_number > cd_toc.last_track)
                        {
                            set.is_playing = 0;
                            needRedraw = 1;
                        }
                        else
                        {
                            /* Если привод сообщает СТОП, но трек в границах диска ?
                               пробуем запустить его (на случай если он не запустился выше) */
                            if (playTrack(set.current_track))
                            {
                                set.is_playing = 1;
                                set.is_paused = 0;
                            }
                            else
                            {
                                /* Если запуск не удался (например, диск вынули) ? останавливаем */
                                set.is_playing = 0;
                            }
                            needRedraw = 1;
                        }
                    }
                    if (!needRedraw)
                    {
                        drawPlayerStatus(statPos, set.current_track, set.is_playing, set.is_paused);
                    }
                }
            }
        }

        YIELD();
    }
}

void play3sec(void)
{
}

C_task main(void)
{
    /* 1. Системная инициализация окружения NedoOS / BDOS */
    OS_HIDEFROMPARENT(); /* Скрываем интерфейс родительского процесса */
    OS_SETGFX(0x86);     /* Устанавливаем текстовый режим экрана 80x24 */
    OS_CLS(0);           /* Очищаем экран */
    YIELD();             /* Даем системе обработать переключение режимов */

    init();

    output(hddupr, 0x0C);
    delayInt(15);
    output(hddupr, 0x08);
    delayInt(15);

    /* 2. Запуск нашего визуального плеера */
    runVisualPlayer();

    /* 3. Корректный выход из приложения при закрытии плеера (кнопка Q) */
    quit();
    return 0;
}