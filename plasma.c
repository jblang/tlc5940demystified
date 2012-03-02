/*
  Plasma effect demo for red-green matrix using TLC5940 library
  Copyright (c) 2012 J.B. Langston <jb.langston@gmail.com>

  adapted from 
  ColorduinoSlave - Colorduino Slave using Colorduino Library for Arduino
  Copyright (c) 2011 Sam C. Lin lincomatic@hotmail.com ALL RIGHTS RESERVED

  plasma code based on  Color cycling plasma   
    Version 0.1 - 8 July 2009
    Copyright (c) 2009 Ben Combee.  All right reserved.
    Copyright (c) 2009 Ken Corey.  All right reserved.
    Copyright (c) 2008 Windell H. Oskay.  All right reserved.

  ColorduinoSlave is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This demo is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include <math.h>
#include "tlc5940.h"
#include "plasma.h"

#define GREEN(x) ((x) * 2)
#define RED(x) (((x) * 2)  + 1)

float dist(float a, float b, float c, float d) {
  return sqrt((c-a)*(c-a)+(d-b)*(d-b));
}

void do_plasma() {
  long paletteShift = 2038;
  float value;
  uint8_t x, y;
  uint8_t numRows = TLC5940_MULTIPLEX_N;
  uint8_t numColumns = numChannels / 2;
  uint16_t color = 0;
  for (;;) {
    while(gsUpdateFlag); // wait until we can modify gsData
    for(y = 0; y < numRows; y++) {
      for(x = 0; x < numColumns; x++) {
	value = sin(dist(x + paletteShift, y, 128.0, 128.0) / 8.0)
	  + sin(dist(x, y, 64.0, 64.0) / 8.0)
	  + sin(dist(x, y + paletteShift / 7, 192.0, 64) / 7.0)
	  + sin(dist(x, y, 192.0, 100.0) / 8.0);
        color = (uint16_t)(value * 4096) & 0xfff;
        if (color > 2047) {
          TLC5940_SetGS(y, GREEN(x), color);
          TLC5940_SetGS(y, RED(x), 4095 - color);
        } else {
          TLC5940_SetGS(y, GREEN(x), 2047 - color);
          TLC5940_SetGS(y, RED(x), 2048 + color);
        }
      }
    }
    paletteShift++;
    TLC5940_SetGSUpdateFlag();
  }
}

