#include <hip/hip_runtime.h>
#include <iostream>
#include <cstdlib>
#include <random>
#include <gem5/m5ops.h>

#ifdef GPUFS
#include <m5_mmap.h>
#endif

// Used since HIP functions are marked [[nodiscard]]
#define HIP_CHECK(command) { \
    hipError_t status = command; \
    if (status != hipSuccess) { \
        std::cerr << "HIP Error: " << hipGetErrorString(status) \
                  << " at " << __FILE__ << ":" << __LINE__ << std::endl; \
        exit(EXIT_FAILURE); \
    } \
}

// Globals
constexpr unsigned int N = 64; 
constexpr unsigned int numBlocks = 128; 
constexpr unsigned int threadsPerBlock = 128; 

constexpr float min_val = -3.0F; 
constexpr float max_val = 3.0F; 


// Kernels
__global__ void HardTanh_divergent(float *A, float min_val, float max_val) {
    unsigned int idx = blockIdx.x*threadsPerBlock*N+threadIdx.x*N;
    for (int i = 0; i < N; ++i) {
        float x = A[idx+i];
        if (x < min_val) {
            A[idx+i] = min_val;
        } else if (x > max_val) {
            A[idx+i] = max_val; 
        } else {
            A[idx+i] = x;
        }
    }
}

__global__ void Hardswish_divergent(float *A) {
    unsigned int idx = blockIdx.x*threadsPerBlock*N+threadIdx.x*N;
    for (int i = 0; i < N; ++i) {
        float x = A[idx+i]; // 1
        if (x <= -3.0F) {    // 1
            A[idx+i] = 0;   // 1/3
        } else if (x >= 3.0F) { // 2/3
            A[idx+i] = x;   // 1/3
        } else {    
            A[idx+i] = x*(x+3)/6; // 1/3*3
        }
    }
}

__global__ void ELU_divergent(float *A, float alpha) {
    unsigned int idx = blockIdx.x*threadsPerBlock*N+threadIdx.x*N;
    for (int i = 0; i < N; ++i) {
        float x = A[idx+i];
        if (x > 0.0F) {
            A[idx+i] = x;
        } else {
            A[idx+i] = alpha*(std::exp(x)-1);
        }
    }
}

int main() {
    #ifdef GPUFS
    m5op_addr = 0xFFFF0000;
    map_m5_mem();
    m5_work_begin_addr(0, 0);
    #endif
    std::mt19937 random_engine(N);
    size_t elements = numBlocks*threadsPerBlock*N;
    size_t size = elements*sizeof(float);

    auto A_host = new float[elements];
    float *A_device, *B_device, *C_device;
    HIP_CHECK(hipMalloc(&A_device, size));
    HIP_CHECK(hipMalloc(&B_device, size));
    HIP_CHECK(hipMalloc(&C_device, size));


    std::uniform_real_distribution<float> distribution(-9.0F, 9.0F);
    for(int i = 0; i < elements; ++i) {
        A_host[i] = distribution(random_engine);
    }

    HIP_CHECK(hipMemcpy(A_device, A_host, size, hipMemcpyHostToDevice));
    HIP_CHECK(hipMemcpy(B_device, A_host, size, hipMemcpyHostToDevice));
    HIP_CHECK(hipMemcpy(C_device, A_host, size, hipMemcpyHostToDevice));

    #ifdef GPUFS
    m5_reset_stats_addr(0,0);
    #else
    m5_reset_stats(0, 0);
    #endif
    
    dim3 block_dim(numBlocks, 1, 1);
    dim3 thread_dim(threadsPerBlock, 1, 1);

    HardTanh_divergent<<<block_dim, thread_dim>>>(A_device, min_val, max_val);
    HIP_CHECK(hipDeviceSynchronize());
    #ifdef GPUFS
    m5_dump_reset_stats_addr(0,0);
    #else
    m5_dump_reset_stats(0,0);
    #endif

    Hardswish_divergent<<<block_dim, thread_dim>>>(B_device);
    HIP_CHECK(hipDeviceSynchronize());
    #ifdef GPUFS
    m5_dump_reset_stats_addr(0,0);
    #else
    m5_dump_reset_stats(0,0);
    #endif

    ELU_divergent<<<block_dim, thread_dim>>>(C_device, 3.14F);
    HIP_CHECK(hipDeviceSynchronize());
    #ifdef GPUFS
    m5_dump_reset_stats_addr(0,0);
    #else
    m5_dump_reset_stats(0,0);
    #endif

    #ifdef GPUFS
    m5_work_end_addr(0, 0);
    m5_exit_addr(0);
    #else
    m5_exit(0);
    #endif
}