/*************************************************************************************
 Title	 :  MAXIM Integrated MAX6675 Library for STM32 Using HAL Libraries
 Author  :  Bardia Alikhan Afshar <bardia.a.afshar@gmail.com>
 Software:  STM32CubeIDE
 Hardware:  Any STM32 device
*************************************************************************************/
#include"MAX6675.h"
extern SPI_HandleTypeDef hspi2;

// ------------------- Variables ----------------
_Bool TCF=0;                                          // Thermocouple Connection acknowledge Flag
uint8_t DATARX[2];                                    // Raw Data from MAX6675

// ------------------- Functions ----------------
float Max6675_Read_Temp(void){
	float Temp=0;                                         // Temperature Variable
	HAL_GPIO_WritePin(SSPORT,SSPIN,GPIO_PIN_RESET);       // Low State for SPI Communication
	HAL_SPI_Receive(&hspi2,DATARX,1,50);                  // DATA Transfer
	HAL_GPIO_WritePin(SSPORT,SSPIN,GPIO_PIN_SET);         // High State for SPI Communication
	TCF=(((DATARX[0]|(DATARX[1]<<8))>>2)& 0x0001);        // State of Connecting
	Temp=((((DATARX[0]|DATARX[1]<<8)))>>3);               // Temperature Data Extraction
	Temp*=0.25;                                           // Data to Centigrade Conversation
	HAL_Delay(250);                                       // Waits for Chip Ready(according to Datasheet, the max time for conversion is 220ms)
	return Temp;
}


/*
void MUX_Enable(uint8_t enable)
{
#if defined(MUX_EN_Port) && defined(MUX_EN_Pin)
    HAL_GPIO_WritePin(MUX_EN_Port, MUX_EN_Pin, enable ? MUX_ENABLE : MUX_DISABLE);
#else
    (void)enable;
#endif
}

void MUX_Select(uint8_t ch)
{
    ch &= 0x7;
#ifdef MUX_A0_Port
    HAL_GPIO_WritePin(MUX_A0_Port, MUX_A0_Pin, (ch & 0x1) ? GPIO_PIN_SET : GPIO_PIN_RESET);
#endif
#ifdef MUX_A1_Port
    HAL_GPIO_WritePin(MUX_A1_Port, MUX_A1_Pin, (ch & 0x2) ? GPIO_PIN_SET : GPIO_PIN_RESET);
#endif
#ifdef MUX_A2_Port
    HAL_GPIO_WritePin(MUX_A2_Port, MUX_A2_Pin, (ch & 0x4) ? GPIO_PIN_SET : GPIO_PIN_RESET);
#endif
}
*/
