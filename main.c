#include <stdint.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "tlc5940.h"

int main(void) {
  TLC5940_Init();

#if (TLC5940_INCLUDE_DC_FUNCS)
  TLC5940_SetAllDC(63);
  TLC5940_ClockInDC();
#endif

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

  // Manually clock in last set of values to be multiplexed
  TLC5940_ClockInGS();

  // Enable Global Interrupts
  sei();


  for (;;) {
    while(gsUpdateFlag); // wait until we can modify gsData
    TLC5940_SetGSUpdateFlag();
  }

  return 0;
}
