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

The program to show how to configure the TMR2 peripheral to generate 4 different
signals with four different delays.

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

The CHx delay correspond to the time difference between PE6 falling edge and TMR2_CHx signal
rising edges. Reset system and display TMR2 waveform by oscilloscope.

&par Hardware Description

  - using TMR2 Channel 1 (PA0) to output signal
  - using TMR2 Channel 2 (PA1) to output signal
  - using TMR2 Channel 3 (PA2) to output signal
  - using TMR2 Channel 4 (PA3) to output signal

&par Directory contents

  - TMR/TMR_OCActive/src/apm32f10x_int.c           Interrupt handlers
  - TMR/TMR_OCActive/src/main.c                    Main program

&par IDE environment

  - MDK-ARM V5.36
  - EWARM V8.50.5.26295

&par Hardware and Software environment

  - This example runs on APM32F103 MINI Devices.
