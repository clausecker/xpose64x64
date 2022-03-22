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

	.text
	.balign 4

	# transpose a 64x64 bit matrix held in x0
	GLOBL(xpose_asm)
FUNC(xpose_asm)
	# plan of attack: use registers v16--v32 to hold
	# half the array, v0--v7 for scratch.  First transpose
	# the two array halves individually, then swap the
	# second and third quarters.
	mov	x4, lr

	mov	x2, x0
	bl	NAME(xpose_half)
	mov	x3, x0
	bl	NAME(xpose_half)

	# final step: transpose 64x64 bit matrices
	# we have to do this one in two parts as to not run
	# out of registers
	mov	x5, x2
	mov	x6, x3
	bl	NAME(xpose_final)
	bl	NAME(xpose_final)

	ret	x4
ENDFUNC(xpose_asm)

	# Transpose half a 32x64 bit matrix held in x0.
	# On return, advance x0 by 32*8 = 256 byte.
FUNC(xpose_half)
	# v16 holds rows 0 and 4, v17 holds 1 and 5, and so on
	mov	x1, x0
	ld4	{v16.2d, v17.2d, v18.2d, v19.2d}, [x0], #64
	ld4	{v20.2d, v21.2d, v22.2d, v23.2d}, [x0], #64
	ld4	{v24.2d, v25.2d, v26.2d, v27.2d}, [x0], #64
	ld4	{v28.2d, v29.2d, v30.2d, v31.2d}, [x0], #64

	# macro for a transposition step.  Trashes v6 and v7
.macro	xpstep lo, hi, mask, shift
	ushr v6.2d, \lo\().2d, #\shift
	shl v7.2d, \hi\().2d, #\shift
	bif \lo\().16b, v7.16b, \mask\().16b
	bit \hi\().16b, v6.16b, \mask\().16b
.endm

	# 1st step: transpose 2x2 bit matrices
	movi	v0.16b, #0x55
	xpstep	v16, v17, v0, 1
	xpstep	v18, v19, v0, 1
	xpstep	v20, v21, v0, 1
	xpstep	v22, v23, v0, 1
	xpstep	v24, v25, v0, 1
	xpstep	v26, v27, v0, 1
	xpstep	v28, v29, v0, 1
	xpstep	v30, v31, v0, 1

	# 2nd step: transpose 4x4 bit matrices
	movi	v0.16b, #0x33
	xpstep	v16, v18, v0, 2
	xpstep	v17, v19, v0, 2
	xpstep	v20, v22, v0, 2
	xpstep	v21, v23, v0, 2
	xpstep	v24, v26, v0, 2
	xpstep	v25, v27, v0, 2
	xpstep	v28, v30, v0, 2
	xpstep	v29, v31, v0, 2

	# immediate step: zip vectors to change
	# colocation.  As a side effect, every other
	# vector is temporarily relocated to the v0..v7
	# register range
	zip1	v0.2d,  v16.2d, v17.2d
	zip2	v17.2d, v16.2d, v17.2d
	zip1	v1.2d,  v18.2d, v19.2d
	zip2	v19.2d, v18.2d, v19.2d
	zip1	v2.2d,  v20.2d, v21.2d
	zip2	v21.2d, v20.2d, v21.2d
	zip1	v3.2d,  v22.2d, v23.2d
	zip2	v23.2d, v22.2d, v23.2d
	zip1	v4.2d,	v24.2d, v25.2d
	zip2	v25.2d, v24.2d, v25.2d
	zip1	v5.2d,  v26.2d, v27.2d
	zip2	v27.2d, v26.2d, v27.2d
	zip1	v6.2d,  v28.2d, v29.2d
	zip2	v29.2d, v28.2d, v29.2d
	zip1	v7.2d,  v30.2d, v31.2d
	zip2	v31.2d, v30.2d, v31.2d

	# macro for the 3rd transposition step
	# swap low 4 bit of each hi member with
	# high 4 bit of each orig member.  The orig
	# members are copied to lo in the process.
.macro	xpstep3	lo, hi, orig
	mov	\lo\().2d, \orig\().2d
	sli	\lo\().16b, \hi\().16b, #4
	sri	\hi\().16b, \orig\().16b, #4
