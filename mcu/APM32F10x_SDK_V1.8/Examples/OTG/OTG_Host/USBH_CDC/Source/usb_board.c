/*!
 * @file       usb_board.c
 *
 * @brief      This file provides firmware functions to USB board
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
#include "Board.h"
#include "usb_board.h"
#include "usb_user.h"
#include "drv_usb.h"
#include "usb_config.h"

/** @addtogroup Examples
  @{
*/

/** @addtogroup USBH_CDC
  @{
*/

/** @defgroup USBH_CDC_Variables Variables
  @{
*/

#if ((DELAY_SOURCE == USE_TIMER))
uint32_t TMR_delayCnt = 0;
uint32_t tmr2Clk = 0;
static void TMR2_Delay(uint32_t delayTime, uint8_t timeUnit);
#endif

/**@} end of group USBH_CDC_Variables */

/** @defgroup USBH_CDC_Functions Functions
  @{
*/

/*!
 * @brief       USB hardware Init
 *
 * @param       None
 *
 * @retval      None
 */
void USB_HardwareInit(void)
{
    GPIO_Config_T gpioConfig;

#ifdef APM32F10X_CL
    /* Enable Clock */
    RCM->AHBCLKEN |= BIT12;
    RCM_EnableAPB2PeriphClock(RCM_APB2_PERIPH_GPIOA | RCM_APB2_PERIPH_AFIO);

    /* USB DM, DP pin configuration */
    gpioConfig.mode  = GPIO_MODE_AF_PP;
    gpioConfig.speed = GPIO_SPEED_50MHz;
    gpioConfig.pin   = GPIO_PIN_11 | GPIO_PIN_12;
    GPIO_Config(GPIOA, &gpioConfig);

#if USB_VBUS_SWITCH
    gpioConfig.mode = GPIO_MODE_IN_FLOATING;
    gpioConfig.pin = GPIO_PIN_9;
    GPIO_Config(GPIOA, &gpioConfig);
#endif

    /* Disable USB Global interrupt */
    USB_OTG_DisableAllGlobalInterrupt();

    /* NVIC */
    NVIC_ConfigPriorityGroup(NVIC_PRIORITY_GROUP_1);
    NVIC_EnableIRQRequest(OTG_FS_IRQn, 1, 3);
#endif
    
#ifdef APM32F40X
#ifdef USB_OTG_FS
    FMC->ACCTRL = 0x05 | BIT8 | BIT9 | BIT10;

    /* Enable Clock */
    RCM_EnableAPB2PeriphClock(RCM_APB2_PERIPH_SYSCFG);
    RCM_EnableAHB2PeriphClock(RCM_AHB2_PERIPH_OTG_FS);
    RCM_EnableAHB1PeriphClock(RCM_AHB1_PERIPH_GPIOA);

    GPIO_ConfigPinAF(GPIOA, GPIO_PIN_SOURCE_11, GPIO_AF_OTG1_FS);
    GPIO_ConfigPinAF(GPIOA, GPIO_PIN_SOURCE_12, GPIO_AF_OTG1_FS);

    /* USB DM, DP pin configuration */
    gpioConfig.mode = GPIO_MODE_AF;
    gpioConfig.speed = GPIO_SPEED_100MHz;
    gpioConfig.otype = GPIO_OTYPE_PP;
    gpioConfig.pupd = GPIO_PUPD_NOPULL;
    gpioConfig.pin = GPIO_PIN_11 | GPIO_PIN_12;
    GPIO_Config(GPIOA, &gpioConfig);

    /* Configure VBUS Pin */
    gpioConfig.mode = GPIO_MODE_IN;
    gpioConfig.otype = GPIO_OTYPE_OD;
    gpioConfig.pin = GPIO_PIN_9;
    GPIO_Config(GPIOA, &gpioConfig);

    /* Disable USB Global interrupt */
    USB_OTG_DisableAllGlobalInterrupt();

    /* NVIC */
    NVIC_ConfigPriorityGroup(NVIC_PRIORITY_GROUP_1);
    NVIC_EnableIRQRequest(OTG_FS_IRQn, 1, 3);

#else
#ifdef OTG_HS_PHY_ULPI /* ULPI PHY */
    RCM_EnableAHB1PeriphClock(RCM_AHB1_PERIPH_GPIOA | RCM_AHB1_PERIPH_GPIOB | \
                              RCM_AHB1_PERIPH_GPIOC | RCM_AHB1_PERIPH_GPIOH | \
                              RCM_AHB1_PERIPH_GPIOI);

    GPIO_ConfigPinAF(GPIOA, GPIO_PIN_SOURCE_3, GPIO_AF_OTG2_HS);
    GPIO_ConfigPinAF(GPIOA, GPIO_PIN_SOURCE_5, GPIO_AF_OTG2_HS);
    GPIO_ConfigPinAF(GPIOB, GPIO_PIN_SOURCE_0, GPIO_AF_OTG2_HS);
    GPIO_ConfigPinAF(GPIOB, GPIO_PIN_SOURCE_1, GPIO_AF_OTG2_HS);
    GPIO_ConfigPinAF(GPIOB, GPIO_PIN_SOURCE_5, GPIO_AF_OTG2_HS);
    GPIO_ConfigPinAF(GPIOB, GPIO_PIN_SOURCE_10, GPIO_AF_OTG2_HS);
    GPIO_ConfigPinAF(GPIOB, GPIO_PIN_SOURCE_11, GPIO_AF_OTG2_HS);
    GPIO_ConfigPinAF(GPIOB, GPIO_PIN_SOURCE_12, GPIO_AF_OTG2_HS);
    GPIO_ConfigPinAF(GPIOB, GPIO_PIN_SOURCE_13, GPIO_AF_OTG2_HS);
    GPIO_ConfigPinAF(GPIOH, GPIO_PIN_SOURCE_4, GPIO_AF_OTG2_HS);
    GPIO_ConfigPinAF(GPIOI, GPIO_PIN_SOURCE_11, GPIO_AF_OTG2_HS);
    GPIO_ConfigPinAF(GPIOC, GPIO_PIN_SOURCE_0, GPIO_AF_OTG2_HS);

    /* CLK */
    gpioConfig.pin = GPIO_PIN_5;
    gpioConfig.speed = GPIO_SPEED_100MHz;
    gpioConfig.mode = GPIO_MODE_AF;
    GPIO_Config(GPIOA, &gpioConfig);

    /* D0 */
    gpioConfig.pin = GPIO_PIN_3;
    gpioConfig.otype = GPIO_OTYPE_PP;
    gpioConfig.pupd = GPIO_PUPD_NOPULL;
    GPIO_Config(GPIOA, &gpioConfig);

    /* D1, D2, D3, D4, D5, D6, D7 */
    gpioConfig.pin = GPIO_PIN_0 | GPIO_PIN_1 | GPIO_PIN_5 | GPIO_PIN_10 |
                     GPIO_PIN_11 | GPIO_PIN_12 | GPIO_PIN_13;
    GPIO_Config(GPIOB, &gpioConfig);

    /* STP */
    gpioConfig.pin = GPIO_PIN_0;
    GPIO_Config(GPIOC, &gpioConfig);

    /* NXT */
    gpioConfig.pin = GPIO_PIN_4;
    GPIO_Config(GPIOH, &gpioConfig);

    /* DIR */
    gpioConfig.pin = GPIO_PIN_11;
    GPIO_Config(GPIOI, &gpioConfig);

    RCM_EnableAHB1PeriphClock(RCM_AHB1_PERIPH_OTG_HS | RCM_AHB1_PERIPH_OTG_HS_ULPI);

#else /* UTMI PHY (OTG_HS_PHY_UTMI) */
    RCM_EnableAHB1PeriphClock(RCM_AHB1_PERIPH_GPIOB);

    gpioConfig.pin = GPIO_PIN_12 | GPIO_PIN_14 | GPIO_PIN_15;
    gpioConfig.speed = GPIO_SPEED_100MHz;
    gpioConfig.mode = GPIO_MODE_AF;
    GPIO_Config(GPIOB, &gpioConfig);

    GPIO_ConfigPinAF(GPIOB, GPIO_PIN_SOURCE_12, GPIO_AF_OTG_HS_FS);
    GPIO_ConfigPinAF(GPIOB, GPIO_PIN_SOURCE_14, GPIO_AF_OTG_HS_FS);
    GPIO_ConfigPinAF(GPIOB, GPIO_PIN_SOURCE_15, GPIO_AF_OTG_HS_FS);

    gpioConfig.pin = GPIO_PIN_13;
    gpioConfig.speed = GPIO_SPEED_100MHz;
    gpioConfig.mode = GPIO_MODE_IN;
    GPIO_Config(GPIOB, &gpioConfig);

    RCM_EnableAHB1PeriphClock(RCM_AHB1_PERIPH_OTG_HS);

    USB_OTG_HS2->USB_SWITCH_B.usb_switch = BIT_SET;
    USB_OTG_HS2->POWERON_CORE_B.poweron_core = BIT_SET;
    USB_OTG_HS2->OTG_SUSPENDM_B.otg_suspendm = BIT_SET;
    USB_OTG_HS2->SW_RREF_I2C_B.sw_rref_i2c = 0x05;
#endif
    /* Disable USB Global interrupt */
    USB_OTG_DisableAllGlobalInterrupt();

    /* NVIC */
    NVIC_ConfigPriorityGroup(NVIC_PRIORITY_GROUP_1);
    NVIC_EnableIRQRequest(OTG_HS1_IRQn, 1, 3);
#endif
#endif

    ConfigDelayTimer();
}

