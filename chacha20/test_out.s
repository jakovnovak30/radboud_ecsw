	.cpu arm7tdmi
	.arch armv4t
	.fpu softvfp
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"chacha20.c"
	.text
	.align	2
	.syntax unified
	.arm
	.type	load_littleendian, %function
load_littleendian:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #12
	str	r0, [fp, #-8]
	ldr	r3, [fp, #-8]
	ldrb	r3, [r3]	@ zero_extendqisi2
	mov	r2, r3
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsl	r3, r3, #8
	orr	r2, r2, r3
	ldr	r3, [fp, #-8]
	add	r3, r3, #2
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsl	r3, r3, #16
	orr	r2, r2, r3
	ldr	r3, [fp, #-8]
	add	r3, r3, #3
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsl	r3, r3, #24
	orr	r3, r2, r3
	mov	r0, r3
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	load_littleendian, .-load_littleendian
	.align	2
	.syntax unified
	.arm
	.type	store_littleendian, %function
store_littleendian:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #12
	str	r0, [fp, #-8]
	str	r1, [fp, #-12]
	ldr	r3, [fp, #-12]
	and	r2, r3, #255
	ldr	r3, [fp, #-8]
	strb	r2, [r3]
	ldr	r3, [fp, #-12]
	lsr	r3, r3, #8
	str	r3, [fp, #-12]
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	ldr	r2, [fp, #-12]
	and	r2, r2, #255
	strb	r2, [r3]
	ldr	r3, [fp, #-12]
	lsr	r3, r3, #8
	str	r3, [fp, #-12]
	ldr	r3, [fp, #-8]
	add	r3, r3, #2
	ldr	r2, [fp, #-12]
	and	r2, r2, #255
	strb	r2, [r3]
	ldr	r3, [fp, #-12]
	lsr	r3, r3, #8
	str	r3, [fp, #-12]
	ldr	r3, [fp, #-8]
	add	r3, r3, #3
	ldr	r2, [fp, #-12]
	and	r2, r2, #255
	strb	r2, [r3]
	nop
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	store_littleendian, .-store_littleendian
	.align	2
	.syntax unified
	.arm
	.type	rotate, %function
rotate:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #20
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	ldr	r3, [fp, #-20]
	rsb	r3, r3, #32
	ldr	r2, [fp, #-16]
	lsr	r3, r2, r3
	str	r3, [fp, #-8]
	ldr	r2, [fp, #-16]
	ldr	r3, [fp, #-20]
	lsl	r3, r2, r3
	str	r3, [fp, #-16]
	ldr	r2, [fp, #-16]
	ldr	r3, [fp, #-8]
	orr	r3, r2, r3
	mov	r0, r3
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	rotate, .-rotate
	.align	2
	.syntax unified
	.arm
	.type	quarterround, %function
quarterround:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	str	r0, [fp, #-8]
	str	r1, [fp, #-12]
	str	r2, [fp, #-16]
	str	r3, [fp, #-20]
	ldr	r3, [fp, #-8]
	ldr	r2, [r3]
	ldr	r3, [fp, #-12]
	ldr	r3, [r3]
	add	r2, r2, r3
	ldr	r3, [fp, #-8]
	str	r2, [r3]
	ldr	r3, [fp, #-20]
	ldr	r2, [r3]
	ldr	r3, [fp, #-8]
	ldr	r3, [r3]
	eor	r2, r2, r3
	ldr	r3, [fp, #-20]
	str	r2, [r3]
	ldr	r3, [fp, #-20]
	ldr	r3, [r3]
	mov	r1, #16
	mov	r0, r3
	bl	rotate
	mov	r2, r0
	ldr	r3, [fp, #-20]
	str	r2, [r3]
	ldr	r3, [fp, #-16]
	ldr	r2, [r3]
	ldr	r3, [fp, #-20]
	ldr	r3, [r3]
	add	r2, r2, r3
	ldr	r3, [fp, #-16]
	str	r2, [r3]
	ldr	r3, [fp, #-12]
	ldr	r2, [r3]
	ldr	r3, [fp, #-16]
	ldr	r3, [r3]
	eor	r2, r2, r3
	ldr	r3, [fp, #-12]
	str	r2, [r3]
	ldr	r3, [fp, #-12]
	ldr	r3, [r3]
	mov	r1, #12
	mov	r0, r3
	bl	rotate
	mov	r2, r0
	ldr	r3, [fp, #-12]
	str	r2, [r3]
	ldr	r3, [fp, #-8]
	ldr	r2, [r3]
	ldr	r3, [fp, #-12]
	ldr	r3, [r3]
	add	r2, r2, r3
	ldr	r3, [fp, #-8]
	str	r2, [r3]
	ldr	r3, [fp, #-20]
	ldr	r2, [r3]
	ldr	r3, [fp, #-8]
	ldr	r3, [r3]
	eor	r2, r2, r3
	ldr	r3, [fp, #-20]
	str	r2, [r3]
	ldr	r3, [fp, #-20]
	ldr	r3, [r3]
	mov	r1, #8
	mov	r0, r3
	bl	rotate
	mov	r2, r0
	ldr	r3, [fp, #-20]
	str	r2, [r3]
	ldr	r3, [fp, #-16]
	ldr	r2, [r3]
	ldr	r3, [fp, #-20]
	ldr	r3, [r3]
	add	r2, r2, r3
	ldr	r3, [fp, #-16]
	str	r2, [r3]
	ldr	r3, [fp, #-12]
	ldr	r2, [r3]
	ldr	r3, [fp, #-16]
	ldr	r3, [r3]
	eor	r2, r2, r3
	ldr	r3, [fp, #-12]
	str	r2, [r3]
	ldr	r3, [fp, #-12]
	ldr	r3, [r3]
	mov	r1, #7
	mov	r0, r3
	bl	rotate
	mov	r2, r0
	ldr	r3, [fp, #-12]
	str	r2, [r3]
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, lr}
	bx	lr
	.size	quarterround, .-quarterround
	.align	2
	.syntax unified
	.arm
	.type	crypto_core_chacha20, %function
crypto_core_chacha20:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 152
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #152
	str	r0, [fp, #-144]
	str	r1, [fp, #-148]
	str	r2, [fp, #-152]
	str	r3, [fp, #-156]
	ldr	r0, [fp, #-156]
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-76]
	ldr	r3, [fp, #-76]
	str	r3, [fp, #-12]
	ldr	r3, [fp, #-156]
	add	r3, r3, #4
	mov	r0, r3
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-80]
	ldr	r3, [fp, #-80]
	str	r3, [fp, #-16]
	ldr	r3, [fp, #-156]
	add	r3, r3, #8
	mov	r0, r3
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-84]
	ldr	r3, [fp, #-84]
	str	r3, [fp, #-20]
	ldr	r3, [fp, #-156]
	add	r3, r3, #12
	mov	r0, r3
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-88]
	ldr	r3, [fp, #-88]
	str	r3, [fp, #-24]
	ldr	r0, [fp, #-152]
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-92]
	ldr	r3, [fp, #-92]
	str	r3, [fp, #-28]
	ldr	r3, [fp, #-152]
	add	r3, r3, #4
	mov	r0, r3
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-96]
	ldr	r3, [fp, #-96]
	str	r3, [fp, #-32]
	ldr	r3, [fp, #-152]
	add	r3, r3, #8
	mov	r0, r3
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-100]
	ldr	r3, [fp, #-100]
	str	r3, [fp, #-36]
	ldr	r3, [fp, #-152]
	add	r3, r3, #12
	mov	r0, r3
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-104]
	ldr	r3, [fp, #-104]
	str	r3, [fp, #-40]
	ldr	r3, [fp, #-152]
	add	r3, r3, #16
	mov	r0, r3
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-108]
	ldr	r3, [fp, #-108]
	str	r3, [fp, #-44]
	ldr	r3, [fp, #-152]
	add	r3, r3, #20
	mov	r0, r3
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-112]
	ldr	r3, [fp, #-112]
	str	r3, [fp, #-48]
	ldr	r3, [fp, #-152]
	add	r3, r3, #24
	mov	r0, r3
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-116]
	ldr	r3, [fp, #-116]
	str	r3, [fp, #-52]
	ldr	r3, [fp, #-152]
	add	r3, r3, #28
	mov	r0, r3
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-120]
	ldr	r3, [fp, #-120]
	str	r3, [fp, #-56]
	ldr	r3, [fp, #-148]
	add	r3, r3, #8
	mov	r0, r3
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-124]
	ldr	r3, [fp, #-124]
	str	r3, [fp, #-60]
	ldr	r3, [fp, #-148]
	add	r3, r3, #12
	mov	r0, r3
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-128]
	ldr	r3, [fp, #-128]
	str	r3, [fp, #-64]
	ldr	r0, [fp, #-148]
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-132]
	ldr	r3, [fp, #-132]
	str	r3, [fp, #-68]
	ldr	r3, [fp, #-148]
	add	r3, r3, #4
	mov	r0, r3
	bl	load_littleendian
	mov	r3, r0
	str	r3, [fp, #-136]
	ldr	r3, [fp, #-136]
	str	r3, [fp, #-72]
	mov	r3, #20
	str	r3, [fp, #-8]
	b	.L8
.L9:
	sub	r3, fp, #124
	sub	r2, fp, #108
	sub	r1, fp, #92
	sub	r0, fp, #76
	bl	quarterround_asm
	sub	r3, fp, #128
	sub	r2, fp, #112
	sub	r1, fp, #96
	sub	r0, fp, #80
	bl	quarterround_asm
	sub	r3, fp, #132
	sub	r2, fp, #116
	sub	r1, fp, #100
	sub	r0, fp, #84
	bl	quarterround_asm
	sub	r3, fp, #136
	sub	r2, fp, #120
	sub	r1, fp, #104
	sub	r0, fp, #88
	bl	quarterround_asm
	sub	r3, fp, #136
	sub	r2, fp, #116
	sub	r1, fp, #96
	sub	r0, fp, #76
	bl	quarterround_asm
	sub	r3, fp, #124
	sub	r2, fp, #120
	sub	r1, fp, #100
	sub	r0, fp, #80
	bl	quarterround_asm
	sub	r3, fp, #128
	sub	r2, fp, #108
	sub	r1, fp, #104
	sub	r0, fp, #84
	bl	quarterround_asm
	sub	r3, fp, #132
	sub	r2, fp, #112
	sub	r1, fp, #92
	sub	r0, fp, #88
	bl	quarterround_asm
	ldr	r3, [fp, #-8]
	sub	r3, r3, #2
	str	r3, [fp, #-8]
.L8:
	ldr	r3, [fp, #-8]
	cmp	r3, #0
	bgt	.L9
	ldr	r2, [fp, #-76]
	ldr	r3, [fp, #-12]
	add	r3, r2, r3
	str	r3, [fp, #-76]
	ldr	r2, [fp, #-80]
	ldr	r3, [fp, #-16]
	add	r3, r2, r3
	str	r3, [fp, #-80]
	ldr	r2, [fp, #-84]
	ldr	r3, [fp, #-20]
	add	r3, r2, r3
	str	r3, [fp, #-84]
	ldr	r2, [fp, #-88]
	ldr	r3, [fp, #-24]
	add	r3, r2, r3
	str	r3, [fp, #-88]
	ldr	r2, [fp, #-92]
	ldr	r3, [fp, #-28]
	add	r3, r2, r3
	str	r3, [fp, #-92]
	ldr	r2, [fp, #-96]
	ldr	r3, [fp, #-32]
	add	r3, r2, r3
	str	r3, [fp, #-96]
	ldr	r2, [fp, #-100]
	ldr	r3, [fp, #-36]
	add	r3, r2, r3
	str	r3, [fp, #-100]
	ldr	r2, [fp, #-104]
	ldr	r3, [fp, #-40]
	add	r3, r2, r3
	str	r3, [fp, #-104]
	ldr	r2, [fp, #-108]
	ldr	r3, [fp, #-44]
	add	r3, r2, r3
	str	r3, [fp, #-108]
	ldr	r2, [fp, #-112]
	ldr	r3, [fp, #-48]
	add	r3, r2, r3
	str	r3, [fp, #-112]
	ldr	r2, [fp, #-116]
	ldr	r3, [fp, #-52]
	add	r3, r2, r3
	str	r3, [fp, #-116]
	ldr	r2, [fp, #-120]
	ldr	r3, [fp, #-56]
	add	r3, r2, r3
	str	r3, [fp, #-120]
	ldr	r2, [fp, #-124]
	ldr	r3, [fp, #-60]
	add	r3, r2, r3
	str	r3, [fp, #-124]
	ldr	r2, [fp, #-128]
	ldr	r3, [fp, #-64]
	add	r3, r2, r3
	str	r3, [fp, #-128]
	ldr	r2, [fp, #-132]
	ldr	r3, [fp, #-68]
	add	r3, r2, r3
	str	r3, [fp, #-132]
	ldr	r2, [fp, #-136]
	ldr	r3, [fp, #-72]
	add	r3, r2, r3
	str	r3, [fp, #-136]
	ldr	r3, [fp, #-76]
	mov	r1, r3
	ldr	r0, [fp, #-144]
	bl	store_littleendian
	ldr	r3, [fp, #-144]
	add	r3, r3, #4
	ldr	r2, [fp, #-80]
	mov	r1, r2
	mov	r0, r3
	bl	store_littleendian
	ldr	r3, [fp, #-144]
	add	r3, r3, #8
	ldr	r2, [fp, #-84]
	mov	r1, r2
	mov	r0, r3
	bl	store_littleendian
	ldr	r3, [fp, #-144]
	add	r3, r3, #12
	ldr	r2, [fp, #-88]
	mov	r1, r2
	mov	r0, r3
	bl	store_littleendian
	ldr	r3, [fp, #-144]
	add	r3, r3, #16
	ldr	r2, [fp, #-92]
	mov	r1, r2
	mov	r0, r3
	bl	store_littleendian
	ldr	r3, [fp, #-144]
	add	r3, r3, #20
	ldr	r2, [fp, #-96]
	mov	r1, r2
	mov	r0, r3
	bl	store_littleendian
	ldr	r3, [fp, #-144]
	add	r3, r3, #24
	ldr	r2, [fp, #-100]
	mov	r1, r2
	mov	r0, r3
	bl	store_littleendian
	ldr	r3, [fp, #-144]
	add	r3, r3, #28
	ldr	r2, [fp, #-104]
	mov	r1, r2
	mov	r0, r3
	bl	store_littleendian
	ldr	r3, [fp, #-144]
	add	r3, r3, #32
	ldr	r2, [fp, #-108]
	mov	r1, r2
	mov	r0, r3
	bl	store_littleendian
	ldr	r3, [fp, #-144]
	add	r3, r3, #36
	ldr	r2, [fp, #-112]
	mov	r1, r2
	mov	r0, r3
	bl	store_littleendian
	ldr	r3, [fp, #-144]
	add	r3, r3, #40
	ldr	r2, [fp, #-116]
	mov	r1, r2
	mov	r0, r3
	bl	store_littleendian
	ldr	r3, [fp, #-144]
	add	r3, r3, #44
	ldr	r2, [fp, #-120]
	mov	r1, r2
	mov	r0, r3
	bl	store_littleendian
	ldr	r3, [fp, #-144]
	add	r3, r3, #48
	ldr	r2, [fp, #-124]
	mov	r1, r2
	mov	r0, r3
	bl	store_littleendian
	ldr	r3, [fp, #-144]
	add	r3, r3, #52
	ldr	r2, [fp, #-128]
	mov	r1, r2
	mov	r0, r3
	bl	store_littleendian
	ldr	r3, [fp, #-144]
	add	r3, r3, #56
	ldr	r2, [fp, #-132]
	mov	r1, r2
	mov	r0, r3
	bl	store_littleendian
	ldr	r3, [fp, #-144]
	add	r3, r3, #60
	ldr	r2, [fp, #-136]
	mov	r1, r2
	mov	r0, r3
	bl	store_littleendian
	mov	r3, #0
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, lr}
	bx	lr
	.size	crypto_core_chacha20, .-crypto_core_chacha20
	.section	.rodata
	.align	2
	.type	sigma, %object
	.size	sigma, 16
sigma:
	.ascii	"expand 32-byte k"
	.text
	.align	2
	.global	crypto_stream_chacha20
	.syntax unified
	.arm
	.type	crypto_stream_chacha20, %function
crypto_stream_chacha20:
	@ Function supports interworking.
	@ args = 8, pretend = 0, frame = 168
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, r9, fp, lr}
	add	fp, sp, #28
	sub	sp, sp, #168
	str	r0, [fp, #-160]
	str	r2, [fp, #-172]
	str	r3, [fp, #-168]
	sub	r3, fp, #172
	ldmia	r3, {r2-r3}
	orrs	r3, r2, r3
	bne	.L12
	mov	r3, #0
	b	.L27
.L12:
	mov	r2, #0
	mov	r3, #0
	str	r2, [fp, #-36]
	str	r3, [fp, #-32]
	b	.L14
.L15:
	ldr	r3, [fp, #-36]
	ldr	r2, [fp, #8]
	add	r3, r2, r3
	ldrb	r1, [r3]	@ zero_extendqisi2
	sub	r2, fp, #152
	ldr	r3, [fp, #-36]
	add	r2, r2, r3
	mov	r3, r1
	strb	r3, [r2]
	sub	r3, fp, #36
	ldmia	r3, {r2-r3}
	adds	r1, r2, #1
	str	r1, [fp, #-180]
	adc	r3, r3, #0
	str	r3, [fp, #-176]
	sub	r3, fp, #180
	ldmia	r3, {r2-r3}
	str	r2, [fp, #-36]
	str	r3, [fp, #-32]
.L14:
	sub	r3, fp, #36
	ldmia	r3, {r2-r3}
	cmp	r2, #32
	sbcs	r3, r3, #0
	bcc	.L15
	mov	r2, #0
	mov	r3, #0
	str	r2, [fp, #-36]
	str	r3, [fp, #-32]
	b	.L16
.L17:
	ldr	r3, [fp, #-36]
	ldr	r2, [fp, #4]
	add	r3, r2, r3
	ldrb	r1, [r3]	@ zero_extendqisi2
	sub	r2, fp, #56
	ldr	r3, [fp, #-36]
	add	r3, r2, r3
	mov	r2, r1
	strb	r2, [r3]
	sub	r3, fp, #36
	ldmia	r3, {r2-r3}
	adds	r1, r2, #1
	str	r1, [fp, #-188]
	adc	r3, r3, #0
	str	r3, [fp, #-184]
	sub	r3, fp, #188
	ldmia	r3, {r2-r3}
	str	r2, [fp, #-36]
	str	r3, [fp, #-32]
.L16:
	sub	r3, fp, #36
	ldmia	r3, {r2-r3}
	cmp	r2, #8
	sbcs	r3, r3, #0
	bcc	.L17
	mov	r2, #8
	mov	r3, #0
	str	r2, [fp, #-36]
	str	r3, [fp, #-32]
	b	.L18
.L19:
	sub	r2, fp, #56
	ldr	r3, [fp, #-36]
	add	r3, r2, r3
	mov	r2, #0
	strb	r2, [r3]
	sub	r3, fp, #36
	ldmia	r3, {r2-r3}
	adds	r1, r2, #1
	str	r1, [fp, #-196]
	adc	r3, r3, #0
	str	r3, [fp, #-192]
	sub	r3, fp, #196
	ldmia	r3, {r2-r3}
	str	r2, [fp, #-36]
	str	r3, [fp, #-32]
.L18:
	sub	r3, fp, #36
	ldmia	r3, {r2-r3}
	cmp	r2, #16
	sbcs	r3, r3, #0
	bcc	.L19
	b	.L20
.L23:
	sub	r2, fp, #152
	sub	r1, fp, #56
	ldr	r3, .L28
	ldr	r0, [fp, #-160]
	bl	crypto_core_chacha20
	mov	r3, #1
	str	r3, [fp, #-40]
	mov	r2, #8
	mov	r3, #0
	str	r2, [fp, #-36]
	str	r3, [fp, #-32]
	b	.L21
.L22:
	sub	r2, fp, #56
	ldr	r3, [fp, #-36]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	mov	r2, r3
	ldr	r3, [fp, #-40]
	add	r3, r3, r2
	str	r3, [fp, #-40]
	ldr	r3, [fp, #-40]
	and	r1, r3, #255
	sub	r2, fp, #56
	ldr	r3, [fp, #-36]
	add	r3, r2, r3
	mov	r2, r1
	strb	r2, [r3]
	ldr	r3, [fp, #-40]
	lsr	r3, r3, #8
	str	r3, [fp, #-40]
	sub	r3, fp, #36
	ldmia	r3, {r2-r3}
	adds	r6, r2, #1
	adc	r7, r3, #0
	str	r6, [fp, #-36]
	str	r7, [fp, #-32]
.L21:
	sub	r3, fp, #36
	ldmia	r3, {r2-r3}
	cmp	r2, #16
	sbcs	r3, r3, #0
	bcc	.L22
	sub	r3, fp, #172
	ldmia	r3, {r2-r3}
	subs	r8, r2, #64
	sbc	r9, r3, #0
	str	r8, [fp, #-172]
	str	r9, [fp, #-168]
	ldr	r3, [fp, #-160]
	add	r3, r3, #64
	str	r3, [fp, #-160]
.L20:
	sub	r3, fp, #172
	ldmia	r3, {r2-r3}
	cmp	r2, #64
	sbcs	r3, r3, #0
	bcs	.L23
	sub	r3, fp, #172
	ldmia	r3, {r2-r3}
	orrs	r3, r2, r3
	beq	.L24
	sub	r2, fp, #152
	sub	r1, fp, #56
	sub	r0, fp, #120
	ldr	r3, .L28
	bl	crypto_core_chacha20
	mov	r2, #0
	mov	r3, #0
	str	r2, [fp, #-36]
	str	r3, [fp, #-32]
	b	.L25
.L26:
	ldr	r3, [fp, #-36]
	ldr	r2, [fp, #-160]
	add	r3, r2, r3
	sub	r1, fp, #120
	ldr	r2, [fp, #-36]
	add	r2, r1, r2
	ldrb	r2, [r2]	@ zero_extendqisi2
	strb	r2, [r3]
	sub	r3, fp, #36
	ldmia	r3, {r2-r3}
	adds	r4, r2, #1
	adc	r5, r3, #0
	str	r4, [fp, #-36]
	str	r5, [fp, #-32]
.L25:
	sub	r1, fp, #36
	ldmia	r1, {r0-r1}
	sub	r3, fp, #172
	ldmia	r3, {r2-r3}
	cmp	r0, r2
	sbcs	r3, r1, r3
	bcc	.L26
.L24:
	mov	r3, #0
.L27:
	mov	r0, r3
	sub	sp, fp, #28
	@ sp needed
	pop	{r4, r5, r6, r7, r8, r9, fp, lr}
	bx	lr
.L29:
	.align	2
.L28:
	.word	sigma
	.size	crypto_stream_chacha20, .-crypto_stream_chacha20
	.ident	"GCC: (Arch Repository) 14.1.0"
