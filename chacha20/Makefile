LDSCRIPT   = ../libopencm3/lib/stm32/f4/stm32f405x6.ld
LIBNAME    = opencm3_stm32f4
ARCH_FLAGS = -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16
DEFINES    = -DSTM32F4
OBJS       = stm32f4_wrapper.o

all: chacha20test.bin \
		 chacha20speed.bin

chacha20.o: chacha20.c chacha20.s
	$(CC) $(CFLAGS) -c chacha20.c -o chacha20_c.o
	$(CC) $(CFLAGS) -c chacha20.s -o chacha20_s.o
	$(CC) $(CFLAGS) -o chacha20.o -r chacha20_c.o chacha20_s.o

chacha20test.elf: chacha20.o chacha20.h test.o $(OBJS) $(LDSCRIPT)
		$(LD) -o $@ test.o chacha20.o $(OBJS) $(LDFLAGS) -l$(LIBNAME)

chacha20speed.elf: chacha20.o chacha20.h speed.o $(OBJS) $(LDSCRIPT)
		$(LD) -o $@ speed.o chacha20.o $(OBJS) $(LDFLAGS) -l$(LIBNAME)


include ../common/make.mk
