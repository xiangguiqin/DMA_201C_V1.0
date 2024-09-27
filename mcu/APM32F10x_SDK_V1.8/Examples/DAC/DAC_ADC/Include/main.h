/*!
 * @file        main.h
 *
 * @brief       Main program body
 *
 * @version     V1.0.0
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

/* Includes */
#include "Board.h"
#include "apm32f10x_adc.h"
#include "apm32f10x_dac.h"
#include "apm32f10x_rcm.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup DAC_ADC
  @{
  */

/** @defgroup DAC_ADC_Functions Functions
  @{
*/
void ADC_Isr(void);

/**@} end of group DAC_ADC_Functions */
/**@} end of group DAC_ADC */
/**@} end of group Examples */

#endif
