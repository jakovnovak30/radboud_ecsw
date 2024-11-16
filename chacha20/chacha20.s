.syntax unified
.global crypto_core_chacha20
.global crypto_stream_chacha20_asm

.extern send_USART_str
.extern send_USART_bytes

.section .rodata
  sigma:
    .asciz "expand 32-byte k"

.section .text
  .macro QUATERROUND_CALCULATION reg1 reg2 reg3 reg4
    # *a = *a + *b;
    # *d = *d ^ *a;
    # *d = rotate(*d, 16); -> WE DO THIS LATER! (at the end)
    add \reg1, \reg1, \reg2
    eor \reg4, \reg4, \reg1

    # *c = *c + *d;
    # *b = *b ^ *c;
    # *b = rotate(*b, 12); -> WE DO THIS LATER (at the end)
    add \reg3, \reg3, \reg4, ror #(32 - 16)
    eor \reg2, \reg2, \reg3

    # *a = *a + *b;
    # *d = *d ^ *a;
    # *d = rotate(*d, 8); -> WE DO THIS LATER (at the end)
    add \reg1, \reg1, \reg2, ror #(32 - 12)
    eor \reg4, \reg1, \reg4, ror #(32 - 16)

    # *c = *c + *d;
    # *b = *b ^ *c;
    # *b = rotate(*b, 7);
    add \reg3, \reg3, \reg4, ror #(32 - 8)
    eor \reg2, \reg3, \reg2, ror #(32 - 12)

    ror \reg2, \reg2, #(32 - 7)
    ror \reg4, \reg4, #(32 - 8)
  .endm

  .macro ONE_DOUBLEROUND
    # quarterround(&x0, &x4, &x8,&x12);
    # quarterround(&x1, &x5, &x9,&x13);
    ldr r4 , [sp]
    ldr r5 , [sp, #(4 * 4)]
    ldr r6 , [sp, #(8 * 4)]
    ldr r7 , [sp, #(12 * 4)]
    ldr r8 , [sp, #(1 * 4)]
    ldr r9 , [sp, #(5 * 4)]
    ldr r10, [sp, #(9 * 4)]
    ldr r11, [sp, #(13 * 4)]

    QUATERROUND_CALCULATION r4 r5 r6 r7
    QUATERROUND_CALCULATION r8 r9 r10 r11

    str r4 , [sp]
    str r5 , [sp, #(4 * 4)]
    str r6 , [sp, #(8 * 4)]
    str r7 , [sp, #(12 * 4)]
    str r8 , [sp, #(1 * 4)]
    str r9 , [sp, #(5 * 4)]
    str r10, [sp, #(9 * 4)]
    str r11, [sp, #(13 * 4)]

    # quarterround(&x2, &x6,&x10,&x14);
    # quarterround(&x3, &x7,&x11,&x15);

    ldr r4 , [sp, #(2 * 4)]
    ldr r5 , [sp, #(6 * 4)]
    ldr r6 , [sp, #(10 * 4)]
    ldr r7 , [sp, #(14 * 4)]
    ldr r8 , [sp, #(3 * 4)]
    ldr r9 , [sp, #(7 * 4)]
    ldr r10, [sp, #(11 * 4)]
    ldr r11, [sp, #(15 * 4)]

    QUATERROUND_CALCULATION r4 r5 r6 r7
    QUATERROUND_CALCULATION r8 r9 r10 r11

    str r4 , [sp, #(2 * 4)]
    str r5 , [sp, #(6 * 4)]
    str r6 , [sp, #(10 * 4)]
    str r7 , [sp, #(14 * 4)]
    str r8 , [sp, #(3 * 4)]
    str r9 , [sp, #(7 * 4)]
    str r10, [sp, #(11 * 4)]
    str r11, [sp, #(15 * 4)]

    # quarterround(&x0, &x5,&x10,&x15);
    # quarterround(&x1, &x6,&x11,&x12);
    ldr r4 , [sp]
    ldr r5 , [sp, #(5 * 4)]
    ldr r6 , [sp, #(10 * 4)]
    ldr r7 , [sp, #(15 * 4)]
    ldr r8 , [sp, #(1 * 4)]
    ldr r9 , [sp, #(6 * 4)]
    ldr r10, [sp, #(11 * 4)]
    ldr r11, [sp, #(12 * 4)]

    QUATERROUND_CALCULATION r4 r5 r6 r7
    QUATERROUND_CALCULATION r8 r9 r10 r11

    str r4 , [sp]
    str r5 , [sp, #(5 * 4)]
    str r6 , [sp, #(10 * 4)]
    str r7 , [sp, #(15 * 4)]
    str r8 , [sp, #(1 * 4)]
    str r9 , [sp, #(6 * 4)]
    str r10, [sp, #(11 * 4)]
    str r11, [sp, #(12 * 4)]

    # quarterround(&x2, &x7, &x8,&x13);
    # quarterround(&x3, &x4, &x9,&x14);

    ldr r4 , [sp, #(2 * 4)]
    ldr r5 , [sp, #(7 * 4)]
    ldr r6 , [sp, #(8 * 4)]
    ldr r7 , [sp, #(13 * 4)]
    ldr r8 , [sp, #(3 * 4)]
    ldr r9 , [sp, #(4 * 4)]
    ldr r10, [sp, #(9 * 4)]
    ldr r11, [sp, #(14 * 4)]

    QUATERROUND_CALCULATION r4 r5 r6 r7
    QUATERROUND_CALCULATION r8 r9 r10 r11

    str r4 , [sp, #(2 * 4)]
    str r5 , [sp, #(7 * 4)]
    str r6 , [sp, #(8 * 4)]
    str r7 , [sp, #(13 * 4)]
    str r8 , [sp, #(3 * 4)]
    str r9 , [sp, #(4 * 4)]
    str r10, [sp, #(9 * 4)]
    str r11, [sp, #(14 * 4)]
  .endm

  crypto_core_chacha20:
    # arguments:
    # unsigned char *out      - r0
    # const unsigned char *in - r1
    # const unsigned char *k  - r2
    # const unsigned char *c  - r3
    
    # store registers
    stmfd sp!, {r4-r11, lr}

    # load x0-x15 and j0-j15 from the pointers
    # indices 0 to 3 -> *c
    # indices 4 to 11 -> *k
    # indices 12 to 15 -> *in
    # store everything directly on stack ("local variables")

    /* NOTE: we push in reverse order to make indexing easier later on... */
    # loading *in
    ldm r1, {r4-r7}
    stmfd sp!, {r4-r5}
    stmfd sp!, {r6-r7}
    # loading *k
    ldm r2, {r4-r11}
    stmfd sp!, {r4-r11}
    # loading *c
    ldm r3, {r4-r7}
    stmfd sp!, {r4-r7}

    # provjeri lokalne varijable
    /*
    push {r0, r1}

    add r0, sp, #(2*4)

    mov r1, #(16*4)

    bl send_USART_bytes

    pop {r0, r1}
    */

    # do 20 rounds
    ONE_DOUBLEROUND
    ONE_DOUBLEROUND
    ONE_DOUBLEROUND
    ONE_DOUBLEROUND
    ONE_DOUBLEROUND
    ONE_DOUBLEROUND
    ONE_DOUBLEROUND
    ONE_DOUBLEROUND
    ONE_DOUBLEROUND
    ONE_DOUBLEROUND

    # increment results by initial values
    # and then store everything on *out

    # registers r0-r3 are taken, we have r4-r12 availible (9 registers),
    # use r4-r7 for current x_i to x_{i+3}, and r8-r11 for current j_i to j_{i+3}

    # indices 0 to 3 -> *c (r3)
    # indices 4 to 11 -> *k (r2)
    # indices 12 to 15 -> *in (r1)

    # 0 to 3
    ldmfd sp, {r4-r7}
    ldm r3, {r8-r11}
    add r4, r4, r8
    add r5, r5, r9
    add r6, r6, r10
    add r7, r7, r11
    stm r0, {r4-r7}

    # 4 to 7
    add sp, sp, #(4*4)
    add r0, r0, #(4*4)

    ldmfd sp, {r4-r7}
    ldm r2, {r8-r11}
    add r2, r2, #(4*4) /* increment *k */
    add r4, r4, r8
    add r5, r5, r9
    add r6, r6, r10
    add r7, r7, r11
    stm r0, {r4-r7}

    # 8 to 11
    add sp, sp, #(4*4)
    add r0, r0, #(4*4)

    ldmfd sp, {r4-r7}
    ldm r2, {r8-r11}
    add r4, r4, r8
    add r5, r5, r9
    add r6, r6, r10
    add r7, r7, r11
    stm r0, {r4-r7}

    # 12 to 15
    add sp, sp, #(4*4)
    add r0, r0, #(4*4)

    ldmfd sp, {r4-r7}
    ldm r1, {r8-r11}
    add r4, r4, r10
    add r5, r5, r11
    add r6, r6, r8
    add r7, r7, r9
    stm r0, {r4-r7}
    
    add sp, sp, #(4*4)
    # restore registers and return
    ldmfd sp!, {r4-r11, lr}
    bx lr

  crypto_stream_chacha20_asm:
    stmfd sp!, {r4-r7, lr}
    # r0 - unsigned char *c (output vector)
    # r1 - unsigned long long clen (desired output length)
    # r2 - const unsigned char *n (init vector)
    # r3 - const unsigned char *k (cryptographic key)

    mov r4, r1 /* move clen to r4 register */

    sub sp, sp, #(16*4)
    mov r1, sp /* move bottom of stack to r1 for *in */
    # move *n to r1 and initialize that
    ldm r2, {r6-r7}
    stm r1, {r6-r7}
    mov r6, #0
    mov r7, #0
    add r5, r1, #8 /* r5 <- in + 8 */
    stm r1, {r6-r7}

    mov r2, r3 /* get *k to r2 */
    ldr r3, sigma /* set up r3 with *c */

    while_loop:
      # call core function
      bl crypto_core_chacha20

      # update init vector (counter)
      ldm r5, {r6-r7}
      add r6, r6, #1
      addcs r7, r7, #0 /* add with carry just in case */
      stm r5, {r6-r7}

      # regular loop stuff
      add r0, r0, #64
      sub r4, r4, #64
      cmp r4, #64
      bge while_loop
    
    cmp r4, #0
    beq return

    # encrypt another block
    # make local variable for last block since we don't have enough buffer space
    sub sp, sp, #(16*4)
    push {r0}
    
    add r0, sp, #4 /* bottom of stack before pushing old r0 */
    # r1, r2 and r3 should be set up correctly
    bl crypto_core_chacha20
    
    mov r6, r0
    pop {r0}

    # copy memory from local var (in r6) to correct output
    copy_loop:
      subs r4, r4, #1
      bgt copy_loop

    add sp, sp, #(16*4)

    return:
    # restore registers and return
    add sp, sp, #(16*4)
    ldmfd sp!, {r4-r7, lr}
    bx lr
