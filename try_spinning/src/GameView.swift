import MetalKit
import Foundation

class GameView: MTKView {
    // Texture & Sampler Properties //
    var textureDescriptor: MTLTextureDescriptor!
    var texture: MTLTexture!
    var samplerDescriptor: MTLSamplerDescriptor!
    var samplerState: MTLSamplerState!

    // Vertex Properties //
    var vertices: [Vertex]!
    var vertexBuffer: MTLBuffer!
    var vertexDescriptor: MTLVertexDescriptor!

    // Library
    var library: MTLLibrary!
    var vertexFunction: MTLFunction?
    var fragmentFunction: MTLFunction?

    // Rendering Pipeline
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var pipelineDescriptor: MTLRenderPipelineDescriptor!

    // Update Function
    var timer: Timer?
    let cosTheta: Float = cos(20 * .pi / 180)
    let sinTheta: Float = sin(20 * .pi / 180)

    struct Vertex{
        var position: SIMD4<Float>
        var uv: SIMD2<Float>
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    //// Vert setup functions ////
    func CreateVerts() {
        vertices =
        [
            // Upper left tri
            Vertex(position: SIMD4<Float>(-1, -1, 0, 1),    uv: SIMD2<Float>(0, 0)),
            Vertex(position: SIMD4<Float>(-1,  1, 0, 1),    uv: SIMD2<Float>(0, 1)),
            Vertex(position: SIMD4<Float>( 1, 1, 0, 1),    uv: SIMD2<Float>(1, 1)),
            
            // Lower right tri
            Vertex(position: SIMD4<Float>( 1,  1, 0, 1),    uv: SIMD2<Float>(1, 1)),
            Vertex(position: SIMD4<Float>( 1, -1, 0, 1),    uv: SIMD2<Float>(1, 0)),
            Vertex(position: SIMD4<Float>(-1, -1, 0, 1),    uv: SIMD2<Float>(0, 0)),
        ]
    }

    func CreateVertBuffer(){
        vertexBuffer = device?.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: [])
    }

    func CreateVertDescriptor() {
        vertexDescriptor = MTLVertexDescriptor()

        // Position attribute
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        // UV attribute
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0

        // Layout of the buffer
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        vertexDescriptor.layouts[0].stepFunction = .perVertex
    }

    //// Texture & Sampler ////

    func LoadTexture(filename: String, directory: String) {
        let textureLoader = MTKTextureLoader(device: device!)
        let fileURL = URL(fileURLWithPath: directory).appendingPathComponent(filename)
        do {
            texture = try textureLoader.newTexture(URL: fileURL, options: nil)
        } catch {
            print("Error loading texture: \(error)")
        }
    }

    func CreateSampler() {
        samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .nearest // ./linear?
        samplerDescriptor.magFilter = .nearest // ./linear?
        samplerState = device?.makeSamplerState(descriptor: samplerDescriptor)
    }
    
    //// Library: Shader Functions ////
    func GetLibrary(directory: String, filename: String) {
        let shaderURL = URL(fileURLWithPath: directory).appendingPathComponent(filename)
        library = try! self.device?.makeLibrary(URL: shaderURL)
        vertexFunction = library.makeFunction(name: "vertex_main")
        fragmentFunction = library.makeFunction(name: "fragment_main")
    }

    override init(frame frameRect: NSRect, device: MTLDevice?)
    {
        super.init(frame: frameRect, device: device)
        let device = device!

        // Get VertexFunction and Fragment Function
        GetLibrary(
            directory: "./lib",
            filename: "shaders.metallib"
        )

        // Load a texture & get a sampler
        LoadTexture(
            // filename: "niceTexture.png", 
            filename: "fossil.jpeg", 
            directory: "/Users/abe/Documents/GitHub/LearningSwift/Wave"
        )
        CreateSampler()

        // Create & manage vertices to display texture
        CreateVerts()      
        CreateVertBuffer()  
        CreateVertDescriptor()
        
        // Rendering Pipeline core pieces...
        commandQueue = device.makeCommandQueue()
        pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        // Once the Pipeline Descriptor is set up, we should be good to make the pipeline state.
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        // We want action, something to really animate the experience
        self.timer = Timer.scheduledTimer(
            timeInterval: 1 / 60, 
            target: self, 
            selector: #selector(updateVertices), 
            userInfo: nil, 
            repeats: true
        )
    }
    
    func rotateVert(x: Float, y: Float) -> SIMD4<Float> {
        return SIMD4<Float>((cosTheta * x) - (sinTheta * y), (sinTheta * x) + (cosTheta * y), 0, 1)
    }

    @objc func updateVertices() {
        // oooh baby let's spin
        for i in 0...(vertices.count-1) {
            vertices[i].position = rotateVert(x: vertices[i].position[0], y: vertices[i].position[1])
        }
        // Don't forget to update the buffer (should I be using UpdateVertBuffer() rather than re-creating? Probably.)
        CreateVertBuffer()
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let drawable = self.currentDrawable,
              let descriptor = self.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }
        
        renderEncoder.setRenderPipelineState(pipelineState)

        // Passing to vert shader
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        // Passing to fragemnt shader
        renderEncoder.setFragmentTexture(texture, index: 0)
        renderEncoder.setFragmentSamplerState(samplerState, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count) // maybe could do .trianglestrip if i was smart about rotations
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
