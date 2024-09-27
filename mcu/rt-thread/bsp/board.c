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
#include "sys.h"
#include <cm_backtrace.h>

#define HARDWARE_VERSION               "V1.0.0"
#define SOFTWARE_VERSION               "V0.1.0"

#define PLL_CLOCK       72000000
//#define _SYSTICK_PRI    (*(rt_uint8_t  *)(0xE000ED23UL))

extern uint32_t SystemCoreClock;

//static uint32_t _SysTick_Config(rt_uint32_t ticks)
//{
//    if ((ticks - 1) > 0xFFFFFF)
//    {
//        return 1;
//    }

//    SysTick->LOAD = ticks - 1;
//    NVIC_SetPriority(SysTick_IRQn, (1 << __NVIC_PRIO_BITS) - 1);
//    _SYSTICK_PRI = 0xFF;
//    SysTick->VAL  = 0;
//    SysTick->CTRL = 0x07;

//    return 0;
//}
static rt_err_t exception_hook(void *context) {
    extern long list_thread(void);
    uint8_t _continue = 1;

    rt_enter_critical();

#ifdef RT_USING_FINSH
    list_thread();
#endif

    cm_backtrace_fault(*((uint32_t *)(cmb_get_sp() + sizeof(uint32_t) * 8)), cmb_get_sp() + sizeof(uint32_t) * 9);

    while (_continue == 1);

    return RT_EOK;
}

#if defined(RT_USING_USER_MAIN) && defined(RT_USING_HEAP)
/*
 * Please modify RT_HEAP_SIZE if you enable RT_USING_HEAP
 * the RT_HEAP_SIZE max value = (sram size - ZI size), 1024 means 1024 bytes
 */
#define RT_HEAP_SIZE (6*1024)
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

extern void delay_init(void);
#ifdef RT_USING_CONSOLE
static int rt_uart_init(uint32_t bound);
#endif
/**
 * This function will initial your board.
 */
void rt_hw_board_init(void)
{
	/*
	 * #error "TODO 1: OS Tick Configuration."
     * 
     * TODO 1: OS Tick Configuration
     * Enable the hardware timer and call the rt_os_tick_callback function
     * periodically with the frequency RT_TICK_PER_SECOND. 
     */
	__NVIC_SetPriority(SysTick_IRQn, (1 << __NVIC_PRIO_BITS) - 1);
	delay_init();
#ifdef RT_USING_CONSOLE
	rt_uart_init(115200);
#endif
	/* CmBacktrace initialize */
    cm_backtrace_init("FT32F030xx", HARDWARE_VERSION, SOFTWARE_VERSION);
	
    /* set exception hook */
    rt_hw_exception_install(exception_hook);
	
	
    /* Call components board initial (use INIT_BOARD_EXPORT()) */
#ifdef RT_USING_COMPONENTS_INIT
    rt_components_board_init();
#endif

#if defined(RT_USING_USER_MAIN) && defined(RT_USING_HEAP)
    rt_system_heap_init(rt_heap_begin_get(), rt_heap_end_get());
#endif
}

#ifdef RT_USING_CONSOLE

static int rt_uart_init(uint32_t bound)
{
	//GPIO端口设置
	GPIO_Config_T GPIO_InitStructure;
	USART_Config_T USART_InitStructure;
	
	RCM_EnableAPB2PeriphClock(RCM_APB2_PERIPH_GPIOA);
	RCM_EnableAPB2PeriphClock(RCM_APB2_PERIPH_USART1);

	//GPIOA.9 10
	GPIO_InitStructure.GPIO_Pin = GPIO_PIN_9 | GPIO_PIN_10;
	GPIO_InitStructure.mode = GPIO_MODE_AF_PP;
	GPIO_InitStructure.speed = GPIO_SPEED_50MHz;
	GPIO_Config(GPIOA, &GPIO_InitStructure);

	//USART 初始化设置
	USART_InitStructure.baudRate = bound;//串口波特率
	USART_InitStructure.wordLength = USART_WORD_LEN_8B;//字长为8位数据格式
	USART_InitStructure.stopBits = USART_STOP_BIT_1;//一个停止位
	USART_InitStructure.parity = USART_PARITY_NONE;//无奇偶校验位
	USART_InitStructure.hardwareFlow = USART_HARDWARE_FLOW_NONE;//无硬件数据流控制
	USART_InitStructure.mode = USART_MODE_TX_RX;	//收发模式
	USART_Config(USART1, &USART_InitStructure); //初始化串口1
	
	//Usart1 NVIC 配置
	NVIC_EnableIRQRequest(USART1_IRQn, 2, 0);
	
	USART_Enable(USART1);                    //使能串口1 
	
	USART_EnableInterrupt(USART2, USART_INT_RXBNE);//开启串口接受中断

	return 0;
}
//INIT_BOARD_EXPORT(rt_uart_init);



void rt_hw_console_output(const char *str)
{
	rt_enter_critical();
	
	while(*str != '\0')
	{
		
		if(*str == '\n')
		{
			while(((USART1->STS_B.TXCFLG)&0X40)==0){}//循环发送,直到发送完毕
			USART1->DATA_B.DATA = (uint8_t)'\n';
		}
		
		while(((USART1->STS_B.TXCFLG)&0X40)==0){}//循环发送,直到发送完毕
		USART1->DATA_B.DATA = (uint8_t)*str++;
	}
	
	rt_exit_critical();
}

#endif


#if 0
char rt_hw_console_getchar(void)
{
    /* Note: the initial value of ch must < 0 */
    int ch = -1;
	if(USART_ReadStatusFlag(USART1, USART_FLAG_RXBNE) != RESET){
        //USART_ClearIntFlag(USART1, USART_INT_RXBNE);
        ch = USART_RxData(USART1) & 0xFF;
    }else{
        if(USART_ReadStatusFlag(USART1, USART_FLAG_OVRE) != RESET){
            USART_ClearStatusFlag(USART1, USART_FLAG_OVRE);
        }
        rt_thread_mdelay(10);
    }

    return ch;
}
#endif



