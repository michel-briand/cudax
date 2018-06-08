all: cpuAdd cudaAdd simpleMPI

CFLAGS=-g
cpuAdd: cpuAdd.cpp
	g++ $(CFLAGS) $^ -o $@
cudaAdd: cudaAdd.cu
	nvcc $(CFLAGS) $^ -o $@

CFLAGS_MPI=-fPIC -I/usr/lib/x86_64-linux-gnu/openmpi/include
LDFLAGS_MPI=-pthread -L/usr/lib/x86_64-linux-gnu/openmpi/lib -lmpi_cxx -lmpi -lcuda -lcudart
simpleMPI: simpleMPI.cpp.o simpleMPI.cu.o
	g++ $(CFLAGS) $(LDFLAGS_MPI) $^ -o $@

simpleMPI.cu.o: simpleMPI.cu
	nvcc -c $(CFLAGS) -Xcompiler $(CFLAGS_MPI) $^ -o $@

simpleMPI.cpp.o: simpleMPI.cpp
	g++ -c $(CFLAGS) $(CFLAGS_MPI) $^ -o $@

clean:
	-rm -f cpuAdd cudaAdd simpleMPI simpleMPI.cpp.o simpleMPI.cu.o
