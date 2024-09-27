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

This example describes how to use the USB OTG device module on APM32F107 to
enumerated as a MSC USB disk. This example use PC as host, and APM32F107 will
use SRAM array to simulate a fake U disk, unable to store files, only Used to
test speed of file transferring.

&par Directory contents

  - OTG\OTG_Device\USBD_MSC\Source\apm32f10x_int.c    Interrupt handlers
  - OTG\OTG_Device\USBD_MSC\Source\main.c             Main program
  - OTG\OTG_Device\USBD_MSC\Source\usb_user.c         provides functions for usb user configuration

&par IDE environment

  - MDK-ARM V5.29
  - EWARM V8.50.4.26131

&par Hardware and Software environment

  - This example runs on APM32F107_MINI Devices.
