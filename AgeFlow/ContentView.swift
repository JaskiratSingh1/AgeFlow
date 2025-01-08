import SwiftUI

struct ContentView: View {
    @State private var userAge: Double = 0.0
    @State private var isShowingSplash: Bool = false
    @State private var birthDate: Date? = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1)) // Default to 1/1/2000
    @State private var timer: Timer? = nil // Track the active timer
    
    // State to control showing settings
    @State private var isShowingSettings = false
    
    // Tracks Dark/Light Mode setting from UserDefaults
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    // Detect the current color scheme
    @Environment(\.colorScheme) var colorScheme
    
    // Animated color state
    @State private var startColor: Color = .white
    @State private var endColor: Color = .teal
    @State private var colorToggle = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                
                ZStack {
                    // Conditional background color
                    LinearGradient(
                        gradient: Gradient(colors: [startColor, endColor]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // Center the entire “Age” block in the middle of the screen
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Text("Your age is")
                            .font(.system(size: width * 0.04, design: .monospaced))
                            .foregroundColor(.primary) // adjusts automatically in light/dark
                        
                        Text(String(format: "%.8f", userAge))
                            .font(.system(size: width * 0.13, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("years")
                            .font(.system(size: width * 0.1, design: .monospaced))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Toolbar with Settings Button
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .font(.system(size: 20, weight: .regular)) // Adjust icon size
                            .foregroundColor(.primary) // Match the icon color to the current theme
                    }
                    .padding(8)
                }
            }
            // Present the splash screen in a full screen cover
            .fullScreenCover(
                isPresented: $isShowingSplash,
                onDismiss: {
                    print("Splash dismissed; re-checking birthDate")

                    let defaults = UserDefaults(suiteName: "group.com.jaskirat.singh.ageflow.AgeFlow")
                    
                    if let savedDate = defaults?.object(forKey: "userBirthDate") as? Date {
                        birthDate = savedDate
                        startAgeTimer()
                    }
                }
            ) {
                newUserSplashScreen(isPresented: $isShowingSplash, birthDate: Binding(
                    get: { birthDate ?? Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1))! },
                    set: { birthDate = $0 }
                ))
            }
            // Present the settings page as a full-screen cover
            .fullScreenCover(isPresented: $isShowingSettings) {
                SettingsView(isPresented: $isShowingSettings, birthDate: $birthDate)
            }
            
            .onAppear {
                // 1) Initialize the animated gradient with appropriate colors for the current mode
                setupInitialColors()
                // 2) Kick off the background animation
                startAnimatingGradient()
                
                // Load the saved birth date from UserDefaults
                let defaults = UserDefaults(suiteName: "group.com.jaskirat.singh.ageflow.AgeFlow")
                if let savedDate = defaults?.object(forKey: "userBirthDate") as? Date {
                    birthDate = savedDate
                    startAgeTimer() // Start the timer with the saved date
                } else {
                    isShowingSplash = true // Show splash screen if no date is set
                }
            }
            
            // Update age when birthDate changes
            .onChange(of: birthDate) { newDate, oldDate in
                guard let newDate = newDate else { return }
                print("Birth date updated to: \(newDate) (was \(String(describing: oldDate)))")
                startAgeTimer() // Restart the timer with the new date
            }
        }
        // Apply the chosen Light/Dark mode
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    private func startAgeTimer() {
        // Stop any existing timer before starting a new one
        timer?.invalidate()
        
        guard let storedBirthDate = birthDate else { return }
        
        // Create a new timer to update the age every 0.01 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            userAge = calculateAge(birthDate: storedBirthDate)
        }
    }
    
    // MARK: - Set Initial Colors for Light/Dark
    private func setupInitialColors() {
        if isDarkMode {
            startColor = .black
            endColor   = .indigo
        } else {
            startColor = .white
            endColor   = .teal
        }
    }
        
    // MARK: - Animate the Gradient
    private func startAnimatingGradient() {
        Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 20.0)) {
                colorToggle.toggle()
                
                if isDarkMode {
                    // Dark-mode palette
                    startColor = colorToggle ? .indigo   : .gray
                    endColor   = colorToggle ? .black  : .blue
                } else {
                    // Light-mode palette
                    startColor = colorToggle ? .teal   : .cyan
                    endColor   = colorToggle ? .pink : .white
                }
            }
        }
    }
}

// MARK: - Helper Functions

func calculateAge(birthDate: Date) -> Double {
    let now = Date()
    let timeInterval = now.timeIntervalSince(birthDate)
    // 1 year ≈ 365.2422 days (more accurate than 365.25)
    return timeInterval / (60 * 60 * 24 * 365.2422)
}

#Preview {
    ContentView()
}
