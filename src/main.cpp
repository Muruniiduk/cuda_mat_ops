#include <stdio.h>
//#include "../include/rnd_numbers.h"
#include "../include/main.h"
#include "../include/test.h"
//#include "../include/matrix_mul.h"
#include <iostream>
#include <chrono>

using namespace std;

void test(size_t n, bool verbose) {
	std::chrono::milliseconds tic = std::chrono::duration_cast<
			std::chrono::milliseconds>(
			std::chrono::system_clock::now().time_since_epoch());
	test_rnd(verbose, n);
	std::chrono::milliseconds toc = std::chrono::duration_cast<
			std::chrono::milliseconds>(
			std::chrono::system_clock::now().time_since_epoch());
	unsigned int dur = toc.count() - tic.count();
	cout << "These operations took " << dur << "ms for nXn matrix where n=" << n << endl;
}


int main() {
//	time_t tic = time(NULL);
	test(4, true);
	test(100, false);
	test(1000, false);
	test(10000, false);
	return 0;
}
