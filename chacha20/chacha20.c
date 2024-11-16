/* Based on the public domain implemntation in
 * crypto_stream/chacha20/e/ref from http://bench.cr.yp.to/supercop.html
 * by Daniel J. Bernstein */

#include <stdint.h>
#include "chacha20.h"
#include "../common/stm32wrapper.h"

#define ROUNDS 20

typedef uint32_t uint32;

// include our assembly functions
extern void crypto_core_chacha20(
  unsigned char *out,
  const unsigned char *in,
  const unsigned char *k,
  const unsigned char *c
);

static const unsigned char sigma[16] = "expand 32-byte k";

int crypto_stream_chacha20(unsigned char *c, unsigned long long clen, const unsigned char *n, const unsigned char *k)
{
  unsigned char in[16];
  unsigned char block[64];
  unsigned long long i;
  unsigned int u;

  if (!clen) return 0;

  for (i = 0;i < 8;++i) in[i] = n[i];
  *((uint32 *)(in + 8)) = 0;
  *((uint32 *)(in + 12)) = 0;

  while (clen >= 64) {
    crypto_core_chacha20(c,in,k,sigma);

    // increment counter
    (*((uint64_t *)(in + 8)))++;

    clen -= 64;
    c += 64;
  }

  if (clen) {
    crypto_core_chacha20(block,in,k,sigma);
    for (i = 0;i < clen;++i) c[i] = block[i];
  }
  return 0;
}
