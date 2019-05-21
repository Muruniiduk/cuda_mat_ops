/* Basic Matrix Multiplication */
#include <stdio.h>
//#include "../include/rnd_numbers.h"
#include "../include/matrix_mul.h"
#include <cuda.h>
#include <curand.h>
#include <curand_kernel.h>

//See meetod on kopeeritud: https://github.com/slitvinov/cuda-examples/tree/master/day1/matmul
//Kasutab memory sharemist.
__global__ void matmul(const float* const a, const float* const b, const int n,
		float* const c) {
	// Base indexes inside A and B
	const int ia = (blockDim.y * blockIdx.y) * n;
	const int ib = blockDim.x * blockIdx.x;

	// Subindex inside a "tile"
	const int tileidx = n * threadIdx.y + threadIdx.x;

	// Index in C
	const int ic = ia + ib + tileidx;

	float sum = 0.0f;
	int aoff = 0, boff = 0;

	// Shared memory for the "tile" sub-matrix of A and B
	__shared__ float as[BLOCK_SIZE][BLOCK_SIZE];
	__shared__ float bs[BLOCK_SIZE][BLOCK_SIZE];

	// Go through "tiles" of size blockDim.x * blockDim.y
	for (; aoff < n; aoff += blockDim.x, boff += blockDim.y * n) {
		// Load the "tile" matrices from global memory to shared memory
		as[threadIdx.y][threadIdx.x] = a[ia + aoff + tileidx];
		bs[threadIdx.y][threadIdx.x] = b[ib + boff + tileidx];

		// Synchronize to make sure the matrices are loaded
		__syncthreads();

		// Multiply the two matrices
		for (int k = 0; k < BLOCK_SIZE; k++)
			sum += as[threadIdx.y][k] * bs[k][threadIdx.x];

		// Synchronize to make sure that the preceding
		// computation is done before loading two new
		// sub-matrices of A and B in the next iteration
		__syncthreads();
	}

	// Write the block sub-matrix to global memory
	// each thread writes one element
	c[ic] = sum;
}

__global__ void sum(const float* const a, const float* const b, const int n,
		float* const c) {
	int tid = blockDim.x * blockIdx.x + threadIdx.x;
	int n2 = n*n;
	// perform tid-th elements addition
	if (tid <  n2)
		c[tid] = a[tid] + b[tid];
}

void printMat(size_t n, float *data) {
	size_t i, j;
	printf("Matrix: \n");
	for (i = 0; i < n; i++) {
		for (j = 0; j < n; j++) {
			printf("	%1.3f", data[i + n * j]);
		}
		printf("\n");
	}
}

void transpose(size_t n, float *data, float *newData) {
	size_t i, j;
//	size_t n2 = n * n;

	for (i = 0; i < n; i++) {
		for (j = 0; j < n; j++) {
			newData[j * n + i] = data[i * n + j];
		}
	}
}

void random_matrix(size_t n, float *hostData) {
	size_t n2 = n * n;
	curandGenerator_t gen;
	float *a;
	cudaMalloc((void **) &a, n2 * sizeof(float));

	curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_MTGP32);
	curandSetPseudoRandomGeneratorSeed(gen, 0);
	curandGenerateNormal(gen, a, n2, 0, 1);

	cudaMemcpy(hostData, a, n2 * sizeof(float), cudaMemcpyDeviceToHost);
//	printMat(n, hostData);
	curandDestroyGenerator(gen);
	cudaFree(a);
}

