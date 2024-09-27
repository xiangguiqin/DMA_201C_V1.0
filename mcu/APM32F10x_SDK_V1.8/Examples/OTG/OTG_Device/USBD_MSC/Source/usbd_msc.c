/*!
 * @file        usbd_msc.c
 *
 * @brief       USB MSC core function
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
#include "usbd_msc.h"
#include "usbd_msc_bot.h"
#include "usbd_descriptor.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBD_MSC
  @{
  */

/** @defgroup USBD_MSC_Functions Functions
  @{
  */

static void USBD_MSC_SetConfigCallBack(void);
static void USBD_MSC_ClearFeatureHandler(void);

/**@} end of group USBD_MSC_Functions */

/** @defgroup USBD_MSC_Variables Variables
  @{
  */

/* Standard Request handler */
USBD_StdReqCallback_T g_stdReqCallback =
{
    NULL,      /*!< getConfigurationHandler; */
    NULL,      /*!< getDescriptorHandler;*/
    NULL,      /*!< getInterfaceHandler;*/
    NULL,      /*!< getStatusHandler;*/
    NULL,      /*!< setAddressHandler;*/
    USBD_MSC_SetConfigCallBack, /*!< setConfigurationHandler;*/
    NULL,      /*!< setDescriptorHandler;*/
    NULL,      /*!< setFeatureHandler;*/
    NULL,      /*!< setInterfaceHandler;*/
    USBD_MSC_ClearFeatureHandler /*!< clearFeatureHandler;*/
};
/**@} end of group USBD_MSC_Variables*/

/** @defgroup USBD_MSC_Functions Functions
  @{
  */

/*!
 * @brief       Standard request set configuration call back
 *
 * @param       None
 *
 * @retval      None
 */
static void USBD_MSC_SetConfigCallBack(void)
{
    if (g_usbDev.devState == USBD_DEVICE_STATE_CONFIGURED)
    {
        USBD_OpenInEP(MSC_IN_EP & 0x7f, USB_EP_TYPE_BULK, 64);
        USBD_OpenOutEP(MSC_OUT_EP & 0x7f, USB_EP_TYPE_BULK, 64);
        USBD_MSC_BOT_Init();
    }
    else
    {
        USBD_CloseInEP(MSC_IN_EP & 0x7f);
        USBD_CloseOutEP(MSC_OUT_EP & 0x7f);
    }
}

/*!
 * @brief       handler clearFeature
 *
 * @param       None
 *
 * @retval      None
 */
static void USBD_MSC_ClearFeatureHandler(void)
{
    uint8_t ep = g_usbDev.reqData.domain.wIndex[0] & 0x7f;

    if (g_usbDev.reqData.domain.wValue[0] == USBD_FEATURE_ENDPOINT_HALT)
    {
        if (g_usbDev.reqData.domain.wIndex[0] & 0x80)
        {
            USB_OTG_FlushTxFIFO(ep);
        }
        else
        {
            USB_OTG_FlushRxFIFO();
        }

        USBD_MSV_BOT_ClearFeatureHandler();
    }
}

/*!
 * @brief       MSC Out endpoint initialization call back
 *
 * @param       ep : endpoint number
 *
 * @retval      None
 */
void USBD_MSC_OutEpCallback(uint8_t ep)
{
    if (ep == (MSC_OUT_EP & 0x7f))
    {
        USBD_MSC_BOT_OutData(ep);
    }
}

/*!
 * @brief       MSC In endpoint initialization  call back
 *
 * @param       ep : endpoint number
 *
 * @retval      None
 */
void USBD_MSC_InEpCallback(uint8_t ep)
{
    if (ep == (MSC_IN_EP & 0x7f))
    {
        USBD_MSC_BOT_InData(ep);
    }
}

/*!
 * @brief       MSC initialization
 *
 * @param       None
 *
 * @retval      None
 */
void USBD_MSC_Init(void)
{
    USBD_InitParam_T devParam;

    /* Config devParam Structure */
    USBD_InitParamStructInit(&devParam);

    /* Descriptor */
    devParam.pDeviceDesc = &g_deviceDescriptor;
    devParam.pConfigurationDesc = &g_configDescriptor;
    devParam.pStringDesc = (USBD_Descriptor_T *)g_stringDescriptor;
    devParam.pQualifierDesc = &g_qualifierDescriptor;

    /* Setup Request */
    devParam.pStdReqCallback = &g_stdReqCallback;
    devParam.classReqHandler = USBD_MSC_ClassHandler;

    /* OUT and IN transfer handler(except EP0) */
    devParam.outEpHandler = USBD_MSC_OutEpCallback;
    devParam.inEpHandler = USBD_MSC_InEpCallback;

    USBD_Init(&devParam);
}

/**@} end of group USBD_MSC_Functions */
/**@} end of group USBD_MSC */
/**@} end of group Examples */
