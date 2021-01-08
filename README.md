# zx-unikeyboard

This is a keyboard controller for Speccy that allows to connect any keyboard matrix and remap its keys into standard Speccy keyboard layout.
valerum@rambler.ru
Russia, 2021

Based on idea of converting a custom keyboard into PS/2-keyboard
https://zx-pk.ru/threads/32497-kak-peredelat-prakticheski-lyubuyu-klaviaturu-v-ps-2.html
and PS/2-CPLD-keyboard controller by andykarpov
https://github.com/andykarpov/ps2_cpld_kbd

Unikeyboard controller lets you connect any laptop or desktop keyboard matrix (up to 26 pins in any order), scan its keypresses to collect the pins interaction (AVR-Keyexplorer module), build an array of its key and then "learn" a controller firmware (avr_kbd) to convert your keyboard layout into standard Speccy 40-key keyboard (8x5).

