/*!
 * @file        usbh_msc.c
 *
 * @brief       USB MSC core function
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
#include "usbh_msc.h"
#include "usbh_init.h"
#include "usbh_class_msc.h"
#include <string.h>
#include <stdio.h>

/** @addtogroup Examples
  @{
  */

/** @addtogroup USBH_MSC
  @{
  */

/** @defgroup USBH_MSC_Variables Variables
  @{
  */

/* workspace of logic disk */
FATFS *fs[FF_VOLUMES];
/* workspace of logic disk */
char fileScanPath[255] = "0:";

UINT byteReadWriteNum;
/* fatfs read buffer */
BYTE readBuffer[1024]={0};
/* fatfs write buffer */
BYTE writeBuffer[] ="Hello, Geehy!!";

/**@} end of group USBH_MSC_Variables */

/** @defgroup USBH_MSC_Functions Functions
  @{
  */

/*!
 * @brief       Init USB host MSC
 *
 * @param       None
 *
 * @retval      None
 */
void USBH_MSC_Init(void)
{
    USBH_InitParam_T param;

    param.classInitHandler = USBH_MSC_ClassInitHandler;
    param.classDeInitHandler = USBH_MSC_ClassDeInitHandler;
    param.classReqHandler  = USBH_MSC_ClassReqHandler;
    param.classCoreHandler = USBH_MSC_CoreHandler;
    param.suspendHandler = NULL;
    param.wakeUpHandler = NULL;
    param.intHandler = NULL;

    USBH_Init(&param);
}

/*!
 * @brief       Get the device connection status
 *
 * @param       None
 *
 * @retval      Device connection status.
 *              1 -> connected
 *              0 -> disconnected
 */
uint8_t USBH_DeviceStatus(void)
{
    return g_usbHost.connectedFlag;
}

/*!
 * @brief       USB_DiskRead
 *
 * @param       buffer:U-disk data buffer
 *
 * @param       sector:read sector
 *
 * @param       cnt:total number of sector
 *
 * @retval      Status
 */
uint8_t USB_DiskRead(uint8_t* buffer, uint32_t sector, uint32_t cnt)
{
    uint8_t status = USBH_BOT_FAIL;

    do
    {
        status = MSC_SCSI_Read10(buffer, sector, cnt);

        USBH_MSC_BOTXferHandler();
        if(!(USBH_DeviceStatus()))
        {
            status = USBH_BOT_FAIL;
            break;
        }

    }while(status == USBH_BOT_BUSY);

    return status;
}

/*!
 * @brief       USB_DiskWrite
 *
 * @param       buffer:U-disk data buffer
 *
 * @param       sector:read sector
 *
 * @param       cnt:total number of sector
 *
 * @retval      Status
 */
uint8_t USB_DiskWrite(uint8_t* buffer, uint32_t sector, uint32_t cnt)
{
    uint8_t status = USBH_BOT_FAIL;

    do
    {
        status = MSC_SCSI_Write10(buffer, sector, cnt);
        USBH_MSC_BOTXferHandler();
        if(!(USBH_DeviceStatus()))
        {
            status = USBH_BOT_FAIL;
            break;
        }

    }while(status == USBH_BOT_BUSY);

    return status;
}

 /*!
 * @brief       Traverse files of FatFs
 *
 * @param       path: init scan path
 *
 * @retval      File function return code
 *
 * @note        This function is assuming non-Unicode cfg
 */
FRESULT FATFS_ScanFiles(char* path)
{
    FRESULT status;
    /* file informations */
    FILINFO fileInfo;
    /* file directory */
    DIR dir;
    /* file name */
    char *fileName;
    uint32_t lengthScanPath;

#if _USE_LFN
    /* Simplified Chinese need two bytes to save a word */
    static char lfn[_MAX_LFN * 2 + 1];
    fileInfo.lfsize = sizeof(lfn);
    fileInfo.lfname = lfn;
#endif

    /* open directory */
    status = f_opendir(&dir,(const TCHAR*)path);
    if(status == FR_OK)
    {
        lengthScanPath = strlen(path);
        while(1)
        {
            /* Read the contents of the directory */
            status = f_readdir(&dir, &fileInfo);

            /* Error or read all items complete */
            if((status != FR_OK) || (fileInfo.fname[0] == 0))
            {
                break;
            }
#if _USE_LFN
            fileName = *fileInfo.lfname ? fileInfo.lfname : fileInfo.fname;
#else
            fileName = fileInfo.fname;
#endif
            /* Ignore parent directory */
            if(*fileName == '.')
            {
                continue;
            }
            /* It is a directory */
            if(fileInfo.fattrib & AM_DIR)
            {
                sprintf(&path[lengthScanPath], "/%s", fileName);

                /* recursive */
                status = FATFS_ScanFiles(path);
                path[lengthScanPath] = 0;
                if(status != FR_OK)
                {
                    break;
                }
            }
            /* It is a file */
            else
            {
                printf("%s/%s\r\n",path,fileName);
            }
        }
    }

    return status;
}

 /*!
 * @brief       Write a file to fatfs and read it
 *
 * @param       file: point to the file.
 *
 * @retval      None
 *
 */
void FATFS_WriteReadFile(FIL *file)
{
    FRESULT status;

    /* Write file */
    /* Open or create file */
    printf("------ Write File ------\r\n");
    status = f_open(file, "0:Host_MSC_Test.txt", FA_CREATE_ALWAYS | FA_WRITE);
    if(status == FR_OK)
    {
        printf(">> Open or create <Host_MSC_Test.txt> success.\r\n");
        printf(">> Write data to <Host_MSC_Test.txt>\r\n");

        /* Write data */
        status = f_write(file,writeBuffer,sizeof(writeBuffer),&byteReadWriteNum);
        if(status == FR_OK)
        {
            printf(">> Write %d bytes data to file.\r\n",byteReadWriteNum);
            printf(">> The data written to the file is \"%s\".\r\n",writeBuffer);
        }
        else
        {
            printf(">> Write data to file fail.\r\n");
        }

        /* Close file */
        f_close(file);
    }
    else
    {
        printf(">> Open or create file fail, status is %d\r\n",status);
    }

    /* Read file */
    /* Open file */
    printf("------ Read File ------\r\n");
    status = f_open(file, "0:Host_MSC_Test.txt",FA_OPEN_EXISTING | FA_READ);
    if(status == FR_OK)
    {
        printf(">> Open <Host_MSC_Test.txt> success.\r\n");
        status = f_read(file,readBuffer,sizeof(readBuffer),&byteReadWriteNum);
        if(status == FR_OK)
        {
            printf(">> Read %d bytes data from file.\r\n",byteReadWriteNum);
            printf(">> The data read from the file is \"%s\".\r\n",readBuffer);
        }
        else
        {
            printf(">> Read data from file fail!\r\n");
        }
    }
    else
    {
        printf(">> Open file fail, status is %d\r\n",status);
    }

    /* Close file */
    f_close(file);
}

/**@} end of group USBH_MSC_Functions */
/**@} end of group USBH_MSC */
/**@} end of group Examples */
