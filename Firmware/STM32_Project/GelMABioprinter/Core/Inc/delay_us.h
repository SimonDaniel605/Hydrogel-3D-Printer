/*
 * delay_us.h
 *
 *  Created on: Sep 18, 2025
 *      Author: Simon
 */

#ifndef INC_DELAY_US_H_
#define INC_DELAY_US_H_

#pragma once
#include "main.h"
#include "stm32f4xx_hal.h"

// Use a free timer (TIM5)
void delay_us_init(TIM_HandleTypeDef *htim);
void delay_us(uint32_t us);

#endif /* INC_DELAY_US_H_ */
