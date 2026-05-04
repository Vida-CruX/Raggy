import SwiftUI

struct PermissionView: View {
    let onRequestPermission: () -> Void
    let onCheckPermission: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: "keyboard")
                .font(.system(size: 48))
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: 8) {
                Text("Accessibility Permission Required")
                    .font(.title2.weight(.semibold))

                Text("Raggy needs Accessibility permission before cleaning mode so it can block brightness, volume, and other function keys.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 12) {
                Button("Quit Raggy", action: onQuit)

                Spacer()

                Button("Check Again", action: onCheckPermission)

                Button("Open Settings", action: onRequestPermission)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(32)
        .frame(width: 520)
    }
}

struct CleaningView: View {
    let onExit: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black
                .ignoresSafeArea()

            Button("Exit Raggy", action: onExit)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(24)
                .accessibilityIdentifier("exitButton")
        }
    }
}

#Preview {
    CleaningView {}
}
