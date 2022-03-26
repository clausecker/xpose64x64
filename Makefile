CFLAGS=	-O3 -std=c11
RM= rm -f

all: benchmark harness

benchmark: xpose_benchmark.c xpose_lee.c xpose_arm64.S xpose_arm.S
	$(CC) $(CFLAGS) -o benchmark xpose_benchmark.c xpose_lee.c xpose_`uname -m`.S -lm

harness: xpose_harness.c xpose_lee.c xpose_arm64.S xpose_arm.S
	$(CC) $(CFLAGS) -o harness xpose_harness.c xpose_lee.c xpose_`uname -m`.S -lm

clean:
	$(RM) benchmark harness *.o

.PHONY: all clean
