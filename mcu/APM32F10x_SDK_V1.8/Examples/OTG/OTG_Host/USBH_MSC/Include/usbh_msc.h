/*!
 * @file        usbh_msc.h
 *
 * @brief       USB MSC core function head file
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

/* Define to prevent recursive inclusion */
#ifndef __USBH_MSC_H_
#define __USBH_MSC_H_

/* Includes */
#include "usbh_core.h"
#include "ff.h"
#include "diskio.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBH_MSC
  @{
  */


/** @defgroup USBH_MSC_Variables Variables
  @{
*/

extern FATFS *fs[FF_VOLUMES];
extern char fileScanPath[255];

/**@} end of group USBH_MSC_Variables */

/** @defgroup USBH_MSC_Functions Functions
  @{
*/

/* function declaration */
void USBH_MSC_Init(void);
uint8_t USBH_DeviceStatus(void);
uint8_t USB_DiskRead(uint8_t* buffer, uint32_t sector, uint32_t cnt);
uint8_t USB_DiskWrite(uint8_t* buffer, uint32_t sector, uint32_t cnt);

/* function declaration */
FRESULT FATFS_ScanFiles(char* path);
void FATFS_WriteReadFile(FIL *file);

/**@} end of group USBH_MSC_Functions */
/**@} end of group USBH_MSC */
/**@} end of group Examples */

#endif /* __USBH_MSC_H_ */
