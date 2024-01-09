#include <rtconfig.h>

# Startup file
    .text
    .align	4

.globl	_lltriscv_startup
_lltriscv_startup:
    # Load gp
    .option push
    .option norelax
    la  gp, __global_pointer$
    .option pop
    # Setup stack
    li  sp, _sp
    # bss clear
    la a0, __bss_start
    la a1, __BSS_END__
    call reset_data
    # Init CLINT mtvec
    la a5, irq_entry
    csrw mtvec, a5
    # Call entry
    call entry
