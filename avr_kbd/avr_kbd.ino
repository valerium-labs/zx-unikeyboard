/*
 * Based on AVR keyboard firmware for ps2_cpld_kbd project
 * @author Andy Karpov <andy.karpov@gmail.com>
 * Ukraine, 2019
 * 
 * Ported to ATMega32 and redesigned for custom keyboard matrix by Valeriy Matveyev
 * valerium@rambler.ru
 * Russia, 2021
 * 
 */

#define DEBUG_MODE 1
#define PRESSED true
#define RELEASED false

#include <EEPROM.h>
#include <SPI.h>
#include "zxkeyboard.h"
#include "customkey.h"

 
//Keyboard connector pins corresponding to MCU pins
#define PIN1 PIN_PD2
#define PIN2 PIN_PD3
#define PIN3 PIN_PD4
#define PIN4 PIN_PD5
#define PIN5 PIN_PD6
#define PIN6 PIN_PD7
#define PIN7 PIN_PC0
#define PIN8 PIN_PC1
#define PIN9 PIN_PC2
#define PIN10 PIN_PC3
#define PIN11 PIN_PC4
#define PIN12 PIN_PC5
#define PIN13 PIN_PC6
#define PIN14 PIN_PC7
#define PIN15 PIN_PA7
#define PIN16 PIN_PA6
#define PIN17 PIN_PA5
#define PIN18 PIN_PA4
#define PIN19 PIN_PA3
#define PIN20 PIN_PA2
#define PIN21 PIN_PA1
#define PIN22 PIN_PA0
#define PIN23 PIN_PB0
#define PIN24 PIN_PB1
#define PIN25 PIN_PB2
#define PIN26 PIN_PB3

//MCU pins array to search by keyboard pin number
const uint8_t pins[] = 
{
0xFF, PIN1, PIN2, PIN3, PIN4, PIN5, PIN6, PIN7, PIN8, PIN9, PIN10,
PIN11, PIN12, PIN13, PIN14, PIN15, PIN16, PIN17, PIN18, PIN19, PIN20,
PIN21, PIN22, PIN23, PIN24, PIN25, PIN26
};


#define COLS_MAX 8
#define ROWS_MAX 16

//Keyboard connector pins used as COLUMNS
const uint8_t cols[COLS_MAX] = 
{                                                 
  6, 7, 8, 9, 10, 11, 12, 13
};

//Keyboard connector pins used as ROWS
const uint8_t rows[ROWS_MAX] = 
{
  1, 2, 3, 4, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24
};


// hardware SPI
#define PIN_SS PIN_PB4 // SPI slave select

#define EEPROM_TURBO_ADDRESS 0x00
#define EEPROM_SPECIAL_ADDRESS 0x01

#define EEPROM_VALUE_TRUE 10
#define EEPROM_VALUE_FALSE 20

bool matrix[ZX_MATRIX_FULL_SIZE]; // matrix of pressed keys + special keys to be transmitted on CPLD side by SPI protocol

bool is_turbo = false;
bool is_special = false;

SPISettings settingsA(8000000, MSBFIRST, SPI_MODE0); // SPI transmission settings

