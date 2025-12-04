#ifndef _CUSTOMER_MAIN_H_
#define _CUSTOMER_MAIN_H_

#include <stdint.h>
#include <stdio.h>

void app_main_init(void);
uint32_t app_main_loop(void);
void app_sys_wakeup_callback(void);
void app_sys_sleep_prepare(void);


#endif

