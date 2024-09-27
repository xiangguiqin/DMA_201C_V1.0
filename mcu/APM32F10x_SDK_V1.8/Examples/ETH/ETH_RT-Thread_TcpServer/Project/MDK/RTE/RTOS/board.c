/*
 * Copyright (c) 2006-2019, RT-Thread Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2021-05-24                  the first version
 */

#include <rthw.h>
#include <rtthread.h>
#include "main.h"

#if defined(RT_USING_USER_MAIN) && defined(RT_USING_HEAP)
/*
 * Please modify RT_HEAP_SIZE if you enable RT_USING_HEAP
 * the RT_HEAP_SIZE max value = (sram size - ZI size), 1024 means 1024 bytes
 */
#define RT_HEAP_SIZE (15*1024)
static rt_uint8_t rt_heap[RT_HEAP_SIZE];

RT_WEAK void *rt_heap_begin_get(void)
{
    return rt_heap;
}

RT_WEAK void *rt_heap_end_get(void)
{
    return rt_heap + RT_HEAP_SIZE;
}
#endif

void rt_os_tick_callback(void)
{
    rt_interrupt_enter();
    
    rt_tick_increase();

    rt_interrupt_leave();
}

void SysTick_Handler(void)
{
    rt_os_tick_callback();
}

/**
 * This function will initial your board.
 */
void rt_hw_board_init(void)
{
//#error "TODO 1: OS Tick Configuration."
    /* 
     * TODO 1: OS Tick Configuration
     * Enable the hardware timer and call the rt_os_tick_callback function
     * periodically with the frequency RT_TICK_PER_SECOND. 
     */
    SysTick_Config( SystemCoreClock / 1000);

    /* Call components board initial (use INIT_BOARD_EXPORT()) */
#ifdef RT_USING_COMPONENTS_INIT
    rt_components_board_init();
#endif

#if defined(RT_USING_USER_MAIN) && defined(RT_USING_HEAP)
    rt_system_heap_init(rt_heap_begin_get(), rt_heap_end_get());
#endif
}

#ifdef RT_USING_CONSOLE

static int uart_init(void)
{
//#error "TODO 2: Enable the hardware uart and config baudrate."
    GPIO_Config_T GPIO_ConfigStruct;
    USART_Config_T USART_ConfigStruct;
    
    /* Enable GPIO peripheral Clock */
    RCM_EnableAPB2PeriphClock(RCM_APB2_PERIPH_GPIOC);
    
    /* Enable USART peripheral Clock */
    RCM_EnableAPB1PeriphClock(RCM_APB1_PERIPH_UART4);

    /* Configure USART Tx as alternate function push-pull */
    GPIO_ConfigStruct.mode = GPIO_MODE_AF_PP;
    GPIO_ConfigStruct.pin = GPIO_PIN_10;
    GPIO_ConfigStruct.speed = GPIO_SPEED_50MHz;
    GPIO_Config(GPIOC, &GPIO_ConfigStruct);

    /* Configure USART Rx as input floating */
    GPIO_ConfigStruct.mode = GPIO_MODE_IN_FLOATING;
    GPIO_ConfigStruct.pin = GPIO_PIN_11;
    GPIO_Config(GPIOC, &GPIO_ConfigStruct);

    /* USART configuration */
    USART_ConfigStruct.baudRate = 115200;
    USART_ConfigStruct.hardwareFlow = USART_HARDWARE_FLOW_NONE;
    USART_ConfigStruct.mode = USART_MODE_TX_RX;
    USART_ConfigStruct.parity = USART_PARITY_NONE;
    USART_ConfigStruct.stopBits = USART_STOP_BIT_1;
    USART_ConfigStruct.wordLength = USART_WORD_LEN_8B;
    USART_Config(UART4, &USART_ConfigStruct);
    
    /* Enable USART */
    USART_Enable(UART4);

    return 0;
}
INIT_BOARD_EXPORT(uart_init);

void rt_hw_console_output(const char *str)
{
//#error "TODO 3: Output the string 'str' through the uart."
    rt_enter_critical();

    while (*str != '\0')
    {
        if (*str == '\n')
        {
            while (USART_ReadStatusFlag(UART4, USART_FLAG_TXBE) == RESET);

            USART_TxData(UART4, '\r');
        }

        while (USART_ReadStatusFlag(UART4, USART_FLAG_TXBE) == RESET);

        USART_TxData(UART4, *str++ );
    }

    rt_exit_critical();
}

char rt_hw_console_getchar(void)
{
    int ch = -1;

    if (USART_ReadStatusFlag(UART4, USART_FLAG_RXBNE) != RESET)
    {
        ch = (int)USART_RxData(UART4);
        USART_ClearStatusFlag(UART4, USART_FLAG_RXBNE);
    }
    else
    {
        if (USART_ReadStatusFlag(UART4, USART_FLAG_OVRE) != RESET)
        {
            USART_ClearStatusFlag(UART4, USART_FLAG_OVRE);
        }

        rt_thread_mdelay(10);
    }

    return ch;
}

#endif

