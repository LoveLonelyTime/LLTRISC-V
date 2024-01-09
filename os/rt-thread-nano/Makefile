include ../../config.mk

defalut : all

INC = -Iinclude -Ilibcpu/risc-v/lltrisc-v -Ibsp/tang-nano-9k -Icomponents/finsh
C_SRCS = $(wildcard src/*.c) $(wildcard libcpu/risc-v/lltrisc-v/*.c) $(wildcard bsp/tang-nano-9k/*.c) $(wildcard components/finsh/*.c)
ASM_SRCS = bsp/tang-nano-9k/startup.S $(wildcard libcpu/risc-v/lltrisc-v/*.S)

all : rt-thread-nano-tang9k.elf

rt-thread-nano-tang9k.elf : $(C_SRCS) $(ASM_SRCS)
	$(RISCV_CC) -Wl,-T,lds.ld -march=$(ARCH) $(INC) -nostdlib --entry=_lltriscv_startup $(ASM_SRCS) $(C_SRCS) -lgcc -o rt-thread-nano-tang9k.elf

.PHONY : clean test
clean :
	-$(RM) rt-thread-nano-tang9k.elf
	