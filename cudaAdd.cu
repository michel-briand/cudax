#include <iostream>
#include <math.h>

using std::cout;;
using std::cerr;
using std::endl;

// Shut down MPI cleanly if something goes wrong
void my_abort(int err)
{
    cout << "Test FAILED\n";
}

// Error handling macro
#define CUDA_CHECK(call) \
    if((call) != cudaSuccess) { \
        cudaError_t err = cudaGetLastError(); \
        cerr << "CUDA error calling \""#call"\", code is " << err << endl; \
        my_abort(err); }

// Kernel function to add the elements of two arrays
__global__
void add(int n, float *x, float *y)
{
  for (int i = 0; i < n; i++)
    y[i] = x[i] + y[i];
}

int main(void)
{
  int N = 1000;
  float *h_x = NULL;
  float *d_x = NULL;
  float *h_y = NULL;
  float *d_y = NULL;

  // allocate memory for arrays on the host
  h_x = (float *) malloc(N*sizeof(float));
  if (!h_x)
	  cerr << "can't allocate memory h_x" << endl;
  h_y = (float *) malloc(N*sizeof(float));
  if (!h_y)
	  cerr << "can't allocate memory h_y" << endl;

  // allocate memory for arrays on the device
  CUDA_CHECK(cudaMalloc((void **)&d_x, N*sizeof(float)));
  if (!d_x)
	  cerr << "can't allocate memory d_x" << endl;

  CUDA_CHECK(cudaMalloc((void **)&d_y, N*sizeof(float)));
  if (!d_y)
	  cerr << "can't allocate memory d_y" << endl;

  // initialize x and y arrays on the host
  for (int i = 0; i < N; i++) {
    h_x[i] = 1.0f;
    h_y[i] = 2.0f;
  }

  // copy arrays to device
  CUDA_CHECK(cudaMemcpy(d_x, h_x, N*sizeof(float),
                             cudaMemcpyHostToDevice));
  CUDA_CHECK(cudaMemcpy(d_y, h_y, N*sizeof(float),
                             cudaMemcpyHostToDevice));

  // Run kernel on the GPU
  add<<<1, 1>>>(N, d_x, d_y);

  // Wait for GPU to finish before accessing on host
  cudaDeviceSynchronize();

  // copy array to the host
  CUDA_CHECK(cudaMemcpy(h_y, d_y, N*sizeof(float),
                        cudaMemcpyDeviceToHost));

  // Check for errors (all values should be 3.0f)
  float maxError = 0.0f;

  for (int i = 0; i < N; i++)
    maxError = fmax(maxError, fabs(h_y[i]-3.0f));

  cout << "Max error: " << maxError << std::endl;

  // Free memory
  free(h_x);
  free(h_y);
  cudaFree(d_x);
  cudaFree(d_y);

  return 0;
}
