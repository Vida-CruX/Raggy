import SwiftUI

struct CleaningView: View {
    let onExit: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black
                .ignoresSafeArea()

            BloomCleaningAnimation()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 8) {
                Text("Raggy")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))

                Text("Cleaning mode")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.48))
            }
            .foregroundStyle(.white.opacity(0.82))
            .padding(28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .allowsHitTesting(false)

            Button(action: onExit) {
                Label("Exit Raggy", systemImage: "xmark")
            }
            .buttonStyle(ExitButtonStyle())
            .padding(24)
            .accessibilityIdentifier("exitButton")
        }
    }
}

private struct BloomCleaningAnimation: View {
    @State private var isBlooming = false

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let bloomSize = min(max(width, height) * 0.42, 620)

            ZStack {
                sweepLine(in: proxy.size)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.20),
                                Color.mint.opacity(0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 1,
                            endRadius: bloomSize * 0.5
                        )
                    )
                    .frame(width: bloomSize, height: bloomSize)
                    .blur(radius: 34)
                    .scaleEffect(isBlooming ? 1.12 : 0.74)
                    .opacity(isBlooming ? 0.32 : 0.12)
                    .position(
                        x: isBlooming ? width * 0.72 : width * 0.28,
                        y: isBlooming ? height * 0.34 : height * 0.68
                    )
                    .blendMode(.screen)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 5.6).repeatForever(autoreverses: true)) {
                    isBlooming = true
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func sweepLine(in size: CGSize) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.08),
                        Color.mint.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: max(size.width, size.height) * 1.4, height: 2)
            .blur(radius: 5)
            .rotationEffect(.degrees(-23))
            .offset(x: isBlooming ? size.width * 0.18 : -size.width * 0.18)
            .opacity(isBlooming ? 1 : 0.35)
            .blendMode(.screen)
    }
}

private struct ExitButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.20 : 0.13))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(.white.opacity(0.18), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview("Cleaning") {
    CleaningView {}
}
