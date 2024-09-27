/*!
 * @file        usb_user.c
 *
 * @brief       usb user configuration
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
#include "usb_user.h"
#include "usbh_core.h"
#include "usb_board.h"
#include "usbh_msc.h"
#include "ff.h"

/** @addtogroup Examples
  @{
*/

/** @addtogroup USBH_MSC
  @{
*/

/** @defgroup USBH_MSC_Functions Functions
  @{
  */

static void USER_InitHandler(void);
static void USER_DeInitHandler(void);
static void USER_ResetDevHandler(void);
static void USER_DevAttachedHandler(void);
static void USER_DevDetachedHandler(void);
static void USER_DevSpeedDetectedHandler(uint8_t speed);
static void USER_DevDescHandler(void *devDesc);
static void USER_CfgDescHandler(void *cfgDesc, void *interface);
static void USER_ManufacturerStringHandler(void *mfcDesc);
static void USER_ProductStringHandler(void *productDesc);
static void USER_SerialNumStringHandler(void *serialDesc);
static void USER_EnumDoneHandler(void);
static USER_STATE_T USER_UserInputHandler(void);
static USER_STATE_T USER_ApplicationHandler(void);
static void USER_DeviceNotSupportedHandler(void);
static void USER_UnrecoveredErrHandler(void);

#if (DELAY_SOURCE != USE_DEFAULT)
static void USB_USER_Delay(uint32_t cnt);
#endif

/**@} end of group USBH_MSC_Functions*/

/** @defgroup USBH_MSC_Variables Variables
  @{
  */

FATFS s_fatFs;
FIL s_file;

USB_UserCallBack_T g_userCallback =
{
    USER_InitHandler,
    USER_DeInitHandler,
    USER_ResetDevHandler,
    USER_DevAttachedHandler,
    USER_DevDetachedHandler,
    USER_DevSpeedDetectedHandler,
    USER_DevDescHandler,
    USER_CfgDescHandler,
    USER_ManufacturerStringHandler,
    USER_ProductStringHandler,
    USER_SerialNumStringHandler,
    USER_EnumDoneHandler,
    USER_UserInputHandler,
    USER_ApplicationHandler,
    USER_DeviceNotSupportedHandler,
    USER_UnrecoveredErrHandler,

#if (DELAY_SOURCE == USE_DEFAULT)
    NULL
#else
    USB_USER_Delay
#endif
};

/**@} end of group USBH_MSC_Variables*/

/** @defgroup USBH_MSC_Functions Functions
  @{
  */

static void USER_InitHandler(void)
{
    USART_Config_T usartConfig;

    /* Configure USART */
    usartConfig.baudRate = 115200;
    usartConfig.wordLength = USART_WORD_LEN_8B;
    usartConfig.stopBits = USART_STOP_BIT_1;
    usartConfig.parity = USART_PARITY_NONE ;
    usartConfig.mode = USART_MODE_TX_RX;
    usartConfig.hardwareFlow = USART_HARDWARE_FLOW_NONE;

    APM_BOARD_COMInit(COM2,&usartConfig);

    APM_MINI_PBInit(BUTTON_KEY1, BUTTON_MODE_GPIO);
    APM_MINI_PBInit(BUTTON_KEY2, BUTTON_MODE_GPIO);
}

static void USER_DeInitHandler(void)
{
    printf(">> Host Re-Initialize.\r\n");
}


static void USER_ResetDevHandler(void)
{
    printf(">> Reset USB Device.\r\n");
}

static void USER_DevAttachedHandler(void)
{
    printf(">> Device Attached.\r\n");
}

static void USER_DevDetachedHandler(void)
{
    printf(">> Device Disconnected.\r\n");
}

static void USER_DevSpeedDetectedHandler(uint8_t speed)
{
    switch (speed)
    {
        case USBH_DEVICE_SPEED_HS:
            printf(">> Device Speed : High Speed.\r\n");
            break;
        case USBH_DEVICE_SPEED_FS:
            printf(">> Device Speed : Full Speed.\r\n");
            break;
        case USBH_DEVICE_SPEED_LS:
            printf(">> Device Speed : Low Speed.\r\n");
            break;
        default :
            printf(">> Unknown Speed.\r\n");
            break;
    }
}

