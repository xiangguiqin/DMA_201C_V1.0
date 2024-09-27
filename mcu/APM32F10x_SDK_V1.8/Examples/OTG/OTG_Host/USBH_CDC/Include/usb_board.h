/*!
 * @file       usb_board.h
 *
 * @brief      Header file for USB Board
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
#ifndef __USB_BOARD_H
#define __USB_BOARD_H

/* Includes */
#include "usb_user.h"
#include "drv_usb.h"
#include "Board.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBH_CDC
  @{
  */

/** @defgroup USBH_CDC_Macros Macros
  @{
*/

#define DEBUG_USART    USART2

/**@} end of group USBH_CDC_Macros*/

/** @defgroup USBH_CDC_Functions Functions
  @{
*/

void USB_HardwareInit(void);

void USB_Timer_IRQHandler(void);
void USB_usDelay(uint32_t delayTime);
void USB_msDelay(uint32_t delayTime);
void ConfigDelayTimer(void);
void APM_BOARD_COMInit(COM_TypeDef COM, USART_Config_T* configStruct);

/**@} end of group USBH_CDC_Functions */
/**@} end of group USBH_CDC */
/**@} end of group Examples */

#endif /*__USB_BOARD_H */
