/*!
 * @file        mmc_sdram.c
 *
 * @brief       This file contains all the functions for the APM32F103xCS SDRAM
 *
 * @version     V1.0.2
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

/* Includes */
#include "dmc_sdram.h"
#include "apm32f10x_dmc.h"
#include "apm32f10x_gpio.h"
#include "apm32f10x_rcm.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup DMC_SDRAM
  @{
  */

/** @defgroup DMC_SDRAM_Variables Variables
  @{
  */

extern volatile uint32_t tick;

/**@} end of group DMC_SDRAM_Variables*/

/** @defgroup DMC_SDRAM_Functions Functions
  @{
*/

static void SDRAM_GPIOConfig(void);
static void SDRAM_DMCConfig(void);

/*!
 * @brief       SDRAM Init
 *
 * @param       None
 *
 * @retval      None
 *
 */
void SDRAM_Init(void)
{
    SDRAM_GPIOConfig();
    SDRAM_DMCConfig();
}

/*!
 * @brief       SDRAM Word Test
 *
 * @param       None
 *
 * @retval      i : W/R Err Count
 *
 */
uint32_t SDRAM_Word_Test(void)
{
    uint32_t Addr = 0;
    uint32_t i = 0;

    for (Addr = SDRAM_START_ADDR; Addr < SDRAM_END_ADDR; Addr += 0x4)
    {
        SDRAM_WriteWord(Addr, (uint32_t)0x55555555);
    }

    for (Addr = SDRAM_START_ADDR; Addr < SDRAM_END_ADDR; Addr += 0x4)
    {
        if (*(__IO uint32_t*)(Addr) != 0x55555555)
        {
            i++;
        }
    }

    return i;
}

/*!
 * @brief       SDRAM HalfWord Test
 *
 * @param       None
 *
 * @retval      i : W/R Err Count
 *
 */
uint32_t SDRAM_HalfWord_Test(void)
{
    uint32_t Addr = 0;
    uint32_t i= 0;

    for (Addr = SDRAM_START_ADDR; Addr < SDRAM_END_ADDR; Addr += 0x2)
    {
        SDRAM_WriteHalfWord(Addr, (uint16_t)0x5555);
    }

    for (Addr = SDRAM_START_ADDR; Addr < SDRAM_END_ADDR; Addr += 0x2)
    {
        if (*(__IO uint16_t*)(Addr) != 0x5555)
        {
            i++;
        }
    }

    return i;
}

/*!
 * @brief       SDRAM Byte Test
 *
 * @param       None
 *
 * @retval      i : W/R Err Count
 *
 */
uint32_t SDRAM_Byte_Test(void)
{
    uint32_t Addr = 0;
    uint32_t i= 0;

    for (Addr = SDRAM_START_ADDR; Addr < SDRAM_END_ADDR; Addr += 0x1)
    {
        SDRAM_WriteByte(Addr, (uint8_t)0x55);
    }

    for (Addr = SDRAM_START_ADDR; Addr < SDRAM_END_ADDR; Addr += 0x1)
    {
        if (*(__IO uint8_t*)(Addr) != 0x55)
        {
            i++;
        }
    }

    return i;
}

/*!
 * @brief       SDRAM Write Word
 *
 * @param       address:the address to be programmed.
 *
 * @param       data: the data to be programmed.
 *
 * @retval      None
 *
 */
void SDRAM_WriteWord(uint32_t address, uint32_t data)
{
    *(__IOM uint32_t*)address = data;
}

/*!
 * @brief       SDRAM Write Half Word
 *
 * @param       address:the address to be programmed.
 *
 * @param       data: the data to be programmed.
 *
 * @retval      None
 *
 */
void SDRAM_WriteHalfWord(uint32_t address, uint16_t data)
{
    *(uint16_t*)address = (uint16_t)data;
}

/*!
 * @brief       SDRAM Write Byte
 *
 * @param       address:the address to be programmed.
 *
 * @param       data: the data to be programmed.
 *
 * @retval      None
 *
 */
void SDRAM_WriteByte(uint32_t address, uint8_t data)
{
    *(uint8_t*)address = data;
}

/*!
 * @brief       SDRAM GPIO Config
 *
 * @param       None
 *
 * @retval      None
 *
 */
static void SDRAM_GPIOConfig(void)
{
    GPIO_Config_T gpioConfig;

    RCM_EnableAPB2PeriphClock(RCM_SDRAM_GPIO_PERIPH);

    /* SDRAM pins assignment */
    /*
     +-------------------------+--------------------------+--------------------------+
     | PB10 <-> MMC_SDRAM_A9   | PC11 <-> MMC_SDRAM_D10   | PD3  <-> MMC_SDRAM_D12   |
     | PB11 <-> MMC_SDRAM_CKE  | PC12 <-> MMC_SDRAM_D11   | PD4  <-> MMC_SDRAM_D13   |
     |                         |                          | PD5  <-> MMC_SDRAM_D14   |
     |                         |                          | PD6  <-> MMC_SDRAM_D15   |
     |                         |                          | PD12 <-> MMC_SDRAM_CLK   |
     +-------------------------+--------------------------+--------------------------+
     | PE1  <-> MMC_SDRAM_D3   | PF0  <-> MMC_SDRAM_CS    | PG2  <-> MMC_SDRAM_UDQM  |
     | PE2  <-> MMC_SDRAM_D4   | PF1  <-> MMC_SDRAM_RAS   | PG3  <-> MMC_SDRAM_D9    |
     | PE3  <-> MMC_SDRAM_D5   | PF2  <-> MMC_SDRAM_CAS   | PG4  <-> MMC_SDRAM_D8    |
     | PE5  <-> MMC_SDRAM_D6   | PF3  <-> MMC_SDRAM_WE    | PG13 <-> MMC_SDRAM_D0    |
     | PE6  <-> MMC_SDRAM_D7   | PF6  <-> MMC_SDRAM_LDQM  | PG14 <-> MMC_SDRAM_D1    |
     | PE7  <-> MMC_SDRAM_A1   | PF11 <-> MMC_SDRAM_Bank  | PG15 <-> MMC_SDRAM_D2    |
     | PE8  <-> MMC_SDRAM_A2   | PF12 <-> MMC_SDRAM_A10   |                          |
     | PE9  <-> MMC_SDRAM_A3   | PF13 <-> MMC_SDRAM_A0    |                          |
     | PE11 <-> MMC_SDRAM_A4   |                          |                          |
     | PE12 <-> MMC_SDRAM_A5   |                          |                          |
     | PE13 <-> MMC_SDRAM_A6   |                          |                          |
     | PE14 <-> MMC_SDRAM_A7   |                          |                          |
     | PE15 <-> MMC_SDRAM_A8   |                          |                          |
     +-------------------------+--------------------------+--------------------------+
    */

    gpioConfig.speed = GPIO_SPEED_50MHz;
    gpioConfig.mode = GPIO_MODE_AF_PP;

    gpioConfig.pin = GPIO_PIN_10 | GPIO_PIN_11;
    GPIO_Config(GPIOB, &gpioConfig);

    gpioConfig.pin = GPIO_PIN_11 | GPIO_PIN_12;
    GPIO_Config(GPIOC, &gpioConfig);

    gpioConfig.pin = GPIO_PIN_12 | GPIO_PIN_3 |
                     GPIO_PIN_4 | GPIO_PIN_5 |
                     GPIO_PIN_6;
    GPIO_Config(GPIOD, &gpioConfig);

    gpioConfig.pin = GPIO_PIN_1 | GPIO_PIN_2 |
                     GPIO_PIN_3 | GPIO_PIN_5 |
                     GPIO_PIN_6 | GPIO_PIN_7 |
                     GPIO_PIN_8 | GPIO_PIN_9 |
                     GPIO_PIN_11 | GPIO_PIN_12 |
                     GPIO_PIN_13 | GPIO_PIN_14 |
                     GPIO_PIN_15;
    GPIO_Config(GPIOE, &gpioConfig);

    gpioConfig.pin = GPIO_PIN_0 | GPIO_PIN_1 |
                     GPIO_PIN_2 | GPIO_PIN_3 |
                     GPIO_PIN_6 |GPIO_PIN_11 |
                     GPIO_PIN_12 | GPIO_PIN_13;
    GPIO_Config(GPIOF, &gpioConfig);

    gpioConfig.pin = GPIO_PIN_2 | GPIO_PIN_3|
                     GPIO_PIN_4 | GPIO_PIN_13 |
                     GPIO_PIN_14 | GPIO_PIN_15;
    GPIO_Config(GPIOG, &gpioConfig);
}

/*!
 * @brief       SDRAM DMC Config
 *
 * @param       None
 *
 * @retval      None
 *
 */
static void SDRAM_DMCConfig(void)
{
    DMC_Config_T dmcConfig;

    RCM_EnableAHBPeriphClock(RCM_SDRAM_PERIPH);

    dmcConfig.bankWidth = DMC_BANK_WIDTH_1;
    dmcConfig.clkPhase = DMC_CLK_PHASE_REVERSE;
    dmcConfig.colWidth = DMC_COL_WIDTH_8;
    dmcConfig.memorySize = DMC_MEMORY_SIZE_2MB;
    dmcConfig.rowWidth = DMC_ROW_WIDTH_11;

    DMC_ConfigTimingStructInit(&dmcConfig.timing);

    DMC_Config(&dmcConfig);

    DMC_Enable();
}

/**@} end of group DMC_SDRAM_Functions */
/**@} end of group DMC_SDRAM */
/**@} end of group Examples */
