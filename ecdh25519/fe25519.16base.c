#include <stdio.h>
#include "fe25519.h"

#if 0
#define WINDOWSIZE 1 /* Should be 1,2, or 4 */
#define WINDOWMASK ((1<<WINDOWSIZE)-1)
#endif

const fe25519 fe25519_zero = {{0}};
const fe25519 fe25519_one  = {{1}};
const fe25519 fe25519_two  = {{2}};

/* sqrt(-1) */
const fe25519 fe25519_sqrtm1 = {{0xA0B0, 0x4A0E, 0x1B27, 0xC4EE, 0xE478, 0xAD2F, 0x1806, 0x2F43, 
                                 0xD7A7, 0x3DFB, 0x0099, 0x2B4D, 0xDF0B, 0x4FC1, 0x2480, 0x2B83}};

/* -sqrt(-1) */
const fe25519 fe25519_msqrtm1 = {{0x5F3D, 0xB5F1, 0xE4D8, 0x3B11, 0x1B87, 0x52D0, 0xE7F9, 0xD0BC, 
                                  0x2858, 0xC204, 0xFF66, 0xD4B2, 0x20F4, 0xB03E, 0xDB7F, 0x547C}};

/* -1 */
const fe25519 fe25519_m1 = {{0xffec, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 
                             0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0x7fff}};



static uint32_t equal(uint32_t a,uint32_t b) /* 16-bit inputs */
{
  uint32_t x = a ^ b; /* 0: yes; 1..65535: no */
  x -= 1; /* 4294967295: yes; 0..65534: no */
  x >>= 31; /* 1: yes; 0: no */
  return x;
}

static uint32_t ge(uint32_t a,uint32_t b) /* 16-bit inputs */
{
  uint32_t x = a;
  x -= (uint32_t) b; /* 0..65535: yes; 4294901761..4294967295: no */
  x >>= 31; /* 0: yes; 1: no */
  x ^= 1; /* 1: yes; 0: no */
  return x;
}

static uint32_t times19(uint32_t a)
{
  return (a << 4) + (a << 1) + a;
}

static uint32_t times38(uint32_t a)
{
  return (a << 5) + (a << 2) + (a << 1);
}

static void reduce_add_sub(fe25519 *r)
{
  uint32_t t;
  int i,rep;

  for(rep=0;rep<2;rep++)
  {
    t = r->v[15] >> 15;
    r->v[15] &= ((1 << 15) - 1);
    t = times19(t);
    r->v[0] += t;
    for(i=0;i<15;i++)
    {
      t = r->v[i] >> 16;
      r->v[i+1] += t;
      r->v[i] &= ((1 << 16) - 1);
    }
  }
}

static void reduce_mul(fe25519 *r)
{
  uint32_t t;
  int i,rep;

  for(rep=0;rep<3;rep++)
  {
    t = r->v[15] >> 15;
    r->v[15] &= ((1 << 15) - 1);
    t = times19(t);
    r->v[0] += t;
    for(i=0;i<15;i++)
    {
      t = r->v[i] >> 16;
      r->v[i+1] += t;
      r->v[i] &= ((1 << 16) - 1);
    }
  }
}

/* reduction modulo 2^255-19 */
void fe25519_freeze(fe25519 *r) 
{
  int i;
  uint32_t m = equal(r->v[15], (127 << 8) | 0xffff);
  for(i=14;i>0;i--)
    m &= equal(r->v[i], ((1 << 16) - 1));
  m &= ge(r->v[0],237 | (0xffff << 8));

  m = -m;

  r->v[15] -= m&((127 << 8) | 0xffff);
  for(i=14;i>0;i--)
    r->v[i] -= m&((1 << 16) - 1);
  r->v[0] -= m&(237 | (0xffff << 8));
}

void fe25519_unpack(fe25519 *r, const unsigned char x[32])
{
  int i;
  for(i=0;i<16;i++) r->v[i] = x[2*i] + (x[2*i + 1] << 8);
  r->v[15] &= ((127 << 8) | 0xffff);
}

