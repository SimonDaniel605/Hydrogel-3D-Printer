/*
 * mosfet.c
 *
 *  Created on: Sep 12, 2025
 *      Author: Simon
 */

#include "mosfet.h"
#include "system_pins.h"

static uint32_t pel_period_ms = 0;
static uint32_t pel_on_ms = 0;
static uint32_t pel_epoch_ms = 0;

static inline void pwm_write(TIM_HandleTypeDef *htim, uint32_t ch, float pct)
{
  if (pct < 0.0f) pct = 0.0f;
  if (pct > 100.0f) pct = 100.0f;
  uint32_t arr = __HAL_TIM_GET_AUTORELOAD(htim);
  uint32_t ccr = (uint32_t)((pct * (arr + 1U)) / 100.0f);
  __HAL_TIM_SET_COMPARE(htim, ch, ccr);
}

void Mosfet_Init(void)
{
  /* Start PWMs and default to 0% */
  HAL_TIM_PWM_Start(NOZZLE_TIM, NOZZLE_TIM_CH);
  pwm_write(NOZZLE_TIM, NOZZLE_TIM_CH, 0.0f);

  HAL_TIM_PWM_Start(FAN_TIM, FAN_TIM_CH);
  pwm_write(FAN_TIM, FAN_TIM_CH, 0.0f);

  HAL_TIM_PWM_Start(UV_TIM, UV_TIM_CH);
  pwm_write(UV_TIM, UV_TIM_CH, 0.0f);

  /* Peltier off */
  HAL_GPIO_WritePin(PELTIER_GPIO_Port, PELTIER_GPIO_Pin, GPIO_PIN_RESET);

  /* disable timed helper by default */
  pel_period_ms = 0;
  pel_on_ms = 0;
  pel_epoch_ms = 0;
}

void Mosfet_SetDuty(mosfet_id_t id, float percent)
{
  switch (id) {
    case MOSFET_NOZZLE: pwm_write(NOZZLE_TIM, NOZZLE_TIM_CH, percent); break;
    case MOSFET_FAN:    pwm_write(FAN_TIM,    FAN_TIM_CH,    percent); break;
    case MOSFET_UV:     pwm_write(UV_TIM,     UV_TIM_CH,     percent); break;
    case MOSFET_PELTIER:
      /* If you eventually switch PELTIER to PWM, you can hook it here.
         For now it's GPIO on/off; treat duty>=50% as ON. */
      HAL_GPIO_WritePin(PELTIER_GPIO_Port, PELTIER_GPIO_Pin,
                        (percent >= 50.0f) ? GPIO_PIN_SET : GPIO_PIN_RESET);
      break;
    default: break;
  }
}
/*
void Mosfet_SetEnabled(mosfet_id_t id, bool on)
{
  if (id == MOSFET_PELTIER) {
    HAL_GPIO_WritePin(PELTIER_GPIO_Port, PELTIER_GPIO_Pin, on ? GPIO_PIN_SET : GPIO_PIN_RESET);
    return;
  }
  pwm_write(
    (id==MOSFET_NOZZLE)?NOZZLE_TIM:(id==MOSFET_FAN)?FAN_TIM:UV_TIM,
    (id==MOSFET_NOZZLE)?NOZZLE_TIM_CH:(id==MOSFET_FAN)?FAN_TIM_CH:UV_TIM_CH,
    on ? 100.0f : 0.0f
  );
}


void Mosfet_Peltier_SetTimedDuty(uint32_t period_ms, uint32_t on_ms)
{
  pel_period_ms = period_ms;
  pel_on_ms = (on_ms > period_ms) ? period_ms : on_ms;
  pel_epoch_ms = 0; // re-sync on next Update call
}

void Mosfet_Peltier_Update(uint32_t now_ms)
{
  if (pel_period_ms == 0U) return;      // helper disabled
  if (pel_epoch_ms == 0U) pel_epoch_ms = now_ms;

  uint32_t phase = (now_ms - pel_epoch_ms) % pel_period_ms;
  bool on = (phase < pel_on_ms);
  HAL_GPIO_WritePin(PELTIER_GPIO_Port, PELTIER_GPIO_Pin,
                    on ? GPIO_PIN_SET : GPIO_PIN_RESET);
}
*/
