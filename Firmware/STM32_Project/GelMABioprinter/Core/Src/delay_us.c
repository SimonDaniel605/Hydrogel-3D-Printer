/*
 * delay_us.c
 *
 *  Created on: Sep 18, 2025
 *      Author: Simon
 */

#include "delay_us.h"

static TIM_HandleTypeDef *g_htim = NULL;
static uint8_t g_started = 0;


void delay_us_init(TIM_HandleTypeDef *htim) {
    if (g_htim == NULL) g_htim = htim;     // remember the handle
    if (!g_started) {
        __HAL_TIM_SET_COUNTER(g_htim, 0);
        HAL_TIM_Base_Start(g_htim);        // ensure that the timer is configured to 1 MHz
        g_started = 1;
    }
}
void delay_us(uint32_t us) {
    uint32_t start = __HAL_TIM_GET_COUNTER(g_htim);
    while ((uint32_t)(__HAL_TIM_GET_COUNTER(g_htim) - start) < us) {
        __NOP();
    }
}
