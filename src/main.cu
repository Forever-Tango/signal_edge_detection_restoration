
#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <cuda_runtime.h>
#include "signal_utils.h"

#define BLOCK_SIZE 256

// CUDA kernel for edge detection (using gradient method)
__global__ void edgeDetection(const float* inputSignal, float* outputSignal, int length) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    if (idx > 0 && idx < length - 1) {
        // Compute gradient (difference between adjacent samples)
        outputSignal[idx] = fabs(inputSignal[idx + 1] - inputSignal[idx - 1]);
    }
}

void processSignal(const std::string& inputPath, const std::string& edgeOutputPath, const std::string& restoredOutputPath) {
    std::vector<float> signal = loadSignal(inputPath);
    int length = signal.size();

    // Allocate memory for device input and output signals
    float* d_input;
    float* d_output;

    cudaMalloc(&d_input, length * sizeof(float));
    cudaMalloc(&d_output, length * sizeof(float));

    // Copy the signal to the device
    cudaMemcpy(d_input, signal.data(), length * sizeof(float), cudaMemcpyHostToDevice);

    // Set up grid and block size for CUDA kernel
    int gridSize = (length + BLOCK_SIZE - 1) / BLOCK_SIZE;

    // Run the edge detection kernel
    edgeDetection<<<gridSize, BLOCK_SIZE>>>(d_input, d_output, length);
    cudaDeviceSynchronize();

    // Copy the result back to host
    std::vector<float> edgeSignal(length);
    cudaMemcpy(edgeSignal.data(), d_output, length * sizeof(float), cudaMemcpyDeviceToHost);

    // Save the edge-detected signal
    saveSignal(edgeSignal, edgeOutputPath);

    // Restore the signal by simple moving average (smoothing)
    std::vector<float> restoredSignal = restoreSignal(edgeSignal);

    // Save the restored signal
    saveSignal(restoredSignal, restoredOutputPath);

    // Clean up
    cudaFree(d_input);
    cudaFree(d_output);
}

int main() {
    processSignal("data/noisy_signal.csv", "output/edge_detected_signal.csv", "output/restored_signal.csv");
    std::cout << "Processing completed.\n";
    return 0;
}
