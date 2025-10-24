/*
 * command.h
 *
 *  Created on: Sep 15, 2025
 *      Author: Simon
 */

#ifndef INC_COMMAND_H_
#define INC_COMMAND_H_

#pragma once
#include <stdint.h>
#include <stdbool.h>

// Call once at startup to queue your scripted moves
void Command_RunScript(void);

#endif /* INC_COMMAND_H_ */
