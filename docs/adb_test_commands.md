# TI60 / X2000 ADB测试指令

以下命令在电脑端执行，通过ADB让X2000向`/dev/ttyS1`发送现有Python脚本生成的同一报文。命令只负责发送；带“查询”的命令不会在终端显示回包。

> **要测 OSD 菜单显示，请看 [osd_menu_test_commands.md](osd_menu_test_commands.md)。** 那份带判据（回包该是什么、画面上该看到什么）与排查表。
> 本文件是全模块的裸命令清单，只负责“发出去”，看不出成功失败。

## UI菜单和状态

> **实现范围**：固件目前只实现了 3 个菜单页 —— `0x0000` 一级菜单（9 项）、`0x0100` 图像设置（6 项，前 4 项是数值行）、`0x0200` 图像模式（4 项）。下面第一段里只有这三页的 `SET_VIEW` 会成功，其余页返回失败（`status=0x00`）。
> 另外 `0x01`–`0x05`（显示/隐藏/按键/状态/清除/测距标记）在固件里**只解析、不应答**，发出去必然超时 —— **这是设计，不是故障**。
> **要显示/隐藏菜单，用 `0x06` 的 `flags.bit0`**（即下面的 `--view` 不带/带 `--hidden`），不是“隐藏UI”那一条。

```powershell
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x04\\x01\\x00\\x01\\xED\\xE0\\xAA" > /dev/ttyS1' # 显示UI
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x04\\x01\\x00\\x00\\xFD\\xC1\\xAA" > /dev/ttyS1' # 隐藏UI
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x04\\x02\\x00\\x00\\xA4\\x91\\xAA" > /dev/ttyS1' # 菜单按键 up
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x04\\x02\\x00\\x01\\xB4\\xB0\\xAA" > /dev/ttyS1' # 菜单按键 down
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x04\\x02\\x00\\x02\\x84\\xD3\\xAA" > /dev/ttyS1' # 菜单按键 enter
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x04\\x02\\x00\\x03\\x94\\xF2\\xAA" > /dev/ttyS1' # 菜单按键 back
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x0C\\x04\\x03\\x00\\x0F\\x00\\x7B\\x01\\xC8\\xFF\\xF4\\x00\\x22\\x26\\x10\\xAA" > /dev/ttyS1' # 四项状态示例
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x0C\\x04\\x03\\x00\\x01\\x00\\x7B\\x00\\x00\\x00\\x00\\x00\\x00\\x51\\x43\\xAA" > /dev/ttyS1' # 仅方位角123°有效
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x0C\\x04\\x03\\x00\\x0F\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\xED\\x7A\\xAA" > /dev/ttyS1' # 默认四项零值
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x03\\x04\\x04\\x00\\x10\\x04\\xAA" > /dev/ttyS1' # 清除状态数值
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x05\\x00\\x02\\x13\\x00\\x89\\x75\\x3D\\xAA" > /dev/ttyS1' # 测距圆移到(531,137)
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x05\\x00\\x01\\x90\\x00\\xC8\\xD4\\x0E\\xAA" > /dev/ttyS1' # 测距圆移到(400,200)
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x00\\x01\\x5C\\x06\\xAA" > /dev/ttyS1' # 直接刷新一级菜单，选中第0项
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x00\\x01\\x2A\\xB2\\xAA" > /dev/ttyS1' # 直接刷新图像设置子菜单
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x02\\x00\\x00\\x01\\xB1\\x6E\\xAA" > /dev/ttyS1' # 直接刷新调色板子菜单
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x07\\x00\\x00\\x05\\x05\\x05\\x4D\\x27\\xAA" > /dev/ttyS1' # 图像增强0，其余三项5
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x03\\x04\\x08\\x00\\x55\\x69\\xAA" > /dev/ttyS1' # 查询当前菜单页、选中项和四项数值
```
以下每条命令直接显示对应页面并选中注释中的菜单项，序号从0开始。

> **这一段的页面大多不在当前固件里**：下表的页面与条目文字按**规格**（26 页）写，
> 而固件只有 `0x0000`/`0x0100`/`0x0200` 三页，条目文字与条目数也不同（例如 `0x0200` 固件里是 4 项、不是 7 项）。
> 其余页发过去回 `status=0x00`。逐页对照见 [osd_menu_test_commands.md](osd_menu_test_commands.md) 附录 B。

