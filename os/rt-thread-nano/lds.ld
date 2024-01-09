SECTIONS
{
    . = 0x00010000;
    .text : { 
        *(.text .text.*)
    }

    . = 0x00020000;
    .rodata : { 
        *(.rodata .rodata.*)
        . = ALIGN(4);

        /* section information for finsh shell */
        __fsymtab_start = .;
        KEEP(*(FSymTab))
        __fsymtab_end = .;
        . = ALIGN(4);
        __vsymtab_start = .;
        KEEP(*(VSymTab))
        __vsymtab_end = .;
        . = ALIGN(4);

        /* section information for initial. */
        . = ALIGN(4);
        __rt_init_start = .;
        KEEP(*(SORT(.rti_fn*)))
        __rt_init_end = .;
        . = ALIGN(4);

        /* section information for modules */
        . = ALIGN(4);
        __rtmsymtab_start = .;
        KEEP(*(RTMSymTab))
        __rtmsymtab_end = .;
    }

    . = 0x80000000;
    .data : {
        __DATA_BEGIN__ = .;
        *(.data)
    }
    __bss_start = .;
    .bss : { 
        *(.sbss)
        *(.bss)
        . = ALIGN(4);
    }
    __BSS_END__ = .;
    __global_pointer$ = MIN(__bss_start + 0x800,
		            MAX(__DATA_BEGIN__ + 0x800, __BSS_END__ - 0x800));
}
