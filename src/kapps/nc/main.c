#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <stdlib.h>
#include <oscalls.h>
#include <../common/terminal.c>
#include <osfs.h>
#include <ctype.h>
#include <math.h>
//
#define true 1
#define false 0
#define screenHeight 23
#define screenWidth 80
//---------Цветовое решение-------------
#define BLACK 0
#define BLUE 1
#define RED 2
#define MAGENTA 3
#define GREEN 4
#define CYAN 5
#define YELLOW 6
#define WHITE 7
#define BR_NORMAL 0x00
#define BR_INK 0x40	  // Повышенная яркость тона (6 бит)
#define BR_PAPER 0x80 // Повышенная яркость фона (7 бит)
#define BR_BOTH 0xC0  // Повышенная яркость всего
#define MAKE_COLOR(bright, paper, ink) ((unsigned char)((bright) | ((paper) << 3) | (ink)))
#define COLOR_PANEL_MAIN MAKE_COLOR(BR_BOTH, BLUE, WHITE)	/* Белые буквы на синем фоне */
#define COLOR_PANEL_CURSOR MAKE_COLOR(BR_BOTH, CYAN, BLACK) /* Бирюзовый фон, черный текст */
#define COLOR_STATUS_BAR MAKE_COLOR(BR_BOTH, CYAN, BLACK)	/* Черные кнопки на бирюзовом фоне */
#define COLOR_PANEL_BORDER_ACT MAKE_COLOR(BR_BOTH, BLUE, CYAN)
#define COLOR_PANEL_BORDER_PAS MAKE_COLOR(BR_BOTH, BLUE, CYAN)
//------------------------------------
/* Флаги кнопок */
#define D_BTN_OK 0x01
#define D_BTN_CANCEL 0x02
#define D_BTN_YES 0x04
#define D_BTN_NO 0x01
#define D_BTN_SKIP 0x08
#define D_BTN_SKIP_ALL 0x10
#define D_BTN_REPLACE_ALL 0x20 /* Добавили флаг "Заменить все" */

/* Результаты */
#define D_RES_CANCEL 0
#define D_RES_OK 1
#define D_RES_YES 2
#define D_RES_NO 3
#define D_RES_SKIP 4
#define D_RES_SKIP_ALL 5
#define D_RES_REPLACE_ALL 6 /* Новый код ответа */

//------------------------------------

#define BANK_WINDOW_ADDRESS 0xC000
#define FILES_PER_PAGE 185									   /* Строго сколько элементов влезает в 16 КБ */
#define PAGES_PER_PANEL 3									   /* Фиксировано 3 страницы на панель */
#define MAX_FILES_PER_PANEL (FILES_PER_PAGE * PAGES_PER_PANEL) /* 576 файлов! */

unsigned char uVer[] = "0.1";
unsigned char botMenu[] = "1Drive 2Find 3View 4Edit 5Copy 6Rename 7MkDir 8Delete 9Menu 0Quit";

/* Глобальные статические буферы для рекурсивного копирования (экономим стек) */
static char r_src_full[200];
static char r_dst_full[200];
static fileInfo r_global_info; /* По твоему паттерну из deltree */

typedef struct
{
	unsigned char bank_ids[PAGES_PER_PANEL]; /* Массив из 3 страниц памяти */
	unsigned char bank_id;
	unsigned int file_count;
	unsigned int cursor_idx;
	unsigned int scroll_offset;
	unsigned char is_active;
	char current_path[64];
	unsigned int file_indices[MAX_FILES_PER_PANEL];
	unsigned char file_chars[MAX_FILES_PER_PANEL];
	unsigned char file_is_dir[MAX_FILES_PER_PANEL];
	unsigned char file_sort4[MAX_FILES_PER_PANEL][4];
} PanelState;

PanelState left_panel;
PanelState right_panel;

unsigned char pgbak;
union APP_PAGES main_pg;

struct setup
{
	unsigned char freeMem;
	unsigned char totalMem;
	/* Глобальные буферы для разгрузки стека */
	fileInfo current_file;
	char local_dir_name[64];
	char exited_dir_name[64];
	char temp_path[64];
	fileInfo *bank_array;
} set;

struct coordinates
{
	unsigned char winX;
	unsigned char winY;
	unsigned char winW;
	unsigned char winH;
	unsigned char color;
};

void spaces(unsigned char number)
{
	while (number > 0)
	{
		putchar(' ');
		number--;
	}
}

struct DialogWindow
{
	unsigned char x;
	unsigned char y;
	unsigned char w;
	unsigned char h;
	unsigned char color; /* Объединенный байт цвета (MAKE_COLOR) */
	const char *title;	 /* Оптимизация: теперь просто указатель! */
	const char *prompt;	 /* Текст вопроса/инструкции внутри окна */
};

/* Функция инициализирует структуры и запрашивает банки памяти у ОС */
void init_panels(void)
{
	unsigned char p;

	/* Инициализация левой панели */
	for (p = 0; p < PAGES_PER_PANEL; p++)
	{
		left_panel.bank_ids[p] = OS_NEWPAGE(); /* Запрашиваем 3 страницы */
	}
	left_panel.file_count = 0;
	left_panel.cursor_idx = 0;
	left_panel.scroll_offset = 0;
	left_panel.is_active = 1;
	strcpy(left_panel.current_path, "M:/bin/");

	/* Инициализация правой панели */
	for (p = 0; p < PAGES_PER_PANEL; p++)
	{
		right_panel.bank_ids[p] = OS_NEWPAGE(); /* Запрашиваем 3 страницы */
	}
	right_panel.file_count = 0;
	right_panel.cursor_idx = 0;
	right_panel.scroll_offset = 0;
	right_panel.is_active = 0;
	strcpy(right_panel.current_path, "M:/");
}

void clearStatus(void)
{
	OS_SETCOLOR(5);
	OS_SETXY(0, 24);
	spaces(79);
	putchar('\r');
}

/* 1. Быстрый вывод строки оганиченной длины без дополнения*/
void fast_print_str_width(const char *str, unsigned char width)
{
	unsigned char i;
	i = 0;
	/* Выводим символы строки, пока они есть и не превысили ширину */
	while (str[i] != 0 && i < width)
	{
		putchar(str[i]);
		i++;
	}
}

/**
 * Универсальное диалоговое окно для файлового менеджера
 * @param dlg       - Настройки геометрии и заголовков окна
 * @param buffer    - Внешний буфер для ввода (если NULL - поле ввода скрыто)
 * @param max_len   - Максимальный размер буфера ввода
 * @param btn_mask  - Битовая маска кнопок, которые надо нарисовать
 * @return          - Код выбранного действия (D_RES_xxx)
 */
/**
 * Улучшенное универсальное диалоговое окно для NedoOS (IAR C89)
 */
/**
 * Идеальное универсальное диалоговое окно для NedoOS (IAR C89)
 */
/**
 * Идеально центрированное диалоговое окно для NedoOS (IAR C89)
 */
