def convert_8bit_to_4bit_bmp(input_path, output_path):
    with open(input_path, 'rb') as f:
        data = bytearray(f.read())
    
    # Проверяем сигнатуру BMP
    if data[0:2] != b'BM':
        raise ValueError("Файл не является корректным BMP")
        
    # Читаем важные данные из заголовка оригинального файла
    pixel_data_offset = int.from_bytes(data[10:14], 'little')
    width = int.from_bytes(data[18:22], 'little')
    height = int.from_bytes(data[22:26], 'little')
    
    # Извлекаем оригинальную палитру (первые 16 цветов по 4 байта BGRA)
    # В 8-битном BMP палитра начинается с 54 байта
    old_palette_start = 54
    palette_16 = data[old_palette_start : old_palette_start + 16 * 4]
    
    # Извлекаем пиксели из 8-битной матрицы
    raw_pixels = data[pixel_data_offset:]
    
    # Каждая строка в BMP выравнивается по границе 4 байт (Padding)
    row_size_8bit = (width + 3) & ~3
    row_size_4bit = ((width + 1) // 2 + 3) & ~3
    
    new_pixel_data = bytearray()
    
    # Перепаковываем 8-битные пиксели (1 байт на пиксель) в 4-битные (2 пикселя в 1 байт)
    for y in range(height):
        row_start_8bit = y * row_size_8bit
        row_4bit = bytearray()
        
        for x in range(0, width, 2):
            p1 = raw_pixels[row_start_8bit + x]
            # Если ширина нечетная, для последнего пикселя берем 0
            p2 = raw_pixels[row_start_8bit + x + 1] if (x + 1) < width else 0
            
            # Ограничиваем индексы строго до 15 (4 бита) на случай ошибок
            p1 = p1 & 0x0F
            p2 = p2 & 0x0F
            
            # Упаковываем два пикселя в один байт
            packed_byte = (p1 << 4) | p2
            row_4bit.append(packed_byte)
            
        # Добавляем выравнивание (padding) для 4-битной строки
        while len(row_4bit) < row_size_4bit:
            row_4bit.append(0)
            
        new_pixel_data.extend(row_4bit)
        
    # Собираем новый заголовок 4-битного BMP
    new_palette_size = 16 * 4  # 64 байта
    new_header_size = 54
    new_pixel_offset = new_header_size + new_palette_size
    new_file_size = new_pixel_offset + len(new_pixel_data)
    
    new_bmp = bytearray(new_header_size)
    new_bmp[0:2] = b'BM'
    new_bmp[2:6] = new_file_size.to_bytes(4, 'little')
    new_bmp[10:14] = new_pixel_offset.to_bytes(4, 'little')
    new_bmp[14:18] = (40).to_bytes(4, 'little') # Размер BITMAPINFOHEADER
    new_bmp[18:22] = width.to_bytes(4, 'little')
    new_bmp[22:26] = height.to_bytes(4, 'little')
    new_bmp[26:28] = (1).to_bytes(2, 'little')  # Цветовые плоскости
    new_bmp[28:30] = (4).to_bytes(2, 'little')  # БИТНОСТЬ: СТАВИМ 4 БИТА
    new_bmp[34:38] = len(new_pixel_data).to_bytes(4, 'little') # Размер растра
    new_bmp[46:50] = (16).to_bytes(4, 'little') # Количество используемых цветов
    new_bmp[50:54] = (16).to_bytes(4, 'little') # Количество важных цветов
    
    # Склеиваем: Заголовок + Наша нетронутая палитра (16 цветов) + Сжатые пиксели
    final_data = new_bmp + palette_16 + new_pixel_data
    
    with open(output_path, 'wb') as f:
        f.write(final_data)

# Скрипт готов к обработке вашего файла

convert_8bit_to_4bit_bmp("pic1.bmp", "pic1_4bit.bmp")
