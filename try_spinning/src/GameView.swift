import MetalKit
import Foundation

// TODO: Create "game" functionality which is managed by another class.
// I don't want to be stuck doing game management via View class. That divide doesn't make sense.

struct Vertex{
    var position: SIMD4<Float>
    var uv: SIMD2<Float>
}

class GameView: MTKView {
    var texture: MTLTexture!
    var vertices: [Vertex]!
    var renderer: Renderer!

    // Update Function
    var timer: Timer?
    let cosTheta: Float = cos(2 * .pi / 180)
    let sinTheta: Float = sin(4 * .pi / 180)

    func LoadTexture(filename: String, directory: String) {
        let textureLoader = MTKTextureLoader(device: device!)
        let fileURL = URL(fileURLWithPath: directory).appendingPathComponent(filename)
        do {
            texture = try textureLoader.newTexture(URL: fileURL, options: nil)
        } catch {
            print("Error loading texture: \(error)")
        }
    }

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

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame frameRect: NSRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        
        let device = device!
        
        LoadTexture(filename: "star.png", directory: "./images")
        
        CreateVerts()

        self.renderer = Renderer(device: device, vertexData: vertices, texture: texture)

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
        let bufferPointer = renderer.vertexBuffer.contents()
        let vertexPointer = bufferPointer.assumingMemoryBound(to: Vertex.self)
        for i in 0...(5) {
            vertexPointer[i].position = rotateVert(x: vertexPointer[i].position[0], y: vertexPointer[i].position[1])
        }    
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let drawable = self.currentDrawable,
              let descriptor = self.currentRenderPassDescriptor else { return }        
        self.renderer.render(drawable: drawable, currentRenderPassDescriptor: descriptor, vertices: vertices)
    }
}