```POWERSHELL
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x00\\x01\\x5C\\x06\\xAA" > /dev/ttyS1' # 0x0000 一级菜单 [0] Настройки изображения
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x01\\x01\\x6F\\x37\\xAA" > /dev/ttyS1' # 0x0000 一级菜单 [1] Палитры
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x02\\x01\\x3A\\x64\\xAA" > /dev/ttyS1' # 0x0000 一级菜单 [2] Зум
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x03\\x01\\x09\\x55\\xAA" > /dev/ttyS1' # 0x0000 一级菜单 [3] Функции
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x04\\x01\\x90\\xC2\\xAA" > /dev/ttyS1' # 0x0000 一级菜单 [4] Настройки
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x05\\x01\\xA3\\xF3\\xAA" > /dev/ttyS1' # 0x0000 一级菜单 [5] Измерение
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x06\\x01\\xF6\\xA0\\xAA" > /dev/ttyS1' # 0x0000 一级菜单 [6] Пристрелка
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x07\\x01\\xC5\\x91\\xAA" > /dev/ttyS1' # 0x0000 一级菜单 [7] Баллистика
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x08\\x01\\xD5\\xAF\\xAA" > /dev/ttyS1' # 0x0000 一级菜单 [8] Настройки дисплея
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x00\\x01\\x2A\\xB2\\xAA" > /dev/ttyS1' # 0x0100 Настройки изображения [0] Улучшение изображения
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x01\\x01\\x19\\x83\\xAA" > /dev/ttyS1' # 0x0100 Настройки изображения [1] Контраст
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x02\\x01\\x4C\\xD0\\xAA" > /dev/ttyS1' # 0x0100 Настройки изображения [2] Яркость изображения
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x03\\x01\\x7F\\xE1\\xAA" > /dev/ttyS1' # 0x0100 Настройки изображения [3] Яркость экрана
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x04\\x01\\xE6\\x76\\xAA" > /dev/ttyS1' # 0x0100 Настройки изображения [4] Картинка-в-картинке
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x05\\x01\\xD5\\x47\\xAA" > /dev/ttyS1' # 0x0100 Настройки изображения [5] Коррекция изображения
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x01\\x00\\x01\\x1D\\x82\\xAA" > /dev/ttyS1' # 0x0101 Картинка-в-картинке [0] Коррекция изображения
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x02\\x00\\x01\\x44\\xD2\\xAA" > /dev/ttyS1' # 0x0102 Коррекция изображения [0] Автокоррекция
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x02\\x01\\x01\\x77\\xE3\\xAA" > /dev/ttyS1' # 0x0102 Коррекция изображения [1] Ручная коррекция
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x02\\x02\\x01\\x22\\xB0\\xAA" > /dev/ttyS1' # 0x0102 Коррекция изображения [2] Коррекция объектива
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x02\\x00\\x00\\x01\\xB1\\x6E\\xAA" > /dev/ttyS1' # 0x0200 Палитры [0] Белое горячее
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x02\\x00\\x01\\x01\\x82\\x5F\\xAA" > /dev/ttyS1' # 0x0200 Палитры [1] Чёрное горячее
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x02\\x00\\x02\\x01\\xD7\\x0C\\xAA" > /dev/ttyS1' # 0x0200 Палитры [2] Красное горячее
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x02\\x00\\x03\\x01\\xE4\\x3D\\xAA" > /dev/ttyS1' # 0x0200 Палитры [3] Железо-красный
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x02\\x00\\x04\\x01\\x7D\\xAA\\xAA" > /dev/ttyS1' # 0x0200 Палитры [4] Радуга
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x02\\x00\\x05\\x01\\x4E\\x9B\\xAA" > /dev/ttyS1' # 0x0200 Палитры [5] Зелёное горячее
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x02\\x00\\x06\\x01\\x1B\\xC8\\xAA" > /dev/ttyS1' # 0x0200 Палитры [6] Контур
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x03\\x00\\x00\\x01\\xC7\\xDA\\xAA" > /dev/ttyS1' # 0x0300 Зум [0] x1
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x03\\x00\\x01\\x01\\xF4\\xEB\\xAA" > /dev/ttyS1' # 0x0300 Зум [1] x2
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x03\\x00\\x02\\x01\\xA1\\xB8\\xAA" > /dev/ttyS1' # 0x0300 Зум [2] x4
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x03\\x00\\x03\\x01\\x92\\x89\\xAA" > /dev/ttyS1' # 0x0300 Зум [3] x8
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x04\\x00\\x00\\x01\\x96\\xF7\\xAA" > /dev/ttyS1' # 0x0400 Функции [0] Настройка WiFi
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x04\\x00\\x01\\x01\\xA5\\xC6\\xAA" > /dev/ttyS1' # 0x0400 Функции [1] Компас On/Off
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x04\\x00\\x02\\x01\\xF0\\x95\\xAA" > /dev/ttyS1' # 0x0400 Функции [2] Угол наклона Вкл/Выкл
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x04\\x00\\x03\\x01\\xC3\\xA4\\xAA" > /dev/ttyS1' # 0x0400 Функции [3] Сделать фото
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x04\\x00\\x04\\x01\\x5A\\x33\\xAA" > /dev/ttyS1' # 0x0400 Функции [4] Снять видео
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x04\\x00\\x05\\x01\\x69\\x02\\xAA" > /dev/ttyS1' # 0x0400 Функции [5] Момент съёмки
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x04\\x00\\x06\\x01\\x3C\\x51\\xAA" > /dev/ttyS1' # 0x0400 Функции [6] Поднять для пробуждения
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x04\\x01\\x00\\x01\\xA1\\xC7\\xAA" > /dev/ttyS1' # 0x0401 Настройка WiFi [0] Wi-Fi On/Off
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x04\\x02\\x00\\x01\\xF8\\x97\\xAA" > /dev/ttyS1' # 0x0402 Момент съёмки [0] Сила удара On/Off
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x00\\x00\\x01\\xE0\\x43\\xAA" > /dev/ttyS1' # 0x0500 Настройки [0] Язык
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x00\\x01\\x01\\xD3\\x72\\xAA" > /dev/ttyS1' # 0x0500 Настройки [1] Внешний вид
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x00\\x02\\x01\\x86\\x21\\xAA" > /dev/ttyS1' # 0x0500 Настройки [2] Время и дата
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x00\\x03\\x01\\xB5\\x10\\xAA" > /dev/ttyS1' # 0x0500 Настройки [3] Хранилище
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x00\\x04\\x01\\x2C\\x87\\xAA" > /dev/ttyS1' # 0x0500 Настройки [4] Назначение кнопок
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x00\\x05\\x01\\x1F\\xB6\\xAA" > /dev/ttyS1' # 0x0500 Настройки [5] Авто-выключение
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x00\\x06\\x01\\x4A\\xE5\\xAA" > /dev/ttyS1' # 0x0500 Настройки [6] Ремонт пикселей
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x00\\x07\\x01\\x79\\xD4\\xAA" > /dev/ttyS1' # 0x0500 Настройки [7] Единицы измерения
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x01\\x00\\x01\\xD7\\x73\\xAA" > /dev/ttyS1' # 0x0501 Язык [0] Китайский
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x01\\x01\\x01\\xE4\\x42\\xAA" > /dev/ttyS1' # 0x0501 Язык [1] Русский
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x01\\x02\\x01\\xB1\\x11\\xAA" > /dev/ttyS1' # 0x0501 Язык [2] English
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x02\\x00\\x01\\x8E\\x23\\xAA" > /dev/ttyS1' # 0x0502 Время и дата [0] Отображение времени
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x02\\x01\\x01\\xBD\\x12\\xAA" > /dev/ttyS1' # 0x0502 Время и дата [1] Настройка времени
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x02\\x02\\x01\\xE8\\x41\\xAA" > /dev/ttyS1' # 0x0502 Время и дата [2] Отображение даты
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x02\\x03\\x01\\xDB\\x70\\xAA" > /dev/ttyS1' # 0x0502 Время и дата [3] Настройка даты
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x03\\x00\\x01\\xB9\\x13\\xAA" > /dev/ttyS1' # 0x0503 Назначение кнопок [0] Разрешить назначение
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x03\\x01\\x01\\x8A\\x22\\xAA" > /dev/ttyS1' # 0x0503 Назначение кнопок [1] Вверх-коротко
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x03\\x02\\x01\\xDF\\x71\\xAA" > /dev/ttyS1' # 0x0503 Назначение кнопок [2] Вверх-долго
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x03\\x03\\x01\\xEC\\x40\\xAA" > /dev/ttyS1' # 0x0503 Назначение кнопок [3] Вниз-коротко
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x03\\x04\\x01\\x75\\xD7\\xAA" > /dev/ttyS1' # 0x0503 Назначение кнопок [4] Вниз-долго
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x03\\x05\\x01\\x46\\xE6\\xAA" > /dev/ttyS1' # 0x0503 Назначение кнопок [5] Вправо-кратко
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x03\\x06\\x01\\x13\\xB5\\xAA" > /dev/ttyS1' # 0x0503 Назначение кнопок [6] Вправо-долго
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x04\\x00\\x01\\x3C\\x83\\xAA" > /dev/ttyS1' # 0x0504 Авто-выключение [0] Авто-выключение On/Off
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x04\\x01\\x01\\x0F\\xB2\\xAA" > /dev/ttyS1' # 0x0504 Авто-выключение [1] Время выключения
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x05\\x00\\x01\\x0B\\xB3\\xAA" > /dev/ttyS1' # 0x0505 Ремонт пикселей [0] Автовосстановление
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x05\\x01\\x01\\x38\\x82\\xAA" > /dev/ttyS1' # 0x0505 Ремонт пикселей [1] Ручное добавление
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x05\\x05\\x02\\x01\\x6D\\xD1\\xAA" > /dev/ttyS1' # 0x0505 Ремонт пикселей [2] Очистить метку
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x06\\x00\\x00\\x01\\x7B\\x9F\\xAA" > /dev/ttyS1' # 0x0600 Измерение [0] Лазерный дальномер
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x06\\x00\\x01\\x01\\x48\\xAE\\xAA" > /dev/ttyS1' # 0x0600 Измерение [1] Сканирование расстояния
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x06\\x00\\x02\\x01\\x1D\\xFD\\xAA" > /dev/ttyS1' # 0x0600 Измерение [2] Цвет курсора
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x06\\x01\\x00\\x01\\x4C\\xAF\\xAA" > /dev/ttyS1' # 0x0601 Цвет курсора [0] Красный
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x06\\x01\\x01\\x01\\x7F\\x9E\\xAA" > /dev/ttyS1' # 0x0601 Цвет курсора [1] Жёлтый
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x06\\x01\\x02\\x01\\x2A\\xCD\\xAA" > /dev/ttyS1' # 0x0601 Цвет курсора [2] Синий
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x06\\x01\\x03\\x01\\x19\\xFC\\xAA" > /dev/ttyS1' # 0x0601 Цвет курсора [3] Чёрный
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x00\\x00\\x01\\x0D\\x2B\\xAA" > /dev/ttyS1' # 0x0700 Пристрелка [0] Корректировка пристрелки
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x00\\x01\\x01\\x3E\\x1A\\xAA" > /dev/ttyS1' # 0x0700 Пристрелка [1] Группа пристрелки
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x00\\x02\\x01\\x6B\\x49\\xAA" > /dev/ttyS1' # 0x0700 Пристрелка [2] Стиль прицела
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x00\\x03\\x01\\x58\\x78\\xAA" > /dev/ttyS1' # 0x0700 Пристрелка [3] Цвет прицела
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x01\\x00\\x01\\x3A\\x1B\\xAA" > /dev/ttyS1' # 0x0701 Корректировка пристрелки [0] Зум
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x01\\x01\\x01\\x09\\x2A\\xAA" > /dev/ttyS1' # 0x0701 Корректировка пристрелки [1] Заморозить On/Off
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x01\\x02\\x01\\x5C\\x79\\xAA" > /dev/ttyS1' # 0x0701 Корректировка пристрелки [2] Регулировка прицела
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x01\\x03\\x01\\x6F\\x48\\xAA" > /dev/ttyS1' # 0x0701 Корректировка пристрелки [3] Отмена регулировки
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x02\\x00\\x01\\x63\\x4B\\xAA" > /dev/ttyS1' # 0x0702 Группа пристрелки [0] Имя группы A/B/C/D/E
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x02\\x01\\x01\\x50\\x7A\\xAA" > /dev/ttyS1' # 0x0702 Группа пристрелки [1] Расстояние 0-999
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x02\\x02\\x01\\x05\\x29\\xAA" > /dev/ttyS1' # 0x0702 Группа пристрелки [2] Температура
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x02\\x03\\x01\\x36\\x18\\xAA" > /dev/ttyS1' # 0x0702 Группа пристрелки [3] Влажность
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x02\\x04\\x01\\xAF\\x8F\\xAA" > /dev/ttyS1' # 0x0702 Группа пристрелки [4] Давление воздуха
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x03\\x00\\x01\\x54\\x7B\\xAA" > /dev/ttyS1' # 0x0703 Стиль прицела [0] Стиль1
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x03\\x01\\x01\\x67\\x4A\\xAA" > /dev/ttyS1' # 0x0703 Стиль прицела [1] Стиль2
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x03\\x02\\x01\\x32\\x19\\xAA" > /dev/ttyS1' # 0x0703 Стиль прицела [2] Стиль3
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x03\\x03\\x01\\x01\\x28\\xAA" > /dev/ttyS1' # 0x0703 Стиль прицела [3] Стиль4
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x03\\x04\\x01\\x98\\xBF\\xAA" > /dev/ttyS1' # 0x0703 Стиль прицела [4] Стиль5
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x03\\x05\\x01\\xAB\\x8E\\xAA" > /dev/ttyS1' # 0x0703 Стиль прицела [5] Нет
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x04\\x00\\x01\\xD1\\xEB\\xAA" > /dev/ttyS1' # 0x0704 Цвет прицела [0] Красный
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x04\\x01\\x01\\xE2\\xDA\\xAA" > /dev/ttyS1' # 0x0704 Цвет прицела [1] Жёлтый
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x04\\x02\\x01\\xB7\\x89\\xAA" > /dev/ttyS1' # 0x0704 Цвет прицела [2] Синий
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x04\\x03\\x01\\x84\\xB8\\xAA" > /dev/ttyS1' # 0x0704 Цвет прицела [3] Чёрный
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x04\\x04\\x01\\x1D\\x2F\\xAA" > /dev/ttyS1' # 0x0704 Цвет прицела [4] Белый
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x04\\x05\\x01\\x2E\\x1E\\xAA" > /dev/ttyS1' # 0x0704 Цвет прицела [5] Пурпурный
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x07\\x04\\x06\\x01\\x7B\\x4D\\xAA" > /dev/ttyS1' # 0x0704 Цвет прицела [6] Зелёный
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x08\\x00\\x00\\x01\\xD9\\xC5\\xAA" > /dev/ttyS1' # 0x0800 Баллистика [0] Баллистический калькулятор
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x08\\x00\\x01\\x01\\xEA\\xF4\\xAA" > /dev/ttyS1' # 0x0800 Баллистика [1] Настройка баллистики
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x08\\x00\\x02\\x01\\xBF\\xA7\\xAA" > /dev/ttyS1' # 0x0800 Баллистика [2] Цвет маркера
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x08\\x00\\x03\\x01\\x8C\\x96\\xAA" > /dev/ttyS1' # 0x0800 Баллистика [3] Единица угла MIL/MOA
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x08\\x00\\x04\\x01\\x15\\x01\\xAA" > /dev/ttyS1' # 0x0800 Баллистика [4] Компенсация движения
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x08\\x01\\x00\\x01\\xEE\\xF5\\xAA" > /dev/ttyS1' # 0x0801 Цвет маркера [0] Красный
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x08\\x01\\x01\\x01\\xDD\\xC4\\xAA" > /dev/ttyS1' # 0x0801 Цвет маркера [1] Жёлтый
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x08\\x01\\x02\\x01\\x88\\x97\\xAA" > /dev/ttyS1' # 0x0801 Цвет маркера [2] Синий
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x08\\x01\\x03\\x01\\xBB\\xA6\\xAA" > /dev/ttyS1' # 0x0801 Цвет маркера [3] Чёрный
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x08\\x01\\x04\\x01\\x22\\x31\\xAA" > /dev/ttyS1' # 0x0801 Цвет маркера [4] Белый
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x08\\x01\\x05\\x01\\x11\\x00\\xAA" > /dev/ttyS1' # 0x0801 Цвет маркера [5] Пурпурный
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x08\\x01\\x06\\x01\\x44\\x53\\xAA" > /dev/ttyS1' # 0x0801 Цвет маркера [6] Зелёный
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x09\\x00\\x00\\x01\\xAF\\x71\\xAA" > /dev/ttyS1' # 0x0900 Настройки дисплея [0] Положение отображения A-E
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x09\\x00\\x01\\x01\\x9C\\x40\\xAA" > /dev/ttyS1' # 0x0900 Настройки дисплея [1] Перемещение
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x09\\x00\\x02\\x01\\xC9\\x13\\xAA" > /dev/ttyS1' # 0x0900 Настройки дисплея [2] Аналоговое видео On/Off
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x09\\x00\\x03\\x01\\xFA\\x22\\xAA" > /dev/ttyS1' # 0x0900 Настройки дисплея [3] Клипсовый Вкл/Выкл
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x09\\x01\\x00\\x01\\x98\\x41\\xAA" > /dev/ttyS1' # 0x0901 Перемещение [0] Изображение
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x09\\x01\\x01\\x01\\xAB\\x70\\xAA" > /dev/ttyS1' # 0x0901 Перемещение [1] Положение по умолчанию
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x09\\x01\\x02\\x01\\xFE\\x23\\xAA" > /dev/ttyS1' # 0x0901 Перемещение [2] Отменить перемещение
```


