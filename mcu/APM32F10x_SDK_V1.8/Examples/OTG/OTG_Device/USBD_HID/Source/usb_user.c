/*!
 * @file        usb_user.c
 *
 * @brief       usb user configuration
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
#include "usb_user.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBD_HID
  @{
  */

/** @defgroup USBD_HID_Functions Functions
  @{
  */

static void USB_USER_DeviceReset(void);
static void USB_USER_DeviceSuspend(void);
static void USB_USER_DeviceResume(void);
#if (DELAY_SOURCE != USE_DEFAULT)
static void USB_USER_Delay(uint32_t cnt);
#endif

/**@} end of group USBD_HID_Functions */

/** @defgroup USBD_HID_Variables Variables
  @{
  */

USB_UserCallBack_T g_userCallback =
{
    USB_USER_DeviceReset,
    USB_USER_DeviceSuspend,
    USB_USER_DeviceResume,
#if (DELAY_SOURCE == USE_DEFAULT)
    NULL
#else
    USB_USER_Delay
#endif
};

/**@} end of group USBD_HID_Variables*/

/** @defgroup USBD_HID_Functions Functions
  @{
  */

static void USB_USER_DeviceReset(void)
{
}

static void USB_USER_DeviceSuspend(void)
{
}

static void USB_USER_DeviceResume(void)
{
}

#if (DELAY_SOURCE != USE_DEFAULT)
static void USB_USER_Delay(uint32_t cnt)
{
    __IO uint32_t i = 0;
    __IO uint32_t j = 0;
    __IO uint32_t delayCnt;

    delayCnt = (cnt*6);

    do
    {
        i++;
        j++;
    }
    while (i < cnt);
}
#endif

/**@} end of group USBD_HID_Functions */
/**@} end of group USBD_HID */
/**@} end of group Examples */