unsigned char show_dialog(struct DialogWindow *dlg, char *buffer, unsigned char max_len, unsigned char btn_mask)
{
	unsigned char wcount, tempx, titleStart;
	unsigned char byte;

	/* Переменные редактора строки (C89 строго в начале) */
	unsigned char cmdLen;
	unsigned char cursorPos;
	unsigned char viewOffset;
	unsigned char visibleLen;
	unsigned char i;
	unsigned char printPos;

	/* Переменные для управления кнопками и фокусом */
	unsigned char activeBtn;
	unsigned char numButtons;
	unsigned char btn_types[6]; /* Фиксированный размер массива для Z80 */
	unsigned char focusOnButtons;

	/* Переменные для точной центровки кнопок */
	unsigned char totalButtonsWidth;
	unsigned char btnX;
	unsigned char btnY;
	unsigned char inputColor;

	cmdLen = 0;
	cursorPos = 0;
	viewOffset = 0;

	/* Идеальная симметрия: отступ 2 символа слева и 2 символа справа */
	visibleLen = dlg->w - 4;

	/* Формируем контрастный цвет подложки поля ввода */
	inputColor = (unsigned char)(((dlg->color & 0x07) << 3) |
								 ((dlg->color & 0x38) >> 3) |
								 (dlg->color & 0xC0));

	if (buffer != NULL)
	{
		cmdLen = strlen(buffer);
		cursorPos = cmdLen;
		focusOnButtons = 0;
	}
	else
	{
		focusOnButtons = 1;
	}

	/* Собираем массив кнопок */
	numButtons = 0;
	if (btn_mask & D_BTN_YES)
	{
		btn_types[numButtons++] = D_RES_YES;
	}
	if (btn_mask & D_BTN_NO && !(btn_mask & D_BTN_YES))
	{
		btn_types[numButtons++] = D_RES_NO;
	}
	if (btn_mask & D_BTN_OK)
	{
		btn_types[numButtons++] = D_RES_OK;
	}
	if (btn_mask & D_BTN_SKIP)
	{
		btn_types[numButtons++] = D_RES_SKIP;
	}
	if (btn_mask & D_BTN_SKIP_ALL)
	{
		btn_types[numButtons++] = D_RES_SKIP_ALL;
	}
	if (btn_mask & D_BTN_REPLACE_ALL)
	{
		btn_types[numButtons++] = D_RES_REPLACE_ALL;
	}
	if (btn_mask & D_BTN_CANCEL)
	{
		btn_types[numButtons++] = D_RES_CANCEL;
	}

	activeBtn = 0;

	/* Отрисовка геометрии окна через BDBOX */
	OS_SETXY(dlg->x, dlg->y - 1);
	BDBOX(dlg->x, dlg->y, dlg->w + 1, dlg->h + 1, dlg->color, 32);

	/* Верхняя грань рамки */
	OS_SETXY(dlg->x, dlg->y);
	OS_SETCOLOR(dlg->color);
	putchar(201);
	for (wcount = 0; wcount < dlg->w; wcount++)
	{
		putchar(205);
	}
	putchar(187);

	/* Нижняя грань рамки */
	OS_SETXY(dlg->x, dlg->y + dlg->h);
	putchar(200);
	for (wcount = 0; wcount < dlg->w; wcount++)
	{
		putchar(205);
	}
	putchar(188);

	/* Боковые грани */
	tempx = dlg->x + dlg->w + 1;
	for (wcount = 1; wcount < dlg->h; wcount++)
	{
		OS_SETXY(dlg->x, dlg->y + wcount);
		putchar(186);
		OS_SETXY(tempx, dlg->y + wcount);
		putchar(186);
	}

	/* Вывод заголовка окна */
	if (dlg->title != NULL)
	{
		titleStart = dlg->x + (dlg->w / 2) - (strlen(dlg->title) / 2);
		OS_SETXY(titleStart, dlg->y);
		printf("[%s]", dlg->title);
	}

	/* Вывод текста подсказки prompt (Отступ X+2, строка Y+1) */
	if (dlg->prompt != NULL)
	{
		OS_SETXY(dlg->x + 2, dlg->y + 1);
		OS_SETCOLOR(dlg->color);
		fast_print_str_width(dlg->prompt, dlg->w - 2);
	}

	/* ГЛАВНЫЙ ИНТЕРАКТИВНЫЙ ЦИКЛ */
	for (;;)
	{
		/* --- СЕКЦИЯ А: ОТРИСОВКА ПОЛЯ ВВОДА --- */
		if (buffer != NULL)
		{
			if (cursorPos < viewOffset)
			{
				viewOffset = cursorPos;
			}
			else if (cursorPos - viewOffset >= visibleLen)
			{
				viewOffset = cursorPos - visibleLen + 1;
			}

			/* Идеальный симметричный отступ (X+2), строка (Y+3) */
			OS_SETXY(dlg->x + 2, dlg->y + 3);

			for (i = 0; i < visibleLen; i++)
			{
				printPos = viewOffset + i;

				if (focusOnButtons == 0 && printPos == cursorPos)
				{
					OS_SETCOLOR((unsigned char)(((inputColor & 0x40) << 1) |
												((inputColor & 0x07) << 3) |
												((inputColor & 0x80) >> 1) |
												((inputColor & 0x38) >> 3)));
				}
				else
				{
					OS_SETCOLOR(inputColor);
				}

				if (printPos < cmdLen)
				{
					putchar(buffer[printPos]);
				}
				else
				{
					putchar(' ');
				}
			}
			OS_SETCOLOR(dlg->color);
		}

		/* --- СЕКЦИЯ Б: ЦЕНТРОВКА И ОТРИСОВКА КНОПОК --- */
		if (numButtons > 0)
		{
			btnY = dlg->y + dlg->h - 1;

			/* Каждая кнопка занимает ровно 10 символов. Шаг между ними = 11 */
			totalButtonsWidth = (numButtons * 11) - 1;

			/* Динамический стартовый X для идеального центрования */
			btnX = dlg->x + 1 + ((dlg->w - totalButtonsWidth) / 2);

			for (i = 0; i < numButtons; i++)
			{
				OS_SETXY(btnX, btnY);

				if (focusOnButtons == 1 && i == activeBtn)
				{
					/* Инверсия цвета для активной кнопки в NedoOS */
					OS_SETCOLOR((unsigned char)(((dlg->color & 0x40) << 1) | ((dlg->color & 0x07) << 3) |
												((dlg->color & 0x80) >> 1) | ((dlg->color & 0x38) >> 3)));
				}
				else
				{
					OS_SETCOLOR(dlg->color);
				}

				/* Выводим твои новые отцентрированные кнопки (строго 10 символов) */
				switch (btn_types[i])
				{
				case D_RES_OK:
					printf("[   OK   ]");
					break;
				case D_RES_CANCEL:
					printf("[ Cancel ]");
					break;
				case D_RES_YES:
					printf("[  Yes   ]");
					break;
				case D_RES_NO:
					printf("[   No   ]");
					break;
				case D_RES_SKIP:
					printf("[  Skip  ]");
					break;
				case D_RES_SKIP_ALL:
					printf("[Skip All]");
					break;
				case D_RES_REPLACE_ALL:
					printf("[Yes  All]");
					break;
				}

				btnX += 11; /* Сдвиг к следующей кнопке */
			}
			OS_SETCOLOR(dlg->color);
		}

		YIELD();

		/* --- СЕКЦИЯ В: ОБРАБОТКА КЛАВИШ --- */
		byte = OS_GETKEY();
		if (byte != 0)
		{
			switch (byte)
			{
			case 250: /* Стрелка ВВЕРХ */
				if (buffer != NULL && focusOnButtons == 1)
				{
					focusOnButtons = 0;
				}
				break;

			case 249: /* Стрелка ВНИЗ */
				if (numButtons > 0 && focusOnButtons == 0)
				{
					focusOnButtons = 1;
				}
				break;

			case 9: /* TAB */
				if (numButtons > 0)
				{
					if (focusOnButtons == 0)
					{
						focusOnButtons = 1;
						activeBtn = 0;
					}
					else
					{
						activeBtn++;
						if (activeBtn >= numButtons)
						{
							if (buffer != NULL)
								focusOnButtons = 0;
							else
								activeBtn = 0;
						}
					}
				}
				break;

			case 248: /* Стрелка ВЛЕВО */
				if (focusOnButtons == 1)
				{
					if (activeBtn > 0)
						activeBtn--;
					else
						activeBtn = numButtons - 1;
				}
				else if (buffer != NULL && cursorPos > 0)
				{
					cursorPos--;
				}
				break;

			case 251: /* Стрелка ВПРАВО */
				if (focusOnButtons == 1)
				{
					activeBtn = (activeBtn + 1) % numButtons;
				}
				else if (buffer != NULL && cursorPos < cmdLen)
				{
					cursorPos++;
				}
				break;

			case 0x08: /* Backspace */
				if (focusOnButtons == 0 && buffer != NULL && cursorPos > 0 && cmdLen > 0)
				{
					for (i = cursorPos - 1; i < cmdLen; i++)
					{
						buffer[i] = buffer[i + 1];
					}
					cursorPos--;
					cmdLen--;
				}
				break;

			case 252: /* Delete */
				if (focusOnButtons == 0 && buffer != NULL && cursorPos < cmdLen && cmdLen > 0)
				{
					for (i = cursorPos; i < cmdLen; i++)
					{
						buffer[i] = buffer[i + 1];
					}
					cmdLen--;
				}
				break;

			case 0x0d: /* ENTER */
				if (focusOnButtons == 1 && numButtons > 0)
				{
					return btn_types[activeBtn];
				}
				return (buffer != NULL) ? D_RES_OK : btn_types[activeBtn];

			case 27: /* ESC */
				return D_RES_CANCEL;

			default: /* Обычный ввод */
				if (focusOnButtons == 0 && buffer != NULL && cmdLen < (max_len - 2) && byte >= 32)
				{
					for (i = cmdLen; i > cursorPos; i--)
					{
						buffer[i] = buffer[i - 1];
					}
					buffer[cursorPos] = byte;
					cursorPos++;
					cmdLen++;
					buffer[cmdLen] = 0;
				}
				break;
			}
		}
	}
}

