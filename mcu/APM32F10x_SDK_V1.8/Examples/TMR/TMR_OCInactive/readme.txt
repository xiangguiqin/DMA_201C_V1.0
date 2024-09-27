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

The program to show how to configure the TMR2 peripheral in Output Compare Inactive
mode.

  - SystemCoreClock = 72MHz.
  - TMR2CLK = SystemCoreClock = 72 MHz.Prescaler = 71, TMR counter clock = 1 MHz
  - TMR2_Period    = (1000000 / 1000) - 1
  - TMR2 CH1 pulse = 800
  - TMR2 CH1 delay = 800/1MHz = 800us
  - TMR2 CH2 pulse = 600
  - TMR2 CH2 delay = 600/1MHz = 600us
  - TMR2 CH3 pulse = 400
  - TMR2 CH3 delay = 400/1MHz = 400us
  - TMR2 CH4 pulse = 200
  - TMR2 CH4 delay = 200/1MHz = 200us

While the counter is lower than the Output compare registers values,
the PA1, PA2, PA3, and PA4 are set.

When the counter value reaches the Output compare registers values,
the PA1, PA2, PA3, and PA4 are reset.

The CHx delay correspond to the time difference between PAx rising edges and falling edge.
Reset system and display PA1, PA2, PA3, and PA4 waveform by oscilloscope.

&par Directory contents

  - TMR/TMR_OCInactive/src/apm32f10x_int.c           Interrupt handlers
  - TMR/TMR_OCInactive/src/main.c                    Main program

&par IDE environment

  - MDK-ARM V5.36
  - EWARM V8.50.5.26295

&par Hardware and Software environment

  - This example runs on APM32F103_MINI Devices.
