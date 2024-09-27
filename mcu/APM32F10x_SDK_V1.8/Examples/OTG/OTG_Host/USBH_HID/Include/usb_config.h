/*!
 * @file        usb_config.h
 *
 * @brief       USB configuration file
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
#ifndef __USB_CONFIG_H
#define __USB_CONFIG_H

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBH_HID
  @{
  */

/** @defgroup USBH_HID_Macros Macros
  @{
*/

#define USBH_DEVICE_DEFAULT_ADDRESS           0
#define USBH_DEVICE_CONFIGURED_ADDRESS        1

#define CFG_DESC_MAX_LEN                      256
#define STRING_DESC_MAX_LEN                   256

#define INTERFACE_DESC_MAX_NUM                2
#define ENDPOINT_DESC_MAX_NUM                 3

/* define 0 to disable, 1 to enable */
#define USB_VBUS_SWITCH                       0
/* define 0 to disable, 1 to enable */
#define USB_SOF_OUTPUT_SWITCH                 0

#define USB_EP0_PACKET_SIZE                   64

#ifdef USB_OTG_FS
#define USB_FS_RX_FIFO_SIZE                   128
#define USB_FS_NP_TXH_FIFO_SIZE               96
#define USB_FS_P_TXH_FIFO_SIZE                96

#else
/* USB_OTG_HS_CORE */
#define USB_HS_RX_FIFO_SIZE                   512
#define USB_HS_NP_TXH_FIFO_SIZE               256
#define USB_HS_P_TXH_FIFO_SIZE                256
#endif

#define USE_DEFAULT                           0
#define USE_TIMER                             1
#define USE_USER                              2

/* Change the delay function source */
#define DELAY_SOURCE                          USE_USER

/**@} end of group USBH_HID_Macros*/
/**@} end of group USBH_HID */
/**@} end of group Examples */

#endif
