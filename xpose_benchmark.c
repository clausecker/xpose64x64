#include <ctype.h>
#include <math.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#ifndef TIME_GOAL
# define TIME_GOAL 2.0
#endif

typedef void xpose_func(unsigned long long[64]);
extern xpose_func xpose_asm, xpose_lee, xpose_ref, xpose_noob;

static const struct xpose_method {
	const char *name;
	xpose_func *method;
} methods[] = {
	{ "ref", xpose_ref },
	{ "lee", xpose_lee },
	{ "fuz", xpose_asm },
//	{ "noob", xpose_noob },
	{ NULL, NULL },
};

/* state of performance counters at one point in time */
struct counters {
	struct timespec ts;
};

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

/* set counters to their current value */
static int
reset_counters(struct counters *c)
{
	ssize_t count;
	int res;

	res = clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &c->ts);
	if (res == -1) {
		perror("clock_gettime");
		return (-1);
	}

	return (0);
}

/* compute the difference between two timespec as a double */
static double
tsdiff(struct timespec start, struct timespec end)
{
	time_t sec;
	long nsec;

	sec = end.tv_sec - start.tv_sec;
	nsec = end.tv_nsec - start.tv_nsec;
	if (nsec < 0) {
		sec--;
		nsec += 1000000000L;
	}

	return (sec + nsec * 1.0e-9);
}

/* print test results */
/* https://golang.org/design/14313-benchmark-format */
static void
print_results(
    const char *name,
    struct counters *start, struct counters *end,
    size_t m) {
	double elapsed;

	elapsed = tsdiff(start->ts, end->ts);

	if (name == NULL || name[0] == '\0')
		name = " ";

	printf("Benchmark%c%s\t%10zu\t"
	    "%.8g ns/op\t%.8g MB/s\n",
	    toupper(name[0]), name+1, m,
	    (elapsed * 1e9) / m, (1e-6 * 64 * 8 * m) / elapsed);
}

static int
test_xpose(struct counters *c, xpose_func *xpose, size_t m)
{
	unsigned long long _Alignas(64) A[64];
	unsigned long long accum;
	volatile unsigned long long sum;
	size_t i;
	int res;

	srand48(42);
	generate(A);

	/* skip initialisation step in benchmark measurements */
	res = reset_counters(c);
	if (res != 0)
		return (-1);

	for (i = 0; i < m; i++)
		xpose(A);

	/* make sure the result is used */
	accum = 0;
	for (i = 0; i < 64; i++)
		accum += A[i];
	sum = accum;

	return (0);
}

/* run one test case and print the result */
static void
run_test(const struct xpose_method *method)
{
	struct counters start, end;
	size_t m = 1;
	int first_run = 1;

	/* repeatedly run benchmark and adjust m until result is meaningful */
	for (;; first_run = 0) {
		double elapsed;
		size_t newm;
		int res;

		res = reset_counters(&start);
		if (res != 0) {
			printf("FAIL\t%s\n", method->name);
			return;
		}

		res = test_xpose(&start, method->method, m);
		if (res != 0) {
			printf("FAIL\t%s\n", method->name);
			return;
		}

		res = reset_counters(&end);
		if (res != 0) {
			printf("FAIL\t%s\n", method->name);
			return;
		}

		elapsed = tsdiff(start.ts, end.ts);
		if (elapsed < TIME_GOAL) {
			if (elapsed < TIME_GOAL * 0.5)
				m *= 2;
			else {
				/* try to overshoot 1s time goal slightly */
				newm = ceil(m * TIME_GOAL * 1.05 / elapsed);
				m = newm > m ? newm : m + 1;
			}

			continue;
		}

		/* make sure to perform at least one warm-up iteration */
		if (!first_run)
			break;
	}

	print_results(method->name, &start, &end, m);
}

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

static void print(unsigned long long A[64])
{
	size_t i;

	for (i = 0; i < 64; i++)
		printf("%016llx\n", A[i]);

	putchar('\n');
}

extern int main()
{
	const struct xpose_method *method;

	for (method = methods; method->name != NULL; method++)
		run_test(method);
}