void test_matmul(const float* const b, const float* const a, const int n,
		float* const c) {

	size_t n2 = n * n;
	float *da, *db, *dc;

	cudaMalloc((void **) &da, n2 * sizeof(float));
	cudaMalloc((void **) &db, n2 * sizeof(float));
	cudaMalloc((void **) &dc, n2 * sizeof(float));
	cudaMemcpy(da, (void **) a, n2 * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(db, (void **) b, n2 * sizeof(float), cudaMemcpyHostToDevice);

//	cudaMemcpy((void **) a, da, n2 * sizeof(float), cudaMemcpyHostToDevice);
//	cudaMemcpy((void **) b, db, n2 * sizeof(float), cudaMemcpyHostToDevice);
//	int threadsPerBlock, blocksPerGrid;
//	if (n2 < 512) {
//		threadsPerBlock = n2;
//		blocksPerGrid = 1;
//	} else {
//		threadsPerBlock = 512;
//		blocksPerGrid = ceil(double(n2) / double(threadsPerBlock));
//	}
//	matmul<<<blocksPerGrid, threadsPerBlock>>>(da, db, n, dc);


	matmul<<<1028, 1>>>(da, db, n, dc);
	cudaDeviceSynchronize();
	cudaMemcpy(c, dc, n2 * sizeof(float), cudaMemcpyDeviceToHost);
}

void test_sum(const float* const b, const float* const a, const int n,
		float* const c) {

	size_t n2 = n * n;
	float *da, *db, *dc;

	cudaMalloc((void **) &da, n2 * sizeof(float));
	cudaMalloc((void **) &db, n2 * sizeof(float));
	cudaMalloc((void **) &dc, n2 * sizeof(float));
	cudaMemcpy(da, (void **) a, n2 * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(db, (void **) b, n2 * sizeof(float), cudaMemcpyHostToDevice);

	int threadsPerBlock, blocksPerGrid;

	// use 1 to 512 threads per block
	if (n2 < 512) {
		threadsPerBlock = n2;
		blocksPerGrid = 1;
	} else {
		threadsPerBlock = 512;
		blocksPerGrid = ceil(double(n2) / double(threadsPerBlock));
	}

//	sum<<<32, 1>>>(da, db, n, dc);
	sum<<<blocksPerGrid, threadsPerBlock>>>(da, db, n, dc);
	cudaDeviceSynchronize();
	cudaMemcpy(c, dc, n2 * sizeof(float), cudaMemcpyDeviceToHost);
}

void my_mat_mul() {
	size_t n = 3;
	size_t n2 = 9;
	curandGenerator_t gen;
	float *a, *b, *c, *hostData;
	float *hostA, *hostB;

	hostData = (float *) calloc(n2, sizeof(float));

	hostA = (float *) calloc(n2, sizeof(float));
	hostB = (float *) calloc(n2, sizeof(float));

	cudaMalloc((void **) &a, n2 * sizeof(float));
	cudaMalloc((void **) &b, n2 * sizeof(float));
	cudaMalloc((void **) &c, n2 * sizeof(float));
	printf("Allocated memory in GPU\n");

	curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_MTGP32);

	curandSetPseudoRandomGeneratorSeed(gen, 0);

	curandGenerateNormal(gen, a, n2, 0, 1);
	curandGenerateNormal(gen, b, n2, 0, 1);
	printf("Random 3x3 matrices created\n");

	cudaMemcpy(hostA, a, n2 * sizeof(float), cudaMemcpyDeviceToHost);
	cudaMemcpy(hostB, b, n2 * sizeof(float), cudaMemcpyDeviceToHost);

	printf("A ");
	printMat(n, hostA);
	printf("B ");
	printMat(n, hostB);

	matmul<<<32, 1>>>(a, b, n, c);
	cudaDeviceSynchronize();

	cudaMemcpy(hostData, c, n2 * sizeof(float), cudaMemcpyDeviceToHost);

	printf("RESULT ");
	printMat(n, hostData);

	float* newData;
	newData = (float *) calloc(n2, sizeof(float));
	transpose(n, hostData, newData);
	printf("TRANSPOSE ");
	printMat(n, newData);

	curandDestroyGenerator(gen);
	cudaFree(a);
	cudaFree(b);
	cudaFree(c);
	free(hostData);
	free(hostA);
	free(hostB);
}