/*!
 * @brief       Handle USB Timer interrupt
 *
 * @param       None
 *
 * @retval      None
 */
void USB_Timer_IRQHandler(void)
{
#if ((DELAY_SOURCE == USE_TIMER))
  if(TMR_ReadIntFlag(TMR2, TMR_INT_UPDATE))
  {
    TMR_ClearIntFlag(TMR2, TMR_INT_UPDATE);
    if (TMR_delayCnt == 0x00)
    {
      TMR_Disable(TMR2);
    }
    else
    {
        TMR_delayCnt--;
    }
  }
#endif
}

/*!
 * @brief       microseconds delay function
 *
 * @param       delayTime : set the number of microseconds to delay
 *
 * @retval      None
 */
void USB_usDelay(uint32_t delayTime)
{
#if (DELAY_SOURCE == USE_TIMER)
    TMR2_Delay(delayTime, 0);
#else
    __IO uint32_t i = 0;
    __IO uint32_t j = 0;
    uint32_t cnt = (delayTime * 6);

    do
    {
        i++;
        j++;
    }
    while (i < cnt);

#endif
}

/*!
 * @brief       milliseconds delay function
 *
 * @param       delayTime : set the number of milliseconds to delay
 *
 * @retval      None
 */
void USB_msDelay(uint32_t delayTime)
{
#if (DELAY_SOURCE == USE_TIMER)
  TMR2_Delay(delayTime, 1);
#else
  USB_usDelay(delayTime * 1000);
#endif
}

