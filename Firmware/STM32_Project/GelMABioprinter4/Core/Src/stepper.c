/*
 * stepper.c
 *
 *  Created on: Sep 10, 2025
 *      Author: Simon
 */

#include "stepper.h"
#include "system_pins.h"
#include <math.h>
#include <string.h>

extern TIM_HandleTypeDef htim1;

// ---- internal plan / queue ----
typedef struct {
    uint32_t Nx, Ny, Nz, Ne, Nmax;
    int8_t   dirX, dirY, dirZ, dirE;
    uint32_t period_us;          // total period (hi+lo)
    uint32_t ex, ey, ez, ee;     // DDA accumulators
    uint32_t ticks_left;
    float tx, ty, tz, te;
} Plan;

static volatile Plan cur = {0};
static volatile uint8_t have_plan = 0;

static float Sx = STEPS_MM_X, Sy = STEPS_MM_Y, Sz = STEPS_MM_Z, Se = STEPS_MM_E;
static volatile float mx=0, my=0, mz=0, me=0;

#define QSIZE 128
typedef struct { float x,y,z,e,v; uint8_t rel; } Cmd;
static volatile Cmd q[QSIZE];
static volatile uint8_t qh=0, qt=0, qc=0;

static inline uint32_t u32rf(float v){ return (uint32_t)(v + 0.5f); }

