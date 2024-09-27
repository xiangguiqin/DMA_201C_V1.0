/*!
 * @file        main.h
 *
 * @brief       Main program body
 *
 * @version     V1.0.3
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
#ifndef __MAIN_H
#define __MAIN_H

/* Includes */
#include <stdio.h>
#include "Board.h"
#include "apm32f10x_tmr.h"

/** @addtogroup Examples
  @{
*/

/** @addtogroup TMR_32BitCount
  @{
*/

/** @defgroup TMR_32BitCount_Functions Functions
  @{
*/

void Delay(void);
extern volatile uint32_t tick;

#endif /* __MAIN_H */

/**@} end of group TMR_32BitCount_Functions */
/**@} end of group TMR_32BitCount */
/**@} end of group Examples */
