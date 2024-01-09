/*
 * Copyright (c) 2006-2019, RT-Thread Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2017-07-24     Tanek        the first version
 * 2018-11-12     Ernest Chen  modify copyright
 */

#include <stdint.h>
#include <rthw.h>
#include <rtthread.h>
#include <tang9k.h>

void reset_data(rt_uint32_t *_bss_start, rt_uint32_t *_bss_end)
{
    for (; _bss_start < _bss_end; _bss_start++)
    {
        *_bss_start = 0;
    }
    // Copy rodata to data
    for (rt_size_t i = 0; i < Core_Memory_Copy_Count; i++)
    {
        ((volatile rt_uint32_t *)Core_Memory_Copy_To)[i] = ((volatile rt_uint32_t *)Core_Memory_Copy_Start)[i];
    }
}

static void ostick_config(rt_uint32_t ticks)
{
    /* set value */
    System_Timer_Set_Timecmp(ticks);
    /* enable interrupt */
    Core_Interrupt_Enable_SetBits(Core_Interrupt_Enable_System_Timer);
    /* clear value */
    System_Timer_Set_Time(0);
}

static void uart_init(void)
{
    UART_Set_Baud(RT_UART_BADU);
}

#if defined(RT_USING_USER_MAIN) && defined(RT_USING_HEAP)
#define RT_HEAP_SIZE 1024
static uint32_t rt_heap[RT_HEAP_SIZE]; // heap default size: 4K(1024 * 4)
RT_WEAK void *rt_heap_begin_get(void)
{
    return rt_heap;
}

RT_WEAK void *rt_heap_end_get(void)
{
    return rt_heap + RT_HEAP_SIZE;
}
#endif

/**
 * This function will initial your board.
 */
void rt_hw_board_init()
{
    /* UART Init */
    uart_init();
    /* System Tick Configuration */
    ostick_config(SystemCoreClock / RT_TICK_PER_SECOND);
    /* Call components board initial (use INIT_BOARD_EXPORT()) */
#ifdef RT_USING_COMPONENTS_INIT
    rt_components_board_init();
#endif

#if defined(RT_USING_USER_MAIN) && defined(RT_USING_HEAP)
    rt_system_heap_init(rt_heap_begin_get(), rt_heap_end_get());
#endif
}

// Trap handler function
void Trap_Handler(rt_base_t mcause, rt_base_t mepc, rt_base_t sp)
{
    if (mcause == Core_Interrupt_Cause_System_Timer)
    {
        rt_tick_increase();
        /* clear value */
        System_Timer_Set_Time(0);
    }
}

void rt_hw_console_output(const char *str)
{
    rt_size_t i = 0, size = 0;
    size = rt_strlen(str);
    for (i = 0; i < size; i++)
    {
        if (*(str + i) == '\n')
        {
            UART_Transmit('\r');
        }
        UART_Transmit(str[i]);
    }
}
