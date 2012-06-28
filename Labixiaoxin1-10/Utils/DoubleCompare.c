//
//  DoubleCompare.c
//  Three Hundred
//
//  Created by skye on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "DoubleCompare.h"

int getExpoBase2(double d);

int getExpoBase2(double d)
{
    int i = 0;
    ((short *)(&i))[0] = (((short *)(&d))[3] & (short)32752); // _123456789ab____ & 0111111111110000
    return (i >> 4) - 1023;
}

bool equals(double d1, double d2)
{
    if (d1 == d2)
        return true;
    int e1 = getExpoBase2(d1);
    int e2 = getExpoBase2(d2);
    int e3 = getExpoBase2(d1 - d2);
    if ((e3 - e2 < -48) && (e3 - e1 < -48))
        return true;
    return false;
}

int compare(double d1, double d2)
{
    if (equals(d1, d2) == true)
        return 0;
    if (d1 > d2)
        return 1;
    return -1;
}

bool greater(double d1, double d2)
{
    if (equals(d1, d2) == true)
        return false;
    if (d1 > d2)
        return true;
    return false;    
}

bool greaterOrEqual(double d1, double d2)
{
    if (equals(d1, d2) == true)
        return true;
    if (d1 > d2)
        return true;
    return false;    
}

bool less(double d1, double d2)
{
    if (equals(d1, d2) == true)
        return false;
    if (d1 < d2)
        return true;
    return false;    
}

bool lessOrEqual(double d1, double d2)
{
    if (equals(d1, d2) == true)
        return true;
    if (d1 < d2)
        return true;
    return false;    
}

