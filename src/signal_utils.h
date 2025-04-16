
#ifndef SIGNAL_UTILS_H
#define SIGNAL_UTILS_H

#include <iostream>
#include <fstream>
#include <vector>

// Load signal data from CSV file
std::vector<float> loadSignal(const std::string& path) {
    std::ifstream file(path);
    std::vector<float> signal;
    float value;
    while (file >> value) {
        signal.push_back(value);
    }
    return signal;
}

// Save signal data to CSV file
void saveSignal(const std::vector<float>& signal, const std::string& path) {
    std::ofstream file(path);
    for (float value : signal) {
        file << value << ",";
    }
    file.close();
}

// Simple restoration by smoothing (moving average)
std::vector<float> restoreSignal(const std::vector<float>& signal) {
    std::vector<float> restored(signal.size());
    for (size_t i = 1; i < signal.size() - 1; ++i) {
        restored[i] = (signal[i - 1] + signal[i] + signal[i + 1]) / 3.0f;
    }
    restored[0] = signal[0];  // First value stays the same
    restored[signal.size() - 1] = signal[signal.size() - 1];  // Last value stays the same
    return restored;
}

#endif // SIGNAL_UTILS_H
