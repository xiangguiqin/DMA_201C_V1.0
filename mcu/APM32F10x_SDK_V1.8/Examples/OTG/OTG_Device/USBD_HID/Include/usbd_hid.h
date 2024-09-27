/*!
 * @file        usbd_hid.h
 *
 * @brief       HID core funtion header file
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

/* Includes */
#include "usbd_core.h"
#include "usbd_init.h"
#include "usbd_class_hid.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBD_HID
  @{
  */

/** @defgroup USBD_HID_Enumerates Enumerates
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

/**@} end of group USBD_HID_Enumerates*/

/** @defgroup USBD_HID_Functions Functions
  @{
  */

static void USBD_HID_SetConfigCallBack(void);
static void USBD_HID_GetReportDescriptor(void);

void USBD_HID_Init(void);
void USBD_HID_Proc(void);
void USBD_HID_SetConfigCallBack(void);
void USBD_HID_GPIOInit(void);

/**@} end of group USBD_HID_Functions */
/**@} end of group USBD_HID */
/**@} end of group Examples */
