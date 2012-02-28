# Name: Makefile
# Author: Matthew T. Pandina
# Copyright: <insert your copyright message here>
# License: <insert your license reference here>

# This is a prototype Makefile. Modify it according to your needs.
# You should at least check the settings for
# DEVICE ....... The AVR device you compile for
# CLOCK ........ Target AVR clock rate in Hertz
# OBJECTS ...... The object files created from your source files. This list is
#                usually the same as the list of source files with suffix ".o".
# PROGRAMMER ... Options to avrdude which define the hardware you use for
#                uploading to the AVR and the interface where this hardware
#                is connected.
# FUSES ........ Parameters for avrdude to flash the fuses appropriately.

DEVICE     = atmega328p
CLOCK      = 20000000
#CLOCK      = 18432000
#CLOCK      = 16000000
#CLOCK      = 8000000
#CLOCK      = 1000000
PROGRAMMER = -c avrispmkII -P usb
OBJECTS    = main.o tlc5940.o

# Default setting for ATmega328P in Arduino Duemilanove
#FUSES      = -U hfuse:w:0xda:m -U lfuse:w:0xff:m

# Default setting for ATmega328P
#FUSES      = -U hfuse:w:0xd9:m -U lfuse:w:0x62:m

# Remove clock divider for ATmega328P
#FUSES      = -U hfuse:w:0xd9:m -U lfuse:w:0xe2:m

# Remove clock divider, set external crystal for ATmega328P
#FUSES      = -U hfuse:w:0xd9:m -U lfuse:w:0xe6:m

# Remove clock divider, set external crystal, enable clock output
FUSES      = -U hfuse:w:0xd9:m -U lfuse:w:0xa6:m

# ---------- Begin TLC5940 Configuration Section ----------

# Defines the number of TLC5940 chips that are connected in series
TLC5940_N = 4

# Flag for including functions for manually setting the dot correction
#  0 = Do not include dot correction features (generates smaller code)
#  1 = Include dot correction features (will still read from EEPROM by default)
TLC5940_INCLUDE_DC_FUNCS = 1

# Flag for including efficient functions for setting the grayscale
# and possibly dot correction values of four channels at once.
#  0 = Do not include functions for ganging outputs in groups of four
#  1 = Include functions for ganging outputs in groups of four
# Note: Any number of outputs can be ganged together at any time by simply
#       connecting them together. These function only provide a more efficient
#       way of setting the values if outputs 0-3, 4-7, 8-11, 12-15, ... are
#       connected together
TLC5940_INCLUDE_SET4_FUNCS = 0

# Flag for including a default implementation of the TIMER0_COMPA_vect ISR
#  0 = For advanced users only! Only choose this if you want to override the
#      default implementation of the ISR(TIMER0_COMPA_vect) with your own custom
#      implemetation inside main.c
#  1 = Most users should use this setting. Use the default implementation of the
#      TIMER0_COMPA_vect ISR as defined in tlc5940.c
TLC5940_INCLUDE_DEFAULT_ISR = 1

# Flag for including a gamma correction table stored in the flash memory. When
# driving LEDs, it is helpful to use the full 12-bits of PWM the TLC5940 offers
# to output a 12-bit gamma-corrected value derived from an 8-bit value, since
# the human eye has a non-linear perception of brightness.
#
# For example, calling:
#    TLC5940_SetGS(0, 2047);
# will not make the LED appear half as bright as calling:
#    TLC5940_SetGS(0, 4095);
# However, calling:
#    TLC5940_SetGS(0, pgm_read_word(&TLC5940_GammaCorrect[127]));
# will make the LED appear half as bright as calling:
#    TLC5940_SetGS(0, pgm_read_word(&TLC5940_GammaCorrect[255]));
#
#  0 = Do not store a gamma correction table in flash memory
#  1 = Stores a gamma correction table in flash memory
TLC5940_INCLUDE_GAMMA_CORRECT = 1

