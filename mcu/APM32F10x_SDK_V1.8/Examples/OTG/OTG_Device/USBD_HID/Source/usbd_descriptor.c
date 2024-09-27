/*!
 * @file        usb_descriptor.c
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

/** @addtogroup USBD_HID
  @{
  */

/** @defgroup USBD_HID_Variables Variables
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
    /* bMaxPacketSize = 64 */
    0x40,
    /* idVendor =  314b */
    0x4B, 0x31,
    /* idProduct = 0107 */
    0x07, 0x01,
    /* bcdDevice = 2.00 */
    0x00, 0x20,

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
    USB_CONFIG_DESCRIPTOR_SIZE & 0XFF, USB_CONFIG_DESCRIPTOR_SIZE >> 8,

    /* bNumInterfaces */
    0X01,
    /* bConfigurationValue */
    0X01,
    /* iConfiguration */
    0X00,
    /* bmAttributes */
    0XE0,
    /* MaxPower */
    0X32,

    /* bLength */
    0X09,
    /* bDescriptorType */
    USBD_DESC_INTERFACE,
    /* bInterfaceNumber */
    0X00,
    /* bAlternateSetting */
    0X00,
    /* bNumEndpoints */
    0X01,
    /* bInterfaceClass */
    0X03,
    /* bInterfaceSubClass */
    0X01,
    /* bInterfaceProtocol */
    0X02,
    /* iInterface */
    0X00,

    /* bLength */
    0X09,
    /* Functional Descriptor */
    0x21,
    /* bcdHID */
    0X00, 0X01,
    /* bCountryCode */
    0X00,
    /* bNumDescriptors */
    0X01,
    /* bDescriptorType */
    0X22,
    /* wItemLength */
    74 & 0xFF, 74 >> 8,

    /* bLength */
    0X07,
    /* bDescriptorType */
    USBD_DESC_ENDPOINT,
    /* bEndpointAddress */
    HID_IN_EP,
    /* bmAttributes */
    0X03,
    /* wMaxPacketSize */
    0X04, 0X00,
    /* bInterval */
    0X20
};

/**
 * @brief   HID report descriptor
 */
uint8_t g_hidMouseReportDescriptor[74] =
{
    0x05,0x01,
    0x09,0x02,
    0xA1,0x01,
    0x09,0x01,

    0xA1,0x00,
    0x05,0x09,
    0x19,0x01,
    0x29,0x03,

    0x15,0x00,
    0x25,0x01,
    0x95,0x03,
    0x75,0x01,

    0x81,0x02,
    0x95,0x01,
    0x75,0x05,
    0x81,0x01,

    0x05,0x01,
    0x09,0x30,
    0x09,0x31,
    0x09,0x38,

    0x15,0x81,
    0x25,0x7F,
    0x75,0x08,
    0x95,0x03,
    0x81,0x06,
    0xC0,

    0x09,0x3c,
    0x05,0xff,
    0x09,0x01,
    0x15,0x00,
    0x25,0x01,

    0x75,0x01,
    0x95,0x02,
    0xb1,0x22,
    0x75,0x06,
    0x95,0x01,

    0xb1,0x01,
    0xc0
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
    0X09,0X04
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
    'A', 0, 'P', 0, 'M', 0, '3', 0, '2', 0, ' ', 0, 'H', 0,
    'I', 0, 'D', 0, ' ', 0, 'M', 0, 'o', 0, 'u', 0, 's', 0,
    'e', 0
};

/**
 * @brief   Qualifier descriptor
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

/**@} end of group USBD_HID_Variables*/

/** @defgroup USBD_HID_Functions Functions
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

/**@} end of group USBD_HID_Functions */
/**@} end of group USBD_HID */
/**@} end of group Examples */