static void enable_driver_and_microstep(void){
	// enable
    HAL_GPIO_WritePin(EN_Port,    EN_Pin,    GPIO_PIN_RESET);
    HAL_GPIO_WritePin(SLEEP_Port, SLEEP_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(RESET_Port, RESET_Pin, GPIO_PIN_SET);
    // 1/16
    HAL_GPIO_WritePin(M0_Port,    M0_Pin,    GPIO_PIN_SET);
    HAL_GPIO_WritePin(M1_Port,    M1_Pin,    GPIO_PIN_SET);
    HAL_GPIO_WritePin(M2_Port,    M2_Pin,    GPIO_PIN_SET);
}

static inline GPIO_PinState dir_level(int8_t sign, int invert) {
    uint8_t level = (sign > 0) ? 1u : 0u;   // 1 = "positive" direction
    level ^= (invert ? 1u : 0u);            // apply inversion
    return level ? GPIO_PIN_SET : GPIO_PIN_RESET;
}

static void set_dirs(int8_t dx, int8_t dy, int8_t dz, int8_t de){
    HAL_GPIO_WritePin(DIR_X_Port, DIR_X_Pin, dir_level(dx, INVERT_X_DIR));
    HAL_GPIO_WritePin(DIR_Y_Port, DIR_Y_Pin, dir_level(dy, INVERT_Y_DIR));
    HAL_GPIO_WritePin(DIR_Z_Port, DIR_Z_Pin, dir_level(dz, INVERT_Z_DIR));
    HAL_GPIO_WritePin(DIR_E_Port, DIR_E_Pin, dir_level(de, INVERT_E_DIR));
}


static void arm_timer_period_us(uint32_t total_us){
    if (total_us < (STEP_HIGH_US+1U)) total_us = STEP_HIGH_US+1U;
    __HAL_TIM_SET_AUTORELOAD(&htim1, total_us - 1U);
    __HAL_TIM_SET_COUNTER(&htim1, 0U);
}

static void build_plan(Plan *p, float tx, float ty, float tz, float te, float v){
    float dx = tx - mx, dy = ty - my, dz = tz - mz, de = te - me;
    float L  = sqrtf(dx*dx + dy*dy + dz*dz);

    if (L < 1e-9f && fabsf(de) < 1e-9f) { memset(p,0,sizeof(*p)); return; }

    p->dirX = (dx>=0)?+1:-1;  p->dirY = (dy>=0)?+1:-1;  p->dirZ = (dz>=0)?+1:-1;  p->dirE = (de>=0)?+1:-1;
    p->Nx = u32rf(fabsf(dx)*Sx);  p->Ny = u32rf(fabsf(dy)*Sy);  p->Nz = u32rf(fabsf(dz)*Sz);  p->Ne = (Se>0)?u32rf(fabsf(de)*Se):0;

    uint32_t nmax = p->Nx; if (p->Ny>nmax) nmax=p->Ny; if (p->Nz>nmax) nmax=p->Nz; if (p->Ne>nmax) nmax=p->Ne;
    p->Nmax = (nmax==0)?1:nmax;

    float v_mm_s = (v>0.0001f)? v : 5.0f;
    float length = (L>=1e-9f) ? L : fabsf(de);
    float T_s    = (length>0.0f) ? (length / v_mm_s) : 1e-3f;
    float f_m    = (float)p->Nmax / T_s;
    float per_us = 1e6f / f_m;
    if (per_us < (float)STEP_HIGH_US + 1.0f) per_us = (float)STEP_HIGH_US + 1.0f;
    p->period_us = (uint32_t)(per_us + 0.5f);

    p->ex=p->ey=p->ez=p->ee=0;  p->ticks_left = p->Nmax;
    p->tx=tx; p->ty=ty; p->tz=tz; p->te=te;
}

static int load_next_plan(void){
    if (qc==0) return 0;
    Cmd c = q[qt]; qt=(qt+1U)%QSIZE; qc--;

    float tx = c.rel ? (mx + c.x) : c.x;
    float ty = c.rel ? (my + c.y) : c.y;
    float tz = c.rel ? (mz + c.z) : c.z;
    float te = c.rel ? (me + c.e) : c.e;

    build_plan((Plan*)&cur, tx, ty, tz, te, c.v);
    if (cur.Nmax==0) return load_next_plan();

    set_dirs(cur.dirX, cur.dirY, cur.dirZ, cur.dirE);
    arm_timer_period_us(cur.period_us);
    have_plan = 1;
    return 1;
}

void Stepper_Init_TIM1(void){
    enable_driver_and_microstep();
    HAL_NVIC_SetPriority(TIM1_UP_TIM10_IRQn, 1, 0);
    HAL_NVIC_EnableIRQ(TIM1_UP_TIM10_IRQn);
    HAL_TIM_Base_Start_IT(&htim1);
    arm_timer_period_us(1000); // idle 1ms tick until a job loads
}

void Stepper_ResetPosition(float x,float y,float z,float e){
    __disable_irq(); mx=x; my=y; mz=z; me=e; __enable_irq();
}

static bool qpush(float x,float y,float z,float e,float v,uint8_t rel){
    __disable_irq();
    if (qc>=QSIZE){ __enable_irq(); return false; }
    q[qh]=(Cmd){x,y,z,e,v,rel}; qh=(qh+1U)%QSIZE; qc++;
    if (!have_plan) load_next_plan();
    __enable_irq();
    return true;
}

bool Stepper_QueueAbs(float x,float y,float z,float e,float feed){ return qpush(x,y,z,e,feed,0); }
bool Stepper_QueueRel(float dx,float dy,float dz,float de,float feed){ return qpush(dx,dy,dz,de,feed,1); }
bool Stepper_IsIdle(void){ return (qc==0 && !have_plan); }

// HAL callback
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim){
    if (htim->Instance != TIM1) return;
    if (!have_plan) return;

    uint8_t sx=0,sy=0,sz=0,se=0;
    cur.ex += cur.Nx; if (cur.ex >= cur.Nmax){ cur.ex -= cur.Nmax; sx=1; }
    cur.ey += cur.Ny; if (cur.ey >= cur.Nmax){ cur.ey -= cur.Nmax; sy=1; }
    cur.ez += cur.Nz; if (cur.ez >= cur.Nmax){ cur.ez -= cur.Nmax; sz=1; }
    if (cur.Ne){ cur.ee += cur.Ne; if (cur.ee >= cur.Nmax){ cur.ee -= cur.Nmax; se=1; } }

    if (sx) HAL_GPIO_WritePin(STEP_X_Port, STEP_X_Pin, GPIO_PIN_SET);
    if (sy) HAL_GPIO_WritePin(STEP_Y_Port, STEP_Y_Pin, GPIO_PIN_SET);
    if (sz) HAL_GPIO_WritePin(STEP_Z_Port, STEP_Z_Pin, GPIO_PIN_SET);
#ifdef STEP_E_Port
    if (se) HAL_GPIO_WritePin(STEP_E_Port, STEP_E_Pin, GPIO_PIN_SET);
#endif

    uint16_t t0 = __HAL_TIM_GET_COUNTER(&htim1);
    while ((uint16_t)(__HAL_TIM_GET_COUNTER(&htim1) - t0) < (uint16_t)STEP_HIGH_US) { __NOP(); }

    if (sx) HAL_GPIO_WritePin(STEP_X_Port, STEP_X_Pin, GPIO_PIN_RESET);
    if (sy) HAL_GPIO_WritePin(STEP_Y_Port, STEP_Y_Pin, GPIO_PIN_RESET);
    if (sz) HAL_GPIO_WritePin(STEP_Z_Port, STEP_Z_Pin, GPIO_PIN_RESET);
#ifdef STEP_E_Port
    if (se) HAL_GPIO_WritePin(STEP_E_Port, STEP_E_Pin, GPIO_PIN_RESET);
#endif

    if (--cur.ticks_left == 0){
        mx=cur.tx; my=cur.ty; mz=cur.tz; me=cur.te;
        have_plan = 0;
        if (!load_next_plan()) arm_timer_period_us(1000);
    }
}
