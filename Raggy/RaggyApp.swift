

import SwiftUI

@main
struct RaggyApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
			//在启动时进入全屏
			//i have no fucking idea what i'm doing
				.onAppear() {
					Task { @MainActor in NSApplication.shared.windows.last?.toggleFullScreen(nil) }
						}
					}
				}
		}
