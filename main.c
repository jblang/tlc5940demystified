#include <stdint.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "tlc5940.h"

  /*
    breadboardMode

      If 1, instead of the LEDs being arranged sequentially, they are
      arranged in two halves with all of the even numbered outputs
      first, followed by all of the odd numbered outputs. This makes
      it easier to fit them next to each other on a breadboard.
  */
uint8_t breadboardMode = 1;


#define RED 0
#define GREEN 1
#define BLUE 2

// color_index should be in the range 0-767
static inline void SetColorToIndex(uint16_t color_index, uint8_t *r, uint8_t *g, uint8_t *b) {
  uint8_t group = color_index >> 8;
  uint8_t value = (uint8_t)color_index;

  switch (group) {
  case 0:
    *r = 255 - value;
    *g = value;
    *b = 0;
    break;
  case 1:
    *r = 0;
    *g = 255 - value;
    *b = value;
    break;
  case 2:
    *r = value;
    *g = 0;
    *b = 255 - value;
    break;
  }
}

int main(void) {
  // Set multiplex pins as outputs
  setOutput(MULTIPLEX_DDR, R_PIN);
  setOutput(MULTIPLEX_DDR, G_PIN);
  setOutput(MULTIPLEX_DDR, B_PIN);

  // Turn all multiplexing MOSFETs off
  setHigh(MULTIPLEX_PORT, R_PIN);
  setHigh(MULTIPLEX_PORT, G_PIN);
  setHigh(MULTIPLEX_PORT, B_PIN);

  // Set the order in which the multiplexing MOSFETs will be toggled
  toggleRows[0] = (1 << B_PIN) | (1 << R_PIN); // blue off, red on
  toggleRows[1] = (1 << R_PIN) | (1 << G_PIN); // red off, green on
  toggleRows[2] = (1 << G_PIN) | (1 << B_PIN); // green off, blue on

  TLC5940_Init();

#if (TLC5940_INCLUDE_DC_FUNCS)
  TLC5940_SetAllDC(31);
  TLC5940_ClockInDC();
#endif

  // Default all channels to off
  TLC5940_SetAllGS(RED, 0);
  TLC5940_SetAllGS(GREEN, 0);
  TLC5940_SetAllGS(BLUE, 0);

  // Manually clock in last set of values to be multiplexed
  TLC5940_ClockInGS();

  // Turn on the last multiplexing MOSFET (so the toggle function works)
  setLow(MULTIPLEX_PORT, B_PIN);

  // Enable Global Interrupts
  sei();

  uint8_t r, g, b, offset, led_offset;
  r = g = b = offset = led_offset = 0;

  // create the mapping for TLC5940 outputs --> actual LED order
  uint8_t led[numChannels];
  if (breadboardMode) {
    for (channel_t i = 0; i < numChannels; i++) {
      if (i % 2)
        led[numChannels / 2 + i / 2] = i;
      else
        led[i / 2] = i;
    }
  } else {
    for (channel_t i = 0; i < numChannels; i++)
      led[i] = i;
  }

  for (;;) {
    while(gsUpdateFlag); // wait until we can modify gsData
    for (uint16_t i = 0; i < numChannels; i++) {
      SetColorToIndex(i * (768 / numChannels) + offset, &r, &g, &b);
      TLC5940_SetGS(RED, led[(i - led_offset) % numChannels], pgm_read_word(&TLC5940_GammaCorrect[r]));
      TLC5940_SetGS(GREEN, led[(i - led_offset) % numChannels], pgm_read_word(&TLC5940_GammaCorrect[g]));
      TLC5940_SetGS(BLUE, led[(i - led_offset) % numChannels], pgm_read_word(&TLC5940_GammaCorrect[b]));
    }
    TLC5940_SetGSUpdateFlag();
    //_delay_ms(1);
    offset = (offset + 1) % (768 / numChannels);
    if (offset == 0)
      led_offset = (led_offset + 1) % numChannels;
  }

  return 0;
}
