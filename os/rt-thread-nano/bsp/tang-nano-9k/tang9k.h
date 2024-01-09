#ifndef __TANG9K_H__
#define __TANG9K_H__

#include <rtthread.h>

#define __IO volatile
#define __I volatile const

/*
    Core
*/
#define Core_Debug_Char_Port 0x00000020
#define Core_Debug_Assert_Port 0x00000010
#define Core_Debug_Assert_OK 0x7F
#define Core_Debug_Assert_Unexpected 0x7C

void Core_Debug_Transmit(rt_uint32_t ch);
void Core_Debug_Assert(rt_uint32_t assertion);

// 0x00020400 - 0x00020800
#define Core_Memory_Copy_Start 0x00021C00
// 256 Word
#define Core_Memory_Copy_Count 256
#define Core_Memory_Copy_To 0x80000000

#define Core_Interrupt_Enable_System_Timer 0x00000080
#define Core_Interrupt_Enable_External_Interrupt 0x00000800
#define Core_Interrupt_Pending_System_Timer 0x00000080
#define Core_Interrupt_Pending_External_Interrupt 0x00000800

void Core_Interrupt_Enable_SetBits(rt_uint32_t bits);
void Core_Interrupt_Enable_ResetBits(rt_uint32_t bits);
rt_uint32_t Core_Interrupt_Enable_Get(void);
rt_uint32_t Core_Interrupt_Pending_Get(void);

#define Core_Interrupt_Cause_System_Timer 0x80000007
#define Core_Interrupt_Cause_External_Interrupt 0x8000000B

/*
    System timer
*/
typedef struct
{
    __IO rt_uint32_t mtime;
    __IO rt_uint32_t mtimeh;
    __IO rt_uint32_t mtimecmp;
    __IO rt_uint32_t mtimecmph;
} System_Timer_TypeDef;

#define System_Timer_BASE 0x20000000
#define System_Timer ((System_Timer_TypeDef *)System_Timer_BASE)

void System_Timer_Set_Time(rt_uint64_t val);
rt_uint64_t System_Timer_Get_Time(void);
void System_Timer_Set_Timecmp(rt_uint64_t val);
rt_uint64_t System_Timer_Get_Timecmp(void);

/*
    UART
*/
typedef struct
{
    __IO rt_uint32_t baudcmp;
    __IO rt_uint32_t send_data;
    __IO rt_uint32_t status;
    __I rt_uint32_t read_data;
} UART_TypeDef;

#define UART_BASE 0x20000100
#define UART ((UART_TypeDef *)UART_BASE)

#define UART_BAUD_9600 (SystemCoreClock / 9600)
void UART_Set_Baud(rt_uint32_t baud);

#define UART_Status_Sending 0x00000001
#define UART_Status_Received 0x00000002
rt_uint32_t UART_Status_Read(void);
void UART_Status_SetBits(rt_uint32_t bits);
void UART_Status_ResetBits(rt_uint32_t bits);
void UART_Transmit(rt_uint32_t data);
rt_uint32_t UART_Receive(void);
#endif
