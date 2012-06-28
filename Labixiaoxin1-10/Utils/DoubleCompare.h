//
//  DoubleCompare.h
//  Three Hundred
//
//  Created by skye on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef DOUBLE_COMPARE_H
#define DOUBLE_COMPARE_H

#ifndef __cplusplus

#define bool  _Bool

#define true  1
#define false 0

#endif

int compare(double d1, double d2);
bool equals(double d1, double d2);
bool greater(double d1, double d2);
bool greaterOrEqual(double d1, double d2);
bool less(double d1, double d2);
bool lessOrEqual(double d1, double d2);

#endif