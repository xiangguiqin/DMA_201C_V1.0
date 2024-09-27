/*!
 * @file        usbh_msc_bot.c
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

/* Includes */
#include "usbh_msc_bot.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBH_MSC
  @{
  */

/** @defgroup USBH_MSC_Functions Functions
  @{
  */

/* private function */
static void MSC_BOT_SendCBWHandler(void);
static void MSC_BOT_SentCBWHandler(void);
static void MSC_BOT_DataInHandler(void);
static void MSC_BOT_DataOutHandler(void);
static void MSC_BOT_ReceiveCSWHandler(void);
static void MSC_BOT_DecodeCSWHandler(void);
static void MSC_BOT_ErrorInHandler(void);
static void MSC_BOT_ErrorOutHandler(void);

/**@} end of group USBH_MSC_Functions */

/** @defgroup USBH_MSC_Variables Variables
  @{
  */

/* public variables */
USBH_BOT_Info_T g_BOTInfo;
USBH_URB_STATUS_T g_UrbStatus;

uint32_t g_tempDataXferLen;
uint8_t *g_pdata;
uint8_t *g_pdataPrev;
uint8_t g_errorTimeout;
uint32_t g_errorCntBOTStall;

/* BOT callback function */
MSC_BOT_Handler_T MSC_BOT_Handler[] =
{
    MSC_BOT_SendCBWHandler,
    MSC_BOT_SentCBWHandler,
    MSC_BOT_DataInHandler,
    MSC_BOT_DataOutHandler,
    MSC_BOT_ReceiveCSWHandler,
    MSC_BOT_DecodeCSWHandler,
    MSC_BOT_ErrorInHandler,
    MSC_BOT_ErrorOutHandler,
};

/**@} end of group USBH_MSC_Variables */

/** @defgroup USBH_MSC_Functions Functions
  @{
  */

/*!
 * @brief       Init BOT of USB host MSC
 *
 * @param       None
 *
 * @retval      None
 */
void USBH_MSC_BOT_Init(void)
{
    g_BOTInfo.cmdPack.CBW.field.dSignature = MSC_BOT_CBW_SIGNATURE;
    g_BOTInfo.cmdPack.CBW.field.dTag = MSC_BOT_CBW_TAG;
    g_BOTInfo.cmdPack.CBW.field.bLUN = 0;

    g_errorCntBOTStall = 0;

    g_MSCInfo.errorCnt = 0;
    g_MSCInfo.SCSIStates = MSC_SCSI_SEND;
}

/*!
 * @brief       Decode CSW
 *
 * @param       None
 *
 * @retval      BOT transmission status
 */
static USBH_BOT_STATUS_T MSC_BOT_DecodeCSW(void)
{
    USBH_BOT_STATUS_T status = USBH_BOT_FAIL;

    /* Check validity of the CSW Signature and CSWStatus */
    if(g_BOTInfo.cmdPack.CSW.field.dSignature == MSC_BOT_CSW_SIGNATURE)
    {
        if(g_BOTInfo.cmdPack.CSW.field.dTag == g_BOTInfo.cmdPack.CBW.field.dTag)
        {
            if(g_BOTInfo.cmdPack.CSW.field.bStatus == USBH_BOT_OK)
            {
                status = USBH_BOT_OK;
            }
            else if(g_BOTInfo.cmdPack.CSW.field.bStatus == USBH_BOT_FAIL)
            {
                status = USBH_BOT_FAIL;
            }
            else if(g_BOTInfo.cmdPack.CSW.field.bStatus == USBH_BOT_PHASE_ERROR)
            {
                status = USBH_BOT_PHASE_ERROR;
            }
        }
    }
    else
    {
        /* If the CSW Signature is not valid, We Sall return the Phase Error to
        Upper Layers for Reset Recovery */
        status = USBH_BOT_PHASE_ERROR;
    }

    g_BOTInfo.BOTXferStatus = status;

    return status;
}

/*!
 * @brief       BOT transmission handler
 *
 * @param       None
 *
 * @retval      None
 */
void USBH_MSC_BOTXferHandler(void)
{
    /* Hander enum function */
    MSC_BOT_Handler[g_BOTInfo.curBOTState]();

}

/*!
 * @brief       Process status of Send CBW
 *
 * @param       None
 *
 * @retval      None
 */
static void MSC_BOT_SendCBWHandler(void)
{
    if (test == 2)
    {
        __NOP();
    }
    USBH_BulkOutData(g_BOTInfo.outChNum, g_BOTInfo.cmdPack.CBW.buffer, BOT_CBW_LEN);

    USBH_BOT_ConfigBOTState(USBH_BOT_SENT_CBW);

    g_errorTimeout = 0;
}

/*!
 * @brief       Process status of Sent CBW
 *
 * @param       None
 *
 * @retval      None
 */
static void MSC_BOT_SentCBWHandler(void)
{
    g_UrbStatus = g_usbHost.xferPipe[g_BOTInfo.outChNum].urbStatus;
    if (g_UrbStatus != USBH_URB_IDLE)
    {
        if (test == 2)
        {
            __NOP();
        }
    }
    switch(g_UrbStatus)
    {
        case USBH_URB_OK:
            g_errorCntBOTStall = 0;
            /* Data Stage */
            if(g_BOTInfo.cmdPack.CBW.field.dDataXferLen != 0)
            {
                g_tempDataXferLen = g_BOTInfo.cmdPack.CBW.field.dDataXferLen;
                g_pdata = g_BOTInfo.pXferBuf;
                g_pdataPrev = g_pdata;

                /* If there is Data Transfer Stage */
                if(g_BOTInfo.cmdPack.CBW.field.bmFlags.bit.dir == USBH_REQ_DIR_IN)
                {
                    USBH_BOT_ConfigBOTState(USBH_BOT_DATAIN);
                }
                else
                {
                    USBH_BOT_ConfigBOTState(USBH_BOT_DATAOUT);
                }
            }
            else
            {
                /* If there is NO Data Transfer Stage */
                USBH_BOT_ConfigBOTState(USBH_BOT_RECEIVE_CSW);
            }
            g_UrbStatus = USBH_URB_IDLE;
            break;

        case USBH_URB_NOREADY:
            g_BOTInfo.curBOTState = g_BOTInfo.preBOTState;
            break;

        case USBH_URB_STALL:
            g_UrbStatus = USBH_URB_IDLE;
            USBH_BOT_ConfigBOTState(USBH_BOT_ERROR_OUT);
            break;

        case USBH_URB_ERROR:
            g_errorTimeout++;

            if(g_errorTimeout >= 3)
            {
                g_UrbStatus = USBH_URB_IDLE;
                USBH_BOT_ConfigBOTState(USBH_BOT_ERROR_OUT);
            }
            else
            {
                g_BOTInfo.curBOTState = g_BOTInfo.preBOTState;
            }
            break;
        case USBH_URB_PING:
            USB_OTG_EnableChannelPing(g_BOTInfo.outChNum);
            break;
        default:
            break;
    }
}
/*!
 * @brief       Process status of input data
 *
 * @param       None
 *
 * @retval      None
 */
static void MSC_BOT_DataInHandler(void)
{
    g_UrbStatus = g_usbHost.xferPipe[g_BOTInfo.inChNum].urbStatus;

    if((g_UrbStatus == USBH_URB_OK) || (g_BOTInfo.preBOTState != USBH_BOT_DATAIN))
    {
        g_errorCntBOTStall = 0;
        g_BOTInfo.preBOTState = USBH_BOT_DATAIN;

        if(g_tempDataXferLen > g_BOTInfo.bulkInEpSize)
        {
            USBH_BulkInData(g_BOTInfo.inChNum, g_pdata, g_BOTInfo.bulkInEpSize);

            g_tempDataXferLen -= g_BOTInfo.bulkInEpSize;
            g_pdata = g_pdata + g_BOTInfo.bulkInEpSize;
        }
        else if(g_tempDataXferLen == 0)
        {
            if (g_MSCInfo.preMSCState == USBH_MSC_READ_CAPACITY10)
            {

                g_MSCInfo.storageInfo.capacity = g_pdata[0] << 24| \
                                                 g_pdata[1] << 16| \
                                                 g_pdata[2] << 8| \
                                                 g_pdata[3];

                g_MSCInfo.storageInfo.blockSize = g_pdata[4] << 24| \
                                                   g_pdata[5] << 16| \
                                                   g_pdata[6] << 8| \
                                                   g_pdata[7];

                g_MSCInfo.storageInfo.sectorSize = g_MSCInfo.storageInfo.blockSize;
            }
             /* If value was 0, and successful transfer, then change the state */
            g_BOTInfo.curBOTState = USBH_BOT_RECEIVE_CSW;
        }
        else
        {
            USBH_BulkInData(g_BOTInfo.inChNum, g_pdata, g_tempDataXferLen);

            /* Reset this value and keep in same state */
            g_tempDataXferLen = 0;
        }
    }
    else if(g_UrbStatus == USBH_URB_STALL)
    {
        g_MSCInfo.preMSCState = g_MSCInfo.curMSCState;
        g_BOTInfo.preBOTState = g_BOTInfo.curBOTState;

        g_BOTInfo.curBOTState = USBH_BOT_ERROR_IN;
    }
    else if(g_UrbStatus == USBH_URB_ERROR)
    {
        g_errorTimeout++;

        if(g_errorTimeout >= 3)
        {
            g_MSCInfo.preMSCState = g_MSCInfo.curMSCState;
            g_BOTInfo.curBOTState = USBH_BOT_ERROR_IN;
        }
        else
        {
            g_BOTInfo.curBOTState = g_BOTInfo.preBOTState;
        }
    }
}
/*!
 * @brief       Process status of output data
 *
 * @param       None
 *
 * @retval      None
 */
static void MSC_BOT_DataOutHandler(void)
{
    g_UrbStatus = g_usbHost.xferPipe[g_BOTInfo.outChNum].urbStatus;

    switch(g_UrbStatus)
    {
        case USBH_URB_OK:
            g_errorCntBOTStall = 0;
            g_BOTInfo.preBOTState = USBH_BOT_DATAOUT;
            if(g_tempDataXferLen > g_BOTInfo.bulkOutEpSize)
            {
                USBH_BulkOutData(g_BOTInfo.outChNum, g_pdata, g_BOTInfo.bulkOutEpSize);
                g_pdataPrev = g_pdata;
                g_pdata = g_pdata + g_BOTInfo.bulkOutEpSize;

                g_tempDataXferLen -= g_BOTInfo.bulkOutEpSize;

                g_errorTimeout = 0;
            }
            else if(g_tempDataXferLen == 0)
            {
                 /* If value was 0, and successful transfer, then change the state */
                g_BOTInfo.curBOTState = USBH_BOT_RECEIVE_CSW;
            }
            else
            {
                USBH_BulkOutData(g_BOTInfo.outChNum, g_pdata,g_tempDataXferLen);

                /* Reset this value and keep in same state */
                g_tempDataXferLen = 0;
            }
            break;

        case USBH_URB_NOREADY:
            if(g_pdata != g_pdataPrev)
            {
                USBH_BulkOutData(g_BOTInfo.outChNum,
                                 (g_pdata - g_BOTInfo.bulkOutEpSize),
                                 g_BOTInfo.bulkOutEpSize);
            }
            else
            {
                USBH_BulkOutData(g_BOTInfo.outChNum,
                                g_pdata,
                                g_BOTInfo.bulkOutEpSize);
            }
            break;

        case USBH_URB_STALL:
            g_MSCInfo.preMSCState = g_MSCInfo.curMSCState;
            g_BOTInfo.preBOTState = g_BOTInfo.curBOTState;
            g_BOTInfo.curBOTState = USBH_BOT_ERROR_OUT;
            break;

        case USBH_URB_ERROR:
            g_errorTimeout++;

            if(g_errorTimeout >= 3)
            {
                g_MSCInfo.preMSCState = g_MSCInfo.curMSCState;
                g_BOTInfo.preBOTState = g_BOTInfo.curBOTState;
                g_BOTInfo.curBOTState = USBH_BOT_ERROR_OUT;
            }
            else
            {
                g_BOTInfo.curBOTState = g_BOTInfo.preBOTState;
            }
            break;

        default:
            break;
    }
}
/*!
 * @brief       Process status of receive CSW
 *
 * @param       None
 *
 * @retval      None
 */
static void MSC_BOT_ReceiveCSWHandler(void)
{
    uint8_t i;

    g_BOTInfo.preBOTState = USBH_BOT_RECEIVE_CSW;
    g_BOTInfo.pXferBuf = g_BOTInfo.cmdPack.CSW.buffer;
    g_BOTInfo.xferLen = LEN_CSW_MAX;

    for(i = 0; i < MSC_BOT_CSW_LENGTH; i++)
    {
        g_BOTInfo.cmdPack.CSW.buffer[i] = 0x00;
    }

    USBH_BulkInData(g_BOTInfo.inChNum,
                    g_BOTInfo.pXferBuf,
                    LEN_CSW_MAX);

    g_BOTInfo.curBOTState = USBH_BOT_DECODE_CSW;

    g_errorTimeout = 0;
}
/*!
 * @brief       Process status of decode CSW
 *
 * @param       None
 *
 * @retval      None
 */
static void MSC_BOT_DecodeCSWHandler(void)
{
    g_UrbStatus = g_usbHost.xferPipe[g_BOTInfo.inChNum].urbStatus;

    switch(g_UrbStatus)
    {
        case USBH_URB_OK:
            g_errorCntBOTStall = 0;

            g_BOTInfo.preBOTState = USBH_BOT_RECEIVE_CSW;

            g_MSCInfo.curMSCState = g_MSCInfo.preMSCState;

            g_BOTInfo.BOTXferStatus = MSC_BOT_DecodeCSW();
            break;

        case USBH_URB_STALL:
            g_MSCInfo.preMSCState = g_MSCInfo.curMSCState;
            g_BOTInfo.preBOTState = g_BOTInfo.curBOTState;

            g_BOTInfo.curBOTState = USBH_BOT_ERROR_IN;
            break;

        case USBH_URB_ERROR:
            g_errorTimeout++;

            if(g_errorTimeout >= 3)
            {
                g_MSCInfo.preMSCState = g_MSCInfo.curMSCState;
                g_BOTInfo.preBOTState = g_BOTInfo.curBOTState;

                g_BOTInfo.curBOTState = USBH_BOT_ERROR_IN;
            }
            else
            {
                g_BOTInfo.curBOTState = g_BOTInfo.preBOTState;
            }
            break;

        default:
            break;
    }
}

/*!
 * @brief       Process status of input error
 *
 * @param       None
 *
 * @retval      None
 */
static void MSC_BOT_ErrorInHandler(void)
{
    USBH_CTRL_STATE_T   xferCtrlState;

    /* Config Request */
    if(g_usbHost.control.xferState == USBH_XFER_START)
    {
        USBH_StandardClearFeature(USBH_RECIPIENT_ENDPOINT,
                                  USBH_FEATURE_ENDPOINT_HALT,
                                  g_BOTInfo.bulkInEpAddr,
                                  g_BOTInfo.inChNum);

        g_usbHost.control.xferState = USBH_XFER_WAITING;
    }
    /* Do the transaction */
    else if(g_usbHost.control.xferState == USBH_XFER_WAITING)
    {
        /* Polling transaction handler */
        xferCtrlState = USBH_ControlXferHandler(&g_usbHost.control.reqData, NULL);

        switch (xferCtrlState)
        {
            case USBH_CTRL_COMPLETE:
                g_usbHost.control.xferState = USBH_XFER_OK;
                break;
            case USBH_CTRL_STALL :
            case USBH_CTRL_ERROR :
                g_usbHost.control.xferState = USBH_XFER_START;
                break;
            default :
                break;
        }

    }
    /* If transfer OK */
    else if (g_usbHost.control.xferState == USBH_XFER_OK)
    {
        g_usbHost.control.xferState = USBH_XFER_START;

        g_MSCInfo.curMSCState = USBH_MSC_TEST_UNIT_READY;
        g_MSCInfo.SCSIStates = MSC_SCSI_SEND;
    }
}

/*!
 * @brief       Process status of output error
 *
 * @param       None
 *
 * @retval      None
 */
static void MSC_BOT_ErrorOutHandler(void)
{
    USBH_CTRL_STATE_T   xferCtrlState;

    /* Config Request */
    if(g_usbHost.control.xferState == USBH_XFER_START)
    {
        USBH_StandardClearFeature(USBH_RECIPIENT_ENDPOINT,
                                  USBH_FEATURE_ENDPOINT_HALT,
                                  g_BOTInfo.bulkOutEpAddr,
                                  g_BOTInfo.outChNum);

        g_usbHost.control.xferState = USBH_XFER_WAITING;
    }
    /* Do the transaction */
    else if(g_usbHost.control.xferState == USBH_XFER_WAITING)
    {
        /* Polling transaction handler */
        xferCtrlState = USBH_ControlXferHandler(&g_usbHost.control.reqData, NULL);

        switch (xferCtrlState)
        {
            case USBH_CTRL_COMPLETE:
                g_usbHost.control.xferState = USBH_XFER_OK;
                break;
            case USBH_CTRL_STALL :
            case USBH_CTRL_ERROR :
                g_usbHost.control.xferState = USBH_XFER_START;
                break;
            default :
                break;
        }

    }
    /* If transfer OK */
    else if (g_usbHost.control.xferState == USBH_XFER_OK)
    {
        g_usbHost.control.xferState = USBH_XFER_START;

        /* Go to backup state */
        g_MSCInfo.curMSCState = USBH_MSC_TEST_UNIT_READY;
        g_MSCInfo.SCSIStates = MSC_SCSI_SEND;
    }
}

/**@} end of group USBH_MSC_Functions */
/**@} end of group USBH_MSC */
/**@} end of group Examples */
