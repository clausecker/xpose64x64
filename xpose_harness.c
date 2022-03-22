#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern void xpose_asm(unsigned long long[64]);
extern void xpose_lee(unsigned long long[64]);
extern void xpose_ref(unsigned long long[64]);

static int check(unsigned long long A[64], void (*xpose)(unsigned long long[64]))
{
	unsigned long long B[64], C[64];

	memcpy(B, A, sizeof B);
	memcpy(C, A, sizeof C);

	xpose(B);
	xpose_ref(C);

	return (memcmp(B, C, sizeof B) == 0);
}

static void minimize(unsigned long long A[64], void (*xpose)(unsigned long long[64]))
{
	size_t i, j;

	for (i = 0; i < 64; i++)
		for (j = 0; j < 64; j++) {
			if ((A[i] & 1ULL << j) == 0)
				continue;

			A[i] &= ~(1ULL << j);
			if (check(A, xpose))
				A[i] |= 1ULL << j;
		}
}

static void generate(unsigned long long A[64])
{
	size_t i;

	for (i = 0; i < 64; i++) {
		unsigned long long lo, hi;

		lo = mrand48();
		hi = mrand48();

		A[i] = lo & 0xffffffff | (hi & 0xffffffff) << 32;
	}
}

static void print(unsigned long long A[64])
{
	size_t i;

	for (i = 0; i < 64; i++)
		printf("%016llx\n", A[i]);

	putchar('\n');
}

static void cycle(void (*xpose)(unsigned long long[64]))
{
	unsigned long long A[64];

	generate(A);
	if (check(A, xpose))
		return;

	minimize(A, xpose);
	print(A);
}

static void testpattern(void (*xpose)(unsigned long long[64]))
{
	unsigned long long A[64];

	size_t i;

	for (i = 8; i < 64; i++) {
		printf("*** %zu\n", i);
		memset(A, 0, sizeof A);
		A[i] = ~0ULL;
		xpose(A);
		print(A);
	}
}

#define N 100
extern int main()
{
/*	testpattern(xpose_asm); */

	size_t i;

	puts("asm");
	for (i = 0; i < N; i++)
		cycle(xpose_asm);

	puts("lee");
	for (i = 0; i < N; i++)
		cycle(xpose_lee);
}
