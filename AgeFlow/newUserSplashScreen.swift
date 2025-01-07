import SwiftUI

struct newUserSplashScreen: View {
    // A binding to let us communicate back to the parent if the user is done
    @Binding var isPresented: Bool
    
    // Temporary storage for birthDate while user picks it
    @State private var tempBirthDate = Date()
    
    var body: some View {
        ZStack {
            Color(.systemBlue)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Welcome!")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text("Please provide your birth date so we can calculate your age.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
                
                // A date picker for selecting a birthday — disallow future dates
                DatePicker("Birth Date",
                           selection: $tempBirthDate,
                           in: ...Date(),             // from the distant past up to "now"
                           displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())  // Show month/day/year all at once
                    .labelsHidden()
                    .padding()
                    .background(Color.white.cornerRadius(8))
                
                Button(action: {
                    // When user taps "Done":
                    saveBirthDate(tempBirthDate)
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
    
    /// Save the birthDate to UserDefaults for future launches
    private func saveBirthDate(_ date: Date) {
        UserDefaults.standard.set(date, forKey: "userBirthDate")
        print("Saved birthDate to UserDefaults: \(tempBirthDate)")
    }
}
