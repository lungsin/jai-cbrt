# jai-cbrt

This is a jai port of cube root algorithm from [fdlibm](https://www.netlib.org/fdlibm/s_cbrt.c) library.

## Why?

At the time I'm writing this, there's no cube root routine in jai standard library.
I found out about the algorithm from [Golang standard library](https://go.dev/src/math/cbrt.go).

An alternative algorithm is from cephes math library. Actually, jai standard library has some routines ported from cephes.
But I didn't realize about the existance of [cephes](https://www.netlib.org/cephes/) until much later.

## Usage

Just copy-paste the code (don't forget to copy the license notice), or use it as a module.

```jai
#import "jai-cbrt"

x := cbrt(10.8);
```

