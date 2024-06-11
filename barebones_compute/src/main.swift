import Metal

// Arrays to add
let array1: [Float] = [1, 2, 3, 4, 5]
let array2: [Float] = [6, 7, 8, 9, 10]
var result: [Float] = Array(repeating: 0, count: array1.count)

// Initialize Metal
guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("Metal is not supported on this device")
}

let commandQueue = device.makeCommandQueue()!

// Load and compile the compute shader
let libraryURL = URL(fileURLWithPath: "./lib").appendingPathComponent("ComputeShader.metallib")
let library = try! device.makeLibrary(URL: libraryURL)
let function = library.makeFunction(name: "add_arrays")!
let pipelineState = try! device.makeComputePipelineState(function: function)

// Create buffers
let array1Buffer = device.makeBuffer(bytes: array1, length: array1.count * MemoryLayout<Float>.size, options: [])
let array2Buffer = device.makeBuffer(bytes: array2, length: array2.count * MemoryLayout<Float>.size, options: [])
let resultBuffer = device.makeBuffer(bytes: result, length: result.count * MemoryLayout<Float>.size, options: [])

// Create a command buffer and compute command encoder
let commandBuffer = commandQueue.makeCommandBuffer()!
let computeEncoder = commandBuffer.makeComputeCommandEncoder()!
computeEncoder.setComputePipelineState(pipelineState)

// Set buffers for the compute shader
computeEncoder.setBuffer(array1Buffer, offset: 0, index: 0)
computeEncoder.setBuffer(array2Buffer, offset: 0, index: 1)
computeEncoder.setBuffer(resultBuffer, offset: 0, index: 2)

// Dispatch compute commands
let threadGroupSize = MTLSize(width: 1, height: 1, depth: 1)
let threadGroups = MTLSize(width: array1.count, height: 1, depth: 1)
computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)

// End encoding and commit the command buffer
computeEncoder.endEncoding()
commandBuffer.commit()
commandBuffer.waitUntilCompleted()

// Retrieve results
let resultPointer = resultBuffer!.contents().bindMemory(to: Float.self, capacity: result.count)
for i in 0..<result.count {
    result[i] = resultPointer[i]
}

// Print the results
print("array1: \(array1)")
print("array2: \(array2)")
print("result: \(result)")