/*!
 * @brief       Config Delay Timer 1ms Timer
 *
 * @param       None
 *
 * @retval      None
 */
void ConfigDelayTimer(void)
{
#if ((DELAY_SOURCE == USE_TIMER))
    TMR_BaseConfig_T TMR_BaseConfigStruct;
    uint32_t pClk2 = 0;

    RCM_ReadPCLKFreq(&tmr2Clk, &pClk2);

    /* Enable TMR2 Periph Clock */
    RCM_EnableAPB1PeriphClock(RCM_APB1_PERIPH_TMR2);

    TMR_BaseConfigStruct.division = 3;
    TMR_BaseConfigStruct.clockDivision = TMR_CLOCK_DIV_1;
    TMR_BaseConfigStruct.countMode = TMR_COUNTER_MODE_UP;

    /* T = (1 + period)*(1/((tmr2Clk*2)/(1+division))) */
    TMR_BaseConfigStruct.period = (tmr2Clk*2)/4/1000 - 1;

    /* Config TMR2 */
    TMR_ConfigTimeBase(TMR2, &TMR_BaseConfigStruct);
    TMR_EnableAutoReload(TMR2);

    /* Enable TMR2 Interrupt */
    NVIC_EnableIRQRequest(TMR2_IRQn, 0, 0);
    TMR_EnableInterrupt(TMR2, TMR_INT_UPDATE);
    TMR_Enable(TMR2);
#endif
}


#if ((DELAY_SOURCE == USE_TIMER))
/*!
 * @brief       enable TMR2 Timer to delay
 *
 * @param       delayTime : set the value to delay
 *
 * @param       timeUnit  : select time unit
 *                        This value can be one of the following values:
 *                        @arg 0 : delayTime unit is microseconds.
 *                        @arg 1 : delayTime unit is milliseconds.
 *
 * @retval      None
 */
