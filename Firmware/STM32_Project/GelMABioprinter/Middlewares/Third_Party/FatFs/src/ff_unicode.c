/*
 * ff_unicode.c
 *
 *  Created on: Oct 3, 2025
 *      Author: Simon
 */

#include "ff.h"
WCHAR ff_convert (WCHAR chr, UINT dir) { return chr < 0x100 ? chr : '?'; }
WCHAR ff_wtoupper (WCHAR chr) {
  if (chr >= 'a' && chr <= 'z') return (WCHAR)(chr - 'a' + 'A');
  return chr;
}

