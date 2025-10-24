/*
 * max.h
 *
 *  Created on: Sep 15, 2025
 *      Author: Simon
 */

#ifndef INC_MAX_H_
#define INC_MAX_H_

#include "main.h"
#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void MAX6675_Init(SPI_HandleTypeDef *hspi);     // call once (e.g., after MX_SPI2_Init)
void MAX6675_Update(void);                      // call often (e.g., in SystemTasks)
float MAX6675_GetTemp(uint8_t ch);              // returns °C (NAN until first read)
uint8_t MAX6675_DataReady(uint8_t ch);          // 1 if we have a sample for ch (0..2)
void MAX6675_OnRxCplt(SPI_HandleTypeDef *hspi); // forward your HAL_SPI_RxCpltCallback

// MUX helpers (what you pasted; kept public so you can reuse from main if needed)
void MUX_Enable(uint8_t enable);
void MUX_Select(uint8_t ch);

#ifdef __cplusplus
}
#endif


#endif /* INC_MAX_H_ */
