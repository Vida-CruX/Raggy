import SwiftUI

struct PermissionWindowView: View {
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
            .frame(maxWidth: 560, alignment: .leading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(40)
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
            .foregroundStyle(.red)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .opacity(configuration.isPressed ? 0.55 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview("Permission") {
    PermissionWindowView(
        onRequestPermission: {},
        onCheckPermission: {},
        onQuit: {}
    )
}