static void TMR2_Delay(uint32_t delayTime, uint8_t timeUnit)
{
    TMR_BaseConfig_T TMR_BaseConfigStruct;

    TMR_Disable(TMR2);
    TMR_DisableInterrupt(TMR2, TMR_INT_UPDATE);
    TMR_ClearStatusFlag(TMR2, TMR_INT_UPDATE);

    /* set delay value */
    TMR_delayCnt = delayTime;

    TMR_BaseConfigStruct.division = 3;
    TMR_BaseConfigStruct.clockDivision = TMR_CLOCK_DIV_1;
    TMR_BaseConfigStruct.countMode = TMR_COUNTER_MODE_UP;

    /* T = (1 + period)*(1/((tmr2Clk*2)/(1+division))) */
    switch (timeUnit)
    {
        case 0:
            TMR_BaseConfigStruct.period = (tmr2Clk*2)/4/1000000 - 1;
            break;
        case 1 :
            TMR_BaseConfigStruct.period = (tmr2Clk*2)/4/1000 - 1;
            break;
        default :
            TMR_BaseConfigStruct.period = (tmr2Clk*2)/4/1000 - 1;
            break;
    }
    TMR_ConfigTimeBase(TMR2, &TMR_BaseConfigStruct);

    /* delay time start*/
    TMR_EnableInterrupt(TMR2, TMR_INT_UPDATE);
    TMR_Enable(TMR2);
    while (TMR_delayCnt > 0);

    /* delay time end*/
    TMR_Disable(TMR2);
}
#endif


/*!
 * @brief       Configures COM port.
 *
 * @param       COM: Specifies the COM port to be configured.
 *              This parameter can be one of following parameters:
 *              @arg COM1
 *              @arg COM2
 *
 * @retval      None
 */
void APM_BOARD_COMInit(COM_TypeDef COM, USART_Config_T* configStruct)
{
    #if defined (APM32F107_MINI)
    APM_MINI_COMInit(COM,configStruct);
    #elif defined (APM32F107_ELE_HUETB)
    APM_ELE_HUETB_COMInit(COM,configStruct);
    #elif defined (APM32F107_EVAL)
    APM_EVAL_COMInit(COM,configStruct);
    #else
    #error "Please select first the APM32  board to be used (in board.h)"
    #endif
}

#if defined (__CC_ARM) || defined (__ICCARM__) || (defined(__ARMCC_VERSION) && (__ARMCC_VERSION >= 6010050))

/*!
* @brief       Redirect C Library function printf to serial port.
*              After Redirection, you can use printf function.
*
* @param       ch:  The characters that need to be send.
*
* @param       *f:  pointer to a FILE that can recording all information
*              needed to control a stream
*
* @retval      The characters that need to be send.
*
* @note
*/
int fputc(int ch, FILE* f)
{
    /* send a byte of data to the serial port */
    USART_TxData(DEBUG_USART, (uint8_t)ch);

    /* wait for the data to be send */
    while (USART_ReadStatusFlag(DEBUG_USART, USART_FLAG_TXBE) == RESET);

    return (ch);
}

#elif defined (__GNUC__)

/*!
* @brief       Redirect C Library function printf to serial port.
*              After Redirection, you can use printf function.
*
* @param       ch:  The characters that need to be send.
*
* @retval      The characters that need to be send.
*
* @note
*/
int __io_putchar(int ch)
{
    /* send a byte of data to the serial port */
    USART_TxData(DEBUG_USART, ch);

    /* wait for the data to be send */
    while (USART_ReadStatusFlag(DEBUG_USART, USART_FLAG_TXBE) == RESET);

    return ch;
}

/*!
* @brief       Redirect C Library function printf to serial port.
*              After Redirection, you can use printf function.
*
* @param       file:  Meaningless in this function.
*
* @param       *ptr:  Buffer pointer for data to be sent.
*
* @param       len:  Length of data to be sent.
*
* @retval      The characters that need to be send.
*
* @note
*/
int _write(int file, char* ptr, int len)
{
    int i;
    for (i = 0; i < len; i++)
    {
        __io_putchar(*ptr++);
    }

    return len;
}

#else
#warning Not supported compiler type
#endif

/**@} end of group USBH_CDC_Functions */
/**@} end of group USBH_CDC */
/**@} end of group Examples */
