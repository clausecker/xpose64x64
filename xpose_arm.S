#ifdef __MACH__
#define FUNC(f) _ ## f:
#define ENDFUNC(f)
#define GLOBL(f) .globl _ ## f
#define NAME(f) _ ## f
#else
#define FUNC(f) f: .type f, %function
#define ENDFUNC(f) .size f, .-f
#define GLOBL(f) .globl f
#define NAME(f) f
#endif

	.syntax unified
	.arch armv7-a
	.text
	.balign 4

	# transpose 64x64 bit matrix held in x0
	GLOBL(xpose_asm)
FUNC(xpose_asm)
	# plan of attack: first transpose each 16x16 subarray,
	# then swap 16x16 and 32x32 subarrays.
	push	{lr}
	vpush	{q4, q5, q6, q7}
	movs	r2, r0
	movs	r3, #64
	bl	NAME(xpose_first)
	bl	NAME(xpose_first)
	bl	NAME(xpose_first)
	bl	NAME(xpose_first)

	movs	r0, r2
	bl	NAME(xpose_second)
	bl	NAME(xpose_second)

	movs	r0, r2
	bl	NAME(xpose_third)
	bl	NAME(xpose_third)

	vpop	{q4, q5, q6, q7}
	pop	{pc} 
ENDFUNC(xpose_asm)

	# Transpose one 16x64 bit matric held in r0.
	# On return, advance r0 by 16*8 = 128 byte.
FUNC(xpose_first)
	add	r1, r0, #32
	vld1.64	{d0, d1, d2, d3}, [r0], r3
	vld1.64 {d4, d5, d6, d7}, [r1], r3
	vld1.64	{d8, d9, d10, d11}, [r0], r3
	vld1.64 {d12, d13, d14, d15}, [r1], r3
	sub r0, r0, #128
	sub r1, r1, #128

	# step 1: transpose 2x2 submatrices
.macro	xpstep1 lo, hi, both
	vshl.u64 q11, \both, q9
	vbif	\lo, d23, d20
	vbit	\hi, d22, d20
.endm

	vmov.i64 d18, #0xffffffffffffffff
	vmov.i8	d20, #0x55
	vshr.u64 d19, d18, #63

	xpstep1	d0, d1, q0
	xpstep1	d2, d3, q1
	xpstep1	d4, d5, q2
	xpstep1	d6, d7, q3
	xpstep1	d8, d9, q4
	xpstep1	d10, d11, q5
	xpstep1	d12, d13, q6
	xpstep1	d14, d15, q7

	# step 2: transpose 4x4 submatrices
.macro	xpstep2 lo, hi
	vshr.u64 q10, \lo, #2
	vshl.i64 q11, \hi, #2
	vbif.64	\lo, q11, q12
	vbit.64 \hi, q10, q12
.endm

	vmov.i8	q12, #0x33
	xpstep2	q0, q1
	xpstep2	q2, q3
	xpstep2	q4, q5
	xpstep2	q6, q7

	# step 3: transpose 8x8 submatrices
.macro	xpstep3	lo, hi
	vmov	q8, \lo
	vsli.u8	\lo, \hi, #4
	vsri.u8	\hi, q8, #4
.endm

	xpstep3	q0, q2
	xpstep3	q1, q3
	xpstep3	q4, q6
	xpstep3	q5, q7

	# step 4: transpose 16x16 submatrices
	vtrn.8	q0, q4
	vtrn.8	q1, q5
	vtrn.8	q2, q6
	vtrn.8	q3, q7

	# deposit results and advance r0
	vst1.64 {d0, d1, d2, d3}, [r0], r3
	vst1.64 {d4, d5, d6, d7}, [r1], r3
	vst1.64 {d8, d9, d10, d11}, [r0], r3
	vst1.64 {d12, d13, d14, d15}, [r1], r3

	bx	lr
ENDFUNC(xpose_first)

	# Swap the 16x16 submatrices of a 32x64 bit matrix in r0
	# On return, advance r0 by 32*8 = 256 byte
FUNC(xpose_second)
	add	r1, r0, #32
	vld1.64 {d0, d1, d2, d3}, [r0], r3
	vld1.64 {d4, d5, d6, d7}, [r1], r3
	vld1.64 {d8, d9, d10, d11}, [r0], r3
	vld1.64 {d12, d13, d14, d15}, [r1], r3
	vld1.64 {d16, d17, d18, d19}, [r0], r3
	vld1.64 {d20, d21, d22, d23}, [r1], r3
	vld1.64 {d24, d25, d26, d27}, [r0], r3
	vld1.64 {d28, d29, d30, d31}, [r1], r3
	sub r0, r0, #256
	sub r1, r1, #256

	vtrn.16	q0, q8
	vtrn.16	q1, q9
	vtrn.16	q2, q10
	vtrn.16	q3, q11
	vtrn.16	q4, q12
	vtrn.16	q5, q13
	vtrn.16	q6, q14
	vtrn.16	q7, q15

	vst1.64 {d0, d1, d2, d3}, [r0], r3
	vst1.64 {d4, d5, d6, d7}, [r1], r3
	vst1.64 {d8, d9, d10, d11}, [r0], r3
	vst1.64 {d12, d13, d14, d15}, [r1], r3
	vst1.64 {d16, d17, d18, d19}, [r0], r3
	vst1.64 {d20, d21, d22, d23}, [r1], r3
	vst1.64 {d24, d25, d26, d27}, [r0], r3
	vst1.64 {d28, d29, d30, d31}, [r1], r3

	bx	lr
ENDFUNC(xpose_second)

	# Swap half the 32x32 submatrices of a 64x64 matrix in r0
	# On return, advance r0 by 16*8 = 128 byte
FUNC(xpose_third)
	movs	r1, r0
	add	r2, r0, #32*8

	vld1.64 {d0, d1, d2, d3}, [r1]!
	vld1.64 {d16, d17, d18, d19}, [r2]!
	vld1.64 {d4, d5, d6, d7}, [r1]!
	vld1.64 {d20, d21, d22, d23}, [r2]!
	vld1.64 {d8, d9, d10, d11}, [r1]!
	vld1.64 {d24, d25, d26, d27}, [r2]!
	vld1.64 {d12, d13, d14, d15}, [r1]!
	vld1.64 {d28, d29, d30, d31}, [r2]!

	vtrn.32	q0, q8
	vtrn.32	q1, q9
	vtrn.32	q2, q10
	vtrn.32	q3, q11
	vtrn.32	q4, q12
	vtrn.32	q5, q13
	vtrn.32	q6, q14
	vtrn.32	q7, q15

	add	r2, r0, #32*8
	vst1.64 {d0, d1, d2, d3}, [r0]!
	vst1.64 {d16, d17, d18, d19}, [r2]!
	vst1.64 {d4, d5, d6, d7}, [r0]!
	vst1.64 {d20, d21, d22, d23}, [r2]!
	vst1.64 {d8, d9, d10, d11}, [r0]!
	vst1.64 {d24, d25, d26, d27}, [r2]!
	vst1.64 {d12, d13, d14, d15}, [r0]!
	vst1.64 {d28, d29, d30, d31}, [r2]!

	bx	lr
ENDFUNC(xpose_third)
