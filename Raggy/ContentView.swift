import SwiftUI

struct PermissionView: View {
    let onRequestPermission: () -> Void
    let onCheckPermission: () -> Void
    let onQuit: () -> Void

    var body: some View {
        ZStack {
            PermissionBackdrop()

            VStack(alignment: .leading, spacing: 24) {
                header
                permissionCopy
                permissionRows

                Divider()
                    .overlay(Color.white.opacity(0.16))

                actions
            }
            .padding(30)
            .frame(width: 560)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(.white.opacity(0.14), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.22), radius: 34, y: 18)
            .padding(26)
        }
        .frame(minWidth: 620, minHeight: 420)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.mint.opacity(0.28), Color.cyan.opacity(0.16)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: "keyboard.badge.ellipsis")
                    .font(.system(size: 30, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.mint)
            }
            .frame(width: 62, height: 62)

            VStack(alignment: .leading, spacing: 5) {
                Text("Raggy")
                    .font(.system(size: 30, weight: .semibold, design: .rounded))

                Text("Accessibility permission required")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusPill()
        }
    }

    private var permissionCopy: some View {
        Text("Enable Accessibility so Raggy can lock down keyboard input while the screen is in cleaning mode.")
            .font(.body)
            .foregroundStyle(.secondary)
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var permissionRows: some View {
        VStack(alignment: .leading, spacing: 14) {
            PermissionRow(icon: "switch.2", title: "Blocks function keys", detail: "Brightness, volume, and system keys stay quiet.")
            PermissionRow(icon: "macwindow.badge.plus", title: "Keeps the surface calm", detail: "Full screen mode hides interruptions while you clean.")
            PermissionRow(icon: "arrow.uturn.backward.circle", title: "Exits cleanly", detail: "Raggy removes its monitors before quitting.")
        }
    }

    private var actions: some View {
        HStack(spacing: 12) {
            Button(action: onQuit) {
                Label("Quit", systemImage: "power")
            }
            .buttonStyle(QuietButtonStyle())

            Spacer()

            Button(action: onCheckPermission) {
                Label("Check Again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(SecondaryButtonStyle())

            Button(action: onRequestPermission) {
                Label("Open Settings", systemImage: "gearshape")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}

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

private struct PermissionBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color(red: 0.05, green: 0.08, blue: 0.09)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    Color.mint.opacity(0.18),
                    Color.clear,
                    Color.cyan.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
}

private struct StatusPill: View {
    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(Color.orange)
                .frame(width: 7, height: 7)

            Text("Waiting")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.thinMaterial, in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(.white.opacity(0.14), lineWidth: 1)
        }
    }
}

private struct PermissionRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.mint)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout.weight(.semibold))

                Text(detail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
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

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(.black)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.mint)
            )
            .opacity(configuration.isPressed ? 0.76 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.thinMaterial)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(.white.opacity(0.15), lineWidth: 1)
            }
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct QuietButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .opacity(configuration.isPressed ? 0.55 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
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

#Preview("Permission") {
    PermissionView(
        onRequestPermission: {},
        onCheckPermission: {},
        onQuit: {}
    )
}
