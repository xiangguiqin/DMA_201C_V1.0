/*!
 * @file        usbd_descriptor.c
 *
 * @brief       USB descriptor
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
#include "usbd_descriptor.h"
#include "usbd_core.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBD_MSC
  @{
  */

/** @defgroup USBD_MSC_Variables Variables
  @{
  */

/* Device descriptor */
USBD_Descriptor_T g_deviceDescriptor = {g_usbDeviceDescriptor, USB_DEVICE_DESCRIPTOR_SIZE};
/* Config descriptor */
USBD_Descriptor_T g_configDescriptor = {g_usbConfigDescriptor, USB_CONFIG_DESCRIPTOR_SIZE};
/* String descriptor */
USBD_Descriptor_T g_stringDescriptor[] =
{
    {g_usbLandIDString, USB_LANGID_STRING_SIZE},
    {g_usbVendorString, USB_VENDOR_STRING_SIZE},
    {g_usbProductString, USB_PRODUCT_STRING_SIZE},
    {g_usbSerialString, USB_SERIAL_STRING_SIZE}
};
/* Device Qualifier descriptor */
USBD_Descriptor_T g_qualifierDescriptor = {g_usbQualifierDescriptor, USB_QUALIFIER_DESCRIPTOR_SIZE};


/**
 * @brief   Device descriptor
 */
uint8_t g_usbDeviceDescriptor[USB_DEVICE_DESCRIPTOR_SIZE] =
{
    /* bLength */
    0x12,
    /* bDescriptorType */
    USBD_DESC_DEVICE,
    /* bcdUSB */
    0x00, 0x02,
    /* bDeviceClass */
    0x00,
    /* bDeviceSubClass */
    0x00,
    /* bDeviceProtocol */
    0x00,
    /* bMaxPacketSize */
    USB_EP0_PACKET_SIZE,
    /* idVendor =  314b*/
    0x4B, 0x31,
    /* idProduct = 0109 */
    0x09, 0x02,
    /* bcdDevice = 2.00 */
    0x00, 0x02,
    /* Index of string descriptor describing manufacturer */
    1,
    /* Index of string descriptor describing product */
    2,
    /* Index of string descriptor describing the device serial number */
    3,
    /* bNumConfigurations */
    USBD_CONFIGURATION_NUM,
};

/**
 * @brief   Configuration descriptor
 */
uint8_t g_usbConfigDescriptor[USB_CONFIG_DESCRIPTOR_SIZE] =
{
    /* bLength */
    0x09,
    /* bDescriptorType */
    USBD_DESC_CONFIGURATION,
    /* wTotalLength */
    USB_CONFIG_DESCRIPTOR_SIZE & 0xFF, USB_CONFIG_DESCRIPTOR_SIZE >> 8,

    /* bNumInterfaces */
    0x01,
    /* bConfigurationValue */
    0x01,
    /* iConfiguration */
    0x01,
    /* bmAttributes */
    0xC0,
    /* MaxPower */
    0x32,

    /* bLength */
    0x09,
    /* bDescriptorType */
    USBD_DESC_INTERFACE,
    /* bInterfaceNumber */
    0x00,
    /* bAlternateSetting */
    0x00,
    /* bNumEndpoints */
    0x02,
    /* bInterfaceClass */
    0x08,
    /* bInterfaceSubClass */
    0x06,
    /* bInterfaceProtocol */
    0x50,
    /* iInterface */
    0x05,

    /* bLength */
    0x07,
    /* bDescriptorType: Endpoint */
    USBD_DESC_ENDPOINT,
    /* bEndpointAddress */
    MSC_IN_EP,
    /* bmAttributes */
    0x02,
    /* wMaxPacketSize: */
    0x40,0x00,
    /* bInterval: */
    0x00,

    /* bLength */
    0x07,
    /* bDescriptorType: Endpoint */
    USBD_DESC_ENDPOINT,
    /* bEndpointAddress */
    MSC_OUT_EP,
    /* bmAttributes */
    0x02,
    /* wMaxPacketSize: */
    0x40,0x00,
    /* bInterval: */
    0x00,
};

/**
 * @brief   language ID string
 */
uint8_t g_usbLandIDString[USB_LANGID_STRING_SIZE] =
{
    /* Size */
    USB_LANGID_STRING_SIZE,
    /* bDescriptorType */
    USBD_DESC_STRING,
    0x09,0x04
};

/**
 * @brief   Vendor string
 */
uint8_t g_usbVendorString[USB_VENDOR_STRING_SIZE] =
{
    /* Size */
    USB_VENDOR_STRING_SIZE,
    /* bDescriptorType */
    USBD_DESC_STRING,
    'G', 0, 'e', 0, 'e', 0, 'h', 0, 'y', 0,
};

/**
 * @brief   Product string
 */
uint8_t g_usbProductString[USB_PRODUCT_STRING_SIZE] =
{
    USB_PRODUCT_STRING_SIZE,
    USBD_DESC_STRING,

#ifdef USB_OTG_FS
    'A', 0, 'P', 0, 'M', 0, '3', 0, '2', 0,
    ' ', 0, 'F', 0, 'S', 0, ' ', 0, 'M', 0,
    'S', 0, 'C', 0
#else
    'A', 0, 'P', 0, 'M', 0, '3', 0, '2', 0,
    ' ', 0, 'H', 0, 'S', 0, ' ', 0, 'M', 0,
    'S', 0, 'C', 0
#endif
};

/**
 * @brief   Serial string
 */
uint8_t g_usbSerialString[USB_SERIAL_STRING_SIZE] =
{
    USB_SERIAL_STRING_SIZE,
    USBD_DESC_STRING,

    '0', 0,
    '0', 0,
    '0', 0,
    '0', 0,
    '0', 0,
    '0', 0,
    '0', 0,
    '0', 0,
    '0', 0,
    '0', 0,
    '0', 0,
    '0', 0
};

/**
 * @brief   Qualifier string
 */
uint8_t g_usbQualifierDescriptor[USB_QUALIFIER_DESCRIPTOR_SIZE] =
{
    USB_QUALIFIER_DESCRIPTOR_SIZE,
    USBD_DESC_DEVICE_QUALIFIER,

    0x00, 0x02,
    0x00,
    0x00,
    0x00,
    0x40,
    0x01,
    0x00,
};

/**@} end of group USBD_MSC_Variables*/

/** @defgroup USBD_MSC_Functions Functions
  @{
  */

/*!
 * @brief       Config Serial String
 *
 * @param       string: point to the Serial String
 *
 * @retval      None
 */
void USBD_ConfigSerialString(uint8_t *string)
{
    uint32_t serialNum1 = 0;
    uint16_t serialNum2 = 0;
    uint8_t  index, movCnt = 0;
    serialNum1 = (*(uint32_t *)UID_ADDRESS1) +  (*(uint32_t *)UID_ADDRESS2);
    serialNum2 = (uint16_t)((*(uint32_t *)UID_ADDRESS1) +  (*(uint32_t *)UID_ADDRESS3));
    for (index = 2; index <= 16; index += 2)
    {
        string[index] = USBD_NumberToChar((uint8_t)(serialNum1 >> movCnt) & 0x0F);
        if (movCnt < 16)
        {
            string[index + 16] = USBD_NumberToChar(((uint8_t)(serialNum2 >> movCnt) & 0x0F));
        }
        movCnt += 4;
    }
}

/**@} end of group USBD_MSC_Functions */
/**@} end of group USBD_MSC */
/**@} end of group Examples */
