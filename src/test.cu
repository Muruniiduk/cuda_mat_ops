#include <stdio.h>
//#include "../include/rnd_numbers.h"
#include "../include/test.h"
#include "../include/matrix_mul.h"
#include <cuda.h>
#include <curand.h>
#include <curand_kernel.h>

void test_rnd(bool verbose, size_t n) {
	size_t n2 = n*n;
	float *a, *b, *c;

	a = (float *) calloc(n2, sizeof(float));
	b = (float *) calloc(n2, sizeof(float));
	c = (float *) calloc(n2, sizeof(float));

	if (verbose) printf("Random ");
	random_matrix(n, a);
	if (verbose) printMat(n, a);

	if (verbose) printf("\nTransposed ");
	transpose(n, a, b);
	if (verbose) printMat(n, b);

	if (verbose) printf("\nFirst 2 Multiplied ");
	test_matmul(a,b,n,c);
	if (verbose) printMat(n, c);

	if (verbose) printf("\nFirst 2 Summed ");
	test_sum(a,b,n,c);
	if (verbose) printMat(n, c);
}
