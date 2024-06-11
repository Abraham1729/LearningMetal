#include <metal_stdlib>
using namespace metal;

kernel void add_arrays(device const float* array1 [[ buffer(0) ]],
                       device const float* array2 [[ buffer(1) ]],
                       device float* result [[ buffer(2) ]],
                       uint id [[ thread_position_in_grid ]]) {
    result[id] = array1[id] + array2[id];
}