.endm

	# 3rd step: transpose 8x8 bit matrices
	# special code is needed here since we need to
	# swap row n row line n+4, but these rows are
	# always colocated in the same register
	xpstep3	v16, v17, v0
	xpstep3	v18, v19, v1
	xpstep3	v20, v21, v2
	xpstep3 v22, v23, v3
	xpstep3	v24, v25, v4
	xpstep3	v26, v27, v5
	xpstep3	v28, v29, v6
	xpstep3	v30, v31, v7

	# registers now hold
	# v16: { 0,  1}  v17: { 4,  5}  v18: { 2,  3}  v19: { 6,  7}
	# v20: { 8,  9}  v21: {12, 13}  v22: {10, 11}  v23: {14, 15}
	# v24: {16, 17}  v25: {20, 21}  v26: {18, 19}  v27: {22, 23}
	# v28: {24, 25}  v29: {28, 29}  v30: {26, 27}  v31: {30, 31}

	# 4th step: transpose 16x16 bit matrices
	# this step again moves half the registers to v0--v7
	trn1	v0.16b,  v16.16b, v20.16b
	trn2	v20.16b, v16.16b, v20.16b
	trn1	v1.16b,  v17.16b, v21.16b
	trn2	v21.16b, v17.16b, v21.16b
	trn1	v2.16b,  v18.16b, v22.16b
	trn2	v22.16b, v18.16b, v22.16b
	trn1	v3.16b,  v19.16b, v23.16b
	trn2	v23.16b, v19.16b, v23.16b
	trn1	v4.16b,	 v24.16b, v28.16b
	trn2	v28.16b, v24.16b, v28.16b
	trn1	v5.16b,  v25.16b, v29.16b
	trn2	v29.16b, v25.16b, v29.16b
	trn1	v6.16b,  v26.16b, v30.16b
	trn2	v30.16b, v26.16b, v30.16b
	trn1	v7.16b,	 v27.16b, v31.16b
	trn2	v31.16b, v27.16b, v31.16b

	# 5th step: transpose 32x32 bit matrices
	# while we are at it, shuffle the order of
	# entries such that they are in order
	trn1	v16.8h, v0.8h, v4.8h
	trn2	v24.8h, v0.8h, v4.8h
	trn1	v18.8h, v1.8h, v5.8h
	trn2	v26.8h, v1.8h, v5.8h
	trn1	v17.8h, v2.8h, v6.8h
	trn2	v25.8h, v2.8h, v6.8h
	trn1	v19.8h, v3.8h, v7.8h
	trn2	v27.8h, v3.8h, v7.8h

	trn1	v0.8h, v20.8h, v28.8h
	trn2	v4.8h, v20.8h, v28.8h
	trn1	v2.8h, v21.8h, v29.8h
	trn2	v6.8h, v21.8h, v29.8h
	trn1	v1.8h, v22.8h, v30.8h
	trn2	v5.8h, v22.8h, v30.8h
	trn1	v3.8h, v23.8h, v31.8h
	trn2	v7.8h, v23.8h, v31.8h

	# now deposit the partially transposed matrix
	st1	{v16.2d, v17.2d, v18.2d, v19.2d}, [x1], #64
	st1	{v0.2d, v1.2d, v2.2d, v3.2d}, [x1], #64
	st1	{v24.2d, v25.2d, v26.2d, v27.2d}, [x1], #64
	st1	{v4.2d, v5.2d, v6.2d, v7.2d}, [x1], #64

	ret
ENDFUNC(xpose_half)

FUNC(xpose_final)
	ld1	{v16.2d, v17.2d, v18.2d, v19.2d}, [x2], #64
	ld1	{v24.2d, v25.2d, v26.2d, v27.2d}, [x3], #64
	ld1	{v20.2d, v21.2d, v22.2d, v23.2d}, [x2], #64
	ld1	{v28.2d, v29.2d, v30.2d, v31.2d}, [x3], #64

	trn1	v0.4s, v16.4s, v24.4s
	trn2	v4.4s, v16.4s, v24.4s
	trn1	v1.4s, v17.4s, v25.4s
	trn2	v5.4s, v17.4s, v25.4s
	trn1	v2.4s, v18.4s, v26.4s
	trn2	v6.4s, v18.4s, v26.4s
	trn1	v3.4s, v19.4s, v27.4s
	trn2	v7.4s, v19.4s, v27.4s

	trn1	v16.4s, v20.4s, v28.4s
	trn2	v24.4s, v20.4s, v28.4s
	trn1	v17.4s, v21.4s, v29.4s
	trn2	v25.4s, v21.4s, v29.4s
	trn1	v18.4s, v22.4s, v30.4s
	trn2	v26.4s, v22.4s, v30.4s
	trn1	v19.4s, v23.4s, v31.4s
	trn2	v27.4s, v23.4s, v31.4s

	st1	{v0.2d, v1.2d, v2.2d, v3.2d}, [x5], #64
	st1	{v4.2d, v5.2d, v6.2d, v7.2d}, [x6], #64
	st1	{v16.2d, v17.2d, v18.2d, v19.2d}, [x5], #64
	st1	{v24.2d, v25.2d, v26.2d, v27.2d}, [x6], #64

	ret
ENDFUNC(xpose_final)
