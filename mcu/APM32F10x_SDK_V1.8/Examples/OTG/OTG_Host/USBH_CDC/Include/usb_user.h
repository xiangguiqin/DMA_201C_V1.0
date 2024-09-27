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
#ifdef APM32F40X
#include "apm32f4xx.h"
#include "apm32f4xx_misc.h"
#include "apm32f4xx_gpio.h"
#include "apm32f4xx_rcm.h"
#include "apm32f4xx_tmr.h"
#else
#include "apm32f10x.h"
#include "apm32f10x_misc.h"
#include "apm32f10x_gpio.h"
#include "apm32f10x_rcm.h"
#include "apm32f10x_tmr.h"
#endif
#include "usb_board.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBH_CDC
  @{
  */

/** @defgroup USBH_CDC_Enumerations Enumerations
  @{
  */

typedef enum
{
    USER_OK,
    USER_WAITING,
    USER_ERROR
} USER_STATE_T;

/**@} end of group USBH_CDC_Enumerations */

/** @defgroup USBH_CDC_Type_define Type_define
  @{
  */

/**
 * @brief USB function type define
 */
typedef void (*USER_InitHandler_T)(void);
typedef void (*USER_DeInitHandler_T)(void);
typedef void (*USER_ResetDevHandler_T)(void);
typedef void (*USER_DevAttachedHandler_T)(void);
typedef void (*USER_DevDetachedHandler_T)(void);
typedef void (*USER_DevSpeedDetectedHandler_T)(uint8_t speed);
typedef void (*USER_DevDescHandler_T)(void *devDesc);
typedef void (*USER_CfgDescHandler_T)(void *cfgDesc, void *interface);
typedef void (*USER_ManufacturerStringHandler_T)(void * mfcDesc);
typedef void (*USER_ProductStringHandler_T)(void *productDesc);
typedef void (*USER_SerialNumStringHandler_T)(void *serialDesc);
typedef void (*USER_EnumDoneHandler_T)(void);
typedef USER_STATE_T (*USER_UserInputHandler_T)(void);
typedef USER_STATE_T (*USER_ApplicationHandler_T)(void);
typedef void (*USER_DeviceNotSupportedHandler_T)(void);
typedef void (*USER_UnrecoveredErrHandler_T)(void);
typedef void (*USER_DelayCallBack_T)(uint32_t );

/**@} end of group USBH_CDC_Type_define */

/** @defgroup USBH_CDC_Structures Structures
  @{
  */

/**
 * @brief   USB User Callback handler
 */
typedef struct
{
    USER_InitHandler_T               initHandler;
    USER_DeInitHandler_T             deInitHandler;
    USER_ResetDevHandler_T           resetDevHandler;
    USER_DevAttachedHandler_T        devAttachedHandler;
    USER_DevDetachedHandler_T        devDetachedHandler;
    USER_DevSpeedDetectedHandler_T   devSpeedDetectedHandler;
    USER_DevDescHandler_T            devDescHandler;
    USER_CfgDescHandler_T            cfgDescHandler;
    USER_ManufacturerStringHandler_T manufacturerStringHandler;
    USER_ProductStringHandler_T      productStringHandler;
    USER_SerialNumStringHandler_T    serialNumStringHandler;
    USER_EnumDoneHandler_T           enumDoneHandler;
    USER_UserInputHandler_T          userInputHandler;
    USER_ApplicationHandler_T        applicationHandler;
    USER_DeviceNotSupportedHandler_T deviceNotSupportedHandler;
    USER_UnrecoveredErrHandler_T     unrecoveredErrHandler;
    USER_DelayCallBack_T             delay;
} USB_UserCallBack_T;

/**@} end of group USBH_CDC_Structures*/

/** @defgroup USBH_CDC_Variables Variables
  @{
  */

extern USB_UserCallBack_T g_userCallback;

/**@} end of group USBH_CDC_Variables*/
/**@} end of group USBH_CDC */
/**@} end of group Examples */

#endif /** __USB_USER_H */
