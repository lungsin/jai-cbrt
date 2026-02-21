// The jai code is a modified version of the original C code from
// http://www.netlib.org/fdlibm/s_cbrt.c and came with the following notice.

/*
 * ====================================================
 * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
 *
 * Developed at SunSoft, a Sun Microsystems, Inc. business.
 * Permission to use, copy, modify, and distribute this
 * software is freely granted, provided that this notice
 * is preserved.
 * ====================================================
 *
 */

// cbrt returns the cube root of x.
cbrt :: (x: float64) -> float64 {
    B1 :: 715094163; // B1 = (682-0.03306235651)*2**20
    B2 :: 696219795; // B2 = (664-0.03306235651)*2**20
    C :: 5.42857142857142815906e-01; // 19/35     = 0x3FE15F15, 0xF15F15F1
    D :: -7.05306122448979611050e-01; // -864/1225 = 0xBFE691DE, 0x2532C834
    E :: 1.41428571428571436819e+00; // 99/70     = 0x3FF6A0EA, 0x0EA0EA0F
    F :: 1.60714285714285720630e+00; // 45/28     = 0x3FF9B6DB, 0x6DB6DB6E
    G :: 3.57142857142857150787e-01; // 5/14      = 0x3FD6DB6D, 0xB6DB6DB7

    // special cases
    if x == 0 || is_nan_or_inf(x) return x;

    // Copy x to FloatInt64 for crazy blackmagic bit manipulation
    x_raw: FloatInt64 = ---;
    x_raw._float64 = x;

    sign := x_raw._u64 & 0x8000_0000_0000_0000; // sign = signbit(x)
    x_raw._u64 ^= sign; // x <- |x|

    // rough cbrt to 5 bits
    t_raw: FloatInt64 = ---;
    if (x_raw._u64 < 0x0010_0000_0000_0000) {
        // subnormal number
        t_raw._u64 = 0x4350_0000_0000_0000; // set t= 2**54 
        t_raw._float64 *= x_raw._float64;
        t_raw._u64 = t_raw._u64 / 3 + (B2 << 32);
    } else
        t_raw._u64 = x_raw._u64 / 3 + (B1 << 32);

    // new cbrt to 23 bits
    r := t_raw._float64 * t_raw._float64 / x_raw._float64;
    s := C + r * t_raw._float64;
    t_raw._float64 *= G + F / (s + E + D / s);

    // chopped to 20 bits and make it larger than cbrt(x)
    t_raw._u64 &= 0xffff_ffff_0000_0000;
    t_raw._u64 += 0x0000_0001_0000_0000;

    // one step newton iteration to 53 bits with error less than 0.667 ulps
    s = t_raw._float64 * t_raw._float64; // t*t is exact
    r = x_raw._float64 / s;
    w := t_raw._float64 + t_raw._float64;
    r = (r - t_raw._float64) / (w + r); // r-s is exact
    t_raw._float64 = t_raw._float64 + t_raw._float64 * r;

    // retore the sign bit
    t_raw._u64 ^= sign;
    return t_raw._float64;
}

#scope_file

#import "Math";

is_nan_or_inf :: inline (x: float64) -> bool {
    is_nan, is_inf := is_nan_is_inf(x);
    return is_nan || is_inf;
}

// Helper type for crazy blackmagic bit manipulation
FloatInt64 :: union {
    _u64: u64;
    _float64: float64;
}
