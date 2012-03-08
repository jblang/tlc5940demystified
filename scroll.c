// Based on code in Project 21 of Beginning Arduino by Mike McRoberts

#include <avr/pgmspace.h>
#include <util/delay.h>
#include "tlc5940.h"
#include "scroll.h"

#include "readable.h"

uint8_t mapchar(uint8_t chr) {
#ifdef MAP_NUMBER
    if (chr >= 32 && chr < 64)
        return chr - 32 + MAP_NUMBER;
#endif
#ifdef MAP_UPPER
    if (chr >= 64 && chr < 96)
        return chr - 64 + MAP_UPPER;
#endif
#ifdef MAP_LOWER
    if (chr >= 96 && chr < 128)
        return chr - 96 + MAP_LOWER;
#endif
    return chr;
}

#define GREEN(x) ((x) * 2)
#define RED(x) (((x) * 2)  + 1)

void scroll(char myString[]) {
  uint8_t firstChrRow, secondChrRow;
  uint8_t ledOutput;
  uint8_t chrPointer = 0; // Initialise the string position pointer
  uint8_t Char1, Char2; // the two characters that will be displayed
  uint8_t scrollBit = 0;
  uint8_t strLength = 0;
  //uint16_t color = 0;
  //unsigned long time;
  //unsigned long counter;
  
  // Increment count till we reach the string 
  while (myString[strLength]) {strLength++;}
  
  for (;;) {
    while (chrPointer < (strLength-1)) {
      while(gsUpdateFlag); // wait until we can modify gsData
      Char1 = myString[chrPointer];
      Char2 = myString[chrPointer+1];
      for (uint8_t y= 0; y<8; y++) {
        firstChrRow = pgm_read_byte(&font[mapchar(Char1)*8+y]);
        secondChrRow = (pgm_read_byte(&font[mapchar(Char2)*8+y]));
        ledOutput = (firstChrRow << scrollBit) | (secondChrRow >> (8 - scrollBit) );
        for (uint8_t x = 0; x < 8; x++) {
          if (ledOutput & 0x80) {
            TLC5940_SetGS(y, GREEN(x), x * 512);
            TLC5940_SetGS(y, RED(x), 4095 - (y*512));
          } else {
            TLC5940_SetGS(y, RED(x), 0);
            TLC5940_SetGS(y, GREEN(x), 0);
          }
          ledOutput <<= 1;
        }
      }
      scrollBit++; 
      if (scrollBit > 6) { 
        scrollBit = 0;
        chrPointer++;
      }
      TLC5940_SetGSUpdateFlag();
      _delay_ms(50);
    }
    chrPointer = 0;
  }
}



