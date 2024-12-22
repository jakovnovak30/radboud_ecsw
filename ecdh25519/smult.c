#include <stdint.h>
#include "fe25519.h"
#include "group.h"
#include "smult.h"

// optimizations: fixed window scalar mult + custom squaring function + loop unrolling added to CFLAGS
int crypto_scalarmult(unsigned char *ss, const unsigned char *sk, const unsigned char *pk)
{
  group_ge p, k;
  unsigned char t[32];
  int i,j;

  for(i=1;i<31;i++) {
    t[i] = sk[i];
  }
  t[0] = sk[0] & 248;
  t[31] = (sk[31] & 127) | 64;

  if(group_ge_unpack(&p, pk)) return -1;

  // change point to montgomery representation
  // (x, y) |-> (u, v) = ((1+y) / (1-y), (1+y)/((1-y)*x))
  // https://en.wikipedia.org/wiki/Montgomery_curve#Equivalence_with_twisted_Edwards_curves
  fe25519 numerator = fe25519_one; // 1 + y
  fe25519_add(&numerator, &numerator, &p.y);
  fe25519 denominator = fe25519_one;
  fe25519_sub(&denominator, &denominator, &p.y); // 1 - y
  // k.x <- numerator / denominator = (1+y) / (1-y)
  fe25519_invert(&k.x, &denominator);
  fe25519_mul(&k.x, &k.x, &numerator);

  fe25519_mul(&denominator, &denominator, &p.x); // (1 - y) * x
  // k.y <- (1+y) / ((1-y)*x)
  fe25519_invert(&k.y, &denominator);
  fe25519_mul(&k.y, &k.y, &numerator);

  // montgomery scalar mult
  // algorithm: constant time montgomery ladder: https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication#Constant_time_Montgomery_ladder
  fe25519 _121665 = fe25519_zero;
  _121665.v[0] = 0x41; _121665.v[1] = 0xDB; _121665.v[2] = 0x1;

  // https://en.wikipedia.org/wiki/Montgomery_curve#Equivalence_with_twisted_Edwards_curves
  //
  fe25519 a, b, c, d, e, f;
  for (i = 0; i < 32; ++i) {
      b.v[i] = k.x.v[i];
      d.v[i] = a.v[i] = c.v[i] = 0;
    }
    a.v[0] = d.v[0] = 1;
  for (i = 254; i >= 0; --i) {
    uint32_t bit = (t[i >> 3] >> (i & 7)) & 1;
    fe25519_swap(&a, &b, bit);
    fe25519_swap(&c, &d, bit);
    fe25519_add(&e, &a, &c);
    fe25519_sub(&a, &a, &c);
    fe25519_add(&c, &b, &d);
    fe25519_sub(&b, &b, &d);
    fe25519_mul(&d, &e, &e);
    fe25519_mul(&f, &a, &a);
    fe25519_mul(&a, &c, &a);
    fe25519_mul(&c, &b, &e);
    fe25519_add(&e, &a, &c);
    fe25519_sub(&a, &a, &c);
    fe25519_mul(&b, &a, &a);
    fe25519_sub(&c, &d, &f);
    fe25519_mul(&a, &c, &_121665);
    fe25519_add(&a, &a, &d);
    fe25519_mul(&c, &c, &a);
    fe25519_mul(&a, &d, &f);
    fe25519_mul(&d, &b, &k.x);
    fe25519_mul(&b, &e, &e);
    fe25519_swap(&a, &b, bit);
    fe25519_swap(&c, &d, bit);
  }
  fe25519_invert(&c, &c);
  fe25519_mul(&a, &a, &c);

  // a == u
  // v^2 == u^3 + Au^2 + u
  // A = 486662 = 76D06
  fe25519 v_sqr = fe25519_zero;
  fe25519 x_cubed;
  fe25519 A = fe25519_zero;
  A.v[0] = 0x06; A.v[1] = 0x6D; A.v[2] = 0x07;

  // change point back to edwards representation
  // (u, v) |-> (x, y) = (u/v, (u-1)/(u+1))
  fe25519_mul(&v_sqr, &a, &a); // x^2
  fe25519_mul(&x_cubed, &a, &v_sqr); // x^3
  fe25519_mul(&v_sqr, &v_sqr, &A); // Ax^2
  fe25519_add(&v_sqr, &v_sqr, &a); // Ax^2 + x
  fe25519_add(&v_sqr, &v_sqr, &x_cubed); // x^3 + Ax^2 + x

  fe25519 inv_v;
  fe25519_invsqrt(&inv_v, &v_sqr); // inv_v <- 1 / sqrt(v_sqr) = 1/v
  fe25519_sub(&numerator, &a, &fe25519_one); // num <- u - 1
  fe25519_add(&denominator, &a, &fe25519_one); // den <- u + 1
  // k.x <- u / v
  fe25519_mul(&k.x, &a, &inv_v);
  // k.y <- (u-1)/(u+1)
  fe25519_invert(&denominator, &denominator);
  fe25519_mul(&k.y, &numerator, &denominator);

  //k.t = fe25519_one;
  //k.z = fe25519_one;

  group_ge_pack(ss, &k);
  return 0;
}

int crypto_scalarmult_base(unsigned char *pk, const unsigned char *sk)
{
  unsigned char t[GROUP_GE_PACKEDBYTES];
  group_ge_pack(t, &group_ge_base);
  return crypto_scalarmult(pk, sk, t);
}