/* Assumes input x being reduced below 2^255 */
void fe25519_pack(unsigned char r[32], const fe25519 *x)
{
  int i;
  fe25519 y = *x;
  fe25519_freeze(&y);
  for(i=0;i<16;i++) {
    r[2*i + 0] = y.v[i] & 0xffff;
    r[2*i + 1] = y.v[i] >> 8;
  }
}

int fe25519_iszero(const fe25519 *x)
{
  return fe25519_iseq(x, &fe25519_zero);
}

int fe25519_isone(const fe25519 *x)
{
  return fe25519_iseq(x, &fe25519_one);
}

// return true if x has LSB set
int fe25519_isnegative(const fe25519 *x)
{
  fe25519 t = *x;
  
  fe25519_freeze(&t);

  return t.v[0] & 1;
}

int fe25519_iseq(const fe25519 *x, const fe25519 *y)
{
  fe25519 t1,t2;
  int i,r=0;

  t1 = *x;
  t2 = *y;
  fe25519_freeze(&t1);
  fe25519_freeze(&t2);
  for(i=0;i<16;i++)
    r |= (1-equal(t1.v[i],t2.v[i]));
  return 1-r;
}

void fe25519_cmov(fe25519 *r, const fe25519 *x, unsigned char b)
{
  b = -b; // if b == 0 it stays the same, otherwise we get a mask
  for(int i = 0;i < 16;i++) {
    r->v[i] = (x->v[i] & b) ^ (r->v[i] & ~b);
  }
}

void fe25519_neg(fe25519 *r, const fe25519 *x)
{
  fe25519 t = fe25519_zero;
  fe25519_sub(r, &t, x);
}

void fe25519_add(fe25519 *r, const fe25519 *x, const fe25519 *y)
{
  int i;
  for(i=0;i<16;i++) r->v[i] = x->v[i] + y->v[i];
  reduce_add_sub(r);
}

void fe25519_double(fe25519 *r, const fe25519 *x)
{
  int i;
  for(i=0;i<16;i++) r->v[i] = 2*x->v[i];
  reduce_add_sub(r);
}

void fe25519_sub(fe25519 *r, const fe25519 *x, const fe25519 *y)
{
  int i;
  uint32_t t[16];
  t[0] = x->v[0] + 0xffed;
  t[15] = x->v[15] + 0x7fff;
  for(i=1;i<15;i++) t[i] = x->v[i] + 0xffff;
  for(i=0;i<16;i++) r->v[i] = t[i] - y->v[i];
  reduce_add_sub(r);
}

void fe25519_mul(fe25519 *r, const fe25519 *x, const fe25519 *y)
{
  int i,j;
  uint32_t t[31];
  for(i=0;i<31;i++)t[i] = 0;

  for(i=0;i<16;i++)
    for(j=0;j<16;j++)
      t[i+j] += x->v[i] * y->v[j];

  for(i=16;i<31;i++)
    r->v[i-16] = t[i-16] + times38(t[i]); 
  r->v[15] = t[15]; /* result now in r[0]...r[31] */

  reduce_mul(r);
}

void fe25519_square(fe25519 *r, const fe25519 *x)
{
  fe25519_mul(r, x, x);
}

