/*!
 * @file        usbh_cdc.h
 *
 * @brief       USB CDC core function
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
#include "usbh_cdc.h"
#include "usbh_init.h"
#include "usbh_class_cdc.h"
#include "Board.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBH_CDC
  @{
  */

/** @defgroup USBH_CDC_Functions Functions
  @{
  */

/*!
 * @brief       Init USB host CDC
 *
 * @param       None
 *
 * @retval      None
 */
void USBH_CDC_Init(void)
{
    USBH_InitParam_T param;

    param.classInitHandler = USBH_CDC_ClassInitHandler;
    param.classDeInitHandler = USBH_CDC_ClassDeInitHandler;
    param.classReqHandler = USBH_CDC_ClassReqHandler;
    param.classCoreHandler = USBH_CDC_CoreHandler;
    param.suspendHandler = NULL;
    param.wakeUpHandler = NULL;
    param.intHandler = NULL;

    USBH_Init(&param);
}

/**@} end of group USBH_CDC_Functions */
/**@} end of group USBH_CDC */
/**@} end of group Examples */
