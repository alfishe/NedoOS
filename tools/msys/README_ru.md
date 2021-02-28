# MinGW - Минимальный набор программ GNU для Windows

Домашняя страница проекта: https://sourceforge.net/projects/mingw/

Установщик MinGW: https://sourceforge.net/projects/mingw/files/Installer/

## Использованные инструменты

Инструменты MinGW/MSYS:

Пакет          | Класс | Версия                 | Описание
---------------|-------|------------------------|---------------------------------------------------------------
msys-core      | bin   | 1.0.19-1-msys-1.0.19   | Основные компоненты MSYS
msys-coreutils | bin   | 5.97-3-msys-1.0.13     | Набор основных утилит GNU
msys-grep      | bin   | 2.5.4-2-msys-1.0.13    | Печать строк соответствующих шаблону
msys-libiconv  | bin   | 1.14-1-msys-1.0.17     | Библиотеки и утилиты GNU для преобразования кодировок символов
msys-libiconv  | dll   | 1.14-1-msys-1.0.17     | Библиотеки и утилиты GNU для преобразования кодировок символов
msys-libintl   | dll   | 0.18.1.1-1-msys-1.0.17 | Библиотека интернационализации GNU времени исполнения
msys-liblzma   | dll   | 5.0.3-1-msys-1.0.17    | Высокоэффективное сжатие на основе алгоритма LZMA
msys-sed       | bin   | 4.2.1-2-msys-1.0.13    | Потоковый редактор GNU
msys-xz        | bin   | 5.0.3-1-msys-1.0.17    | Высокоэффективное сжатие на основе алгоритма LZMA

Файлы:

Файл               | Пакет         | Класс | Версия
-------------------|---------------|-------|-----------------------
cat.exe            | msys-core     | bin   | 5.97-3-msys-1.0.13
cp.exe             | msys-core     | bin   | 5.97-3-msys-1.0.13
grep.exe           | msys-grep     | bin   | 2.5.4-2-msys-1.0.13
iconv.exe          | msys-libiconv | bin   | 0.14-1-msys-1.0.17
mkdir.exe          | msys-core     | bin   | 5.97-3-msys-1.0.13
msys-1.0.dll       | msys-core     | bin   | 1.0.19-1-msys-1.0.19
msys-iconv-2.dll   | msys-libiconv | dll   | 0.14-1-msys-1.0.17
msys-libintl-8.dll | msys-libintl  | dll   | 0.18.1.1-1-msys-1.0.17
msys-liblzma-5.dll | msys-liblzma  | dll   | 5.0.3-1-msys-1.0.17
mv.exe             | msys-core     | bin   | 5.97-3-msys-1.0.13
sed.exe            | msys-sed      | bin   | 4.2.1-2-msys-1.0.13
rm.exe             | msys-core     | bin   | 5.97-3-msys-1.0.13
rmdir.exe          | msys-core     | bin   | 5.97-3-msys-1.0.13
xz.exe             | msys-xz       | bin   | 5.0.3-1-msys-1.0.17
