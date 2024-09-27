/*!
 * @file        main.h
 *
 * @brief       Main program body
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
#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
  extern "C" {
#endif

/* Includes */
#include "Board.h"
#include "apm32f10x_dma.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup DMA_MemoryToMemory
  @{
  */

/** @defgroup DMA_MemoryToMemory_Enumerates Enumerates
  @{
  */

enum {FAILED, PASSED};

/**@} end of group DMA_MemoryToMemory_Enumerates*/

/** @defgroup DMA_MemoryToMemory_Variables Variables
  @{
  */

extern volatile uint32_t CurrDataCounterEnd;

/**@} end of group DMA_MemoryToMemory_Variables */

/** @defgroup DMA_MemoryToMemory_Functions Functions
  @{
  */

void RCM_Configuration(void);
void NVIC_Configuration(void);
uint8_t Buffercmp(const uint32_t* pBuffer, uint32_t* pBuffer1, uint16_t BufferLength);

/**@} end of group DMA_MemoryToMemory_Functions */
/**@} end of group DMA_MemoryToMemory */
/**@} end of group Examples */

#ifdef __cplusplus
}
#endif

#endif