## FPGA伪彩色

```powershell
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x03\\x01\\x00\\x00\\xAC\\xEC\\xAA" > /dev/ttyS1' # FPGA伪彩 white-hot
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x03\\x01\\x00\\x01\\xBC\\xCD\\xAA" > /dev/ttyS1' # FPGA伪彩 black-hot
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x03\\x01\\x00\\x02\\x8C\\xAE\\xAA" > /dev/ttyS1' # FPGA伪彩 red-hot
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x03\\x01\\x00\\x03\\x9C\\x8F\\xAA" > /dev/ttyS1' # FPGA伪彩 iron-red
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x03\\x01\\x00\\x04\\xEC\\x68\\xAA" > /dev/ttyS1' # FPGA伪彩 rainbow
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x03\\x01\\x00\\x05\\xFC\\x49\\xAA" > /dev/ttyS1' # FPGA伪彩 green-hot
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x03\\x01\\x00\\x06\\xCC\\x2A\\xAA" > /dev/ttyS1' # FPGA伪彩 outline
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x03\\x03\\x02\\x00\\x3F\\x32\\xAA" > /dev/ttyS1' # 查询伪彩状态
```

## 热点追踪

```powershell
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x02\\x01\\x00\\x01\\xCA\\x79\\xAA" > /dev/ttyS1' # 白热热点追踪
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x02\\x01\\x00\\x03\\xEA\\x3B\\xAA" > /dev/ttyS1' # 黑热热点追踪
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x02\\x01\\x00\\x00\\xDA\\x58\\xAA" > /dev/ttyS1' # 关闭热点追踪
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x03\\x02\\x02\\x00\\x08\\x02\\xAA" > /dev/ttyS1' # 查询热点坐标
```