#if 0
void fe25519_invert(fe25519 *r, const fe25519 *x)
{
	fe25519 z2;
	fe25519 z9;
	fe25519 z11;
	fe25519 z2_5_0;
	fe25519 z2_10_0;
	fe25519 z2_20_0;
	fe25519 z2_50_0;
	fe25519 z2_100_0;
	fe25519 t0;
	fe25519 t1;
	int i;
	
	/* 2 */ fe25519_square(&z2,x);
	/* 4 */ fe25519_square(&t1,&z2);
	/* 8 */ fe25519_square(&t0,&t1);
	/* 9 */ fe25519_mul(&z9,&t0,x);
	/* 11 */ fe25519_mul(&z11,&z9,&z2);
	/* 22 */ fe25519_square(&t0,&z11);
	/* 2^5 - 2^0 = 31 */ fe25519_mul(&z2_5_0,&t0,&z9);

	/* 2^6 - 2^1 */ fe25519_square(&t0,&z2_5_0);
	/* 2^7 - 2^2 */ fe25519_square(&t1,&t0);
	/* 2^8 - 2^3 */ fe25519_square(&t0,&t1);
	/* 2^9 - 2^4 */ fe25519_square(&t1,&t0);
	/* 2^10 - 2^5 */ fe25519_square(&t0,&t1);
	/* 2^10 - 2^0 */ fe25519_mul(&z2_10_0,&t0,&z2_5_0);

	/* 2^11 - 2^1 */ fe25519_square(&t0,&z2_10_0);
	/* 2^12 - 2^2 */ fe25519_square(&t1,&t0);
	/* 2^20 - 2^10 */ for (i = 2;i < 10;i += 2) { fe25519_square(&t0,&t1); fe25519_square(&t1,&t0); }
	/* 2^20 - 2^0 */ fe25519_mul(&z2_20_0,&t1,&z2_10_0);

	/* 2^21 - 2^1 */ fe25519_square(&t0,&z2_20_0);
	/* 2^22 - 2^2 */ fe25519_square(&t1,&t0);
	/* 2^40 - 2^20 */ for (i = 2;i < 20;i += 2) { fe25519_square(&t0,&t1); fe25519_square(&t1,&t0); }
	/* 2^40 - 2^0 */ fe25519_mul(&t0,&t1,&z2_20_0);

	/* 2^41 - 2^1 */ fe25519_square(&t1,&t0);
	/* 2^42 - 2^2 */ fe25519_square(&t0,&t1);
	/* 2^50 - 2^10 */ for (i = 2;i < 10;i += 2) { fe25519_square(&t1,&t0); fe25519_square(&t0,&t1); }
	/* 2^50 - 2^0 */ fe25519_mul(&z2_50_0,&t0,&z2_10_0);

	/* 2^51 - 2^1 */ fe25519_square(&t0,&z2_50_0);
	/* 2^52 - 2^2 */ fe25519_square(&t1,&t0);
	/* 2^100 - 2^50 */ for (i = 2;i < 50;i += 2) { fe25519_square(&t0,&t1); fe25519_square(&t1,&t0); }
	/* 2^100 - 2^0 */ fe25519_mul(&z2_100_0,&t1,&z2_50_0);

	/* 2^101 - 2^1 */ fe25519_square(&t1,&z2_100_0);
	/* 2^102 - 2^2 */ fe25519_square(&t0,&t1);
	/* 2^200 - 2^100 */ for (i = 2;i < 100;i += 2) { fe25519_square(&t1,&t0); fe25519_square(&t0,&t1); }
	/* 2^200 - 2^0 */ fe25519_mul(&t1,&t0,&z2_100_0);

	/* 2^201 - 2^1 */ fe25519_square(&t0,&t1);
	/* 2^202 - 2^2 */ fe25519_square(&t1,&t0);
	/* 2^250 - 2^50 */ for (i = 2;i < 50;i += 2) { fe25519_square(&t0,&t1); fe25519_square(&t1,&t0); }
	/* 2^250 - 2^0 */ fe25519_mul(&t0,&t1,&z2_50_0);

	/* 2^251 - 2^1 */ fe25519_square(&t1,&t0);
	/* 2^252 - 2^2 */ fe25519_square(&t0,&t1);
	/* 2^253 - 2^3 */ fe25519_square(&t1,&t0);
	/* 2^254 - 2^4 */ fe25519_square(&t0,&t1);
	/* 2^255 - 2^5 */ fe25519_square(&t1,&t0);
	/* 2^255 - 21 */ fe25519_mul(r,&t1,&z11);
}
#endif

