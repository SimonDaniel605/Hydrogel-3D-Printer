/*
 * HX711.c
 *
 *  Created on: Jul 31, 2025
 *      Author: Simon
 */
#include "HX711.h"
#include "main.h"

extern TIM_HandleTypeDef htim2;   // <-- tells the compiler htim2 exists elsewheres
uint32_t tare = 4273348;
float knownOriginal = 15000000;  // in milli gram
float knownHX711 = 25437;
int weight;

void microDelay(uint16_t delay)
{
  __HAL_TIM_SET_COUNTER(&htim2, 0);
  while (__HAL_TIM_GET_COUNTER(&htim2) < delay);
}

int32_t getHX711(void)
{
  uint32_t data = 0;
  uint32_t startTime = HAL_GetTick();
  while(HAL_GPIO_ReadPin(DT_PORT, DT_PIN) == GPIO_PIN_SET)
  {
    if(HAL_GetTick() - startTime > 200)
      return 0;
  }
  for(int8_t len=0; len<24 ; len++)
  {
    HAL_GPIO_WritePin(SCK_PORT, SCK_PIN, GPIO_PIN_SET);
    microDelay(1);
    data = data << 1;
    HAL_GPIO_WritePin(SCK_PORT, SCK_PIN, GPIO_PIN_RESET);
    microDelay(1);
    if(HAL_GPIO_ReadPin(DT_PORT, DT_PIN) == GPIO_PIN_SET)
      data ++;
  }
  data = data ^ 0x800000;
  HAL_GPIO_WritePin(SCK_PORT, SCK_PIN, GPIO_PIN_SET);
  microDelay(1);
  HAL_GPIO_WritePin(SCK_PORT, SCK_PIN, GPIO_PIN_RESET);
  microDelay(1);
  return data;
}

int weigh()
{
  int32_t  total = 0;
  int32_t  samples = 50;
  int milligram;
  float coefficient;
  for(uint16_t i=0 ; i<samples ; i++)
  {
      total += getHX711();
  }
  int32_t average = (int32_t)(total / samples);
  coefficient = knownOriginal / knownHX711;
  milligram = (int)(average-tare)*coefficient;
  return milligram/1000000;
}
