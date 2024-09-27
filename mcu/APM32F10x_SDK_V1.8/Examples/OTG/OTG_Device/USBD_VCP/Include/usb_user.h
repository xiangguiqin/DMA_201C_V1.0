/*!
 * @file        usb_user.h
 *
 * @brief       usb user function
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
#ifndef __USB_USER_H
#define __USB_USER_H

/* Includes */
#if defined (APM32F40X)
#include "apm32f4xx.h"
#include "apm32f4xx_rcm.h"
#include "apm32f4xx_gpio.h"
#include "apm32f4xx_misc.h"
#elif defined (APM32F10X_CL)
#include "apm32f10x.h"
#include "apm32f10x_rcm.h"
#include "apm32f10x_gpio.h"
#include "apm32f10x_misc.h"
#endif

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBD_VCP
  @{
  */

/** @defgroup USBD_VCP_Type_define
  @{
  */

/* User callback function type define */
typedef void (*USER_CallBack_T)(void);

typedef void (*USER_DelayCallBack_T)(uint32_t );



/**@} end of group USBD_VCP_Type_define */

/** @defgroup USBD_VCP_Structures Structures
  @{
  */

/**
 * @brief   USB User Callback handler
 */
typedef struct
{
    USER_CallBack_T USER_DeviceReset;
    USER_CallBack_T USER_DeviceSuspend;
    USER_CallBack_T USER_DeviceResume;
    USER_DelayCallBack_T delay;
} USB_UserCallBack_T;

/**@} end of group USBD_VCP_Structures*/

/** @defgroup USBD_VCP_Variables Variables
  @{
  */

extern USB_UserCallBack_T g_userCallback;


/**@} end of group USBD_VCP_Variables*/
/**@} end of group USBD_VCP */
/**@} end of group Examples */

#endif /** __USB_USER_H */
