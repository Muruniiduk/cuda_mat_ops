BLOCK_SIZE = 16
SRCDIR   = src
OBJDIR   = obj
BINDIR   = bin

OBJS = main.o matrix_mul.o test.o
OBJS_LOC = $(OBJDIR)/main.o $(OBJDIR)/matrix_mul.o $(OBJDIR)/test.o

PROGRAM = test

CXX = g++
NVCC = nvcc 
CFLAGS = --compiler-options -Wall -g -O3 -lcublas -DBLOCK_SIZE=$(BLOCK_SIZE) #--ptxas-options -v

all: $(OBJS)
	$(CXX) -o $(BINDIR)/$(PROGRAM) $(OBJS_LOC) -L/usr/local/cuda/lib64 -lcudart -lcurand
        
main.o: $(SRCDIR)/main.cpp
	$(CXX) -c $< -o $(OBJDIR)/$@
#
#rnd_numbers.o: $(SRCDIR)/rnd_numbers.cu
#	$(NVCC) $(CFLAGS) -c $< -o $(OBJDIR)/$@
	
matrix_mul.o: $(SRCDIR)/matrix_mul.cu
	$(NVCC) $(CFLAGS) -c $< -o $(OBJDIR)/$@
	
test.o: $(SRCDIR)/test.cu
	$(NVCC) $(CFLAGS) -c $< -o $(OBJDIR)/$@

clean:
	rm -rf $(OBJDIR)/* $(BINDIR)/* docs/*

docs: docs/
	doxygen
