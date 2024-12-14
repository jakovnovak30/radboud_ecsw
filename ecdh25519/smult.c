#include <stdint.h>
#include "group.h"
#include "smult.h"

// TODO: optimize field arithmetic, optimize group arithmetic
int crypto_scalarmult(unsigned char *ss, const unsigned char *sk, const unsigned char *pk)
{
  group_ge p, k;
  unsigned char t[64];
  int i,j;

  t[0] = sk[0] & 248 & 0xf;
  t[1] = (sk[0] & 248) >> 4;
  for(i=1;i<31;i++) {
    t[2*i  ] = sk[i] & 0xf;
    t[2*i+1] = sk[i] >> 4;
  }
  unsigned char last = (sk[31] & 127) | 64;
  t[62] = last & 0xf;
  t[63] = last >> 4;

  if(group_ge_unpack(&p, pk)) return -1;

  // precompute results p, 2*p, 3*p, ..., (2^4-1) * p
  group_ge T[16];
  group_ge_add(T, &group_ge_neutral, &group_ge_neutral);
  for (i = 1;i <= 15;i++) {
    group_ge_add(T + i, T + i-1, &p);
  }

  k = T[t[63]];
  // WINDOW_SIZE = 4, 64 * 4 = 32 * 8
  for(i=62;i>=0;--i)
  {
    for(j=1;j<=4;++j)
    {
      group_ge_double(&k, &k);
    }

    // TODO: constant time indexing
    group_ge_add(&k, &k, &T[t[i]]);
  }

  group_ge_pack(ss, &k);
  return 0;
}

int crypto_scalarmult_base(unsigned char *pk, const unsigned char *sk)
{
  unsigned char t[GROUP_GE_PACKEDBYTES];
  group_ge_pack(t, &group_ge_base);
  return crypto_scalarmult(pk, sk, t);
}


