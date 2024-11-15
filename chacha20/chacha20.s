.syntax unified
.global quarterround_asm
.global crypto_core_chacha20_asm

.extern send_USART_str

.section .data
test_output:
  .asciz "Tu sam!"

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
  
  # testing function... TODO: delete after main function starts working
  quarterround_asm:
    # arguments in registers: r0, r1, r2, r3
    # no return value

    # save registers
    stmfd sp!, {r4-r7}

    # use registers r4, r5, r6, r7 for dereferenced values
    ldr r4, [r0]
    ldr r5, [r1]
    ldr r6, [r2]
    ldr r7, [r3]

    # actual calculations:
    # ====================
    QUATERROUND_CALCULATION r4 r5 r6 r7
    # ===================

    # save result back to *r0, *r1, *r2, *r3
    str r4, [r0]
    str r5, [r1]
    str r6, [r2]
    str r7, [r3]

    # restore registers
    ldmfd sp!, {r4-r7}

    bx lr

  crypto_core_chacha20_asm:
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

    # loading *c
    ldm r3, {r4-r7}
    stmfd sp!, {r4-r7}
    # loading *k
    ldm r2, {r4-r11}
    stmfd sp!, {r4-r11}
    # loading *in
    ldm r1, {r4-r7}
    stmfd sp!, {r4-r7}

    # do 20 rounds
    mov r12, #10 /* 10 double rounds */
  rounds_loop:
    # quarterround(&x0, &x4, &x8,&x12);
    # quarterround(&x1, &x5, &x9,&x13);
    ldr r4 , [sp, #(15*4)]
    ldr r5 , [sp, #(15*4 - 4 * 4)]
    ldr r6 , [sp, #(15*4 - 8 * 4)]
    ldr r7 , [sp, #(15*4 - 12 * 4)]
    ldr r8 , [sp, #(15*4 - 1 * 4)]
    ldr r9 , [sp, #(15*4 - 5 * 4)]
    ldr r10, [sp, #(15*4 - 9 * 4)]
    ldr r11, [sp, #(15*4 - 13 * 4)]

    QUATERROUND_CALCULATION r4 r5 r6 r7
    QUATERROUND_CALCULATION r8 r9 r10 r11

    str r4 , [sp, #(15*4)]
    str r5 , [sp, #(15*4 - 4 * 4)]
    str r6 , [sp, #(15*4 - 8 * 4)]
    str r7 , [sp, #(15*4 - 12 * 4)]
    str r8 , [sp, #(15*4 - 1 * 4)]
    str r9 , [sp, #(15*4 - 5 * 4)]
    str r10, [sp, #(15*4 - 9 * 4)]
    str r11, [sp, #(15*4 - 13 * 4)]

    # quarterround(&x2, &x6,&x10,&x14);
    # quarterround(&x3, &x7,&x11,&x15);

    ldr r4 , [sp, #(15*4 - 2 * 4)]
    ldr r5 , [sp, #(15*4 - 6 * 4)]
    ldr r6 , [sp, #(15*4 - 10 * 4)]
    ldr r7 , [sp, #(15*4 - 14 * 4)]
    ldr r8 , [sp, #(15*4 - 3 * 4)]
    ldr r9 , [sp, #(15*4 - 7 * 4)]
    ldr r10, [sp, #(15*4 - 11 * 4)]
    ldr r11, [sp, #(15*4 - 15 * 4)]

    QUATERROUND_CALCULATION r4 r5 r6 r7
    QUATERROUND_CALCULATION r8 r9 r10 r11

    str r4 , [sp, #(15*4 - 2 * 4)]
    str r5 , [sp, #(15*4 - 6 * 4)]
    str r6 , [sp, #(15*4 - 10 * 4)]
    str r7 , [sp, #(15*4 - 14 * 4)]
    str r8 , [sp, #(15*4 - 3 * 4)]
    str r9 , [sp, #(15*4 - 7 * 4)]
    str r10, [sp, #(15*4 - 11 * 4)]
    str r11, [sp, #(15*4 - 15 * 4)]

    # quarterround(&x0, &x5,&x10,&x15);
    # quarterround(&x1, &x6,&x11,&x12);
    ldr r4 , [sp, #(15*4)]
    ldr r5 , [sp, #(15*4 - 5 * 4)]
    ldr r6 , [sp, #(15*4 - 10 * 4)]
    ldr r7 , [sp, #(15*4 - 15 * 4)]
    ldr r8 , [sp, #(15*4 - 1 * 4)]
    ldr r9 , [sp, #(15*4 - 6 * 4)]
    ldr r10, [sp, #(15*4 - 11 * 4)]
    ldr r11, [sp, #(15*4 - 12 * 4)]

    QUATERROUND_CALCULATION r4 r5 r6 r7
    QUATERROUND_CALCULATION r8 r9 r10 r11

    str r4 , [sp, #(15*4)]
    str r5 , [sp, #(15*4 - 5 * 4)]
    str r6 , [sp, #(15*4 - 10 * 4)]
    str r7 , [sp, #(15*4 - 15 * 4)]
    str r8 , [sp, #(15*4 - 1 * 4)]
    str r9 , [sp, #(15*4 - 6 * 4)]
    str r10, [sp, #(15*4 - 11 * 4)]
    str r11, [sp, #(15*4 - 12 * 4)]

    # quarterround(&x2, &x7, &x8,&x13);
    # quarterround(&x3, &x4, &x9,&x14);

    ldr r4 , [sp, #(15*4 - 2 * 4)]
    ldr r5 , [sp, #(15*4 - 7 * 4)]
    ldr r6 , [sp, #(15*4 - 8 * 4)]
    ldr r7 , [sp, #(15*4 - 13 * 4)]
    ldr r8 , [sp, #(15*4 - 3 * 4)]
    ldr r9 , [sp, #(15*4 - 4 * 4)]
    ldr r10, [sp, #(15*4 - 9 * 4)]
    ldr r11, [sp, #(15*4 - 14 * 4)]

    QUATERROUND_CALCULATION r4 r5 r6 r7
    QUATERROUND_CALCULATION r8 r9 r10 r11

    str r4 , [sp, #(15*4 - 2 * 4)]
    str r5 , [sp, #(15*4 - 7 * 4)]
    str r6 , [sp, #(15*4 - 8 * 4)]
    str r7 , [sp, #(15*4 - 13 * 4)]
    str r8 , [sp, #(15*4 - 3 * 4)]
    str r9 , [sp, #(15*4 - 4 * 4)]
    str r10, [sp, #(15*4 - 9 * 4)]
    str r11, [sp, #(15*4 - 14 * 4)]

    subs r12, r12, #1

    bne rounds_loop

    # increment results by initial values
    # and then store everything on *out

    # registers r0-r3 are taken, we have r4-r12 availible (9 registers),
    # use r4-r7 for current x_i to x_{i+3}, and r8-r11 for current j_i to j_{i+3}

    # indices 0 to 3 -> *c (r3)
    # indices 4 to 11 -> *k (r2)
    # indices 12 to 15 -> *in (r1)

    add sp, sp, #(16*4)

    # 0 to 3
    ldmfd sp, {r4-r7}
    ldm r3, {r8-r11}
    add r4, r4, r8
    add r5, r5, r9
    add r6, r6, r10
    add r7, r7, r11
    stm r0, {r4-r7}

    # 4 to 7
    sub sp, sp, #(4*4)
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
    sub sp, sp, #(4*4)
    add r0, r0, #(4*4)

    ldmfd sp, {r4-r7}
    ldm r2, {r8-r11}
    add r4, r4, r8
    add r5, r5, r9
    add r6, r6, r10
    add r7, r7, r11
    stm r0, {r4-r7}

    # 12 to 15
    sub sp, sp, #(4*4)
    add r0, r0, #(4*4)

    ldmfd sp, {r4-r7}
    ldm r1, {r8-r11}
    add r4, r4, r8
    add r5, r5, r9
    add r6, r6, r10
    add r7, r7, r11
    stm r0, {r4-r7}
    
    add sp, sp, #(12*4)
    # restore registers and return
    ldmfd sp!, {r4-r11, lr}
    bx lr