void Action_Delete(void)
{
	struct DialogWindow dlg;
	unsigned char result;

	dlg.x = 20;
	dlg.y = 8;
	dlg.w = 40;
	dlg.h = 5;
	dlg.color = MAKE_COLOR(BR_BOTH, RED, WHITE);
	dlg.title = "Delete File";
	dlg.prompt = "Are you sure you want to delete?";

	/* buffer = NULL, маска кнопок Да/Нет */
	result = show_dialog(&dlg, NULL, 0, D_BTN_YES | D_BTN_CANCEL);

	if (result == D_RES_YES)
	{
		/* Логика удаления файла */
	}
}

/* Включает нужную страницу памяти для указанного индекса файла на панели */
void switch_file_page(PanelState *panel, unsigned int file_idx)
{
	/* Вычисляем номер страницы (0, 1 или 2) */
	unsigned char page_num = (unsigned char)(file_idx / FILES_PER_PAGE);

	/* Включаем соответствующий физический банк */
	SETPG32KHIGH(panel->bank_ids[page_num]);
}

/* Основная функция сортировки (вставьте вместо старого кода) */
void read_panel_dir(PanelState *panel)
{
	/* СЕКЦИЯ ОБЪЯВЛЕНИЯ ПЕРЕМЕННЫХ C89 */
	unsigned char result;
	unsigned int idx, i, j, temp_idx;
	unsigned char swap_needed;
	char *name1, *name2;
	char *temp_name;

	unsigned int page_offset;	/* Смещение внутри текущей страницы */
	unsigned char current_page; /* Индекс текущей удерживаемой страницы */

	/* 1. Настраиваемся на чтение первой страницы (индекс 0) */
	current_page = 0;
	SETPG32KHIGH(panel->bank_ids[current_page]);
	set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;

	/* 2. Заходим в папку и открываем её в ОС */
	OS_CHDIR((unsigned char *)panel->current_path);
	OS_OPENDIR("");
	idx = 0;
	panel->file_count = 0;

	/* 3. Цикл последовательного чтения каталога через OS_READDIR */
	while (idx < MAX_FILES_PER_PANEL)
	{
		/* Вычисляем локальный индекс записи внутри текущей страницы памяти */
		page_offset = idx % FILES_PER_PAGE;

		/* Если мы заполнили текущую страницу (дошли до 192), прыгаем на следующую */
		if (idx > 0 && page_offset == 0)
		{
			current_page++;
			if (current_page >= PAGES_PER_PANEL)
				break; /* Страницы кончились */

			SETPG32KHIGH(panel->bank_ids[current_page]);
			/* Указатель set.bank_array остается на 0xC000, но банк памяти уже сменился */
		}

		/* Читаем запись напрямую в новое смещение активного банка */
		result = OS_READDIR(&set.bank_array[page_offset]);
		if (result == 4 || result != 0)
			break;

		/* Пропускаем одиночную точку */
		if (set.bank_array[page_offset].fname[0] == '.' && set.bank_array[page_offset].fname[1] == 0)
			continue;

		/* Фиксируем сквозной индекс */
		panel->file_indices[idx] = idx;
		idx++;
	}
	panel->file_count = idx;
	panel->cursor_idx = 0;
	panel->scroll_offset = 0;

	if (panel->file_count < 2)
		return;

	/* 4. ЗАПОЛНЯЕМ КЭШИ ДЛЯ СОРТИРОВКИ ШЕЛЛА (С ПОДДЕРЖКОЙ СТРАНИЦ) */
	for (idx = 0; idx < panel->file_count; idx++)
	{
		unsigned int real_idx = panel->file_indices[idx];
		char *sort_name;
		unsigned char c, k;

		/* Включаем страницу, на которой лежит физический элемент real_idx */
		switch_file_page(panel, real_idx);
		page_offset = real_idx % FILES_PER_PAGE;

		sort_name = (set.bank_array[page_offset].lfname[0] != 0)
						? (char *)set.bank_array[page_offset].lfname
						: (char *)set.bank_array[page_offset].fname;

		for (k = 0; k < 4; k++)
		{
			c = (unsigned char)sort_name[k];
			if (c >= 'A' && c <= 'Z')
				c = c + ('a' - 'A');
			panel->file_sort4[idx][k] = c;
			if (sort_name[k] == '\0')
				break;
		}
		while (k < 4)
		{
			panel->file_sort4[idx][k++] = 0;
		}

		panel->file_is_dir[idx] = (set.bank_array[page_offset].fattrib & 0x10) ? 1 : 0;
	}

	/* 5. АЛГОРИТМ СОРТИРОВКИ ШЕЛЛА (Адаптирован под динамические переключения страниц) */
	{
		int gap = 13;
		while (gap > 0)
		{
			for (i = gap; i < panel->file_count; i++)
			{
				temp_idx = panel->file_indices[i];
				j = i;
				while (j >= (unsigned int)gap)
				{
					unsigned int prev_idx = panel->file_indices[j - gap];
					swap_needed = 0;

					if (!panel->file_is_dir[prev_idx] && panel->file_is_dir[temp_idx])
					{
						swap_needed = 1;
					}
					else if (panel->file_is_dir[prev_idx] == panel->file_is_dir[temp_idx])
					{
						unsigned char k;
						int cmp = 0;
						for (k = 0; k < 4; k++)
						{
							if (panel->file_sort4[prev_idx][k] > panel->file_sort4[temp_idx][k])
							{
								cmp = 1;
								break;
							}
							else if (panel->file_sort4[prev_idx][k] < panel->file_sort4[temp_idx][k])
							{
								cmp = -1;
								break;
							}
						}

						if (cmp > 0)
						{
							swap_needed = 1;
						}
						else if (cmp == 0)
						{
							unsigned int real_prev = panel->file_indices[j - gap];
							unsigned int real_temp = temp_idx;

							/* ПЕРЕКЛЮЧАЕМ СТРАНИЦУ ДЛЯ СТРОКИ 1 */
							switch_file_page(panel, real_prev);
							page_offset = real_prev % FILES_PER_PAGE;
							name1 = (set.bank_array[page_offset].lfname[0] != 0)
										? (char *)set.bank_array[page_offset].lfname
										: (char *)set.bank_array[page_offset].fname;

							strncpy(set.temp_path, name1, sizeof(set.temp_path) - 1); // Cursos insert here
							set.temp_path[sizeof(set.temp_path) - 1] = '\0';		  // Cursos insert here

							/* ПЕРЕКЛЮЧАЕМ СТРАНИЦУ ДЛЯ СТРОКИ 2 */
							switch_file_page(panel, real_temp);

							if (strcmp(set.temp_path, name2) > 0) // Cursor insert here
								swap_needed = 1;				  // Cursor insert here
							page_offset = real_temp % FILES_PER_PAGE;
							name2 = (set.bank_array[page_offset].lfname[0] != 0)
										? (char *)set.bank_array[page_offset].lfname
										: (char *)set.bank_array[page_offset].fname;

							if (strcmp(name1, name2) > 0)
								swap_needed = 1;
						}
					}

					if (!swap_needed)
						break;
					panel->file_indices[j] = panel->file_indices[j - gap];
					j -= gap;
				}
				panel->file_indices[j] = temp_idx;
			}
			if (gap == 13)
				gap = 4;
			else if (gap == 4)
				gap = 1;
			else
				gap = 0;
		}
	}

	/* Обновляем кэш первой буквы */
	for (idx = 0; idx < panel->file_count; idx++)
	{
		unsigned int real_idx = panel->file_indices[idx];
		switch_file_page(panel, real_idx);
		page_offset = real_idx % FILES_PER_PAGE;

		temp_name = (set.bank_array[page_offset].lfname[0] != 0)
						? (char *)set.bank_array[page_offset].lfname
						: (char *)set.bank_array[page_offset].fname;
		panel->file_chars[idx] = (unsigned char)tolower(temp_name[0]);
	}
}

