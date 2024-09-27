/*!
 * @file        usbd_msc.h
 *
 * @brief       MSC head file
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
#ifndef __USBD_MSC_H
#define __USBD_MSC_H

/** @addtogroup Examples
  @{
*/

/** @addtogroup USB_MSC_Disk
  @{
*/

/** @defgroup USB_MSC_Disk_Functions Functions
  @{
*/

void MSC_Init(void);
void MSC_Proc(void);
void MSC_SetConfigCallBack(void);

/**@} end of group USB_MSC_Disk_Functions */
/**@} end of group USB_MSC_Disk */
/**@} end of group Examples */

#endif /*__USBD_MSC_H */
