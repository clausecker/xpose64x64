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

    .arch armv8-a
GLOBL(xpose_noob)
    .text

.balign 64
// void xpose_noob(uint64_t *pDst, uint64_t *pSrc);
pDst    .req    x0
pSrc0   .req    x1
pSrc1   .req    x2
pDst1   .req    x3
stride  .req    x4
count   .req    w5

pDst0   .req    pDst

// no "battle plan" here. not needed for such a self-explanatory cakewalk
FUNC(xpose_noob)
    mov     pSrc0, pDst
    add     pSrc1, pSrc0, #64
    movi    v6.16b, #0xcc
    mov     stride, #128
    movi    v7.16b, #0xaa
    sub     pDst, pDst, #32
    mov     count, #2

.balign 16
1:
    ld4     {v16.16b, v17.16b, v18.16b, v19.16b}, [pSrc0], stride
    ld4     {v20.16b, v21.16b, v22.16b, v23.16b}, [pSrc1], stride
    ld4     {v24.16b, v25.16b, v26.16b, v27.16b}, [pSrc0], stride
    ld4     {v28.16b, v29.16b, v30.16b, v31.16b}, [pSrc1], stride

    stp     q16, q20, [pDst, #32]!
    subs    count, count, #1
    stp     q17, q21, [pDst, #1*64]
    stp     q18, q22, [pDst, #2*64]
    stp     q19, q23, [pDst, #3*64]
    stp     q24, q28, [pDst, #4*64]
    stp     q25, q29, [pDst, #5*64]
    stp     q26, q30, [pDst, #6*64]
    stp     q27, q31, [pDst, #7*64]
    b.ne    1b
    // 8x64 matrix transpose virtually finished. What a moron needs zip1/zip2/trn for that?
    nop

    sub     pSrc0, pDst, #32
    add     pSrc1, pDst, #256-32
    mov     count, #4
    sub     pDst0, pDst, #32
    add     pDst1, pSrc0, #256

1:
    // 8x64 matrix transpose finished on-the-fly while reloading. Again, who the hell needs permutation instructions when we have ld2/ld3/ld4?
    ld2     {v24.16b, v25.16b}, [pSrc0], #32
    ld2     {v26.16b, v27.16b}, [pSrc1], #32
    ld2     {v28.16b, v29.16b}, [pSrc0], #32
    ld2     {v30.16b, v31.16b}, [pSrc1], #32
    subs    count, count, #1

    // nosy noob shut up remark: the trns below aren't part of the matrix transpose
    trn1    v16.2d, v24.2d, v25.2d  // row0
    trn2    v17.2d, v24.2d, v25.2d  // row1
    trn1    v18.2d, v26.2d, v27.2d  // row2
    trn2    v19.2d, v26.2d, v28.2d  // row3
    trn1    v20.2d, v28.2d, v29.2d  // row4
    trn2    v21.2d, v28.2d, v29.2d  // row5
    trn1    v22.2d, v30.2d, v31.2d  // row6
    trn2    v23.2d, v30.2d, v31.2d  // row7

    mov     v24.16b, v16.16b
    mov     v25.16b, v17.16b
    mov     v26.16b, v18.16b
    mov     v27.16b, v19.16b

    sli     v16.16b, v20.16b, #4
    sli     v17.16b, v21.16b, #4
    sli     v18.16b, v22.16b, #4
    sli     v19.16b, v23.16b, #4
    sri     v20.16b, v24.16b, #4
    sri     v21.16b, v25.16b, #4
    sri     v22.16b, v26.16b, #4
    sri     v23.16b, v27.16b, #4

    shl     v24.16b, v18.16b, #2
    shl     v25.16b, v19.16b, #2
    ushr    v26.16b, v16.16b, #2
    ushr    v27.16b, v17.16b, #2
    shl     v28.16b, v22.16b, #2
    shl     v29.16b, v23.16b, #2
    ushr    v30.16b, v20.16b, #2
    ushr    v31.16b, v21.16b, #2

    bit     v16.16b, v24.16b, v6.16b
    bit     v17.16b, v25.16b, v6.16b
    bif     v18.16b, v26.16b, v6.16b
    bif     v19.16b, v27.16b, v6.16b
    bit     v20.16b, v28.16b, v6.16b
    bit     v21.16b, v29.16b, v6.16b
    bif     v22.16b, v30.16b, v6.16b
    bif     v23.16b, v31.16b, v6.16b

    shl     v24.16b, v17.16b, #1
    ushr    v25.16b, v16.16b, #1
    shl     v26.16b, v19.16b, #1
    ushr    v27.16b, v18.16b, #1
    shl     v28.16b, v21.16b, #1
    ushr    v29.16b, v20.16b, #1
    shl     v30.16b, v23.16b, #1
    ushr    v31.16b, v22.16b, #1

    bit     v16.16b, v24.16b, v7.16b
    bif     v17.16b, v25.16b, v7.16b
    bit     v18.16b, v26.16b, v7.16b
    bif     v19.16b, v27.16b, v7.16b
    bit     v20.16b, v28.16b, v7.16b
    bif     v21.16b, v29.16b, v7.16b
    bit     v22.16b, v30.16b, v7.16b
    bif     v23.16b, v31.16b, v7.16b

    st4     {v16.d, v17.d, v18.d, v19.d}[0], [pDst0], #32
    st4     {v16.d, v17.d, v18.d, v19.d}[1], [pDst1], #32
    st4     {v20.d, v21.d, v22.d, v23.d}[0], [pDst0], #32
    st4     {v20.d, v21.d, v22.d, v23.d}[1], [pDst1], #32
    b.ne    1b

// Everyone has a plan until they get punched in the mouth - Mike Tyson

.balign 16
    ret
ENDFUNC(xpose_noob)
.end
