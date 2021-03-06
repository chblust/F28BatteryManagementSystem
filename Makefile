PROJECT_ROOT = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SRC = $(PROJECT_ROOT)src/
INC = $(PROJECT_ROOT)inc/
BIN = $(PROJECT_ROOT)bin/

CXX = avr-gcc
CC = avr-gcc

OBJCOPY = avr-objcopy

MODULE_NAMES = adc ioport usart multiplex sn74lv4051a thermistor temp_data temp_monitor fault_status shutdown_control config temp_monitor_dbc can can_data watchdog task_watchdog reset_handler
MODULES = $(foreach n, $(MODULE_NAMES), $(SRC)$n/)

INCLUDE_DIRS = $(MODULES) $(INC)
INC_PARAMS=$(foreach d, $(INCLUDE_DIRS), -I$d)

CFLAGS += -mmcu=at90can128
CFLAGS += --std=gnu99
CFLAGS += -lm
CFLAGS += -u
CFLAGS += vfprintf
CFLAGS += -lprintf_flt
CFLAGS += -Xlinker
CFLAGS += -Map=output.map 

C_DEFINES = GCC_MEGA_AVR F_CPU=8000000UL CAN_BAUDRATE=1000
C_DEFINE_PARAMS = $(foreach d, $(C_DEFINES), -D$d)

all:	at90.hex

at90.hex: at90.elf
	$(OBJCOPY) -O ihex -j .text -j .data $(BIN)at90.elf $(BIN)at90.hex
	rm *.o

at90.elf: *.o
	-mkdir $(BIN)
	$(CC) -mmcu=at90can128 *.o -o $(BIN)$@ $(CFLAGS)

*.o: $(wildcard $(SRC)*.c) $(foreach n, $(MODULES), $(wildcard $n*.c)) $(SRC)portable/gcc/atmega323/port.c $(SRC)portable/mem_man/heap_1.c
	$(CC) -c $(CFLAGS) $(C_DEFINE_PARAMS) $(INC_PARAMS) $^

clean:
	-rm -fr $(BIN)*.hex $(BIN)*.elf *.o
	-rm -r $(BIN)
