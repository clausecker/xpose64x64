#include <string.h>
#include <arm_neon.h>

void xpose_ref(unsigned long long A[64])
{
	unsigned long long B[64];
	size_t i, j;

	memset(B, 0, sizeof B);

	for (i = 0; i < 64; i++)
		for (j = 0; j < 64; j++)
			B[i] |= (A[j] >> i & 1) << j;

	memcpy(A, B, sizeof B);
}
   
void xpose_lee(uint64_t *pSrc)
    {
        uint64_t aDst[64], *pDst = aDst, *pSrcOrig = pSrc;

        uint8x8_t drow0, drow1, drow2, drow3, drow4, drow5, drow6, drow7;
        uint8x8_t dtmp0, dtmp1, dtmp2, dtmp3, dtmp4, dtmp5, dtmp6, dtmp7;
        uint8x16_t qrow0, qrow1, qrow2, qrow3, qrow4, qrow5, qrow6, qrow7;
        uint8x16_t qtmp0, qtmp1, qtmp2, qtmp3, qtmp4, qtmp5, qtmp6, qtmp7;
        const intptr_t sstride = 16;
        uint8_t *pSrc1, *pSrc2, *pSrcBase;
        uint32_t count = 8;
    
        drow0 = vmov_n_u8(0);
        drow1 = vmov_n_u8(0);
        drow2 = vmov_n_u8(0);
        drow3 = vmov_n_u8(0);
        drow4 = vmov_n_u8(0);
        drow5 = vmov_n_u8(0);
        drow6 = vmov_n_u8(0);
        drow7 = vmov_n_u8(0);
    
        pSrcBase = (uint8_t *) pSrc;
    
        do {
            pSrc1 = pSrcBase;
            pSrc2 = pSrcBase + 8;
            pSrcBase += 1;
            drow0 = vld1_lane_u8(pSrc1, drow0, 0); pSrc1 += sstride;
            drow1 = vld1_lane_u8(pSrc2, drow1, 0); pSrc2 += sstride;
            drow2 = vld1_lane_u8(pSrc1, drow2, 0); pSrc1 += sstride;
            drow3 = vld1_lane_u8(pSrc2, drow3, 0); pSrc2 += sstride;
            drow4 = vld1_lane_u8(pSrc1, drow4, 0); pSrc1 += sstride;
            drow5 = vld1_lane_u8(pSrc2, drow5, 0); pSrc2 += sstride;
            drow6 = vld1_lane_u8(pSrc1, drow6, 0); pSrc1 += sstride;
            drow7 = vld1_lane_u8(pSrc2, drow7, 0); pSrc2 += sstride;
            drow0 = vld1_lane_u8(pSrc1, drow0, 1); pSrc1 += sstride;
            drow1 = vld1_lane_u8(pSrc2, drow1, 1); pSrc2 += sstride;
            drow2 = vld1_lane_u8(pSrc1, drow2, 1); pSrc1 += sstride;
            drow3 = vld1_lane_u8(pSrc2, drow3, 1); pSrc2 += sstride;
            drow4 = vld1_lane_u8(pSrc1, drow4, 1); pSrc1 += sstride;
            drow5 = vld1_lane_u8(pSrc2, drow5, 1); pSrc2 += sstride;
            drow6 = vld1_lane_u8(pSrc1, drow6, 1); pSrc1 += sstride;
            drow7 = vld1_lane_u8(pSrc2, drow7, 1); pSrc2 += sstride;
            drow0 = vld1_lane_u8(pSrc1, drow0, 2); pSrc1 += sstride;
            drow1 = vld1_lane_u8(pSrc2, drow1, 2); pSrc2 += sstride;
            drow2 = vld1_lane_u8(pSrc1, drow2, 2); pSrc1 += sstride;
            drow3 = vld1_lane_u8(pSrc2, drow3, 2); pSrc2 += sstride;
            drow4 = vld1_lane_u8(pSrc1, drow4, 2); pSrc1 += sstride;
            drow5 = vld1_lane_u8(pSrc2, drow5, 2); pSrc2 += sstride;
            drow6 = vld1_lane_u8(pSrc1, drow6, 2); pSrc1 += sstride;
            drow7 = vld1_lane_u8(pSrc2, drow7, 2); pSrc2 += sstride;
            drow0 = vld1_lane_u8(pSrc1, drow0, 3); pSrc1 += sstride;
            drow1 = vld1_lane_u8(pSrc2, drow1, 3); pSrc2 += sstride;
            drow2 = vld1_lane_u8(pSrc1, drow2, 3); pSrc1 += sstride;
            drow3 = vld1_lane_u8(pSrc2, drow3, 3); pSrc2 += sstride;
            drow4 = vld1_lane_u8(pSrc1, drow4, 3); pSrc1 += sstride;
            drow5 = vld1_lane_u8(pSrc2, drow5, 3); pSrc2 += sstride;
            drow6 = vld1_lane_u8(pSrc1, drow6, 3); pSrc1 += sstride;
            drow7 = vld1_lane_u8(pSrc2, drow7, 3); pSrc2 += sstride;
            drow0 = vld1_lane_u8(pSrc1, drow0, 4); pSrc1 += sstride;
            drow1 = vld1_lane_u8(pSrc2, drow1, 4); pSrc2 += sstride;
            drow2 = vld1_lane_u8(pSrc1, drow2, 4); pSrc1 += sstride;
            drow3 = vld1_lane_u8(pSrc2, drow3, 4); pSrc2 += sstride;
            drow4 = vld1_lane_u8(pSrc1, drow4, 4); pSrc1 += sstride;
            drow5 = vld1_lane_u8(pSrc2, drow5, 4); pSrc2 += sstride;
            drow6 = vld1_lane_u8(pSrc1, drow6, 4); pSrc1 += sstride;
            drow7 = vld1_lane_u8(pSrc2, drow7, 4); pSrc2 += sstride;
            drow0 = vld1_lane_u8(pSrc1, drow0, 5); pSrc1 += sstride;
            drow1 = vld1_lane_u8(pSrc2, drow1, 5); pSrc2 += sstride;
            drow2 = vld1_lane_u8(pSrc1, drow2, 5); pSrc1 += sstride;
            drow3 = vld1_lane_u8(pSrc2, drow3, 5); pSrc2 += sstride;
            drow4 = vld1_lane_u8(pSrc1, drow4, 5); pSrc1 += sstride;
            drow5 = vld1_lane_u8(pSrc2, drow5, 5); pSrc2 += sstride;
            drow6 = vld1_lane_u8(pSrc1, drow6, 5); pSrc1 += sstride;
            drow7 = vld1_lane_u8(pSrc2, drow7, 5); pSrc2 += sstride;
            drow0 = vld1_lane_u8(pSrc1, drow0, 6); pSrc1 += sstride;
            drow1 = vld1_lane_u8(pSrc2, drow1, 6); pSrc2 += sstride;
            drow2 = vld1_lane_u8(pSrc1, drow2, 6); pSrc1 += sstride;
            drow3 = vld1_lane_u8(pSrc2, drow3, 6); pSrc2 += sstride;
            drow4 = vld1_lane_u8(pSrc1, drow4, 6); pSrc1 += sstride;
            drow5 = vld1_lane_u8(pSrc2, drow5, 6); pSrc2 += sstride;
            drow6 = vld1_lane_u8(pSrc1, drow6, 6); pSrc1 += sstride;
            drow7 = vld1_lane_u8(pSrc2, drow7, 6); pSrc2 += sstride;
            drow0 = vld1_lane_u8(pSrc1, drow0, 7); pSrc1 += sstride;
            drow1 = vld1_lane_u8(pSrc2, drow1, 7); pSrc2 += sstride;
            drow2 = vld1_lane_u8(pSrc1, drow2, 7); pSrc1 += sstride;
            drow3 = vld1_lane_u8(pSrc2, drow3, 7); pSrc2 += sstride;
            drow4 = vld1_lane_u8(pSrc1, drow4, 7); pSrc1 += sstride;
            drow5 = vld1_lane_u8(pSrc2, drow5, 7); pSrc2 += sstride;
            drow6 = vld1_lane_u8(pSrc1, drow6, 7);
            drow7 = vld1_lane_u8(pSrc2, drow7, 7);
    
            dtmp0 = vshr_n_u8(drow0, 1);
            dtmp1 = vshr_n_u8(drow1, 1);
            dtmp2 = vshr_n_u8(drow2, 1);
            dtmp3 = vshr_n_u8(drow3, 1);
            dtmp4 = vshr_n_u8(drow4, 1);
            dtmp5 = vshr_n_u8(drow5, 1);
            dtmp6 = vshr_n_u8(drow6, 1);
            dtmp7 = vshr_n_u8(drow7, 1);
    
            qrow0 = vcombine_u8(drow0, dtmp0);
            qrow1 = vcombine_u8(drow1, dtmp1);
            qrow2 = vcombine_u8(drow2, dtmp2);
            qrow3 = vcombine_u8(drow3, dtmp3);
            qrow4 = vcombine_u8(drow4, dtmp4);
            qrow5 = vcombine_u8(drow5, dtmp5);
            qrow6 = vcombine_u8(drow6, dtmp6);
            qrow7 = vcombine_u8(drow7, dtmp7);
    
    //////////////////////////////////////
    
            qtmp0 = qrow0;
            qtmp1 = qrow1;
            qtmp2 = qrow2;
            qtmp3 = qrow3;
            qtmp4 = qrow4;
            qtmp5 = qrow5;
            qtmp6 = qrow6;
            qtmp7 = qrow7;
    
            qtmp0 = vsliq_n_u8(qtmp0, qtmp1, 1);
            qtmp2 = vsliq_n_u8(qtmp2, qtmp3, 1);
            qtmp4 = vsliq_n_u8(qtmp4, qtmp5, 1);
            qtmp6 = vsliq_n_u8(qtmp6, qtmp7, 1);
    
            qtmp0 = vsliq_n_u8(qtmp0, qtmp2, 2);
            qtmp4 = vsliq_n_u8(qtmp4, qtmp6, 2);
    
            qtmp0 = vsliq_n_u8(qtmp0, qtmp4, 4);
    
            vst1q_u8((uint8_t *)pDst, qtmp0); pDst += 2;
    
    //////////////////////////////////////
    
            qtmp0 = vshrq_n_u8(qrow0, 2);
            qtmp1 = vshrq_n_u8(qrow1, 2);
            qtmp2 = vshrq_n_u8(qrow2, 2);
            qtmp3 = vshrq_n_u8(qrow3, 2);
            qtmp4 = vshrq_n_u8(qrow4, 2);
            qtmp5 = vshrq_n_u8(qrow5, 2);
            qtmp6 = vshrq_n_u8(qrow6, 2);
            qtmp7 = vshrq_n_u8(qrow7, 2);
    
            qtmp0 = vsliq_n_u8(qtmp0, qtmp1, 1);
            qtmp2 = vsliq_n_u8(qtmp2, qtmp3, 1);
            qtmp4 = vsliq_n_u8(qtmp4, qtmp5, 1);
            qtmp6 = vsliq_n_u8(qtmp6, qtmp7, 1);
    
            qtmp0 = vsliq_n_u8(qtmp0, qtmp2, 2);
            qtmp4 = vsliq_n_u8(qtmp4, qtmp6, 2);
    
            qtmp0 = vsliq_n_u8(qtmp0, qtmp4, 4);
    
            vst1q_u8((uint8_t *)pDst, qtmp0); pDst += 2;
    
            //////////////////////////////////////
    
            qtmp0 = vshrq_n_u8(qrow0, 4);
            qtmp1 = vshrq_n_u8(qrow1, 4);
            qtmp2 = vshrq_n_u8(qrow2, 4);
            qtmp3 = vshrq_n_u8(qrow3, 4);
            qtmp4 = vshrq_n_u8(qrow4, 4);
            qtmp5 = vshrq_n_u8(qrow5, 4);
            qtmp6 = vshrq_n_u8(qrow6, 4);
            qtmp7 = vshrq_n_u8(qrow7, 4);
    
            qtmp0 = vsliq_n_u8(qtmp0, qtmp1, 1);
            qtmp2 = vsliq_n_u8(qtmp2, qtmp3, 1);
            qtmp4 = vsliq_n_u8(qtmp4, qtmp5, 1);
            qtmp6 = vsliq_n_u8(qtmp6, qtmp7, 1);
    
            qtmp0 = vsliq_n_u8(qtmp0, qtmp2, 2);
            qtmp4 = vsliq_n_u8(qtmp4, qtmp6, 2);
    
            qtmp0 = vsliq_n_u8(qtmp0, qtmp4, 4);
    
            vst1q_u8((uint8_t *)pDst, qtmp0); pDst += 2;
    
            //////////////////////////////////////
    
            qtmp0 = vshrq_n_u8(qrow0, 6);
            qtmp1 = vshrq_n_u8(qrow1, 6);
            qtmp2 = vshrq_n_u8(qrow2, 6);
            qtmp3 = vshrq_n_u8(qrow3, 6);
            qtmp4 = vshrq_n_u8(qrow4, 6);
            qtmp5 = vshrq_n_u8(qrow5, 6);
            qtmp6 = vshrq_n_u8(qrow6, 6);
            qtmp7 = vshrq_n_u8(qrow7, 6);
    
            qtmp0 = vsliq_n_u8(qtmp0, qtmp1, 1);
            qtmp2 = vsliq_n_u8(qtmp2, qtmp3, 1);
            qtmp4 = vsliq_n_u8(qtmp4, qtmp5, 1);
            qtmp6 = vsliq_n_u8(qtmp6, qtmp7, 1);
    
            qtmp0 = vsliq_n_u8(qtmp0, qtmp2, 2);
            qtmp4 = vsliq_n_u8(qtmp4, qtmp6, 2);
    
            qtmp0 = vsliq_n_u8(qtmp0, qtmp4, 4);
    
            vst1q_u8((uint8_t *)pDst, qtmp0); pDst += 2;
    
        } while (--count);

        memcpy(pSrcOrig, aDst, sizeof aDst);
    }
