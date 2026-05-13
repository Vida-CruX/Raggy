import SwiftUI

enum PermissionWindowMetrics {
    static let panelWidth: CGFloat = 560
    static let panelHeight: CGFloat = 412
    static let contentSize = CGSize(width: panelWidth, height: panelHeight)
}

struct PermissionView: View {
    let onRequestPermission: () -> Void
    let onCheckPermission: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
            permissionCopy
            permissionRows

            Divider()
                .overlay(Color.white.opacity(0.16))

            actions
        }
        .padding(30)
        .frame(width: PermissionWindowMetrics.panelWidth, height: PermissionWindowMetrics.panelHeight)
        .background(PermissionPanelBackground())
        .fixedSize()
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

private struct PermissionPanelBackground: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.regularMaterial)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.mint.opacity(0.11),
                            Color(nsColor: .windowBackgroundColor).opacity(0.70),
                            Color.cyan.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

struct CleaningView: View {
    private static let cleaningTips = [
        "Use a soft, lint-free cloth lightly dampened with water for the exterior.",
        "Keep moisture away from ports, vents, keyboard gaps, and other openings.",
        "Clean the screen with water only on a soft, lint-free cloth.",
        "Never spray liquid directly onto your Mac.",
        "Skip aerosol sprays, solvents, abrasives, bleach, and hydrogen peroxide cleaners.",
        "For stubborn smudges, gently wipe with a cloth moistened with 70% isopropyl alcohol.",
        "Clean Touch Bar and Touch ID surfaces like the display: shut down, unplug, then use a water-dampened lint-free cloth.",
        "For nano-texture displays, use the Apple polishing cloth instead of a regular cloth.",
        "If the nano-texture cloth gets dirty, hand-wash it with dish soap and water, then air-dry it for 24 hours."
    ]

    let onExit: () -> Void
    @State private var cleaningTip: String

    init(onExit: @escaping () -> Void) {
        self.onExit = onExit
        _cleaningTip = State(initialValue: Self.cleaningTips.randomElement() ?? Self.cleaningTips[0])
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            centeredActions
        }
    }

    private var centeredActions: some View {
        VStack(spacing: 16) {
//			AnimatedBroomIcon()
//				.accessibilityHidden(true)
            Button(action: onExit) {
                Label("Exit Raggy", systemImage: "xmark")
            }
            .buttonStyle(ExitButtonStyle())
            .accessibilityIdentifier("exitButton")

            VStack(spacing: 8) {
                

                Text(cleaningTip)
                    .font(.caption2.weight(.medium))
                    .lineSpacing(2)
                    .foregroundStyle(.white.opacity(0.58))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 340)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Cleaning tip: \(cleaningTip)")
            }
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

private struct AnimatedBroomIcon: View {
    @State private var isSweeping = false

    var body: some View {
        ZStack {
            broom
                .rotationEffect(.degrees(isSweeping ? -10 : 10), anchor: .bottom)
                .offset(x: isSweeping ? -5 : 5, y: isSweeping ? 1 : -1)

            sparkle
                .offset(x: isSweeping ? 16 : -16, y: 16)
                .opacity(isSweeping ? 0.82 : 0.34)
                .scaleEffect(isSweeping ? 1 : 0.72)
        }
        .frame(width: 58, height: 58)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true)) {
                isSweeping = true
            }
        }
    }

    private var broom: some View {
        ZStack {
            Capsule()
                .fill(Color.white.opacity(0.78))
                .frame(width: 5, height: 42)
                .offset(y: -8)

            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color.mint.opacity(0.72))
                .frame(width: 24, height: 18)
                .offset(y: 15)

            HStack(spacing: 3) {
                ForEach(0..<4) { _ in
                    Capsule()
                        .fill(Color.white.opacity(0.50))
                        .frame(width: 2, height: 12)
                }
            }
            .offset(y: 21)
        }
        .rotationEffect(.degrees(-32))
    }

    private var sparkle: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.mint.opacity(0.80))
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
