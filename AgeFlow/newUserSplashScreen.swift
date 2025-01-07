import SwiftUI

struct newUserSplashScreen: View {
    // A binding to let us communicate back to the parent if the user is done
    @Binding var isPresented: Bool
    @Binding var birthDate: Date? // Binding to update the birthDate in ContentView
    
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
                        UserDefaults.standard.set(selectedDate, forKey: "userBirthDate")
                        print("Saved birthDate to UserDefaults: \(selectedDate)")
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
}