/* 1. Быстрый вывод строки с фиксированным заполнением пробелами */
void fast_print_str_pad(const char *str, unsigned char width)
{
	unsigned char i;
	i = 0;
	/* Выводим символы строки, пока они есть и не превысили ширину */
	while (str[i] != 0 && i < width)
	{
		putchar(str[i]);
		i++;
	}
	/* Добиваем оставшееся место пробелами */
	while (i < width)
	{
		putchar(' ');
		i++;
	}
}

void fast_print_datetime(unsigned int fdate, unsigned int ftime)
{
	/* Секция переменных C89 строго в начале блока */
	unsigned char day, month, year_short;
	unsigned char hour, minute;

	/* 1. Распаковываем дату FAT */
	day = (unsigned char)(fdate & 0x1F);
	month = (unsigned char)((fdate >> 5) & 0x0F);
	/* Получаем две последние цифры года (из года FAT вычитаем 2000, то есть 18 отнимаем от дельты) */
	year_short = (unsigned char)((((fdate >> 9) & 0x7F) + 1980) % 100);

	/* 2. Распаковываем время FAT */
	minute = (unsigned char)((ftime >> 5) & 0x3F);
	hour = (unsigned char)((ftime >> 11) & 0x1F);

	/* 3. ВЫВОД ДНЯ (2 символа, например: "05" или "31") */
	putchar('0' + (day / 10));
	putchar('0' + (day % 10));

	/* 4. ВЫВОД МЕСЯЦА (2 символа на базе стандарта) */
	switch (month)
	{
	case 1:
		putchar('j');
		putchar('a');
		break;
	case 2:
		putchar('f');
		putchar('b');
		break;
	case 3:
		putchar('m');
		putchar('r');
		break;
	case 4:
		putchar('a');
		putchar('p');
		break;
	case 5:
		putchar('m');
		putchar('y');
		break;
	case 6:
		putchar('j');
		putchar('n');
		break;
	case 7:
		putchar('j');
		putchar('l');
		break;
	case 8:
		putchar('a');
		putchar('g');
		break;
	case 9:
		putchar('s');
		putchar('p');
		break;
	case 10:
		putchar('o');
		putchar('c');
		break;
	case 11:
		putchar('n');
		putchar('v');
		break;
	case 12:
		putchar('d');
		putchar('c');
		break;
	default:
		putchar('?');
		putchar('?');
		break; /* Страховка на случай мусора в FAT */
	}

	/* 5. ВЫВОД ГОДА (2 символа, например: "26") */
	putchar('0' + (year_short / 10));
	putchar('0' + (year_short % 10));

	/* Разделительный пробел перед временем */
	putchar(' ');

	/* 6. ВЫВОД ВРЕМЕНИ ЧЧ:ММ (5 символов) */
	putchar('0' + (hour / 10));
	putchar('0' + (hour % 10));
	putchar(':');
	putchar('0' + (minute / 10));
	putchar('0' + (minute % 10));
}

void fast_print_size(unsigned long size)
{
	unsigned char digit;
	char show_zeros = 0;

	/* РУБЕЖ 3: Если размер 100 МБ или больше (104857600 байт) ? переходим на Гигабайты (G) */
	if (size >= 104857600UL)
	{
		/* Переводим в мегабайты, чтобы работать с числами поменьше */
		unsigned int total_mb = (unsigned int)(size / 1048576UL);
		unsigned int gb_part = total_mb / 1024;
		/* Сотые доли гигабайта: остаток МБ * 100 / 1024 */
		unsigned int rem_gb = (total_mb % 1024) * 100 / 1024;

		/* Выводим целую часть гигабайт (макс 1 знак, например 0.12G или 1.45G) */
		putchar('0' + (unsigned char)gb_part);
		putchar('.');

		/* Выводим сотые доли */
		putchar('0' + (unsigned char)(rem_gb / 10));
		putchar('0' + (unsigned char)(rem_gb % 10));
		putchar('G'); /* Флаг гигабайта */
		putchar(' '); /* Добиваем 6-й символ пробелом для выравнивания */
		return;
	}

	/* РУБЕЖ 2: Если размер от 1 МБ до 99 МБ (1048576 байт) */
	if (size >= 1048576UL)
	{
		unsigned int mb_part = (unsigned int)(size / 1048576UL);
		/* Вычисляем сотые доли мегабайта */
		unsigned int rem_part = (unsigned int)(((size % 1048576UL) * 100UL) / 1048576UL);

		/* Безопасный вывод мегабайт (строго до 99 включительно) */
		if (mb_part >= 10)
			putchar('0' + (unsigned char)(mb_part / 10));
		else
			putchar(' ');
		putchar('0' + (unsigned char)(mb_part % 10));

		putchar('.');

		/* Выводим сотые доли */
		putchar('0' + (unsigned char)(rem_part / 10));
		putchar('0' + (unsigned char)(rem_part % 10));
		putchar('M'); /* Флаг мегабайта */
		return;
	}

	/* РУБЕЖ 1: Для файлов меньше 1 МБ ? классический вывод с подавлением нулей (6 позиций) */
	/* Сто тысяч */
	digit = 0;
	while (size >= 100000UL)
	{
		size -= 100000UL;
		digit++;
	}
	if (digit > 0)
	{
		putchar('0' + digit);
		show_zeros = 1;
	}
	else
	{
		putchar(' ');
	}

	/* Десятки тысяч */
	digit = 0;
	while (size >= 10000UL)
	{
		size -= 10000UL;
		digit++;
	}
	if (digit > 0 || show_zeros)
	{
		putchar('0' + digit);
		show_zeros = 1;
	}
	else
	{
		putchar(' ');
	}

	/* Тысячи */
	digit = 0;
	while (size >= 1000UL)
	{
		size -= 1000UL;
		digit++;
	}
	if (digit > 0 || show_zeros)
	{
		putchar('0' + digit);
		show_zeros = 1;
	}
	else
	{
		putchar(' ');
	}

	/* Сотни */
	digit = 0;
	while (size >= 100UL)
	{
		size -= 100UL;
		digit++;
	}
	if (digit > 0 || show_zeros)
	{
		putchar('0' + digit);
		show_zeros = 1;
	}
	else
	{
		putchar(' ');
	}

	/* Десятки */
	digit = 0;
	while (size >= 10UL)
	{
		size -= 10UL;
		digit++;
	}
	if (digit > 0 || show_zeros)
	{
		putchar('0' + digit);
		show_zeros = 1;
	}
	else
	{
		putchar(' ');
	}

	/* Единицы */
	putchar('0' + (unsigned char)size);
}