static void USER_DevDescHandler(void *devDesc)
{
    USBH_DeviceDesc_T *desc = devDesc;

    printf(">> VID : 0x%04X\r\n", desc->idVendor[0] | desc->idVendor[1] << 8);
    printf(">> PID : 0x%04X\r\n", desc->idProduct[0] | desc->idProduct[1] << 8);
    printf(">> Endpoint 0 max pack size is %d\r\n", desc->bMaxPacketSize);
}

static void USER_CfgDescHandler(void *cfgDesc, void *interface)
{
    USBH_Interface_T *itf = interface;
    uint8_t i;

    switch (itf->itfDesc.bInterfaceClass)
    {
        case 0x08:
            printf(">> This is a Mass Storage Class Device.\r\n");
            break;
        case 0x03:
            printf(">> This is a HID Class Device.\r\n");
            break;
        case 0x0A:
            printf(">> This is a Communications Class Device.\r\n");
            break;
        default :
            printf(">> Class Code is : 0x%02X\r\n", itf->itfDesc.bInterfaceClass);
            break;
    }
    printf(">> Use %d endpoint:\r\n", itf->itfDesc.bNumEndpoints);
    for (i = 0; i < itf->itfDesc.bNumEndpoints; i++)
    {
        printf("    Endpoint 0x%02X: max pack size is %d bytes\r\n", \
        itf->epDesc[i].bEndpointAddress,
        itf->epDesc[i].wMaxPacketSize[0] | itf->epDesc[i].wMaxPacketSize[1] << 8);
    }
}

static void USER_ManufacturerStringHandler(void *mfcDesc)
{
    printf(">> Manufacturer : %s\r\n", (uint8_t*)mfcDesc);
}
static void USER_ProductStringHandler(void *productDesc)
{
    printf(">> Product : %s\r\n", (uint8_t*)productDesc);
}

static void USER_SerialNumStringHandler(void *serialDesc)
{
    printf(">> SerialNumber : %s\r\n", (uint8_t*)serialDesc);
}

static void USER_EnumDoneHandler(void)
{
    printf(">> USB Enum Done.\r\n");
}

static USER_STATE_T USER_UserInputHandler(void)
{
    return USER_OK;
}

static USER_STATE_T USER_ApplicationHandler(void)
{
    FRESULT res;

    if (!APM_MINI_PBGetState(BUTTON_KEY1))
    {
        /* Read Disk Test */
        if (g_usbHost.connectedFlag)
        {
            printf("------ Scan files on the USB disk ------ \r\n");

            if (f_mount(&s_fatFs, "0:", 1) == FR_OK)
            {
                FATFS_ScanFiles(fileScanPath);
                __NOP();
            }
            else
            {
                printf("fatFs mount fail!\r\n");
            }
        }
        else
        {
            printf("Device is not connected\r\n");
        }
        while (!APM_MINI_PBGetState(BUTTON_KEY1));
    }

    if (!APM_MINI_PBGetState(BUTTON_KEY2))
    {
        if (g_usbHost.connectedFlag)
        {
            printf("------ Write and read USB disk file ------\r\n");

            if ((res = f_mount(&s_fatFs, "0:", 1)) == FR_OK)
            {
                FATFS_WriteReadFile(&s_file);
            }
            else
            {
                printf("Error : %d\r\n" ,res);
            }
        }
        else
        {
            printf("Device is not connected\r\n");
        }
        while (!APM_MINI_PBGetState(BUTTON_KEY2));
    }

    return USER_OK;
}

static void USER_DeviceNotSupportedHandler(void)
{
    printf(">> Device is not Supported!\r\n");
}

static void USER_UnrecoveredErrHandler(void)
{
    printf(">> Unrecovered Error!\r\n");
}


#if (DELAY_SOURCE != USE_DEFAULT)
static void USB_USER_Delay(uint32_t cnt)
{
    USB_usDelay(cnt);
}
#endif

/**@} end of group USBH_MSC_Functions */
/**@} end of group USBH_MSC */
/**@} end of group Examples */
