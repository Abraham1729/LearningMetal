import Metal
import MetalKit

class Renderer {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState
    var vertexBuffer: MTLBuffer
    var texture: MTLTexture
    var samplerDescriptor: MTLSamplerDescriptor!
    var samplerState: MTLSamplerState!

    init(device: MTLDevice, vertexData: [Vertex], texture: MTLTexture) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!

        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float4 // Position attribute
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float2 // UV attribute
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        vertexDescriptor.layouts[0].stepFunction = .perVertex

        let vertexBufferSize = vertexData.count * MemoryLayout<Vertex>.stride
        self.vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexBufferSize, options: [])!

        let libraryURL = URL(fileURLWithPath: "./lib").appendingPathComponent("shaders.metallib")
        let library = try! self.device.makeLibrary(URL: libraryURL)
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "fragment_main")

        self.texture = texture

        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .nearest // ./linear?
        samplerDescriptor.magFilter = .nearest // ./linear?
        samplerState = device.makeSamplerState(descriptor: samplerDescriptor)

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        self.pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }

    // func updateVertexBuffer() {
    //     let bufferPointer = vertexBuffer.contents()
    //     let vertexPointer = bufferPointer.assumingMemoryBound(to: Vertex.self)
    //     for i in 0...(5) {
    //         vertexPointer[i].position = rotateVert(x: vertexPointer[i].position[0], y: vertexPointer[i].position[1])
    //     }        
    // }

    func render(drawable: CAMetalDrawable, currentRenderPassDescriptor: MTLRenderPassDescriptor, vertices: [Vertex]) {
        let commandBuffer = commandQueue.makeCommandBuffer()!
        // let renderPassDescriptor = currentRenderPassDescriptor

        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentTexture(texture, index: 0)
        renderEncoder.setFragmentSamplerState(samplerState, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
        // commandBuffer.waitUntilCompleted()
    }
}