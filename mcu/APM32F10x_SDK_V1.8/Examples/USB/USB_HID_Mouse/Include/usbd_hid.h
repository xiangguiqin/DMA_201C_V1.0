/*!
 * @file        usbd_hid.h
 *
 * @brief       HID head file
 *
 * @version     V1.0.1
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
#ifndef __USBD_HID_H
#define __USBD_HID_H

/* Includes */
#include "usbd_init.h"

/** @addtogroup Examples
  @{
*/

/** @addtogroup USB_HID_Mouse
  @{
*/

/** @defgroup USB_HID_Mouse_Enumerates Enumerates
  @{
*/

/**
 * @brief   Key enumeration
 */
enum
{
    HID_MOUSE_KEY_NULL,
    HID_MOUSE_KEY_LEFT,
    HID_MOUSE_KEY_RIGHT,
    HID_MOUSE_KEY_UP,
    HID_MOUSE_KEY_DOWN,
};

/**@} end of group USB_HID_Mouse_Enumerates */

/** @defgroup USB_HID_Mouse_Functions Functions
  @{
*/

void HidMouse_Init(void);
void HidMouse_Proc(void);
void HidMouse_SetConfigCallBack(void);

/**@} end of group USB_HID_Mouse_Functions */
/**@} end of group USB_HID_Mouse */
/**@} end of group Examples */

#endif /* __USBD_HID_H */
