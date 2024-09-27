/*!
 * @file        apm32f10x_int.c
 *
 * @brief       Main Interrupt Service Routines
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
#include "main.h"
#include "apm32f10x_int.h"
#include "usbh_class_cdc.h"
#include "usbh_interrupt.h"
#include "usb_board.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBH_CDC
  @{
  */

/** @defgroup USBH_CDC_INT_Functions INT_Functions
  @{
*/

/*!
 * @brief   This function handles NMI exception
 *
 * @param   None
 *
 * @retval  None
 *
 */
void NMI_Handler(void)
{
}

/*!
 * @brief   This function handles Hard Fault exception
 *
 * @param   None
 *
 * @retval  None
 *
 */
void HardFault_Handler(void)
{
    /** Go to infinite loop when Hard Fault exception occurs */
    while (1)
    {
    }
}

/*!
 * @brief   This function handles Memory Manage exception
 *
 * @param   None
 *
 * @retval  None
 *
 */
void MemManage_Handler(void)
{
    /** Go to infinite loop when Memory Manage exception occurs */
    while (1)
    {
    }
}

/*!
 * @brief   This function handles Bus Fault exception
 *
 * @param   None
 *
 * @retval  None
 *
 */
void BusFault_Handler(void)
{
    /** Go to infinite loop when Bus Fault exception occurs */
    while (1)
    {
    }
}

/*!
 * @brief   This function handles Usage Fault exception
 *
 * @param   None
 *
 * @retval  None
 *
 */
void UsageFault_Handler(void)
{
    /** Go to infinite loop when Usage Fault exception occurs */
    while (1)
    {
    }
}

/*!
 * @brief   This function handles SVCall exception
 *
 * @param   None
 *
 * @retval  None
 *
 */
void SVC_Handler(void)
{
}

/*!
 * @brief   This function handles Debug Monitor exception
 *
 * @param   None
 *
 * @retval  None
 *
 */
void DebugMon_Handler(void)
{
}

/*!
 * @brief   This function handles PendSV_Handler exception
 *
 * @param   None
 *
 * @retval  None
 *
 */
void PendSV_Handler(void)
{
}

/*!
 * @brief   This function handles SysTick Handler
 *
 * @param   None
 *
 * @retval  None
 *
 */
void SysTick_Handler(void)
{
}

/*!
 * @brief   This function handles USB FS or HS Handler
 *
 * @param   None
 *
 * @retval  None
 *
 */
void OTG_FS_IRQHandler(void)
{
    USBH_OTG_IsrHandler();
}

/*!
 * @brief   This function handles TMR2 Handler
 *
 * @param   None
 *
 * @retval  None
 *
 */
void TMR2_IRQHandler(void)
{
    USB_Timer_IRQHandler();
}

/*!
 * @brief   This function handles External line 0 Handler
 *
 * @param   None
 *
 * @retval  None
 *
 */
void EINT0_IRQHandler(void)
{
    if(EINT_ReadIntFlag(EINT_LINE_0))
    {
        APM_MINI_LEDToggle(LED2);
        if(!GPIO_ReadInputBit(LED2_GPIO_PORT, LED2_PIN))
        {
            /* send data to cdc device */
            if(CDC_SendData(cdcDataOutBuff, 64))
            {
                printf(">> Buffer to send: %s\n",cdcDataOutBuff);
            }
        }
        else
        {
        }
        /* Clear EINT_LINE0 interrupt flag */
        EINT_ClearIntFlag(EINT_LINE_0);
    }
}

/*!
 * @brief   This function handles External lines 1 Handler
 *
 * @param   None
 *
 * @retval  None
 *
 */
void EINT1_IRQHandler(void)
{
    if(EINT_ReadIntFlag(EINT_LINE_1))
    {
        APM_MINI_LEDToggle(LED3);
        if(!GPIO_ReadInputBit(LED3_GPIO_PORT, LED3_PIN))
        {
            /* enable cdc get data */
            CDC_EnableGet();
            printf(">> Enable CDC Get data.\n");
        }
        else
        {
            /* disable cdc get data */
            CDC_DisableGet();
            printf(">> Disable CDC Get data\n");
        }
        /* Clear EINT_LINE0 interrupt flag */
        EINT_ClearIntFlag(EINT_LINE_1);
    }
}

/**@} end of group USBH_CDC_INT_Functions */
/**@} end of group USBH_CDC */
/**@} end of group Examples */
