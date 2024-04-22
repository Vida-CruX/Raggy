

import SwiftUI

struct ContentView: View {
	var body: some View {
		//将背景设为黑色
		Color.black.ignoresSafeArea(edges: .all)
			.overlay(Button("Exit Raggy"){
				NSApplication.shared.terminate(self)
			}
				.padding())
		
    }
}

#Preview {
    ContentView()
}
