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

/** @addtogroup USBD_MSC
  @{
  */

/** @defgroup USBD_MSC_Macros Macros
  @{
*/

/* Interrupt source */
#define USB_INT_G_SOURCE          (USB_INT_G_ONEP | USB_INT_G_INEP | USB_INT_G_RXFNONE | \
                                   USB_INT_G_USBRST | USB_INT_G_ENUMD)

/* OUT endpoint Interrupt source */
#define USB_INT_EP_OUT_SOURCE      (USB_INT_EP_OUT_TSFCMP | USB_INT_EP_OUT_SETPCMP)

/* IN endpoint Interrupt source */
#define USB_INT_EP_IN_SOURCE       (USB_INT_EP_IN_TSFCMP | USB_INT_EP_IN_ITXEMP)

/* define 0 to disable, 1 to enable */
#define USB_VBUS_SWITCH             1

/* define 0 to disable, 1 to enable */
#define USB_SOF_OUTPUT_SWITCH       0

/* Configuraion number */
#define USBD_CONFIGURATION_NUM      1

/* Out endpoint number */
#define USB_OUT_EP_MAX_NUM          5

/* In endpoint number */
#define USB_IN_EP_MAX_NUM           5

/* Endpoint pack size in bytes */
#define USB_EP0_PACKET_SIZE         64

#ifdef USB_OTG_FS
/* FS RxFIFO size setting */
#define USB_FS_RX_FIFO_SIZE         128
/* FS TxFIFO size setting */
#define USB_FS_TX_FIFO_0_SIZE       64
#define USB_FS_TX_FIFO_1_SIZE       128
#define USB_FS_TX_FIFO_2_SIZE       0
#define USB_FS_TX_FIFO_3_SIZE       0

#else
/* HS RxFIFO size setting */
#define USB_HS_RX_FIFO_SIZE         128
/* HS TxFIFO size setting */
#define USB_HS_TX_FIFO_0_SIZE       64
#define USB_HS_TX_FIFO_1_SIZE       128
#define USB_HS_TX_FIFO_2_SIZE       0
#define USB_HS_TX_FIFO_3_SIZE       0
#define USB_HS_TX_FIFO_4_SIZE       0
#define USB_HS_TX_FIFO_5_SIZE       0
#define USB_HS_TX_FIFO_6_SIZE       0
#define USB_HS_TX_FIFO_7_SIZE       0
#endif

#define USE_DEFAULT      1
#define USE_USER         2

#define DELAY_SOURCE     USE_DEFAULT

/**@} end of group USBD_MSC_Macros*/
/**@} end of group USBD_MSC */
/**@} end of group Examples */

#endif
