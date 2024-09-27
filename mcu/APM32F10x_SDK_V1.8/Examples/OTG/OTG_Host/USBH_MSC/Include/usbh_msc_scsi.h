/*!
 * @file        usbh_msc_scsi.h
 *
 * @brief       USB host MSC scsi
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
#ifndef __USBH_MSC_SCSI_H_
#define __USBH_MSC_SCSI_H_

/* Includes */
#include "usbh_core.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBH_MSC
  @{
  */

/** @defgroup USBH_HID_Macros Macros
  @{
*/

/* Length define of command */
#define LEN_XFER_TEST_UNIT_READY           0
#define LEN_XFER_READ_CAPACITY10           8
#define LEN_XFER_MODE_SENSE6               34
#define LEN_XFER_REQUEST_SENSE             13

/* Request define */
#define DESC_REQUEST_SENSE                 0X00
#define MASK_MODE_SENSE_WRITE_PROTECT      0x80
#define MODE_SENSE_PAGE_CONTROL_FIELD      0x00
#define MODE_SENSE_PAGE_CODE               0x3F

#define DISK_WRITE_PROTECTED               0x01

/* SCSI Commands */
#define SCSI_CMD_FORMAT_UNIT                        ((uint8_t)0x04)
#define SCSI_CMD_INQUIRY                            ((uint8_t)0x12)
#define SCSI_CMD_MODE_SELECT_6                      ((uint8_t)0x15)
#define SCSI_CMD_MODE_SELECT_10                     ((uint8_t)0x55)
#define SCSI_CMD_MODE_SENSE_6                       ((uint8_t)0x1A)
#define SCSI_CMD_MODE_SENSE_10                      ((uint8_t)0x5A)
#define SCSI_CMD_ALLOW_MEDIUM_REMOVAL               ((uint8_t)0x1E)
#define SCSI_CMD_READ_6                             ((uint8_t)0x08)
#define SCSI_CMD_READ_10                            ((uint8_t)0x28)
#define SCSI_CMD_READ_12                            ((uint8_t)0xA8)
#define SCSI_CMD_READ_16                            ((uint8_t)0x88)

#define SCSI_CMD_READ_CAPACITY_10                   ((uint8_t)0x25)
#define SCSI_CMD_READ_CAPACITY_16                   ((uint8_t)0x9E)

#define SCSI_CMD_REQUEST_SENSE                      ((uint8_t)0x03)
#define SCSI_CMD_START_STOP_UNIT                    ((uint8_t)0x1B)
#define SCSI_CMD_TEST_UNIT_READY                    ((uint8_t)0x00)
#define SCSI_CMD_WRITE6                             ((uint8_t)0x0A)
#define SCSI_CMD_WRITE10                            ((uint8_t)0x2A)
#define SCSI_CMD_WRITE12                            ((uint8_t)0xAA)
#define SCSI_CMD_WRITE16                            ((uint8_t)0x8A)

#define SCSI_CMD_VERIFY_10                          ((uint8_t)0x2F)
#define SCSI_CMD_VERIFY_12                          ((uint8_t)0xAF)
#define SCSI_CMD_VERIFY_16                          ((uint8_t)0x8F)

#define SCSI_CMD_SEND_DIAGNOSTIC                    ((uint8_t)0x1D)
#define SCSI_CMD_READ_FORMAT_CAPACITIES             ((uint8_t)0x23)

/**@} end of group USBH_MSC_Macros */

/** @defgroup USBH_MSC_Enumerates Enumerates
  @{
  */

/**
 * @brief    SCSI transmission state of BOT
 */
typedef enum
{
    MSC_SCSI_SEND,
    MSC_SCSI_BUSY
} MSC_SCSI_STATE_T;

/**@} end of group USBH_MSC_Enumerates */

/** @defgroup USBH_MSC_Variables Variables
  @{
*/

extern uint32_t test;

/**@} end of group USBH_MSC_Variables */

/** @defgroup USBH_MSC_Functions Functions
  @{
*/

/** function declaration*/
uint8_t MSC_SCSI_TestUnitReady(void);
uint8_t MSC_SCSI_ReadCapacity10(void);
uint8_t MSC_SCSI_ModeSense6(void);
uint8_t MSC_SCSI_RequestSense(void);
uint8_t MSC_SCSI_Write10(uint8_t *dataBuffer, uint32_t address, uint32_t sectorCnt);
uint8_t MSC_SCSI_Read10(uint8_t *dataBuffer, uint32_t address, uint32_t sectorCnt);

/**@} end of group USBH_MSC_Functions */
/**@} end of group USBH_MSC */
/**@} end of group Examples */

#endif /** __USBH_MSC_SCSI_H_ */
