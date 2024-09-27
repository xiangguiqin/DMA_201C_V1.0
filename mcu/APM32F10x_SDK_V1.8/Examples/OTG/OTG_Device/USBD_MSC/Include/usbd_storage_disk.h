/*!
 * @file        usbd_storage_disk.h
 *
 * @brief       usb device storage disk operations functions
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
#include "usbd_msc.h"
#include "usbd_init.h"

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBD_MSC
  @{
  */

/** @defgroup USBD_MSC_Macros Macros
  @{
*/

#define USBD_STD_INQUIRY_LENGTH          36

/* define Storage disk block num and size */
#define STORAGE_BLK_SIZ                  MSC_MEDIA_PACKET

#define STORAGE_BLK_NBR                  (100 * 1024)

/**@} end of group USBD_MSC_Macros*/

/** @defgroup USBD_MSC_Functions Functions
  @{
  */

typedef uint8_t (*STORAGE_Init_T)(uint8_t lun);
typedef uint8_t (*STORAGE_ReadCapacity_T)(uint8_t lun, uint32_t *blockNum, uint32_t *blockSize);
typedef uint8_t (*STORAGE_CheckReady_T)(uint8_t lun);
typedef uint8_t (*STORAGE_CheckWPR_T)(uint8_t lun);
typedef uint8_t (*STORAGE_Read_T)(uint8_t lun, uint8_t *buf, uint32_t blkAddr, uint16_t blkLen);
typedef uint8_t (*STORAGE_Write_T)(uint8_t lun, uint8_t *buf, uint32_t blkAddr, uint16_t blkLen);

/**@} end of group USBD_MSC_Functions */

/** @defgroup USBD_MSC_Structures Structures
  @{
  */

typedef struct
{
    STORAGE_Init_T         Init;
    STORAGE_ReadCapacity_T ReadCapacity;
    STORAGE_CheckReady_T   CheckReady;
    STORAGE_CheckWPR_T     CheckWPR;
    STORAGE_Read_T         ReadData;
    STORAGE_Write_T        WriteData;
    uint8_t *pInquiryData;
} STORAGE_Callback_T;

/**@} end of group USBD_MSC_Structures*/

/** @defgroup USBD_MSC_Variables Variables
  @{
  */

extern STORAGE_Callback_T g_storageCallBack;

/**@} end of group USBD_MSC_Variables*/
/**@} end of group USBD_MSC */
/**@} end of group Examples */