void fe25519_pow2523(fe25519 *r, const fe25519 *x)
{
	fe25519 z2;
	fe25519 z9;
	fe25519 z11;
	fe25519 z2_5_0;
	fe25519 z2_10_0;
	fe25519 z2_20_0;
	fe25519 z2_50_0;
	fe25519 z2_100_0;
	fe25519 t;
	int i;
		
	/* 2 */ fe25519_square(&z2,x);
	/* 4 */ fe25519_square(&t,&z2);
	/* 8 */ fe25519_square(&t,&t);
	/* 9 */ fe25519_mul(&z9,&t,x);
	/* 11 */ fe25519_mul(&z11,&z9,&z2);
	/* 22 */ fe25519_square(&t,&z11);
	/* 2^5 - 2^0 = 31 */ fe25519_mul(&z2_5_0,&t,&z9);

	/* 2^6 - 2^1 */ fe25519_square(&t,&z2_5_0);
	/* 2^10 - 2^5 */ for (i = 1;i < 5;i++) { fe25519_square(&t,&t); }
	/* 2^10 - 2^0 */ fe25519_mul(&z2_10_0,&t,&z2_5_0);

	/* 2^11 - 2^1 */ fe25519_square(&t,&z2_10_0);
	/* 2^20 - 2^10 */ for (i = 1;i < 10;i++) { fe25519_square(&t,&t); }
	/* 2^20 - 2^0 */ fe25519_mul(&z2_20_0,&t,&z2_10_0);

	/* 2^21 - 2^1 */ fe25519_square(&t,&z2_20_0);
	/* 2^40 - 2^20 */ for (i = 1;i < 20;i++) { fe25519_square(&t,&t); }
	/* 2^40 - 2^0 */ fe25519_mul(&t,&t,&z2_20_0);

	/* 2^41 - 2^1 */ fe25519_square(&t,&t);
	/* 2^50 - 2^10 */ for (i = 1;i < 10;i++) { fe25519_square(&t,&t); }
	/* 2^50 - 2^0 */ fe25519_mul(&z2_50_0,&t,&z2_10_0);

	/* 2^51 - 2^1 */ fe25519_square(&t,&z2_50_0);
	/* 2^100 - 2^50 */ for (i = 1;i < 50;i++) { fe25519_square(&t,&t); }
	/* 2^100 - 2^0 */ fe25519_mul(&z2_100_0,&t,&z2_50_0);

	/* 2^101 - 2^1 */ fe25519_square(&t,&z2_100_0);
	/* 2^200 - 2^100 */ for (i = 1;i < 100;i++) { fe25519_square(&t,&t); }
	/* 2^200 - 2^0 */ fe25519_mul(&t,&t,&z2_100_0);

	/* 2^201 - 2^1 */ fe25519_square(&t,&t);
	/* 2^250 - 2^50 */ for (i = 1;i < 50;i++) { fe25519_square(&t,&t); }
	/* 2^250 - 2^0 */ fe25519_mul(&t,&t,&z2_50_0);

	/* 2^251 - 2^1 */ fe25519_square(&t,&t);
	/* 2^252 - 2^2 */ fe25519_square(&t,&t);
	/* 2^252 - 3 */ fe25519_mul(r,&t,x);
}

void fe25519_invsqrt(fe25519 *r, const fe25519 *x)
{
  fe25519 den2, den3, den4, den6, chk, t, t2;
  int b;

  fe25519_square(&den2, x);
  fe25519_mul(&den3, &den2, x);

  fe25519_square(&den4, &den2);
  fe25519_mul(&den6, &den2, &den4);
  fe25519_mul(&t, &den6, x); // r is now x^7

  fe25519_pow2523(&t, &t);
  fe25519_mul(&t, &t, &den3);

  fe25519_square(&chk, &t);
  fe25519_mul(&chk, &chk, x);

  fe25519_mul(&t2, &t, &fe25519_sqrtm1);
  b = 1 - fe25519_isone(&chk);

  fe25519_cmov(&t, &t2, b);

  *r = t;
}