## 电子变倍

```powershell
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x0B\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x04\\xFF\\x03\\xFF\\xF9\\x3D\\xAA" > /dev/ttyS1' # 全幅1倍
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x0B\\x01\\x01\\x00\\x01\\x40\\x01\\x00\\x03\\xBF\\x02\\xFF\\x59\\x13\\xAA" > /dev/ttyS1' # 中心2倍
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x0B\\x01\\x01\\x00\\x01\\xE0\\x01\\x80\\x03\\x1F\\x02\\x7F\\x92\\xD8\\xAA" > /dev/ttyS1' # 中心4倍
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x0B\\x01\\x01\\x00\\x02\\x30\\x01\\xC0\\x02\\xCF\\x02\\x3F\\x51\\x4F\\xAA" > /dev/ttyS1' # 中心8倍
```

## 掩膜

```powershell
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x00\\x04\\x00\\x01\\xCC\\xE1\\xAA" > /dev/ttyS1' # 掩膜开启
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x04\\x00\\x04\\x00\\x00\\xDC\\xC0\\xAA" > /dev/ttyS1' # 掩膜关闭
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x00\\x03\\x00\\x00\\x96\\x00\\xB2\\x83\\xE0\\xAA" > /dev/ttyS1' # 掩膜位置(150,178)
```

## 机芯测试

```powershell
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xAA\\x05\\x01\\x01\\x01\\x00\\xB2\\xEB\\xAA" > /dev/ttyS1' # 机芯基础通信
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xAA\\x05\\x01\\x02\\x02\\x01\\xB5\\xEB\\xAA" > /dev/ttyS1' # 机芯快门（会触发快门动作）
adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xAA\\x05\\x01\\x42\\x02\\x00\\xF4\\xEB\\xAA" > /dev/ttyS1' # 机芯白热（伪彩脚本的--force-machine-white）
```

完整BMP掩膜上传需要图像转换和分包，继续使用：

```powershell
python "./tools/send_mask_via_adb.py" --image "../mask.bmp"
python "./tools/send_mask_via_adb.py" --image "../mask.bmp" --persist # 上传并保存到Flash
```
