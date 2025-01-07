import SwiftUI
import WidgetKit

struct newUserSplashScreen: View {
    // A binding to let us communicate back to the parent if the user is done
    @Binding var isPresented: Bool
    @Binding var birthDate: Date? // Binding to update the birthDate in ContentView
    
    @State private var startColor: Color = .red
    @State private var endColor: Color = .white
    @State private var colorToggle = false // Toggle to switch colors
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [startColor, endColor]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .onAppear {
                    startAnimatingGradient()
                }
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("AgeFlow")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text("Please provide your birth date for your age to be calculated.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
                
                // A date picker for selecting a birthday — disallow future dates
                DatePicker("Birth Date",
                           selection: Binding(
                               get: { birthDate ?? Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1))! },
                               set: { birthDate = $0 }
                           ),
                           in: ...Date(),             // from the distant past up to "now"
                           displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())  // Show month/day/year all at once
                    .labelsHidden()
                    .padding()
                    .background(Color.white.cornerRadius(8))
                
                Button(action: {
                    // When user taps "Done":
                    if let selectedDate = birthDate {
                        let defaults = UserDefaults(suiteName: "group.com.jaskirat.singh.ageflow.AgeFlow")
                        defaults?.set(selectedDate, forKey: "userBirthDate")
                        print("Saved birthDate to UserDefaults: \(selectedDate)")
                        
                        // Update widget
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    isPresented = false  // Dismiss the splash
                }) {
                    Text("Done")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
    
    private func startAnimatingGradient() {
            Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 10.0)) {
                    colorToggle.toggle()
                    startColor = colorToggle ? .teal : .cyan
                    endColor = colorToggle ? .purple : .white
                }
            }
        }
}

#Preview {
    newUserSplashScreen(isPresented: .constant(true), birthDate: .constant(Date()))
}
