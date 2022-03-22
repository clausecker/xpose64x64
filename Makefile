CFLAGS=	-O3 -std=c11
RM= rm -f

all: benchmark harness

benchmark: xpose_benchmark.c xpose_lee.c xpose.S
	$(CC) $(CFLAGS) -o benchmark xpose_benchmark.c xpose_lee.c xpose.S

harness: xpose_harness.c xpose_lee.c xpose.S
	$(CC) $(CFLAGS) -o harness xpose_harness.c xpose_lee.c xpose.S

clean:
	$(RM) benchmark harness *.o

.PHONY: all clean
