/*
 * Stepper.h
 *
 *  Created on: Jul 31, 2025
 *      Author: Simon
 */

#ifndef INC_STEPPER_H_
#define INC_STEPPER_H_

#include "main.h"

typedef enum {
    STEPPER_X = 0,
    STEPPER_Y,
    STEPPER_Z,
    STEPPER_E,
    STEPPER_COUNT
} StepperID;

typedef struct {
    GPIO_TypeDef* STEP_Port;
    uint16_t STEP_Pin;
    GPIO_TypeDef* DIR_Port;
    uint16_t DIR_Pin;
    GPIO_TypeDef* EN_Port;
    uint16_t EN_Pin;
    TIM_HandleTypeDef* htim;
    uint8_t direction;
    uint32_t steps_remaining;
    uint8_t active;
} StepperMotor;

void Stepper_Init(StepperID id, StepperMotor config);
void Stepper_SetDirection(StepperID id, uint8_t dir);
void Stepper_Move(StepperID id, uint32_t steps, uint32_t step_freq_hz);
void Stepper_Stop(StepperID id);
void Stepper_Enable(StepperID id);
void Stepper_Disable(StepperID id);
void Stepper_TIM_ISR(TIM_HandleTypeDef *htim);

// Cartesian interface
void moveTo(float x, float y, float z, float e, uint32_t speed_mm_s);
void setPosition(float x, float y, float z, float e);
void getPosition(float* x, float* y, float* z, float* e);


#endif /* INC_STEPPER_H_ */
