/*!
 * @file        main.c
 *
 * @brief       Main program body
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
#include "usb_config.h"
#include "usbd_hid.h"
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

/*!
 * @brief       Main program
 *
 * @param       None
 *
 * @retval      int
 */
int main(void)
{
    USBD_HID_GPIOInit();

    USBD_HID_Init();

    while (1)
    {
        USBD_HID_Proc();
    }
}

/**@} end of group USBD_HID_Functions */
/**@} end of group USBD_HID */
/**@} end of group Examples */