void fast_put_char_color(unsigned char x, unsigned char y, unsigned char sym, unsigned char color)
{
	/* Задаем координаты и цвет напрямую через ваши системные вызовы */
	OS_SETXY(x, y);
	OS_SETCOLOR(color);
	putchar(sym);
}

void draw_single_line(PanelState *panel, unsigned int file_idx, unsigned char start_x, unsigned char row_y)
{
	unsigned int real_bank_idx;
	unsigned int page_offset;
	char *display_name;
	unsigned char current_color;
	unsigned char sym_v_single = 179;

	if (file_idx < panel->file_count)
	{
		real_bank_idx = panel->file_indices[file_idx];

		/* 1. СНАЧАЛА включаем нужную банку памяти и считываем все данные */
		switch_file_page(panel, real_bank_idx);
		page_offset = real_bank_idx % FILES_PER_PAGE;

		display_name = (set.bank_array[page_offset].lfname[0] != 0)
						   ? (char *)set.bank_array[page_offset].lfname
						   : (char *)set.bank_array[page_offset].fname;

		/* 2. СТРОГО ПОСЛЕ ПЕРЕКЛЮЧЕНИЯ СТРАНИЦЫ позиционируем курсор экрана! */
		OS_SETXY(start_x + 1, 3 + row_y);

		current_color = (file_idx == panel->cursor_idx && panel->is_active) ? COLOR_PANEL_CURSOR : COLOR_PANEL_MAIN;
		OS_SETCOLOR(current_color);

		/* ИМЯ ФАЙЛА ? Выводим строго 18 символов */
		fast_print_str_pad(display_name, 18);

		/* Первый разделитель */
		if (file_idx == panel->cursor_idx && panel->is_active)
		{
			putchar(sym_v_single);
		}
		else
		{
			OS_SETCOLOR(MAKE_COLOR(BR_BOTH, BLUE, CYAN));
			putchar(sym_v_single);
			OS_SETCOLOR(COLOR_PANEL_MAIN);
		}

		/* РАЗМЕР ИЛИ КАТАЛОГ ? Выводим строго 6 символов */
		if (set.bank_array[page_offset].fattrib & 0x10)
		{
			fast_print_str_pad(" <DIR>", 6);
		}
		else
		{
			fast_print_size(set.bank_array[page_offset].fsize);
		}

		/* Второй разделитель */
		if (file_idx == panel->cursor_idx && panel->is_active)
		{
			putchar(sym_v_single);
		}
		else
		{
			OS_SETCOLOR(MAKE_COLOR(BR_BOTH, BLUE, CYAN));
			putchar(sym_v_single);
			OS_SETCOLOR(COLOR_PANEL_MAIN);
		}

		/* ДАТА И ВРЕМЯ ? Выводим стандартные 12 символов */
		fast_print_datetime(set.bank_array[page_offset].fdate, set.bank_array[page_offset].ftime);

		OS_SETCOLOR(COLOR_PANEL_MAIN);
	}
	else
	{
		/* Для пустых строк переключение банков не нужно, но позицию всё равно ставим */
		OS_SETXY(start_x + 1, 3 + row_y);

		OS_SETCOLOR(COLOR_PANEL_MAIN);
		fast_print_str_pad("", 18);
		OS_SETCOLOR(MAKE_COLOR(BR_BOTH, BLUE, CYAN));
		putchar(sym_v_single);
		OS_SETCOLOR(COLOR_PANEL_MAIN);
		fast_print_str_pad("", 6);
		OS_SETCOLOR(MAKE_COLOR(BR_BOTH, BLUE, CYAN));
		putchar(sym_v_single);
		OS_SETCOLOR(COLOR_PANEL_MAIN);
		fast_print_str_pad("", 12);
	}
}

void draw_bottom_info(PanelState *active_p)
{
	unsigned int real_idx;
	unsigned int page_offset;
	char *full_name;
	unsigned long f_size;
	unsigned char is_dir;

	real_idx = active_p->file_indices[active_p->cursor_idx];

	/* Включаем правильную страницу */
	switch_file_page(active_p, real_idx);
	page_offset = real_idx % FILES_PER_PAGE;

	full_name = (set.bank_array[page_offset].lfname[0] != 0) ? (char *)set.bank_array[page_offset].lfname : (char *)set.bank_array[page_offset].fname;

	f_size = set.bank_array[page_offset].fsize;
	is_dir = (set.bank_array[page_offset].fattrib & 0x10) ? 1 : 0;

	OS_SETCOLOR(MAKE_COLOR(BR_BOTH, BLACK, WHITE));
	OS_SETXY(0, 22);

	fast_print_str_pad("Sz:", 3);
	if (is_dir)
	{
		fast_print_str_pad("<DIR>", 10);
	}
	else
	{
		fast_print_size(f_size);
		putchar(' ');
		putchar(' ');
		putchar(' ');
	}

	fast_print_str_pad("Nm:", 3);
	fast_print_str_pad(full_name, 64);
}

void draw_panel_frame(unsigned char start_x, unsigned char color)
{
	unsigned char q;
	unsigned char sym_tl = 201;
	unsigned char sym_tr = 187;
	unsigned char sym_bl = 200;
	unsigned char sym_br = 188;
	unsigned char sym_h = 205;
	unsigned char sym_v = 186;

	/* Обе панели имеют одинаковую ширину рамки: 39 символов от старта */
	unsigned char width = 39;

	/* 1. Верхняя линия рамки */
	fast_put_char_color(start_x, 0, sym_tl, color);
	for (q = 1; q < width; q++)
	{
		fast_put_char_color(start_x + q, 0, sym_h, color);
	}
	fast_put_char_color(start_x + width, 0, sym_tr, color);

	/* 2. Боковые вертикальные грани */
	for (q = 1; q <= 21; q++)
	{
		fast_put_char_color(start_x, q, sym_v, color);
		fast_put_char_color(start_x + width, q, sym_v, color);
	}

	/* 3. Нижняя линия рамки */
	fast_put_char_color(start_x, 21, sym_bl, color);
	for (q = 1; q < width; q++)
	{
		fast_put_char_color(start_x + q, 21, sym_h, color);
	}
	fast_put_char_color(start_x + width, 21, sym_br, color);
}

void draw_panel_background(PanelState *panel, unsigned char start_x)
{
	int i;
	/* 1. Рисуем рамку */
	draw_panel_frame(start_x, COLOR_PANEL_MAIN);

	/* 2. Заголовок пути сверху */
	OS_SETCOLOR(COLOR_PANEL_MAIN);
	OS_SETXY(start_x + 2, 0);
	putchar('[');
	putchar(' ');
	i = 0;
	while (panel->current_path[i] != 0)
	{
		putchar(panel->current_path[i]);
		i++;
	}
	putchar(' ');
	putchar(']');

	/* 3. ТЕКСТОВЫЕ ЗАГОЛОВКИ КОЛОНОК (Строка 1 на экране) */
	OS_SETXY(start_x + 1, 1);
	OS_SETCOLOR(MAKE_COLOR(BR_BOTH, BLUE, CYAN));

	/* Выводим шапку по кускам, гарантируя точность до символа */
	fast_print_str_pad("Name", 18);
	putchar(179);
	fast_print_str_pad("Size", 6);
	putchar(179);
	fast_print_str_pad(" Date/Time", 12);

	/* 4. Горизонтальный разделитель шапки (Строка 2 на экране) */
	OS_SETXY(start_x + 1, 2);
	OS_SETCOLOR(COLOR_PANEL_MAIN);
	for (i = 0; i < 38; i++)
	{
		putchar(196);
	}
}

void draw_panel(PanelState *panel, unsigned char start_x, unsigned char height)
{
	unsigned char i;
	for (i = 0; i < height; i++)
	{
		/* Теперь передаем start_x и номер строки i напрямую в функцию строки */
		draw_single_line(panel, panel->scroll_offset + i, start_x, i);
	}
}

/* Функция рисует нижний статус бар с подсказками кнопок */
void draw_status_bar(void)
{
	OS_SETCOLOR(COLOR_STATUS_BAR);
	OS_SETXY(0, 23);
	fast_print_str_pad(botMenu, 80);
}

