/**
 * @file av_main.c
 *
 * @brief sample main entry for audio/video based software
 */
#include "av_main.h"
#include "global_var.h"

extern uint8 EdidHdmi2p0;
extern uint8 LogicOutputSel;
AvPort gsv2k11Ports[9];
//void vResolutionSwitch(AvPort *port);
/**
 * @brief  sample main entry for audio/video based software
 * @return never return
 */
#ifdef GSV_BASE_PROJECT
int main(void)
#else
void GsvMain_thread_entry(void *parameter)
#endif

{
    /* 1. Low Level Hardware Level Initialization */
    /* 1.1 init bsp support (user speficic) */
    BspInit();

    /* 1.2 init software package and hookup user's bsp functions */
    AvApiInit();
    AvApiHookBspFunctions(&BspI2cRead, &BspI2cWrite, &BspUartSendByte,
                          &BspUartGetByte, &BspGetMilliSecond, &BspGetKey, &BspIrdaGetByte);
    AvApiHookUserFunctions(&ListenToKeyCommand, &ListenToUartCommand, &ListenToIrdaCommand);

    /* 2. Device Level Declaration */
    /* 2.1 total devices */
    /* it must be declared in AvDevice */
    AvDevice devices[1];

    /* 2.2 specific devices and ports */
    /* they must be able to be linked to the device in 1. */
    Gsv2k11Device gsv2k11_0;
//    AvPort gsv2k11Ports[9];

    /* 2.3 init device address in 2.2 */
    gsv2k11_0.DeviceAddress = AvGenerateDeviceAddress(0x00,0x01,0xB0,0x00);

    /* 2.4 connect devices to device declaration */
    AvApiAddDevice(&devices[0], Gsv2k11, 0, (void *)&gsv2k11_0, (void *)&gsv2k11Ports[0],  NULL);

    /* 3. Port Level Declaration */
    /* 3.1 init devices and port structure, must declare in number order */
    /* 0-3 HdmiRx, 4-7 HdmiTx, 8-9 TTLTx, 10-11 TTLRx,
       20-23 Scaler, 24-27 Color, 28 VideoGen, 30 VideoIn, 32 VideoOut,
       34 AudioGen, 36 ClockGen */
    AvApiAddPort(&devices[0],&gsv2k11Ports[0] ,0 ,HdmiRx);
    AvApiAddPort(&devices[0],&gsv2k11Ports[1] ,5 ,HdmiTx);
    AvApiAddPort(&devices[0],&gsv2k11Ports[2] ,32,LogicVideoTx);
    AvApiAddPort(&devices[0],&gsv2k11Ports[3] ,8 ,LogicAudioTx);
    AvApiAddPort(&devices[0],&gsv2k11Ports[4] ,20,VideoScaler);
    AvApiAddPort(&devices[0],&gsv2k11Ports[5] ,24,VideoColor);
    AvApiAddPort(&devices[0],&gsv2k11Ports[6] ,28,VideoGen);
    AvApiAddPort(&devices[0],&gsv2k11Ports[7] ,30,LogicVideoRx);
    AvApiAddPort(&devices[0],&gsv2k11Ports[8] ,10,LogicAudioRx);

    /* 3.2 initialize port content */
#if AvEnableCecFeature
    gsv2k11Ports[1].content.cec->CecEnable = 1;
    if(AudioStatus == 0)
        gsv2k11Ports[1].content.cec->EnableAudioAmplifier = AV_CEC_AMP_TO_DISABLE;
    else
    {
        gsv2k11Ports[1].content.cec->EnableAudioAmplifier = AV_CEC_AMP_TO_ENABLE;
        gsv2k11Ports[1].content.cec->EnableARC = AV_CEC_ARC_TO_INITIATE;
    }
    Cec_Tx_Audio_Status.Volume = 30;
    Cec_Tx_Audio_Status.Mute   = 0;    /*  */
    Cec_Tx_Audio_Status.AudioMode = 1; /* Audio Mode is ON to meet ARC */
    Cec_Tx_Audio_Status.AudioRate = 1; /* 100% rate */
    Cec_Tx_Audio_Status.AudioFormatCode = AV_AUD_FORMAT_LINEAR_PCM; /* Follow Spec */
    Cec_Tx_Audio_Status.MaxNumberOfChannels = 2; /* Max Channels */
    Cec_Tx_Audio_Status.AudioSampleRate = 0x07; /* 32KHz/44.1KHz/48KHz */
    Cec_Tx_Audio_Status.AudioBitLen = 0x01;  /* 16-bit only */
    Cec_Tx_Audio_Status.MaxBitRate  = 0;  /* default */
    Cec_Tx_Audio_Status.ActiveSource = 0; /* default */
#endif

    /* 3.3 init fsms */
    AvApiInitDevice(&devices[0]);
    AvApiPortStart();

    /* 3.4 routing */
    /* connect the port by video using AvConnectVideo */
    /* connect the port by audio using AvConnectAudio */
    /* connect the port by video and audio using AvConnectAV */

    /* 3.4.1 video routing */
    /* CHIP1 setting */
    /* case 1: default routing RxA->TxB */
    if(LogicOutputSel == 1)
    {
        AvApiConnectPort(&gsv2k11Ports[0], &gsv2k11Ports[1], AvConnectAV);
//        AvApiConnectPort(&gsv2k11Ports[0], &gsv2k11Ports[2], AvConnectVideo);
        AvApiConnectPort(&gsv2k11Ports[0], &gsv2k11Ports[3], AvConnectAudio);
    }
    /* case 2: routing of LogicTx/Rx->TxB */
    else
    {
        AvApiConnectPort(&gsv2k11Ports[7], &gsv2k11Ports[1], AvConnectVideo);
        AvApiConnectPort(&gsv2k11Ports[8], &gsv2k11Ports[1], AvConnectAudio);
    }
    LogicLedOut(LogicOutputSel);

    /* 3.4.2 ARC Connection, set after rx port connection to avoid conflict */
#if AvEnableCecFeature
    if(AudioStatus == 1)
    {
        AvApiConnectPort(&gsv2k11Ports[0], &gsv2k11Ports[1], AvConnectAudio);
    }
#endif

    /* 3.4.3 Internal Video Generator*/
#if AvEnableInternalVideoGen
    gsv2k11Ports[6].content.video->timing.Vic = 0x10; /* 1080p60 */
    gsv2k11Ports[6].content.video->AvailableVideoPackets = AV_BIT_AV_INFO_FRAME;
    gsv2k11Ports[6].content.video->Cd         = AV_CD_24;
    gsv2k11Ports[6].content.video->Y          = AV_Y2Y1Y0_RGB;
    gsv2k11Ports[6].content.vg->Pattern       = AV_PT_COLOR_BAR;
#endif

    /* 3.4.4 Audio Insertion */
#if AvEnableAudioTTLInput
    gsv2k11Ports[8].content.audio->AudioMute    = 0;
    gsv2k11Ports[8].content.audio->AudFormat    = AV_AUD_I2S;
    gsv2k11Ports[8].content.audio->AudType      = AV_AUD_TYPE_ASP;
    gsv2k11Ports[8].content.audio->AudCoding    = AV_AUD_FORMAT_LINEAR_PCM;
    gsv2k11Ports[8].content.audio->AudMclkRatio = AV_MCLK_256FS;
    gsv2k11Ports[8].content.audio->Layout       = 1;    /* 2 channel Layout = 0 */
    gsv2k11Ports[8].content.audio->Consumer     = 0;    /* Consumer */
    gsv2k11Ports[8].content.audio->Copyright    = 0;    /* Copyright asserted */
    gsv2k11Ports[8].content.audio->Emphasis     = 0;    /* No Emphasis */
    gsv2k11Ports[8].content.audio->CatCode      = 0;    /* Default */
    gsv2k11Ports[8].content.audio->SrcNum       = 0;    /* Refer to Audio InfoFrame */
    gsv2k11Ports[8].content.audio->ChanNum      = 8;    /* Audio Channel Count */
    gsv2k11Ports[8].content.audio->SampFreq     = AV_AUD_FS_48KHZ; /* Sample Frequency */
    gsv2k11Ports[8].content.audio->ClkAccur     = 0;    /* Level 2 */
    gsv2k11Ports[8].content.audio->WordLen      = 0x0B; /* 24-bit word length */
#endif

    /* 3.4.5 Video Parallel Bus Input */
    /* CommonBusConfig = 0 to disable, CommonBusConfig = 1~64 for feature setting */
    uint8 CommonBusConfig = 7;
    gsv2k11Ports[2].content.lvtx->Config        = CommonBusConfig;
    /* 3.4.5.1 LogicVideoTx Port's Y and InCS
       = AV_Y2Y1Y0_INVALID/AV_CS_AUTO to do no 2011 color processing,
       = Dedicated Color for internal Color/Scaler Processing */
    if((ParallelConfigTable[CommonBusConfig*3 + 1] & 0x04) != 0)
    {
        gsv2k11Ports[2].content.video->Y           = AV_Y2Y1Y0_YCBCR_422;
        gsv2k11Ports[2].content.video->InCs        = AV_CS_YUV_709;
    }
    else
    {
		gsv2k11Ports[2].content.video->Y           = AV_Y2Y1Y0_YCBCR_444;
    	gsv2k11Ports[2].content.video->InCs        = AV_CS_LIM_YUV_709;
//        gsv2k11Ports[2].content.video->Y           = AV_Y2Y1Y0_INVALID;
//        gsv2k11Ports[2].content.video->InCs        = AV_CS_AUTO;
    }

    /* 3.4.5.2 LogicVideoTx Port's Limited Highest Pixel Clock Frequency
      = 600 to output HDMI 2.0 on Parallel bus,
      = 300 to output HDMI 1.4 on Parallel bus,
      = 150 to output 1080p on Parallel bus */
	/* =300, 4K50/60 will be down-scaled to 1080p50/60 */
    gsv2k11Ports[2].content.video->info.TmdsFreq   = 600;

    /* 3.4.6 Video Parallel Bus Input */
    gsv2k11Ports[7].content.video->timing.Vic  = 0x61; /* 4K60 */
    gsv2k11Ports[7].content.video->AvailableVideoPackets = AV_BIT_GC_PACKET | AV_BIT_AV_INFO_FRAME;
    gsv2k11Ports[7].content.video->Cd          = AV_CD_24;
    if((ParallelConfigTable[CommonBusConfig*3 + 1] & 0x04) != 0)
    {
        gsv2k11Ports[7].content.video->Y           = AV_Y2Y1Y0_YCBCR_422;
        gsv2k11Ports[7].content.video->InCs        = AV_CS_YUV_709;
    }
    else
    {
		gsv2k11Ports[7].content.video->Y           = AV_Y2Y1Y0_YCBCR_444;
    	gsv2k11Ports[7].content.video->InCs        = AV_CS_LIM_YUV_709;
//        gsv2k11Ports[7].content.video->Y           = AV_Y2Y1Y0_RGB;
//        gsv2k11Ports[7].content.video->InCs        = AV_CS_RGB;
    }

	
	
    gsv2k11Ports[7].content.lvrx->Config       = CommonBusConfig;

    /* 3.4.7 Video Parallel Bus Config */
    gsv2k11Ports[7].content.rx->VideoEncrypted = 0;
    if(LogicOutputSel == 1)
    {
        gsv2k11Ports[2].content.lvtx->Update       = 1;
    }
    else
    {
        gsv2k11Ports[7].content.lvrx->Update       = 1;
    }

    /* 4. routine */
    uint8 NewVic = 0x61;
    uint16 PixelFreq = 0;
    /* call update api to enter into audio/video software loop */
    while(1)
    {
		rt_enter_critical();
        AvApiUpdate();
        AvPortConnectUpdate(&devices[0]);
        /* 4.1 switch Vic based on frequency */
        if((LogicOutputSel == 0) && (gsv2k11Ports[7].content.lvrx->Lock == 1))
        {
            PixelFreq = gsv2k11Ports[7].content.video->info.TmdsFreq;
            if((ParallelConfigTable[CommonBusConfig*3 + 2] & 0x40) == 0x40)
            {
                if((ParallelConfigTable[CommonBusConfig*3 + 2] & 0x01) == 0x00)
                    PixelFreq = PixelFreq / 2;
            }
            else
            {
                if((ParallelConfigTable[CommonBusConfig*3 + 2] & 0x01) == 0x00)
                    PixelFreq = PixelFreq * 2;
            }
            if(PixelFreq > 590)
                NewVic = 0x61;
            else if(PixelFreq > 290)
                NewVic = 0x5F;
            else if(PixelFreq > 145)
                NewVic = 0x10;
            else if(PixelFreq > 70)
                NewVic = 0x04;
            else
                NewVic = 0x02;
            if(NewVic != gsv2k11Ports[7].content.video->timing.Vic)
            {
                gsv2k11Ports[7].content.video->timing.Vic = NewVic;
                gsv2k11Ports[7].content.lvrx->Update      = 1;
            }
        }
		
		
//		vResolutionSwitch(&gsv2k11Ports[0]);
//		rt_thread_yield();
//		rt_schedule();
		rt_exit_critical();
		rt_thread_mdelay(10);
    }
}


