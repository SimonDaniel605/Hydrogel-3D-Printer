/*
 * mosfets.h
 *
 *  Created on: Sep 12, 2025
 *      Author: Simon
 */

#ifndef INC_MOSFET_H_
#define INC_MOSFET_H_

#include <stdbool.h>
#include <stdint.h>

typedef enum {
  MOSFET_NOZZLE = 0,   // PWM (TIM3_CH2 / PB5)
  MOSFET_FAN,          // PWM (TIM4_CH1 / PB6)
  MOSFET_UV,           // PWM (TIM4_CH2 / PB7)
  MOSFET_PELTIER       // GPIO (PB4). Optional timed duty helper below.
} mosfet_id_t;

/* Call after CubeMX peripheral init (TIMs/GPIO ready). */
void Mosfet_Init(void);

/* Set PWM duty in % (0..100) for PWM-controlled loads. */
void Mosfet_SetDuty(mosfet_id_t id, float percent);

/* Simple on/off for any channel. For PWM ones, on=100%, off=0%.
   For PELTIER, this drives the GPIO. */
void Mosfet_SetEnabled(mosfet_id_t id, bool on);

/* ---- Optional: time-based duty helper for the Peltier ----
   period_ms: total cycle time (e.g. 10000)
   on_ms: on-window (e.g. 2000)
   Set on_ms==0 to disable this helper and leave Peltier under direct control. */
void Mosfet_Peltier_SetTimedDuty(uint32_t period_ms, uint32_t on_ms);
void Mosfet_Peltier_Update(uint32_t now_ms);  // call from main loop

#endif /* INC_MOSFET_H_ */
