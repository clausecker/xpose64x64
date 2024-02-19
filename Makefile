CFLAGS=	-O3 -std=c11
RM= rm -f
ARCH!= uname -m

all: benchmark harness

benchmark: xpose_benchmark.c xpose_lee.c xpose_$(ARCH).S
	$(CC) $(CFLAGS) -o benchmark xpose_benchmark.c xpose_lee.c xpose_$(ARCH).S -lm

harness: xpose_harness.c xpose_lee.c xpose_$(ARCH).S
	$(CC) $(CFLAGS) -o harness xpose_harness.c xpose_lee.c xpose_$(ARCH).S -lm

clean:
	$(RM) benchmark harness *.o

.PHONY: all clean
