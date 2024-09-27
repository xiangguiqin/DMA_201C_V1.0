/**
  ******************************************************************************
  * @file    apm32f10x_conf.h
  * @author  FMD-AE
  * @version V1.0.0
  * @date    2021-8-2
  * @brief   Library configuration file.
  ******************************************************************************
*/

#ifndef __APM32F10X_CONF_H
#define __APM32F10X_CONF_H

#ifdef _RTE_
//#include "RTE_Components.h"             /* Component selection */
#endif

#ifdef __cplusplus
 extern "C" {
#endif


#include "apm32f10x_adc.h"



#include "apm32f10x_bakpr.h"



#include "apm32f10x_can.h"



#include "apm32f10x_crc.h"



#include "apm32f10x_dac.h"



#include "apm32f10x_dbgmcu.h"



#include "apm32f10x_dma.h"



#include "apm32f10x_dmc.h"



#include "apm32f10x_eint.h"



#include "apm32f10x_fmc.h"



#include "apm32f10x_gpio.h"



#include "apm32f10x_i2c.h"



#include "apm32f10x_iwdt.h"



#include "apm32f10x_misc.h"  



#include "apm32f10x_pmu.h"



#include "apm32f10x_qspi.h"



#include "apm32f10x_rcm.h"



#include "apm32f10x_rtc.h"



#include "apm32f10x_sci2c.h"



#include "apm32f10x_sdio.h"



#include "apm32f10x_smc.h"



#include "apm32f10x_spi.h"



#include "apm32f10x_tmr.h"



#include "apm32f10x_usart.h"



#include "apm32f10x_wwdt.h"




#include "stdio.h"   

#ifdef  USE_FULL_ASSERT

/**
  * @brief  The assert_param macro is used for function's parameters check.
  * @param  expr: If expr is false, it calls assert_failed function which reports 
  *         the name of the source file and the source line number of the call 
  *         that failed. If expr is true, it returns no value.
  * @retval None
  */
  #define assert_param(expr) ((expr) ? (void)0 : assert_failed((uint8_t *)__FILE__, __LINE__))
/* Exported functions ------------------------------------------------------- */
  void assert_failed(uint8_t* file, uint32_t line);
#else
  #define assert_param(expr) ((void)0)
#endif /* USE_FULL_ASSERT */
#ifdef __cplusplus
}
#endif  
#endif /* __APM32F10X_CONF_H */

/************************ (C) COPYRIGHT FMD *****END OF FILE****/
