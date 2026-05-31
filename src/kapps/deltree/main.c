#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>

char force_delete;
char silent_mode;

/* ГЛОБАЛЬНАЯ ПЕРЕМЕННАЯ: Спасает стек Z80 от переполнения.
   Теперь структура занимает память один раз, а не плодится на каждом уровне рекурсии! */
fileInfo global_info;

/* Рекурсивная функция очистки и удаления папки */
unsigned char delete_tree_recursive(const char *dir_name)
{
  /* СЕКЦИЯ ОБЪЯВЛЕНИЯ ПЕРЕМЕННЫХ (Всего несколько байт в стеке!) */
  unsigned char result;
  char local_name[64];
  char is_dir;
  char found_any;

  /* Пытаемся зайти внутрь целевой папки */
  if (OS_CHDIR((unsigned char *)dir_name) != 0)
  {
    if (!silent_mode)
      printf("Error: Cannot enter folder %s\n", dir_name);
    return 1;
  }

  /* Главный цикл очистки текущей папки */
  while (1)
  {
    /* Принудительно переоткрываем текущую папку */
    OS_OPENDIR("");
    found_any = 0;

    /* Ищем ПЕРВЫЙ валидный элемент, используя глобальную структуру */
    while (1)
    {
      result = OS_READDIR(&global_info);

      if (result == 4 || result != 0)
        break;

      /* Строжайшая посимвольная проверка на служебные точки */
      if (global_info.fname[0] == '.')
      {
        if (global_info.fname[1] == 0 || (global_info.fname[1] == '.' && global_info.fname[2] == 0))
        {
          continue;
        }
      }

      /* Забираем имя в локальный безопасный буфер текущего уровня */
      if (global_info.lfname[0] != 0)
      {
        strcpy(local_name, (char *)global_info.lfname);
      }
      else
      {
        strcpy(local_name, (char *)global_info.fname);
      }

      is_dir = (global_info.fattrib & 0x10) ? 1 : 0;
      found_any = 1;
      break;
    }

    /* Если папка пуста ? выходим из цикла удаления содержимого */
    if (!found_any)
    {
      break;
    }

    /* Уничтожаем цель */
    if (is_dir)
    {
      if (!silent_mode)
        printf("Folder -> %s\n", local_name);

      /* Рекурсивно очищаем подпапку (чистая рекурсия, стек тратит всего пару байт) */
      delete_tree_recursive(local_name);

      /* ВОССТАНОВЛЕНИЕ ПОЗИЦИИ И КЭША ОС */
      OS_CHDIR((unsigned char *)"..");
      OS_CHDIR((unsigned char *)dir_name);

      /* НИКАКИХ РЕКУРСИВНЫХ RETURN! Просто продолжаем цикл while(1) дальше */
    }
    else
    {
      if (!silent_mode)
        printf("Deleting: %s\n", local_name);
      OS_DELETE((unsigned char *)local_name);
    }
  }

  /* Выходим из вычищенной папки на уровень вверх */
  OS_CHDIR((unsigned char *)"..");

  /* Удаляем саму папку */
  if (!silent_mode)
    printf("Removing empty folder: %s\n", dir_name);
  OS_DELETE((unsigned char *)dir_name);

  return 0;
}

C_task main(int argc, char *argv[])
{
  char safe_target_dir[64];
  char *target_dir_ptr;
  int i;
  char response;

  os_initstdio();

  force_delete = 0;
  silent_mode = 0;
  target_dir_ptr = NULL;

  if (argc < 2)
  {
    printf("Usage: deltree [-y] [-s]<directory_name>\n");
    return 255;
  }

  for (i = 1; i < argc; i++)
  {
    if (strcmp(argv[i], "-y") == 0 || strcmp(argv[i], "-Y") == 0)
    {
      force_delete = 1;
    }
    else if (strcmp(argv[i], "-s") == 0 || strcmp(argv[i], "-S") == 0)
    {
      silent_mode = 1;
      force_delete = 1;
    }
    else
    {
      target_dir_ptr = argv[i];
    }
  }

  if (target_dir_ptr == NULL)
  {
    if (!silent_mode)
      printf("Error: No directory specified.\n");
    return 255;
  }

  strcpy(safe_target_dir, target_dir_ptr);

  if (!force_delete)
  {
    printf("Are you sure you want to delete '%s' and ALL its contents? (y/N): ", safe_target_dir);
    response = getchar();
    printf("%c\n", response);

    if (response != 'y' && response != 'Y')
    {
      printf("Deletion cancelled.\n");
      return 255;
    }
  }

  if (!silent_mode)
  {
    printf("Starting deltree for: %s\n", safe_target_dir);
    printf("-----------------------------------------\n");
  }
  delete_tree_recursive(safe_target_dir);
  if (!silent_mode)
  {
    printf("-----------------------------------------\n");
    printf("Done!\n");
  }
  return 0;
}
