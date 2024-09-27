/*!
 * @file        usbd_hid.c
 *
 * @brief       USB HID core function
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
#include "usbd_hid.h"
#include "usbd_descriptor.h"
#include "usb_user.h"
#include "Board.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBD_HID
  @{
  */

/** @defgroup USBD_HID_Variables Variables
  @{
  */

/* Endpoint status */
static uint8_t s_statusEP = 1;

/* Standard Request handler */
USBD_StdReqCallback_T stdReqCallback =
{
    NULL,      /*!< getConfiguration Callback Function */
    USBD_HID_GetReportDescriptor, /*!< getDescriptor Callback Function */
    NULL,      /*!< getInterface Callback Function */
    NULL,      /*!< getStatus Callback Function */
    NULL,      /*!< setAddress Callback Function */
    USBD_HID_SetConfigCallBack, /*!< setConfiguration Callback Function */
    NULL,      /*!< setDescriptor Callback Function */
    NULL,      /*!< setFeature Callback Function */
    NULL,      /*!< setInterface Callback Function */
    NULL       /*!< clearFeature Callback Function */
};

/**@} end of group USBD_HID_Variables*/

/** @defgroup USBD_HID_Functions Functions
  @{
  */

/*!
 * @brief       Standard request set configuration call back
 *
 * @param       None
 *
 * @retval      None
 */
static void USBD_HID_SetConfigCallBack(void)
{
    USBD_OpenInEP(HID_IN_EP & 0x7F, USB_EP_TYPE_INTERRUPT, 4);
}

/*!
 * @brief       Standard request Report HID Descriptor
 *
 * @param       None
 *
 * @retval      None
 */
static void USBD_HID_GetReportDescriptor(void)
{
    USBD_DevReqData_T *reqData = &g_usbDev.reqData;
    uint8_t len;

    if((reqData->domain.bRequest == USBD_GET_DESCRIPTOR) &&
        (reqData->domain.bmRequestType.bit.recipient == USBD_RECIPIENT_INTERFACE) &&
        (reqData->domain.bmRequestType.bit.type == USBD_REQ_TYPE_STANDARD))
    {
        if(reqData->domain.wValue[1] == 0x21)
        {
            len = USB_MIN(reqData->domain.wLength[0], 9);
            USBD_CtrlInData((uint8_t *)&g_configDescriptor.pDesc[0x12], len);
        }
        else if(reqData->domain.wValue[1] == 0x22)
        {
            len = USB_MIN(reqData->domain.wLength[0], sizeof(g_hidMouseReportDescriptor));
            USBD_CtrlInData((uint8_t *)g_hidMouseReportDescriptor, len);
        }
    }
    else
    {
        USB_OTG_SetStall(USB_EP_0);
        USB_OTG_ReceiveSetupPacket(3);
    }
    if (reqData->domain.wLength[0] == 0)
    {
        USBD_CtrlTxStatus();
    }
}

/*!
 * @brief       Endpoint handler
 *
 * @param       ep: Endpoint number
 *
 * @retval      None
 */
void USBD_HID_EPHandler(uint8_t ep)
{
    if (ep == USB_EP_1)
    {
        s_statusEP = 1;
    }
}

/*!
 * @brief       Mouse write
 *
 * @param       key: Mouse key
 *
 * @retval      None
 */
void USBD_HID_Write(uint8_t key)
{
    int8_t x = 0;
    int8_t y = 0;
    uint8_t g_buffer[4] = {0, 0, 0, 0};

    switch (key)
    {
        case HID_MOUSE_KEY_LEFT:
            x -= 10;
            break;

        case HID_MOUSE_KEY_RIGHT:
            x += 10;
            break;

        case HID_MOUSE_KEY_UP:
            y -= 10;
            break;

        case HID_MOUSE_KEY_DOWN:
            y += 10;
            break;

        default:
            return;
    }

    g_buffer[1] = x;
    g_buffer[2] = y;

    s_statusEP = 0;

    USBD_TxData(USB_EP_1, g_buffer, 4);
}
/*!
 * @brief       Read key
 *
 * @param       None
 *
 * @retval      None
 */
uint8_t USBD_HID_ReadKey(void)
{
    /* Left key */
    if (!APM_MINI_PBGetState(BUTTON_KEY1))
    {
        return HID_MOUSE_KEY_LEFT;
    }

    /* Right key */
    if (!APM_MINI_PBGetState(BUTTON_KEY2))
    {
        return HID_MOUSE_KEY_RIGHT;
    }

    return HID_MOUSE_KEY_NULL;
}

/*!
 * @brief       Mouse process
 *
 * @param       None
 *
 * @retval      None
 */
void USBD_HID_Proc(void)
{
    uint8_t key;

    key = HID_MOUSE_KEY_NULL;

    /* Check the usb device configured state */
    if(g_usbDev.devState != USBD_DEVICE_STATE_CONFIGURED)
    {
        return;
    }

    key = USBD_HID_ReadKey();

    if(key != HID_MOUSE_KEY_NULL)
    {
        if(s_statusEP)
        {
            USBD_HID_Write(key);
        }
    }
}

/*!
 * @brief       USB initialization for HID
 *
 * @param       None
 *
 * @retval      None
 */
void USBD_HID_Init(void)
{
    USBD_InitParam_T devParam;

    USBD_InitParamStructInit(&devParam);

    devParam.pDeviceDesc = &g_deviceDescriptor;
    devParam.pConfigurationDesc = &g_configDescriptor;
    devParam.pStringDesc = (USBD_Descriptor_T *)g_stringDescriptor;
    devParam.pQualifierDesc = &g_qualifierDescriptor;

    devParam.pStdReqCallback = &stdReqCallback;
    devParam.classReqHandler = USBD_ClassHandler;

    devParam.inEpHandler = USBD_HID_EPHandler;

    USBD_Init(&devParam);
}

/*!
 * @brief       HID test key GPIO init
 *
 * @param       None
 *
 * @retval      None
 */
void USBD_HID_GPIOInit(void)
{
    APM_MINI_PBInit(BUTTON_KEY1, BUTTON_MODE_GPIO);
    APM_MINI_PBInit(BUTTON_KEY2, BUTTON_MODE_GPIO);
}

/**@} end of group USBD_HID_Functions */
/**@} end of group USBD_HID */
/**@} end of group Examples */