AvPort* get_gsv_port(void)
{
	return gsv2k11Ports;
}

uint8_t RxConfig = 1;
uint8_t VideoScan = 0;
//void vResolutionSwitch(AvPort *port)
//{
//	rt_err_t rt_err_event;
//	rt_uint32_t RecvedEvent;
//	extern rt_event_t xOsEvent;
//	rt_err_event = rt_event_recv( xOsEvent
//				                 ,EV_UART_RXCONFIG | EV_UART_VIDEOSCAN
//				                 ,RT_EVENT_FLAG_OR | RT_EVENT_FLAG_CLEAR
//				                 ,RT_WAITING_NO//,RT_WAITING_FOREVER
//				                 ,&RecvedEvent
//				                );
//	if(rt_err_event == RT_EOK){
//		if((RecvedEvent & EV_UART_RXCONFIG) || (RecvedEvent & EV_UART_VIDEOSCAN)){
//			rt_kprintf("DownScaler = %d\r\n", RxConfig);
////			DownScaler = get_uart_data();
//#if 0
//			if((next_PixelFreq>290)){//4k
//				port[1].content.lvtx->Config           = 9;//9:TTL BT.1120 24-bit, SDR mode, YCbCr 444
//			}else{//1080
//				port[1].content.lvtx->Config           = 8;//8:TTL 32-bit, SDR mode, YCbCr 422
//			}
//#endif		
//			if(VideoScan != 0x00){//I Resolution
//				gsv2k11Ports[7].content.lvrx->Config           = 7;//7:TTL 24-bit, SDR mode, YCbCr 444
//			}else{//P Resolution
//				if(RxConfig == 0x00){
//					gsv2k11Ports[7].content.lvrx->Config           = 9;//9:TTL BT.1120 24-bit, SDR mode, YCbCr 444
//				}else{
//					gsv2k11Ports[7].content.lvrx->Config           = 8;//8:TTL 32-bit, SDR mode, YCbCr 422
//				}
//			}
//			gsv2k11Ports[7].content.lvrx->Update = 1;
//		}
//	}
//#if 0	
//	if((LogicOutputSel == 0) && (gsv2k11Ports[7].content.lvrx->Lock == 1)){
//		GPIO_ResetBits(GPIOB, GPIO_Pin_3);
//	}else{
//		GPIO_SetBits(GPIOB, GPIO_Pin_3);
//	}
//#endif
//	
//}
//	uint8_t next_Interlaced = 0, current_Interlaced = 0;
//	uint8_t next_4k = 0, current_4k = 0;
//void vResolutionSwitch(AvPort *port)
//{
//
//	
//	next_Interlaced = GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_3);
//	next_4k = GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_4);
//	
//	if(next_Interlaced != current_Interlaced || (next_4k != current_4k)){
//		current_Interlaced = next_Interlaced;
//		current_4k = next_4k;
//		if(next_Interlaced != 0x00){//I Resolution
//			gsv2k11Ports[7].content.lvrx->Config           = 7;//7:TTL 24-bit, SDR mode, YCbCr 444
//		}else{//P Resolution
//			if(next_4k == 0x00){
//				gsv2k11Ports[7].content.lvrx->Config           = 9;//9:TTL BT.1120 24-bit, SDR mode, YCbCr 444
//			}else{
//				gsv2k11Ports[7].content.lvrx->Config           = 8;//8:TTL 32-bit, SDR mode, YCbCr 422
//			}
//		}
//		gsv2k11Ports[7].content.lvrx->Update = 1;
//	}
//	
//	
//}



