/*
 * stepper.h
 *
 *  Created on: Sep 10, 2025
 *      Author: Simon
 */

#ifndef INC_STEPPER_H_
#define INC_STEPPER_H_

#pragma once
#include "main.h"
#include <stdint.h>
#include <stdbool.h>

// System characteristics
#define STEPS_PER_REV 		200.0f //360 divided by 1.8 degrees per step
#define BELT_PITCH_MM 		2.0f
#define PULLEY_X_TEETH 		20.0f
#define PULLEY_Y_TEETH 		36.0f
#define LEAD_Z_MM      		8.0f
#define LEAD_E_MM			8.0f
#define EXTRUDER_GEAR_RATIO 3.0f
#define MICROSTEP     		16.0f
#define STEPS_MM_X  (STEPS_PER_REV * MICROSTEP / (PULLEY_X_TEETH * BELT_PITCH_MM))  // 80.00
#define STEPS_MM_Y  (STEPS_PER_REV * MICROSTEP / (PULLEY_Y_TEETH * BELT_PITCH_MM))  // 44.444..
#define STEPS_MM_Z  (STEPS_PER_REV * MICROSTEP / LEAD_Z_MM)                         // 400.00
#define STEPS_MM_E  (3 * STEPS_PER_REV * MICROSTEP / LEAD_E_MM )  					// 1200.00 (due to belt and pulley)

#ifndef STEP_HIGH_US
#define STEP_HIGH_US 5U    // A4988-safe high time
#endif

// Direction inversion (0 or 1). Set so that +X/+Y move away from their switches, and +Z moves UP (so DOWN is negative).
#define INVERT_X_DIR  0   // flip to 1 if +X goes toward the X switch
#define INVERT_Y_DIR  1   // flip to 1 if +Y goes toward the Y switch
#define INVERT_Z_DIR  0   // flip to 1 if +Z goes down (you want +Z to be UP)
#define INVERT_E_DIR  0   // flip to 1 if +E moves the extruder plate up instead of pushing the plunger down


void Stepper_Init_TIM1(void);
void Stepper_ResetPosition(float x, float y, float z, float e);

bool Stepper_QueueAbs(float x, float y, float z, float e, float feed_mm_s);
bool Stepper_QueueRel(float dx, float dy, float dz, float de, float feed_mm_s);

bool Stepper_IsIdle(void);

#endif /* INC_STEPPER_H_ */