# Flag for forced inlining of the SetGS, SetAllGS, and Set4GS functions.
#  0 = Do not force inline the calls to Set*GS family of functions.
#  1 = Force all calls to the Set*GS family of functions to be inlined. Use this
#      option if execution speed is critical, possibly at the expense of program
#      size, although I have found that forcing these calls to be inlined often
#      results in both smaller and faster code.
TLC5940_INLINE_SETGS_FUNCS = 1

# Flag to enable multiplexing. This can be used to drive both common cathode
# (preferred), or common anode RGB LEDs, or even single-color LEDs. Use a
# P-Channel MOSFET such as an IRF9520 for each row to be multiplexed.
#  0 = Disable multiplexing; library functions as normal.
#  1 = Enable multiplexing; The gsData array will become two-dimensional, and
#      functions in the Set*GS family require another argument which corresponds
#      to the multiplexed row they operate on.
TLC5940_ENABLE_MULTIPLEXING = 1

# The following option only applies if TLC5940_ENABLE_MULTIPLEXING = 1
ifeq ($(TLC5940_ENABLE_MULTIPLEXING), 1)
# Defines the number of rows to be multiplexed.
# Note: Without writing a custom ISR, that can toggle pins from multiple PORT
#       registers, the maximum number of rows that can be multiplexed is eight.
#       This option is ignored if TLC5940_ENABLE_MULTIPLEXING = 0
TLC5940_MULTIPLEX_N = 3
endif

# Flag to use the USART in MSPIM mode, rather than use the SPI Master bus to
# communicate with the TLC5940. One major advantage of using the USART in MSPIM
# mode is that the  transmit register is double-buffered, so you can send data
# to the TLC5940 much faster. Refer to schematics ending in _usart_mspim for
# details on how to connect the hardware before enabling this mode.
#  0 = Use normal SPI Master mode to communicate with TLC5940 (slower)
#  1 = Use the USART in double-buffered MSPIM mode to communicate with the
#      TLC5940 (faster, but requires the use of different hardware pins)
# WARNING: Before you enable this option, you must wire the chip up differently!
TLC5940_USART_MSPIM = 1

# Defines the number of bits used to define a single PWM cycle. The default
# is 12, but it may be lowered to achieve faster refreshes, at the expense
# of the ISR being called more frequently. If TLC5940_INCLUDE_GAMMA_CORRECT = 1
# then changing TLC5940_PWM_BITS will automatically rescale the gamma correction
# table to use the appropriate maximum value, at the expense of precision.
#  12 = Normal 12-bit PWM mode. Possible output values between 0-4095
#  11 = 11-bit PWM mode. Possible output values between 0-2047
#  10 = 10-bit PWM mode. Possible output values between 0-1023
#   9 =  9-bit PWM mode. Possible output values between 0-511
#   8 =  8-bit PWM mode. Possible output values between 0-255
# Note: Lowering this value will decrease the amount of time you have in the
#       ISR to send the TLC5940 updated values, potentially limiting the
#       number of devices you can connect in series, and it will decrease the
#       number of cycles available to main(), since the ISR will be called
#       more often. Lowering this value will however, reduce flickering and
#       will allow for much quicker updates.
TLC5940_PWM_BITS = 12

# Determines whether or not GPIOR0 is used to store flags. This special-purpose
# register is designed to store bit flags, as it can set, clear or test a
# single bit in only 2 clock cycles.
#
# Note: If enabled, you must make sure that the flag bits assigned below do not
#       conflict with any other GPIOR0 flag bits your application might use.
TLC5940_USE_GPIOR0 = 1

# GPIOR0 flag bits used
ifeq ($(TLC5940_USE_GPIOR0), 1)
TLC5940_FLAG_GS_UPDATE = 0
TLC5940_FLAG_XLAT_NEEDS_PULSE = 1
endif

# BLANK is only configurable if the TLC5940 is using the USART in MSPIM mode
ifeq ($(TLC5940_USART_MSPIM), 1)
BLANK_DDR = DDRD
BLANK_PORT = PORTD
BLANK_PIN = PD6
endif

