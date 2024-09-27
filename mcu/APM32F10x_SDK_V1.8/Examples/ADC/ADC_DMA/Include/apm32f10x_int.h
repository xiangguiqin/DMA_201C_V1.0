/*!
 * @file        apm32f10x_int.h
 *
 * @brief       This file contains the headers of the interrupt handlers
 *
 * @version     V1.0.2
 *
 * @date        2022-12-01
 *
 * @attention
 *
 *  Copyright (C) 2020-2022 Geehy Semiconductor
 *
 *  You may not use this file except in compliance with the
 *  GEEHY COPYRIGHT NOTICE (GEEHY SOFTWARE PACKAGE LICENSE).
 *
 *  The program is only for reference, which is distributed in the hope
 *  that it will be useful and instructional for customers to develop
 *  their software. Unless required by applicable law or agreed to in
 *  writing, the program is distributed on an "AS IS" BASIS, WITHOUT
 *  ANY WARRANTY OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the GEEHY SOFTWARE PACKAGE LICENSE for the governing permissions
 *  and limitations under the License.
 */

/* Define to prevent recursive inclusion */
#ifndef __APM32F10X_INT_H
#define __APM32F10X_INT_H

#ifdef __cplusplus
  extern "C" {
#endif

/* Includes */
#include "apm32f10x.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup ADC_DMA
  @{
  */

/** @defgroup ADC_DMA_INT_Functions INT_Functions
  @{
  */

void NMI_Handler(void);
void HardFault_Handler(void);
void MemManage_Handler(void);
void BusFault_Handler(void);
void UsageFault_Handler(void);
void SVC_Handler(void);
void DebugMon_Handler(void);
void PendSV_Handler(void);
void SysTick_Handler(void);

/**@} end of group ADC_DMA_INT_Functions */
/**@} end of group ADC_DMA */
/**@} end of group Examples */

#ifdef __cplusplus
}
#endif

#endif /*__APM32F10X_INT_H */
