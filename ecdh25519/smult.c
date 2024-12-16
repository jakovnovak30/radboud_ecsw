#include <stdint.h>
#include "group.h"
#include "smult.h"

group_ge get_index(group_ge T[16], int index) {
  group_ge out;
  int i,j;

  for(i=0;i < 16;++i) {
    uint32_t mask = - equal(i, index);

    for(j=0;j<32;++j) {
      out.x.v[j] = (mask & T[i].x.v[j]) ^ (~mask & out.x.v[j]);
      out.y.v[j] = (mask & T[i].y.v[j]) ^ (~mask & out.y.v[j]);
      out.z.v[j] = (mask & T[i].z.v[j]) ^ (~mask & out.z.v[j]);
      out.t.v[j] = (mask & T[i].t.v[j]) ^ (~mask & out.t.v[j]);
    }
  }

  return out;
}

// optimizations: fixed window scalar mult + custom squaring function
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

  k = get_index(T, t[63]);
  // WINDOW_SIZE = 4, 64 * 4 = 32 * 8
  group_ge add_val;
  for(i=62;i>=0;--i)
  {
    for(j=1;j<=4;++j)
    {
      group_ge_double(&k, &k);
    }

    // constant time indexing
    add_val = get_index(T, t[i]);
    group_ge_add(&k, &k, &add_val);
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