# DDR, PORT, and PIN connected to DCPRG
DCPRG_DDR = DDRD
DCPRG_PORT = PORTD
# DCPRG is always configurable, but the default pin needs to change if
# the TLC5940 is using USART MSPIM mode, because PD4 is needed for XCK
ifeq ($(TLC5940_USART_MSPIM), 1)
DCPRG_PIN = PD3
else
DCPRG_PIN = PD4
endif

# DDR, PORT, and PIN connected to VPRG
VPRG_DDR = DDRD
VPRG_PORT = PORTD
VPRG_PIN = PD7

# DDR, PORT, and PIN connected to XLAT
ifeq ($(TLC5940_USART_MSPIM), 1)
XLAT_DDR = DDRD
XLAT_PORT = PORTD
XLAT_PIN = PD5
else
XLAT_DDR = DDRB
XLAT_PORT = PORTB
XLAT_PIN = PB1
endif

# The following options only apply if TLC5940_ENABLE_MULTIPLEXING = 1
ifeq ($(TLC5940_ENABLE_MULTIPLEXING), 1)
# DDR, PORT, and PIN registers used for driving the multiplexing IRF9520 MOSFETs
# Note: All pins used for multiplexing must share the same DDR, PORT, and PIN
#       registers. These options are ignored if TLC5940_ENABLE_MULTIPLEXING = 0
MULTIPLEX_DDR = DDRC
MULTIPLEX_PORT = PORTC
MULTIPLEX_PIN = PINC

# List of PIN names of pins that are connected to the multiplexing IRF9520
# MOSFETs. You can define up to eight unless you use a custom ISR that can
# toggle PINs on multiple PORTs.
# Note: All pins used for multiplexing must share the same DDR, PORT, and PIN
#       registers. These options are ignored if TLC5940_ENABLE_MULTIPLEXING = 0
# Also: If you add any pins here, do not forget to add those variables to the
#       MULTIPLEXING_DEFINES flag below!
R_PIN = PC0
G_PIN = PC1
B_PIN = PC2

# This avoids adding needless defines if TLC5940_ENABLE_MULTIPLEXING = 0
MULTIPLEXING_DEFINES = -DTLC5940_MULTIPLEX_N=$(TLC5940_MULTIPLEX_N) \
                       -DMULTIPLEX_DDR=$(MULTIPLEX_DDR) \
                       -DMULTIPLEX_PORT=$(MULTIPLEX_PORT) \
                       -DMULTIPLEX_PIN=$(MULTIPLEX_PIN) \
                       -DR_PIN=$(R_PIN) \
                       -DG_PIN=$(G_PIN) \
                       -DB_PIN=$(B_PIN)
endif

# This avoids a redefinition warning if TLC5940_USART_MSPIM = 0
ifeq ($(TLC5940_USART_MSPIM), 1)
BLANK_DEFINES = -DBLANK_DDR=$(BLANK_DDR) \
                -DBLANK_PORT=$(BLANK_PORT) \
                -DBLANK_PIN=$(BLANK_PIN)
endif

# This avoids adding needless defines if TLC5940_USE_GPIOR0 = 0
ifeq ($(TLC5940_USE_GPIOR0), 1)
TLC5940_GPIOR0_DEFINES = -DTLC5940_FLAG_GS_UPDATE=$(TLC5940_FLAG_GS_UPDATE) \
                         -DTLC5940_FLAG_XLAT_NEEDS_PULSE=$(TLC5940_FLAG_XLAT_NEEDS_PULSE)
endif