void redraw_all(void)
{
	draw_panel(&left_panel, 0, 18); /* Обновляет только списки файлов и курсор */
	draw_panel(&right_panel, 40, 18);
	draw_status_bar();
}

void draw_file_line(PanelState *panel, unsigned char start_x, unsigned int file_idx)
{
	/* Вычисляем, на какой строчке внутри панели (0-17) физически находится файл */
	unsigned char row_y = (unsigned char)(file_idx - panel->scroll_offset);
	/* Больше не вызываем здесь OS_SETXY до переключения страниц! */
	/* Передаем координаты напрямую в draw_single_line */
	draw_single_line(panel, file_idx, start_x, row_y);
}

unsigned char getFreeMem(void)
{
	unsigned char freeMem = 0, counter;
	for (counter = 0; counter < set.totalMem; counter++)
	{
		unsigned char owner;
		owner = OS_GETPAGEOWNER(~counter);
		if (owner == 0)
		{
			freeMem++;
		}
	}
	return freeMem - 8;
}

int ext_cmp(const char *s1, const char *s2)
{
	while (*s1 && (tolower((unsigned char)*s1) == tolower((unsigned char)*s2)))
	{
		s1++;
		s2++;
	}
	return tolower((unsigned char)*s1) - tolower((unsigned char)*s2);
}

void handle_enter(PanelState *active_p)
{
	unsigned int real_idx;
	char *dir_name;
	char *ext;
	char *n;
	int len;
	unsigned int page_offset;

	OS_CHDIR((unsigned char *)active_p->current_path);

	real_idx = active_p->file_indices[active_p->cursor_idx];
	switch_file_page(active_p, real_idx);
	page_offset = real_idx % FILES_PER_PAGE;

	set.current_file = ((fileInfo *)BANK_WINDOW_ADDRESS)[page_offset];

	if (set.current_file.fattrib & 0x10)
	{
		dir_name = (set.current_file.lfname[0] != 0) ? (char *)set.current_file.lfname : (char *)set.current_file.fname;
		strcpy(set.local_dir_name, dir_name);

		if (set.local_dir_name[0] == '.' && set.local_dir_name[1] == '.')
		{
			char truncated = 0;
			int scan_len;
			len = strlen(active_p->current_path);
			if (len > 3 && active_p->current_path[len - 1] == '/')
			{
				active_p->current_path[len - 1] = 0;
				len--;
			}
			scan_len = len;
			set.exited_dir_name[0] = 0;
			while (scan_len > 2)
			{
				scan_len--;
				if (active_p->current_path[scan_len] == '/')
				{
					strcpy(set.exited_dir_name, &active_p->current_path[scan_len + 1]);
					break;
				}
			}
			while (len > 2)
			{
				len--;
				if (active_p->current_path[len] == '/')
				{
					active_p->current_path[len] = 0;
					truncated = 1;
					break;
				}
			}
			if (!truncated || strlen(active_p->current_path) <= 2)
			{
				strcpy(active_p->current_path, "M:/");
			}

			read_panel_dir(active_p);

			if (set.exited_dir_name[0] != 0)
			{
				unsigned int search_idx;
				for (search_idx = 0; search_idx < active_p->file_count; search_idx++)
				{
					unsigned int r_idx = active_p->file_indices[search_idx];
					switch_file_page(active_p, r_idx);
					page_offset = r_idx % FILES_PER_PAGE;

					n = (set.bank_array[page_offset].lfname[0] != 0) ? (char *)set.bank_array[page_offset].lfname : (char *)set.bank_array[page_offset].fname;
					if (strcmp(n, set.exited_dir_name) == 0)
					{
						active_p->cursor_idx = search_idx;
						if (active_p->cursor_idx >= 18)
						{
							active_p->scroll_offset = active_p->cursor_idx - 18 + 1;
						}
						break;
					}
				}
			}
		}
		else
		{
			len = strlen(active_p->current_path);
			if (active_p->current_path[len - 1] != '/')
			{
				strcat(active_p->current_path, "/");
			}
			strcat(active_p->current_path, set.local_dir_name);
			read_panel_dir(active_p);
		}

		/* ИСПРАВЛЕНИЕ: Перед отрисовкой принудительно возвращаем страницу */
		/* первой видимой строчки на панели, чтобы draw_panel не читал мусор */
		if (active_p->file_count > 0)
		{
			switch_file_page(active_p, active_p->file_indices[active_p->scroll_offset]);
		}

		draw_panel_background(active_p, (left_panel.is_active) ? 0 : 40);
		draw_panel(active_p, (left_panel.is_active) ? 0 : 40, 18);
		return;
	}

	/* Секция файлов */
	ext = strrchr(set.current_file.fname, '.');
	if (ext != NULL)
	{
		ext++;
		if (ext_cmp(ext, "com") == 0 || ext_cmp(ext, "bin") == 0)
		{
		}
		else if (ext_cmp(ext, "txt") == 0 || ext_cmp(ext, "c") == 0)
		{
		}
	}
}

/* Умное обновление панелей, готовое к будущему выделению файлов.
 * @param next_file_hint - Имя файла, на который МЫ ХОТИМ поставить курсор.
 *                         Если NULL или файл не найден ? встанет на первый файл.
 */

void panels_refresh_all(const char *next_file_hint)
{
	/* --- СЕКЦИЯ ОБЪЯВЛЕНИЯ ПЕРЕМЕННЫХ C89 --- */
	PanelState *active_p;
	unsigned int search_idx;
	unsigned char found;
	unsigned int page_offset;
	char *current_name;

	/* 1. Определяем активную панель */
	active_p = (left_panel.is_active) ? &left_panel : &right_panel;

	/* 2. ПЕРЕЧИТЫВАЕМ ОБЕ ПАНЕЛИ С ДИСКА */
	read_panel_dir(&left_panel);
	read_panel_dir(&right_panel);

	/* 3. ИЩЕМ ФАЙЛ ПО НАШЕЙ ПОДСКАЗКЕ (HINT) */
	found = false;
	if (next_file_hint != NULL && active_p->file_count > 0)
	{
		for (search_idx = 0; search_idx < active_p->file_count; search_idx++)
		{
			unsigned int r_idx = active_p->file_indices[search_idx];
			switch_file_page(active_p, r_idx);
			page_offset = r_idx % FILES_PER_PAGE;

			current_name = (set.bank_array[page_offset].lfname[0] != 0)
							   ? (char *)set.bank_array[page_offset].lfname
							   : (char *)set.bank_array[page_offset].fname;

			if (strcmp(current_name, next_file_hint) == 0)
			{
				active_p->cursor_idx = search_idx;
				found = true;
				break;
			}
		}
	}

	/* 4. ЕСЛИ ПОДСКАЗКА НЕ СРАБОТАЛА ? СБРАСЫВАЕМ НА НАЧАЛО СПИСКА */
	if (!found)
	{
		active_p->cursor_idx = 0; /* Встаем на первый файл в папке */
	}

	/* 5. КОРРЕКЦИЯ СКРОЛЛИНГА (ПРОКРУТКИ ОКНА) */
	if (active_p->cursor_idx < active_p->scroll_offset)
	{
		active_p->scroll_offset = active_p->cursor_idx;
	}
	else if (active_p->cursor_idx >= active_p->scroll_offset + 18)
	{
		active_p->scroll_offset = active_p->cursor_idx - 18 + 1;
	}

	/* 6. СТРАХОВКА БАНКОВ ПАМЯТИ ПЕРЕД НАЧАЛОМ ОТРИСОВКИ */
	if (left_panel.file_count > 0)
	{
		switch_file_page(&left_panel, left_panel.file_indices[left_panel.scroll_offset]);
	}
	if (right_panel.file_count > 0)
	{
		switch_file_page(&right_panel, right_panel.file_indices[right_panel.scroll_offset]);
	}

	/* 7. ПОЛНАЯ ПЕРЕРИСОВКА ЭКРАНА */
	draw_panel_background(&left_panel, 0);
	draw_panel_background(&right_panel, 40);

	draw_panel(&left_panel, 0, 18);
	draw_panel(&right_panel, 40, 18);

	draw_bottom_info(active_p);
	draw_status_bar();
}

