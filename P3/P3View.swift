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

// MARK: - Main View
struct ContentView: View {
    @State private var red: Double = 1.0
    @State private var green: Double = 0.8
    @State private var blue: Double = 0.0
    @State private var isFullScreen: Bool = false
    @State private var isiOS26: Bool = false
    @State private var showList: Bool = false
    @FocusState private var isInputFocused: Bool

    private var p3Color: Color {
        Color(.displayP3, red: red, green: green, blue: blue, opacity: 1.0)
    }

    var body: some View {
        
        
//        NavigationStack {
//            ZStack {
//                p3Color
//                    .ignoresSafeArea()
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        if isInputFocused {
//                            // Dismiss active keyboard/focus first
//                            isInputFocused = false
//                        } else {
//                            // Toggle full-screen mode on tap or click
//                            withAnimation(.easeInOut(duration: 0.25)) {
//                                isFullScreen.toggle()
//                            }
//                        }
//                    }
//                
//                if !isFullScreen {
//                    
//                    VStack {
//                        Spacer()
//                        
//                        HStack(alignment: .bottom, spacing: 18) {
//                            // Native Sliders + Value Input Fields
//                            VStack(spacing: 16) {
//                                NativeColorRow(value: $red, isFocused: $isInputFocused)
//                                NativeColorRow(value: $green, isFocused: $isInputFocused)
//                                NativeColorRow(value: $blue, isFocused: $isInputFocused)
//                            }
//                        }
//                        .padding(.horizontal, 24)
//                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
//                        
//                    }
//                    .frame(maxWidth: 400, maxHeight: .infinity)
//                    
//                }
//            }
//        }
        ZStack(alignment: .topLeading) {
            Color(.displayP3, red: red, green: green, blue: blue, opacity: 1.0)
                .ignoresSafeArea()
                .onTapGesture {
                    if isInputFocused {
                        // Dismiss active keyboard/focus first
                        isInputFocused = false
                    } else {
                        // Toggle full-screen mode on tap or click
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isFullScreen.toggle()
                        }
                    }
                }
            if !isFullScreen {
                VStack(spacing: 16) {
                    Spacer()
                    NativeColorRow(value: $red, isFocused: $isInputFocused)
                    NativeColorRow(value: $green, isFocused: $isInputFocused)
                    NativeColorRow(value: $blue, isFocused: $isInputFocused)
                }
                .padding(.horizontal, 24)
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                .frame(maxWidth: 400, maxHeight: .infinity)
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isFullScreen.toggle()
                        }
                    } label: {
                        Image(systemName: isFullScreen ? "chevron.compact.down" : "chevron.compact.up")
                    }
                }
            }
        }.sheet(isPresented: $showList) {
            SavedColorsView()
            .presentationDetents([.medium, .large])
        }
        
        // iOS: Hide status bar and home indicator
        #if os(iOS)
        .statusBarHidden(true)
        .persistentSystemOverlays(isFullScreen ? .hidden : .visible)
        #endif
        // macOS: Press Esc to exit full screen
        #if os(macOS)
        .onExitCommand {
            if isFullScreen {
                withAnimation { isFullScreen = false }
            }
        }
        #endif
    }
}

struct SavedColorsView: View {
    var body: some View {
    }
}

// MARK: - Native Slider & Native TextField Row
struct NativeColorRow: View {
    
    private var clampedValue: Binding<Double> {Binding(get: { value },set: { value = min(max($0, 0.0), 1.0) })}
    
    @Binding var value: Double
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        HStack(spacing: 14) {
            // 1. Native SwiftUI Slider
            Slider(value: $value, in: 0.0...1.0)
                #if os(iOS)
                .tint(Color.white)
                #endif

            // 2. Native SwiftUI TextField (3 decimal places precision)
            TextField(
                "",
                value: clampedValue,
                format: .number.precision(.fractionLength(3))
            )
            .textFieldStyle(.plain)
            .font(.system(size: 15, weight: .semibold, design: .monospaced))
            .multilineTextAlignment(.trailing)
            .foregroundColor(.black)
            .padding(.horizontal, 10)
            .frame(width: 72, height: 36)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.45))
            )
            .focused($isFocused)
            #if os(iOS)
            .keyboardType(.decimalPad)
            #endif
        }
    }
}

#Preview {
    ContentView()
}
