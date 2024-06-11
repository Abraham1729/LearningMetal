import Metal

class Adder {
    var array1: [Float]
    var array2: [Float]
    var result: [Float]

    var device: MTLDevice


    init(array1: [Float], array2: [Float]) {
        // Initialize Metal
        device = MTLCreateSystemDefaultDevice()!
        self.array1 = array1
        self.array2 = array2
        result = Array(repeating: 0, count: array1.count)
        
    }

    func Add() {
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
    }

    func Display() {
        // Print the results
        print("array1: \(array1)")
        print("array2: \(array2)")
        print("result: \(result)")
    }
}