/**
 * Надежная функция склеивания путей под NedoOS
 */
void build_full_path(char *dest, const char *path, const char *filename)
{
	unsigned int len;
	strcpy(dest, path);
	len = strlen(dest);

	/* Если путь не пустой и не заканчивается на слэш ? принудительно добавляем */
	if (len > 0 && dest[len - 1] != '/' && dest[len - 1] != '\\')
	{
		strcat(dest, "/");
	}
	strcat(dest, filename);
}

/**
 * Вспомогательная функция поблочного копирования одного файла
 */
unsigned char copy_single_file_core(const char *src_path, const char *dst_path)
{
	FILE *h_src;
	FILE *h_dst;
	unsigned int bytes_read;
	unsigned int bytes_written;
	unsigned long original_size;
	unsigned int len;
	static unsigned char c_buf[512];

	h_src = OS_OPENHANDLE((unsigned char *)src_path, 0x80);
	if (((int)h_src) & 0xff)
		return 1;

	original_size = OS_GETFILESIZE(h_src);

	h_dst = OS_CREATEHANDLE((unsigned char *)dst_path, 0x80);
	if (((int)h_dst) & 0xff)
	{
		OS_CLOSEHANDLE(h_src);
		return 1;
	}

	for (;;)
	{
		bytes_read = OS_READHANDLE(c_buf, h_src, 512);
		if (bytes_read == 0 || (((int)bytes_read) & 0xff))
			break;

		if (bytes_read < 512)
		{
			for (len = bytes_read; len < 512; len++)
				c_buf[len] = 0;
			OS_WRITEHANDLE(c_buf, h_dst, 512);
			break;
		}

		bytes_written = OS_WRITEHANDLE(c_buf, h_dst, bytes_read);
		if (bytes_written != bytes_read || (((int)bytes_written) & 0xff))
			break;
		YIELD();
	}

	OS_SEEKHANDLE(h_dst, original_size);
	OS_CLOSEHANDLE(h_dst);
	OS_CLOSEHANDLE(h_src);
	return 0;
}

/**
 * Рекурсивный обход папки с защитой от зацикливания через индексный сдвиг
 * (C89, сохраняет стек Z80)
 */
void copy_tree_recursive(const char *base_src, const char *base_dst)
{
	/* Локальные переменные текущего уровня рекурсии (всего несколько байт в стеке!) */
	char local_name[64];
	char is_dir;
	unsigned int target_file_idx; /* Порядковый номер файла, который мы хотим прочитать */
	unsigned int skip_counter;	  /* Счетчик для промотки потока FAT */
	unsigned char res;
	unsigned char found_valid_item;

	target_file_idx = 0;

	while (1)
	{
		/* Шаг 1: Принудительно возвращаемся в исходную папку текущего уровня */
		if (OS_CHDIR((unsigned char *)base_src) != 0)
			return;

		/* Шаг 2: Инициализируем поток чтения каталога с самого начала */
		OS_OPENDIR("");
		skip_counter = 0;
		found_valid_item = 0;

		/* Шаг 3: Проматываем поток до нужного нам индекса файла */
		while (1)
		{
			res = OS_READDIR(&r_global_info);
			if (res == 4 || res != 0)
				break; /* Каталог закончился */

			/* Пропускаем служебные точки FAT */
			if (r_global_info.fname[0] == '.')
			{
				if (r_global_info.fname[1] == 0 || (r_global_info.fname[1] == '.' && r_global_info.fname[2] == 0))
				{
					continue;
				}
			}

			/* Если мы дошли до нужного по счету несанкционированного файла */
			if (skip_counter == target_file_idx)
			{
				/* Забираем его данные в локальный буфер этого уровня стека */
				if (r_global_info.lfname[0] != 0)
				{
					strcpy(local_name, (char *)r_global_info.lfname);
				}
				else
				{
					strcpy(local_name, (char *)r_global_info.fname);
				}

				is_dir = (r_global_info.fattrib & 0x10) ? 1 : 0;
				found_valid_item = 1;
				break; /* Файл успешно захвачен */
			}

			skip_counter++; /* Пропускаем уже скопированные ранее файлы */
		}

		/* Если на данном индексе файлы кончились ? значит папка полностью скопирована! */
		if (!found_valid_item)
			break;

		/* Переходим к следующему файлу на будущей итерации */
		target_file_idx++;

		/* Шаг 4: Формируем полные пути */
		build_full_path(r_src_full, base_src, local_name);
		build_full_path(r_dst_full, base_dst, local_name);

		/* ТЕКСТОВЫЙ ИНДИКАТОР ПРОГРЕССА (Строка 22) */
		OS_SETCOLOR(MAKE_COLOR(BR_BOTH, BLACK, WHITE));
		OS_SETXY(0, 22);
		fast_print_str_pad("Copying...", 11);
		fast_print_str_pad(local_name, 64);

		/* Шаг 5: Выполняем копирование в зависимости от типа */
		if (is_dir)
		{
			/* Создаем подпапку на диске-приемнике */
			OS_MKDIR((unsigned char *)r_dst_full);

			/* Рекурсивно ныряем внутрь созданной структуры */
			copy_tree_recursive(r_src_full, r_dst_full);
		}
		else
		{
			/* Копируем обычный файл через наш отлаженный посекторный движок */
			copy_single_file_core(r_src_full, r_dst_full);
		}

		YIELD(); /* Уступаем квант времени операционной системе NedoOS */
	}

	/* Выходим из текущей обработанной папки на уровень вверх */
	OS_CHDIR((unsigned char *)"..");
}

/**
 * Высокоуровневая точка входа для копирования файлов и папок
 */