//transform active keys' numbers into internal matrix of pressed keys
void fill_kbd_matrix(uint8_t key)
{
  switch (key) 
  {
  
    // LCtrl, LShift -> CS for ZX
    case KEY_LSHIFT:
    case KEY_LCTRL:
      matrix[ZX_K_CS] = PRESSED;
      break;

    // RCtrl,RShift -> SS for ZX
    case KEY_RSHIFT:
    case KEY_RCTRL:
      matrix[ZX_K_SS] = PRESSED;
      break;

    // Alt -> SS+CS for ZX
    case KEY_LALT:
    case KEY_RALT:
      matrix[ZX_K_SS] = PRESSED;
      matrix[ZX_K_CS] = PRESSED;
      break;


    // Del -> SS+C for ZX
    case KEY_DELETE:
       matrix[ZX_K_SS] = PRESSED;
       matrix[ZX_K_C] =  PRESSED;
    break;

    // Ins -> SS+A for ZX
    case KEY_INSERT:
       matrix[ZX_K_SS] = PRESSED;
       matrix[ZX_K_A] =  PRESSED;
    break;

    // Cursor -> CS + 5,6,7,8
    case KEY_UP:
      matrix[ZX_K_CS] = PRESSED;
      matrix[ZX_K_7] = PRESSED;
      break;
    case KEY_DOWN:
      matrix[ZX_K_CS] = PRESSED;
      matrix[ZX_K_6] = PRESSED;
      break;
    case KEY_LEFT:
      matrix[ZX_K_CS] = PRESSED;
      matrix[ZX_K_5] = PRESSED;
      break;
    case KEY_RIGHT:
      matrix[ZX_K_CS] = PRESSED;
      matrix[ZX_K_8] = PRESSED;
      break;

    // ESC -> CS+SPACE for ZX
    case KEY_ESC:
      matrix[ZX_K_CS] = PRESSED;
      matrix[ZX_K_SP] = PRESSED;
      break;

    // Backspace -> CS+0
    case KEY_BACKSPACE:
      matrix[ZX_K_CS] = PRESSED;
      matrix[ZX_K_0] = PRESSED;
      break;

    // Enter
    case KEY_ENTER:
      matrix[ZX_K_ENT] = PRESSED;
      break;

    // Space
    case KEY_SPACE:
      matrix[ZX_K_SP] = PRESSED;
      break;

    // Letters & numbers
    case KEY_A: matrix[ZX_K_A] = PRESSED; break;
    case KEY_B: matrix[ZX_K_B] = PRESSED; break;
    case KEY_C: matrix[ZX_K_C] = PRESSED; break;
    case KEY_D: matrix[ZX_K_D] = PRESSED; break;
    case KEY_E: matrix[ZX_K_E] = PRESSED; break;
    case KEY_F: matrix[ZX_K_F] = PRESSED; break;
    case KEY_G: matrix[ZX_K_G] = PRESSED; break;
    case KEY_H: matrix[ZX_K_H] = PRESSED; break;
    case KEY_I: matrix[ZX_K_I] = PRESSED; break;
    case KEY_J: matrix[ZX_K_J] = PRESSED; break;
    case KEY_K: matrix[ZX_K_K] = PRESSED; break;
    case KEY_L: matrix[ZX_K_L] = PRESSED; break;
    case KEY_M: matrix[ZX_K_M] = PRESSED; break;
    case KEY_N: matrix[ZX_K_N] = PRESSED; break;
    case KEY_O: matrix[ZX_K_O] = PRESSED; break;
    case KEY_P: matrix[ZX_K_P] = PRESSED; break;
    case KEY_Q: matrix[ZX_K_Q] = PRESSED; break;
    case KEY_R: matrix[ZX_K_R] = PRESSED; break;
    case KEY_S: matrix[ZX_K_S] = PRESSED; break;
    case KEY_T: matrix[ZX_K_T] = PRESSED; break;
    case KEY_U: matrix[ZX_K_U] = PRESSED; break;
    case KEY_V: matrix[ZX_K_V] = PRESSED; break;
    case KEY_W: matrix[ZX_K_W] = PRESSED; break;
    case KEY_X: matrix[ZX_K_X] = PRESSED; break;
    case KEY_Y: matrix[ZX_K_Y] = PRESSED; break;
    case KEY_Z: matrix[ZX_K_Z] = PRESSED; break;

    // digits
    case KEY_0: matrix[ZX_K_0] = PRESSED; break;
    case KEY_1: matrix[ZX_K_1] = PRESSED; break;
    case KEY_2: matrix[ZX_K_2] = PRESSED; break;
    case KEY_3: matrix[ZX_K_3] = PRESSED; break;
    case KEY_4: matrix[ZX_K_4] = PRESSED; break;
    case KEY_5: matrix[ZX_K_5] = PRESSED; break;
    case KEY_6: matrix[ZX_K_6] = PRESSED; break;
    case KEY_7: matrix[ZX_K_7] = PRESSED; break;
    case KEY_8: matrix[ZX_K_8] = PRESSED; break;
    case KEY_9: matrix[ZX_K_9] = PRESSED; break;

    // CapsLock
    case KEY_CAPSLOCK:
      matrix[ZX_K_CS] = PRESSED;
      matrix[ZX_K_2] = PRESSED;
      break;

    // = -> SS+L
    case KEY_EQ:
      matrix[ZX_K_SS] = PRESSED;
      matrix[ZX_K_L] = PRESSED;
      break;

    // -  -> SS+J
    case KEY_MINUS:
      matrix[ZX_K_SS] = PRESSED;
      matrix[ZX_K_J] = PRESSED;
      break;

    // [ -> replaced for  SS+0 (_)
    case KEY_LBRACKET:
//        send_macros(ZX_K_Y);  //macro for [ works too faulty
        matrix[ZX_K_SS] = PRESSED;
        matrix[ZX_K_0] = PRESSED;
        break;

    // ] -> replaced for SS+K (+)
    case KEY_RBRACKET:
//        send_macros(ZX_K_U);  //macro for ] works too faulty
        matrix[ZX_K_SS] = PRESSED;
        matrix[ZX_K_K] = PRESSED;
        break;

    // , -> SS+N
    case KEY_COMMA:
      matrix[ZX_K_SS] = PRESSED;
      matrix[ZX_K_N] = PRESSED;
      break;

    // . -> SS+M
    case KEY_PERIOD:
      matrix[ZX_K_SS] = PRESSED;
      matrix[ZX_K_M] = PRESSED;
      break;

    // ; -> SS+O
    case KEY_SEMICOLON:
      matrix[ZX_K_SS] = PRESSED;
      matrix[ZX_K_O] = PRESSED;
      break;

    // " -> SS+7
    case KEY_QUOTE:
      matrix[ZX_K_SS] = PRESSED;
      matrix[ZX_K_P] = PRESSED;
      break;

    // / -> SS+V
    case KEY_SLASH:
      matrix[ZX_K_SS] = PRESSED;
      matrix[ZX_K_V] = PRESSED;
      break;

    // \ -> replaced for SS+Z (:)
    case KEY_BACKSLASH:
      matrix[ZX_K_SS] = PRESSED;
      matrix[ZX_K_Z] = PRESSED;
      break;


    // Scroll Lock -> Turbo
    case KEY_F10: 
        is_turbo = !is_turbo;        
        eeprom_store_value(EEPROM_TURBO_ADDRESS, is_turbo);
        matrix[ZX_K_TURBO] = is_turbo;
        transmit_keyboard_matrix();
        delay (500);
        break;

    // PrintScreen -> Special
    case KEY_PRTSCR: 
        is_special = !is_special;        
        eeprom_store_value(EEPROM_SPECIAL_ADDRESS, is_special);
        matrix[ZX_K_SPECIAL] = is_special;
        transmit_keyboard_matrix();
        delay (500);
	      break;

    // F2 -> Magic button
    case KEY_F2:
        do_magic();
	      break;

    // F12 -> Reset
    case KEY_F12:
        do_reset();
	      break;

  }
}



