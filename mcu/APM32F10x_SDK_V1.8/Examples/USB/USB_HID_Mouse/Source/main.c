/*!
 * @file        main.c
 *
 * @brief       Main program body
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

/* Includes */
#include "main.h"
#include "usbd_hid.h"

/** @addtogroup Examples
  @{
*/

/** @addtogroup USB_HID_Mouse
  @{
*/

/** @defgroup USB_HID_Mouse_Functions Functions
  @{
*/

/*!
 * @brief       Main program
 *
 * @param       None
 *
 * @retval      None
 *
 */
int main(void)
{
    HidMouse_Init();

    while(1)
    {
        HidMouse_Proc();
    }
}

/**@} end of group USB_HID_Mouse_Functions */
/**@} end of group USB_HID_Mouse */
/**@} end of group Examples */
