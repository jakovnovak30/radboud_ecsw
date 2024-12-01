/*
20080912
D. J. Bernstein
Public domain.
*/

#include "poly1305.h"
#include <stdint.h>

static void add(unsigned int h[5],const unsigned int c[5])
{
  unsigned int j;
  unsigned int u;
  u = 0;
  for (j = 0;j < 4;++j) { u += h[j] + c[j]; h[j] = u & ((1 << 26) - 1); u >>= 26; }
  u += h[4] + c[4]; h[4] = u;
}

// funkcija uzima nas 130-bitni broj i vraća taj broj modulo 2^130 - 5
static void squeeze(uint64_t h[5])
{
  unsigned int j;
  uint64_t u;
  u = 0;
  // 130 = 5 * 26
  for (j = 0;j < 5;++j) { u += h[j]; h[j] = u & ((1 << 26) - 1); u >>= 26; }
  // uzmi preljev i pomnoži ga s 5
  u = 5 * u;
  for (j = 0;j < 4;++j) { u += h[j]; h[j] = u & ((1 << 26) - 1); u >>= 26; }
  u += h[4]; h[4] = u;
}

// 2^130 - 5
static const unsigned int minusp[5] = {
  5, 0, 0, 0, (((1 << 6) - 1) << 26)
};
/*
static const unsigned int minusp[17] = {
  5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 252
} ;
*/

// converts the value to the cannonical representation (positive number)
static void freeze(unsigned int h[5])
{
  unsigned int horig[5];
  unsigned int j;
  unsigned int negative;
  for (j = 0;j < 5;++j) horig[j] = h[j];
  add(h,minusp);
  negative = -(h[4] >> 31);
  for (j = 0;j < 5;++j) h[j] ^= negative & (horig[j] ^ h[j]);
}

// mulmod function converted to radix 26
static void mulmod(unsigned int h[5], const unsigned int r[5])
{
  uint64_t hr[5];
  unsigned int i;
  unsigned int j;
  uint64_t u;

  for (i = 0;i < 5;++i) {
    u = 0;
    for (j = 0;j <= i;++j) u += (uint64_t) h[j] * (uint64_t) r[i - j];
    for (j = i + 1;j < 5;++j) u += 5 * (uint64_t) h[j] * (uint64_t) r[i + 5 - j]; // modular reduction, shift 130 bits to right, then multiply by 5
    hr[i] = u;
  }

  squeeze(hr);
  for (i = 0;i < 5;++i) h[i] = hr[i];
}

/*
00: 9b
01: 38
02: 7d
03: 70
04: 2e
05: dc
06: 75
07: 37
08: 5e
09: 5
10: 57
11: fd
12: 5d
13: b
14: b4
15: 54
 */
int crypto_onetimeauth_poly1305(unsigned char *out,const unsigned char *in,unsigned long long inlen,const unsigned char *k)
{
  unsigned int j;
  unsigned int r[5];
  unsigned int h[5];
  unsigned int c[5];

  // radix 2^26
  r[0] =  k[0]
       | (k[1] << 8)
       | (k[2] << 16)
       | ((k[3] & 3  ) << 24);
  r[1] = ((k[3] & 12 ) >> 2) // 6 bits
       | ((k[4] & 252) << 6) // 6 + 8 = 14 bits
       | (k[5] << 14) // 14 + 8 = 22
       | ((k[6] & 0xf) << 22); // 22 + 4 = 26 bits

  r[2] = (k[6] >> 4) // 4 bits (shifted because we used the value before)
       | ((k[7] & 15  ) << 4) // 4 + 8 = 12 bits
       | ((k[8] & 252 ) << 12) // 12 + 8 = 20 bits
       | ((k[9] & 0x3f) << 20); // 20 + 6 = 26 bits

  r[3] = (k[9] >> 6) // 2 bits
       | (k[10] << 2) // 2 + 8 = 10 bits
       | ((k[11] & 15 ) << 10) // 10 + 8 = 18
       | ((k[12] & 252) << 18); // 18 + 8 = 26

  r[4] =  k[13]
       | (k[14] << 8)
       | ((k[15] & 15) << 16); // the zero at the end is implied

  for (j = 0;j < 5;++j) h[j] = 0;

  // NOTE: probaj baze menjati (8 bitovna verzija koristi 136, a ne 130 bitova na kraju!)
  short iter_limit = 3;
  while (inlen > 0) {
    for (j = 0;j < 5;++j) c[j] = 0;
    //for (j = 0;j < 5;++j) h[j] = 0;

    // copies byte by byte with radix 2^26 adjustments
    short bit_ctr = 0;
    short c_index = 0;
    for (j = 0;(j < 16) && (j < inlen);++j) {
      if(bit_ctr + 8 < 26) {
        c[c_index] += (in[j] << bit_ctr);
      }
      else {
        short stari_dio = 26 - bit_ctr;
        short novi_dio = 8 - stari_dio;

        c[c_index++] += (in[j] << bit_ctr) & ((1 << 26) - 1);
        c[c_index]   += (in[j] >> stari_dio);
      }

      bit_ctr = (bit_ctr + 8) % 26;
    }
    c[c_index] += (1 << bit_ctr);

    in += j; inlen -= j;
    add(h,c);
    mulmod(h,r);

    /*
    if (iter_limit == 0)
      break;
    iter_limit--;
    */
  }

  freeze(h);

  /*
  // for (j = 0;j < 16;++j) c[j] = k[j + 16];
  short bit_ctr = 0;
  short c_index = 0;
  for (j = 0;j < 16;++j) {
    if(bit_ctr + 8 <= 26) {
      c[c_index] += (k[j + 16] << bit_ctr);
    }
    else {
      short stari_dio = 26 - bit_ctr;
      bit_ctr -= 26;

      c[c_index++] += (k[j + 16] << bit_ctr) & ((1 << stari_dio) - 1);
      c[c_index]   += (k[j + 16] >> stari_dio);
    }

    bit_ctr += 8;
  }

  // postavi zadnji bajt na nulu
  c[4] &= ((1 << 18) - 1);
  add(h,c);
  */

  // convert result to output
  short bit_ctr = 0;
  short c_index = 0;
  for (j = 0;j < 16;++j) {
    if (bit_ctr + 8 <= 26) {
      out[j] = (h[c_index] >> bit_ctr) & 0xff;

      bit_ctr += 8;
    }
    else {
      short stari_dio = 26 - bit_ctr;
      short novi_dio = 8 - stari_dio;

      out[j]  = (h[c_index++] >> bit_ctr) & ((1 << stari_dio) - 1);
      out[j] +=  (h[c_index] & ((1 << novi_dio) - 1)) << stari_dio;

      bit_ctr = novi_dio;
    }

  }

  return 0;
}