uint8_t get_matrix_byte(uint8_t pos)
{
  uint8_t result = 0;
  for (uint8_t i=0; i<8; i++) {
    uint8_t k = pos*8 + i;
    if (k < ZX_MATRIX_FULL_SIZE) {
      bitWrite(result, i, matrix[k]);
    }
  }
  return result;
}

void spi_send(uint8_t addr, uint8_t data) 
{
      SPI.beginTransaction(settingsA);
      digitalWrite(PIN_SS, LOW);
      uint8_t cmd = SPI.transfer(addr); // keymatrix part (1...6)
      uint8_t res = SPI.transfer(data); // data byte
      digitalWrite(PIN_SS, HIGH);
      SPI.endTransaction();
}

// transmit keyboard matrix from AVR to CPLD side via SPI
void transmit_keyboard_matrix()
{
    uint8_t bytes = 6;
    for (uint8_t i=0; i<bytes; i++) {
      uint8_t data = get_matrix_byte(i);
      spi_send(i+1, data);
    }
}

// transmit keyboard macros (sequence of keyboard clicks) to emulate typing some special symbols [, ], {, }, ~, |, `
void send_macros(uint8_t pos)
{
  clear_matrix(ZX_MATRIX_SIZE);
  transmit_keyboard_matrix();
  delay(20);
  matrix[ZX_K_CS] = PRESSED;
  matrix[ZX_K_SS] = PRESSED;
  transmit_keyboard_matrix();
  delay(20);
  matrix[ZX_K_SS] = RELEASED;
  transmit_keyboard_matrix();
  delay(20);
  matrix[ZX_K_CS] = PRESSED;
  matrix[pos] = PRESSED;
  transmit_keyboard_matrix();
  delay(20);
  matrix[ZX_K_CS] = RELEASED;
  matrix[pos] = RELEASED;
}

