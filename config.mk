RISCV_CC = riscv32-unknown-elf-gcc
RISCV_AR = riscv32-unknown-elf-ar
ARCH = rv32i_zicsr

CORE_SECTION = -Wl,-Ttext=00010000,-Tdata=80000000,--section-start,.rodata=00020000