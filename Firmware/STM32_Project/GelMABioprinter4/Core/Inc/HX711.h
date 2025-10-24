/*
 * HX711.h
 *
 *  Created on: Jul 31, 2025
 *      Author: Simon
 */
#ifndef INC_HX711_H_
#define INC_HX711_H_

#include "main.h"

// Pin configuration
#define DT_PORT GPIOD
#define DT_PIN GPIO_PIN_12
#define SCK_PORT GPIOD
#define SCK_PIN GPIO_PIN_11

// Public calibration variables
extern uint32_t tare;          // Raw ADC offset (Digital value with no load)
extern float    knownOriginal; // Known mass for calibration (mg)
extern float    knownHX711;    // Raw digital value corresponding to the known mass
extern int      weight;        // last computed weight in (integer) kg from weigh()

// Functions
void microDelay(uint16_t delay);
int32_t getHX711(void);
int weigh(void);

#endif /* INC_HX711_H_ */