void do_reset()
{
  clear_matrix(ZX_MATRIX_SIZE);
  matrix[ZX_K_RESET] = true;
  transmit_keyboard_matrix();
  delay(500);
  matrix[ZX_K_RESET] = false;
  transmit_keyboard_matrix();  
}

void do_magic()
{
  matrix[ZX_K_MAGIC] = true;
  transmit_keyboard_matrix();
  delay(500);
  matrix[ZX_K_MAGIC] = false;
  transmit_keyboard_matrix();
}

void clear_matrix(int clear_size)
{
    // release all keys
  for (int i=0; i<clear_size; i++) {
      matrix[i] = RELEASED;
  }
}


bool eeprom_restore_value(int addr, bool default_value)
{
  byte val;  
  val = EEPROM.read(addr);
  if ((val == EEPROM_VALUE_TRUE) || (val == EEPROM_VALUE_FALSE)) {
    return (val == EEPROM_VALUE_TRUE) ? true : false;
  } else {
    EEPROM.update(addr, (default_value ? EEPROM_VALUE_TRUE : EEPROM_VALUE_FALSE));
    return default_value;
  }
}

void eeprom_store_value(int addr, bool value)
{
  byte val = (value ? EEPROM_VALUE_TRUE : EEPROM_VALUE_FALSE);
  EEPROM.update(addr, val);
}

void eeprom_restore_values()
{
  is_turbo = eeprom_restore_value(EEPROM_TURBO_ADDRESS, is_turbo);
  is_special = eeprom_restore_value(EEPROM_SPECIAL_ADDRESS, is_special);
  matrix[ZX_K_TURBO] = is_turbo;
  matrix[ZX_K_SPECIAL] = is_special;
}

void eeprom_store_values()
{
  eeprom_store_value(EEPROM_TURBO_ADDRESS, is_turbo);
  eeprom_store_value(EEPROM_SPECIAL_ADDRESS, is_special);
}




// initial setup
void setup()
{
  Serial.begin(115200);
  Serial.flush();

  SPI.begin();
  pinMode(PIN_SS, OUTPUT);
  digitalWrite(PIN_SS, HIGH);


  for (uint8_t i=0; i<ROWS_MAX; i++) pinMode (pins[rows[i]], INPUT_PULLUP);
  for (uint8_t i=0; i<COLS_MAX; i++) pinMode (pins[cols[i]], INPUT_PULLUP); 

  // clear full matrix
  clear_matrix(ZX_MATRIX_FULL_SIZE);

  // restore saved modes from EEPROM
  eeprom_restore_values();


Serial.println(F("ZX unikeyboard controller v1.0"));

#if DEBUG_MODE
  Serial.println(F("Reset on boot..."));
#endif

  do_reset();

#if DEBUG_MODE
  Serial.println(F("done"));
  Serial.println(F("Keyboard init..."));
#endif


#if DEBUG_MODE
  Serial.println(F("done"));
#endif
}


// main loop
void loop()
{

  uint8_t i, colcount, rowcount;

  //clear ZX keymatrix buffer here without special functions
  clear_matrix(ZX_MATRIX_SIZE);

  //all keys polling cycle
  for (colcount=0; colcount<COLS_MAX; colcount++)
      {
          for (i=0; i<COLS_MAX; i++)
                   if (i!=colcount) 
                     pinMode (pins[cols[i]], INPUT_PULLUP);
                   else 
                   { 
                     pinMode (pins[cols[i]], OUTPUT);
                     digitalWrite (pins[cols[i]], LOW);
                   }

          for (rowcount=0; rowcount<ROWS_MAX; rowcount++)  
            if (!digitalRead(pins[rows[rowcount]])) 
             {

                for (i=0; i<sizeof(keyaddr)/3; i++)
                  if ((keyaddr[i][1]==cols[colcount]) and (keyaddr[i][2]==rows[rowcount]))
                  {
                    #if DEBUG_MODE
                       Serial.println ("Pressed key ("+String(i)+")");
                    #endif
                    // apply the active keycode to ZX keymatrix
                    fill_kbd_matrix (keyaddr[i][0]);
                  }    
             }
      }




  // transmit kbd always
  transmit_keyboard_matrix();

}
