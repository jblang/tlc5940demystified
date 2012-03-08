/*

  main.c

  Copyright 2010-2011 Matthew T. Pandina. All rights reserved.
  Copyright 2012 J.B. Langston III. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY MATTHEW T. PANDINA "AS IS" AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
  EVENT SHALL MATTHEW T. PANDINA OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/
#include <avr/interrupt.h>
#include "tlc5940.h"
#include "plasma.h"
#include "scroll.h"

int main(void) {
  TLC5940_Init();

#if (TLC5940_INCLUDE_DC_FUNCS)
  TLC5940_SetAllDC(63);
  TLC5940_ClockInDC();
#endif

  /*
  uint16_t color = 0;
  // Make a nice gradient from red to green
  for (uint8_t y = 0; y < TLC5940_MULTIPLEX_N; y++) {
    for (uint8_t x = 0; x < numChannels / 2; x++) {
      channel_t green = x * 2;
      channel_t red = x * 2 + 1;
      TLC5940_SetGS(y, green, color);
      TLC5940_SetGS(y, red, (4095 - color)/4);
      color += 64;
    }
  }
  */

  // Manually clock in last set of values to be multiplexed
  TLC5940_ClockInGS();

  // Enable Global Interrupts
  sei();

  //do_plasma();
  scroll(" hello, TLC5940. ");

  return 0;
}
