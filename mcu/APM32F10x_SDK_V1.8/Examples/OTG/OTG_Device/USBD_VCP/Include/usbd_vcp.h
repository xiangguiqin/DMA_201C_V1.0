/*!
 * @file        usbd_vcp.h
 *
 * @brief       USB VCP core function
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
#ifndef __USBD_VCP_H_
#define __USBD_VCP_H_

/* Includes */
#include "usbd_init.h"
#include "usbd_class_cdc.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBD_VCP
  @{
  */

/** @defgroup USBD_VCP_Functions
  @{
*/

static void USBD_VCP_SetConfigCallBack(void);
void USBD_VCP_Init(void);
void USBD_VCP_Proc(void);

/**@} end of group USBD_VCP_Functions */
/**@} end of group USBD_VCP */
/**@} end of group Examples */

#endif /** __USBD_VCP_H_ */
