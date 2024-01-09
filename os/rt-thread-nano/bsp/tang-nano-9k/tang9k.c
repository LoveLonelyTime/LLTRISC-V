#include <tang9k.h>
#include <rthw.h>
#include <riscv-ops.h>

// Core function

void Core_Debug_Transmit(rt_uint32_t ch)
{
    HWREG32(Core_Debug_Char_Port) = ch;
}
void Core_Debug_Assert(rt_uint32_t assertion)
{
    HWREG32(Core_Debug_Assert_Port) = assertion ? Core_Debug_Assert_OK : Core_Debug_Assert_Unexpected;
}

void Core_Interrupt_Enable_SetBits(rt_uint32_t bits)
{
    set_csr(mie, bits);
}

void Core_Interrupt_Enable_ResetBits(rt_uint32_t bits)
{
    clear_csr(mie, bits);
}

rt_uint32_t Core_Interrupt_Enable_Get(void)
{
    return read_csr(mie);
}

rt_uint32_t Core_Interrupt_Pending_Get(void)
{
    return read_csr(mip);
}

// System timer function

/*
    Set system timer time
*/
void System_Timer_Set_Time(rt_uint64_t val)
{
    System_Timer->mtime = (rt_uint32_t)val;
    System_Timer->mtimeh = (rt_uint32_t)(val >> 32);
}

/*
    Get system timer time
*/
rt_uint64_t System_Timer_Get_Time(void)
{
    rt_uint64_t res = 0;
    res |= ((rt_uint64_t)System_Timer->mtime);
    res |= ((rt_uint64_t)System_Timer->mtimeh) << 32;
    return res;
}

/*
    Set system timer timecmp
*/
void System_Timer_Set_Timecmp(rt_uint64_t val)
{
    System_Timer->mtimecmp = (rt_uint32_t)val;
    System_Timer->mtimecmph = (rt_uint32_t)(val >> 32);
}

/*
    Get system timer timecmp
*/
rt_uint64_t System_Timer_Get_Timecmp(void)
{
    rt_uint64_t res = 0;
    res |= ((rt_uint64_t)System_Timer->mtimecmp);
    res |= ((rt_uint64_t)System_Timer->mtimecmph) << 32;
    return res;
}

// UART function
void UART_Set_Baud(rt_uint32_t baud)
{
    UART->baudcmp = baud;
}

rt_uint32_t UART_Status_Read(void)
{
    return UART->status;
}

void UART_Status_SetBits(rt_uint32_t bits)
{
    UART->status |= bits;
}

void UART_Status_ResetBits(rt_uint32_t bits)
{
    UART->status &= ~bits;
}

void UART_Transmit(rt_uint32_t data)
{
    while (UART_Status_Read() & UART_Status_Sending)
        ;
    UART->send_data = data;
    UART_Status_SetBits(UART_Status_Sending);
}

rt_uint32_t UART_Receive(void)
{
    rt_uint32_t data;
    while (!(UART_Status_Read() & UART_Status_Received))
        ;
    data = UART->read_data;
    UART_Status_ResetBits(UART_Status_Received);
    return data;
}
