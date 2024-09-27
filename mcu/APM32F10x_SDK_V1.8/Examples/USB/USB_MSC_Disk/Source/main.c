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
#include "usbd_msc.h"

/** @addtogroup Examples
  @{
*/

/** @addtogroup USB_MSC_Disk
  @{
*/

/** @defgroup USB_MSC_Disk_Functions Functions
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
    MSC_Init();

    while(1)
    {
    }
}

/**@} end of group USB_MSC_Disk_Functions */
/**@} end of group USB_MSC_Disk */
/**@} end of group Examples */
