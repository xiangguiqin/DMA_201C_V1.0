/**
  ******************************************************************************
  * @file    			main.c
  * @author  			FMD AE
  * @brief   		
  * @version 			V1.0.0           
  * @data		 		2021-07-01
	******************************************************************************
  */

/* Includes ------------------------------------------------------------------*/
#include "sys.h"
#include "main.h"
#include "delay.h"
#if SYSTEM_SUPPORT_OS
#include "rtthread.h"
#endif

/******************************************************************************/
ALIGN(RT_ALIGN_SIZE)
rt_uint8_t gsv_main_thread_stack[GSV_MAIN_THREAD_STACK_SIZE];
//ÈÎÎñ¾ä±ú
struct rt_thread gsv_main_thread;

extern uint8_t LogicOutputSel;
/* Private functions ---------------------------------------------------------*/
static void MX_GPIO_Init(void);


/**
  * @brief  Main program.
  * @param  None
  * @retval None
  */
uint32_t SYSCLK;
uint32_t HCLK;
uint32_t PCLK1;
uint32_t PCLK2;

int main(void)
{
    /* get clk frequency */
    SYSCLK = RCM_ReadSYSCLKFreq();
    HCLK = RCM_ReadHCLKFreq();
    RCM_ReadPCLKFreq(&PCLK1, &PCLK2);
    
	/* Initialize all configured peripherals */
	MX_GPIO_Init();
	
	//mb_init();
	
	//if(LogicOutputSel == 1)
	//{
		GPIO_SetBit(DUT_RST_GPIO_Port, DUT_RST_Pin);
		rt_thread_mdelay(100);
		GPIO_ResetBit(DUT_RST_GPIO_Port, DUT_RST_Pin);
		rt_thread_mdelay(100);
		GPIO_SetBit(DUT_RST_GPIO_Port, DUT_RST_Pin);
	//}
	//else
	//{
		rt_thread_mdelay(100);
	//}
	
	rt_enter_critical();
	rt_thread_init(&gsv_main_thread
                   ,"gsv main thread"
                   ,GsvMain_thread_entry
                   ,RT_NULL
                   ,&gsv_main_thread_stack[0]
                   ,GSV_MAIN_THREAD_STACK_SIZE
                   ,GSV_MAIN_THREAD_PRIORITY
                   ,GSV_MAIN_THREAD_TIMESLICE
				  );
	rt_exit_critical();
	rt_thread_startup(&gsv_main_thread);
	
	
//	rt_enter_critical();
//	rt_thread_init(&mbpoll_thread
//                   ,"MB Poll thread"
//                   ,MBPoll_thread_entry
//                   ,RT_NULL
//                   ,&MBPoll_thread_stack[0]
//                   ,MBPOLL_THREAD_STACK_SIZE
//                   ,MBPOLL_THREAD_PRIORITY
//                   ,MBPOLL_THREAD_TIMESLICE
//                  );
//	rt_exit_critical();
//	rt_thread_startup(&mbpoll_thread);
	

	/* Infinite loop */
	while (1)
	{
		//edid_update();
		rt_thread_mdelay(5);
	}
}


static void MX_GPIO_Init(void)
{

	GPIO_Config_T GPIO_InitStruct;
	
	/* GPIO Ports Clock Enable */
    RCM_EnableAPB2PeriphClock(RCM_APB2_PERIPH_GPIOA | RCM_APB2_PERIPH_GPIOB);
    
	/*Configure GPIO GPIO_Pin Output Level */
	GPIO_SetBit(GPIOA, DUT_RST_Pin|LED0_Pin|LED1_Pin|LED2_Pin);
	
	/*Configure GPIO GPIO_Pin Output Level */
	GPIO_SetBit(GPIOB, I2C_SCL_Pin|I2C_SDA_Pin);
	
	/*Configure GPIO GPIO_Pin : DUT_RST_Pin */
	GPIO_InitStruct.mode = GPIO_MODE_OUT_PP;
	GPIO_InitStruct.GPIO_Pin = DUT_RST_Pin;
	GPIO_InitStruct.speed = GPIO_SPEED_50MHz;
	GPIO_Config(DUT_RST_GPIO_Port, &GPIO_InitStruct);
	
	/*Configure GPIO pins : LED0_Pin LED1_Pin LED2_Pin */
	GPIO_InitStruct.mode = GPIO_MODE_OUT_PP;
	GPIO_InitStruct.GPIO_Pin = LED0_Pin|LED1_Pin|LED2_Pin;
	GPIO_InitStruct.speed = GPIO_SPEED_50MHz;
	GPIO_Config(GPIOA, &GPIO_InitStruct);
	
	/*Configure GPIO GPIO_Pin : KEY0_Pin */
	GPIO_InitStruct.mode = GPIO_MODE_IN_PU;
	GPIO_InitStruct.GPIO_Pin = KEY0_Pin;
	GPIO_InitStruct.speed = GPIO_SPEED_50MHz;
	GPIO_Config(KEY0_GPIO_Port, &GPIO_InitStruct);
	
	/*Configure GPIO pins : AVMUTE_Pin INT_Pin */
	GPIO_InitStruct.mode = GPIO_MODE_IN_PU;
	GPIO_InitStruct.GPIO_Pin = AVMUTE_Pin|INT_Pin;
	GPIO_InitStruct.speed = GPIO_SPEED_50MHz;
	GPIO_Config(GPIOB, &GPIO_InitStruct);
	
	/*Configure GPIO pins : I2C_SCL_Pin I2C_SDA_Pin */
	GPIO_InitStruct.mode = GPIO_MODE_IN_PU;
	GPIO_InitStruct.GPIO_Pin = I2C_SCL_Pin|I2C_SDA_Pin;
	GPIO_InitStruct.speed = GPIO_SPEED_50MHz;
	GPIO_Config(GPIOB, &GPIO_InitStruct);
	
	/**/
//	HAL_I2CEx_EnableFastModePlus(SYSCFG_CFGR1_I2C_FMP_PB8);
	
	/**/
//	HAL_I2CEx_EnableFastModePlus(SYSCFG_CFGR1_I2C_FMP_PB9);
	
}




/**
  * @}
  */

/**
  * @}
  */

/************************ (C) COPYRIGHT FMD *****END OF FILE****/
