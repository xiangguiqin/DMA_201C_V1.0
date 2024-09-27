/*!
 * @file        usbh_msc_bot.h
 *
 * @brief       USB host MSC bot
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
#ifndef __USBH_MSC_BOT_H_
#define __USBH_MSC_BOT_H_

/* Includes */
#include "usbh_core.h"
#include "usbh_msc_scsi.h"
#include "usbh_class_msc.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBH_MSC
  @{
  */

/** @defgroup USBH_MSC_Macros Macros
  @{
*/

/* CBW parameter */
#define MSC_BOT_CBW_SIGNATURE             (uint32_t)(0x43425355)
#define MSC_BOT_CBW_TAG                   (uint32_t)(0x20304050)
#define BOT_CBW_LEN                       31
#define BOT_CBW_CB_LEN                    16

/* CSW parameter */
#define MSC_BOT_CSW_SIGNATURE             (uint32_t)(0x53425355)
#define MSC_BOT_CSW_LENGTH                13
#define LEN_CSW_MAX                       63

#define USBH_CLASS_GET_MAX_LUN            0xFE
#define USBH_CLASS_BOT_RESET              0xFF

#define LEN_CBW_TEST_UNIT_READY           6
#define LEN_CBW                           10

#define LEN_MSC_PAGE                      4096

/**@} end of group USBH_MSC_Macros */

/** @defgroup USBH_MSC_Enumerates Enumerates
  @{
  */

/**
 * @brief    SCSI transmission state of BOT
 */
typedef enum
{
    USBH_BOT_SEND_CBW,
    USBH_BOT_SENT_CBW,
    USBH_BOT_DATAIN,
    USBH_BOT_DATAOUT,
    USBH_BOT_RECEIVE_CSW,
    USBH_BOT_DECODE_CSW,
    USBH_BOT_ERROR_IN,
    USBH_BOT_ERROR_OUT,
} USBH_BOT_STATE_T;

typedef enum
{
    USBH_BOT_DIR_OUT,
    USBH_BOT_DIR_IN
} USBH_BOT_DIR_T;

/**
 * @brief    BOT status of USB host MSC
 */
typedef enum
{
    USBH_BOT_OK,
    USBH_BOT_FAIL,
    USBH_BOT_PHASE_ERROR,
    USBH_BOT_BUSY
} USBH_BOT_STATUS_T;

/**@} end of group USBH_MSC_Enumerates */

/** @defgroup USBH_MSC_Structures
  @{
  */

/**
 * @brief    CBW flag
 */
typedef union
{
    uint8_t byte;

    struct
    {
        uint8_t reserved : 7;
        uint8_t dir      : 1;
    } bit;

} USBH_BOT_CBW_FLAG_T;

/**
 * @brief    Command Block Wrapper
 */
typedef union
{
    struct
    {
        uint32_t dSignature;
        uint32_t dTag;
        uint32_t dDataXferLen;
        USBH_BOT_CBW_FLAG_T bmFlags;
        uint8_t bLUN;
        uint8_t bCBLen;
        uint8_t CB[16];
    } field;

    uint8_t buffer[31];
} USBH_BOT_CBW_T;

/**
 * @brief    Command Status Wrapper
 */
typedef union
{
    struct
    {
        uint32_t dSignature;
        uint32_t dTag;
        uint32_t dDataResidue;
        uint8_t  bStatus;
    } field;

    uint8_t buffer[13];
} USBH_BOT_CSW_T;

/**
 * @brief    BOT transmission parameter
 */
typedef struct
{
    USBH_BOT_CBW_T CBW;
    USBH_BOT_CSW_T CSW;
} USBH_BOT_CmdPack_T;

/**
 * @brief    MSC BOT information
 */
typedef struct
{
    USBH_BOT_STATE_T curBOTState;
    USBH_BOT_STATE_T preBOTState;
    USBH_BOT_STATUS_T BOTXferStatus;

    uint8_t  inChNum;
    uint8_t  outChNum;
    uint8_t  bulkOutEpAddr;
    uint8_t  bulkInEpAddr;
    uint16_t bulkInEpSize;
    uint16_t bulkOutEpSize;

    uint8_t* pXferBuf;
    uint32_t xferLen;
    uint8_t dataInBuf[512];
    uint8_t dataOutBuf[512];

    USBH_BOT_CmdPack_T cmdPack;
} USBH_BOT_Info_T;

/**@} end of group USBH_MSC_Structures */

/* define callback function type */
typedef void (*MSC_BOT_Handler_T)(void);

/* extern variables */
extern USBH_BOT_Info_T g_BOTInfo;

#define USBH_BOT_ConfigBOTState(state) \
{ \
    g_BOTInfo.preBOTState = g_BOTInfo.curBOTState; \
    g_BOTInfo.curBOTState = state; \
}

/** @defgroup USBH_MSC_Functions Functions
  @{
*/

/* function declaration */
void USBH_MSC_BOT_Init(void);
void USBH_MSC_BOTXferHandler(void);
void USBH_MSC_BOT_ConfigCBW(uint32_t xferLen,
                            USBH_BOT_DIR_T dir,
                            uint8_t *CBBuf,
                            uint8_t  CBLen);

/**@} end of group USBH_MSC_Functions */
/**@} end of group USBH_MSC */
/**@} end of group Examples */

#endif /* __USBH_MSC_BOT_H_ */
