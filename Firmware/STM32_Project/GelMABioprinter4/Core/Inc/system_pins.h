/*
 * system_pins.h
 *
 *  Created on: Sep 10, 2025
 *      Author: Simon
 */

#ifndef INC_SYSTEM_PINS_H_
#define INC_SYSTEM_PINS_H_

#pragma once
#include "main.h"

/* ----------------------------- STEPPER PINS ------------------------------- */
// Universal A4988 Pins
#define EN_Port    	  GPIOE
#define EN_Pin		  GPIO_PIN_7
#define SLEEP_Port    GPIOC
#define SLEEP_Pin     GPIO_PIN_7
#define RESET_Port    GPIOC
#define RESET_Pin     GPIO_PIN_6
#define M0_Port       GPIOB
#define M0_Pin        GPIO_PIN_1
#define M1_Port       GPIOB
#define M1_Pin        GPIO_PIN_2
#define M2_Port    	  GPIOC
#define M2_Pin        GPIO_PIN_8

// X axis
#define STEP_X_Port   GPIOE
#define STEP_X_Pin    GPIO_PIN_9
#define DIR_X_Port    GPIOE
#define DIR_X_Pin     GPIO_PIN_8

// Y axis
#define STEP_Y_Port   GPIOE
#define STEP_Y_Pin    GPIO_PIN_11
#define DIR_Y_Port    GPIOE
#define DIR_Y_Pin     GPIO_PIN_10

// Z axis
#define STEP_Z_Port   GPIOE
#define STEP_Z_Pin    GPIO_PIN_13
#define DIR_Z_Port    GPIOE
#define DIR_Z_Pin     GPIO_PIN_12

// E (extruder)
#define STEP_E_Port   GPIOE
#define STEP_E_Pin    GPIO_PIN_14
#define DIR_E_Port    GPIOE
#define DIR_E_Pin     GPIO_PIN_15

/* --------------------------- LIMIT SWITCH PINS ---------------------------- */
// X axis
#define LIMIT_X_Port   GPIOC
#define LIMIT_X_Pin    GPIO_PIN_0

// Y axis
#define LIMIT_Y_Port   GPIOC
#define LIMIT_Y_Pin    GPIO_PIN_1

// Z axis
#define LIMIT_Z_Port   GPIOC
#define LIMIT_Z_Pin    GPIO_PIN_2


/* ------------------------------- MUX PINS --------------------------------- */
// TMUX1208 select pins (A0, A1, & A2) and EN.
#define MUX_A0_Port   GPIOD
#define MUX_A0_Pin    GPIO_PIN_8
#define MUX_A1_Port   GPIOD
#define MUX_A1_Pin    GPIO_PIN_9
#define MUX_A2_Port   GPIOD
#define MUX_A2_Pin    GPIO_PIN_10
#define MUX_EN_Port   GPIOB
#define MUX_EN_Pin    GPIO_PIN_15

// EN active high; inactive low
#define MUX_ENABLE    GPIO_PIN_SET
#define MUX_DISABLE   GPIO_PIN_RESET


/* --------------------------- SWITCHING MOSFETS ---------------------------- */
// Peltier
#define PELTIER_GPIO_Port	GPIOB
#define PELTIER_GPIO_Pin    GPIO_PIN_4

// Nozzle heater (PB5)
#define NOZZLE_TIM          (&htim3)
#define NOZZLE_TIM_CH       TIM_CHANNEL_2

// Cooling Fan (PB6)
#define FAN_TIM             (&htim4)
#define FAN_TIM_CH          TIM_CHANNEL_1

// UV Curing (PB7)
#define UV_TIM              (&htim4)
#define UV_TIM_CH           TIM_CHANNEL_2

// External TIM handles provided by CubeMX code
extern TIM_HandleTypeDef htim3;
extern TIM_HandleTypeDef htim4;


#endif /* INC_SYSTEM_PINS_H_ */
