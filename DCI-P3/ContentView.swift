import SwiftUI

// MARK: - App Entry Point
@main
struct DisplayP3PreviewApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}

// MARK: - Main Content View
struct ContentView: View {
    // Initial color matching the mockup: R=1.0, G=0.8, B=0.0
    @State private var red: Double = 1.0
    @State private var green: Double = 0.8
    @State private var blue: Double = 0.0
    
    // Toggle for hiding controls / 100% full screen
    @State private var isFullScreen: Bool = false

    // Display P3 Color instance
    private var p3Color: Color {
        Color(.displayP3, red: red, green: green, blue: blue, opacity: 1.0)
    }

    var body: some View {
        ZStack {
            // Full-screen Display P3 background
            p3Color
                .ignoresSafeArea()
                // Click or tap anywhere on screen to exit (or toggle) full-screen mode
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isFullScreen.toggle()
                    }
                }

            // Controls overlay
            if !isFullScreen {
                VStack {
                    Spacer()

                    HStack(alignment: .bottom, spacing: 20) {
                        // Slider Stack (Red, Green, Blue)
                        VStack(spacing: 20) {
                            ColorSliderRow(value: $red)
                            ColorSliderRow(value: $green)
                            ColorSliderRow(value: $blue)
                        }

                        // Full-screen / Hide Controls Button (Mockup eye.slash icon)
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isFullScreen = true
                            }
                        }) {
                            Image(systemName: "eye.slash.fill")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.black.opacity(0.85))
                                .padding(12)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Enter Full Screen")
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
            }
        }
        // iOS: Hide status bar
        #if os(iOS)
        .statusBarHidden(true)
        .persistentSystemOverlays(isFullScreen ? .hidden : .visible)
        #endif
        // macOS: Support toggling with Space or Escape
        #if os(macOS)
        .onExitCommand {
            if isFullScreen {
                withAnimation { isFullScreen = false }
            }
        }
        #endif
    }
}

// MARK: - Custom Slider & Pill Row
struct ColorSliderRow: View {
    @Binding var value: Double
    
    private let trackHeight: CGFloat = 14
    private let thumbDiameter: CGFloat = 26

    var body: some View {
        HStack(spacing: 14) {
            // Custom Track & Knob Slider
            GeometryReader { geometry in
                let availableWidth = geometry.size.width - thumbDiameter
                let dragOffset = CGFloat(value) * availableWidth

                ZStack(alignment: .leading) {
                    // Gray Track
                    Capsule()
                        .fill(Color(white: 0.47))
                        .frame(height: trackHeight)

                    // White Circular Thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: thumbDiameter, height: thumbDiameter)
                        .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 1)
                        .offset(x: dragOffset)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    let clampedX = min(max(0, gesture.location.x - thumbDiameter / 2), availableWidth)
                                    value = Double(clampedX / availableWidth)
                                }
                        )
                }
                .frame(maxHeight: .infinity)
            }
            .frame(height: thumbDiameter)

            // Value Display Pill (no text field, pure display badge)
            Text(String(format: "%.1f", value))
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(.black)
                .frame(width: 72, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.45))
                )
        }
    }
}
