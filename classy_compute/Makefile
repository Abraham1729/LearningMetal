all: shaders app

shaders: src/ComputeShader.metal
	mkdir lib
	xcrun -sdk macosx metal -c $< -o lib/ComputeShader.air
	xcrun -sdk macosx metallib lib/ComputeShader.air -o lib/ComputeShader.metallib

app:
	swiftc -o app src/main.swift src/Adder.swift -framework Metal -framework MetalKit

clean:
	rm -rf lib
	rm ./app