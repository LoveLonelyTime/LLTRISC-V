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
    li  sp, 0x8000FFF0
    # Call main
    call main
