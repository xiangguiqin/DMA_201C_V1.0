/*!
 * @file        usbd_vcp.c
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

/* Includes */
#include "usbd_vcp.h"
#include "usbd_descriptor.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBD_VCP
  @{
  */

/** @defgroup USBD_VCP_Variables Variables
  @{
  */

static uint8_t dataBuf[256] = {0};


/* Standard Request handler */
USBD_StdReqCallback_T stdReqCallback =
{
    NULL,      /*!< getConfigurationHandler; */
    NULL,      /*!< getDescriptorHandler; */
    NULL,      /*!< getInterfaceHandler; */
    NULL,      /*!< getStatusHandler; */
    NULL,      /*!< setAddressHandler; */
    USBD_VCP_SetConfigCallBack, /*!< setConfigurationHandler; */
    NULL,      /*!< setDescriptorHandler; */
    NULL,      /*!< setFeatureHandler; */
    NULL,      /*!< setInterfaceHandler; */
    NULL       /*!< clearFeatureHandler; */
};
/**@} end of group USBD_VCP_Variables*/

/** @defgroup USBD_VCP_Functions Functions
  @{
  */

/*!
 * @brief       Standard request set configuration call back
 *
 * @param       None
 *
 * @retval      None
 */
static void USBD_VCP_SetConfigCallBack(void)
{
    if (g_usbDev.devState == USBD_DEVICE_STATE_CONFIGURED)
    {
        USBD_OpenInEP(USB_EP_1, USB_EP_TYPE_BULK, 64);
        USBD_OpenInEP(USB_EP_2, USB_EP_TYPE_INTERRUPT, 8);

        USBD_OpenOutEP(USB_EP_1, USB_EP_TYPE_BULK, 64);

        USBD_RxData(USB_EP_1, dataBuf, g_usbDev.outBuf[USB_EP_1].maxPackSize);
    }
    else
    {
        USBD_CloseInEP(USB_EP_1);
        USBD_CloseInEP(USB_EP_2);
        USBD_CloseOutEP(USB_EP_1);
    }
}

/*!
 * @brief       OUT endpoint transfer done handler(except EP0)
 *
 * @param       ep : OUT endpoint
 *
 * @retval      None
 */
void USBD_VCP_OutEpCallback(uint8_t ep)
{
    uint32_t dataCnt;

    if (ep == USB_EP_1)
    {
        dataCnt = g_usbDev.outBuf[USB_EP_1].xferCnt;

        USBD_TxData(USB_EP_1, dataBuf, dataCnt);
    }
}

/*!
 * @brief       IN endpoint transfer done handler(except EP0)
 *
 * @param       ep : IN endpoint
 *
 * @retval      None
 */
void USBD_VCP_InEpCallback(uint8_t ep)
{
    if (ep == USB_EP_1)
    {
        USBD_RxData(USB_EP_1, dataBuf, g_usbDev.outBuf[USB_EP_1].maxPackSize);
    }
}

/*!
 * @brief       Start to reveive OUT packet
 *
 * @param       None
 *
 * @retval      None
 */
void USBD_VCP_Proc(void)
{
//    USBD_RxData(USB_EP_1, dataBuf, g_usbDev.outBuf[USB_EP_1].maxPackSize);
}

/*!
 * @brief       VCP initialization
 *
 * @param       None
 *
 * @retval      None
 */
void USBD_VCP_Init(void)
{
    USBD_InitParam_T devParam;

    USBD_InitParamStructInit(&devParam);

    devParam.pDeviceDesc = &g_deviceDescriptor;
    devParam.pConfigurationDesc = &g_configDescriptor;
    devParam.pStringDesc = (USBD_Descriptor_T *)g_stringDescriptor;
    devParam.pQualifierDesc = &g_qualifierDescriptor;

    devParam.pStdReqCallback = &stdReqCallback;
    devParam.classReqHandler = USBD_ClassHandler;
    devParam.stdReqExceptionHandler = NULL;

    devParam.outEpHandler = USBD_VCP_OutEpCallback;
    devParam.inEpHandler = USBD_VCP_InEpCallback;

    USBD_Init(&devParam);
}

/**@} end of group USBD_VCP_Functions */
/**@} end of group USBD_VCP */
/**@} end of group Examples */
