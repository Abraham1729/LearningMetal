all: shaders app

shaders: shaders/shaders.metal
	mkdir lib
	xcrun -sdk macosx metal -c $< -o lib/shaders.air
	xcrun -sdk macosx metallib lib/shaders.air -o lib/shaders.metallib

app:
	swiftc -o app src/AppDelegate.swift src/GameView.swift src/Renderer.swift src/main.swift -framework Metal -framework MetalKit

clean:
	rm -rf lib
	rm ./app