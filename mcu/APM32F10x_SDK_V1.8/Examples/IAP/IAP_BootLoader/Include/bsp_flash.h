/*!
 * @file        bsp_flash.h
 *
 * @brief       Header for bsp_flash.c module
 *
 * @version     V1.0.0
 *
* @date        2022-12-01
 *
 * @attention
 *
 *  Copyright (C) 2022 Geehy Semiconductor
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
#ifndef __BSP_FLASH_H
#define __BSP_FLASH_H

/* Includes */
#include "main.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup IAP_BootLoader
  @{
  */

/** @addtogroup BSP_FLASH
  @{
  */

/** @defgroup BSP_FLASH_Macros Macros
  @{
  */

#define FLASH_BASE                  (uint32_t)0x08000000

#define FLASH_PAGE_SIZE             ((uint16_t)0x400)

#define USER_APP1_START_ADDRESS     (uint32_t)0x08004000
/* 8 KBytes */
#define USER_APP1_END_ADDRESS       (uint32_t)0x08006000
#define USER_APP1_FLASH_SIZE        (USER_APP1_END_ADDRESS - USER_APP1_START_ADDRESS + 1)

#define USER_APP2_START_ADDRESS     (uint32_t)0x08006000
/* 8 KBytes */
#define USER_APP2_END_ADDRESS       (uint32_t)0x08008000
#define USER_APP2_FLASH_SIZE        (USER_APP2_END_ADDRESS - USER_APP2_START_ADDRESS + 1)

#define USER_FLASH_SIZE             (USER_APP2_END_ADDRESS - USER_APP1_START_ADDRESS + 1)

/**@} end of group BSP_FLASH_Macros */

/** @defgroup BSP_FLASH_Enumerations Enumerations
  @{
  */

/*!
 * @brief    APP type define
 */
typedef enum
{
  APP1 = 0,
  APP2 = 1
} APP_TypeDef;

/*!
 * @brief    FMC operation type define
 */
typedef enum
{
  FMC_OP_SUCCESS,
  FMC_OP_ERROR
} FMC_OP_TypeDef;

/**@} end of group BSP_FLASH_Enumerations */

/** @defgroup BSP_FLASH_Functions Functions
  @{
  */

/* function declaration */
void FLASH_IAP_Init(void);
uint32_t FLASH_IAP_Erase(APP_TypeDef Application);
uint32_t FLASH_IAP_Write(__IO uint32_t* address, uint32_t* data, uint16_t length, APP_TypeDef Application);

/**@} end of group BSP_FLASH_Functions */
/**@} end of group BSP_FLASH */
/**@} end of group IAP_BootLoader */
/**@} end of group Examples */

#endif
