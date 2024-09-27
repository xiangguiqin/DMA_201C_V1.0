/*!
 * @file        usbh_msc_scsi.c
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

/* Includes */
#include "usbh_msc_scsi.h"
#include "usbh_msc_bot.h"
#include "usbh_class_msc.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBH_MSC
  @{
  */

/** @defgroup USBH_MSC_Functions Functions
  @{
  */

static void MSC_SCSI_InitBuffer(uint8_t *buf, uint32_t len);

/*!
 * @brief       Test Unit Ready command
 *
 * @param       None
 *
 * @retval      BOT SCSI transmission status
 */
uint8_t MSC_SCSI_TestUnitReady(void)
{
    if(g_MSCInfo.SCSIStates == MSC_SCSI_SEND)
    {
        /* Config CBW */
        g_BOTInfo.cmdPack.CBW.field.dDataXferLen = 0;
        g_BOTInfo.cmdPack.CBW.field.bmFlags.bit.dir = USBH_REQ_DIR_OUT;
        g_BOTInfo.cmdPack.CBW.field.bCBLen = LEN_CBW_TEST_UNIT_READY;

        MSC_SCSI_InitBuffer(g_BOTInfo.cmdPack.CBW.field.CB, BOT_CBW_CB_LEN);

        g_BOTInfo.cmdPack.CBW.field.CB[0] = SCSI_CMD_TEST_UNIT_READY;

        g_BOTInfo.pXferBuf = g_BOTInfo.cmdPack.CSW.buffer;
        g_BOTInfo.xferLen = LEN_CSW_MAX;

        g_BOTInfo.BOTXferStatus = USBH_BOT_BUSY;
        g_MSCInfo.SCSIStates = MSC_SCSI_BUSY;

        /* Prepare Handler bulk transfer */
        USBH_ConfigClassCoreState(USBH_MSC_BOT_TRANSFER);
        g_BOTInfo.curBOTState = USBH_BOT_SEND_CBW;
    }
    else if(g_MSCInfo.SCSIStates == MSC_SCSI_BUSY)
    {
        switch (g_BOTInfo.BOTXferStatus)
        {
            case USBH_BOT_OK:
            case USBH_BOT_FAIL:
            case USBH_BOT_PHASE_ERROR:
                g_MSCInfo.SCSIStates = MSC_SCSI_SEND;
                break;
            default :
                break;
        }
    }

    return g_BOTInfo.BOTXferStatus;
}

/*!
 * @brief       Read Capacity 10 command
 *
 * @param       None
 *
 * @retval      BOT SCSI transmission status
 */
uint8_t MSC_SCSI_ReadCapacity10(void)
{
    if(g_MSCInfo.SCSIStates == MSC_SCSI_SEND)
    {
        /* Config CBW */
        g_BOTInfo.cmdPack.CBW.field.dDataXferLen = LEN_XFER_READ_CAPACITY10;
        g_BOTInfo.cmdPack.CBW.field.bmFlags.bit.dir = USBH_REQ_DIR_IN;
        g_BOTInfo.cmdPack.CBW.field.bCBLen = LEN_CBW;

        MSC_SCSI_InitBuffer(g_BOTInfo.cmdPack.CBW.field.CB, BOT_CBW_CB_LEN);

        g_BOTInfo.cmdPack.CBW.field.CB[0] = SCSI_CMD_READ_CAPACITY_10;

        g_BOTInfo.pXferBuf = g_BOTInfo.dataInBuf;

        g_BOTInfo.xferLen = LEN_CSW_MAX;

        g_BOTInfo.BOTXferStatus = USBH_BOT_BUSY;
        g_MSCInfo.SCSIStates = MSC_SCSI_BUSY;

        /* Prepare Handler bulk transfer */
        USBH_ConfigClassCoreState(USBH_MSC_BOT_TRANSFER);
        g_BOTInfo.curBOTState = USBH_BOT_SEND_CBW;
    }
    else if(g_MSCInfo.SCSIStates == MSC_SCSI_BUSY)
    {
        switch (g_BOTInfo.BOTXferStatus)
        {
            case USBH_BOT_OK:
            case USBH_BOT_FAIL:
            case USBH_BOT_PHASE_ERROR:
                g_MSCInfo.SCSIStates = MSC_SCSI_SEND;
                break;
            default :
                break;
        }

    }
    return g_BOTInfo.BOTXferStatus;
}

/*!
 * @brief       Mode Sense 6 command
 *
 * @param       None
 *
 * @retval      BOT SCSI transmission status
 */
uint8_t MSC_SCSI_ModeSense6(void)
{
    if(g_MSCInfo.SCSIStates == MSC_SCSI_SEND)
    {
        /* Config CBW */
        g_BOTInfo.cmdPack.CBW.field.dDataXferLen = LEN_XFER_MODE_SENSE6;
        g_BOTInfo.cmdPack.CBW.field.bmFlags.bit.dir = USBH_REQ_DIR_IN;
        g_BOTInfo.cmdPack.CBW.field.bCBLen = LEN_CBW;

        MSC_SCSI_InitBuffer(g_BOTInfo.cmdPack.CBW.field.CB, BOT_CBW_CB_LEN);

        g_BOTInfo.cmdPack.CBW.field.CB[0] = SCSI_CMD_MODE_SENSE_6;
        g_BOTInfo.cmdPack.CBW.field.CB[2] = MODE_SENSE_PAGE_CONTROL_FIELD | MODE_SENSE_PAGE_CODE;
        g_BOTInfo.cmdPack.CBW.field.CB[4] = LEN_XFER_MODE_SENSE6;

        g_BOTInfo.pXferBuf = g_BOTInfo.dataInBuf;

        g_BOTInfo.BOTXferStatus = USBH_BOT_BUSY;
        g_MSCInfo.SCSIStates = MSC_SCSI_BUSY;

        /* Prepare Handler bulk transfer */
        USBH_ConfigClassCoreState(USBH_MSC_BOT_TRANSFER);
        g_BOTInfo.curBOTState = USBH_BOT_SEND_CBW;
    }
    else if(g_MSCInfo.SCSIStates == MSC_SCSI_BUSY)
    {
        switch (g_BOTInfo.BOTXferStatus)
        {
            case USBH_BOT_OK:
            case USBH_BOT_FAIL:
            case USBH_BOT_PHASE_ERROR:
                g_MSCInfo.SCSIStates = MSC_SCSI_SEND;
                break;
            default :
                break;
        }

    }
    return g_BOTInfo.BOTXferStatus;
}

/*!
 * @brief       Request Sense command
 *
 * @param       None
 *
 * @retval      BOT SCSI transmission status
 */
uint8_t MSC_SCSI_RequestSense(void)
{
    if(g_MSCInfo.SCSIStates == MSC_SCSI_SEND)
    {
        /* Config CBW */
        g_BOTInfo.cmdPack.CBW.field.dDataXferLen = LEN_XFER_REQUEST_SENSE;
        g_BOTInfo.cmdPack.CBW.field.bmFlags.bit.dir = USBH_REQ_DIR_IN;
        g_BOTInfo.cmdPack.CBW.field.bCBLen = LEN_CBW;

        MSC_SCSI_InitBuffer(g_BOTInfo.cmdPack.CBW.field.CB, BOT_CBW_CB_LEN);

        g_BOTInfo.cmdPack.CBW.field.CB[0] = SCSI_CMD_REQUEST_SENSE;
        g_BOTInfo.cmdPack.CBW.field.CB[1] = DESC_REQUEST_SENSE;
        g_BOTInfo.cmdPack.CBW.field.CB[4] = LEN_XFER_REQUEST_SENSE;

        g_BOTInfo.pXferBuf = g_BOTInfo.dataInBuf;

        g_BOTInfo.BOTXferStatus = USBH_BOT_BUSY;
        g_MSCInfo.SCSIStates = MSC_SCSI_BUSY;

        /* Prepare Handler bulk transfer */
        USBH_ConfigClassCoreState(USBH_MSC_BOT_TRANSFER);
        g_BOTInfo.curBOTState = USBH_BOT_SEND_CBW;
    }
    else if(g_MSCInfo.SCSIStates == MSC_SCSI_BUSY)
    {
        switch (g_BOTInfo.BOTXferStatus)
        {
            case USBH_BOT_OK:
            case USBH_BOT_FAIL:
            case USBH_BOT_PHASE_ERROR:
                g_MSCInfo.SCSIStates = MSC_SCSI_SEND;
                break;
            default :
                break;
        }

    }
    return g_BOTInfo.BOTXferStatus;
}

/*!
 * @brief       Write 10 command
 *
 * @param       None
 *
 * @retval      BOT SCSI transmission status
 */
uint8_t MSC_SCSI_Write10(uint8_t *dataBuffer, uint32_t address, uint32_t sectorCnt)
{
    uint16_t pageNum;

    if(g_MSCInfo.SCSIStates == MSC_SCSI_SEND)
    {
        /* Config CBW */
        g_BOTInfo.cmdPack.CBW.field.dDataXferLen = sectorCnt * g_MSCInfo.storageInfo.blockSize;
        g_BOTInfo.cmdPack.CBW.field.bmFlags.bit.dir = USBH_REQ_DIR_OUT;
        g_BOTInfo.cmdPack.CBW.field.bCBLen = LEN_CBW;

        MSC_SCSI_InitBuffer(g_BOTInfo.cmdPack.CBW.field.CB, BOT_CBW_CB_LEN);

        g_BOTInfo.cmdPack.CBW.field.CB[0] = SCSI_CMD_WRITE10;
        /* logical block address */
        g_BOTInfo.cmdPack.CBW.field.CB[2]  = (((uint8_t*) &address)[3]);
        g_BOTInfo.cmdPack.CBW.field.CB[3]  = (((uint8_t*) &address)[2]);
        g_BOTInfo.cmdPack.CBW.field.CB[4]  = (((uint8_t*) &address)[1]);
        g_BOTInfo.cmdPack.CBW.field.CB[5]  = (((uint8_t*) &address)[0]);

        pageNum = sectorCnt;

        /* transfer length */
        g_BOTInfo.cmdPack.CBW.field.CB[7]  = (((uint8_t *) &pageNum)[1]);
        g_BOTInfo.cmdPack.CBW.field.CB[8]  = (((uint8_t *) &pageNum)[0]);

        g_BOTInfo.pXferBuf = dataBuffer;

        g_BOTInfo.BOTXferStatus = USBH_BOT_BUSY;
        g_MSCInfo.SCSIStates = MSC_SCSI_BUSY;

        /* Prepare Handler bulk transfer */
        USBH_ConfigClassCoreState(USBH_MSC_BOT_TRANSFER);
        g_BOTInfo.curBOTState = USBH_BOT_SEND_CBW;
    }
    else if(g_MSCInfo.SCSIStates == MSC_SCSI_BUSY)
    {
        switch (g_BOTInfo.BOTXferStatus)
        {
            case USBH_BOT_OK:
            case USBH_BOT_FAIL:
            case USBH_BOT_PHASE_ERROR:
                g_MSCInfo.SCSIStates = MSC_SCSI_SEND;
                break;
            default :
                break;
        }

    }
    return g_BOTInfo.BOTXferStatus;
}
uint32_t test = 0;
/*!
 * @brief       Read 10 command
 *
 * @param       None
 *
 * @retval      BOT SCSI transmission status
 */
uint8_t MSC_SCSI_Read10(uint8_t *dataBuffer, uint32_t address, uint32_t sectorCnt)
{
    uint16_t pageNum;

    if(g_MSCInfo.SCSIStates == MSC_SCSI_SEND)
    {
        /* Config CBW */
        g_BOTInfo.cmdPack.CBW.field.dDataXferLen = sectorCnt * g_MSCInfo.storageInfo.blockSize;
        g_BOTInfo.cmdPack.CBW.field.bmFlags.bit.dir = USBH_REQ_DIR_IN;
        g_BOTInfo.cmdPack.CBW.field.bCBLen = LEN_CBW;

        MSC_SCSI_InitBuffer(g_BOTInfo.cmdPack.CBW.field.CB, BOT_CBW_CB_LEN);

        g_BOTInfo.cmdPack.CBW.field.CB[0] = SCSI_CMD_READ_10;

        /* logical block address */
        g_BOTInfo.cmdPack.CBW.field.CB[2]  = (((uint8_t*) &address)[3]);
        g_BOTInfo.cmdPack.CBW.field.CB[3]  = (((uint8_t*) &address)[2]);
        g_BOTInfo.cmdPack.CBW.field.CB[4]  = (((uint8_t*) &address)[1]);
        g_BOTInfo.cmdPack.CBW.field.CB[5]  = (((uint8_t*) &address)[0]);

        pageNum = sectorCnt;

        /* transfer length */
        g_BOTInfo.cmdPack.CBW.field.CB[7]  = (((uint8_t *) &pageNum)[1]);
        g_BOTInfo.cmdPack.CBW.field.CB[8]  = (((uint8_t *) &pageNum)[0]);

        g_BOTInfo.pXferBuf = dataBuffer;

        g_BOTInfo.BOTXferStatus = USBH_BOT_BUSY;
        g_MSCInfo.SCSIStates = MSC_SCSI_BUSY;

        /* Prepare Handler bulk transfer */
        USBH_ConfigClassCoreState(USBH_MSC_BOT_TRANSFER);
        g_BOTInfo.curBOTState = USBH_BOT_SEND_CBW;
        test++;
        if (test == 2)
        {
            __NOP();
        }
    }
    else if(g_MSCInfo.SCSIStates == MSC_SCSI_BUSY)
    {
        switch (g_BOTInfo.BOTXferStatus)
        {
            case USBH_BOT_OK:
            case USBH_BOT_FAIL:
            case USBH_BOT_PHASE_ERROR:
                g_MSCInfo.SCSIStates = MSC_SCSI_SEND;
                break;
            default :
                break;
        }
    }

    return g_BOTInfo.BOTXferStatus;
}

static void MSC_SCSI_InitBuffer(uint8_t *buf, uint32_t len)
{
    while (len--)
    {
        buf[len] = 0;
    }
}

/**@} end of group USBH_MSC_Functions */
/**@} end of group USBH_MSC */
/**@} end of group Examples */
