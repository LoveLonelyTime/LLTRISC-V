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
    # Init CLINT
    la a5,_trap_handler
    csrw mtvec, a5
    # Call main
    call main

_trap_handler:
    addi sp,sp,-12
    sw ra,0(sp)
    sw a4,4(sp)
    sw a5,8(sp)
    call trapHandler
    lw ra,0(sp)
    lw a4,4(sp)
    lw a5,8(sp)
    addi sp,sp,12
    mret