# This line integrates all options into a single flag called:
#     $(TLC5940_DEFINES)
# which should be appended to the definition of COMPILE below
TLC5940_DEFINES = -DTLC5940_N=$(TLC5940_N) \
                  -DTLC5940_INCLUDE_DC_FUNCS=$(TLC5940_INCLUDE_DC_FUNCS) \
                  -DTLC5940_INCLUDE_SET4_FUNCS=$(TLC5940_INCLUDE_SET4_FUNCS) \
                  -DTLC5940_INCLUDE_DEFAULT_ISR=$(TLC5940_INCLUDE_DEFAULT_ISR) \
                  -DTLC5940_INCLUDE_GAMMA_CORRECT=$(TLC5940_INCLUDE_GAMMA_CORRECT) \
                  -DTLC5940_INLINE_SETGS_FUNCS=$(TLC5940_INLINE_SETGS_FUNCS) \
                  -DTLC5940_ENABLE_MULTIPLEXING=$(TLC5940_ENABLE_MULTIPLEXING) \
                  $(MULTIPLEXING_DEFINES) \
                  -DTLC5940_USART_MSPIM=$(TLC5940_USART_MSPIM) \
                  -DTLC5940_PWM_BITS=$(TLC5940_PWM_BITS) \
                  -DTLC5940_USE_GPIOR0=$(TLC5940_USE_GPIOR0) \
                  $(BLANK_DEFINES) \
                  $(TLC5940_GPIOR0_DEFINES) \
                  -DDCPRG_DDR=$(DCPRG_DDR) \
                  -DDCPRG_PORT=$(DCPRG_PORT) \
                  -DDCPRG_PIN=$(DCPRG_PIN) \
                  -DVPRG_DDR=$(VPRG_DDR) \
                  -DVPRG_PORT=$(VPRG_PORT) \
                  -DVPRG_PIN=$(VPRG_PIN) \
                  -DXLAT_DDR=$(XLAT_DDR) \
                  -DXLAT_PORT=$(XLAT_PORT) \
                  -DXLAT_PIN=$(XLAT_PIN)

# ---------- End TLC5940 Configuration Section ----------


# Tune the lines below only if you know what you are doing:

AVRDUDE    = avrdude $(PROGRAMMER) -p $(DEVICE)
COMPILE    = avr-gcc -std=gnu99 -Wall -Wextra -Werror -Winline -mint8 -O3 -funroll-loops -DF_CPU=$(CLOCK) -mmcu=$(DEVICE) $(TLC5940_DEFINES)
#COMPILE    = avr-gcc -std=gnu99 -Wall -Wextra -Werror -Winline -O3 -funroll-loops -DF_CPU=$(CLOCK) -mmcu=$(DEVICE) $(TLC5940_DEFINES)

LINK_FLAGS = -lc -lm

# symbolic targets:
all:	main.hex

.c.o:
	$(COMPILE) -c $< -o $@

.S.o:
	$(COMPILE) -x assembler-with-cpp -c $< -o $@
# "-x assembler-with-cpp" should not be necessary since this is the default
# file type for the .S (with capital S) extension. However, upper case
# characters are not always preserved on Windows. To ensure WinAVR
# compatibility define the file type manually.

.c.s:
	$(COMPILE) -S $< -o $@

flash:	all
	$(AVRDUDE) -U flash:w:main.hex:i

pflash:	all
	$(AVRDUDE) -n -U flash:w:main.hex:i

fuse:
	$(AVRDUDE) $(FUSES)

# Xcode uses the Makefile targets "", "clean" and "install"
install: flash fuse

# if you use a bootloader, change the command below appropriately:
load: all
	bootloadHID main.hex

clean:
	rm -f main.hex main.elf $(OBJECTS)

# file targets:
main.elf: $(OBJECTS)
	$(COMPILE) -o main.elf $(OBJECTS) $(LINK_FLAGS)

main.hex: main.elf
	rm -f main.hex
	avr-objcopy -j .text -j .data -O ihex main.elf main.hex
# If you have an EEPROM section, you must also create a hex file for the
# EEPROM and add it to the "flash" target.

# Targets for code debugging and analysis:
disasm:	main.elf
	avr-objdump -d main.elf

cpp:
	$(COMPILE) -E main.c

.lst.o:
	$(COMPILE) -S -g -c $< -o $@

%.lst: %.c
	{ echo '.psize 0' ; $(COMPILE) -S -g -o - $< ; } | avr-as -alhd -mmcu=$(DEVICE) -o /dev/null - > $@