void Action_Copy(void)
{
	/* --- СЕКЦИЯ ОБЪЯВЛЕНИЯ ПЕРЕМЕННЫХ C89 СТРОГО В НАЧАЛЕ БЛОКА --- */
	struct DialogWindow dlg;
	PanelState *src_panel;
	PanelState *dst_panel;
	unsigned int real_idx;
	unsigned int page_offset;
	char *src_filename_ptr;
	unsigned char dialog_result;
	unsigned int len;
	unsigned char is_directory;

	/* Статические буферы для изоляции путей */
	static char saved_filename[64];
	static char full_src_path[200];
	static char full_dst_path[200];

	src_panel = (left_panel.is_active) ? &left_panel : &right_panel;
	dst_panel = (left_panel.is_active) ? &right_panel : &left_panel;

	if (src_panel->file_count == 0)
		return;

	/* 1. ПОЛУЧАЕМ ИМЯ И АТРИБУТЫ ВЫБРАННОГО ЭЛЕМЕНТА */
	real_idx = src_panel->file_indices[src_panel->cursor_idx];
	switch_file_page(src_panel, real_idx);
	page_offset = real_idx % FILES_PER_PAGE;

	is_directory = (set.bank_array[page_offset].fattrib & 0x10) ? 1 : 0;
	src_filename_ptr = (set.bank_array[page_offset].lfname[0] != 0)
						   ? (char *)set.bank_array[page_offset].lfname
						   : (char *)set.bank_array[page_offset].fname;

	/* Защита от копирования перехода наверх */
	if (is_directory && src_filename_ptr[0] == '.' && src_filename_ptr[1] == '.')
		return;

	strncpy(saved_filename, src_filename_ptr, sizeof(saved_filename) - 1);
	saved_filename[sizeof(saved_filename) - 1] = '\0';

	/* 2. НАСТРОЙКА И ВЫЗОВ НАШЕГО СИММЕТРИЧНОГО ДИАЛОГА */
	dlg.x = 10;
	dlg.y = 7;
	dlg.w = 60;
	dlg.h = 7;
	dlg.color = MAKE_COLOR(BR_BOTH, BLUE, WHITE);
	dlg.title = is_directory ? "Copy Directory" : "Copy File";
	dlg.prompt = "Copy to path:";

	strncpy(set.temp_path, dst_panel->current_path, sizeof(set.temp_path) - 1);
	set.temp_path[sizeof(set.temp_path) - 1] = '\0';

	len = strlen(set.temp_path);
	if (len > 0 && set.temp_path[len - 1] != '/' && set.temp_path[len - 1] != '\\')
	{
		strcat(set.temp_path, "/");
	}

	dialog_result = show_dialog(&dlg, set.temp_path, sizeof(set.temp_path), D_BTN_OK | D_BTN_CANCEL);
	if (dialog_result == D_RES_CANCEL)
	{
		panels_refresh_all(saved_filename);
		return;
	}

	/* 3. СБОРКА СТАРТОВЫХ ПОЛНЫХ ПУТЕЙ */
	build_full_path(full_src_path, src_panel->current_path, saved_filename);
	build_full_path(full_dst_path, set.temp_path, saved_filename);

	/* 4. ЗАПУСК ОПЕРАЦИИ */
	if (is_directory)
	{
		/* Сначала создаем корневую папку на приемнике */
		OS_MKDIR((unsigned char *)full_dst_path);

		/* Запускаем умный рекурсивный обход внутренностей */
		copy_tree_recursive(full_src_path, full_dst_path);
	}
	else
	{
		/* Копирование одиночного файла */
		OS_SETCOLOR(MAKE_COLOR(BR_BOTH, BLACK, WHITE));
		OS_SETXY(0, 22);
		fast_print_str_pad("Copying file:", 14);
		fast_print_str_pad(saved_filename, 64);

		copy_single_file_core(full_src_path, full_dst_path);
	}

	/* 5. ВОЗВРАЩАЕМ СИСТЕМНЫЙ КАТАЛОГ И ОБНОВЛЯЕМ ЭКРАН */
	OS_CHDIR((unsigned char *)src_panel->current_path);
	panels_refresh_all(saved_filename);
}

void init(void)
{
	main_pg.l = OS_GETMAINPAGES();
	pgbak = main_pg.pgs.window_3;
	OS_DELPAGE(pgbak);
	set.freeMem = getFreeMem();
}

C_task main(int argc, const char *argv[])
{
	OS_HIDEFROMPARENT();
	OS_SETGFX(0x86);
	OS_CLS(0);
	OS_SETSYSDRV();
	printf("[Build:%s %s]\r\n", __DATE__, __TIME__);
	os_initstdio();

	/* Привязываем глобальный указатель к окну проецирования банков */
	set.bank_array = (fileInfo *)BANK_WINDOW_ADDRESS;

	init_panels();

	read_panel_dir(&left_panel);
	read_panel_dir(&right_panel);
	OS_CLS(0);

	draw_panel_background(&left_panel, 0);
	draw_panel_background(&right_panel, 40);
	draw_panel(&left_panel, 0, 18);
	draw_panel(&right_panel, 40, 18);
	;
	draw_status_bar();

	/* Первичный вывод имен внизу рамок при старте приложения */
	draw_bottom_info(&left_panel);

	while (1)
	{
		unsigned char key;
		PanelState *active_p;
		active_p = (left_panel.is_active) ? &left_panel : &right_panel;

		key = OS_GETKEY();
		// printf("[key = %u]", key);
		switch (key)
		{
		case 0:
			YIELD();
			continue;
		case 27:
		case 176:
			exit(0);
			break;
		case '8':
			Action_Delete();
			panels_refresh_all(NULL);
			break;
		case '5':
			Action_Copy();
			break;
		}

		/* TAB (9): Переключение активной панели */
		if (key == 9)
		{
			left_panel.is_active = !left_panel.is_active;
			right_panel.is_active = !right_panel.is_active;
			redraw_all();
			/* Обновляем инфо-строку для новой активной панели */
			draw_bottom_info(active_p);
			continue;
		}

		/* Движение курсора ВВЕРХ (250) */
		if (key == 250)
		{
			if (active_p->cursor_idx > 0)
			{
				unsigned int old_idx = active_p->cursor_idx;
				unsigned int old_scroll = active_p->scroll_offset;
				unsigned char start_x = (left_panel.is_active) ? 0 : 40;

				active_p->cursor_idx--;
				if (active_p->cursor_idx < active_p->scroll_offset)
				{
					active_p->scroll_offset = active_p->cursor_idx;
				}
				if (active_p->scroll_offset != old_scroll)
				{
					draw_panel(active_p, start_x, 18);
				}
				else
				{
					draw_file_line(active_p, start_x, old_idx);
					draw_file_line(active_p, start_x, active_p->cursor_idx);
				}
				/* Обновляем длинное имя внизу рамки */
				draw_bottom_info(active_p);
			}
			continue;
		}

		/* Движение курсора ВНИЗ (249) */
		if (key == 249)
		{
			if (active_p->cursor_idx + 1 < active_p->file_count)
			{
				unsigned int old_idx = active_p->cursor_idx;
				unsigned int old_scroll = active_p->scroll_offset;
				unsigned char start_x = (left_panel.is_active) ? 0 : 40;

				active_p->cursor_idx++;
				if (active_p->cursor_idx >= active_p->scroll_offset + 18)
				{
					active_p->scroll_offset = active_p->cursor_idx - 18 + 1;
				}
				if (active_p->scroll_offset != old_scroll)
				{
					draw_panel(active_p, start_x, 18);
				}
				else
				{
					draw_file_line(active_p, start_x, old_idx);
					draw_file_line(active_p, start_x, active_p->cursor_idx);
				}
				/* Обновляем длинное имя внизу рамки */
				draw_bottom_info(active_p);
			}
			continue;
		}

		/* PAGE UP / ВЛЕВО (248) */
		if (key == 248)
		{
			if (active_p->cursor_idx > 0)
			{
				unsigned int old_scroll = active_p->scroll_offset;
				unsigned char start_x = (left_panel.is_active) ? 0 : 40;

				if (active_p->cursor_idx >= 18)
				{
					active_p->cursor_idx -= 18;
				}
				else
				{
					active_p->cursor_idx = 0;
				}
				if (active_p->cursor_idx < active_p->scroll_offset)
				{
					active_p->scroll_offset = active_p->cursor_idx;
				}
				OS_CHDIR((unsigned char *)active_p->current_path);
				if (active_p->scroll_offset != old_scroll)
				{
					draw_panel(active_p, start_x, 18);
				}
				else
				{
					switch_file_page(active_p, active_p->file_indices[active_p->cursor_idx]);
					redraw_all();
				}
				/* Обновляем длинное имя внизу рамки */
				draw_bottom_info(active_p);
			}
			continue;
		}

		/* PAGE DOWN / ВПРАВО (251) */
		if (key == 251)
		{
			if (active_p->cursor_idx + 1 < active_p->file_count)
			{
				unsigned int old_scroll = active_p->scroll_offset;
				unsigned char start_x = (left_panel.is_active) ? 0 : 40;

				active_p->cursor_idx += 18;
				if (active_p->cursor_idx >= active_p->file_count)
				{
					active_p->cursor_idx = active_p->file_count - 1;
				}
				if (active_p->cursor_idx >= active_p->scroll_offset + 18)
				{
					active_p->scroll_offset = active_p->cursor_idx - 18 + 1;
				}
				OS_CHDIR((unsigned char *)active_p->current_path);
				draw_panel(active_p, start_x, 18);

				/* Обновляем длинное имя внизу рамки */
				draw_bottom_info(active_p);
			}
			continue;
		}

		/* ENTER (13) */
		if (key == 13)
		{
			handle_enter(active_p);
			/* После смены папки принудительно обновляем нижнюю строку новой позиции */
			draw_bottom_info(active_p);
			continue;
		}
	}
}
