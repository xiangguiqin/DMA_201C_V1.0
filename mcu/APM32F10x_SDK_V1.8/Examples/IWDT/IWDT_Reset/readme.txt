/*!
 * @file        readme.txt
 *
 * @brief       This file is routine instruction
 *
 * @version     V1.0.3
 *
 * @date        2022-12-01
 *
 * @attention
 *
 *  Copyright (C) 2020-2022 Geehy Semiconductor
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

The example shows how to configure IWDT and feed dog to prevent a system reset.
After IWDT initialization, System enters into an infinite loop, feed dog before the counter
reach a given timeout value to prevent system reset and keep LED2 blinking regularly.
Pressing KEY1 to stop feed dog will trigger system reset when the counter reach a given
timeout value. LED3 will be lighted when a system reset is triggered by IWDT.

&par Directory contents

  - IWDT/IWDT_Reset/src/apm32f10x_it.c     Interrupt handlers
  - IWDT/IWDT_Reset/src/main.c             Main program

&par IDE environment

  - MDK-ARM V5.36
  - EWARM V8.50.5.26295

&par Hardware and Software environment

  - This example runs on APM32F103_MINI Devices.
