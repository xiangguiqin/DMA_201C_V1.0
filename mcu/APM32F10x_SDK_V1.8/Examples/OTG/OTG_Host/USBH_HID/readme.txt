/*!
 * @file        readme.txt
 *
 * @brief       This file is routine instruction
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


&par Example Description

This example describes how to use the USB host to enumerate mouse.
When mouse move right or left, user can use USART2(PA2/PA3) to
catch the track of mouse.

The USART2 is configured as follows:
    - TX:PA2, RX:PA3
    - BaudRate = 115200 baud
    - Word Length = 8 Bits
    - One Stop Bit
    - No parity
    - Hardware flow control disabled (RTS and CTS signals)
    - Receive and transmit enabled

&par Directory contents

  - OTG\OTG_Host\USBH_HID\Source\apm32f10x_int.c       Interrupt handlers
  - OTG\OTG_Host\USBH_HID\Source\main.c                Main program
  - OTG\OTG_Host\USBH_HID\Source\usb_user.c            provides functions for usb user configuration
  - OTG\OTG_Host\USBH_HID\Source\usb_board.c           board configuration

&par IDE environment

  - MDK-ARM V5.29
  - EWARM V8.50.4.26131

&par Hardware and Software environment

  - This example runs on APM32F107_MINI Devices.
